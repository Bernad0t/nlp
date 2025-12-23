import Foundation

// MARK: - Простой конвертер HTML в XML

class SimpleHTMLToXMLConverter {
    
    /// Словарь соответствия HTML тегов XML тегам
    private static let tagMapping: [String: String] = [
        "html": "html",
        "head": "head",
        "body": "body",
        "title": "title",
        "h1": "heading1", "h2": "heading2", "h3": "heading3", "h4": "heading4", "h5": "heading5", "h6": "heading6",
        "p": "paragraph",
        "div": "division",
        "span": "span",
        "a": "link",
        "img": "image",
        "ul": "unorderedlist",
        "ol": "orderedlist",
        "li": "listitem",
        "table": "table",
        "tr": "tablerow",
        "td": "tablecell",
        "th": "tableheader",
        "strong": "bold",
        "b": "bold",
        "em": "italic",
        "i": "italic",
        "u": "underline",
        "br": "linebreak",
        "hr": "horizontalrule",
        "form": "form",
        "input": "input",
        "button": "button",
        "select": "select",
        "option": "option",
        "textarea": "textarea",
        "label": "label",
        "meta": "meta",
        "link": "linkelement",
        "script": "script",
        "style": "style",
        "header": "header",
        "footer": "footer",
        "nav": "navigation",
        "section": "section",
        "article": "article",
        "aside": "aside",
        "main": "main"
    ]
    
    /// Атрибуты, которые нужно переименовать
    private static let attributeMapping: [String: String] = [
        "class": "cssClass",
        "for": "labelFor",
        "src": "source",
        "href": "reference",
        "alt": "alternativeText",
        "title": "tooltip",
        "type": "inputType",
        "value": "defaultValue",
        "name": "fieldName",
        "id": "identifier",
        "style": "inlineStyle",
        "width": "width",
        "height": "height",
        "border": "borderWidth",
        "colspan": "columnSpan",
        "rowspan": "rowSpan",
        "cellpadding": "cellPadding",
        "cellspacing": "cellSpacing",
        "target": "linkTarget"
    ]
    
    /// Конвертирует HTML строку в XML
    static func convert(html: String) -> String {
        // Очищаем и подготавливаем HTML
        let cleanHTML = cleanHTMLString(html)
        
        // Создаем XML структуру
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        xml += "<document>\n"
        xml += convertTags(cleanHTML)
        xml += "</document>"
        
        return xml
    }
    
    /// Очищает HTML строку
    private static func cleanHTMLString(_ html: String) -> String {
        var result = html
        
        // Убираем DOCTYPE и комментарии
        let patterns = [
            "<!DOCTYPE[^>]*>": "",
            "<!--[^>]*-->": "",
            "\\s+": " ",
            "<html[^>]*>": "",       
            "</html>": "",  
        ]
        
        for (pattern, replacement) in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(result.startIndex..., in: result)
                result = regex.stringByReplacingMatches(in: result, 
                                                      range: range, 
                                                      withTemplate: replacement)
            }
        }
        
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Конвертирует HTML теги в XML
    private static func convertTags(_ html: String) -> String {
        var result = ""
        var currentTag = ""
        var inTag = false
        var textBuffer = ""
        var indentLevel = 0
        
        for char in html {
            if char == "<" {
                // Начинается тег
                if !textBuffer.isEmpty {
                    result += indentString(level: indentLevel) + escapeXML(textBuffer) + "\n"
                    textBuffer = ""
                }
                inTag = true
                currentTag = ""
            } else if char == ">" && inTag {
                // Заканчивается тег
                inTag = false
                
                if currentTag.hasPrefix("/") {
                    // Закрывающий тег
                    indentLevel = max(0, indentLevel - 1)
                    let tagName = String(currentTag.dropFirst())
                    let xmlTagName = getXMLTagName(tagName)
                    result += indentString(level: indentLevel) + "</\(xmlTagName)>\n"
                } else if currentTag.hasSuffix("/") || isSelfClosingTag(currentTag) {
                    // Самозакрывающийся тег
                    result += indentString(level: indentLevel) + convertTagToXML(currentTag, isClosing: false) + "\n"
                } else {
                    // Открывающий тег
                    result += indentString(level: indentLevel) + convertTagToXML(currentTag, isClosing: false) + "\n"
                    indentLevel += 1
                }
                currentTag = ""
            } else if inTag {
                // Читаем содержимое тега
                currentTag.append(char)
            } else {
                // Читаем текст между тегами
                textBuffer.append(char)
            }
        }
        
        // Добавляем оставшийся текст
        if !textBuffer.isEmpty {
            result += indentString(level: indentLevel) + escapeXML(textBuffer.trimmingCharacters(in: .whitespacesAndNewlines)) + "\n"
        }
        
        return result
    }
    
    /// Конвертирует HTML тег в XML тег
    private static func convertTagToXML(_ htmlTag: String, isClosing: Bool) -> String {
        if htmlTag.isEmpty {
            return ""
        }
        
        // Разделяем имя тега и атрибуты
        let components = htmlTag.split(separator: " ", maxSplits: 1)
        let tagName = String(components[0])
        var attributes = ""
        
        // Получаем XML имя тега
        let xmlTagName = getXMLTagName(tagName)
        
        // Обрабатываем атрибуты, если есть
        if components.count > 1 {
            attributes = convertAttributes(String(components[1]))
        }
        
        // Если самозакрывающийся тег
        if tagName.hasSuffix("/") || isSelfClosingTag(tagName) {
            if attributes.isEmpty {
                return "<\(xmlTagName)/>"
            } else {
                return "<\(xmlTagName) \(attributes)/>"
            }
        }
        
        // Обычный тег
        if attributes.isEmpty {
            return "<\(xmlTagName)>"
        } else {
            return "<\(xmlTagName) \(attributes)>"
        }
    }
    
    /// Конвертирует HTML атрибуты в XML атрибуты
    private static func convertAttributes(_ htmlAttributes: String) -> String {
        var xmlAttributes: [String] = []
        
        // Разбираем атрибуты
        let pattern = "([a-zA-Z][a-zA-Z0-9_-]*)\\s*=\\s*\"([^\"]*)\""
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let range = NSRange(htmlAttributes.startIndex..., in: htmlAttributes)
            let matches = regex.matches(in: htmlAttributes, range: range)
            
            for match in matches {
                if let nameRange = Range(match.range(at: 1), in: htmlAttributes),
                   let valueRange = Range(match.range(at: 2), in: htmlAttributes) {
                    
                    let htmlAttrName = String(htmlAttributes[nameRange])
                    let attrValue = String(htmlAttributes[valueRange])
                    
                    // Получаем XML имя атрибута
                    let xmlAttrName = attributeMapping[htmlAttrName] ?? htmlAttrName
                    
                    // Экранируем значение
                    let escapedValue = escapeXMLAttribute(attrValue)
                    
                    xmlAttributes.append("\(xmlAttrName)=\"\(escapedValue)\"")
                }
            }
        }
        
        return xmlAttributes.joined(separator: " ")
    }
    
    /// Получает XML имя тега
    private static func getXMLTagName(_ htmlTagName: String) -> String {
        // Убираем / если есть
        var cleanName = htmlTagName
        if cleanName.hasSuffix("/") {
            cleanName = String(cleanName.dropLast())
        }
        
        // Ищем в маппинге
        return tagMapping[cleanName.lowercased()] ?? cleanName
    }
    
    /// Проверяет, является ли тег самозакрывающимся
    private static func isSelfClosingTag(_ tag: String) -> Bool {
        let selfClosingTags = ["br", "hr", "img", "input", "meta", "link", "base", "area", "col", "embed", "param", "source", "track", "wbr"]
        let tagName = tag.split(separator: " ").first?.lowercased() ?? ""
        return selfClosingTags.contains(tagName)
    }
    
    /// Создает отступ
    private static func indentString(level: Int) -> String {
        return String(repeating: "  ", count: level)
    }
    
    /// Экранирует текст для XML
    private static func escapeXML(_ text: String) -> String {
        var result = text
        let escapeMap = [
            "&": "&amp;",
            "<": "&lt;",
            ">": "&gt;",
            "\"": "&quot;",
            "'": "&apos;"
        ]
        
        for (char, replacement) in escapeMap {
            result = result.replacingOccurrences(of: char, with: replacement)
        }
        
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Экранирует значение атрибута для XML
    private static func escapeXMLAttribute(_ value: String) -> String {
        var result = value
        // Заменяем только кавычки, остальное уже обработано
        result = result.replacingOccurrences(of: "\"", with: "&quot;")
        result = result.replacingOccurrences(of: "'", with: "&apos;")
        return result
    }
}

// Читаем HTML из файла input.txt
do {
    let html = try String(contentsOfFile: "input.txt", encoding: .utf8)
    
    // Конвертируем в XML
    let xml = SimpleHTMLToXMLConverter.convert(html: html)
    
    // Выводим результат
    print(xml)
    
} catch {
    print("Ошибка: Не удалось прочитать файл input.txt")
}