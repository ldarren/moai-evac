--
-- EVAC Sim
--

Avatar = require 'modules/avatar'

sw = MOAIEnvironment.horizontalResolution or 1024
sh = MOAIEnvironment.verticalResolution or sw * 9/16
r = sh/sw

MOAISim.openWindow("EVAC Sim", sw, sh)

layer = MOAILayer2D.new ()
MOAISim.pushRenderPass ( layer )

MOAIUntzSystem.initialize ()
sound = MOAIUntzSound.new ()
sound:load ( 'mono16.wav' )
sound:setVolume ( 1 )
sound:setLooping ( false )

viewport = MOAIViewport.new ()
viewport:setSize ( sw, sh)
viewport:setScale ( 1024, math.ceil(1024 * r))
layer:setViewport ( viewport )

partition = MOAIPartition.new ()
layer:setPartition(partition)

player = Avatar.create('player', {0, 0})
Avatar.setSprite(player, "../PlayerSpriteSheet.png", {5, 4}, { -51, -51, 51, 51 })
Avatar.setAnimation(player, 10, 19)
partition:insertProp(prop)

enemyTiles = MOAITileDeck2D.new ()
enemyTiles:setTexture("EnemySpriteSheet.png")
enemyTiles:setSize ( 5, 6 )
enemyTiles:setRect ( -51, -51, 51, 51 )

function addObject(name, x, y, deck)
  local prop = MOAIProp2D.new ()
  prop:setDeck(deck)
  prop:setLoc(x, y)
  prop.name = name
  partition:insertProp(prop)
  return prop
end

function createMover(first, last)
  local curve = MOAIAnimCurve.new ()
  local size = last - first + 1
  local step = 1 / size

  curve:reserveKeys ( size )
  for i=1, size do
    curve:setKey ( i, step * (i-1), first+i-1, MOAIEaseType.FLAT )
  end

  return curve
end

function animObject(mover, obj)
  local anim = MOAIAnim:new ()
  anim:reserveLinks ( 1 )
  anim:setLink ( 1, mover, obj, MOAIProp2D.ATTR_INDEX )
  anim:setMode ( MOAITimer.LOOP )
  anim:start ()
end

function moveCB(x, y)
  pickX, pickY = layer:wndToWorld(x, y)
end

function clickCB(isDown)
  if isDown then
    local e = partition:propForPoint(pickX, pickY)

    if e then
      print (e.name)
      enemy = e
    elseif enemy then
      local ex, ey = enemy:getLoc()
      local e = enemy

      if e.action then e.action:stop() end -- clear previous action

      enemy:seekRot(math.deg(math.atan2(pickX - ex, ey - pickY)), 3, MOAIEaseType.EASE_IN)
      local action = enemy:seekLoc(pickX, pickY, 10, MOAIEaseType.LINEAR)
      enemy.action = action

      animObject(walkAnim, enemy)
      action:setListener(MOAIAction.EVENT_STOP, function ()
        if not e.action or not e.action:isBusy() then
          animObject(idleAnim, e)
        end
      end)
      sound:play ()
    end
  end
end

walkAnim = createMover(1, 10)
idleAnim = createMover(11, 20)
-- enemy1 = addObject('darren', -100, 0, enemyTiles)
enemy1 = Avatar.create('darren', {-100, 0})
Avatar.setSprite(enemy1, "PlayerSpriteSheet.png", {5, 4}, { -51, -51, 51, 51 })
enemy2 = addObject('peisan', 100, 0, enemyTiles)
animObject(idleAnim, enemy1)
animObject(idleAnim, enemy2)

MOAIInputMgr.device.touch:setCallback (
  function(eventType, idx, x, y, tapCount)
    moveCB(x, y)

    if eventType == MOAITouchSensor.TOUCH_DOWN then
      clickCB(true)
    elseif eventType == MOAITouchSensor.TOUCH_UP then
      clickCB(false)
    end
  end
)
