﻿
Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	Отказ = Ложь;	
	
	ПроверитьВозможностьПроведения(Отказ);	
	
	Если НЕ Отказ тогда
		ВыполнитьДвиженияПоРегистрам();
	КонецЕсли;	
	
КонецПроцедуры

Процедура ПроверитьВозможностьПроведения(Отказ)
	
	Движения.ОстаткиДенежныхСредств.Очистить();
	Движения.ОстаткиДенежныхСредств.Записывать = Истина;
	Движения.Записать();
	
	Движения.АктивыОстатки.Очистить();
	Движения.АктивыОстатки.Записывать = Истина;
	Движения.Записать();

	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	АктивыОстаткиОстатки.Актив КАК Актив,
		|	АктивыОстаткиОстатки.Валюта КАК Валюта,
		|	АктивыОстаткиОстатки.Портфель КАК Портфель,
		|	АктивыОстаткиОстатки.СуммаОстаток КАК СуммаОстаток,
		|	АктивыОстаткиОстатки.КоличествоОстаток КАК КоличествоОстаток
		|ИЗ
		|	РегистрНакопления.АктивыОстатки.Остатки(
		|			&Период,
		|			Портфель = &Портфель
		|				И Валюта = &Валюта
		|				И Актив = &Актив) КАК АктивыОстаткиОстатки";
	
	Запрос.УстановитьПараметр("Валюта", Актив.Валюта);
	Запрос.УстановитьПараметр("Период", Дата);
	Запрос.УстановитьПараметр("Портфель", Портфель);
	Запрос.УстановитьПараметр("Актив", Актив);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Если ВыборкаДетальныеЗаписи.КоличествоОстаток < Количество тогда
			Отказ = Истина;
		КонецЕсли;
	КонецЦикла;	
		
КонецПроцедуры

Процедура ВыполнитьДвиженияПоРегистрам()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	АктивыОстаткиОстатки.Актив КАК Актив,
		|	АктивыОстаткиОстатки.Валюта КАК Валюта,
		|	АктивыОстаткиОстатки.Портфель КАК Портфель,
		|	АктивыОстаткиОстатки.ДокументПартии КАК ДокументПартии,
		|	СУММА(АктивыОстаткиОстатки.СуммаОстаток) КАК СуммаОстаток,
		|	СУММА(АктивыОстаткиОстатки.КоличествоОстаток) КАК КоличествоОстаток
		|ИЗ
		|	РегистрНакопления.АктивыОстатки.Остатки(
		|			&Период,
		|			Портфель = &Портфель
		|				И Актив = &Актив
		|				И Валюта = &Валюта) КАК АктивыОстаткиОстатки
		|
		|СГРУППИРОВАТЬ ПО
		|	АктивыОстаткиОстатки.Валюта,
		|	АктивыОстаткиОстатки.Портфель,
		|	АктивыОстаткиОстатки.ДокументПартии,
		|	АктивыОстаткиОстатки.Актив";
	
	Запрос.УстановитьПараметр("Актив", Актив);
	Запрос.УстановитьПараметр("Валюта", Актив.Валюта);
	Запрос.УстановитьПараметр("Период", Дата);
	Запрос.УстановитьПараметр("Портфель", Портфель);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	ОсталосьСписатьКоличество = Количество;
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Если ОсталосьСписатьКоличество <> 0 Тогда
			Движения.АктивыОстатки.Записывать = Истина;
			Движение = Движения.АктивыОстатки.Добавить();
			Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
			Движение.Период = Дата;
			Движение.Портфель = Портфель;
			Движение.Актив = Актив;
			Движение.ДокументПартии = ВыборкаДетальныеЗаписи.ДокументПартии;
			
			Движение.Валюта = Актив.Валюта;
			Движение.Сумма = ВыборкаДетальныеЗаписи.СуммаОстаток;
			Движение.Количество = ВыборкаДетальныеЗаписи.КоличествоОстаток;	
		КонецЕсли;
	КонецЦикла;
	

	Движения.ОстаткиДенежныхСредств.Записывать = Истина;
	Движение = Движения.ОстаткиДенежныхСредств.Добавить();
	Движение.ВидДвижения = ВидДвиженияНакопления.Приход;;
	Движение.Период = Дата;
	Движение.ВидОперации = Перечисления.ВидыОперацийПриходРасходДенежныхСредств.ПродажаАктива;
	Движение.Портфель = Портфель;
	
	Движение.Валюта = Актив.Валюта;
	Движение.Сумма = Сумма;
	
	Если СуммаКомиссии <> 0 тогда
		Движения.ОстаткиДенежныхСредств.Записывать = Истина;
		Движение = Движения.ОстаткиДенежныхСредств.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = Дата;
		Движение.ВидОперации = Перечисления.ВидыОперацийПриходРасходДенежныхСредств.КомиссияБрокера;		
		Движение.Портфель = Портфель;
		
		Движение.Валюта = Актив.Валюта;
		Движение.Сумма = СуммаКомиссии;
	КонецЕсли;
	
	Если НКД <> 0 тогда
		Движения.ОстаткиДенежныхСредств.Записывать = Истина;
		Движение = Движения.ОстаткиДенежныхСредств.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Период = Дата;
		Движение.ВидОперации = Перечисления.ВидыОперацийПриходРасходДенежныхСредств.НКД;		
		Движение.Портфель = Портфель;
		
		Движение.Валюта = Актив.Валюта;
		Движение.Сумма = НКД;
	КонецЕсли;
	
КонецПроцедуры



