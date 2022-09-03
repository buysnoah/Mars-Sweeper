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
local debris = {}

function love.load()
    math.randomseed(os.time())
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
            local spotinfo = {
                image=tiles[1],
                px=x*16+8,
                py=y*16+8,
                x=x+1,
                y=y+1,
                selected = false,
                debris = (math.random(1,20)==10 and "ice") or (math.random(1,20) ==10 and "debris"),
                near = 0
                state = "covered"
            }
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
                if love.mouse.isDown(1) then
                    y.image = tiles[2]
                    y.state = "uncovered"
                end
                love.graphics.draw(tilesheet, tiles[13], y.px, y.py)
                if y.state == "uncovered" then
                    if y.debris then
                        table.insert(debris, {type=y.debris, px=y.px, py=y.py})
                    elseif y.near then

                    end
                end
            end
            for _,u in ipairs(debris) do
                love.graphics.draw(tilesheet, tiles[u.type == "ice" and 3 or 4], u.px, u.py)
            end
        end
    end
    love.graphics.draw(overlay)
    --love.graphics.print("mouse ( x:"..mouse.x .." y:"..mouse.y ..")\nselectedtile ("..(((selectedtile=="NONE") and "NONE)") or "x:"..selectedtile.x.." y:"..selectedtile.y..")"))
end 
