local rla = peripheral.wrap("back") -- Укажи свою сторону
if not rla then error("Reactor adapter not found!") end

local lastEff = 0
local bestEff = 0
local bestReactivity = 0
local dir = 1
local step = 1
local emergencyDrop = 10.0
local emergencyJump = 5

term.clear()
term.setCursorPos(1, 1)
print("Auto-Tuner running...")

while true do
  local curEff = rla.getEfficiency() or 0
  local curReact = rla.getReactivity and rla.getReactivity() or 0

  -- Обновляем рекорд эффективности и запоминаем лучшую реактивность
  if curEff > bestEff then
    bestEff = curEff
    bestReactivity = curReact
  end

  if curEff > 0 then
    local drop = lastEff - curEff

    -- Экстренный обвал при сбросе/смещении ЦР
    if drop > emergencyDrop and lastEff > 0 then
      -- Если текущая реактивность выше лучшей — нужно резко вниз, иначе — вверх
      if curReact > bestReactivity then
        dir = -1
      else
        dir = 1
      end

      rla.adjustReactivity(dir * emergencyJump)

      term.setCursorPos(1, 4)
      term.clearLine()
      term.write(string.format("STATUS: EMERGENCY! Rollback %+.1f", dir * emergencyJump))
    else
      -- Обычная подстройка
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
    dir = -dir
    rla.adjustReactivity(dir * emergencyJump)
  end

  term.setCursorPos(1, 3)
  term.clearLine()
  term.write(string.format("Eff: %.2f%% | Best: %.2f%% | Dir: %s", curEff, bestEff, dir > 0 and "+1" or "-1"))

  os.sleep(5)
end
