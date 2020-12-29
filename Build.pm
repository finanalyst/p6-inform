use NativeCall;

# The whole of this file is based on BUILD.pm in GTK::Simple

# test sub for system library
sub test() is native('libgtk-3-0.dll') { * }

class Build {
    method build($workdir) {
        my $no-gtk = False;

        # we only have .dll files bundled. Non-windows is assumed to have gtk already
        if $*DISTRO.is-win {
            test();
            CATCH {
                default {
                    $no-gtk = True if $_.payload ~~ m:s/Cannot locate/;
                }
            }
        }
        exit note "Windows: No GTK library found. See https://www.gtk.org/docs/installations/windows/"
            if $no-gtk;
        note "GTK library found. Caution is libgtk-dev installed on Linux distributions?"
    }
}
