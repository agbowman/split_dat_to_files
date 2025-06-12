CREATE PROGRAM dm_merge_show_max
 SELECT
  *
  FROM dm_merge_audit
  WHERE (merge_id=
  (SELECT
   max(merge_id)
   FROM dm_merge_audit))
  ORDER BY merge_dt_tm
 ;end select
END GO
