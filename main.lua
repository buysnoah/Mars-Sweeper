love.graphics.setDefaultFilter("nearest", "nearest")
local tiles = {}
local tilesheet = love.graphics.newImage("images/tiles.png")
local gridinfo = {sizex=21, sizey=15}

function love.load()
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
            --[[TODO:
            Make a class for the tiles, so that I can detect clicks on them and assign them
            properties and such.
            ]] 
            local spotinfo = {}
            table.insert(gridinfo.grid[y+1], x+1, spotinfo)
        end
    end
end

function love.update(dt)
end

function love.draw()
    love.graphics.applyTransform(love.math.newTransform():scale(2,2))
    for i,v in ipairs(gridinfo.grid) do
        for j,_ in ipairs(v) do
            love.graphics.draw(tilesheet, tiles[1], (j-1)*16+8, (i-1)*16+8)
        end
    end
end
