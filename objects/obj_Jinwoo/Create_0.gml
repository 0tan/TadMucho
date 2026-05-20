_my_walls = -1

_phase = JinwooPhase.Patrol
_phase_timer = 0

_notice_radius = 300
_tight_radius = 44
_patrol_speed = 1.15
// Right of spawn anchor: walk right-to-left (-1). Left: walk left-to-right (+1).
_patrol_dir = 1
if (instance_exists(obj_Tad)) {
	_patrol_dir = (x >= obj_Tad.x) ? -1 : 1
} else {
	_patrol_dir = (x > room_width * 0.5) ? -1 : 1
}
_despawn_dist = 2300

_flee_dir = 0
_flee_timer_frames = 0

_autograph_timer_frames = 0
_autograph_started = false
_autograph_slot = 0

sprite_index = spr_Jinwoo_Walking
image_xscale = (_patrol_dir > 0) ? 1 : -1
