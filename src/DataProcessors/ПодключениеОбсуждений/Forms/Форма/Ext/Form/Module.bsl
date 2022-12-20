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
	
	Если Не ПравоДоступа("РегистрацияИнформационнойБазыСистемыВзаимодействия", Метаданные) Тогда 
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
	УстановитьСерверВзаимодействияПоУмолчанию(ЭтотОбъект);

	ИмяИнформационнойБазы = Константы.ЗаголовокСистемы.Получить();
	Если Не ЗначениеЗаполнено(ИмяИнформационнойБазы) Тогда
		ИмяИнформационнойБазы = Метаданные.КраткаяИнформация;
	КонецЕсли;
	СостояниеРегистрации = ТекущееСостояниеРегистрации();
	
	ПриИзмененииСостоянияФормы(ЭтотОбъект);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ТребуетсяСоздатьАдминистратораПояснениеОбработкаНавигационнойСсылки(Элемент, 
	НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	
	Закрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура ВыборСервераВзаимодействияДиалогПриИзменении(Элемент)
	УстановитьСерверВзаимодействияПоУмолчанию(ЭтотОбъект);
	ОбновитьЭлементыВыбораСервера(ЭтотОбъект);
КонецПроцедуры

&НаКлиенте
Процедура ВыборСервераВзаимодействияЛокальноПриИзменении(Элемент)
	ОбновитьЭлементыВыбораСервера(ЭтотОбъект);
КонецПроцедуры

&НаКлиенте
Процедура АдресСервераВзаимодействияПриИзменении(Элемент)
	СерверВзаимодействия = АдресСервераВзаимодействия;
	ОбновитьЭлементыВыбораСервера(ЭтотОбъект);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Зарегистрироваться(Команда)
	
	Если СостояниеРегистрации = "ТребуетсяРазблокировать" Тогда 
		ПриРазблокировке();
	ИначеЕсли СостояниеРегистрации = "НеЗарегистрирована" Тогда 
		ПриПолученииКодаРегистрации();
	ИначеЕсли СостояниеРегистрации = "ОжиданиеВводаКодаПодтверждения" Тогда 
		ПриРегистрации();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура Назад(Команда)
	
	Если СостояниеРегистрации = "ОжиданиеВводаКодаПодтверждения" Тогда 
		ПриОтказеОтВводаКодаПодтверждения();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область СлужебныеОбработчикиСобытий

&НаКлиенте
Процедура ПриРазблокировке()
	
	ОбсужденияСлужебныйВызовСервера.Разблокировать();
	
	СостояниеРегистрации = "Зарегистрирована";
	ПриИзмененииСостоянияФормы(ЭтотОбъект);
	Оповестить("ОбсужденияПодключены", Истина);
	ОбновитьИнтерфейс();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриПолученииКодаРегистрации()
	
	Если ПустаяСтрока(АдресЭлектроннойПочты) Тогда 
		ПоказатьПредупреждение(, НСтр("ru = 'Адрес электронной почты не заполнен';
										|en = 'Email address is not filled in'"));
		Возврат;
	КонецЕсли;
	
	Если Не ОбщегоНазначенияКлиентСервер.АдресЭлектроннойПочтыСоответствуетТребованиям(АдресЭлектроннойПочты) Тогда 
		ПоказатьПредупреждение(, НСтр("ru = 'Адрес электронной почты содержит ошибки';
										|en = 'The email address contains errors'"));
		Возврат;
	КонецЕсли;
	
	Если ВыборСервераВзаимодействия = 1 И ПустаяСтрока(АдресСервераВзаимодействия) Тогда
		ПоказатьПредупреждение(, НСтр("ru = 'Не указан адрес локального сервера взаимодействия';
										|en = 'URL of local collaboration server is not specified'"));
		Возврат;
	КонецЕсли;
	
	ПараметрыРегистрации = Новый ПараметрыРегистрацииИнформационнойБазыСистемыВзаимодействия;
	ПараметрыРегистрации.АдресСервера = СерверВзаимодействия;
	ПараметрыРегистрации.АдресЭлектроннойПочты = АдресЭлектроннойПочты;
	
	Оповещение = Новый ОписаниеОповещения("ПослеУспешногоПолученияКодаРегистрации", ЭтотОбъект,,
		"ПриОбработкеОшибкиПолученияКодаРегистрации", ЭтотОбъект);
	СистемаВзаимодействия.НачатьРегистрациюИнформационнойБазы(Оповещение, ПараметрыРегистрации);
	
	СостояниеРегистрации = "ОжиданиеОтветаСервераВзаимодействия";
	ПриИзмененииСостоянияФормы(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеУспешногоПолученияКодаРегистрации(РегистрацияВыполнена, ТекстСообщения, Контекст) Экспорт
	
	ПоказатьПредупреждение(, ТекстСообщения);
	
	СостояниеРегистрации = "ОжиданиеВводаКодаПодтверждения";
	ПриИзмененииСостоянияФормы(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОбработкеОшибкиПолученияКодаРегистрации(ИнформацияОбОшибке, СтандартнаяОбработка, Контекст) Экспорт 
	
	СтандартнаяОбработка = Ложь;
	ПоказатьИнформациюОбОшибке(ИнформацияОбОшибке);
	
	СостояниеРегистрации = "НеЗарегистрирована";
	ПриИзмененииСостоянияФормы(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриРегистрации()
	
	Если ПустаяСтрока(КодРегистрации) Тогда 
		ПоказатьПредупреждение(, НСтр("ru = 'Код регистрации не заполнен';
										|en = 'Registration code is required'"));
		Возврат;
	КонецЕсли;
	
	ПараметрыРегистрации = Новый ПараметрыРегистрацииИнформационнойБазыСистемыВзаимодействия;
	ПараметрыРегистрации.АдресСервера = СерверВзаимодействия;
	ПараметрыРегистрации.АдресЭлектроннойПочты = АдресЭлектроннойПочты;
	ПараметрыРегистрации.ИмяИнформационнойБазы = ИмяИнформационнойБазы;
	ПараметрыРегистрации.КодАктивации = СокрЛП(КодРегистрации);
	
	Оповещение = Новый ОписаниеОповещения("ПослеУспешнойРегистрации", ЭтотОбъект,,
		"ПриОбработкеОшибкиРегистрации", ЭтотОбъект);
	
	СистемаВзаимодействия.НачатьРегистрациюИнформационнойБазы(Оповещение, ПараметрыРегистрации);
	
	СостояниеРегистрации = "ОжиданиеОтветаСервераВзаимодействия";
	ПриИзмененииСостоянияФормы(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеУспешнойРегистрации(РегистрацияВыполнена, ТекстСообщения, Контекст) Экспорт
	
	Если РегистрацияВыполнена Тогда 
		Оповестить("ОбсужденияПодключены", Истина);
		СостояниеРегистрации = "Зарегистрирована";
	Иначе 
		ПоказатьПредупреждение(, ТекстСообщения);
		СостояниеРегистрации = "ОжиданиеВводаКодаПодтверждения";
	КонецЕсли;
	
	ПриИзмененииСостоянияФормы(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОбработкеОшибкиРегистрации(ИнформацияОбОшибке, СтандартнаяОбработка, Контекст) Экспорт 
	
	СтандартнаяОбработка = Ложь;
	ПоказатьИнформациюОбОшибке(ИнформацияОбОшибке);
	
	СостояниеРегистрации = "ОжиданиеВводаКодаПодтверждения";
	ПриИзмененииСостоянияФормы(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОтказеОтВводаКодаПодтверждения()
	
	Оповещение = Новый ОписаниеОповещения("ПослеПодтвержденияОтказаВводаКодаПодтверждения", ЭтотОбъект);
	ПоказатьВопрос(Оповещение, 
		НСтр("ru = 'При отказе от ввода высланный на электронную почту код станет недействительным.
		           |Продолжение будет возможно только с запросом нового кода.';
		           |en = 'If not entered, the code sent to your email will be invalid.
		           |You can continue only after a new code is requested.'"), 
		РежимДиалогаВопрос.ОКОтмена,, КодВозвратаДиалога.Отмена);
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеПодтвержденияОтказаВводаКодаПодтверждения(РезультатВопроса, Контекст) Экспорт 
	
	Если РезультатВопроса = КодВозвратаДиалога.ОК Тогда 
		СостояниеРегистрации = "НеЗарегистрирована";
		ПриИзмененииСостоянияФормы(ЭтотОбъект);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура ПриИзмененииСостоянияФормы(Форма) 
	
	СостояниеРегистрации = Форма.СостояниеРегистрации;
	
	Если СостояниеРегистрации = "ОжиданиеВводаКодаПодтверждения" Тогда
		Форма.КодРегистрации = "";
	КонецЕсли;
	
	УстановитьСтраницу(Форма);
	ОбновитьВидимостьКнопокКоманднойПанели(Форма);
	ОбновитьЭлементыВыбораСервера(Форма);
	
КонецПроцедуры

#КонецОбласти

#Область МодельПредставления

// Возвращаемое значение:
//   Строка - "ТребуетсяСоздатьАдминистратора",
//   "НеЗарегистрирована",
//   "Зарегистрирована",
//   "ОжиданиеВводаКодаПодтверждения",
//   "ОжиданиеОтветаСервераВзаимодействия".
//
&НаСервереБезКонтекста
Функция ТекущееСостояниеРегистрации()
	
	ТекущийПользователь = ПользователиИнформационнойБазы.ТекущийПользователь();
	
	Если ПустаяСтрока(ТекущийПользователь.Имя) Тогда 
		Возврат "ТребуетсяСоздатьАдминистратора";
	КонецЕсли;
	
	Если ОбсужденияСлужебный.Заблокированы() Тогда 
		Возврат "ТребуетсяРазблокировать";
	КонецЕсли;
	
	Возврат ?(СистемаВзаимодействия.ИнформационнаяБазаЗарегистрирована(),
		"Зарегистрирована", "НеЗарегистрирована");
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьСерверВзаимодействияПоУмолчанию(Форма)
	Форма.СерверВзаимодействия = "wss://1cdialog.com:443";
КонецПроцедуры

#КонецОбласти

#Область Представления

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьСтраницу(Форма)
	
	СостояниеРегистрации = Форма.СостояниеРегистрации;
	Элементы = Форма.Элементы;
	
	Если СостояниеРегистрации = "ТребуетсяСоздатьАдминистратора" Тогда 
		Элементы.Страницы.ТекущаяСтраница = Элементы.ТребуетсяСоздатьАдминистратора;
	ИначеЕсли СостояниеРегистрации = "ТребуетсяРазблокировать" Тогда 
		Элементы.Страницы.ТекущаяСтраница = Элементы.ТребуетсяРазблокировать;
	ИначеЕсли СостояниеРегистрации = "НеЗарегистрирована" Тогда 
		Элементы.Страницы.ТекущаяСтраница = Элементы.ПредложениеРегистрации;
	ИначеЕсли СостояниеРегистрации = "ОжиданиеВводаКодаПодтверждения" Тогда 
		Элементы.Страницы.ТекущаяСтраница = Элементы.ВводКодаРегистрации;
	ИначеЕсли СостояниеРегистрации = "ОжиданиеОтветаСервераВзаимодействия" Тогда
		Элементы.Страницы.ТекущаяСтраница = Элементы.ДлительнаяОперация;
	ИначеЕсли СостояниеРегистрации = "Зарегистрирована" Тогда
		Элементы.Страницы.ТекущаяСтраница = Элементы.РегистрацияЗавершена;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура ОбновитьВидимостьКнопокКоманднойПанели(Форма)
	
	СостояниеРегистрации = Форма.СостояниеРегистрации;
	
	Если СостояниеРегистрации = "ТребуетсяСоздатьАдминистратора" Тогда 
		Форма.Элементы.Зарегистрироваться.Видимость = Ложь;
		Форма.Элементы.Назад.Видимость = Ложь;
	ИначеЕсли СостояниеРегистрации = "ТребуетсяРазблокировать" Тогда 
		Форма.Элементы.Зарегистрироваться.Видимость = Истина;
		Форма.Элементы.Зарегистрироваться.Заголовок = НСтр("ru = 'Восстановить подключение';
															|en = 'Restore connection'");
		Форма.Элементы.Назад.Видимость = Ложь;
	ИначеЕсли СостояниеРегистрации = "НеЗарегистрирована" Тогда 
		Форма.Элементы.Зарегистрироваться.Видимость = Истина;
		Форма.Элементы.Назад.Видимость = Ложь;
	ИначеЕсли СостояниеРегистрации = "ОжиданиеВводаКодаПодтверждения" Тогда 
		Форма.Элементы.Зарегистрироваться.Видимость = Истина;
		Форма.Элементы.Назад.Видимость = Истина;
	ИначеЕсли СостояниеРегистрации = "ОжиданиеОтветаСервераВзаимодействия" Тогда 
		Форма.Элементы.Зарегистрироваться.Видимость = Ложь;
		Форма.Элементы.Назад.Видимость = Ложь;
	ИначеЕсли СостояниеРегистрации = "Зарегистрирована" Тогда 
		Форма.Элементы.Зарегистрироваться.Видимость = Ложь;
		Форма.Элементы.Назад.Видимость = Ложь;
		Форма.Элементы.Закрыть.КнопкаПоУмолчанию = Истина;
		Форма.Элементы.Закрыть.Заголовок = НСтр("ru = 'Готово';
												|en = 'Finish'");
	КонецЕсли;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура ОбновитьЭлементыВыбораСервера(Форма)
	ПредставлениеСервераВзаимодействия = ?(Форма.ВыборСервераВзаимодействия = 0, 
		НСтр("ru = '1С:Диалог';
			|en = '1C:Dialog'"),
		Форма.СерверВзаимодействия);
	ПредставлениеЗаголовка = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Подключаться к %1';
			|en = 'Connect to %1'"),
		ПредставлениеСервераВзаимодействия);
			
	ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(
		Форма.Элементы,
		"ГруппаЛокальныйСерверВзаимодействия",
		"Заголовок",
		ПредставлениеЗаголовка);
	ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(
		Форма.Элементы,
		"ГруппаЛокальныйСерверВзаимодействия",
		"Доступность",
		Форма.ВыборСервераВзаимодействия <> 0);
КонецПроцедуры

#КонецОбласти

#КонецОбласти