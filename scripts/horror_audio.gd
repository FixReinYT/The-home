extends Node

var ambient_player: AudioStreamPlayer
var threat_player: AudioStreamPlayer
var creak_player: AudioStreamPlayer
var _creak_timer := 18.0

func _ready() -> void:
	var ambient := _make_ambient()
	var heartbeat := _make_heartbeat()
	var creak := _make_creak()
	ambient_player = AudioStreamPlayer.new()
	ambient_player.stream = ambient
	ambient_player.volume_db = -14.0
	add_child(ambient_player)
	ambient_player.play()
	threat_player = AudioStreamPlayer.new()
	threat_player.stream = heartbeat
	threat_player.volume_db = -30.0
	add_child(threat_player)
	threat_player.play()
	creak_player = AudioStreamPlayer.new()
	creak_player.stream = creak
	creak_player.volume_db = -19.0
	add_child(creak_player)

func _process(delta: float) -> void:
	_creak_timer -= delta
	if _creak_timer <= 0.0:
		_creak_timer = randf_range(20.0, 38.0)
		if randf() < 0.7 and not creak_player.playing:
			creak_player.pitch_scale = randf_range(0.82, 1.1)
			creak_player.play()

func set_threat(distance: float, chasing: bool) -> void:
	var proximity := clampf(1.0 - distance / 13.0, 0.0, 1.0)
	var target_db := lerpf(-30.0, -8.0, proximity)
	if chasing:
		target_db = maxf(target_db, -6.0)
	threat_player.volume_db = move_toward(threat_player.volume_db, target_db, 22.0 * get_process_delta_time())
	threat_player.pitch_scale = 0.92 + proximity * 0.22

func _wav(samples: PackedFloat32Array, looped: bool) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for i in range(samples.size()):
		bytes.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 32767.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	wav.data = bytes
	if looped:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = samples.size()
	return wav

func _make_ambient() -> AudioStreamWAV:
	var rate := 22050
	var count := rate * 12
	var samples := PackedFloat32Array()
	samples.resize(count)
	var rng := RandomNumberGenerator.new()
	rng.seed = 73021
	var low_noise := 0.0
	for i in range(count):
		var t := float(i) / rate
		low_noise = low_noise * 0.985 + rng.randf_range(-1.0, 1.0) * 0.015
		var drone := sin(TAU * 43.0 * t) * 0.16
		drone += sin(TAU * 51.7 * t + 0.7) * 0.09
		drone += sin(TAU * 27.3 * t + sin(t * 0.17)) * 0.08
		var wind := low_noise * (0.18 + 0.08 * sin(t * 0.31))
		var distant := sin(TAU * 112.0 * t + sin(t * 0.09) * 2.0) * 0.018
		samples[i] = (drone + wind + distant) * 0.55
	return _wav(samples, true)

func _make_heartbeat() -> AudioStreamWAV:
	var rate := 22050
	var count := rate * 2
	var samples := PackedFloat32Array()
	samples.resize(count)
	for i in range(count):
		var t := float(i) / rate
		var phase := fposmod(t, 0.92)
		var env := 0.0
		if phase < 0.12:
			env = sin(PI * phase / 0.12)
		elif phase > 0.16 and phase < 0.27:
			env = sin(PI * (phase - 0.16) / 0.11) * 0.62
		samples[i] = sin(TAU * 48.0 * t) * env * 0.42
	return _wav(samples, true)

func _make_creak() -> AudioStreamWAV:
	var rate := 22050
	var count := int(rate * 2.8)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var rng := RandomNumberGenerator.new()
	rng.seed = 4419
	var noise := 0.0
	for i in range(count):
		var t := float(i) / rate
		var env := clampf(t / 0.18, 0.0, 1.0) * clampf((2.8 - t) / 0.55, 0.0, 1.0)
		noise = noise * 0.94 + rng.randf_range(-1.0, 1.0) * 0.06
		var groan := sin(TAU * (185.0 - 70.0 * t) * t) * 0.35
		groan += sin(TAU * (92.0 + 18.0 * sin(t * 3.0)) * t) * 0.2
		samples[i] = (groan + noise * 0.18) * env * 0.55
	return _wav(samples, false)
