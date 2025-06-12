CREATE PROGRAM afc_update_phys_id:dba
 FREE DEFINE tmp_upt_tbl
 SELECT DISTINCT INTO TABLE tmp_upt_tbl
  c.order_id, c.verify_phys_id, c.perf_phys_id
  FROM charge c
  WHERE c.verify_phys_id != 0
   AND c.perf_phys_id != 0
   AND c.order_id > 0
   AND c.process_flg=0
  WITH check
 ;end select
 UPDATE  FROM charge c,
   tmp_upt_tbl ur
  SET c.verify_phys_id = ur.verify_phys_id
  PLAN (ur)
   JOIN (c
   WHERE c.verify_phys_id=0
    AND c.perf_phys_id=0
    AND c.order_id=ur.order_id
    AND c.process_flg=0)
  WITH nocounter
 ;end update
 COMMIT
 SET clean = remove("tmp_upt_tbl.dat")
END GO
