#!/usr/bin/make -f
# ----------------------------------------------------------------------
# AlternC - Web Hosting System
# Copyright (C) 2000-2013 by the AlternC Development Team.
# https://alternc.org/
# ----------------------------------------------------------------------
# LICENSE
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License (GPL)
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# To read the license please visit http://www.gnu.org/copyleft/gpl.html
# ----------------------------------------------------------------------
# Purpose of file: Global Makefile 
# ----------------------------------------------------------------------
MAJOR=$(shell sed -ne 's/^[^(]*(\([^)]*\)).*/\1/;1p' debian/changelog)
REV=$(shell env LANG=C svn info --non-interactive | awk '/^Revision:/ { print $$2 }')
VERSION="${MAJOR}~svn${REV}"
export VERSION

build:
# gettext are built at runtime, to be able to MERGE them from CORE + MODULES before msgfmt
	pod2man --center "" --date "" --release "AlternC" --section=8 man/alternc.install.pod >man/alternc.install.8

install: 
#install-alternc install-squirrelmail install-roundcube install-upnp install-awstats

# install AlternC files common between ALTERNC and ALTERNC-SLAVE
install-common:
# Shell Scripts
	test -d $(DESTDIR)/usr/lib/alternc || mkdir -p $(DESTDIR)/usr/lib/alternc
	cp src/* $(DESTDIR)/usr/lib/alternc/
	chown root:root $(DESTDIR)/usr/lib/alternc/*
	chmod 755 $(DESTDIR)/usr/lib/alternc/*

# Configuration Files
	test -d $(DESTDIR)/etc || mkdir -p $(DESTDIR)/etc
	cp -r etc/alternc $(DESTDIR)/etc
	cp -r etc/incron.d $(DESTDIR)/etc
	find $(DESTDIR)/etc/ -depth -type d -name ".svn" -exec rm {} -rf \;
	chmod 755 $(DESTDIR)/etc/alternc etc/incron.d

# Installer and upgrade scripts 
	test -d $(DESTDIR)/usr/share/alternc/install || mkdir -p $(DESTDIR)/usr/share/alternc/install
	cp -r install/* $(DESTDIR)/usr/share/alternc/install
	find $(DESTDIR)/usr/share/alternc/install -depth -type d -name ".svn" -exec rm {} -rf \;
	chmod a+x $(DESTDIR)/usr/share/alternc/install/alternc.install $(DESTDIR)/usr/share/alternc/install/dopo.sh $(DESTDIR)/usr/share/alternc/install/mysql.sh $(DESTDIR)/usr/share/alternc/install/newone.php $(DESTDIR)/usr/share/alternc/install/reset_root.php $(DESTDIR)/usr/share/alternc/install/upgrade_check.sh $(DESTDIR)/usr/share/alternc/install/upgrades/*.php $(DESTDIR)/usr/share/alternc/install/upgrades/*.sh


# install AlternC itself: 
install-alternc: install-common
# Web Panel
	test -d $(DESTDIR)/usr/share/alternc/panel || mkdir $(DESTDIR)/usr/share/alternc/panel
	cp -r bureau/* $(DESTDIR)/usr/share/alternc/panel
	find $(DESTDIR)/usr/share/alternc/panel -depth -type d -name ".svn" -exec rm {} -rf \;
	sed -i -e "s/@@REPLACED_DURING_BUILD@@/${MAJOR}/" $(DESTDIR)/usr/share/alternc/panel/class/local.php
	echo ${VERSION} > $(DESTDIR)/usr/share/alternc/panel/class/.svn-infos
	chown -R root:root $(DESTDIR)/usr/share/alternc/panel
	chmod -R 644 $(DESTDIR)/usr/share/alternc/panel
	chmod -R a+X $(DESTDIR)/usr/share/alternc/panel
# Logs
	test -d $(DESTDIR)/var/log/alternc || mkdir $(DESTDIR)/var/log/alternc
	chown -R root:root $(DESTDIR)/var/log/alternc 

# Ex old alternc-admintools
	install -o root -g root -m 755 tools/* $(DESTDIR)/usr/bin
# Man pages
	install -o root -g root -m 644 man/*.8 $(DESTDIR)/usr/share/man/man8/

install-slave: install-common
# Man pages
	install -o root -g root -m 644 man/alternc.install.8 $(DESTDIR)/usr/share/man/man8/


# Then its modules : 
install-awstats:
	make -C awstats install DESTDIR=$(DESTDIR) 

install-roundcube:
	make -C roundcube install DESTDIR=$(DESTDIR) 

install-squirrelmail:
	make -C squirrelmail install DESTDIR=$(DESTDIR) 

install-upnp:
	make -C upnp install DESTDIR=$(DESTDIR) 

