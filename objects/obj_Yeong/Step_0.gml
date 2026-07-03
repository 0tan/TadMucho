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
_run_speed = _chase_spd
_fly_speed = _chase_spd * 2.35

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

// Touch-close hug any time except Miss (stunned) and after she already hugged once.
if (_phase != YeongPhase.Miss && _phase != YeongPhase.Hug && _phase != YeongPhase.Flee && !_hug_done && _dist < _hug_radius) {
	_hug_slot = 0
	with (obj_Tad) {
		_hug_slot = _hug_slow_stacks
	}
	_phase = YeongPhase.Hug
	_phase_timer = max(1, round(1.3 * _fps))
	sprite_index = spr_Yeong_Hug
	image_index = 0
	image_speed = 5 / _fps
	Tad_RegisterHugSlowdown()
	AwardFame(global.YEONG_HUG_FAME_REWARD)
}

switch (_phase) {
	case YeongPhase.Run:
		sprite_index = spr_Yeong_Run
		image_speed = 1
		var _dir = point_direction(x, y, _t.x, _t.y)
		_vx = lengthdir_x(_run_speed, _dir)
		_vy = lengthdir_y(_run_speed, _dir)
		if (_dist < _launch_range) {
			_phase = YeongPhase.Launch
			_phase_timer = AnimLengthSteps(spr_Yeong_Launch, 5)
			sprite_index = spr_Yeong_Launch
			image_index = 0
			image_speed = 5 / _fps
			_vx = 0
			_vy = 0
		}
		if (_dist > _despawn_use) {
			instance_destroy()
			exit
		}
		break

	case YeongPhase.Launch:
		sprite_index = spr_Yeong_Launch
		_vx = 0
		_vy = 0
		if (_t.x > x) {
			image_xscale = 1
		} else {
			image_xscale = -1
		}
		_phase_timer -= 1
		if (_phase_timer <= 0) {
			_phase = YeongPhase.Fly
			_fly_dir = point_direction(x, y, _t.x, _t.y)
			_phase_timer = max(1, round(0.75 * _fps))
			sprite_index = spr_Yeong_Fly
			image_index = 0
			image_speed = 6 / _fps
			if (lengthdir_x(1, _fly_dir) > 0) {
				image_xscale = 1
			} else {
				image_xscale = -1
			}
		}
		break

	case YeongPhase.Fly:
		sprite_index = spr_Yeong_Fly
		_vx = lengthdir_x(_fly_speed, _fly_dir)
		_vy = lengthdir_y(_fly_speed, _fly_dir)
		if (_dist < _fly_hit_radius) {
			AwardFame(global.YEONG_FLY_FAME_REWARD)
			_phase = YeongPhase.Run
			sprite_index = spr_Yeong_Run
			image_speed = 1
			break
		}
		_phase_timer -= 1
		if (_phase_timer <= 0) {
			_phase = YeongPhase.Miss
			_phase_timer = max(1, round(2 * _fps))
			sprite_index = spr_Yeong_Miss
			image_index = 0
			image_speed = 5 / _fps
			_vx = 0
			_vy = 0
		}
		break

	case YeongPhase.Miss:
		sprite_index = spr_Yeong_Miss
		_vx = 0
		_vy = 0
		_phase_timer -= 1
		if (_phase_timer <= 0) {
			_phase = YeongPhase.Run
			sprite_index = spr_Yeong_Run
			image_index = 0
			image_speed = 1
		}
		break

	case YeongPhase.Hug:
		sprite_index = spr_Yeong_Hug
		_vx = 0
		_vy = 0
		var _hug_ox = YeongHugOffsetX(_hug_slot)
		x = clamp(_t.x + _hug_ox, _xl, _xr)
		y = clamp(_t.y, _yt, _yb)
		if (_t.x > x) {
			image_xscale = 1
		} else {
			image_xscale = -1
		}
		_phase_timer -= 1
		if (_phase_timer <= 0) {
			Tad_ReleaseHugSlowdown()
			_hug_done = true
			_phase = YeongPhase.Flee
			_flee_dir = point_direction(_t.x, _t.y, x, y)
			_phase_timer = max(1, round(1.8 * _fps))
			sprite_index = spr_Yeong_Run
			image_speed = 1
		}
		break

	case YeongPhase.Flee:
		sprite_index = spr_Yeong_Run
		image_speed = 1.2
		var _fspd = _chase_spd * 1.85
		_vx = lengthdir_x(_fspd, _flee_dir)
		_vy = lengthdir_y(_fspd, _flee_dir)
		_phase_timer -= 1
		if (_phase_timer <= 0 || _dist > _despawn_use) {
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

if (_phase != YeongPhase.Hug) {
	FanCrowdSeparate(id)
	x = clamp(x, _xl, _xr)
	y = clamp(y, _yt, _yb)
}

depth = -y
if (_vx > 0.02) {
	image_xscale = 1
} else if (_vx < -0.02) {
	image_xscale = -1
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
	if (_off && _phase == YeongPhase.Flee) {
		instance_destroy()
	}
}
