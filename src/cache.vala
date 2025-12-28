public class Cache {
    public Cache () {
        this.create_folder_if_doesnt_exist (CacheType.IMAGES.base_path ());
        this.create_folder_if_doesnt_exist (CacheType.JSON.base_path ());
    }

    public async Bytes? fetch(CacheType type, string filename) {
        var file = File.new_for_path(Path.build_filename(type.base_path (), filename));
        try {
            uint8[] contents;
            yield file.load_contents_async(null, out contents, null);

            return new Bytes(contents);
        } catch (Error e) {
            return null;
        }
    }

    public bool exists(CacheType type, string filename) {
        return FileUtils.test (Path.build_filename(type.base_path (), filename), FileTest.IS_REGULAR);
    }

    public async void save(CacheType type, string filename, Bytes data) {
        var file = File.new_for_path(Path.build_filename(type.base_path (), filename));
        try {
            yield file.replace_contents_bytes_async(
                data,
                null,
                false,
                FileCreateFlags.NONE,
                null,
                null
            );
        } catch (Error e) {
            stderr.printf("Error saving file: %s\n", e.message);
        }
    }

    private void create_folder_if_doesnt_exist (string path) {
        if (!FileUtils.test (path, FileTest.IS_DIR)) {
            DirUtils.create_with_parents (path, 0755);
        }
    }
}
