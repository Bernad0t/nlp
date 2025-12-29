import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.json;

void main(string[] args) {

    string inputFile = "input.txt";
    string outputFile = "output.json";
    
    try {
        auto file = File(inputFile, "r");
        
        // Создаем объект через ассоциативный массив
        JSONValue[string] data;
        
        string line;
        while (!file.eof) {
            line = file.readln.strip;
            
            if (line.length == 0 || line.startsWith("//")) continue;
            
            auto parts = line.split("=");
            if (parts.length != 2) {
                writeln("Ошибка в строке: ", line);
                continue;
            }
            
            string key = parts[0].strip;
            string value = parts[1].strip;
            
            data[key] = JSONValue(value);
        }
        
        // Преобразуем ассоциативный массив в JSONValue
        auto jsonObject = JSONValue(data);
        
        auto output = File(outputFile, "w");
        string jsonString = jsonObject.toPrettyString();
        output.write(jsonString);
        writeln(jsonString);
        writeln("JSON успешно сохранен в ", outputFile);
        
    } catch (Exception e) {
        writeln("Произошла ошибка: ", e.msg);
    }
}