if (global.game_won || global.game_over) {
	sprite_index = spr_Tad_Mucho_Stand
	_speedx = 0
	_speedy = 0
	depth = -y
	exit
}

// Movement blocked while any Jinwoo autograph lock is active (locks can overlap).
if (_autograph_lock_count > 0) {
	depth = -y
	exit
}

// Reserved for non-autograph interactions (e.g. Yeong) in v2.
if (_interaction_kind != "") {
	depth = -y
	exit
}

var _left = keyboard_check(vk_left) or keyboard_check(ord("A"))
var _right = keyboard_check(vk_right) or keyboard_check(ord("D"))
var _up = keyboard_check(vk_up) or keyboard_check(ord("W"))
var _down = keyboard_check(vk_down) or keyboard_check(ord("S"))
var _stop = keyboard_check(vk_space)

var _hor = (_right - _left)
var _vert = (_down - _up)
var _newdir = arctan2(_vert, _hor)
var _olddir = arctan2(_speedy, _speedx)
var _speed = point_distance(0, 0, _speedx, _speedy)
if (_speed < 0.1) {
	_newdir = _olddir
	_speedx = _hor * _accelrate
	_speedy = _vert * _accelrate
}
var _da = 2 * pi + _olddir - _newdir
while (_da > pi) _da -= 2 * pi

if (((_speed > _brakerate) && abs(_da) > 2.0) || (_stop)) {
	if (_speedx > _brakerate) _speedx -= _brakerate
	else if (_speedx < -_brakerate) _speedx += _brakerate
	else _speedx = 0
	if (_speedy > _brakerate) _speedy -= _brakerate
	else if (_speedy < -_brakerate) _speedy += _brakerate
	else _speedy = 0
	sprite_index = spr_Tad_Mucho_Slip
} else {
	sprite_index = spr_Tad_Mucho_Run
}

var _d = point_distance(0, 0, _hor, _vert)
if (_d > 1.0) {
	_hor = cos(_newdir)
	_vert = sin(_newdir)
	_d = 1.0
}

_speedx += _hor * _accelrate
_speedy += _vert * _accelrate

if (_d < 0.2) {
	_speedx *= .98
	_speedy *= .98
	if (_speedx > 0.01) _speedx -= 0.01 else if (_speedx < 0.01) _speedx += 0.01 else _speedx = 0
	if (_speedy > 0.01) _speedy -= 0.01 else if (_speedy < -0.01) _speedy += 0.01 else _speedy = 0
}

if (_speed > _maxspeed) {
	_speedx *= (_maxspeed / _speed)
	_speedy *= (_maxspeed / _speed)
} else if (_speed < 0.1) {
	sprite_index = spr_Tad_Mucho_Stand
}

var _maps = global.g_wall_tilemaps
if (_maps != undefined) {
	MoveTilesAndShops(id, _speedx, _speedy, _maps)
} else {
	MoveTilesAndShops(id, _speedx, _speedy, -1)
}

depth = -y
if (_speedx > 0.02) image_xscale = 1
if (_speedx < -0.02) image_xscale = -1
