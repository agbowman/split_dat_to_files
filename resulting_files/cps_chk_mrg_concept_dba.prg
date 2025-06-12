CREATE PROGRAM cps_chk_mrg_concept:dba
 SET beg_dt_tm = format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d")
 SET end_dt_tm = fillstring(21," ")
 FREE DEFINE rtl2
 DEFINE rtl2 "CPS_MRG_CONCEPT.LOG"
 RECORD err_log(
   1 qual_knt = i4
   1 qual[*]
     2 msg = vc
 )
 SET knt = 0
 SET time_dif = 0.003473
 SET true = 1
 SET false = 0
 SET continue = true
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
  SET request->setup_proc[1].error_msg = concat("FAILURE on merge of concepts ",format(cnvtdatetime(
     curdate,curtime3),"dd-mmm-yyyy hh:mm;;q"),
   "  : Could not find log file CCLUSERDIR:CPS_MRG_CONCEPT.LOG")
  GO TO exit_script
 ENDIF
 WHILE (knt >= 1
  AND continue=true)
   IF (substring(22,7,err_log->qual[knt].msg)="SUCCESS")
    SET continue = false
    IF (datetimediff(cnvtdatetime(beg_dt_tm),cnvtdatetime(substring(30,20,err_log->qual[knt].msg)))
     < time_dif)
     SET request->setup_proc[1].success_ind = 1
     SET request->setup_proc[1].error_msg = concat("SUCCESS on merge of concepts ",format(
       cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm;;q"))
     GO TO exit_script
    ENDIF
   ELSEIF (substring(22,7,err_log->qual[knt].msg)="WARNING")
    SET continue = false
    IF (datetimediff(cnvtdatetime(beg_dt_tm),cnvtdatetime(substring(30,20,err_log->qual[knt].msg)))
     < time_dif)
     SET request->setup_proc[1].success_ind = 1
     SET request->setup_proc[1].error_msg = concat("WARNING on merge of concepts see ",
      "CCLUSERDIR:CPS_MRG_CONCEPT.LOG for details ",format(cnvtdatetime(curdate,curtime3),
       "dd-mmm-yyyy hh:mm;;q"))
     GO TO exit_script
    ENDIF
   ELSEIF (substring(22,7,err_log->qual[knt].msg)="FAILURE")
    SET continue = false
    IF (datetimediff(cnvtdatetime(beg_dt_tm),cnvtdatetime(substring(30,20,err_log->qual[knt].msg)))
     < time_dif)
     SET request->setup_proc[1].success_ind = 0
     SET request->setup_proc[1].error_msg = concat("FAILURE on merge of concepts see ",
      "CCLUSERDIR:CPS_MRG_CONCEPT.LOG for details ",format(cnvtdatetime(curdate,curtime3),
       "dd-mmm-yyyy hh:mm;;q"))
     GO TO exit_script
    ENDIF
   ENDIF
   SET knt = (knt - 1)
   IF (((knt+ 3)=err_log->qual_knt))
    SET continue = false
   ENDIF
 ENDWHILE
 SET request->setup_proc[1].success_ind = 0
 SET request->setup_proc[1].error_msg = concat("FAILURE on merge of concepts see ",
  "CCLUSERDIR:CPS_MRG_CONCEPT.LOG for details ",format(cnvtdatetime(curdate,curtime3),
   "dd-mmm-yyyy hh:mm;;q"))
#exit_script
 EXECUTE dm_add_upt_setup_proc_log
END GO
