extends SceneTree

const SCREENSHOT_PATH := "res://artifacts/phase17_player_view_demo.png"

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
	await create_timer(2.4).timeout
	var player = root.find_child("Player", true, false)
	if not player:
		push_error("[FAIL] Player did not spawn")
		quit(1)
		return
	player.global_position = Vector3(0.0, 1.0, 5.2)
	player.rotation = Vector3.ZERO
	var head = player.get_node_or_null("Head")
	if head:
		head.rotation = Vector3(deg_to_rad(-4.0), 0.0, 0.0)
	var camera = player.get_node_or_null("Head/Camera3D")
	if not camera:
		push_error("[FAIL] First-person camera missing")
		quit(1)
		return
	camera.current = true
	await process_frame
	await RenderingServer.frame_post_draw
	var dir = DirAccess.open("res://")
	if dir and not dir.dir_exists("artifacts"):
		dir.make_dir("artifacts")
	var image = root.get_texture().get_image()
	if not image or image.get_width() <= 0 or image.get_height() <= 0:
		push_error("[FAIL] Renderer did not produce player-view image")
		quit(1)
		return
	var err = image.save_png(SCREENSHOT_PATH)
	if err != OK:
		push_error("[FAIL] Could not save player-view screenshot: " + str(err))
		quit(1)
		return
	print("[PASS] Phase 17 player-view screenshot saved: " + SCREENSHOT_PATH)
	main.queue_free()
	await process_frame
	quit(0)
