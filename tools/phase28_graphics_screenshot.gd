extends SceneTree

const SCREENSHOT_PATH := "res://artifacts/phase28_major_graphics_upgrade.png"

func _initialize():
	call_deferred("_run")

func _run():
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var main_scene = load("res://scenes/world/Main.tscn")
	if not main_scene:
		push_error("[FAIL] Main scene did not load")
		quit(1)
		return
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	main.start_new_game()
	await create_timer(2.0).timeout
	_add_overview_camera()
	await process_frame
	await RenderingServer.frame_post_draw
	var dir = DirAccess.open("res://")
	if dir and not dir.dir_exists("artifacts"):
		dir.make_dir("artifacts")
	var image = root.get_texture().get_image()
	if not image or image.get_width() <= 0 or image.get_height() <= 0:
		push_error("[FAIL] Renderer did not produce an image")
		quit(1)
		return
	var err = image.save_png(SCREENSHOT_PATH)
	if err != OK:
		push_error("[FAIL] Could not save screenshot: " + str(err))
		quit(1)
		return
	print("[PASS] Phase 28 rendered screenshot saved: " + SCREENSHOT_PATH)
	main.queue_free()
	await process_frame
	quit(0)

func _add_overview_camera():
	var camera = Camera3D.new()
	camera.name = "Phase28GraphicsOverviewCamera"
	camera.fov = 70.0
	root.add_child(camera)
	camera.look_at_from_position(Vector3(6.6, 2.65, -6.7), Vector3(0.0, 1.05, -0.35), Vector3.UP)
	camera.current = true
