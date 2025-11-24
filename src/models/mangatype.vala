public class MangaType : MangaTypeBasic {
    public string description;

    public MangaType (int64 id, string title, string description, string thumbnailUrl) {
        base (id, title, thumbnailUrl);

        this.description = description;
    }
}
