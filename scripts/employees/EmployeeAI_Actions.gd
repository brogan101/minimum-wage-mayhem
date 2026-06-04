func snatch_item():
	var player = get_tree().root.find_child("Player", true, false)
	var interaction = player.get_node_or_null("InteractionHandler") if player else null
	if not interaction:
		return
	
	if interaction.carried_item:
		var item = interaction.carried_item
		print(employee_name, " SNATCHED your ", item.name, "!")
		
		# Take the item from the player
		interaction.drop_item()
		
		# The NPC now carries the item (temporarily)
		# They might throw it in the trash or eat it
		await get_tree().create_timer(2.0).timeout
		if randf() < 0.5:
			print(employee_name, " ate your item. Rude.")
		else:
			print(employee_name, " threw your item across the room!")
			item.apply_central_impulse(Vector3(randf(), 5, randf()) * 10)
