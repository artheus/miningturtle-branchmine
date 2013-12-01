local args = { ... }

function showUsage ()
	print("Usage: branchmine <depth> [width=depth]")
	print("---")
	print("branchmine help - to show this usage message")
end

if args[1] == "help" then
	showUsage()
	return
end

-- Check the command arguments
local mineDepth = tonumber(args[1])
local mineWidth = tonumber(args[2])

local xFromHome = 0
local yFromHome = 0

local currentDirection = 1

if mineDepth == nil then
	showUsage()
	return
end

if mineWidth == nil then
	print("Using width same as depth "..mineDepth)
	mineWidth = mineDepth * 6 - 2
end

-- Common functions

function checkDirection ()
	if currentDirection == 5 then currentDirection = 1 end
	if currentDirection == 0 then currentDirection = 4 end
end

function printFuelLevel ()
	print("Fuel level: "..turtle.getFuelLevel())
end

function turnLeft ()
	turtle.turnLeft()
	currentDirection = currentDirection + 1
	checkDirection()
end

function turnRight ()
	turtle.turnRight()
	currentDirection = currentDirection - 1
	checkDirection()
end

function goForward ()
	if turtle.getFuelLevel() < 5 then
		turtle.select(1)
		turtle.refuel(1)
	end

	if turtle.getFuelLevel() <= getDistanceFromHome() then
		turtle.select(1)
		if not turtle.refuel(1) then
			print("Fuel level critical")
			goHome()
		end
	end

	repeat
		turtle.dig()
	until not turtle.detect()
	
	turtle.forward()

	if currentDirection == 1 then
		xFromHome = xFromHome + 1
	elseif currentDirection == 2 then
		yFromHome = yFromHome + 1
	elseif currentDirection == 3 then
		xFromHome = xFromHome - 1
	elseif currentDirection == 4 then
		yFromHome = yFromHome  - 1
	end
end

function getDistanceFromHome ()
	local home = vector.new(0, 0, 0)
	local pos = vector.new(xFromHome, yFromHome, 0)

	local dist = pos - home

	return dist.x + dist.y
end

function checkFreeSlots ()
	local count = 0

	for i=4,16 do
		if turtle.getItemCount(i) == 0 then
			count = count + 1
		end
	end

	return count
end

function digSingle ()
	if checkFreeSlots() == 0 then shell.run("compactItems") end

	if checkFreeSlots() > 0 then
		goForward()
		if turtle.detectUp() then
			if checkFreeSlots == 0 then
				local exists = false
				for i=4,16 do
					turtle.select(i)
					if turtle.compareUp() then
						exists = true
						break
					end
				end
				
				if not exists then
					print("No more free slots")
					goHome()
				end
			end
			
			turtle.digUp()
		end
	else
		print("No more free slots")
		goHome()
	end
end

function digATunnel ()
	for i=1,mineWidth-1 do
		digSingle()
	end

	turnLeft()
	digSingle()
	digSingle()
	digSingle()
	turnLeft()

	for i=1,mineWidth-1 do
		digSingle()
	end
end

function goHome ()
	local loX = xFromHome
	local loY = yFromHome
	
	print("Going back home..")
	goTo(0,0, true)

	-- Empty inventory (front)
	for i=4,16 do
		turtle.select(i)
		turtle.drop()
	end

	local fuelLevelNow = turtle.getFuelLevel()

	-- Check for fuel (up)
	if fuelLevelNow < 5 then
		if turtle.getItemCount(1) == 0 then print("Waiting for fuel..") end
		turtle.select(1)
		repeat
			if turtle.getItemCount(1) > 0 then
				if not turtle.refuel(1) then
					print("Ew.. this is not fuel!")
					turtle.drop()
				end
			end
		until fuelLevelNow ~= turtle.getFuelLevel()
	end

	-- Go back
	print("Going back to where I left of.")
	goTo(loX, loY)
end

function goToX (x)
	local xDir = (xFromHome == x)

    if not xDir then
        if xFromHome>x then xDir = 3 end
        if xFromHome<x then xDir = 1 end

        repeat
            turnLeft()
        until currentDirection == xDir

        repeat
            goForward()
        until xFromHome == x
    end
end

function goToY (y)
	local yDir = (yFromHome == y)
	if yDir then
		print("yDir: true")
	else
		print("yDir: false")
	end
	print("y: "..y)
	print("yFromHome: "..yFromHome)

    if not yDir then
        if yFromHome>y then yDir = 4 end
        if yFromHome<y then yDir = 2 end

		print("yDir: "..yDir)

        repeat
            turnLeft()
			print("curDir: "..currentDirection)
        until currentDirection == yDir

        repeat
            goForward()
			print("yFromHome: "..yFromHome)
        until yFromHome == y
    end
end

function goTo (x,y,yFirst)
	if yFirst == nil then yFirst = true end

	if yFirst then
		goToY(y)
		goToX(x)
	else
		goToX(x)
		goToY(y)
	end
end

-- Initial fuel check
if turtle.getFuelLevel() == 0 then
	-- Attempt refuel
	turtle.select(1)
	if not turtle.refuel(1) then
		print("No fuel..")
		return
	else
		printFuelLevel()
	end
else
	printFuelLevel()
end

-- Start mining
print("Attempting to start mining.")

digSingle()

xFromHome = 0
yFromHome = 0

for i=1,mineDepth do
	if quitProgram then break end
	-- Dig one U shaped tunnel
	digATunnel()

	-- Turn around for next runnel
	if i < mineDepth then
		turnRight()
		digSingle()
		digSingle()
		digSingle()
		turnRight()
	end
end

goTo(0,0)
