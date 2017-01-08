use GTK::Simple;
show_text("Here",5); show_text("There",10);

sub show_text( Str $str, $time ) {
my $a = GTK::Simple::App.new();
$a.set-content(my $inf = GTK::Simple::Label.new(:text($str)));
my $sup = $a.g-timeout(1000);
$sup.tap( { 
            state $i = $time-1;
            $inf.text = $str ~ $i;
            $a.exit if ($i <= 0);
            $i--;
            } );
$a.run;
}
