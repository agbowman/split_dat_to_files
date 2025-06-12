CREATE PROGRAM dm_merge_stop_pending
 UPDATE  FROM dm_merge_action
  SET merge_status_flag = 2
  WHERE merge_status_flag IN (1, 7)
 ;end update
 COMMIT
END GO
