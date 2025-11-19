------------------------------------------------------------
-- DATA WAREHOUSE SCHEMA FOR PUDDIT (BONUS)
-- Author: Borislav Minkov (FN: 2301321069)
-- Date: 2025
------------------------------------------------------------
CREATE DATABASE PUDDiT_DW;
GO
USE PUDDiT_DW;
GO
------------------------------------------------------------
-- 1. DIMENSION TABLES
------------------------------------------------------------

-- DimDate
CREATE TABLE DimDate (
    DateKey        INT PRIMARY KEY,       -- YYYYMMDD
    FullDate       DATE NOT NULL,
    [Year]         INT NOT NULL,
    [Month]        TINYINT NOT NULL,
    MonthName      NVARCHAR(20),
    [Day]          TINYINT NOT NULL,
    DayOfWeek      TINYINT NOT NULL,
    DayName        NVARCHAR(20),
    WeekOfYear     TINYINT NOT NULL
);

------------------------------------------------------------

-- DimUser
CREATE TABLE DimUser (
    UserKey            INT IDENTITY(1,1) PRIMARY KEY,
    SourceUserId       INT NOT NULL,
    Email              NVARCHAR(255),
    DisplayName        NVARCHAR(100),
    FacultyNumber      NVARCHAR(50),
    RoleName           NVARCHAR(50),
    CreatedAtDateKey   INT,
    FOREIGN KEY (CreatedAtDateKey) REFERENCES DimDate(DateKey)
);

------------------------------------------------------------

-- DimChannel
CREATE TABLE DimChannel (
    ChannelKey       INT IDENTITY(1,1) PRIMARY KEY,
    SourceChannelId  INT NOT NULL,
    Name             NVARCHAR(100),
    Description      NVARCHAR(500),
    IsPrivate        BIT
);

------------------------------------------------------------

-- DimPost
CREATE TABLE DimPost (
    PostKey            INT IDENTITY(1,1) PRIMARY KEY,
    SourcePostId       INT NOT NULL,
    TitleShort         NVARCHAR(100),
    ChannelKey         INT,
    CreatedByUserKey   INT,
    FOREIGN KEY (ChannelKey) REFERENCES DimChannel(ChannelKey),
    FOREIGN KEY (CreatedByUserKey) REFERENCES DimUser(UserKey)
);

------------------------------------------------------------

-- DimStatus
CREATE TABLE DimStatus (
    StatusKey      INT IDENTITY(1,1) PRIMARY KEY,
    StatusType     NVARCHAR(20),
    StatusName     NVARCHAR(20),
    IsFinal        BIT
);

------------------------------------------------------------

-- DimVoteType
CREATE TABLE DimVoteType (
    VoteTypeKey     INT IDENTITY(1,1) PRIMARY KEY,
    Name            NVARCHAR(20),     -- 'Upvote', 'Downvote'
    Value           INT               -- +1 или -1
);

------------------------------------------------------------
-- 2. FACT TABLES
------------------------------------------------------------

-- FactPostDaily
CREATE TABLE FactPostDaily (
    PostActivityKey      INT IDENTITY(1,1) PRIMARY KEY,
    DateKey              INT NOT NULL,
    PostKey              INT NOT NULL,
    ChannelKey           INT NOT NULL,
    AuthorUserKey        INT NOT NULL,
    StatusKey            INT NOT NULL,

    PostsCreatedCount    INT DEFAULT 0,
    CommentsCount        INT DEFAULT 0,
    PostVotesCount       INT DEFAULT 0,
    PostScore            INT DEFAULT 0,
    PostReportsCount     INT DEFAULT 0,

    FOREIGN KEY (DateKey)       REFERENCES DimDate(DateKey),
    FOREIGN KEY (PostKey)       REFERENCES DimPost(PostKey),
    FOREIGN KEY (ChannelKey)    REFERENCES DimChannel(ChannelKey),
    FOREIGN KEY (AuthorUserKey) REFERENCES DimUser(UserKey),
    FOREIGN KEY (StatusKey)     REFERENCES DimStatus(StatusKey)
);

------------------------------------------------------------

-- FactCommentDaily
CREATE TABLE FactCommentDaily (
    CommentActivityKey     INT IDENTITY(1,1) PRIMARY KEY,
    DateKey                INT NOT NULL,
    PostKey                INT NOT NULL,
    CommentAuthorUserKey   INT NOT NULL,
    StatusKey              INT NOT NULL,

    CommentsCreatedCount   INT DEFAULT 0,
    CommentVotesCount      INT DEFAULT 0,
    CommentScore           INT DEFAULT 0,
    CommentReportsCount    INT DEFAULT 0,

    FOREIGN KEY (DateKey)              REFERENCES DimDate(DateKey),
    FOREIGN KEY (PostKey)              REFERENCES DimPost(PostKey),
    FOREIGN KEY (CommentAuthorUserKey) REFERENCES DimUser(UserKey),
    FOREIGN KEY (StatusKey)            REFERENCES DimStatus(StatusKey)
);

------------------------------------------------------------

-- FactVoteDaily
CREATE TABLE FactVoteDaily (
    VoteActivityKey     INT IDENTITY(1,1) PRIMARY KEY,
    DateKey             INT NOT NULL,
    ChannelKey          INT NOT NULL,
    VoteTypeKey         INT NOT NULL,

    VotesCount          INT DEFAULT 0,

    FOREIGN KEY (DateKey)    REFERENCES DimDate(DateKey),
    FOREIGN KEY (ChannelKey) REFERENCES DimChannel(ChannelKey),
    FOREIGN KEY (VoteTypeKey) REFERENCES DimVoteType(VoteTypeKey)
);
