public class DataFetch {
    private Api api;
    private Cache cache = new Cache();
    private Db db = new Db();

    public DataFetch(string base_url, string? username, string? password) {
        this.api = new Api(base_url, username, password);
    }

    public async Gee.List<CategoryType> categories () throws Error {
        return yield api.categories();
    }

    public async Gee.List<MangaTypeBasic> mangas_from_category (int64 category_id) throws Error {
        return yield api.mangas_from_category (category_id);
    }

    public async MangaType manga (int64 manga_id) throws Error {
        return yield api.manga (manga_id);
    }

    public async Gee.List<ChapterType> chapters (int64 manga_id) throws Error {
        return yield api.chapters (manga_id);
    }

    public async Gee.List<string> pages_from_chapter (int64 chapter_id) throws Error {
        return yield api.pages_from_chapter (chapter_id);
    }

    public async Bytes image (string id, string path) throws Error {
        Bytes? bytes;

        var cached = cache.exists (id);

        if (cached) {
            bytes = yield cache.fetch (id);
        } else {
            bytes = yield api.image (path);
            cache.save.begin (id, bytes);
        }

        return bytes;
    }
}
