// M toggles music: mute stops playback; unmute restarts the track.
if (keyboard_check_pressed(ord("M"))) {
	_bgm_muted = !_bgm_muted
	if (_bgm_muted) {
		if (_bgm_handle != -1 && audio_is_playing(_bgm_handle)) {
			audio_stop_sound(_bgm_handle)
		}
		_bgm_handle = -1
		alarm[1] = -1
	} else {
		MusicPlayBgm()
	}
}

if (global.game_won || global.game_over) {
	exit
}

var _fps = game_get_speed(gamespeed_fps)
if (_fps < 1) {
	_fps = 60
}

if (global.match_countdown_frames > 0) {
	global.match_countdown_frames -= 1
} else {
	global.fame_decay_elapsed_frames += 1
	var _t = global.fame_decay_elapsed_frames / _fps
	var _rate = 5
	if (_t >= 40) {
		_rate = 100
	} else if (_t >= 30) {
		_rate = 50
	} else if (_t >= 20) {
		_rate = 20
	} else if (_t >= 10) {
		_rate = 10
	}

	global._fame_drain_buffer += _rate / _fps
	if (global._fame_drain_buffer >= 1) {
		var _sub = floor(global._fame_drain_buffer)
		global.fame = max(0, global.fame - _sub)
		global._fame_drain_buffer -= _sub
	}

	if (global.fame <= 0) {
		global.game_over = true
		global.fame = 0
	}
}
