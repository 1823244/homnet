﻿&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка) 
	Выполнить("ГруппаПоказателей = Справочники.хн_нфо_ПоказателиОтчета.ПустаяСсылка()");
	Элементы.ГруппаПоказателей.ВыборГруппИЭлементов = ГруппыИЭлементы.ГруппыИЭлементы;
КонецПроцедуры


&НаСервере
Функция ВыгрузитьНаСервере()
		
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	Номенклатура.Ссылка КАК Ссылка
	               |ИЗ
	               |	Справочник.Номенклатура КАК Номенклатура
	               |ГДЕ
	               |	Номенклатура.Ссылка В ИЕРАРХИИ(&ПарамГруппа)";
	Запрос.УстановитьПараметр("ПарамГруппа", ГруппаПоказателей);
	Запрос.Текст = СтрЗаменить(Запрос.текст, "Номенклатура", "хн_нфо_ПоказателиОтчета");
	Выборка = Запрос.Выполнить().Выбрать();
	рез = "[";
	Пока выборка.Следующий() Цикл
		т = ВыгрузитьОбъектПоСсылке(выборка.Ссылка);
		Рез = Рез + т + Символы.ПС;
		Рез = Рез + ",";
		Рез = Рез + Символы.ПС;
	КонецЦикла;
	Рез = Рез + "{""type"" : """"}" + Символы.ПС;
	рез = Рез + "]";

	//рез = ВыгрузитьОбъектПоСсылке(ГруппаПоказателей);
	Возврат рез;                                     
	
КонецФункции

&НаКлиенте
Процедура Выгрузить(Команда)
	т = ВыгрузитьНаСервере();
	тдок = Новый ТекстовыйДокумент;
	тдок.УстановитьТекст(т);
	тдок.показать();
КонецПроцедуры


/////////////////////////////



Функция ПолучитьСвойствоОбъекта(СсылкаНаОбъект,Свойство) 
	
		//{{КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!
	
	Запрос = Новый Запрос;
	Текст = 
		"ВЫБРАТЬ
		|	Элемент.(Свойство) КАК Свойство
		|ИЗ
		|	(Объект) КАК Элемент
		|ГДЕ
		|	Элемент.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", СсылкаНаОбъект);
	
	ПолноеИмяОбъектаМетаданных = СсылкаНаОбъект.Метаданные().ПолноеИмя();
	
	Текст = СтрЗаменить(Текст,"(Объект)",ПолноеИмяОбъектаМетаданных);
	Текст = СтрЗаменить(Текст,"(Свойство)",Свойство);
	
	Запрос.Текст = Текст;
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Возврат  ВыборкаДетальныеЗаписи.Свойство;
	КонецЦикла;
	
КонецФункции	
	
Функция СоздатьУзелIdentification(СсылкаНаОбъект) Экспорт

	// Проверка заполнения делается в вызываемых методах!!!!!!
	//Если СсылкаНаОбъект = Неопределено ИЛИ НЕ ЗначениеЗаполнено(СсылкаНаОбъект) Тогда
	//	Возврат Новый Структура;
	//КонецЕсли;

	Если Перечисления.ТипВсеСсылки().СодержитТип(ТипЗнч(СсылкаНаОбъект)) Тогда
		Возврат СоздатьУзелIdentification_Перечисления(СсылкаНаОбъект);
		
	ИначеЕсли Справочники.ТипВсеСсылки().СодержитТип(ТипЗнч(СсылкаНаОбъект)) Тогда
		Возврат СоздатьУзелIdentification_Справочника(СсылкаНаОбъект);
		
	ИначеЕсли Документы.ТипВсеСсылки().СодержитТип(ТипЗнч(СсылкаНаОбъект)) Тогда
		Возврат СоздатьУзелIdentification_Документа(СсылкаНаОбъект);

	ИначеЕсли ПланыВидовХарактеристик.ТипВсеСсылки().СодержитТип(ТипЗнч(СсылкаНаОбъект)) Тогда
		Возврат СоздатьУзелIdentification_ПВХ(СсылкаНаОбъект);

	КонецЕсли;
		
	Возврат Неопределено;
	
КонецФункции


Функция СоздатьУзелIdentification_Перечисления(СсылкаНаОбъект) Экспорт
	
	ОтветСтруктура = Новый Структура("type", "");
	
	Если СсылкаНаОбъект = Неопределено или СсылкаНаОбъект = null Тогда                          
		Возврат ОтветСтруктура;
	КонецЕсли;

	ОтветСтруктура.type = СсылкаНаОбъект.Метаданные().ПолноеИмя();
	
	Если не ЗначениеЗаполнено(СсылкаНаОбъект) Тогда
		Возврат ОтветСтруктура;
	КонецЕсли;
	
	ОтветСтруктура.Вставить("Значение", НайтиЗначениеПеречисленияПоПредставлению(СсылкаНаОбъект));
	ОтветСтруктура.Вставить("Представление", Строка(СсылкаНаОбъект));
	
	Возврат ОтветСтруктура;
	
КонецФункции                                         

Функция СоздатьУзелIdentification_Справочника(СсылкаНаОбъект) Экспорт
	
	ОтветСтруктура = Новый Структура("type", "");
	
	Если СсылкаНаОбъект = Неопределено или СсылкаНаОбъект = null Тогда                          
		Возврат ОтветСтруктура;
	КонецЕсли;

	мд = СсылкаНаОбъект.метаданные();
	type = мд.ПолноеИмя();	
	ОтветСтруктура.type = type;
	
	Если не ЗначениеЗаполнено(СсылкаНаОбъект) Тогда
		Возврат ОтветСтруктура;
	КонецЕсли;
	
	ОтветСтруктура.Вставить("Ref", Строка(СсылкаНаОбъект.УникальныйИдентификатор()));
	ОтветСтруктура.Вставить("Version", ПолучитьСвойствоОбъекта(СсылкаНаОбъект,"ВерсияДанных"));
	
	Если type = "Справочник.Валюты" Тогда
		ОтветСтруктура.Вставить("currencyCode", СсылкаНаОбъект.Код);	
		ОтветСтруктура.Вставить("currencyName", СокрЛП(СсылкаНаОбъект.Наименование));	
		
	ИначеЕсли type = "Справочник.БанковскиеСчетаОрганизаций" Тогда
		ОтветСтруктура.Вставить("НомерСчета", СокрЛП(СсылкаНаОбъект.НомерСчета));
		БИК = "";
		Если ЗначениеЗаполнено(СсылкаНаОбъект.Банк) И ЗначениеЗаполнено(СсылкаНаОбъект.Банк.ВерсияДанных)  Тогда
			БИК = СокрЛП(СсылкаНаОбъект.Банк.Код);
		КонецЕсли;
		ОтветСтруктура.Вставить("БИК", БИК);	
		
	ИначеЕсли type = "Справочник.БанковскиеСчетаКонтрагентов" Тогда
		ОтветСтруктура.Вставить("НомерСчета", СокрЛП(СсылкаНаОбъект.НомерСчета));
		БИК = "";
		Если ЗначениеЗаполнено(СсылкаНаОбъект.Банк) И ЗначениеЗаполнено(СсылкаНаОбъект.Банк.ВерсияДанных)  Тогда
			БИК = СокрЛП(СсылкаНаОбъект.Банк.Код);
		КонецЕсли;
		ОтветСтруктура.Вставить("БИК", БИК);	
		
	ИначеЕсли type = "Справочник.КартыЛояльности" Тогда
		ОтветСтруктура.Вставить("Штрихкод", СокрЛП(СсылкаНаОбъект.Штрихкод));
		ОтветСтруктура.Вставить("МагнитныйКод", СокрЛП(СсылкаНаОбъект.МагнитныйКод));	

	ИначеЕсли type = "Справочник.СтавкиНДС" Тогда
		ОтветСтруктура.Вставить("ПеречислениеСтавкаНДС", СоздатьУзелIdentification_Перечисления(СсылкаНаОбъект.ПеречислениеСтавкаНДС));
		
	ИначеЕсли type = "Справочник.УпаковкиЕдиницыИзмерения" Тогда
		ОтветСтруктура.Вставить("Наименование", СокрЛП(СсылкаНаОбъект.Наименование));

	ИначеЕсли type = "Справочник.СерииНоменклатуры" Тогда
		ОтветСтруктура.Вставить("СерияНомер", СокрЛП(СсылкаНаОбъект.Номер));

	ИначеЕсли type = "Справочник.ПодарочныеСертификаты" Тогда
		ОтветСтруктура.Вставить("Номинал", СокрЛП(СсылкаНаОбъект.Владелец.Номинал));

	ИначеЕсли type = "Справочник.ХарактеристикиНоменклатурыДляЦенообразования" Тогда 
			
		ХарактеристикаНоменклатуры = Справочники.ХарактеристикиНоменклатуры.ХарактеристикаПоЦО(СсылкаНаОбъект); 
		
		Если НЕ ХарактеристикаНоменклатуры = Неопределено Тогда
				
			ОтветСтруктура.type = "Справочник.ХарактеристикиНоменклатуры";
			
			Гуид = Строка(ХарактеристикаНоменклатуры.УникальныйИдентификатор());
			
			ОтветСтруктура.Ref = Гуид;
			
		КонецЕсли;
		
	ИначеЕсли type = "Справочник.СтатьиДвиженияДенежныхСредств" Тогда
		ОтветСтруктура.Вставить("ИмяПредопределенныхДанных", СокрЛП(СсылкаНаОбъект.ИмяПредопределенныхДанных));
		
	КонецЕсли;

	ОтветСтруктура.Вставить("Predefined", Ложь);
	Если СсылкаНаОбъект.Предопределенный Тогда
		ОтветСтруктура.Вставить("PredefinedName", СокрЛП(СсылкаНаОбъект.ИмяПредопределенныхДанных));
		ОтветСтруктура.Вставить("Predefined", Истина);
	КонецЕсли;
	
	Возврат ОтветСтруктура;
	
КонецФункции

Функция СоздатьУзелIdentification_Документа(СсылкаНаОбъект) Экспорт
	
	ОтветСтруктура = Новый Структура("type", "");
	
	// может быть пустая ссылка! ее надо типизировать и выгрузить в json
	
	Если СсылкаНаОбъект = Неопределено или СсылкаНаОбъект = null Тогда                          
		Возврат ОтветСтруктура;
	КонецЕсли;
	
	// тип нужен для случая наличия нескольких типов в реквизите
	ОтветСтруктура.type = СсылкаНаОбъект.Метаданные().ПолноеИмя();
		
	Если не ЗначениеЗаполнено(СсылкаНаОбъект) Тогда
		Возврат ОтветСтруктура;
	КонецЕсли;

	ОтветСтруктура.Вставить("Ref", Строка(СсылкаНаОбъект.УникальныйИдентификатор()));
	ОтветСтруктура.Вставить("Version", Строка(СсылкаНаОбъект.ВерсияДанных));
	
	
	Возврат ОтветСтруктура;
	
КонецФункции

Функция СоздатьУзелIdentification_ПВХ(СсылкаНаОбъект) Экспорт
	
	ОтветСтруктура = Новый Структура("type", "");
	
	Если СсылкаНаОбъект = Неопределено или СсылкаНаОбъект = null Тогда                          
		Возврат ОтветСтруктура;
	КонецЕсли;

	ОтветСтруктура.type = СсылкаНаОбъект.метаданные().ПолноеИмя();
	
	Если НЕ ЗначениеЗаполнено(СсылкаНаОбъект) Тогда
		Возврат ОтветСтруктура;
	КонецЕсли;
	
	ОтветСтруктура.Вставить("Ref", Строка(СсылкаНаОбъект.УникальныйИдентификатор()));
	ОтветСтруктура.Вставить("Version", Строка(СсылкаНаОбъект.ВерсияДанных));

	Возврат ОтветСтруктура;
	
КонецФункции



Функция СоздатьУзелDefinition(СсылкаНаОбъект) Экспорт
	
	Если Перечисления.ТипВсеСсылки().СодержитТип(ТипЗнч(СсылкаНаОбъект)) Тогда
		Возврат СоздатьУзелDefinition_Перечисления(СсылкаНаОбъект);
		
	ИначеЕсли Справочники.ТипВсеСсылки().СодержитТип(ТипЗнч(СсылкаНаОбъект)) Тогда
		Возврат СоздатьУзелDefinition_Справочника(СсылкаНаОбъект);
		
	ИначеЕсли Документы.ТипВсеСсылки().СодержитТип(ТипЗнч(СсылкаНаОбъект)) Тогда
		Возврат СоздатьУзелDefinition_Документа(СсылкаНаОбъект);

	ИначеЕсли ПланыВидовХарактеристик.ТипВсеСсылки().СодержитТип(ТипЗнч(СсылкаНаОбъект)) Тогда
		Возврат СоздатьУзелDefinition_ПВХ(СсылкаНаОбъект);

	КонецЕсли;
		
	Возврат Неопределено;
	
КонецФункции

Функция СоздатьУзелDefinition_Перечисления(СсылкаНаОбъект) Экспорт
	
	ОтветСтруктура = Новый Структура;
	
	Возврат ОтветСтруктура;
	
КонецФункции                                         

Функция СоздатьУзелDefinition_Справочника(СсылкаНаОбъект) Экспорт
	
	ОтветСтруктура = Новый Структура;
	
	Если НЕ ЗначениеЗаполнено(СсылкаНаОбъект) Тогда
		Возврат ОтветСтруктура;
	КонецЕсли;
	
	ОтветСтруктура.Вставить("DeletionMark", СсылкаНаОбъект.ПометкаУдаления);
	
	мд = СсылкаНаОбъект.метаданные();
	
	Если мд.ДлинаКода > 0 Тогда
		ОтветСтруктура.Вставить("Code", СсылкаНаОбъект.Код);
	Иначе 
		ОтветСтруктура.Вставить("Code", "");
	КонецЕсли;
		
	Если мд.ДлинаНаименования > 0 Тогда
		ОтветСтруктура.Вставить("Description", СсылкаНаОбъект.Наименование);
	Иначе 
		ОтветСтруктура.Вставить("Description", "");
	КонецЕсли;
		
	Если мд.Владельцы.Количество() > 0 Тогда
		Попытка		
			owner = СоздатьУзелIdentification_Справочника(СсылкаНаОбъект.Владелец);
			ОтветСтруктура.Вставить("Owner", owner);
		Исключение
		    
		КонецПопытки;		
	КонецЕсли;
	
	ОтветСтруктура.Вставить("Predefined", Ложь);
	Если СсылкаНаОбъект.Предопределенный Тогда
		ОтветСтруктура.Вставить("PredefinedName", СокрЛП(СсылкаНаОбъект.ИмяПредопределенныхДанных));
		ОтветСтруктура.Вставить("Predefined", Истина);
	КонецЕсли;

	Если мд.Иерархический = Истина Тогда
		ОтветСтруктура.Вставить("isFolder", СсылкаНаОбъект.ЭтоГруппа);
		parent = СоздатьУзелIdentification_Справочника(СсылкаНаОбъект.Родитель);
		ОтветСтруктура.Вставить("Parent", parent);
	Иначе 
		ОтветСтруктура.Вставить("isFolder", false);
	КонецЕсли;
	
	
	
	Возврат ОтветСтруктура;
	
КонецФункции

Функция СоздатьУзелDefinition_Документа(СсылкаНаОбъект) Экспорт
	
	ОтветСтруктура = Новый Структура;
	
	Если НЕ ЗначениеЗаполнено(СсылкаНаОбъект) Тогда
		Возврат ОтветСтруктура;
	КонецЕсли;
	
	ОтветСтруктура.Вставить("DeletionMark", СсылкаНаОбъект.ПометкаУдаления);
	
	ОтветСтруктура.Вставить("isPosted", СсылкаНаОбъект.Проведен);
	
	ОтветСтруктура.Вставить("Number", СсылкаНаОбъект.Номер);
	ОтветСтруктура.Вставить("Date", XMLСтрока(СсылкаНаОбъект.Дата));
	
	Возврат ОтветСтруктура;
	
КонецФункции

Функция СоздатьУзелDefinition_ПВХ(СсылкаНаОбъект) Экспорт
	
	ОтветСтруктура = Новый Структура;
	
	Если НЕ ЗначениеЗаполнено(СсылкаНаОбъект) Тогда
		Возврат ОтветСтруктура;
	КонецЕсли;
	
	ОтветСтруктура.Вставить("DeletionMark", СсылкаНаОбъект.ПометкаУдаления);
	
	мд = СсылкаНаОбъект.метаданные();
	
	Если мд.ДлинаКода > 0 Тогда
		ОтветСтруктура.Вставить("Code", СсылкаНаОбъект.Код);
	Иначе 
		ОтветСтруктура.Вставить("Code", "");
	КонецЕсли;
		
	Если мд.ДлинаНаименования > 0 Тогда
		ОтветСтруктура.Вставить("Description", СсылкаНаОбъект.Наименование);
	Иначе 
		ОтветСтруктура.Вставить("Description", "");
	КонецЕсли;

	Если мд.Иерархический = Истина Тогда
		ОтветСтруктура.Вставить("isFolder", СсылкаНаОбъект.ЭтоГруппа);
		parent = СоздатьУзелIdentification_Справочника(СсылкаНаОбъект.Родитель);
		ОтветСтруктура.Вставить("Parent", parent);
	Иначе 
		ОтветСтруктура.Вставить("isFolder", false);
	КонецЕсли;
	
	
	Возврат ОтветСтруктура;
	
КонецФункции

// Описание_метода
//
// Параметры:
//	Параметр1 	- Тип1 - 
//
// Возвращаемое значение:
//	Тип: Тип_значения
//
Функция НайтиЗначениеПеречисленияПоПредставлению(ЗначениеПеречисления)
	
	МД = ЗначениеПеречисления.Метаданные().ЗначенияПеречисления;
	Для каждого Значение Из МД Цикл
		Если Значение.Синоним = Строка(ЗначениеПеречисления) Тогда
			Возврат Значение.Имя;
		КонецЕсли;
	КонецЦикла;
	Возврат Неопределено;
	
КонецФункции



Функция ВыгрузитьДокументПоСсылке(ДанныеСсылка) Экспорт
	ТипСсылка = Тип(СтрЗаменить(ДанныеСсылка.метаданные().ПолноеИмя(),"Документ.","ДокументСсылка."));
	Если ТипЗнч(ДанныеСсылка) = ТипСсылка Тогда
		Обк = ДанныеСсылка.ПолучитьОбъект(); 
	Иначе 
		Обк = ДанныеСсылка; 
	КонецЕсли;
	Возврат ВыгрузитьОбъектПоСсылке(Обк);
КонецФункции

Функция ВыгрузитьСправочникПоСсылке(ДанныеСсылка) Экспорт
	ТипСсылка = Тип(СтрЗаменить(ДанныеСсылка.метаданные().ПолноеИмя(),"Справочник.","СправочникСсылка."));
	Если ТипЗнч(ДанныеСсылка) = ТипСсылка Тогда
		Обк = ДанныеСсылка.ПолучитьОбъект(); 
	Иначе 
		Обк = ДанныеСсылка; 
	КонецЕсли;
	Возврат ВыгрузитьОбъектПоСсылке(Обк);
КонецФункции

Функция ВыгрузитьПВХПоСсылке(ДанныеСсылка) Экспорт
	ТипСсылка = Тип(СтрЗаменить(ДанныеСсылка.метаданные().ПолноеИмя(),"ПланВидовХарактеристик.","ПланВидовХарактеристикСсылка."));
	Если ТипЗнч(ДанныеСсылка) = ТипСсылка Тогда
		Обк = ДанныеСсылка.ПолучитьОбъект(); 
	Иначе 
		Обк = ДанныеСсылка; 
	КонецЕсли;
	Возврат ВыгрузитьОбъектПоСсылке(Обк);
КонецФункции

Функция ВыгрузитьОбъектПоСсылке(Обк) Экспорт
	
	ТипДокТоЧтоНужно = Ложь;
	//Если ТипЗнч(Обк) = Тип("ДокументСсылка.ПриходныйКассовыйОрдер") 
	//	ИЛИ ТипЗнч(Обк) = Тип("ДокументСсылка.РасходныйКассовыйОрдер") 
	//	ИЛИ ТипЗнч(Обк) = Тип("ДокументСсылка.ПоступлениеБезналичныхДенежныхСредств") 
	//	ИЛИ ТипЗнч(Обк) = Тип("ДокументСсылка.СписаниеБезналичныхДенежныхСредств") 
	//ИЛИ ТипЗнч(Обк) = Тип("ДокументОбъект.ПриходныйКассовыйОрдер") 
	//	ИЛИ ТипЗнч(Обк) = Тип("ДокументОбъект.РасходныйКассовыйОрдер") 
	//	ИЛИ ТипЗнч(Обк) = Тип("ДокументОбъект.ПоступлениеБезналичныхДенежныхСредств") 
	//	ИЛИ ТипЗнч(Обк) = Тип("ДокументОбъект.СписаниеБезналичныхДенежныхСредств") Тогда
	//
	//	ТипДокТоЧтоНужно = Истина;
	//
	//КонецЕсли;
	
	ПараметрыЗаписиJSON = Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Авто, Символы.Таб);
	ЗаписьJson = Новый ЗаписьJSON;
	ЗаписьJson.УстановитьСтроку(ПараметрыЗаписиJSON);
	// Это основной объект json-сообщения
	СтруктураОбъекта = Новый Структура;
	СтруктураОбъекта.Вставить("source", "NFO");
	СтруктураОбъекта.Вставить("type", Обк.Метаданные().ПолноеИмя());
	СтруктураОбъекта.Вставить("datetime", XMLСтрока(ТекущаяДатаСеанса()));
	identification = СоздатьУзелIdentification(Обк.Ссылка);
	СтруктураОбъекта.Вставить("identification", identification);
	//	DEFINITION
	definition = СоздатьУзелDefinition(Обк.Ссылка);
	Для каждого Реквизит Из Обк.Метаданные().СтандартныеРеквизиты Цикл
		РеквизитИмя = Реквизит.Имя;
		РеквизитЗначение = Обк[РеквизитИмя];
		Если ТипЗнч(РеквизитЗначение) = Тип("Булево") или ТипЗнч(РеквизитЗначение) = Тип("Строка") или ТипЗнч(РеквизитЗначение) = Тип("Число")
			или ТипЗнч(РеквизитЗначение) = Тип("Дата") или ТипЗнч(РеквизитЗначение) = Тип("Неопределено") Тогда
			definition.Вставить(РеквизитИмя, РеквизитЗначение);	
		Иначе		
			definition.Вставить(РеквизитИмя, СоздатьУзелIdentification(РеквизитЗначение));	
		КонецЕсли;	
	КонецЦикла;
	Для каждого Реквизит Из Обк.Метаданные().Реквизиты Цикл
		РеквизитИмя = Реквизит.Имя;
		РеквизитЗначение = Обк[РеквизитИмя];
		Если ТипЗнч(РеквизитЗначение) = Тип("Булево") или ТипЗнч(РеквизитЗначение) = Тип("Строка") или ТипЗнч(РеквизитЗначение) = Тип("Число")
			или ТипЗнч(РеквизитЗначение) = Тип("Дата") или ТипЗнч(РеквизитЗначение) = Тип("Неопределено") Тогда
			definition.Вставить(РеквизитИмя, РеквизитЗначение);	
		Иначе		
			definition.Вставить(РеквизитИмя, СоздатьУзелIdentification(РеквизитЗначение));	
		КонецЕсли;
	КонецЦикла;
	
	Для каждого ИмяТЧ Из Обк.Метаданные().ТабличныеЧасти Цикл
		ИмяТабЧасти = ИмяТЧ.Имя;
		ТЧ_Документа = Новый Массив;
		Для каждого стрк из Обк[ИмяТабЧасти] Цикл
			НовСтр = Новый Структура;
			Для каждого РеквизитТЧ из ИмяТЧ.Реквизиты Цикл
				РеквизитИмя = РеквизитТЧ.Имя;
				РеквизитЗначение = стрк[РеквизитТЧ.Имя];
				Если ТипЗнч(РеквизитЗначение) = Тип("Булево") или ТипЗнч(РеквизитЗначение) = Тип("Строка") или ТипЗнч(РеквизитЗначение) = Тип("Число")
					или ТипЗнч(РеквизитЗначение) = Тип("Дата") или ТипЗнч(РеквизитЗначение) = Тип("Неопределено") Тогда
					НовСтр.Вставить(РеквизитИмя,РеквизитЗначение);
				Иначе
					НовСтр.Вставить(РеквизитИмя,СоздатьУзелIdentification(РеквизитЗначение));
				КонецЕсли;
				
				Если ИмяТабЧасти = "РасшифровкаПлатежа" И РеквизитИмя = "ОбъектРасчетов" И ТипДокТоЧтоНужно Тогда
					мРеквизитыОбъекта = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(РеквизитЗначение, "Объект, Партнер, Организация, Контрагент, Договор");
					НовСтр.Вставить("Объект",			СоздатьУзелIdentification(мРеквизитыОбъекта.Объект));
					НовСтр.Вставить("ОбъектПартнер",			СоздатьУзелIdentification(мРеквизитыОбъекта.Партнер));
					НовСтр.Вставить("ОбъектОрганизация",		СоздатьУзелIdentification(мРеквизитыОбъекта.Организация));
					НовСтр.Вставить("ОбъектКонтрагент",		СоздатьУзелIdentification(мРеквизитыОбъекта.Контрагент));
					НовСтр.Вставить("ОбъектДоговор",			СоздатьУзелIdentification(мРеквизитыОбъекта.Договор));
				КонецЕсли;
				
			КонецЦикла;
			ТЧ_Документа.Добавить(НовСтр);
		КонецЦикла;
		definition.Вставить("ТЧ"+ИмяТЧ.Имя, ТЧ_Документа);
	КонецЦикла;
	
	ДополнитьОбъектИнформацией(СтруктураОбъекта, Обк.Ссылка);
	
	//------------------------------------------------------ ФИНАЛ
	СтруктураОбъекта.Вставить("definition", definition);
	ЗаписатьJSON(ЗаписьJson, СтруктураОбъекта);
	json = ЗаписьJson.Закрыть();
	
	Возврат json;
КонецФункции
 

Процедура ДополнитьОбъектИнформацией(СтруктураОбъекта, Ссылка)
	
	Если СтруктураОбъекта.type = "Документ.ЗаказКлиента" Тогда 
		
		ДополнитьЗаказКлиентаИнформацией(СтруктураОбъекта, Ссылка);
		
	КонецЕсли;
	
	
КонецПроцедуры 

Процедура ДополнитьЗаказКлиентаИнформацией(СтруктураОбъекта, Ссылка)
	
    	//{{КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!
	СтруктураОбъекта.Вставить("НомерИнтернетЗаказа","");
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ксп_ИсходныеДанныеЗаказов.id КАК id
		|ИЗ
		|	РегистрСведений.ксп_ИсходныеДанныеЗаказов КАК ксп_ИсходныеДанныеЗаказов
		|ГДЕ
		|	ксп_ИсходныеДанныеЗаказов.ЗаказКлиента = &ЗаказКлиента";
	
	Запрос.УстановитьПараметр("ЗаказКлиента", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		СтруктураОбъекта.НомерИнтернетЗаказа = ВыборкаДетальныеЗаписи.id;
		Возврат;
		
	КонецЦикла;
	
	//}}КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА

	
КонецПроцедуры

