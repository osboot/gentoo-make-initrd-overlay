# Copyright 2024  Gabi Falk <gabifalk@gmx.com>
# SPDX-License-Identifier: GPL-2.0-or-later

EAPI=8
DESCRIPTION="The libshell is a set of the most commonly-used shell functions"
HOMEPAGE="https://github.com/legionus/libshell"
SRC_URI="https://github.com/legionus/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64"
IUSE="man"

BDEPEND="
	man? ( app-text/scdoc )
"

src_compile() {
	sed -i -e 's,^#!/bin/ash,#!/bin/sh,' utils/cgrep.in
	if ! use man; then
		export SCDOC=
	fi
	emake
}

src_install() {
	if ! use man; then
		export SCDOC=
	fi
	emake DESTDIR="${D}" install
}
