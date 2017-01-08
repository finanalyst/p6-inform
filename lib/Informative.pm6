use NativeCall;
use nqp;
class Informative {
    has $!app;
    has Bool $!reinit = True;
    has $!inf-lable;
    has $!deleted_supply;
    has $!title;
    has $!position;
    has Supply $!sup = self.g-timeout(1000);
    has Tap $!tap;
    has Int $!timer = 10;
    has Bool $!show-countdown = True;
    has Str $.text is rw = "Say <span color=\"green\">something</span><span weight=\"bold\" color=\"red\"> beautiful</span>";

    enum GtkWindowPosition (
        GTK_WIN_POS_NONE               => 0,
        GTK_WIN_POS_CENTER             => 1,
        GTK_WIN_POS_MOUSE              => 2,
        GTK_WIN_POS_CENTER_ALWAYS      => 3,
        GTK_WIN_POS_CENTER_ON_PARENT   => 4,
    );

    class GtkWidget is repr('CPointer') { }

    submethod BUILD (
    Str :$!title = "Inform",
    GtkWindowPosition :$!position = GTK_WIN_POS_CENTER
    ) {
        my $arg_arr = CArray[Str].new;
        $arg_arr[0] = $*PROGRAM.Str;
        my $argc = CArray[int32].new;
        $argc[0] = 1;
        my $argv = CArray[CArray[Str]].new;
        $argv[0] = $arg_arr;
        gtk_init($argc, $argv);
        
        self.init;
    }
        
    submethod init {
        $!app = gtk_window_new(0);
        gtk_window_set_title($!app, $!title.Str);

        g_signal_connect_wd($!app, "delete-event",
        -> $, $ {
            self.destroy
        }, OpaquePointer, 0);

        # Set window default size and position
        gtk_window_set_default_size($!app, 100, 40);
        gtk_window_set_position($!app, $!position);
        gtk_container_set_border_width($!app, 10);
        
        $!inf-lable = gtk_label_new(''.Str);
        gtk_container_add( $!app, $!inf-lable );
        $!reinit = False;
    }
    
    method make-text( $count ) {
        my $lable = $!text;
        if $!show-countdown and $!timer > 0 {
            $lable ~= "\n <span color=\"red\">$count sec</span>"
        } elsif $!show-countdown {
            $lable ~= "\n<span color=\"red\">Til window is closed</span>"
        }
        gtk_label_set_markup($!inf-lable, $lable.Str);
    }

    method hide() {
        $!tap.close;
        gtk_widget_hide($!app);
        gtk_main_quit();
    }

    method show(
        Str $str?,
        Int :$timer,
        Bool :$show-countdown
    ) {
        self.init if $!reinit;
        $!timer = $timer // $!timer;
        $!show-countdown = $show-countdown // $!show-countdown;
        $!text = $str // $!text;
        self.make-text( $!timer );
           
        if $!timer > 0 {
            my $counter = $!timer - 1;
            $!tap = $!sup.tap( { 
                self.make-text( $counter );
                if ($counter <= 0) {
                    self.hide();
                }
                $counter--;
                } );
            self.deleted.tap( { self.hide; });
        }
        gtk_widget_show_all($!app);
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

    method destroy() {
        $!tap.close;
        $!reinit = True;
        gtk_widget_destroy($!app);
        gtk_main_quit();
    }

    method deleted() {
        $!deleted_supply //= do {
            my $s = Supplier.new;
            g_signal_connect_wd($!app, "delete-event",
                -> $, $ {
                    $s.emit(self);
                    CATCH { default { note $_; } }
                },
                OpaquePointer, 0);
            $s.Supply;
        }
    }
    
    sub gtk_init(CArray[int32] $argc, CArray[CArray[Str]] $argv)
        is native('gtk-3')
        {*}

    sub gtk_widget_show(GtkWidget $widgetw)
        is native('gtk-3')
        is export
        {*}

    sub gtk_widget_hide(GtkWidget $widgetw)
        is native('gtk-3')
        is export    
        { * }

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

    sub gtk_container_set_border_width(GtkWidget $container, int32 $border_width)
        is native('gtk-3')
        is export
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
