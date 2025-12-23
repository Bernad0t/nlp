defmodule Math do
  def gcd(a, 0), do: a
  def gcd(0, b), do: b
  def gcd(a, b) when a == b, do: a
  
  def gcd(a, b) when a > b, do: gcd(a - b, b)
  def gcd(a, b), do: gcd(a, b - a)
end

# Считываем файл file.txt
case File.read("file.txt") do
  {:ok, content} ->
    content
    |> String.split("\n")
    |> Enum.each(fn line ->
      line = String.trim(line)
      if line != "" and not String.starts_with?(line, "#") do
        numbers = String.split(line) |> Enum.map(&String.to_integer/1)
        case numbers do
          [a, b] -> IO.puts("НОД(#{a}, #{b}) = #{Math.gcd(a, b)}")
          _ -> nil
        end
      end
    end)
    
  {:error, reason} ->
    IO.puts("Не удалось прочитать file.txt: #{reason}")
end