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

use Test::More qw(no_plan);
use Test::MockObject::Extends;
use FindBin;
use Data::Dump qw(dump);
use lib ("$FindBin::Bin/../lib");

my $utils = Test::MockObject;
my $rubygems_from_source = 0;
my $add_opscode_gem_source = 0;
my $chef_from_gems = 1;
my @run_command_args;

$utils->fake_module(
  'Chef::Install::Utils',
  'run_command' => sub {
    my $self = shift;
    push( @run_command_args, [@_] );
  },
  'rubygems_from_source' => sub { $rubygems_from_source = 1; },
  'add_opscode_gem_source' => sub { $add_opscode_gem_source = 1; },
  'chef_from_gems' => sub { $chef_from_gems = 1; },
);

use_ok('Chef::Install::Ubuntu');

##
# new
##
my $ci = Chef::Install::Ubuntu->new;
isa_ok( $ci, Chef::Install::Ubuntu );

##
# setup_environment
##
$ci->setup_environment;
like( $run_command_args[0][1], qr/apt-get -y/, "Runs apt-get -y" );
foreach my $pkg (qw(ruby build-essential ssl-cert)) {
  like( $run_command_args[0][1], qr/$pkg/, "Installs $pkg" );
}
is($rubygems_from_source, 1, "Installed rubygems from source");
is($add_opscode_gem_source, 1, "Added opscode gem source");

##
# install_chef_client
##
$ci->install_chef_client;
is($chef_from_gems, 1, "Installed chef from rubygems");


