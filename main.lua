love.graphics.setDefaultFilter("nearest", "nearest")
local font = love.graphics.newFont("images/alarm clock.ttf")
local music = love.audio.newSource("audio/mars.wav", "stream")
local click = love.audio.newSource("audio/click.wav", "static")
local junk = love.audio.newSource("audio/junk.wav", "static")
local ice = love.audio.newSource("audio/ice.wav", "static")
music:setVolume(0.1) junk:setVolume(0.1) ice:setVolume(0.1) click:setVolume(0.1)
music:setLooping(true)
music:play()
local tiles
--[[TILES:
    1=Covered
    2=Uncovered
    3=Ice
    4=Junk
    5=One
    6=Two
    7=Three
    8=Four
    9=Five
    10=Six
    11=Seven
    12=Eight
    13=Cursor
]]
local tilesheet = love.graphics.newImage("images/tiles.png")
local overlay = love.graphics.newImage("images/overlay.png")
local gridinfo = { sizex = 21, sizey = 15 }
local mouse = {}
local tileselected = false
local clicks
local ices, clickedices
local inmenu = "game"
love.window.setIcon(love.image.newImageData("images/icon.png"))
local function surroundingdebris(x, y)
	local near = 0
	for by = -1, 1 do
		for bx = -1, 1 do
			if
				not (by == 0 and bx == 0)
				and gridinfo.grid[y + by]
				and gridinfo.grid[y + by][x + bx]
				and gridinfo.grid[y + by][x + bx].debris
			then
				near = near + 1
			end
		end
	end
	return near
end

function love.load()
	tiles = {}
	clicks = 10
	ices = 0
	clickedices = 0
	math.randomseed(os.time())
	local cursorimage = love.graphics.newImage("images/cursor.png")
	local cursor = love.mouse.newCursor("images/cursor.png", cursorimage:getWidth() / 2, cursorimage:getHeight() / 2)
	love.mouse.setCursor(cursor)
	love.window.setTitle("Mars Sweeper")
	for y = 0, tilesheet:getWidth() / 16 - 1 do
		for x = 0, tilesheet:getHeight() / 16 - 1 do
			local quad = love.graphics.newQuad(x * 16, y * 16, 16, 16, tilesheet)
			table.insert(tiles, quad)
		end
	end
	print(#tiles)
	gridinfo.grid = {}
	for y = 0, gridinfo.sizey - 1 do
		gridinfo.grid[y + 1] = {}
		for x = 0, gridinfo.sizex - 1 do
			local spotinfo = {
				image = tiles[1],
				px = x * 16 + 8,
				py = y * 16 + 8,
				x = x + 1,
				y = y + 1,
				selected = false,
				debris = (math.random(1, 25) == 25 and "ice") or (math.random(1, 10) == 10 and "junk"),
				near = 0,
				state = "covered",
				clicked = false,
			}
			table.insert(gridinfo.grid[y + 1], x + 1, spotinfo)
			if spotinfo.debris == "ice" then
				ices = ices + 1
			end
		end
	end
end

function love.update(dt)
	if inmenu == "game" then
		mouse.x = math.ceil((love.mouse.getX() - 16) / 32)
		mouse.y = math.ceil((love.mouse.getY() - 16) / 32)
		for i, v in ipairs(gridinfo.grid) do
			for j, y in ipairs(v) do
				if mouse.y == i and mouse.x == j then
					y.selected = true
				else
					y.selected = false
				end
			end
		end
	end
end

function love.draw()
	love.graphics.applyTransform(love.math.newTransform():scale(2, 2))
	if inmenu == "game" then
		for i, v in ipairs(gridinfo.grid) do
			for j, y in ipairs(v) do
				love.graphics.draw(tilesheet, y.image, y.px, y.py)
				if y.selected then
					love.graphics.draw(tilesheet, tiles[13], y.px, y.py)
				end
				y.near = surroundingdebris(j, i)
				if y.state == "uncovered" then
					y.image = tiles[2]
					if y.debris then
						love.graphics.draw(tilesheet, tiles[y.debris == "ice" and 3 or 4], y.px, y.py)
					elseif y.near > 0 then
						love.graphics.draw(tilesheet, tiles[y.near + 4], y.px, y.py)
					end
				end
			end
		end
		love.graphics.setColor(love.math.colorFromBytes(66, 129, 245))
		love.graphics.rectangle("fill", 362, 272, 20, -255 * (clickedices / ices))
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(overlay)
		love.graphics.setColor(0, 1, 0)
		love.graphics.print("CLKS: " .. string.format("%.2d", clicks), font, 32 / 2, 533 / 2)
		love.graphics.setColor(1, 1, 1)
	elseif inmenu == "pause" then
		love.graphics.draw(overlay)
		local ox = love.graphics.newText(font, pausetext):getWidth() / 2
        if pausetext == "PRESS ESC TO UNPAUSE" then
        love.graphics.setColor(0, 1, 0)
		love.graphics.print("CLKS: " .. string.format("%.2d", clicks), font, 32 / 2, 533 / 2)
		love.graphics.setColor(1, 1, 1)
        love.graphics.print(pausetext, font, 338 * 0.5, 258 * 0.4, 0, 1.5, 1.5, ox)
        else
            love.graphics.setColor(1, 0, 0)
            love.graphics.print("CLKS: 00", font, 32 / 2, 533 / 2)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(pausetext, font, 338 * 0.5, 258 * 0.4, 0, 1.5, 1.5, ox)
        end
	end
end

function love.mousereleased(_, _, button)
    if inmenu == "pause" then return end
	if button == 1 then
		local stack = {
			{
				x = mouse.x,
				y = mouse.y,
			},
		}
		if gridinfo.grid[mouse.y] and gridinfo.grid[mouse.y][mouse.x] then
			if gridinfo.grid[mouse.y][mouse.x].state == "covered" then
				clicks = clicks - 1
                click:stop()
                click:play()
				if clicks == 0 then
					love.load()
					pausetext = " YOU DIDN'T FIND ALL THE ICE!\n  PRESS ESC TO PLAY AGAIN"
					inmenu = "pause"
					return
                end
			end
		end

		while #stack > 0 do
			local current = table.remove(stack)
			local x = current.x
			local y = current.y

			if gridinfo.grid[y] and gridinfo.grid[y][x] then
				gridinfo.grid[y][x].state = "uncovered"
				if surroundingdebris(x, y) == 0 then
					for dy = -1, 1 do
						for dx = -1, 1 do
							if
								not (dx == 0 and dy == 0)
								and gridinfo.grid[y + dy]
								and gridinfo.grid[y + dy][x + dx]
								and gridinfo.grid[y + dy][x + dx].state == "covered"
							then
								table.insert(stack, {
									x = x + dx,
									y = y + dy,
								})
							end
						end
					end
				end
				if gridinfo.grid[y][x].debris == "ice" and gridinfo.grid[y][x].clicked == false then
                    ice:stop()
                    ice:play()
					clicks = clicks + 6
					gridinfo.grid[y][x].clicked = true
					clickedices = clickedices + 1
                elseif gridinfo.grid[y][x].debris == "junk" and gridinfo.grid[y][x].clicked == false then
                    junk:stop()
                    junk:play()
				end
                if ices == clickedices then
                    love.load()
                    pausetext = "YOU FOUND ALL THE ICE!\nEARTH IS SAVED\nPRESS ESC TO PLAY AGAIN"
                    inmenu = "pause"
                    return
                end
			end
		end
		clicked = false
	end
end

function love.keypressed(key)
	if key == "escape" then
		pausetext = "PRESS ESC TO UNPAUSE"
		inmenu = inmenu == "game" and "pause" or "game"
	end
end
