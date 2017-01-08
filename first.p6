#!/usr/bin/env perl6
use lib 'lib';
use Informative;

=comment
    object form of inform

sub MAIN () {
    my $stg = 'This is a <span color="blue">colored</span> inform string';
    
    my Informative $popup .= new();
    
    $popup.show;

    $popup.show("1\: $stg for 5",:timer(5));
     sleep 3;
     $popup.show("2\: $stg for 10",:timer(10));
     $popup.show(:timer(9));
     $popup.show("3\: $stg for 5",:show-countdown(False),:timer(5));
     $popup.show("4\: $stg forever",:show-countdown,:timer(0));
}
    
