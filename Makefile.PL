
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'Upload tarball to my own site',
  'AUTHOR' => 'Mark Gardner <mjgardner@cpan.org>, Curtis Jewell <CSJewell@cpan.org>',
  'BUILD_REQUIRES' => {
    'Carp' => '0',
    'English' => '0',
    'File::Find' => '0',
    'File::Temp' => '0',
    'Scalar::Util' => '0',
    'Test::More' => '0.94',
    'perl' => '5.004'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.30'
  },
  'DISTNAME' => 'Dist-Zilla-Plugin-UploadToSFTP',
  'EXE_FILES' => [],
  'LICENSE' => 'perl',
  'NAME' => 'Dist::Zilla::Plugin::UploadToSFTP',
  'PREREQ_PM' => {
    'Dist::Zilla::Role::Releaser' => '0',
    'Moose' => '0',
    'MooseX::Has::Sugar' => '0',
    'MooseX::Types::Moose' => '0',
    'Net::FTP' => '0',
    'Net::Netrc' => '0',
    'utf8' => '0'
  },
  'VERSION' => '0.001',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



