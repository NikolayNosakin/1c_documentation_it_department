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
	
	Параметры.Свойство("Префикс", НовыйПрефиксИБ);
	
	Элементы.АктивныеПользователи.Видимость = 
		ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ЗавершениеРаботыПользователей");
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	// Устанавливаем текущую таблицу переходов.
	ЗаполнитьТаблицуПереходов();
	
	// Позиционируемся на первом шаге помощника.
	УстановитьПорядковыйНомерПерехода(1);
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)

	Если Элементы.ПанельОсновная.ТекущаяСтраница = Элементы.СтраницаОжидание Тогда
	
		ТекстПредупреждения = НСтр("ru = 'Отменить перенумерацию?';
									|en = 'Undo renumbering?'");
		ОбщегоНазначенияКлиент.ПоказатьПодтверждениеЗакрытияПроизвольнойФормы(
			ЭтотОбъект, Отказ, ЗавершениеРаботы, ТекстПредупреждения, "ЗакрытьФормуБезусловно");
			
	КонецЕсли;	
	
КонецПроцедуры

#КонецОбласти 

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура КомандаДалее(Команда)

	ИзменитьПрефиксВМонопольномРежиме = Ложь;
	ИзменитьПорядковыйНомерПерехода(+1);
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаНазад(Команда)
	
	ИзменитьПорядковыйНомерПерехода(-1);
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаВНачало(Команда)
	
    ИзменитьПорядковыйНомерПерехода(-2);
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаГотово(Команда)
	
	ЗакрытьФормуБезусловно = Истина;
	
	Закрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаОтмена(Команда)
	
	Закрыть();
	
КонецПроцедуры
	
&НаКлиенте
Процедура ПовторитьВМонопольномРежиме(Команда)
	
	ИзменитьПрефиксВМонопольномРежиме = Истина;
	ИзменитьПорядковыйНомерПерехода(-1);
	
КонецПроцедуры

&НаКлиенте
Процедура АктивныеПользователи(Команда)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.ЗавершениеРаботыПользователей") Тогда
		
		ИмяФормыАктивныеПользователи = "АктивныеПользователи.Форма.АктивныеПользователи";
		ОткрытьФорму("Обработка." + ИмяФормыАктивныеПользователи, , , , , , , РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
		
	КонецЕсли;

КонецПроцедуры

#КонецОбласти


#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ИзменитьПорядковыйНомерПерехода(Итератор)
	
	ОчиститьСообщения();
	
	УстановитьПорядковыйНомерПерехода(ПорядковыйНомерПерехода + Итератор);
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьПорядковыйНомерПерехода(Знач Значение)
	
	ЭтоПереходДалее = (Значение > ПорядковыйНомерПерехода);
	
	ПорядковыйНомерПерехода = Значение;
	
	Если ПорядковыйНомерПерехода < 0 Тогда
		
		ПорядковыйНомерПерехода = 0;
		
	КонецЕсли;
	
	ПорядковыйНомерПереходаПриИзменении(ЭтоПереходДалее);
	
КонецПроцедуры

&НаКлиенте
Процедура ПорядковыйНомерПереходаПриИзменении(Знач ЭтоПереходДалее)
	
	// Выполняем обработчики событий перехода.
	ВыполнитьОбработчикиСобытийПерехода(ЭтоПереходДалее);
	
	// Устанавливаем отображение страниц.
	СтрокиПереходаТекущие = ТаблицаПереходов.НайтиСтроки(Новый Структура("ПорядковыйНомерПерехода", ПорядковыйНомерПерехода));
	
	Если СтрокиПереходаТекущие.Количество() = 0 Тогда
		ВызватьИсключение НСтр("ru = 'Не определена страница для отображения.';
								|en = 'The page to display is not specified.'");
	КонецЕсли;
	
	СтрокаПереходаТекущая = СтрокиПереходаТекущие[0];
	
	Элементы.ПанельОсновная.ТекущаяСтраница  = Элементы[СтрокаПереходаТекущая.ИмяОсновнойСтраницы];
	Элементы.ПанельНавигации.ТекущаяСтраница = Элементы[СтрокаПереходаТекущая.ИмяСтраницыНавигации];
	
	Если Не ПустаяСтрока(СтрокаПереходаТекущая.ИмяСтраницыДекорации) Тогда
		
		Элементы.ПанельДекорации.ТекущаяСтраница = Элементы[СтрокаПереходаТекущая.ИмяСтраницыДекорации];
		
	КонецЕсли;
	
	// Устанавливаем текущую кнопку по умолчанию.
	КнопкаДалее = ПолучитьКнопкуФормыПоИмениКоманды(Элементы.ПанельНавигации.ТекущаяСтраница, "КомандаДалее");
	
	Если КнопкаДалее <> Неопределено Тогда
		
		КнопкаДалее.КнопкаПоУмолчанию = Истина;
		
	Иначе
		
		КнопкаГотово = ПолучитьКнопкуФормыПоИмениКоманды(Элементы.ПанельНавигации.ТекущаяСтраница, "КомандаГотово");
		
		Если КнопкаГотово <> Неопределено Тогда
			
			КнопкаГотово.КнопкаПоУмолчанию = Истина;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Если ЭтоПереходДалее И СтрокаПереходаТекущая.ДлительнаяОперация Тогда
		
		ПодключитьОбработчикОжидания("ВыполнитьОбработчикДлительнойОперации", 0.1, Истина);
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьОбработчикиСобытийПерехода(Знач ЭтоПереходДалее)
	
	// Обработчики событий переходов.
	Если ЭтоПереходДалее Тогда
		
		СтрокиПерехода = ТаблицаПереходов.НайтиСтроки(Новый Структура("ПорядковыйНомерПерехода", ПорядковыйНомерПерехода - 1));
		
		Если СтрокиПерехода.Количество() > 0 Тогда
			
			СтрокаПерехода = СтрокиПерехода[0];
			
			// Обработчик ПриПереходеДалее.
			Если Не ПустаяСтрока(СтрокаПерехода.ИмяОбработчикаПриПереходеДалее)
				И Не СтрокаПерехода.ДлительнаяОперация Тогда
				
				ИмяПроцедуры = "[ИмяОбработчика](Отказ)";
				ИмяПроцедуры = СтрЗаменить(ИмяПроцедуры, "[ИмяОбработчика]", СтрокаПерехода.ИмяОбработчикаПриПереходеДалее);
				
				Отказ = Ложь;
				
				Результат = Вычислить(ИмяПроцедуры);
				
				Если Отказ Тогда
					
					ПорядковыйНомерПерехода = ПорядковыйНомерПерехода - 1;
					Возврат;
					
				КонецЕсли;
				
			КонецЕсли;
			
		КонецЕсли;
		
	Иначе
		
		СтрокиПерехода = ТаблицаПереходов.НайтиСтроки(Новый Структура("ПорядковыйНомерПерехода", ПорядковыйНомерПерехода + 1));
		
		Если СтрокиПерехода.Количество() > 0 Тогда
			
			СтрокаПерехода = СтрокиПерехода[0];
			
			// Обработчик ПриПереходеНазад.
			Если Не ПустаяСтрока(СтрокаПерехода.ИмяОбработчикаПриПереходеНазад)
				И Не СтрокаПерехода.ДлительнаяОперация Тогда
				
				ИмяПроцедуры = "[ИмяОбработчика](Отказ)";
				ИмяПроцедуры = СтрЗаменить(ИмяПроцедуры, "[ИмяОбработчика]", СтрокаПерехода.ИмяОбработчикаПриПереходеНазад);
				
				Отказ = Ложь;
				
				Результат = Вычислить(ИмяПроцедуры);
				
				Если Отказ Тогда
					
					ПорядковыйНомерПерехода = ПорядковыйНомерПерехода + 1;
					Возврат;
					
				КонецЕсли;
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
	СтрокиПереходаТекущие = ТаблицаПереходов.НайтиСтроки(Новый Структура("ПорядковыйНомерПерехода", ПорядковыйНомерПерехода));
	
	Если СтрокиПереходаТекущие.Количество() = 0 Тогда
		ВызватьИсключение НСтр("ru = 'Не определена страница для отображения.';
								|en = 'The page to display is not specified.'");
	КонецЕсли;
	
	СтрокаПереходаТекущая = СтрокиПереходаТекущие[0];
	
	Если СтрокаПереходаТекущая.ДлительнаяОперация И Не ЭтоПереходДалее Тогда
		
		УстановитьПорядковыйНомерПерехода(ПорядковыйНомерПерехода - 1);
		Возврат;
	КонецЕсли;
	
	// обработчик ПриОткрытии
	Если Не ПустаяСтрока(СтрокаПереходаТекущая.ИмяОбработчикаПриОткрытии) Тогда
		
		ИмяПроцедуры = "[ИмяОбработчика](Отказ, ПропуститьСтраницу, ЭтоПереходДалее)";
		ИмяПроцедуры = СтрЗаменить(ИмяПроцедуры, "[ИмяОбработчика]", СтрокаПереходаТекущая.ИмяОбработчикаПриОткрытии);
		
		Отказ = Ложь;
		ПропуститьСтраницу = Ложь;
		
		Результат = Вычислить(ИмяПроцедуры);
		
		Если Отказ Тогда
			
			ПорядковыйНомерПерехода = ПорядковыйНомерПерехода - 1;
			Возврат;
			
		ИначеЕсли ПропуститьСтраницу Тогда
			
			Если ЭтоПереходДалее Тогда
				
				УстановитьПорядковыйНомерПерехода(ПорядковыйНомерПерехода + 1);
				Возврат;
				
			Иначе
				
				УстановитьПорядковыйНомерПерехода(ПорядковыйНомерПерехода - 1);
				Возврат;
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьОбработчикДлительнойОперации()
	
	СтрокиПереходаТекущие = ТаблицаПереходов.НайтиСтроки(Новый Структура("ПорядковыйНомерПерехода", ПорядковыйНомерПерехода));
	
	Если СтрокиПереходаТекущие.Количество() = 0 Тогда
		ВызватьИсключение НСтр("ru = 'Не определена страница для отображения.';
								|en = 'The page to display is not specified.'");
	КонецЕсли;
	
	СтрокаПереходаТекущая = СтрокиПереходаТекущие[0];
	
	// Обработчик ОбработкаДлительнойОперации.
	Если Не ПустаяСтрока(СтрокаПереходаТекущая.ИмяОбработчикаДлительнойОперации) Тогда
		
		ИмяПроцедуры = "[ИмяОбработчика](Отказ, ПерейтиДалее)";
		ИмяПроцедуры = СтрЗаменить(ИмяПроцедуры, "[ИмяОбработчика]", СтрокаПереходаТекущая.ИмяОбработчикаДлительнойОперации);
		
		Отказ = Ложь;
		ПерейтиДалее = Истина;
		
		Результат = Вычислить(ИмяПроцедуры);
		
		Если Отказ Тогда
			
			ПорядковыйНомерПерехода = ПорядковыйНомерПерехода - 1;
			Возврат;
			
		ИначеЕсли ПерейтиДалее Тогда
			
			УстановитьПорядковыйНомерПерехода(ПорядковыйНомерПерехода + 1);
			Возврат;
			
		КонецЕсли;
		
	Иначе
		
		УстановитьПорядковыйНомерПерехода(ПорядковыйНомерПерехода + 1);
		Возврат;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Функция ПолучитьКнопкуФормыПоИмениКоманды(ЭлементФормы, ИмяКоманды)
	
	Для Каждого Элемент Из ЭлементФормы.ПодчиненныеЭлементы Цикл
		
		Если ТипЗнч(Элемент) = Тип("ГруппаФормы") Тогда
			
			ЭлементФормыПоИмениКоманды = ПолучитьКнопкуФормыПоИмениКоманды(Элемент, ИмяКоманды);
			
			Если ЭлементФормыПоИмениКоманды <> Неопределено Тогда
				
				Возврат ЭлементФормыПоИмениКоманды;
				
			КонецЕсли;
			
		ИначеЕсли ТипЗнч(Элемент) = Тип("КнопкаФормы")
			И СтрНайти(Элемент.ИмяКоманды, ИмяКоманды) > 0 Тогда
			
			Возврат Элемент;
			
		Иначе
			
			Продолжить;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Неопределено;
	
КонецФункции

&НаСервере
Функция УстановитьМонопольныйРежимНаСервере()
	
	Результат = Ложь;
	
	СеансыИнформационнойБазы = ПолучитьСеансыИнформационнойБазы();
	НомерСеансаТекущегоПользователя = НомерСеансаИнформационнойБазы();
	КоличествоАктивныхСеансов = 0;
	Для Каждого СеансИБ Из СеансыИнформационнойБазы Цикл
		Если СеансИБ.ИмяПриложения = "Designer"
			Или СеансИБ.НомерСеанса = НомерСеансаТекущегоПользователя Тогда
			Продолжить;
		КонецЕсли;
		КоличествоАктивныхСеансов = КоличествоАктивныхСеансов + 1;
	КонецЦикла;
	
	ОшибкаУстановкиМонопольногоРежима = "";
	Если КоличествоАктивныхСеансов = 0 Тогда
		Попытка
			УстановитьМонопольныйРежим(Истина);
			Результат = Истина;
		Исключение
			ОшибкаУстановкиМонопольногоРежима = НСтр("ru = 'Техническая информация:';
													|en = 'Technical details:'") + " " 
				+ КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
		КонецПопытки;
		Если МонопольныйРежим() Тогда
			УстановитьМонопольныйРежим(Ложь);
		КонецЕсли;
	Иначе
		
		Элементы.АктивныеПользователи.Видимость = Истина;
		Элементы.ДекорацияПояснениеПоОшибке.Видимость = Истина;
		
		Элементы.ДекорацияОшибка.Заголовок = НСтр("ru = 'Невозможно изменить префикс, т.к. с программой работают другие пользователи:';
													|en = 'Couldn''t change the prefix. There are active user sessions:'");
		Элементы.АктивныеПользователи.Заголовок = СтроковыеФункции.ФорматированнаяСтрока(НСтр("ru = 'Активные пользователи (%1)';
																								|en = 'Active users (%1)'"), КоличествоАктивныхСеансов);
		Элементы.ДекорацияПояснениеПоОшибке.Заголовок = НСтр("ru = 'Для продолжения необходимо завершить их работу.';
															|en = 'To continue, close their sessions.'")
		
	КонецЕсли;
		
	Возврат Результат;
			
КонецФункции 

&НаСервере
Процедура УдалитьМонопольныйРежимНаСервере()

	Если МонопольныйРежим() Тогда
		УстановитьМонопольныйРежим(Ложь);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Функция Подключаемый_СтраницаОжидание_ПриОткрытии(Отказ, ПропуститьСтраницу, Знач ЭтоПереходДалее)

	Если ИзменитьПрефиксВМонопольномРежиме Тогда
		Если НЕ УстановитьМонопольныйРежимНаСервере() Тогда
			ИзменитьПорядковыйНомерПерехода(+1);
			Возврат Неопределено;
		КонецЕсли;
	КонецЕсли;
	
	ФоновоеЗадание = ЗапуститьИзменениеПрефиксаИБВФоновомЗадании();
		
	НастройкиОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
	НастройкиОжидания.ВыводитьОкноОжидания = Ложь;
		
	Обработчик = Новый ОписаниеОповещения("ПослеИзмененияПрефикса", ЭтотОбъект);
	ДлительныеОперацииКлиент.ОжидатьЗавершение(ФоновоеЗадание, Обработчик, НастройкиОжидания);

	Возврат Неопределено;
	
КонецФункции

&НаСервере
Функция ЗапуститьИзменениеПрефиксаИБВФоновомЗадании()
	
	ПараметрыПроцедуры = Новый Структура("НовыйПрефиксИБ, ПродолжитьНумерацию", НовыйПрефиксИБ, Истина);
		
	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияВФоне(УникальныйИдентификатор);
	ПараметрыВыполнения.НаименованиеФоновогоЗадания = НСтр("ru = 'Изменение префикса';
															|en = 'Change prefix'");
	ПараметрыВыполнения.ОжидатьЗавершение = 0;
		
	Возврат ДлительныеОперации.ВыполнитьПроцедуру(ПараметрыВыполнения,"ПрефиксацияОбъектовСлужебный.ИзменитьПрефиксИБ", ПараметрыПроцедуры);
	
КонецФункции

&НаКлиенте
Процедура ПослеИзмененияПрефикса(ФоновоеЗадание, ДополнительныеПараметры) Экспорт 
	
	Если ФоновоеЗадание.Статус = "Выполнено" Тогда
				
		ИзменитьПорядковыйНомерПерехода(+2);
		УдалитьМонопольныйРежимНаСервере();
		Оповестить("НаборКонстант.ПрефиксУзлаРаспределеннойИнформационнойБазы", НовыйПрефиксИБ);
				
	ИначеЕсли ФоновоеЗадание.Статус = "Ошибка" Тогда 
		
		Элементы.АктивныеПользователи.Видимость = Ложь;
		Элементы.ДекорацияПояснениеПоОшибке.Видимость = Ложь;
		
		Шаблон = НСтр("ru = '%1
                       |
                       |Запустите операцию позже или повторите попытку в монопольном режиме';
                       |en = '%1
                       |
                       |Retry later or in exclusive mode'");
		
		Элементы.ДекорацияОшибка.Заголовок = СтроковыеФункцииКлиент.ФорматированнаяСтрока(Шаблон, ФоновоеЗадание.КраткоеПредставлениеОшибки);
		ИзменитьПорядковыйНомерПерехода(+1);
		
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьТаблицуПереходов()
	
	ТаблицаПереходов.Очистить();
	
	Переход = ТаблицаПереходов.Добавить();
	Переход.ПорядковыйНомерПерехода = 1;
	Переход.ИмяОсновнойСтраницы     = "СтраницаУстановкаПрефикса";
	Переход.ИмяСтраницыНавигации    = "СтраницаНавигацииНачало";
	
	Переход = ТаблицаПереходов.Добавить();
	Переход.ПорядковыйНомерПерехода = 2;
	Переход.ИмяОсновнойСтраницы     = "СтраницаОжидание";
	Переход.ИмяСтраницыНавигации    = "СтраницаНавигацииОжидание";;
	Переход.ИмяОбработчикаПриОткрытии = "Подключаемый_СтраницаОжидание_ПриОткрытии";
	
	Переход = ТаблицаПереходов.Добавить();
	Переход.ПорядковыйНомерПерехода = 3;
	Переход.ИмяОсновнойСтраницы     = "СтраницаОшибка";
	Переход.ИмяСтраницыНавигации    = "СтраницаНавигацииОшибка";
	
	Переход = ТаблицаПереходов.Добавить();
	Переход.ПорядковыйНомерПерехода = 4;
	Переход.ИмяОсновнойСтраницы     = "СтраницаГотово";
	Переход.ИмяСтраницыНавигации    = "СтраницаНавигацииОкончание";
		
КонецПроцедуры



#КонецОбласти
