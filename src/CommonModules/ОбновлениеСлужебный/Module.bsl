// Получить версию конфигурации или родительской конфигурации (библиотеки),
// которая хранится в информационной базе.
//
// Параметры
//  ИдентификаторБиблиотеки  - Строка - имя конфигурации или идентификатор библиотеки.
//
// Возвращаемое значение:
//   Строка   - версия.
//
// Пример использования:
//   ВерсияКонфигурацииИБ = ВерсияИБ(Метаданные.Имя);
//
Функция ВерсияИБ(Знач ИдентификаторБиблиотеки, Знач ПолучитьВерсиюОбщихДанных = Ложь) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	СтандартнаяОбработка = Истина;
	Результат = "";
	
	Если СтандартнаяОбработка Тогда
		
		Запрос = Новый Запрос;
		Запрос.Текст =
		"ВЫБРАТЬ
		|	ВерсииПодсистем.Версия
		|ИЗ
		|	РегистрСведений.ВерсииПодсистем КАК ВерсииПодсистем
		|ГДЕ
		|	ВерсииПодсистем.ИмяПодсистемы = &ИмяПодсистемы";
		
		Запрос.УстановитьПараметр("ИмяПодсистемы", ИдентификаторБиблиотеки);
		ТаблицаЗначений = Запрос.Выполнить().Выгрузить();
		Результат = "";
		Если ТаблицаЗначений.Количество() > 0 Тогда
			Результат = СокрЛП(ТаблицаЗначений[0].Версия);
		КонецЕсли;
				
	КонецЕсли;
	
	Возврат ?(ПустаяСтрока(Результат), "0.0.0.0", Результат);
	
КонецФункции

Функция ВерсияМетаданных() Экспорт
	Соответствие = Новый Соответствие;
	Соответствие.Вставить("Версия", Метаданные.Версия);
	Возврат Соответствие;
КонецФункции

Процедура ПервыйЗапуск() Экспорт
	НачатьТранзакцию();
	НастройкиСОАП = Справочники.НастройкиSOAP.Основная.ПолучитьОбъект();
	НастройкиСОАП.АдресСервера = "sigrand.com.ua:9090/orawsv";
	НастройкиСОАП.СистемныйПользователь = "dba_divas";
	НастройкиСОАП.СистемныйПароль = "divas";
	НастройкиСОАП.Записать();
	
	НастройкиРЕСТ = Справочники.НастройкиREST.Основная.ПолучитьОбъект();
	НастройкиРЕСТ.АдресСервера = "sigrand.com.ua/divas_rest/";
	НастройкиРЕСТ.СистемныйПользователь = "sysdba";
	НастройкиРЕСТ.СистемныйПароль = "!stigmata70";
	НастройкиРЕСТ.Записать();

	ОбновлениеИнформационнойБазы();
	
	ПланЭтот = ПланыОбмена.ОбменСОсновнойБазой.ЭтотУзел().ПолучитьОбъект();
	ПланЭтот.Код= "ZM";
	ПланЭтот.Наименование = "Эта база";
	ПланЭтот.Записать();
	
	План = ПланыОбмена.ОбменСОсновнойБазой.СоздатьУзел();
	План.Код = "ORA";
	План.Наименование = "Оракул";
	План.Записать();
	
	ЗафиксироватьТранзакцию();
КонецПроцедуры

Функция ПользовательИБНайден(Идентификатор)
	Если ТипЗнч(Идентификатор) = Тип("УникальныйИдентификатор") Тогда
		
		Если Идентификатор = ПользователиИнформационнойБазы.ТекущийПользователь().УникальныйИдентификатор Тогда
			
			ПользовательИБ = ПользователиИнформационнойБазы.ТекущийПользователь();
		Иначе
			ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(Идентификатор);
		КонецЕсли;
		
	ИначеЕсли ТипЗнч(Идентификатор) = Тип("Строка") Тогда
		ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоИмени(Идентификатор);
	Иначе
		ПользовательИБ = Неопределено;
	КонецЕсли;
	Возврат ПользовательИБ;
КонецФункции	

Функция СоздатьПользователя(Имя, Логин, Роль) Экспорт
	ПользовательИБ = ПользовательИБНайден(Имя);
	Если ПользовательИБ = Неопределено Тогда
		ПользовательИБ = ПользователиИнформационнойБазы.СоздатьПользователя();
		ПользовательИБ.Имя = Логин;
		ПользовательИБ.ПолноеИмя = Логин;
		//ПользовательИБ.АутентификацияОС = Ложь;
		//ПользовательИБ.ПользовательОС = ПользовательОС;
		//ПользовательИБ.ОсновнойИнтерфейс = Метаданные.Интерфейсы.Полный;
		ПользовательИБ.Роли.Очистить();
		ПользовательИБ.Роли.Добавить(Роль);
		//ПользовательИБ.Роли.Добавить(Метаданные.Роли.эакПользователь);
		ПользовательИБ.Записать();
	Иначе
		ПользовательИБ.Имя = Логин;
		ПользовательИБ.ПолноеИмя = Логин;
		//ПользовательИБ.АутентификацияОС = Ложь;
		ПользовательИБ.Роли.Очистить();
		ПользовательИБ.Роли.Добавить(Роль);
		//Сообщить("Пользователю "+Логин+" добавлена роль "+Роль);
		ПользовательИБ.Записать();
	КонецЕсли;
	//о = Справочники.Пользователи.СоздатьЭлемент();
	//о.Наименование = Имя;
	//о.УстановитьНовыйКод();
	//о.ИдентификаторПользователяИБ = ПользовательИБ.УникальныйИдентификатор;
	//о.Записать();
	Возврат ПользовательИБ.УникальныйИдентификатор;
КонецФункции

Функция ИзменитьПарольПользователяИБ(Имя, Пароль) Экспорт
	ПользовательИБ = ПользовательИБНайден(Имя);
	Если ПользовательИБ = Неопределено Тогда
		ПользовательИБ = ПользователиИнформационнойБазы.СоздатьПользователя();
		ПользовательИБ.Имя = Имя;
		ПользовательИБ.ПолноеИмя = Имя;
		//ПользовательИБ.АутентификацияОС = Ложь;
		ПользовательИБ.Пароль = Пароль;
		ПользовательИБ.ПоказыватьВСпискеВыбора= Истина;
		//ПользовательИБ.ПользовательОС = ПользовательОС;
		//ПользовательИБ.ОсновнойИнтерфейс = Метаданные.Интерфейсы.Полный;
		//ПользовательИБ.Роли.Добавить(Роль);
		//ПользовательИБ.Роли.Добавить(Метаданные.Роли.эакПользователь);
		ПользовательИБ.Записать();
	Иначе
		//ПользовательИБ.Роли.Очистить();
		//ПользовательИБ.Роли.Добавить(Роль);
		ПользовательИБ.Пароль = Пароль;
		ПользовательИБ.ПоказыватьВСпискеВыбора= Истина;
		ПользовательИБ.Записать();
	КонецЕсли;
	//о = Справочники.Пользователи.СоздатьЭлемент();
	//о.Наименование = Имя;
	//о.УстановитьНовыйКод();
	//о.ИдентификаторПользователяИБ = ПользовательИБ.УникальныйИдентификатор;
	//о.Записать();
	Возврат ПользовательИБ.УникальныйИдентификатор;
КонецФункции

Процедура ОбновлениеИнформационнойБазы() Экспорт
	
	НаборЗаписей = РегистрыСведений.ВерсииПодсистем.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.ИмяПодсистемы.Установить(Метаданные.Имя);
	
	НоваяЗапись = НаборЗаписей.Добавить();
	НоваяЗапись.ИмяПодсистемы = Метаданные.Имя;
	НоваяЗапись.Версия = Метаданные.Версия;
	//НоваяЗапись.ПланОбновления = Неопределено;
	НоваяЗапись.ЭтоОсновнаяКонфигурация = Истина;
	
	НаборЗаписей.Записать();

КонецПроцедуры	