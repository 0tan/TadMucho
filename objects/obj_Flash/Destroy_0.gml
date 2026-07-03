if (surface_exists(flash_surf)) {
	surface_free(flash_surf)
	flash_surf = -1
}
if (surface_exists(flash_comp_surf)) {
	surface_free(flash_comp_surf)
	flash_comp_surf = -1
}
