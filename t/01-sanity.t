use v6.d;
use Test;

use-ok 'Informative';

use Informative;
my Informative::Informing $p;
lives-ok { $p .= new }, 'instantiates ok';

done-testing;
