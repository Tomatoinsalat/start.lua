local rla = peripheral.find("reactor_logic_adapter") or peripheral.wrap("back")
if not rla then error("Reactor adapter not found!") end

local dir = 1
local bestEff = 0
local step = 1

term.clear()
term.setCursorPos(1, 1)
print("Smart Auto-Tuner V5 (93%, Active Polling)")

while true do
  local eff = rla.getEfficiency() or 0

  -- Обновление UI для мертвой зоны
  term.setCursorPos(1, 3)
  term.clearLine()
  term.write(string.format("Efficiency: %.2f%% | Step: %d", eff, step))

  if eff > 0 then
    -- МЕРТВАЯ ЗОНА
    if eff >= 93.0 then
      term.setCursorPos(1, 4)
      term.clearLine()
      term.write("STATUS: Perfect! Idling...      ")
      bestEff = eff
      step = 1
      os.sleep(0.5) -- В идеальном состоянии просто слегка мониторим
    else
      -- ЛОГИКА ШАГА
      if eff >= bestEff then
        bestEff = eff
        -- Если идем верно, постепенно разгоняем шаг (до 5)
        if step < 5 then step = step + 1 end
      else
        -- Начали падать - разворот и сброс шага
        dir = -dir
        bestEff = eff - 0.5
        step = 1 
      end
      
      rla.adjustReactivity(dir * step)
      
      term.setCursorPos(1, 4)
      term.clearLine()
      term.write(string.format("STATUS: Tuning %s%-5d", dir > 0 and "+" or "-", step))

      -- === АКТИВНОЕ ОЖИДАНИЕ (ЗАЩИТА ОТ ПИНГА) ===
      local waitCycles = 0
      local tempEff = eff
      
      -- Ждем максимум 5 секунд (10 итераций по 0.5с), но можем выйти раньше
      while waitCycles < 10 do 
        os.sleep(0.5)
        local currentEff = rla.getEfficiency() or 0
        
        -- Постоянно обновляем экран
        term.setCursorPos(1, 3)
        term.clearLine()
        term.write(string.format("Efficiency: %.2f%% | Step: %d", currentEff, step))
        
        -- 1. Достигли цели? Выходим из цикла ожидания мгновенно.
        if currentEff >= 93.0 then
          break 
        end
        
        -- 2. Эффективность падает прямо сейчас? Мы проскочили пик. Выходим.
        if currentEff < tempEff then
          break
        end
        
        -- 3. Реактор замер (ЦР догнала ТР)? Нет смысла ждать дальше, делаем следующий шаг.
        if currentEff == tempEff and waitCycles > 2 then
          break
        end
        
        tempEff = currentEff
        waitCycles = waitCycles + 1
      end
    end
  else
    -- Реактор на нуле, толкаем
    rla.adjustReactivity(1)
    step = 1
    term.setCursorPos(1, 4)
    term.clearLine()
    term.write("STATUS: Kickstarting (+1)       ")
    os.sleep(2)
  end
end
