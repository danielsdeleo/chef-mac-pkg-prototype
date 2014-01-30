# Developer Certificates:

We need to sign packages with an Apple-supplied certificate in order for
users to be able to install them without a warning. Some further
information is here:

https://developer.apple.com/support/technical/certificates/

# Packaging

## Conclusion:

My notes from learning this process are below.

The proper way to create a package seems to be a two step process.

1. First, you create one or more packages using the `pkgbuild` tool. For
us there is only one package.
2. Second, you combine the packages from step one into a larger package.
   This package contains the branding stuff (background image), license,
   etc. This package is goverened by an XML file named "Distribution",
   which specifies the license and background image. It can also define
   a set of choices for the user to install optional components and such
   (if you have more than one component package). Since we only have one
   component, we disable the component selection UI.

## Notes from My Learning Process


Packages should be distributed as disk image files containing a .pkg
package file.

There seem to be two tools that can create .pkg files:

* "productbuild": https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/productbuild.1.html#//apple_ref/doc/man/1/productbuild
* "pkgbuild": https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/pkgbuild.1.html

"productbuild" seems to be preferred, maybe? But doesn't seem to work as
well for me so far...

### Commands:

Using pkgbuild:

    pkgbuild --identifier "com.getchef.chef-client" --version "11.8.2" --scripts ~/oc/omnibus-chef/package-scripts/chef/ --root /opt/chef --install-location /opt/chef Chef.pkg

**NOTE** I manually copied `postinst` to `postinstall` so it would get
used by pkgbuild

Using product build:

    productbuild --identifier "com.getchef.chef-client" --version "11.8.2" --scripts ~/oc/omnibus-chef/package-scripts/chef/ --root /opt/chef /opt/chef chef-mac.pkg

**NOTE**: this didn't handle the scripts correctly. I wonder if that's
even supported with productbuild, considering the limitations of the mac
app store...


### Customization and Branding

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

# Disk Images

Disk images are more difficult to generate in an automated fashion.

## Easily Make "Ugly" Images:

It's easy enough to make uncustomized dmgs from a directory:

    hdiutil create chef.dmg -srcfolder Chef -volname "Chef Client" -type SPARSE -ov

## Customized Images

Customized images are a lot harder. As best I can tell, the information
that customizes a Disk Image lives in the `.DS_Store` file which is a
binary blob and doesn't seem to have any command line interface.

There seem to be two main ways to customize the disk image, both of
which are described here: http://stackoverflow.com/questions/96882/how-do-i-create-a-nice-looking-dmg-for-mac-os-x-using-command-line-tools

1. Use a bunch of applescript to drive the finder and set the attributes
   as desired.
2. Create a template disk image with everything set just so, then
   unmount it and keep it around as a template.

I didn't try the applescript approach.

## Template Disk Image

### Creating the Template

I created the template like shown below. This creates a 256 MB disk
image file that is read/write.

    hdiutil create template.dmg -volname "Chef Client" -fs "HFS+" -size 256M

Then I opened it in the finder. I then created a `.background` directory
inside of it using:

    mkdir /Volumes/Chef\ Client/.background_image

Then I copied the background image there with cp. Next, I `cd`'d to that
directory and opened it in the finder with `open .`

In the finder window for the disk image, I used the "show view options"
menu to set the background (by dragging it from the finder window for
the `.background_image` directory.

Next, I copied the chef-mac.pkg file into the disk image directory.

Then, I fucked around with the grid sizing and such until everything
looked okay, then unmounted the disk image. 

Finally, I gzipped the template.dmg file (it's a 256M file, but
compresses down to the actual size of the contents).

### Updating the Template

I didn't do this step, but the basic idea is that you copy and unzip the
template and then mount the disk image with `hdiutil`. You should be
able to replace the `chef-mac.pkg` file using `mv` without disrupting
the positioning of the file when viewed in the finder. When this is
done, unmount the disk image. For the purposes of the example below, it
should be named `chef-stage.dmg`

### Converting the Disk Image to Compressed

Converting the disk image to compressed format will make it read only
and shrink the unused space to reduce the file size.

    hdiutil convert chef-stage.dmg -format UDZO -o chef.dmg

The resulting `chef.dmg` file is the final product that you want to
ship.


