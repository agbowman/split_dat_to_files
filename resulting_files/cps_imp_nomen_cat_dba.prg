CREATE PROGRAM cps_imp_nomen_cat:dba
 FREE RECORD hold
 RECORD hold(
   1 qual_cnt = i4
   1 qual[*]
     2 category_name = vc
     2 cat_type_cd = f8
     2 nomen_cat_id = f8
 )
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
 SET list_size = size(requestin->list_0,5)
 SET dvar = 0
 FREE SET err_log
 RECORD err_log(
   1 msg_qual = i4
   1 msg[*]
     2 err_msg = vc
 )
 SET log_file = "CPS_IMP_NOMEN_CAT.LOG"
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
 SET err_log->msg[msg_knt].err_msg = concat("CPS_IMP_NOMEN_CAT  BEG : ",format(cnvtdatetime(curdate,
    curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = "   INFO  : Determine existence of a valid input list"
 IF (list_size < 1)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = "   WARNING  : Input list contains no elements"
  SET msg_knt = (msg_knt+ 1)
  SET error_level = 2
  GO TO exit_script
 ENDIF
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = "   INFO  : Get code value"
 SET cat_name = fillstring(100," ")
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(list_size)),
   code_value cv
  PLAN (d)
   JOIN (cv
   WHERE cv.code_set=25321
    AND (cv.cdf_meaning=requestin->list_0[d.seq].category_type_mean))
  HEAD REPORT
   knt = 0, stat = alterlist(hold->qual,50)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,50)=1
    AND knt != 1)
    stat = alterlist(hold->qual,(knt+ 49))
   ENDIF
   hold->qual[knt].category_name = requestin->list_0[d.seq].category_name, hold->qual[knt].
   cat_type_cd = cv.code_value
  FOOT REPORT
   hold->qual_cnt = knt, stat = alterlist(hold->qual,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = "   ERROR  : Finding the code_value for categories"
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = trim(substring(1,132,serrmsg))
  SET error_level = 1
  GO TO exit_script
 ENDIF
 SET list1 = size(hold->qual,5)
 SET msg_knt = (msg_knt+ 1)
 SET cat_name = fillstring(100," ")
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = "   INFO  : Get categories"
 SET ierrcode = 0
 FOR (y = 1 TO list1)
   CALL echo("***")
   CALL echo(build("***   category_name :",hold->qual[y].category_name))
   CALL echo(build("***   cat_type_cd   :",hold->qual[y].cat_type_cd))
   CALL echo("***")
   SET cat_name = trim(cnvtupper(hold->qual[y].category_name))
   SELECT INTO "nl:"
    FROM nomen_category nc
    WHERE nc.category_name=cat_name
     AND (nc.category_type_cd=hold->qual[y].cat_type_cd)
     AND nc.parent_entity_id=0
    ORDER BY nc.category_name
    HEAD REPORT
     hold->qual[y].nomen_cat_id = nc.nomen_category_id,
     CALL echo(build("***   table.category_name      :",nc.category_name)),
     CALL echo(build("***   table.category_type_cd   :",nc.category_type_cd)),
     CALL echo(build("***   table.parent_entity_name :",nc.parent_entity_name)),
     CALL echo(build("***   table.parent_entity_id   :",nc.parent_entity_id))
    WITH nocounter
   ;end select
   IF (curqual < 1)
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = "   ERROR  : Finding the categories"
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = trim(substring(1,132,serrmsg))
     SET error_level = 1
     GO TO exit_script
    ELSE
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = "   INFO  : Inserting categoies"
     SET ierrcode = 0
     INSERT  FROM nomen_category nc
      SET nc.nomen_category_id = cnvtreal(seq(nomenclature_seq,nextval)), nc.category_name = hold->
       qual[y].category_name, nc.category_type_cd = hold->qual[y].cat_type_cd,
       nc.updt_dt_tm = cnvtdatetime(curdate,curtime3), nc.updt_applctx = reqinfo->updt_applctx, nc
       .updt_cnt = 0,
       nc.updt_dt_tm = cnvtdatetime(curdate,curtime3), nc.updt_id = reqinfo->updt_id, nc.updt_task =
       reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual < 1)
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET msg_knt = (msg_knt+ 1)
       SET stat = alterlist(err_log->msg,msg_knt)
       SET err_log->msg[msg_knt].err_msg = "   ERROR  : Inserting categories"
       SET msg_knt = (msg_knt+ 1)
       SET stat = alterlist(err_log->msg,msg_knt)
       SET err_log->msg[msg_knt].err_msg = trim(substring(1,132,serrmsg))
       SET error_level = 1
       ROLLBACK
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = "   INFO  : Updating categoies"
    SET ierrcode = 0
    CALL echo(build("Nomen cat id : ",hold->qual[y].nomen_cat_id))
    UPDATE  FROM nomen_category nc
     SET nc.category_type_cd = hold->qual[y].cat_type_cd, nc.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), nc.updt_cnt = (nc.updt_cnt+ 1)
     WHERE (nc.nomen_category_id=hold->qual[y].nomen_cat_id)
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = "   ERROR  : Updating categories"
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = trim(substring(1,132,serrmsg))
     SET error_level = 1
     ROLLBACK
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_level=1)
  SET status_msg = "FAILURE"
  SET reqinfo->commit_ind = 3
 ELSEIF (error_level=2)
  SET status_msg = "WARNING"
  COMMIT
 ELSE
  SET status_msg = "SUCCESS"
  COMMIT
 ENDIF
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("CPS_IMP_NOMEN_CAT  END : ",trim(status_msg),"  ",format(
   cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 CALL error_logging(dvar)
END GO
