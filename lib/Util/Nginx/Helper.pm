package Util::Nginx::Helper;

=head1 NAME

Util::Nginx::Helper - The great new Util::Nginx::Helper!

=head1 VERSION

Version 0.05

=cut

use strict;
use common::sense;
use nginx;

our $VERSION = '0.05';

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw/sendError/;

=head2	sendErrorPage

generate simple error pages

=cut
sub sendErrorPage {
	my ($r, $status) = @_;

	$status //= HTTP_NOT_FOUND;
	$r->status($status);
	$r->send_http_header;
	$r->print('error ', $status);

	return OK;
}


=head1 AUTHOR

norbornen, C<< <https://github.com/norbornen/nginx-perl-dbi-util> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2015 norbornen.

This program is distributed under the MIT (X11) License.

=cut

1;
