
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКоманды.ПриСозданииНаСервере(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды   
	
	// {{Шаблов А.В.: создание группы "согласованная скидка" на форме,добавление в нее команды и поля ввода для реквизита

	ГруппаФормы = Элементы.Вставить("ГруппаСогласованнаяСкидка",Тип("ГруппаФормы"),,Элементы.Страницы);
	ГруппаФормы.Вид = ВидГруппыФормы.ОбычнаяГруппа;
	ГруппаФормы.Группировка = ГруппировкаПодчиненныхЭлементовФормы.ГоризонтальнаяВсегда;
	
	ПолеВвода = Элементы.Добавить("СогласованнаяСкидка", Тип("ПолеФормы"),Элементы.ГруппаСогласованнаяСкидка);
	ПолеВвода.Вид = ВидПоляФормы.ПолеВвода;
	ПолеВвода.ПутьКДанным = "Объект.Дораб_СогласованнаяСкидка";
	
	ПолеВвода.УстановитьДействие("ПриИзменении","СогласованнаяСкидкаПриИзменении");
 	КомандаФормы = Команды.Добавить("ПересчитатьТаблицу");
	КомандаФормы.Заголовок = "Пересчитать таблицу";
	КомандаФормы.Действие = "ПересчитатьТаблицуНажатие";
	
	Кнопка = Элементы.Добавить("ПересчитатьТаблицу", Тип("КнопкаФормы"),Элементы.ГруппаСогласованнаяСкидка);
	Кнопка.ИмяКоманды = "ПересчитатьТаблицу";
	Кнопка.Вид = ВидКнопкиФормы.ОбычнаяКнопка;
	Кнопка.Отображение = ОтображениеКнопки.Авто;
		
// Шаблов А.В. }
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
    // СтандартныеПодсистемы.ПодключаемыеКоманды
    ПодключаемыеКомандыКлиент.НачатьОбновлениеКоманд(ЭтотОбъект);
    // Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
    // СтандартныеПодсистемы.ПодключаемыеКоманды
    ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
    // Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
    ПодключаемыеКомандыКлиент.ПослеЗаписи(ЭтотОбъект, Объект, ПараметрыЗаписи);
КонецПроцедуры

#КонецОбласти 

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура СогласованнаяСкидкаПриИзменении(Элемент)
	
	Если Объект.Товары.Количество() > 0 ИЛИ Объект.Услуги.Количество() > 0 Тогда
		ЗадатьВопросОПродолжении();
	КонецЕсли;
	
КонецПроцедуры 

// Шаблов А.В. }}

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура ТоварыКоличествоПриИзменении(Элемент)
	
	ТекущиеДанные = Элементы.Товары.ТекущиеДанные;
	
	РассчитатьСуммуСтроки(ТекущиеДанные);
	
КонецПроцедуры

&НаКлиенте
Процедура ТоварыЦенаПриИзменении(Элемент)
	
	ТекущиеДанные = Элементы.Товары.ТекущиеДанные;
	
	РассчитатьСуммуСтроки(ТекущиеДанные);
	
КонецПроцедуры

&НаКлиенте
Процедура УслугиКоличествоПриИзменении(Элемент)
	
	ТекущиеДанные = Элементы.Услуги.ТекущиеДанные;
	
	РассчитатьСуммуСтроки(ТекущиеДанные);
	
КонецПроцедуры

&НаКлиенте
Процедура УслугиЦенаПриИзменении(Элемент)
	
	ТекущиеДанные = Элементы.Услуги.ТекущиеДанные;
	
	РассчитатьСуммуСтроки(ТекущиеДанные);
	
КонецПроцедуры

&НаКлиенте
Процедура ТоварыПриИзменении(Элемент)
	РассчитатьСуммуДокумента();
КонецПроцедуры

&НаКлиенте
Процедура УслугиПриИзменении(Элемент)
	РассчитатьСуммуДокумента();
КонецПроцедуры


#КонецОбласти

#Область ОбработчикиКомандФормы

// {{Шаблов А.В.: обработчик команды пересчета суммы документа и сумм табличной части с учетом скидки

&НаКлиенте
Процедура ПересчитатьТаблицуНажатие()
	
	Скидка  = Объект.Дораб_СогласованнаяСкидка;
	
	Для каждого Стр Из Объект.Товары Цикл;
		СуммаБезСкидки = Стр.Количество * Стр.Цена;
		Стр.Сумма = СуммаБезСкидки - СуммаБезСкидки * Скидка/100;
	КонецЦикла;
	
	Для каждого Стр Из Объект.Услуги Цикл;
		СуммаБезСкидки = Стр.Количество * Стр.Цена;
		Стр.Сумма = СуммаБезСкидки - СуммаБезСкидки * Скидка/100;
	КонецЦикла;
	
	РассчитатьСуммуДокумента();
		
КонецПроцедуры

// Шаблов А.В.}}

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура РассчитатьСуммуСтроки(ТекущиеДанные)
	
	//ТекущиеДанные.Сумма = ТекущиеДанные.Цена * ТекущиеДанные.Количество;
	
	// {{Шаблов А.В.: доработка рассчёта суммы строки с учётом скидки	
	КоэффициентСкидки = 1 - Объект.Дораб_СогласованнаяСкидка / 100;
	ТекущиеДанные.Сумма = ТекущиеДанные.Цена * ТекущиеДанные.Количество * КоэффициентСкидки;
	// Шаблов А.В.}}
	
	РассчитатьСуммуДокумента();
	
КонецПроцедуры

&НаКлиенте
Процедура РассчитатьСуммуДокумента()
	
	Объект.СуммаДокумента = Объект.Товары.Итог("Сумма") + Объект.Услуги.Итог("Сумма");
	
КонецПроцедуры

// {{Шаблов А.В.:вопрос клиенту о согласии на пересчет сумм в строках табличной части и суммы документа с учетом скидки 
&НаКлиенте
Асинх Процедура ЗадатьВопросОПродолжении()
	
	Режим = РежимДиалогаВопрос.ДаНет;
	Ответ =  Ждать ВопросАсинх("Скидка изменилась, пересчитать таблицу?", Режим);
	
	Если Ответ = КодВозвратаДиалога.Да Тогда
		ПересчитатьТаблицуНажатие();
	КонецЕсли;
	
КонецПроцедуры

// Шаблов А.В.}}

#Область ПодключаемыеКоманды

// СтандартныеПодсистемы.ПодключаемыеКоманды
&НаКлиенте
Процедура Подключаемый_ВыполнитьКоманду(Команда)
    ПодключаемыеКомандыКлиент.НачатьВыполнениеКоманды(ЭтотОбъект, Команда, Объект);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ПродолжитьВыполнениеКомандыНаСервере(ПараметрыВыполнения, ДополнительныеПараметры) Экспорт
    ВыполнитьКомандуНаСервере(ПараметрыВыполнения);
КонецПроцедуры

&НаСервере
Процедура ВыполнитьКомандуНаСервере(ПараметрыВыполнения)
    ПодключаемыеКоманды.ВыполнитьКоманду(ЭтотОбъект, ПараметрыВыполнения, Объект);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ОбновитьКоманды()
    ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
КонецПроцедуры
// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

#КонецОбласти

#КонецОбласти
