public class LocalDb {
    private Sqlite.Database conn;

    public LocalDb () {
        var file = File.new_build_filename (Storage.build_data_folder (), "suwayomi.db");
        var exists = file.query_exists ();

        Sqlite.Database.open (file.get_path (), out this.conn);

        if (!exists) {
            this.create ();
        }
    }

    public Gee.List<CategoryType> get_categories () throws Error {
        string query = "SELECT * FROM categories";
        int ec;
        Sqlite.Statement stmt;

        ec = this.conn.prepare_v2 (query, query.length, out stmt);
        if (ec != Sqlite.OK) {
            throw new Error (Quark.from_string ("Could not get categories"), 0, "Db error");
        }

        var data = new Gee.ArrayList<CategoryType> ();
        while (stmt.step () == Sqlite.ROW) {
            data.add (new CategoryType (stmt.column_int64 (0), stmt.column_text (1)));
        }

        return data;
    }

    public void save_categories (Gee.List<CategoryType> data) throws Error {
        string query = "INSERT INTO categories (id, name) VALUES ($ID, $NAME)";
        int ec;
        Sqlite.Statement stmt;

        ec = this.conn.prepare_v2 (query, query.length, out stmt);
        if (ec != Sqlite.OK) {
            throw new Error (Quark.from_string ("Could save categories"), this.conn.errcode(  ), this.conn.errmsg(  ));
        }

        int id_pos = stmt.bind_parameter_index ("$ID");
        int name_pos = stmt.bind_parameter_index ("$NAME");

        this.conn.exec ("BEGIN TRANSACTION");
        foreach (var category in data) {
            stmt.bind_int64 (id_pos, category.id);
            stmt.bind_text (name_pos, category.name);

            if (stmt.step () != Sqlite.DONE) {
                throw new Error (Quark.from_string ("Could save categories"), this.conn.errcode(  ), this.conn.errmsg(  ));
            }

            stmt.reset ();
        }

        this.conn.exec ("COMMIT");
    }

    private void create () {
        string query = """
        CREATE TABLE categories (
            id		INT		PRIMARY KEY		NOT NULL,
            name	TEXT					NOT NULL
        );
        """;

        this.conn.exec (query);
    }
}
