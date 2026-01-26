public class Cache {
    private string base_path;

    public Cache () {
        this.base_path = Path.build_filename (GLib.Environment.get_user_cache_dir (), Build.ID);
        this.create_folder_if_doesnt_exist ();
    }

    public async Bytes fetch (string filename) throws Error {
        var file = File.new_for_path(this.file_path(filename));
        uint8[] contents;
        yield file.load_contents_async (null, out contents, null);
        return new Bytes (contents);
    }

    public bool exists (string filename) {
        return FileUtils.test (this.file_path (filename), FileTest.IS_REGULAR);
    }

    public async void save (string filename, Bytes data) {
        var file = File.new_for_path (this.file_path (filename));
        try {
            yield file.replace_contents_bytes_async (
                data,
                null,
                false,
                FileCreateFlags.NONE,
                null,
                null
            );
        } catch (Error e) {
            stderr.printf ("Error saving file: %s\n", e.message);
        }
    }

    private string file_path(string filename) {
        return Path.build_filename (this.base_path, filename);
    }

    private void create_folder_if_doesnt_exist () {
        if (!FileUtils.test (this.base_path, FileTest.IS_DIR)) {
            DirUtils.create_with_parents (this.base_path, 0755);
        }
    }
}
