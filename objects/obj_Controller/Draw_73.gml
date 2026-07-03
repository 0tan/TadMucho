var _num = instance_number(obj_Myung)
for (var _i = 0; _i < _num; _i++) {
	var _mid = instance_find(obj_Myung, _i)
	if (_mid._flash_capture_armed) {
		MyungTriggerFlashCapture(_mid)
	}
}
