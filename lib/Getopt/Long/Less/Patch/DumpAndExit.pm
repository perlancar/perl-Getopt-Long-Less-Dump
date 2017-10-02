package Getopt::Long::Less::Patch::DumpAndExit;

# DATE
# VERSION

use strict;
no warnings;

use Data::Dmp;
use Module::Patch 0.26 qw();
use base qw(Module::Patch);

our %config;

sub _dump {
    print "# BEGIN DUMP $config{-tag}\n";
    local $Data::Dmp::OPT_DEPARSE = 0;
    print dmp($_[0]), "\n";
    print "# END DUMP $config{-tag}\n";
}

sub _GetOptions {
    if (ref($_[0]) eq 'HASH') {
        my $h = shift;
        _dump({ map {$_ => sub{}} @_ });
    } else {
        _dump({@_});
    }
    $config{-exit_method} eq 'exit' ? exit(0) : die;
}

sub _GetOptionsFromArray {
    # discard array
    shift;
    if (ref($_[0]) eq 'HASH') {
        my $h = shift;
        _dump({ map {$_ => sub{}} @_ });
    } else {
        _dump({@_});
    }
    $config{-exit_method} eq 'exit' ? exit(0) : die;
}

sub patch_data {
    return {
        v => 3,
        patches => [
            {
                action      => 'replace',
                sub_name    => 'GetOptions',
                code        => \&_GetOptions,
            },
            {
                action      => 'replace',
                sub_name    => 'GetOptionsFromArray',
                code        => \&_GetOptionsFromArray,
            },
        ],
        config => {
            -tag => {
                schema  => 'str*',
                default => 'TAG',
            },
            -exit_method => {
                schema  => 'str*',
                default => 'exit',
            },
        },
   };
}

1;
# ABSTRACT: Patch Getopt::Long::Less to dump option spec and exit

=for Pod::Coverage ^(patch_data)$

=head1 DESCRIPTION

This patch can be used to extract Getopt::Long options specification from a
script by running the script but exiting early after getting the specification.
