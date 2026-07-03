if (global.game_won || global.game_over) {
	instance_destroy()
	exit
}

if (!instance_exists(obj_Tad)) {
	instance_destroy()
	exit
}

var _t = obj_Tad
var _dist = CharDistInst(id, _t)
var _f = global.fame
var _chase_spd = (2.2 + min(_f * 0.045, 3.5)) * 0.75

var _xl = global.inner_left
var _xr = global.inner_right
var _yt = global.inner_top
var _yb = global.inner_bottom

var _fwd = TadForwardSign()
var _pads = CameraLeadWorldPads()
var _lead_ahead = _pads[0]
var _lead_behind = _pads[1]
var _dx = x - _t.x
var _despawn_use = _despawn_dist + ((_dx * _fwd > 0) ? _lead_ahead : _lead_behind)

var _vx = 0
var _vy = 0
var _fps = game_get_speed(gamespeed_fps)

var _goal_x = _t.x + (_approach_from_left ? -_lead_dist : _lead_dist)
var _goal_y = _t.y
var _goal_dist = point_distance(x, y, _goal_x, _goal_y)

switch (_phase) {
	case MyungPhase.Run:
		sprite_index = spr_Myung_Walking
		if (_goal_dist > _snap_arrive_dist) {
			var _dir = point_direction(x, y, _goal_x, _goal_y)
			var _run_spd = _chase_spd * _run_speed_mult
			_vx = lengthdir_x(_run_spd, _dir)
			_vy = lengthdir_y(_run_spd, _dir)
		} else {
			_vx = 0
			_vy = 0
			_phase = MyungPhase.Snap
			_phase_timer = AnimLengthSteps(spr_Myung_Snap, 10)
			sprite_index = spr_Myung_Snap
			image_index = 0
			image_speed = 1
			if (_t.x >= x) {
				image_xscale = 1
			} else {
				image_xscale = -1
			}
		}
		if (_dist > _despawn_use) {
			instance_destroy()
			exit
		}
		break

	case MyungPhase.Snap:
		sprite_index = spr_Myung_Snap
		_vx = 0
		_vy = 0
		if (_t.x >= x) {
			image_xscale = 1
		} else {
			image_xscale = -1
		}
		_phase_timer -= 1
		if (_phase_timer <= 0) {
			image_index = sprite_get_number(spr_Myung_Snap) - 1
			image_speed = 0
			_flash_capture_armed = true
		}
		break

	case MyungPhase.Flee:
		sprite_index = spr_Myung_Walking
		var _fspd = _chase_spd * 1.85
		_vx = lengthdir_x(_fspd, _flee_dir)
		_vy = lengthdir_y(_fspd, _flee_dir)
		_flee_timer_frames -= 1
		if (_flee_timer_frames <= 0) {
			instance_destroy()
			exit
		}
		if (_dist > _despawn_use) {
			instance_destroy()
			exit
		}
		break
}

var _maps = global.g_wall_tilemaps
if (_maps != undefined) {
	MoveTilesAndShops(id, _vx, _vy, _maps)
} else {
	x += _vx
	y += _vy
}

x = clamp(x, _xl, _xr)
y = clamp(y, _yt, _yb)

if (_phase != MyungPhase.Snap) {
	FanCrowdSeparate(id)
	x = clamp(x, _xl, _xr)
	y = clamp(y, _yt, _yb)
}

depth = -y
if (_phase == MyungPhase.Run) {
	if (_vx > 0.02) {
		image_xscale = 1
	} else if (_vx < -0.02) {
		image_xscale = -1
	}
}

if (view_enabled && view_visible[0]) {
	var _vxw = camera_get_view_x(view_camera[0])
	var _vyw = camera_get_view_y(view_camera[0])
	var _vww = camera_get_view_width(view_camera[0])
	var _vhh = camera_get_view_height(view_camera[0])
	var _trail_m = 520 + _lead_behind
	var _lead_m = 520 + _lead_ahead * 0.4
	var _off = false
	if (_fwd > 0) {
		_off = (x < _vxw - _trail_m || x > _vxw + _vww + _lead_m || y < _vyw - _trail_m || y > _vyw + _vhh + _trail_m)
	} else {
		_off = (x < _vxw - _lead_m || x > _vxw + _vww + _trail_m || y < _vyw - _trail_m || y > _vyw + _vhh + _trail_m)
	}
	if (_off && _phase == MyungPhase.Flee) {
		instance_destroy()
	}
}
