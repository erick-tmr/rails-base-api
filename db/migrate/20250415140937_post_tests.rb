class PostTests < ActiveRecord::Migration[8.0]
  def change
    create_table :post_tests do |t|
      t.text :text
      t.jsonb :json_response, default: {}

      t.timestamps
    end
  end
end
