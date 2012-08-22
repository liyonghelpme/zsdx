local map = ...
-- Dungeon 10 2F

function map:on_started(destination_point_name)

  if map:get_game():get_boolean(205) then
    map:block_set_enabled("block1_1",false)
    lock_torches_group1()
  end

  if map:get_game():get_boolean(206) then
    map:block_set_enabled("block2_1",false)
    lock_torches_group2()
  end

  if map:get_game():get_boolean(227) then
    map:switch_set_activated("switch1_1", true)
    map:switch_set_activated("switch1_2", true)
    map:switch_set_activated("switch1_3", true)
    map:switch_set_activated("switch1_4", true)
  end
end

function are_group1_torches_on()

  return map:npc_exists("torch1_1")
  and map:npc_get_sprite("torch1_1"):get_animation() == "lit"
  and map:npc_get_sprite("torch1_2"):get_animation() == "lit"
  and map:npc_get_sprite("torch1_3"):get_animation() == "lit"
end

function are_group2_torches_on()

  return map:npc_exists("torch2_1")
  and map:npc_get_sprite("torch2_1"):get_animation() == "lit"
  and map:npc_get_sprite("torch2_2"):get_animation() == "lit"
  and map:npc_get_sprite("torch2_3"):get_animation() == "lit"
end


function lock_torches_group1()

  map:npc_remove("torch1_1")
  map:npc_remove("torch1_2")
  map:npc_remove("torch1_3")
end

function lock_torches_group2()

  map:npc_remove("torch2_1")
  map:npc_remove("torch2_2")
  map:npc_remove("torch2_3")
end

function map:on_switch_activated(switch_name)

  local error
  if switch_name == "switch1_1"  then
    error = false
    if map:switch_is_activated("switch1_2") 
      or map:switch_is_activated("switch1_3") 
      or map:switch_is_activated("switch1_4") then
      error = true
    end
  end

  if switch_name == "switch1_2" then
    if map:switch_is_activated("switch1_1") == false  then
      error = true
    end
  end

  if switch_name == "switch1_3" then
    if  map:switch_is_activated("switch1_2") == false then
      error = true			
    end
  end

  if switch_name == "switch1_4" then
    if  map:switch_is_activated("switch1_3") == false then
      error = true			
    end
  end

  if error then
    switch1_error()
  end

  if map:switch_is_activated("switch1_1") 
    and map:switch_is_activated("switch1_2") 
    and map:switch_is_activated("switch1_3")
    and map:switch_is_activated("switch1_4") then
    sol.audio.play_sound("secret")
    map:create_pickable("small_key", 1, 227, 144, 504, 0)
  end
end

function switch1_error()

  sol.audio.play_sound("wrong")
  map:switch_set_activated("switch1_1", false)
  map:switch_set_activated("switch1_2", false)
  map:switch_set_activated("switch1_3", false)
  map:switch_set_activated("switch1_4", false)
end

function map:on_enemy_dead(enemy_name)

  if enemy_name:find("enemy_group2") 
      and map:enemy_is_group_dead("enemy_group2")
      and not map:get_game():get_boolean(221) then

    map:move_camera(232, 728, 250, function()
      map:create_pickable("small_key", 1, 221, 232, 733, 1)
      sol.audio.play_sound("secret")
    end)
  end
end

function explode_block1() 

  map:create_explosion(536, 256, 1)
  sol.audio.play_sound("explosion")
  sol.audio.play_sound("secret")
  map:block_set_enabled("block1_1",false)
end

function explode_block2() 

  map:create_explosion(552, 256, 1)
  sol.audio.play_sound("explosion")
  sol.audio.play_sound("secret")
  map:block_set_enabled("block2_1",false)
end

function map:on_update()

  if not map:get_game():get_boolean(205)
      and are_group1_torches_on() then
    map:get_game():set_boolean(205, true)
    lock_torches_group1()
    map:move_camera(536, 256, 250, explode_block1)
  end

  if not map:get_game():get_boolean(206)
      and are_group2_torches_on() then
    map:get_game():set_boolean(206, true)
    lock_torches_group2()
    map:move_camera(552, 256, 250, explode_block2)
  end
end

