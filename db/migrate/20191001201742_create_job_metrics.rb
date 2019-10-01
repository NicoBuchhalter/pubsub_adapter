class CreateJobMetrics < ActiveRecord::Migration[6.0]
  def change
    create_table :job_metrics do |t|
      t.integer :total_count, limit: 8
      t.float :total_duration

      t.timestamps
    end
    JobMetric.create!(total_count: 0, total_duration: 0)
  end
end
