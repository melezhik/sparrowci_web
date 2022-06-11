# Building alpine package for Raku modules

# Install abuild toolchain

```bash
apk add curl nano alpine-sdk
curl -1sLf 'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/rsa.1A83FB1E50BD764C.key' > /etc/apk/keys/rakudo-pkg@nxadm-pkgs-1A83FB1E50BD764C.rsa.pub
curl -1sLf 'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/rsa.1A83FB1E50BD764C.key' > /etc/apk/keys/rakudo-pkg@nxadm-pkgs-1A83FB1E50BD764C.rsa.pub
curl -1sLf 'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/config.alpine.txt?distro=alpine&codename=v3.8' >> /etc/apk/repositories
apk update
apk search -v raku 
apk add rakudo-dev
apk add rakudo
adduser builder wheel
nano /etc/sudoers
su - builder
```

# Create APKBUILD

```bash
sudo addgroup builder abuild
sudo addgroup builder abuild
sudo mkdir -p /var/cache/distfiles
sudo chmod a+w /var/cache/distfiles
abuild-keygen -a -i
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

# Build a package

```bash
abuild checksum
abuild -r
```

# Install a package

```bash
ls -l ~/packages/
sudo echo "/home/builder/packages/raku-packages/" >> /etc/apk/repositories 
sudo apk update
sudo apk search raku-kind
# raku-kind-doc-0.2.2-r3
# raku-kind-0.2.2-r3
sudo apk add raku-kind
#(1/1) Installing raku-kind (0.2.2-r3)
#OK: 263 MiB in 65 packages
```

# Test package

```bash
cat << 'HERE' > test.raku

use Kind;

my constant Class = Kind[Metamodel::ClassHOW];

proto sub is-class(Mu --> Bool:D)             {*}
multi sub is-class(Mu $ where Class --> True) { }
multi sub is-class(Mu --> False)              { }

say Str.&is-class;  # OUTPUT: True
say Blob.&is-class; # OUTPUT: False

HERE

raku test.raku
```
