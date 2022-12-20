﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытий

&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	Отказ = Ложь;
	
	АдресВременногоХранилища = "";
	
	ПолучитьНастройкиОбменаДаннымиДляВторойИнформационнойБазыНаСервере(Отказ, АдресВременногоХранилища, ПараметрКоманды);
	
	Если Отказ Тогда
		
		ПоказатьПредупреждение(, НСтр("ru = 'Возникли ошибки при получении настроек обмена данными.';
										|en = 'Cannot get data exchange settings.'"));
		
	Иначе
		
		ПараметрыСохранения = ФайловаяСистемаКлиент.ПараметрыСохраненияФайла();
		ПараметрыСохранения.Диалог.Фильтр = "Файлы XML (*.xml)|*.xml";

		ФайловаяСистемаКлиент.СохранитьФайл(
			Неопределено,
			АдресВременногоХранилища,
			НСтр("ru = 'Настройки синхронизации данных.xml';
				|en = 'Synchronization settings.xml'"),
			ПараметрыСохранения);
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ПолучитьНастройкиОбменаДаннымиДляВторойИнформационнойБазыНаСервере(Отказ, АдресВременногоХранилища, УзелИнформационнойБазы)
	
	ПомощникСозданияОбменаДанными = ОбменДаннымиСервер.МодульПомощникСозданияОбменаДанными().Создать();
	ПомощникСозданияОбменаДанными.Инициализация(УзелИнформационнойБазы);
	ПомощникСозданияОбменаДанными.ВыполнитьВыгрузкуПараметровМастераВоВременноеХранилище(Отказ, АдресВременногоХранилища);
	
КонецПроцедуры

#КонецОбласти
