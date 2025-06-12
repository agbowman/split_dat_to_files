CREATE PROGRAM dm_eucb_coding_specialty:dba
 IF ((validate(dm_cmb_cust_script->called_by_readme_ind,- (9))=- (9)))
  RECORD dm_cmb_cust_script(
    1 called_by_readme_ind = i2
    1 exc_maint_ind = i2
  )
 ENDIF
 SUBROUTINE (dm_cmb_get_context(dummy=i2) =null)
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
 SUBROUTINE (dm_cmb_exc_maint_status(s_dcems_status=c1,s_dcems_msg=c255,s_dcems_tname=vc) =null)
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
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "ENCOUNTER"
  SET dcem_request->qual[1].child_entity = "CODING_SPECIALTY"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "DM_EUCB_CODING_SPECIALTY"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 FREE SET upt_rec
 RECORD upt_rec(
   1 qual_cnt = i4
   1 qual[*]
     2 coding_id = f8
 )
 DECLARE mq_save_date = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE ml_index = i4 WITH protect, noconstant(0)
 DECLARE mi_using_coding_hist = i2 WITH protect, noconstant(0)
 IF (checkdic("CODING_HIST","T",0)=2)
  SET mi_using_coding_hist = 1
  DECLARE mn_ch_parent_entity_exists = i2 WITH protect, constant(checkdic(
    "CODING_HIST.PARENT_ENTITY_ID","A",0))
  DECLARE ms_ch_parent_entity_parser = vc WITH protect, noconstant("0=0")
  DECLARE ms_ch_coding_parent_entity_parser = vc WITH protect, noconstant("0=0")
  SUBROUTINE (addcodinghistrow(new_coding_id=f8,save_date=f8) =i2)
    IF ( NOT (validate(add_coding_hist_request,0)))
     RECORD add_coding_hist_request(
       1 call_echo_ind = i2
       1 qual[*]
         2 coding_hist_id = f8
         2 encntr_id = f8
         2 person_id = f8
         2 length_of_stay = i4
         2 birth_weight = i4
         2 ascpay = i4
         2 completed_dt_tm = dq8
         2 create_dt_tm = dq8
         2 create_prsnl_id = f8
         2 contributor_system_cd = f8
         2 beg_effective_dt_tm = dq8
         2 end_effective_dt_tm = dq8
         2 merged_encntr_id = f8
         2 svc_cat_hist_id = f8
         2 coding_dt_tm = dq8
         2 coding_prsnl_id = f8
         2 cancer_code_cnt = i4
         2 event_id = f8
         2 encntr_slice_id = f8
         2 active_ind = i2
         2 allow_partial_ind = i2
         2 parent_entity_id = f8
         2 parent_entity_name = vc
         2 coding_parent_entity_id = f8
         2 coding_parent_entity_name = vc
     )
    ENDIF
    IF ( NOT (validate(add_coding_hist_reply,0)))
     RECORD add_coding_hist_reply(
       1 qual_cnt = i4
       1 qual[*]
         2 coding_hist_id = f8
         2 status = i4
     )
    ENDIF
    SELECT INTO "nl:"
     FROM coding c
     WHERE c.coding_id=new_coding_id
     DETAIL
      stat = alterlist(add_coding_hist_request->qual,1), add_coding_hist_request->qual[1].
      coding_hist_id = 0.0, add_coding_hist_request->qual[1].encntr_id = c.encntr_id,
      add_coding_hist_request->qual[1].person_id = c.person_id, add_coding_hist_request->qual[1].
      length_of_stay = c.length_of_stay, add_coding_hist_request->qual[1].birth_weight = c
      .birth_weight,
      add_coding_hist_request->qual[1].ascpay = c.ascpay, add_coding_hist_request->qual[1].
      completed_dt_tm = c.completed_dt_tm, add_coding_hist_request->qual[1].create_dt_tm = c
      .create_dt_tm,
      add_coding_hist_request->qual[1].create_prsnl_id = c.create_prsnl_id, add_coding_hist_request->
      qual[1].contributor_system_cd = c.contributor_system_cd, add_coding_hist_request->qual[1].
      beg_effective_dt_tm = cnvtdatetime(save_date),
      add_coding_hist_request->qual[1].end_effective_dt_tm = c.end_effective_dt_tm,
      add_coding_hist_request->qual[1].merged_encntr_id = c.merged_encntr_id, add_coding_hist_request
      ->qual[1].svc_cat_hist_id = c.svc_cat_hist_id,
      add_coding_hist_request->qual[1].coding_dt_tm = c.coding_dt_tm, add_coding_hist_request->qual[1
      ].coding_prsnl_id = c.coding_prsnl_id, add_coding_hist_request->qual[1].cancer_code_cnt = c
      .cancer_code_cnt,
      add_coding_hist_request->qual[1].event_id = c.event_id, add_coding_hist_request->qual[1].
      encntr_slice_id = c.encntr_slice_id, add_coding_hist_request->qual[1].active_ind = c.active_ind
      IF (mn_ch_parent_entity_exists > 1)
       IF (validate(add_coding_hist_request->qual[1].parent_entity_id))
        add_coding_hist_request->qual[1].parent_entity_id = validate(c.parent_entity_id,0.0),
        add_coding_hist_request->qual[1].parent_entity_name = validate(c.parent_entity_name," ")
        IF ((add_coding_hist_request->qual[1].parent_entity_id > 0.0))
         add_coding_hist_request->qual[1].coding_parent_entity_id = new_coding_id,
         add_coding_hist_request->qual[1].coding_parent_entity_name = "CODING"
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (((curqual=0) OR (size(add_coding_hist_request->qual,5)=0)) )
     SELECT INTO "nl:"
      FROM coding_specialty c
      WHERE c.coding_id=new_coding_id
      DETAIL
       stat = alterlist(add_coding_hist_request->qual,1), add_coding_hist_request->qual[1].
       coding_hist_id = 0.0, add_coding_hist_request->qual[1].encntr_id = c.encntr_id,
       add_coding_hist_request->qual[1].person_id = c.person_id, add_coding_hist_request->qual[1].
       length_of_stay = c.length_of_stay, add_coding_hist_request->qual[1].birth_weight = c
       .birth_weight,
       add_coding_hist_request->qual[1].ascpay = c.ascpay, add_coding_hist_request->qual[1].
       completed_dt_tm = c.completed_dt_tm, add_coding_hist_request->qual[1].create_dt_tm = c
       .create_dt_tm,
       add_coding_hist_request->qual[1].create_prsnl_id = c.create_prsnl_id, add_coding_hist_request
       ->qual[1].contributor_system_cd = c.contributor_system_cd, add_coding_hist_request->qual[1].
       beg_effective_dt_tm = cnvtdatetime(save_date),
       add_coding_hist_request->qual[1].end_effective_dt_tm = c.end_effective_dt_tm,
       add_coding_hist_request->qual[1].merged_encntr_id = c.merged_encntr_id,
       add_coding_hist_request->qual[1].svc_cat_hist_id = c.svc_cat_hist_id,
       add_coding_hist_request->qual[1].coding_dt_tm = c.coding_dt_tm, add_coding_hist_request->qual[
       1].coding_prsnl_id = c.coding_prsnl_id, add_coding_hist_request->qual[1].cancer_code_cnt = c
       .cancer_code_cnt,
       add_coding_hist_request->qual[1].event_id = c.event_id, add_coding_hist_request->qual[1].
       encntr_slice_id = c.encntr_slice_id, add_coding_hist_request->qual[1].active_ind = c
       .active_ind
       IF (mn_ch_parent_entity_exists > 1)
        IF (validate(add_coding_hist_request->qual[1].parent_entity_id))
         add_coding_hist_request->qual[1].parent_entity_id = validate(c.parent_entity_id,0.0),
         add_coding_hist_request->qual[1].parent_entity_name = validate(c.parent_entity_name," ")
         IF ((add_coding_hist_request->qual[1].parent_entity_id > 0.0))
          add_coding_hist_request->qual[1].coding_parent_entity_id = new_coding_id,
          add_coding_hist_request->qual[1].coding_parent_entity_name = "CODING_SPECIALTY"
         ENDIF
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
    IF (((curqual=0) OR (size(add_coding_hist_request->qual,5)=0)) )
     RETURN(0)
    ENDIF
    EXECUTE him_add_coding_hist
    IF (size(add_coding_hist_reply->qual,5)=0)
     RETURN(0)
    ENDIF
    IF ((add_coding_hist_reply->qual[1].status != true))
     RETURN(0)
    ENDIF
    RETURN(1)
  END ;Subroutine
  SUBROUTINE (endeffectcodinghistrow(modified_coding_id=f8,save_date=f8) =i2)
    IF ( NOT (validate(chg_coding_hist_request,0)))
     RECORD chg_coding_hist_request(
       1 call_echo_ind = i2
       1 qual[*]
         2 coding_hist_id = f8
         2 encntr_id = f8
         2 person_id = f8
         2 length_of_stay = i4
         2 birth_weight = i4
         2 ascpay = i4
         2 completed_dt_tm = dq8
         2 create_dt_tm = dq8
         2 create_prsnl_id = f8
         2 contributor_system_cd = f8
         2 beg_effective_dt_tm = dq8
         2 end_effective_dt_tm = dq8
         2 merged_encntr_id = f8
         2 svc_cat_hist_id = f8
         2 coding_dt_tm = dq8
         2 coding_prsnl_id = f8
         2 cancer_code_cnt = i4
         2 event_id = f8
         2 encntr_slice_id = f8
         2 updt_cnt = i4
         2 allow_partial_ind = i2
         2 version_ind = i2
         2 force_updt_ind = i2
         2 parent_entity_id = f8
         2 parent_entity_name = vc
         2 coding_parent_entity_id = f8
         2 coding_parent_entity_name = vc
     )
    ENDIF
    IF ( NOT (validate(chg_coding_hist_reply,0)))
     RECORD chg_coding_hist_reply(
       1 qual_cnt = i4
       1 qual[*]
         2 status = i4
     )
    ENDIF
    IF (mn_ch_parent_entity_exists > 1)
     SET ms_ch_parent_entity_parser = build2("(ch.coding_parent_entity_name = 'CODING' and",
      " ch.coding_parent_entity_id = modified_coding_id) or (ch.coding_parent_entity_name = ' ' and",
      " ch.coding_parent_entity_id = 0.0)")
     SET ms_ch_coding_parent_entity_parser =
     'ch.parent_entity_name in (" ", "ENCOUNTER", "ENCNTR_SLICE", "SERVICE_CATEGORY_HIST")'
    ENDIF
    SELECT INTO "nl:"
     FROM coding c,
      coding_hist ch
     PLAN (c
      WHERE c.coding_id=modified_coding_id)
      JOIN (ch
      WHERE ch.encntr_id=c.encntr_id
       AND ((ch.person_id+ 0)=c.person_id)
       AND ch.svc_cat_hist_id=c.svc_cat_hist_id
       AND ch.encntr_slice_id=c.encntr_slice_id
       AND ch.contributor_system_cd=c.contributor_system_cd
       AND ch.active_ind=1
       AND ch.beg_effective_dt_tm <= cnvtdatetime(save_date)
       AND ch.end_effective_dt_tm > cnvtdatetime(save_date)
       AND parser(ms_ch_parent_entity_parser)
       AND parser(ms_ch_coding_parent_entity_parser))
     ORDER BY c.coding_id, ch.beg_effective_dt_tm
     HEAD c.coding_id
      stat = alterlist(chg_coding_hist_request->qual,1), chg_coding_hist_request->qual[1].
      coding_hist_id = ch.coding_hist_id, chg_coding_hist_request->qual[1].encntr_id = ch.encntr_id,
      chg_coding_hist_request->qual[1].person_id = ch.person_id, chg_coding_hist_request->qual[1].
      length_of_stay = ch.length_of_stay, chg_coding_hist_request->qual[1].birth_weight = ch
      .birth_weight,
      chg_coding_hist_request->qual[1].ascpay = ch.ascpay, chg_coding_hist_request->qual[1].
      completed_dt_tm = ch.completed_dt_tm, chg_coding_hist_request->qual[1].create_dt_tm = ch
      .create_dt_tm,
      chg_coding_hist_request->qual[1].create_prsnl_id = ch.create_prsnl_id, chg_coding_hist_request
      ->qual[1].contributor_system_cd = ch.contributor_system_cd, chg_coding_hist_request->qual[1].
      beg_effective_dt_tm = ch.beg_effective_dt_tm,
      chg_coding_hist_request->qual[1].end_effective_dt_tm = cnvtdatetime(save_date),
      chg_coding_hist_request->qual[1].merged_encntr_id = ch.merged_encntr_id,
      chg_coding_hist_request->qual[1].svc_cat_hist_id = ch.svc_cat_hist_id,
      chg_coding_hist_request->qual[1].coding_dt_tm = ch.coding_dt_tm, chg_coding_hist_request->qual[
      1].coding_prsnl_id = ch.coding_prsnl_id, chg_coding_hist_request->qual[1].cancer_code_cnt = ch
      .cancer_code_cnt,
      chg_coding_hist_request->qual[1].event_id = ch.event_id, chg_coding_hist_request->qual[1].
      encntr_slice_id = ch.encntr_slice_id, chg_coding_hist_request->qual[1].updt_cnt = ch.updt_cnt
      IF (mn_ch_parent_entity_exists > 1)
       IF (validate(chg_coding_hist_request->qual[1].parent_entity_id))
        chg_coding_hist_request->qual[1].parent_entity_id = validate(c.parent_entity_id,0.0),
        chg_coding_hist_request->qual[1].parent_entity_name = validate(c.parent_entity_name," ")
        IF ((chg_coding_hist_request->qual[1].parent_entity_id > 0.0))
         chg_coding_hist_request->qual[1].coding_parent_entity_id = modified_coding_id,
         chg_coding_hist_request->qual[1].coding_parent_entity_name = "CODING"
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (mn_ch_parent_entity_exists > 1)
     SET ms_ch_parent_entity_parser = build2("(ch.coding_parent_entity_name = 'CODING_SPECIALTY' and",
      " ch.coding_parent_entity_id = modified_coding_id) or (ch.coding_parent_entity_name = ' ' and",
      " ch.coding_parent_entity_id = 0.0)")
    ENDIF
    IF (((curqual=0) OR (size(chg_coding_hist_request->qual,5)=0)) )
     SELECT INTO "nl:"
      FROM coding_specialty c,
       coding_hist ch
      PLAN (c
       WHERE c.coding_id=modified_coding_id)
       JOIN (ch
       WHERE ch.encntr_id=c.encntr_id
        AND ((ch.person_id+ 0)=c.person_id)
        AND ch.svc_cat_hist_id=c.svc_cat_hist_id
        AND ch.encntr_slice_id=c.encntr_slice_id
        AND ch.contributor_system_cd=c.contributor_system_cd
        AND ch.active_ind=1
        AND ch.beg_effective_dt_tm <= cnvtdatetime(save_date)
        AND ch.end_effective_dt_tm > cnvtdatetime(save_date)
        AND parser(ms_ch_parent_entity_parser)
        AND parser(ms_ch_coding_parent_entity_parser))
      ORDER BY c.coding_id, ch.beg_effective_dt_tm
      HEAD c.coding_id
       stat = alterlist(chg_coding_hist_request->qual,1), chg_coding_hist_request->qual[1].
       coding_hist_id = ch.coding_hist_id, chg_coding_hist_request->qual[1].encntr_id = ch.encntr_id,
       chg_coding_hist_request->qual[1].person_id = ch.person_id, chg_coding_hist_request->qual[1].
       length_of_stay = ch.length_of_stay, chg_coding_hist_request->qual[1].birth_weight = ch
       .birth_weight,
       chg_coding_hist_request->qual[1].ascpay = ch.ascpay, chg_coding_hist_request->qual[1].
       completed_dt_tm = ch.completed_dt_tm, chg_coding_hist_request->qual[1].create_dt_tm = ch
       .create_dt_tm,
       chg_coding_hist_request->qual[1].create_prsnl_id = ch.create_prsnl_id, chg_coding_hist_request
       ->qual[1].contributor_system_cd = ch.contributor_system_cd, chg_coding_hist_request->qual[1].
       beg_effective_dt_tm = ch.beg_effective_dt_tm,
       chg_coding_hist_request->qual[1].end_effective_dt_tm = cnvtdatetime(save_date),
       chg_coding_hist_request->qual[1].merged_encntr_id = ch.merged_encntr_id,
       chg_coding_hist_request->qual[1].svc_cat_hist_id = ch.svc_cat_hist_id,
       chg_coding_hist_request->qual[1].coding_dt_tm = ch.coding_dt_tm, chg_coding_hist_request->
       qual[1].coding_prsnl_id = ch.coding_prsnl_id, chg_coding_hist_request->qual[1].cancer_code_cnt
        = ch.cancer_code_cnt,
       chg_coding_hist_request->qual[1].event_id = ch.event_id, chg_coding_hist_request->qual[1].
       encntr_slice_id = ch.encntr_slice_id, chg_coding_hist_request->qual[1].updt_cnt = ch.updt_cnt
       IF (mn_ch_parent_entity_exists)
        IF (validate(chg_coding_hist_request->qual[1].parent_entity_id))
         chg_coding_hist_request->qual[1].parent_entity_id = validate(c.parent_entity_id,0.0),
         chg_coding_hist_request->qual[1].parent_entity_name = validate(c.parent_entity_name," ")
         IF ((chg_coding_hist_request->qual[1].parent_entity_id > 0.0))
          chg_coding_hist_request->qual[1].coding_parent_entity_id = modified_coding_id,
          chg_coding_hist_request->qual[1].coding_parent_entity_name = "CODING_SPECIALTY"
         ENDIF
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
    IF (((curqual=0) OR (size(chg_coding_hist_request->qual,5)=0)) )
     RETURN(1)
    ENDIF
    EXECUTE him_chg_coding_hist
    IF (size(chg_coding_hist_reply->qual,5)=0)
     RETURN(0)
    ENDIF
    IF ((chg_coding_hist_reply->qual[1].status != true))
     RETURN(0)
    ENDIF
    RETURN(1)
  END ;Subroutine
 ENDIF
 SET cust_ucb_dummy = 0
 IF ((rchildren->qual1[det_cnt].combine_action_cd=add))
  IF (mi_using_coding_hist=1)
   DECLARE mn_parent_entity_exists = i2 WITH protect, constant(checkdic("CODING.PARENT_ENTITY_ID","A",
     0))
   IF (mn_parent_entity_exists <= 1)
    SELECT INTO "nl:"
     FROM coding_specialty cs
     WHERE (cs.encntr_id=request->xxx_uncombine[ucb_cnt].from_xxx_id)
      AND cs.beg_effective_dt_tm <= cnvtdatetime(mq_save_date)
      AND cs.end_effective_dt_tm > cnvtdatetime(mq_save_date)
      AND cs.active_ind=1
     ORDER BY cs.contributor_system_cd, cs.coding_id DESC
     HEAD cs.contributor_system_cd
      upt_rec->qual_cnt += 1, stat = alterlist(upt_rec->qual,upt_rec->qual_cnt), upt_rec->qual[
      upt_rec->qual_cnt].coding_id = cs.coding_id
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM coding_specialty cs1,
      coding_specialty cs2
     PLAN (cs1
      WHERE (cs1.coding_id=rchildren->qual1[det_cnt].entity_id))
      JOIN (cs2
      WHERE cs2.encntr_id=cs1.encntr_id
       AND cs2.encntr_slice_id=cs1.encntr_slice_id
       AND cs2.svc_cat_hist_id=cs1.svc_cat_hist_id
       AND cs2.contributor_system_cd=cs1.contributor_system_cd
       AND cs2.beg_effective_dt_tm <= cnvtdatetime(mq_save_date)
       AND cs2.end_effective_dt_tm > cnvtdatetime(mq_save_date)
       AND cs2.active_ind=1
       AND ((cs2.parent_entity_name=cs1.parent_entity_name
       AND cs2.parent_entity_id=cs1.parent_entity_id) OR (cs1.parent_entity_id=0.0)) )
     ORDER BY cs2.contributor_system_cd, cs2.coding_id DESC
     HEAD cs2.contributor_system_cd
      upt_rec->qual_cnt += 1, stat = alterlist(upt_rec->qual,upt_rec->qual_cnt), upt_rec->qual[
      upt_rec->qual_cnt].coding_id = cs2.coding_id
     WITH nocounter
    ;end select
   ENDIF
   FOR (ml_index = 1 TO upt_rec->qual_cnt)
     SET mi_status = endeffectcodinghistrow(upt_rec->qual[ml_index].coding_id,mq_save_date)
     IF (mi_status=0)
      SET ucb_failed = update_error
      SET error_table = "CODING_HIST"
      GO TO exit_sub
     ENDIF
     SET mi_status = addcodinghistrow(upt_rec->qual[ml_index].coding_id,mq_save_date)
     IF (mi_status=0)
      SET ucb_failed = insert_error
      SET error_table = "CODING_HIST"
      GO TO exit_sub
     ENDIF
   ENDFOR
  ENDIF
 ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=del))
  CALL cust_ucb_del(cust_ucb_dummy)
 ELSE
  SET ucb_failed = data_error
  SET error_table = rchildren->qual1[det_cnt].entity_name
  GO TO exit_sub
 ENDIF
 SUBROUTINE cust_ucb_del(dummy)
  UPDATE  FROM coding_specialty cs
   SET cs.active_ind = rchildren->qual1[det_cnt].prev_active_ind, cs.active_status_cd =
    IF ((rchildren->qual1[det_cnt].prev_active_ind=1)) reqdata->active_status_cd
    ELSE reqdata->inactive_status_cd
    ENDIF
    , cs.end_effective_dt_tm = cnvtdatetime(rchildren->qual1[det_cnt].prev_end_eff_dt_tm),
    cs.updt_id = reqinfo->updt_id, cs.updt_dt_tm = cnvtdatetime(sysdate), cs.updt_applctx = reqinfo->
    updt_applctx,
    cs.updt_cnt = (cs.updt_cnt+ 1), cs.updt_task = reqinfo->updt_task
   WHERE (cs.coding_id=rchildren->qual1[det_cnt].entity_id)
    AND (((cs.encntr_id=request->xxx_uncombine[ucb_cnt].to_xxx_id)) OR ((cs.merged_encntr_id=request
   ->xxx_uncombine[ucb_cnt].to_xxx_id)))
   WITH nocounter
  ;end update
  IF (curqual != 0)
   SET activity_updt_cnt += 1
  ENDIF
 END ;Subroutine
#exit_sub
END GO
