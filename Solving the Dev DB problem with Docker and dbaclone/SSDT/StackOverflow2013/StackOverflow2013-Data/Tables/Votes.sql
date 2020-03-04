CREATE TABLE [dbo].[Votes] (
    [Id]           INT      IDENTITY (1, 1) NOT NULL,
    [PostId]       INT      NOT NULL,
    [UserId]       INT      NULL,
    [BountyAmount] INT      NULL,
    [VoteTypeId]   INT      NOT NULL,
    [CreationDate] DATETIME NOT NULL,
    CONSTRAINT [PK_Votes_Id] PRIMARY KEY CLUSTERED ([Id] ASC)
);

