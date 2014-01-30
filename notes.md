# Developer Certificates:

We need to sign packages with an Apple-supplied certificate in order for
users to be able to install them without a warning. Some further
information is here:

https://developer.apple.com/support/technical/certificates/

# Packaging

Packages should be distributed as disk image files containing a .pkg
package file.

There seem to be two tools that can create .pkg files:

* "productbuild": https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/productbuild.1.html#//apple_ref/doc/man/1/productbuild
* "pkgbuild": https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/pkgbuild.1.html

"productbuild" seems to be preferred, maybe? But doesn't seem to work as
well for me so far...

## Commands:

Using pkgbuild:

    pkgbuild --identifier "com.getchef.chef-client" --version "11.8.2" --scripts ~/oc/omnibus-chef/package-scripts/chef/ --root /opt/chef --install-location /opt/chef Chef.pkg

**NOTE** I manually copied `postinst` to `postinstall` so it would get
used by pkgbuild

Using product build:

    productbuild --identifier "com.getchef.chef-client" --version "11.8.2" --scripts ~/oc/omnibus-chef/package-scripts/chef/ --root /opt/chef /opt/chef chef-mac.pkg

**NOTE**: this didn't handle the scripts correctly. I wonder if that's
even supported with productbuild, considering the limitations of the mac
app store...


## Customization and Branding

The key to making this look good appears to be by editing a
`Distribution` xml file. It seems that only `productbuild` makes this
file, packages created with `pkgbuild` don't have them (at least not by
default)?

Distribution file reference: https://developer.apple.com/library/mac/documentation/DeveloperTools/Reference/DistributionDefinitionRef/DistributionDefinitionRef.pdf

By reverse engineering the vagrant installer, I found that it looks like
a productbuild pkg that contains a pkgbuild package.

Yep. The way to do this is you create one package with pkgbuild, then
you make a container package using productbuild. The latter allows you
to customize the installer with branding and license (optionally you can
let the user pick amongst multiple packages within the "container" if
you include more than one package).
