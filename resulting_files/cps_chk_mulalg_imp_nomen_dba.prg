CREATE PROGRAM cps_chk_mulalg_imp_nomen:dba
 SET beg_dt_tm = format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d")
 SET end_dt_tm = fillstring(21," ")
 FREE DEFINE rtl2
 DEFINE rtl2 "CPS_IMP_MULALG_NOMEN.LOG"
 RECORD err_log(
   1 qual_knt = i4
   1 qual[*]
     2 msg = vc
 )
 SET knt = 0
 SET time_dif = 0.003473
 SET true = 1
 SET false = 0
 SET vocab = "MULALG"
 SET continue = true
 SET log_file_name = fillstring(24," ")
 SELECT INTO "nl:"
  err_msg = r.line
  FROM rtl2t r
  HEAD REPORT
   knt = 0, stat = alterlist(err_log->qual,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(err_log->qual,(knt+ 9))
   ENDIF
   err_log->qual[knt].msg = err_msg
  FOOT REPORT
   err_log->qual_knt = knt, stat = alterlist(err_log->qual,knt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  FREE DEFINE rtl2
  DEFINE rtl2 "CPS_IMP__NOMEN.LOG"
  SELECT INTO "nl:"
   err_msg = r.line
   FROM rtl2t r
   HEAD REPORT
    knt = 0, stat = alterlist(err_log->qual,10)
   DETAIL
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(err_log->qual,(knt+ 9))
    ENDIF
    err_log->qual[knt].msg = err_msg
   FOOT REPORT
    err_log->qual_knt = knt, stat = alterlist(err_log->qual,knt)
   WITH nocounter
  ;end select
  IF (curqual < 1)
   SET request->setup_proc[1].success_ind = 0
   SET request->setup_proc[1].error_msg = concat("FAILURE on ",vocab," Import ",format(cnvtdatetime(
      curdate,curtime3),"dd-mmm-yyyy hh:mm;;q"),"  : Could not find CCLUSERDIR:CPS_IMP_",
    vocab,"_NOMEN.LOG  look for ","CPS*NOMEN.LOG files for more information")
   GO TO exit_script
  ELSE
   SET log_file_name = "CPS_IMP__NOMEN.LOG"
  ENDIF
 ELSE
  SET log_file_name = concat("CPS_IMP_",vocab,"_NOMEN.LOG")
 ENDIF
 WHILE (knt >= 1
  AND continue=true)
   IF (substring(31,7,err_log->qual[knt].msg)="SUCCESS")
    SET continue = false
    IF (datetimediff(cnvtdatetime(beg_dt_tm),cnvtdatetime(substring(39,20,err_log->qual[knt].msg)))
     < time_dif)
     SET request->setup_proc[1].success_ind = 1
     SET request->setup_proc[1].error_msg = concat("SUCCESS on ",vocab," Import ",format(cnvtdatetime
       (curdate,curtime3),"dd-mmm-yyyy hh:mm;;q"))
     GO TO exit_script
    ENDIF
   ELSEIF (substring(31,7,err_log->qual[knt].msg)="WARNING")
    SET continue = false
    IF (datetimediff(cnvtdatetime(beg_dt_tm),cnvtdatetime(substring(39,20,err_log->qual[knt].msg)))
     < time_dif)
     SET request->setup_proc[1].success_ind = 1
     SET request->setup_proc[1].error_msg = concat("WARNING on ",vocab," Import ",format(cnvtdatetime
       (curdate,curtime3),"dd-mmm-yyyy hh:mm;;q"),"  :See log file CCLUSERDIR:",
      trim(log_file_name)," for details")
     GO TO exit_script
    ENDIF
   ELSEIF (substring(31,7,err_log->qual[knt].msg)="PREVIOU")
    SET continue = false
    IF (datetimediff(cnvtdatetime(beg_dt_tm),cnvtdatetime(substring(39,20,err_log->qual[knt].msg)))
     < time_dif)
     SET request->setup_proc[1].success_ind = 1
     SET request->setup_proc[1].error_msg = concat("ATTEMPTING to import pervious version of ",vocab,
      " ",format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm;;q"),"  :See log file CCLUSERDIR:",
      trim(log_file_name)," for details")
     GO TO exit_script
    ENDIF
   ELSEIF (substring(31,7,err_log->qual[knt].msg)="FAILURE")
    SET continue = false
    IF (datetimediff(cnvtdatetime(beg_dt_tm),cnvtdatetime(substring(39,20,err_log->qual[knt].msg)))
     < time_dif)
     SET request->setup_proc[1].success_ind = 0
     SET request->setup_proc[1].error_msg = concat("FAILURE on ",vocab," Import ",format(cnvtdatetime
       (curdate,curtime3),"dd-mmm-yyyy hh:mm;;q"),"  :See log file CCLUSERDIR:",
      trim(log_file_name)," for details")
     GO TO exit_script
    ENDIF
   ENDIF
   SET knt = (knt - 1)
   IF (((knt+ 3)=err_log->qual_knt))
    SET continue = false
   ENDIF
 ENDWHILE
 SET request->setup_proc[1].success_ind = 0
 SET request->setup_proc[1].error_msg = concat("FAILURE on ",vocab," Import ",format(cnvtdatetime(
    curdate,curtime3),"dd-mmm-yyyy hh:mm;;q"),"  :See log file CCLUSERDIR:",
  trim(log_file_name)," for details")
#exit_script
 EXECUTE dm_add_upt_setup_proc_log
END GO
