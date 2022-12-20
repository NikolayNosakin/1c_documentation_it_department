﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем ОбновитьИнтерфейс;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Не Пользователи.ОбщиеНастройкиВходаИспользуются() Тогда
		Элементы.ГруппаНастройкиВходаПользователей.Видимость = Ложь;
		Элементы.ГруппаСписокВнешнихПользователейОтступ.Видимость = Ложь;
		Элементы.ГруппаНастройкиВходаВнешнихПользователей.Видимость = Ложь;
		Элементы.ГруппаВнешниеПользователи.Группировка
			= ГруппировкаПодчиненныхЭлементовФормы.ГоризонтальнаяВсегда;
	КонецЕсли;
	
	Если ОбщегоНазначения.РазделениеВключено()
	 Или СтандартныеПодсистемыСервер.ЭтоБазоваяВерсияКонфигурации()
	 Или ОбщегоНазначения.ЭтоАвтономноеРабочееМесто()
	 Или Не ПользователиСлужебный.ВнешниеПользователиВнедрены() Тогда
	
		Элементы.ГруппаВнешниеПользователи.Видимость = Ложь;
		Элементы.ОписаниеРаздела.Заголовок =
			НСтр("ru = 'Администрирование пользователей, настройка групп доступа, управление пользовательскими настройками.';
				|en = 'Manage users, configure access groups, grant access to external users, and manage user settings.'");
	КонецЕсли;
	
	Если СтандартныеПодсистемыСервер.ЭтоБазоваяВерсияКонфигурации()
	 Или ОбщегоНазначения.ЭтоАвтономноеРабочееМесто() Тогда
		
		Элементы.ИспользоватьГруппыПользователей.Доступность = Ложь;
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.УправлениеДоступом") Тогда
		МодульУправлениеДоступомСлужебный = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступомСлужебный");
		УпрощенныйИнтерфейс = МодульУправлениеДоступомСлужебный.УпрощенныйИнтерфейсНастройкиПравДоступа();
		Элементы.ОткрытьГруппыДоступа.Видимость            = Не УпрощенныйИнтерфейс;
		Элементы.ИспользоватьГруппыПользователей.Видимость = Не УпрощенныйИнтерфейс;
		Элементы.ОграничиватьДоступНаУровнеЗаписейУниверсально.Видимость
			= МодульУправлениеДоступомСлужебный.ВариантВстроенногоЯзыкаРусский()
				И Пользователи.ЭтоПолноправныйПользователь(, Истина);
		Элементы.ОбновлениеДоступаНаУровнеЗаписей.Видимость =
			МодульУправлениеДоступомСлужебный.ОграничиватьДоступНаУровнеЗаписейУниверсально(Истина);
		
		Если ОбщегоНазначения.ЭтоАвтономноеРабочееМесто() Тогда
			Элементы.ОграничиватьДоступНаУровнеЗаписей.Доступность = Ложь;
		КонецЕсли;
	Иначе
		Элементы.ГруппаГруппыДоступа.Видимость = Ложь;
	КонецЕсли;
	
	Если Не ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ДатыЗапретаИзменения") Тогда
		Элементы.ГруппаДатыЗапретаИзменения.Видимость = Ложь;
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ЗащитаПерсональныхДанных") Тогда
		Элементы.ГруппаОткрытьНастройкиРегистрацииСобытийДоступаКПерсональнымДанным.Видимость =
			  Не ОбщегоНазначения.РазделениеВключено()
			И Пользователи.ЭтоПолноправныйПользователь(, Истина);
	Иначе
		Элементы.ГруппаЗащитаПерсональныхДанных.Видимость = Ложь;
	КонецЕсли;
	
	Если ОбщегоНазначения.РазделениеВключено()
		 Или Не ПользователиСлужебныйПовтИсп.ВерсияПредприятияПоддерживаетВосстановлениеПаролей() Тогда
			Элементы.ВосстановлениеПаролей.Видимость = Ложь;
	КонецЕсли;
	
	// Обновление состояния элементов.
	УстановитьДоступность();
	
	НастройкиПрограммыПереопределяемый.НастройкиПользователейИПравПриСозданииНаСервере(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	Если ЗавершениеРаботы Тогда
		Возврат;
	КонецЕсли;
	ОбновитьИнтерфейсПрограммы();
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия <> "Запись_НаборКонстант" Тогда
		Возврат;
	КонецЕсли;
	
	Если Источник = "ИспользоватьАнкетирование" 
		И ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.Анкетирование") Тогда
		
		Прочитать();
		УстановитьДоступность();
		
	ИначеЕсли Источник = "ИспользоватьСкрытиеПерсональныхДанныхСубъектов" Тогда
		Прочитать();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ИспользоватьГруппыПользователейПриИзменении(Элемент)
	Подключаемый_ПриИзмененииРеквизита(Элемент);
КонецПроцедуры

&НаКлиенте
Процедура ОграничиватьДоступНаУровнеЗаписейУниверсальноПриИзменении(Элемент)
	
	Если НаборКонстант.ОграничиватьДоступНаУровнеЗаписейУниверсально Тогда
		ТекстВопроса =
			НСтр("ru = 'Включить производительный вариант ограничения доступа?
			           |
			           |Включение произойдет после окончания первого обновления
			           |(см. ход по ссылке ""Обновление доступа на уровне записей"").';
			           |en = 'Do you want to enable the High-performance mode of access restriction?
			           |
			           |It will be applied after the first update
			           |(see “Update record-level access”).'");
	ИначеЕсли НаборКонстант.ОграничиватьДоступНаУровнеЗаписей Тогда
		ТекстВопроса =
			НСтр("ru = 'Выключить производительный вариант ограничения доступа?
			           |
			           |Потребуется заполнение данных, которое будет выполняться частями
			           |регламентным заданием ""Заполнение данных для ограничения доступа""
			           |(ход выполнения в журнале регистрации).';
			           |en = 'Do you want to disable the High-performance mode of access restriction?
			           |
			           |This requires data population that will be performed in batches by
			           |scheduled job ""Filling data to restrict access""
			           |(see the progress is in the Event Log).'");
	Иначе
		ТекстВопроса =
			НСтр("ru = 'Выключить производительный вариант ограничения доступа?
			           |
			           |Потребуется частичное заполнение данных, которое будет выполняться частями
			           |регламентным заданием ""Заполнение данных для ограничения доступа""
			           |(ход выполнения в журнале регистрации).';
			           |en = 'Do you want to disable the High-performance mod of access restriction?
			           |
			           |This requires data population that will be performed in batches
			           |by scheduled job ""Access restriction data population""
			           |(see the progress in the Event Log).'");
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ТекстВопроса) Тогда
		ПоказатьВопрос(
			Новый ОписаниеОповещения(
				"ОграничиватьДоступНаУровнеЗаписейУниверсальноПриИзмененииЗавершение",
				ЭтотОбъект, Элемент),
			ТекстВопроса, РежимДиалогаВопрос.ДаНет);
	Иначе
		ОграничиватьДоступНаУровнеЗаписейУниверсальноПриИзмененииЗавершение(КодВозвратаДиалога.Да, Элемент);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОграничиватьДоступНаУровнеЗаписейПриИзменении(Элемент)
	
	Если НаборКонстант.ОграничиватьДоступНаУровнеЗаписейУниверсально Тогда
		ТекстВопроса =
			НСтр("ru = 'Настройки групп доступа вступят в силу постепенно
			           |(см. ход по ссылке ""Обновление доступа на уровне записей"").
			           |
			           |Обновление доступа может замедлить работу программы и выполняться
			           |от нескольких секунд до часов (в зависимости от объема данных).';
			           |en = 'Access groups settings will take effect gradually
			           |(to view the progress, click ""View record-level access update progress"").
			           |
			           |This might slow down the application and take
			           |from seconds to a few hours depending on the data volume.'");
		Если НаборКонстант.ОграничиватьДоступНаУровнеЗаписей Тогда
			ТекстВопроса = НСтр("ru = 'Включить ограничение доступа на уровне записей?';
								|en = 'Do you want to enable record-level access restrictions?'")
				+ Символы.ПС + Символы.ПС + ТекстВопроса;
		Иначе
			ТекстВопроса = НСтр("ru = 'Выключить ограничение доступа на уровне записей?';
								|en = 'Do you want to disable record-level access restrictions?'")
				+ Символы.ПС + Символы.ПС + ТекстВопроса;
		КонецЕсли;
		
	ИначеЕсли НаборКонстант.ОграничиватьДоступНаУровнеЗаписей Тогда
		ТекстВопроса =
			НСтр("ru = 'Включить ограничение доступа на уровне записей?
			           |
			           |Потребуется заполнение данных, которое будет выполняться частями
			           |регламентным заданием ""Заполнение данных для ограничения доступа""
			           |(ход выполнения в журнале регистрации).
			           |
			           |Выполнение может сильно замедлить работу программы и выполняться
			           |от нескольких секунд до многих часов (в зависимости от объема данных).';
			           |en = 'Do you want to enable record-level access restriction?
			           |
			           |This requires data population that will be performed in batches
			           |by scheduled job ""Access restriction data population"" 
			           |(see the progress in the Event Log).
			           |
			           |The processing might slow down the application and take
			           |from seconds to a few hours depending on the data volume.'");
	Иначе
		ТекстВопроса = "";
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ТекстВопроса) Тогда
		ПоказатьВопрос(
			Новый ОписаниеОповещения(
				"ОграничиватьДоступНаУровнеЗаписейПриИзмененииЗавершение",
				ЭтотОбъект, Элемент),
			ТекстВопроса, РежимДиалогаВопрос.ДаНет);
	Иначе
		ОграничиватьДоступНаУровнеЗаписейПриИзмененииЗавершение(КодВозвратаДиалога.Да, Элемент);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ИспользоватьВнешнихПользователейПриИзменении(Элемент)
	
	Если НаборКонстант.ИспользоватьВнешнихПользователей Тогда
		
		ТекстВопроса =
			НСтр("ru = 'Разрешить доступ внешним пользователям?
			           |
			           |При входе в программу список выбора пользователей станет пустым
			           |(реквизит ""Показывать в списке выбора"" в карточках всех
			           | пользователей будет очищен и скрыт).';
			           |en = 'Do you want to allow external user access?
			           |
			           |The user list in the startup dialog will be cleared
			           |(attribute ""Show in choice list"" will be cleared and hidden from all user profiles).
			           |'");
		
		ПоказатьВопрос(
			Новый ОписаниеОповещения(
				"ИспользоватьВнешнихПользователейПриИзмененииЗавершение",
				ЭтотОбъект,
				Элемент),
			ТекстВопроса,
			РежимДиалогаВопрос.ДаНет);
	Иначе
		ТекстВопроса =
			НСтр("ru = 'Запретить доступ внешним пользователям?
			           |
			           |Реквизит ""Вход в программу разрешен"" будет
			           |очищен в карточках всех внешних пользователей.';
			           |en = 'Do you want to deny external user access?
			           |
			           |Attribute ""Can sign in"" will be cleared
			           |in all external user profiles.'");
		
		ПоказатьВопрос(
			Новый ОписаниеОповещения(
				"ИспользоватьВнешнихПользователейПриИзмененииЗавершение",
				ЭтотОбъект,
				Элемент),
			ТекстВопроса,
			РежимДиалогаВопрос.ДаНет);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура СправочникВнешниеПользователи(Команда)
	ОткрытьФорму("Справочник.ВнешниеПользователи.ФормаСписка", , ЭтотОбъект);
КонецПроцедуры

&НаКлиенте
Процедура НастройкиВходаВнешнихПользователей(Команда)
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ПоказатьНастройкиВнешнихПользователей", Истина);
	
	ОткрытьФорму("ОбщаяФорма.НастройкиВходаПользователей", ПараметрыФормы, ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновлениеДоступаНаУровнеЗаписей(Команда)
	
	ОткрытьФорму("РегистрСведений" + "." + "ОбновлениеКлючейДоступаКДанным" + "."
		+ "Форма" + "." + "ОбновлениеДоступаНаУровнеЗаписей");
	
КонецПроцедуры

&НаКлиенте
Процедура НастроитьДатыЗапретаИзменения(Команда)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.ДатыЗапретаИзменения") Тогда
		МодульДатыЗапретаИзмененияСлужебныйКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ДатыЗапретаИзмененияСлужебныйКлиент");
		МодульДатыЗапретаИзмененияСлужебныйКлиент.ОткрытьДатыЗапретаИзмененияДанных(ЭтотОбъект);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

////////////////////////////////////////////////////////////////////////////////
// Клиент

&НаКлиенте
Процедура Подключаемый_ПриИзмененииРеквизита(Элемент, ОбновлятьИнтерфейс = Истина)
	
	ИменаКонстант = ПриИзмененииРеквизитаСервер(Элемент.Имя);
	ОбновитьПовторноИспользуемыеЗначения();
	
	Если ОбновлятьИнтерфейс Тогда
		ОбновитьИнтерфейс = Истина;
		ПодключитьОбработчикОжидания("ОбновитьИнтерфейсПрограммы", 2, Истина);
	КонецЕсли;
	
	Для Каждого ИмяКонстанты Из ИменаКонстант Цикл
		Если ИмяКонстанты <> "" Тогда
			Оповестить("Запись_НаборКонстант", Новый Структура, ИмяКонстанты);
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_НастройкиСкрытияПДнПриИзменении(Элемент)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.ЗащитаПерсональныхДанных") Тогда
		МодульЗащитаПерсональныхДанныхКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ЗащитаПерсональныхДанныхКлиент");
		МодульЗащитаПерсональныхДанныхКлиент.НастройкиСкрытияПерсональныхДанныхПриИзменении(ЭтотОбъект);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьИнтерфейсПрограммы()
	
	Если ОбновитьИнтерфейс = Истина Тогда
		ОбновитьИнтерфейс = Ложь;
		ОбщегоНазначенияКлиент.ОбновитьИнтерфейсПрограммы();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОграничиватьДоступНаУровнеЗаписейУниверсальноПриИзмененииЗавершение(Ответ, Элемент) Экспорт
	
	Если Ответ = КодВозвратаДиалога.Нет Тогда
		НаборКонстант.ОграничиватьДоступНаУровнеЗаписейУниверсально
			= Не НаборКонстант.ОграничиватьДоступНаУровнеЗаписейУниверсально;
		Возврат;
	КонецЕсли;
	
	Подключаемый_ПриИзмененииРеквизита(Элемент);
	
	Элементы.ОбновлениеДоступаНаУровнеЗаписей.Видимость =
		НаборКонстант.ОграничиватьДоступНаУровнеЗаписейУниверсально;
	
КонецПроцедуры

&НаКлиенте
Процедура ОграничиватьДоступНаУровнеЗаписейПриИзмененииЗавершение(Ответ, Элемент) Экспорт
	
	Если Ответ = КодВозвратаДиалога.Нет Тогда
		НаборКонстант.ОграничиватьДоступНаУровнеЗаписей = Не НаборКонстант.ОграничиватьДоступНаУровнеЗаписей;
		Возврат;
	КонецЕсли;
	
	Подключаемый_ПриИзмененииРеквизита(Элемент);
	
	Если Не НаборКонстант.ОграничиватьДоступНаУровнеЗаписей Тогда
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ИспользоватьВнешнихПользователейПриИзмененииЗавершение(Ответ, Элемент) Экспорт
	
	Если Ответ = КодВозвратаДиалога.Нет Тогда
		НаборКонстант.ИспользоватьВнешнихПользователей = Не НаборКонстант.ИспользоватьВнешнихПользователей;
	Иначе
		Подключаемый_ПриИзмененииРеквизита(Элемент);
	КонецЕсли;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Вызов сервера

&НаСервере
Функция ПриИзмененииРеквизитаСервер(ИмяЭлемента)
	
	ИменаКонстант = Новый Массив;
	РеквизитПутьКДанным = Элементы[ИмяЭлемента].ПутьКДанным;
	
	НачатьТранзакцию();
	Попытка
		
		ИмяКонстанты = СохранитьЗначениеРеквизита(РеквизитПутьКДанным);
		ИменаКонстант.Добавить(ИмяКонстанты);
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
	УстановитьДоступность(РеквизитПутьКДанным);
	ОбновитьПовторноИспользуемыеЗначения();
	Возврат ИменаКонстант;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Сервер

&НаСервере
Функция СохранитьЗначениеРеквизита(РеквизитПутьКДанным)
	
	ЧастиИмени = СтрРазделить(РеквизитПутьКДанным, ".");
	Если ЧастиИмени.Количество() <> 2 Тогда
		Возврат "";
	КонецЕсли;
	
	ИмяКонстанты = ЧастиИмени[1];
	КонстантаМенеджер = Константы[ИмяКонстанты];
	КонстантаЗначение = НаборКонстант[ИмяКонстанты];
	ТекущееЗначение  = КонстантаМенеджер.Получить();
	Если ТекущееЗначение <> КонстантаЗначение Тогда
		Попытка
			КонстантаМенеджер.Установить(КонстантаЗначение);
		Исключение
			НаборКонстант[ИмяКонстанты] = ТекущееЗначение;
			ВызватьИсключение;
		КонецПопытки;
	КонецЕсли;
	
	Возврат ИмяКонстанты;
	
КонецФункции

&НаСервере
Процедура УстановитьДоступность(РеквизитПутьКДанным = "")
	
	Если РеквизитПутьКДанным = "НаборКонстант.ИспользоватьВнешнихПользователей"
	 Или РеквизитПутьКДанным = "" Тогда
		
		ИспользоватьВнешнихПользователей = НаборКонстант.ИспользоватьВнешнихПользователей;
		
		Элементы.ОткрытьВнешниеПользователи.Доступность         = ИспользоватьВнешнихПользователей;
		Элементы.НастройкиВходаВнешнихПользователей.Доступность = ИспользоватьВнешнихПользователей;
		
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ДатыЗапретаИзменения")
		И (РеквизитПутьКДанным = "НаборКонстант.ИспользоватьДатыЗапретаИзменения"
		Или РеквизитПутьКДанным = "") Тогда
		
		Элементы.НастроитьДатыЗапретаИзменения.Доступность = НаборКонстант.ИспользоватьДатыЗапретаИзменения;
	КонецЕсли;
	
	
	
КонецПроцедуры

#КонецОбласти
