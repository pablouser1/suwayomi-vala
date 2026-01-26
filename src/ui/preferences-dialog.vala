[GtkTemplate (ui = "/es/pablouser1/suwayomi/preferences-dialog.ui")]
public class PreferencesDialog : Adw.PreferencesDialog {
    private Settings settings;

    public PreferencesDialog(Settings settings) {
        this.settings = settings;
    }
}
