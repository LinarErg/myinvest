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

Функция РассчитатьСуммуКомиссииБрокера(СуммаОперации, Брокер, Период, Актив = Неопределено) Экспорт 
	
	Если Актив = Неопределено тогда		
		ПроцентКомиссииБрокера = ПолучитьПроцентКомисииБрокера(Брокер, Период);
		СуммаКомиссии = (СуммаОперации * ПроцентКомиссииБрокера) / 100;		
		Возврат Окр(СуммаКомиссии,2);		
	Иначе
		Если ТипЗнч(Актив) = Тип("СправочникСсылка.Валюта") тогда
			ПроцентКомиссииБрокера = ПолучитьПроцентКомисииБрокера(Брокер, Период);
			СуммаКомиссии = (СуммаОперации * ПроцентКомиссииБрокера) / 100;			
			Возврат Окр(СуммаКомиссии,2);	
		Иначе
			СтрокаКомиссии = Актив.ИндивидуальныеКомиссии.Найти(Брокер,"Брокер");
			Если СтрокаКомиссии = Неопределено тогда
				ПроцентКомиссииБрокера = ПолучитьПроцентКомисииБрокера(Брокер, Период);
				СуммаКомиссии = (СуммаОперации * ПроцентКомиссииБрокера) / 100;			
				Возврат Окр(СуммаКомиссии,2);	
			Иначе
				СуммаКомиссии = (СуммаОперации * СтрокаКомиссии.ПроцентКомиссии) / 100;			
				Возврат Окр(СуммаКомиссии,2);	
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
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
	Если Актив.Вид = Перечисления.ВидАктива.Облигация тогда
		ЗаписьНабора.Цена = Цена * Актив.Номинал / 100;	
	Иначе
		ЗаписьНабора.Цена = Цена;
	КонецЕсли;
	
	НаборЗаписей.Записывать = Истина;
	НаборЗаписей.Записать();
	
КонецПроцедуры

Функция ПолучитьСоответствиеТикеровВалюты() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	СоответствиеТикеровВалюты.Валюта КАК Валюта,
		|	СоответствиеТикеровВалюты.Тикер КАК Тикер
		|ИЗ
		|	РегистрСведений.СоответствиеТикеровВалюты КАК СоответствиеТикеровВалюты";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Соответствие = Новый Соответствие;	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Соответствие.Вставить(ВыборкаДетальныеЗаписи.Тикер,ВыборкаДетальныеЗаписи.Валюта);
	КонецЦикла;
	
	Возврат Соответствие;
	
КонецФункции

Функция ПолучитьДатуЗапретаПортфеля(Портфель) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ДатаЗапретаИзменений.ДатаЗапрета КАК ДатаЗапрета
		|ИЗ
		|	РегистрСведений.ДатаЗапретаИзменений КАК ДатаЗапретаИзменений
		|ГДЕ
		|	ДатаЗапретаИзменений.Портфель = &Портфель";
	
	Запрос.УстановитьПараметр("Портфель", Портфель);
	РезультатЗапроса = Запрос.Выполнить();
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Возврат ВыборкаДетальныеЗаписи.ДатаЗапрета;
	КонецЦикла;
	
	Возврат Дата(1,1,1,0,0,0);
	
КонецФункции

Процедура ДатаЗапретаПередЗаписью(Источник, Отказ, РежимЗаписи, РежимПроведения) Экспорт
	
	ДатаЗапрета = ПолучитьДатуЗапретаПортфеля(Источник.Портфель);
	
	Если ДатаЗапрета > Источник.Дата тогда
		Отказ = Истина;
	КонецЕсли;
	
КонецПроцедуры

