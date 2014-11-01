# [Euradionantes.eu](http://www.euradionantes.eu) Web Platform


Initiated here [DILL44/euradio](https://github.com/DILL44/euradio), 
built atop [Symfony2](http://symfony.com) & [Sonata Project](http://sonata-project.org)


## Build status

[![License](https://poser.pugx.org/ronanguilloux/euradionantes/license.svg)](https://packagist.org/packages/ronanguilloux/euradionantes)
[![Latest Stable Version](https://poser.pugx.org/ronanguilloux/euradionantes/v/stable.svg)](https://packagist.org/packages/ronanguilloux/euradionantes)
[![Latest Unstable Version](https://poser.pugx.org/ronanguilloux/euradionantes/v/unstable.svg)](https://packagist.org/packages/ronanguilloux/euradionantes)
[![Build Status](https://secure.travis-ci.org/ronanguilloux/euradionantes.png?branch=master)](http://travis-ci.org/ronanguilloux/euradionantes)
[![Scrutinizer Code Quality](https://scrutinizer-ci.com/g/ronanguilloux/euradionantes/badges/quality-score.png?s=db3d0ec70de304f743065f3b628c809c4a48d46f)](https://scrutinizer-ci.com/g/ronanguilloux/euradionantes/) [![SensioLabsInsight](https://insight.sensiolabs.com/projects/fde42adb-344d-4055-b78d-20b598040ac8/mini.png)](https://insight.sensiolabs.com/projects/fde42adb-344d-4055-b78d-20b598040ac8)

Continously inspecting results (phpdoc, phpmd, phpcc, etc.) available on [Scrutinizer CI](https://scrutinizer-ci.com/g/ronanguilloux/euradionantes/inspections)


## Installing via GitHub

```bash
    $ git clone git@github.com:ronanguilloux/euradionantes.git
```

Autoloading is PSR-0 friendly.


## Installing via [Packagist](https://packagist.org/packages/ronanguilloux/euradionantes) & [Composer](http://getcomposer.org/doc/00-intro.md)

Create a composer.json file:

```json
    {
        "require": {"ronanguilloux/euradionantes": "dev-master"}
    }
```

Grab composer:

```bash
    $ curl -s http://getcomposer.org/installer | php
```

Run install (will build the autoloading):

```bash
    $ php composer.phar install
```


## Tests

Unit testing:

```bash
    $ bin/phpunit --testdox --coverage-text
```

Behaviour testing:

```bash
    $ bin/behat
```

Make utilities
--------------

For development & contribution purpose only,
a Makefile provides various tools to check your code style, quality & test coverage:

```
Usual tasks:

	To initialize vendors:  make
	To check code quality:	make quality
	To run tests suite:	    make tests
	To fix code style:	    make cs-fix

Other specific tasks:

	To evaluate code coverage:			        make codecoverage
	To run a simple continuous tests server:	mak continuous
	To dry-fix code style issues:			    make dry-fix
	To evaluate code quality stats:			    make stats
	To update vendors using Composer:		    make update
```

Quality assurance report
------------------------

Euradionantes web plateform quality plan is mainly based on Phpunit: it runs +/- 750 tests & assertions,
with separated valid & invalid entries sets.
Tests values are mainly real data or documented examples
from standards documentation, and a few handmade values.

The `composer.json` already includes these  [Php Quality Assurance Toolchain](http://phpqatools.org) libraries:

* [phploc](https://github.com/sebastianbergmann/phploc)
* [phpmd](https://github.com/phpmd/phpmd)
* [phpcpd](https://github.com/sebastianbergmann/phpcpd)
* [pdepend](https://github.com/pdepend/pdepend)
* [php-cs-fixer](https://github.com/fabpot/PHP-CS-Fixer)

Just run:

```bash
    $ make stats -i
```

XML report outputs are then generated in a new `./build` folder

License Information
-------------------

MIT Licensed. You can find a copy of this software here: [ronanguilloux/euradionantes](https://github.com/ronanguilloux/euradionantes)


Contributing Code
-----------------

The issue queue can be found at: https://github.com/ronanguilloux/euradionantes/issues
All contributors will be fully credited. Just sign up for a Github account, create a fork and hack away at the codebase.
Even one-off contributors will be fully credited.


