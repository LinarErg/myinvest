﻿
//Для примера брал статью
//https://habr.com/ru/post/496722/
//
//Примеры GET запросов
//https://tinkoffcreditsystems.github.io/invest-openapi/swagger-ui/#/


Функция ТокенПоПортфелю(Портфель) Экспорт
	
	Возврат Портфель.Токен;
	
КонецФункции

Функция ПолучитьПортфельПоУмолчаниюДляПолученияДанныхСБиржи() Экспорт 
	
	Возврат Константы.ПортфельПоУмолчанию.Получить();
	
КонецФункции

Функция ПолучитьДатуВФормате1С(ДатаСтрока) Экспорт
	
	ДатаСтрока = СтрЗаменить(ДатаСтрока,"-","");
	ДатаСтрока = СтрЗаменить(ДатаСтрока,"T","");
	ДатаСтрока = СтрЗаменить(ДатаСтрока,":","");
	ДатаСтрока = Лев(ДатаСтрока,14);
	
	Возврат Дата(ДатаСтрока);
	
КонецФункции

Функция ПолучитьОтветHTTPЗапроса(Метод, HTTPКоманда2, ПараметрыЗапроса = Неопределено, ОтправляемыеДанные = "", Токен) Экспорт 
	
	Если ПустаяСтрока(Токен) Тогда 
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не заполнен токен";
		Сообщение.Сообщить();
		Возврат Неопределено; 
	КонецЕсли;
	
	ЗащищенноеСоединениеOpenSSL = Новый ЗащищенноеСоединениеOpenSSL(,Новый СертификатыУдостоверяющихЦентровОС()); 
	
	Попытка
		HTTPСоединение = Новый HTTPСоединение("api-invest.tinkoff.ru",,,,,,ЗащищенноеСоединениеOpenSSL); 
	Исключение 
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не удалось установить соединение с сервером : " + ИнформацияОбОшибке().Описание;
		Сообщение.Сообщить();
		Возврат Неопределено; 
	КонецПопытки;
	
	ПараметрыHTTPЗапроса = Новый Соответствие; 
	ПараметрыHTTPЗапроса.Вставить("accept:", "application/json"); 
	ПараметрыHTTPЗапроса.Вставить("Content-Type:", "application/json");
	ПараметрыHTTPЗапроса.Вставить("Authorization","Bearer " + Токен); 
	
	Если НЕ ПараметрыЗапроса = Неопределено Тогда 
		Для Каждого ПараметрЗапроса Из ПараметрыЗапроса Цикл
			ПараметрыHTTPЗапроса.Вставить(ПараметрЗапроса.Ключ,ПараметрЗапроса.Значение); 
		КонецЦикла; 
	КонецЕсли;
	
	HTTPКоманда = "/openapi" + HTTPКоманда2; 
	HTTPЗапрос = Новый HTTPЗапрос(HTTPКоманда,ПараметрыHTTPЗапроса); 
	
	Если Метод = "GET" Тогда
		HTTPЗапрос.УстановитьТелоИзСтроки("",КодировкаТекста.UTF8, ИспользованиеByteOrderMark.НеИспользовать); 
		ОтветHTTPСоединения = HTTPСоединение.ВызватьHTTPМетод(Метод,HTTPЗапрос); 
	ИначеЕсли Метод = "POST" или Метод = "PATCH" или Метод = "PUT" Тогда
		ЗаписьJSON = Новый ЗаписьJSON; 
		ЗаписьJSON.УстановитьСтроку(); 
		ЗаписатьJSON(ЗаписьJSON, ОтправляемыеДанные, Новый НастройкиСериализацииJSON);
		СтрокаДляТела = ЗаписьJSON.Закрыть();
		HTTPЗапрос.УстановитьТелоИзСтроки(СтрокаДляТела);
		ОтветHTTPСоединения = HTTPСоединение.ОтправитьДляОбработки(HTTPЗапрос);
	КонецЕсли;
	
	ТекстОтвета = ОтветHTTPСоединения.ПолучитьТелоКакСтроку("UTF-8"); 
	HTTPСоединение = Неопределено;
	
	Если ПустаяСтрока(ТекстОтвета) Тогда 
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Нет ответа от сервера";
		Сообщение.Сообщить();
		Возврат Неопределено; 
	КонецЕсли; 
	
	Если ОтветHTTPСоединения.КодСостояния = 503 Тогда 
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Нет ответа от сервера, Код состояния 503";
		Сообщение.Сообщить();
		Возврат Неопределено; 
	ИначеЕсли ОтветHTTPСоединения.КодСостояния = 500 Тогда 
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Инструмент не найден,  Код состояния 500";
		Сообщение.Сообщить();
		Возврат Неопределено; 
	КонецЕсли; 
	
	Попытка
		ЧтениеJSON = Новый ЧтениеJSON; 
		ЧтениеJSON.УстановитьСтроку(ТекстОтвета); 
		ОтветJSONСоответствие = ПрочитатьJSON(ЧтениеJSON,Истина);
	Исключение Сообщить(Строка(ОтветHTTPСоединения.КодСостояния)); 
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не удалось прочитать ответ JSON: " + ОписаниеОшибки();
		Сообщение.Сообщить();
		Возврат Неопределено; 
	КонецПопытки; 
	
	Если ОтветHTTPСоединения.КодСостояния > 400 Тогда
		ОтветJSONpayload = ОтветJSONСоответствие.Получить("payload"); 
		Если ОтветJSONpayload = Неопределено Тогда 
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = HTTPКоманда2 + "код ошибки соединения: " + Строка(ОтветHTTPСоединения.КодСостояния);
			Сообщение.Сообщить();
		Иначе ОписаниеОшибки = ОтветJSONpayload.Получить("message"); 
			КодОшибки = ОтветJSONpayload.Получить("code");
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = ОписаниеОшибки + " Код ошибки: " + КодОшибки;
			Сообщение.Сообщить();
		КонецЕсли; 
		Возврат Неопределено;
	Иначе 
		Возврат ОтветJSONСоответствие; 
	КонецЕсли;
	
КонецФункции

Функция ПолучитьСписокДоступныхИнструментовБрокера(Токен,ИмяИнструмента = Неопределено) Экспорт
	
	ТаблицаИнструментов = Новый ТаблицаЗначений;
	ТаблицаИнструментов.Колонки.Добавить("market");
	ТаблицаИнструментов.Колонки.Добавить("figi");
	ТаблицаИнструментов.Колонки.Добавить("ticker");
	ТаблицаИнструментов.Колонки.Добавить("lot");
	ТаблицаИнструментов.Колонки.Добавить("currency");
	ТаблицаИнструментов.Колонки.Добавить("name");
	ТаблицаИнструментов.Колонки.Добавить("type");
	ТаблицаИнструментов.Колонки.Добавить("minPriceIncrement");
	
	Если ИмяИнструмента = Неопределено тогда
		
		//Акции
		ОтветЗапроса = ПолучитьОтветHTTPЗапроса("GET","/market/stocks",,,Токен); 
		Если ОтветЗапроса <> Неопределено Тогда 
			ЗаполнитьТаблицуИнструментовИзСоответсвия(ОтветЗапроса,ТаблицаИнструментов, "stocks");
		КонецЕсли;	
		
		//Облигации
		ОтветЗапроса = ПолучитьОтветHTTPЗапроса("GET","/market/bonds",,,Токен);
		Если ОтветЗапроса <> Неопределено Тогда 
			ЗаполнитьТаблицуИнструментовИзСоответсвия(ОтветЗапроса,ТаблицаИнструментов, "bonds");
		КонецЕсли; 
		
		//Фонды
		ОтветЗапроса = ПолучитьОтветHTTPЗапроса("GET","/market/etfs",,,Токен);
		Если ОтветЗапроса <> Неопределено Тогда 
			ЗаполнитьТаблицуИнструментовИзСоответсвия(ОтветЗапроса,ТаблицаИнструментов, "etfs");
		КонецЕсли;
		
		//Валюта
		ОтветЗапроса = ПолучитьОтветHTTPЗапроса("GET","/market/currencies",,,Токен);
		Если ОтветЗапроса <> Неопределено Тогда 
			ЗаполнитьТаблицуИнструментовИзСоответсвия(ОтветЗапроса,ТаблицаИнструментов, "currencies");
		КонецЕсли;
		
		Возврат ТаблицаИнструментов;
		
	Иначе
		
		ОтветЗапроса = ПолучитьОтветHTTPЗапроса("GET","/market/" + ИмяИнструмента,,,Токен); 
		Если ОтветЗапроса <> Неопределено Тогда 
			ЗаполнитьТаблицуИнструментовИзСоответсвия(ОтветЗапроса,ТаблицаИнструментов, ИмяИнструмента);
		КонецЕсли;
		
		Возврат ТаблицаИнструментов;
		
	КонецЕсли;
		
КонецФункции

Процедура ЗаполнитьТаблицуИнструментовИзСоответсвия(ОтветЗапроса, ТаблицаИнструментов, ВидИнструмента)
	
	МассивСоответствий = ОтветЗапроса.Получить("payload").Получить("instruments"); 
	Для Каждого ЭлементМассива Из МассивСоответствий Цикл
		НоваяСтрока = ТаблицаИнструментов.Добавить(); 
		НоваяСтрока.market  	= ВидИнструмента;
		НоваяСтрока.figi 		= ЭлементМассива["figi"];
		НоваяСтрока.ticker 		= ЭлементМассива["ticker"];		
		НоваяСтрока.lot 		= ЭлементМассива["lot"];
		НоваяСтрока.currency 	= ЭлементМассива["currency"]; 
		НоваяСтрока.name 		= ЭлементМассива["name"]; 
		НоваяСтрока.type 		= ЭлементМассива["type"];
		НоваяСтрока.minPriceIncrement = ЭлементМассива["minPriceIncrement"]; 
	КонецЦикла; 
	
КонецПроцедуры

Функция ПолучитьТаблицуДанныхСчета(Токен) Экспорт 
	
	ТаблицаДанныхСчета = Новый ТаблицаЗначений;
	ТаблицаДанныхСчета.Колонки.Добавить("currency");
	ТаблицаДанныхСчета.Колонки.Добавить("balance");
	ТаблицаДанныхСчета.Колонки.Добавить("blocked");
	
	СоответствиеОтвет = ПолучитьОтветHTTPЗапроса("GET","/portfolio/currencies",,,Токен); 
	Если СоответствиеОтвет = Неопределено	Тогда 
		Возврат ТаблицаДанныхСчета; 
	КонецЕсли;
	
	СоответствиеPayload = СоответствиеОтвет.Получить("payload");
	Если НЕ СоответствиеPayload.Получить("message") = Неопределено Тогда 
		СоответствиеMessage = СоответствиеPayload.Получить("message");
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = СоответствиеMessage;
		Сообщение.Сообщить();
		Возврат ТаблицаДанныхСчета; 
	КонецЕсли;
	
	СоответствиеПозиции = СоответствиеPayload.Получить("currencies"); 
	Для Каждого ЭлементСоответствия Из СоответствиеПозиции Цикл 
		НоваяСтрока = ТаблицаДанныхСчета.Добавить();
		НоваяСтрока.currency 	= ЭлементСоответствия.Получить("currency"); 
		НоваяСтрока.balance		= ЭлементСоответствия.Получить("balance"); 
		НоваяСтрока.blocked		= ЭлементСоответствия.Получить("blocked");
		//НоваяСтрока.Доступно		= НоваяСтрока.balance - НоваяСтрока.blocked; 
	КонецЦикла;
	
	Возврат ТаблицаДанныхСчета;
	
КонецФункции

Функция ПолучитьТаблицуДанныхПортфеля(Токен) Экспорт 
	
	ТаблицаДанныеПортфеля = Новый ТаблицаЗначений;
	ТаблицаДанныеПортфеля.Колонки.Добавить("name");
	ТаблицаДанныеПортфеля.Колонки.Добавить("ticker");
	ТаблицаДанныеПортфеля.Колонки.Добавить("lots");
	ТаблицаДанныеПортфеля.Колонки.Добавить("balance");
	ТаблицаДанныеПортфеля.Колонки.Добавить("blocked");
	ТаблицаДанныеПортфеля.Колонки.Добавить("value");
	
	СоответствиеОтвет = ПолучитьОтветHTTPЗапроса("GET","/portfolio",,,Токен); 
	Если СоответствиеОтвет = Неопределено Тогда 
		Возврат ТаблицаДанныеПортфеля; 
	КонецЕсли; 
	
	СоответствиеPayload = СоответствиеОтвет.Получить("payload");
	Если НЕ СоответствиеPayload.Получить("message") = Неопределено Тогда 
		СоответствиеMessage =СоответствиеPayload.Получить("message");
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = СоответствиеMessage;
		Сообщение.Сообщить(); 
		Возврат ТаблицаДанныеПортфеля; 
	КонецЕсли;
	
	СоответствиеПозиции = СоответствиеPayload.Получить("positions"); 
	Для Каждого ЭлементСоответствия Из СоответствиеПозиции Цикл 
		НоваяСтрока = ТаблицаДанныеПортфеля.Добавить();
		НоваяСтрока.name 	= ЭлементСоответствия.Получить("name"); 
		НоваяСтрока.ticker	= ЭлементСоответствия.Получить("ticker"); 
		НоваяСтрока.lots 	= ЭлементСоответствия.Получить("lots");
		НоваяСтрока.balance = ЭлементСоответствия.Получить("balance"); 
		НоваяСтрока.blocked = ЭлементСоответствия.Получить("blocked"); 
		СоответствиеСредняяЦена = ЭлементСоответствия.Получить("expectedYield");
		Если НЕ СоответствиеСредняяЦена = Неопределено Тогда 
			НоваяСтрока.value = СоответствиеСредняяЦена.Получить("value"); 
		КонецЕсли;
	КонецЦикла;
	
	Возврат ТаблицаДанныеПортфеля;
	
КонецФункции

Функция ПолучитьТаблицуОперацийПоПортфелю(Токен, НачалоПериода, КонецПериода) Экспорт
	
	ТаблицаДанныеСделок = Новый ТаблицаЗначений;
	ТаблицаДанныеСделок.Колонки.Добавить("instrumentType");
	ТаблицаДанныеСделок.Колонки.Добавить("price");
	ТаблицаДанныеСделок.Колонки.Добавить("quantity");
	ТаблицаДанныеСделок.Колонки.Добавить("operationType");
	ТаблицаДанныеСделок.Колонки.Добавить("payment");
	ТаблицаДанныеСделок.Колонки.Добавить("quantityExecuted");
	ТаблицаДанныеСделок.Колонки.Добавить("isMarginCall");
	ТаблицаДанныеСделок.Колонки.Добавить("date");
	ТаблицаДанныеСделок.Колонки.Добавить("figi");
	ТаблицаДанныеСделок.Колонки.Добавить("currency");
	ТаблицаДанныеСделок.Колонки.Добавить("status");
	ТаблицаДанныеСделок.Колонки.Добавить("id");
	
	НачалоПериодаВФорматеЗапроса = "&from=" + Формат(НачалоПериода,"ДФ=yyyy-MM-dd") + "T00%3A00%3A00%2B03%3A00";
	КонецПериодаВФорматеЗапроса = "&to=" + Формат(КонецПериода,"ДФ=yyyy-MM-dd") + "T23%3A59%3A59.00%2B03%3A00";
	СоответствиеОтвет = ПолучитьОтветHTTPЗапроса("GET","/operations?" + НачалоПериодаВФорматеЗапроса + КонецПериодаВФорматеЗапроса,,,Токен); 
	Если СоответствиеОтвет = Неопределено Тогда 
		Возврат ТаблицаДанныеСделок; 
	КонецЕсли;
	
	СоответствиеPayload = СоответствиеОтвет.Получить("payload");
	Если НЕ СоответствиеPayload.Получить("message") = Неопределено Тогда 
		СоответствиеMessage = СоответствиеPayload.Получить("message");
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = СоответствиеMessage;
		Сообщение.Сообщить(); 
		Возврат ТаблицаДанныеСделок; 
	КонецЕсли;
	
	СоответствиеПозиции = СоответствиеPayload.Получить("operations"); 
	Для Каждого ЭлементСоответствия Из СоответствиеПозиции Цикл
		НоваяСтрока = ТаблицаДанныеСделок.Добавить();
		НоваяСтрока.instrumentType 	= ЭлементСоответствия.Получить("instrumentType");
		НоваяСтрока.price 			= ЭлементСоответствия.Получить("price");
		НоваяСтрока.quantity 		= ЭлементСоответствия.Получить("quantity");
		НоваяСтрока.operationType 	= ЭлементСоответствия.Получить("operationType");
		НоваяСтрока.payment 		= ЭлементСоответствия.Получить("payment");
		НоваяСтрока.quantityExecuted= ЭлементСоответствия.Получить("quantityExecuted");
		НоваяСтрока.isMarginCall 	= ЭлементСоответствия.Получить("isMarginCall");
		НоваяСтрока.date 			= ЭлементСоответствия.Получить("date");
		НоваяСтрока.figi 			= ЭлементСоответствия.Получить("figi");
		НоваяСтрока.currency 		= ЭлементСоответствия.Получить("currency");
		НоваяСтрока.status 			= ЭлементСоответствия.Получить("status");
		НоваяСтрока.id 				= ЭлементСоответствия.Получить("id");
	КонецЦикла;
	
	Возврат ТаблицаДанныеСделок;
	
КонецФункции

Процедура ЗаполнитьРегистрСделок(Портфель, НачалоПериода = Неопределено, КонецПериода = Неопределено) Экспорт
	
	Токен = ТокенПоПортфелю(Портфель);
	
	Если НачалоПериода = Неопределено тогда
		НачалоПериода = ПолучитьДатуПоследнейЗагруженнойСделки(Портфель);
	КонецЕсли;
	
	Если КонецПериода = Неопределено тогда
		КонецПериода = ТекущаяДата();
	КонецЕсли;
	
	ТаблицаОпераций = ПолучитьТаблицуОперацийПоПортфелю(Токен,НачалоПериода,КонецПериода);
	
	Для каждого СтрокаОперации из ТаблицаОпераций цикл
		НаборЗаписей = РегистрыСведений.СделкиТинькофф.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.Портфель.Установить(Портфель);		
		НаборЗаписей.Отбор.id.Установить(СтрокаОперации.id);
		НаборЗаписей.Отбор.status.Установить(СтрокаОперации.status);
		НаборЗаписей.Отбор.currency.Установить(СтрокаОперации.currency);
		НаборЗаписей.Отбор.figi.Установить(СтрокаОперации.figi);
		НаборЗаписей.Отбор.date.Установить(СтрокаОперации.date);
		НаборЗаписей.Отбор.isMarginCall.Установить(?(СтрокаОперации.isMarginCall = "Истина",Истина,Ложь));
		НаборЗаписей.Отбор.quantityExecuted.Установить(?(СтрокаОперации.quantityExecuted = Неопределено,0,Число(СтрокаОперации.quantityExecuted)));
		НаборЗаписей.Отбор.payment.Установить(?(СтрокаОперации.payment = Неопределено,0,Число(СтрокаОперации.payment)));
		НаборЗаписей.Отбор.operationType.Установить(СтрокаОперации.operationType);
		НаборЗаписей.Отбор.quantity.Установить(?(СтрокаОперации.quantity = Неопределено,0,Число(СтрокаОперации.quantity)));
		НаборЗаписей.Отбор.price.Установить(?(СтрокаОперации.price = Неопределено,0,Число(СтрокаОперации.price)));
		НаборЗаписей.Отбор.instrumentType.Установить(СтрокаОперации.instrumentType);
		НаборЗаписей.Прочитать();
		
		Если НаборЗаписей.Количество() = 0 тогда
			НоваяЗапись = НаборЗаписей.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяЗапись,СтрокаОперации);
			НоваяЗапись.Портфель = Портфель;
			НаборЗаписей.Записать();
		КонецЕсли;
		
	КонецЦикла;
	
	
КонецПроцедуры

Функция ПолучитьДатуПоследнейЗагруженнойСделки(Портфель)
	
	//Запрос = Новый Запрос;
	//Запрос.Текст = 
	//	"ВЫБРАТЬ ПЕРВЫЕ 1
	//	|	СделкиТинькофф.Период КАК Период
	//	|ИЗ
	//	|	РегистрСведений.СделкиТинькофф КАК СделкиТинькофф
	//	|ГДЕ
	//	|	СделкиТинькофф.Портфель = &Портфель
	//	|
	//	|УПОРЯДОЧИТЬ ПО
	//	|	Период УБЫВ";
	//
	//Запрос.УстановитьПараметр("Портфель", Портфель);
	//
	//РезультатЗапроса = Запрос.Выполнить();
	//
	//ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	//
	//Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
	//	Возврат ВыборкаДетальныеЗаписи.Период;
	//КонецЦикла;
	
	Возврат Дата(2010,1,1,0,0,0);	
	
КонецФункции

Функция ПолучитьFIGIпоТикеру(Тикер) Экспорт
	
	Токен = ТокенПоПортфелю(ПолучитьПортфельПоУмолчаниюДляПолученияДанныхСБиржи());
	ТаблицаИнструментов = ПолучитьСписокДоступныхИнструментовБрокера(Токен);
	СтрокаТаблицы = ТаблицаИнструментов.Найти(Тикер,"ticker");
	Если СтрокаТаблицы = Неопределено тогда
		Возврат "";
	Иначе
		Возврат СтрокаТаблицы.figi;
	КонецЕсли;
	
КонецФункции

Процедура ЗагрузитьЦеныАктивов(НачалоПериода = Неопределено, КонецПериода = Неопределено, Интервал = Неопределено, Актив = Неопределено) Экспорт
	
	Токен = ТокенПоПортфелю(Константы.ПортфельПоУмолчанию.Получить());
	
	Если НачалоПериода = Неопределено тогда
		НачалоПериода = Дата(2020,1,1,0,0,0);	
	КонецЕсли;
	
	Если КонецПериода = Неопределено тогда
		КонецПериода = ТекущаяДата();
	КонецЕсли;
	
	Если Интервал = Неопределено тогда
		Интервал = "day";	
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Активы.Ссылка КАК Ссылка,
		|	Активы.figi КАК figi
		|ИЗ
		|	Справочник.Активы КАК Активы
		|ГДЕ
		|	ВЫБОР
		|			КОГДА &Ссылка = НЕОПРЕДЕЛЕНО
		|				ТОГДА ИСТИНА
		|			ИНАЧЕ Активы.Ссылка = &Ссылка
		|		КОНЕЦ
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	Валюта.Ссылка,
		|	Валюта.Figi
		|ИЗ
		|	Справочник.Валюта КАК Валюта
		|ГДЕ
		|	ВЫБОР
		|			КОГДА &Ссылка = НЕОПРЕДЕЛЕНО
		|				ТОГДА ИСТИНА
		|			ИНАЧЕ Валюта.Ссылка = &Ссылка
		|		КОНЕЦ";
	
	Запрос.УстановитьПараметр("Ссылка", Актив);	
	РезультатЗапроса = Запрос.Выполнить();	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Если НЕ ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.figi) тогда
			Продолжить;
		КонецЕсли;
		НачалоПериодаВФорматеЗапроса = Формат(НачалоПериода,"ДФ=yyyy-MM-dd") + "T" +Прав("0"+Строка(Час(НачалоПериода)),2) + "%3A" + Прав("0"+Строка(Минута(НачалоПериода)),2) + "%3A" + Прав("0"+Строка(Секунда(НачалоПериода)),2);
		КонецПериодаВФорматеЗапроса  = Формат(КонецПериода ,"ДФ=yyyy-MM-dd") + "T" +Прав("0"+Строка(Час(КонецПериода)) ,2) + "%3A" + Прав("0"+Строка(Минута(КонецПериода)) ,2) + "%3A" + Прав("0"+Строка(Секунда(КонецПериода)) ,2);
		
		СоответствиеОтвет = ПолучитьОтветHTTPЗапроса("GET","/market/candles?figi=" + ВыборкаДетальныеЗаписи.figi + "&from=" + НачалоПериодаВФорматеЗапроса + "%2B03%3A00&to=" + КонецПериодаВФорматеЗапроса + ".00%2B03%3A00&interval=" + Интервал,,,Токен); 
		Если СоответствиеОтвет = Неопределено Тогда 
			Возврат; 
		КонецЕсли;
		СоответствиеPayload = СоответствиеОтвет.Получить("payload");
		
		Если НЕ СоответствиеPayload.Получить("message") = Неопределено Тогда
			СоответствиеMessage = СоответствиеPayload.Получить("message"); 
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = СоответствиеMessage;
			Сообщение.Сообщить(); 
			Возврат
		КонецЕсли; 
		СоответствиеПозиций = СоответствиеPayload.Получить("candles");
		
		Для Каждого ЭлементСоответствия Из СоответствиеПозиций Цикл 
			Если ТипЗнч(ВыборкаДетальныеЗаписи.Ссылка) = Тип("СправочникСсылка.Активы") тогда
				Период = ПолучитьДатуВФормате1С(ЭлементСоответствия.Получить("time"));
				НаборЗаписей = РегистрыСведений.ТекущаяЦенаАктива.СоздатьНаборЗаписей();
				НаборЗаписей.Отбор.Период.Установить(КонецДня(Период));
				НаборЗаписей.Отбор.Актив.Установить(ВыборкаДетальныеЗаписи.Ссылка);
				НаборЗаписей.Прочитать();
				Если НаборЗаписей.Количество() = 0 Тогда
					ЗаписьНабора = НаборЗаписей.Добавить();	
				Иначе
					ЗаписьНабора = НаборЗаписей[0];
				КонецЕсли;
				ЗаписьНабора.Период = КонецДня(Период);
				ЗаписьНабора.Актив = ВыборкаДетальныеЗаписи.Ссылка;
				ЗаписьНабора.Цена = Число(ЭлементСоответствия.Получить("c"));
				НаборЗаписей.Записать();
			ИначеЕсли ТипЗнч(ВыборкаДетальныеЗаписи.Ссылка) = Тип("СправочникСсылка.Валюта") тогда
				Период = ПолучитьДатуВФормате1С(ЭлементСоответствия.Получить("time"));
				НаборЗаписей = РегистрыСведений.КурсыВалют.СоздатьНаборЗаписей();
				НаборЗаписей.Отбор.Период.Установить(КонецДня(Период));
				НаборЗаписей.Отбор.Валюта.Установить(ВыборкаДетальныеЗаписи.Ссылка);
				НаборЗаписей.Прочитать();
				Если НаборЗаписей.Количество() = 0 Тогда
					ЗаписьНабора = НаборЗаписей.Добавить();	
				Иначе
					ЗаписьНабора = НаборЗаписей[0];
				КонецЕсли;
				ЗаписьНабора.Период = КонецДня(Период);
				ЗаписьНабора.Валюта = ВыборкаДетальныеЗаписи.Ссылка;
				ЗаписьНабора.КурсВРублях = Число(ЭлементСоответствия.Получить("c"));
				НаборЗаписей.Записать();
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	РасчитатьЦенуАктиваВРублях();
	
КонецПроцедуры

Процедура РасчитатьЦенуАктиваВРублях() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ТекущаяЦенаАктива.Период КАК Период,
		|	ТекущаяЦенаАктива.Актив КАК Актив,
		|	ТекущаяЦенаАктива.Цена КАК Цена,
		|	ТекущаяЦенаАктива.ЦенаВРублях КАК ЦенаВРублях
		|ПОМЕСТИТЬ ВТ_АктивыВВалютеБезЦеныВРублях
		|ИЗ
		|	РегистрСведений.ТекущаяЦенаАктива КАК ТекущаяЦенаАктива
		|ГДЕ
		|	ТекущаяЦенаАктива.Актив В
		|			(ВЫБРАТЬ
		|				Активы.Ссылка КАК Ссылка
		|			ИЗ
		|				Справочник.Активы КАК Активы
		|			ГДЕ
		|				Активы.Валюта <> &ВалютаРубль)
		|	И ТекущаяЦенаАктива.ЦенаВРублях = 0
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_АктивыВВалютеБезЦеныВРублях.Период КАК Период,
		|	ВТ_АктивыВВалютеБезЦеныВРублях.Актив КАК Актив,
		|	ВТ_АктивыВВалютеБезЦеныВРублях.Цена КАК Цена,
		|	КурсыВалют.КурсВРублях КАК КурсВРублях,
		|	ВЫРАЗИТЬ(ВТ_АктивыВВалютеБезЦеныВРублях.Цена * КурсыВалют.КурсВРублях КАК ЧИСЛО(15, 2)) КАК ЦенаВРублях
		|ИЗ
		|	ВТ_АктивыВВалютеБезЦеныВРублях КАК ВТ_АктивыВВалютеБезЦеныВРублях
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.КурсыВалют КАК КурсыВалют
		|		ПО (ВТ_АктивыВВалютеБезЦеныВРублях.Период = КОНЕЦПЕРИОДА(КурсыВалют.Период, ДЕНЬ))
		|			И ВТ_АктивыВВалютеБезЦеныВРублях.Актив.Валюта = КурсыВалют.Валюта";
	
	Запрос.УстановитьПараметр("ВалютаРубль", Справочники.Валюта.НайтиПоКоду("810"));
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		НаборЗаписей = РегистрыСведений.ТекущаяЦенаАктива.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.Период.Установить(ВыборкаДетальныеЗаписи.Период);
		НаборЗаписей.Отбор.Актив.Установить(ВыборкаДетальныеЗаписи.Актив);
		НаборЗаписей.Прочитать();
		Если НаборЗаписей.Количество() <> 0 Тогда
			ЗаписьНабора = НаборЗаписей[0];
			ЗаписьНабора.ЦенаВРублях = ВыборкаДетальныеЗаписи.ЦенаВРублях;
			НаборЗаписей.Записать();
		КонецЕсли;		
	КонецЦикла;
	
КонецПроцедуры	

Функция ПолучитьТекущиеЦеныАктивов(МассивАктивов) Экспорт
	
	Токен = ТокенПоПортфелю(Константы.ПортфельПоУмолчанию.Получить());
	
	ТаблицаЗначений = Новый ТаблицаЗначений;
	ТаблицаЗначений.Колонки.Добавить("Актив");
	ТаблицаЗначений.Колонки.Добавить("Цена");	
	
	НачалоПериода = НачалоДня(ТекущаяДата());
	КонецПериода  = ТекущаяДата();
	
	НачалоПериодаВФорматеЗапроса = Формат(НачалоПериода,"ДФ=yyyy-MM-dd") + "T" +Прав("0"+Строка(Час(НачалоПериода)),2) + "%3A" + Прав("0"+Строка(Минута(НачалоПериода)),2) + "%3A" + Прав("0"+Строка(Секунда(НачалоПериода)),2);
	КонецПериодаВФорматеЗапроса  = Формат(КонецПериода ,"ДФ=yyyy-MM-dd") + "T" +Прав("0"+Строка(Час(КонецПериода)) ,2) + "%3A" + Прав("0"+Строка(Минута(КонецПериода)) ,2) + "%3A" + Прав("0"+Строка(Секунда(КонецПериода)) ,2);
	
	Для каждого ЭлементМассива из МассивАктивов цикл
		СоответствиеОтвет = ПолучитьОтветHTTPЗапроса("GET","/market/candles?figi=" + ЭлементМассива.figi + "&from=" + НачалоПериодаВФорматеЗапроса + "%2B03%3A00&to=" + КонецПериодаВФорматеЗапроса + ".00%2B03%3A00&interval=" + "day",,,Токен); 
		Если СоответствиеОтвет = Неопределено Тогда 
			Возврат ТаблицаЗначений; 
		КонецЕсли;
		СоответствиеPayload = СоответствиеОтвет.Получить("payload");
		
		Если НЕ СоответствиеPayload.Получить("message") = Неопределено Тогда
			Возврат ТаблицаЗначений;
		КонецЕсли; 
		СоответствиеПозиций = СоответствиеPayload.Получить("candles");
		
		Для Каждого ЭлементСоответствия Из СоответствиеПозиций Цикл 
			НоваяСтрока = ТаблицаЗначений.Добавить();
			НоваяСтрока.Актив = ЭлементМассива;
			НоваяСтрока.Цена = Число(ЭлементСоответствия.Получить("c"));
		КонецЦикла;

	КонецЦикла;
	
	Возврат ТаблицаЗначений;
	
КонецФункции