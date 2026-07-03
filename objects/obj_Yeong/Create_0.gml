_my_walls = -1

_phase = YeongPhase.Run
_phase_timer = 0

_launch_range = 190
_hug_radius = 44
_fly_hit_radius = 40
_run_speed = 2.4
_fly_speed = 5.5
_despawn_dist = 2300

_flee_dir = 0
_fly_dir = 0
_hug_done = false
_hug_slot = 0

sprite_index = spr_Yeong_Run
image_speed = 1
if (instance_exists(obj_Tad)) {
	image_xscale = (obj_Tad.x >= x) ? 1 : -1
} else {
	image_xscale = 1
}
