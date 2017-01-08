#!/usr/bin/env perl6
use NativeCall;
use nqp;
class Informative {
    has $!app;
    has $!inf-lable;
    has $!deleted_supply;

    enum GtkWindowPosition (
        GTK_WIN_POS_NONE               => 0,
        GTK_WIN_POS_CENTER             => 1,
        GTK_WIN_POS_MOUSE              => 2,
        GTK_WIN_POS_CENTER_ALWAYS      => 3,
        GTK_WIN_POS_CENTER_ON_PARENT   => 4,
    );

    class GtkWidget is repr('CPointer') { }

    submethod BUILD (
    Str :$title = "Inform",
    Str :$text = "Say something beautiful",
    GtkWindowPosition :$position = GTK_WIN_POS_CENTER
    ) {
        my $arg_arr = CArray[Str].new;
        $arg_arr[0] = $*PROGRAM.Str;
        my $argc = CArray[int32].new;
        $argc[0] = 1;
        my $argv = CArray[CArray[Str]].new;
        $argv[0] = $arg_arr;
        gtk_init($argc, $argv); #

        $!app = gtk_window_new(0); #
        gtk_window_set_title($!app, $title.Str) if defined $title; #

        g_signal_connect_wd($!app, "delete-event",
        -> $, $ {
            self.exit
        }, OpaquePointer, 0); #

        # Set window default size and position
        gtk_window_set_default_size($!app, 100, 40); #
        gtk_window_set_position($!app, $position); #
        
        $!inf-lable = gtk_label_new(''.Str);
        gtk_label_set_markup($!inf-lable, $text.Str);
        gtk_container_add( $!app, $!inf-lable );
    }
    
    method show( Str $str) {
        gtk_label_set_markup($!inf-lable,$str.Str)
            if $str ne '';
#        gtk_widget_show($!inf-lable); #        
    }

    method exit() {
        gtk_main_quit(); #
    }

    method run() {
        gtk_widget_show_all($!app); #
        gtk_main(); #
    }

    method g-timeout(Cool $usecs) {
        my $s = Supplier.new;
        my $starttime = nqp::time_n();
        my $lasttime  = nqp::time_n();
        g_timeout_add($usecs.Int,
            sub (*@) {
                my $dt = nqp::time_n() - $lasttime;
                $lasttime = nqp::time_n();
                $s.emit((nqp::time_n() - $starttime, $dt)); #

                return 1;
            }, OpaquePointer);
        return $s.Supply;
    }

    method destroy() {
        gtk_widget_destroy($!app); #
    }

    method deleted() {
        $!deleted_supply //= do {
            my $s = Supplier.new;
            g_signal_connect_wd($!app, "delete-event",
                -> $, $ {
                    $s.emit(self);
                    CATCH { default { note $_; } }
                },
                OpaquePointer, 0); #
            $s.Supply;
        }
    }
    
    sub gtk_init(CArray[int32] $argc, CArray[CArray[Str]] $argv)
        is native('gtk-3')
        {*}

    sub gtk_main()
        is native('gtk-3')
        {*}

    sub gtk_main_quit()
        is native('gtk-3')
        {*}

    sub gtk_window_new(int32 $window_type)
        is native('gtk-3')
        returns GtkWidget
        {*}

    sub gtk_window_set_title(GtkWidget $w, Str $title)
        is native('gtk-3')
        returns GtkWidget
        {*}

    sub gtk_window_set_position(GtkWidget $window, int32 $position)
        is native('gtk-3')
        { * }

    sub gtk_window_set_default_size(GtkWidget $window, int32 $width, int32 $height)
        is native('gtk-3')
        { * }

    sub g_signal_connect_wd(GtkWidget $widget, Str $signal,
        &Handler (GtkWidget $h_widget, OpaquePointer $h_data),
        OpaquePointer $data, int32 $connect_flags)
        returns int32
        is native('gobject-2.0')
        is symbol('g_signal_connect_object')
        { * }

    sub g_timeout_add(int32 $interval, &Handler (OpaquePointer $h_data, --> int32), OpaquePointer $data)
        is native('gtk-3')
        returns int32
        {*}

    sub gtk_widget_destroy(GtkWidget $widget)
        is native('gtk-3')
        {*}

    sub gtk_container_add(GtkWidget $container, GtkWidget $widgen)
        is native('gtk-3')
        {*}
        
    sub gtk_widget_show_all(GtkWidget $widgetw)
        is native('gtk-3')
        {*}
            
    sub gtk_label_new(Str $text)
        is native('gtk-3')
        returns GtkWidget
        {*}

    sub gtk_label_set_markup(GtkWidget $label, Str $text)
        is native('gtk-3')
        {*}

}


=comment
    procedural form of inform
use Informative;

sub MAIN () {
    my $stg = 'This is a <span color="blue">colored</span> inform string';

    inform("1\: $stg",:timer(5));
    inform("2\: $stg",:timer(10));
    inform(:timer(9));
    inform("3\: $stg",:show(False),:timer(5));
    inform("4\: $stg",:timer(0));
}
    
sub inform( 
    Str $str?, 
    Int :$timer = 20, 
    Str :$title = "Inform", 
    Bool :$show = True
) {
    state Informative $a .= new(
        :title($title), 
        :text($str ~ 
            ( ($show and $timer > 0) ?? "\n<span color=\"red\">" ~ $timer ~ "</span> sec" !! '') )
    );
    my $tap;
    my $sup = $a.g-timeout(1000);
    
    if $timer > 0 {
        my $counter = $timer - 1;
        $tap = $sup.tap( { 
            if $show {
                $a.show( $str ~ "\n<span color=\"red\">" ~ $counter ~ " sec</span>");
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