use v6;
use Test;
use Informative;

plan *;

if %*ENV<DISPLAY> or $*DISTRO.is-win {
    my Informative::Informing $p;
    lives-ok { $p .= new }, 'instantiates ok';
    lives-ok {$p = inform(:timer(2))} , 'creates an object and shows it';
    lives-ok {$p.show('A string')}, 're uses the object';
    isa-ok $p, Informative::Informing, 'is the correct type';
}

done-testing;
