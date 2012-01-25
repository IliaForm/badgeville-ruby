describe BadgevilleBerlinJsonFormat, ".decode" do

  it "should convert a string into a hash" do
    BadgevilleBerlinJsonFormat.decode('{}').should == {}
  end

  it "should handle nils" do
    BadgevilleBerlinJsonFormat.decode(nil).should == nil
  end

  #   it "should raise TypeError when JSON string is nil" do
  #     lambda{ @decoded_json = BadgevilleBerlinJsonFormat.decode( @nil_string ) }.should raise_error(TypeError)
  #   end

  context "with a single object" do
    before do
      @json_record_w_root =
        "{\"data\":{\"name\":\"visitor_username\",\"created_at\":\"2012-01-05T10:43:42-08:00\",\"email\":\"revised_visitor@emailserver.com\",\"_id\":\"4f05ef5ea768651b3500009f\"},\"paging\":null}"
      @json_record_without_root =
        "{\"name\":\"visitor_username\",\"created_at\":\"2012-01-05T10:43:42-08:00\",\"email\":\"revised_visitor@emailserver.com\",\"_id\":\"4f05ef5ea768651b3500009f\"}"
      @json_w_2_keys_data =
        "{\"data\":{\"name\":\"visitor_username\",\"data\":\"value_of_nested_key_data\"},\"paging\":null}"
    end

    it "should handle it" do
      BadgevilleBerlinJsonFormat.decode(@json_record_w_root).should ==
        {"name"=>"visitor_username", "created_at"=>"2012-01-05T10:43:42-08:00", "email"=>"revised_visitor@emailserver.com", "_id"=>"4f05ef5ea768651b3500009f"}
    end

    it "should handle when there's a nested key 'data'" do
        BadgevilleBerlinJsonFormat.decode(@json_w_2_keys_data).should == {"name"=>"visitor_username", "data" => "value_of_nested_key_data"}
    end

    it "should handle when there's no root key 'data'" do
      BadgevilleBerlinJsonFormat.decode(@json_record_without_root).should ==
        {"name"=>"visitor_username", "created_at"=>"2012-01-05T10:43:42-08:00", "email"=>"revised_visitor@emailserver.com", "_id"=>"4f05ef5ea768651b3500009f"}
    end

  end

  context "with multiple objects" do
    before do
      @json_collection_w_root =
        '{"data":[{"name":"visitor1","_id":"4dfa6cbc888bae20b0000016"},{"name":"visitor2","_id":"4dfa8908888bae20b50000d1"}],"paging":{"current_page":1,"per_page":10}}'
      @json_collection_without_root =
        '[{"name":"visitor1","_id":"4dfa6cbc888bae20b0000016"},{"name":"visitor2","_id":"4dfa8908888bae20b50000d1"}]'
    end

    it "should handle it" do
      BadgevilleBerlinJsonFormat.decode(@json_collection_w_root).should ==
        [ {"name" => "visitor1", "_id" => "4dfa6cbc888bae20b0000016"},
          {"name" => "visitor2", "_id" => "4dfa8908888bae20b50000d1"} ]
    end

    it "should handle when there's no root key 'data'" do
      BadgevilleBerlinJsonFormat.decode(@json_collection_without_root).should ==
        [ {"name" => "visitor1", "_id" => "4dfa6cbc888bae20b0000016"},
          {"name" => "visitor2", "_id" => "4dfa8908888bae20b50000d1"} ]
    end
  end
end

