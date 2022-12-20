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
	
	ПараметрыПроверки = Справочники.ВерсииРасширений.ДинамическиИзмененныеРасширения();
	ПараметрыПроверки.Вставить("КонфигурацияБазыДанныхИзмененаДинамически", КонфигурацияБазыДанныхИзмененаДинамически());
	
	Если ПараметрыПроверки.Исправления <> Неопределено И ПараметрыПроверки.Исправления.СписокНовых.Количество() > 0 Тогда
		АдресХранилища = ПоместитьВоВременноеХранилище(Неопределено, УникальныйИдентификатор);
		ПараметрыМетода = Новый Массив;
		ПараметрыМетода.Добавить(АдресХранилища);
		ПараметрыМетода.Добавить(ПараметрыПроверки.Исправления.СписокНовых);
		ФоновоеЗадание = РасширенияКонфигурации.ВыполнитьФоновоеЗаданиеСРасширениямиБазыДанных(
			"ОбновлениеКонфигурации.ОписанияНовыхПатчей",
			ПараметрыМетода);
		ФоновоеЗадание.ОжидатьЗавершенияВыполнения(Неопределено);
		
		ОписаниеНовыхПатчей = ПолучитьИзВременногоХранилища(АдресХранилища);
		УточняющаяСсылка = " " + НСтр("ru = '<a href = ""%1"">Подробно</a>';
										|en = '<a href = ""%1"">Detailed information</a>'");
	Иначе
		УточняющаяСсылка = "Ссылка";
	КонецЕсли;
	
	Сообщение = СтандартныеПодсистемыСервер.ТекстСообщенияПриДинамическомОбновлении(ПараметрыПроверки,
		УточняющаяСсылка);
	
	Элементы.Текст.Заголовок = СтроковыеФункции.ФорматированнаяСтрока(Сообщение, "ПереходПоСсылке");
	
	СРасписанием = Истина;
	Если ПараметрыПроверки.Исправления = Неопределено
		Или ПараметрыПроверки.Исправления.Добавлено = 0 Тогда
		Элементы.ГруппаРасписание.Видимость = Ложь;
		СРасписанием = Ложь;
	Иначе
		ЗаполнитьРасписаниеОтображенияФормы();
	КонецЕсли;
	
	Ключ = "";
	Если ПараметрыПроверки.КонфигурацияБазыДанныхИзмененаДинамически Тогда
		Ключ = "Конфигурация";
	КонецЕсли;
	Если ПараметрыПроверки.Исправления <> Неопределено Тогда
		Ключ = Ключ + "Исправления";
	КонецЕсли;
	Если ПараметрыПроверки.Расширения <> Неопределено Тогда
		Ключ = Ключ + "Расширения";
	КонецЕсли;
	Если СРасписанием Тогда
		Ключ = Ключ + "Расписание";
	КонецЕсли;
	
	СтандартныеПодсистемыСервер.УстановитьКлючНазначенияФормы(ЭтотОбъект, Ключ);
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	Если Не ЗавершениеРаботы Тогда
		СохранитьРасписание();
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ТекстОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	
	Документ = Новый ТекстовыйДокумент;
	Документ.УстановитьТекст(ОписаниеНовыхПатчей);
	Документ.Показать(НСтр("ru = 'Новые исправления ошибок';
							|en = 'New bug fixes'"));
КонецПроцедуры

&НаКлиенте
Процедура РасписаниеНажатие(Элемент, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ОбработчикЗавершения = Новый ОписаниеОповещения("РасписаниеНажатиеЗавершение", ЭтотОбъект);
	Список = Новый СписокЗначений;
	Список.Добавить("ОдинРаз", НСтр("ru = 'один раз в день';
									|en = 'once a day'"));
	Список.Добавить("ДваРаза", НСтр("ru = 'два раза в день';
									|en = 'twice a day'"));
	Список.Добавить("ДругойИнтервал", НСтр("ru = 'другой интервал...';
											|en = 'another interval…'"));
	
	ПоказатьВыборИзМеню(ОбработчикЗавершения, Список, Элементы.Расписание);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Перезапустить(Команда)
	СохранитьРасписание();
	СтандартныеПодсистемыКлиент.ПропуститьПредупреждениеПередЗавершениемРаботыСистемы();
	ЗавершитьРаботуСистемы(Истина, Истина);
КонецПроцедуры

&НаКлиенте
Процедура НапомнитьПозже(Команда)
	НапомнитьЗавтра();
	Закрыть();
КонецПроцедуры

&НаКлиенте
Процедура БольшеНеНапоминать(Команда)
	БольшеНеНапоминатьНаСервере();
	Закрыть();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура БольшеНеНапоминатьНаСервере()
	ОбщегоНазначения.ХранилищеОбщихНастроекСохранить("ОбщиеНастройкиПользователя",
		"ПоказыватьПредупреждениеОбУстановленныхОбновленияхПрограммы",
		Ложь);
КонецПроцедуры

&НаКлиенте
Процедура НапомнитьЗавтра()
	НапомнитьЗавтраНаСервере();
КонецПроцедуры

&НаСервереБезКонтекста
Процедура НапомнитьЗавтраНаСервере()
	
	ОбщегоНазначения.ХранилищеСистемныхНастроекСохранить("КонтрольДинамическогоОбновления",
		"ДатаНапомнитьЗавтра", НачалоДня(ТекущаяДатаСеанса()) + 60*60*24);
	
КонецПроцедуры

&НаКлиенте
Процедура РасписаниеНажатиеЗавершение(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если Результат.Значение = "ОдинРаз" Или Результат.Значение = "ДваРаза" Тогда
		ПредставлениеРасписания = Результат;
		РасписаниеИзменено = Истина;
		ТекущееРасписание.Идентификатор = Результат.Значение;
		ТекущееРасписание.Представление = Результат.Представление;
		ТекущееРасписание.Расписание = СтандартноеРасписание[Результат.Значение];
		Возврат;
	КонецЕсли;
	
	ОбработчикЗавершений = Новый ОписаниеОповещения("РасписаниеНажатиеПослеВыбораПроизвольногоРасписания", ЭтотОбъект);
	ДиалогРасписания = Новый ДиалогРасписанияРегламентногоЗадания(Новый РасписаниеРегламентногоЗадания);
	ДиалогРасписания.Показать(ОбработчикЗавершений);
КонецПроцедуры

&НаКлиенте
Процедура РасписаниеНажатиеПослеВыбораПроизвольногоРасписания(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	РасписаниеИзменено = Истина;
	ПредставлениеРасписания = Результат;
	ТекущееРасписание.Идентификатор = "ДругойИнтервал";
	ТекущееРасписание.Представление = Строка(Результат);
	ТекущееРасписание.Расписание = Результат;
	
КонецПроцедуры

&НаСервере
Процедура СохранитьРасписание()
	Если Не РасписаниеИзменено Тогда
		Возврат;
	КонецЕсли;
	
	ОбщегоНазначения.ХранилищеСистемныхНастроекСохранить("КонтрольДинамическогоОбновления", "РасписаниеПроверкиПатчей", ТекущееРасписание);
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьРасписаниеОтображенияФормы()
	
	ТекущееРасписание = ОбщегоНазначения.ХранилищеСистемныхНастроекЗагрузить("КонтрольДинамическогоОбновления", "РасписаниеПроверкиПатчей");
	Если ТекущееРасписание = Неопределено Тогда
		ТекущееРасписание = Новый Структура;
		ТекущееРасписание.Вставить("Идентификатор");
		ТекущееРасписание.Вставить("Представление");
		ТекущееРасписание.Вставить("Расписание");
		ТекущееРасписание.Вставить("ПоследнееОповещение");
		ПредставлениеРасписания = НСтр("ru = 'по умолчанию (каждые 20 минут)';
										|en = 'by default (every 20 minutes)'");
	Иначе
		ПредставлениеРасписания = ТекущееРасписание.Представление;
	КонецЕсли;
	
	ОдинРазВДень = Новый РасписаниеРегламентногоЗадания;
	ОдинРазВДень.ПериодПовтораДней = 1;
	ДваРазаВДень = Новый РасписаниеРегламентногоЗадания;
	ДваРазаВДень.ПериодПовтораДней = 1;
	
	ПервыйЗапуск = Новый РасписаниеРегламентногоЗадания;
	ПервыйЗапуск.ВремяНачала = Дата(01,01,01,09,00,00);
	ДваРазаВДень.ДетальныеРасписанияДня.Добавить(ПервыйЗапуск);
	
	ВторойЗапуск = Новый РасписаниеРегламентногоЗадания;
	ВторойЗапуск.ВремяНачала = Дата(01,01,01,15,00,00);
	ДваРазаВДень.ДетальныеРасписанияДня.Добавить(ВторойЗапуск);
	
	СтандартноеРасписание = Новый Структура;
	СтандартноеРасписание.Вставить("ОдинРаз", ОдинРазВДень);
	СтандартноеРасписание.Вставить("ДваРаза", ДваРазаВДень);
	
КонецПроцедуры

#КонецОбласти