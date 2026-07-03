if (global.game_won || global.game_over) {
	alarm[0] = -1
	exit
}

if (FanNpcCount() >= fan_cap) {
	alarm[0] = JinwooSpawnDelayFrames()
	exit
}

if (!instance_exists(obj_Tad)) {
	alarm[0] = JinwooSpawnDelayFrames()
	exit
}

var _t = obj_Tad
var _xl = global.inner_left
var _xr = global.inner_right
var _yt = global.inner_top
var _yb = global.inner_bottom
var _spawn_margin = 96
var _fwd = TadForwardSign()
var _has_view = (view_enabled && view_visible[0])
var _vxw = 0
var _vyw = 0
var _vww = 0
var _vhh = 0
var _lead_ahead = 0
var _lead_behind = 0
var _logic_l = _xl
var _logic_r = _xr
var _logic_w = global.CAM_LOGIC_W
if (_logic_w == undefined) {
	_logic_w = 1280
}

if (_has_view) {
	_vxw = camera_get_view_x(view_camera[0])
	_vyw = camera_get_view_y(view_camera[0])
	_vww = camera_get_view_width(view_camera[0])
	_vhh = camera_get_view_height(view_camera[0])
	var _frac = global.cam_lead_frac
	if (_frac == undefined) {
		_frac = 0.5
	}
	_lead_ahead = _vww * (1 - _frac)
	_lead_behind = _vww * _frac
	_logic_l = _vxw + (_vww - _logic_w) * 0.5
	_logic_r = _logic_l + _logic_w
}

var _y_wall_buf = 72
var _spawn_y_lo = _yt + _y_wall_buf
var _spawn_y_hi = _yb - _y_wall_buf
if (_spawn_y_hi <= _spawn_y_lo) {
	_spawn_y_lo = _yt
	_spawn_y_hi = _yb
}

var _xx = _t.x
var _yy = _t.y
var _placed = false

for (var _try = 0; _try < 28; _try++) {
	if (random(1) < 0.78 && _has_view) {
		if (_fwd > 0) {
			_xx = _vxw + _vww + _spawn_margin + irandom_range(32, 280)
		} else {
			_xx = _vxw - _spawn_margin - irandom_range(32, 280)
		}
		_yy = irandom_range(_spawn_y_lo, _spawn_y_hi)
	} else if (random(1) < 0.65) {
		var _fa = (_fwd > 0) ? 0 : 180
		var _a = _fa + random_range(-50, 50)
		var _d = 360 + random(760)
		_xx = _t.x + lengthdir_x(_d, _a)
		_yy = irandom_range(_spawn_y_lo, _spawn_y_hi)
		_xx = clamp(_xx, _xl, _xr)
	} else {
		if (_fwd > 0) {
			_xx = clamp(_logic_r + irandom_range(80, _lead_ahead + 320), _xl, _xr)
		} else {
			_xx = clamp(_logic_l - irandom_range(80, _lead_ahead + 320), _xl, _xr)
		}
		_yy = irandom_range(_spawn_y_lo, _spawn_y_hi)
	}

	var _offscreen = true
	if (_has_view) {
		_offscreen = (_xx < _vxw - _spawn_margin || _xx > _vxw + _vww + _spawn_margin || _yy < _vyw - _spawn_margin || _yy > _vyw + _vhh + _spawn_margin)
	}
	var _forward_ok = ((_xx - _t.x) * _fwd > 100)
	if (_offscreen && _forward_ok && CharDist(_xx, _yy, _t.x, _t.y) > 120) {
		_placed = true
		break
	}
}

if (!_placed) {
	if (_has_view) {
		if (_fwd > 0) {
			_xx = clamp(_logic_r + _lead_ahead + irandom_range(64, 260), _xl, _xr)
		} else {
			_xx = clamp(_logic_l - _lead_ahead - irandom_range(64, 260), _xl, _xr)
		}
		_yy = irandom_range(_spawn_y_lo, _spawn_y_hi)
	} else {
		_xx = clamp(_t.x + _fwd * (420 + random(520)), _xl, _xr)
		_yy = irandom_range(_spawn_y_lo, _spawn_y_hi)
	}
}

var _fan_obj = PickFanSpawnObject()
instance_create_layer(_xx, _yy, global.g_inst_layer, _fan_obj)
alarm[0] = JinwooSpawnDelayFrames()
