public class Tab {
    public int64 id;
    public Gtk.Box child;
    public bool fetched = false;

    public Tab (int64 id, Gtk.Box child) {
        this.id = id;
        this.child = child;
    }
}
