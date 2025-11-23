public class Tab {
    public int64 id;
    public Gtk.FlowBox child;
    public bool fetched = false;

    public Tab (int64 id, Gtk.FlowBox child) {
        this.id = id;
        this.child = child;
    }
}
