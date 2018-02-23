Entity = Object:extend()

function Entity:new(world,x,y, opts)
	self.world = world
	self.x, self.y = x, y
	self.w, self.h = w, h
	self.v = 20
	self.r = opts.r or 16
	self.collider = world:newCircleCollider(x, y, self.r)
	self.collider:setObject(self)
	self.steering = SteeringManager(self)
	
	self.neighbours = {}

	--STERING
	self.mass = opts.mass or 1
	--self.velocity = Vector(0,0)
	self.max_force = 20
	self.max_speed = 200
	self.rotation = 0


	self.target = {x = 150, y = 150}
end

function Entity:update(dt)
	self.x, self.y = self.collider:getPosition()
	self.rotation = self.collider:getAngle()
	self.steering:update(dt)
	self.target.x , self.target.y = love.mouse:getPosition()
end

function Entity:draw()
	love.graphics.push()
	love.graphics.translate(self.x,self.y)
	love.graphics.rotate(self.rotation)
	love.graphics.translate(-self.x,-self.y)
	love.graphics.setColor({255,255,255})
	love.graphics.circle('line', self.x, self.y, self.r)
	love.graphics.pop()
	self.steering:draw()
end