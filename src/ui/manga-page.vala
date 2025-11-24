[GtkTemplate(ui = "/es/pablouser1/suwayomi/manga-page.ui")]
public class MangaPage : Adw.NavigationPage {
    private Api api;

    private unowned Adw.NavigationView nav;
    private unowned Adw.ToastOverlay toastOverlay;

    [GtkChild]
    private unowned Gtk.Picture thumbnail;

    [GtkChild]
    private unowned Gtk.Label titleLabel;

    [GtkChild]
    private unowned Gtk.Label descriptionLabel;

    [GtkChild]
    private unowned Gtk.ListBox chaptersBox;

    public MangaPage(int64 manga_id, Api api, Adw.NavigationView nav, Adw.ToastOverlay toastOverlay) {
        this.api = api;
        this.nav = nav;
        this.toastOverlay = toastOverlay;
        this.fetch_details.begin(manga_id);
        this.fetch_chapters.begin(manga_id);
    }

    private async void fetch_details(int64 manga_id) {
        try {
            var manga = yield this.api.manga(manga_id);

            // Image
            var bytes = yield api.image(manga.thumbnailUrl);

            var texture = Gdk.Texture.from_bytes(bytes);
            this.thumbnail.set_paintable(texture);

            // Text
            this.titleLabel.set_label(manga.title);
            this.descriptionLabel.set_label(manga.description);
            this.title = manga.title;
        } catch (Error e) {
            this.toastOverlay.add_toast(new Adw.Toast(e.message));
        }
    }

    private async void fetch_chapters(int64 manga_id) {
        try {
            var chapters = yield this.api.chapters(manga_id);

            foreach (var chapter in chapters) {
                var child = new Gtk.Label(chapter.name);
                this.chaptersBox.append(child);
            }
        } catch (Error e) {
            this.toastOverlay.add_toast(new Adw.Toast(e.message));
        }
    }
}
