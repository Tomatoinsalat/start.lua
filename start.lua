local rla = peripheral.find("reactor_logic_adapter") or peripheral.wrap("back")
if not rla then error("Reactor adapter not found!") end

term.clear()
term.setCursorPos(1, 1)
print("Dumb & Safe Tuner (Target 90%)")

local lastEff = rla.getEfficiency() or 0
local dir = 1
local step = 1

-- СНАЧАЛА ПРОВЕРЯЕМ РЕАКЦИЮ: делаем тестовый тык в +1
if lastEff > 0 and lastEff < 90.0 then
  term.setCursorPos(1, 4)
  term.clearLine()
  term.write("STATUS: Probing direction (+1)...")
  rla.adjustReactivity(1)
  
  -- Ждем реакцию реактора
  os.sleep(4.5)
  
  local probeEff = rla.getEfficiency() or 0
  if probeEff < lastEff then
    dir = -1 -- Эффективность упала, значит 100% надо идти в минус
  else
    dir = 1  -- Выросла, значит идем правильно
  end
  lastEff = probeEff
end

-- ОСНОВНОЙ ЦИКЛ
while true do
  local eff = rla.getEfficiency() or 0

  term.setCursorPos(1, 3)
  term.clearLine()
  term.write(string.format("Efficiency: %.2f%%   ", eff))

  -- Если дошли до 90% - стопаем калибровку
  if eff >= 90.0 then
    term.setCursorPos(1, 4)
    term.clearLine()
    term.write("STATUS: Goal reached (90%+). Idling.")
    os.sleep(2)
  else
    -- Устанавливаем шаг: до 60% шагаем по 3, после 60% шагаем по 1
    if eff < 60.0 then
      step = 3
    else
      step = 1
    end

    if eff == 0 then
      -- Если реактор потух, значит ТР улетела за пределы.
      -- Принудительно тянем вниз, чтобы вытащить его со дна.
      dir = -1
      step = 5
    else
      -- Если стало хуже, чем было на прошлом шаге, меняем направление
      if eff < lastEff then
        dir = -dir
      end
    end

    -- Тыкаем ТР
    rla.adjustReactivity(dir * step)
    
    term.setCursorPos(1, 4)
    term.clearLine()
    term.write(string.format("STATUS: Tuning %s%d            ", dir > 0 and "+" or "-", step))

    lastEff = eff
    -- Ждем 4.5 секунды! Это важно, иначе скрипт натыкает ТР до сотни раньше, чем реактор поймет, что произошло.
    os.sleep(4.5)
  end
end
