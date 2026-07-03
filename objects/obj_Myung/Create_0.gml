_my_walls = -1

_phase = MyungPhase.Run
_phase_timer = 0

_lead_dist = global.MYUNG_LEAD_DIST
if (_lead_dist == undefined) {
	_lead_dist = 300
}
_snap_arrive_dist = 36
_despawn_dist = 2300
_run_speed_mult = 1.5

_flee_dir = 0
_flee_timer_frames = 0
_flash_capture_armed = false

// Left-side spawns snap 300 left of Tad; right-side (default) snap 300 right.
_approach_from_left = false
if (instance_exists(obj_Tad)) {
	_approach_from_left = (x < obj_Tad.x)
	image_xscale = (_approach_from_left) ? -1 : 1
} else {
	image_xscale = 1
}

sprite_index = spr_Myung_Walking
