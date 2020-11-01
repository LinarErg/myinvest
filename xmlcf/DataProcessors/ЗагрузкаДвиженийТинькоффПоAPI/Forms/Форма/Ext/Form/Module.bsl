﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Объект.НачалоПериода = ХранилищеОбщихНастроек.Загрузить("НастройкаЗагрузкиДвиженийТинькофф","ДатаПоследнегоПолучения");	
	Объект.КонецПериода = ТекущаяДата();
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьРегистрСделокТинькофф(Команда)
	
	ИнтеграцияСТинькоффПоAPIСервер.ЗаполнитьРегистрСделок(Объект.Портфель,?(ЗначениеЗаполнено(Объект.НачалоПериода),Объект.НачалоПериода,Неопределено),?(ЗначениеЗаполнено(Объект.КонецПериода),Объект.КонецПериода,Неопределено));
	СохранитьДатуПоследнегоПолучения();
	
КонецПроцедуры

&НаСервере
Процедура СохранитьДатуПоследнегоПолучения()
	
	ХранилищеОбщихНастроек.Сохранить("НастройкаЗагрузкиДвиженийТинькофф","ДатаПоследнегоПолучения",ТекущаяДата());
	
КонецПроцедуры

&НаСервере
Функция ПолучитьДатуВФормате1С(ДатаСтрока)
	
	ДатаСтрока = СтрЗаменить(ДатаСтрока,"-","");
	ДатаСтрока = СтрЗаменить(ДатаСтрока,"T","");
	ДатаСтрока = СтрЗаменить(ДатаСтрока,":","");
	ДатаСтрока = Лев(ДатаСтрока,14);
	
	Возврат Дата(ДатаСтрока);
	
КонецФункции

&НаСервере
Функция НайтиАктив(figi,currency)
	
	Если ЗначениеЗаполнено(figi) тогда
		Актив = Справочники.Активы.НайтиПоРеквизиту("figi",figi);
		Если ЗначениеЗаполнено(Актив) тогда
			Возврат Актив;
		Иначе
			Актив = Справочники.Валюта.НайтиПоРеквизиту("figi",figi);
			Если ЗначениеЗаполнено(Актив) тогда
				Возврат Актив;	
			Иначе				
				НоваяСтрока = ТаблицаНеНайденныхАктивов.Добавить();
				НоваяСтрока.Обработать = Истина;
				НоваяСтрока.Figi = figi;
			КонецЕсли;			
		КонецЕсли;
	Иначе
		Возврат Справочники.Валюта.НайтиПоНаименованию(currency);
	КонецЕсли;
	
КонецФункции

&НаСервере
Функция НайтиДокументСделки(id)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПополнениеВыводСБрокерскогоСчета.Ссылка КАК Ссылка
		|ИЗ
		|	Документ.ПополнениеВыводСБрокерскогоСчета КАК ПополнениеВыводСБрокерскогоСчета
		|ГДЕ
		|	НЕ ПополнениеВыводСБрокерскогоСчета.ПометкаУдаления
		|	И ПополнениеВыводСБрокерскогоСчета.Портфель = &Портфель
		|	И ПополнениеВыводСБрокерскогоСчета.НомерРаспоряжения = &НомерСделки
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ПриобретениеАктива.Ссылка
		|ИЗ
		|	Документ.ПриобретениеАктива КАК ПриобретениеАктива
		|ГДЕ
		|	НЕ ПриобретениеАктива.ПометкаУдаления
		|	И ПриобретениеАктива.Портфель = &Портфель
		|	И ПриобретениеАктива.НомерСделки = &НомерСделки
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ПриобретениеВалюты.Ссылка
		|ИЗ
		|	Документ.ПриобретениеВалюты КАК ПриобретениеВалюты
		|ГДЕ
		|	НЕ ПриобретениеВалюты.ПометкаУдаления
		|	И ПриобретениеВалюты.Портфель = &Портфель
		|	И ПриобретениеВалюты.НомерСделки = &НомерСделки
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ПродажаАктива.Ссылка
		|ИЗ
		|	Документ.ПродажаАктива КАК ПродажаАктива
		|ГДЕ
		|	НЕ ПродажаАктива.ПометкаУдаления
		|	И ПродажаАктива.Портфель = &Портфель
		|	И ПродажаАктива.НомерСделки = &НомерСделки
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ПродажаВалюты.Ссылка
		|ИЗ
		|	Документ.ПродажаВалюты КАК ПродажаВалюты
		|ГДЕ
		|	НЕ ПродажаВалюты.ПометкаУдаления
		|	И ПродажаВалюты.Портфель = &Портфель
		|	И ПродажаВалюты.НомерСделки = &НомерСделки
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ВыплатаДивидендовКупонов.Ссылка
		|ИЗ
		|	Документ.ВыплатаДивидендовКупонов КАК ВыплатаДивидендовКупонов
		|ГДЕ
		|	НЕ ВыплатаДивидендовКупонов.ПометкаУдаления
		|	И ВыплатаДивидендовКупонов.Портфель = &Портфель
		|	И ВыплатаДивидендовКупонов.НомерСделки = &НомерСделки";
	
	Запрос.УстановитьПараметр("Портфель", Объект.Портфель);
	Запрос.УстановитьПараметр("НомерСделки", id);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Возврат ВыборкаДетальныеЗаписи.Ссылка;
	КонецЦикла;
	
	Возврат Неопределено;
	
КонецФункции

&НаСервере
Процедура ОбновитьТаблицуСделокНаСервере()

	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	СделкиТинькофф.Портфель КАК Портфель,
		|	СделкиТинькофф.id КАК id,
		|	СделкиТинькофф.status КАК status,
		|	СделкиТинькофф.currency КАК currency,
		|	СделкиТинькофф.figi КАК figi,
		|	СделкиТинькофф.date КАК date,
		|	СделкиТинькофф.isMarginCall КАК isMarginCall,
		|	СделкиТинькофф.quantityExecuted КАК quantityExecuted,
		|	СделкиТинькофф.payment КАК payment,
		|	СделкиТинькофф.operationType КАК operationType,
		|	СделкиТинькофф.quantity КАК quantity,
		|	СделкиТинькофф.price КАК price,
		|	СделкиТинькофф.instrumentType КАК instrumentType,
		|	СделкиТинькофф.СтрокаОбработана КАК СтрокаОбработана
		|ИЗ
		|	РегистрСведений.СделкиТинькофф КАК СделкиТинькофф
		|ГДЕ
		|	ВЫБОР
		|			КОГДА &ПоказатьВсе = ИСТИНА
		|				ТОГДА ИСТИНА
		|			ИНАЧЕ СделкиТинькофф.СтрокаОбработана = ЛОЖЬ
		|		КОНЕЦ
		|	И СделкиТинькофф.Портфель = &Портфель
		|
		|УПОРЯДОЧИТЬ ПО
		|	date";
	
	Запрос.УстановитьПараметр("Портфель", Объект.Портфель);
	Запрос.УстановитьПараметр("ПоказатьВсе", НЕ Объект.ТолькоНеОбработанные);
	ТаблицаЗагруженныхСделок = Запрос.Выполнить().Выгрузить();
	
	ТаблицаСделок.Очистить();
	ТаблицаНеНайденныхАктивов.Очистить();
	
	Для каждого СтрокаТаблицы из ТаблицаЗагруженныхСделок цикл
		Если СтрокаТаблицы.status = "Decline" тогда
			Продолжить;
		КонецЕсли;
		
		ДокументСделки = НайтиДокументСделки(СтрокаТаблицы.id);
		
		Если Объект.ТолькоНеОбработанные тогда
			Если ДокументСделки <> Неопределено тогда
				Продолжить;
			КонецЕсли;
		КонецЕсли;				
		
		НоваяСтрока = ТаблицаСделок.Добавить();
		НоваяСтрока.НомерСделки 	= СтрокаТаблицы.id;		
		НоваяСтрока.ДатаВремяСделки = ПолучитьДатуВФормате1С(СтрокаТаблицы.date);
		НоваяСтрока.ВидСделки 		= СтрокаТаблицы.operationType;
		НоваяСтрока.Актив			= НайтиАктив(СтрокаТаблицы.figi,СтрокаТаблицы.currency);
		НоваяСтрока.ВалютаСделки	= Справочники.Валюта.НайтиПоНаименованию(СтрокаТаблицы.currency);
		НоваяСтрока.Количество		= СтрокаТаблицы.quantity;
		НоваяСтрока.Цена		 	= СтрокаТаблицы.price;
		НоваяСтрока.СуммаСНКД 		= ?(СтрокаТаблицы.payment < 0,СтрокаТаблицы.payment * -1,СтрокаТаблицы.payment);
		НоваяСтрока.ДокументСделки 	= ДокументСделки;
	КонецЦикла;
	
	ТаблицаСделокВременная = ТаблицаСделок.Выгрузить();
	ТаблицаСделокВременная.Сортировать("ДатаВремяСделки Возр");
	ТаблицаСделок.Загрузить(ТаблицаСделокВременная);
	
	ТаблицаНеНайденныхАктивовВременная = ТаблицаНеНайденныхАктивов.Выгрузить();
	ТаблицаНеНайденныхАктивовВременная.Свернуть("Figi,ИмяАктива,Тикер,ВидАктива,Обработать");
	ТаблицаНеНайденныхАктивов.Загрузить(ТаблицаНеНайденныхАктивовВременная);
	
	ЗаполнитьТаблицуОтсутствующихАктивовВСправочнике();
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТаблицуОтсутствующихАктивовВСправочнике()
	
	Если ТаблицаНеНайденныхАктивов.Количество() = 0 тогда
		Возврат;
	КонецЕсли;
	
	ТаблицаИнструментовБиржи = ИнтеграцияСТинькоффПоAPIСервер.ПолучитьСписокДоступныхИнструментовБрокера(ИнтеграцияСТинькоффПоAPIСервер.ТокенПоПортфелю(Объект.Портфель));
	Для каждого СтрокаТаблицы из ТаблицаНеНайденныхАктивов цикл
		НайденнаяСтрока = ТаблицаИнструментовБиржи.Найти(СтрокаТаблицы.figi,"figi");
		Если НайденнаяСтрока <> Неопределено тогда
			СтрокаТаблицы.ИмяАктива = НайденнаяСтрока.name;
			СтрокаТаблицы.Тикер = НайденнаяСтрока.ticker;
			ВидАктива = Перечисления.ВидАктива.ПустаяСсылка();
			Если НайденнаяСтрока.type = "Stock" Тогда 
				СтрокаТаблицы.ВидАктива = Перечисления.ВидАктива.Акция;
			ИначеЕсли НайденнаяСтрока.type = "Etf" Тогда 
				СтрокаТаблицы.ВидАктива = Перечисления.ВидАктива.ETF;
			ИначеЕсли НайденнаяСтрока.type = "bond" Тогда 
				СтрокаТаблицы.ВидАктива = Перечисления.ВидАктива.Облигация;
			КонецЕсли;
		КонецЕсли;		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьТаблицуСделок(Команда)
	
	ОбновитьТаблицуСделокНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура СоздатьДокументыОтраженияВУчетеНаСервере()
	// + PayIn — Пополнение брокерского счета
	// + PayOut — Вывод денег
	//BuyCard — Покупка с карты
	// + Sell — Продажа
	// + BrokerCommission — Комиссия брокера
	//Dividend — Выплата дивидендов
	//Tax — Налоги
	//TaxDividend- Налоги c дивидендов
	//ServiceCommission — Комиссия за обслуживание
	//Coupon
	
	Для каждого СтрокаТаблицы из ТаблицаСделок Цикл 
		Если НЕ ЗначениеЗаполнено(СтрокаТаблицы.Актив) Тогда
			Продолжить;
		КонецЕсли;		
		
		Если СтрокаТаблицы.ВидСделки = "PayIn" Тогда //Пополнение брокерского счета
			
			#Область ПополнениеБрокерскогоСчета
			
			Если НЕ Объект.ПерезаписыватьСуществующиеДокументы И ЗначениеЗаполнено(СтрокаТаблицы.ДокументСделки) тогда
				Продолжить;	
			ИначеЕсли Объект.ПерезаписыватьСуществующиеДокументы И ЗначениеЗаполнено(СтрокаТаблицы.ДокументСделки) тогда
				НовыйДокумент = СтрокаТаблицы.ДокументСделки.ПолучитьОбъект();	
			ИначеЕсли НЕ ЗначениеЗаполнено(СтрокаТаблицы.ДокументСделки) тогда
				НовыйДокумент = Документы.ПополнениеВыводСБрокерскогоСчета.СоздатьДокумент();	
			КонецЕсли;			
			НовыйДокумент.Дата 				= СтрокаТаблицы.ДатаВремяСделки;
			НовыйДокумент.Портфель 			= Объект.Портфель;
			НовыйДокумент.ВидОперации 		= Перечисления.ВидОперацииПополнениеВыводСБрокерскогоСчета.Пополнение;
			НовыйДокумент.Валюта 			= СтрокаТаблицы.ВалютаСделки;
			НовыйДокумент.НомерРаспоряжения = СтрокаТаблицы.НомерСделки;
			НовыйДокумент.Сумма 			= СтрокаТаблицы.СуммаСНКД;
			НовыйДокумент.Комментарий 		= "#Создан автоматически загрузкой по API";
			
			Попытка
				НовыйДокумент.Записать(РежимЗаписиДокумента.Проведение);
				СтрокаТаблицы.ДокументСделки = НовыйДокумент.Ссылка;
			Исключение
				Сообщение = Новый СообщениеПользователю;
				Сообщение.Текст = "Не удалось провести документ по id: " + Строка(СтрокаТаблицы.НомерСделки);
				Сообщение.Сообщить();
				
				Попытка
					НовыйДокумент.Записать(РежимЗаписиДокумента.Запись);
					СтрокаТаблицы.ДокументСделки = НовыйДокумент.Ссылка;
				Исключение
					Сообщение = Новый СообщениеПользователю;
					Сообщение.Текст = "Не удалось записать документ по id: " + Строка(СтрокаТаблицы.НомерСделки);
					Сообщение.Сообщить();	
				КонецПопытки;
				
			КонецПопытки;
			
			#КонецОбласти
			
		ИначеЕсли СтрокаТаблицы.ВидСделки = "PayOut" Тогда //Вывод с брокерского счета
			
			#Область ВыводСБрокерскогоСчета
			
			Если НЕ Объект.ПерезаписыватьСуществующиеДокументы И ЗначениеЗаполнено(СтрокаТаблицы.ДокументСделки) тогда
				Продолжить;	
			ИначеЕсли Объект.ПерезаписыватьСуществующиеДокументы И ЗначениеЗаполнено(СтрокаТаблицы.ДокументСделки) тогда
				НовыйДокумент = СтрокаТаблицы.ДокументСделки.ПолучитьОбъект();	
			ИначеЕсли НЕ ЗначениеЗаполнено(СтрокаТаблицы.ДокументСделки) тогда
				НовыйДокумент = Документы.ПополнениеВыводСБрокерскогоСчета.СоздатьДокумент();	
			КонецЕсли;
			
			НовыйДокумент.Дата 				= СтрокаТаблицы.ДатаВремяСделки;
			НовыйДокумент.Портфель 			= Объект.Портфель;
			НовыйДокумент.ВидОперации 		= Перечисления.ВидОперацииПополнениеВыводСБрокерскогоСчета.Вывод;
			НовыйДокумент.Валюта 			= СтрокаТаблицы.ВалютаСделки;
			НовыйДокумент.НомерРаспоряжения = СтрокаТаблицы.НомерСделки;
			НовыйДокумент.Сумма 			= СтрокаТаблицы.СуммаСНКД;
			НовыйДокумент.Комментарий 		= "#Создан автоматически загрузкой по API";
			
			СтрокаНалога = НайтиСтрокуДополненияКСделке(Неопределено,СтрокаТаблицы.ДатаВремяСделки, "Tax");
			Если СтрокаНалога <> Неопределено тогда
				НовыйДокумент.СуммаУдержанногоНалога = СтрокаНалога.СуммаСНКД;	
			КонецЕсли;
			
			Попытка
				НовыйДокумент.Записать(РежимЗаписиДокумента.Проведение);
				СтрокаТаблицы.ДокументСделки = НовыйДокумент.Ссылка;
			Исключение
				Сообщение = Новый СообщениеПользователю;
				Сообщение.Текст = "Не удалось провести документ по id: " + Строка(СтрокаТаблицы.НомерСделки);
				Сообщение.Сообщить();
				
				Попытка
					НовыйДокумент.Записать(РежимЗаписиДокумента.Запись);
					СтрокаТаблицы.ДокументСделки = НовыйДокумент.Ссылка;
				Исключение
					Сообщение = Новый СообщениеПользователю;
					Сообщение.Текст = "Не удалось записать документ по id: " + Строка(СтрокаТаблицы.НомерСделки);
					Сообщение.Сообщить();	
				КонецПопытки;
				
			КонецПопытки;
			
			#КонецОбласти
			
		ИначеЕсли СтрокаТаблицы.ВидСделки = "Buy" Тогда //Покупка на брокерский счет
			
			#Область ПокупкаАктиваВалюты

			Если ТипЗнч(СтрокаТаблицы.Актив) = Тип("СправочникСсылка.Валюта") тогда
				
				Если НЕ Объект.ПерезаписыватьСуществующиеДокументы И ЗначениеЗаполнено(СтрокаТаблицы.ДокументСделки) тогда
					Продолжить;	
				ИначеЕсли Объект.ПерезаписыватьСуществующиеДокументы И ЗначениеЗаполнено(СтрокаТаблицы.ДокументСделки) тогда
					НовыйДокумент = СтрокаТаблицы.ДокументСделки.ПолучитьОбъект();	
				ИначеЕсли НЕ ЗначениеЗаполнено(СтрокаТаблицы.ДокументСделки) тогда
					НовыйДокумент = Документы.ПриобретениеВалюты.СоздатьДокумент();	
				КонецЕсли;	 
				
				НовыйДокумент.Дата 				= СтрокаТаблицы.ДатаВремяСделки;
				НовыйДокумент.Портфель 			= Объект.Портфель;
				НовыйДокумент.ВалютаСписания	= СтрокаТаблицы.ВалютаСделки;
				НовыйДокумент.ВалютаПриобретения= СтрокаТаблицы.Актив;				
				НовыйДокумент.Цена 				= СтрокаТаблицы.Цена;
				НовыйДокумент.СуммаСписания 	= СтрокаТаблицы.СуммаСНКД;				
				НовыйДокумент.СуммаПриобретения	= СтрокаТаблицы.Количество;
				НовыйДокумент.НомерСделки 		= СтрокаТаблицы.НомерСделки;
				НовыйДокумент.Комментарий 		= "#Создан автоматически загрузкой по API";
				
				СтрокаКомиссии = НайтиСтрокуДополненияКСделке(СтрокаТаблицы.Актив,СтрокаТаблицы.ДатаВремяСделки, "BrokerCommission");
				Если СтрокаКомиссии <> Неопределено тогда
					НовыйДокумент.СуммаКомиссии  = СтрокаКомиссии.СуммаСНКД;
					НовыйДокумент.ВалютаКомиссии = СтрокаКомиссии.ВалютаСделки;
				КонецЕсли;
							
				Попытка
					НовыйДокумент.Записать(РежимЗаписиДокумента.Проведение);
					СтрокаТаблицы.ДокументСделки = НовыйДокумент.Ссылка;
				Исключение
					Сообщение = Новый СообщениеПользователю;
					Сообщение.Текст = "Не удалось провести документ по id: " + Строка(СтрокаТаблицы.НомерСделки);
					Сообщение.Сообщить();
					
					Попытка
						НовыйДокумент.Записать(РежимЗаписиДокумента.Запись);
						СтрокаТаблицы.ДокументСделки = НовыйДокумент.Ссылка;
					Исключение
						Сообщение = Новый СообщениеПользователю;
						Сообщение.Текст = "Не удалось записать документ по id: " + Строка(СтрокаТаблицы.НомерСделки);
						Сообщение.Сообщить();	
					КонецПопытки;
					
				КонецПопытки;
			
			ИначеЕсли ТипЗнч(СтрокаТаблицы.Актив) = Тип("СправочникСсылка.Активы") тогда
				
				Если НЕ Объект.ПерезаписыватьСуществующиеДокументы И ЗначениеЗаполнено(СтрокаТаблицы.ДокументСделки) тогда
					Продолжить;	
				ИначеЕсли Объект.ПерезаписыватьСуществующиеДокументы И ЗначениеЗаполнено(СтрокаТаблицы.ДокументСделки) тогда
					НовыйДокумент = СтрокаТаблицы.ДокументСделки.ПолучитьОбъект();	
				ИначеЕсли НЕ ЗначениеЗаполнено(СтрокаТаблицы.ДокументСделки) тогда
					НовыйДокумент = Документы.ПриобретениеАктива.СоздатьДокумент();	
				КонецЕсли;	 
				
				НовыйДокумент.Дата 			= СтрокаТаблицы.ДатаВремяСделки;
				НовыйДокумент.Актив 		= СтрокаТаблицы.Актив;
				НовыйДокумент.Портфель 		= Объект.Портфель;
				НовыйДокумент.Сумма 		= СтрокаТаблицы.СуммаСНКД;
				НовыйДокумент.Количество	= СтрокаТаблицы.Количество;
				НовыйДокумент.НомерСделки 	= СтрокаТаблицы.НомерСделки;
				НовыйДокумент.ВалютаСделки 	= СтрокаТаблицы.ВалютаСделки;
				НовыйДокумент.Комментарий 	= "#Создан автоматически загрузкой по API";
				
				СтрокаКомиссии = НайтиСтрокуДополненияКСделке(СтрокаТаблицы.Актив,СтрокаТаблицы.ДатаВремяСделки, "BrokerCommission");
				Если СтрокаКомиссии <> Неопределено тогда
					НовыйДокумент.СуммаКомиссии = СтрокаКомиссии.СуммаСНКД;	
				КонецЕсли;
				
				Если НовыйДокумент.Актив.Вид = Перечисления.ВидАктива.Облигация тогда
					НКД = СтрокаТаблицы.СуммаСНКД - (СтрокаТаблицы.Цена * СтрокаТаблицы.Количество);
					НовыйДокумент.НКД = НКД;
				КонецЕсли;				
							
				Попытка
					НовыйДокумент.Записать(РежимЗаписиДокумента.Проведение);
					СтрокаТаблицы.ДокументСделки = НовыйДокумент.Ссылка;
				Исключение
					Сообщение = Новый СообщениеПользователю;
					Сообщение.Текст = "Не удалось провести документ по id: " + Строка(СтрокаТаблицы.НомерСделки);
					Сообщение.Сообщить();
					
					Попытка
						НовыйДокумент.Записать(РежимЗаписиДокумента.Запись);
						СтрокаТаблицы.ДокументСделки = НовыйДокумент.Ссылка;
					Исключение
						Сообщение = Новый СообщениеПользователю;
						Сообщение.Текст = "Не удалось записать документ по id: " + Строка(СтрокаТаблицы.НомерСделки);
						Сообщение.Сообщить();	
					КонецПопытки;
					
				КонецПопытки;
		
			КонецЕсли;			
			
			#КонецОбласти
			
		ИначеЕсли СтрокаТаблицы.ВидСделки = "Sell" Тогда //Продажа с брокерского счета
			
			#Область ПродажаАктиваВалюты

			Если ТипЗнч(СтрокаТаблицы.Актив) = Тип("СправочникСсылка.Валюта") тогда
				
				Сообщение = Новый СообщениеПользователю;
				Сообщение.Текст = "Примеров продажи валюты на Тинькофф нет";
				Сообщение.Сообщить();
				
				//Если НЕ Объект.ПерезаписыватьСуществующиеДокументы И ЗначениеЗаполнено(СтрокаТаблицы.ДокументСделки) тогда
				//	Продолжить;	
				//ИначеЕсли Объект.ПерезаписыватьСуществующиеДокументы И ЗначениеЗаполнено(СтрокаТаблицы.ДокументСделки) тогда
				//	НовыйДокумент = СтрокаТаблицы.ДокументСделки.ПолучитьОбъект();	
				//ИначеЕсли НЕ ЗначениеЗаполнено(СтрокаТаблицы.ДокументСделки) тогда
				//	НовыйДокумент = Документы.ПродажаВалюты.СоздатьДокумент();	
				//КонецЕсли;	 
				//
				//НовыйДокумент.Дата 				= СтрокаТаблицы.ДатаВремяСделки;
				//НовыйДокумент.Портфель 			= Объект.Портфель;
				//НовыйДокумент.ВалютаСписания	= СтрокаТаблицы.ВалютаСделки;
				//НовыйДокумент.ВалютаПриобретения= СтрокаТаблицы.Актив;				
				//НовыйДокумент.Цена 				= СтрокаТаблицы.Цена;
				//НовыйДокумент.СуммаСписания 	= СтрокаТаблицы.СуммаСНКД;				
				//НовыйДокумент.СуммаПриобретения	= СтрокаТаблицы.Количество;
				//НовыйДокумент.НомерСделки 		= СтрокаТаблицы.Актив;
				//НовыйДокумент.Комментарий 		= "#Создан автоматически загрузкой по API";
				//
				//СтрокаКомиссии = НайтиСтрокуДополненияКСделке(СтрокаТаблицы.Актив,СтрокаТаблицы.ДатаВремяСделки, "BrokerCommission");
				//Если СтрокаНалога <> Неопределено тогда
				//	НовыйДокумент.СуммаКомиссии  = СтрокаКомиссии.СуммаСНКД;
				//	НовыйДокумент.ВалютаКомиссии = СтрокаКомиссии.ВалютаСделки;
				//КонецЕсли;
				
			ИначеЕсли ТипЗнч(СтрокаТаблицы.Актив) = Тип("СправочникСсылка.Активы") тогда
				
				Если НЕ Объект.ПерезаписыватьСуществующиеДокументы И ЗначениеЗаполнено(СтрокаТаблицы.ДокументСделки) тогда
					Продолжить;	
				ИначеЕсли Объект.ПерезаписыватьСуществующиеДокументы И ЗначениеЗаполнено(СтрокаТаблицы.ДокументСделки) тогда
					НовыйДокумент = СтрокаТаблицы.ДокументСделки.ПолучитьОбъект();	
				ИначеЕсли НЕ ЗначениеЗаполнено(СтрокаТаблицы.ДокументСделки) тогда
					НовыйДокумент = Документы.ПродажаАктива.СоздатьДокумент();	
				КонецЕсли;	 
				
				НовыйДокумент.Дата 			= СтрокаТаблицы.ДатаВремяСделки;
				НовыйДокумент.Актив 		= СтрокаТаблицы.Актив;
				НовыйДокумент.Портфель 		= Объект.Портфель;
				Если НовыйДокумент.Актив.Вид = Перечисления.ВидАктива.Облигация тогда
					НовыйДокумент.Сумма = СтрокаТаблицы.Цена * СтрокаТаблицы.Количество;
				Иначе
					НовыйДокумент.Сумма = СтрокаТаблицы.СуммаСНКД;
				КонецЕсли;
				НовыйДокумент.Количество	= СтрокаТаблицы.Количество;
				НовыйДокумент.НомерСделки 	= СтрокаТаблицы.НомерСделки;
				НовыйДокумент.ВалютаСделки 	= СтрокаТаблицы.ВалютаСделки;
				НовыйДокумент.Комментарий 	= "#Создан автоматически загрузкой по API";
				
				СтрокаКомиссии = НайтиСтрокуДополненияКСделке(СтрокаТаблицы.Актив,СтрокаТаблицы.ДатаВремяСделки, "BrokerCommission");
				Если СтрокаКомиссии <> Неопределено тогда
					НовыйДокумент.СуммаКомиссии = СтрокаКомиссии.СуммаСНКД;	
				КонецЕсли;
				
				Если НовыйДокумент.Актив.Вид = Перечисления.ВидАктива.Облигация тогда
					НКД = СтрокаТаблицы.СуммаСНКД - (СтрокаТаблицы.Цена * СтрокаТаблицы.Количество);
					НовыйДокумент.НКД = НКД;
				КонецЕсли;
				
				Попытка
					НовыйДокумент.Записать(РежимЗаписиДокумента.Проведение);
					СтрокаТаблицы.ДокументСделки = НовыйДокумент.Ссылка;
				Исключение
					Сообщение = Новый СообщениеПользователю;
					Сообщение.Текст = "Не удалось провести документ по id: " + Строка(СтрокаТаблицы.НомерСделки);
					Сообщение.Сообщить();
					
					Попытка
						НовыйДокумент.Записать(РежимЗаписиДокумента.Запись);
						СтрокаТаблицы.ДокументСделки = НовыйДокумент.Ссылка;
					Исключение
						Сообщение = Новый СообщениеПользователю;
						Сообщение.Текст = "Не удалось записать документ по id: " + Строка(СтрокаТаблицы.НомерСделки);
						Сообщение.Сообщить();	
					КонецПопытки;
					
			КонецПопытки;
				
			КонецЕсли;			
			
			#КонецОбласти

		ИначеЕсли СтрокаТаблицы.ВидСделки = "Dividend" Тогда //Получение дивидендов
			
			Если НЕ Объект.ПерезаписыватьСуществующиеДокументы И ЗначениеЗаполнено(СтрокаТаблицы.ДокументСделки) тогда
				Продолжить;	
			ИначеЕсли Объект.ПерезаписыватьСуществующиеДокументы И ЗначениеЗаполнено(СтрокаТаблицы.ДокументСделки) тогда
				НовыйДокумент = СтрокаТаблицы.ДокументСделки.ПолучитьОбъект();	
			ИначеЕсли НЕ ЗначениеЗаполнено(СтрокаТаблицы.ДокументСделки) тогда
				НовыйДокумент = Документы.ВыплатаДивидендовКупонов.СоздатьДокумент();	
			КонецЕсли;	 
			
			НовыйДокумент.Дата 			= СтрокаТаблицы.ДатаВремяСделки;
			НовыйДокумент.Актив 		= СтрокаТаблицы.Актив;
			НовыйДокумент.Портфель 		= Объект.Портфель;
			НовыйДокумент.НомерСделки 	= СтрокаТаблицы.НомерСделки;
			НовыйДокумент.Валюта	 	= СтрокаТаблицы.ВалютаСделки;
			НовыйДокумент.Сумма	 		= СтрокаТаблицы.СуммаСНКД;
			НовыйДокумент.Комментарий 	= "#Создан автоматически загрузкой по API";
			
			СтрокаНалога = НайтиСтрокуДополненияКСделке(СтрокаТаблицы.Актив,СтрокаТаблицы.ДатаВремяСделки, "TaxDividend");
			Если СтрокаНалога <> Неопределено тогда
				НовыйДокумент.СуммаНалога = СтрокаНалога.СуммаСНКД;	
			КонецЕсли;
						
			Попытка
				НовыйДокумент.Записать(РежимЗаписиДокумента.Проведение);
				СтрокаТаблицы.ДокументСделки = НовыйДокумент.Ссылка;
			Исключение
				Сообщение = Новый СообщениеПользователю;
				Сообщение.Текст = "Не удалось провести документ по id: " + Строка(СтрокаТаблицы.НомерСделки);
				Сообщение.Сообщить();
				
				Попытка
					НовыйДокумент.Записать(РежимЗаписиДокумента.Запись);
					СтрокаТаблицы.ДокументСделки = НовыйДокумент.Ссылка;
				Исключение
					Сообщение = Новый СообщениеПользователю;
					Сообщение.Текст = "Не удалось записать документ по id: " + Строка(СтрокаТаблицы.НомерСделки);
					Сообщение.Сообщить();	
				КонецПопытки;
				
			КонецПопытки;
			
		КонецЕсли;		
	КонецЦикла;	
	
КонецПроцедуры

&НаКлиенте
Процедура СоздатьДокументыОтраженияВУчете(Команда)
	
	СоздатьДокументыОтраженияВУчетеНаСервере();
	
КонецПроцедуры

&НаСервере
Функция НайтиСтрокуДополненияКСделке(Актив,Период, ВидСделки)
	
	Если ВидСделки = "TaxDividend" тогда
		
		СтруктураОтбора = Новый Структура;
		СтруктураОтбора.Вставить("Актив", 		Актив);
		СтруктураОтбора.Вставить("ВидСделки", 	ВидСделки);
		
		МассивНайденныхСтрок = ТаблицаСделок.НайтиСтроки(СтруктураОтбора);
		
		МассивСтроки = Новый Массив;
		
		Для Каждого ЭлементМассива из МассивНайденныхСтрок Цикл 
			Если ЭлементМассива.ДатаВремяСделки < КонецДня(Период) Тогда 	
				МассивСтроки.Добавить(ЭлементМассива);
			КонецЕсли;
		КонецЦикла;
		
		Если МассивСтроки.Количество() = 0 Тогда
			Возврат Неопределено;
		ИначеЕсли МассивСтроки.Количество() = 1 Тогда
			Возврат МассивСтроки[0];
		ИначеЕсли МассивСтроки.Количество() > 1 Тогда 
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = "ААааАааААа!!! TaxDividend";
			Сообщение.Сообщить();
			Возврат Неопределено;
		КонецЕсли;
		
	Иначе
		
		СтруктураОтбора = Новый Структура;
		Если Актив <> Неопределено тогда
			СтруктураОтбора.Вставить("Актив", Актив);
		КонецЕсли;
		СтруктураОтбора.Вставить("ДатаВремяСделки", Период);
		СтруктураОтбора.Вставить("ВидСделки"	  , ВидСделки);
		
		МассивСтрок = ТаблицаСделок.НайтиСтроки(СтруктураОтбора);
		
		Если МассивСтрок.Количество() = 0 Тогда
			Возврат Неопределено;
		ИначеЕсли МассивСтрок.Количество() = 1 Тогда
			Возврат МассивСтрок[0];
		ИначеЕсли МассивСтрок.Количество() > 1 Тогда 
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = "ААааАааААа!!!";
			Сообщение.Сообщить();
			Возврат Неопределено;
		КонецЕсли;
		
	КонецЕсли;
	
КонецФункции

&НаСервере
Процедура СоздатьАктивыНаСервере()
	
	Для каждого СтрокаТаблицы из ТаблицаНеНайденныхАктивов цикл
		Если НЕ СтрокаТаблицы.Обработать тогда
			Продолжить;
		КонецЕсли;
		Если ЗначениеЗаполнено(СтрокаТаблицы.Актив) Тогда 
			Продолжить;
		КонецЕсли;
		
		НовыйАктив = Справочники.Активы.СоздатьЭлемент();
		НовыйАктив.figi = СтрокаТаблицы.figi;
		НовыйАктив.Вид = СтрокаТаблицы.ВидАктива;
		НовыйАктив.Наименование = СтрокаТаблицы.ИмяАктива;
		НовыйАктив.Тикер = СтрокаТаблицы.Тикер;
		НовыйАктив.Записать();
		
		СтрокаТаблицы.Актив = НовыйАктив.Ссылка;		
	КонецЦикла;

КонецПроцедуры

&НаКлиенте
Процедура СоздатьАктивы(Команда)
	
	СоздатьАктивыНаСервере();
	
КонецПроцедуры
