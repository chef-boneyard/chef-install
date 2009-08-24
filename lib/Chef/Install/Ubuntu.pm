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

package Chef::Install::Ubuntu;

use Data::Dump qw(dump ddx);
use Chef::Install::Utils;

use warnings;
use strict;

=head1 NAME

Chef::Install::Ubuntu - Default install for Ubuntu

=cut

sub new {
  my $class = shift;

  bless( {}, $class );
}

=head1 SYNOPSIS

=head1 FUNCTIONS

=head2 setup_environment

Sets up the environment needed to run Chef.

=cut

sub setup_environment {
  Chef::Install::Utils->run_command( "command" =>
"apt-get -y install ruby ruby1.8-dev libopenssl-ruby1.8 rdoc ri irb build-essential wget ssl-cert"
  );
  Chef::Install::Utils->rubygems_from_source;
  Chef::Install::Utils->add_opscode_gem_source;
}

sub install_chef_client {
  Chef::Install::Utils->chef_from_gems;
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

