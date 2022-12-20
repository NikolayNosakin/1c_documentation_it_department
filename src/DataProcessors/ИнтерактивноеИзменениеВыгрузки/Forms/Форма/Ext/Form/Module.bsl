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
	
	Если НЕ Параметры.Свойство("ОткрытаПоСценарию") Тогда
		ВызватьИсключение НСтр("ru = 'Обработка не предназначена для непосредственного использования.';
								|en = 'The data processor cannot be opened manually.'");
	КонецЕсли;
	
	ЭтаОбработка = ЭтотОбъект();
	Если ПустаяСтрока(Параметры.АдресОбъекта) Тогда
		ЭтотОбъект( ЭтаОбработка.ИнициализироватьЭтотОбъект(Параметры.НастройкиОбъекта) );
	Иначе
		ЭтотОбъект( ЭтаОбработка.ИнициализироватьЭтотОбъект(Параметры.АдресОбъекта) );
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Объект.УзелИнформационнойБазы) Тогда
		Текст = НСтр("ru = 'Настройка обмена данными не найдена.';
					|en = 'The data exchange setting is not found.'");
		ОбменДаннымиСервер.СообщитьОбОшибке(Текст, Отказ);
		Возврат;
	КонецЕсли;
	
	Заголовок = Заголовок + " (" + Объект.УзелИнформационнойБазы + ")";
	БазовоеИмяДляФормы = ЭтаОбработка.БазовоеИмяДляФормы();
	
	ПредставлениеТекущейНастройки = "";
	Элементы.НастройкиОтборов.Видимость = ПравоДоступа("СохранениеДанныхПользователя", Метаданные);
	
	СброситьНадписьКоличествТаблицы();
	ОбновитьНадписьОбщегоКоличества();
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	Если ЗавершениеРаботы Тогда
		Возврат;
	КонецЕсли;
	ОстановитьРасчетКоличества();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ДополнительнаяРегистрацияВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	Если Поле <> Элементы.ДополнительнаяРегистрацияОтборСтрокой Тогда
		Возврат;
	КонецЕсли;
	
	СтандартнаяОбработка = Ложь;
	ТекущиеДанные = Элементы.ДополнительнаяРегистрация.ТекущиеДанные;
	
	ИмяОткрываемойФормы = БазовоеИмяДляФормы + "Форма.РедактированиеПериодаИОтбора";
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("Заголовок",           ТекущиеДанные.Представление);
	ПараметрыФормы.Вставить("ДействиеВыбора",      - Элементы.ДополнительнаяРегистрация.ТекущаяСтрока);
	ПараметрыФормы.Вставить("ВыборПериода",        ТекущиеДанные.ВыборПериода);
	ПараметрыФормы.Вставить("КомпоновщикНастроек", КомпоновщикНастроекПоИмениТаблицы(ТекущиеДанные.ПолноеИмяМетаданных, ТекущиеДанные.Представление, ТекущиеДанные.Отбор));
	ПараметрыФормы.Вставить("ПериодДанных",        ТекущиеДанные.Период);
	
	ПараметрыФормы.Вставить("АдресХранилищаФормы", УникальныйИдентификатор);
	
	ОткрытьФорму(ИмяОткрываемойФормы, ПараметрыФормы, Элементы.ДополнительнаяРегистрация);
КонецПроцедуры

&НаКлиенте
Процедура ДополнительнаяРегистрацияПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	Отказ = Истина;
	Если Копирование Тогда
		Возврат;
	КонецЕсли;
	
	ОткрытьФорму(БазовоеИмяДляФормы + "Форма.ВыборВидаОбъектаСоставаУзла",
		Новый Структура("УзелИнформационнойБазы", Объект.УзелИнформационнойБазы),
		Элементы.ДополнительнаяРегистрация);
КонецПроцедуры

&НаКлиенте
Процедура ДополнительнаяРегистрацияПередУдалением(Элемент, Отказ)
	Выделенные = Элементы.ДополнительнаяРегистрация.ВыделенныеСтроки;
	Количество = Выделенные.Количество();
	Если Количество>1 Тогда
		ТекстПредставления = НСтр("ru = 'выбранные строки';
									|en = 'the selected lines'");
	ИначеЕсли Количество=1 Тогда
		ТекстПредставления = Элементы.ДополнительнаяРегистрация.ТекущиеДанные.Представление;
	Иначе
		Возврат;
	КонецЕсли;
	
	// Действие будет произведено из подтверждения.
	Отказ = Истина;
	
	ТекстВопроса = НСтр("ru = 'Удалить из дополнительных данных %1 ?';
						|en = 'Do you want to delete %1 from the additional data?'");    
	ТекстВопроса = СтрЗаменить(ТекстВопроса, "%1", ТекстПредставления);
	
	ЗаголовокВопроса = НСтр("ru = 'Подтверждение';
							|en = 'Confirm operation'");
	
	Оповещение = Новый ОписаниеОповещения("ДополнительнаяРегистрацияПередУдалениемЗавершение", ЭтотОбъект, Новый Структура);
	Оповещение.ДополнительныеПараметры.Вставить("ВыделенныеСтроки", Выделенные);
	
	ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНет, , ,ЗаголовокВопроса);
КонецПроцедуры

&НаКлиенте
Процедура ДополнительнаяРегистрацияОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	
	ТипВыбранного = ТипЗнч(ВыбранноеЗначение);
	Если ТипВыбранного=Тип("Массив") Тогда
		// Добавление новой строки
		Элементы.ДополнительнаяРегистрация.ТекущаяСтрока = ДобавлениеСтрокиВДополнительныйСоставСервер(ВыбранноеЗначение);
		
	ИначеЕсли ТипВыбранного= Тип("Структура") Тогда
		Если ВыбранноеЗначение.ДействиеВыбора=3 Тогда
			// Восстановление настроек
			ПредставлениеНастройки = ВыбранноеЗначение.ПредставлениеНастройки;
			Если Не ПустаяСтрока(ПредставлениеТекущейНастройки) И ПредставлениеНастройки<>ПредставлениеТекущейНастройки Тогда
				ТекстВопроса  = НСтр("ru = 'Восстановить настройки ""%1""?';
									|en = 'Do you want to restore ""%1"" settings?'");
				ТекстВопроса  = СтрЗаменить(ТекстВопроса, "%1", ПредставлениеНастройки);
				ТекстЗаголовка = НСтр("ru = 'Подтверждение';
										|en = 'Confirm operation'");
				
				Оповещение = Новый ОписаниеОповещения("ДополнительнаяРегистрацияОбработкаВыбораЗавершение", ЭтотОбъект, Новый Структура);
				Оповещение.ДополнительныеПараметры.Вставить("ПредставлениеНастройки", ПредставлениеНастройки);
				
				ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНет, , , ТекстЗаголовка);
			Иначе
				ПредставлениеТекущейНастройки = ПредставлениеНастройки;
			КонецЕсли;
		Иначе
			// Редактирование условия отбора, отрицательный номер строки.
			Элементы.ДополнительнаяРегистрация.ТекущаяСтрока = РедактированиеОтбораСтрокиДополнительныйСоставСервер(ВыбранноеЗначение);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ДополнительнаяРегистрацияПослеУдаления(Элемент)
	ОбновитьНадписьОбщегоКоличества();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ПодтвердитьВыбор(Команда)
	ОповеститьОВыборе( РезультатВыбораСервер() );
КонецПроцедуры

&НаКлиенте
Процедура ПоказатьТекстОбщихПараметров(Команда)
	ОткрытьФорму(БазовоеИмяДляФормы +  "Форма.ОбщиеПараметрыСинхронизации",
		Новый Структура("УзелИнформационнойБазы", Объект.УзелИнформационнойБазы));
КонецПроцедуры

&НаКлиенте
Процедура СоставВыгрузки(Команда)
	ОткрытьФорму(БазовоеИмяДляФормы + "Форма.СоставВыгрузки",
		Новый Структура("АдресОбъекта", АдресОбъектаДополнительнойВыгрузки() ));
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьКоличествоКлиент(Команда)
	
	Результат = ОбновитьКоличествоСервер();
	
	Если Результат.Статус = "Выполняется" Тогда
		
		Элементы.КартинкаРасчетаКоличества.Видимость = Истина;
		
		ПараметрыОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
		ПараметрыОжидания.ВыводитьОкноОжидания  = Ложь;
		ПараметрыОжидания.ВыводитьСообщения     = Истина;
		
		ОповещениеОЗавершении = Новый ОписаниеОповещения("ЗавершениеФоновогоЗадания", ЭтотОбъект);
		ДлительныеОперацииКлиент.ОжидатьЗавершение(Результат, ОповещениеОЗавершении, ПараметрыОжидания);
		
	Иначе
		ПодключитьОбработчикОжидания("ЗагрузитьЗначенияКоличествКлиент", 1, Истина);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура НастройкиОтборов(Команда)
	
	// Выбор из меню - списка
	СписокВариантов = ПрочитатьСписокВариантовНастроекСервер();
	
	Текст = НСтр("ru = 'Сохранить текущую настройку...';
				|en = 'Save current setting…'");
	СписокВариантов.Добавить(1, Текст, , БиблиотекаКартинок.СохранитьНастройкиОтчета);
	
	Оповещение = Новый ОписаниеОповещения("НастройкиОтборовВыборВариантаЗавершение", ЭтотОбъект);
	
	ПоказатьВыборИзМеню(Оповещение, СписокВариантов, Элементы.НастройкиОтборов);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ЗагрузитьЗначенияКоличествКлиент()
	Элементы.КартинкаРасчетаКоличества.Видимость = Ложь;
	ЗагрузитьЗначенияКоличествСервер();
КонецПроцедуры

&НаКлиенте
Процедура ЗавершениеФоновогоЗадания(Результат, ДополнительныеПараметры) Экспорт
	ЗагрузитьЗначенияКоличествКлиент();
КонецПроцедуры

&НаКлиенте
Процедура НастройкиОтборовВыборВариантаЗавершение(Знач ВыбранныйЭлемент, Знач ДополнительныеПараметры) Экспорт
	Если ВыбранныйЭлемент = Неопределено Тогда
		Возврат;
	КонецЕсли;
		
	ПредставлениеНастройки = ВыбранныйЭлемент.Значение;
	Если ТипЗнч(ПредставлениеНастройки)=Тип("Строка") Тогда
		ТекстЗаголовка = НСтр("ru = 'Подтверждение';
								|en = 'Confirm operation'");
		ТекстВопроса   = НСтр("ru = 'Восстановить настройки ""%1""?';
								|en = 'Do you want to restore ""%1"" settings?'");
		ТекстВопроса   = СтрЗаменить(ТекстВопроса, "%1", ПредставлениеНастройки);
		
		Оповещение = Новый ОписаниеОповещения("НастройкиОтборовЗавершение", ЭтотОбъект, Новый Структура);
		Оповещение.ДополнительныеПараметры.Вставить("ПредставлениеНастройки", ПредставлениеНастройки);
		
		ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНет, , , ТекстЗаголовка);
		
	ИначеЕсли ПредставлениеНастройки=1 Тогда
		
		// Форма всех настроек.
		
		ПараметрыФормыНастроек = Новый Структура;
		ПараметрыФормыНастроек.Вставить("ЗакрыватьПриВыборе", Истина);
		ПараметрыФормыНастроек.Вставить("ДействиеВыбора", 3);
		ПараметрыФормыНастроек.Вставить("Объект", Объект);
		ПараметрыФормыНастроек.Вставить("ПредставлениеТекущейНастройки", ПредставлениеТекущейНастройки);
		
		ИмяФормыНастроек = БазовоеИмяДляФормы + "Форма.РедактированиеСоставаНастроек";
		
		ОткрытьФорму(ИмяФормыНастроек, ПараметрыФормыНастроек, Элементы.ДополнительнаяРегистрация);
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура НастройкиОтборовЗавершение(Знач РезультатВопроса, Знач ДополнительныеПараметры) Экспорт
	Если РезультатВопроса <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьНастройкиСервер(ДополнительныеПараметры.ПредставлениеНастройки);
КонецПроцедуры

&НаКлиенте
Процедура ДополнительнаяРегистрацияОбработкаВыбораЗавершение(Знач РезультатВопроса, Знач ДополнительныеПараметры) Экспорт
	Если РезультатВопроса <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьНастройкиСервер(ДополнительныеПараметры.ПредставлениеНастройки);
КонецПроцедуры

&НаКлиенте
Процедура ДополнительнаяРегистрацияПередУдалениемЗавершение(Знач РезультатВопроса, Знач ДополнительныеПараметры) Экспорт
	Если РезультатВопроса <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
	
	ТаблицаУдаления = Объект.ДополнительнаяРегистрация;
	ПодлежитУдалению = Новый Массив;
	Для Каждого ИдентификаторСтроки Из ДополнительныеПараметры.ВыделенныеСтроки Цикл
		УдаляемаяСтрока = ТаблицаУдаления.НайтиПоИдентификатору(ИдентификаторСтроки);
		Если УдаляемаяСтрока<>Неопределено Тогда
			ПодлежитУдалению.Добавить(УдаляемаяСтрока);
		КонецЕсли;
	КонецЦикла;
	Для Каждого УдаляемаяСтрока Из ПодлежитУдалению Цикл
		ТаблицаУдаления.Удалить(УдаляемаяСтрока);
	КонецЦикла;
	
	ОбновитьНадписьОбщегоКоличества();
КонецПроцедуры

&НаСервере
Функция РезультатВыбораСервер()
	ОбъектРезультат = Новый Структура("УзелИнформационнойБазы, ВариантВыгрузки, КомпоновщикОтбораВсехДокументов, ПериодОтбораВсехДокументов");
	ЗаполнитьЗначенияСвойств(ОбъектРезультат, Объект);
	
	ОбъектРезультат.Вставить("ДополнительнаяРегистрация", 
		ТаблицаВМассивСтруктур( РеквизитФормыВЗначение("Объект.ДополнительнаяРегистрация")) );
	
	Возврат Новый Структура("ДействиеВыбора, АдресОбъекта", 
		Параметры.ДействиеВыбора, ПоместитьВоВременноеХранилище(ОбъектРезультат, УникальныйИдентификатор));
КонецФункции

&НаСервере
Функция ТаблицаВМассивСтруктур(Знач ТаблицаЗначений)
	Результат = Новый Массив;
	
	ИменаКолонок = "";
	Для Каждого Колонка Из ТаблицаЗначений.Колонки Цикл
		ИменаКолонок = ИменаКолонок + "," + Колонка.Имя;
	КонецЦикла;
	ИменаКолонок = Сред(ИменаКолонок, 2);
	
	Для Каждого Строка Из ТаблицаЗначений Цикл
		СтруктураСтроки = Новый Структура(ИменаКолонок);
		ЗаполнитьЗначенияСвойств(СтруктураСтроки, Строка);
		Результат.Добавить(СтруктураСтроки);
	КонецЦикла;
	
	Возврат Результат;
КонецФункции

&НаСервере
Функция ЭтотОбъект(НовыйОбъект = Неопределено)
	Если НовыйОбъект=Неопределено Тогда
		Возврат РеквизитФормыВЗначение("Объект");
	КонецЕсли;
	ЗначениеВРеквизитФормы(НовыйОбъект, "Объект");
	Возврат Неопределено;
КонецФункции

&НаСервере
Функция ДобавлениеСтрокиВДополнительныйСоставСервер(МассивВыбора)
	
	Если МассивВыбора.Количество()=1 Тогда
		Строка = ДобавитьВДополнительныйСоставВыгрузки(МассивВыбора[0]);
	Иначе
		Строка = Неопределено;
		Для Каждого ЭлементВыбора Из МассивВыбора Цикл
			ТестСтрока = ДобавитьВДополнительныйСоставВыгрузки(ЭлементВыбора);
			Если Строка=Неопределено Тогда
				Строка = ТестСтрока;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	Возврат Строка;
КонецФункции

&НаСервере 
Функция РедактированиеОтбораСтрокиДополнительныйСоставСервер(СтруктураВыбора)
	
	ТекущиеДанные = Объект.ДополнительнаяРегистрация.НайтиПоИдентификатору(-СтруктураВыбора.ДействиеВыбора);
	Если ТекущиеДанные=Неопределено Тогда
		Возврат Неопределено
	КонецЕсли;
	
	ТекущиеДанные.Период       = СтруктураВыбора.ПериодДанных;
	ТекущиеДанные.Отбор        = СтруктураВыбора.КомпоновщикНастроек.Настройки.Отбор;
	ТекущиеДанные.ОтборСтрокой = ПредставлениеОтбора(ТекущиеДанные.Период, ТекущиеДанные.Отбор);
	ТекущиеДанные.Количество   = НСтр("ru = 'Не рассчитано';
										|en = 'Not calculated'");
	
	ОбновитьНадписьОбщегоКоличества();
	
	Возврат СтруктураВыбора.ДействиеВыбора;
КонецФункции

&НаСервере
Функция ДобавитьВДополнительныйСоставВыгрузки(Элемент)
	
	СуществующиеСтроки = Объект.ДополнительнаяРегистрация.НайтиСтроки( 
		Новый Структура("ПолноеИмяМетаданных", Элемент.ПолноеИмяМетаданных));
	Если СуществующиеСтроки.Количество()>0 Тогда
		Строка = СуществующиеСтроки[0];
	Иначе
		Строка = Объект.ДополнительнаяРегистрация.Добавить();
		ЗаполнитьЗначенияСвойств(Строка, Элемент,,"Представление");
		
		Строка.Представление = Элемент.ПредставлениеСписка;
		Строка.ОтборСтрокой  = ПредставлениеОтбора(Строка.Период, Строка.Отбор);
		Объект.ДополнительнаяРегистрация.Сортировать("Представление");
		
		Строка.Количество = НСтр("ru = 'Не рассчитано';
								|en = 'Not calculated'");
		ОбновитьНадписьОбщегоКоличества();
	КонецЕсли;
	
	Возврат Строка.ПолучитьИдентификатор();
КонецФункции

&НаСервере
Функция ПредставлениеОтбора(Период, Отбор)
	Возврат ЭтотОбъект().ПредставлениеОтбора(Период, Отбор);
КонецФункции

&НаСервере
Функция КомпоновщикНастроекПоИмениТаблицы(ИмяТаблицы, Представление, Отбор)
	Возврат ЭтотОбъект().КомпоновщикНастроекПоИмениТаблицы(ИмяТаблицы, Представление, Отбор, УникальныйИдентификатор);
КонецФункции

&НаСервере
Процедура ОстановитьРасчетКоличества()
	
	ДлительныеОперации.ОтменитьВыполнениеЗадания(ИдентификаторФоновогоЗадания);
	Если Не ПустаяСтрока(АдресРезультатаФоновогоЗадания) Тогда
		УдалитьИзВременногоХранилища(АдресРезультатаФоновогоЗадания);
	КонецЕсли;
	
	АдресРезультатаФоновогоЗадания = "";
	ИдентификаторФоновогоЗадания   = Неопределено;
	
КонецПроцедуры

&НаСервере
Функция ОбновитьКоличествоСервер()
	
	ОстановитьРасчетКоличества();
	
	ПараметрыЗадания = Новый Структура;
	ПараметрыЗадания.Вставить("СтруктураОбработки", ЭтотОбъект().ЭтотОбъектВСтруктуруДляФонового());
	
	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияВФоне(УникальныйИдентификатор);
	ПараметрыВыполнения.НаименованиеФоновогоЗадания = 
		НСтр("ru = 'Расчет количества объектов для отправки при синхронизации';
			|en = 'Calculate the number of objects to send during synchronization'");

	РезультатЗапускаФоновогоЗадания = ДлительныеОперации.ВыполнитьВФоне(
		"ОбменДаннымиСервер.ИнтерактивноеИзменениеВыгрузки_СформироватьДеревоЗначений",
		ПараметрыЗадания,
		ПараметрыВыполнения);
		
	ИдентификаторФоновогоЗадания   = РезультатЗапускаФоновогоЗадания.ИдентификаторЗадания;
	АдресРезультатаФоновогоЗадания = РезультатЗапускаФоновогоЗадания.АдресРезультата;
	
	Возврат РезультатЗапускаФоновогоЗадания;
	
КонецФункции

&НаСервере
Процедура ЗагрузитьЗначенияКоличествСервер()
	
	ДеревоКоличеств = Неопределено;
	Если Не ПустаяСтрока(АдресРезультатаФоновогоЗадания) Тогда
		ДеревоКоличеств = ПолучитьИзВременногоХранилища(АдресРезультатаФоновогоЗадания);
		УдалитьИзВременногоХранилища(АдресРезультатаФоновогоЗадания);
	КонецЕсли;
	Если ТипЗнч(ДеревоКоличеств) <> Тип("ДеревоЗначений") Тогда
		ДеревоКоличеств = Новый ДеревоЗначений;
	КонецЕсли;
	
	Если ДеревоКоличеств.Строки.Количество() = 0 Тогда
		ОбновитьНадписьОбщегоКоличества(Неопределено);
		Возврат;
	КонецЕсли;
	
	ЭтаОбработка = ЭтотОбъект();
	
	СтрокиКоличеств = ДеревоКоличеств.Строки;
	Для Каждого Строка Из Объект.ДополнительнаяРегистрация Цикл
		
		КоличествоВсего = 0;
		КоличествоВыгружать = 0;
		СоставСтроки = ЭтаОбработка.СоставУкрупненнойГруппыМетаданных(Строка.ПолноеИмяМетаданных);
		Для Каждого ИмяТаблицы Из СоставСтроки Цикл
			СтрокаДанных = СтрокиКоличеств.Найти(ИмяТаблицы, "ПолноеИмяМетаданных", Ложь);
			Если СтрокаДанных <> Неопределено Тогда
				КоличествоВыгружать = КоличествоВыгружать + СтрокаДанных.КоличествоДляВыгрузки;
				КоличествоВсего     = КоличествоВсего     + СтрокаДанных.ОбщееКоличество;
			КонецЕсли;
		КонецЦикла;
		
		Строка.Количество = Формат(КоличествоВыгружать, "ЧН=") + " / " + Формат(КоличествоВсего, "ЧН=");
	КонецЦикла;
	
	// Общие итоги
	СтрокаДанных = СтрокиКоличеств.Найти(Неопределено, "ПолноеИмяМетаданных", Ложь);
	ОбновитьНадписьОбщегоКоличества(?(СтрокаДанных = Неопределено, Неопределено, СтрокаДанных.КоличествоДляВыгрузки));
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьНадписьОбщегоКоличества(Количество = Неопределено) 
	
	ОстановитьРасчетКоличества();
	
	Если Количество = Неопределено Тогда
		ТекстКоличества = НСтр("ru = '<не рассчитано>';
								|en = '<not calculated>'");
	Иначе
		ТекстКоличества = НСтр("ru = 'Объектов: %1';
								|en = 'Objects: %1'");
		ТекстКоличества = СтрЗаменить(ТекстКоличества, "%1", Формат(Количество, "ЧН="));
	КонецЕсли;
	
	Элементы.ОбновитьКоличество.Заголовок  = ТекстКоличества;
КонецПроцедуры

&НаСервере
Процедура СброситьНадписьКоличествТаблицы()
	ТекстКоличеств = НСтр("ru = 'Не рассчитано';
							|en = 'Not calculated'");
	Для Каждого Строка Из Объект.ДополнительнаяРегистрация Цикл
		Строка.Количество = ТекстКоличеств;
	КонецЦикла;
	Элементы.КартинкаРасчетаКоличества.Видимость = Ложь;
КонецПроцедуры

&НаСервере
Функция ПрочитатьСписокВариантовНастроекСервер()
	ФильтрВариантов = Новый Массив;
	ФильтрВариантов.Добавить(Объект.ВариантВыгрузки);
	
	Возврат ЭтотОбъект().ПрочитатьПредставленияСпискаНастроек(Объект.УзелИнформационнойБазы, ФильтрВариантов);
КонецФункции

&НаСервере
Процедура УстановитьНастройкиСервер(ПредставлениеНастройки)
	
	НеизменныеДанные = Новый Структура("УзелИнформационнойБазы, ВариантВыгрузки, КомпоновщикОтбораВсехДокументов, ПериодОтбораВсехДокументов");
	ЗаполнитьЗначенияСвойств(НеизменныеДанные, Объект);
	
	ЭтаОбработка = ЭтотОбъект();
	ЭтаОбработка.ВосстановитьТекущееИзНастроек(ПредставлениеНастройки);
	ЭтотОбъект(ЭтаОбработка);
	
	ЗаполнитьЗначенияСвойств(Объект, НеизменныеДанные);
	
	СброситьНадписьКоличествТаблицы();
	ОбновитьНадписьОбщегоКоличества();
КонецПроцедуры

&НаСервере
Функция АдресОбъектаДополнительнойВыгрузки()
	Возврат ЭтотОбъект().СохранитьЭтотОбъект(УникальныйИдентификатор);
КонецФункции

#КонецОбласти
