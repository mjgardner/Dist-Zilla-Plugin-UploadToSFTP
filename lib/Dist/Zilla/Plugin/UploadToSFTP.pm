package Dist::Zilla::Plugin::UploadToSFTP;

# ABSTRACT: Upload tarball to my own site

use Moose;
use MooseX::Has::Sugar;
use MooseX::Types::Moose qw(Bool Str);
use Net::Netrc;
use Net::FTP;
with 'Dist::Zilla::Role::Releaser';

=attr site

The FTP site to upload to.

=attr directory

The directory on the FTP site to upload the tarball to.

=cut

has [qw(site directory)] => ( ro, required, isa => Str );

=attr passive_ftp

Whether to use passive FTP or not. Defaults to 1.

=cut

has passive_ftp => ( ro, isa => Bool, default => 1 );

=attr debug

Tells Net::FTP to print out its debug messages.  Defaults to 0.

=cut

has debug => ( ro, isa => Bool, default => 0 );

=method release

Uploads the tarball to the specified site and directory.

=cut

sub release {
    my ( $self, $archive ) = @_;

    my $filename = $archive->stringify();
    my $site     = $self->site();
    my $siteinfo = Net::Netrc->lookup($site);
    if ( not $siteinfo ) {
        $self->log_fatal("Could not get information for $site from .netrc.");
    }
    my ( $user, $password, undef ) = $siteinfo->lpa();

    my $ftp = Net::FTP->new(
        $site,
        Debug   => $self->debug(),
        Passive => $self->passive_ftp(),
    );

    $ftp->login( $user, $password )
        or $self->log_fatal( 'Could not log in to ' . $site );

    $ftp->binary;

    $ftp->cwd( $self->directory() )
        or $self->log_fatal(
        'Could not change remote site directory to' . $self->directory() );

    my $remote_file = $ftp->put($filename);

    if ( $remote_file ne $filename ) {
        $self->log_fatal( 'Could not upload file: ' . $ftp->message() );
    }

    my $remote_size = $ftp->size($remote_file);
    $remote_size ||= 0;
    my $local_size = -s $filename;

    if ( $remote_size != $local_size ) {
        $self->log( "Uploaded file is $remote_size bytes, "
                . "but local file is $local_size bytes" );
    }

    $ftp->quit;

    $self->log( 'File uploaded to ' . $self->site() );

    return 1;
}

__PACKAGE__->meta->make_immutable();
1;

=head1 DESCRIPTION

    ; in dzil.ini
    [UploadToSFTP]
    site        = ftp.geocities.invalid
    directory   = /Heartland/Meadows/3044
    passive_ftp = 1
    debug       = 0

    # in $HOME/.netrc
    machine ftp.geocities.invalid login csjewell password drowssap

=head2 .netrc file

The .netrc file is described in L<Net::Netrc|Net::Netrc> and should have an
entry in it, matching the site given in the dzil.ini file, and specifying
the username and password.

=head1 SEE ALSO

L<Dist::Zilla::BeLike::CSJEWELL|Dist::Zilla::BeLike::CSJEWELL>
