CREATE PROGRAM dm_merge_charting_operations
 DELETE  FROM dm_merge_charting_ops
  WHERE 1=1
 ;end delete
 COMMIT
 INSERT  FROM dm_merge_charting_ops
  (charting_operations_id, batch_name)(SELECT DISTINCT
   co.charting_operations_id, co.batch_name
   FROM charting_operations co)
 ;end insert
 COMMIT
END GO
