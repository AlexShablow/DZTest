///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

// Возвращает описания всех библиотек конфигурации, включая
// описание самой конфигурации.
// 
// Возвращаемое значение:
//  ФиксированнаяСтруктура:
//   * Порядок - Массив из Строка
//   * ПоИменам - Соответствие из КлючИЗначение:
//     ** Ключ - Строка
//     ** Значение - см. НовоеОписаниеПодсистемы
//
Функция ОписанияПодсистем() Экспорт
	
	МодулиПодсистем = Новый Массив;
	МодулиПодсистем.Добавить("ОбновлениеИнформационнойБазыБСП");
	
	ИнтеграцияПодсистемБСП.ПриДобавленииПодсистем(МодулиПодсистем);
	ПодсистемыКонфигурацииПереопределяемый.ПриДобавленииПодсистем(МодулиПодсистем);
	
	ОписаниеКонфигурацииНайдено = Ложь;
	ОписанияПодсистем = Новый Структура;
	ОписанияПодсистем.Вставить("Порядок",  Новый Массив);
	ОписанияПодсистем.Вставить("ПоИменам", Новый Соответствие);
	
	ВсеТребуемыеПодсистемы = Новый Соответствие;
	
	Для Каждого ИмяМодуля Из МодулиПодсистем Цикл
		
		Описание = НовоеОписаниеПодсистемы();
		Модуль = ОбщегоНазначения.ОбщийМодуль(ИмяМодуля);
		Модуль.ПриДобавленииПодсистемы(Описание);
		
		Если ОписанияПодсистем.ПоИменам.Получить(Описание.Имя) <> Неопределено Тогда
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Ошибка при подготовке описаний подсистем:
				           |в описании подсистемы (см. процедуру %1.%2)
				           |указано имя подсистемы ""%2"", которое уже зарегистрировано ранее.'"),
				ИмяМодуля, "ПриДобавленииПодсистемы", Описание.Имя);
			ВызватьИсключение ТекстОшибки;
		КонецЕсли;
		
		Если Описание.Имя = Метаданные.Имя Тогда
			ОписаниеКонфигурацииНайдено = Истина;
			Описание.Вставить("ЭтоКонфигурация", Истина);
		Иначе
			Описание.Вставить("ЭтоКонфигурация", Ложь);
		КонецЕсли;
		
		Описание.Вставить("ОсновнойСерверныйМодуль", ИмяМодуля);
		
		ОписанияПодсистем.ПоИменам.Вставить(Описание.Имя, Описание);
		// Настройка порядка подсистем с учетом порядка добавления основных модулей.
		ОписанияПодсистем.Порядок.Добавить(Описание.Имя);
		// Сборка всех требуемых подсистем.
		Для каждого ТребуемаяПодсистема Из Описание.ТребуемыеПодсистемы Цикл
			Если ВсеТребуемыеПодсистемы.Получить(ТребуемаяПодсистема) = Неопределено Тогда
				ВсеТребуемыеПодсистемы.Вставить(ТребуемаяПодсистема, Новый Массив);
			КонецЕсли;
			ВсеТребуемыеПодсистемы[ТребуемаяПодсистема].Добавить(Описание.Имя);
		КонецЦикла;
	КонецЦикла;
	
	// Проверка описания основной конфигурации.
	Если ОписаниеКонфигурацииНайдено Тогда
		Описание = ОписанияПодсистем.ПоИменам[Метаданные.Имя];
		
		Если Описание.Версия <> Метаданные.Версия Тогда
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Ошибка при подготовке описаний подсистем:
				           |версия ""%2"" конфигурации ""%1"" (см. процедуру %3.%4)
				           |не совпадает с версией конфигурации в метаданных ""%5"".'"),
				Описание.Имя,
				Описание.Версия,
				Описание.ОсновнойСерверныйМодуль,
				"ПриДобавленииПодсистемы",
				Метаданные.Версия);
			ВызватьИсключение ТекстОшибки;
		КонецЕсли;
	Иначе
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Ошибка при подготовке описаний подсистем:
			           |в общих модулях, указанных в процедуре %1,
			           |не существует описание подсистемы, совпадающей с именем конфигурации ""%2"".'"),
			"ПодсистемыКонфигурацииПереопределяемый.ПриДобавленииПодсистемы", Метаданные.Имя);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
	
	// Проверка наличия всех требуемых подсистем.
	Для каждого КлючИЗначение Из ВсеТребуемыеПодсистемы Цикл
		Если ОписанияПодсистем.ПоИменам.Получить(КлючИЗначение.Ключ) = Неопределено Тогда
			ЗависимыеПодсистемы = "";
			Для Каждого ЗависимаяПодсистема Из КлючИЗначение.Значение Цикл
				ЗависимыеПодсистемы = Символы.ПС + ЗависимаяПодсистема;
			КонецЦикла;
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Ошибка при подготовке описаний подсистем:
				           |не существует подсистема ""%1"" требуемая для подсистем: %2.'"),
				КлючИЗначение.Ключ,
				ЗависимыеПодсистемы);
			ВызватьИсключение ТекстОшибки;
		КонецЕсли;
	КонецЦикла;
	
	// Настройка порядка подсистем с учетом зависимостей.
	Для Каждого КлючИЗначение Из ОписанияПодсистем.ПоИменам Цикл
		Имя = КлючИЗначение.Ключ;
		Порядок = ОписанияПодсистем.Порядок.Найти(Имя);
		Для каждого ТребуемаяПодсистема Из КлючИЗначение.Значение.ТребуемыеПодсистемы Цикл
			ПорядокТребуемойПодсистемы = ОписанияПодсистем.Порядок.Найти(ТребуемаяПодсистема);
			Если Порядок < ПорядокТребуемойПодсистемы Тогда
				Взаимозависимость = ОписанияПодсистем.ПоИменам[ТребуемаяПодсистема
					].ТребуемыеПодсистемы.Найти(Имя) <> Неопределено;
				Если Взаимозависимость Тогда
					НовыйПорядок = ПорядокТребуемойПодсистемы;
				Иначе
					НовыйПорядок = ПорядокТребуемойПодсистемы + 1;
				КонецЕсли;
				Если Порядок <> НовыйПорядок Тогда
					ОписанияПодсистем.Порядок.Вставить(НовыйПорядок, Имя);
					ОписанияПодсистем.Порядок.Удалить(Порядок);
					Порядок = НовыйПорядок - 1;
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	// Смещение описания конфигурации в конец массива.
	Индекс = ОписанияПодсистем.Порядок.Найти(Метаданные.Имя);
	Если ОписанияПодсистем.Порядок.Количество() > Индекс + 1 Тогда
		ОписанияПодсистем.Порядок.Удалить(Индекс);
		ОписанияПодсистем.Порядок.Добавить(Метаданные.Имя);
	КонецЕсли;
	
	Для Каждого КлючИЗначение Из ОписанияПодсистем.ПоИменам Цикл
		КлючИЗначение.Значение.ТребуемыеПодсистемы =
			Новый ФиксированныйМассив(КлючИЗначение.Значение.ТребуемыеПодсистемы);
		
		ОписанияПодсистем.ПоИменам[КлючИЗначение.Ключ] =
			Новый ФиксированнаяСтруктура(КлючИЗначение.Значение);
	КонецЦикла;
	
	Возврат ОбщегоНазначения.ФиксированныеДанные(ОписанияПодсистем);
	
КонецФункции

// Возвращает Истина, если привилегированный режим был установлен
// при запуске с помощью параметра UsePrivilegedMode.
//
// Поддерживается только при запуске клиентских приложений
// (внешнее соединение не поддерживается).
// 
// Возвращаемое значение:
//  Булево
// 
Функция ПривилегированныйРежимУстановленПриЗапуске() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);	
	Возврат ПараметрыСеанса.ПараметрыКлиентаНаСервере.Получить(
		"ПривилегированныйРежимУстановленПриЗапуске") = Истина;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Использование идентификаторов объектов метаданных конфигурации и расширений.

// Только для внутреннего использования.
// 
// Возвращаемое значение:
//  Булево
//
Функция ОтключитьИдентификаторыОбъектовМетаданных() Экспорт
	
	ОбщиеПараметры = ОбщегоНазначения.ОбщиеПараметрыБазовойФункциональности();	
	Если НЕ ОбщиеПараметры.ОтключитьИдентификаторыОбъектовМетаданных Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ВариантыОтчетов")
	 ИЛИ ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ДополнительныеОтчетыИОбработки")
	 ИЛИ ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.РассылкаОтчетов")
	 ИЛИ ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.УправлениеДоступом") Тогда
		
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Невозможно отключить справочник идентификаторов объектов метаданных,
			           |если используется любая из следующих подсистем:
			           |- %1,
			           |- %2,
			           |- %3,
			           |- %4.'"),
			"ВариантыОтчетов", "ДополнительныеОтчетыИОбработки", "РассылкаОтчетов", "УправлениеДоступом");
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

// Только для внутреннего использования.
// 
// Параметры:
//  ПроверитьОбновление  - Булево
//  ОбъектыРасширений    - Булево
//
// Возвращаемое значение:
//  Булево
//
Функция ИдентификаторыОбъектовМетаданныхПроверкаИспользования(ПроверитьОбновление = Ложь, ОбъектыРасширений = Ложь) Экспорт
	
	Справочники.ИдентификаторыОбъектовМетаданных.ПроверкаИспользования(ОбъектыРасширений);
	
	Если ПроверитьОбновление Тогда
		Справочники.ИдентификаторыОбъектовМетаданных.ДанныеОбновлены(Истина, ОбъектыРасширений);
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Процедуры и функции работы с обменом данными.

// Возвращает признак использования в информационной базе полного РИБ (без фильтров).
// Проверка выполняется по более точному алгоритму, если используется подсистема "Обмен данными".
//
// Параметры:
//  ФильтрПоНазначению - Строка - уточняет, наличие какого РИБ проверяется:
//                                Пустая строка - любого РИБ;
//                                "СФильтром" - РИБ с фильтром;
//                                "Полный" - РИБ без фильтров.
//
// Возвращаемое значение:
//   Булево
//
Функция ИспользуетсяРИБ(ФильтрПоНазначению = "") Экспорт
	
	Если УзлыРИБ(ФильтрПоНазначению).Количество() > 0 Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
	
КонецФункции

// Возвращает список используемых в информационной базе узлов РИБ (без фильтров).
// Проверка выполняется по более точному алгоритму, если используется подсистема "Обмен данными".
//
// Параметры:
//  ФильтрПоНазначению - Строка - задает назначение узлов планов обмена РИБ, которые необходимо вернуть:
//                                Пустая строка - будут возвращены все узлы РИБ;
//                                "СФильтром" - будут возвращены узлы РИБ с фильтром;
//                                "Полный" - будут возвращены узлы РИБ без фильтров.
//
// Возвращаемое значение:
//   СписокЗначений
//
Функция УзлыРИБ(ФильтрПоНазначению = "") Экспорт
	
	ФильтрПоНазначению = ВРег(ФильтрПоНазначению);
	
	СписокУзлов = Новый СписокЗначений;
	
	ПланыОбменаРИБ = ПланыОбменаРИБ();
	Запрос = Новый Запрос();
	Для Каждого ИмяПланаОбмена Из ПланыОбменаРИБ Цикл
		
		Если ЗначениеЗаполнено(ФильтрПоНазначению)
			И ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОбменДанными") Тогда
			
			МодульОбменДаннымиСервер = ОбщегоНазначения.ОбщийМодуль("ОбменДаннымиСервер");
			НазначениеРИБ = ВРег(МодульОбменДаннымиСервер.НазначениеПланаОбмена(ИмяПланаОбмена));
			
			Если ФильтрПоНазначению = "СФИЛЬТРОМ" И НазначениеРИБ <> "РИБСФИЛЬТРОМ"
				Или ФильтрПоНазначению = "ПОЛНЫЙ" И НазначениеРИБ <> "РИБ" Тогда
				Продолжить;
			КонецЕсли;
		КонецЕсли;
		
		Запрос.Текст =
		"ВЫБРАТЬ
		|	ПланОбмена.Ссылка КАК Ссылка
		|ИЗ
		|	&ИмяПланаОбмена КАК ПланОбмена
		|ГДЕ
		|	НЕ ПланОбмена.ЭтотУзел
		|	И НЕ ПланОбмена.ПометкаУдаления";
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "&ИмяПланаОбмена", "ПланОбмена" + "." + ИмяПланаОбмена);
		ВыборкаУзлов = Запрос.Выполнить().Выбрать();
		Пока ВыборкаУзлов.Следующий() Цикл
			СписокУзлов.Добавить(ВыборкаУзлов.Ссылка);
		КонецЦикла;
	КонецЦикла;
	
	Возврат СписокУзлов;
	
КонецФункции

// Возвращает список планов обмена РИБ.
// Если конфигурация работает в модели сервиса,
// то возвращает список разделенных планов обмена РИБ.
// 
// Возвращаемое значение:
//  Массив из Строка
// 
Функция ПланыОбменаРИБ() Экспорт
	
	Результат = Новый Массив;
	
	Если ОбщегоНазначения.РазделениеВключено() Тогда
		
		Для Каждого ПланОбмена Из Метаданные.ПланыОбмена Цикл
			
			Если Лев(ПланОбмена.Имя, 7) = "Удалить" Тогда
				Продолжить;
			КонецЕсли;
			
			Если ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса.БазоваяФункциональность") Тогда
				МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
				ЭтоРазделенныеДанные = МодульРаботаВМоделиСервиса.ЭтоРазделенныйОбъектМетаданных(
					ПланОбмена.ПолноеИмя(), МодульРаботаВМоделиСервиса.РазделительОсновныхДанных());
			Иначе
				ЭтоРазделенныеДанные = Ложь;
			КонецЕсли;
			
			Если ПланОбмена.РаспределеннаяИнформационнаяБаза
				И ЭтоРазделенныеДанные Тогда
				
				Результат.Добавить(ПланОбмена.Имя);
				
			КонецЕсли;
			
		КонецЦикла;
		
	Иначе
		
		Для Каждого ПланОбмена Из Метаданные.ПланыОбмена Цикл
			
			Если Лев(ПланОбмена.Имя, 7) = "Удалить" Тогда
				Продолжить;
			КонецЕсли;
			
			Если ПланОбмена.РаспределеннаяИнформационнаяБаза Тогда
				
				Результат.Добавить(ПланОбмена.Имя);
				
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Определяет режим регистрации данных на узлах плана обмена.
// 
// Параметры:
//  ПолноеИмяОбъекта - Строка - полное имя проверяемого объекта метаданных.
//  ИмяПланаОбмена - Строка - проверяемый план обмена.
//
// Возвращаемое значение:
//  Неопределено - объект не включен в состав плана обмена,
//  "АвторегистрацияВключена"  - объект включен в состав плана обмена, авторегистрация включена,
//  "АвторегистрацияОтключена" - объект включен в состав плана обмена, авторегистрация отключена,
//                               объекты обрабатываются при создания начального образа РИБ.
//  "ПрограммнаяРегистрация"   - объект включен в состав плана обмена, авторегистрация отключена,
//                               регистрация осуществляется программно с помощью подписок на события,
//                               объекты обрабатываются при создания начального образа РИБ.
//
Функция РежимРегистрацииДанныхДляПланаОбмена(ПолноеИмяОбъекта, ИмяПланаОбмена) Экспорт
	
	ОбъектМетаданных = Метаданные.НайтиПоПолномуИмени(ПолноеИмяОбъекта);
	
	ЭлементСоставаПланаОбмена = Метаданные.ПланыОбмена[ИмяПланаОбмена].Состав.Найти(ОбъектМетаданных);
	Если ЭлементСоставаПланаОбмена = Неопределено Тогда
		Возврат Неопределено;
	ИначеЕсли ЭлементСоставаПланаОбмена.Авторегистрация = АвтоРегистрацияИзменений.Разрешить Тогда
		Возврат "АвторегистрацияВключена";
	КонецЕсли;
	
	// Анализ подписок на события для более сложных вариантов использования,
	// когда механизм платформенной авторегистрации отключен для объекта метаданных.
	Для каждого Подписка Из Метаданные.ПодпискиНаСобытия Цикл
		НачалоНазванияПодписки = ИмяПланаОбмена + "Регистрация";
		Если ВРег(Лев(Подписка.Имя, СтрДлина(НачалоНазванияПодписки))) = ВРег(НачалоНазванияПодписки) Тогда
			Для каждого Тип Из Подписка.Источник.Типы() Цикл
				Если ОбъектМетаданных = Метаданные.НайтиПоТипу(Тип) Тогда
					Возврат "ПрограммнаяРегистрация";
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;
	
	Возврат "АвторегистрацияОтключена";
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Прочее.

// Доступность объектов метаданных по функциональным опциям.
// 
// Возвращаемое значение:
//  ФиксированноеСоответствие из КлючИЗначение:
//   * Ключ - Строка
//   * Значение - Булево
//
Функция ДоступностьОбъектовПоОпциям() Экспорт
	
	Параметры = Новый Структура(СтандартныеПодсистемыПовтИсп.ОпцииИнтерфейса());
	
	ДоступностьОбъектов = Новый Соответствие;
	Для Каждого ФункциональнаяОпция Из Метаданные.ФункциональныеОпции Цикл
		Значение = -1;
		Для Каждого Элемент Из ФункциональнаяОпция.Состав Цикл
			Если Элемент.Объект = Неопределено Тогда
				Продолжить;
			КонецЕсли;
			Если Значение = -1 Тогда
				Значение = ПолучитьФункциональнуюОпцию(ФункциональнаяОпция.Имя, Параметры);
			КонецЕсли;
			ПолноеИмя = Элемент.Объект.ПолноеИмя();
			Если Значение = Истина Тогда
				ДоступностьОбъектов.Вставить(ПолноеИмя, Истина);
			Иначе
				Если ДоступностьОбъектов[ПолноеИмя] = Неопределено Тогда
					ДоступностьОбъектов.Вставить(ПолноеИмя, Ложь);
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	Возврат Новый ФиксированноеСоответствие(ДоступностьОбъектов);
	
КонецФункции

// Последняя версия компоненты из макета.
// 
// Параметры:
//  Местоположение - Строка - полное имя макета в метаданных
// 
// Возвращаемое значение:
//  ФиксированнаяСтруктура - последняя версия компоненты из макета:
//   * Версия - Строка
//   * Местоположение - Строка
//
Функция ПоследняяВерсияКомпонентыИзМакета(Местоположение) Экспорт
	
	МестоположениеМакетаРазделенное = СтрРазделить(Местоположение, ".");
	НачалоИмениМакета = МестоположениеМакетаРазделенное.Получить(МестоположениеМакетаРазделенное.ВГраница());
	
	Если МестоположениеМакетаРазделенное.Количество() = 2 Тогда
		ПутьКМакетам = Метаданные.ОбщиеМакеты;
	Иначе
		МестоположениеМакетаРазделенное.Удалить(МестоположениеМакетаРазделенное.ВГраница());
		МестоположениеМакетаРазделенное.Удалить(МестоположениеМакетаРазделенное.ВГраница());
		МетаданныеПоПолномуИмени = Метаданные.НайтиПоПолномуИмени(СтрСоединить(МестоположениеМакетаРазделенное, "."));
		
		Если МетаданныеПоПолномуИмени = Неопределено Тогда 
			Параметры = Новый Структура;
			Параметры.Вставить("Версия", "0.0.0.0");
			Параметры.Вставить("Местоположение", Местоположение);
			Возврат Новый ФиксированнаяСтруктура(Параметры);
		КонецЕсли;
		
		ПутьКМакетам = МетаданныеПоПолномуИмени.Макеты;
	КонецЕсли;
	
	ТаблицаВерсий = Новый ТаблицаЗначений;
	ТаблицаВерсий.Колонки.Добавить("ПолноеИмяМакета");
	ТаблицаВерсий.Колонки.Добавить("Версия");
	ТаблицаВерсий.Колонки.Добавить("РасширеннаяВерсия", ОбщегоНазначения.ОписаниеТипаСтрока(23));
	
	Для Каждого Макет Из ПутьКМакетам Цикл
		
		Если Макет.ТипМакета <> Метаданные.СвойстваОбъектов.ТипМакета.ВнешняяКомпонента
			И Макет.ТипМакета <> Метаданные.СвойстваОбъектов.ТипМакета.ДвоичныеДанные Тогда
			Продолжить;
		КонецЕсли;
		
		ИмяМакета = Макет.Имя;
				
		Если СтрНачинаетсяС(ВРег(ИмяМакета), ВРег(НачалоИмениМакета)) Тогда
			
			Если ВРег(ИмяМакета) = ВРег(НачалоИмениМакета) Тогда
				СтрокаТаблицыВерсий = ТаблицаВерсий.Добавить();
				СтрокаТаблицыВерсий.ПолноеИмяМакета = Макет.ПолноеИмя();
				СтрокаТаблицыВерсий.РасширеннаяВерсия = "00000_00000_00000_00000";
				СтрокаТаблицыВерсий.Версия = "0.0.0.0";
			Иначе
				Если Сред(ИмяМакета, СтрДлина(НачалоИмениМакета) + 1, 1) <> "_" Тогда
					Продолжить;
				КонецЕсли;
				
				Версия = Сред(ИмяМакета, СтрДлина(НачалоИмениМакета) + 1);
				ЧастиВерсии = СтрРазделить(Версия, "_", Ложь);
				Если ЧастиВерсии.Количество() <> 4 Тогда
					Продолжить;
				КонецЕсли;
				
				РасширенныеЧастиВерсии = Новый Массив;
				Для Каждого ЧастьВерсии Из ЧастиВерсии Цикл
					РасширенныеЧастиВерсии.Добавить(ВРег(Прав("0000" + ЧастьВерсии, 5)));
				КонецЦикла;
				СтрокаТаблицыВерсий = ТаблицаВерсий.Добавить();
				СтрокаТаблицыВерсий.ПолноеИмяМакета = Макет.ПолноеИмя();
				СтрокаТаблицыВерсий.РасширеннаяВерсия = СтрСоединить(РасширенныеЧастиВерсии, "_");
				СтрокаТаблицыВерсий.Версия = СтрСоединить(ЧастиВерсии, ".");
			КонецЕсли;
			
		КонецЕсли;
	КонецЦикла;
	
	Если ТаблицаВерсий.Количество() = 0 Тогда
		
		Параметры = Новый Структура;
		Параметры.Вставить("Версия", "0.0.0.0");
		Параметры.Вставить("Местоположение", Местоположение);
		
		Возврат Новый ФиксированнаяСтруктура(Параметры);
		
	КонецЕсли;
	
	ТаблицаВерсий.Сортировать("РасширеннаяВерсия Убыв");
	
	Параметры = Новый Структура;
	Параметры.Вставить("Версия", ТаблицаВерсий[0].Версия);
	Параметры.Вставить("Местоположение", ТаблицаВерсий[0].ПолноеИмяМакета);

	Возврат Новый ФиксированнаяСтруктура(Параметры);
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Параметры, применяемых к элементам командного интерфейса, связанным с параметрическими функциональными опциями.
// 
// Возвращаемое значение:
//  ФиксированнаяСтруктура:
//   * Ключ - Строка
//   * Значение - Произвольный
//
Функция ОпцииИнтерфейса() Экспорт 
	
	ОпцииИнтерфейса = Новый Структура;
	ОбщегоНазначенияПереопределяемый.ПриОпределенииПараметровФункциональныхОпцийИнтерфейса(ОпцииИнтерфейса);
	Возврат Новый ФиксированнаяСтруктура(ОпцииИнтерфейса);
	
КонецФункции

// Возвращает соответствие имен "функциональных" подсистем и значения Истина.
// У "функциональной" подсистемы снят флажок "Включать в командный интерфейс".
//
// Возвращаемое значение:
//  ФиксированноеСоответствие из КлючИЗначение:
//   * Ключ - Строка
//   * Значение - Булево
//
Функция ИменаПодсистем() Экспорт
	
	ОтключенныеПодсистемы = Новый Соответствие;
	ОбщегоНазначенияПереопределяемый.ПриОпределенииОтключенныхПодсистем(ОтключенныеПодсистемы);
	
	Имена = Новый Соответствие;
	ВставитьИменаПодчиненныхПодсистем(Имена, Метаданные, ОтключенныеПодсистемы);
	
	Возврат Новый ФиксированноеСоответствие(Имена);
	
КонецФункции

Функция ОписаниеТипаВсеСсылки() Экспорт
	
	Возврат Новый ОписаниеТипов(Новый ОписаниеТипов(Новый ОписаниеТипов(Новый ОписаниеТипов(Новый ОписаниеТипов(
		Новый ОписаниеТипов(Новый ОписаниеТипов(Новый ОписаниеТипов(Новый ОписаниеТипов(
			Справочники.ТипВсеСсылки(),
			Документы.ТипВсеСсылки().Типы()),
			ПланыОбмена.ТипВсеСсылки().Типы()),
			Перечисления.ТипВсеСсылки().Типы()),
			ПланыВидовХарактеристик.ТипВсеСсылки().Типы()),
			ПланыСчетов.ТипВсеСсылки().Типы()),
			ПланыВидовРасчета.ТипВсеСсылки().Типы()),
			БизнесПроцессы.ТипВсеСсылки().Типы()),
			БизнесПроцессы.ТипВсеСсылкиТочекМаршрутаБизнесПроцессов().Типы()),
			Задачи.ТипВсеСсылки().Типы());
	
КонецФункции

Функция ЭтоСеансДлительнойОперации() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	КлючСеансаРодителя = ПараметрыСеанса.ПараметрыКлиентаНаСервере.Получить("КлючСеансаРодителя");
	УстановитьПривилегированныйРежим(Ложь);
	
	Возврат ЗначениеЗаполнено(КлючСеансаРодителя);
	
КонецФункции

Функция РазделениеВключено() Экспорт
	
	Если ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса.БазоваяФункциональность") Тогда
		МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
		Возврат МодульРаботаВМоделиСервиса.РазделениеВключено();
	Иначе
		Возврат Ложь;
	КонецЕсли;
	
КонецФункции

Функция ДоступноИспользованиеРазделенныхДанных() Экспорт
	
	Если ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса.БазоваяФункциональность") Тогда
		МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
		Возврат МодульРаботаВМоделиСервиса.ДоступноИспользованиеРазделенныхДанных();
	Иначе
		Возврат Истина;
	КонецЕсли;
	
КонецФункции

Функция ИменаКоллекцийПоИменамБазовыхТипов() Экспорт
	
	ИменаКоллекций = Новый Соответствие;
	ИменаКоллекций.Вставить(ВРег("Подсистема"), "Подсистемы");
	ИменаКоллекций.Вставить(ВРег("ОбщийМодуль"), "ОбщиеМодули");
	ИменаКоллекций.Вставить(ВРег("ПараметрСеанса"), "ПараметрыСеанса");
	ИменаКоллекций.Вставить(ВРег("Роль"), "Роли");
	ИменаКоллекций.Вставить(ВРег("ОбщийРеквизит"), "ОбщиеРеквизиты");
	ИменаКоллекций.Вставить(ВРег("ПланОбмена"), "ПланыОбмена");
	ИменаКоллекций.Вставить(ВРег("КритерийОтбора"), "КритерииОтбора");
	ИменаКоллекций.Вставить(ВРег("ПодпискаНаСобытие"), "ПодпискиНаСобытия");
	ИменаКоллекций.Вставить(ВРег("РегламентноеЗадание"), "РегламентныеЗадания");
	ИменаКоллекций.Вставить(ВРег("ФункциональнаяОпция"), "ФункциональныеОпции");
	ИменаКоллекций.Вставить(ВРег("ПараметрФункциональныхОпций"), "ПараметрыФункциональныхОпций");
	ИменаКоллекций.Вставить(ВРег("ОпределяемыйТип"), "ОпределяемыеТипы");
	ИменаКоллекций.Вставить(ВРег("ХранилищеНастроек"), "ХранилищаНастроек");
	ИменаКоллекций.Вставить(ВРег("ОбщаяФорма"), "ОбщиеФормы");
	ИменаКоллекций.Вставить(ВРег("ОбщаяКоманда"), "ОбщиеКоманды");
	ИменаКоллекций.Вставить(ВРег("ГруппаКоманд"), "ГруппыКоманд");
	ИменаКоллекций.Вставить(ВРег("ОбщийМакет"), "ОбщиеМакеты");
	ИменаКоллекций.Вставить(ВРег("ОбщаяКартинка"), "ОбщиеКартинки");
	ИменаКоллекций.Вставить(ВРег("ПакетXDTO"), "ПакетыXDTO");
	ИменаКоллекций.Вставить(ВРег("WebСервис"), "WebСервисы");
	ИменаКоллекций.Вставить(ВРег("HTTPСервис"), "HTTPСервисы");
	ИменаКоллекций.Вставить(ВРег("WSСсылка"), "WSСсылки");
	ИменаКоллекций.Вставить(ВРег("СервисИнтеграции"), "СервисыИнтеграции");
	ИменаКоллекций.Вставить(ВРег("ЭлементСтиля"), "ЭлементыСтиля");
	ИменаКоллекций.Вставить(ВРег("Стиль"), "Стили");
	ИменаКоллекций.Вставить(ВРег("Язык"), "Языки");
	ИменаКоллекций.Вставить(ВРег("Константа"), "Константы");
	ИменаКоллекций.Вставить(ВРег("Справочник"), "Справочники");
	ИменаКоллекций.Вставить(ВРег("Документ"), "Документы");
	ИменаКоллекций.Вставить(ВРег("Последовательность"), "Последовательности");
	ИменаКоллекций.Вставить(ВРег("ЖурналДокументов"), "ЖурналыДокументов");
	ИменаКоллекций.Вставить(ВРег("Перечисление"), "Перечисления");
	ИменаКоллекций.Вставить(ВРег("Отчет"), "Отчеты");
	ИменаКоллекций.Вставить(ВРег("Обработка"), "Обработки");
	ИменаКоллекций.Вставить(ВРег("ПланВидовХарактеристик"), "ПланыВидовХарактеристик");
	ИменаКоллекций.Вставить(ВРег("ПланСчетов"), "ПланыСчетов");
	ИменаКоллекций.Вставить(ВРег("ПланВидовРасчета"), "ПланыВидовРасчета");
	ИменаКоллекций.Вставить(ВРег("РегистрСведений"), "РегистрыСведений");
	ИменаКоллекций.Вставить(ВРег("РегистрНакопления"), "РегистрыНакопления");
	ИменаКоллекций.Вставить(ВРег("РегистрБухгалтерии"), "РегистрыБухгалтерии");
	ИменаКоллекций.Вставить(ВРег("РегистрРасчета"), "РегистрыРасчета");
	ИменаКоллекций.Вставить(ВРег("БизнесПроцесс"), "БизнесПроцессы");
	ИменаКоллекций.Вставить(ВРег("Задача"), "Задачи");
	ИменаКоллекций.Вставить(ВРег("ВнешниеИсточникиДанных"), "ВнешнийИсточникДанных");
	
	Возврат Новый ФиксированноеСоответствие(ИменаКоллекций);
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Для справочника ИдентификаторыОбъектовМетаданных.

// См. Справочники.ИдентификаторыОбъектовМетаданных.КэшИдентификаторовОбъектовМетаданных
Функция КэшИдентификаторовОбъектовМетаданных(КлючДанныхПовторногоИспользования) Экспорт
	
	Возврат Справочники.ИдентификаторыОбъектовМетаданных.КэшИдентификаторовОбъектовМетаданных(
		КлючДанныхПовторногоИспользования);
	
КонецФункции

// См. Справочники.ИдентификаторыОбъектовМетаданных.ТаблицаПереименованияДляТекущейВерсии
Функция ТаблицаПереименованияДляТекущейВерсии() Экспорт
	
	Возврат Справочники.ИдентификаторыОбъектовМетаданных.ТаблицаПереименованияДляТекущейВерсии();
	
КонецФункции

// См. Справочники.ИдентификаторыОбъектовМетаданных.СвойстваКоллекцийОбъектовМетаданных
Функция СвойстваКоллекцийОбъектовМетаданных(ОбъектыРасширений = Ложь) Экспорт
	
	Возврат Справочники.ИдентификаторыОбъектовМетаданных.СвойстваКоллекцийОбъектовМетаданных(ОбъектыРасширений);
	
КонецФункции

// См. Справочники.ИдентификаторыОбъектовМетаданных.ПредставлениеИдентификатора
Функция ПредставлениеИдентификатораОбъектаМетаданных(Ссылка) Экспорт
	
	Возврат Справочники.ИдентификаторыОбъектовМетаданных.ПредставлениеИдентификатора(Ссылка);
	
КонецФункции

// См. Справочники.ИдентификаторыОбъектовМетаданных.РолиПоКлючамОбъектовМетаданных
Функция РолиПоКлючамОбъектовМетаданных() Экспорт
	
	Возврат Справочники.ИдентификаторыОбъектовМетаданных.РолиПоКлючамОбъектовМетаданных();
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Работа с предопределенными данными.

// Возвращает соответствие имен предопределенных значений ссылкам на них.
//
// Параметры:
//  ПолноеИмяОбъектаМетаданных - Строка - например, "Справочник.ВидыНоменклатуры",
//                               Поддерживаются только таблицы
//                               с предопределенными элементами:
//                               > Справочники,
//                               > Планы видов характеристик,
//                               > Планы счетов,
//                               > Планы видов расчета.
//
// Возвращаемое значение:
//  ФиксированноеСоответствие из КлючИЗначение:
//      * Ключ     - Строка - имя предопределенного,
//      * Значение - СправочникСсылка
//                 - ПланВидовХарактеристикСсылка
//                 - ПланСчетовСсылка
//                 - ПланВидовРасчетаСсылка
//                 - Null - ссылка предопределенного или Null, если объекта нет в ИБ.
//
//  Если ошибка в имени метаданных или неподходящий тип метаданного, то возвращается Неопределено.
//  Если предопределенных у метаданного нет, то возвращается пустое фиксированное соответствие.
//  Если предопределенный определен в метаданных, но не создан в ИБ, то для него в соответствии возвращается Null.
//
Функция СсылкиПоИменамПредопределенных(ПолноеИмяОбъектаМетаданных) Экспорт
	
	ПредопределенныеЗначения = Новый Соответствие;
	
	МетаданныеОбъекта = Метаданные.НайтиПоПолномуИмени(ПолноеИмяОбъектаМетаданных);
	
	// Если метаданных не существует.
	Если МетаданныеОбъекта = Неопределено Тогда 
		Возврат Неопределено;
	КонецЕсли;
	
	// Если не подходящий тип метаданных.
	Если Не Метаданные.Справочники.Содержит(МетаданныеОбъекта)
		И Не Метаданные.ПланыВидовХарактеристик.Содержит(МетаданныеОбъекта)
		И Не Метаданные.ПланыСчетов.Содержит(МетаданныеОбъекта)
		И Не Метаданные.ПланыВидовРасчета.Содержит(МетаданныеОбъекта) Тогда 
		
		Возврат Неопределено;
	КонецЕсли;
	
	ИменаПредопределенных = МетаданныеОбъекта.ПолучитьИменаПредопределенных();
	
	// Если предопределенных у метаданного нет.
	Если ИменаПредопределенных.Количество() = 0 Тогда 
		Возврат Новый ФиксированноеСоответствие(ПредопределенныеЗначения);
	КонецЕсли;
	
	// Заполнение по умолчанию признаком отсутствия в ИБ (присутствующие переопределятся).
	Для каждого ИмяПредопределенного Из ИменаПредопределенных Цикл 
		ПредопределенныеЗначения.Вставить(ИмяПредопределенного, Null);
	КонецЦикла;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ТекущаяТаблица.Ссылка КАК Ссылка,
		|	ТекущаяТаблица.ИмяПредопределенныхДанных КАК ИмяПредопределенныхДанных
		|ИЗ
		|	&ТекущаяТаблица КАК ТекущаяТаблица
		|ГДЕ
		|	ТекущаяТаблица.Предопределенный";
	
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "&ТекущаяТаблица", ПолноеИмяОбъектаМетаданных);
	
	УстановитьОтключениеБезопасногоРежима(Истина);
	УстановитьПривилегированныйРежим(Истина);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	УстановитьПривилегированныйРежим(Ложь);
	УстановитьОтключениеБезопасногоРежима(Ложь);
	
	// Заполнение присутствующих в ИБ.
	Пока Выборка.Следующий() Цикл
		ПредопределенныеЗначения.Вставить(Выборка.ИмяПредопределенныхДанных, Выборка.Ссылка);
	КонецЦикла;
	
	Возврат Новый ФиксированноеСоответствие(ПредопределенныеЗначения);
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Вспомогательные процедуры и функции

// Возвращаемое значение:
//   Структура:
//   * ПараллельноеОтложенноеОбновлениеСВерсии - Строка
//   * РежимВыполненияОтложенныхОбработчиков - Строка
//   * ОсновнойСерверныйМодуль - Строка
//   * ЭтоКонфигурация - Булево
//   * ИдентификаторИнтернетПоддержки - Строка
//   * ТребуемыеПодсистемы - Массив
//   * Версия - Строка
//   * Имя - Строка
//   * ЗаполнятьДанныеНовыхПодсистемПриПереходеСДругойПрограммы - Булево
//
Функция НовоеОписаниеПодсистемы() Экспорт
	
	Описание = Новый Структура;
	Описание.Вставить("Имя",    "");
	Описание.Вставить("Версия", "");
	Описание.Вставить("ТребуемыеПодсистемы", Новый Массив);
	Описание.Вставить("ИдентификаторИнтернетПоддержки", "");
	
	// Свойство устанавливается автоматически.
	Описание.Вставить("ЭтоКонфигурация", Ложь);
	
	// Имя основного модуля библиотеки.
	// Может быть пустым для конфигурации.
	Описание.Вставить("ОсновнойСерверныйМодуль", "");
	
	// Режим выполнения отложенных обработчиков обновления.
	// По умолчанию Последовательно.
	Описание.Вставить("РежимВыполненияОтложенныхОбработчиков", "Последовательно");
	Описание.Вставить("ПараллельноеОтложенноеОбновлениеСВерсии", "");
	
	// Режим выполнения обработчиков начального заполнения при переходе
	// с другой программы.
	Описание.Вставить("ЗаполнятьДанныеНовыхПодсистемПриПереходеСДругойПрограммы", Ложь);
	
	Возврат Описание;
	
КонецФункции

Процедура ВставитьИменаПодчиненныхПодсистем(Имена, РодительскаяПодсистема, ОтключенныеПодсистемы, ИмяРодительскойПодсистемы = "")
	
	Для Каждого ТекущаяПодсистема Из РодительскаяПодсистема.Подсистемы Цикл
		
		Если ТекущаяПодсистема.ВключатьВКомандныйИнтерфейс Тогда
			Продолжить;
		КонецЕсли;
		
		ИмяТекущейПодсистемы = ИмяРодительскойПодсистемы + ТекущаяПодсистема.Имя;
		Если ОтключенныеПодсистемы.Получить(ИмяТекущейПодсистемы) = Истина Тогда
			Продолжить;
		Иначе
			Имена.Вставить(ИмяТекущейПодсистемы, Истина);
		КонецЕсли;
		
		Если ТекущаяПодсистема.Подсистемы.Количество() = 0 Тогда
			Продолжить;
		КонецЕсли;
		
		ВставитьИменаПодчиненныхПодсистем(Имена, ТекущаяПодсистема, ОтключенныеПодсистемы, ИмяТекущейПодсистемы + ".");
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти