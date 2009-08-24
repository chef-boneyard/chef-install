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

package Chef::Install::Utils;

sub run_command {
    my $self = shift;
    my %p = @_;
    my $output;

    if (ref($p{'command'}) eq "ARRAY") {
        open(COMMAND, "-|", @{$p{'command'}}) or die "Can't run $p{'command'}: $!";
    } else {
        open(COMMAND, "-|", "$p{'command'}") or die "Can't run $p{'command'}: $!";
    }
    while (my $line = <COMMAND>) {
        $output .= $line;
    }
    close(COMMAND);

    return $output;
}

sub rubygems_from_source {
  my $cwd = getcwd;
  chdir("/tmp");
  Chef::Install::Utils->run_command(
    "command",
    "wget http://rubyforge.org/frs/download.php/57643/rubygems-1.3.4.tgz"
  );
  Chef::Install::Utils->run_command(
    "command",
    "tar zxf rubygems-1.3.4.tgz"
  );
  chdir("/tmp/rubygems-1.3.4");
  Chef::Install::Utils->run_command(
    "command",
    "sudo ruby setup.rb"
  );
  symlink("/usr/bin/gem1.8", "/usr/bin/gem");
  chdir($cwd);
  1;
}

sub add_opscode_gem_source {
  Chef::Install::Utils->run_command("command" => "gem sources -a http://gems.opscode.com");
  1;
}

sub chef_from_gems {
  run_command("command" => "gem install ohai chef");
}


sub render_to_file {
  my $self = shift;
  my $file = shift;
  my $contents = shift;

  open(my $template, ">", $file);
  print $template $contents;
  close($template);
}

sub render_chef_solo_json {
  my $self = shift;
  my $server_name = shift;

  render_to_file(
    "/tmp/solo.json", 
    <<EOH
{ "chef": { "server_hostname": "$server_name" }, "recipes": "chef::client" }
EOH
  );
}

1;
