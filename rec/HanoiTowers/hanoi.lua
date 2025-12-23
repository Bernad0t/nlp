function read_disks_from_file(filename)
    local file = io.open(filename, "r")
    if not file then
        print("Ошибка: не удалось открыть файл '" .. filename .. "'")
        return nil
    end
    
    local content = file:read("*all")
    file:close()
    
    -- Преобразуем строку в число
    local disks = tonumber(content)
    return disks
end

-- Основная рекурсивная функция
function solve_hanoi(n, from, to)
    if n == 1 then
        print("Переместить диск 1 со стержня " .. from .. " на стержень " .. to)
        return
    end
    
    -- Вычисляем вспомогательный стержень: 6 - from - to
    local aux = 6 - from - to
    
    -- 1. Перемещаем n-1 дисков с 'from' на 'aux'
    solve_hanoi(n - 1, from, aux)
    
    -- 2. Перемещаем самый большой диск с 'from' на 'to'
    print("Переместить диск " .. n .. " со стержня " .. from .. " на стержень " .. to)
    
    -- 3. Перемещаем n-1 дисков с 'aux' на 'to'
    solve_hanoi(n - 1, aux, to)
end

function solve_hanoi_with_disks(disks)
    if disks <= 0 then
        print("Ошибка: количество дисков должно быть положительным числом")
        return
    end
    
    print("=== Решение Ханойской башни с " .. disks .. " дисками ===")
    print("Стержни: 1 (источник), 2 (вспомогательный), 3 (целевой)")
    print("==============================================")
    
    solve_hanoi(disks, 1, 3)
    
    -- Подсчет количества ходов
    local moves = 2^disks - 1
    print("==============================================")
    print("Всего выполнено ходов: " .. moves)
end

print("Программа решения головоломки 'Ханойские башни'")
print("===============================================\n")

-- Читаем количество дисков из файла input.txt
local filename = "input.txt"
local disks = read_disks_from_file(filename)

if disks then
    solve_hanoi_with_disks(disks)
else
    print("Файл не найден")
end