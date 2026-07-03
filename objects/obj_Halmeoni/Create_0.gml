_step_px = 4
_patrol_dir = 1
_despawn_dist = 2400

_stepping = false
_step_start_x = 0
_step_end_x = 0
_step_prog = 0
_prev_anim_frame = 0

if (instance_exists(obj_Tad)) {
	_patrol_dir = (x >= obj_Tad.x) ? -1 : 1
} else {
	_patrol_dir = (x > room_width * 0.5) ? -1 : 1
}

sprite_index = Halmeoni
