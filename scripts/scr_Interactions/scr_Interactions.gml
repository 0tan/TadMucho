/// Jinwoo FSM phases (shared with Tad alarm handoff).
enum JinwooPhase {
	Patrol,
	NoticeStun,
	Pursue,
	Autograph,
	Flee,
}

enum YeongPhase {
	Run,
	Launch,
	Fly,
	Miss,
	Hug,
	Flee,
}

enum MyungPhase {
	Run,
	Snap,
	Flee,
}

// Tier 0: Halmeoni — slow walk, no chase/fame; slows Tad when very close.
// Tier 1: Jinwoo. Tier 2: Yeong. Tier 3: Myung.
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

/// Halmeoni spawn weight: 50% at 0 fame → 15% at 350+ fame (linear).
function HalmeoniSpawnChance() {
	var _top = global.HALMEONI_SPAWN_FAME_TOP
	if (_top == undefined || _top <= 0) {
		_top = 350
	}
	var _at0 = global.HALMEONI_SPAWN_AT_0
	if (_at0 == undefined) {
		_at0 = 0.5
	}
	var _at_top = global.HALMEONI_SPAWN_AT_350
	if (_at_top == undefined) {
		_at_top = 0.15
	}
	var _t = clamp(global.fame / _top, 0, 1)
	return _at0 + (_at_top - _at0) * _t
}

/// Spawn tiers: Halmeoni/Jinwoo at 0+, Yeong at 80+, Myung at 150+.
function PickFanSpawnObject() {
	if (random(1) < HalmeoniSpawnChance()) {
		return obj_Halmeoni
	}
	if (global.fame >= global.MYUNG_FAME_MIN) {
		var _myung_chance = 0.15 + min((global.fame - global.MYUNG_FAME_MIN) * 0.002, 0.22)
		if (random(1) < _myung_chance) {
			return obj_Myung
		}
	}
	if (global.fame < global.YEONG_FAME_MIN) {
		return obj_Jinwoo
	}
	var _chance = 0.22 + min((global.fame - global.YEONG_FAME_MIN) * 0.003, 0.38)
	if (random(1) < _chance) {
		return obj_Yeong
	}
	return obj_Jinwoo
}

function FanNpcCount() {
	return instance_number(obj_Jinwoo) + instance_number(obj_Yeong) + instance_number(obj_Halmeoni) + instance_number(obj_Myung)
}

/// Character instances use bottom-center sprite origins; x/y is the feet point.
function CharDist(_ax, _ay, _bx, _by) {
	return point_distance(_ax, _ay, _bx, _by)
}

function CharDistInst(_a, _b) {
	return point_distance(_a.x, _a.y, _b.x, _b.y)
}

/// Playback length in steps for a sprite at _fps (matches sequence-style sprites).
function AnimLengthSteps(_spr, _fps) {
	if (_fps <= 0) {
		_fps = 5
	}
	var _rs = game_get_speed(gamespeed_fps)
	return max(1, round(sprite_get_number(_spr) * _rs / _fps))
}

/// Each hug adds one stack while active; capped at 4 for slowdown strength.
function Tad_RegisterHugSlowdown() {
	if (!instance_exists(obj_Tad)) {
		return
	}
	with (obj_Tad) {
		_hug_slow_stacks++
	}
}

function Tad_ReleaseHugSlowdown() {
	if (!instance_exists(obj_Tad)) {
		return
	}
	with (obj_Tad) {
		_hug_slow_stacks = max(0, _hug_slow_stacks - 1)
	}
}

function Tad_HugSpeedMult() {
	if (!instance_exists(obj_Tad)) {
		return 1
	}
	with (obj_Tad) {
		var _stacks = min(_hug_slow_stacks, 4)
		return max(0.25, 1 - 0.1875 * _stacks)
	}
}

/// Yeong hug and Halmeoni proximity share one pull debuff — never stacked.
function Tad_PullDebuffActive() {
	if (!instance_exists(obj_Tad)) {
		return false
	}
	with (obj_Tad) {
		if (_hug_slow_stacks > 0) {
			return true
		}
	}
	return Tad_NearHalmeoni()
}

function Tad_PullSpeedMult() {
	if (!instance_exists(obj_Tad)) {
		return 1
	}
	with (obj_Tad) {
		if (_hug_slow_stacks > 0) {
			var _stacks = min(_hug_slow_stacks, 4)
			return max(0.25, 1 - 0.1875 * _stacks)
		}
	}
	if (Tad_NearHalmeoni()) {
		var _cap = global.HALMEONI_SPEED_CAP
		if (_cap == undefined) {
			_cap = 0.7
		}
		return _cap
	}
	return 1
}

/// +1 right, -1 left — velocity when moving, else facing.
function Tad_MoveSignX() {
	if (!instance_exists(obj_Tad)) {
		return 1
	}
	with (obj_Tad) {
		if (abs(_speedx) > 0.35) {
			return sign(_speedx)
		}
		return (image_xscale < 0) ? -1 : 1
	}
}

/// Hug anchor beside Tad: slot 0 opposite movement (pulled along); extras either side.
function YeongHugOffsetX(_slot) {
	if (_slot <= 0) {
		return -40 * Tad_MoveSignX()
	}
	return (_slot mod 2 == 1) ? 44 : -48
}

/// True if Tad is within slow radius of any Halmeoni.
function Tad_NearHalmeoni() {
	if (!instance_exists(obj_Tad)) {
		return false
	}
	var _r = global.HALMEONI_SLOW_RADIUS
	if (_r == undefined) {
		_r = 72
	}
	var _tx = obj_Tad.x
	var _ty = obj_Tad.y
	for (var _i = 0; _i < instance_number(obj_Halmeoni); _i++) {
		var _h = instance_find(obj_Halmeoni, _i)
		if (CharDist(_tx, _ty, _h.x, _h.y) < _r) {
			return true
		}
	}
	return false
}

/// Soft push between crowd NPCs so fans do not stack. Halmeoni stays put; others yield.
function FanCrowdSeparate(_inst, _sep_r) {
	if (_sep_r == undefined) {
		_sep_r = 38
	}
	var _push_k = 0.38
	with (_inst) {
		var _types = [obj_Jinwoo, obj_Yeong, obj_Halmeoni, obj_Myung]
		for (var _t = 0; _t < array_length(_types); _t++) {
			var _list = ds_list_create()
			var _num = collision_circle_list(x, y, _sep_r, _types[_t], false, true, _list, false)
			for (var _i = 0; _i < _num; _i++) {
				var _o = _list[| _i]
				if (_o.id == id) {
					continue
				}
				var _pdx = x - _o.x
				var _pdy = y - _o.y
				var _pd = point_distance(0, 0, _pdx, _pdy)
				if (_pd < 0.5) {
					_pd = 0.5
				}
				if (_pd < _sep_r) {
					var _push = (_sep_r - _pd) * _push_k
					if (object_index == obj_Halmeoni) {
						with (_o) {
							x -= (_pdx / _pd) * _push
							y -= (_pdy / _pd) * _push
						}
					} else if (_o.object_index == obj_Halmeoni) {
						x += (_pdx / _pd) * _push
						y += (_pdy / _pd) * _push
					} else {
						x += (_pdx / _pd) * _push
						y += (_pdy / _pd) * _push
					}
				}
			}
			ds_list_destroy(_list)
		}
	}
}

/// Light feet-based push — Tad yields when overlapping Halmeoni.
function Tad_SeparateFromHalmeoni(_sep_r) {
	if (!instance_exists(obj_Tad)) {
		return
	}
	if (_sep_r == undefined) {
		_sep_r = 40
	}
	var _push_k = 0.4
	with (obj_Tad) {
		for (var _i = 0; _i < instance_number(obj_Halmeoni); _i++) {
			var _h = instance_find(obj_Halmeoni, _i)
			var _pdx = x - _h.x
			var _pdy = y - _h.y
			var _pd = point_distance(0, 0, _pdx, _pdy)
			if (_pd < 0.5) {
				_pd = 0.5
			}
			if (_pd < _sep_r) {
				var _push = (_sep_r - _pd) * _push_k
				x += (_pdx / _pd) * _push
				y += (_pdy / _pd) * _push
			}
		}
		if (global.inner_left != undefined) {
			x = clamp(x, global.inner_left, global.inner_right)
			y = clamp(y, global.inner_top, global.inner_bottom)
		}
	}
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

/// Flash anchor on Myung sprite (frame pixels, top-left): camera point when facing right / left.
function MyungFlashAnchorSpritePx(_facing_right) {
	if (_facing_right) {
		return [80, 32]
	}
	return [16, 32]
}

/// World position of the flash anchor (matches Myung sprite pixel at snap time).
function MyungFlashWorldAnchor(_inst) {
	with (_inst) {
		var _spr = sprite_index
		var _ox = sprite_get_xoffset(_spr)
		var _oy = sprite_get_yoffset(_spr)
		var _px = MyungFlashAnchorSpritePx(image_xscale >= 0)
		return [x + _px[0] - _ox, y + _px[1] - _oy]
	}
}

/// 384×384 world capture square (±192) centered on the flash anchor.
function MyungFlashWorldRect(_inst) {
	var _half = global.MYUNG_FLASH_HALF
	if (_half == undefined) {
		_half = 192
	}
	var _a = MyungFlashWorldAnchor(_inst)
	return [_a[0] - _half, _a[1] - _half, _a[0] + _half, _a[1] + _half]
}

/// Map a world-space rect to GUI coords at the current camera framing.
function FlashWorldRectToGui(_wl, _wt, _wr, _wb) {
	if (!view_enabled || !view_visible[0]) {
		return [_wl, _wt, _wr - _wl, _wb - _wt]
	}
	var _cam = view_camera[0]
	var _vx = camera_get_view_x(_cam)
	var _vy = camera_get_view_y(_cam)
	var _vw = camera_get_view_width(_cam)
	var _vh = camera_get_view_height(_cam)
	var _gw = display_get_gui_width()
	var _gh = display_get_gui_height()
	return [
		(_wl - _vx) / _vw * _gw,
		(_wt - _vy) / _vh * _gh,
		(_wr - _wl) / _vw * _gw,
		(_wb - _wt) / _vh * _gh,
	]
}

/// Apply spr_FlashyAlpha frame as an alpha mask on a surface (RGB kept, alpha multiplied).
function FlashApplyCircleMask(_surf, _mask_frame) {
	if (_surf == -1 || !surface_exists(_surf)) {
		return
	}
	if (_mask_frame == undefined) {
		_mask_frame = 1
	}
	var _size = surface_get_width(_surf)
	var _half = _size * 0.5
	var _mask_scale = _size / sprite_get_width(spr_FlashyAlpha)

	surface_set_target(_surf)
	gpu_set_blendmode_ext_sepalpha(bm_zero, bm_dest_color, bm_dest_alpha, bm_zero)
	draw_sprite_ext(spr_FlashyAlpha, _mask_frame, _half, _half, _mask_scale, _mask_scale, 0, c_white, 1)
	gpu_set_blendmode(bm_normal)
	surface_reset_target()
}

/// Build a masked copy of _src into _dst using the given FlashyAlpha frame.
function FlashCompositeMasked(_src, _dst, _mask_frame) {
	if (_src == -1 || !surface_exists(_src) || _dst == -1 || !surface_exists(_dst)) {
		return
	}
	surface_set_target(_dst)
	draw_clear_alpha(c_black, 0)
	gpu_set_blendmode(bm_normal)
	draw_surface(_src, 0, 0)
	surface_reset_target()
	FlashApplyCircleMask(_dst, _mask_frame)
}

/// Copy a world-view region from the application surface into a 384×384 surface.
function FlashCaptureAppRegion(_wl, _wt, _wr, _wb) {
	var _app = application_surface
	if (!surface_exists(_app)) {
		return -1
	}
	if (!view_enabled || !view_visible[0]) {
		return -1
	}
	var _out_size = global.MYUNG_FLASH_SIZE
	if (_out_size == undefined) {
		_out_size = 384
	}
	var _cam = view_camera[0]
	var _vx = camera_get_view_x(_cam)
	var _vy = camera_get_view_y(_cam)
	var _vw = max(1, camera_get_view_width(_cam))
	var _vh = max(1, camera_get_view_height(_cam))
	var _asw = surface_get_width(_app)
	var _ash = surface_get_height(_app)

	var _sx = (_wl - _vx) / _vw * _asw
	var _sy = (_wt - _vy) / _vh * _ash
	var _sw = (_wr - _wl) / _vw * _asw
	var _sh = (_wb - _wt) / _vh * _ash

	_sx = floor(clamp(_sx, 0, _asw - 1))
	_sy = floor(clamp(_sy, 0, _ash - 1))
	_sw = max(1, ceil(min(_sw, _asw - _sx)))
	_sh = max(1, ceil(min(_sh, _ash - _sy)))

	var _out = surface_create(_out_size, _out_size)
	surface_set_target(_out)
	draw_clear_alpha(c_black, 0)
	gpu_set_blendmode(bm_normal)
	draw_surface_part_ext(_app, _sx, _sy, _sw, _sh, 0, 0, _out_size / _sw, _out_size / _sh, c_white, 1)
	surface_reset_target()
	return _out
}

/// End-of-frame snap: grab app-surface crop and pin it on the GUI layer.
function MyungTriggerFlashCapture(_mid) {
	var _rect = MyungFlashWorldRect(_mid)
	var _wl = _rect[0]
	var _wt = _rect[1]
	var _wr = _rect[2]
	var _wb = _rect[3]

	var _gui = FlashWorldRectToGui(_wl, _wt, _wr, _wb)
	var _surf = FlashCaptureAppRegion(_wl, _wt, _wr, _wb)
	FlashCreateFromSurface(_surf, _gui[0], _gui[1], _gui[2], _gui[3])
	AwardFame(global.MYUNG_FAME_REWARD)

	with (_mid) {
		_flash_capture_armed = false
		_phase = MyungPhase.Flee
		if (instance_exists(obj_Tad)) {
			_flee_dir = point_direction(obj_Tad.x, obj_Tad.y, x, y)
		} else {
			_flee_dir = 180
		}
		_flee_timer_frames = max(1, round(1.8 * game_get_speed(gamespeed_fps)))
	}
}

/// GUI-layer paparazzi still: hold, fade, free surface.
function FlashCreateFromSurface(_surf, _gx, _gy, _gw, _gh) {
	if (_surf == -1 || !surface_exists(_surf)) {
		return noone
	}
	var _f = instance_create_depth(-64, -64, -10000, obj_Flash)
	_f.flash_surf = _surf
	_f.flash_comp_surf = surface_create(surface_get_width(_surf), surface_get_height(_surf))
	_f.gui_x = _gx
	_f.gui_y = _gy
	_f.gui_w = _gw
	_f.gui_h = _gh
	var _rs = game_get_speed(gamespeed_fps)
	_f.flash_phase = 0
	_f.alpha = 1
	_f.burst_frames = max(1, round(0.3 * _rs))
	_f.burst_timer = _f.burst_frames
	_f.hold_frames = max(1, round(1.2 * _rs))
	_f.hold_timer = _f.hold_frames
	_f.shrink_frames = max(1, round(0.8 * _rs))
	_f.shrink_timer = _f.shrink_frames
	_f.shrink_mask_count = 8
	return _f
}

/// Play IceyHot once, then reschedule after track length + BGM_PAUSE_SEC silence.
function MusicPlayBgm() {
	if (!instance_exists(obj_Controller)) {
		return
	}
	with (obj_Controller) {
		if (_bgm_muted) {
			exit
		}
		if (_bgm_handle != -1 && audio_is_playing(_bgm_handle)) {
			audio_stop_sound(_bgm_handle)
		}
		_bgm_handle = audio_play_sound(snd_IceyHot, 1, false)
		var _rs = game_get_speed(gamespeed_fps)
		var _pause = global.BGM_PAUSE_SEC
		if (_pause == undefined) {
			_pause = 3
		}
		var _len = audio_sound_length(snd_IceyHot)
		alarm[1] = max(1, round((_len + _pause) * _rs))
	}
}
