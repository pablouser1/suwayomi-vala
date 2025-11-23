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
                var container = new Gtk.FlowBox();

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

            foreach (var manga in mangas_category) {
                var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 10);
                var picture = new Gtk.Picture();
                picture.set_size_request(100, 300);
                picture.set_content_fit(Gtk.ContentFit.SCALE_DOWN);
                try {
                    var bytes = yield api.image(manga.thumbnailUrl);
                    var texture = Gdk.Texture.from_bytes(bytes);
                    picture.set_paintable(texture);
                    box.append(picture);
                    box.append(new Gtk.Label(manga.title));
                    tab.child.append(box);
                } catch (Error e) {
                    this.toastOverlay.add_toast(new Adw.Toast(e.message));
                    picture.set_paintable(null);
                }
            }

            tab.fetched = true;
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
                }
            }
        }
    }
}