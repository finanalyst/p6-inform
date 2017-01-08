#!/usr/bin/env perl6

=comment
    informative class

my $s = 'This is a <span color="blue">colored</span> inform string';

my Informative $x .= new(:title<MyInform>);

$x.show($s);

$x.timer(10);
$x.show;

class Informative {
    has $!title = "Inform";
    has $.text = "" is rw;
    has $!inf = $!txt  ~ "\n<span color=\"red\">" ~ $!timer ~ "</span> sec") ;
    has $.timer = 20 is rw;
    has $!app;
    has $!supply;

    submethod BUILD(
        Str :$title,
        Bool :$exit-on-close = True,
        Int :$width = 200, Int :$height = 80,
        GtkWindowPosition :$position = GTK_WIN_POS_CENTER
    ) {
        my $arg_arr = CArray[Str].new;
        $arg_arr[0] = $*PROGRAM.Str;
        my $argc = CArray[int32].new;
        $argc[0] = 1;
        my $argv = CArray[CArray[Str]].new;
        $argv[0] = $arg_arr;
        gtk_init($argc, $argv);

        $!app = gtk_window_new(0);
        gtk_window_set_title($!app, $title.Str) if defined $title;

        if $exit-on-close {
            g_signal_connect_wd($!app, "delete-event",
            -> $, $ {
                self.exit
            }, OpaquePointer, 0);
        }

        # Set window default size and position
        gtk_window_set_default_size($!app, $width, $height);
        gtk_window_set_position($!app, $position);
        
        $!supply = $.g-timeout(10000):
        
    }

    method exit() {
        gtk_main_quit();
    }

    method run() {
        self.show();
        gtk_main();
    }

    method g-timeout(Cool $usecs) {
        my $s = Supplier.new;
        my $starttime = nqp::time_n();
        my $lasttime  = nqp::time_n();
        g_timeout_add($usecs.Int,
            sub (*@) {
                my $dt = nqp::time_n() - $lasttime;
                $lasttime = nqp::time_n();
                $s.emit((nqp::time_n() - $starttime, $dt));

                return 1;
            }, OpaquePointer);
        return $s.Supply;
    }

    method show ( Str $str = "") {
        $a.set-content( $inf );
        $!sup = $a.g-timeout(1000);
        $sup.tap( { 
            state $i = $duration-1;
            $inf.text = $str ~ "\n<span color=\"red\">" ~ $i ~ "</span> sec";
            $a.exit if ($i <= 0) ;
            $i--;
            } );
        

        
        $a.run
}