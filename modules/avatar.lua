local Avatar = {}

local function create(name, pos)
    local prop = MOAIProp2D.new()
    prop:setLoc(pos[1], pos[2])
    prop.name = name
    return prop
end

local function setSprite(prop, sprite, counts, size)
    local tiles = MOAITileDeck2D.new()
    tiles:setTexture(sprite)
    tiles:setSize( counts[1], counts[2] )
    tiles:setRect( size[1], size[2], size[3], size[4] )

    prop:setDeck(tiles)

    return prop
end

local function setAnimation(prop, first, last)
    local curve = MOAIAnimCurve.new ()
    local size = last - first + 1
    local step = 1 / size

    curve:reserveKeys ( size )
    for i=1, size do
        curve:setKey ( i, step * (i-1), first+i-1, MOAIEaseType.FLAT )
    end

    local anim = MOAIAnim:new ()
    anim:reserveLinks ( 1 )
    anim:setLink ( 1, curve, prop, MOAIProp2D.ATTR_INDEX )
    anim:setMode ( MOAITimer.LOOP )
    anim:start ()

    return prop
end

Avatar.create = create
Avatar.setSprite = setSprite
Avatar.setAnimation = setAnimation

return Avatar
