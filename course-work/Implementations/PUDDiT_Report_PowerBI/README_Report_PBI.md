## 1. Структура на проекта

```
Implementations/
│
├── conceptual_chen_notation/
├── Logical_Crows_Foot_notation/
├── Data_Warehouse_UML_notation/
├── MS_SQL_Server_database/
├── PUDDiT_Report_PowerBI/
```

## 2. Инструкции за инсталация

### Необходими инструменти
- MS SQL Server
- SSMS
- Power BI Desktop
- Draw.io

### Стъпки
1. Създай база: `CREATE DATABASE PUDDiT;`
2. Зареди schema.sql
3. Зареди seed.sql

## 4. Power BI визуализации и SQL заявки

### 1. Брой постове по канали
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

### 2. Постове по време
```sql
SELECT 
    p.CreatedAt,
    COUNT(p.PostId) AS PostCount
FROM Post p
GROUP BY p.CreatedAt
ORDER BY p.CreatedAt;
```

### 3. Score по постове
```sql
SELECT 
    p.PostId,
    p.Title,
    SUM(CASE 
            WHEN v.Value = 1 THEN 1 
            WHEN v.Value = -1 THEN -1 
            ELSE 0 END
       ) AS Score
FROM Post p
LEFT JOIN PostVote v ON v.PostId = p.PostId
GROUP BY p.PostId, p.Title
ORDER BY Score DESC;
```

### 4. Брой коментари по постове
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

## 5. Стартиране
1. Увери се, че SQL Server работи
2. Отвори Power BI → Refresh
3. Готово – всички визуализации се обновяват
