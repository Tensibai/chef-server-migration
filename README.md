# chef-server-migration

[![Code Climate](https://codeclimate.com/github/Tensibai/chef-server-migration/badges/gpa.svg)](https://codeclimate.com/github/Tensibai/chef-server-migration)

Repository to store scripts needed to clean up cookbooks while migrating from Chef server opens source 11 to Chef 12

# Usage

Those scripts are what I did use when my upgrade by `chef-server-ctl upgrade` failed 

1 )I did `cd` to the /tmp/chef12-<randomDateBaseId>/organizations/<myorg>/cookbooks directory made y the transformation

2) pass all the commands in the .txt file (copy/paste should do)

3) And next copy the .rb to /tmp and run `/tmp/depends-validations.rb -d ./` assuming you're still in the cookbooks directory, this will list the cookbooks and versions where the version constraint can't be satisfied with the current state, fix all of them (or delete them if a newer version is available)

4) run chef-server-ctl `chef12-upgrade-upload -e /tmp/chef12-<...>` to upload your datas.


# Todo:

- Incude the commands in the script
- Add a dry run mode
- Improve the output
- Add an option to remove cookbooks version not needed anymore according to environments and roles.



