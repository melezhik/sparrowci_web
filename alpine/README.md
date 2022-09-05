# Building alpine package for Raku modules

# Install abuild toolchain

```bash
apk update
apk add curl nano alpine-sdk
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
```

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
# (1/1) Installing raku-kind (0.2.2-r3)
# OK: 263 MiB in 65 packages
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
# True
# False
```



```
991e1636dc8e:~/packages/raku-kind$ abuild-keygen -a
>>> Generating public/private rsa key pair for abuild
Enter file in which to save the key [/home/builder/.abuild/builder-6316182f.rsa]: 
Generating RSA private key, 2048 bit long modulus (2 primes)
...........................................+++++
...................+++++
e is 65537 (0x010001)
writing RSA key
>>> 
>>> You'll need to install /home/builder/.abuild/builder-6316182f.rsa.pub into 
>>> /etc/apk/keys to be able to install packages and repositories signed with
>>> /home/builder/.abuild/builder-6316182f.rsa
>>> 
>>> Please remember to make a safe backup of your private key:
>>> /home/builder/.abuild/builder-6316182f.rsa
```
