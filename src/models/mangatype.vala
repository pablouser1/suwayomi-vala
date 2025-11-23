public class MangaType : Object {
    public int64 id { get; construct; }
    public string title { get; construct; }
    public string thumbnailUrl { get; construct; }

    public MangaType (int64 id, string title, string thumbnailUrl) {
        Object (id: id, title: title, thumbnailUrl: thumbnailUrl);
    }
}