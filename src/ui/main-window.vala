[GtkTemplate (ui = "/es/pablouser1/suwayomi/main-window.ui")]
public class MainWindow : Adw.ApplicationWindow {
    [GtkChild]
    private unowned Adw.ViewStack viewStack;

    public MainWindow(Gtk.Application app) {
        Object(application: app);
    }
}
