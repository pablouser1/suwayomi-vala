public class App : Adw.Application {
    public MainWindow main_window;
    public Settings settings;
    public Api api;

    private static App _instance;
    public static App instance {
        get {
            if (_instance == null)
                _instance = new App ();

            return _instance;
        }
    }

    construct {
        application_id = Build.ID;
        flags = ApplicationFlags.DEFAULT_FLAGS;
    }

    public override void activate () {
        if (main_window != null) {
            main_window.present ();
            return;
        }

        // Actions
        var about_action = new SimpleAction("about", null);
        about_action.activate.connect (this.on_about_activated);
        this.add_action (about_action);

        this.settings = new Settings (Build.ID);
        var base_url = settings.get_string ("url");
        var username = this.get_optional_string ("username");
        var password = this.get_optional_string ("password");

        this.api = new Api (base_url, username, password);

        main_window = new MainWindow (this);
        main_window.present ();
        main_window.maximize ();
    }

    public static int main (string[] args) {
        Intl.setlocale ();
        var app = App.instance;
        return app.run (args);
    }

    private string ? get_optional_string (string key) {
        string value = this.settings.get_string (key);
        return value == "" ? null : value;
    }

    private void on_about_activated (SimpleAction action, Variant? parameter) {
        var about = new Adw.AboutDialog () {
            // Basic Metadata
            application_name = "Suwayomi Vala",
            application_icon = Build.ID,
            version = Build.VERSION,
            
            // Links
            website = "https://github.com/pablouser1/suwaoymi-vala",
            issue_url = "https://github.com/pablouser1/suwaoymi-vala/issues",
            
            // Legal & Credits
            license_type = Gtk.License.GPL_3_0,
        };

        about.present (main_window);
    }
}
