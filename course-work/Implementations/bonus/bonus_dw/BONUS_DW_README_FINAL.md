# BONUS DW – PUDDiT Data Warehouse

Този бонус модул добавя **Data Warehouse (DW)** слой към проекта **PUDDiT**, отделно от оперативната база данни.

DW моделът позволява по-лесни и бързи справки за:
- активност по постове,
- коментари,
- гласуване,
- потребители и канали.

---

## 1. Предпоставки

Преди да използвате DW бонуса, трябва да имате:

1. **OLTP база данни `PUDDiT`**, създадена и заредена чрез:
   - `MS_SQL_Server_database/schema.sql`
   - `MS_SQL_Server_database/seed.sql`

2. Инсталиран **MS SQL Server** и **SQL Server Management Studio (SSMS)**.

---

## 2. Структура на BONUS DW папката

Папка (примерно):

```text
Implementations/BONUS/bonus_DW/
│
├── dw_schema.sql
├── dw_load_from_oltp.sql
└── BONUS_DW_README.md
```

### 2.1 `dw_schema.sql`

Създава структурата на Data Warehouse базата:

- **Измерения (Dimensions)**:
  - `DimDate`
  - `DimUser`
  - `DimChannel`
  - `DimPost`
  - `DimStatus`
  - `DimVoteType`

- **Факт таблици (Facts)**:
  - `FactPostDaily`
  - `FactCommentDaily`
  - `FactVoteDaily`

Таблиците са организирани в **звездовидна схема (Star Schema)**.

### 2.2 `dw_load_from_oltp.sql`

ETL скрипт, който:

- изчиства предишни данни от DW таблиците (чрез `DELETE`);
- зарежда Dim таблиците от оперативната база `PUDDiT`;
- агрегира данни и зарежда Fact таблиците.

По-конкретно:

- `DimDate`: генерира диапазон от дати между минималната и максималната дата от `CreatedAt` полетата в OLTP (User, Post, Comment, PostVote, PostReport, CommentReport) + fallback дата `1900-01-01`.
- `DimUser`: копира потребители от `PUDDiT.dbo.[User]`.
- `DimChannel`: копира канали от `PUDDiT.dbo.Channel`.
- `DimStatus`: попълва статични стойности за статусите (PostStatus, CommentStatus, ReportStatus).
- `DimVoteType`: попълва статични стойности за типовете гласове (Upvote, Downvote).
- `DimPost`: копира постове от `PUDDiT.dbo.Post` и ги свързва с DimChannel / DimUser.
- `FactPostDaily`: агрегира по пост – брой коментари, гласове, score, доклади.
- `FactCommentDaily`: агрегира по коментар – гласове, score, доклади.
- `FactVoteDaily`: агрегира по дата, канал и тип глас.

---

## 3. Създаване на DW база и зареждане на данните

### Стъпка 1: Създаване на DW база

В SSMS изпълнете:

```sql
CREATE DATABASE PUDDiT_DW;
GO
USE PUDDiT_DW;
GO

#има го също и във файла dw_schema.sql
```

### Стъпка 2: Създаване на DW таблиците

Отворете файла:

```text
dw_schema.sql
```

Уверете се, че контекстът е `PUDDiT_DW`, и изпълнете целия скрипт.

Това ще създаде всички Dim и Fact таблици.

### Стъпка 3: Зареждане на DW данните от OLTP

Уверете се, че базата `PUDDiT` съществува и е заредена.

След това:

1. В SSMS изберете база `PUDDiT_DW` (от падащото меню).
2. Отворете:

   ```text
   dw_load_from_oltp.sql
   ```

3. Изпълнете скрипта (**Execute**).

Ако всичко е наред, накрая ще получите:

```text
DW ETL LOAD COMPLETED SUCCESSFULLY (UPDATED).
```

---

## 4. Проверка на резултата

Може да използвате следните заявки, за да се уверите, че DW е зареден:

```sql
USE PUDDiT_DW;
GO

SELECT TOP 10 * FROM DimDate;
SELECT TOP 10 * FROM DimUser;
SELECT TOP 10 * FROM DimChannel;
SELECT TOP 10 * FROM DimPost;
SELECT TOP 10 * FROM DimStatus;
SELECT TOP 10 * FROM DimVoteType;

SELECT TOP 10 * FROM FactPostDaily;
SELECT TOP 10 * FROM FactCommentDaily;
SELECT TOP 10 * FROM FactVoteDaily;
```

Ако заявките връщат редове → DW моделът реално е попълнен с данни. - заявките са качени в папката също!!!!!!

---

## 5. Кратко обобщение за защита

> Освен оперативната база PUDDiT, реализирах и Data Warehouse модел в отделна база PUDDiT_DW.  
> В нея имам Dim и Fact таблици (звездовидна схема), които се зареждат от OLTP чрез скрипта dw_load_from_oltp.sql.  
> Това позволява по-лесно и бързо изграждане на BI справки и репорти.
