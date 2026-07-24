extends Node2D

@export var master_seed: int = 1337
@export var chunk_size: int = 1024
@export var render_radius: int = 5
@export var pixel_scale: int = 40
@export var use_threads: bool = true

var active_chunks: Dictionary = {}
var pending_chunks: Dictionary = {}
var last_chunk: Vector2i = Vector2i(-999999, -999999)

func _ready() -> void:
	z_index = -100

func _process(_delta: float) -> void:
	var center_pos = global_position
	var cam = get_viewport().get_camera_2d()
	if cam:
		center_pos = cam.global_position
		
	var current_chunk = Vector2i(
		int(floor(center_pos.x / chunk_size)),
		int(floor(center_pos.y / chunk_size))
	)
	
	if current_chunk != last_chunk:
		last_chunk = current_chunk
		_update_chunks(current_chunk)

func _update_chunks(current_chunk: Vector2i) -> void:
	var r2 = render_radius * render_radius

	for x in range(-render_radius, render_radius + 1):
		for y in range(-render_radius, render_radius + 1):
			if x * x + y * y > r2:
				continue
			var coord = current_chunk + Vector2i(x, y)
			if not active_chunks.has(coord) and not pending_chunks.has(coord):
				pending_chunks[coord] = true
				_request_chunk_async(coord)

	var unload_margin = render_radius + 1
	var unload_margin2 = unload_margin * unload_margin
	var to_remove = []
	for coord in active_chunks.keys():
		var dx = coord.x - current_chunk.x
		var dy = coord.y - current_chunk.y
		if dx * dx + dy * dy > unload_margin2:
			to_remove.append(coord)

	for coord in to_remove:
		var sprite = active_chunks[coord]
		active_chunks.erase(coord)
		sprite.queue_free()

func _request_chunk_async(coord: Vector2i) -> void:
	var opts = {"pixel_scale": pixel_scale, "dither": true}
	var c_size = chunk_size
	var m_seed = master_seed
	
	if use_threads:
		WorkerThreadPool.add_task(func():
			var img = generate_chunk_image(coord, c_size, m_seed, opts)
			self.call_deferred("_on_chunk_generated", coord, img)
		)
	else:
		var img = generate_chunk_image(coord, c_size, m_seed, opts)
		_on_chunk_generated(coord, img)

const PALS = [
	{"bg": [3, 4, 18], "layers": [[28,18,210,0.51], [80,10,195,0.56], [110,40,230,0.54]]},
	{"bg": [4, 3, 22], "layers": [[110,12,205,0.49], [55,8,178,0.54], [155,5,195,0.52]]},
	{"bg": [2, 10, 20], "layers": [[0,95,215,0.50], [12,165,235,0.55], [18,48,185,0.53]]},
	{"bg": [14, 3, 6], "layers": [[215,22,38,0.51], [205,72,14,0.55], [225,10,58,0.53]]},
	{"bg": [3, 13, 5], "layers": [[8,172,68,0.51], [28,215,108,0.56], [0,132,172,0.54]]},
	{"bg": [12, 10, 2], "layers": [[215,118,4,0.50], [232,78,8,0.55], [195,168,8,0.53]]}
]

const BAYER = [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5]

func _on_chunk_generated(coord: Vector2i, img: Image) -> void:
	pending_chunks.erase(coord)
	
	var tex = ImageTexture.create_from_image(img)
	
	var sprite = Sprite2D.new()
	sprite.texture = tex
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	sprite.global_position = Vector2(
		(coord.x * chunk_size) + (chunk_size / 2.0),
		(coord.y * chunk_size) + (chunk_size / 2.0)
	)
	
	add_child(sprite)
	active_chunks[coord] = sprite

static func generate_chunk_image(chunk_coord: Vector2i, chunk_size: int, master_seed: int, options: Dictionary = {}) -> Image:
	var px_scale: int = options.get("pixel_scale", 6)
	var dither: bool = options.get("dither", true)

	var sw = int(ceil(float(chunk_size) / px_scale))
	var sh = int(ceil(float(chunk_size) / px_scale))
	
	var chunk_seed = _ih(chunk_coord.x, chunk_coord.y, master_seed)
	
	var pal = PALS[_ih(0, 0, master_seed) % PALS.size()]
	var nSeeds = []
	for i in range(pal["layers"].size()):
		nSeeds.append(_ih(i, 100, master_seed))
	var dSeed = _ih(200, 0, master_seed)
	var wSeed = _ih(300, 0, master_seed)
	
	var sc = 0.0025
	var bayer_mapped = []
	for v in BAYER:
		bayer_mapped.append((v / 16.0 - 0.5) * 28.0)

	# Raw byte buffer instead of Image.set_pixel: set_pixel() carries real
	# per-call overhead (bounds checks, format conversion) that adds up fast
	# over sw*sh pixels. Writing bytes directly and building the Image once
	# at the end is significantly cheaper for a full-chunk fill.
	var data := PackedByteArray()
	data.resize(sw * sh * 4)

	var start_gx = chunk_coord.x * sw
	var start_gy = chunk_coord.y * sh
	
	for y in range(sh):
		var gx = start_gx
		var gy = start_gy + y
		var row_offset = y * sw
		for x in range(sw):
			var current_gx = gx + x
			
			var r: float = pal["bg"][0]
			var g: float = pal["bg"][1]
			var b: float = pal["bg"][2]
			
			var wx = _fbm(current_gx * sc * 0.5, gy * sc * 0.5, wSeed, 3) * 0.4
			var wy = _fbm(current_gx * sc * 0.5 + 5.2, gy * sc * 0.5 + 1.3, wSeed + 71, 3) * 0.4
			
			var layers: Array = pal["layers"]
			for li in range(layers.size()):
				var cr = layers[li][0]
				var cg = layers[li][1]
				var cb = layers[li][2]
				var thresh = layers[li][3]
				
				var n = _fbm(current_gx * sc + wx, gy * sc + wy, nSeeds[li])
				if n > thresh:
					var t = pow((n - thresh) / (1.0 - thresh), 1.5)
					var al = min(t * 0.92, 0.90)
					r += (cr - r) * al
					g += (cg - g) * al
					b += (cb - b) * al
					
			var d2 = _vn(current_gx * sc * 9.0, gy * sc * 9.0, dSeed)
			if d2 > 0.68:
				var dt = (d2 - 0.68) / 0.32 * 0.10
				r += layers[0][0] * dt
				g += layers[0][1] * dt
				b += layers[0][2] * dt
				
			var dk = bayer_mapped[(y & 3) * 4 + (x & 3)] if dither else 0.0
			var idx = (row_offset + x) * 4
			data[idx] = clampi(int(r + dk), 0, 255)
			data[idx + 1] = clampi(int(g + dk), 0, 255)
			data[idx + 2] = clampi(int(b + dk), 0, 255)
			data[idx + 3] = 255
			
	var star_rng = _ih(11, 22, chunk_seed)
	var ns1 = 15 + (star_rng % 20)
	for i in range(ns1):
		var sx = _ih(i, 1, chunk_seed) % sw
		var sy = _ih(i, 2, chunk_seed) % sh
		var v = 80 + (_ih(i, 3, chunk_seed) % 110)
		var sidx = (sy * sw + sx) * 4
		data[sidx] = v
		data[sidx + 1] = v
		data[sidx + 2] = v
		data[sidx + 3] = 255
		
	if (_ih(99, 99, chunk_seed) % 100) < 15:
		var pr = 4 + (_ih(1, 4, chunk_seed) % 5)
		var span_x = max(1, sw - (pr * 2) - 8)
		var span_y = max(1, sh - (pr * 2) - 8)
		var ppx = pr + 4 + (_ih(2, 4, chunk_seed) % span_x)
		var ppy = pr + 4 + (_ih(3, 4, chunk_seed) % span_y)
		var ph = float(_ih(4, 4, chunk_seed) % 1000) / 1000.0
		var v_rgb = _hsl(ph, 0.6, 0.4)
		
		for dy in range(-(pr + 2), pr + 3):
			for dx in range(-(pr + 2), pr + 3):
				var nx = ppx + dx
				var ny = ppy + dy
				if nx < 0 or ny < 0 or nx >= sw or ny >= sh: continue
				var dist = sqrt(dx * dx + dy * dy)
				if dist < pr:
					var pidx = (ny * sw + nx) * 4
					data[pidx] = int(v_rgb.x)
					data[pidx + 1] = int(v_rgb.y)
					data[pidx + 2] = int(v_rgb.z)
					data[pidx + 3] = 255

	var img := Image.create_from_data(sw, sh, false, Image.FORMAT_RGBA8, data)

	if px_scale > 1:
		img.resize(chunk_size, chunk_size, Image.INTERPOLATE_NEAREST)
		
	return img

static func _ih(x: int, y: int, s: int) -> int:
	var mul_x = (x * 1664525) & 0xFFFFFFFF
	var mul_y = (y * 1013904223) & 0xFFFFFFFF
	var mul_s = (s * 2246822519) & 0xFFFFFFFF
	var n = mul_x ^ mul_y ^ mul_s
	n = ((n ^ (n >> 16)) * 0x45d9f3b) & 0xFFFFFFFF
	return (n ^ (n >> 16)) & 0xFFFFFFFF

static func _smt(t: float) -> float:
	return t * t * (3.0 - 2.0 * t)

static func _vn(x: float, y: float, s: int) -> float:
	var ix = int(floor(x))
	var iy = int(floor(y))
	var fx = _smt(x - ix)
	var fy = _smt(y - iy)
	var a = float(_ih(ix, iy, s)) / 4294967296.0
	var b = float(_ih(ix+1, iy, s)) / 4294967296.0
	var c = float(_ih(ix, iy+1, s)) / 4294967296.0
	var d = float(_ih(ix+1, iy+1, s)) / 4294967296.0
	return a + (b - a) * fx + ((c + (d - c) * fx) - (a + (b - a) * fx)) * fy

static func _fbm(x: float, y: float, s: int, oct: int = 5) -> float:
	var v = 0.0
	var a = 0.5
	var f = 1.0
	for i in range(oct):
		v += _vn(x * f, y * f, s + i * 137) * a
		a *= 0.5
		f *= 2.1
	return v

static func _hq(t: float, p: float, q: float) -> float:
	t = fmod(fmod(t, 1.0) + 1.0, 1.0)
	if t < 1.0 / 6.0: return p + (q - p) * 6.0 * t
	if t < 1.0 / 2.0: return q
	if t < 2.0 / 3.0: return p + (q - p) * (2.0 / 3.0 - t) * 6.0
	return p

static func _hsl(h: float, s: float, l: float) -> Vector3:
	var q = l * (1.0 + s) if l < 0.5 else l + s - l * s
	var p = 2.0 * l - q
	if s == 0.0:
		return Vector3(l * 255.0, l * 255.0, l * 255.0)
	else:
		return Vector3(_hq(h + 1.0/3.0, p, q) * 255.0, _hq(h, p, q) * 255.0, _hq(h - 1.0/3.0, p, q) * 255.0)
