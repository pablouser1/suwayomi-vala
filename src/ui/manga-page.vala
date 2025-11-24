[GtkTemplate(ui = "/es/pablouser1/suwayomi/manga-page.ui")]
public class MangaPage: Adw.NavigationPage {
    private Api api;

    private unowned Adw.NavigationView nav;
    private unowned Adw.ToastOverlay toastOverlay;

    [GtkChild]
    private unowned Gtk.Picture thumbnail;

    [GtkChild]
    private unowned Gtk.Label titleLabel;

    public MangaPage(int64 manga_id, Api api, Adw.NavigationView nav, Adw.ToastOverlay toastOverlay) {
        this.api = api;
        this.nav = nav;
        this.toastOverlay = toastOverlay;
        this.build_page.begin(manga_id);
    }

    private async void build_page(int64 manga_id) {
        try {
            var manga = yield this.api.manga(manga_id);

            // Image
            var bytes = yield api.image(manga.thumbnailUrl);
            var texture = Gdk.Texture.from_bytes(bytes);
            this.thumbnail.set_paintable(texture);

            // Title
            this.titleLabel.set_label(manga.title);
            this.title = manga.title;
        } catch (Error e) {
            this.toastOverlay.add_toast(new Adw.Toast(e.message));
        }
    }
}
