CREATE PROGRAM dma_sel_desc
 SELECT
  *
  FROM dm_merge_audit
  ORDER BY merge_dt_tm DESC
  WITH counter
 ;end select
END GO
