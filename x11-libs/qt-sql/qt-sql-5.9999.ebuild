# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit qt5-build

DESCRIPTION="The Qt toolkit is a comprehensive C++ application development framework"

if [[ ${QT5_BUILD_TYPE} == live ]]; then
	KEYWORDS=""
else
	KEYWORDS="~amd64"
fi

IUSE="firebird freetds mysql oci8 odbc postgres +sqlite"

REQUIRED_USE="
	|| ( firebird freetds mysql oci8 odbc postgres sqlite )
"

DEPEND="
	~x11-libs/qt-core-${PV}[debug=]
	firebird? ( dev-db/firebird )
	freetds? ( dev-db/freetds )
	mysql? ( virtual/mysql )
	oci8? ( dev-db/oracle-instantclient-basic )
	odbc? ( || ( dev-db/unixODBC dev-db/libiodbc ) )
	postgres? ( dev-db/postgresql-base )
	sqlite? ( dev-db/sqlite:3 )
"
RDEPEND="${DEPEND}"

QT5_TARGET_SUBDIRS=(
	src/sql
	src/plugins/sqldrivers
)

src_configure() {
	local myconf=(
		$(qt_use firebird sql-ibase  plugin)
		$(qt_use freetds  sql-tds    plugin)
		$(qt_use mysql    sql-mysql  plugin)
		$(qt_use oci8     sql-oci    plugin)
		$(qt_use odbc     sql-odbc   plugin)
		$(qt_use postgres sql-psql   plugin)
		$(qt_use sqlite   sql-sqlite plugin)
		$(use sqlite && echo -system-sqlite)
		-no-sql-db2
		-no-sql-sqlite2
		-no-accessibility -no-gui -no-cups -no-dbus
		-no-xcb -no-eglfs -no-directfb -no-opengl
	)

	use mysql && myconf+=("-I${EPREFIX}/usr/include/mysql" "-L${EPREFIX}/usr/$(get_libdir)/mysql")
	use oci8 && myconf+=("-I${ORACLE_HOME}/include" "-L${ORACLE_HOME}/$(get_libdir)")
	use odbc && myconf+=("-I${EPREFIX}/usr/include/iodbc")
	use postgres && myconf+=("-I${EPREFIX}/usr/include/postgresql/pgsql")

	qt5-build_src_configure
}
