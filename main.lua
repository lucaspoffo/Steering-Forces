Object = require 'libraries/classic/classic'
Vector = require 'libraries/hump/vector'
wf = require 'libraries/windfield'
Input = require 'libraries/boipushy/Input'
require 'Entity'
require 'SteeringManager'

function love.load()
	--BINDS
	input = Input()
	input:bind('p','p')


    world = wf.newWorld(0, 0, true)
    world:setQueryDebugDrawing(true) -- Draws the area of a query for 10 frames



    entities = {}
    for i = 1, 10 do
        table.insert(entities, Entity(world, love.math.random(0, 800), love.math.random(0, 600), {r= 16}))
    end
    for _, entity in ipairs(entities) do
            entity.neighbours = entities
        end
end

function love.update(dt)
    world:update(dt)
    for _, entity in ipairs(entities) do
            entity:update(dt)
    end

    if input:pressed('p') then
        local colliders = world:queryCircleArea(400, 300, 100)
        for _, collider in ipairs(colliders) do
            collider:applyLinearImpulse(200, 200)
        end
    end
end

function love.draw()
	for _, entity in ipairs(entities) do
            entity:draw()
    end
    world:draw(50)
end
