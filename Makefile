#
# Makefile
# Les Polypodes, 2014
# Licence: MIT
# Source: https://github.com/polypodes/Build-and-Deploy/blob/master/build/Makefile

# To enable this quality-related tasks, add these dependencies to your composer.json:
# they'll be available in the ./bin dir :
#
#    "require-dev": {
#	     (...)
#        "phpunit/phpunit":             "~3.7",
#        "squizlabs/php_codesniffer":   "2.0.x-dev",
#        "sebastian/phpcpd":            "*",
#        "phploc/phploc" :              "*",
#        "phpmd/phpmd" :                "2.0.*",
#        "pdepend/pdepend" :            "2.0.*",
#        "fabpot/php-cs-fixer":         "@stable"
#    },


# Usage:

# me@myserver$~: make help
# me@myserver$~: make install
# me@myserver$~: make reinstall
# me@myserver$~: make update
# me@myserver$~: make tests
# me@myserver$~: make quality
# etc.

############################################################################
# Vars

# some lines may be useless for now, but these are nice tricks:
PWD         := $(shell pwd)
# Retrieve db connection params, triming white spaces
DB_USER	    := $(shell if [ -f app/config/parameters.yml ] ; then cat app/config/parameters.yml | grep 'database_user' | sed 's/database_user: //' | sed 's/^ *//;s/ *$$//' ; fi)
DB_PASSWORD := $(shell if [ -f app/config/parameters.yml ] ; then cat app/config/parameters.yml | grep 'database_password' | sed 's/database_password: //' | sed 's/null//' | sed 's/^ *//;s/ *$$//' ; fi)
DB_NAME     := $(shell if [ -f app/config/parameters.yml ] ; then cat app/config/parameters.yml | grep 'database_name' | sed 's/database_name: //' | sed 's/^ *//;s/ *$$//' ; fi)
VENDOR_PATH := $(PWD)/vendor
BIN_PATH    := $(PWD)/bin
WEB_PATH    := $(PWD)/web
NOW         := $(shell date +%Y-%m-%d--%H-%M-%S)
REPO        := "git@github.com:ronanguilloux/euradionantes.git"
BRANCH      := '2.0'
# Colors
YELLOW      := $(shell tput bold ; tput setaf 3)
GREEN       := $(shell tput bold ; tput setaf 2)
RESETC      := $(shell tput sgr0)

# Custom MAKE options
ifndef VERBOSE
  MAKEFLAGS += --no-print-directory
endif

############################################################################
# Mandatory tasks:

all: .git/hook/pre-commit vendor/autoload.php check help

vendor/autoload.php:
	@composer self-update
	@composer install --optimize-autoloader

.git/hook/pre-commit:
	@curl -s -o .git/hooks/pre-commit https://raw.githubusercontent.com/polypodes/Build-and-Deploy/master/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit

############################################################################
# Specific, project-related sf2 tasks:

integration:
	@echo
	@cd integration
	@gulp build
	@cd ../

dumps:
	@echo "Creating dump folder for SQL exports..."
	@mkdir -p ./dumps/remote
	@mkdir -p ./dumps/upgrade

mysqldump: dumps
	@echo
	@echo "Dumping existing db into ./dumps ..."
	@mysqldump --user=${DB_USER} --password=${DB_PASSWORD} ${DB_NAME} > 'dumps/${NOW}.sql' 2>/dev/null

mysqlinfo: dumps
	@echo
	@echo "mysql --user=${DB_USER} --password=${DB_PASSWORD} ${DB_NAME}"

dumps/remote/sql:
	@echo
	@echo "Fetching sql dump from remote backup into dumps/remote/sql..."
	@scp XXXXX@YYYYY:/var/www/backup_bdd/euradionantes_prod_11-15--12.sql.gz dumps/remote/sql.gz
	gunzip ./dumps/remote/sql.gz

importRemote: dumps/remote/sql dropDb
	@echo
	@echo "Importing remote sql backup into db..."
	@mysql --user=${DB_USER} --password=${DB_PASSWORD} -e 'CREATE DATABASE ${DB_NAME}' 2>/dev/null
	@mysql --user=${DB_USER} --password=${DB_PASSWORD} ${DB_NAME} < dumps/remote/sql 2>/dev/null

mysqlimport: importRemote
	@echo
	@echo "Dumping tables before update..."
	@mysqldump --user=${DB_USER} --password=${DB_PASSWORD} ${DB_NAME} -t news__post_tag > dumps/upgrade/v1_news__post_tag.sql 2>/dev/null
	@mysqldump --user=${DB_USER} --password=${DB_PASSWORD} ${DB_NAME} -t news__tag > dumps/upgrade/v1_news__tag.sql 2>/dev/null
	@mysqldump --user=${DB_USER} --password=${DB_PASSWORD} ${DB_NAME} news__post > dumps/upgrade/v1_news__post.sql 2>/dev/null

	@echo
	@echo "Exporting collections from news__post..."
	@mysql --user=${DB_USER} --password=${DB_PASSWORD} ${DB_NAME} -e "SELECT CONCAT('UPDATE news__post SET collection_id=', COALESCE(category_id, 'NULL'), ' WHERE id=', id, ';') from news__post" > dumps/upgrade/v1_news__post_tmp.sql 2>/dev/null
	@echo "Removing first line & trailing comma from news__post dump..."
	@tail -n +2 dumps/upgrade/v1_news__post_tmp.sql > dumps/upgrade/v2_news__post_collection

	@echo
	@echo "Applying new schema updates..."
	@mysql --user=${DB_USER} --password=${DB_PASSWORD} ${DB_NAME} < doc/upgrade/v1tov2.sql 2>/dev/null
	@$(MAKE) schemaDb

	@echo
	@echo "Re-importing news__tag rows into classification__tag prepared dump..."
	@sed -e "s/news__tag/classification__tag/g" dumps/upgrade/v1_news__tag.sql > dumps/upgrade/v2_classification__tag.sql
	@mysql --user=${DB_USER} --password=${DB_PASSWORD} ${DB_NAME} < dumps/upgrade/v2_classification__tag.sql 2>/dev/null

	@echo
	@echo "Re-importing news__post_tag using raw dump..."
	@mysql --user=${DB_USER} --password=${DB_PASSWORD} ${DB_NAME} < dumps/upgrade/v1_news__post_tag.sql 2>/dev/null

	@echo
	@echo "Importing classification_collection using prepared SQL upgrade file..."
	@mysql --user=${DB_USER} --password=${DB_PASSWORD} ${DB_NAME} < doc/upgrade/v2_classification__collection.sql 2>/dev/null

	@echo
	@echo "Re-importing news__post collection joins using prepared dump..."
	@mysql --user=${DB_USER} --password=${DB_PASSWORD} ${DB_NAME} < dumps/upgrade/v2_news__post_collection 2>/dev/null

	@echo
	@echo "Removing temporary sql dumps..."
	@rm dumps/upgrade/*

data: vendor/autoload.php
	@echo
	@echo "Install initial datas..."
#	@php app/console dbal:data:initialize --purge
	@php app/console fos:user:create admin --super-admin
	@php app/console fos:user:promote admin ROLE_SUPER_ADMIN
	@php app/console fos:user:activate admin

fixtures: vendor/autoload.php
#	@echo "Install fixtures in db..."
#	@php app/console dbal:fixtures:load --purge

############################################################################
# Generic sf2 tasks:

help:
	@echo "\n${GREEN}Usual tasks:${RESETC}\n"
	@echo "\tTo prepare install:\tmake"
	@echo "\tTo install:\t\tmake install"
	@echo "\tTo update from git:\tmake update"
	@echo "\tTo reinstall:\t\tmake reinstall (will erase all your datas)\n\n"

	@echo "${GREEN}Other specific tasks:${RESETC}\n"
	@echo "\tTo check code quality:\tmake quality"
	@echo "\tTo fix code style:\tmake cs-fix"
	@echo "\tTo clear all caches:\tmake clear"
	@echo "\tTo run tests:\t\tmake tests (will erase all your datas)\n"

check:
	@php app/check.php

pull:
	@git pull origin $(BRANCH)


dropDb: vendor/autoload.php mysqldump
	@echo
	@echo "Dropping database..."
	@php app/console doctrine:database:drop --force

createDb: vendor/autoload.php
	@echo
	@echo "Creating database..."
	@php app/console doctrine:database:create

schemaDb: vendor/autoload.php mysqldump
	@echo
	@echo "Configuring database schema..."
	@php app/console doctrine:schema:update --force

assets:
	@echo "\nPublishing assets..."
	@php app/console assets:install --symlink

clear: vendor/autoload.php
	@echo
	@echo "Resetting caches..."
	@php app/console cache:clear --env=prod --no-debug
	@php app/console cache:clear --env=dev

explain:
	@echo "git pull origin master + update db schema + build integration + copy new assets + rebuild prod cache"
	@echo "Note you can change the git remote repo username in .git/config"

behavior: vendor/autoload.php
	@echo "Run behavior tests..."
	@bin/behat --lang=fr  "@AcmeDemoBundle"

unit: vendor/autoload.php
	@echo "Run unit tests..."
	@php bin/phpunit -c build/phpunit.xml -v

codecoverage: vendor/autoload.php
	@echo "Run coverage tests..."
	@bin/phpunit -c build/phpunit.xml -v --coverage-html ./build/codecoverage

continuous: vendor/autoload.php
	@echo "Starting continuous tests..."
	@while true; do bin/phpunit -c build/phpunit.xml -v; done

sniff: vendor/autoload.php
	@bin/phpcs --standard=PSR2 src -n

dry-fix:
	@bin/php-cs-fixer fix . --config=sf23 --dry-run -vv

cs-fix:
	@bin/phpcbf --standard=PSR2 src
	@bin/php-cs-fixer fix . --config=sf23 -vv

#quality must remain quiet, as far as it's used in a pre-commit hook validation
quality: sniff dry-fix

build:
	@mkdir -p build/pdepend

# packagist-based dev tools to add to your composer.json. See http://phpqatools.org
stats: quality build
	@echo "Some stats about code quality"
	@bin/phploc src
	@bin/phpcpd src
	@bin/phpmd src text codesize,unusedcode
	@bin/pdepend --summary-xml=build/pdepend/summary.xml --jdepend-chart=build/pdepend/jdepend.svg --overview-pyramid=build/pdepend/pyramid.svg src

update: vendor/autoload.php
	@$(MAKE) explain
	@$(MAKE) pull
	@$(MAKE) schemaDb
	@$(MAKE) clear
	@$(MAKE) done

robot:
	@echo "User-agent: *" > $(WEB_PATH)/robots.txt
	@echo "Disallow: " >> $(WEB_PATH)/robots.txt

unrobot:
	@echo "User-agent: *" > $(WEB_PATH)/robots.txt
	@echo "Disallow: /" >> $(WEB_PATH)/robots.txt

done:
	@echo
	@echo "${GREEN}Done.${RESETC}"

# Tasks sets:

all: vendor/autoload.php check

prepareDb: createDb schemaDb

purgeDb: dropDb createDb schemaDb

install: prepareDb data assets clear done

reinstall: dropDb install

tests: reinstall fixtures behavior unit codecoverage

############################################################################
# .PHONY tasks list

.PHONY: integration data fixtures help check all pull dropDb createDb myqldump
.PHONY: schemaDb assets clear explain behavior unit codecoverage
.PHONY: continuous sniff dry-fix cs-fix quality stats deploy done prepareDb purgeDb
.PHONY: install reinstall test update robot unrobot
# vim:ft=make
