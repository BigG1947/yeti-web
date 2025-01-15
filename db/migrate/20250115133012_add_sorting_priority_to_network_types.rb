class AddSortingPriorityToNetworkTypes < ActiveRecord::Migration[7.0]
  def up
    add_column :network_types, :sorting_priority, :integer, default: 999

    execute <<~SQL
WITH network_type_priorities(name, priority) AS (
    VALUES ('Landline', 10),
           ('Mobile', 20),
           ('Toll-Free', 30),
           ('Shared Cost', 40),
           ('Special Services', 50),
           ('Supplementary services', 60),
           ('Premium-rate, global telecommunication service', 70),
           ('UIFN', 80),
           ('Satellite', 90),
           ('Short Code', 100),
           ('Mobile/Paging', 110),
           ('Paging', 120),
           ('National', 130),
           ('Emergency', 140),
           ('Unknown', 150),
           ('Country Code', 160)
)
UPDATE network_types
SET sorting_priority = network_type_priorities.priority
FROM network_type_priorities
WHERE network_types.name = network_type_priorities.name
    SQL

    execute <<~SQL
UPDATE network_types
SET sorting_priority = 999
WHERE sorting_priority IS NULL
    SQL
  end

  def down
    remove_column :network_types, :sorting_priority
  end
end
