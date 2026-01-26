[GtkTemplate (ui = "/es/pablouser1/suwayomi/preferences-dialog.ui")]
public class PreferencesDialog : Adw.PreferencesDialog {
    private Settings settings;

    [GtkChild]
    private unowned Adw.EntryRow url_input;

    [GtkChild]
    private unowned Adw.ComboRow mode_input;

    [GtkChild]
    private unowned Adw.EntryRow username_input;

    [GtkChild]
    private unowned Adw.PasswordEntryRow password_input;

    public PreferencesDialog(Settings settings) {
        this.settings = settings;

        this.set_input_values ();
        this.set_input_listeners ();
    }

    private void set_input_values() {
        this.url_input.set_text (this.settings.get_string ("url"));
        this.mode_input.set_selected (1); // TODO: Make enum
        this.username_input.set_text (this.settings.get_string ("username"));
        this.password_input.set_text (this.settings.get_string ("password"));
    }

    private void set_input_listeners() {
        this.url_input.changed.connect((editable) => {
            this.set_input_value("url", editable);
        });

        this.username_input.changed.connect((editable) => {
            this.set_input_value("username", editable);
        });

        this.password_input.changed.connect((editable) => {
            this.set_input_value("password", editable);
        });
    }

    private void set_input_value(string key, Gtk.Editable editable) {
        this.settings.set_string(key, editable.get_text());
    }
}
