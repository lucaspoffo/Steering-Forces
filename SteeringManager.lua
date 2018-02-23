SteeringManager = Object:extend()

function SteeringManager:new(agent)
	self.agent = agent
	self.arrival_force = Vector(0,0)
	self.separation_force = Vector(0,0)
	self.cohesion_force = Vector(0,0)
	self.aligment_force = Vector(0,0)
end

function SteeringManager:update(dt)
	--self.steering = self:seek(self.agent.target)
	self.arrival_force = self:arrival(self.agent.target, 64)
	self.separation_force = self:separation(48)
	self.cohesion_force = self:cohesion(128) * .1
	self.aligment_force = self:aligment(128)
	self.steering = self.arrival_force + self.separation_force + self.cohesion_force + self.aligment_force
	self.steering = self.steering:trimInplace(self.agent.max_force)

	local vel = Vector(self.agent.collider:getLinearVelocity())
	
	vel = vel + self.steering

	vel:trimInplace(self.agent.max_speed)

	self.agent.collider:setLinearVelocity(vel.x,vel.y)

	self.steering = Vector(0,0)
end

function SteeringManager:draw()
	love.graphics.push()
    love.graphics.translate(self.agent.x, self.agent.y)
    love.graphics.rotate(self.agent.rotation)
    love.graphics.translate(-self.agent.x, -self.agent.y)
	local velocity = Vector(self.agent.collider:getLinearVelocity())
	--love.graphics.points(self.agent.x, self.agent.y)
	love.graphics.setColor({0,255,0})
	love.graphics.line(self.agent.x, self.agent.y, self.agent.x  + velocity.x, self.agent.y  + velocity.y)
	love.graphics.setColor({255,255,0})
	love.graphics.line(self.agent.x, self.agent.y, self.agent.x  + self.arrival_force.x * 3, self.agent.y  + self.arrival_force.y * 3)
	love.graphics.setColor({255,0,0})
	love.graphics.line(self.agent.x, self.agent.y, self.agent.x  + self.separation_force.x * 3, self.agent.y  + self.separation_force.y * 3)
	love.graphics.setColor({255,0,255})
	love.graphics.line(self.agent.x, self.agent.y, self.agent.x  + self.cohesion_force.x * 3, self.agent.y  + self.cohesion_force.y * 3)
	love.graphics.setColor({0,0,255})
	love.graphics.line(self.agent.x, self.agent.y, self.agent.x  + self.aligment_force.x * 3, self.agent.y  + self.aligment_force.y * 3)
	love.graphics.pop()
end

function SteeringManager:seek(target)
	local dest = Vector(target.x,target.y)
	local pos = Vector(self.agent.x,self.agent.y)
	
	local vel = Vector(self.agent.collider:getLinearVelocity())

	local desired = (dest - pos):normalized() * self.agent.max_speed

	local force = desired - vel
	force:trimInplace(self.agent.max_force)
	return force
end

function SteeringManager:arrival(target, slowing_distance)

	local dest = Vector(target.x,target.y)
	local pos = Vector(self.agent.x,self.agent.y)
	local vel = Vector(self.agent.collider:getLinearVelocity())

	local offset = dest - pos

	local distance = offset:len()

	local ramped_speed = self.agent.max_speed * (distance / slowing_distance)

	local clipped_speed = math.min(ramped_speed, self.agent.max_speed)
	
	local desired_velocity = (clipped_speed / distance) * offset

	local force = desired_velocity - vel
	force:trimInplace(self.agent.max_force)
	return force
	
end

function SteeringManager:separation(min_separation)

	local pos = Vector(self.agent.x,self.agent.y)
	local vel = Vector(self.agent.collider:getLinearVelocity())

	local total_force = Vector(0,0)
	local neighbours_count = 0

	for _, n in ipairs(self.agent.neighbours) do
            if n ~= self.agent then
            	local n_pos = Vector(n.x,n.y)
            	local distance = pos:dist(n_pos)
            	if distance < min_separation and distance > 0 then
            		local push_force = pos - n_pos
            		total_force = total_force + push_force
            		neighbours_count = neighbours_count + 1
            	end
            end
    end

    if neighbours_count == 0 then
    	return Vector(0,0)
    end

    total_force = total_force / neighbours_count
    --total_force:trimInplace(self.agent.max_force)
    return total_force
end

function SteeringManager:cohesion(max_cohesion)
	
	local pos = Vector(self.agent.x,self.agent.y)
	local center_mass = Vector(self.agent.x,self.agent.y)

	local neighbours_count = 1

	for _, n in ipairs(self.agent.neighbours) do
            if n ~= self.agent then
            	local n_pos = Vector(n.x,n.y)
            	local distance = pos:dist(n_pos)
            	if distance < max_cohesion and distance > 0 then
            		center_mass = center_mass + Vector(n.x,n.y)
            		neighbours_count = neighbours_count + 1
            	end
            end
    end

    if neighbours_count == 1 then
    	return Vector(0,0)
    end

    center_mass = center_mass / neighbours_count

    return self:seek(center_mass)

end

function SteeringManager:aligment(max_aligment)
	
	local average_heading = Vector(0,0)
	local neighbours_count = 0
	local pos = Vector(self.agent.x,self.agent.y)

	for _, n in ipairs(self.agent.neighbours) do
            if n ~= self.agent then
            	local n_pos = Vector(n.x,n.y)
            	local distance = pos:dist(n_pos)
            	local n_vel = Vector(n.collider:getLinearVelocity())
            	if distance < max_aligment then
            		average_heading = average_heading + n_vel:normalized()
            		neighbours_count = neighbours_count + 1
            	end
            end
    end

    if neighbours_count == 0 then
    	return Vector(0,0)
    end

    average_heading = average_heading / neighbours_count

    local vel = Vector(self.agent.collider:getLinearVelocity())

    local desired = average_heading * self.agent.max_speed
    local force = desired - vel
    force = force * (self.agent.max_force / self.agent.max_speed)
    return force
end
