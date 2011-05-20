#
# This file is part of Dist-Zilla-Plugin-UploadToSFTP
#
# This software is copyright (c) 2011 by Curtis Jewell.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
use 5.008;
use strict;
use warnings;
use utf8;

package Dist::Zilla::Plugin::UploadToSFTP;

BEGIN {
    $Dist::Zilla::Plugin::UploadToSFTP::VERSION = '0.001';
}

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

has [qw(site directory)] => ( ro, required, isa => Str );

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

__END__

=pod

=for :stopwords Mark Gardner Curtis Jewell cpan testmatrix url annocpan anno bugtracker rt
cpants kwalitee diff irc mailto metadata placeholders

=head1 NAME

Dist::Zilla::Plugin::UploadToSFTP - Upload tarball to my own site

=head1 VERSION

version 0.001

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

=head1 ATTRIBUTES

=head2 site

The FTP site to upload to.

=head2 directory

The directory on the FTP site to upload the tarball to.

=head2 debug

Tells ssh to run in verbose mode.  Defaults to 0.

=head1 METHODS

=head2 release

Uploads the tarball to the specified site and directory.

=head1 SEE ALSO

L<Dist::Zilla::BeLike::CSJEWELL|Dist::Zilla::BeLike::CSJEWELL>

=head1 SUPPORT

=head2 Perldoc

You can find documentation for this module with the perldoc command.

  perldoc Dist::Zilla::Plugin::UploadToSFTP

=head2 Websites

The following websites have more information about this module, and may be of help to you. As always,
in addition to those websites please use your favorite search engine to discover more resources.

=over 4

=item *

Search CPAN

The default CPAN search engine, useful to view POD in HTML format.

L<http://search.cpan.org/dist/Dist-Zilla-Plugin-UploadToSFTP>

=item *

AnnoCPAN

The AnnoCPAN is a website that allows community annonations of Perl module documentation.

L<http://annocpan.org/dist/Dist-Zilla-Plugin-UploadToSFTP>

=item *

CPAN Ratings

The CPAN Ratings is a website that allows community ratings and reviews of Perl modules.

L<http://cpanratings.perl.org/d/Dist-Zilla-Plugin-UploadToSFTP>

=item *

CPANTS

The CPANTS is a website that analyzes the Kwalitee ( code metrics ) of a distribution.

L<http://cpants.perl.org/dist/overview/Dist-Zilla-Plugin-UploadToSFTP>

=item *

CPAN Testers

The CPAN Testers is a network of smokers who run automated tests on uploaded CPAN distributions.

L<http://www.cpantesters.org/distro/D/Dist-Zilla-Plugin-UploadToSFTP>

=item *

CPAN Testers Matrix

The CPAN Testers Matrix is a website that provides a visual way to determine what Perls/platforms PASSed for a distribution.

L<http://matrix.cpantesters.org/?dist=Dist-Zilla-Plugin-UploadToSFTP>

=item *

CPAN Testers Dependencies

The CPAN Testers Dependencies is a website that shows a chart of the test results of all dependencies for a distribution.

L<http://deps.cpantesters.org/?module=Dist::Zilla::Plugin::UploadToSFTP>

=back

=head2 Bugs / Feature Requests

Please report any bugs or feature requests through the web
interface at L<https://github.com/mjgardner/Dist-Zilla-Plugin-UploadToSFTP/issues>. You will be automatically notified of any
progress on the request by the system.

=head2 Source Code

The code is open to the world, and available for you to hack on. Please feel free to browse it and play
with it, or whatever. If you want to contribute patches, please send me a diff or prod me to pull
from your repository :)

L<https://github.com/mjgardner/Dist-Zilla-Plugin-UploadToSFTP>

  git clone git://github.com/mjgardner/Dist-Zilla-Plugin-UploadToSFTP.git

=head1 AUTHORS

=over 4

=item *

Mark Gardner <mjgardner@cpan.org>

=item *

Curtis Jewell <CSJewell@cpan.org>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Curtis Jewell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
