# Do not edit this file - Generated by Perlito5 8.0
use v5;
use utf8;
use strict;
use warnings;
no warnings ('redefine', 'once', 'void', 'uninitialized', 'misc', 'recursion');
use Perlito5::Perl5::Runtime;
use Perlito5::Perl5::Prelude;
our $MATCH = Perlito5::Match->new();
{
package main;
    sub new { shift; bless { @_ }, "main" }
    use v5;
    {
    package Perlito5::Match;
        sub new { shift; bless { @_ }, "Perlito5::Match" }
        sub from { $_[0]->{from} };
        sub to { $_[0]->{to} };
        sub str { $_[0]->{str} };
        sub bool { $_[0]->{bool} };
        sub capture { $_[0]->{capture} };
        sub scalar {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            if (($self->{bool})) {
                if ((defined($self->{capture}))) {
                    return ($self->{capture})
                };
                return (substr($self->{str}, $self->{from}, (($self->{to} - $self->{from}))))
            }
            else {
                return ('')
            }
        };
        sub flat {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            if (($self->{bool})) {
                if ((defined($self->{capture}))) {
                    return ($self->{capture})
                };
                return (substr($self->{str}, $self->{from}, (($self->{to} - $self->{from}))))
            }
            else {
                return ('')
            }
        };
        sub string {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            if (($self->{bool})) {
                if ((defined($self->{capture}))) {
                    return ($self->{capture})
                };
                return (substr($self->{str}, $self->{from}, (($self->{to} - $self->{from}))))
            }
            else {
                return ('')
            }
        }
    }

;
    {
    package Main;
        sub new { shift; bless { @_ }, "Main" }
        1
    }


}

1;
