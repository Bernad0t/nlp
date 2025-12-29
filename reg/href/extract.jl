using Printf

# Читаем файл
function read_file(filename)
    try
        content = read(filename, String)
        return content
    catch e
        @printf "Ошибка чтения файла '%s': %s\n" filename e.msg
        return nothing
    end
end

# Извлекаем href только из тегов <a> с помощью регулярных выражений
function extract_href_from_a_tags(html)
    links = String[]
    
    # Регулярное выражение для поиска тегов <a>
    a_tag_pattern = r"<a[^>]*>"i
    
    # Находим все теги <a>
    for m_match in eachmatch(a_tag_pattern, html)
        a_tag = m_match.match
        
        # Ищем href внутри тега <a>
        href_pattern = r"href\s*=\s*\"([^\"]*)\""i
        
        m = match(href_pattern, a_tag)
        if m !== nothing
            push!(links, m.captures[1])
        end
    end
    
    return links
end

# Основная программа
function main()
    println("Извлечение ссылок из HTML файла")
    println("===============================\n")
    
    # Читаем файл
    html = read_file("input.txt")
    
    if html === nothing
        println("Не удалось прочитать файл input.txt")
        return
    end
    
    # Извлекаем ссылки из тегов <a>
    links = extract_href_from_a_tags(html)
    
    if isempty(links)
        println("Ссылки не найдены")
    else
        println("Найдено ссылок: ", length(links))
        for (i, link) in enumerate(links)
            @printf "%d. %s\n" i link
        end
    end
end

# Запуск программы
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end