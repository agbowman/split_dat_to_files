CREATE PROGRAM dm_ecmb_coding_specialty:dba
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
     add_coding_hist_request->qual[1].coding_dt_tm = c.coding_dt_tm, add_coding_hist_request->qual[1]
     .coding_prsnl_id = c.coding_prsnl_id, add_coding_hist_request->qual[1].cancer_code_cnt = c
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
     chg_coding_hist_request->qual[1].create_prsnl_id = ch.create_prsnl_id, chg_coding_hist_request->
     qual[1].contributor_system_cd = ch.contributor_system_cd, chg_coding_hist_request->qual[1].
     beg_effective_dt_tm = ch.beg_effective_dt_tm,
     chg_coding_hist_request->qual[1].end_effective_dt_tm = cnvtdatetime(save_date),
     chg_coding_hist_request->qual[1].merged_encntr_id = ch.merged_encntr_id, chg_coding_hist_request
     ->qual[1].svc_cat_hist_id = ch.svc_cat_hist_id,
     chg_coding_hist_request->qual[1].coding_dt_tm = ch.coding_dt_tm, chg_coding_hist_request->qual[1
     ].coding_prsnl_id = ch.coding_prsnl_id, chg_coding_hist_request->qual[1].cancer_code_cnt = ch
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
      chg_coding_hist_request->qual[1].coding_dt_tm = ch.coding_dt_tm, chg_coding_hist_request->qual[
      1].coding_prsnl_id = ch.coding_prsnl_id, chg_coding_hist_request->qual[1].cancer_code_cnt = ch
      .cancer_code_cnt,
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
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 from_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 encntr_id = f8
     2 person_id = f8
     2 svc_cat_hist_id = f8
     2 encntr_slice_id = f8
     2 completed_dt_tm = dq8
     2 merged_encntr_id = f8
     2 coding_prsnl_id = f8
     2 coding_dt_tm = dq8
     2 length_of_stay = i4
     2 birth_weight = i4
     2 ascpay = i4
     2 contributor_system_cd = f8
     2 end_effective_dt_tm = dq8
     2 attribute_name = c32
     2 parent_entity_id = f8
     2 parent_entity_name = vc
   1 to_rec[*]
     2 to_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 encntr_id = f8
     2 person_id = f8
     2 svc_cat_hist_id = f8
     2 encntr_slice_id = f8
     2 completed_dt_tm = dq8
     2 merged_encntr_id = f8
     2 coding_prsnl_id = f8
     2 coding_dt_tm = dq8
     2 length_of_stay = i4
     2 birth_weight = i4
     2 ascpay = i4
     2 contributor_system_cd = f8
     2 end_effective_dt_tm = dq8
     2 attribute_name = c32
     2 parent_entity_id = f8
     2 parent_entity_name = vc
 )
 FREE SET rreccodinghist
 RECORD rreccodinghist(
   1 qual_cnt = i4
   1 qual[*]
     2 from_ind = i2
     2 coding_id = f8
     2 contributor_system_cd = f8
 )
 DECLARE mq_save_date = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE ml_from_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_to_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_cust_new_nbr = f8 WITH protect, noconstant(0.0)
 DECLARE ml_index = i4 WITH protect, noconstant(0)
 DECLARE ml_index2 = i4 WITH protect, noconstant(0)
 DECLARE ml_coding_index = i4 WITH protect, noconstant(0)
 DECLARE mi_contrib_sys_found = i2 WITH protect, noconstant(0)
 DECLARE mf_coding_merge_contrib_sys_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",89,
   "HIMCODINGMRG"))
 DECLARE mn_parent_entity_exists = i2 WITH protect, constant(checkdic(
   "CODING_SPECIALTY.PARENT_ENTITY_ID","A",0))
 DECLARE ms_parent_entity_exists_tu_parser = vc WITH protect, noconstant("TU.encntr_slice_id = 0.0")
 DECLARE mn_drg_parent_entity_exists = i2 WITH protect, constant(checkdic("DRG.PARENT_ENTITY_ID","A",
   0))
 DECLARE ms_drg_parent_entity_exists_parser = vc WITH protect, noconstant("0 = 0")
 DECLARE ms_parent_entity_name = vc WITH protect, noconstant("")
 IF (mn_parent_entity_exists > 1)
  SET ms_parent_entity_exists_tu_parser = build2("TU.svc_cat_hist_id > 0.0",
   " or (TU.encntr_slice_id = 0.0 and TU.parent_entity_name != 'ENCNTR_SLICE')")
 ENDIF
 IF (mn_drg_parent_entity_exists > 1)
  SET ms_drg_parent_entity_exists_parser = build2(
   "d.parent_entity_name = outerjoin('CODING_SPECIALTY')",
   " and d.parent_entity_id = outerjoin(TU.coding_id)")
 ENDIF
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "ENCOUNTER"
  SET dcem_request->qual[1].child_entity = "CODING_SPECIALTY"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_ECMB_CODING_SPECIALTY"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 SELECT INTO "nl:"
  frm.*
  FROM coding_specialty frm
  WHERE (((frm.encntr_id=request->xxx_combine[icombine].from_xxx_id)) OR ((frm.merged_encntr_id=
  request->xxx_combine[icombine].from_xxx_id)))
   AND frm.active_ind=1
  DETAIL
   ml_from_cnt += 1
   IF (mod(ml_from_cnt,10)=1)
    stat = alterlist(rreclist->from_rec,(ml_from_cnt+ 9))
   ENDIF
   rreclist->from_rec[ml_from_cnt].from_id = frm.coding_id, rreclist->from_rec[ml_from_cnt].
   active_ind = frm.active_ind, rreclist->from_rec[ml_from_cnt].active_status_cd = frm
   .active_status_cd,
   rreclist->from_rec[ml_from_cnt].encntr_id = frm.encntr_id, rreclist->from_rec[ml_from_cnt].
   person_id = frm.person_id, rreclist->from_rec[ml_from_cnt].svc_cat_hist_id = frm.svc_cat_hist_id,
   rreclist->from_rec[ml_from_cnt].encntr_slice_id = frm.encntr_slice_id, rreclist->from_rec[
   ml_from_cnt].completed_dt_tm = frm.completed_dt_tm, rreclist->from_rec[ml_from_cnt].
   merged_encntr_id = frm.merged_encntr_id,
   rreclist->from_rec[ml_from_cnt].coding_prsnl_id = frm.coding_prsnl_id, rreclist->from_rec[
   ml_from_cnt].coding_dt_tm = frm.coding_dt_tm, rreclist->from_rec[ml_from_cnt].length_of_stay = frm
   .length_of_stay,
   rreclist->from_rec[ml_from_cnt].birth_weight = frm.birth_weight, rreclist->from_rec[ml_from_cnt].
   ascpay = frm.ascpay, rreclist->from_rec[ml_from_cnt].contributor_system_cd = frm
   .contributor_system_cd,
   rreclist->from_rec[ml_from_cnt].end_effective_dt_tm = frm.end_effective_dt_tm
   IF ((frm.encntr_id=request->xxx_combine[icombine].from_xxx_id))
    rreclist->from_rec[ml_from_cnt].attribute_name = "ENCNTR_ID"
   ELSE
    rreclist->from_rec[ml_from_cnt].attribute_name = "MERGED_ENCNTR_ID"
   ENDIF
   rreclist->from_rec[ml_from_cnt].parent_entity_id = validate(frm.parent_entity_id,0.0), rreclist->
   from_rec[ml_from_cnt].parent_entity_name = validate(frm.parent_entity_name," "),
   CALL store_for_history(1,frm.coding_id,frm.contributor_system_cd)
  WITH forupdatewait(frm)
 ;end select
 FOR (ml_index = 1 TO ml_from_cnt)
   CALL del_rec(rreclist->from_rec[ml_index].from_id,rreclist->from_rec[ml_index].active_ind,rreclist
    ->from_rec[ml_index].active_status_cd,rreclist->from_rec[ml_index].end_effective_dt_tm,rreclist->
    from_rec[ml_index].attribute_name)
 ENDFOR
 IF (ml_from_cnt > 0)
  SELECT INTO "nl:"
   tu.*
   FROM coding_specialty tu,
    drg d
   PLAN (tu
    WHERE (((tu.encntr_id=request->xxx_combine[icombine].to_xxx_id)) OR ((tu.merged_encntr_id=request
    ->xxx_combine[icombine].to_xxx_id)))
     AND tu.active_ind=1
     AND parser(ms_parent_entity_exists_tu_parser))
    JOIN (d
    WHERE (d.encntr_id= Outerjoin(tu.encntr_id))
     AND (d.svc_cat_hist_id= Outerjoin(tu.svc_cat_hist_id))
     AND (d.encntr_slice_id= Outerjoin(0.0))
     AND (d.contributor_system_cd= Outerjoin(tu.contributor_system_cd))
     AND (d.active_ind= Outerjoin(tu.active_ind))
     AND (d.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(mq_save_date)))
     AND (d.end_effective_dt_tm> Outerjoin(cnvtdatetime(mq_save_date)))
     AND parser(ms_drg_parent_entity_exists_parser))
   HEAD tu.coding_id
    ms_parent_entity_name = validate(tu.parent_entity_name," ")
    IF (((ms_parent_entity_name IN (" ", "ENCOUNTER", "SERVICE_CATEGORY_HIST")) OR (d.drg_id > 0.0))
    )
     ml_to_cnt += 1
     IF (mod(ml_to_cnt,10)=1)
      stat = alterlist(rreclist->to_rec,(ml_to_cnt+ 9))
     ENDIF
     rreclist->to_rec[ml_to_cnt].to_id = tu.coding_id, rreclist->to_rec[ml_to_cnt].active_ind = tu
     .active_ind, rreclist->to_rec[ml_to_cnt].active_status_cd = tu.active_status_cd,
     rreclist->to_rec[ml_to_cnt].encntr_id = tu.encntr_id, rreclist->to_rec[ml_to_cnt].person_id = tu
     .person_id, rreclist->to_rec[ml_to_cnt].svc_cat_hist_id = tu.svc_cat_hist_id,
     rreclist->to_rec[ml_to_cnt].encntr_slice_id = tu.encntr_slice_id, rreclist->to_rec[ml_to_cnt].
     completed_dt_tm = cnvtdatetime(tu.completed_dt_tm), rreclist->to_rec[ml_to_cnt].merged_encntr_id
      = tu.merged_encntr_id,
     rreclist->to_rec[ml_to_cnt].coding_prsnl_id = tu.coding_prsnl_id, rreclist->to_rec[ml_to_cnt].
     coding_dt_tm = cnvtdatetime(tu.coding_dt_tm), rreclist->to_rec[ml_to_cnt].length_of_stay = tu
     .length_of_stay,
     rreclist->to_rec[ml_to_cnt].birth_weight = tu.birth_weight, rreclist->to_rec[ml_to_cnt].ascpay
      = tu.ascpay, rreclist->to_rec[ml_to_cnt].contributor_system_cd = tu.contributor_system_cd,
     rreclist->to_rec[ml_to_cnt].end_effective_dt_tm = cnvtdatetime(tu.end_effective_dt_tm)
     IF ((tu.encntr_id=request->xxx_combine[icombine].to_xxx_id))
      rreclist->to_rec[ml_to_cnt].attribute_name = "ENCNTR_ID"
     ELSE
      rreclist->to_rec[ml_to_cnt].attribute_name = "MERGED_ENCNTR_ID"
     ENDIF
     rreclist->to_rec[ml_to_cnt].parent_entity_id = validate(tu.parent_entity_id,0.0), rreclist->
     to_rec[ml_to_cnt].parent_entity_name = ms_parent_entity_name,
     CALL store_for_history(0,tu.coding_id,tu.contributor_system_cd)
    ENDIF
   WITH forupdatewait(tu)
  ;end select
  FOR (ml_index = 1 TO ml_to_cnt)
    SET mf_cust_new_nbr = 0.0
    IF ((rreclist->to_rec[ml_index].contributor_system_cd != mf_coding_merge_contrib_sys_cd))
     SELECT INTO "nl:"
      num = seq(profile_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       mf_cust_new_nbr = cnvtreal(num)
      WITH format, counter
     ;end select
     INSERT  FROM coding_specialty cs
      SET cs.coding_id = mf_cust_new_nbr, cs.encntr_id = rreclist->to_rec[ml_index].encntr_id, cs
       .person_id = rreclist->to_rec[ml_index].person_id,
       cs.svc_cat_hist_id = rreclist->to_rec[ml_index].svc_cat_hist_id, cs.length_of_stay = rreclist
       ->to_rec[ml_index].length_of_stay, cs.birth_weight = rreclist->to_rec[ml_index].birth_weight,
       cs.ascpay = rreclist->to_rec[ml_index].ascpay, cs.contributor_system_cd = rreclist->to_rec[
       ml_index].contributor_system_cd, cs.create_dt_tm = cnvtdatetime(mq_save_date),
       cs.completed_dt_tm = null, cs.create_prsnl_id = reqinfo->updt_id, cs.coding_prsnl_id =
       rreclist->to_rec[ml_index].coding_prsnl_id,
       cs.merged_encntr_id = rreclist->to_rec[ml_index].merged_encntr_id, cs.coding_dt_tm =
       cnvtdatetime(rreclist->to_rec[ml_index].coding_dt_tm), cs.updt_cnt = 0,
       cs.active_ind = 1, cs.active_status_cd = reqdata->active_status_cd, cs.active_status_dt_tm =
       cnvtdatetime(mq_save_date),
       cs.active_status_prsnl_id = reqinfo->updt_id, cs.beg_effective_dt_tm = cnvtdatetime(
        mq_save_date), cs.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"),
       cs.updt_dt_tm = cnvtdatetime(mq_save_date), cs.updt_id = reqinfo->updt_id, cs.updt_applctx =
       reqinfo->updt_applctx,
       cs.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (mn_parent_entity_exists > 1
      AND (rreclist->to_rec[ml_index].parent_entity_id > 0.0))
      UPDATE  FROM coding_specialty cs
       SET cs.parent_entity_id = rreclist->to_rec[ml_index].parent_entity_id, cs.parent_entity_name
         = rreclist->to_rec[ml_index].parent_entity_name
       WHERE cs.coding_id=mf_cust_new_nbr
      ;end update
     ENDIF
     SET icombinedet += 1
     SET stat = alterlist(request->xxx_combine_det,icombinedet)
     SET request->xxx_combine_det[icombinedet].combine_action_cd = add
     SET request->xxx_combine_det[icombinedet].entity_id = mf_cust_new_nbr
     SET request->xxx_combine_det[icombinedet].entity_name = "CODING_SPECIALTY"
     SET request->xxx_combine_det[icombinedet].attribute_name = rreclist->to_rec[ml_index].
     attribute_name
     SET request->xxx_combine_det[icombinedet].prev_active_ind = 1
     SET request->xxx_combine_det[icombinedet].prev_active_status_cd = reqdata->active_status_cd
     SET request->xxx_combine_det[icombinedet].prev_end_eff_dt_tm = cnvtdatetime(
      "31-DEC-2100 00:00:00")
    ENDIF
    CALL del_rec(rreclist->to_rec[ml_index].to_id,rreclist->to_rec[ml_index].active_ind,rreclist->
     to_rec[ml_index].active_status_cd,rreclist->to_rec[ml_index].end_effective_dt_tm,rreclist->
     to_rec[ml_index].attribute_name)
    IF (should_update_history(rreclist->to_rec[ml_index].to_id)=1)
     IF (mf_cust_new_nbr > 0.0)
      SET mi_status = addcodinghistrow(mf_cust_new_nbr,mq_save_date)
      IF (mi_status=0)
       SET failed = insert_error
       GO TO exit_sub
      ENDIF
     ENDIF
     SET mi_status = endeffectcodinghistrow(rreclist->to_rec[ml_index].to_id,mq_save_date)
     IF (mi_status=0)
      SET failed = update_error
      GO TO exit_sub
     ENDIF
    ENDIF
  ENDFOR
  FOR (ml_index = 1 TO ml_from_cnt)
    IF ((((rreclist->from_rec[ml_index].svc_cat_hist_id > 0.0)) OR ((rreclist->from_rec[ml_index].
    encntr_slice_id=0.0)
     AND (rreclist->from_rec[ml_index].parent_entity_name IN (" ", "ENCOUNTER",
    "SERVICE_CATEGORY_HIST")))) )
     SET mi_contrib_sys_found = 0
     FOR (ml_index2 = 1 TO ml_to_cnt)
       IF ((rreclist->from_rec[ml_index].contributor_system_cd=rreclist->to_rec[ml_index2].
       contributor_system_cd)
        AND (rreclist->to_rec[ml_index].encntr_slice_id=0.0))
        SET mi_contrib_sys_found = 1
        SET ml_index2 = ml_to_cnt
       ENDIF
     ENDFOR
     IF (mi_contrib_sys_found=0
      AND (rreclist->from_rec[ml_index].contributor_system_cd != mf_coding_merge_contrib_sys_cd))
      SET mf_cust_new_nbr = 0.0
      SELECT INTO "nl:"
       num = seq(profile_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        mf_cust_new_nbr = cnvtreal(num)
       WITH format, counter
      ;end select
      INSERT  FROM coding_specialty cs
       SET cs.coding_id = mf_cust_new_nbr, cs.encntr_id = request->xxx_combine[icombine].to_xxx_id,
        cs.person_id = rreclist->from_rec[ml_index].person_id,
        cs.svc_cat_hist_id = rreclist->from_rec[ml_index].svc_cat_hist_id, cs.length_of_stay =
        rreclist->from_rec[ml_index].length_of_stay, cs.birth_weight = rreclist->from_rec[ml_index].
        birth_weight,
        cs.ascpay = rreclist->from_rec[ml_index].ascpay, cs.contributor_system_cd = rreclist->
        from_rec[ml_index].contributor_system_cd, cs.create_dt_tm = cnvtdatetime(mq_save_date),
        cs.completed_dt_tm = null, cs.create_prsnl_id = reqinfo->updt_id, cs.merged_encntr_id =
        rreclist->from_rec[ml_index].merged_encntr_id,
        cs.coding_prsnl_id = rreclist->from_rec[ml_index].coding_prsnl_id, cs.coding_dt_tm =
        cnvtdatetime(rreclist->from_rec[ml_index].coding_dt_tm), cs.updt_cnt = 0,
        cs.active_ind = 1, cs.active_status_cd = reqdata->active_status_cd, cs.active_status_dt_tm =
        cnvtdatetime(mq_save_date),
        cs.active_status_prsnl_id = reqinfo->updt_id, cs.beg_effective_dt_tm = cnvtdatetime(
         mq_save_date), cs.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"),
        cs.updt_dt_tm = cnvtdatetime(mq_save_date), cs.updt_id = reqinfo->updt_id, cs.updt_applctx =
        reqinfo->updt_applctx,
        cs.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (mn_parent_entity_exists > 1
       AND (rreclist->from_rec[ml_index].parent_entity_id > 0.0))
       UPDATE  FROM coding_specialty cs
        SET cs.parent_entity_id = rreclist->from_rec[ml_index].parent_entity_id, cs
         .parent_entity_name = rreclist->from_rec[ml_index].parent_entity_name
        WHERE cs.coding_id=mf_cust_new_nbr
       ;end update
      ENDIF
      SET icombinedet += 1
      SET stat = alterlist(request->xxx_combine_det,icombinedet)
      SET request->xxx_combine_det[icombinedet].combine_action_cd = add
      SET request->xxx_combine_det[icombinedet].entity_id = mf_cust_new_nbr
      SET request->xxx_combine_det[icombinedet].entity_name = "CODING_SPECIALTY"
      SET request->xxx_combine_det[icombinedet].attribute_name = rreclist->from_rec[ml_index].
      attribute_name
      SET request->xxx_combine_det[icombinedet].prev_active_ind = 1
      SET request->xxx_combine_det[icombinedet].prev_end_eff_dt_tm = cnvtdatetime(
       "31-DEC-2100 00:00:00")
      IF (should_update_history(rreclist->from_rec[ml_index].from_id)=1)
       SET mi_status = addcodinghistrow(mf_cust_new_nbr,mq_save_date)
       IF (mi_status=0)
        SET failed = insert_error
        GO TO exit_sub
       ENDIF
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE (del_rec(entity_id=f8,prev_active_ind=i2,prev_active_status_cd=f8,prev_end_eff_dt_tm=f8,
  attribute_name=c32) =i2)
   UPDATE  FROM coding_specialty cs
    SET cs.active_ind = 0, cs.active_status_cd = combinedaway, cs.active_status_dt_tm = cnvtdatetime(
      mq_save_date),
     cs.active_status_prsnl_id = reqinfo->updt_id, cs.end_effective_dt_tm = cnvtdatetime(mq_save_date
      ), cs.updt_cnt = (cs.updt_cnt+ 1),
     cs.updt_id = reqinfo->updt_id, cs.updt_applctx = reqinfo->updt_applctx, cs.updt_task = reqinfo->
     updt_task,
     cs.updt_dt_tm = cnvtdatetime(sysdate)
    WHERE cs.coding_id=entity_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = entity_id
   SET request->xxx_combine_det[icombinedet].entity_name = "CODING_SPECIALTY"
   SET request->xxx_combine_det[icombinedet].attribute_name = attribute_name
   SET request->xxx_combine_det[icombinedet].prev_active_ind = prev_active_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = prev_active_status_cd
   SET request->xxx_combine_det[icombinedet].prev_end_eff_dt_tm = cnvtdatetime(prev_end_eff_dt_tm)
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = substring(1,132,build(
      "No values found on the coding_specialty table with coding_id = ",entity_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (store_for_history(from_ind=i2,coding_id=f8,contributor_system_cd=f8) =null)
   SET mi_contrib_sys_found = 0
   FOR (ml_coding_index = 1 TO rreccodinghist->qual_cnt)
     IF ((rreccodinghist->qual[ml_coding_index].from_ind=from_ind)
      AND (rreccodinghist->qual[ml_coding_index].contributor_system_cd=contributor_system_cd))
      IF ((coding_id > rreccodinghist->qual[ml_coding_index].coding_id))
       SET rreccodinghist->qual[ml_coding_index].coding_id = coding_id
      ENDIF
      SET mi_contrib_sys_found = 1
      SET ml_coding_index = rreccodinghist->qual_cnt
     ENDIF
   ENDFOR
   IF (mi_contrib_sys_found=0
    AND contributor_system_cd > 0.0)
    SET rreccodinghist->qual_cnt += 1
    SET stat = alterlist(rreccodinghist->qual,rreccodinghist->qual_cnt)
    SET rreccodinghist->qual[rreccodinghist->qual_cnt].from_ind = from_ind
    SET rreccodinghist->qual[rreccodinghist->qual_cnt].coding_id = coding_id
    SET rreccodinghist->qual[rreccodinghist->qual_cnt].contributor_system_cd = contributor_system_cd
   ENDIF
 END ;Subroutine
 SUBROUTINE (should_update_history(coding_id=f8) =i2)
  FOR (ml_coding_index = 1 TO rreccodinghist->qual_cnt)
    IF ((rreccodinghist->qual[ml_coding_index].coding_id=coding_id))
     RETURN(1)
    ENDIF
  ENDFOR
  RETURN(0)
 END ;Subroutine
#exit_sub
 FREE SET rreclist
END GO
