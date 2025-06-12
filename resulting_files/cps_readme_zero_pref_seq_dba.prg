CREATE PROGRAM cps_readme_zero_pref_seq:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 FREE SET err_log
 RECORD err_log(
   1 msg_qual = i4
   1 msg[*]
     2 err_msg = vc
 )
 FREE RECORD hold
 RECORD hold(
   1 qual_knt = i4
   1 qual[*]
     2 detail_prefs_id = f8
     2 prsnl_id = f8
     2 position_cd = f8
     2 app_nbr = i4
     2 view_name = vc
     2 view_seq = i4
     2 comp_name = vc
     2 comp_seq = i4
 )
 SET dvar = 0
 SET log_file = "CPS_README_ZERO_PREF_SEQ.LOG"
 SET msg_knt = 0
 SET error_level = 0
 SET status_msg = fillstring(7," ")
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("CPS_README_ZERO_PREF_SEQ BEG : ",format(cnvtdatetime(
    curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 FREE RECORD detail_list
 RECORD detail_list(
   1 qual_knt = i4
   1 qual[*]
     2 prsnl_id = f8
     2 position_cd = f8
     2 application_number = i4
     2 view_name = vc
     2 comp_name = vc
     2 detail_prefs_id = f8
 )
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM detail_prefs dp,
   dummyt d,
   detail_prefs dp2
  PLAN (dp
   WHERE dp.view_name IN ("CLINNOTES", "MPTASKLIST", "PTLIST", "FLOWSHEET", "TASKLIST",
   "FormBrowser", "ORDERPOE")
    AND dp.view_seq=1
    AND dp.application_number=961000)
   JOIN (d)
   JOIN (dp2
   WHERE dp2.prsnl_id=dp.prsnl_id
    AND dp2.position_cd=dp.position_cd
    AND dp2.application_number=dp.application_number
    AND dp2.view_name=dp.view_name
    AND dp2.view_seq=0)
  HEAD REPORT
   knt = 0, stat = alterlist(detail_list->qual,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(detail_list->qual,(knt+ 9))
   ENDIF
   detail_list->qual[knt].detail_prefs_id = dp.detail_prefs_id, detail_list->qual[knt].prsnl_id = dp
   .prsnl_id, detail_list->qual[knt].position_cd = dp.position_cd,
   detail_list->qual[knt].application_number = dp.application_number, detail_list->qual[knt].
   view_name = dp.view_name
  FOOT REPORT
   detail_list->qual_knt = knt, stat = alterlist(detail_list->qual,knt)
  WITH nocounter, outerjoin = d, dontexist
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = "   ERROR  :: Finding items to update"
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = serrmsg
  SET error_level = 1
  GO TO exit_script
 ENDIF
 IF ((detail_list->qual_knt < 1))
  CALL echo("***")
  CALL echo("***   No items found")
  CALL echo("***")
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = "   INFO   :: No items needed to be updated"
  GO TO exit_script
 ENDIF
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("   INFO   :: ",trim(cnvtstring(detail_list->qual_knt)),
  " needing to be updated")
 SET b_idx = 1
 IF ((detail_list->qual_knt <= 100))
  SET e_idx = detail_list->qual_knt
 ELSE
  SET e_idx = 100
 ENDIF
 SET continue = true
 SET w_knt = 1
 WHILE (continue=true
  AND (e_idx <= detail_list->qual_knt))
   IF (w_knt=1)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = "   INFO   :: Updating the 1st 100"
   ELSEIF (w_knt=2)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = "   INFO   :: Updating the 2nd 100"
   ELSEIF (w_knt=3)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = "   INFO   :: Updating the 3rd 100"
   ELSE
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat("   INFO   :: Updating the ",trim(cnvtstring(w_knt)),
     "th 100")
   ENDIF
   UPDATE  FROM (dummyt d  WITH seq = value(detail_list->qual_knt)),
     detail_prefs dp
    SET dp.view_seq = 0, dp.comp_seq = 0, dp.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     dp.updt_cnt = (dp.updt_cnt+ 1), dp.updt_id = 0.0, dp.updt_task = 0,
     dp.updt_applctx = 0
    PLAN (d
     WHERE d.seq >= b_idx
      AND d.seq <= e_idx)
     JOIN (dp
     WHERE (dp.detail_prefs_id=detail_list->qual[d.seq].detail_prefs_id))
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = "   ERROR  :: Updating items"
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = serrmsg
    SET error_level = 1
    SET continue = false
   ENDIF
   COMMIT
   SET b_idx = (e_idx+ 1)
   IF (continue=true)
    IF ((e_idx=detail_list->qual_knt))
     SET continue = false
    ELSEIF (((e_idx+ 100) >= detail_list->qual_knt))
     SET e_idx = detail_list->qual_knt
    ELSE
     SET e_idx = (e_idx+ 100)
    ENDIF
   ENDIF
   SET w_knt = (w_knt+ 1)
 ENDWHILE
 GO TO exit_script
 SUBROUTINE error_logging(lvar)
  SET err_log->msg_qual = msg_knt
  SELECT INTO value(log_file)
   out_string = substring(1,132,err_log->msg[d.seq].err_msg)
   FROM (dummyt d  WITH seq = value(err_log->msg_qual))
   PLAN (d
    WHERE d.seq > 0)
   DETAIL
    row + 1, col 0, out_string
   WITH nocounter, append, format = variable,
    noformfeed, maxrow = value((msg_knt+ 1)), maxcol = 150
  ;end select
 END ;Subroutine
#exit_script
 IF (error_level=0)
  SET status_msg = "SUCCESS"
  SET readme_data->status = "S"
  SET readme_data->message = "SUCCESS : Readme has finished successfully"
 ELSE
  SET status_msg = "FAILURE"
  SET readme_data->status = "F"
  SET readme_data->message =
  "FAILURE : Examine the CCLUSERDIR:CPS_README_ZERO_PREF_SEQ.LOG file for specific errors"
 ENDIF
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("CPS_README_ZERO_PREF_SEQ  END : ",trim(status_msg),"  ",
  format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 CALL error_logging(dvar)
 EXECUTE dm_readme_status
 COMMIT
 SET script_version = "002 08/06/03 SF3151"
END GO
