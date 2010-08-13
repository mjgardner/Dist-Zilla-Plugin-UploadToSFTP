package Dist::Zilla::Plugin::CSJEWELL::DotFileFix;

use 5.008003;
use Moose;
use File::Copy qw( move );
use English qw( -no_match_vars );
with 'Dist::Zilla::Role::AfterMint';

our $VERSION = '0.900';
$VERSION =~ s/_//sm;


sub after_mint {
	my ( $self, $hash ) = @_;

	my $root = $hash->{mint_root};

	my $source_file = $root->file('_hgignore')->stringify();
	my $dest_file   = $root->file('.hgignore')->stringify();

	move( $source_file, $dest_file )
	  or $self->log("Could not move _hgignore to .hgignore: $OS_ERROR");

	return 1;
} ## end sub after_mint

__PACKAGE__->meta()->make_immutable();
no Moose;
1;

__END__

=pod

=head1 NAME

Dist::Zilla::Plugin::CSJEWELL::DotFileFix - Fix the .hgignore file.

=head1 VERSION

This document describes Dist::Zilla::Plugin::CSJEWELL::DotFileFix version 0.900.

=head1 DESCRIPTION

This plugin renames the _hgignore file in the source to .hgignore.

=for Pod::Coverage after_mint

=head1 AUTHOR

Curtis Jewell <CSJewell@cpan.org>

=head1 SEE ALSO

L<Dist::Zilla::BeLike::CSJEWELL|Dist::Zilla::BeLike::CSJEWELL>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2010, Curtis Jewell C<< CSJewell@cpan.org >>.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself, either version
5.8.1 or any later version. See L<perlartistic|perlartistic> 
and L<perlgpl|perlgpl>.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut

