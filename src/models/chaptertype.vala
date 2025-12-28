public class ChapterType {
    public int64 id;
    public string name;
    public bool is_read;
    public int64 last_page_read;
    public string scanlator;
    public DateTime upload_date;

    public ChapterType (
        int64 id,
        string name,
        bool is_read,
        int64 last_page_read,
        string scanlator,
        string upload_date
    ) {
        this.id = id;
        this.name = name;
        this.is_read = is_read;
        this.last_page_read = last_page_read;
        this.scanlator = scanlator;
        this.upload_date = new DateTime.from_unix_local (int.parse (upload_date));
    }
}
