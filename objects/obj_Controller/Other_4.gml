BakeCorridorToTilemaps()

global.game_won = false
global.game_over = false
var _fps_rs = game_get_speed(gamespeed_fps)
global.match_countdown_frames = round(120 * _fps_rs)
global.fame_decay_elapsed_frames = 0
global._fame_drain_buffer = 0

// Room file often ends up with Background at depth 0 (drawn on top), which hides tilemaps and sprites.
// Force order every room start so HTML5 builds match even after saving the room in the IDE.
layer_depth("Background", 400)
layer_depth("Floorge", 200)
layer_depth("Wallge", 100)
var _lay_col = layer_get_id("WallgeCol")
if (_lay_col != -1) {
	layer_set_visible(_lay_col, false)
}
layer_depth(global.g_inst_layer, 0)

if (instance_exists(obj_Tad)) {
	obj_Tad.x = 22000
	obj_Tad.y = global.corridor_y
}

with (obj_Club) {
	instance_destroy()
}
var _club = instance_create_layer(global.club_world_x, global.club_world_y, global.g_inst_layer, obj_Club)
_club.image_xscale = 2
_club.image_yscale = 2
_club.depth = 40

view_enabled = true
view_visible[0] = true

// Match GUI layer to view so Draw GUI coords (and scissor vs back buffer) stay stable on HTML5.
display_set_gui_size(view_wview[0], view_hview[0])

instance_create_layer(-64, -64, global.g_inst_layer, obj_NPCManager)
