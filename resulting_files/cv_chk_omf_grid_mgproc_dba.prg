CREATE PROGRAM cv_chk_omf_grid_mgproc:dba
 SET request->setup_proc[1].success_ind = 1
 SET request->setup_proc[1].error_msg = fillstring(200," ")
 SET request->setup_proc[1].error_msg = "CV_OMF_GRID_MGPROC Successful.  Count= "
 SET v_count1 = 0
 SET v_expected_count = 2
 SELECT INTO "nl:"
  table_count = count(*)
  FROM omf_grid og,
   code_value cv
  WHERE og.grid_cd != 0
   AND og.view_cd=cv.code_value
   AND cv.display="CVPROC*"
  DETAIL
   v_count1 = table_count
  WITH nocounter
 ;end select
 IF (v_count1 < v_expected_count)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = concat("CV_OMF_GRID_CVPROC: Expected ",trim(cnvtstring(
     v_expected_count),3)," rows but found ",trim(cnvtstring(v_count1),3)," rows")
 ELSE
  SET request->setup_proc[1].error_msg = concat(trim(request->setup_proc[1].error_msg,3),trim(
    cnvtstring(v_count1),3))
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
