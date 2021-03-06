﻿
Процедура ОбработкаПроведения(Отказ, Режим)
	
	//СтруктураВозврата = ПолучитьТаблицуПартий(Отказ);
	//Для каждого СтрокаТаблицы из СтруктураВозврата.ТаблицаОстатки Цикл 
	//	// регистр ВыплатыКупоновДивидендов 
	//	Движения.ВыплатыКупоновДивидендов.Записывать = Истина;
	//	Движение = Движения.ВыплатыКупоновДивидендов.Добавить();
	//	Движение.Период = Дата;
	//	Движение.ДокументПартии = СтрокаТаблицы.ДокументПартии;
	//	Движение.Актив = Актив;
	//	Движение.Сумма = Сумма;
	//КонецЦикла;
	
	// регистр ОстаткиДенежныхСредств Приход
	//Приход дивидендов/купонов
	Движения.ОстаткиДенежныхСредств.Записывать = Истина;
	Движение = Движения.ОстаткиДенежныхСредств.Добавить();
	Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
	Движение.Период = Дата;
	Движение.Валюта = Валюта;
	Движение.Портфель = Портфель;
	Движение.Сумма = Сумма;
	
	Если СуммаНалога <> 0 тогда
		// регистр ОстаткиДенежныхСредств Приход
		//Списание налога дивидендов/купонов если есть
		Движения.ОстаткиДенежныхСредств.Записывать = Истина;
		Движение = Движения.ОстаткиДенежныхСредств.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = Дата + 1;
		Движение.Валюта = Валюта;
		Движение.Портфель = Портфель;
		Движение.Сумма = СуммаНалога;
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьТаблицуПартий(Отказ)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ИсторияДивидендовСрезПоследних.Период КАК Период,
		|	ИсторияДивидендовСрезПоследних.Актив КАК Актив,
		|	ИсторияДивидендовСрезПоследних.СуммаНаАкцию КАК СуммаНаАкцию,
		|	ИсторияДивидендовСрезПоследних.СуммаВключаетНалог КАК СуммаВключаетНалог
		|ИЗ
		|	РегистрСведений.ИсторияДивидендов.СрезПоследних(&Период, Актив = &Актив) КАК ИсторияДивидендовСрезПоследних";
	
	Запрос.УстановитьПараметр("Актив", Актив);
	Запрос.УстановитьПараметр("Период", Дата);
	
	ТаблицаИсторияДивидендов = Запрос.Выполнить().Выгрузить();
	Если ТаблицаИсторияДивидендов.Количество() = 0 тогда
		Отказ = Истина;
		Возврат Неопределено;
	КонецЕсли;

	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	АктивыОстаткиОстатки.Актив КАК Актив,
		|	АктивыОстаткиОстатки.Валюта КАК Валюта,
		|	АктивыОстаткиОстатки.Портфель КАК Портфель,
		|	АктивыОстаткиОстатки.ДокументПартии КАК ДокументПартии,
		|	АктивыОстаткиОстатки.СуммаОстаток КАК СуммаОстаток,
		|	АктивыОстаткиОстатки.КоличествоОстаток КАК КоличествоОстаток
		|ИЗ
		|	РегистрНакопления.АктивыОстатки.Остатки(
		|			&ДатаСрезаРеестра,
		|			Портфель = &Портфель
		|				И Актив = &Актив) КАК АктивыОстаткиОстатки";
	
	Запрос.УстановитьПараметр("Актив", Актив);
	Запрос.УстановитьПараметр("ДатаСрезаРеестра", КонецДня(ТаблицаИсторияДивидендов[0].Период));
	Запрос.УстановитьПараметр("Портфель", Портфель);
	
	ТаблицаОстатки = Запрос.Выполнить().Выгрузить();
	
	СтруктураВозврата = Новый Структура;
	СтруктураВозврата.Вставить("ТаблицаИсторияДивидендов",ТаблицаИсторияДивидендов);
	СтруктураВозврата.Вставить("ТаблицаОстатки",ТаблицаОстатки);
	
	Возврат СтруктураВозврата;
	
КонецФункции	

//// регистр ОстаткиДенежныхСредств Приход
//	Приход дивидендов/купонов
//	Движения.ОстаткиДенежныхСредств.Записывать = Истина;
//	Движение = Движения.ОстаткиДенежныхСредств.Добавить();
//	Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
//	Движение.Период = Дата;
//	Движение.Валюта = Валюта;
//	Движение.Портфель = Портфель;
//	Движение.Сумма = Сумма;

//// регистр ОстаткиДенежныхСредств Приход
//	Списание налога дивидендов/купонов если есть
//	Движения.ОстаткиДенежныхСредств.Записывать = Истина;
//	Движение = Движения.ОстаткиДенежныхСредств.Добавить();
//	Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
//	Движение.Период = Дата + 1;
//	Движение.Валюта = Валюта;
//	Движение.Портфель = Портфель;
//	Движение.Сумма = СуммаНалога;

	//// регистр ВыплатыКупоновДивидендов 
	//Движения.ВыплатыКупоновДивидендов.Записывать = Истина;
	//Движение = Движения.ВыплатыКупоновДивидендов.Добавить();
	//Движение.Период = Дата;
	//Движение.ДокументПартии = "";
	//Движение.Актив = Актив;
	//Движение.Сумма = Сумма;
