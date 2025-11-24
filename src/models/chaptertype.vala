public class ChapterType {
    public int64 id;
    public string name;
    public bool isRead;
    public int64 lastPageRead;
    public string scanlator;
    public DateTime uploadDate;

    public ChapterType (int64 id, string name, bool isRead, int64 lastPageRead, string scanlator, string uploadDate) {
        this.id = id;
        this.name = name;
        this.isRead = isRead;
        this.lastPageRead = lastPageRead;
        this.scanlator = scanlator;
        this.uploadDate = new DateTime.from_unix_local (int.parse (uploadDate));
    }
}
