﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

//// Форма параметризуется:
////
////      ИдентификаторНаселенногоПункта    - УникальныйИдентификатор - Идентификатор текущего объекта для определения и
////                                                                    редактирования частей формы.
////      НаселенныйПунктДетально           - Структура               - Описание населенного пункта в терминах варианта
////                                                                    классификатора. Используется, если не указан
////                                                                    идентификатор.
////      ФорматАдреса - Строка - Вариант адресного  классификатора,
////      СкрыватьНеактуальныеАдреса        - Булево - Флаг того, что при редактировании неактуальные адреса будут
////                                                   скрываться.
////      СервисКлассификатораНедоступен    - Булево - Необязательный флаг того, что поставщик на обслуживании.
////
////  Результат выбора:
////      Структура - поля:
////          * Идентификатор           - УникальныйИдентификатор - Выбранный населенный пункт.
////          * Представление           - Строка                  - Представление выбранного.
////          * НаселенныйПунктДетально - Структура               - Отредактированное описание населенного пункта.
////
//// -------------------------------------------------------------------------------------------------

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Параметры.Свойство("НаселенныйПунктДетально", НаселенныйПунктДетально);
	ИспользоватьАвтоподбор = Истина;
	Если НаселенныйПунктДетально <> Неопределено Тогда
		
		ТипАдреса = НаселенныйПунктДетально.AddressType;
		Если НаселенныйПунктДетально.Свойство("country")
			 И РаботаСАдресамиКлиентСервер.ЭтоОсновнаяСтрана(НаселенныйПунктДетально.Country) Тогда
			
			МуниципальныйРайон   = ПредставлениеУровняАдреса(НаселенныйПунктДетально, "munDistrict");
			Поселение            = ПредставлениеУровняАдреса(НаселенныйПунктДетально, "settlement");
			Территория           = ПредставлениеУровняАдреса(НаселенныйПунктДетально, "territory");
			
		Иначе
			ИспользоватьАвтоподбор = Ложь;
		КонецЕсли;
		
		Регион               = ПредставлениеУровняАдреса(НаселенныйПунктДетально, "area");
		Район                = ПредставлениеУровняАдреса(НаселенныйПунктДетально, "district");
		НаселенныйПункт      = ПредставлениеУровняАдреса(НаселенныйПунктДетально, "locality");
		Город                = ПредставлениеУровняАдреса(НаселенныйПунктДетально, "city");
	
	Иначе
		ТипАдреса = РаботаСАдресамиКлиентСервер.МуниципальныйАдрес();
		НаселенныйПунктДетально = УправлениеКонтактнойИнформацией.ОписаниеНовойКонтактнойИнформации(Перечисления.ТипыКонтактнойИнформации.Адрес);
	КонецЕсли;
	
	ЕстьПравоЗагружатьКлассификатор = Обработки.РасширенныйВводКонтактнойИнформации.ЕстьВозможностьИзмененияАдресногоКлассификатора();
	СведенияОАдресномКлассификаторе = УправлениеКонтактнойИнформациейСлужебныйПовтИсп.СведенияОДоступностиАдресногоКлассификатора();
	КлассификаторДоступен           = СведенияОАдресномКлассификаторе.Получить("КлассификаторДоступен");
	
	Если Не Параметры.ОтображатьКнопкиВыбора Тогда
		ОтключитьКнопкиВыбораУЧастейАдреса();
	КонецЕсли;
	
	Если ОбщегоНазначения.ЭтоМобильныйКлиент() Тогда
		
		ПоложениеКоманднойПанели = ПоложениеКоманднойПанелиФормы.Авто;
		Элементы.ФормаКомандаОК.Отображение = ОтображениеКнопки.Картинка;
		Элементы.ФормаСправка.Видимость = Ложь;
		Элементы.ФормаОтмена.Видимость  = Ложь;
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Параметры.ТипАдреса) Тогда
		Элементы.ТипАдреса.Видимость = Ложь;
		ТипАдреса = Параметры.ТипАдреса;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ОтобразитьПоляПоТипуАдреса();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ТипАдресаПриИзменении(Элемент)
	
	НаселенныйПунктДетально.AddressType = ?(РаботаСАдресамиКлиентСервер.ЭтоМуниципальныйАдрес(ТипАдреса),
		РаботаСАдресамиКлиентСервер.МуниципальныйАдрес(), РаботаСАдресамиКлиентСервер.АдминистративноТерриториальныйАдрес());
	ОтобразитьПоляПоТипуАдреса();
	ОпределитьПоляАдреса(Неопределено);
	
КонецПроцедуры

&НаКлиенте
Процедура СубъектРФАвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
	АвтоПодборПоУровню(Текст, ДанныеВыбора, "area", СтандартнаяОбработка);
КонецПроцедуры

&НаКлиенте
Процедура РайонАвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
	АвтоПодборПоУровню(Текст, ДанныеВыбора, "district", СтандартнаяОбработка);
КонецПроцедуры

&НаКлиенте
Процедура МуниципальныйРайонАвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
	АвтоПодборПоУровню(Текст, ДанныеВыбора, "munDistrict", СтандартнаяОбработка);
КонецПроцедуры

&НаКлиенте
Процедура ГородАвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
	АвтоПодборПоУровню(Текст, ДанныеВыбора, "city", СтандартнаяОбработка);
КонецПроцедуры

&НаКлиенте
Процедура ПоселениеАвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
	АвтоПодборПоУровню(Текст, ДанныеВыбора, "settlement", СтандартнаяОбработка);
КонецПроцедуры

&НаКлиенте
Процедура НаселенныйПунктАвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
	АвтоПодборПоУровню(Текст, ДанныеВыбора, "locality", СтандартнаяОбработка);
КонецПроцедуры

&НаКлиенте
Процедура ТерриторияАвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
	АвтоПодборПоУровню(Текст, ДанныеВыбора, "territory", СтандартнаяОбработка);
КонецПроцедуры

&НаКлиенте
Процедура СубъектРФНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	ОткрытьФормуВыбораАдресныхОбъектов(Элемент, ДанныеВыбора, СтандартнаяОбработка);
КонецПроцедуры

&НаКлиенте
Процедура РайонНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	ОткрытьФормуВыбораАдресныхОбъектов(Элемент, ДанныеВыбора, СтандартнаяОбработка);
КонецПроцедуры

&НаКлиенте
Процедура МуниципальныйРайонНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	ОткрытьФормуВыбораАдресныхОбъектов(Элемент, ДанныеВыбора, СтандартнаяОбработка);
КонецПроцедуры

&НаКлиенте
Процедура ПоселениеНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	ОткрытьФормуВыбораАдресныхОбъектов(Элемент, ДанныеВыбора, СтандартнаяОбработка);
КонецПроцедуры

&НаКлиенте
Процедура ГородНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	ОткрытьФормуВыбораАдресныхОбъектов(Элемент, ДанныеВыбора, СтандартнаяОбработка);
КонецПроцедуры

&НаКлиенте
Процедура НаселенныйПунктНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	ОткрытьФормуВыбораАдресныхОбъектов(Элемент, ДанныеВыбора, СтандартнаяОбработка);
КонецПроцедуры

&НаКлиенте
Процедура ТерриторияНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	ОткрытьФормуВыбораАдресныхОбъектов(Элемент, ДанныеВыбора, СтандартнаяОбработка);
КонецПроцедуры

&НаКлиенте
Процедура СубъектРФОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	ОбработкаВыбораУровня(Элемент, ВыбранноеЗначение, СтандартнаяОбработка);
КонецПроцедуры

&НаКлиенте
Процедура РайонОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	ОбработкаВыбораУровня(Элемент, ВыбранноеЗначение, СтандартнаяОбработка);
КонецПроцедуры

&НаКлиенте
Процедура МуниципальныйРайонОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	ОбработкаВыбораУровня(Элемент, ВыбранноеЗначение, СтандартнаяОбработка);
КонецПроцедуры

&НаКлиенте
Процедура ГородОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	ОбработкаВыбораУровня(Элемент, ВыбранноеЗначение, СтандартнаяОбработка);
КонецПроцедуры

&НаКлиенте
Процедура ПоселениеОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	ОбработкаВыбораУровня(Элемент, ВыбранноеЗначение, СтандартнаяОбработка);
КонецПроцедуры

&НаКлиенте
Процедура НаселенныйПунктОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	ОбработкаВыбораУровня(Элемент, ВыбранноеЗначение, СтандартнаяОбработка);
КонецПроцедуры

&НаКлиенте
Процедура ТерриторияОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	ОбработкаВыбораУровня(Элемент, ВыбранноеЗначение, СтандартнаяОбработка);
КонецПроцедуры

&НаКлиенте
Процедура СубъектРФПриИзменении(Элемент)
	ИзменитьУровеньАдреса("area", Регион);
КонецПроцедуры

&НаКлиенте
Процедура РайонПриИзменении(Элемент)
	ИзменитьУровеньАдреса("district", Район);
КонецПроцедуры

&НаКлиенте
Процедура МуниципальныйРайонПриИзменении(Элемент)
	ИзменитьУровеньАдреса("munDistrict", МуниципальныйРайон);
КонецПроцедуры

&НаКлиенте
Процедура ГородПриИзменении(Элемент)
	ИзменитьУровеньАдреса("city", Город);
КонецПроцедуры

&НаКлиенте
Процедура ПоселениеПриИзменении(Элемент)
	ИзменитьУровеньАдреса("settlement", Поселение);
КонецПроцедуры

&НаКлиенте
Процедура НаселенныйПунктПриИзменении(Элемент)
	ИзменитьУровеньАдреса("locality", НаселенныйПункт);
КонецПроцедуры

&НаКлиенте
Процедура ТерриторияПриИзменении(Элемент)
	ИзменитьУровеньАдреса("territory", Территория);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура КомандаОК(Команда)
	
	Если Модифицированность Тогда
		Закрыть(ВозвращаемыеДанныеОбАдресе());
	Иначе
		Закрыть();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ОбработкаВыбораУровня(Элемент, Знач ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если ПустаяСтрока(ВыбранноеЗначение) Тогда
		ТекстПредупреждения = НСтр("ru = 'Выбор из списка недоступен, т.к в адресном классификаторе отсутствует информация о адресных сведениях.';
									|en = 'Dropdown selection is not available. The address classifier does not contain details on the address.'");
		ПоказатьПредупреждение(, ТекстПредупреждения );
		СтандартнаяОбработка = Ложь;
		Возврат;
	КонецЕсли;
	
	Если ТипЗнч(ВыбранноеЗначение) <> Тип("Структура") Тогда
		Возврат;
	КонецЕсли;
	
	Если ВыбранноеЗначение.Свойство("Идентификатор")
		 И ПустаяСтрока(ВыбранноеЗначение.Идентификатор) Тогда
		 СтандартнаяОбработка = Ложь;
			Возврат;
	КонецЕсли;

	Если ВыбранноеЗначение.Отказ Или ПустаяСтрока(ВыбранноеЗначение.Идентификатор) Тогда
		Возврат;
	КонецЕсли;
		
	СтандартнаяОбработка = Ложь;
	
	СведенияОбАдресе                   = СведенияОбАдресномОбъекта();
	СведенияОбАдресе.Муниципальный     = РаботаСАдресамиКлиентСервер.ЭтоМуниципальныйАдрес(ТипАдреса);
	СведенияОбАдресе.Адрес             = НаселенныйПунктДетально;
	СведенияОбАдресе.ЗагруженныеДанные = ВыбранноеЗначение.ЗагруженныеДанные;
	СведенияОбАдресе.Идентификатор     = ВыбранноеЗначение.Идентификатор;
	
	НаселенныйПунктДетально = НаселенныйПунктДетальноПоИдентификатору(СведенияОбАдресе);
	
	ОпределитьПоляАдреса(ВыбранноеЗначение.Уровень);
	Элемент.ОбновитьТекстРедактирования();
	
	Если ЕстьПравоЗагружатьКлассификатор И Не КлассификаторДоступен И ВыбранноеЗначение.ПредлагатьЗагрузкуКлассификатора Тогда
		// Предлагаем загрузить классификатор.
		ПредложениеЗагрузкиКлассификатора(СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Данные для ""%1"" не загружены.';
																										|en = 'Data for ""%1"" is not imported.'"), ВыбранноеЗначение.Представление),
			ВыбранноеЗначение.Представление);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ОтключитьКнопкиВыбораУЧастейАдреса()
	
	Элементы.СубъектРФ.КнопкаВыбора            = Ложь;
	Элементы.Район.КнопкаВыбора                = Ложь;
	Элементы.МуниципальныйРайон.КнопкаВыбора   = Ложь;
	Элементы.Город.КнопкаВыбора                = Ложь;
	Элементы.Поселение.КнопкаВыбора            = Ложь;
	Элементы.НаселенныйПункт.КнопкаВыбора      = Ложь;
	Элементы.Территория.КнопкаВыбора           = Ложь;

КонецПроцедуры

&НаКлиенте
Функция ИмяУровняПоНазваниюЭлемента(ИмяЭлемента)
	
	ИменаУровней = Новый Соответствие;
	ИменаУровней.Вставить("СубъектРФ",          "area");
	ИменаУровней.Вставить("Район",              "district");
	ИменаУровней.Вставить("МуниципальныйРайон", "munDistrict");
	ИменаУровней.Вставить("Город",              "city");
	ИменаУровней.Вставить("Поселение",          "settlement");
	ИменаУровней.Вставить("НаселенныйПункт",    "locality");
	ИменаУровней.Вставить("Территория",         "territory");
	
	Возврат ИменаУровней[ИмяЭлемента];
	
КонецФункции

&НаКлиенте
Функция ВозвращаемыеДанныеОбАдресе()
	
	Результат = РаботаСАдресамиКлиентСервер.ВозвращаемыеДанныеОбАдресе();
	
	Результат.НаселенныйПунктДетально = НаселенныйПунктДетально;
	
	Возврат Результат;
	
КонецФункции

&НаКлиенте
Функция ПорядокУровнейАдреса(ТипАдреса)
	
	ИменаУровней = РаботаСАдресамиКлиентСервер.ИменаУровнейАдреса(ТипАдреса, Истина);
	НаборУровней = Новый Массив;
	
	Для каждого ИмяУровня Из ИменаУровней Цикл
		Если ЗначениеЗаполнено(НаселенныйПунктДетально[ИмяУровня]) 
			 Или ЗначениеЗаполнено(НаселенныйПунктДетально[ИмяУровня + "Type"]) Тогда
				НаборУровней.Добавить(ИмяУровня);
		КонецЕсли;
	КонецЦикла;
	
	Если ЗначениеЗаполнено(НаселенныйПунктДетально.houseNumber) 
		Или НаселенныйПунктДетально.apartments.Количество() >0 Тогда
			НаборУровней.Добавить("house");
	КонецЕсли;
	
	Возврат НаборУровней;
	
КонецФункции

&НаКлиенте
Процедура ОткрытьФормуВыбораАдресныхОбъектов(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	
	ИмяУровня = ИмяУровняПоНазваниюЭлемента(Элемент.Имя);
	
	РодительскийИдентификатор = ИдентификаторРодителяУровняАдреса(ИмяУровня, НаселенныйПунктДетально, ТипАдреса);
	Уровень = РаботаСАдресамиКлиентСервер.СопоставлениеНаименованиеУровнюАдреса(ИмяУровня);
	
	ПараметрыОткрытия = Новый Структура;
	ПараметрыОткрытия.Вставить("ТипАдреса", ТипАдреса);
	ПараметрыОткрытия.Вставить("Уровень",   Уровень);
	ПараметрыОткрытия.Вставить("Родитель",  РодительскийИдентификатор);
	
	ОткрытьФорму("Обработка.РасширенныйВводКонтактнойИнформации.Форма.ВыборАдресаПоУровню", ПараметрыОткрытия, Элемент);
	Модифицированность = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура ОпределитьПоляАдреса(Знач Уровень)
	
	Регион               = ПредставлениеУровняАдреса(НаселенныйПунктДетально, "area");
	Район                = ПредставлениеУровняАдреса(НаселенныйПунктДетально, "district");
	МуниципальныйРайон   = ПредставлениеУровняАдреса(НаселенныйПунктДетально, "munDistrict");
	Город                = ПредставлениеУровняАдреса(НаселенныйПунктДетально, "city");
	Поселение            = ПредставлениеУровняАдреса(НаселенныйПунктДетально, "settlement");
	НаселенныйПункт      = ПредставлениеУровняАдреса(НаселенныйПунктДетально, "locality");
	Территория           = ПредставлениеУровняАдреса(НаселенныйПунктДетально, "territory");

КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция ПредставлениеУровняАдреса(Адрес, ИмяУровня)
	
	СкорректироватьИмяУровняКогдаГородВРайоне(Адрес, ИмяУровня);
	
	ИменаУровнейАдресаПоАдресу = РаботаСАдресамиКлиентСервер.ИменаУровнейАдресаПоАдресу(Адрес, Ложь);
	
	Если ИменаУровнейАдресаПоАдресу.Найти(ИмяУровня) = Неопределено Тогда
		Возврат "";
	КонецЕсли;
	
	Если СтрСравнить(ИмяУровня, "area") = 0 И ЗначениеЗаполнено(Адрес.areaValue) Тогда
		Возврат Адрес.areaValue;
	КонецЕсли;
	
	Если Адрес.Свойство(ИмяУровня) И ЗначениеЗаполнено(Адрес[ИмяУровня]) Тогда
		Возврат УправлениеКонтактнойИнформациейКлиентСервер.СоединитьНаименованиеИТипАдресногоОбъекта(
			Адрес[ИмяУровня], Адрес[ИмяУровня +"Type"], СтрСравнить(ИмяУровня, "area") = 0);
	КонецЕсли;
	
	Возврат "";
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Процедура СкорректироватьИмяУровняКогдаГородВРайоне(Адрес, ИмяУровня)
	
	ТипАдреса = Адрес.AddressType;
	
	Если РаботаСАдресамиКлиентСервер.ЭтоМуниципальныйАдрес(ТипАдреса) 
		И СтрСравнить(ИмяУровня, "city") = 0
		И ПустаяСтрока(Адрес["city"])
		И (СтрСравнить(Адрес["districtType"], "Г") = 0 
			Или СтрСравнить(Адрес["districtType"], "Г.") = 0) Тогда
			
			ИмяУровня = "district";
			
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОтобразитьПоляПоТипуАдреса()
	
	Если СтрСравнить(УправлениеКонтактнойИнформациейКлиентСервер.АдресЕАЭС(), ТипАдреса) <> 0 Тогда
		
		ЭтоМуниципальныйАдрес = РаботаСАдресамиКлиентСервер.ЭтоМуниципальныйАдрес(ТипАдреса);
		Элементы.Район.Видимость              = НЕ ЭтоМуниципальныйАдрес;
		Элементы.МуниципальныйРайон.Видимость = ЭтоМуниципальныйАдрес;
		Элементы.Поселение.Видимость          = ЭтоМуниципальныйАдрес;
		
	Иначе
		
		Элементы.ТипАдреса.Видимость            = Ложь;
		Элементы.МуниципальныйРайон.Видимость   = Ложь;
		Элементы.Поселение.Видимость            = Ложь;
		Элементы.Территория.Видимость           = Ложь;
		Элементы.СубъектРФ.Заголовок            = НСтр("ru = 'Регион';
														|en = 'State'");
		Элементы.СубъектРФ.КнопкаВыбора         = Ложь;
		Элементы.Район.КнопкаВыбора             = Ложь;
		Элементы.Город.КнопкаВыбора             = Ложь;
		Элементы.НаселенныйПункт.КнопкаВыбора   = Ложь;
		
	КонецЕсли;
	
	
КонецПроцедуры

&НаКлиенте
Процедура АвтоПодборПоУровню( Знач Текст, ДанныеВыбора, ИмяУровня, СтандартнаяОбработка)
	
	Если ИспользоватьАвтоподбор И ЗначениеЗаполнено(Текст) Тогда
		
		ДанныеВыбора = АвтоПодборВариантов(Текст, ИмяУровня, ТипАдреса, НаселенныйПунктДетально);
		СтандартнаяОбработка = НЕ ДанныеВыбора.Количество() > 0;
		Модифицированность = Истина;
		
	КонецЕсли;

КонецПроцедуры

&НаСервереБезКонтекста
Функция АвтоПодборВариантов(Текст, ИмяУровня, ТипАдреса, НаселенныйПунктДетально)
	
	ДанныеВыбора = Новый СписокЗначений;
	
	Если ЗначениеЗаполнено(Текст) Тогда
		
		РодительскийИдентификатор = ИдентификаторРодителяУровняАдреса(ИмяУровня, НаселенныйПунктДетально, ТипАдреса);
		
		Если НЕ ЗначениеЗаполнено(РодительскийИдентификатор) И СтрСравнить(ИмяУровня, "area") <> 0 Тогда
			Возврат ДанныеВыбора;
		КонецЕсли;
		
		Уровень = РаботаСАдресамиКлиентСервер.СопоставлениеНаименованиеУровнюАдреса(ИмяУровня);
	
		МодульАдресныйКлассификаторСлужебный = ОбщегоНазначения.ОбщийМодуль("АдресныйКлассификаторСлужебный");
		Результат = МодульАдресныйКлассификаторСлужебный.АдресныеОбъектыУровня(РодительскийИдентификатор, Уровень, ТипАдреса, Текст);
		Если Не Результат.Отказ Тогда
			ДанныеВыбора = Результат.Данные;
		КонецЕсли;
		
		Если ДанныеВыбора.Количество() = 0 Тогда
			ИменаУровней = РаботаСАдресамиКлиентСервер.ИменаУровнейАдреса(ТипАдреса, Истина, Истина);
			ОчищатьИдентификатор = Ложь;
			Для каждого Уровень Из ИменаУровней Цикл
				Если СтрСравнить(ИмяУровня, Уровень) = 0 Тогда
					ОчищатьИдентификатор = Истина;
				КонецЕсли;
				Если ОчищатьИдентификатор Тогда
					НаселенныйПунктДетально[Уровень + "Id"] = "";
				КонецЕсли;
			КонецЦикла;
			НаселенныйПунктДетально["Id"] = ИдентификаторРодителяУровняАдреса(ИмяУровня, НаселенныйПунктДетально, ТипАдреса);
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат ДанныеВыбора;
	
КонецФункции

&НаСервереБезКонтекста
Функция ИдентификаторРодителяУровняАдреса(Знач ИмяУровня, Знач НаселенныйПунктДетально, Знач ТипАдреса)
	
	РодительскийИдентификатор = Неопределено;
	
	ЭтоМуниципальныйАдрес = РаботаСАдресамиКлиентСервер.ЭтоМуниципальныйАдрес(ТипАдреса);
	
	ИменаУровнейАдреса = ?(ЭтоМуниципальныйАдрес,
		НаселенныйПунктДетально.munLevels,
		НаселенныйПунктДетально.admLevels);
		
	Уровень = РаботаСАдресамиКлиентСервер.СопоставлениеНаименованиеУровнюАдреса(ИмяУровня);
	
	Если ИменаУровнейАдреса.Количество() = 0 Тогда
		ИменаУровнейАдреса = РаботаСАдресамиКлиентСервер.ИменаУровнейАдреса(ТипАдреса, Ложь);
	КонецЕсли;
	
	Для каждого ИмяУровняАдреса Из ИменаУровнейАдреса Цикл
		
		ТекущийУровня = РаботаСАдресамиКлиентСервер.СопоставлениеНаименованиеУровнюАдреса(ИмяУровняАдреса);
		Если ТекущийУровня > Уровень Или ИмяУровняАдреса = ИмяУровня Тогда
			Возврат РодительскийИдентификатор;
		КонецЕсли;
		
		Если ЗначениеЗаполнено(НаселенныйПунктДетально[ИмяУровняАдреса + "Id"]) Тогда
			РодительскийИдентификатор = НаселенныйПунктДетально[ИмяУровняАдреса + "Id"];
		КонецЕсли;
	КонецЦикла;
	
	Возврат РодительскийИдентификатор;
	
КонецФункции


// Возвращаемое значение:
//  Структура:
//   * ЗагруженныеДанные - Булево
//   * Идентификатор - УникальныйИдентификатор
//   * Муниципальный - Булево
//   * Адрес - Структура
//
&НаКлиенте
Функция СведенияОбАдресномОбъекта()
	
	СведенияОбАдресе = Новый Структура;
	СведенияОбАдресе.Вставить("ЗагруженныеДанные", Ложь);
	СведенияОбАдресе.Вставить("Идентификатор",     Новый УникальныйИдентификатор);
	СведенияОбАдресе.Вставить("Муниципальный",     Ложь);
	СведенияОбАдресе.Вставить("Адрес",      Новый Структура);
	
	Возврат СведенияОбАдресе;
КонецФункции

// Предлагает загрузить адресный классификатор.
//
//  Параметры:
//      Текст  - Строка        - дополнительный текст предложения.
//      Регион - Число
//             - Строка - код или название региона для загрузки.
//
&НаКлиенте
Процедура ПредложениеЗагрузкиКлассификатора(Знач Текст = "", Знач Регион = Неопределено)
	
	Если Не ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.АдресныйКлассификатор") Тогда
		Возврат;
	КонецЕсли;
	
	НеЗагружатьАдресныйКлассификатор = ПараметрыПриложения.Получить("АдресныйКлассификатор.НеЗагружатьКлассификатор");
	Если НеЗагружатьАдресныйКлассификатор = Неопределено ИЛИ НеЗагружатьАдресныйКлассификатор = Ложь Тогда
		ТипПараметраРегиона = ТипЗнч(Регион);
		ПараметрыФормы = Новый Структура;
		ПараметрыЗагрузки = Новый Структура;
		ПараметрыФормы.Вставить("ТекстПредупреждения", Текст);
		
		Если ТипПараметраРегиона = Тип("Число") Тогда
			ПараметрыЗагрузки.Вставить("КодРегионаДляЗагрузки", Регион);
			
		ИначеЕсли ТипПараметраРегиона = Тип("Строка") Тогда
			ПараметрыЗагрузки.Вставить("НазваниеРегиона", Регион);
			ПараметрыФормы.Вставить("НазваниеРегиона", Регион);
		КонецЕсли;
		
		Оповещение = Новый ОписаниеОповещения("ПредложениеЗагрузкиКлассификатораЗавершение", ЭтотОбъект, ПараметрыЗагрузки);
		ОткрытьФорму("Обработка.РасширенныйВводКонтактнойИнформации.Форма.ЗагрузкаАдресногоКлассификатора", ПараметрыФормы, ЭтотОбъект,,,, Оповещение, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПредложениеЗагрузкиКлассификатораЗавершение(Знач РезультатВопроса, Знач ДополнительныеПараметры) Экспорт
	
	Если РезультатВопроса <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
	
	ЗагрузитьАдресныйКлассификатор(ДополнительныеПараметры);
	
КонецПроцедуры

// Загружает адресный классификатор.
//
&НаКлиенте
Процедура ЗагрузитьАдресныйКлассификатор(Знач ДополнительныеПараметры = Неопределено)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.АдресныйКлассификатор") Тогда
		МодульАдресныйКлассификаторКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("АдресныйКлассификаторКлиент");
		МодульАдресныйКлассификаторКлиент.ЗагрузитьАдресныйКлассификатор(ДополнительныеПараметры);
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция НаселенныйПунктДетальноПоИдентификатору(СведенияОбАдресе)
	Возврат Обработки.РасширенныйВводКонтактнойИнформации.СписокРеквизитовНаселенныйПункт(СведенияОбАдресе);
КонецФункции

&НаКлиенте
Процедура ИзменитьУровеньАдреса(ИмяУровня, Значение)
	
	Если ТипАдреса =  РаботаСАдресамиКлиентСервер.АдминистративноТерриториальныйАдрес()
		Или ТипАдреса =  РаботаСАдресамиКлиентСервер.МуниципальныйАдрес() Тогда
			НаименованиеСокращение = УправлениеКонтактнойИнформациейКлиентСервер.НаименованиеСокращение(Значение);
			
			НаселенныйПунктДетально[ИмяУровня]          = НаименованиеСокращение.Наименование;
			НаселенныйПунктДетально[ИмяУровня + "Type"] = НаименованиеСокращение.Сокращение;
			НаселенныйПунктДетально[ИмяУровня + "Id"]   = "";
	Иначе
			НаселенныйПунктДетально[ИмяУровня] = Значение;
	КонецЕсли;
	
	НаселенныйПунктДетально.munLevels = ПорядокУровнейАдреса(РаботаСАдресамиКлиентСервер.МуниципальныйАдрес());
	НаселенныйПунктДетально.admLevels = ПорядокУровнейАдреса(РаботаСАдресамиКлиентСервер.АдминистративноТерриториальныйАдрес());
	
КонецПроцедуры

#КонецОбласти