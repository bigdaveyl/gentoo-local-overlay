# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils webapp

BACKPORTS="3fa642f00da9529674ea93110396d036da1d43ff"
# Release version
MY_PV="${PV%_p*}"
MY_P="mythweb-${MY_PV}"

DESCRIPTION="PHP scripts intended to manage MythTV from a web browser"
HOMEPAGE="http://www.mythtv.org"
LICENSE="GPL-2"
SRC_URI="https://github.com/MythTV/mythweb/archive/${BACKPORTS}.tar.gz -> ${P}.tar.gz"
IUSE=""
KEYWORDS="~amd64 ~ppc ~x86"

RDEPEND="dev-lang/php:*[json,mysql,session,posix]
	virtual/httpd-php:*
	dev-perl/DBI
	dev-perl/DBD-mysql
	dev-perl/HTTP-Date
	dev-perl/Net-UPnP"

DEPEND="${RDEPEND}"

need_httpd_cgi

S="${WORKDIR}/mythweb-${BACKPORTS}"

src_prepare() {
	default
}

src_configure() {
	:
}

src_compile() {
	:
}

src_install() {
	webapp_src_preinst

	# Install docs
	cd "${S}"
	dodoc README INSTALL

	# Install htdocs files
	insinto "${MY_HTDOCSDIR}"
	doins mythweb.php
	doins -r classes
	doins -r configuration
	doins -r data
	doins -r includes
	doins -r js
	doins -r modules
	doins -r skins
	doins -r tests
	exeinto "${MY_HTDOCSDIR}"
	doexe mythweb.pl

	# Install our server config files
	webapp_server_configfile apache mythweb.conf.apache mythweb.conf
	webapp_server_configfile lighttpd mythweb.conf.lighttpd mythweb.conf
	webapp_server_configfile nginx "${FILESDIR}"/mythweb.conf.nginx \
		mythweb.include

	# Data needs to be writable and modifiable by the web server
	webapp_serverowned -R "${MY_HTDOCSDIR}"/data

	# Message to display after install
	webapp_postinst_txt en "${FILESDIR}"/0.25-postinstall-en.txt

	# Script to set the correct defaults on install
	webapp_hook_script "${FILESDIR}"/reconfig

	webapp_src_install
}
