-module(main).
-export([print_as_array/1, read_tree_from_file/1, run/0]).

%% Определение структуры дерева
%% {Value, LeftSubtree, RightSubtree}
%% или nil для пустого дерева

%% Основная функция
print_as_array(Tree) ->
    Size = calculate_size(Tree),
    io:format("Размер массива: ~p~n", [Size]),
    Array = array:new(Size, {default, null}),
    FilledArray = fill_array(Tree, Array, 0),
    print_array(FilledArray).

%% Вычисляем размер массива (максимальный индекс + 1)
calculate_size(nil) -> 0;
calculate_size(Tree) ->
    MaxIndex = calculate_max_index(Tree, 0),
    MaxIndex + 1.

calculate_max_index(nil, CurrentIndex) -> CurrentIndex;
calculate_max_index({_, Left, Right}, CurrentIndex) ->
    LeftIndex = 2 * CurrentIndex + 1,
    RightIndex = 2 * CurrentIndex + 2,
    
    MaxLeft = calculate_max_index(Left, LeftIndex),
    MaxRight = calculate_max_index(Right, RightIndex),
    
    max(CurrentIndex, max(MaxLeft, MaxRight)).

%% Заполняем массив значениями дерева
fill_array(nil, Array, _Index) -> Array;
fill_array({Value, Left, Right}, Array, Index) ->
    %% Записываем текущее значение
    Array1 = array:set(Index, Value, Array),
    
    %% Рекурсивно заполняем детей
    LeftIndex = 2 * Index + 1,
    RightIndex = 2 * Index + 2,
    
    Array2 = fill_array(Left, Array1, LeftIndex),
    Array3 = fill_array(Right, Array2, RightIndex),
    
    Array3.

%% Выводим массив
print_array(Array) ->
    Size = array:size(Array),
    print_array_recursive(Array, 0, Size).

print_array_recursive(Array, Index, Size) when Index < Size ->
    case array:get(Index, Array) of
        null -> io:format("null ");
        Value -> io:format("~p ", [Value])
    end,
    print_array_recursive(Array, Index + 1, Size);
print_array_recursive(_, _, _) ->
    io:format("~n").

%% Чтение дерева из файла (формат: Erlang терм)
read_tree_from_file(Filename) ->
    case file:consult(Filename) of
        {ok, [Tree]} -> 
            {ok, Tree};
        {ok, _} -> 
            {error, invalid_format};
        {error, Reason} -> 
            {error, Reason}
    end.

%% Основная функция запуска
run() ->
    case read_tree_from_file("tree.txt") of
        {ok, Tree} ->
            io:format("Успешно прочитали дерево из файла~n"),
            print_as_array(Tree);
        {error, Reason} ->
            io:format("Ошибка чтения файла: ~p~n", [Reason])
    end.