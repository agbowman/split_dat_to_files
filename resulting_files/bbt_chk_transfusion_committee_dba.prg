CREATE PROGRAM bbt_chk_transfusion_committee:dba
 RECORD errors(
   1 err_cnt = i4
   1 err[5]
     2 err_code = i4
     2 err_msg = vc
 )
 RECORD internal(
   1 transfusion_committee[*]
     2 product_cd = f8
     2 trans_commit_id = f8
     2 single_trans_ind = i2
     2 single_pre_hours = i4
     2 single_post_hours = i4
     2 active_ind = i2
     2 active_status_cd = f8
 )
 SET tc_cnt = 0
 SET tc_cnt_chk = 0
 SET tc = 0
 SET tc_success_ind = "N"
 SET request->setup_proc[1].success_ind = 0
 SET request->setup_proc[1].error_msg = ""
 SELECT INTO "nl:"
  tc.product_cd, tc.trans_commit_id, tc.single_trans_ind,
  tc.single_pre_hours, tc.single_post_hours, tc.active_ind
  FROM transfusion_committee tc
  ORDER BY tc.trans_commit_id
  HEAD REPORT
   tc_success_ind = "N", tc_active_ind = 0, tc_cnt = 0,
   stat = alterlist(internal->transfusion_committee,10)
  HEAD tc.trans_commit_id
   tc_cnt = (tc_cnt+ 1)
   IF (mod(tc_cnt,10)=1
    AND tc_cnt != 1)
    stat = alterlist(internal->transfusion_committee,(tc_cnt+ 9))
   ENDIF
   internal->transfusion_committee[tc_cnt].product_cd = tc.product_cd, internal->
   transfusion_committee[tc_cnt].trans_commit_id = tc.trans_commit_id, internal->
   transfusion_committee[tc_cnt].single_trans_ind = tc.single_trans_ind,
   internal->transfusion_committee[tc_cnt].single_pre_hours = tc.single_pre_hours, internal->
   transfusion_committee[tc_cnt].single_post_hours = tc.single_post_hours
  FOOT REPORT
   stat = alterlist(internal->transfusion_committee,tc_cnt), tc_success_ind = "Y"
  WITH nocounter, nullreport
 ;end select
 IF (((curqual=0) OR (tc_success_ind != "Y")) )
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "SCRIPT ERROR:  transfusion_committee select failed."
  GO TO exit_script
 ELSEIF (tc_cnt=0)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "No rows found on transfusion_committee table."
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  tca.trans_commit_assay_id, tca.trans_commit_id, tca.task_assay_cd,
  tca.pre_hours, tca.post_hours, tca.all_results_ind
  FROM trans_commit_assay tca
  ORDER BY tca.trans_commit_id, tca.trans_commit_assay_id
  HEAD tca.trans_commit_id
   tc = 0, tc_found_fg = "N"
   FOR (tc = 1 TO tc_cnt)
     IF ((internal->transfusion_committee[tc].trans_commit_id=tca.trans_commit_id))
      tc_cnt_chk = (tc_cnt_chk+ 1), tc = tc_cnt
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "No rows found on transfusion_committee table (includeing no '0' row)"
  GO TO exit_script
 ELSEIF (tc_cnt_chk != tc_cnt)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "Extra or missing rows on trans_commit_assay"
  GO TO exit_script
 ELSEIF (tc_cnt_chk=tc_cnt)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "SUCCESS"
  GO TO exit_script
 ENDIF
#exit_script
 EXECUTE dm_add_upt_setup_proc_log
 CALL echo(build("tc_cnt      = ",tc_cnt))
 CALL echo(build("tc_cnt_chk  = ",tc_cnt_chk))
 CALL echo("     ")
 CALL echo(build("success_ind = ",request->setup_proc[1].success_ind))
 CALL echo(build("error_msg   = ",request->setup_proc[1].error_msg))
END GO
