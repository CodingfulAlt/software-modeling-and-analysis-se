SELECT 
    c.ChannelId,
    c.Name AS ChannelName,
    COUNT(p.PostId) AS PostCount
FROM Channel c
LEFT JOIN Post p ON p.ChannelId = c.ChannelId
GROUP BY c.ChannelId, c.Name
ORDER BY c.ChannelId;

SELECT 
    p.CreatedAt,
    COUNT(p.PostId) AS PostCount
FROM Post p
GROUP BY p.CreatedAt
ORDER BY p.CreatedAt;

SELECT 
    p.PostId,
    p.Title,
    SUM(
        CASE WHEN v.Value = 1 THEN 1 
             WHEN v.Value = -1 THEN -1 
             ELSE 0 END
    ) AS Score
FROM Post p
LEFT JOIN PostVote v ON v.PostId = p.PostId
GROUP BY p.PostId, p.Title
ORDER BY Score DESC;

SELECT 
    p.PostId,
    p.Title,
    COUNT(c.CommentId) AS CommentCount
FROM Post p
LEFT JOIN Comment c ON c.PostId = p.PostId
GROUP BY p.PostId, p.Title
ORDER BY CommentCount DESC;

