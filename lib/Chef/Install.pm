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

package Chef::Install;

use warnings;
use strict;

=head1 NAME

Chef::Install - Install Chef, and connect to a Chef Server, from any system 

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

sub new {
  my $class  = shift;
  my %params = @_;

  bless(
    {
      "platform"     => $params{'platform'},
      "version"      => $params{'version'},
      "platform_map" => {
        ubuntu => {
          default => "Chef::Install::Ubuntu",
          "9.04"  => "Chef::Install::Ubuntu"
        }
      },
      "module" => "",
      "key"    => $params{'key'},
      "url"    => $params{'url'},
      "client" => $params{'client'},
      "roles"  => $params{'roles'},
    },
    $class
  );
}

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Chef::Install;

    my $foo = Chef::Install->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head2 platform

Sets/gets the current platform.

=cut

sub platform {
  my ( $self, $value ) = @_;

  if ($value) {
    $self->{'platform'} = $value;
  } else {
    $self->{'platform'};
  }
}

=head2 version 

Sets/gets the current version. 

=cut

sub version {
  my ( $self, $value ) = @_;

  if ($value) {
    $self->{'version'} = $value;
  } else {
    $self->{'version'};
  }
}

=head2 url 

Sets/gets the current chef server url. 

=cut

sub url {
  my ( $self, $value ) = @_;

  if ($value) {
    $self->{'url'} = $value;
  } else {
    $self->{'url'};
  }
}

=head2 key  

Sets/gets the current chef validation key. 

=cut

sub key {
  my ( $self, $value ) = @_;

  if ($value) {
    $self->{'key'} = $value;
  } else {
    $self->{'key'};
  }
}

=head2 client 

Sets/gets the current chef validation client name. 

=cut

sub client {
  my ( $self, $value ) = @_;

  if ($value) {
    $self->{'client'} = $value;
  } else {
    $self->{'client'};
  }
}

=head2 roles 

Sets/gets the current list of roles for this client. 

=cut

sub roles {
  my ( $self, $value ) = @_;

  if ($value) {
    $self->{'roles'} = $value;
  } else {
    $self->{'roles'};
  }
}

=head2 module 

Sets/gets the current module 

=cut

sub module {
  my ( $self, $value ) = @_;

  if ($value) {
    $self->{'module'} = $value;
  } else {
    $self->{'module'};
  }
}

=head2 find_installer_object 

Set the installer object, based on the platform and version.

=cut

sub find_installer_object {
  my ($self) = @_;

  if ( exists( $self->{'platform_map'}->{ $self->{'platform'} } ) ) {
    if (
      exists(
        $self->{'platform_map'}->{ $self->{'platform'} }
          ->{ $self->{'version'} }
      )
      ) {
      eval( "use "
          . $self->{'platform_map'}->{ $self->{'platform'} }
          ->{ $self->{'version'} } );
      $self->{'module'} =
        eval( $self->{'platform_map'}->{ $self->{'platform'} }
          ->{ $self->{'version'} } . "->new();" );
    } else {
      eval( "use "
          . $self->{'platform_map'}->{ $self->{'platform'} }->{'default'} );
      $self->{'module'} =
        eval( $self->{'platform_map'}->{ $self->{'platform'} }->{'default'}
          . "->new();" );
    }
  } else {
    die "Unknown platform $self->{'platform'} \n";
  }
  return $self;
}

=head2 go

Install Chef, Configure the Client, and connect to a Chef Server.

=cut

sub go {
  my $self = shift;

  print "* Installing Chef\n";
  $self->find_installer_object unless $self->module;
  print "* Setting up the environment, installing pre-requisites\n";
  $self->module->setup_environment();
  print "* Installing Chef\n";
  $self->module->install_chef_client();
  print "* Bootstrapping Chef Client\n";
  $self->module->bootstrap_client( $self->url, $self->key, $self->client );
  print "* First Chef Client Run\n";
  $self->module->run_chef;
  print "* Adding roles\n";
  foreach my $role ( $self->roles ) {
    Chef::Install::Utils->run_command( "command" => "env OPSCODE_USER="
        . $self->client
        . " OPSCODE_KEY="
        . $self->key
        . " knife add_node_role --node="
        . chomp(`ohai fqdn`)
        . " --role=$role" );
  }
  print "* Final chef run\n";
  $self->module->run_chef;
}

=head1 AUTHOR

Adam Jacob, C<< <adam at opscode.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-chef-install at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Chef-Install>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Chef::Install


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Chef-Install>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Chef-Install>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Chef-Install>

=item * Search CPAN

L<http://search.cpan.org/dist/Chef-Install/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Adam Jacob, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1;    # End of Chef::Install
