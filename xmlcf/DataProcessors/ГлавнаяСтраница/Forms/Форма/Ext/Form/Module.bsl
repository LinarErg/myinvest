﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ПортфельПриИзмененииНаСервере();
	
	//ПодключитьОбработчикОжидания("ПолучитьТаблицуТекущихЦен", 30);
	
КонецПроцедуры

&НаСервере
Процедура ПолучитьТаблицуТекущихЦен()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	АктивыОстатки.Актив КАК Актив
		|ИЗ
		|	РегистрНакопления.АктивыОстатки КАК АктивыОстатки
		|
		|СГРУППИРОВАТЬ ПО
		|	АктивыОстатки.Актив";
	
	МассивАктивов = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Актив");
	ТаблицаТекущихЦен.Загрузить(ИнтеграцияСТинькоффПоAPIСервер.ПолучитьТекущиеЦеныАктивов(МассивАктивов));
	
	СписокАктивы.КомпоновщикНастроек.Настройки.ДополнительныеСвойства.Вставить("ТаблицаТекущихЦен",ТаблицаТекущихЦен);
	
	Элементы.СписокАктивы.Обновить();
	
КонецПроцедуры

&НаСервере
Процедура ПортфельПриИзмененииНаСервере()

	Если ЗначениеЗаполнено(Объект.Портфель) тогда
		СписокАктивы.Параметры.УстановитьЗначениеПараметра("Портфель", Объект.Портфель);
	Иначе
		СписокАктивы.Параметры.УстановитьЗначениеПараметра("Портфель",Неопределено);	
	КонецЕсли;
	
	ПолучитьТаблицуТекущихЦен();
	
КонецПроцедуры

&НаКлиенте
Процедура ПортфельПриИзменении(Элемент)
	ПортфельПриИзмененииНаСервере();
КонецПроцедуры

&НаСервереБезКонтекста
Процедура СписокАктивыПриПолученииДанныхНаСервере(ИмяЭлемента, Настройки, Строки)
	
	//ТаблицаЦен = Новый ТаблицаЗначений;
	//Настройки.ДополнительныеСвойства.Свойство("ТаблицаТекущихЦен",ТаблицаЦен);
	//
	//ДанныеФормыВЗначение("ТаблицаЦен", Тип("ТаблицаЗначений"));
	//
	//Для каждого СтрокаСписка из Строки цикл
	//	СтрокаТекущейЦены = ТаблицаЦен.Найти(СтрокаСписка.Ключ, "Актив");
	//	СтрокаСписка.Значение.Данные.ТекущаяСтоимость = "";
	//	а = 1;
	//	
	//КонецЦикла;
	
КонецПроцедуры
