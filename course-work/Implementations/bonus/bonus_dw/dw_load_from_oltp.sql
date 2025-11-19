------------------------------------------------------------
-- DATA WAREHOUSE LOAD SCRIPT FOR PUDDiT (BONUS ETL)
-- Author: Borislav Minkov (FN: 2301321069)
-- Description: Loads dimensional and fact tables in PUDDiT_DW
--              from the OLTP database PUDDiT. Uses DELETE instead
--              of TRUNCATE and handles missing dates with fallback.
------------------------------------------------------------

USE PUDDiT_DW;
GO

------------------------------------------------------------
-- 0. CLEAN TABLES (DELETE instead of TRUNCATE due to FK)
------------------------------------------------------------

DELETE FROM FactVoteDaily;
DELETE FROM FactCommentDaily;
DELETE FROM FactPostDaily;

DELETE FROM DimPost;
DELETE FROM DimChannel;
DELETE FROM DimUser;
DELETE FROM DimStatus;
DELETE FROM DimVoteType;
DELETE FROM DimDate;
GO

------------------------------------------------------------
-- 1. LOAD DimDate (continuous date range from OLTP)
------------------------------------------------------------

DECLARE @MinDate date = (
    SELECT MIN(d) FROM (
        SELECT CAST(CreatedAt AS date) AS d FROM PUDDiT.dbo.[User]
        UNION
        SELECT CAST(CreatedAt AS date) FROM PUDDiT.dbo.Post
        UNION
        SELECT CAST(CreatedAt AS date) FROM PUDDiT.dbo.Comment
        UNION
        SELECT CAST(CreatedAt AS date) FROM PUDDiT.dbo.PostVote
        UNION
        SELECT CAST(CreatedAt AS date) FROM PUDDiT.dbo.PostReport
        UNION
        SELECT CAST(CreatedAt AS date) FROM PUDDiT.dbo.CommentReport
    ) X
);

DECLARE @MaxDate date = (
    SELECT MAX(d) FROM (
        SELECT CAST(CreatedAt AS date) AS d FROM PUDDiT.dbo.[User]
        UNION
        SELECT CAST(CreatedAt AS date) FROM PUDDiT.dbo.Post
        UNION
        SELECT CAST(CreatedAt AS date) FROM PUDDiT.dbo.Comment
        UNION
        SELECT CAST(CreatedAt AS date) FROM PUDDiT.dbo.PostVote
        UNION
        SELECT CAST(CreatedAt AS date) FROM PUDDiT.dbo.PostReport
        UNION
        SELECT CAST(CreatedAt AS date) FROM PUDDiT.dbo.CommentReport
    ) X
);

;WITH N AS (
    SELECT @MinDate AS d
    UNION ALL
    SELECT DATEADD(DAY, 1, d)
    FROM N
    WHERE d < @MaxDate
)
INSERT INTO DimDate (DateKey, FullDate, [Year], [Month], MonthName, [Day], DayOfWeek, DayName, WeekOfYear)
SELECT
    CONVERT(INT, FORMAT(d, 'yyyyMMdd')) AS DateKey,
    d                                   AS FullDate,
    YEAR(d)                             AS [Year],
    MONTH(d)                            AS [Month],
    DATENAME(MONTH, d)                  AS MonthName,
    DAY(d)                              AS [Day],
    DATEPART(WEEKDAY, d)                AS DayOfWeek,
    DATENAME(WEEKDAY, d)                AS DayName,
    DATEPART(WEEK, d)                   AS WeekOfYear
FROM N
OPTION (MAXRECURSION 0);
GO

------------------------------------------------------------
-- 1.1 Ensure fallback date 1900-01-01 exists
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM DimDate WHERE DateKey = 19000101)
BEGIN
    INSERT INTO DimDate (DateKey, FullDate, [Year], [Month], MonthName, [Day], DayOfWeek, DayName, WeekOfYear)
    VALUES (19000101, '1900-01-01', 1900, 1, 'January', 1, 1, 'Monday', 1);
END;
GO

------------------------------------------------------------
-- 2. LOAD DimUser (from PUDDiT.dbo.[User])
------------------------------------------------------------

INSERT INTO DimUser (SourceUserId, Email, DisplayName, FacultyNumber, RoleName, CreatedAtDateKey)
SELECT
    u.UserId              AS SourceUserId,
    u.Email,
    u.DisplayName,
    u.FacultyNumber,
    u.Role                AS RoleName,
    ISNULL(dd.DateKey, 19000101) AS CreatedAtDateKey
FROM PUDDiT.dbo.[User] u
LEFT JOIN DimDate dd
    ON dd.FullDate = CAST(u.CreatedAt AS date);
GO

------------------------------------------------------------
-- 3. LOAD DimChannel (from PUDDiT.dbo.Channel)
------------------------------------------------------------

INSERT INTO DimChannel (SourceChannelId, Name, Description, IsPrivate)
SELECT
    c.ChannelId,
    c.Name,
    c.Description,
    c.IsPrivate
FROM PUDDiT.dbo.Channel c;
GO

------------------------------------------------------------
-- 4. LOAD DimStatus (static)
------------------------------------------------------------

INSERT INTO DimStatus (StatusType, StatusName, IsFinal)
VALUES
    ('PostStatus',    'Active', 0),
    ('PostStatus',    'Hidden', 1),
    ('PostStatus',    'Locked', 1),
    ('CommentStatus', 'Active', 0),
    ('CommentStatus', 'Hidden', 1),
    ('ReportStatus',  'Open', 0),
    ('ReportStatus',  'Resolved', 1),
    ('ReportStatus',  'Rejected', 1);
GO

------------------------------------------------------------
-- 5. LOAD DimVoteType (static)
------------------------------------------------------------

INSERT INTO DimVoteType (Name, Value)
VALUES
    ('Upvote',   1),
    ('Downvote', -1);
GO

------------------------------------------------------------
-- 6. LOAD DimPost (after DimChannel and DimUser)
------------------------------------------------------------

INSERT INTO DimPost (SourcePostId, TitleShort, ChannelKey, CreatedByUserKey)
SELECT
    p.PostId                              AS SourcePostId,
    LEFT(p.Title, 100)                    AS TitleShort,
    dc.ChannelKey,
    du.UserKey                            AS CreatedByUserKey
FROM PUDDiT.dbo.Post p
INNER JOIN DimChannel dc
    ON dc.SourceChannelId = p.ChannelId
LEFT JOIN DimUser du
    ON du.SourceUserId = p.AuthorUserId;
GO

------------------------------------------------------------
-- 7. LOAD FactPostDaily
------------------------------------------------------------

;WITH CommentAgg AS (
    SELECT PostId, COUNT(*) AS CommentCount
    FROM PUDDiT.dbo.Comment
    GROUP BY PostId
),
VoteAgg AS (
    SELECT PostId,
           COUNT(*)      AS VoteCount,
           SUM(Value)    AS Score
    FROM PUDDiT.dbo.PostVote
    GROUP BY PostId
),
ReportAgg AS (
    SELECT PostId,
           COUNT(*) AS ReportCount
    FROM PUDDiT.dbo.PostReport
    GROUP BY PostId
)
INSERT INTO FactPostDaily (
    DateKey,
    PostKey,
    ChannelKey,
    AuthorUserKey,
    StatusKey,
    PostsCreatedCount,
    CommentsCount,
    PostVotesCount,
    PostScore,
    PostReportsCount
)
SELECT
    ISNULL(dd.DateKey, 19000101)         AS DateKey,
    dp.PostKey,
    dc.ChannelKey,
    du.UserKey,
    ds.StatusKey,
    1                                          AS PostsCreatedCount,
    ISNULL(ca.CommentCount, 0)                 AS CommentsCount,
    ISNULL(va.VoteCount, 0)                    AS PostVotesCount,
    ISNULL(va.Score, 0)                        AS PostScore,
    ISNULL(ra.ReportCount, 0)                  AS PostReportsCount
FROM PUDDiT.dbo.Post p
INNER JOIN DimPost dp
    ON dp.SourcePostId = p.PostId
INNER JOIN DimChannel dc
    ON dc.SourceChannelId = p.ChannelId
LEFT JOIN DimUser du
    ON du.SourceUserId = p.AuthorUserId
LEFT JOIN DimDate dd
    ON dd.FullDate = CAST(p.CreatedAt AS date)
LEFT JOIN DimStatus ds
    ON ds.StatusType = 'PostStatus' AND ds.StatusName = p.Status
LEFT JOIN CommentAgg ca
    ON ca.PostId = p.PostId
LEFT JOIN VoteAgg va
    ON va.PostId = p.PostId
LEFT JOIN ReportAgg ra
    ON ra.PostId = p.PostId;
GO

------------------------------------------------------------
-- 8. LOAD FactCommentDaily
------------------------------------------------------------

;WITH CommentVoteAgg AS (
    SELECT CommentId,
           COUNT(*)   AS VoteCount,
           SUM(Value) AS Score
    FROM PUDDiT.dbo.CommentVote
    GROUP BY CommentId
),
CommentReportAgg AS (
    SELECT CommentId,
           COUNT(*) AS ReportCount
    FROM PUDDiT.dbo.CommentReport
    GROUP BY CommentId
)
INSERT INTO FactCommentDaily (
    DateKey,
    PostKey,
    CommentAuthorUserKey,
    StatusKey,
    CommentsCreatedCount,
    CommentVotesCount,
    CommentScore,
    CommentReportsCount
)
SELECT
    ISNULL(dd.DateKey, 19000101)         AS DateKey,
    dp.PostKey,
    du.UserKey,
    ds.StatusKey,
    1                                          AS CommentsCreatedCount,
    ISNULL(cva.VoteCount, 0)                   AS CommentVotesCount,
    ISNULL(cva.Score, 0)                       AS CommentScore,
    ISNULL(cra.ReportCount, 0)                 AS CommentReportsCount
FROM PUDDiT.dbo.Comment c
INNER JOIN DimPost dp
    ON dp.SourcePostId = c.PostId
LEFT JOIN DimUser du
    ON du.SourceUserId = c.AuthorUserId
LEFT JOIN DimDate dd
    ON dd.FullDate = CAST(c.CreatedAt AS date)
LEFT JOIN DimStatus ds
    ON ds.StatusType = 'CommentStatus' AND ds.StatusName = c.Status
LEFT JOIN CommentVoteAgg cva
    ON cva.CommentId = c.CommentId
LEFT JOIN CommentReportAgg cra
    ON cra.CommentId = c.CommentId;
GO

------------------------------------------------------------
-- 9. LOAD FactVoteDaily
------------------------------------------------------------

INSERT INTO FactVoteDaily (
    DateKey,
    ChannelKey,
    VoteTypeKey,
    VotesCount
)
SELECT
    ISNULL(dd.DateKey, 19000101)         AS DateKey,
    dc.ChannelKey,
    dvt.VoteTypeKey,
    COUNT(*) AS VotesCount
FROM PUDDiT.dbo.PostVote v
INNER JOIN PUDDiT.dbo.Post p
    ON p.PostId = v.PostId
INNER JOIN DimChannel dc
    ON dc.SourceChannelId = p.ChannelId
LEFT JOIN DimDate dd
    ON dd.FullDate = CAST(v.CreatedAt AS date)
INNER JOIN DimVoteType dvt
    ON dvt.Value = v.Value
GROUP BY
    ISNULL(dd.DateKey, 19000101),
    dc.ChannelKey,
    dvt.VoteTypeKey;
GO

PRINT 'DW ETL LOAD COMPLETED SUCCESSFULLY (UPDATED).';
