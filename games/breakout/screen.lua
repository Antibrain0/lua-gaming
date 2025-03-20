local __sys={cmd='',cursor={1,1},color={0,0,0},done_draw=false,framerate=10} --system state
__sys.canvas_w,__sys.canvas_h=65,65 --canvas size
__sys.imgtbl={} --image local
function arr2d(w,h,s)
    local build={}
    for y=1,h do
        build[y]={}
        for x=1,w do
            build[y][x]=s
        end
    end
    return build
end

__sys.imgtbl=arr2d(__sys.canvas_w,__sys.canvas_h,"000 000 000")
io.write"Welcome to shitty lua breakout!\n"
io.write"Made by anti using only base lua - no modules or libraries besides builtin.\n"
io.write"Make sure youve opened both 'canvas.pbm' and 'input.txt'\n"
io.write"With autosave set to 0ms, and auto update set to instant.\n"
io.write"A/D to move paddle.\n"
__sys.framerate=30 --idk random number (works good actually no way)
game={}
game.ball={x=33,y=32,w=1,h=1,spd={x=0,y=1}}
game.paddle={x=27,y=60,w=12,h=2}
game.bricks={}
game.level=1
game.score=0
for yy=1,game.level+1 do for xx=1,8 do
    table.insert(game.bricks,{y=4*yy+4,x=xx*8-6,w=6,h=2,c={255,0,0}})
end end
function _mainloop() --run 10 times every second (10fps)
    cls() --clear screen
    rectfill(game.paddle.x,game.paddle.y,game.paddle.x+game.paddle.w,game.paddle.y+game.paddle.h,col(255,255,255))
    set_px(game.ball.x,game.ball.y,col(255,255,255))
    game.ball.x=game.ball.x+game.ball.spd.x
    game.ball.y=game.ball.y+game.ball.spd.y
    if game.ball.x>=game.paddle.x and game.ball.y>game.paddle.y and game.ball.x<=game.paddle.x+game.paddle.w and game.ball.y<=game.paddle.y+game.paddle.h or game.ball.y<=0 then
        game.ball.spd.y=game.ball.spd.y*-1.05
        local pm=game.paddle.x+game.paddle.w/2
        local bm=game.ball.x+.5
        game.ball.spd.x=game.ball.spd.x+(-(pm-bm)/20)
    end
    if game.ball.x>=__sys.canvas_w or game.ball.x<=1 then
        game.ball.spd.x=-game.ball.spd.x
    end
    if btn'a' then
        game.paddle.x=game.paddle.x-4
    end
    if btn'd' then
        game.paddle.x=game.paddle.x+4
    end
    game.paddle.x=math.max(1,math.min(game.paddle.x,__sys.canvas_w-game.paddle.w))
    for i=1,#game.bricks do
        local b=game.bricks[i]
        rect(b.x,b.y,b.x+b.w,b.y+b.h,b.c)
        if game.ball.x>=b.x and game.ball.x<=b.x+b.w and game.ball.y>=b.y and game.ball.y<=b.y+b.h then
            game.ball.spd.y=game.ball.spd.y*-1.05
            local pm=b.x+b.w/2
            local bm=game.ball.x+.5
            game.ball.spd.x=game.ball.spd.x+(-(pm-bm)/20)
            table.remove(game.bricks,i)
            game.score=game.score+1
            io.write("Score: "..game.score.."\n")
            break
        end
    end
    game.ball.spd.y=math.min(game.ball.spd.y,1.5)
    game.ball.spd.x=math.max(-1.5,math.min(game.ball.spd.x,1.5))
    game.ball.x=math.max(0,math.min(game.ball.x,__sys.canvas_w))
    game.ball.y=math.max(1,game.ball.y)

    if #game.bricks==0 then
        game.level=game.level+1
        game.ball={x=33,y=32,w=1,h=1,spd={x=0,y=1}}
        game.paddle={x=27,y=60,w=12,h=2}
        game.bricks={}
        for yy=1,game.level+1 do for xx=1,8 do
            table.insert(game.bricks,{y=4*yy+4,x=xx*8-6,w=6,h=2,c={255,0,0}})
        end end        
        io.write("Level up! Level: "..game.level.."\n")
    end
    if game.ball.y>__sys.canvas_h+6 then
        io.write("You lose! Wow you suck at this.\n")
        io.write("Score: "..game.score..'\n')
        os.exit()
    end
end

function rectfill(x1,y1,x2,y2,c) --filled rectangle
    local xmin, xmax = math.min(x1, x2), math.max(x1, x2)
    local ymin, ymax = math.min(y1, y2), math.max(y1, y2)
    for x = xmin, xmax do
        line(x, ymin, x, ymax, c)
    end
    
end

function rect(x1,y1,x2,y2,c) --simple rectangle
    line(x1,y1,x2,y1,c)
    line(x2,y2)
    line(x1,y2)
    line(x1,y1)
end

function set_px(qx,qy,c) --set single pixel
    local x,y=math.floor(qx),math.floor(qy)
    if x>=1 and x<=__sys.canvas_w and y>=1 and y<=__sys.canvas_h then
    __sys.imgtbl[y][x]=c[1].." "..c[2].." "..c[3]
    end
 --   io.write("Set pixel at ["..x..","..y.."] to color {"..c[1]..","..c[2]..","..c[3].."}!!\n")
end

function cursor(x,y) --set system cursor position
    __sys.cursor[1],__sys.cursor[2]=x,y
end

function color(c) --set system color
    __sys.color=c
end

function col(r,g,b)
    return {r,g,b}
end

function line (x1, y1, x2, y2, c) --draw a line from x1,y1 to x2,y2 (annoying)
    if x2==nil then --account for shorter syntax
        local dx1,dy1=__sys.cursor[1],__sys.cursor[2] --system state
        x2=x1
        y2=y1
        x1,y1=dx1,dy1
        c=__sys.color
        cursor(x2,y2)
    else
        cursor(x2,y2)
        color(c)
    end

    local steep = math.abs(y2 - y1) > math.abs(x2 - x1)
    if steep then
        x1, y1 = y1, x1
        x2, y2 = y2, x2
    end
    if x1 > x2 then
        x1, x2 = x2, x1
        y1, y2 = y2, y1
    end
    local dx = x2 - x1
    local dy = math.abs(y2 - y1)
    local err = dx / 2
    local ystep
    if y1 < y2 then
        ystep = 1
    else
        ystep = -1
    end
    local y = y1
    for x = x1, x2 do
        if steep then
            set_px(y, x, {c[1], c[2], c[3]})
        else
            set_px(x, y, {c[1], c[2], c[3]})
        end
        err = err - dy
        if err < 0 then
            y = y + ystep
            err = err + dx
        end
    end
end

function cls() --clear screen
    for x=1,__sys.canvas_w do for y=1,__sys.canvas_h do
        __sys.imgtbl[x][y]="000 000 000"
    end end
end

function output() --output canvas to pbm file for viewing
    for y=1,__sys.canvas_w do for x=1,__sys.canvas_h do
        __sys.image:write(__sys.imgtbl[y][x]..'\n')
    end end
end

function log_command(str)
    --io.write('Recieved command!! ['..str..']\n')
end

function btn(s)
    if __sys.cmd==s then

        log_command('key_'..s)
        return true
        
    end
end

xxx=2
__sys.input=io.open("input.txt","w")
__sys.done_draw=false
while true do --uhhh main loop thingie i guesss
    
    __sys.time=os.clock()*__sys.framerate --framerate fps
    if math.floor(__sys.time%2)==1 and not __sys.done_draw then --run the thingie when its time
        --okay now we do usr input

        __sys.input=io.open("input.txt",'r')
        __sys.cmd=__sys.input:read(1)
        --__sys.input:close()

        if __sys.cmd=='q' then
            log_command('quit_program')
            io.open("input.txt","w")
            os.exit()
        end

        input=io.open("input.txt","w")    
        __sys.done_draw=true
        __sys.image=io.open("canvas.pbm","w") --reset display
        __sys.image:write("P3\n"..__sys.canvas_w.." "..__sys.canvas_h.."\n255\n") --fill the image with empty shit
        _mainloop() --run mainloop
        output() --output image for viewing in external tool
        __sys.image:close() --delete contents of image so we dont fill it full of crap
    end
    if math.floor(__sys.time%2)==0 then
        __sys.done_draw=false --set up next frame

    end

end