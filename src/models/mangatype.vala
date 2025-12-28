public class MangaType : MangaTypeBasic {
    public string description;

    public MangaType (int64 id, string title, string description, string thumbnail_url) {
        base (id, title, thumbnail_url);

        this.description = description;
    }
}
