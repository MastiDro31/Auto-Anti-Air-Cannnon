--[[
    Код для пушки из видео: https://www.youtube.com/watch?v=Rn7dKYUX3zQ
    Страница github: https://github.com/MastiDro31/Auto-Anti-Air-Cannnon/blob/main
    Автор: Masti (MastiDro31)
    Discord: _masti.
]]
----------------------Settings----------------------
local cannon_pos = {x = 11.5, y = 4.5, z = -4.5} -- Позиция точки крепления пушки
local start_yaw = 90  -- В какую сторону света смотрит пушка [ (0):north, (90):east, (-90):north, (180):west ] (Не проверял правилность)
local start_pitch = 0 -- В какую сторону по вертикали смотрит пушка [ (0):Прямо, (90):Верх, (-90):Вниз ]       (Не проверял правилность)
----------------------Settings----------------------
----------------------------------------------------
local rotate_ratio = 26 + (2/3) -- Соотношение RPM к градусам поворота в тик
local y = peripheral.wrap("right") -- Регулятор скорости для yaw
local p = peripheral.wrap("top") -- Регулятор скорости для pitch
p.setTargetSpeed(0)
y.setTargetSpeed(0)
local current_look = {yaw = start_yaw, pitch = start_pitch}
local plr_scaner = peripheral.wrap("left") -- Сканер игроков (mod: Advanced Peripherals)
local chat = peripheral.wrap("bottom") -- Сканер игроков (mod: Advanced Peripherals)
local old_y_speed = 0.1
local old_p_speed = 0.1

redstone.setOutput("back", false) -------------- 
os.sleep(0.1)                     -- Иницилизация
redstone.setOutput("back", true)  -- Для того чтобы пушка не была чуть сдвинута
y.setTargetSpeed(200)             -- я просто не разобрался как это сделать без этого xd
for i=1,13 do                     -- 
    os.sleep()                    -- 
end                               -- 
y.setTargetSpeed(0)               --------------

local function turn(yaw,pitch)
    local ys = 1                  --------
    local ps = 1                  -- поворот в обратную сторону
    if yaw < 0 then ys = -1 end   -- 
    if pitch < 0 then ps = -1 end --------
    local yaw = math.min(math.max(math.abs(yaw), 0), 90)     -- Модуль yaw и ограничение до 90 градусов (ограничения для того чтобы пушка не сбилась если цель слишком быстрая)
    local pitch = math.min(math.max(math.abs(pitch), 0), 90) -- Модуль pitch и ограничение до 90 градусов (ограничения для того чтобы пушка не сбилась если цель слишком быстрая)
    local m = rotate_ratio / (12/20) / 20 -- Множитель
    y_speed = yaw * m * ys -- Высчитывание yaw скорости
    p_speed = pitch * m * ps -- Высчитывание pitch скорости
    if yaw ~= 0 then y.setTargetSpeed(y_speed) end -- Если yaw нужно изменить
    if pitch ~= 0 then p.setTargetSpeed(p_speed) end -- Если pitch нужно изменить
    for i=1,11 do  ----------
        os.sleep() -- ждать 11 тиков
    end            ----------
    if yaw ~= 0 then y.setTargetSpeed(0) end -- Если yaw крутился
    if pitch ~= 0 then p.setTargetSpeed(0) end -- Если pitch крутился
    current_look.yaw = current_look.yaw + yaw*ys         -- Изменить current_look
    current_look.pitch = current_look.pitch + pitch*ps   --
end

local function get_offset(look_from, look_to) -- Для определения на сколько нужно повернуть пушку
    local yaw = look_to.yaw - look_from.yaw
    local pitch = look_to.pitch - look_from.pitch
    return {
        yaw = yaw,
        pitch = pitch}
end
local function get_distance(from, to) -- На будующее чтобы пушка не целилась на цели по которым она не достанет
    local dist = math.pow(from.x - to.x,2) +
    math.pow(from.y - to.y, 2) +
    math.pow(from.z - to.z, 2)
    return math.sqrt(dist)
end
local function get_look(from,to) -- Получить направление до цели
    local dX = to.x - from.x
    local dY = to.y - from.y
    local dZ = to.z - from.z
    local yaw = math.atan2(dZ, dX)
    local pitch = math.atan2(math.sqrt(dZ*dZ + dX*dX), dY) + math.pi
    return {
        yaw = (yaw * 180 / math.pi)*-1,
        pitch = ((pitch * 180 / math.pi)-270)*-1
    }
end

local function get_target_pos() -- Получить позицию цели
    local pos = plr_scaner.getPlayerPos("Masti") -- Получить позицию игрока (mod: Advanced Peripherals)
    return pos
end

while true do
    local target_pos = get_target_pos() -- Получить позицию цели
    target_pos.y = target_pos.y + 1     -------------
    target_pos.x = target_pos.x + 0.5   -- Сдвинуть координаты в центр блока (Если коодринаты цели получаются с числами после точкой это нужно убрать)
    target_pos.z = target_pos.z + 0.5   -------------
    local needing_look = get_look(cannon_pos,target_pos)    -- Получить направление до цели
    local turn_look = get_offset(current_look,needing_look) -- Узнать на сколько нужно повернуть пушку
    turn(turn_look.yaw,turn_look.pitch) -- Повернуть пушку
end
