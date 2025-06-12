CREATE PROGRAM cps_imp_nomen_list:dba
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
 FREE RECORD request1
 RECORD request1(
   1 list_0[*]
     2 parent_cat_name = vc
     2 child_cat_name = vc
     2 source_vocabulary_mean = vc
     2 vocab_cd = f8
     2 source_identifier = vc
     2 source_string = vc
     2 principle_type_mean = vc
     2 principle_cd = f8
 )
 SELECT INTO "nl:"
  FROM code_value cv,
   dummyt d1,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (d1)
   JOIN (cv
   WHERE cv.code_set=400
    AND (cv.cdf_meaning=requestin->list_0[d.seq].source_vocabulary_mean))
  HEAD REPORT
   knt = 0, stat = alterlist(request1->list_0,100)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,100)=1)
    stat = alterlist(request1->list_0,(knt+ 99))
   ENDIF
   request1->list_0[knt].vocab_cd = cv.code_value, request1->list_0[knt].parent_cat_name = requestin
   ->list_0[d.seq].parent_cat_name, request1->list_0[knt].child_cat_name = requestin->list_0[d.seq].
   child_cat_name,
   request1->list_0[knt].source_identifier = requestin->list_0[d.seq].source_identifier, request1->
   list_0[knt].source_string = requestin->list_0[d.seq].source_string,
   CALL echo(build("cv : ",request1->list_0[knt].vocab_cd))
  FOOT REPORT
   stat = alterlist(request1->list_0,knt)
  WITH nocounter, outerjoin = d1
 ;end select
 IF (curqual < 1)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = "   ERROR  : can't find the vocab cd"
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv,
   dummyt d1,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (d1)
   JOIN (cv
   WHERE cv.code_set=401
    AND (cv.cdf_meaning=requestin->list_0[d.seq].principle_type_mean))
  HEAD REPORT
   knt = 0, stat = alterlist(request1->list_0,100)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,100)=1)
    stat = alterlist(request1->list_0,(knt+ 99))
   ENDIF
   request1->list_0[knt].principle_cd = cv.code_value,
   CALL echo(build("principle : ",request1->list_0[knt].principle_cd))
  WITH nocounter, outerjoin = d1
 ;end select
 SET list_size = size(request1->list_0,5)
 SET dvar = 0
 FREE SET err_log
 RECORD err_log(
   1 msg_qual = i4
   1 msg[*]
     2 err_msg = vc
 )
 SET log_file = "CPS_IMP_NOMEN_LIST.LOG"
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
 FREE SET hold_cat
 RECORD hold_cat(
   1 qual_cnt = i4
   1 qual[*]
     2 parent_cat_id = f8
     2 last_seq = i4
     2 exist_ind = i2
     2 child_cnt = i4
     2 child[*]
       3 nomen_cat_list_id = f8
       3 child_cat_id = f8
 )
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("CPS_IMP_NOMEN_LIST  BEG : ",format(cnvtdatetime(curdate,
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
 SET err_log->msg[msg_knt].err_msg = "   INFO  : Get child nomen categories"
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(list_size)),
   nomen_category nc,
   nomen_category nc1,
   nomen_cat_list nl,
   (dummyt d2  WITH seq = 1)
  PLAN (d
   WHERE (request1->list_0[d.seq].child_cat_name > " "))
   JOIN (nc
   WHERE (nc.category_name=request1->list_0[d.seq].parent_cat_name))
   JOIN (nc1
   WHERE (nc1.category_name=request1->list_0[d.seq].child_cat_name))
   JOIN (d2)
   JOIN (nl
   WHERE nl.parent_category_id=nc.nomen_category_id
    AND nl.child_category_id=nc1.nomen_category_id)
  ORDER BY nc.category_name
  HEAD REPORT
   knt = 0, stat = alterlist(hold_cat->qual,100)
  HEAD nc.category_name
   knt = (knt+ 1)
   IF (mod(knt,100)=1
    AND knt != 1)
    stat = alterlist(hold_cat->qual,(knt+ 99))
   ENDIF
   hold_cat->qual[knt].parent_cat_id = nc.nomen_category_id
   IF (nl.parent_category_id > 0)
    hold_cat->qual[knt].exist_ind = 1
   ELSE
    hold_cat->qual[knt].exist_ind = 0
   ENDIF
   c_knt = 0, stat = alterlist(hold_cat->qual[knt].child,10)
  DETAIL
   c_knt = (c_knt+ 1)
   IF (mod(c_knt,10)=1
    AND c_knt != 1)
    stat = alterlist(hold_cat->qual[knt].child,(c_knt+ 9))
   ENDIF
   hold_cat->qual[knt].child[c_knt].child_cat_id = nc1.nomen_category_id, hold_cat->qual[knt].child[
   c_knt].nomen_cat_list_id = nl.nomen_cat_list_id
  FOOT  nc.category_name
   hold_cat->qual[knt].child_cnt = c_knt, stat = alterlist(hold_cat->qual[knt].child,c_knt)
  FOOT REPORT
   hold_cat->qual_cnt = knt, stat = alterlist(hold_cat->qual,knt)
  WITH nocounter, outerjoin = d2
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = "   ERROR  : Determining parent|child category relationships"
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = trim(substring(1,132,serrmsg))
  SET error_level = 1
  GO TO exit_script
 ENDIF
 IF ((hold_cat->qual_cnt < 1))
  CALL echo("Grt nomen items ")
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = "   INFO  : No child nomen categories found"
  GO TO get_nomen_items
 ENDIF
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = "   INFO  : Determine last sequence number"
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM nomen_cat_list nl,
   (dummyt d  WITH seq = value(hold_cat->qual_cnt))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (nl
   WHERE (nl.parent_category_id=hold_cat->qual[d.seq].parent_cat_id))
  ORDER BY d.seq, nl.list_sequence DESC
  HEAD d.seq
   found_last = false, hold_cat->qual[d.seq].last_seq = nl.list_sequence,
   CALL echo(build("last_seq : ",hold_cat->qual[d.seq].last_seq))
  DETAIL
   dvar = 1
  WITH nocounter, outerjoin = d
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg =
  "   ERROR  : Determining last sequence number for the parent category"
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = trim(substring(1,132,serrmsg))
  SET error_level = 1
  GO TO exit_script
 ENDIF
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = "   INFO  : Inserting child nomen categoies"
 SET ierrcode = 0
 FOR (i = 1 TO hold_cat->qual_cnt)
   IF ((hold_cat->qual[i].exist_ind=0))
    INSERT  FROM nomen_cat_list nc,
      (dummyt d  WITH seq = value(hold_cat->qual[i].child_cnt))
     SET nc.parent_category_id = hold_cat->qual[i].parent_cat_id, nc.child_category_id = hold_cat->
      qual[i].child[d.seq].child_cat_id, nc.list_sequence = (hold_cat->qual[i].last_seq+ d.seq),
      nc.child_flag = 1, nc.nomenclature_id = 0, nc.nomen_cat_list_id = seq(nomenclature_seq,nextval),
      nc.updt_dt_tm = cnvtdatetime(curdate,curtime3), nc.updt_cnt = 0
     PLAN (d
      WHERE d.seq > 0)
      JOIN (nc
      WHERE 0=0)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = "   ERROR  : Inserting child categories"
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = trim(substring(1,132,serrmsg))
     SET error_level = 1
     ROLLBACK
     GO TO exit_script
    ENDIF
   ELSE
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = "   INFO  : Updating child categories"
    UPDATE  FROM nomen_cat_list nc,
      (dummyt d  WITH seq = value(hold_cat->qual[i].child_cnt))
     SET nc.parent_category_id = hold_cat->qual[i].parent_cat_id, nc.child_category_id = hold_cat->
      qual[i].child[d.seq].child_cat_id, nc.list_sequence = nc.list_sequence,
      nc.child_flag = 1, nc.nomenclature_id = 0, nc.nomen_cat_list_id = nc.nomen_cat_list_id,
      nc.updt_dt_tm = cnvtdatetime(curdate,curtime3), nc.updt_cnt = (nc.updt_cnt+ 1)
     PLAN (d
      WHERE d.seq > 0)
      JOIN (nc
      WHERE (nc.nomen_cat_list_id=hold_cat->qual[i].child[d.seq].nomen_cat_list_id))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = "   ERROR  : Updating child categories"
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = trim(substring(1,132,serrmsg))
     SET error_level = 1
     ROLLBACK
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#get_nomen_items
 FREE SET hold_item
 RECORD hold_item(
   1 qual_cnt = i4
   1 qual[*]
     2 nomen_cat_id = f8
     2 parent_cat_id = f8
     2 last_sequence = i4
     2 exist_ind = i2
     2 nomen_cnt = i4
     2 nomen[*]
       3 nomen_cat_list_id = f8
       3 nomen_id = f8
 )
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = "   INFO  : Get nomen items"
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM nomen_category nc,
   nomenclature n,
   nomen_cat_list nl,
   (dummyt d  WITH seq = value(list_size)),
   (dummyt d2  WITH seq = 1)
  PLAN (d
   WHERE (request1->list_0[d.seq].vocab_cd > 0))
   JOIN (nc
   WHERE (nc.category_name=request1->list_0[d.seq].parent_cat_name))
   JOIN (n
   WHERE (n.source_vocabulary_cd=request1->list_0[d.seq].vocab_cd)
    AND (n.source_identifier=request1->list_0[d.seq].source_identifier)
    AND (n.source_string=request1->list_0[d.seq].source_string)
    AND (n.principle_type_cd=request1->list_0[d.seq].principle_cd))
   JOIN (d2)
   JOIN (nl
   WHERE nl.parent_category_id=nc.nomen_category_id
    AND nl.nomenclature_id=n.nomenclature_id)
  ORDER BY nc.category_name
  HEAD REPORT
   knt = 0, stat = alterlist(hold_item->qual,100)
  HEAD nc.category_name
   knt = (knt+ 1)
   IF (mod(knt,100)=1
    AND knt != 1)
    stat = alterlist(hold_item->qual,(knt+ 99))
   ENDIF
   hold_item->qual[knt].parent_cat_id = nc.nomen_category_id,
   CALL echo(build("parent : ",hold_item->qual[knt].parent_cat_id)), s_knt = 0,
   stat = alterlist(hold_item->qual[knt].nomen,10)
  DETAIL
   s_knt = (s_knt+ 1)
   IF (mod(s_knt,10)=1
    AND s_knt != 1)
    stat = alterlist(hold_item->qual[knt].nomen,(s_knt+ 9))
   ENDIF
   hold_item->qual[knt].nomen[s_knt].nomen_id = n.nomenclature_id,
   CALL echo(build("nomen id : ",hold_item->qual[knt].nomen[s_knt].nomen_id)), hold_item->qual[knt].
   nomen[s_knt].nomen_cat_list_id = nl.nomen_cat_list_id,
   CALL echo(build("nomen cat list id : ",hold_item->qual[knt].nomen[s_knt].nomen_cat_list_id))
   IF (nl.nomen_cat_list_id > 0)
    hold_item->qual[knt].exist_ind = 0,
    CALL echo("**** it's exist")
   ELSE
    hold_item->qual[knt].exist_ind = 1,
    CALL echo("*** It's not exist")
   ENDIF
  FOOT  nc.nomen_category_id
   hold_item->qual[knt].nomen_cnt = s_knt, stat = alterlist(hold_item->qual[knt].nomen,s_knt)
  FOOT REPORT
   hold_item->qual_cnt = knt, stat = alterlist(hold_item->qual,knt),
   CALL echo(hold_item->qual_cnt)
  WITH nocounter, outerjoin = d2
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = "   ERROR  : Determining nomen_id for nomenclature"
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = trim(substring(1,132,serrmsg))
  SET error_level = 1
  GO TO exit_script
 ENDIF
 IF ((hold_item->qual_cnt < 1))
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = "   INFO  : No nomen items found"
  GO TO exit_script
 ENDIF
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = "   INFO  : Determine last sequence number"
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM nomen_cat_list nl,
   (dummyt d  WITH seq = value(hold_item->qual_cnt))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (nl
   WHERE (nl.parent_category_id=hold_item->qual[d.seq].parent_cat_id))
  ORDER BY d.seq, nl.list_sequence DESC
  HEAD d.seq
   found_last = false, hold_item->qual[d.seq].last_sequence = nl.list_sequence
  DETAIL
   dvar
  WITH nocounter, outerjoin = d
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg =
  "   ERROR  : Determining last sequence number for the parent category"
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = trim(substring(1,132,serrmsg))
  SET error_level = 1
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 CALL echo(build("hold : ",hold_item->qual_cnt))
 FOR (i = 1 TO hold_item->qual_cnt)
   IF ((hold_item->qual[i].exist_ind=1))
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = "   INFO  : Inserting nomen items"
    CALL echo(build("list seq : ",hold_item->qual[i].last_sequence))
    CALL echo(build("list seq : ",hold_item->qual[i].parent_cat_id))
    INSERT  FROM nomen_cat_list nl,
      (dummyt d  WITH seq = value(hold_item->qual[i].nomen_cnt))
     SET nl.nomen_cat_list_id = seq(nomenclature_seq,nextval), nl.parent_category_id = hold_item->
      qual[i].parent_cat_id, nl.nomenclature_id = hold_item->qual[i].nomen[d.seq].nomen_id,
      nl.list_sequence = (hold_item->qual[i].last_sequence+ d.seq), nl.child_flag = 2, nl
      .child_category_id = 0,
      nl.updt_dt_tm = cnvtdatetime(curdate,curtime3), nl.updt_applctx = reqinfo->updt_applctx, nl
      .updt_id = reqinfo->updt_id,
      nl.updt_task = reqinfo->updt_task, nl.updt_cnt = 0
     PLAN (d)
      JOIN (nl
      WHERE 0=0)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = "   ERROR  : Inserting nomen items"
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = trim(substring(1,132,serrmsg))
     SET error_level = 1
     ROLLBACK
     GO TO exit_script
    ENDIF
   ELSE
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = "   INFO  : Updating nomen items"
    UPDATE  FROM nomen_cat_list nl,
      (dummyt d  WITH seq = value(hold_item->qual[i].nomen_cnt))
     SET nl.parent_category_id = hold_item->qual[i].parent_cat_id, nl.nomenclature_id = hold_item->
      qual[i].nomen[d.seq].nomen_id, nl.list_sequence = nl.list_sequence,
      nl.child_flag = 2, nl.child_category_id = 0, nl.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      nl.updt_cnt = (nl.updt_cnt+ 1)
     PLAN (d
      WHERE d.seq > 0)
      JOIN (nl
      WHERE (nl.nomen_cat_list_id=hold_item->qual[i].nomen[d.seq].nomen_cat_list_id))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET msg_knt = (msg_knt+ 1)
     SET stat = alterlist(err_log->msg,msg_knt)
     SET err_log->msg[msg_knt].err_msg = "   ERROR  : Updating nomen items"
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
 SET err_log->msg[msg_knt].err_msg = concat("CPS_IMP_NOMEN_LIST  END : ",trim(status_msg),"  ",format
  (cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 CALL error_logging(dvar)
END GO
