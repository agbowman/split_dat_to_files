CREATE PROGRAM dm_merge_id:dba
 SELECT
  *
  FROM dm_merge_audit
  WHERE (merge_id= $1)
  ORDER BY merge_dt_tm, sequence
 ;end select
END GO
