
local lulex = {}

local rex_ok, rex
for _, flavor in ipairs{"gnu", "pcre", "tre", "posix", "oniguruma"} do
   rex_ok, rex = pcall(require, "rex_"..flavor)
   if rex_ok then break end
end

local function lua_match(rule, input, at)
   local match = string.match(input, "^"..rule[1], at)
   if match then
      return at + #match
   end
end

local function re_match(rule, input, at)
   if not rule.pat then
      rule.pat = rex.new("^"..rule[1])
   end
   local start, finish = rule.pat:find(input:sub(at))
   if start then
      return at+(finish-start)+1
   end
end

local function run(self, input)
   local at = 1
   while at <= #input do
      local lrule = nil
      local llen = 0
      for _, rule in ipairs(self.rules) do
         local found = self.match(rule, input, at)
         if found then
            local len = found - at
            if len > llen then
               llen = len
               lrule = rule
            end
         end
      end
      if lrule then
         lrule[2](input:sub(at, at+llen-1))
         at = at + llen
      else
         io.write(input:sub(at, at))
         at = at + 1
      end
   end
end

function lulex.new(rules, use_lua)

   return {
      match = (use_lua or not rex_ok) and lua_match or re_match,
      rules = rules,
      run = run,
   }
end

return lulex