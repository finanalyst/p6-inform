use NativeCall;

# test for presence of gtk system library
sub LoadLibraryA( Str --> int32 ) is native( 'kernel32' ) { * };

class Build {
    method build($workdir) {
        # Non-windows is assumed to have gtk already
        if $*DISTRO.is-win {
            exit note "Windows: No GTK library found. See https://www.gtk.org/docs/installations/windows/"
                        unless ?LoadLibraryA( "libgtk-3-0.dll" );
        }
        note "GTK library found. Caution: libgtk-dev should also be installed on Linux distributions"
    }
}
