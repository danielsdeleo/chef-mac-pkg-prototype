# Create a pkg file containing the result of a chef client install.
#
# In this case, I manually installed the sharball version of the omnibus
# package and then moved it to /opt/chef.hide
#
# Also note that I manually copied the `postinst` script to `postinstall` which
# is a "magical" script name, the mac installer will run it.
system(<<-E.strip)
pkgbuild \
  --identifier "com.getchef.chef-client" \
  --version "11.8.2" \
  --scripts ~/oc/omnibus-chef/package-scripts/chef/ \
  --root /opt/chef.hide \
  --install-location /opt/chef \
  chef-client-core.pkg
E

## Generating a distribution file
# We need to customize the distribution file in order to have custom branding
# and stuff. The Distribution file needs to describe each package that goes in
# the metapackage, and the description contains stuff like the version number.
# We can generate a distribution file to see how that looks using this:
#
#   productbuild --synthesize --package chef-client-core.pkg GeneratedDistribution

system(<<-E.strip)
productbuild \
  --distribution Distribution \
  --resources Resources
  chef-mac.pkg
E
