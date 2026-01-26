[GtkTemplate (ui = "/es/pablouser1/suwayomi/main-window.ui")]
public class MainWindow : Adw.ApplicationWindow {
    private DataFetch data_fetch;

    [GtkChild]
    private unowned Adw.ToastOverlay toast_overlay;

    [GtkChild]
    private unowned Adw.NavigationView nav;

    public MainWindow (App app) {
        Object (application: app);
        this.data_fetch = app.data_fetch;

        this.build_home ();
    }

    private void build_home () {
        var home = new HomePage (this.data_fetch, this.nav, this.toast_overlay);
        nav.push (home);
    }
}
