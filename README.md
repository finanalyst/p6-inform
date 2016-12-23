Provides an inform information box from a perl6 program. It is easy to add buttons and simple entry widgets to the box. Information is returned to a capture object.
The module depends on gtk and borrows heavily from the gtk-simple module, but is not dependent on it.
Module developed using Ubuntu.
'''
eg.
use Inform;
=comment
  Show a box with some information on screen, has a destructor x on window, but removes itself after 10s.
inform( 'this is information' );
# The label shown in the box is 'this is information', the default title is 'Inform'

=comment 
  As above but for a longer time (15s)
inform( 'longer time span for me', :timer(15), :title<More> );
# The title of the window is now 'More'

=comment
  Add a couple of buttons
my $response = inform( 'Do you want to continue?') does buttons( 'OK','Not on your life', 'Cancel'=> "I don't want to"); 
# The box contains the label 'Do you want to continue' and has three buttons with labels 'OK', 'Not on your life' and "I don't want to"
=comment
  Access response information using an array interogation: the order is dependent on the order of the buttons in the calling list
say 'Ok continuing' if $response[0];
=comment
  Access response using a hash intergation based on the string
say 'I am heedful of your desires' if $response<Not on your life>;
=comment
  Access response based on key of key/pair item
say 'Sure, I can wait for ever if you want' if $response<Cancel>;
=comment
  Check whether the destruct x was clicked
say 'So you don\'t like the options I gave you, huh?' if $response<_destruct>;

=comment
  Add an entry widget
my $data = inform('Give me some things to clean') does buttons(:Cancel('None today'), 'Response'=>'Here you go')
  does entry( 'Laundry' => 'Enter your laundry list');
# Box contains a label, then one or more entry widgets, then a row of boxes. The formating will depend on gtk defaults

if $data<Cancel> { say 'Great, more free time for me' }
=comment
  the special _activate flag is set when the <return> key is used to terminate input inside an entry widget
elsif $data<Response> or $data<_activate> {
  for $data<Laundry>.comb(/W+/) { say "I will clean your $_" }
}

There are no limits in the module on the number of buttons or entry widgets that can be added. However, in practice, the reliance on gtk default formating will probably quickly make the inform box look ugly.

If more complicated widgets or formating are required, look at the Gtk::Simple module.
