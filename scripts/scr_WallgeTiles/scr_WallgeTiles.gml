/// Wallge tileset layout (Sprite24, 128px tiles, 4 columns x 2 rows).
/// Reference only — corridor bake still uses tile 1 for perimeter walls until diagonal layout is implemented.
///
/// Row 0: Blank | Horizontal wall | Top-left upward diagonal | Full upward diagonal
/// Row 1: Full downward diagonal | Top-right downward diagonal | Bottom-left downward diagonal | Bottom-right upward diagonal
///
/// Diagonal tiles: the named section is wall; the opposite diagonal is transparent so the road shows through.
/// Intended use: straight corridor, 45° bend up, or 45° bend down; collision should be 45° triangles (not per-pixel).
enum WallgeTile {
	Blank = 0,
	Horiz = 1,
	TLUp = 2,
	FullUp = 3,
	FullDown = 4,
	TRDown = 5,
	BLDown = 6,
	BRUp = 7,
}

/// spr_Shops subimage 0..3; never returns the same index twice in a row as _prev.
function PickShopFrameNoRepeat(_prev) {
	if (_prev < 0) {
		return irandom(3)
	}
	var _pick = irandom(2)
	if (_pick >= _prev) {
		_pick++
	}
	return _pick
}

/// Wallge + hidden WallgeCol (shop footprints); _maps is a tilemap id or [visible, collision].
function MoveTilesAndShops(_inst, _vx, _vy, _maps) {
	with (_inst) {
		var _use_maps = (_maps != -1 && _maps != undefined)
		if (_vx != 0) {
			if (_use_maps) {
				move_and_collide(_vx, 0, _maps)
			} else {
				x += _vx
			}
		}
		if (_vy != 0) {
			if (_use_maps) {
				move_and_collide(0, _vy, _maps)
			} else {
				y += _vy
			}
		}
	}
}
