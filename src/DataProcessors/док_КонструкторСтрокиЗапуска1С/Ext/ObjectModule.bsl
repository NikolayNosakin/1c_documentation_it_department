﻿//Источник https://github.com/galiullintr/1CCommandLine/

Процедура ПрочитатьМакет(Форма, ИмяМакета) Экспорт
	
	Макет = ПолучитьМакет(ИмяМакета);
	
	Колонки = Новый Структура;
	
	Для НомерКолонки = 1 По Макет.ШиринаТаблицы Цикл
		
		Ячейка = Макет.Область(1, НомерКолонки, 1, НомерКолонки);
		
		Колонки.Вставить(Ячейка.Текст, НомерКолонки);
		
	КонецЦикла;
	
	Для НомерСтроки = 2 По Макет.ВысотаТаблицы Цикл
		
		НоваяСтрока = Форма[ИмяМакета].Добавить();
		
		Для Каждого КлючЗначение Из Колонки Цикл
			
			НомерКолонки = КлючЗначение.Значение;
			ИмяКолонки   = КлючЗначение.Ключ;
			
			Ячейка = Макет.Область(НомерСтроки, НомерКолонки, НомерСтроки, НомерКолонки);
			
			Если ТипЗнч(НоваяСтрока[ИмяКолонки]) = Тип("Булево") Тогда
				НоваяСтрока[ИмяКолонки] = (Ячейка.Текст = "1") Или (Ячейка.Текст = "Да");
			Иначе
				НоваяСтрока[ИмяКолонки] = Ячейка.Текст;
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЦикла;
	
КонецПроцедуры