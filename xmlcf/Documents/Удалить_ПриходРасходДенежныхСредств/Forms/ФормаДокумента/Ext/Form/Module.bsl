﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если НЕ Параметры.Ключ.Пустая() тогда
		Брокер = Объект.Портфель.Брокер;
	КонецЕсли;
	
	УстановкаОтображенияВидимости();
	
КонецПроцедуры

&НаСервере
Процедура УстановкаОтображенияВидимости()
	
	Если Объект.ВидОперации = Перечисления.ВидыОперацийПриходРасходДенежныхСредств.ОбменВалюты тогда
		Элементы.ГруппаСуммаПриход.Видимость = Истина;
	Иначе
		Элементы.ГруппаСуммаПриход.Видимость = Ложь;
	КонецЕсли;		
	
КонецПроцедуры

&НаСервере
Процедура ВидОперацииПриИзмененииНаСервере()

	Если Объект.ВидОперации <> Перечисления.ВидыОперацийПриходРасходДенежныхСредств.ОбменВалюты тогда
		Объект.ВалютаПриход = Справочники.Валюта.ПустаяСсылка();
		Объект.СуммаПриход 	=  0;
	КонецЕсли;
	
	УстановкаОтображенияВидимости();
	
КонецПроцедуры

&НаКлиенте
Процедура ВидОперацииПриИзменении(Элемент)
	
	ВидОперацииПриИзмененииНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура СуммаПриИзменении(Элемент)
	
	Если НЕ Объект.СуммаКомиссииУстановленаВручную тогда
		Объект.СуммаКомиссии = ОбщегоНазначенияСервер.РассчитатьСуммуКомиссииБрокера(Объект.Сумма,Брокер,Объект.Дата);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПортфельПриИзмененииНаСервере()

	Брокер = Объект.Портфель.Брокер;
	
КонецПроцедуры

&НаКлиенте
Процедура ПортфельПриИзменении(Элемент)
	
	ПортфельПриИзмененииНаСервере();
	
КонецПроцедуры
