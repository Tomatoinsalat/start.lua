local rla = peripheral.find("reactor_logic_adapter")
if not rla then error("Reactor adapter not found!") end
 
local step = 5
local minStep = 0.1
local lastEff = 0
local dir = 1
 
term.clear()
term.setCursorPos(1, 1)
print("Auto-Tuner running...")
 
while true do
  local curEff = rla.getEfficiency() or 0
 
  if curEff > 0 then
    if curEff < lastEff then
      dir = -dir
      step = math.max(minStep, step * 0.5)
    elseif curEff > lastEff and step < 5 then
      step = math.min(5, step * 1.2)
    end
 
    rla.adjustReactivity(dir * step)
    lastEff = curEff
  else
    rla.adjustReactivity(1)
  end
 
  term.setCursorPos(1, 3)
  term.clearLine()
  term.write(string.format("Eff: %.2f%% | Step: %+.2f", curEff, dir * step))
 
  os.sleep(3)
end
