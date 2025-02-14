﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	УстановитьУсловноеОформление();
	
КонецПроцедуры   

#Область Команды


&НаКлиенте
Процедура НайтиАналоги(Команда)
	
	ОткрытьФорму("Обработка.ПоискАналогов.Форма.Форма");
	
КонецПроцедуры

&НаКлиенте
Процедура ОчиститьТаблицу(Команда)
	
	Объект.СписокАналогов.Очистить();
	
КонецПроцедуры

&НаКлиенте
Процедура ДобавитьЗаписи(Команда)
	
	Если СообщитьРезультат() = СообщенияПользователю().ПроверкаПройдена Тогда
		ДобавитьЗаписиНаСервере();
	Иначе 
		ПоказатьПредупреждение(,СообщитьРезультат());
	КонецЕсли;  
	
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьКорректностьДанных(Команда) 
	
	Если Объект.СписокАналогов.Количество() = 0 Тогда
		ПоказатьПредупреждение(,СообщенияПользователю().НезаполненаТЧ);
	Иначе 
		СгруппироватьСтроки();
		УдалитьЗеркальныеСтроки();
		Для каждого Элемент из Объект.СписокАналогов Цикл
			Элемент.ЕстьОшибка = 2;
		КонецЦикла;  
		
		КоличествоПустыхСтрок = КоличествоПустыхСтрок().Количество();
		Если  КоличествоПустыхСтрок  > 0 Тогда
			ПоказатьПредупреждение(Новый ОписаниеОповещения("ВывестиОшибкиПустыхСтрок", ЭтотОбъект, КоличествоПустыхСтрок), 
			СообщенияПользователю().ЕстьНезаполненныеСтроки);    
		Иначе	
			ПроверитьКорректностьДанныхНаСервере();
		КонецЕсли;  
	КонецЕсли;
	
КонецПроцедуры


#КонецОбласти

&НаСервере
Процедура ДобавитьЗаписиНаСервере()
	
	Для Каждого Строка Из Объект.СписокАналогов Цикл 
		СделатьЗапись(Строка.Аналог, Строка.Препарат);
		СделатьЗапись(Строка.Препарат, Строка.Аналог);
	КонецЦикла;   
	
	Сообщение = Новый СообщениеПользователю;
	Сообщение.Текст = СообщенияПользователю().АналогиДобавлены;
	Сообщение.Сообщить();
	
КонецПроцедуры	

&НаСервере
Процедура СделатьЗапись(Аналог, Препарат) 
	
	НаборЗаписей = РегистрыСведений.АналогиПрепаратов.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Препарат.Установить(Препарат);
	НаборЗаписей.Отбор.Аналог.Установить(Аналог); 
	
	НоваяЗапись = НаборЗаписей.Добавить(); 
	НоваяЗапись.Аналог = Аналог; 
	НоваяЗапись.Препарат = Препарат;
	
	//На всякий случай
	Попытка    
		НаборЗаписей.Записать();
	Исключение 
		Сообщение = Новый СообщениеПользователю;    
		Сообщение.Текст = СообщенияПользователю().АналогиНеДобавлены;
		Сообщение.Сообщить();
	КонецПопытки    
	
КонецПроцедуры	

&НаСервере
Функция СообщитьРезультат()
	
	МассивСтрок = Объект.СписокАналогов.НайтиСтроки(Новый Структура("ЕстьОшибка",2));
	Если МассивСтрок.Количество() = Объект.СписокАналогов.Количество() Тогда
		Возврат СообщенияПользователю().ПроверкаПройдена;
	КонецЕсли;
	
	МассивСтрок = Объект.СписокАналогов.НайтиСтроки(Новый Структура("ЕстьОшибка",0));
	Если МассивСтрок.Количество() <> 0 Тогда
		Возврат СообщенияПользователю().ОтсутствуетПроверкаКорректности;
	Иначе
		Возврат  СообщенияПользователю().ЕстьОшибки;
	КонецЕсли;
	
КонецФункции	

&НаСервере
Процедура СгруппироватьСтроки() 
	
	Запрос = Новый Запрос; 
	Запрос.Текст = "ВЫБРАТЬ
	|	ТЗ.Препарат КАК Препарат,
	|	ТЗ.Аналог КАК Аналог
	|ПОМЕСТИТЬ ВТ_тч
	|ИЗ
	|	&ТЗ КАК ТЗ
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_тч.Препарат КАК Препарат,
	|	ВТ_тч.Аналог КАК Аналог
	|ИЗ
	|	ВТ_тч КАК ВТ_тч
	|
	|СГРУППИРОВАТЬ ПО
	|	ВТ_тч.Препарат,
	|	ВТ_тч.Аналог";
	Запрос.УстановитьПараметр("ТЗ", Объект.СписокАналогов.Выгрузить()); 
	Объект.СписокАналогов.Очистить();
	Объект.СписокАналогов.Загрузить(Запрос.Выполнить().Выгрузить());
	
КонецПроцедуры	

&НаСервере
Процедура УдалитьЗеркальныеСтроки() 
	
	ТЧАналоги = Объект.СписокАналогов;
	Индекс = ТЧАналоги.Количество() - 1; 
	
	Пока Индекс > 0 Цикл
		ТекАналог = ТЧАналоги[Индекс].Аналог;
		ТекПрепарат = ТЧАналоги[Индекс].Препарат;
		МассивСтрок = ТЧАналоги.НайтиСтроки(Новый Структура("Препарат, Аналог", ТекАналог, ТекПрепарат)); 
		Для каждого Строка из МассивСтрок Цикл
			ТЧАналоги.Удалить(Строка);
		КонецЦикла;	
		Индекс = Индекс - 1;
	КонецЦикла;	
	
КонецПроцедуры

&НаСервере
Функция КоличествоПустыхСтрок()   
	
	МассивПустыхСтрок = Новый Массив;
	Для каждого Строка из Объект.СписокАналогов Цикл
		Если НЕ ЗначениеЗаполнено(Строка.Препарат) ИЛИ НЕ ЗначениеЗаполнено(Строка.Аналог) Тогда 
			МассивПустыхСтрок.Добавить(Строка.НомерСтроки);
		КонецЕсли;
	КонецЦикла; 
	
	Возврат МассивПустыхСтрок;
	
КонецФункции

&НаКлиенте
Процедура ВывестиОшибкиПустыхСтрок(ДополнительныеПараметры) Экспорт
	
	Для каждого ЭлМассива из ДополнительныеПараметры Цикл
		Сообщение = Новый СообщениеПользователю;    
		Сообщение.Текст = СообщенияПользователю().НезаполненаСтрока + ЭлМассива;
		Сообщение.Сообщить();
	КонецЦикла;	
	
КонецПроцедуры	

&НаСервере
Процедура ПроверитьКорректностьДанныхНаСервере() 
	
	СтруктураОшибок = Новый Структура;
	ВыгрузкаПрепаратовТЧ = Объект.СписокАналогов.Выгрузить(); 
	
	Запрос = Новый Запрос;
	Запрос.Текст =  "ВЫБРАТЬ
	|	АналогиПрепаратов.Препарат КАК Препарат,
	|	АналогиПрепаратов.Аналог КАК Аналог
	|ПОМЕСТИТЬ ВТ_АналогиРег
	|ИЗ
	|	РегистрСведений.АналогиПрепаратов КАК АналогиПрепаратов
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТЗ.Препарат КАК Препарат,
	|	ТЗ.Аналог КАК Аналог
	|ПОМЕСТИТЬ ВТ_ТЗ
	|ИЗ
	|	&ТЗ КАК ТЗ
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_АналогиРег.Препарат КАК Препарат,
	|	ВТ_АналогиРег.Аналог КАК Аналог
	|ИЗ
	|	ВТ_АналогиРег КАК ВТ_АналогиРег
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_ТЗ КАК ВТ_ТЗ
	|		ПО ВТ_АналогиРег.Препарат = ВТ_ТЗ.Препарат
	|			И ВТ_АналогиРег.Аналог = ВТ_ТЗ.Аналог";  
	Запрос.УстановитьПараметр("ТЗ",ВыгрузкаПрепаратовТЧ);
	ВыборкаПрепаратов = Запрос.Выполнить().Выбрать();
	
	Если ВыборкаПрепаратов.Следующий() Тогда
		
		Для каждого Строка из Объект.СписокАналогов Цикл
			Если Строка.Препарат = Строка.Аналог Тогда
				Сообщение = Новый СообщениеПользователю;    
				Сообщение.Текст = СообщенияПользователю().ИдентичностьПозицийВСтроке + Строка.НомерСтроки;
				Сообщение.Сообщить(); 
				Строка.ЕстьОшибка = 1;
			КонецЕсли;
			ВыборкаПрепаратов.Сбросить();
			Если ВыборкаПрепаратов.НайтиСледующий(Новый Структура("Препарат, Аналог",Строка.Препарат, Строка.Аналог)) Тогда 
				Сообщение = Новый СообщениеПользователю;    
				Сообщение.Текст = СообщенияПользователю().ОригинальностьПрепаратов + Строка.НомерСтроки;
				Сообщение.Сообщить();
				Строка.ЕстьОшибка = 1;
			КонецЕсли;
			
		КонецЦикла;	
		
	Иначе   
		
		Для каждого Строка из Объект.СписокАналогов Цикл
			Если Строка.Препарат = Строка.Аналог Тогда 
				Сообщение = Новый СообщениеПользователю;    
				Сообщение.Текст = СообщенияПользователю().ИдентичностьПозицийВСтроке + Строка.НомерСтроки;
				Сообщение.Сообщить(); 
				Строка.ЕстьОшибка = 1;
			КонецЕсли;
		КонецЦикла; 
		
	КонецЕсли; 	
	
КонецПроцедуры

&НаСервере
Процедура УстановитьУсловноеОформление()
	
	МассивИменКолонокДляПодсветки = Новый Массив;
	Для каждого Стр из Элементы.СписокАналогов.ПодчиненныеЭлементы Цикл
		МассивИменКолонокДляПодсветки.Добавить(Стр.Имя);
	КонецЦикла;   // Костыль  
	
	ЭлементОформления = УсловноеОформление.Элементы.Добавить(); 
	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("ЦветФона", WebЦвета.Белый); 
	
	ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Объект.СписокАналогов.ЕстьОшибка"); 
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбора.ПравоеЗначение = 0;  
	
	
	ЭлементОформления = УсловноеОформление.Элементы.Добавить(); 
	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("ЦветФона", WebЦвета.БледноКрасноФиолетовый); 
	
	ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Объект.СписокАналогов.ЕстьОшибка"); 
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбора.ПравоеЗначение = 1;  
	
	Для каждого Строка из МассивИменКолонокДляПодсветки Цикл
		ПолеОформления = ЭлементОформления.Поля.Элементы.Добавить();
		ПолеОформления.Поле = Новый ПолеКомпоновкиДанных(Строка); 
		ПолеОформления.Использование = Истина;
	КонецЦикла;
	
	ЭлементОформления = УсловноеОформление.Элементы.Добавить(); 
	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("ЦветФона", WebЦвета.БледноЗеленый); 
	
	ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Объект.СписокАналогов.ЕстьОшибка"); 
	ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбора.ПравоеЗначение = 2;
	
	Для каждого Строка из МассивИменКолонокДляПодсветки Цикл
		ПолеОформления = ЭлементОформления.Поля.Элементы.Добавить();
		ПолеОформления.Поле = Новый ПолеКомпоновкиДанных(Строка); 
		ПолеОформления.Использование = Истина;
	КонецЦикла;
	
КонецПроцедуры	

&НаСервере
Функция СообщенияПользователю()
	
	СтруктураСообщений = Новый Структура;
	СтруктураСообщений.Вставить("ИдентичностьПозицийВСтроке",
					НСтр("ru = 'Значение препарата совпадает с аналогом в строке № ' ; en = 'The value of the drug coincides with the analog in line №' "));
	СтруктураСообщений.Вставить("АналогиДобавлены", НСтр("ru = ' Аналоги добавлены!'; en = 'Analogs added!'"));  
	СтруктураСообщений.Вставить("АналогиНеДобавлены",НСтр("ru = 'Аналоги не были добавлены!'; en = 'Analogues have not been added!'"));
	СтруктураСообщений.Вставить("ОригинальностьПрепаратов",
					НСтр("ru = 'Препарат уже существует в базе. Ошибка в строке №'; en = 'The drug already exists in the database. Error in line №'"));  
	СтруктураСообщений.Вставить("НезаполненаТЧ", НСтр("ru = ' Список не заполнен!'; en = 'The list is not filled!'"));							
	СтруктураСообщений.Вставить("НезаполненаСтрока", НСтр("ru = ' Не заполнена строка №'; en = 'The line is not filled in. Error in line №'"));	
	СтруктураСообщений.Вставить("ЕстьНезаполненныеСтроки",
					НСтр("ru = ' В списке присутствуют незаполненные строки'; en = 'There are blank lines in the list'"));
	СтруктураСообщений.Вставить("ЕстьОшибки", НСтр("ru = ' Есть ошибки. Записи не добавлены.'; en = 'There are mistakes. No entries have been added.'"));							
	СтруктураСообщений.Вставить("ОтсутствуетПроверкаКорректности", 
					НСтр("ru = ' Необходимо установить проверку, нажав на соответствующую кнопку.'; en = 'You need to install the check by clicking on the appropriate button.'"));
	
	СтруктураСообщений.Вставить("ПроверкаПройдена", НСтр("ru = 'Проверка пройдена!'; en = 'The check is passed!'"));				
	
	Возврат СтруктураСообщений;
	
КонецФункции	

&НаКлиенте
Процедура СписокАналоговПриИзменении(Элемент)
	
	Для каждого Строка из Объект.СписокАналогов Цикл   
		Строка.ЕстьОшибка = 0;
	КонецЦикла;  
	
КонецПроцедуры

