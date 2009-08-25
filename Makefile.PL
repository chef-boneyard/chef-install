use inc::Module::Install;

name     'Chef-Install';
all_from 'lib/Chef/Install.pm';
author   'Adam Jacob <adam@opscode.com>';
license  'perl';

build_requires 'Test::More';

install_script "bin/chef-install";

auto_install;

WriteAll;

