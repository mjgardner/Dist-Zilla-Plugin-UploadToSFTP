#!perl
#
# This file is part of Dist-Zilla-Plugin-UploadToSFTP
#
# This software is copyright (c) 2011 by GSI Commerce.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#

BEGIN {
    unless ( $ENV{RELEASE_TESTING} ) {
        require Test::More;
        Test::More::plan(
            skip_all => 'these tests are for release candidate testing' );
    }
}

use Test::More;

eval "use Test::DistManifest";
plan skip_all => "Test::DistManifest required for testing the manifest"
    if $@;
manifest_ok();
