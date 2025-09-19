# Maintainer: Phobos <phobos1641[at]noreply[dot]pm[dot]me>
# Contributor: Andreas Radke <andyrtr@archlinux.org>

pkgbase=linux-lts61
pkgver=6.1.153
pkgrel=1
pkgdesc='LTS Linux (6.1)'
url='https://www.kernel.org'
arch=(x86_64)
license=(GPL2)
makedepends=(
  bc
  cpio
  gettext
  libelf
  pahole
  perl
  python
  tar
  xz
)
options=('!strip' '!ccache') # !strip-vmlinux
_srcname=linux-$pkgver
_srctag=v$pkgver
source=(
  https://cdn.kernel.org/pub/linux/kernel/v${pkgver%%.*}.x/${_srcname}.tar.{xz,sign}
  config  # the main kernel config file
  0001-userns-add-sysctl-to-disallow-unprivileged-CLONE_NEW.patch
  0002-userns-add-kconfig-to-set-default-for-unprivileged-C.patch
  0003-sysctl-expose-proc_dointvec_minmax_sysadmin-as-API-f.patch
  0004-restrict-device-timing-side-channels.patch
  0005-usb-add-toggle-for-disabling-newly-added-USB-devices.patch
  0006-usb-implement-dedicated-subsystem-sysctl-tables.patch
  0007-net-tcp-add-option-to-disable-TCP-simultaneous-conne.patch
  0008-Export-__rcu_read_-lock-unlock.patch
  0009-arch-Kconfig-Default-to-maximum-amount-of-ASLR-bits.patch
  0010-io_uring-add-a-sysctl-to-disable-io_uring-system-wid.patch
  0011-Export-follow_pte.patch
  0012-Revert-kbuild-Hack-for-depmod-not-handling-X.Y-versi.patch
  0013-fs-overlayfs-change-xino-print-to-a-pr_debug.patch
  0014-x86-realmode-ensure-std-gnu11.patch
  0018-ntsync5.patch
)
validpgpkeys=(
  ABAF11C65A2970B130ABE3C479BE3E4300411886  # Linus Torvalds
  647F28654894E3BD457199BE38DBBDC86092693E  # Greg Kroah-Hartman
)
# https://www.kernel.org/pub/linux/kernel/v6.x/sha256sums.asc
sha256sums=('76ebbde05899ff712856ae9b06413d71ab7162771e7bc6df4d4ab335e1fc9e48'
            'SKIP'
            '87551eb1bdc1fdfc3f31e11894f2c552857c26226076a81f471e85ed210e7938'
            'da5690e9fcf17717e93af083fa21c5cb12880e8a36a00738c9ca82bd3af4ac71'
            '5596a05b9aa2567c5ea9870da36b95f3c1d820b1fd36bc44378040d70119b431'
            'b438a95d3521c71efb340ef9520670a356afc5f0ecfaa5f49fc9912496700384'
            '64d440f5088f404b04da205204d98e897a1565cbc3cc1d22576854f58c554e41'
            '8c7543e64c45e2da634dc7e3eef35ddcc0f05769f4b3594070892518b36543cb'
            '6541b8bd6f5c2a4c09552f68d67e7c06cbadadfff298a4ba6bfa761a340c37c5'
            'c944451be1bc7ddaebbff3f7c271164b1b3b1f02d1f2b0a3ab0f903f3006a220'
            '0a2cd50dbbbc9f0d7d2a006a75f7c0b1cb1b2a98aef4f8dbe14817f88d69798a'
            'fedc0234ecae0aa2b38b910c3b7b9043fc86076ba8ce05ca3aa04e4219b3172b'
            '0243fd466afd5b0b52ebde0c18558fbc01bad6320e03996cb9fc8fd8cc28afbb'
            '5b01b2ef14de7dfca746c25e466e78f9c8d056fd3399756530546621fb2b01f5'
            '164e279875c6dc2ffc9007a8f74b25030feea34724f374d4bfc92d232f82d0ce'
            'a1e8bb19a238a91178e2aac2a61e657d03c1df343298ef1ad21a722cc0e6af83'
            'e41cc41416abe9b853bce1bdaccf5d5aaec1027ddfb7d28837e31c3d825ed6c0'
            'c6bc50fc62e4465bac91a3f41107d984beeb31764077d42c4b79f371ab619133')

export KBUILD_BUILD_HOST=archlinux
export KBUILD_BUILD_USER=$pkgbase
export KBUILD_BUILD_TIMESTAMP="$(date -Ru${SOURCE_DATE_EPOCH:+d @$SOURCE_DATE_EPOCH})"

if [[ "$BUILD_DOCS" == "1" || "${BUILD_DOCS^^}" =~ ^"Y" ]]; then
  BUILD_DOCS=1
else
  BUILD_DOCS=0
fi

prepare() {
  cd $_srcname

  echo "Setting version..."
  echo "-$pkgrel" > localversion.10-pkgrel
  echo "${pkgbase#linux}" > localversion.20-pkgname

  local src
  for src in "${source[@]}"; do
    src="${src%%::*}"
    src="${src##*/}"
    src="${src%.zst}"
    [[ $src = *.patch ]] || continue
    echo "Applying patch $src..."
    patch -Np1 < "../$src"
  done

  echo "Setting config..."
  cp ../config .config
  make olddefconfig
  diff -u ../config .config || :

  if [[ -e "${HOME}"/.config/modprobed.db ]]; then
    make LSMOD="${HOME}"/.config/modprobed.db localmodconfig
  fi

  make -s kernelrelease > version
  echo "Prepared $pkgbase version $(<version)"
}

build() {
  cd $_srcname
  make all
  make -C tools/bpf/bpftool vmlinux.h feature-clang-bpf-co-re=1

  if test $BUILD_DOCS -eq 1; then
    make htmldocs
  fi
}

_package() {
  pkgdesc="The $pkgdesc kernel and modules"
  depends=(
    coreutils
    initramfs
    kmod
  )
  optdepends=(
    'wireless-regdb: to set the correct wireless channels of your country'
    'linux-firmware: firmware images needed for some devices'
    'usbctl: deny_new_usb control'
  )
  provides=(
    KSMBD-MODULE
    VIRTUALBOX-GUEST-MODULES
    WIREGUARD-MODULE
  )
  replaces=(
    wireguard-lts
  )

  cd $_srcname
  local modulesdir="$pkgdir/usr/lib/modules/$(<version)"

  echo "Installing boot image..."
  # systemd expects to find the kernel here to allow hibernation
  # https://github.com/systemd/systemd/commit/edda44605f06a41fb86b7ab8128dcf99161d2344
  install -Dm644 "$(make -s image_name)" "$modulesdir/vmlinuz"

  # Used by mkinitcpio to name the kernel
  echo "$pkgbase" | install -Dm644 /dev/stdin "$modulesdir/pkgbase"

  echo "Installing modules..."
  ZSTD_CLEVEL=19 make INSTALL_MOD_PATH="$pkgdir/usr" INSTALL_MOD_STRIP=1 \
    DEPMOD=/doesnt/exist modules_install  # Suppress depmod

  # remove build and source links
  rm "$modulesdir"/{source,build}
}

_package-headers() {
  pkgdesc="Headers and scripts for building modules for the $pkgdesc kernel"
  depends=("$pkgbase=$pkgver-$pkgrel" pahole)

  cd $_srcname
  local builddir="$pkgdir/usr/lib/modules/$(<version)/build"

  echo "Installing build files..."
  install -Dt "$builddir" -m644 .config Makefile Module.symvers System.map \
    localversion.* version vmlinux tools/bpf/bpftool/vmlinux.h
  install -Dt "$builddir/kernel" -m644 kernel/Makefile
  install -Dt "$builddir/arch/x86" -m644 arch/x86/Makefile
  cp -t "$builddir" -a scripts
  ln -srt "$builddir" "$builddir/scripts/gdb/vmlinux-gdb.py"

  # required when STACK_VALIDATION is enabled
  install -Dt "$builddir/tools/objtool" tools/objtool/objtool

  # required when DEBUG_INFO_BTF_MODULES is enabled
  install -Dt "$builddir/tools/bpf/resolve_btfids" tools/bpf/resolve_btfids/resolve_btfids

  echo "Installing headers..."
  cp -t "$builddir" -a include
  cp -t "$builddir/arch/x86" -a arch/x86/include
  install -Dt "$builddir/arch/x86/kernel" -m644 arch/x86/kernel/asm-offsets.s

  install -Dt "$builddir/drivers/md" -m644 drivers/md/*.h
  install -Dt "$builddir/net/mac80211" -m644 net/mac80211/*.h

  # https://bugs.archlinux.org/task/13146
  install -Dt "$builddir/drivers/media/i2c" -m644 drivers/media/i2c/msp3400-driver.h

  # https://bugs.archlinux.org/task/20402
  install -Dt "$builddir/drivers/media/usb/dvb-usb" -m644 drivers/media/usb/dvb-usb/*.h
  install -Dt "$builddir/drivers/media/dvb-frontends" -m644 drivers/media/dvb-frontends/*.h
  install -Dt "$builddir/drivers/media/tuners" -m644 drivers/media/tuners/*.h

  # https://bugs.archlinux.org/task/71392
  install -Dt "$builddir/drivers/iio/common/hid-sensors" -m644 drivers/iio/common/hid-sensors/*.h

  echo "Installing KConfig files..."
  find . -name 'Kconfig*' -exec install -Dm644 {} "$builddir/{}" \;

  if compgen -G "rust/*.rmeta" >/dev/null; then
    echo "Installing Rust files..."
    install -Dt "$builddir/rust" -m644 rust/*.rmeta
    install -Dt "$builddir/rust" rust/*.so
  fi

  echo "Installing unstripped VDSO..."
  make INSTALL_MOD_PATH="$pkgdir/usr" vdso_install \
    link=  # Suppress build-id symlinks

  echo "Removing unneeded architectures..."
  local arch
  for arch in "$builddir"/arch/*/; do
    [[ $arch = */x86/ ]] && continue
    echo "Removing $(basename "$arch")"
    rm -r "$arch"
  done

  echo "Removing documentation..."
  rm -r "$builddir/Documentation"

  echo "Removing broken symlinks..."
  find -L "$builddir" -type l -printf 'Removing %P\n' -delete

  echo "Removing loose objects..."
  find "$builddir" -type f -name '*.o' -printf 'Removing %P\n' -delete

  echo "Stripping build tools..."
  local file
  while read -rd '' file; do
    case "$(file -Sib "$file")" in
      application/x-sharedlib\;*)      # Libraries (.so)
        strip -v $STRIP_SHARED "$file" ;;
      application/x-archive\;*)        # Libraries (.a)
        strip -v $STRIP_STATIC "$file" ;;
      application/x-executable\;*)     # Binaries
        strip -v $STRIP_BINARIES "$file" ;;
      application/x-pie-executable\;*) # Relocatable binaries
        strip -v $STRIP_SHARED "$file" ;;
    esac
  done < <(find "$builddir" -type f -perm -u+x ! -name vmlinux -print0)

  if ! printf '%s\0' "${options[@]}" | grep -Fqxz -- '!strip-vmlinux'; then
    echo "Stripping vmlinux..."
    strip -v $STRIP_STATIC "$builddir/vmlinux"
  fi

  echo "Adding symlink..."
  mkdir -p "$pkgdir/usr/src"
  ln -sr "$builddir" "$pkgdir/usr/src/$pkgbase"
}

_package-docs() {
  pkgdesc="Documentation for the $pkgdesc kernel"

  cd $_srcname
  local builddir="$pkgdir/usr/lib/modules/$(<version)/build"

  echo "Installing documentation..."
  local src dst
  while read -rd '' src; do
    dst="${src#Documentation/}"
    dst="$builddir/Documentation/${dst#output/}"
    install -Dm644 "$src" "$dst"
  done < <(find Documentation -name '.*' -prune -o ! -type d -print0)

  echo "Adding symlink..."
  mkdir -p "$pkgdir/usr/share/doc"
  ln -sr "$builddir/Documentation" "$pkgdir/usr/share/doc/$pkgbase"
}

pkgname=(
  "$pkgbase"
  "$pkgbase-headers"
)
if test $BUILD_DOCS -eq 1; then
  pkgname+=(
    "$pkgbase-docs"
  )

  makedepends+=(
    # htmldocs
    graphviz
    imagemagick
    python-sphinx
    texlive-latexextra
  )
fi
for _p in "${pkgname[@]}"; do
  eval "package_$_p() {
    $(declare -f "_package${_p#$pkgbase}")
    _package${_p#$pkgbase}
  }"
done

# vim:set ts=8 sts=2 sw=2 et:
