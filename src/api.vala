public class Api {
    private Soup.Session session = new Soup.Session();
    private string baseUrl;
    private string? username;
    private string? password;

    public Api(string baseUrl, string? username, string? password) {
        this.baseUrl = baseUrl;
        this.username = username;
        this.password = password;
    }

    public async Gee.List<CategoryType> categories() throws Error {
        var categories_query = @"
        query AllCategories {
          categories(orderBy: ORDER, condition: {
            default: false
          }) {
            nodes {
              id
              name
            }
          }
        }
        ";

        var root_node = yield this.graphql(categories_query);

        var data = this.data_from_res(root_node);

        var categories_obj = data.get_object_member("categories");
        var nodes_array = categories_obj.get_array_member("nodes");

        // Get categories
        Gee.List<CategoryType> category_list = new Gee.ArrayList<CategoryType> ();
        for (int i = 0; i < nodes_array.get_length(); i++) {
            Json.Object category_obj = nodes_array.get_element(i).get_object();

            var id = category_obj.get_int_member("id");
            var name = category_obj.get_string_member("name");

            // Create the new CategoryType using the corrected constructor
            CategoryType category = new CategoryType(id, name);

            // GLib.List requires reassignment when appending
            category_list.add(category);
        }

        return category_list;
    }

    public async Gee.List<MangaType> mangas_from_category(int64 category_id) throws Error {
        var mangas_query = @"
        query MangasFromCategories($$condition: MangaConditionInput) {
          mangas(condition: $$condition) {
            nodes {
              id
              title
              thumbnailUrl
            }
          }
        }
        ";

        var ids = new Json.Array();
        ids.add_int_element(category_id);
        var condition = new Json.Object();
        condition.set_boolean_member("inLibrary", true);
        condition.set_array_member("categoryIds", ids);

        var variables = new Json.Object();
        variables.set_object_member("condition", condition);

        var root_node = yield this.graphql(mangas_query, variables);
        var data = this.data_from_res(root_node);

        var mangas_obj = data.get_object_member("mangas");
        var nodes_array = mangas_obj.get_array_member("nodes");

        // Get mangas
        Gee.List<MangaType> manga_list = new Gee.ArrayList<MangaType> ();
        for (int i = 0; i < nodes_array.get_length(); i++) {
            Json.Object category_obj = nodes_array.get_element(i).get_object();

            var id = category_obj.get_int_member("id");
            var title = category_obj.get_string_member("title");
            var thumbnailUrl = category_obj.get_string_member("thumbnailUrl");

            // Create the new CategoryType using the corrected constructor
            var manga = new MangaType(id, title, thumbnailUrl);

            // GLib.List requires reassignment when appending
            manga_list.add(manga);
        }

        return manga_list;
    }

    private async Json.Node graphql(string query, Json.Object? variables = null) throws Error {
        // Build final JSON
        Json.Builder builder = new Json.Builder();
        builder.begin_object();
        builder.set_member_name("query");
        builder.add_string_value(query);

        if (variables != null) {
            builder.set_member_name("variables");
            var variables_node = new Json.Node(Json.NodeType.OBJECT);
            variables_node.set_object(variables);
            builder.add_value(variables_node);
        }

        builder.end_object();

        // Get body string
        Json.Generator generator = new Json.Generator();
        Json.Node root = builder.get_root();
        generator.set_root(root);
        string body = generator.to_data(null);

        // Send request
        var message = new Soup.Message("POST", this.baseUrl + "/api/graphql");

        // Handle auth
        if (this.username != null && this.password != null) {
            string auth_header = this.encode_basic_auth(this.username, this.password);
            message.request_headers.append("Authorization", auth_header);
        }

        message.set_request_body_from_bytes("application/json", new Bytes.take(body.data));
        Bytes? bytes = yield this.session.send_and_read_async(message, 0, null);

        if (message.get_status() != Soup.Status.OK) {
            throw new Error(Soup.SessionError.quark(), 1, "HTTP Error %u: %s",
                            message.get_status(), message.get_reason_phrase());
        }

        if (bytes == null) {
            throw new Error(Quark.from_string("Could not get data"), 0, "Body error");
        }

        // Decode response
        uint8[] data = bytes.get_data();
        string response_data = (string) data;

        Json.Parser response_parser = new Json.Parser();
        try {
            response_parser.load_from_data(response_data, bytes.length);
        } catch (Error e) {
            throw new Error(Quark.from_string("JSON parse error"), 0, "Failed to parse GraphQL response: %s", e.message);
        }

        return response_parser.get_root();
    }

    public async Bytes image(string path) throws Error {
        var message = new Soup.Message("GET", this.baseUrl + path);
        // Handle auth
        if (this.username != null && this.password != null) {
            string auth_header = this.encode_basic_auth(this.username, this.password);
            message.request_headers.append("Authorization", auth_header);
        }

        Bytes? bytes = yield this.session.send_and_read_async(message, 0, null);

        if (message.get_status() != Soup.Status.OK) {
            throw new Error(Soup.SessionError.quark(), 1, "HTTP Error %u: %s",
                            message.get_status(), message.get_reason_phrase());
        }

        if (bytes == null) {
            throw new Error(Quark.from_string("Could not get data"), 0, "Body error");
        }

        return bytes;
    }

    private Json.Object data_from_res(Json.Node root) throws Error {
        Json.Object root_obj = root.get_object();
        if (!root_obj.has_member("data") || root_obj.get_member("data").get_node_type() != Json.NodeType.OBJECT) {
            // Handle case where response has errors or unexpected structure
            throw new Error(Quark.from_string("GraphQL error"), 0, "GraphQL response missing 'data' object.");
        }
        return root_obj.get_object_member("data");
    }

    private string encode_basic_auth(string user, string pass) {
        string credentials = user + ":" + pass;
        Bytes credentials_bytes = new Bytes.take(credentials.data);
        string encoded_credentials = Base64.encode(credentials_bytes.get_data());
        return "Basic " + encoded_credentials;
    }
}
