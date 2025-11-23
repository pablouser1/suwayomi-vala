public class App : Adw.Application {
    public MainWindow main_window;

    private static App _instance;
    public static App instance {
        get {
            if (_instance == null)
                _instance = new App();

            return _instance;
        }
    }

    construct {
        application_id = Build.ID;
        flags = ApplicationFlags.DEFAULT_FLAGS;
    }

    public override void activate() {
        if (main_window != null) {
            main_window.present();
            return;
        }

        main_window = new MainWindow(this);

        main_window.present();
    }

    public static int main(string[] args) {
        var app = App.instance;
        return app.run(args);
    }
}
