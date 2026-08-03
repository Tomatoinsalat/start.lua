local rla = peripheral.wrap("back") -- Укажи свою сторону
if not rla then error("Reactor adapter not found!") end

local lastEff = 0
local dir = 1
local step = 1
local emergencyDrop = 5.0 -- Порог падения efficiency (%) для срабатывания защиты
local emergencyJump = -5  -- На сколько единиц резко сбросить reactivity

term.clear()
term.setCursorPos(1, 1)
print("Auto-Tuner with Safety Guard running...")

while true do
  local curEff = rla.getEfficiency() or 0

  if curEff > 0 then
    -- Проверка на экстренный сброс (резкий обвал эффективности)
    if (lastEff - curEff) > emergencyDrop and lastEff > 0 then
      rla.adjustReactivity(emergencyJump)
      dir = -1
      term.setCursorPos(1, 4)
      term.clearLine()
      term.write("STATUS: EMERGENCY DROP DETECTED! Jumped " .. emergencyJump)
    else
      -- Стандартная логика подстройки
      if curEff < lastEff then
        dir = -dir
      end
      rla.adjustReactivity(dir * step)
      
      term.setCursorPos(1, 4)
      term.clearLine()
      term.write("STATUS: Normal tuning")
    end

    lastEff = curEff
  else
    -- Если эффективность упала в 0, сразу сбрасываем реактивность вниз
    rla.adjustReactivity(-5)
  end

  term.setCursorPos(1, 3)
  term.clearLine()
  term.write(string.format("Eff: %.2f%% | Dir: %s", curEff, dir > 0 and "+1" or "-1"))

  os.sleep(5)
end
