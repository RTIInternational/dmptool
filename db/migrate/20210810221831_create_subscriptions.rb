class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.references  :plan, index: true
      t.integer     :subscription_type, null: false
      t.string      :callback_uri
      t.date        :last_notified, index: true
      t.bigint      :identifiable_id
      t.string      :identifiable_type
      t.timestamps

      t.index [:identifiable_id, :identifiable_type, :plan_id],
              name: "index_subscribers_on_identifiable_and_plan_id"
    end
  end
end
