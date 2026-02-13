class BackfillExistingAudiencesScope < ActiveRecord::Migration[8.1]
  def up
    execute <<-SQL
      UPDATE audiences SET scope_type = 'system' WHERE created_by_id IS NULL
    SQL
  end

  def down
    # no-op: cannot reliably reverse backfill
  end
end
