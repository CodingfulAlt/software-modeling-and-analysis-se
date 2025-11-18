USE PUDDiT;
GO

------------------------------------------------
-- 1. Проверка: всички таблици съществуват ли?
------------------------------------------------
SELECT name AS TableName
FROM sys.tables
ORDER BY name;
GO

------------------------------------------------
-- 2. Колко реда има във всяка таблица
------------------------------------------------

SELECT COUNT(*) AS UserCount FROM [User];
GO

SELECT COUNT(*) AS ChannelCount FROM Channel;
GO

SELECT COUNT(*) AS ChannelMemberCount FROM ChannelMember;
GO

SELECT COUNT(*) AS PostCount FROM Post;
GO

SELECT COUNT(*) AS CommentCount FROM Comment;
GO

SELECT COUNT(*) AS PostVoteCount FROM PostVote;
GO

SELECT COUNT(*) AS CommentVoteCount FROM CommentVote;
GO

SELECT COUNT(*) AS PostReportCount FROM PostReport;
GO

SELECT COUNT(*) AS CommentReportCount FROM CommentReport;
GO

------------------------------------------------
-- 3. Всички потребители
------------------------------------------------
SELECT 
    UserId,
    DisplayName,
    Email,
    FacultyNumber,
    Role,
    CreatedAt
FROM [User]
ORDER BY UserId;
GO

------------------------------------------------
-- 4. Канали и техните създатели
------------------------------------------------
SELECT
    c.ChannelId,
    c.Name       AS ChannelName,
    c.Description,
    c.IsPrivate,
    c.CreatedAt,
    u.DisplayName AS CreatedBy
FROM Channel c
JOIN [User] u ON c.CreatedByUserId = u.UserId
ORDER BY c.ChannelId;
GO

------------------------------------------------
-- 5. Членство по канали
------------------------------------------------
SELECT
    c.ChannelId,
    c.Name        AS ChannelName,
    u.UserId,
    u.DisplayName AS MemberName,
    cm.MemberRole,
    cm.JoinedAt
FROM ChannelMember cm
JOIN [User]  u ON cm.UserId    = u.UserId
JOIN Channel c ON cm.ChannelId = c.ChannelId
ORDER BY c.ChannelId, u.UserId;
GO

------------------------------------------------
-- 6. Всички постове с канал и автор
------------------------------------------------
SELECT
    p.PostId,
    p.Title,
    p.Status,
    p.CreatedAt,
    c.Name        AS ChannelName,
    u.DisplayName AS AuthorName
FROM Post p
JOIN Channel c ON p.ChannelId    = c.ChannelId
JOIN [User]  u ON p.AuthorUserId = u.UserId
ORDER BY p.PostId;
GO

------------------------------------------------
-- 7. Постове + брой коментари и брой гласове
------------------------------------------------
SELECT
    p.PostId,
    p.Title,
    c.Name            AS ChannelName,
    u.DisplayName     AS AuthorName,
    COUNT(DISTINCT cm.CommentId) AS CommentCount,
    COUNT(DISTINCT pv.VoteId)    AS VoteCount
FROM Post p
JOIN Channel c ON p.ChannelId    = c.ChannelId
JOIN [User]  u ON p.AuthorUserId = u.UserId
LEFT JOIN Comment   cm ON cm.PostId = p.PostId
LEFT JOIN PostVote  pv ON pv.PostId = p.PostId
GROUP BY
    p.PostId,
    p.Title,
    c.Name,
    u.DisplayName
ORDER BY p.PostId;
GO

------------------------------------------------
-- 8. Постове със score от fn_GetPostScore
------------------------------------------------
SELECT
    p.PostId,
    p.Title,
    p.Status,
    dbo.fn_GetPostScore(p.PostId) AS Score
FROM Post p
ORDER BY Score DESC, p.PostId;
GO

------------------------------------------------
-- 9. Коментари + пост + автор
------------------------------------------------
SELECT
    cm.CommentId,
    cm.Body        AS CommentBody,
    cm.Status,
    cm.CreatedAt,
    p.PostId,
    p.Title        AS PostTitle,
    u.DisplayName  AS CommentAuthor
FROM Comment cm
JOIN Post   p ON cm.PostId       = p.PostId
JOIN [User] u ON cm.AuthorUserId = u.UserId
ORDER BY cm.CommentId;
GO

------------------------------------------------
-- 10. Отворени доклади за постове
------------------------------------------------
SELECT
    pr.ReportId,
    pr.PostId,
    p.Title             AS PostTitle,
    pr.Reason,
    pr.Status,
    pr.CreatedAt,
    reporter.DisplayName AS Reporter,
    resolver.DisplayName AS ResolvedBy
FROM PostReport pr
JOIN Post    p        ON pr.PostId         = p.PostId
JOIN [User]  reporter ON pr.ReporterUserId = reporter.UserId
LEFT JOIN [User] resolver ON pr.ResolvedByUserId = resolver.UserId
WHERE pr.Status = 'Open'
ORDER BY pr.CreatedAt DESC;
GO

------------------------------------------------
-- 11. Отворени доклади за коментари
------------------------------------------------
SELECT
    cr.ReportId,
    cr.CommentId,
    cm.Body             AS CommentBody,
    cr.Reason,
    cr.Status,
    cr.CreatedAt,
    reporter.DisplayName AS Reporter,
    resolver.DisplayName AS ResolvedBy
FROM CommentReport cr
JOIN Comment cm        ON cr.CommentId        = cm.CommentId
JOIN [User]  reporter  ON cr.ReporterUserId   = reporter.UserId
LEFT JOIN [User] resolver ON cr.ResolvedByUserId = resolver.UserId
WHERE cr.Status = 'Open'
ORDER BY cr.CreatedAt DESC;
GO

------------------------------------------------
-- 12. Постове, които са Hidden (trigger-ът трябва да е пипал)
------------------------------------------------
SELECT
    p.PostId,
    p.Title,
    p.Status
FROM Post p
WHERE p.Status = 'Hidden';
GO

