

function ShowInputKeys()
	local y = 59
	gui.text(10,y+8, "A  ")
	gui.text(10,y+2*8, "B  ")
	gui.text(10,y+3*8, "L  ")
	gui.text(10,y+4*8, "R  ")
	gui.text(10,y+5*8, "up  ")
	gui.text(10,y+6*8, "down  ")
	gui.text(10,y+7*8, "left  ")
	gui.text(10,y+8*8, "right  ")

	local table={}
	table=joypad.get(1)
		if table.A and table.B and table.R then
			gui.text(10,y+9*8, "SUPER ATTACK")
		elseif table.L and table.R then
			gui.text(10,y+9*8, "SPECIAL SKILL")
		elseif table.A then
			gui.text(10,y+8, "A pressed")
		elseif table.B then
			gui.text(10,y+2*8, "B pressed")
		elseif table.L then
			gui.text(10,y+3*8, "L pressed")
		elseif table.R then
			gui.text(10,y+4*8, "R pressed")
		elseif table.up then
			gui.text(10,y+5*8, "up pressed")
		elseif table.down then
			gui.text(10,y+6*8, "down pressed")
		elseif table.left then
			gui.text(10,y+7*8, "left pressed")
		elseif table.right then
			gui.text(10,y+8*8, "right pressed")
	    end
end


function retCoodPrint(str)
	gui.text(10,51,string.format(str))
end

function playerPosCood(p)
	local dir

	if p>=0 and p<=8 then
		dir = "NE"
	elseif p>8 and p<=16 then
		dir = "SE"
	elseif p>16 and p<=24 then
		dir = "SW"
	elseif p>24 and p<=32 then
		dir = "NW"
	end

	retCoodPrint("pos :" .. dir)

	return dir
end

function nodeRepresentation(distX,distY,dir)
	local translated = { boxX1 = 45, boxY1 = 30, boxX2 = 165, boxY2 = 110, boxOX = 115 , boxOY = 70}
	local playerX = (distX/630) * 120
	local playerY = (distY/630) * 80


	if dir == "NE" then
		playerX = playerX
		playerY = -1 * playerY
	elseif dir == "SE" then
		playerX = playerX
		playerY = 1 * playerY
	elseif dir == "SW" then
		playerX = -1 * playerX
		playerY = 1 * playerY
	elseif dir == "NW" then
		playerX = -1 * playerX
		playerY = -1 *playerY
	end

	local playerBoxD = {x1 = translated.boxOX+playerX-2,y1 = translated.boxOY+playerY-2,x2 = translated.boxOX+playerX+2,y2 = translated.boxOY+playerY+2}


	gui.text(49,20,string.format("distFromRival(%f,%f)",playerX,playerY))
	gui.box(translated.boxX1,translated.boxY1,translated.boxX2,translated.boxY2,"black") --main box
	gui.box(102,68,106,72,"red") -- Rival Marking at Origin of the graph
	gui.box(playerBoxD.x1,playerBoxD.y1,playerBoxD.x2,playerBoxD.y2,"blue")

	return {playerX,playerY}

end

function generateOverlays()
	gui.opacity(0.5)

	local Ydistaddress = 0x03002CD8
	local yDist
	local Xdistaddress =0x03002CD4
	local xDist

	local polarCoodAddress = 0x0300288C
	local p
	local dir

	local KIAddressEnemy = 0x03002833
	local kiEnemy
	local HealthAddressEnemy = 0x03004C30
	local hpEnemy

	local KIaddressSelf = 0x0300274B
	local kiSelf
	local HealthAddressSelf = 0x0300273E
	local hpSelf


		yDist=memory.readword(Ydistaddress)
		xDist=memory.readword(Xdistaddress)

		hpSelf = tonumber("000000" .. string.sub(bit.tohex(memory.readword(HealthAddressSelf)),7,8),16)
		kiSelf = memory.readword(KIaddressSelf)
		p = tonumber("000000" .. string.sub(bit.tohex(memory.readword(polarCoodAddress)),7,8),16)
		hpEnemy = memory.readbyte(HealthAddressEnemy)
		kiEnemy = memory.readword(KIAddressEnemy)

		if(hpSelf == 0 or hpEnemy ==0) then

		end

		dir = playerPosCood(p)

		gui.text(10,35,string.format("HP : %d",hpSelf))
		gui.text(10,43,string.format("KI : %d",kiSelf))

		gui.text(200,35,string.format("HP : %d",hpEnemy))
		gui.text(200,43,string.format("KI : %d",kiEnemy))

		ShowInputKeys()
		xy = nodeRepresentation(xDist,yDist,dir)


	return {x = xy[1], y = xy[2], HPPlayer = hpSelf, HPEnemy = hpEnemy, KIPlayer = kiSelf, KIEnemy = kiEnemy}


end

function OutputOverlays(OUTPUTS)
	y = 59
	i = 1
	for k,v in pairs(OUTPUTS) do
		text = k
		gui.text(43,y+8*i,k..v)
		i = i+1
	end
end

function convertOutputsToControls(OUTPUTS)
	local OutButtons = {}

	OutButtons.A = 0
	OutButtons.B = 0
	OutButtons.L = 0
	OutButtons.R = 0
	OutButtons.up = 0
	OutButtons.down = 0
	OutButtons.left = 0
	OutButtons.right = 0

	local controlTable = OutButtons
	local outputsToControlConversion = {}

	index = 1
	for k,v in pairs(OutButtons) do

		if OUTPUTS[index] > 0 then
			val = 1
		elseif OUTPUTS[index] <= 0 then
			val = nil
		end
		OutButtons[k] = val
		index = index + 1

	end

	print(OutButtons)

	print(OUTPUTS)
	joypad.set(1,OutButtons)
	return OutButtons
end


function normalizeControls()
	local OutButtons = {}

	OutButtons.A = nil
	OutButtons.B = nil
	OutButtons.L = nil
	OutButtons.R = nil
	OutButtons.up = nil
	OutButtons.down = nil
	OutButtons.left = nil
	OutButtons.right = nil


	joypad.set(1,OutButtons)

end

function getFrameNumber()

	local framen = vba.framecount()

	return framen

end

function processOverlay(a,b,c,e)


	gui.text(10,140,"Generation : ".. a)
	gui.text(80,140,"Species : " .. b)
	gui.text(140,140,"Organism : ".. c)
	--gui.text(10,148,"Max Fitness : "..MaxFitness)
	if e then
		gui.text(80,148,"Current Fitness : ".. e)
	end
	print("gen :"..a.." species :"..b.." organism :"..c.." fitness :"..e)
end
