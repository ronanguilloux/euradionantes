ALTER TABLE news__post DROP FOREIGN KEY FK_7D109BC812469DE2;
ALTER TABLE news__post_tag DROP FOREIGN KEY FK_682B2051BAD26311;
ALTER TABLE news__post_tag DROP FOREIGN KEY FK_682B20514B89032C;
UPDATE `news__post` SET `category_id`=NULL WHERE 1; # we dumped it before
DROP TABLE news__category; # we dumped it before
#TRUNCATE TABLE news__tag; # we dumped it before
TRUNCATE TABLE news__post_tag; # we dumped it before
#ALTER TABLE classification__collection DROP FOREIGN KEY FK_7D109BC8514956FD;
