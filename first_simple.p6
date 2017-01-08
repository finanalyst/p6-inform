#!/usr/bin/env perl6

=comment
    procedural form of inform

my $s = 'This is a <span color="blue">colored</span> inform string';

inform("1-$s",:timer(5));
inform("2-$s",:timer(10)); 
inform("3-$s",:show(False),:timer(5));
inform("4-$s",:timer(0));

sub inform ( Str $str , 
        Int :$timer = 20, 
        Str :$title = "Inform", 
        Bool :$show = True
    ) {

    use GTK::Simple;
    my GTK::Simple::App $a .= new(:title($title), :width(100), :height(40), );
    my $text = $str ~ ( 
        ($show and $timer > 0) ?? "\n<span color=\"red\">" ~ $timer ~ "</span> sec" !! '');
    my $tap;
    my $sup = $a.g-timeout(1000);    
    $a.set-content( 
        my $inf = GTK::Simple::MarkUpLabel.new( 
            :text( $text ) 
        ) 
    );
    if $timer > 0 {
        my $counter = $timer - 1;
        $tap = $sup.tap( { 
            if $show {
                $inf.text = $str ~ "\n<span color=\"red\">" ~ $counter ~ "</span> sec";
            }
            if ($counter <= 0) {
                $a.destroy;
                $a.exit;
                $tap.close;
            }
            $counter--;
            } );
        $a.deleted.tap( { $tap.close; $a.exit; });
    }
    $a.run
}