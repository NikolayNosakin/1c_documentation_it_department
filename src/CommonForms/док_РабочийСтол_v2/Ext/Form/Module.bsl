﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)	
	
	Если ОбщегоНазначения.ЭтоМобильныйКлиент() Тогда
		ИмяМакета = "док_РабочийСтолМобильный";		
	Иначе
		ИмяМакета = "док_РабочийСтол"; 
		Элементы.Сканировать_Штрихкод.Видимость = Ложь;
	КонецЕсли;
	ТекстHTML = ПолучитьОбщийМакет(ИмяМакета).ПолучитьТекст();
	ПолеHTML = СтрЗаменить(ТекстHTML,"Приветствую, !","Приветствую, " + Пользователи.ТекущийПользователь() + "!");		

КонецПроцедуры

&НаКлиенте
Процедура ПолеHTMLПриНажатии(Элемент, ДанныеСобытия, СтандартнаяОбработка)
	Если НЕ ДанныеСобытия.Href = Неопределено Тогда
		СтандартнаяОбработка = Ложь;
		Позиция = Найти(ДанныеСобытия.Href,"mdobject");
		Ссылка = Сред(ДанныеСобытия.Href,Позиция,СтрДлина(ДанныеСобытия.Href));		
		Позиция = Найти(Ссылка,"e1cib");
		Ссылка = Сред(Ссылка,Позиция,СтрДлина(Ссылка)); 		
		ПерейтиПоНавигационнойСсылке(Ссылка); 
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура Сканировать_Штрихкод(Команда)
	ОткрытьФорму("Обработка.док_СканированиеШтрихкодов.Форма.Форма");
КонецПроцедуры
