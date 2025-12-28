[GtkTemplate (ui = "/es/pablouser1/suwayomi/reader-page.ui")]
public class ReaderPage : Adw.NavigationPage {
    private Api api;

    private int64 manga_id;
    private int64 chapter_id;

    private unowned Adw.NavigationView nav;
    private unowned Adw.ToastOverlay toast_overlay;

    [GtkChild]
    private unowned Adw.Carousel carousel;

    private Gee.List<string> items = new Gee.ArrayList<string> ();
    private Gee.List<int> fetched = new Gee.ArrayList<int> ();

    public ReaderPage (
        int64 manga_id,
        int64 chapter_id,
        int64 last_page_read,
        Api api,
        Adw.NavigationView nav,
        Adw.ToastOverlay toast_overlay
    ) {
        this.manga_id = manga_id;
        this.chapter_id = chapter_id;
        this.api = api;
        this.nav = nav;
        this.toast_overlay = toast_overlay;

        this.carousel.page_changed.connect (this.on_page_changed);
        this.fetch_pages.begin (chapter_id, last_page_read);

        var controller = new Gtk.EventControllerKey ();
        controller.key_pressed.connect (this.on_key_pressed);

        this.carousel.add_controller (controller);
    }

    private async void fetch_pages (int64 chapter_id, int64 last_page_read) {
        try {
            var pages = yield this.api.pages_from_chapter (chapter_id);

            for (var i = 0; i < pages.size; i++) {
                var picture = new Gtk.Picture () {
                    vexpand = true
                };
                picture.set_content_fit (Gtk.ContentFit.CONTAIN);

                var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 10) {
                    vexpand = true,
                    hexpand = true
                };

                box.append (picture);
                this.carousel.append (box);
                if (last_page_read == i + 1) {
                    this.carousel.scroll_to (box, false);
                }
            }

            this.items = pages;
        } catch (Error e) {
            this.toast_overlay.add_toast (new Adw.Toast (e.message));
        }
    }

    private bool on_key_pressed (uint keyval, uint keycode, Gdk.ModifierType state) {
        var current_pos = (uint) this.carousel.position;
        var final_pos = current_pos;

        if (keyval == Gdk.Key.Left && current_pos > 0) {
            final_pos = current_pos - 1;
        } else if (keyval == Gdk.Key.Right && current_pos < this.items.size) {
            final_pos = current_pos + 1;
        }

        if (current_pos != final_pos) {
            var box = (Gtk.Box) this.carousel.get_nth_page (final_pos);
            this.carousel.scroll_to (box, true);
            return true;
        }

        return false;
    }

    private void on_page_changed (uint index) {
        if (index == -1 || index > this.items.size) {
            return;
        }

        if (this.fetched.contains ((int) index)) {
            return;
        }

        var box = (Gtk.Box) this.carousel.get_nth_page (index);
        this.fetch_page.begin ((int) index, (Gtk.Picture) box.get_first_child ());
    }

    private async void fetch_page (int index, Gtk.Picture picture) {
        var page = this.items.get (index);
        try {
            var bytes = yield this.api.image ("%lli-%lli-%i".printf(this.manga_id, this.chapter_id, index), page);

            var texture = Gdk.Texture.from_bytes (bytes);
            picture.set_paintable (texture);
            this.fetched.add (index);
        } catch (Error e) {
            this.toast_overlay.add_toast (new Adw.Toast (e.message));
        }
    }
}
