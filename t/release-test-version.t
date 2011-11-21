#!/usr/bin/perl
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

use 5.006;
use strict;
use warnings;
use Test::More;

eval "use Test::Version 0.04";
plan skip_all => "Test::Version 0.04 required for testing versions"
    if $@;

version_all_ok();
done_testing;
