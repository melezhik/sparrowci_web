   0 apk update
   1 apk add curl nano alpine-sdk
   2 apk add rakudo
   3 apk add rakudo-dev
   8 apk add sudo
   9 adduser builder wheel
  14 addgroup wheel
  20 echo | adduser -G wheel builder 
  23 echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers
  25 addgroup builder abuild
  26 mkdir -p /var/cache/distfiles
  27 chmod a+w /var/cache/distfiles
  28 su --help
  34 su - builder -c 'abuild-keygen -a -n -i'
  35 nano /tmp/crt.package
```sh
mkdir -p ~/raku-packages/raku-kind
cd raku-packages/raku-kind
cat << 'HERE' > APKBUILD
# Contributor:
# Maintainer:
pkgname=raku-kind
pkgver=0.2.2
pkgrel=3
pkgdesc="kind package"
url="https://raku.land/cpan:KAIEPI/Kind"
arch="all !s390x !riscv64"
license="Artistic-2.0"
depends="rakudo"
makedepends="rakudo-dev"
#checkdepends=""
#install=""
subpackages="$pkgname-doc"
source="$pkgname-$pkgver.tar.gz::https://cpan.metacpan.org/authors/id//K/KA/KAIEPI/Perl6/Kind-0.2.2.tar.gz"
builddir="$srcdir"/Kind-"$pkgver"


check() {
	# Replace with proper check command(s)
	# prove -e 'raku -Ilib'
	:
}

package() {
	set -x	
	ls -l	
	RAKUDO_RERESOLVE_DEPENDENCIES=0 /usr/share/rakudo/tools/install-dist.raku \
		--to="$pkgdir"/usr/share/rakudo/vendor --for=vendor
	install -Dvm644 LICENSE META6.json README.md \
		-t "$pkgdir"/usr/share/doc/"$pkgname"

}
HERE

abuild checksum
abuild -r
/ # cat /tmp/crt.package 
mkdir -p ~/raku-packages/raku-kind
cd raku-packages/raku-kind
cat << 'HERE' > APKBUILD
# Contributor:
# Maintainer:
pkgname=raku-kind
pkgver=0.2.2
pkgrel=3
pkgdesc="kind package"
url="https://raku.land/cpan:KAIEPI/Kind"
arch="all !s390x !riscv64"
license="Artistic-2.0"
depends="rakudo"
makedepends="rakudo-dev"
#checkdepends=""
#install=""
subpackages="$pkgname-doc"
source="$pkgname-$pkgver.tar.gz::https://cpan.metacpan.org/authors/id//K/KA/KAIEPI/Perl6/Kind-0.2.2.tar.gz"
builddir="$srcdir"/Kind-"$pkgver"


check() {
	# Replace with proper check command(s)
	# prove -e 'raku -Ilib'
	:
}

package() {
	set -x	
	ls -l	
	RAKUDO_RERESOLVE_DEPENDENCIES=0 /usr/share/rakudo/tools/install-dist.raku \
		--to="$pkgdir"/usr/share/rakudo/vendor --for=vendor
	install -Dvm644 LICENSE META6.json README.md \
		-t "$pkgdir"/usr/share/doc/"$pkgname"

}
HERE

abuild checksum
abuild -r
```
37 chmod a+x /tmp/crt.package
38 su - builder -c /tmp/crt.package
41 ls -l /home/builder/packages/raku-packages/x86_64/
