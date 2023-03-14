class CreateRepositoriesTemplates < ActiveRecord::Migration[6.1]
  def change
    create_table :repositories_templates, :id => false do |t|
      t.integer :templates_id, index: true, foreign_key: true
      t.integer :repositories_id, index: true, foreign_key: true

      t.timestamps
    end
 end

  def down
    drop_table :repositories_templates
  end
end
