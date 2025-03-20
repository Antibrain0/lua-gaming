local __sys={cmd='',cursor={1,1},color={0,0,0},done_draw=false,framerate=10} --system state
__sys.canvas_w,__sys.canvas_h=64,64 --canvas size
__sys.imgtbl={} --image local
for y=1,__sys.canvas_w do --build local canvas image
    __sys.imgtbl[y]={}
    for x=1,__sys.canvas_h do
        __sys.imgtbl[y][x]="000 000 000"
    end
end

__sys.framerate=30 --idk random number (works good actually no way)
t={x=32,y=32}
function _mainloop() --run 10 times every second (10fps)
    cls() --clear screen
    io.write(__sys.cmd and __sys.cmd..'\n' or '')
    --just some graphics api testing
    rectfill(48,38,27,52,col(255,0,255))

    line(xxx,4,xxx,12,col(255,255,255))
    line(xxx+4,4)
    line(xxx,4)
    line(32,32)
    set_px(16,16,col(255,255,0))
    xxx=xxx+(1/10)
    rect(t.x,t.y,t.x+3,t.y+3,col(255,255,255))
    t.x=t.x+(btn'd' and 1 or btn'a' and -1 or 0)
    t.y=t.y+(btn'w' and -1 or btn's' and 1 or 0)
    set_px(42+math.sin(__sys.time/16)*8,32+math.cos(__sys.time/16)*8,col(0,0,255))
    rect(20,20,40,40,col(50,126,100))
    xxx=xxx%__sys.canvas_w
    if xxx<=0 then xxx=xxx+1 end
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

function table.shallow_copy(t) --shallow copy table
    local t2 = {}
    for k,v in pairs(t) do
      t2[k] = v
    end
    return t2
  end

function log_command(str)
    io.write('Recieved command!! ['..str..']\n')
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