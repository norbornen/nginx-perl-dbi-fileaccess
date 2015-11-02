package Util::Nginx::DB;

=head1 NAME

Util::Nginx::DB - The great new Util::Nginx::DB!

=head1 VERSION

Version 0.05

=cut

use strict;
use common::sense;
use DBI;
use Carp;

our $VERSION = '0.05';

=head2	new

Util::Nginx::DB constructor,
create database connect

=cut
sub new {
	my $class = shift;

	my $self = {};
	bless $self, $class;

	$self->{dbh} = DBI->connect(
						'dbi:Pg:dbname=DBNAME',
						'www',
						undef,
						{
							RaiseError=>1,
							HandleError=> sub { Carp::confess($_[0]) },
							pg_enable_utf8=>1,
							pg_server_prepare=>0,
						}
	);

	return $self;
}

=head2

Database dissconnect when object destroy

=cut
sub DESTROY {
	my $self = shift;
	if ($self->{dbh}) {
		$self->{dbh}->finish;
		$self->{dbh}->disconnect or warn $self->{dbh}->errstr;
		undef $self->{dbh};
	}
}

=head2	AUTOLOAD

AUTOLOAD handler: bridge to DBI

=cut
our $AUTOLOAD;
sub AUTOLOAD {
	my $self = shift;

	my $called = (split("::", $AUTOLOAD))[-1];
	die "No such attribute: $called" unless UNIVERSAL::can($self->{dbh}, $called);

	return $self->{dbh}->$called(@_);
}


=head1 AUTHOR

norbornen, C<< <https://github.com/norbornen/nginx-perl-dbi-util> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2015 norbornen.

This program is distributed under the MIT (X11) License.

=cut

1;
