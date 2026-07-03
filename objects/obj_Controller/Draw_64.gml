draw_set_font(Font1)

var _gw = display_get_gui_width()
var _gh = display_get_gui_height()

// Draw GUI scissor uses back-buffer pixels; a tight scissor can clip HUD after the view pans (HTML5).
var _prev_scissor = gpu_get_scissor()
var _bw = window_get_width()
var _bh = window_get_height()
if (_bw > 0 && _bh > 0) {
	gpu_set_scissor(0, 0, _bw, _bh)
}

if (!global.game_won) {
	var _fps_hud = game_get_speed(gamespeed_fps)
	if (_fps_hud < 1) {
		_fps_hud = 60
	}
	var _rem_s = max(0, ceil(global.match_countdown_frames / _fps_hud))
	var _mm = _rem_s div 60
	var _ss = _rem_s mod 60
	var _timer_str = string(_mm) + ":" + ((_ss < 10) ? "0" : "") + string(_ss)
	draw_set_halign(fa_center)
	draw_set_valign(fa_top)
	draw_set_color(c_fuchsia)
	draw_text_transformed(_gw * 0.5, 18, _timer_str, 1.65, 1.65, 0)
}

draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_set_color(c_white)
draw_text_transformed(16, 16, "PROTOTYPE - WASD / arrows - reach the club", 1, 1, 0)

// Player-facing fame (Draw GUI — same in builds and IDE; not the debugger overlay).
var _fame_y = 36
var _fame_s = 1.15
var _fame_pre = "* FAME * - "
draw_set_color(make_color_rgb(0, 255, 255))
draw_text_transformed(16, _fame_y, _fame_pre, _fame_s, _fame_s, 0)
draw_set_color(c_yellow)
draw_text_transformed(16 + string_width(_fame_pre) * _fame_s, _fame_y, string(global.fame), _fame_s, _fame_s, 0)

draw_set_color(c_aqua)
draw_text_transformed(16, 58, "Seed: " + string(global.level_seed), 0.75, 0.75, 0)

var _hud = 0.75
if (instance_exists(obj_Tad)) {
	var _tx = floor(obj_Tad.x)
	var _ty = floor(obj_Tad.y)
	var _vx = 0
	var _vy = 0
	if (view_enabled && view_visible[0]) {
		_vx = floor(camera_get_view_x(view_camera[0]))
		_vy = floor(camera_get_view_y(view_camera[0]))
	}
	var _club_inst = instance_find(obj_Club, 0)
	var _club_dx = "n/a"
	var _club_dx_num = 0
	if (_club_inst != noone) {
		_club_dx_num = _club_inst.x - _tx
		_club_dx = string(floor(_club_dx_num))
	}
	var _line = "Tad world: (" + string(_tx) + ", " + string(_ty) + ")   view TL: (" + string(_vx) + ", " + string(_vy) + ")   club dX: " + _club_dx
	draw_text_transformed(16, 78, _line, _hud, _hud, 0)

	if (_club_inst != noone && _club_dx_num > 800) {
		draw_set_halign(fa_right)
		draw_set_valign(fa_middle)
		draw_set_color(make_color_rgb(0, 255, 255))
		draw_text_transformed(_gw - 16, _gh * 0.5, string(floor(_club_dx_num / 20)) + " >", 1.15, 1.15, 0)
		draw_set_halign(fa_left)
		draw_set_valign(fa_top)
	}
} else {
	draw_text_transformed(16, 78, "Tad world: (no instance)", _hud, _hud, 0)
}

if (global.game_over) {
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_set_color(make_color_rgb(220, 60, 60))
	draw_text_transformed(_gw * 0.5, _gh * 0.5 - 120, "GAME OVER", 7, 7, 0)
	draw_set_color(c_white)
	draw_text_transformed(_gw * 0.5, _gh * 0.5, "Fame reached zero.", 2.5, 2.5, 0)
	draw_text_transformed(_gw * 0.5, _gh * 0.5 + 100, "Press SPACE to exit", 2, 2, 0)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	if (keyboard_check_pressed(vk_space)) {
		game_end()
	}
} else if (global.game_won) {
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_set_color(c_yellow)
	draw_text_transformed(_gw * 0.5, _gh * 0.5 - 120, "VICTORY!", 8, 8, 0)
	draw_text_transformed(_gw * 0.5, _gh * 0.5, "Reach the club - prototype goal met.", 2.5, 2.5, 0)
	draw_text_transformed(_gw * 0.5, _gh * 0.5 + 100, "Press SPACE to exit", 2, 2, 0)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	if (keyboard_check_pressed(vk_space)) {
		game_end()
	}
}

gpu_set_scissor(_prev_scissor)
