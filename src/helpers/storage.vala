public class Storage {
    public static string build_cache_folder () {
        return Path.build_filename (GLib.Environment.get_user_cache_dir (), Build.ID);
    }

    public static string build_data_folder () {
        return Path.build_filename (GLib.Environment.get_user_data_dir (), Build.ID);
    }

    public static void create_folder_if_doesnt_exist (string path) {
        if (!FileUtils.test (path, FileTest.IS_DIR)) {
            DirUtils.create_with_parents (path, 0755);
        }
    }
}
