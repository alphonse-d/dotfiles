local ls = require("luasnip")
local s = ls.snippet
local f = ls.function_node

return {
-- Date filler, can be filled in for more fillings
  s({ trig = "@today" }, f(function()
    return os.date("%Y-%m-%d")
  end)),
  s({ trig = "@tomorrow" }, f(function()
    return os.date("%Y-%m-%d", os.time() + 86400)
  end)),
  s({ trig = "@friday" }, f(function()
    local today = tonumber(os.date("%w"))
    local diff = (5 - today) % 7
    if diff == 0 then diff = 7 end
    return os.date("%Y-%m-%d", os.time() + diff * 86400)
  end)),
}, {
  s({
    trig = "(SLG)%.(%d+) ",
    regTrig = true,
    wordTrig = false,
  }, f(function(_, snip)
    return string.format(
      "<https://emc2summary/GetSummaryReport.ashx/%s/%s> ",
      snip.captures[1],
      snip.captures[2]
    )
  end)),
 s({
     trig = "(QAN)%.(%d+) ",
     regTrig = true,
     wordTrig = false,
   }, f(function(_, snip)
     return string.format(
       "<https://emc2summary/GetSummaryReport.ashx/%s/%s> ",
       snip.captures[1],
       snip.captures[2]
     )
  end)),
 s({
     trig = "(DLG)%.(%d+) ",
     regTrig = true,
     wordTrig = false,
   }, f(function(_, snip)
     return string.format(
       "<https://emc2summary/GetSummaryReport.ashx/%s/%s> ",
       snip.captures[1],
       snip.captures[2]
     )
  end)),
}
