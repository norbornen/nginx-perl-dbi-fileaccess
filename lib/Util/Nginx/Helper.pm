package Util::Nginx::Helper;

=head1 NAME

Util::Nginx::Helper - The great new Util::Nginx::Helper!

=head1 VERSION

Version 0.04

=cut

use strict;
use common::sense;
use nginx;
use DBI;
use Carp;
use Data::Dumper;

our $VERSION = '0.04';

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw/connectDB sendError/;

=head2 connectDB
=cut
sub connectDB {
	my $dbh = DBI->connect(
				'dbi:Pg:dbname=DBNAME;host=192.168.0.2;port=5432',
				'httpd',
				undef,
				{
					RaiseError=>1,
					HandleError=> sub { Carp::confess($_[0]) },
					#AutoCommit for update
					pg_enable_utf8=>1,
					#pg_server_prepare=>0
				}
	);

	return $dbh;
}

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
