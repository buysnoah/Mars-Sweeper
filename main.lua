love.graphics.setDefaultFilter("nearest", "nearest")
local tiles = {}
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
local gridinfo = {sizex=21, sizey=15}
local mouse = {}
local tileselected = false

function love.load()
    local cursorimage = love.graphics.newImage("images/cursor.png") 
    local cursor = love.mouse.newCursor("images/cursor.png", cursorimage:getWidth()/2, cursorimage:getHeight()/2)
    love.mouse.setCursor(cursor)
    love.window.setTitle("Mars Sweeper")
    for y=0, tilesheet:getWidth()/16-1 do
        for x=0, tilesheet:getHeight()/16-1 do
            local quad = love.graphics.newQuad(
                x*16,
                y*16,
                16,
                16,
                tilesheet
            )
            table.insert(tiles, quad)
        end
    end
    gridinfo.grid = {}
    for y=0, gridinfo.sizey-1 do
        gridinfo.grid[y+1] = {}
        for x=0, gridinfo.sizex-1 do
            local spotinfo = {image=tiles[1], px=x*16+8, py=y*16+8, x=x+1, y=y+1, selected = false}
            table.insert(gridinfo.grid[y+1], x+1, spotinfo)
        end
    end
end

function love.update(dt)
    mouse.x = math.ceil((love.mouse.getX()-16)/32)
    mouse.y = math.ceil((love.mouse.getY()-16)/32)
    for i,v in ipairs(gridinfo.grid) do
        for j,y in ipairs(v) do
            if mouse.y == i and mouse.x == j then
                y.selected = true            
            else
                y.selected = false
            end
        end
    end
end

function love.draw()
    love.graphics.applyTransform(love.math.newTransform():scale(2,2))
    for i,v in ipairs(gridinfo.grid) do
        for j,y in ipairs(v) do
            love.graphics.draw(tilesheet, y.image, y.px, y.py)
            if y.selected then
                love.graphics.draw(tilesheet, tiles[13], y.px, y.py)
            end
        end
    end
    love.graphics.draw(overlay)
    --love.graphics.print("mouse ( x:"..mouse.x .." y:"..mouse.y ..")\nselectedtile ("..(((selectedtile=="NONE") and "NONE)") or "x:"..selectedtile.x.." y:"..selectedtile.y..")"))
end 
