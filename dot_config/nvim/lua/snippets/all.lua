local ls = require("luasnip")
local s = ls.snippet
local f = ls.function_node

return {}, {
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
