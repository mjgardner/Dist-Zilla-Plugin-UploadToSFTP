package Dist::Zilla::Plugin::UploadToSFTP;

# ABSTRACT: Upload tarball to my own site

use English '-no_match_vars';
use Moose;
use MooseX::Has::Sugar;
use MooseX::Types::Moose qw(Bool Str);
use Net::Netrc;
use Net::SFTP::Foreign::Exceptional;
use Try::Tiny;
use namespace::autoclean;
with 'Dist::Zilla::Role::Releaser';

=attr site

The FTP site to upload to.

=attr directory

The directory on the FTP site to upload the tarball to.

=cut

has [qw(site directory)] => ( ro, required, isa => Str );

=attr debug

Tells ssh to run in verbose mode.  Defaults to 0.

=cut

has debug => ( ro, isa => Bool, default => 0 );

has _sftp => ( ro, lazy_build, isa => 'Net::SFTP::Foreign::Exceptional' );

sub _build__sftp
{    ## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
    my $self = shift;

    my %sftp_args = (
        host     => $self->site,
        user     => $self->login,
        password => $self->password,
    );
    if ( $self->debug ) { $sftp_args{more} = '-v' }

    my $sftp;
    try { $sftp = Net::SFTP::Foreign::Exceptional->new(%sftp_args) }
    catch { $self->log_fatal($ARG) };
    return $sftp;
}

has _netrc => ( ro, lazy_build,
    isa     => 'Net::Netrc',
    handles => [qw(login password)],
);

sub _build__netrc
{    ## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
    my $self  = shift;
    my $site  = $self->site;
    my $netrc = Net::Netrc->lookup($site)
        or
        $self->log_fatal("Could not get information for $site from .netrc.");
    return $netrc;
}

=method release

Uploads the tarball to the specified site and directory.

=cut

sub release {
    my ( $self, $archive ) = @ARG;
    my $sftp = $self->_sftp;

    try { $sftp->setcwd( $self->directory ) }
    catch { $self->log_fatal($ARG) };

    try { $sftp->put( ("$archive") x 2 ) } catch { $self->log_fatal($ARG) };

    my $remote_size;
    {
        ## no critic (ValuesAndExpressions::ProhibitAccessOfPrivateData)
        $remote_size = $sftp->ls("$archive")->{a}->size || 0;
    }
    my $local_size = $archive->stat->size;
    if ( $remote_size != $local_size ) {
        $self->log( "Uploaded file is $remote_size bytes, "
                . "but local file is $local_size bytes" );
    }
    $self->log( "$archive uploaded to " . $self->site );

    return;
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
