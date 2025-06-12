CREATE PROGRAM cps_fix_favorites:dba
 SET false = 0
 SET true = 1
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
 SET dvar = 0
 FREE SET err_log
 RECORD err_log(
   1 msg_qual = i4
   1 msg[*]
     2 err_msg = vc
 )
 SET log_file = "CPS_FIX_FAVORITES.LOG"
 SET msg_knt = 0
 SET error_level = 0
 SET status_msg = fillstring(7," ")
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
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("CPS_FIX_FAVORITES  BEG : ",format(cnvtdatetime(curdate,
    curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 FREE SET temp
 RECORD temp(
   1 qual_knt = i4
   1 qual[*]
     2 username = vc
     2 prsnl_id = f8
     2 alt_sel_cat_id = f8
     2 cat_name = vc
 )
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM alt_sel_cat ac
  PLAN (ac
   WHERE ac.long_description_key_cap="*_MEDICATIONS"
    AND ac.owner_id < 1)
  HEAD REPORT
   knt = 0, stat = alterlist(temp->qual,10)
  DETAIL
   pos = 0, pos = (findstring("_MEDICATIONS",ac.long_description_key_cap) - 1)
   IF (pos > 0)
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(temp->qual,(knt+ 9))
    ENDIF
    temp->qual[knt].username = substring(1,pos,ac.long_description), temp->qual[knt].alt_sel_cat_id
     = ac.alt_sel_category_id, temp->qual[knt].cat_name = ac.long_description_key_cap
   ENDIF
  FOOT REPORT
   temp->qual_knt = knt, stat = alterlist(temp->qual,knt)
  WITH nocounter
 ;end select
 IF ((temp->qual_knt < 1))
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg =
   "   ERROR  : A script error occurred finding Medication favorites with an invalid owner_id"
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = trim(substring(1,132,serrmsg))
   SET error_level = 1
   GO TO exit_script
  ELSE
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg =
   "   INFO  : Found no Medication favorites with an invalid owner_id"
   GO TO fix_order_fav
  ENDIF
 ENDIF
 SET ierrcode = 0
 SELECT INTO "nl:"
  d.seq, p.updt_dt_tm
  FROM (dummyt d  WITH seq = value(temp->qual_knt)),
   prsnl p
  PLAN (d
   WHERE d.seq > 0)
   JOIN (p
   WHERE (p.username=temp->qual[d.seq].username)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY d.seq, cnvtdatetime(p.updt_dt_tm) DESC
  HEAD d.seq
   IF (p.person_id > 0
    AND (temp->qual[d.seq].username=p.username))
    temp->qual[d.seq].prsnl_id = p.person_id
   ENDIF
  DETAIL
   dvar = dvar
  WITH nocounter, outerjoin = d
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = "   ERROR  : A script error occurred finding prsnl_id"
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = trim(substring(1,132,serrmsg))
  SET error_level = 1
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM alt_sel_cat ac,
   (dummyt d  WITH seq = value(temp->qual_knt))
  SET d.seq = d.seq, ac.owner_id = temp->qual[d.seq].prsnl_id, ac.security_flag = 1
  PLAN (d
   WHERE (temp->qual[d.seq].prsnl_id > 0))
   JOIN (ac
   WHERE (ac.alt_sel_category_id=temp->qual[d.seq].alt_sel_cat_id)
    AND (ac.long_description_key_cap=temp->qual[d.seq].cat_name))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = "   ERROR  : A script error occurred updating the owner_id"
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = trim(substring(1,132,serrmsg))
  SET error_level = 1
  GO TO exit_script
 ENDIF
#fix_order_fav
 FREE SET temp
 RECORD temp(
   1 qual_knt = i4
   1 qual[*]
     2 username = vc
     2 prsnl_id = f8
     2 alt_sel_cat_id = f8
     2 cat_name = vc
 )
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM alt_sel_cat ac
  PLAN (ac
   WHERE ac.long_description_key_cap="*_ORD"
    AND ac.owner_id < 1)
  HEAD REPORT
   knt = 0, stat = alterlist(temp->qual,10)
  DETAIL
   pos = 0, pos = (findstring("_ORD",ac.long_description_key_cap) - 1)
   IF (pos > 0)
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(temp->qual,(knt+ 9))
    ENDIF
    temp->qual[knt].username = substring(1,pos,ac.long_description), temp->qual[knt].alt_sel_cat_id
     = ac.alt_sel_category_id, temp->qual[knt].cat_name = ac.long_description_key_cap
   ENDIF
  FOOT REPORT
   temp->qual_knt = knt, stat = alterlist(temp->qual,knt)
  WITH nocounter
 ;end select
 IF ((temp->qual_knt < 1))
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg =
   "   ERROR  : A script error occurred finding Order favorites with an invalid owner_id"
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = trim(substring(1,132,serrmsg))
   SET error_level = 1
   GO TO exit_script
  ELSE
   SET msg_knt = (msg_knt+ 1)
   SET stat = alterlist(err_log->msg,msg_knt)
   SET err_log->msg[msg_knt].err_msg = "   INFO  : Found no Order favorites with an invalid owner_id"
   GO TO fix_security_flag
  ENDIF
 ENDIF
 SET ierrcode = 0
 SELECT INTO "nl:"
  d.seq, p.updt_dt_tm
  FROM (dummyt d  WITH seq = value(temp->qual_knt)),
   prsnl p
  PLAN (d
   WHERE d.seq > 0)
   JOIN (p
   WHERE (p.username=temp->qual[d.seq].username)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY d.seq, cnvtdatetime(p.updt_dt_tm) DESC
  HEAD d.seq
   IF (p.person_id > 0
    AND (temp->qual[d.seq].username=p.username))
    temp->qual[d.seq].prsnl_id = p.person_id
   ENDIF
  DETAIL
   dvar = dvar
  WITH nocounter, outerjoin = d
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = "   ERROR  : A script error occurred finding prsnl_id"
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = trim(substring(1,132,serrmsg))
  SET error_level = 1
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM alt_sel_cat ac,
   (dummyt d  WITH seq = value(temp->qual_knt))
  SET d.seq = d.seq, ac.owner_id = temp->qual[d.seq].prsnl_id, ac.security_flag = 1
  PLAN (d
   WHERE (temp->qual[d.seq].prsnl_id > 0))
   JOIN (ac
   WHERE (ac.alt_sel_category_id=temp->qual[d.seq].alt_sel_cat_id)
    AND (ac.long_description_key_cap=temp->qual[d.seq].cat_name))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = "   ERROR  : A script error occurred updating the owner_id"
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = trim(substring(1,132,serrmsg))
  SET error_level = 1
  GO TO exit_script
 ENDIF
#fix_security_flag
 SET ierrcode = 0
 UPDATE  FROM alt_sel_cat
  SET security_flag = 1
  WHERE owner_id > 0
   AND long_description_key_cap="*_MEDICATIONS"
   AND security_flag != 1
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg =
  "   ERROR  : A script error occurred Medication favorites security_flag"
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = trim(substring(1,132,serrmsg))
  SET error_level = 1
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM alt_sel_cat
  SET security_flag = 1
  WHERE owner_id > 0
   AND long_description_key_cap="*_ORD"
   AND security_flag != 1
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg =
  "   ERROR  : A script error occurred Order favorites security_flag"
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = trim(substring(1,132,serrmsg))
  SET error_level = 1
  GO TO exit_script
 ENDIF
#exit_script
 IF (error_level=1)
  SET status_msg = "FAILURE"
  ROLLBACK
 ELSE
  SET status_msg = "SUCCESS"
  COMMIT
 ENDIF
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("CPS_FIX_FAVORITES  END : ",trim(status_msg),"  ",format(
   cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 CALL error_logging(dvar)
END GO
