[GtkTemplate (ui = "/es/pablouser1/suwayomi/main-window.ui")]
public class MainWindow : Adw.ApplicationWindow {
    private Api api;

    [GtkChild]
    private unowned Adw.ToastOverlay toastOverlay;
    [GtkChild]
    private unowned Adw.ViewStack viewStack;

    public MainWindow(Api api, Gtk.Application app) {
        Object(application: app);
        this.api = api;

        this.fetch_data.begin();
    }

    private async void fetch_data() {
        try {
            var categories = yield this.api.categories();

            foreach (var category in categories) {
                this.viewStack.add_titled(new Gtk.Label(category.name), category.id.to_string(), category.name);
            }
        } catch (Error e) {
            this.toastOverlay.add_toast(new Adw.Toast(e.message));
        }
    }
}
