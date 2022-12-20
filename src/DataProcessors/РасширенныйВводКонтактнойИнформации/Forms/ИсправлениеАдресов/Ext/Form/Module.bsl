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
	
	ИдентификаторПроверки = Параметры.ИдентификаторПроверки;
	
	Если ИдентификаторПроверки = "РаботаСАдресами.ИсправитьТипЗданияЛитерВАдресах" Тогда
		Заголовок = НСтр("ru = 'Исправление адресов с типом здания Литер';
						|en = 'Correcting addresses with the Liter building type'");
		Элементы.Пояснение.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(Элементы.Пояснение.Заголовок,
			Строка(Параметры.ВидПроверки.Свойство2));
	ИначеЕсли ИдентификаторПроверки = "РаботаСАдресами.ПроверитьАдресаНаСоответствиеАдресномуКлассификатору" Тогда
		Заголовок = НСтр("ru = 'Исправление адресов на соответствие адресному классификатору';
						|en = 'Correct addresses to comply with the address classifier'");
		Элементы.Пояснение.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(Элементы.Пояснение.Заголовок,
			Строка(Параметры.ВидПроверки.Свойство2));
	Иначе
		Заголовок = НСтр("ru = 'Исправление устаревших адресов';
						|en = 'Correcting obsolete addresses'");
		Элементы.Пояснение.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(Элементы.Пояснение.Заголовок,
			Строка(Параметры.ВидПроверки.Свойство2));
	КонецЕсли;
	
	Если ОбщегоНазначения.ЭтоМобильныйКлиент() Тогда
		ПоложениеКоманднойПанели = ПоложениеКоманднойПанелиФормы.Авто;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ИсправитьАдреса(Команда)
	
	Если ИдентификаторПроверки = "РаботаСАдресами.ИсправитьТипЗданияЛитерВАдресах" Тогда
		ДлительнаяОперация = ИсправитьАдресаСТипомЛитерВФоне(ИдентификаторПроверки);
	ИначеЕсли ИдентификаторПроверки = "РаботаСАдресами.ПроверитьАдресаНаСоответствиеАдресномуКлассификатору" Тогда
		ДлительнаяОперация = ИсправитьНекорректныеАдресаВФоне(ИдентификаторПроверки);
	Иначе
		ДлительнаяОперация = ИсправитьУстаревшиеАдресаВФоне(ИдентификаторПроверки);
	КонецЕсли;
	ПараметрыОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
	ОповещениеОЗавершении = Новый ОписаниеОповещения("ИсправитьПроблемуВФонеЗавершение", ЭтотОбъект);
	ДлительныеОперацииКлиент.ОжидатьЗавершение(ДлительнаяОперация, ОповещениеОЗавершении, ПараметрыОжидания);

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьТекущуюСтраницу(Форма, ИмяСтраницы)
	
	ЭлементыФормы = Форма.Элементы;
	Если ИмяСтраницы = "ИдетИсправлениеПроблемы" Тогда
		ЭлементыФормы.ГруппаИндикаторИсправления.Видимость         = Истина;
		ЭлементыФормы.ГруппаИндикаторНачалаИсправления.Видимость   = Ложь;
		ЭлементыФормы.ГруппаИндикаторУспешноеИсправление.Видимость = Ложь;
		ЭлементыФормы.Исправить.Видимость                          = Истина;
	ИначеЕсли ИмяСтраницы = "ИсправлениеУспешноВыполнено" Тогда
		ЭлементыФормы.ГруппаИндикаторИсправления.Видимость         = Ложь;
		ЭлементыФормы.ГруппаИндикаторНачалаИсправления.Видимость   = Ложь;
		ЭлементыФормы.ГруппаИндикаторУспешноеИсправление.Видимость = Истина;
		ЭлементыФормы.Закрыть.КнопкаПоУмолчанию                    = Истина;
		ЭлементыФормы.Исправить.Видимость                           = Ложь;
	Иначе // "Вопрос"
		ЭлементыФормы.ГруппаИндикаторИсправления.Видимость         = Ложь;
		ЭлементыФормы.ГруппаИндикаторНачалаИсправления.Видимость   = Истина;
		ЭлементыФормы.ГруппаИндикаторУспешноеИсправление.Видимость = Ложь;
		ЭлементыФормы.Исправить.Видимость                          = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ИсправитьУстаревшиеАдресаВФоне(ИдентификаторПроверки)
	
	Если ДлительнаяОперация <> Неопределено Тогда
		ДлительныеОперации.ОтменитьВыполнениеЗадания(ДлительнаяОперация.ИдентификаторЗадания);
	КонецЕсли;
	
	УстановитьТекущуюСтраницу(ЭтотОбъект, "ИдетИсправлениеПроблемы");
	
	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияВФоне(УникальныйИдентификатор);
	ПараметрыВыполнения.НаименованиеФоновогоЗадания = НСтр("ru = 'Исправление устаревших адресов контактной информации';
															|en = 'Correcting obsolete contact information addresses'");
	
	ПараметрыВыполненияФоновогоЗадания = Новый Структура;
	ПараметрыВыполненияФоновогоЗадания.Вставить("ИдентификаторПроверки", ИдентификаторПроверки);
	ПараметрыВыполненияФоновогоЗадания.Вставить("ВидПроверки", Параметры.ВидПроверки);
	
	Возврат ДлительныеОперации.ВыполнитьВФоне("РаботаСАдресами.ИсправитьУстаревшиеАдресаВФоне",
		ПараметрыВыполненияФоновогоЗадания, ПараметрыВыполнения);
	
КонецФункции

&НаСервере
Функция ИсправитьНекорректныеАдресаВФоне(ИдентификаторПроверки)
	
	Если ДлительнаяОперация <> Неопределено Тогда
		ДлительныеОперации.ОтменитьВыполнениеЗадания(ДлительнаяОперация.ИдентификаторЗадания);
	КонецЕсли;
	
	УстановитьТекущуюСтраницу(ЭтотОбъект, "ИдетИсправлениеПроблемы");
	
	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияВФоне(УникальныйИдентификатор);
	ПараметрыВыполнения.НаименованиеФоновогоЗадания = НСтр("ru = 'Исправление адресов контактной информации';
															|en = 'Correct contact information addresses'");
	
	ПараметрыВыполненияФоновогоЗадания = Новый Структура;
	ПараметрыВыполненияФоновогоЗадания.Вставить("ИдентификаторПроверки", ИдентификаторПроверки);
	ПараметрыВыполненияФоновогоЗадания.Вставить("ВидПроверки", Параметры.ВидПроверки);
	
	Возврат ДлительныеОперации.ВыполнитьВФоне("РаботаСАдресами.ИсправитьНекорректныеАдресаВФоне",
		ПараметрыВыполненияФоновогоЗадания, ПараметрыВыполнения);
	
КонецФункции

&НаСервере
Функция ИсправитьАдресаСТипомЛитерВФоне(ИдентификаторПроверки)
	
	Если ДлительнаяОперация <> Неопределено Тогда
		ДлительныеОперации.ОтменитьВыполнениеЗадания(ДлительнаяОперация.ИдентификаторЗадания);
	КонецЕсли;
	
	УстановитьТекущуюСтраницу(ЭтотОбъект, "ИдетИсправлениеПроблемы");
	
	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияВФоне(УникальныйИдентификатор);
	ПараметрыВыполнения.НаименованиеФоновогоЗадания = НСтр("ru = 'Исправление адресов контактной информации  с типом здания Литер';
															|en = 'Correcting contact information addresses with the Liter building type'");
	
	ПараметрыВыполненияФоновогоЗадания = Новый Структура;
	ПараметрыВыполненияФоновогоЗадания.Вставить("ИдентификаторПроверки", ИдентификаторПроверки);
	ПараметрыВыполненияФоновогоЗадания.Вставить("ВидПроверки", Параметры.ВидПроверки);
	
	Возврат ДлительныеОперации.ВыполнитьВФоне("РаботаСАдресами.ИсправитьТипЗданияЛитерВАдресахВФоне",
		ПараметрыВыполненияФоновогоЗадания, ПараметрыВыполнения);
	
КонецФункции

&НаКлиенте
Процедура ИсправитьПроблемуВФонеЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	ДлительнаяОперация = Неопределено;

	Если Результат = Неопределено Тогда
		УстановитьТекущуюСтраницу(ЭтотОбъект, "ИдетИсправлениеПроблемы");
		Возврат;
	ИначеЕсли Результат.Статус = "Ошибка" Тогда
		УстановитьТекущуюСтраницу(ЭтотОбъект, "Вопрос");
		ВызватьИсключение Результат.КраткоеПредставлениеОшибки;
	ИначеЕсли Результат.Статус = "Выполнено" Тогда
		Результат = ПолучитьИзВременногоХранилища(Результат.АдресРезультата);
		Если ТипЗнч(Результат) = Тип("Структура") Тогда
			Элементы.НадписьУспешноеИсправление.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				Элементы.НадписьУспешноеИсправление.Заголовок, Результат.ИсправленоОбъектов, Результат.ВсегоОбъектов);
		КонецЕсли;
		УстановитьТекущуюСтраницу(ЭтотОбъект, "ИсправлениеУспешноВыполнено");
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти