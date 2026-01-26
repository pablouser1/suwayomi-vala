[GtkTemplate (ui = "/es/pablouser1/suwayomi/manga-page.ui")]
public class MangaPage : Adw.NavigationPage {
    private DataFetch data_fetch;

    private unowned Adw.NavigationView nav;
    private unowned Adw.ToastOverlay toast_overlay;

    [GtkChild]
    private unowned Gtk.Picture thumbnail;

    [GtkChild]
    private unowned Gtk.Label title_label;

    [GtkChild]
    private unowned Gtk.Label description_label;

    [GtkChild]
    private unowned Gtk.ListBox chapters_box;

    public MangaPage (int64 manga_id, DataFetch data_fetch, Adw.NavigationView nav, Adw.ToastOverlay toast_overlay) {
        this.data_fetch = data_fetch;
        this.nav = nav;
        this.toast_overlay = toast_overlay;
        this.fetch_details.begin (manga_id);
        this.fetch_chapters.begin (manga_id);
    }

    private async void fetch_details (int64 manga_id) {
        try {
            var manga = yield this.data_fetch.manga (manga_id);

            // Image
            var bytes = yield this.data_fetch.image (manga.id.to_string (), manga.thumbnail_url);

            var texture = Gdk.Texture.from_bytes (bytes);
            this.thumbnail.set_paintable (texture);

            // Text
            this.title_label.set_label (manga.title);
            this.description_label.set_label (manga.description);
            this.title = manga.title;
        } catch (Error e) {
            this.toast_overlay.add_toast (new Adw.Toast (e.message));
        }
    }

    private async void fetch_chapters (int64 manga_id) {
        try {
            var chapters = yield this.data_fetch.chapters (manga_id);

            foreach (var chapter in chapters) {
                var child = new Adw.ActionRow ();
                child.set_title (Markup.escape_text (chapter.name, chapter.name.length));
                child.set_subtitle (Markup.escape_text (chapter.scanlator, chapter.scanlator.length));
                if (chapter.is_read) {
                    var check_icon = new Gtk.Image.from_icon_name ("object-select-symbolic");
                    child.add_suffix (check_icon);
                }

                child.set_activatable (true);
                child.activated.connect (() => {
                    this.on_chapter_clicked (manga_id, chapter.id, chapter.last_page_read);
                });

                this.chapters_box.append (child);
            }
        } catch (Error e) {
            this.toast_overlay.add_toast (new Adw.Toast (e.message));
        }
    }

    private void on_chapter_clicked (int64 manga_id, int64 chapter_id, int64 last_page_read) {
        var page = new ReaderPage (manga_id, chapter_id, last_page_read, this.data_fetch, this.nav, this.toast_overlay);
        this.nav.push (page);
    }
}
