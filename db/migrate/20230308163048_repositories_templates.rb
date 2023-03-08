class RepositoriesTemplates < ActiveRecord::Migration[6.1]
  def change
    create_table :repositories_templates, :id => false do |t|
      t.references :template_id
      t.references :repository_id

      t.timestamps
    end
    add_foreign_key :repositories_templates, :templates, column: :template_id
    add_foreign_key :repositories_templates, :repositories, column: :repository_id
  end
end
