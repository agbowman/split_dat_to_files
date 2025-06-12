CREATE PROGRAM dm_dma
 SELECT
  *
  FROM dm_merge_audit
  WHERE (merge_id= $1)
  WITH nocounter
 ;end select
END GO
