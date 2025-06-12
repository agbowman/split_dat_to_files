CREATE PROGRAM bbd_chk_numeric_1632:dba
 RECORD errors(
   1 err_cnt = i4
   1 err[5]
     2 err_code = i4
     2 err_msg = vc
 )
 SET active_ind = 0
 SET request->setup_proc[1].success_ind = 0
 SELECT INTO "NL:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=1632
   AND c.cdf_meaning="NUMERIC"
   AND c.active_ind=1
  DETAIL
   active_ind = c.active_ind
  WITH nocounter
 ;end select
 IF (((active_ind=0) OR (curqual=0)) )
  SET request->setup_proc[1].success_ind = 1
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
