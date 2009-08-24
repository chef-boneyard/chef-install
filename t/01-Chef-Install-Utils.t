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


use Test::More tests => 5;
use FindBin;
use lib ("$FindBin::Bin/../lib");

BEGIN {
  use_ok('Chef::Install::Utils');
}

##
# run_command
##
is(
  Chef::Install::Utils->run_command("command" => "echo foo"), 
  "foo\n", 
  "Run command returns output"
);

is(
  Chef::Install::Utils->run_command("command" => [ "echo", "foo" ]), 
  "foo\n", 
  "Run command returns output when args is an array"
);

eval {
  Chef::Install::Utils->run_command("command" => "notreallyhere");
};
if ($@) {
  like($@, qr/^Can't run notreallyhere: No such file or directory/, "Command dies on bad response");
}

##
# render_chef_solo_json
##
Chef::Install::Utils->render_chef_solo_json("latte.local");
my $text = do { local( @ARGV, $/ ) = "/tmp/solo.json" ; <> };
like($text, qr/"server_hostname": "latte\.local"/, "Writes solo.json with the given server_name");
like($text, qr/"recipes": "chef::client"/, "Solo.json has the chef::client recipe");
unlink('/tmp/solo.json');

##
# config_chef_client
##

my @run_command_args;
$utils->fake_module(
  'Chef::Install::Utils',
  'run_command' => sub {
    my $self = shift;
    push( @run_command_args, [@_] );
  },
);

Chef::Install::Utils->config_chef_client;

