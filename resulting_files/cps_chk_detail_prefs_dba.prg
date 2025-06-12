CREATE PROGRAM cps_chk_detail_prefs:dba
 SET false = 0
 SET true = 1
 SET failed = true
 SELECT INTO "nl:"
  dp.seq
  FROM detail_prefs dp
  PLAN (dp
   WHERE dp.application_number=961000
    AND dp.position_cd=0
    AND dp.prsnl_id=0
    AND dp.person_id=0
    AND dp.view_name="FLOWSHEET"
    AND dp.view_seq=1
    AND dp.comp_name="FLOWSHEET"
    AND dp.comp_seq=1)
  WITH nocounter, maxqual(dp,1)
 ;end select
 IF (curqual > 0)
  SET failed = false
 ENDIF
 IF (failed=false)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = concat("SUCCESS : setting ProVide Flowsheet pref >",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = concat("FAILURE : setting ProVide Flowsheet pref >",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
