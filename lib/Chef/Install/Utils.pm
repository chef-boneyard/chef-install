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

use Cwd;
use Net::HTTP;
use Data::Dumper;

package Chef::Install::Utils;

sub run_command {
  my $self = shift;
  my %p    = @_;
  my $output;

  if ( ref( $p{'command'} ) eq "ARRAY" ) {
    open( COMMAND, "-|", @{ $p{'command'} } )
      or die "Can't run $p{'command'}: $!";
  } else {
    open( COMMAND, "-|", "$p{'command'}" )
      or die "Can't run $p{'command'}: $!";
  }
  while ( my $line = <COMMAND> ) {
    $output .= $line;
  }
  close(COMMAND);

  return $output;
}

sub download {
  my $self = shift;
  my $url  = shift;
  my $file = shift;

  print "Downloading $url\n";
  print "  to $file\n";

  $url =~ /^http:\/\/(.+?)\/(.+)$/;
  my $host = $1;
  my $path = $2;
  my $s    = Net::HTTP->new( Host => $host ) || die $@;
  $s->write_request( GET => $path, 'User−Agent' => 'ChefInstall/0.1' );
  my ( $code, $mess, %h ) = $s->read_response_headers;
  open( my $download, ">", $file );
  while (1) {
    print ".";
    my $buf;
    my $n = $s->read_entity_body( $buf, 1024 );
    die "read failed: $!" unless defined $n;
    last                  unless $n;
    print $download $buf;
  }
  print "\nComplete!\n";
  close($download);
  return $file;
}

sub rubygems_from_source {
  my $cwd = getcwd;
  chdir("/tmp");
  print "Downloading Rubygems\n";
  Chef::Install::Utils->download(
    "http://files.rubyforge.mmmultiworks.com/rubygems/rubygems-1.3.4.tgz",
    "/tmp/rubygems-1.3.4.tgz" );
  Chef::Install::Utils->run_command( "command",
    "tar zxf rubygems-1.3.4.tgz" );
  chdir("/tmp/rubygems-1.3.4");
  print "Installing Rubygems\n";
  Chef::Install::Utils->run_command( "command", "ruby setup.rb" );
  symlink( "/usr/bin/gem1.8", "/usr/bin/gem" );
  chdir($cwd);
  1;
}

sub add_opscode_gem_source {
  Chef::Install::Utils->run_command(
    "command" => "gem sources -a http://gems.opscode.com" );
  1;
}

sub chef_from_gems {
  ###
  # When 0.8.0 is released, this is the deal
  ###
  #Chef::Install::Utils->run_command( "command" => "gem install ohai chef" );
  Chef::Install::Utils->download(
    "https://api.opscode.com/gems/chef-0.8.0.gem",
    "/tmp/chef-0.8.0.gem" );
  Chef::Install::Utils->download(
    "https://api.opscode.com/gems/mixlib-authentication-1.0.0.gem",
    "/tmp/mixlib-authentication-1.0.0.gem" );
  my $cwd = getcwd;
  chdir("/tmp");
  Chef::Install::Utils->run_command("command" => "gem install ./chef-0.8.0.gem ./mixlib-authentication-1.0.0.gem");
  chdir($cwd);
  1;
}

sub render_to_file {
  my $self     = shift;
  my $file     = shift;
  my $contents = shift;

  open( my $template, ">", $file );
  print $template $contents;
  close($template);
}

sub render_chef_solo_rb {
  my $self = shift;

  Chef::Install::Utils->render_to_file(
    "/tmp/solo.rb",
    <<EOH
file_cache_path "/tmp/chef-solo"
cookbook_path "/tmp/chef-solo/cookbooks"
EOH
  );
}

sub render_chef_solo_json {
  my $self        = shift;
  my $server_name = shift;

  Chef::Install::Utils->render_to_file(
    "/tmp/solo.json",
    <<EOH
{ "chef": { "server_hostname": "$server_name" }, "recipes": "chef::client" }
EOH
  );
}

sub bootstrap_client_with_solo {
  my $self = shift;

  Chef::Install::Utils->run_command(
    "command",
"chef-solo -c /tmp/solo.rb -j /tmp/solo.json -r http://s3.amazonaws.com/chef-solo/bootstrap-latest.tar.gz",
  );
}

1;
