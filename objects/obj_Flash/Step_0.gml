switch (flash_phase) {
	case 0:
		burst_timer -= 1
		if (burst_timer <= 0) {
			flash_phase = 1
		}
		break
	case 1:
		hold_timer -= 1
		if (hold_timer <= 0) {
			flash_phase = 2
		}
		break
	case 2:
		shrink_timer -= 1
		if (shrink_timer <= 0) {
			if (surface_exists(flash_surf)) {
				surface_free(flash_surf)
				flash_surf = -1
			}
			if (surface_exists(flash_comp_surf)) {
				surface_free(flash_comp_surf)
				flash_comp_surf = -1
			}
			instance_destroy()
		}
		break
}
