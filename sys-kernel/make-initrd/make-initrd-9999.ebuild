# Copyright 2023  Alexey Gladkov <gladkov.alexey@gmail.com>
# Copyright 2024  Gabi Falk <gabifalk@gmx.com>
# SPDX-License-Identifier: GPL-2.0-or-later

EAPI=8

inherit autotools multilib optfeature

DESCRIPTION="Uevent-driven initramfs infrastructure based around udev"
HOMEPAGE="https://github.com/osboot/make-initrd"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/osboot/${PN}.git"
else
	SRC_URI="https://github.com/osboot/make-initrd/releases/download/${PV}/${P}.tar.xz"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-3+"
SLOT="0"
IUSE="+zlib bzip2 lzma zstd +man +elf-metadata"

DEPEND="
	app-alternatives/cpio
	app-arch/tar
	dev-build/make
	dev-libs/elfutils
	dev-libs/libshell
	net-libs/libtirpc
	sys-apps/coreutils
	sys-apps/findutils
	sys-apps/grep
	sys-apps/kmod
	sys-apps/util-linux
	virtual/libcrypt:=
	virtual/udev
	bzip2? ( app-arch/bzip2 )
	lzma? ( app-arch/xz-utils )
	man? ( app-text/scdoc )
	zlib? ( sys-libs/zlib )
	zstd? ( app-arch/zstd )
	elf-metadata? ( dev-libs/json-c )
"
RDEPEND="${DEPEND}"

BDEPEND="
	dev-build/autoconf
	dev-build/automake
	dev-util/intltool
	sys-devel/bison
	sys-devel/flex
	virtual/pkgconfig
"

src_prepare() {
	default

	eautoreconf
}

src_configure() {
	econf \
		--with-bootdir="${EPREFIX}"/boot \
		--with-runtimedir="${EPREFIX}/usr/$(get_abi_LIBDIR)"/initramfs \
		--libexecdir="${EPREFIX}"/usr/libexec \
		--with-imagename='initramfs-$(KERNEL)$(IMAGE_SUFFIX).img' \
		--with-busybox \
		--without-libshell \
		--with-libelf \
		--with-zlib=$(usex zlib) \
		--with-bzip2=$(usex bzip2) \
		--with-lzma=$(usex lzma) \
		--with-zstd=$(usex zstd) \
		--with-json-c=$(usex elf-metadata) \
		$(usex man --with-scdoc --without-scdoc) \
		#
}

src_compile() {
	emake
	default
}

src_install() {
	emake DESTDIR="${D}" install

	libexec="${ED}/usr/libexec/${PN}"
	projdir="${ED}/usr/share/${PN}"

	rm -vr -- "$projdir/features/guestfs"

	exeinto /usr/lib/kernel/install.d
	# This module is based on 50-dracut.install script from
	# sys-kernel/dracut-060_pre20240104-r3 package.
	newexe "${FILESDIR}"/systemd-make-initrd-v2.install 50-make-initrd.install

	exeinto /etc/kernel/preinst.d
	newexe "${FILESDIR}"/installkernel-make-initrd-v2.install 50-make-initrd.install
}

pkg_postinst() {
	optfeature_header "For underlying volume support:"
	optfeature "LVM2 support" sys-fs/lvm2[lvm]
	optfeature "Software RAID support" sys-fs/mdadm
	optfeature "LUKS support" sys-fs/cryptsetup
	optfeature "Multipath support" sys-fs/multipath-tools
	optfeature "iSCSI support" sys-block/open-iscsi
	optfeature "sshfs support" net-fs/sshfs
	optfeature "ZFS support" sys-fs/zfs

	optfeature_header "For CPU microcode support:"
	optfeature "Intel microcode support" \
		sys-apps/iucode_tool sys-firmware/intel-microcode
	optfeature "AMD microcode support" sys-kernel/linux-firmware

	optfeature_header "For misc feature support:"
	optfeature "Extra Boot Config support" dev-util/bootconfig
	optfeature "Plymouth support" sys-boot/plymouth
	optfeature "SmartCard support" \
		dev-libs/opensc sys-apps/pcsc-lite sys-apps/pcsc-tools
}
