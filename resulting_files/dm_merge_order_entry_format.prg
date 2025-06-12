CREATE PROGRAM dm_merge_order_entry_format
 DELETE  FROM dm_merge_oe_format
  WHERE 1=1
 ;end delete
 COMMIT
 INSERT  FROM dm_merge_oe_format
  (oe_format_id, oe_format_name)(SELECT DISTINCT
   oe.oe_format_id, oe.oe_format_name
   FROM order_entry_format oe)
 ;end insert
END GO
