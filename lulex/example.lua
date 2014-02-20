
local lulex = require("lulex")

local code = {
   FOO = 100,
   BAR = 101,
   STRING = 200,
   ERROR = 999999,
}

local function show(code, token)
   print(code)
   print(token)
end

local lexer = lulex.new {

   { '"([^\\n"\\\\]|\\\\["\\\\])*"',
      function(token)
         show(code.STRING, token)
      end
   },

   { 'foo',
      function(token) show(code.FOO, token) end
   },
   
   { 'bar',
      function(token) show(code.BAR, token) end
   },
   
   { '[ \\n\\t]*',
      function(token)
         -- do nothing!
      end
   },
   
   { '.',
      function(token) show(code.ERROR, token) end
   },
}

local args = {...}
if #args == 0 then
   print("missing argument!")
   os.exit(1)
end

local fd = io.open(args[1], "r")
local input = fd:read("*a")
fd:close()

lexer:run(input, true)

