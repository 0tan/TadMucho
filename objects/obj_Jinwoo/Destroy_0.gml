// If destroyed mid-autograph, release stacked lock so Tad is not stuck forever.
if (_autograph_started && _phase == JinwooPhase.Autograph) {
	Tad_ReleaseAutographLock()
}
