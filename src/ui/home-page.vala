[GtkTemplate(ui = "/es/pablouser1/suwayomi/home-page.ui")]
public class HomePage: Adw.NavigationPage {
    private Api api;
    private Gee.Map<string, Tab> tabs = new Gee.HashMap<string, Tab>();

    private unowned Adw.NavigationView nav;
    private unowned Adw.ToastOverlay toastOverlay;

    [GtkChild]
    private unowned Adw.ViewStack viewStack;

    public HomePage(Api api, Adw.NavigationView nav, Adw.ToastOverlay toastOverlay) {
        this.api = api;
        this.nav = nav;
        this.toastOverlay = toastOverlay;

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
                var picture = new Gtk.Picture();
                picture.set_size_request(100, 300);
                picture.set_content_fit(Gtk.ContentFit.SCALE_DOWN);

                var label = new Gtk.Label(manga.title);
                label.set_max_width_chars(25);
                label.set_ellipsize(Pango.EllipsizeMode.END);

                var gesture = new Gtk.GestureClick();
                gesture.released.connect(() => {
                    this.on_manga_clicked(manga.id);
                });
                // Container
                var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 10);
                box.add_controller(gesture);
                box.append(picture);
                box.append(label);
                try {
                    var bytes = yield api.image(manga.thumbnailUrl);
                    var texture = Gdk.Texture.from_bytes(bytes);
                    picture.set_paintable(texture);
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

    private void on_manga_clicked(int64 manga_id) {
        print("%s\n", manga_id.to_string());
    }
}