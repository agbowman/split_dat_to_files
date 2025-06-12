CREATE PROGRAM dm_pcmb_bbd_counseling_note:dba
 IF ((validate(dm_cmb_cust_script->called_by_readme_ind,- (9))=- (9)))
  RECORD dm_cmb_cust_script(
    1 called_by_readme_ind = i2
    1 exc_maint_ind = i2
  )
 ENDIF
 DECLARE dm_cmb_get_context(dummy=i2) = null
 DECLARE dm_cmb_exc_maint_status(s_dcems_status=c1,s_dcems_msg=c255,s_dcems_tname=vc) = null
 SUBROUTINE dm_cmb_get_context(dummy)
   SET dm_cmb_cust_script->called_by_readme_ind = 0
   IF (validate(readme_data->status,"b") != "b"
    AND validate(readme_data->message,"CUSTCMBVALIDATE") != "CUSTCMBVALIDATE")
    SET dm_cmb_cust_script->called_by_readme_ind = 1
   ENDIF
   SET dm_cmb_cust_script->exc_maint_ind = 0
   IF ((validate(dcue_context_rec->called_by_dcue_ind,- (11)) != - (11))
    AND (validate(dcue_context_rec->called_by_dcue_ind,- (22)) != - (22)))
    SET dm_cmb_cust_script->exc_maint_ind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE cust_chk_ccl_def_col(ftbl_name,fcol_name)
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE a.table_name=cnvtupper(trim(ftbl_name,3))
     AND l.attr_name=cnvtupper(trim(fcol_name,3))
     AND l.structtype="F"
     AND btest(l.stat,11)=0
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dm_cmb_exc_maint_status(s_dcems_status,s_dcems_msg,s_dcems_tname)
   SET dcue_upt_exc_reply->status = s_dcems_status
   SET dcue_upt_exc_reply->message = s_dcems_msg
   SET dcue_upt_exc_reply->error_table = s_dcems_tname
 END ;Subroutine
 IF ((validate(dcem_request->qual[1].single_encntr_ind,- (1))=- (1)))
  FREE RECORD dcem_request
  RECORD dcem_request(
    1 qual[*]
      2 parent_entity = vc
      2 child_entity = vc
      2 op_type = vc
      2 script_name = vc
      2 single_encntr_ind = i2
      2 script_run_order = i4
      2 del_chg_id_ind = i2
      2 delete_row_ind = i2
  )
 ENDIF
 IF (validate(dcem_reply->status,"B")="B")
  FREE RECORD dcem_reply
  RECORD dcem_reply(
    1 status = c1
    1 err_msg = c255
  )
 ENDIF
 IF (validate(dm_cmb_cust_cols->tbl_name,"X")="X"
  AND validate(dm_cmb_cust_cols->tab_name,"Z")="Z")
  RECORD dm_cmb_cust_cols(
    1 tbl_name = vc
    1 updt_std_val_ind = i2
    1 active_std_val_ind = i2
    1 col[*]
      2 col_name = vc
    1 add_col_val[*]
      2 col_name = vc
      2 col_value = vc
    1 where_col_val[*]
      2 col_name = vc
      2 col_value = vc
    1 sub_select_from_tbl = vc
  )
 ENDIF
 IF (validate(dm_cmb_cust_cols2->tbl_name,"X")="X"
  AND validate(dm_cmb_cust_cols2->tab_name,"Z")="Z")
  RECORD dm_cmb_cust_cols2(
    1 tbl_name = vc
    1 updt_std_val_ind = i2
    1 active_std_val_ind = i2
    1 col[*]
      2 col_name = vc
    1 add_col_val[*]
      2 col_name = vc
      2 col_value = vc
    1 where_col_val[*]
      2 col_name = vc
      2 col_value = vc
    1 sub_select_from_tbl = vc
  )
 ENDIF
 IF (validate(dm_err->ecode,- (1)) < 0)
  FREE RECORD dm_err
  RECORD dm_err(
    1 logfile = vc
    1 debug_flag = i2
    1 ecode = i4
    1 emsg = c132
    1 eproc = vc
    1 err_ind = i2
    1 user_action = vc
    1 asterisk_line = c80
    1 tempstr = vc
    1 errfile = vc
    1 errtext = vc
    1 unique_fname = vc
    1 disp_msg_emsg = vc
    1 disp_dcl_err_ind = i2
  )
  SET dm_err->asterisk_line = fillstring(80,"*")
  SET dm_err->ecode = 0
  IF (validate(dm2_debug_flag,- (1)) > 0)
   SET dm_err->debug_flag = dm2_debug_flag
  ELSE
   SET dm_err->debug_flag = 0
  ENDIF
  SET dm_err->err_ind = 0
  SET dm_err->user_action = "NONE"
  SET dm_err->tempstr = " "
  SET dm_err->errfile = "NONE"
  SET dm_err->logfile = "NONE"
  SET dm_err->unique_fname = "NONE"
  SET dm_err->disp_dcl_err_ind = 1
 ENDIF
 DECLARE check_error(sbr_ceprocess=vc) = i2
 SUBROUTINE check_error(sbr_ceprocess)
   DECLARE return_val = i4 WITH protect, noconstant(0)
   IF ((dm_err->err_ind=1))
    SET return_val = 1
   ELSE
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF ((dm_err->ecode != 0))
     SET dm_err->eproc = sbr_ceprocess
     SET dm_err->err_ind = 1
     SET return_val = 1
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 from_id = f8
     2 from_counseling_note_id = f8
     2 from_counseling_note = vc
     2 from_long_text_id = f8
     2 from_bcn_updt_cnt = i4
     2 from_long_text = vc
     2 from_lt_updt_cnt = i4
     2 from_contact_id = f8
     2 active_ind = i2
     2 active_status_cd = f8
   1 to_rec[*]
     2 to_id = f8
     2 to_counseling_note_id = f8
     2 to_counseling_note = vc
     2 to_bcn_updt_cnt = i4
     2 to_long_text_id = f8
     2 to_long_text = vc
     2 to_lt_updt_cnt = i4
     2 to_contact_id = f8
     2 active_ind = i2
     2 active_status_cd = f8
 )
 FREE SET new_comment
 RECORD new_comment(
   1 new_counseling_note = vc
 )
 DECLARE archive_donor_note(sub_bcn_counseling_note_id=f8,sub_bcn_person_id=f8,
  sub_bcn_donor_note_updt_cnt=i4,sub_bcn_long_text_id=f8,sub_bcn_long_text_updt_cnt=i4,
  sub_bcn_active_ind=i2,sub_bcn_active_status_cd=f8) = null
 SUBROUTINE archive_donor_note(sub_bcn_counseling_note_id,sub_bcn_person_id,
  sub_bcn_donor_note_updt_cnt,sub_bcn_long_text_id,sub_bcn_long_text_updt_cnt,sub_bcn_active_ind,
  sub_bcn_active_status_cd)
  UPDATE  FROM bbd_counseling_note bcn
   SET bcn.active_ind = sub_bcn_active_ind, bcn.active_status_cd = sub_bcn_active_status_cd, bcn
    .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
    bcn.active_status_prsnl_id = reqinfo->updt_id, bcn.updt_cnt = (bcn.updt_cnt+ 1), bcn.updt_dt_tm
     = cnvtdatetime(curdate,curtime3),
    bcn.updt_id = reqinfo->updt_id, bcn.updt_task = reqinfo->updt_task, bcn.updt_applctx = reqinfo->
    updt_applctx
   WHERE bcn.counseling_note_id=sub_bcn_counseling_note_id
    AND bcn.person_id=sub_bcn_person_id
    AND bcn.updt_cnt=sub_bcn_donor_note_updt_cnt
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET gsub_status = "F"
   SET gsub_process = "inactivate/archive bbd_counseling_note"
   SET gsub_message =
   "current active bbd_counseling_note row could not be archived--bbd_counseling_note not added"
  ELSE
   CALL chg_long_text(sub_bcn_long_text_id,sub_bcn_long_text_updt_cnt,sub_bcn_active_ind,
    sub_bcn_active_status_cd)
   IF (curqual=0)
    SET gsub_status = "F"
    SET gsub_process = "inactivate/archive long_text"
    SET gsub_message =
    "current active long_text row could not be archived--bbd_counseling_note not added"
   ENDIF
  ENDIF
 END ;Subroutine
 DECLARE chg_long_text(sub_lt_long_text_id=f8,sub_lt_long_text_updt_cnt=i4,sub_lt_active_ind=i2,
  sub_lt_active_status_cd=f8) = null
 SUBROUTINE chg_long_text(sub_lt_long_text_id,sub_lt_long_text_updt_cnt,sub_lt_active_ind,
  sub_lt_active_status_cd)
   UPDATE  FROM long_text lt
    SET lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id =
     reqinfo->updt_id,
     lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.active_ind =
     sub_lt_active_ind,
     lt.active_status_cd = sub_lt_active_status_cd, lt.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3), lt.active_status_prsnl_id = reqinfo->updt_id
    WHERE lt.long_text_id=sub_lt_long_text_id
     AND lt.updt_cnt=sub_lt_long_text_updt_cnt
    WITH nocounter
   ;end update
 END ;Subroutine
 DECLARE add_donor_note(sub_person_id=f8,sub_donor_note=vc,sub_contact_id=f8) = null
 SUBROUTINE add_donor_note(sub_person_id,sub_donor_note,sub_contact_id)
   SET new_counseling_note_id = 0.0
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET gsub_status = "F"
    SET gsub_process = "get new counseling_note_id (PATHNET_SEQ)"
    SET gsub_message =
    "get new counseling_note_id (PATHNET_SEQ) failed for the bbd_counseling_note table"
   ELSE
    SET new_counseling_note_id = new_pathnet_seq
    SET new_long_text_id = 0.0
    SELECT INTO "nl:"
     seqn = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      new_long_text_id = seqn
     WITH format, nocounter
    ;end select
    IF (curqual=0)
     SET gsub_status = "F"
     SET gsub_process = "get new long_text_id (LONG_DATA_SEQ)"
     SET gsub_message = "get new long_text_id (LONG_DATA_SEQ) failed for the long_text table"
    ELSE
     CALL add_long_text(new_long_text_id,"BBD_COUNSELING_NOTE",new_counseling_note_id,sub_donor_note)
     IF (curqual=0)
      SET gsub_status = "F"
      SET gsub_process = "insert into long_text"
      SET gsub_message = "insert into long_text table failed"
     ELSE
      INSERT  FROM bbd_counseling_note bcn
       SET bcn.counseling_note_id = new_counseling_note_id, bcn.person_id = sub_person_id, bcn
        .contact_id = sub_contact_id,
        bcn.long_text_id = new_long_text_id, bcn.create_dt_tm = cnvtdatetime(curdate,curtime3), bcn
        .active_ind = 1,
        bcn.active_status_cd = reqdata->active_status_cd, bcn.active_status_dt_tm = cnvtdatetime(
         curdate,curtime3), bcn.active_status_prsnl_id = reqinfo->updt_id,
        bcn.updt_cnt = 0, bcn.updt_dt_tm = cnvtdatetime(curdate,curtime3), bcn.updt_id = reqinfo->
        updt_id,
        bcn.updt_task = reqinfo->updt_task, bcn.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET gsub_status = "F"
       SET gsub_process = "insert into donor_note"
       SET gsub_message = "insert into bbd_counseling_note table failed"
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_long_text(sub_long_text_id,sub_parent_entity_name,sub_parent_entity_id,sub_long_text)
   INSERT  FROM long_text lt
    SET lt.long_text_id = sub_long_text_id, lt.parent_entity_name = sub_parent_entity_name, lt
     .parent_entity_id = sub_parent_entity_id,
     lt.long_text = sub_long_text, lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
     updt_applctx,
     lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     lt.active_status_prsnl_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
 END ;Subroutine
 DECLARE v_cust_count1 = i4 WITH protect, noconstant(0)
 DECLARE v_cust_count2 = i4 WITH protect, noconstant(0)
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 DECLARE new_counseling_note_id = f8 WITH protect, noconstant(0.0)
 DECLARE new_long_text_id = f8 WITH protect, noconstant(0.0)
 DECLARE gsub_status = c1 WITH protect, noconstant(" ")
 DECLARE nfailed = i2 WITH protect, noconstant(0)
 DECLARE sfailedmessage = vc WITH protect, noconstant("")
 DECLARE gsub_process = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE gsub_message = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE dt_tm_text = c20 WITH protect, noconstant(fillstring(20," "))
 DECLARE ecode = i4 WITH protect, noconstant(0)
 DECLARE emsg = c132 WITH protect, noconstant(fillstring(132," "))
 SET v_cust_count1 = 0
 SET v_cust_count2 = 0
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "BBD_COUNSELING_NOTE"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "dm_pcmb_bbd_counseling_note"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
 ELSE
  IF ((request->xxx_combine[icombine].encntr_id != 0))
   SET failed = false
   SET request->error_message = "bbd_counseling_notes need only be combined for full person combines"
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   bcn.counseling_note_id, lt.long_text_id, long_text_exist_ind = evaluate(nullind(lt.long_text_id),0,
    1,0)
   FROM bbd_counseling_note bcn,
    long_text lt
   PLAN (bcn
    WHERE (bcn.person_id=request->xxx_combine[icombine].from_xxx_id)
     AND bcn.active_ind=1)
    JOIN (lt
    WHERE lt.long_text_id=outerjoin(bcn.long_text_id)
     AND lt.active_ind=outerjoin(1)
     AND ((lt.long_text_id+ 0) > outerjoin(0.0)))
   HEAD REPORT
    IF (long_text_exist_ind=0)
     sfailedmessage = build("'From' row long_text table data integrity issue for long_text_id:"," ",
      bcn.long_text_id), nfailed = 1
    ENDIF
    stat = alterlist(rreclist->from_rec,10)
   DETAIL
    v_cust_count1 = (v_cust_count1+ 1)
    IF (mod(v_cust_count1,10)=1
     AND v_cust_count1 != 1)
     stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
    ENDIF
    rreclist->from_rec[v_cust_count1].from_id = request->xxx_combine[icombine].from_xxx_id, rreclist
    ->from_rec[v_cust_count1].from_counseling_note_id = bcn.counseling_note_id, rreclist->from_rec[
    v_cust_count1].from_counseling_note = lt.long_text,
    rreclist->from_rec[v_cust_count1].from_long_text_id = bcn.long_text_id, rreclist->from_rec[
    v_cust_count1].from_bcn_updt_cnt = bcn.updt_cnt, rreclist->from_rec[v_cust_count1].from_long_text
     = lt.long_text,
    rreclist->from_rec[v_cust_count1].from_lt_updt_cnt = lt.updt_cnt, rreclist->from_rec[
    v_cust_count1].from_contact_id = bcn.contact_id, rreclist->from_rec[v_cust_count1].active_ind =
    bcn.active_ind,
    rreclist->from_rec[v_cust_count1].active_status_cd = bcn.active_status_cd
   FOOT REPORT
    stat = alterlist(rreclist->from_rec,v_cust_count1)
   WITH nocounter
  ;end select
  IF (nfailed=1)
   SET failed = data_error
   SET request->error_message = sfailedmessage
   GO TO exit_script
  ENDIF
  IF (v_cust_count1=0)
   SET failed = false
   SET request->error_message = "No 'From' rows found.  Nothing to combine"
   GO TO exit_script
  ELSEIF (v_cust_count1=1)
   SELECT INTO "nl:"
    bcn.counseling_note_id
    FROM bbd_counseling_note bcn,
     (dummyt d  WITH seq = value(v_cust_count1))
    PLAN (d)
     JOIN (bcn
     WHERE (bcn.counseling_note_id=rreclist->from_rec[d.seq].from_counseling_note_id))
    WITH nocounter, forupdatewait(bcn)
   ;end select
   CALL archive_donor_note(rreclist->from_rec[1].from_counseling_note_id,request->xxx_combine[
    icombine].from_xxx_id,rreclist->from_rec[1].from_bcn_updt_cnt,rreclist->from_rec[1].
    from_long_text_id,rreclist->from_rec[1].from_lt_updt_cnt,
    0,combinedaway)
   SET icombinedet = (icombinedet+ 1)
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].to_record_ind = 0
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = rreclist->from_rec[v_cust_count1].
   from_counseling_note_id
   SET request->xxx_combine_det[icombinedet].entity_name = "BBD_COUNSELING_NOTE"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = rreclist->from_rec[v_cust_count1].
   active_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = rreclist->from_rec[v_cust_count1
   ].active_status_cd
   SET icombinedet = (icombinedet+ 1)
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].to_record_ind = 0
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = rreclist->from_rec[v_cust_count1].
   from_long_text_id
   SET request->xxx_combine_det[icombinedet].entity_name = "LONG_TEXT"
   SET request->xxx_combine_det[icombinedet].attribute_name = ""
   SET request->xxx_combine_det[icombinedet].prev_active_ind = rreclist->from_rec[v_cust_count1].
   active_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = rreclist->from_rec[v_cust_count1
   ].active_status_cd
   IF (gsub_status="F")
    SET failed = update_error
    SET request->error_message = gsub_message
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    bcn.counseling_note_id, lt.long_text_id, long_text_exist_ind = evaluate(nullind(lt.long_text_id),
     0,1,0)
    FROM bbd_counseling_note bcn,
     long_text lt
    PLAN (bcn
     WHERE (bcn.person_id=request->xxx_combine[icombine].to_xxx_id)
      AND bcn.active_ind=1)
     JOIN (lt
     WHERE lt.long_text_id=outerjoin(bcn.long_text_id)
      AND lt.active_ind=outerjoin(1)
      AND ((lt.long_text_id+ 0) > outerjoin(0.0)))
    HEAD REPORT
     IF (long_text_exist_ind=0)
      sfailedmessage = build("'To' row long_text table data integrity issue for long_text_id:"," ",
       bcn.long_text_id), nfailed = 1
     ENDIF
     stat = alterlist(rreclist->to_rec,10)
    DETAIL
     v_cust_count2 = (v_cust_count2+ 1)
     IF (mod(v_cust_count2,10)=1
      AND v_cust_count2 != 1)
      stat = alterlist(rreclist->to_rec,(v_cust_count2+ 9))
     ENDIF
     rreclist->to_rec[v_cust_count2].to_id = request->xxx_combine[icombine].to_xxx_id, rreclist->
     to_rec[v_cust_count2].to_counseling_note_id = bcn.counseling_note_id, rreclist->to_rec[
     v_cust_count2].to_bcn_updt_cnt = bcn.updt_cnt,
     rreclist->to_rec[v_cust_count2].to_counseling_note = lt.long_text, rreclist->to_rec[
     v_cust_count2].to_long_text_id = bcn.long_text_id, rreclist->to_rec[v_cust_count2].to_long_text
      = lt.long_text,
     rreclist->to_rec[v_cust_count2].to_lt_updt_cnt = lt.updt_cnt, rreclist->to_rec[v_cust_count2].
     to_contact_id = bcn.contact_id, rreclist->to_rec[v_cust_count2].active_ind = bcn.active_ind,
     rreclist->to_rec[v_cust_count2].active_status_cd = bcn.active_status_cd
    FOOT REPORT
     stat = alterlist(rreclist->to_rec,v_cust_count2)
    WITH nocounter
   ;end select
   IF (nfailed=1)
    SET failed = data_error
    SET request->error_message = sfailedmessage
    GO TO exit_script
   ENDIF
   IF (v_cust_count2=0)
    SET dt_tm_text = format(cnvtdatetime(curdate,curtime),cclfmt->mediumdatetime)
    SET new_comment->new_counseling_note = concat(">> ",trim(dt_tm_text)," [COMBINE]",
     " [Combine from person_id ",trim(cnvtstring(request->xxx_combine[icombine].from_xxx_id)),
     " to person_id ",trim(cnvtstring(request->xxx_combine[icombine].to_xxx_id)),"]",char(13),char(10
      ),
     char(13),char(10),"[Following comments combined from person_id ",trim(cnvtstring(request->
       xxx_combine[icombine].from_xxx_id)),"]",
     char(13),char(10),rreclist->from_rec[1].from_counseling_note)
    CALL add_donor_note(request->xxx_combine[icombine].to_xxx_id,new_comment->new_counseling_note,
     rreclist->from_rec[v_cust_count1].from_contact_id)
    SET icombinedet = (icombinedet+ 1)
    SET stat = alterlist(request->xxx_combine_det,icombinedet)
    SET request->xxx_combine_det[icombinedet].to_record_ind = 1
    SET request->xxx_combine_det[icombinedet].combine_action_cd = add
    SET request->xxx_combine_det[icombinedet].entity_id = new_counseling_note_id
    SET request->xxx_combine_det[icombinedet].entity_name = "BBD_COUNSELING_NOTE"
    SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
    SET icombinedet = (icombinedet+ 1)
    SET stat = alterlist(request->xxx_combine_det,icombinedet)
    SET request->xxx_combine_det[icombinedet].to_record_ind = 1
    SET request->xxx_combine_det[icombinedet].combine_action_cd = add
    SET request->xxx_combine_det[icombinedet].entity_id = new_long_text_id
    SET request->xxx_combine_det[icombinedet].entity_name = "LONG_TEXT"
    SET request->xxx_combine_det[icombinedet].attribute_name = ""
    IF (gsub_status="F")
     SET failed = insert_error
     SET request->error_message = gsub_message
     GO TO exit_script
    ENDIF
   ELSEIF (v_cust_count2=1)
    SELECT INTO "nl:"
     bcn.counseling_note_id
     FROM bbd_counseling_note bcn,
      (dummyt d  WITH seq = value(v_cust_count2))
     PLAN (d)
      JOIN (bcn
      WHERE (bcn.counseling_note_id=rreclist->to_rec[d.seq].to_counseling_note_id))
     WITH nocounter, forupdatewait(bcn)
    ;end select
    CALL archive_donor_note(rreclist->to_rec[1].to_counseling_note_id,request->xxx_combine[icombine].
     to_xxx_id,rreclist->to_rec[1].to_bcn_updt_cnt,rreclist->to_rec[1].to_long_text_id,rreclist->
     to_rec[1].to_lt_updt_cnt,
     0,combinedaway)
    SET icombinedet = (icombinedet+ 1)
    SET stat = alterlist(request->xxx_combine_det,icombinedet)
    SET request->xxx_combine_det[icombinedet].to_record_ind = 1
    SET request->xxx_combine_det[icombinedet].combine_action_cd = del
    SET request->xxx_combine_det[icombinedet].entity_id = rreclist->to_rec[v_cust_count2].
    to_counseling_note_id
    SET request->xxx_combine_det[icombinedet].entity_name = "BBD_COUNSELING_NOTE"
    SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
    SET request->xxx_combine_det[icombinedet].prev_active_ind = rreclist->to_rec[v_cust_count2].
    active_ind
    SET request->xxx_combine_det[icombinedet].prev_active_status_cd = rreclist->to_rec[v_cust_count2]
    .active_status_cd
    SET icombinedet = (icombinedet+ 1)
    SET stat = alterlist(request->xxx_combine_det,icombinedet)
    SET request->xxx_combine_det[icombinedet].to_record_ind = 1
    SET request->xxx_combine_det[icombinedet].combine_action_cd = del
    SET request->xxx_combine_det[icombinedet].entity_id = rreclist->to_rec[v_cust_count2].
    to_long_text_id
    SET request->xxx_combine_det[icombinedet].entity_name = "LONG_TEXT"
    SET request->xxx_combine_det[icombinedet].attribute_name = ""
    SET request->xxx_combine_det[icombinedet].prev_active_ind = rreclist->to_rec[v_cust_count2].
    active_ind
    SET request->xxx_combine_det[icombinedet].prev_active_status_cd = rreclist->to_rec[v_cust_count2]
    .active_status_cd
    IF (gsub_status="F")
     SET failed = update_error
     SET request->error_message = gsub_message
     GO TO exit_script
    ENDIF
    SET dt_tm_text = format(cnvtdatetime(curdate,curtime),cclfmt->mediumdatetime)
    SET new_comment->new_counseling_note = concat(">> ",trim(dt_tm_text)," [COMBINE]",
     " [Combine from person_id ",trim(cnvtstring(request->xxx_combine[icombine].from_xxx_id)),
     " to person_id ",trim(cnvtstring(request->xxx_combine[icombine].to_xxx_id)),"]",char(13),char(10
      ),
     char(13),char(10),"[Following comments for to person_id ",trim(cnvtstring(request->xxx_combine[
       icombine].to_xxx_id)),"]",
     char(13),char(10),rreclist->to_rec[1].to_counseling_note,char(13),char(10),
     char(13),char(10),"[Following comments combined from person_id ",trim(cnvtstring(request->
       xxx_combine[icombine].from_xxx_id)),"]",
     char(13),char(10),rreclist->from_rec[1].from_counseling_note)
    CALL add_donor_note(request->xxx_combine[icombine].to_xxx_id,new_comment->new_counseling_note,
     rreclist->to_rec[v_cust_count2].to_contact_id)
    SET icombinedet = (icombinedet+ 1)
    SET stat = alterlist(request->xxx_combine_det,icombinedet)
    SET request->xxx_combine_det[icombinedet].to_record_ind = 1
    SET request->xxx_combine_det[icombinedet].combine_action_cd = add
    SET request->xxx_combine_det[icombinedet].entity_id = new_counseling_note_id
    SET request->xxx_combine_det[icombinedet].entity_name = "BBD_COUNSELING_NOTE"
    SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
    SET icombinedet = (icombinedet+ 1)
    SET stat = alterlist(request->xxx_combine_det,icombinedet)
    SET request->xxx_combine_det[icombinedet].to_record_ind = 1
    SET request->xxx_combine_det[icombinedet].combine_action_cd = add
    SET request->xxx_combine_det[icombinedet].entity_id = new_long_text_id
    SET request->xxx_combine_det[icombinedet].entity_name = "LONG_TEXT"
    SET request->xxx_combine_det[icombinedet].attribute_name = ""
    IF (gsub_status="F")
     SET failed = insert_error
     SET request->error_message = gsub_message
     GO TO exit_script
    ENDIF
   ELSE
    SET failed = data_error
    SET request->error_message = "More than 1 'To' row found on bbd_counseling_note table"
    GO TO exit_script
   ENDIF
  ELSE
   SET failed = data_error
   SET request->error_message = "More than 1 'From' row found on bbd_counseling_note table"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 SET ecode = error(emsg,1)
#end_main_sub
 FREE SET rreclist
 FREE SET new_comment
END GO
