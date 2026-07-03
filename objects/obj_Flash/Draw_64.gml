if (!surface_exists(flash_surf)) {
	exit
}

var _cx = gui_x + gui_w * 0.5
var _cy = gui_y + gui_h * 0.5
var _flash_scale = gui_w / sprite_get_width(spr_FlashyAlpha)

if (flash_phase == 0) {
	FlashCompositeMasked(flash_surf, flash_comp_surf, 1)
	if (surface_exists(flash_comp_surf)) {
		draw_surface_stretched_ext(flash_comp_surf, gui_x, gui_y, gui_w, gui_h, c_white, alpha)
	}

	var _elapsed = burst_frames - burst_timer
	var _seg = max(1, burst_frames / 3)
	var _slot = min(2, floor(_elapsed / _seg))
	var _burst_frame = 5
	if (_slot == 1) {
		_burst_frame = 1
	}
	draw_sprite_ext(spr_FlashyAlpha, _burst_frame, _cx, _cy, _flash_scale, _flash_scale, 0, c_white, 1)
	exit
}

var _mask_frame = 1
if (flash_phase == 2) {
	var _elapsed = shrink_frames - shrink_timer
	var _per = max(1, shrink_frames / shrink_mask_count)
	var _idx = min(shrink_mask_count - 1, floor(_elapsed / _per))
	_mask_frame = _idx
}

FlashCompositeMasked(flash_surf, flash_comp_surf, _mask_frame)
if (surface_exists(flash_comp_surf)) {
	draw_surface_stretched_ext(flash_comp_surf, gui_x, gui_y, gui_w, gui_h, c_white, alpha)
}
