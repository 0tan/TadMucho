if (global.game_won || global.game_over) {
	instance_destroy()
	exit
}

var _xl = global.inner_left
var _xr = global.inner_right
var _yt = global.inner_top
var _yb = global.inner_bottom

var _frame = floor(image_index)
var _frame_count = sprite_get_number(sprite_index)
if (_frame_count < 1) {
	_frame_count = 1
}

// Walk cycle frame 10 → 1 (index 9 → 0): lerp 4px in patrol direction.
if (_prev_anim_frame == _frame_count - 1 && _frame == 0 && !_stepping) {
	_step_start_x = x
	_step_end_x = x + _step_px * _patrol_dir
	_step_prog = 0
	_stepping = true
}
_prev_anim_frame = _frame

var _maps = global.g_wall_tilemaps
if (_stepping) {
	_step_prog = min(1, _step_prog + 0.22)
	var _goal_x = lerp(_step_start_x, _step_end_x, _step_prog)
	var _mx = _goal_x - x
	if (_maps != undefined) {
		MoveTilesAndShops(id, _mx, 0, _maps)
	} else {
		x += _mx
	}
	if (_step_prog >= 1) {
		_stepping = false
	}
}

if (x <= _xl + 8) {
	_patrol_dir = 1
}
if (x >= _xr - 8) {
	_patrol_dir = -1
}

x = clamp(x, _xl, _xr)
y = clamp(y, _yt, _yb)

FanCrowdSeparate(id)
x = clamp(x, _xl, _xr)
y = clamp(y, _yt, _yb)

depth = -y
image_xscale = (_patrol_dir > 0) ? 1 : -1

if (instance_exists(obj_Tad)) {
	var _fwd = TadForwardSign()
	var _pads = CameraLeadWorldPads()
	var _lead_ahead = _pads[0]
	var _lead_behind = _pads[1]
	var _dx = x - obj_Tad.x
	var _despawn_use = _despawn_dist + ((_dx * _fwd > 0) ? _lead_ahead : _lead_behind)
	if (abs(_dx) > _despawn_use) {
		instance_destroy()
	}
}
