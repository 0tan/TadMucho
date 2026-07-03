// Prototype v0: corridor bake + reach club. Jinwoo v1: fame + periodic spawns.
global.g_inst_layer = "Instances"
global.game_won = false
global.game_over = false
global.match_countdown_frames = 0
global.fame_decay_elapsed_frames = 0
global._fame_drain_buffer = 0
global.level_seed = irandom(999999)
global.corridor_y = room_height * 0.5
global.inner_left = 128
global.inner_right = max(256, room_width - 128)
global.inner_top = 128
global.inner_bottom = max(256, room_height - 128)
global.fame = 0
global.FAME_SPAWN_CAP = 200
global.JINWOO_FAME_MIN = 0
global.JINWOO_FAME_REWARD = 20
global.HALMEONI_FAME_MIN = 0
global.YEONG_FAME_MIN = 80
global.MYUNG_FAME_MIN = 150
global.MYUNG_FAME_REWARD = 20
global.MYUNG_LEAD_DIST = 300
global.MYUNG_FLASH_HALF = 192
global.MYUNG_FLASH_SIZE = 384
global.YEONG_FLY_FAME_REWARD = 10
global.YEONG_HUG_FAME_REWARD = 20
global.HALMEONI_SPAWN_AT_0 = 0.5
global.HALMEONI_SPAWN_AT_350 = 0.15
global.HALMEONI_SPAWN_FAME_TOP = 350
global.HALMEONI_SLOW_RADIUS = 72
global.HALMEONI_SPEED_CAP = 0.7
global.CAM_LOGIC_W = 1280
global.CAM_LOGIC_H = 640
global.cam_lead_frac = 0.5
global.g_wall_col_map = -1
global.g_wall_tilemaps = undefined
global.club_world_x = 0
global.club_world_y = 0
global.BGM_PAUSE_SEC = 3

_bgm_handle = -1

_tile_px = 128
_club_tile_cols = 3
_club_tile_rows = 3

BakeCorridorToTilemaps = function() {
	random_set_seed(global.level_seed)
	var lay_f = layer_get_id("Floorge")
	var lay_w = layer_get_id("Wallge")
	if (lay_f == -1 || lay_w == -1) {
		show_debug_message("BakeCorridorToTilemaps: missing Floorge or Wallge layer")
		return
	}
	var map_f = layer_tilemap_get_id(lay_f)
	var map_w = layer_tilemap_get_id(lay_w)
	if (map_f == -1 || map_w == -1) return

	var cw = ceil(room_width / _tile_px)
	var ch = ceil(room_height / _tile_px)

	// Invisible tilemap: 2x2 wall collision under shops only (visible Wallge stays blank there).
	var lay_col = layer_get_id("WallgeCol")
	if (lay_col == -1) {
		lay_col = layer_create(150, "WallgeCol")
	}
	var map_col = layer_tilemap_get_id(lay_col)
	if (map_col == -1) {
		map_col = layer_tilemap_create(lay_col, tilemap_get_tileset(map_w), 0, 0, cw, ch)
	} else {
		tilemap_set_width(map_col, cw)
		tilemap_set_height(map_col, ch)
	}
	layer_set_visible(lay_col, false)
	for (var _cx0 = 0; _cx0 < cw; _cx0++) {
		for (var _cy0 = 0; _cy0 < ch; _cy0++) {
			tilemap_set(map_col, -1, _cx0, _cy0)
		}
	}
	// Room file tile layers may be smaller than ceil(room/cell); without this, bottom/side
	// perimeter tiles never get written (e.g. 1080px tall → 9 rows but .yy had 8).
	tilemap_set_width(map_f, cw)
	tilemap_set_height(map_f, ch)
	tilemap_set_width(map_w, cw)
	tilemap_set_height(map_w, ch)
	// Full perimeter on Wallge: old build only had two horizontal bands, so row 7 and left/right
	// edges of the walk band had no tiles — you could run off the bottom/sides while still
	// hitting the top band when moving up.
	var inner_x0 = 1
	var inner_x1 = cw - 2
	var inner_y0 = 2
	var inner_y1 = ch - 2
	var _top_wall_y0 = 0
	var _top_wall_y1 = 1

	for (var cx = 0; cx < cw; cx++) {
		for (var cy = 0; cy < ch; cy++) {
			var edge = (cx == 0 || cx == cw - 1 || cy == 0 || cy == ch - 1)
			if (edge) {
				tilemap_set(map_w, 1, cx, cy)
				tilemap_set(map_f, 0, cx, cy)
			} else if (cx >= inner_x0 && cx <= inner_x1 && cy >= inner_y0 && cy <= inner_y1) {
				tilemap_set(map_w, 0, cx, cy)
				tilemap_set(map_f, irandom_range(1, 5), cx, cy)
			} else {
				tilemap_set(map_w, 0, cx, cy)
				tilemap_set(map_f, 0, cx, cy)
			}
		}
	}

	var mid_tile_y = (inner_y0 + inner_y1) * 0.5
	global.corridor_y = mid_tile_y * _tile_px + _tile_px * 0.5 + 24

	// Goal strip (right end): solid top wall + centered 3x3 club notch; no shops.
	var _goal_tile_cols = max(ceil(1920 / _tile_px), _club_tile_cols + 2)
	var _goal_x0 = max(inner_x0, inner_x1 - _goal_tile_cols + 1)
	var _club_cx0 = _goal_x0 + floor((_goal_tile_cols - _club_tile_cols) * 0.5)
	var _club_cx1 = _club_cx0 + _club_tile_cols - 1
	global.club_world_x = _club_cx0 * _tile_px
	global.club_world_y = _top_wall_y0 * _tile_px

	with (obj_CorridorShop) {
		instance_destroy()
	}
	var _shop_cols = 2
	var _shop_rows = 2
	var _shop_scale = (_tile_px * _shop_cols) / 192
	var _prev_shop = -1
	var _cx = inner_x0
	while (_cx < _goal_x0 && _cx <= inner_x1) {
		var _wall_run = irandom_range(1, 3)
		for (var _w = 0; _w < _wall_run && _cx < _goal_x0; _w++) {
			tilemap_set(map_w, WallgeTile.Horiz, _cx, _top_wall_y0)
			tilemap_set(map_w, WallgeTile.Horiz, _cx, _top_wall_y1)
			_cx++
		}
		if (_cx >= _goal_x0 || _cx + (_shop_cols - 1) > inner_x1) {
			break
		}
		for (var _dx = 0; _dx < _shop_cols; _dx++) {
			for (var _dy = 0; _dy < _shop_rows; _dy++) {
				var _sx = _cx + _dx
				var _sy = _top_wall_y0 + _dy
				tilemap_set(map_w, WallgeTile.Blank, _sx, _sy)
				tilemap_set(map_col, WallgeTile.Horiz, _sx, _sy)
				tilemap_set(map_f, irandom_range(1, 5), _sx, _sy)
			}
		}
		var _fr = PickShopFrameNoRepeat(_prev_shop)
		_prev_shop = _fr
		var _shop = instance_create_layer(_cx * _tile_px, _top_wall_y0 * _tile_px, global.g_inst_layer, obj_CorridorShop)
		_shop.sprite_index = spr_Shops
		_shop.image_index = _fr
		_shop.image_speed = 0
		_shop.image_xscale = _shop_scale
		_shop.image_yscale = _shop_scale
		_shop.depth = 50
		_cx += _shop_cols
	}

	for (_cx = _goal_x0; _cx <= inner_x1; _cx++) {
		var _in_club_x = (_cx >= _club_cx0 && _cx <= _club_cx1)
		if (_in_club_x) {
			// Top 2x3: visible wall, flush with top wall band + collision.
			tilemap_set(map_w, WallgeTile.Horiz, _cx, _top_wall_y0)
			tilemap_set(map_w, WallgeTile.Horiz, _cx, _top_wall_y1)
			tilemap_set(map_f, 0, _cx, _top_wall_y0)
			tilemap_set(map_f, 0, _cx, _top_wall_y1)
			tilemap_set(map_col, WallgeTile.Horiz, _cx, _top_wall_y0)
			tilemap_set(map_col, WallgeTile.Horiz, _cx, _top_wall_y1)
			// Bottom 1x3: blank wall (no brick), road floor, no tile collision — Tad can reach club.
			var _jut_y = _top_wall_y0 + 2
			tilemap_set(map_w, WallgeTile.Blank, _cx, _jut_y)
			tilemap_set(map_col, -1, _cx, _jut_y)
			tilemap_set(map_f, irandom_range(1, 5), _cx, _jut_y)
		} else {
			tilemap_set(map_w, WallgeTile.Horiz, _cx, _top_wall_y0)
			tilemap_set(map_w, WallgeTile.Horiz, _cx, _top_wall_y1)
		}
	}

	global.g_wall_col_map = map_col
	global.g_wall_tilemaps = [map_w, map_col]

	// Walkable inner rect (floor); instance x/y are feet (bottom-center origins).
	var _m = 44
	global.inner_left = inner_x0 * _tile_px + _m
	global.inner_right = (inner_x1 + 1) * _tile_px - _m
	global.inner_top = inner_y0 * _tile_px + _m + 24
	global.inner_bottom = (inner_y1 + 1) * _tile_px - _m + 24
}
