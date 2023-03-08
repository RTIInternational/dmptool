class RepositoriesTemplates < ActiveRecord::Migration[6.1]
  def change
    create_table :repositories_templates, :id => false do |t|
      t.references :templates, index: true, foreign_key: true
      t.references :repositories, index: true, foreign_key: true

      t.timestamps
    end
  end
  
  def down
    drop_table :repositories_templates
  end
end
