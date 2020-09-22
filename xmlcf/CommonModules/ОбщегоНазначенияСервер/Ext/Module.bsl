﻿
Функция ПолучитьПроцентКомисииБрокера(Брокер,Период = Неопределено) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПроцентКомиссииБрокераСрезПоследних.Брокер КАК Брокер,
		|	ПроцентКомиссииБрокераСрезПоследних.ПроцентКомиссии КАК ПроцентКомиссии
		|ИЗ
		|	РегистрСведений.ПроцентКомиссииБрокера.СрезПоследних(&Период, Брокер = &Брокер) КАК ПроцентКомиссииБрокераСрезПоследних";
	
	Запрос.УстановитьПараметр("Брокер", Брокер);
	Запрос.УстановитьПараметр("Период", ?(Период = Неопределено,ТекущаяДата(),Период));
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Возврат ВыборкаДетальныеЗаписи.ПроцентКомиссии; 
	КонецЦикла;
		
КонецФункции

Функция РассчитатьСуммуКомиссииБрокера(СуммаОперации, Брокер, Период) Экспорт 
	
	ПроцентКомиссииБрокера = ПолучитьПроцентКомисииБрокера(Брокер, Период);
	СуммаКомиссии = (СуммаОперации * ПроцентКомиссииБрокера) / 100;
	
	Возврат Окр(СуммаКомиссии,2);
	
КонецФункции

Процедура ЗаписатьТекущуюЦенуАктива(Актив,Период,Цена) Экспорт
	
	НаборЗаписей = РегистрыСведений.ТекущаяЦенаАктива.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Актив.Установить(Актив);
	НаборЗаписей.Отбор.Период.Установить(Период);
	НаборЗаписей.Прочитать();
	
	Если НаборЗаписей.Количество() = 0 тогда
		ЗаписьНабора = НаборЗаписей.Добавить();	
	Иначе
		ЗаписьНабора = НаборЗаписей[0];	
	КонецЕсли;
	
	ЗаписьНабора.Актив 	= Актив;
	ЗаписьНабора.Период = Период;
	ЗаписьНабора.Цена 	= Цена;
	
	НаборЗаписей.Записывать = Истина;
	НаборЗаписей.Записать();
	
КонецПроцедуры