public enum CacheType {
    JSON,
    IMAGES;

    public string base_path () {
        var cache_path = Path.build_filename (GLib.Environment.get_user_cache_dir (), Build.ID);
        return Path.build_filename (cache_path, this.to_string ());
    }

    public string to_string () {
        switch (this) {
        case JSON: return "json";
        case IMAGES: return "images";
        default: return "";
        }
    }
}
