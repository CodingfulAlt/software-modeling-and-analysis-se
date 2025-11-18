--------------------------------------------------------------------
-- schema.sql – PUDDiT (MS SQL Server)
--------------------------------------------------------------------

-- Създаване на база данни
IF DB_ID('PUDDiT') IS NULL
BEGIN
    CREATE DATABASE PUDDiT;
END
GO

USE PUDDiT;
GO

--------------------------------------------------------------------
-- Таблица [User]
--------------------------------------------------------------------
IF OBJECT_ID('dbo.User', 'U') IS NOT NULL
    DROP TABLE dbo.[User];
GO

CREATE TABLE [User] (
    UserId          INT IDENTITY(1,1) PRIMARY KEY,
    Email           NVARCHAR(255) NOT NULL UNIQUE,
    PasswordHash    NVARCHAR(255) NOT NULL,
    DisplayName     NVARCHAR(100) NOT NULL,
    FacultyNumber   NVARCHAR(50)  NULL,
    Role            NVARCHAR(50)  NOT NULL,
    CreatedAt       DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

--------------------------------------------------------------------
-- Таблица Channel
--------------------------------------------------------------------
IF OBJECT_ID('dbo.Channel', 'U') IS NOT NULL
    DROP TABLE dbo.Channel;
GO

CREATE TABLE Channel (
    ChannelId       INT IDENTITY(1,1) PRIMARY KEY,
    Name            NVARCHAR(100) NOT NULL UNIQUE,
    Description     NVARCHAR(500) NULL,
    IsPrivate       BIT           NOT NULL,
    CreatedByUserId INT           NOT NULL,
    CreatedAt       DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Channel_User_CreatedBy
        FOREIGN KEY (CreatedByUserId) REFERENCES [User](UserId)
);
GO

--------------------------------------------------------------------
-- Таблица ChannelMember (реализация на M:N User–Channel)
--------------------------------------------------------------------
IF OBJECT_ID('dbo.ChannelMember', 'U') IS NOT NULL
    DROP TABLE dbo.ChannelMember;
GO

CREATE TABLE ChannelMember (
    UserId      INT NOT NULL,
    ChannelId   INT NOT NULL,
    MemberRole  NVARCHAR(50) NOT NULL,
    JoinedAt    DATETIME2    NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT PK_ChannelMember PRIMARY KEY (UserId, ChannelId),
    CONSTRAINT FK_ChannelMember_User FOREIGN KEY (UserId)
        REFERENCES [User](UserId),
    CONSTRAINT FK_ChannelMember_Channel FOREIGN KEY (ChannelId)
        REFERENCES Channel(ChannelId)
);
GO

--------------------------------------------------------------------
-- Таблица Post
--------------------------------------------------------------------
IF OBJECT_ID('dbo.Post', 'U') IS NOT NULL
    DROP TABLE dbo.Post;
GO

CREATE TABLE Post (
    PostId        INT IDENTITY(1,1) PRIMARY KEY,
    ChannelId     INT           NOT NULL,
    AuthorUserId  INT           NOT NULL,
    Title         NVARCHAR(200) NOT NULL,
    Body          NVARCHAR(MAX) NOT NULL,
    Status        NVARCHAR(20)  NOT NULL, -- Active / Hidden / Locked
    CreatedAt     DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt     DATETIME2     NULL,
    CONSTRAINT FK_Post_Channel FOREIGN KEY (ChannelId)
        REFERENCES Channel(ChannelId),
    CONSTRAINT FK_Post_User_Author FOREIGN KEY (AuthorUserId)
        REFERENCES [User](UserId)
);
GO

--------------------------------------------------------------------
-- Таблица Comment
--------------------------------------------------------------------
IF OBJECT_ID('dbo.Comment', 'U') IS NOT NULL
    DROP TABLE dbo.Comment;
GO

CREATE TABLE Comment (
    CommentId     INT IDENTITY(1,1) PRIMARY KEY,
    PostId        INT           NOT NULL,
    AuthorUserId  INT           NOT NULL,
    Body          NVARCHAR(MAX) NOT NULL,
    Status        NVARCHAR(20)  NOT NULL, -- Active / Hidden
    CreatedAt     DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Comment_Post FOREIGN KEY (PostId)
        REFERENCES Post(PostId),
    CONSTRAINT FK_Comment_User_Author FOREIGN KEY (AuthorUserId)
        REFERENCES [User](UserId)
);
GO

--------------------------------------------------------------------
-- Таблица PostVote
--------------------------------------------------------------------
IF OBJECT_ID('dbo.PostVote', 'U') IS NOT NULL
    DROP TABLE dbo.PostVote;
GO

CREATE TABLE PostVote (
    VoteId       INT IDENTITY(1,1) PRIMARY KEY,
    PostId       INT       NOT NULL,
    VoterUserId  INT       NOT NULL,
    Value        INT       NOT NULL, -- +1 / -1
    CreatedAt    DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_PostVote_Post FOREIGN KEY (PostId)
        REFERENCES Post(PostId),
    CONSTRAINT FK_PostVote_User FOREIGN KEY (VoterUserId)
        REFERENCES [User](UserId),
    CONSTRAINT UQ_PostVote_Post_Voter UNIQUE (PostId, VoterUserId),
    CONSTRAINT CK_PostVote_Value CHECK (Value IN (-1, 1))
);
GO

--------------------------------------------------------------------
-- Таблица CommentVote
--------------------------------------------------------------------
IF OBJECT_ID('dbo.CommentVote', 'U') IS NOT NULL
    DROP TABLE dbo.CommentVote;
GO

CREATE TABLE CommentVote (
    VoteId       INT IDENTITY(1,1) PRIMARY KEY,
    CommentId    INT       NOT NULL,
    VoterUserId  INT       NOT NULL,
    Value        INT       NOT NULL, -- +1 / -1
    CreatedAt    DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_CommentVote_Comment FOREIGN KEY (CommentId)
        REFERENCES Comment(CommentId),
    CONSTRAINT FK_CommentVote_User FOREIGN KEY (VoterUserId)
        REFERENCES [User](UserId),
    CONSTRAINT UQ_CommentVote_Comment_Voter UNIQUE (CommentId, VoterUserId),
    CONSTRAINT CK_CommentVote_Value CHECK (Value IN (-1, 1))
);
GO

--------------------------------------------------------------------
-- Таблица PostReport
--------------------------------------------------------------------
IF OBJECT_ID('dbo.PostReport', 'U') IS NOT NULL
    DROP TABLE dbo.PostReport;
GO

CREATE TABLE PostReport (
    ReportId        INT IDENTITY(1,1) PRIMARY KEY,
    PostId          INT           NOT NULL,
    ReporterUserId  INT           NOT NULL,
    Reason          NVARCHAR(500) NOT NULL,
    Status          NVARCHAR(20)  NOT NULL, -- Open / Resolved / Rejected
    CreatedAt       DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    ResolvedByUserId INT          NULL,
    CONSTRAINT FK_PostReport_Post FOREIGN KEY (PostId)
        REFERENCES Post(PostId),
    CONSTRAINT FK_PostReport_Reporter FOREIGN KEY (ReporterUserId)
        REFERENCES [User](UserId),
    CONSTRAINT FK_PostReport_Resolver FOREIGN KEY (ResolvedByUserId)
        REFERENCES [User](UserId)
);
GO

--------------------------------------------------------------------
-- Таблица CommentReport
--------------------------------------------------------------------
IF OBJECT_ID('dbo.CommentReport', 'U') IS NOT NULL
    DROP TABLE dbo.CommentReport;
GO

CREATE TABLE CommentReport (
    ReportId         INT IDENTITY(1,1) PRIMARY KEY,
    CommentId        INT           NOT NULL,
    ReporterUserId   INT           NOT NULL,
    Reason           NVARCHAR(500) NOT NULL,
    Status           NVARCHAR(20)  NOT NULL, -- Open / Resolved / Rejected
    CreatedAt        DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    ResolvedByUserId INT          NULL,
    CONSTRAINT FK_CommentReport_Comment FOREIGN KEY (CommentId)
        REFERENCES Comment(CommentId),
    CONSTRAINT FK_CommentReport_Reporter FOREIGN KEY (ReporterUserId)
        REFERENCES [User](UserId),
    CONSTRAINT FK_CommentReport_Resolver FOREIGN KEY (ResolvedByUserId)
        REFERENCES [User](UserId)
);
GO

--------------------------------------------------------------------
-- Scalar функция: fn_GetPostScore
--------------------------------------------------------------------
IF OBJECT_ID('dbo.fn_GetPostScore', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_GetPostScore;
GO

CREATE FUNCTION dbo.fn_GetPostScore (@PostId INT)
RETURNS INT
AS
BEGIN
    DECLARE @Score INT;

    SELECT @Score = ISNULL(SUM(Value), 0)
    FROM PostVote
    WHERE PostId = @PostId;

    RETURN @Score;
END;
GO

--------------------------------------------------------------------
-- Stored procedure: sp_CreatePost
--------------------------------------------------------------------
IF OBJECT_ID('dbo.sp_CreatePost', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_CreatePost;
GO

CREATE PROCEDURE dbo.sp_CreatePost
    @ChannelId    INT,
    @AuthorUserId INT,
    @Title        NVARCHAR(200),
    @Body         NVARCHAR(MAX),
    @Status       NVARCHAR(20) = 'Active'
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Post (ChannelId, AuthorUserId, Title, Body, Status)
    VALUES (@ChannelId, @AuthorUserId, @Title, @Body, @Status);

    SELECT SCOPE_IDENTITY() AS NewPostId;
END;
GO

--------------------------------------------------------------------
-- Trigger: tr_PostReport_AutoHide
-- Автоматично скрива пост (Status = 'Hidden'), ако има ≥ 3 Open reports
--------------------------------------------------------------------
IF OBJECT_ID('dbo.tr_PostReport_AutoHide', 'TR') IS NOT NULL
    DROP TRIGGER dbo.tr_PostReport_AutoHide;
GO

CREATE TRIGGER dbo.tr_PostReport_AutoHide
ON PostReport
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE p
    SET p.Status = 'Hidden'
    FROM Post p
    WHERE p.PostId IN (
        SELECT DISTINCT i.PostId
        FROM inserted i
    )
    AND (
        SELECT COUNT(*)
        FROM PostReport r
        WHERE r.PostId = p.PostId
          AND r.Status = 'Open'
    ) >= 3;
END;
GO
