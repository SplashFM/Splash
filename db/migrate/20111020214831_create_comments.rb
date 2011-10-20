class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :author_id
      t.integer :splash_id
      t.string :body

      t.timestamps
    end

    add_index :comments, :author_id
    add_index :comments, :splash_id
  end

  def self.down
    remove_index :comments, :author_id
    remove_index :comments, :splash_id

    drop_table :comments
  end
end
