package Util::Nginx::FileAccessor;

=head1 NAME

Util::Nginx::FileAccessor

=head1 VERSION

Version 0.04

=cut

use strict;
use common::sense;
use nginx;
use Util::Nginx::Helper;

our $VERSION = '0.04';

our $RawFilesROOT = '/path/to/file/storage';



=head2	handlerDirect

http://www.site.xyz/pubs/share/direct/143607464

=cut
sub handlerDirect {
	my $r = shift;

	#	GET and HEAD
	if ($r->request_method ne 'GET' && $r->request_method ne 'HEAD') {
		return HTTP_BAD_REQUEST;
	}
	$r->discard_request_body;


	my $fileObj;

	if ($r->uri =~ m|/(\d+)/?$| || $r->uri =~ m|/(\d+)\.\w{2,5}$|) {
		my $dbh = connectDB();
		my $id = $1;

		$fileObj = $dbh->selectrow_hashref(q|select * from files where id = ?|, {}, $id);
	}

	return _sendFile($r, $fileObj);
}

=head2	handlerThumb

http://www.site.xyz/pubs/share/thumb/146573356:c729x729+0+597:r600x600!

=cut
sub handlerThumb {
	my $r = shift;

	#	GET and HEAD
	if ($r->request_method ne 'GET' && $r->request_method ne 'HEAD') {
		return HTTP_BAD_REQUEST;
	}
	$r->discard_request_body;


	my $fileObj;

	if ($r->uri =~ m|/thumb/(\d+):(.+)$|) {
		my $dbh = connectDB();
		my $id = $1;
		my $ImageThumb = $2;

		my $fileId = $dbh->selectcol_arrayref(q|select json->>'thumb' from file_thumbs where context = ? and name = concat('ImageThumb-'::text, ?::text)|, {}, $id, $ImageThumb)->[0];
		$fileObj = $fileId ? $dbh->selectrow_hashref(q|select * from files where id = ?|, {}, $fileId) : undef;

		return HTTP_NOT_ALLOWED unless $fileObj;
	}

	return _sendFile($r, $fileObj);
}

=head2	handlerBookThumb

http://www.site.xyz/pubs/share/book/cover/thumb/164179821x70

=cut
sub handlerBibitemThumb {
	my $r = shift;

	#	GET and HEAD
	if ($r->request_method ne 'GET' && $r->request_method ne 'HEAD') {
		return HTTP_BAD_REQUEST;
	}
	$r->discard_request_body;


	my $fileObj;

	if ($r->uri =~ m{/(book|preprint)/cover/thumb/(.+)$}) {
		my $dbh = connectDB();
		my $typeData = $1;
		my ($objId, $resizeWidth, $resizeHeight) = split /x/, $2;
		my $tablename = 'table_'.$typeData;

		if ($objId && $objId =~ /^\d+$/) {
			$fileObj = $dbh->selectrow_hashref(qq|select f.* from $tablename b join files f on f.id = b.cover where b.id = ?|, {}, $objId);
		}
		if ($fileObj && $fileObj->{id} && defined $resizeWidth && $resizeWidth =~ /^\d+$/) {
			$fileObj = $dbh->selectrow_hashref(
							q|select f.* from files f join file_thumbs r on (r.json->>'thumb')::int = f.id and r.context = ? and r.name = ?|,
							{},
							$fileObj->{id},	'ImageThumb-'.join('x', grep {$_} $resizeWidth, $resizeHeight));

			return HTTP_NOT_ALLOWED unless $fileObj;
		}
	}

	return _sendFile($r, $fileObj);
}

=head2	handlerPersonImage

http://www.site.xyz/persons/image/451657

=cut
sub handlerPersonImage {
	my $r = shift;

	#	GET and HEAD
	if ($r->request_method ne 'GET' && $r->request_method ne 'HEAD') {
		return HTTP_BAD_REQUEST;
	}
	$r->discard_request_body;

	if ($r->uri =~ m|/image/(\d+)/?$|) {
		my $dbh = connectDB();
		my $personId = $1;

		my $person = $dbh->selectrow_hashref(q|select json->'cropimage' as cropimage, json->'image' as image from persons where id = ?|, {}, $personId);
		if ($person) {
			my $image = $person->{cropimage} || $person->{image} ? $person->{image} || '/i/head.png';

			$r->header_out('X-XYZ', 'Util::Nginx::FileAccessor');
			$r->header_out('X-XYZ-Image', $image);
			$r->internal_redirect($image);
			return OK;
		}
	}

	return HTTP_NOT_FOUND;
}

=head2	_sendFile
=cut
sub _sendFile {
	my ($r, $fileObj) = @_;

	my $error_code;

	if ($fileObj) {
		$fileObj->{file_path_site} = $RawFilesROOT.$fileObj->{file_path_site};
		if (index($fileObj->{access_rules}, 'reader:__guest') == -1) {
			$error_code = HTTP_FORBIDDEN;
		} elsif (!(-f $fileObj->{file_path_site})) {
			$error_code = HTTP_NOT_FOUND;
		}
	}

	return $error_code || HTTP_NOT_FOUND if $error_code || !$fileObj;

	$r->header_out('Content-Disposition', qq|filename="$fileObj->{original_name}"|);
	$r->header_out('X-XYZ', 'Util::Nginx::FileAccessor');
	$r->send_http_header($fileObj->{file_type});
	$r->sendfile($fileObj->{file_path_site});

	return OK;
}



=head1 AUTHOR

norbornen, C<< <https://github.com/norbornen/nginx-perl-dbi-util> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2015 norbornen.

This program is distributed under the MIT (X11) License.

=cut

1;
