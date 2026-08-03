local rla = peripheral.find("reactor_logic_adapter") or peripheral.wrap("back")
if not rla then error("Reactor adapter not found!") end

local dir = 1
local bestEff = 0

term.clear()
term.setCursorPos(1, 1)
print("Zero-Bullshit Tuner V3 (93% Target)")

while true do
  local eff = rla.getEfficiency() or 0

  term.setCursorPos(1, 3)
  term.clearLine()
  term.write(string.format("Efficiency: %.2f%%", eff))

  if eff > 0 then
    -- МЕРТВАЯ ЗОНА: Установлена на 93.0
    if eff >= 93.0 then
      term.setCursorPos(1, 4)
      term.clearLine()
      term.write("STATUS: Perfect! Idling...")
      bestEff = eff 
    else
      -- Если эффективность ниже 93%, калибруем
      if eff >= bestEff then
        bestEff = eff
      else
        dir = -dir
        bestEff = eff - 0.5 
      end
      
      rla.adjustReactivity(dir)
      
      term.setCursorPos(1, 4)
      term.clearLine()
      term.write("STATUS: Tuning " .. (dir > 0 and "+1" or "-1"))
    end
  else
    -- Если реактор выключен
    rla.adjustReactivity(1)
    term.setCursorPos(1, 4)
    term.clearLine()
    term.write("STATUS: Kickstarting (+1)")
  end

  os.sleep(5)
end
