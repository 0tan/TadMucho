if (global.game_won || global.game_over) {
	exit
}

if (!view_enabled || !view_visible[0]) {
	exit
}

if (!instance_exists(obj_Tad)) {
	exit
}

var _cam = view_camera[0]
var _vw = camera_get_view_width(_cam)
var _vh = camera_get_view_height(_cam)
var _t = obj_Tad

// Leading: at speed, keep ~1/3 of view width behind Tad along X (2/3 ahead) for corridor runs.
// Smooth cam_lead_frac so it does not snap to center when velocity drops (e.g. autograph stun).
var _sp = point_distance(0, 0, _t._speedx, _t._speedy)
var _sp_ref = max(_t._maxspeed * 0.75, 3.5)
var _k = clamp(_sp / _sp_ref, 0, 1)

var _frac_want = 0.5
if (_k > 0.04 && abs(_t._speedx) > abs(_t._speedy) * 0.45) {
	if (_t._speedx > 0) {
		_frac_want = lerp(0.5, 1 / 3, _k)
	} else {
		_frac_want = lerp(0.5, 2 / 3, _k)
	}
}

var _lead_smooth = 0.08
if (_t._autograph_lock_count > 0) {
	_lead_smooth = 0.035
}
global.cam_lead_frac = lerp(global.cam_lead_frac, _frac_want, _lead_smooth)

var _aim_x = _t.x - _vw * global.cam_lead_frac
var _aim_y = _t.y - _vh * 0.5

// Keep the centered CAM_LOGIC_W x CAM_LOGIC_H "focus" rect inside inner walk bounds (1920 view has overscan margins).
var _logic_w = global.CAM_LOGIC_W
var _logic_h = global.CAM_LOGIC_H

var _mx = (_vw - _logic_w) * 0.5
var _my = (_vh - _logic_h) * 0.5

var _lo_x = max(0, global.inner_left - _mx)
var _hi_x = min(room_width - _vw, global.inner_right - _mx - _logic_w)
var _lo_y = max(0, global.inner_top - _my)
var _hi_y = min(room_height - _vh, global.inner_bottom - _my - _logic_h)

if (_hi_x < _lo_x) {
	var _mid = (global.inner_left + global.inner_right) * 0.5
	_lo_x = clamp(_mid - _vw * 0.5, 0, room_width - _vw)
	_hi_x = _lo_x
}
if (_hi_y < _lo_y) {
	var _midy = (global.inner_top + global.inner_bottom) * 0.5
	_lo_y = clamp(_midy - _vh * 0.5, 0, room_height - _vh)
	_hi_y = _lo_y
}

var _cx = clamp(_aim_x, _lo_x, _hi_x)
var _cy = clamp(_aim_y, _lo_y, _hi_y)

var _smooth = 0.09
if (_t._autograph_lock_count > 0) {
	_smooth = 0.05
}
var _px = camera_get_view_x(_cam)
var _py = camera_get_view_y(_cam)
_cx = lerp(_px, _cx, _smooth)
_cy = lerp(_py, _cy, _smooth)
_cx = clamp(_cx, _lo_x, _hi_x)
_cy = clamp(_cy, _lo_y, _hi_y)

camera_set_view_pos(_cam, _cx, _cy)
