CREATE PROGRAM dcp_get_cp_encntr:dba
 SET orig_encntr_cnt = size(cp_encntr->encntr_list,5)
 SELECT DISTINCT INTO "nl:"
  dfa.encntr_id
  FROM dcp_forms_activity dfa,
   dcp_forms_ref dfr
  PLAN (dfa
   WHERE dfa.last_activity_dt_tm >= cnvtdatetime(last_dist_run_dt_tm))
   JOIN (dfr
   WHERE dfr.event_set_name > " ")
  HEAD REPORT
   encntr_cnt = 0
  HEAD dfa.encntr_id
   encntr_cnt = (encntr_cnt+ 1)
   IF (mod(encntr_cnt,50)=1)
    stat = alterlist(cp_encntr->encntr_list,((orig_encntr_cnt+ encntr_cnt)+ 50))
   ENDIF
   cp_encntr->encntr_list[(orig_encntr_cnt+ encntr_cnt)].encntr_id = dfa.encntr_id
  FOOT REPORT
   stat = alterlist(cp_encntr->encntr_list,(orig_encntr_cnt+ encntr_cnt))
  WITH nocounter
 ;end select
END GO
