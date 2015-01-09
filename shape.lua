local function randomPermutation(n)
	local perm = {}
	for i=1,n do
		perm[i] = i
	end
	for i=1,n-1 do
		j=love.math.random(i,n)
		perm[i],perm[j] = perm[j],perm[i]
	end
	return perm
end

function newOrder(nColor,nShape,nFill)
	nStages = nColor*nShape*nFill
	stages = {}
	-- randomly select some shapes, colors, fillstyles
	colorPerm = randomPermutation(8)
	shapePerm = randomPermutation(4)
	fillPerm = randomPermutation(2)
	-- generate all combinations in order
	for i=0,nStages-1 do
		local N = i
		local thisFill= N%nFill
		N = (N-thisFill)/nFill
		local thisShape = N%nShape
		N = (N-thisShape)/nShape
		local thisColor = N%nColor
		thisFill = thisFill + 1
		thisShape = thisShape + 1
		thisColor = thisColor + 1
		newStage = {shape = shapePerm[thisShape], color=colorPerm[thisColor],fill=fillPerm[thisFill]}
		table.insert(stages,newStage)
	end
	-- shuffle
	for i=1,nStages-1 do
		j = love.math.random(i,nStages)
		stages[i],stages[j] =	stages[j],stages[i]
	end
	-- assign direction
	local first = love.math.random(2)
	stages[1].direction = first
	count={0,0}
	count[first] = 1
	for i=2,#stages do
		local thisDirection
		if love.math.random() < count[1]/(count[1]+count[2]) then
			thisDirection = 2
		else
			thisDirection = 1
		end
			count[thisDirection] = count[thisDirection] + 1 
			stages[i].direction = thisDirection
	end
	
	--for k,v in ipairs(stages) do
	--	print(v.color .. v.shape .. v.fill .. ', ' .. v.direction)
	--end
	return stages
end

function generateLevel(stages,level,nShapes)
	local newLevel = {}
	for i=1,nShapes do
		table.insert(newLevel,stages[love.math.random(level)])
	end
	return newLevel
end

function initShapes()
	color = {
		{170,0,0},
		{33,68,120},
		{45,80,22},
		{255,204,0},
		{255,102,0},
		{0,170,136},
		{233,221,175},
		{68,33,120},
	}
	outline = {}
	-- rectangle
	outline[1] = {-.8,-.8,-.8,.8,.8,.8,.8,-.8}
	-- triangle
	outline[2] = {0,-.8,-0.8,0.8,0.8,0.8}
	-- star
	outline[3] = {}
	for i=0,4 do
		local factor = 0.9
		outline[3][4*i+1] = math.sin(i*math.pi*2/5) * factor
		outline[3][4*i+2] = -math.cos(i*math.pi*2/5) * factor
		outline[3][4*i+3] = 0.382*math.sin((i+0.5)*math.pi*2/5) * factor
		outline[3][4*i+4] = 0.382*-math.cos((i+0.5)*math.pi*2/5)		 * factor
	end
	-- circle
	outline[4] = {}
	local nSeg = 40
	local factor = 0.9
	for i=0,nSeg-1 do
		outline[4][2*i+1] = math.sin(i*math.pi*2/nSeg) * factor
		outline[4][2*i+2] = -math.cos(i*math.pi*2/nSeg) * factor
	end
	
	insides = {}
	for i=1,#outline do
		if love.math.isConvex(outline[i]) then
		insides[i] = {outline[i]}
		else
		insides[i] = love.math.triangulate(outline[i])
		end
	end
end

function drawShape(x,y,colorIdx,shapeIdx,fillIdx,scale)
	local thisScale = scale or 1
	thisScale = thisScale * 50
	local lineWidth = 5
	local r = color[colorIdx][1]
	local g = color[colorIdx][2]
	local b = color[colorIdx][3]

	love.graphics.origin()
	love.graphics.translate(x,y)
	love.graphics.scale(thisScale,thisScale)	
	love.graphics.setColor(r,g,b)
	love.graphics.setLineWidth(0.2)
	
	for k,v in ipairs(insides[shapeIdx]) do
		if fillIdx == 1 then
			love.graphics.polygon('fill',v)
		end
	end
	love.graphics.polygon('line',outline[shapeIdx])
	love.graphics.origin()
end
