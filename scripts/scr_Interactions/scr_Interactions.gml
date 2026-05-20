/// Jinwoo FSM phases (shared with Tad alarm handoff).
enum JinwooPhase {
	Patrol,
	NoticeStun,
	Pursue,
	Autograph,
	Flee,
}

// Fan tiers (for future spawn tables): higher fame shifts roll toward higher tiers.
// Tier 0: elderly citizen — does not chase; on collision, reduce Tad speed toward a moderate floor (not implemented).
// Tier 1: Jinwoo (current). Tier 2: Yeong. Tier 3: Myung.
enum NpcTier {
	Elder = 0,
	Jinwoo = 1,
	Yeong = 2,
	Myung = 3,
}

function AwardFame(_amount) {
	if (_amount == undefined) {
		_amount = 0
	}
	global.fame += _amount
}

/// Frames until obj_NPCManager's next spawn attempt. Uses min(fame, FAME_SPAWN_CAP) so pressure stops rising after 200.
/// Uncapped global.fame is reserved for future weighted tier rolls inside the manager.
function JinwooSpawnDelayFrames() {
	var _cap = global.FAME_SPAWN_CAP
	if (_cap == undefined) {
		_cap = 200
	}
	var _f = min(global.fame, _cap)
	return max(48, 140 - floor(_f * 0.46))
}

/// +1 toward club / run direction, -1 when clearly moving left.
function TadForwardSign() {
	if (!instance_exists(obj_Tad)) {
		return 1
	}
	with (obj_Tad) {
		if (abs(_speedx) > abs(_speedy) * 0.35 && abs(_speedx) > 0.35) {
			return sign(_speedx)
		}
		var _club = instance_find(obj_Club, 0)
		if (_club != noone) {
			return sign(_club.x - x)
		}
		return 1
	}
}

/// World-space lead pads from camera framing [ahead, behind] along X.
function CameraLeadWorldPads() {
	var _frac = global.cam_lead_frac
	if (_frac == undefined) {
		_frac = 0.5
	}
	if (!view_enabled || !view_visible[0]) {
		return [0, 0]
	}
	var _vw = camera_get_view_width(view_camera[0])
	return [_vw * (1 - _frac), _vw * _frac]
}

/// Each Jinwoo autograph stacks: Tad stays locked until all locks release (overlapping durations OK).
function Tad_RegisterAutographLock() {
	if (!instance_exists(obj_Tad)) {
		return
	}
	with (obj_Tad) {
		_autograph_lock_count++
		_interaction_kind = "autograph"
		_speedx = 0
		_speedy = 0
		sprite_index = spr_Tad_Mucho_Autograph
		image_index = 0
	}
}

function Tad_ReleaseAutographLock() {
	if (!instance_exists(obj_Tad)) {
		return
	}
	with (obj_Tad) {
		_autograph_lock_count = max(0, _autograph_lock_count - 1)
		if (_autograph_lock_count <= 0) {
			_autograph_lock_count = 0
			_interaction_kind = ""
			_interaction_partner = noone
			sprite_index = spr_Tad_Mucho_Run
		}
	}
}

/// Slot index for fan-out around Tad (before increment); pass result into Jinwoo after Register.
function Tad_PeekAutographSlot() {
	if (!instance_exists(obj_Tad)) {
		return 0
	}
	with (obj_Tad) {
		return _autograph_lock_count
	}
}
