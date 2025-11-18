# PUDDiT – Вътрешна академична дискусионна платформа

**Автор:** Борислав Минков  
**Факултетен номер:** 2301321069  
**Курс:** III курс, Софтуерно инженерство  
**Дисциплина:** Software Modeling and Analysis SE  
**Университет:** ПУ „Паисий Хилендарски“  
**Дата:** 2025 г.

---

## 1. Описание на проекта

PUDDiT е вътрешна дискусионна платформа за студенти и преподаватели.  
Идеята е да има едно място, в което:

- студентите задават въпроси по дисциплини;
- преподавателите публикуват важни съобщения;
- дискусиите са подредени по канали (курсове/тематики);
- има коментари, гласуване и базова модерация.

В курсовия проект са реализирани три основни части:

1. **Моделиране** – концептуален, логически и DW модел.  
2. **База данни** – MS SQL Server schema + seed данни, процедури, функции, тригер.  
3. **Доклад и анализ** – Power BI репорт върху реални данни от базата.

---

## 2. Структура на проекта (директории и съдържание)

Проектните файлове са в папка:

```text
course-work/Implementations/
```

Вътре има следните поддиректории:

### 2.1 `conceptual_chen_notation/`

Тук се намира концептуалният модел на PUDDiT, изграден по **Chen notation**.

Файлове:

- `PUDDiT_conceptual_chen.drawio` – оригиналният модел, редактиран в draw.io.  
- `PUDDiT_conceptual_chen.html` – експортирана HTML версия за преглед в браузър (без нужда от draw.io).

Моделът описва основните концептуални обекти:

- User, Channel, Post, Comment, PostVote, PostReport, CommentReport  
- връзки: потребител – канал, авторство, гласуване, докладване и др.

---

### 2.2 `Logical_Crows_Foot_notation/`

Тук е логическият модел на базата данни по **Crow’s Foot notation**.

Файлове:

- `PUDDiT_logical_crows_foot.drawio` – логическа ER диаграма (таблици, PK, FK, уникални ограничения).  
- `PUDDiT_logical_crows_foot.drawio.html` – HTML версия за преглед.

Моделът съдържа реалните таблици и атрибути, които по-късно са реализирани в `schema.sql`, включително:

- `User`, `Channel`, `ChannelMember`, `Post`, `Comment`, `PostVote`,  
  `PostReport`, `CommentReport` и съответните им връзки.

---

### 2.3 `Data_Warehouse_UML_notation/`

Тук е **Data Warehouse** моделът, реализиран с UML Database notation.

Файлове:

- `PUDDiT_DW_UML.drawio` – UML диаграма на DW модела.  
- `PUDDiT_DW_UML.drawio.html` – HTML версия.  
- `PUDDiT_DW_README.md` – кратко текстово описание на измеренията и фактите.

Моделът съдържа:

- Измерения (dimensions): `DimDate`, `DimUser`, `DimChannel`, `DimPost`, `DimStatus`, `DimVoteType`.  
- Факт таблици (facts): `FactPostDaily`, `FactCommentDaily`, `FactVoteDaily`.

DW е проектиран така, че да позволява анализ на активността в платформата по дни, потребители, канали, статус и тип гласувания.

---

### 2.4 `MS_SQL_Server_database/`

Това е основната папка за **реалната релационна база данни** в MS SQL Server.

Файлове:

- `schema.sql` – скрипт за създаване на базата данни PUDDiT (таблици, PK/FK, ограничения, индекси, процедура, функция, тригер).
- `seed.sql` – скрипт за начални данни (примерни потребители, канали, постове, коментари, гласове).
- `queries.sql` – примерни SELECT заявки за проверка и демонстрация.
- `PUDDiT_README.md` – кратко локално README за тази папка (техническо обяснение на SQL частта).

Тук се намира всичко необходимо, за да се стартира базата данни от нулата.

---

### 2.5 `PUDDiT_Report_PowerBI/`

Папка за **аналитичния доклад** върху базата данни.

Файлове:

- `PUDDiT_Report.pbix` – Power BI файл с визуализациите.  
- `TEST_Report.queries.sql` – SQL версиите на заявките, използвани за проверка на данните в SSMS.

Докладът използва директна връзка към базата `PUDDiT` и таблиците `Channel`, `Post`, `Comment`, `PostVote`, `User`.

---

## 3. Инсталация и стартиране на базата данни (MS SQL Server)

### 3.1. Необходими инструменти

- **MS SQL Server** (Express е достатъчен)  
- **SQL Server Management Studio (SSMS)**  
- (по желание) **Power BI Desktop** за доклада  
- **Browser + draw.io** (или само HTML версиите на диаграмите)

### 3.2. Стъпки за създаване на базата

1. Стартирай **SSMS** и се свържи към локалния инстанс.  
2. Създай празна база:

   ```sql
   CREATE DATABASE PUDDiT;
   GO
   USE PUDDiT;
   ```

3. От менюто **File → Open → File…** отвори:

   ```text
   MS_SQL_Server_database/schema.sql
   ```

   и изпълни целия скрипт (**Execute**).

   Това създава всички таблици, ключове, индекси, съхранена процедура, функция и тригер.

4. След това отвори:

   ```text
   MS_SQL_Server_database/seed.sql
   ```

   и го изпълни.  
   Това зарежда примерни данни – 3 потребителя, 2 канала, 6 поста, коментари и гласове.

5. (По желание) Отвори `queries.sql` и стартирай SELECT заявките, за да провериш:

   - броя постове,  
   - броя гласове,  
   - коментарите по постове,  
   - други справки.

---

## 4. Power BI доклад – визуализации и SQL заявки

Power BI файлът се намира в:

```text
PUDDiT_Report_PowerBI/PUDDiT_Report.pbix
```

След зареждане на данните от базата `PUDDiT` са реализирани 4 основни визуализации.

### 4.1. Брой постове по канали

**Power BI:** колонна диаграма –  
- X-Axis: `Channel.Name`  
- Y-Axis: `Count of Post.PostId`

**SQL еквивалент (в `TEST_Report.queries.sql`):**

```sql
SELECT 
    c.ChannelId,
    c.Name AS ChannelName,
    COUNT(p.PostId) AS PostCount
FROM Channel c
LEFT JOIN Post p ON p.ChannelId = c.ChannelId
GROUP BY c.ChannelId, c.Name
ORDER BY c.ChannelId;
```

---

### 4.2. Брой постове по време (CreatedAt)

**Power BI:** line chart –  
- X-Axis: `Post.CreatedAt` (Date/Time)  
- Y-Axis: `Count of Post.PostId`

**SQL еквивалент:**

```sql
SELECT 
    p.CreatedAt,
    COUNT(p.PostId) AS PostCount
FROM Post p
GROUP BY p.CreatedAt
ORDER BY p.CreatedAt;
```

Тази визуализация показва кога са създадени постовете (времева линия).

---

### 4.3. Score по постове (Upvotes – Downvotes)

**Power BI:** bar chart –  
- X-Axis: `Score` (изчислено поле)  
- Y-Axis: `Post.Title`

**SQL еквивалент:**

```sql
SELECT 
    p.PostId,
    p.Title,
    SUM(
        CASE 
            WHEN v.Value = 1  THEN 1 
            WHEN v.Value = -1 THEN -1 
            ELSE 0 
        END
    ) AS Score
FROM Post p
LEFT JOIN PostVote v ON v.PostId = p.PostId
GROUP BY p.PostId, p.Title
ORDER BY Score DESC;
```

Тук се вижда кои постове са най-подкрепяни / най-нелюбими според гласовете.

---

### 4.4. Брой коментари по постове

**Power BI:** bar chart –  
- X-Axis: `CommentCount`  
- Y-Axis: `Post.Title`

**SQL еквивалент:**

```sql
SELECT 
    p.PostId,
    p.Title,
    COUNT(c.CommentId) AS CommentCount
FROM Post p
LEFT JOIN Comment c ON c.PostId = p.PostId
GROUP BY p.PostId, p.Title
ORDER BY CommentCount DESC;
```

Тази визуализация показва кои постове генерират най-много дискусия.

---

## 5. Стартиране на Power BI доклада

1. Увери се, че **SQL Server** работи и базата `PUDDiT` е създадена и заредена (schema + seed).  
2. Отвори:

   ```text
   PUDDiT_Report_PowerBI/PUDDiT_Report.pbix
   ```

3. При нужда актуализирай connection string-а към твоя SQL Server инстанс (Server name).  
4. Натисни **Refresh** – всички визуализации се обновяват от текущите данни.  
5. По желание можеш да добавиш филтри по канал, статус или потребител.

---

## 6. Обобщение на моделите

- **Концептуален модел (Chen)** – фокус върху бизнес обектите и връзките между тях.  
- **Логически модел (Crow’s Foot)** – реални таблици, ключове и ограничения за релационната база.  
- **Data Warehouse UML модел** – ориентиран към анализ и репорти (Dim/Fact таблици), подходящ за бъдещо изграждане на OLAP/BI решения.

Трите нива показват как една идея (вътрешна дискусионна платформа) преминава от концепция → логически дизайн → аналитичен модел.

---

## 7. Авторство

Проектът **PUDDiT** е изцяло разработен за учебни цели от:

**Борислав Минков** (фак. № 2301321069)  
III курс, Софтуерно инженерство, ФМИ – Пловдивски университет.

Всички файлове в папката `Implementations/` са част от курсовата работа по  
**Software Modeling and Analysis SE**.