﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ЗаполнитьСписокТиповОбъектов();
	
	Если Не ПустаяСтрока(Параметры.ВыбранныеТипы) Тогда
		ВыбранныеТипы = СтрРазделить(Параметры.ВыбранныеТипы, ",", Истина);
		Для Каждого ВыбранныйТип Из ВыбранныеТипы Цикл
			НайденныйТип = ДоступныеОбъектыДляИзменения.НайтиПоЗначению(ВыбранныйТип);
			Если НайденныйТип <> Неопределено Тогда
				ДоступныеОбъектыДляИзменения.НайтиПоЗначению(ВыбранныйТип).Пометка = Истина;
				Элементы.ДоступныеОбъектыДляИзменения.ТекущаяСтрока = НайденныйТип.ПолучитьИдентификатор();
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыДоступныеОбъектыДляИзменения

&НаКлиенте
Процедура ДоступныеОбъектыДляИзмененияПриИзменении(Элемент)
	ОбновитьКоличествоВыбранных();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Выбрать(Команда)
	ВыбратьОбъектыИЗакрытьФорму();
КонецПроцедуры

&НаКлиенте
Процедура ДоступныеОбъектыДляИзмененияВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	ВыбратьОбъектыИЗакрытьФорму();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ЗаполнитьСписокТиповОбъектов()
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	ОбработкаОбъект.ЗаполнитьКоллекциюДоступныхДляИзмененияОбъектов(ДоступныеОбъектыДляИзменения, Параметры.ПоказыватьСкрытые);
КонецПроцедуры

// Параметры:
//   РодительскаяПодсистема - ОбъектМетаданныхПодсистема 
// Возвращаемое значение:
//   Соответствие
//
&НаСервереБезКонтекста
Функция ИменаПодчиненныхПодсистем(РодительскаяПодсистема)
	
	Имена = Новый Соответствие;
	
	Для Каждого ТекущаяПодсистема Из РодительскаяПодсистема.Подсистемы Цикл
		
		Имена.Вставить(ТекущаяПодсистема.Имя, Истина);
		ИменаПодчиненных = ИменаПодчиненныхПодсистем(ТекущаяПодсистема);
		
		Для каждого ИмяПодчиненной Из ИменаПодчиненных Цикл
			Имена.Вставить(ТекущаяПодсистема.Имя + "." + ИмяПодчиненной.Ключ, Истина);
		КонецЦикла;
	КонецЦикла;
	
	Возврат Имена;
	
КонецФункции

&НаКлиенте
Функция ВыбранныеЭлементы()
	Результат = Новый Массив;
	Для Каждого Элемент Из ДоступныеОбъектыДляИзменения Цикл
		Если Элемент.Пометка Тогда
			Результат.Добавить(Элемент.Значение);
		КонецЕсли;
	КонецЦикла;
	Возврат Результат;
КонецФункции

&НаКлиенте
Процедура ВыбратьОбъектыИЗакрытьФорму()
	ВыбранныеЭлементы = ВыбранныеЭлементы();
	Если ВыбранныеЭлементы.Количество() = 0 Тогда
		ВыбранныеЭлементы.Добавить(Элементы.ДоступныеОбъектыДляИзменения.ТекущиеДанные.Значение);
	КонецЕсли;
	Закрыть(ВыбранныеЭлементы);
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьКоличествоВыбранных()
	ТекстКнопкиВыбора = НСтр("ru = 'Выбрать';
							|en = 'Select'");
	КоличествоВыбранных = ВыбранныеЭлементы().Количество();
	Если КоличествоВыбранных > 0 Тогда
		ТекстКнопкиВыбора = ТекстКнопкиВыбора + " (" + КоличествоВыбранных + ")";
	КонецЕсли;
	Элементы.ФормаВыбрать.Заголовок = ТекстКнопкиВыбора;
КонецПроцедуры

#КонецОбласти
