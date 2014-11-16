# Doctrine schema update command will restore these outdated constraints
ALTER TABLE news__post DROP FOREIGN KEY FK_7D109BC812469DE2; # Doctrine schema update command will restore it
ALTER TABLE news__post_tag DROP FOREIGN KEY FK_682B2051BAD26311;
ALTER TABLE news__post_tag DROP FOREIGN KEY FK_682B20514B89032C;

# We dump this table before, and we need to move this into a classification_id column.
# Will be restored using dump sql file.
UPDATE `news__post` SET `category_id`=NULL WHERE 1; # we dumped it before

# We dump this table before, and we need to move this into classification__category table.
# Will be restored using dump sql file.
DROP TABLE news__category; # we dumped it before
#TRUNCATE TABLE news__tag; # we dumped it before

# We dump this table before, and we need to temporary cancel this.
# Will be restored using dump sql file.
DROP TABLE news__post_tag; # we dumped it before
DROP TABLE news__tag; # we dumped it before
