# yum-chef Cookbook CHANGELOG

This file is used to list changes made in each version of the yum-chef cookbook.

# v1.0.1 (2016-03-23)

- PR #11 Avoid using $releasever as inconsistent usage in EL @afiune

# v1.0.0 (2016-03-22)

- Update to use the new packages.chef.io repository
- Allow setting the sslverify & gpgcheck options

# v0.2.2 (2015-11-30)

- [#7](https://github.com/chef-cookbooks/yum-chef/pull/7) Resolve Chef 13 deprecation warnings

# v0.2.1 (2015-10-13)

- [#4](https://github.com/chef-cookbooks/yum-chef/pull/4) Relax version constraint for yum

# v0.2.0 (2015-09-17)

- [#3](https://github.com/chef-cookbooks/yum-chef/pull/3) Add stable and current recipes
- Add License file
- Add Rakefile for simplified testing
- Add standard chefignore and gitignore file
- Add cookbook version and Travis CI badges to the readme
- Add Gemfile with development dependencies
- Resolve rubocop warnings
- Update platforms in the Kitchen CI config
