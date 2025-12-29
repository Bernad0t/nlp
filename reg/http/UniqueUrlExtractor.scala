import scala.io.Source
import scala.util.matching.Regex
import scala.util.Try

object UniqueUrlExtractor {
  
  // Регулярное выражение для поиска URL
  private val urlPattern: Regex = 
    """https?://(?:[-\w.]|(?:%[\da-fA-F]{2}))+(?:/[-\w.]*(?:\?\S*)?)?""".r
  
  /**
   * Извлекает уникальные URL из файла
   * @param filename путь к файлу
   * @return List[String] список уникальных URL
   */
  def extractUniqueUrls(filename: String): List[String] = {
    Try {
      // Читаем файл
      val content = Source.fromFile(filename, "UTF-8").mkString
      
      // Находим все URL
      val allUrls = urlPattern.findAllIn(content).toList
      
      // Возвращаем уникальные URL
      allUrls.distinct
    }.getOrElse {
      println(s"Ошибка при чтении файла: $filename")
      List.empty[String]
    }
  }
  
  /**
   * Выводит найденные URL в консоль
   */
  def printUrlsToConsole(urls: List[String]): Unit = {
    if (urls.nonEmpty) {
      println("=" * 60)
      println(s"📊 НАЙДЕНО УНИКАЛЬНЫХ URL: ${urls.size}")
      println("=" * 60)
      
      urls.zipWithIndex.foreach { case (url, index) =>
        val protocol = if (url.startsWith("https://")) "🔒 HTTPS" else "🌐 HTTP"
        println(f"${index + 1}%3d. $protocol: $url")
      }
      
      println("=" * 60)
      
      // Дополнительная статистика
      val httpsCount = urls.count(_.startsWith("https://"))
      val httpCount = urls.count(_.startsWith("http://"))
      println(s"📈 Статистика:")
      println(s"   🔒 HTTPS: $httpsCount")
      println(s"   🌐 HTTP:  $httpCount")
    } else {
      println("❌ URL не найдены в файле")
    }
  }
  
  def main(args: Array[String]): Unit = {
    // Определяем файл для анализа
    val inputFile = if (args.length >= 1) args(0) else "input.txt"
    
    println("🔍 ПРОГРАММА ИЗВЛЕЧЕНИЯ УНИКАЛЬНЫХ URL")
    println(s"📂 Анализируемый файл: $inputFile")
    println("-" * 40)
    
    // Извлекаем уникальные URL
    val uniqueUrls = extractUniqueUrls(inputFile)
    
    // Выводим результат в консоль
    printUrlsToConsole(uniqueUrls)
  }
}