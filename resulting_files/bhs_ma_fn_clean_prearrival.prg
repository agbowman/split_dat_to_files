CREATE PROGRAM bhs_ma_fn_clean_prearrival
 UPDATE  FROM tracking_prearrival
  SET active_ind = 0
  WHERE attached_encntr_id=0
   AND estimated_arrive_dt_tm <= cnvtlookbehind("24,H",cnvtdatetime(curdate,curtime3))
   AND active_ind=1
  WITH nocounter
 ;end update
 COMMIT
END GO
