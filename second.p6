#! /usr/bin/env perl6

use lib 'lib';
use Informative;
# 
# my $p = inform( "Hi there",:title("My Message"), :timer(4) );
# $p.show("I am aware");

my $q = inform( "This is a longer message", :title<Inform>,
    :buttons(OK=>'OK', b2=>"Don't touch", b3=>"Fine by me")
    );

say "We got {$q.response}";

my $r = inform( "Give me some data", :entries( e1=>'Login name', e2_pw => 'Password') );
say "We got {$r.response}";
say "e1 holds {$r.data<e1>}";
say "e2-pw holds {$r.data<e2_pw>}";