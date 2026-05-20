if (global.game_won || global.game_over) {
	instance_destroy()
	exit
}

if (!instance_exists(obj_Tad)) {
	instance_destroy()
	exit
}

var _t = obj_Tad
var _dist = point_distance(x, y, _t.x, _t.y)
var _f = global.fame
var _notice_stun_len = max(25, 73 - floor(min(_f, 80) * 0.49))
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

switch (_phase) {
	case JinwooPhase.Patrol:
		sprite_index = spr_Jinwoo_Walking
		_vx = _patrol_speed * _patrol_dir
		_vy = 0
		if (_dist < _notice_radius) {
			_phase = JinwooPhase.NoticeStun
			_phase_timer = _notice_stun_len
		}
		break

	case JinwooPhase.NoticeStun:
		sprite_index = spr_Jinwoo_Agog
		_vx = 0
		_vy = 0
		if (_t.x > x) {
			image_xscale = 1
		} else {
			image_xscale = -1
		}
		_phase_timer -= 1
		if (_phase_timer <= 0) {
			_phase = JinwooPhase.Pursue
		}
		break

	case JinwooPhase.Pursue:
		sprite_index = spr_Jinwoo_Walking
		var _chdir = point_direction(x, y, _t.x, _t.y)
		_vx = lengthdir_x(_chase_spd, _chdir)
		_vy = lengthdir_y(_chase_spd, _chdir)
		if (_dist < _tight_radius && !_autograph_started) {
			_autograph_slot = Tad_PeekAutographSlot()
			Tad_RegisterAutographLock()
			_autograph_started = true
			_phase = JinwooPhase.Autograph
			var _fps = game_get_speed(gamespeed_fps)
			_autograph_timer_frames = max(1, round(1.5 * _fps))
		}
		if (_dist > _despawn_use) {
			instance_destroy()
			exit
		}
		break

	case JinwooPhase.Autograph:
		sprite_index = spr_Jinwoo_Agog
		_vx = 0
		_vy = 0

		var _ox = 0
		var _oy = 0
		switch (_autograph_slot mod 6) {
			case 0:
				_ox = -56
				_oy = 0
				break
			case 1:
				_ox = 56
				_oy = 0
				break
			case 2:
				_ox = -52
				_oy = -36
				break
			case 3:
				_ox = 52
				_oy = -36
				break
			case 4:
				_ox = -44
				_oy = 40
				break
			default:
				_ox = 44
				_oy = 40
				break
		}
		x = clamp(_t.x + _ox, _xl, _xr)
		y = clamp(_t.y + _oy, _yt, _yb)
		if (_t.x > x) {
			image_xscale = 1
		} else {
			image_xscale = -1
		}

		_autograph_timer_frames -= 1
		if (_autograph_timer_frames <= 0) {
			AwardFame(global.JINWOO_FAME_REWARD)
			Tad_ReleaseAutographLock()
			_autograph_started = false
			_phase = JinwooPhase.Flee
			_flee_dir = point_direction(_t.x, _t.y, x, y)
			_flee_timer_frames = max(1, round(1.8 * game_get_speed(gamespeed_fps)))
		}
		break

	case JinwooPhase.Flee:
		sprite_index = spr_Jinwoo_Autograph
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

// Light separation from other Jinwoos (legacy crowd spacing).
var _list = ds_list_create()
var _sep_r = 38
var _num = collision_circle_list(x, y, _sep_r, obj_Jinwoo, false, true, _list, false)
if (_num > 0) {
	for (var _i = 0; _i < _num; _i++) {
		var _o = _list[| _i]
		if (_o.id == id) {
			continue
		}
		var _dx = x - _o.x
		var _dy = y - _o.y
		var _dd = point_distance(x, y, _o.x, _o.y)
		if (_dd < 0.5) {
			_dd = 0.5
		}
		if (_dd < _sep_r) {
			var _push = (_sep_r - _dd) * 0.38
			x += (_dx / _dd) * _push
			y += (_dy / _dd) * _push
		}
	}
}
ds_list_destroy(_list)

x = clamp(x, _xl, _xr)
y = clamp(y, _yt, _yb)

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
	if (_off && _phase == JinwooPhase.Flee) {
		instance_destroy()
	}
}
