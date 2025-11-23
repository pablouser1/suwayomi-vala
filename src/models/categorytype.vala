public class CategoryType: Object {
    public int64 id { get; construct; }
    public string name { get; construct; }

    public CategoryType(int64 id, string name) {
        Object( id: id, name: name );
    }
}
