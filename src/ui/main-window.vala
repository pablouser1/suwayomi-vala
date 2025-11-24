[GtkTemplate(ui = "/es/pablouser1/suwayomi/main-window.ui")]
public class MainWindow : Adw.ApplicationWindow {
    private Api api;

    [GtkChild]
    private unowned Adw.ToastOverlay toastOverlay;

    [GtkChild]
    private unowned Adw.NavigationView nav;

    public MainWindow(App app) {
        Object(application: app);
        this.api = app.api;

        this.build_home();
    }

    private void build_home() {
        var home = new HomePage(this.api, this.nav, this.toastOverlay);
        nav.push(home);
    }
}
