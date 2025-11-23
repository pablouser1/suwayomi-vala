[GtkTemplate(ui = "/es/pablouser1/suwayomi/main-window.ui")]
public class MainWindow : Adw.ApplicationWindow {
    private Api api;
    private Gee.Map<string, Tab> tabs = new Gee.HashMap<string, Tab>();

    [GtkChild]
    private unowned Adw.ToastOverlay toastOverlay;

    [GtkChild]
    private unowned Adw.ViewStack viewStack;

    public MainWindow(Api api, Gtk.Application app) {
        Object(application: app);
        this.api = api;

        this.viewStack.notify["visible-child"].connect(this.on_page_changed);
        this.build_tabs.begin();
    }

    private async void build_tabs() {
        try {
            var categories = yield this.api.categories();

            foreach (var category in categories) {
                var container = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);

                this.tabs.set(category.id.to_string(), new Tab(category.id, container));
                this.viewStack.add_titled(
                    container,
                    category.id.to_string(),
                    category.name
                );
            }
        } catch (Error e) {
            this.toastOverlay.add_toast(new Adw.Toast(e.message));
        }
    }

    private async void fetch_mangas_from_category(Tab tab) {
        try {
            var mangas_category = yield this.api.mangas_from_category(tab.id);
            print("Appending %s", mangas_category.first().title);
            tab.child.append(new Gtk.Label(mangas_category.first().title));
        } catch (Error e) {
            this.toastOverlay.add_toast(new Adw.Toast(e.message));
        }
    }

    private void on_page_changed() {
        var child = this.viewStack.visible_child;
        if (child != null) {
            // Get the specific page object to access properties like 'title'
            var page = this.viewStack.get_page (child);
            print ("Switched to view: %s (%s)\n", page.name, page.title);

            if (this.tabs.has_key(page.name)) {
                var tab = this.tabs.get(page.name);

                if (!tab.fetched) {
                   this.fetch_mangas_from_category.begin(tab);
                   tab.fetched = true;
                }
            }
        }
    }
}