extends Node3D

## Main game entry point. Boots the current playable vertical-slice path for Codex phase work.

const GameFlowManagerScript = preload("res://scripts/managers/GameFlowManager.gd")
const ShiftManagerScript = preload("res://scripts/managers/ShiftManager.gd")
const ChaosIncidentRuntimeScript = preload("res://scripts/drama/ChaosIncidentRuntime.gd")
const MischiefDirectorScript = preload("res://scripts/mischief/MischiefDirector.gd")
const PrankWarManagerScript = preload("res://scripts/mischief/PrankWarManager.gd")
const RestaurantDamageManagerScript = preload("res://scripts/mischief/RestaurantDamageManager.gd")
const MischiefRecapManagerScript = preload("res://scripts/mischief/MischiefRecapManager.gd")
const SuspicionManagerScript = preload("res://scripts/consequences/SuspicionManager.gd")
const FireableOffenseManagerScript = preload("res://scripts/consequences/FireableOffenseManager.gd")
const ShadyChoiceManagerScript = preload("res://scripts/consequences/ShadyChoiceManager.gd")
const TipJarManagerScript = preload("res://scripts/consequences/TipJarManager.gd")
const RegisterIntegrityManagerScript = preload("res://scripts/consequences/RegisterIntegrityManager.gd")
const InventoryMisconductManagerScript = preload("res://scripts/consequences/InventoryMisconductManager.gd")
const FoodKarmaManagerScript = preload("res://scripts/consequences/FoodKarmaManager.gd")
const AbstractImpairmentManagerScript = preload("res://scripts/consequences/AbstractImpairmentManager.gd")
const ManagerCoverupManagerScript = preload("res://scripts/consequences/ManagerCoverupManager.gd")
const FiringRecoveryManagerScript = preload("res://scripts/consequences/FiringRecoveryManager.gd")
const EmergentEventDirectorScript = preload("res://scripts/emergent/EmergentEventDirector.gd")
const RestaurantMemoryManagerScript = preload("res://scripts/memory/RestaurantMemoryManager.gd")
const EvidenceManagerScript = preload("res://scripts/memory/EvidenceManager.gd")
const StoreObjectMemoryManagerScript = preload("res://scripts/memory/StoreObjectMemoryManager.gd")
const ConsequenceMatrixManagerScript = preload("res://scripts/consequences/ConsequenceMatrixManager.gd")
const EmergentMissionGeneratorScript = preload("res://scripts/missions/EmergentMissionGenerator.gd")
const MultiKarmaManagerScript = preload("res://scripts/karma/MultiKarmaManager.gd")
const DynamicReputationLabelManagerScript = preload("res://scripts/reputation/DynamicReputationLabelManager.gd")
const GeneratedRecapManagerScript = preload("res://scripts/recap/GeneratedRecapManager.gd")
const FutureChainTriggerManagerScript = preload("res://scripts/emergent/FutureChainTriggerManager.gd")
const DepthDirectorScript = preload("res://scripts/depth/DepthDirector.gd")
const NormalcyBalanceDirectorScript = preload("res://scripts/depth/NormalcyBalanceDirector.gd")
const DepthEventLinkerScript = preload("res://scripts/depth/DepthEventLinker.gd")
const WorldTextureManagerScript = preload("res://scripts/depth/WorldTextureManager.gd")
const ShiftFlavorManagerScript = preload("res://scripts/depth/ShiftFlavorManager.gd")
const ContentDensityValidatorRuntimeScript = preload("res://scripts/depth/ContentDensityValidatorRuntime.gd")
const MainMenuUIScript = preload("res://scripts/ui/MainMenuUI.gd")
const ClockOutStationScript = preload("res://scripts/stations/ClockOutStation.gd")
const DrinkStationScript = preload("res://scripts/stations/DrinkStation.gd")

var flow: Node
var current_world: Node = null
var hud: Node = null
var menu: Node = null
var current_shift_manager: Node = null
var game_started := false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	flow = GameFlowManagerScript.new()
	add_child(flow)
	var hud_scene = load("res://scenes/ui/GameHUD.tscn")
	if hud_scene:
		hud = hud_scene.instantiate()
		add_child(hud)
		hud.visible = false
	menu = MainMenuUIScript.new()
	menu.name = "MainMenuUI"
	add_child(menu)
	_connect_menu()
	_spawn_chaos_runtime_if_missing()
	_spawn_mischief_runtime_if_missing()
	_spawn_consequence_runtime_if_missing()
	_spawn_emergent_runtime_if_missing()
	_spawn_depth_runtime_if_missing()
	_connect_staff_hud()
	_connect_store_ops_hud()
	_connect_daily_tasks_hud()
	_connect_career_hud()
	_spawn_player_if_missing()
	_apply_phase17_demo_visuals()
	_set_boot_status("Phase 1: 3D player spawned; input actions ready")
	_show_main_menu("Ready. New Game starts the local shift loop.")

func _process(_delta):
	if game_started and Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			resume_game()
		else:
			pause_game()
	if hud and hud.has_method("set_shift_timer") and current_shift_manager:
		hud.set_shift_timer(float(current_shift_manager.get("time_remaining")), bool(current_shift_manager.get("is_active")))

func _spawn_player_if_missing():
	if find_child("Player", true, false):
		return
	var player_scene = load("res://scenes/player/Player.tscn")
	if player_scene:
		var player = player_scene.instantiate()
		player.name = "Player"
		player.position = Vector3(0, 2, -5.45)
		player.rotation_degrees = Vector3(0, 180, 0)
		add_child(player)
		print("MVP boot: Player spawned.")
	else:
		print("Player scene missing. Phase 1 must restore scenes/player/Player.tscn.")

func load_apartment_hub():
	print("Apartment hub requested. Using lightweight MVP boot path.")
	var event_log = _autoload("EventLog")
	if event_log and event_log.has_method("log_event"):
		event_log.log_event("apartment_loaded", 0, "Apartment hub entered; clock-in fallback started")
	# Keep player in the main world until scene transitions are fully implemented.
	call_deferred("clock_in")

func clock_in():
	start_new_game()

func start_new_game():
	game_started = true
	if hud:
		hud.visible = true
	if menu and menu.has_method("hide_menu"):
		menu.hide_menu()
	_spawn_player_if_missing()
	start_new_shift()

func continue_game():
	var save_system = _autoload("SaveSystem")
	var save_data = save_system.load_game() if save_system and save_system.has_method("load_game") else {}
	start_new_game()
	if menu and menu.has_method("show_status"):
		menu.show_status("Loaded local save." if not save_data.is_empty() else "No save found; started a new shift.")

func start_new_shift():
	if current_shift_manager and bool(current_shift_manager.get("is_active")):
		return
	print("--- STARTING NEW SHIFT ---")
	_set_boot_status("Shift active: serve the order, manage tasks, survive.")
	_play_audio_hook("shift_start")
	var sm = ShiftManagerScript.new()
	current_shift_manager = sm
	add_child(sm)
	sm.start_shift()
	if hud and hud.has_method("set_objective_status"):
		hud.set_objective_status("Serve the ticket: Bag -> Burger/Fries/Soda as requested -> Green DRIVE-THRU Mat -> Clock Out.")
	if hud and hud.has_method("set_first_shift_guidance"):
		hud.set_first_shift_guidance("Follow the floor arrows and ticket. Get a paper bag, add requested food at stations, hand it off on the green mat, then clock-out.")
	var stat_manager = _autoload("StatManager")
	var current_stats = {
		"Energy": stat_manager.stats.get("Energy", 100.0) if stat_manager else 100.0,
		"Mood": stat_manager.stats.get("Mood", 100.0) if stat_manager else 100.0,
		"Stress": stat_manager.stats.get("Stress", 0.0) if stat_manager else 0.0
	}
	var life_cycle = _autoload("LifeCycleManager")
	if life_cycle and life_cycle.has_method("prepare_for_shift"):
		life_cycle.prepare_for_shift(current_stats)
	var corporate = _autoload("CorporateManager")
	if corporate and corporate.has_method("generate_shift_goal"):
		corporate.generate_shift_goal()
	var chaos = _autoload("ChaosEngine")
	if chaos and chaos.has_method("roll_for_chaos"):
		chaos.roll_for_chaos()
	var phase9 = find_child("ChaosIncidentRuntime", true, false)
	if phase9 and phase9.has_method("configure_shift"):
		var shift_results = _autoload("ShiftResultManager")
		var shift_number = 1
		if shift_results:
			var current_shift_number = shift_results.get("shift_number")
			if current_shift_number != null:
				shift_number = int(current_shift_number) + 1
		phase9.configure_shift(shift_number)
	var mischief = find_child("MischiefDirector", true, false)
	if mischief and mischief.has_method("configure_shift"):
		var shift_results_for_mischief = _autoload("ShiftResultManager")
		var mischief_shift_number = 1
		if shift_results_for_mischief:
			var current_number = shift_results_for_mischief.get("shift_number")
			if current_number != null:
				mischief_shift_number = int(current_number) + 1
		mischief.configure_shift(mischief_shift_number)
	var prank_war = find_child("PrankWarManager", true, false)
	if prank_war and prank_war.has_method("configure_shift"):
		prank_war.configure_shift()
	var depth = find_child("DepthDirector", true, false)
	if depth and depth.has_method("generate_shift_depth"):
		var depth_shift_number = 1
		var depth_shift_results = _autoload("ShiftResultManager")
		if depth_shift_results:
			var depth_current_number = depth_shift_results.get("shift_number")
			if depth_current_number != null:
				depth_shift_number = int(depth_current_number) + 1
		depth.generate_shift_depth({
			"shift_number": depth_shift_number,
			"tutorial_shift": depth_shift_number <= 1,
			"recovery_window": false
		})
	spawn_initial_customer()

func pause_game():
	if menu and menu.has_method("show_pause_menu"):
		menu.show_pause_menu("Game paused. Progress is local-only.")

func resume_game():
	if menu and menu.has_method("hide_menu"):
		menu.hide_menu()

func end_current_shift():
	if current_shift_manager and current_shift_manager.has_method("end_shift") and bool(current_shift_manager.get("is_active")):
		current_shift_manager.end_shift()
	else:
		var shift_results = _autoload("ShiftResultManager")
		if shift_results and shift_results.has_method("complete_shift"):
			shift_results.complete_shift({})
	_play_audio_hook("shift_end")
	show_shift_results()

func show_shift_results():
	var shift_results = _autoload("ShiftResultManager")
	var report = shift_results.get_last_report() if shift_results and shift_results.has_method("get_last_report") else "--- SHIFT SUMMARY ---"
	if hud:
		hud.visible = false
	if menu and menu.has_method("show_results"):
		menu.show_results(report)

func save_game_from_menu():
	var save_system = _autoload("SaveSystem")
	if save_system and save_system.has_method("save_game"):
		var ok = save_system.save_game({})
		if menu and menu.has_method("show_status"):
			menu.show_status("Saved locally." if ok else "Save failed.")

func load_game_from_menu():
	var save_system = _autoload("SaveSystem")
	var save_data = save_system.load_game() if save_system and save_system.has_method("load_game") else {}
	if menu and menu.has_method("show_status"):
		menu.show_status("Loaded local save." if not save_data.is_empty() else "No save file found.")

func return_to_main_menu():
	game_started = false
	if current_shift_manager:
		current_shift_manager.set("is_active", false)
	if hud:
		hud.visible = false
	_show_main_menu("Returned to menu. Progress remains local.")

func apply_menu_settings(settings: Dictionary):
	if hud and hud.has_method("apply_accessibility_settings"):
		hud.apply_accessibility_settings(settings)
	var event_log = _autoload("EventLog")
	if event_log and event_log.has_method("log_event"):
		event_log.log_event("settings_changed", 1.0, str(settings))

func spawn_initial_customer():
	var car_scene = load("res://scenes/customers/CustomerCar.tscn") if ResourceLoader.exists("res://scenes/customers/CustomerCar.tscn") else null
	if car_scene:
		var car = car_scene.instantiate()
		if car.has_method("configure_route"):
			car.configure_route(Vector3(-8.5, 0.45, -5.0), Vector3(-6.2, 0.45, -2.2))
		else:
			car.global_position = Vector3(-8.5, 0.45, -5.0)
		add_child(car)
	else:
		print("CustomerCar scene missing. Generating fallback MVP order.")
		var order_manager = _autoload("OrderManager")
		if order_manager and order_manager.has_method("generate_new_order"):
			order_manager.generate_new_order()
		if hud and hud.has_method("set_customer_status"):
			hud.set_customer_status("Fallback customer waiting at DRIVE-THRU.")
		var event_log = _autoload("EventLog")
		if event_log and event_log.has_method("log_event"):
			event_log.log_event("customer_spawn_fallback", 0, "Fallback MVP order generated")

func _set_boot_status(text: String):
	if hud and hud.has_method("set_boot_status"):
		hud.set_boot_status(text)

func _show_main_menu(status: String):
	if menu and menu.has_method("show_main_menu"):
		menu.show_main_menu(status)

func _connect_menu():
	if not menu:
		return
	menu.new_game_requested.connect(start_new_game)
	menu.continue_requested.connect(continue_game)
	menu.resume_requested.connect(resume_game)
	menu.end_shift_requested.connect(end_current_shift)
	menu.return_to_menu_requested.connect(return_to_main_menu)
	menu.save_requested.connect(save_game_from_menu)
	menu.load_requested.connect(load_game_from_menu)
	menu.quit_requested.connect(func(): get_tree().quit())
	menu.settings_changed.connect(apply_menu_settings)

func _autoload(name: String) -> Node:
	return get_tree().root.get_node_or_null(name)

func _apply_phase17_demo_visuals():
	var world = get_node_or_null("World")
	if not world:
		return
	var sky = _mat("Soft daylight sky", Color(0.58, 0.78, 0.95), 1.0)
	var floor_mat = _mat("Warm tile floor", Color(0.93, 0.86, 0.68), 0.85)
	var kitchen_mat = _mat("Kitchen blue tile", Color(0.45, 0.78, 0.86), 0.75)
	var counter_mat = _mat("Counter red laminate", Color(0.86, 0.18, 0.18), 0.65)
	var drive_mat = _mat("Drive-thru orange", Color(1.0, 0.48, 0.08), 0.6)
	var grill_mat = _mat("Grill steel", Color(0.14, 0.16, 0.17), 0.45)
	var fryer_mat = _mat("Fryer yellow", Color(1.0, 0.75, 0.15), 0.55)
	var prep_mat = _mat("Prep green", Color(0.23, 0.68, 0.34), 0.6)
	var sauce_mat = _mat("Sauce purple", Color(0.55, 0.28, 0.82), 0.65)
	var cleaning_mat = _mat("Cleaning cyan", Color(0.18, 0.72, 0.95), 0.65)
	var trash_mat = _mat("Trash gray", Color(0.36, 0.38, 0.38), 0.8)
	var wall_mat = _mat("Warm restaurant wall", Color(0.98, 0.58, 0.32), 0.8)
	var lane_mat = _mat("Asphalt drive-thru lane", Color(0.11, 0.12, 0.13), 0.9)
	var handoff_mat = _mat("Handoff target green", Color(0.2, 0.95, 0.38), 0.55, Color(0.1, 0.8, 0.2))
	var register_mat = _mat("Register blue", Color(0.22, 0.43, 0.92), 0.6)
	var patty_mat = _mat("Food readable tan", Color(0.72, 0.43, 0.19), 0.7)
	var bag_mat = _mat("Paper bag tan", Color(0.72, 0.52, 0.3), 0.8)
	var fries_mat = _mat("Fries carton red yellow", Color(1.0, 0.82, 0.18), 0.7)
	var soda_mat = _mat("Soda cup white red", Color(0.95, 0.95, 0.9), 0.65)
	var arrow_mat = _mat("Prep arrow white", Color(1.0, 1.0, 0.85), 0.5, Color(1.0, 0.95, 0.55))

	_set_world_environment()
	_set_mesh_material("RestaurantFloor", floor_mat)
	_set_mesh_material("TrainingCounter", counter_mat)
	_set_mesh_material("TrainingBurger", patty_mat)
	_set_mesh_material("RawPatty", patty_mat)
	_set_mesh_material("RegisterStation", register_mat)
	_set_mesh_material("RegisterCheckStation", register_mat)
	_set_mesh_material("DriveThruStation", drive_mat)
	_set_mesh_material("GrillStation", grill_mat)
	_set_mesh_material("FryerCheckStation", fryer_mat)
	_set_mesh_material("BaggingTableStation", prep_mat)
	_set_mesh_material("SauceStockStation", sauce_mat)
	_set_mesh_material("CleaningStation", cleaning_mat)
	_set_mesh_material("TrashRunStation", trash_mat)
	_set_mesh_material("RecoveryStation", fryer_mat)
	_set_mesh_material("CoworkerRiley", _mat("Riley uniform", Color(0.98, 0.86, 0.2), 0.8))
	_set_mesh_material("CoworkerCasey", _mat("Casey uniform", Color(0.2, 0.65, 0.95), 0.8))
	_set_mesh_material("CoworkerMorgan", _mat("Morgan uniform", Color(0.9, 0.35, 0.7), 0.8))

	var dressing = world.get_node_or_null("Phase17DemoDressing")
	if not dressing:
		dressing = Node3D.new()
		dressing.name = "Phase17DemoDressing"
		world.add_child(dressing)
	_add_box(dressing, "KitchenColorZone", Vector3(1.5, 0.14, 3.2), Vector3(8.0, 0.04, 4.0), kitchen_mat, false)
	_add_box(dressing, "FrontCounterZone", Vector3(0.0, 0.16, -2.5), Vector3(9.0, 0.04, 2.6), counter_mat, false)
	_add_box(dressing, "DriveThruLane", Vector3(-7.0, 0.12, -2.2), Vector3(2.0, 0.05, 7.0), lane_mat, false)
	_add_box(dressing, "DriveThruHandoffMat", Vector3(-5.8, 0.2, -2.2), Vector3(1.6, 0.08, 1.2), handoff_mat, false)
	_add_box(dressing, "PrepFlowArrowTicket", Vector3(-0.2, 0.26, 0.42), Vector3(1.0, 0.04, 0.18), arrow_mat, false)
	_add_box(dressing, "PrepFlowArrowWindow", Vector3(-2.95, 0.26, -1.35), Vector3(1.3, 0.04, 0.18), arrow_mat, false)
	_add_box(dressing, "BaggingPaperBags", Vector3(-0.8, 1.52, -0.4), Vector3(0.55, 0.42, 0.28), bag_mat, false)
	_add_box(dressing, "FriesReadyBin", Vector3(3.8, 1.52, 2.45), Vector3(0.55, 0.35, 0.28), fries_mat, false)
	_add_box(dressing, "SodaCupStack", Vector3(-1.8, 1.52, 2.45), Vector3(0.38, 0.5, 0.38), soda_mat, false)
	_add_box(dressing, "BackWall", Vector3(0.0, 1.6, 7.9), Vector3(16.0, 3.0, 0.25), wall_mat, true)
	_add_box(dressing, "FrontWallRegisterHalf", Vector3(4.0, 1.6, -7.9), Vector3(8.0, 3.0, 0.25), wall_mat, true)
	_add_box(dressing, "LeftWallDriveThru", Vector3(-7.9, 1.6, 1.5), Vector3(0.25, 3.0, 12.0), wall_mat, true)
	_add_box(dressing, "RightWall", Vector3(7.9, 1.6, 0.0), Vector3(0.25, 3.0, 16.0), wall_mat, true)
	_add_box(dressing, "MenuBoard", Vector3(1.5, 2.4, -7.65), Vector3(4.0, 1.2, 0.12), _mat("Menu board black", Color(0.05, 0.07, 0.08), 0.7), false)
	var clock_out_station = _add_box(dressing, "ClockOutStation", Vector3(6.25, 0.85, 4.15), Vector3(1.2, 1.2, 0.9), _mat("Clock out teal", Color(0.0, 0.62, 0.58), 0.65), true)
	if clock_out_station and not clock_out_station.get_script():
		clock_out_station.set_script(ClockOutStationScript)
	if clock_out_station:
		clock_out_station.set("interact_text", "Clock out / end shift")
	var drink_station = _add_box(dressing, "DrinkFillStation", Vector3(-1.8, 0.9, 2.45), Vector3(0.95, 1.05, 0.75), soda_mat, true)
	if drink_station and not drink_station.get_script():
		drink_station.set_script(DrinkStationScript)
	if drink_station:
		drink_station.set("interact_text", "Add soda to bag")
	_add_label(dressing, "MenuBoardLabel", "MINIMUM WAGE MAYHEM\nBurger - Fries - Soda", Vector3(1.5, 2.35, -7.52), Color(1.0, 0.95, 0.65), 34)
	_add_label(dressing, "PrepFlowLabel", "PREP FLOW:\nTicket -> Bag -> Food -> Window", Vector3(-0.85, 1.85, -0.25), Color(1.0, 0.95, 0.7), 22)
	_add_label(dressing, "SodaAffordanceLabel", "SODA\nadd to bag", Vector3(-1.8, 2.05, 2.45), Color(0.95, 1.0, 1.0), 18)
	_add_label(dressing, "FriesAffordanceLabel", "FRIES\nadd to bag", Vector3(3.8, 2.05, 2.45), Color(1.0, 0.92, 0.5), 18)
	_add_station_label("RegisterStation", "REGISTER", Color(0.75, 0.86, 1.0))
	_add_station_label("DriveThruStation", "DRIVE-THRU\nHAND OFF HERE", Color(1.0, 0.88, 0.45))
	_add_station_label("GrillStation", "GRILL\nADD BURGER", Color(1.0, 0.55, 0.35))
	_add_station_label("FryerCheckStation", "FRYER\nADD FRIES", Color(1.0, 0.9, 0.35))
	_add_station_label("BaggingTableStation", "BAGGING\nGET BAG", Color(0.65, 1.0, 0.7))
	_add_station_label("DrinkFillStation", "DRINK\nADD SODA", Color(0.75, 1.0, 1.0))
	_add_station_label("SauceStockStation", "SAUCE\nRESTOCK", Color(0.9, 0.7, 1.0))
	_add_station_label("RecoveryStation", "FIX-IT", Color(1.0, 0.82, 0.45))
	_add_station_label("TrashRunStation", "TRASH", Color(0.8, 0.85, 0.85))
	_add_station_label("CleaningStation", "CLEAN", Color(0.55, 0.95, 1.0))
	_add_station_label("RegisterCheckStation", "CLOCK OUT\nPause > End Shift", Color(0.9, 0.95, 1.0))
	_add_station_label("ClockOutStation", "CLOCK OUT\nEND SHIFT", Color(0.72, 1.0, 0.95))
	_ensure_demo_light("KitchenSoftbox", Vector3(1.0, 4.2, 2.5), Color(1.0, 0.88, 0.68), 4.5)
	_ensure_demo_light("DriveThruGlow", Vector3(-5.8, 3.4, -2.2), Color(1.0, 0.58, 0.18), 2.5)
	_apply_phase21_cartoon_identity(dressing)
	_apply_phase21_redo_layout(dressing)

func _set_world_environment():
	var env_node = get_node_or_null("WorldEnvironment")
	if not env_node:
		return
	var env = env_node.environment
	if not env:
		env = Environment.new()
		env_node.environment = env
	env.background_mode = 1
	env.background_color = Color(0.62, 0.82, 0.98)
	env.ambient_light_source = 2
	env.ambient_light_color = Color(1.0, 0.86, 0.62)
	env.ambient_light_energy = 1.08
	var light = get_node_or_null("DirectionalLight3D")
	if light:
		light.light_energy = 1.45
		light.shadow_enabled = true
		light.rotation_degrees = Vector3(-48.0, -34.0, 0.0)

func _apply_phase21_cartoon_identity(dressing: Node):
	var cream = _mat("Phase21 cream wall stripe", Color(1.0, 0.86, 0.42), 0.75)
	var red = _mat("Phase21 house red", Color(0.9, 0.12, 0.09), 0.65)
	var blue = _mat("Phase21 ticket blue", Color(0.15, 0.48, 0.95), 0.62)
	var yellow = _mat("Phase21 fry yellow", Color(1.0, 0.82, 0.12), 0.6)
	var white = _mat("Phase21 paper white", Color(0.98, 0.96, 0.88), 0.72)
	var black = _mat("Phase21 cartoon black", Color(0.03, 0.035, 0.04), 0.7)
	var steel = _mat("Phase21 soft steel", Color(0.42, 0.46, 0.48), 0.48)
	var glass = _mat("Phase21 soda glass", Color(0.65, 0.9, 1.0, 0.92), 0.35)
	var bun = _mat("Phase21 bun", Color(0.93, 0.62, 0.25), 0.7)
	var patty = _mat("Phase21 patty", Color(0.34, 0.16, 0.07), 0.8)
	var lettuce = _mat("Phase21 lettuce", Color(0.28, 0.78, 0.2), 0.72)
	var cheese = _mat("Phase21 cheese", Color(1.0, 0.78, 0.08), 0.68)
	var asphalt = _mat("Phase21 asphalt", Color(0.09, 0.095, 0.1), 0.88)
	var glowing_green = _mat("Phase21 handoff glow", Color(0.18, 1.0, 0.35), 0.5, Color(0.1, 0.95, 0.25, 1.0))

	_add_floor_tiles(dressing, white, _mat("Phase21 tile grout", Color(0.78, 0.7, 0.58), 0.8))
	_add_box(dressing, "Phase21WallStripeBack", Vector3(0.0, 2.15, 7.74), Vector3(15.6, 0.34, 0.08), cream, false)
	_add_box(dressing, "Phase21WallStripeLeft", Vector3(-7.74, 2.15, 1.4), Vector3(0.08, 0.34, 11.6), cream, false)
	_add_box(dressing, "Phase21BaseboardBack", Vector3(0.0, 0.48, 7.72), Vector3(15.7, 0.18, 0.1), red, false)
	_add_box(dressing, "Phase21BaseboardRight", Vector3(7.72, 0.48, 0.0), Vector3(0.1, 0.18, 15.7), red, false)
	_add_box(dressing, "Phase21CounterTrim", Vector3(0.0, 1.18, -2.1), Vector3(8.7, 0.16, 0.12), cream, false)
	_add_box(dressing, "Phase21DriveThruWindowFrame", Vector3(-5.7, 1.45, -2.2), Vector3(0.12, 1.45, 1.55), black, false)
	_add_box(dressing, "Phase21DriveThruAwning", Vector3(-5.95, 2.35, -2.2), Vector3(1.1, 0.18, 2.1), red, false)
	_add_box(dressing, "Phase21DriveThruArrow", Vector3(-7.0, 0.23, -4.7), Vector3(1.15, 0.04, 0.18), cream, false)
	_add_box(dressing, "Phase21DriveThruLaneBorderA", Vector3(-7.95, 0.22, -2.2), Vector3(0.09, 0.05, 6.6), yellow, false)
	_add_box(dressing, "Phase21DriveThruLaneBorderB", Vector3(-6.05, 0.22, -2.2), Vector3(0.09, 0.05, 6.6), yellow, false)
	_add_box(dressing, "Phase21HandoffTargetRing", Vector3(-5.78, 0.28, -2.2), Vector3(1.95, 0.05, 1.5), glowing_green, false)

	_add_register_props(dressing, blue, black, white)
	_add_grill_props(dressing, steel, black, red)
	_add_fryer_props(dressing, steel, yellow, red)
	_add_prep_props(dressing, white, red, yellow, glass)
	_add_clockout_props(dressing, blue, white, red)
	_add_food_readability_props(dressing, bun, patty, lettuce, cheese, white)
	_add_label(dressing, "Phase21BrandWallSign", "MINIMUM WAGE MAYHEM\nOPEN UNTIL SOMEONE QUITS", Vector3(0.0, 3.05, 7.55), Color(1.0, 0.95, 0.55), 30)
	_add_label(dressing, "Phase21WindowCue", "GREEN MAT = HANDOFF", Vector3(-5.9, 2.75, -2.2), Color(0.7, 1.0, 0.72), 18)
	_ensure_demo_light("Phase21MenuGlow", Vector3(1.5, 3.2, -6.7), Color(1.0, 0.85, 0.45), 2.2)
	_ensure_demo_light("Phase21PrepGlow", Vector3(-0.5, 3.6, 0.7), Color(0.7, 1.0, 0.78), 1.8)

func _add_floor_tiles(dressing: Node, tile_mat: Material, grout_mat: Material):
	for x in range(-3, 4):
		_add_box(dressing, "Phase21FloorGroutX" + str(x), Vector3(float(x) * 2.0, 0.255, 0.0), Vector3(0.035, 0.025, 15.5), grout_mat, false)
	for z in range(-3, 4):
		_add_box(dressing, "Phase21FloorGroutZ" + str(z), Vector3(0.0, 0.256, float(z) * 2.0), Vector3(15.5, 0.025, 0.035), grout_mat, false)
	_add_box(dressing, "Phase21PrepFloorPatch", Vector3(-0.8, 0.27, -0.4), Vector3(2.6, 0.035, 1.3), tile_mat, false)

func _add_register_props(dressing: Node, blue: Material, black: Material, white: Material):
	_add_box(dressing, "Phase21RegisterScreen", Vector3(3.8, 1.65, -2.05), Vector3(0.95, 0.58, 0.08), black, false)
	_add_box(dressing, "Phase21RegisterGlow", Vector3(3.8, 1.65, -1.99), Vector3(0.78, 0.4, 0.035), blue, false)
	_add_box(dressing, "Phase21ReceiptPrinter", Vector3(4.45, 1.35, -2.08), Vector3(0.48, 0.28, 0.34), white, false)
	_add_box(dressing, "Phase21Keypad", Vector3(3.65, 1.28, -1.82), Vector3(0.7, 0.12, 0.44), blue, false)

func _add_grill_props(dressing: Node, steel: Material, black: Material, red: Material):
	_add_box(dressing, "Phase21GrillFlatTop", Vector3(1.8, 1.52, 3.48), Vector3(1.55, 0.12, 0.7), black, false)
	for i in range(4):
		_add_box(dressing, "Phase21GrillLine" + str(i), Vector3(1.26 + float(i) * 0.34, 1.6, 3.48), Vector3(0.05, 0.05, 0.62), steel, false)
	_add_box(dressing, "Phase21GrillHeatKnobA", Vector3(1.35, 1.3, 3.12), Vector3(0.16, 0.16, 0.08), red, false)
	_add_box(dressing, "Phase21GrillHeatKnobB", Vector3(1.72, 1.3, 3.12), Vector3(0.16, 0.16, 0.08), red, false)

func _add_fryer_props(dressing: Node, steel: Material, yellow: Material, red: Material):
	_add_box(dressing, "Phase21FryerVat", Vector3(3.8, 1.45, 2.55), Vector3(1.05, 0.36, 0.62), steel, false)
	_add_box(dressing, "Phase21FryerOil", Vector3(3.8, 1.67, 2.55), Vector3(0.84, 0.05, 0.48), yellow, false)
	_add_box(dressing, "Phase21FryerBasketHandle", Vector3(3.8, 1.86, 2.18), Vector3(0.62, 0.07, 0.08), red, false)
	for i in range(5):
		_add_box(dressing, "Phase21FryStick" + str(i), Vector3(3.52 + float(i) * 0.13, 1.82, 2.42), Vector3(0.05, 0.34, 0.05), yellow, false)

func _add_prep_props(dressing: Node, white: Material, red: Material, yellow: Material, glass: Material):
	_add_box(dressing, "Phase21TicketRail", Vector3(-0.1, 1.68, 0.18), Vector3(1.35, 0.07, 0.08), red, false)
	_add_box(dressing, "Phase21OrderTicketCard", Vector3(-0.1, 1.88, 0.2), Vector3(0.72, 0.5, 0.04), white, false)
	_add_label(dressing, "Phase21OrderTicketText", "ORDER\nCHECK HUD", Vector3(-0.1, 1.88, 0.23), Color(0.05, 0.05, 0.05), 18)
	_add_box(dressing, "Phase21BagMouth", Vector3(-0.8, 1.78, -0.4), Vector3(0.62, 0.06, 0.36), red, false)
	_add_box(dressing, "Phase21SodaCupA", Vector3(-1.95, 1.78, 2.45), Vector3(0.28, 0.44, 0.28), glass, false)
	_add_box(dressing, "Phase21SodaCupB", Vector3(-1.65, 1.78, 2.45), Vector3(0.28, 0.44, 0.28), glass, false)
	_add_box(dressing, "Phase21SodaStripeA", Vector3(-1.95, 1.82, 2.27), Vector3(0.28, 0.07, 0.035), red, false)
	_add_box(dressing, "Phase21FryCartonLip", Vector3(3.8, 1.86, 2.45), Vector3(0.62, 0.08, 0.36), red, false)
	_add_box(dressing, "Phase21PrepCuttingBoard", Vector3(-0.08, 1.31, 1.2), Vector3(0.92, 0.06, 0.62), white, false)

func _add_clockout_props(dressing: Node, blue: Material, white: Material, red: Material):
	_add_box(dressing, "Phase21ClockFace", Vector3(6.25, 1.62, 3.72), Vector3(0.52, 0.42, 0.05), white, false)
	_add_label(dressing, "Phase21ClockText", "DONE?", Vector3(6.25, 1.62, 3.77), Color(0.1, 0.12, 0.14), 16)
	_add_box(dressing, "Phase21ClockButton", Vector3(6.25, 1.18, 3.68), Vector3(0.36, 0.16, 0.12), red, false)
	_add_box(dressing, "Phase21ClockBaseStripe", Vector3(6.25, 0.56, 3.67), Vector3(1.05, 0.12, 0.12), blue, false)

func _add_food_readability_props(dressing: Node, bun: Material, patty: Material, lettuce: Material, cheese: Material, paper: Material):
	_add_box(dressing, "Phase21BurgerPaper", Vector3(0.0, 1.34, 1.2), Vector3(0.68, 0.04, 0.68), paper, false)
	_add_box(dressing, "Phase21BurgerPatty", Vector3(0.0, 1.42, 1.2), Vector3(0.54, 0.08, 0.54), patty, false)
	_add_box(dressing, "Phase21BurgerCheese", Vector3(0.0, 1.49, 1.2), Vector3(0.58, 0.035, 0.58), cheese, false)
	_add_box(dressing, "Phase21BurgerLettuce", Vector3(0.0, 1.55, 1.2), Vector3(0.64, 0.035, 0.5), lettuce, false)
	_add_box(dressing, "Phase21BurgerBunTop", Vector3(0.0, 1.64, 1.2), Vector3(0.5, 0.12, 0.5), bun, false)
	_add_box(dressing, "Phase21RawPattyReadable", Vector3(2.8, 1.34, 3.6), Vector3(0.54, 0.08, 0.54), patty, false)

func _apply_phase21_redo_layout(dressing: Node):
	var lobby_mat = _mat("Phase21 redo lobby blue", Color(0.2, 0.45, 0.95), 0.68)
	var prep_mat = _mat("Phase21 redo prep green", Color(0.16, 0.72, 0.34), 0.64)
	var kitchen_mat = _mat("Phase21 redo kitchen orange", Color(1.0, 0.48, 0.12), 0.62)
	var service_mat = _mat("Phase21 redo service red", Color(0.9, 0.12, 0.08), 0.64)
	var restock_mat = _mat("Phase21 redo restock purple", Color(0.58, 0.26, 0.9), 0.66)
	var clock_mat = _mat("Phase21 redo clock teal", Color(0.0, 0.82, 0.76), 0.62)
	var path_mat = _mat("Phase21 redo route yellow", Color(1.0, 0.92, 0.18), 0.5, Color(0.9, 0.72, 0.08, 1.0))
	var dark_mat = _mat("Phase21 redo boundary dark", Color(0.035, 0.04, 0.045), 0.82)
	var white_mat = _mat("Phase21 redo sign white", Color(0.98, 0.96, 0.86), 0.68)
	var green_glow = _mat("Phase21 redo success green", Color(0.15, 1.0, 0.35), 0.45, Color(0.08, 0.95, 0.25, 1.0))

	_add_zone_band(dressing, "Phase21RedoLobbyZone", Vector3(1.4, 0.31, -4.85), Vector3(11.4, 0.045, 1.55), lobby_mat, "LOBBY / FRONT COUNTER", Vector3(1.5, 0.42, -5.55), Color(0.78, 0.9, 1.0))
	_add_zone_band(dressing, "Phase21RedoServiceZone", Vector3(-5.35, 0.32, -2.2), Vector3(2.05, 0.05, 2.45), service_mat, "DRIVE-THRU WINDOW", Vector3(-5.45, 0.46, -3.45), Color(1.0, 0.86, 0.45))
	_add_zone_band(dressing, "Phase21RedoPrepZone", Vector3(-0.6, 0.33, 0.25), Vector3(3.1, 0.05, 2.15), prep_mat, "PREP / BAGGING", Vector3(-0.6, 0.48, -0.9), Color(0.72, 1.0, 0.76))
	_add_zone_band(dressing, "Phase21RedoKitchenZone", Vector3(2.65, 0.34, 3.4), Vector3(4.25, 0.05, 2.35), kitchen_mat, "HOT LINE", Vector3(2.65, 0.48, 4.7), Color(1.0, 0.82, 0.45))
	_add_zone_band(dressing, "Phase21RedoRestockZone", Vector3(-2.7, 0.35, 2.2), Vector3(3.9, 0.05, 2.05), restock_mat, "SAUCE / RESTOCK / CLEAN", Vector3(-2.7, 0.5, 3.45), Color(0.92, 0.75, 1.0))
	_add_zone_band(dressing, "Phase21RedoClockZone", Vector3(6.0, 0.36, 3.6), Vector3(1.9, 0.05, 1.9), clock_mat, "CLOCK OUT", Vector3(6.0, 0.5, 4.75), Color(0.75, 1.0, 0.95))

	_add_box(dressing, "Phase21RedoCustomerCounter", Vector3(1.0, 0.95, -3.7), Vector3(8.8, 1.35, 0.28), dark_mat, true)
	_add_box(dressing, "Phase21RedoKitchenRail", Vector3(0.4, 0.72, 2.0), Vector3(6.5, 0.72, 0.18), dark_mat, true)
	_add_box(dressing, "Phase21RedoDriveThruDivider", Vector3(-6.18, 0.62, -2.2), Vector3(0.16, 0.72, 3.1), dark_mat, true)
	_add_box(dressing, "Phase21RedoExitStripe", Vector3(6.9, 0.28, 3.6), Vector3(0.12, 0.05, 2.4), clock_mat, false)

	_add_route_marker(dressing, "Phase21RedoStep1Ticket", "1\nTICKET", Vector3(0.0, 0.62, -1.0), path_mat, Color(0.08, 0.06, 0.02))
	_add_route_marker(dressing, "Phase21RedoStep2Burger", "2\nBURGER", Vector3(0.0, 0.63, 1.18), path_mat, Color(0.08, 0.06, 0.02))
	_add_route_marker(dressing, "Phase21RedoStep3Window", "3\nWINDOW", Vector3(-4.95, 0.64, -2.2), green_glow, Color(0.02, 0.08, 0.03))
	_add_route_marker(dressing, "Phase21RedoStep4ClockOut", "4\nCLOCK", Vector3(6.05, 0.65, 3.25), clock_mat, Color(0.02, 0.07, 0.07))
	_add_flow_arrow(dressing, "Phase21RedoPathArrowTicketToBurger", Vector3(0.0, 0.58, 0.1), Vector3(0.18, 0.05, 1.2), path_mat)
	_add_flow_arrow(dressing, "Phase21RedoPathArrowBurgerToWindowA", Vector3(-1.55, 0.59, -0.1), Vector3(1.25, 0.05, 0.18), path_mat)
	_add_flow_arrow(dressing, "Phase21RedoPathArrowBurgerToWindowB", Vector3(-3.25, 0.6, -1.25), Vector3(1.25, 0.05, 0.18), path_mat)
	_add_flow_arrow(dressing, "Phase21RedoPathArrowWindowToClock", Vector3(1.1, 0.61, 3.2), Vector3(4.4, 0.05, 0.16), path_mat)

	_add_box(dressing, "Phase21RedoRegisterHalo", Vector3(3.8, 0.44, -2.2), Vector3(1.75, 0.06, 1.4), lobby_mat, false)
	_add_box(dressing, "Phase21RedoGrillHalo", Vector3(1.8, 0.45, 3.6), Vector3(1.95, 0.06, 1.35), kitchen_mat, false)
	_add_box(dressing, "Phase21RedoFryerHalo", Vector3(3.8, 0.46, 2.8), Vector3(1.55, 0.06, 1.35), kitchen_mat, false)
	_add_box(dressing, "Phase21RedoSauceHalo", Vector3(-1.8, 0.47, 2.8), Vector3(1.45, 0.06, 1.25), restock_mat, false)
	_add_box(dressing, "Phase21RedoHandoffSpot", Vector3(-5.85, 0.5, -2.2), Vector3(1.15, 0.08, 1.0), green_glow, false)

	_add_label(dressing, "Phase21RedoPlayerStartSign", "START HERE\nLook around, then follow 1-4.", Vector3(0.0, 2.2, -5.45), Color(0.95, 1.0, 1.0), 22)
	_add_label(dressing, "Phase21RedoKitchenOverheadSign", "KITCHEN: GRILL + FRYER", Vector3(2.7, 2.72, 4.95), Color(1.0, 0.84, 0.5), 22)
	_add_label(dressing, "Phase21RedoDriveThruOverheadSign", "DRIVE-THRU\nSERVE ON GREEN", Vector3(-5.9, 2.95, -3.55), Color(0.75, 1.0, 0.7), 22)
	_add_label(dressing, "Phase21RedoPrepOverheadSign", "PREP TABLE\nBURGER + BAG", Vector3(-0.6, 2.32, -0.85), Color(0.76, 1.0, 0.78), 21)
	_add_label(dressing, "Phase21RedoHotLineIcon", "HOT", Vector3(2.6, 1.98, 3.55), Color(1.0, 0.38, 0.18), 20)
	_add_label(dressing, "Phase21RedoTicketIcon", "ORDER\nTICKET", Vector3(-0.12, 2.28, 0.28), Color(0.05, 0.05, 0.05), 18)
	_add_box(dressing, "Phase21RedoReadableBurgerBun", Vector3(0.45, 1.78, 1.18), Vector3(0.58, 0.14, 0.58), _mat("Phase21 redo extra burger bun", Color(0.94, 0.66, 0.28), 0.7), false)
	_add_box(dressing, "Phase21RedoDrinkLid", Vector3(-1.8, 2.05, 2.45), Vector3(0.5, 0.08, 0.5), white_mat, false)

func _add_zone_band(dressing: Node, node_name: String, pos: Vector3, size: Vector3, mat: Material, label_text: String, label_pos: Vector3, label_color: Color):
	_add_box(dressing, node_name, pos, size, mat, false)
	_add_label(dressing, node_name + "Label", label_text, label_pos, label_color, 18)

func _add_route_marker(dressing: Node, node_name: String, text: String, pos: Vector3, mat: Material, text_color: Color):
	_add_box(dressing, node_name, pos, Vector3(0.8, 0.08, 0.8), mat, false)
	_add_label(dressing, node_name + "Label", text, pos + Vector3(0.0, 0.36, 0.0), text_color, 18)

func _add_flow_arrow(dressing: Node, node_name: String, pos: Vector3, size: Vector3, mat: Material):
	_add_box(dressing, node_name, pos, size, mat, false)

func _mat(resource_name: String, color: Color, roughness: float = 0.75, emission: Color = Color(0, 0, 0, 0)) -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.resource_name = resource_name
	mat.albedo_color = color
	mat.roughness = roughness
	if emission.a > 0.0:
		mat.emission_enabled = true
		mat.emission = emission
		mat.emission_energy_multiplier = 0.25
	return mat

func _set_mesh_material(node_name: String, mat: Material):
	var node = find_child(node_name, true, false)
	if not node:
		return
	for child in node.get_children():
		var mesh_instance = child as MeshInstance3D
		if mesh_instance and mesh_instance.mesh != null and mesh_instance.mesh.get_surface_count() > 0:
			mesh_instance.set_surface_override_material(0, mat)

func _add_box(parent: Node, node_name: String, pos: Vector3, size: Vector3, mat: Material, collision: bool):
	if parent.get_node_or_null(node_name):
		return parent.get_node_or_null(node_name)
	var container = StaticBody3D.new() if collision else Node3D.new()
	container.name = node_name
	container.position = pos
	parent.add_child(container)
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = node_name + "Mesh"
	var box = BoxMesh.new()
	box.size = size
	mesh_instance.mesh = box
	mesh_instance.set_surface_override_material(0, mat)
	container.add_child(mesh_instance)
	if collision:
		var collision_shape = CollisionShape3D.new()
		var shape = BoxShape3D.new()
		shape.size = size
		collision_shape.shape = shape
		container.add_child(collision_shape)
	return container

func _add_cylinder(parent: Node, node_name: String, pos: Vector3, radius: float, height: float, mat: Material, collision: bool):
	if parent.get_node_or_null(node_name):
		return parent.get_node_or_null(node_name)
	var container = StaticBody3D.new() if collision else Node3D.new()
	container.name = node_name
	container.position = pos
	parent.add_child(container)
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = node_name + "Mesh"
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius
	cylinder.height = height
	cylinder.radial_segments = 16
	mesh_instance.mesh = cylinder
	mesh_instance.set_surface_override_material(0, mat)
	container.add_child(mesh_instance)
	if collision:
		var collision_shape = CollisionShape3D.new()
		var shape = CylinderShape3D.new()
		shape.radius = radius
		shape.height = height
		collision_shape.shape = shape
		container.add_child(collision_shape)
	return container

func _add_station_label(node_name: String, text: String, color: Color):
	var node = find_child(node_name, true, false)
	if not node or node.get_node_or_null("Phase17Sign"):
		return
	var label = Label3D.new()
	label.name = "Phase17Sign"
	label.text = text
	label.position = Vector3(0.0, 0.78, 0.0)
	label.font_size = 22
	label.pixel_size = 0.0045
	label.modulate = color
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.outline_size = 3
	label.outline_modulate = Color(0.04, 0.04, 0.04)
	node.add_child(label)

func _add_label(parent: Node, node_name: String, text: String, pos: Vector3, color: Color, font_size: int):
	if parent.get_node_or_null(node_name):
		return
	var label = Label3D.new()
	label.name = node_name
	label.text = text
	label.position = pos
	label.font_size = font_size
	label.pixel_size = 0.006
	label.modulate = color
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.outline_size = 5
	label.outline_modulate = Color(0.02, 0.02, 0.02)
	parent.add_child(label)

func _ensure_demo_light(node_name: String, pos: Vector3, color: Color, energy: float):
	if get_node_or_null(node_name):
		return
	var light = OmniLight3D.new()
	light.name = node_name
	light.position = pos
	light.light_color = color
	light.light_energy = energy
	light.omni_range = 7.0
	add_child(light)

func _play_audio_hook(hook_name: String):
	var audio = _autoload("AudioManager")
	if audio and audio.has_method("play_sfx"):
		audio.play_sfx(hook_name)

func _spawn_chaos_runtime_if_missing():
	if find_child("ChaosIncidentRuntime", true, false):
		return
	var runtime = ChaosIncidentRuntimeScript.new()
	runtime.name = "ChaosIncidentRuntime"
	add_child(runtime)

func _spawn_mischief_runtime_if_missing():
	_add_runtime_node_if_missing("MischiefDirector", MischiefDirectorScript)
	_add_runtime_node_if_missing("PrankWarManager", PrankWarManagerScript)
	_add_runtime_node_if_missing("RestaurantDamageManager", RestaurantDamageManagerScript)
	_add_runtime_node_if_missing("MischiefRecapManager", MischiefRecapManagerScript)

func _spawn_consequence_runtime_if_missing():
	_add_runtime_node_if_missing("SuspicionManager", SuspicionManagerScript)
	_add_runtime_node_if_missing("FireableOffenseManager", FireableOffenseManagerScript)
	_add_runtime_node_if_missing("ShadyChoiceManager", ShadyChoiceManagerScript)
	_add_runtime_node_if_missing("TipJarManager", TipJarManagerScript)
	_add_runtime_node_if_missing("RegisterIntegrityManager", RegisterIntegrityManagerScript)
	_add_runtime_node_if_missing("InventoryMisconductManager", InventoryMisconductManagerScript)
	_add_runtime_node_if_missing("FoodKarmaManager", FoodKarmaManagerScript)
	_add_runtime_node_if_missing("AbstractImpairmentManager", AbstractImpairmentManagerScript)
	_add_runtime_node_if_missing("ManagerCoverupManager", ManagerCoverupManagerScript)
	_add_runtime_node_if_missing("FiringRecoveryManager", FiringRecoveryManagerScript)

func _spawn_emergent_runtime_if_missing():
	_add_runtime_node_if_missing("RestaurantMemoryManager", RestaurantMemoryManagerScript)
	_add_runtime_node_if_missing("EvidenceManager", EvidenceManagerScript)
	_add_runtime_node_if_missing("StoreObjectMemoryManager", StoreObjectMemoryManagerScript)
	_add_runtime_node_if_missing("ConsequenceMatrixManager", ConsequenceMatrixManagerScript)
	_add_runtime_node_if_missing("EmergentMissionGenerator", EmergentMissionGeneratorScript)
	_add_runtime_node_if_missing("MultiKarmaManager", MultiKarmaManagerScript)
	_add_runtime_node_if_missing("DynamicReputationLabelManager", DynamicReputationLabelManagerScript)
	_add_runtime_node_if_missing("GeneratedRecapManager", GeneratedRecapManagerScript)
	_add_runtime_node_if_missing("FutureChainTriggerManager", FutureChainTriggerManagerScript)
	_add_runtime_node_if_missing("EmergentEventDirector", EmergentEventDirectorScript)

func _spawn_depth_runtime_if_missing():
	_add_runtime_node_if_missing("NormalcyBalanceDirector", NormalcyBalanceDirectorScript)
	_add_runtime_node_if_missing("DepthEventLinker", DepthEventLinkerScript)
	_add_runtime_node_if_missing("WorldTextureManager", WorldTextureManagerScript)
	_add_runtime_node_if_missing("ShiftFlavorManager", ShiftFlavorManagerScript)
	_add_runtime_node_if_missing("ContentDensityValidatorRuntime", ContentDensityValidatorRuntimeScript)
	_add_runtime_node_if_missing("DepthDirector", DepthDirectorScript)

func _add_runtime_node_if_missing(node_name: String, script_resource: Script):
	if find_child(node_name, true, false):
		return
	var node = script_resource.new()
	node.name = node_name
	add_child(node)

func _connect_staff_hud():
	var staff_director = find_child("StaffDirector", true, false)
	if staff_director and hud and hud.has_method("set_staff_status"):
		if staff_director.has_signal("staff_status_changed"):
			staff_director.staff_status_changed.connect(hud.set_staff_status)
		if staff_director.has_method("get_shift_effects"):
			hud.set_staff_status(staff_director.get_shift_effects())

func _connect_store_ops_hud():
	var store_ops = find_child("StoreOpsDirector", true, false)
	if store_ops and hud and hud.has_method("set_store_ops_status"):
		if store_ops.has_signal("store_ops_status_changed"):
			store_ops.store_ops_status_changed.connect(hud.set_store_ops_status)
		if store_ops.has_method("get_shift_effects"):
			hud.set_store_ops_status(store_ops.get_shift_effects())

func _connect_daily_tasks_hud():
	var daily = find_child("DailyTaskManager", true, false)
	if daily and hud and hud.has_method("set_daily_tasks"):
		if daily.has_signal("daily_tasks_generated"):
			daily.daily_tasks_generated.connect(hud.set_daily_tasks)
		if daily.has_signal("daily_task_updated"):
			daily.daily_task_updated.connect(hud.set_daily_tasks)
		if daily.has_method("get_task_status"):
			hud.set_daily_tasks(daily.get_task_status())

func _connect_career_hud():
	var career = _autoload("CareerManager")
	if career and hud and hud.has_method("set_career_status"):
		if career.has_signal("career_progress_changed"):
			career.career_progress_changed.connect(hud.set_career_status)
		if career.has_method("get_career_status"):
			hud.set_career_status(career.get_career_status())
