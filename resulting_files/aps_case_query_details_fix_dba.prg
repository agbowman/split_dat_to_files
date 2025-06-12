CREATE PROGRAM aps_case_query_details_fix:dba
 UPDATE  FROM ap_case_query_details acqd
  SET acqd.query_detail_id = cnvtreal(seq(pathnet_seq,nextval)), acqd.updt_dt_tm = cnvtdatetime(
    curdate,curtime3), acqd.updt_id = 999999,
   acqd.updt_task = 999999, acqd.updt_cnt = (acqd.updt_cnt+ 1), acqd.updt_applctx = 999999
  PLAN (acqd
   WHERE acqd.query_detail_id IN (0, null)
    AND acqd.param_name > " ")
  WITH nocounter
 ;end update
 COMMIT
END GO
