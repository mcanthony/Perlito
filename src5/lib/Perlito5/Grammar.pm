package Perlito5::Grammar;

use Perlito5::Grammar::Expression;
use Perlito5::Grammar::Statement;
use Perlito5::Grammar::Control;
use Perlito5::Grammar::String;
use Perlito5::Grammar::Sigil;
use Perlito5::Grammar::Use;
use Perlito5::Grammar::Block;
use Perlito5::Grammar::Space;
use Perlito5::Grammar::Print;
use Perlito5::Grammar::Map;
use Perlito5::Grammar::Attribute;
use Perlito5::Grammar::Number;

sub word {
    substr( $_[0], $_[1], 1 ) =~ m/\w/
    ? {
        str  => $_[0],
        from => $_[1],
        to   => $_[1] + 1,
      }
    : 0;
}

sub ident {
    return 
        if substr( $_[0], $_[1], 1 ) !~ m/\w/
        || substr( $_[0], $_[1], 1 ) =~ m/\d/;
    my $m = {
         str  => $_[0],
         from => $_[1],
         to   => $_[1] + 1,
       };
    $m->{to}++
        while substr( $_[0], $m->{to}, 1 ) =~ m/\w/;
    $m;
}

sub caret_char {
    my $c = substr( $_[0], $_[1], 1 );
    my $pos = $_[1];
    if ($c eq '^') {
        $pos++;
        $c = substr( $_[0], $pos, 1 );
        return 0 if $c lt 'A' || $c gt 'Z';
        $c = chr( ord($c) - ord("A") + 1 );
    }
    elsif ( Perlito5::Grammar::Space::ws($_[0], $pos) ) {
        return 0;
    }
    return 0 if $c lt "\cA" || $c gt "\cZ";
    return {
             str  => $_[0],
             from => $_[1],
             to   => $pos + 1,
             capture => $c,
           }
}

token full_ident {
    <.ident>  [ '::' <.ident> ]*
};

token namespace_before_ident {
    <.ident> <before '::'>   [ '::' <.ident> <before '::'> ]*
};
token optional_namespace_before_ident {
    | <namespace_before_ident> '::'*
        { $MATCH->{capture} = Perlito5::Match::flat($MATCH->{namespace_before_ident}) }
    | '::' <optional_namespace_before_ident>
        { 
            my $name = Perlito5::Match::flat($MATCH->{optional_namespace_before_ident});
            $MATCH->{capture} = 'main';
            $MATCH->{capture} .= '::' . $name if $name ne '';
        }
    | ''
        { $MATCH->{capture} = '' }
};

token exp_stmts2 { <exp_stmts> { $MATCH->{capture} = Perlito5::Match::flat($MATCH->{exp_stmts}) } };

token exp {
    <Perlito5::Grammar::Expression::exp_parse>
        { $MATCH->{capture} = Perlito5::Match::flat($MATCH->{"Perlito5::Grammar::Expression::exp_parse"}) }
};

token exp2 {
    <Perlito5::Grammar::Expression::exp_parse>
        { $MATCH->{capture} = Perlito5::Match::flat($MATCH->{"Perlito5::Grammar::Expression::exp_parse"}) }
};

token opt_type {
    |   '::'?  <full_ident>   { $MATCH->{capture} = Perlito5::Match::flat($MATCH->{full_ident}) }
    |   ''                    { $MATCH->{capture} = '' }
};

token var_sigil     { \$ |\% |\@ |\& | \* };

token var_name      { <full_ident> | <Perlito5::Grammar::Number::digits> };

token var_ident {
    <var_sigil> <optional_namespace_before_ident> <var_name>
    {
        $MATCH->{capture} = Perlito5::AST::Var->new(
            sigil       => Perlito5::Match::flat($MATCH->{var_sigil}),
            namespace   => Perlito5::Match::flat($MATCH->{optional_namespace_before_ident}),
            name        => Perlito5::Match::flat($MATCH->{var_name}),
        )
    }
};

sub block {
    Perlito5::Grammar::Block::block(@_)
}
sub block2 {
    Perlito5::Grammar::Block::block(@_)
}
sub opt_continue_block {
    Perlito5::Grammar::Block::opt_continue_block(@_)
}

my @PKG;
sub exp_stmts {
    my $str = $_[0];
    my $pos = $_[1];
    push @PKG, $Perlito5::PKG_NAME;
 
    my $has_semicolon;  # TODO - use this to help disambiguate: block vs. hash literal
    my @stmts;
    my $m = Perlito5::Grammar::Space::opt_ws($str, $pos);
    $pos = $m->{to};
    while ($m) {
        if ( substr($str, $pos, 1) eq ';' ) {
            $has_semicolon = 1;
            $m = Perlito5::Grammar::Space::opt_ws($str, $pos + 1);
            $pos = $m->{to};
        }
        else {
            $m = Perlito5::Grammar::Statement::statement_parse($str, $pos);
            if ($m) {
                push @stmts, $m->{capture};
                $pos = $m->{to};
                if ( substr($str, $pos, 1) eq ';' ) {
                    $has_semicolon = 1;
                    $pos = $pos + 1;
                }
                $m = Perlito5::Grammar::Space::opt_ws($str, $pos);
                $pos = $m->{to};
            }
        }
    }
    $Perlito5::PKG_NAME = pop @PKG;
    $Perlito5::BLOCK_HAS_SEMICOLON ||= $has_semicolon;
    return { str => $str, to => $pos, capture => \@stmts };
}


=begin

=head1 NAME

Perlito5::Grammar - Grammar for Perlito

=head1 SYNOPSIS

    my $match = $source.parse;
    Perlito5::Match::flat($match);    # generated Perlito AST

=head1 DESCRIPTION

This module generates a syntax tree for the Perlito compiler.

=head1 AUTHORS

Flavio Soibelmann Glock <fglock@gmail.com>.
The Pugs Team E<lt>perl6-compiler@perl.orgE<gt>.

=head1 SEE ALSO

The Perl 6 homepage at L<http://dev.perl.org/perl6>.

The Pugs homepage at L<http://pugscode.org/>.

=head1 COPYRIGHT

Copyright 2006, 2009, 2010, 2011, 2012 by Flavio Soibelmann Glock, Audrey Tang and others.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=end
