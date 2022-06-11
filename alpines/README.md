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

```bash
   sudo  addgroup builder abuild
   sudo addgroup builder abuild
   sudo mkdir -p /var/cache/distfiles
   sudo chmod a+w /var/cache/distfiles
   abuild-keygen -a -i
   mkdir -p ~/raku-packages/kind
   cd raku-packages/kind
   nano APKBUILD
   abuild checksum
   abuild -r
   ls -l ~/packages/
   sudo echo "/home/builder/packages/raku-packages/" >> /etc/apk/repositories 
   sudo apk update
   sudo apk search kind
   sudo apk add kind
```

# Test package

```
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
