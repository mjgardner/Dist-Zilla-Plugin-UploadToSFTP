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

use Moose;
use MooseX::Has::Sugar;
use MooseX::Types::Moose qw(Bool Str);
use Net::Netrc;
use Net::FTP;
with 'Dist::Zilla::Role::Releaser';

has [qw(site directory)] => ( ro, required, isa => Str );

has passive_ftp => ( ro, isa => Bool, default => 1 );

has debug => ( ro, isa => Bool, default => 0 );

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

=head2 passive_ftp

Whether to use passive FTP or not. Defaults to 1.

=head2 debug

Tells Net::FTP to print out its debug messages.  Defaults to 0.

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
