﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ВыводитьКонтрагента = Истина;
	ПоложениеТекста = "Право";
	ВыводитьIPАдрес = Истина;
	Если Параметры.Свойство("СсылкаНаОбъект") Тогда
		СсылкаНаОбъект = Параметры.СсылкаНаОбъект;
		СгенерироватьНаСервере();
	КонецЕсли;	
КонецПроцедуры

&НаКлиенте
Процедура Печать(Команда)	
	Результат.Напечатать(РежимИспользованияДиалогаПечати.Использовать);	
КонецПроцедуры

&НаКлиенте
Процедура СформироватьШтрихкод(Команда)
	ОчиститьСообщения();
	СгенерироватьНаСервере();
КонецПроцедуры
       
&НаСервере
Процедура СгенерироватьНаСервере()
	
	Результат.Очистить();
	ПодписьУстройство = Строка(ТипЗнч(СсылкаНаОбъект)) + ": " + Строка(СсылкаНаОбъект);
	
	Если ВыводитьКонтрагента Тогда
		ПодписьУстройство = ПодписьУстройство + " (" + Строка(СсылкаНаОбъект.Контрагент) + ")";
	КонецЕсли;

	Если ВыводитьIPАдрес Тогда
		Если НЕ СсылкаНаОбъект.Метаданные().ТабличныеЧасти.Найти("IP") = Неопределено Тогда
			СтрокаIP = СсылкаНаОбъект.IP.Найти(Истина,"Основной");
			Если НЕ СтрокаIP = Неопределено Тогда
				ПодписьУстройство = ПодписьУстройство + Символы.ПС + СтрокаIP.IP;
			КонецЕсли;	
		КонецЕсли;	
	КонецЕсли;
		
	ВремОбъект = РеквизитФормыВЗначение("Объект");
	Макет = ВремОбъект.ПолучитьМакет("Макет");
	
	Если ПоложениеТекста = "Верх" Тогда
		ОбластьПодписьУстройство = Макет.ПолучитьОбласть("ПодписьУстройствоВерх|Колонка");
	ИначеЕсли ПоложениеТекста = "Низ" Тогда  
		ОбластьПодписьУстройство = Макет.ПолучитьОбласть("ПодписьУстройствоНиз|Колонка");
	ИначеЕсли ПоложениеТекста = "Лево" Тогда
		ОбластьПодписьУстройство = Макет.ПолучитьОбласть("Строка|ПодписьУстройствоЛево"); 
	ИначеЕсли ПоложениеТекста = "Право" Тогда
		ОбластьПодписьУстройство = Макет.ПолучитьОбласть("Строка|ПодписьУстройствоПраво");
	КонецЕсли;
	ОбластьПодписьУстройство.Параметры.Устройство = ПодписьУстройство;
	
	Область = Макет.ПолучитьОбласть("Строка|Колонка");
	Рисунок = Область.Рисунки.ШтрихКод;
	
	Эталон = ВремОбъект.ПолучитьМакет("МакетДляОпределенияКоэффициентовЕдиницИзмерения");
	
	КоличествоМиллиметровВПикселеВысота = Эталон.Рисунки.Квадрат100Пикселей.Высота / 100;
	КоличествоМиллиметровВПикселеШирина = Эталон.Рисунки.Квадрат100Пикселей.Ширина / 100;
	ШиринаШтрихкода = Окр(Рисунок.Ширина / КоличествоМиллиметровВПикселеШирина);
	ВысотаШтрихкода = Окр(Рисунок.Высота / КоличествоМиллиметровВПикселеВысота);

	ВходныеДанные = ПолучитьНавигационнуюСсылку(СсылкаНаОбъект);
		
	Картинка = ПолучитьШтрихкод(ШиринаШтрихкода, ВысотаШтрихкода, ВходныеДанные, 16);
	
	Рисунок.Картинка = Картинка;
	
	Если ПоложениеТекста = "Верх" Тогда
		Результат.Вывести(ОбластьПодписьУстройство);
		Результат.Вывести(Область);
	ИначеЕсли ПоложениеТекста = "Низ" Тогда  		
		Результат.Вывести(Область);
		Результат.Вывести(ОбластьПодписьУстройство);
	ИначеЕсли ПоложениеТекста = "Лево" Тогда
		Результат.Вывести(ОбластьПодписьУстройство);
		Результат.Присоединить(Область); 
	ИначеЕсли ПоложениеТекста = "Право" Тогда
		Результат.Вывести(Область);
		Результат.Присоединить(ОбластьПодписьУстройство);
	КонецЕсли;
		
КонецПроцедуры

&НаСервере
Функция ПолучитьШтрихкод(ШиринаШтрихкода, ВысотаШтрихкода, ЗначШтрихкод, ЗначТипШтрихкода)
	
	ПараметрыШтрихкода = ГенерацияШтрихкода.ПараметрыГенерацииШтрихкода();
	ПараметрыШтрихкода.Ширина = ШиринаШтрихкода;
	ПараметрыШтрихкода.Высота = ВысотаШтрихкода;
	ПараметрыШтрихкода.ТипКода = ЗначТипШтрихкода;
	//ПараметрыШтрихкода.УголПоворота = Число(УголПоворота);
	ПараметрыШтрихкода.Штрихкод = ЗначШтрихкод;
	ПараметрыШтрихкода.ПрозрачныйФон = Истина;
	//ПараметрыШтрихкода.УровеньКоррекцииQR = УровеньКоррекцииQR;
	//ПараметрыШтрихкода.ОтображатьТекст = ОтображатьТекст;
	//ПараметрыШтрихкода.Масштабировать = Масштабировать;
	ПараметрыШтрихкода.СохранятьПропорции = Истина;
	//ПараметрыШтрихкода.ВертикальноеВыравнивание  = ВертикальноеВыравнивание; 
	//ПараметрыШтрихкода.GS1DatabarКоличествоСтрок = КоличествоСтрокGS1Databar;
	ПараметрыШтрихкода.ТипВходныхДанных = 0;
	//ПараметрыШтрихкода.УбратьЛишнийФон = УбратьЛишнийФон;
	//ПараметрыШтрихкода.ЛоготипКартинка = КартинкаBase64;
	//ПараметрыШтрихкода.ЛоготипРазмерПроцентОтШК = ЛоготипРазмерПроцентОтШК;
	
	РезультатШтрихкод = ГенерацияШтрихкода.ИзображениеШтрихкода(ПараметрыШтрихкода);
	Если НЕ РезультатШтрихкод.Результат Тогда
		ОбщегоНазначения.СообщитьПользователю(НСтр("ru='Ошибка генерации'"));
	КонецЕсли;
	
	Возврат РезультатШтрихкод.Картинка;
	
КонецФункции