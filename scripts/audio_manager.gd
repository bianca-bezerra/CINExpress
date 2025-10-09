extends Node2D
@onready var _background_stream = $background
@onready var _sfx_stream = $effects


var _sfxs = {
	"button_hover": preload("res://assets/audio/botao_meleca.mp3"),
	"button_click": preload("res://assets/audio/click_adam_sandler.mp3"),
	"score" : preload("res://assets/audio/pirilimpompom(combo).mp3"),
	"wrong_hit": preload("res://assets/audio/wrong_hit.wav"),
	"text_type": preload("res://assets/audio/text_type.wav"),
	"spinner_sound": preload("res://assets/audio/spinner.mp3"),
	"bang_sound": preload("res://assets/audio/bang.mp3"),
	"flash": preload("res://assets/audio/flash.mp3")
}

func _ready() -> void:
	_background_stream.play()

func toggle_background_song():
	_background_stream.stream_paused = false if _background_stream.stream_paused else true

func play_sfx(sound_name: String, pitch_scale: float = 1.0):
	var song = _sfxs.get(sound_name)
	if not song:
		push_error("O som %s não foi registrado" % song)
	_sfx_stream.stream = song
	_sfx_stream.pitch_scale = pitch_scale
	if not _sfx_stream.playing:
		_sfx_stream.play()

func stop_sfx():
	_sfx_stream.stop()
