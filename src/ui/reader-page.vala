[GtkTemplate(ui = "/es/pablouser1/suwayomi/reader-page.ui")]
public class ReaderPage : Adw.NavigationPage {
    private Api api;

    private unowned Adw.NavigationView nav;
    private unowned Adw.ToastOverlay toastOverlay;

    [GtkChild]
    private unowned Adw.Carousel carousel;

    public ReaderPage(int64 manga_id, int64 chapter_id, Api api, Adw.NavigationView nav, Adw.ToastOverlay toastOverlay) {
        this.api = api;
        this.nav = nav;
        this.toastOverlay = toastOverlay;
    }
}
