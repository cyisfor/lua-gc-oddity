local ext = require(arg[1])

local function luaonly() 
    local obj = {}
    setmetatable(obj,{
        __gc = function()
            print('__gc for lua only',obj)
        end,
        __call = function()
            print('__call for lua only',obj)
        end
    })

    return obj
end


if _VERSION >= 'Lua 5.2' then
  function defer(fn)
    setmetatable({}, { __gc = fn })
  end
else
  function defer(fn)
    getmetatable(newproxy(true)).__gc = fn
  end
end

local x
local y = {}
setmetatable(y, {__mode = "v"});

if os.getenv('buggy') == nil then
    x = ext('x')
    y[1] = ext('y')
    z = luaonly()
end

defer(function()
    print('calling x and y')
  x()
  y[1]()
  z()
end)

if os.getenv('buggy') ~= nil then
    x = ext('x')
    y[1] = ext('y')
    z = luaonly()
end


print('ready, letting collector take over')
