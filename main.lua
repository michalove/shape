states = {}
states.game = require('scripts/game')
states.explanation = require('scripts/explanation')
states.highscore = require('scripts/highscore')
states.menu = require('scripts/menu')
states.modeselect = require('scripts/modeselect')
states.custom = require('scripts/custom')
states.unlock = require('scripts/unlock')
require('scripts/shape')
require('scripts/sound')


function newGame()
	started = false
	timer = 0
	score = 0
	level = 0
	states.explanation.goto()
end

function makeWindow()
	if fullscreen then
		local width, height = love.window.getDesktopDimensions( display )
		local options = {fullscreen = true,fullscreentype = 'desktop'}
		love.window.setMode( width,height, options)
		scaling = math.min(height/520,width/500)
		xShift = (width-(500*scaling))*0.5
		yShift = (height-(520*scaling))*0.5
		
		--xleft = -(width/scaling-500)*0.5
		--xwidth = width/scaling
		xleft = -5
		xwidth = 510
	else
		love.window.setMode( 500, 520 )
		scaling = 1
		xShift = 0
		yShift = 0
		xleft = 0
		xwidth = 500
	end
	createFont()
end

function createFont()
	logo = love.graphics.newImage('images/logo.png')
	largeFont = love.graphics.newFont('font/CaviarDreams.ttf',50*scaling)	
	smallFont = love.graphics.newFont('font/Caviar_Dreams_Bold.ttf',20*scaling)
	tinyFont = love.graphics.newFont('font/Caviar_Dreams_Bold.ttf',11*scaling)
end

function love.load()
	-- load state
	loadFromFile()
	makeWindow()
	
	-- initialize
	--soundOn = true
	initShapes()
	loadSounds()
	
	-- define some colors
	colorBG = {15,15,25}
	colorBox = {45,45,55}
	colorFG = {180,180,180}
	colorEmph = {250,250,250}
	--love.graphics.setBackgroundColor(colorBG)
		
	-- start game in menu
	states.menu.goto()
end

function myPrint(text,x,y,width,align)
	love.graphics.push()
	love.graphics.scale(1/scaling)
	love.graphics.printf(text,x*scaling,y*scaling,width*scaling,align)
	love.graphics.pop()
end	

function loadFromFile()
	local filename = 'config.txt'
	if love.filesystem.exists(filename) then
		local content = {}
		for line in love.filesystem.lines(filename) do
			table.insert(content,line)
		end
		lock = tonumber(content[1])
		soundOn = (tonumber(content[2]) == 1)
		fullscreen = (tonumber(content[3]) == 1)
		customMode = {
				name = 'custom',
				nColor = tonumber(content[5]),
				nShape = tonumber(content[6]),
				nFill = tonumber(content[7]),
				nLevels = tonumber(content[4]),
				threshold = 50000,
				isRandom = (tonumber(content[8]) == 1)
				}		

		--print(lock)
		--print(soundOn)	
	else
		lock = 1
		soundOn = true

		customMode = {
				name = 'custom',
				nColor = 3,
				nShape = 5,
				nFill = 1,
				nLevels = 9,
				threshold = 50000,
				isRandom = true
				}
		-- create file:
		saveState()
	end
end

function saveState()
	local soundFlag = 0
	local randomFlag = 0
	local screenFlag = 0
	if soundOn then
		soundFlag = 1
	end
	if customMode.isRandom then
		randomFlag = 1
	end
	if fullscreen then
		screenFlag = 1
	end
	
	love.filesystem.append('config.txt', randomFlag)
	local output = lock ..'\n' .. soundFlag ..'\n' .. screenFlag .. '\n' .. customMode.nLevels ..'\n' .. customMode.nColor ..'\n' .. customMode.nShape ..'\n' .. customMode.nFill ..'\n' .. randomFlag	..'\n'
	
	love.filesystem.write('config.txt', output)	
end


function love.draw()
	love.graphics.translate(xShift,yShift)
	love.graphics.scale(scaling)

	love.graphics.setColor(colorBG)
	love.graphics.rectangle('fill',xleft,0,xwidth,520)
				
	love.graphics.setScissor( xleft*scaling+xShift, 0, xwidth*scaling, 520*scaling )
	
	if states[state] then
		states[state].draw()
	end
	
	love.graphics.setScissor( )
	love.graphics.setColor(colorFG)
	love.graphics.setLineWidth(2)
	love.graphics.line(xleft,0,xleft,520)
	love.graphics.line(xleft+xwidth,0,xleft+xwidth,520)	
end

function love.update(dt)
	if states[state] then
		states[state].update(dt)
	end
end

function love.keypressed(key)
	if states[state] then
		states[state].keypressed(key)
	end	
end

function love.textinput(text)
	if states[state] and states[state].textinput then
		states[state].textinput(text)
	end
end
