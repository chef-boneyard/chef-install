#!perl
#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2009 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

use Test::More tests => 11;
use FindBin;
use lib ("$FindBin::Bin/../lib");
use Data::Dump qw(dump ddx);
use Test::MockObject;

BEGIN {
  use_ok('Chef::Install');
}

my $ci = Chef::Install->new(platform => 'ubuntu', version => "9.04", url => "http://example.com", key => "/tmp/validation.pem", client => "example-validator", roles => [ "webserver" ]);

is( $ci->platform, 'ubuntu', 'Platform is set' );
is( $ci->version,  '9.04',   'Platform version is set' );
is( $ci->url,  'http://example.com',   'url is set' );
is( $ci->key,  '/tmp/validation.pem',   'validation key is set' );
is( $ci->client,  'example-validator',   'validation key is set' );
is( $ci->roles->[0],  "webserver",   'roles are set' );

$ci->find_installer_object;

ok( $ci->module->isa('Chef::Install::Ubuntu'), 'The current module is Chef::Install::Ubuntu');

# Create our Mock Chef::Install::Method object
my $mock_module = Test::MockObject;
$mock_module->set_true('setup_environment', 'install_chef_client', 'bootstrap_client');

$ci->module($mock_module);

is($ci->module, $mock_module, "Module can be set");

$ci->go;
$mock_module->called_ok('setup_environment');
$mock_module->called_ok('install_chef_client');
$mock_module->called_ok('bootstrap_client');

1;
