CREATE TABLE [dbo].[LinkTypes] (
    [Id]   INT          IDENTITY (1, 1) NOT NULL,
    [Type] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_LinkTypes_Id] PRIMARY KEY CLUSTERED ([Id] ASC)
);

