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

use Test::More tests => 10;
use Test::MockObject;
use FindBin;
use lib ("$FindBin::Bin/../lib");
use Data::Dump qw(dump ddx);

BEGIN {
  use_ok('Chef::Install::Utils');
}

##
# run_command
##
is( Chef::Install::Utils->run_command( "command" => "echo foo" ),
  "foo\n", "Run command returns output" );

is(
  Chef::Install::Utils->run_command( "command" => [ "echo", "foo" ] ),
  "foo\n",
  "Run command returns output when args is an array"
);

eval { Chef::Install::Utils->run_command( "command" => "notreallyhere" ); };
if ($@) {
  like(
    $@,
    qr/^Can't run notreallyhere: No such file or directory/,
    "Command dies on bad response"
  );
}

##
# render_chef_solo_json
##
Chef::Install::Utils->render_chef_solo_json("latte.local");

my $text = do { local ( @ARGV, $/ ) = "/tmp/solo.json"; <> };

like(
  $text,
  qr/"server_hostname": "latte\.local"/,
  "Writes solo.json with the given server_name"
);
like(
  $text,
  qr/"recipes": "chef::client"/,
  "Solo.json has the chef::client recipe"
);
unlink('/tmp/solo.json');

##
# render_chef_solo_rb
##
Chef::Install::Utils->render_chef_solo_rb;

my $text = do { local ( @ARGV, $/ ) = "/tmp/solo.rb"; <> };

like(
  $text,
  qr/^file_cache_path ".+"/,
  "/tmp/solo.rb should set the file_cache_path"
);
like(
  $text,
  qr/^cookbook_path ".+"/m,
  "/tmp/solo.rb should set the cookbook_path"
);
unlink('/tmp/solo.rb');


##
# chef_from_gems
##
my $utils = Test::MockObject;
my @run_command_args;
$utils->fake_module(
  'Chef::Install::Utils',
  'run_command' => sub {
    my $self = shift;
    push( @run_command_args, [@_] );
  },
);
Chef::Install::Utils->chef_from_gems;
like(
  $run_command_args[0][1],
  qr/^gem install ohai chef$/,
  "Installs chef and ohai from rubygems"
);

##
# bootstrap_client_with_solo
##
@run_command_args = (); 
Chef::Install::Utils->bootstrap_client_with_solo;
like(
  $run_command_args[0][1],
  qr/^chef-solo -c \/tmp\/solo\.rb -j \/tmp\/solo\.json -r http:\/\/s3\.amazonaws\.com\/chef-solo\/bootstrap-latest\.tar\.gz/,
  "Bootstraps the client with chef-solo"
);

##
# download
##
my $file = Chef::Install::Utils->download("http://www.google.com/index.html", "/tmp/google-index.html");
my $text = do { local ( @ARGV, $/ ) = $file; <> };
like(
  $text,
  qr/Google/m
);
unlink("/tmp/google-index.html");

