CREATE PROGRAM dm_ocmb_patient_event_detail:dba
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
 SUBROUTINE (check_error(sbr_ceprocess=vc) =i2)
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
 CALL echo("*****dm_cmb_pm_hist_routines.inc - 565951****")
 DECLARE dm_cmb_detect_pm_hist(null) = i4
 SUBROUTINE dm_cmb_detect_pm_hist(null)
   RETURN(1)
 END ;Subroutine
 IF ((validate(dcipht_request->pm_hist_tracking_id,- (9))=- (9)))
  RECORD dcipht_request(
    1 pm_hist_tracking_id = f8
    1 encntr_id = f8
    1 person_id = f8
    1 transaction_type_txt = c3
    1 transaction_reason_txt = c30
  )
 ENDIF
 IF (validate(dcipht_reply->status,"b")="b")
  RECORD dcipht_reply(
    1 status = c1
    1 err_msg = c255
  )
 ENDIF
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 from_id = f8
     2 active_ind = i4
     2 patient_event_id = f8
 )
 SET count1 = 0
 SET count2 = 0
 DECLARE initialize_hist_id(null) = i4
 DECLARE v_cust_count1 = i4 WITH protect, noconstant(0)
 DECLARE v_cust_count2 = i4 WITH protect, noconstant(0)
 DECLARE v_cust_loopcount = i4 WITH protect, noconstant(0)
 DECLARE v_cust_loopcount2 = i4 WITH protect, noconstant(0)
 DECLARE encntr_event_ind = i2 WITH protect, noconstant(0)
 DECLARE parent_entity_id = f8 WITH protect, noconstant(0)
 DECLARE v_hist_init_ind = i2 WITH protect, noconstant(0)
 DECLARE dhistid = f8 WITH protect, noconstant(0.0)
 DECLARE trans_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(sysdate))
 FREE SET eventlist
 RECORD eventlist(
   1 patient_events[*]
     2 patient_event_id = f8
     2 active_status_cd = f8
     2 patient_event_details[*]
       3 patient_event_detail_id = f8
       3 pe_value_meaning = vc
       3 pe_value_dt_tm = dq8
       3 pe_value_numeric = i4
       3 pe_value_string = vc
       3 pe_value_cd = f8
       3 pe_value_id = f8
       3 pe_value_name = vc
       3 active_status_cd = f8
 )
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "ORGANIZATION"
  SET dcem_request->qual[1].child_entity = "PATIENT_EVENT_DETAIL"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "dm_ocmb_patient_event_detail"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 1
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 SELECT INTO "nl:"
  frm.patient_event_detail_id, frm.active_ind, frm.patient_event_id
  FROM patient_event_detail frm
  WHERE (frm.pe_value_id=request->xxx_combine[icombine].from_xxx_id)
   AND frm.pe_value_name="ORGANIZATION"
  DETAIL
   v_cust_count1 += 1
   IF (mod(v_cust_count1,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count1].from_id = frm.patient_event_detail_id, rreclist->from_rec[
   v_cust_count1].active_ind = frm.active_ind, rreclist->from_rec[v_cust_count1].patient_event_id =
   frm.patient_event_id
  FOOT REPORT
   stat = alterlist(rreclist->from_rec,v_cust_count1)
  WITH forupdatewait(frm)
 ;end select
 IF (v_cust_count1 > 0)
  FOR (v_cust_loopcount = 1 TO v_cust_count1)
    IF ((rreclist->from_rec[v_cust_loopcount].active_ind=0))
     IF (upt_from(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
      to_xxx_id)=0)
      GO TO exit_sub
     ENDIF
    ELSE
     SET fromeventindex = populate_events(rreclist->from_rec[v_cust_loopcount].patient_event_id)
     SET eventcount = size(eventlist->patient_events,5)
     IF (eventcount <= 1)
      IF (upt_from(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
       to_xxx_id)=0)
       GO TO exit_sub
      ENDIF
     ELSE
      SET fromdetailindex = populate_event_details(fromeventindex,rreclist->from_rec[v_cust_loopcount
       ].from_id)
      SET eventlist->patient_events[fromeventindex].patient_event_details[fromdetailindex].
      pe_value_id = request->xxx_combine[icombine].to_xxx_id
      SET duplicateevent = false
      IF (fromeventindex > 1)
       SET duplicateevent = are_events_duplicate((fromeventindex - 1),fromeventindex)
      ENDIF
      IF (duplicateevent=false
       AND fromeventindex < eventcount)
       SET duplicateevent = are_events_duplicate(fromeventindex,(fromeventindex+ 1))
      ENDIF
      IF (duplicateevent=true)
       IF (del_from(fromeventindex,rreclist->from_rec[v_cust_loopcount].from_id,rreclist->from_rec[
        v_cust_loopcount].active_ind,request->xxx_combine[icombine].to_xxx_id)=0)
        GO TO exit_sub
       ENDIF
      ELSE
       IF (upt_from(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
        to_xxx_id)=0)
        GO TO exit_sub
       ENDIF
      ENDIF
     ENDIF
     SET stat = initrec(eventlist)
    ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE (del_from(event_index=i4,s_df_pk_id=f8,s_df_prev_act_ind=i2,s_df_to_fk_id=f8) =i4)
   SET detailsize = size(eventlist->patient_events[event_index].patient_event_details,5)
   DECLARE expindex = i4
   UPDATE  FROM patient_event_detail frm
    SET frm.active_ind = false, frm.active_status_cd = combinedaway, frm.active_status_dt_tm =
     cnvtdatetime(trans_dt_tm),
     frm.active_status_prsnl_id = reqinfo->updt_id, frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id =
     reqinfo->updt_id,
     frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm =
     cnvtdatetime(trans_dt_tm),
     frm.pe_value_id = evaluate2(
      IF (frm.patient_event_detail_id=s_df_pk_id) s_df_to_fk_id
      ELSE frm.pe_value_id
      ENDIF
      )
    WHERE expand(expindex,1,detailsize,frm.patient_event_detail_id,eventlist->patient_events[
     event_index].patient_event_details[expindex].patient_event_detail_id)
    WITH nocounter
   ;end update
   FOR (i = 1 TO detailsize)
     SET icombinedet += 1
     SET stat = alterlist(request->xxx_combine_det,icombinedet)
     SET request->xxx_combine_det[icombinedet].combine_action_cd = del
     SET request->xxx_combine_det[icombinedet].entity_id = eventlist->patient_events[event_index].
     patient_event_details[i].patient_event_detail_id
     SET request->xxx_combine_det[icombinedet].entity_name = "PATIENT_EVENT_DETAIL"
     SET request->xxx_combine_det[icombinedet].prev_active_status_cd = eventlist->patient_events[
     event_index].patient_event_details[i].active_status_cd
     IF ((eventlist->patient_events[event_index].patient_event_details[i].patient_event_detail_id=
     s_df_pk_id))
      SET request->xxx_combine_det[icombinedet].attribute_name = "PE_VALUE_ID"
      SET request->xxx_combine_det[icombinedet].prev_active_ind = s_df_prev_act_ind
     ELSE
      SET request->xxx_combine_det[icombinedet].attribute_name = "PATIENT_EVENT_DETAIL"
      SET request->xxx_combine_det[icombinedet].prev_active_ind = 1
     ENDIF
     SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
     SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "PATIENT_EVENT_DETAIL_ID"
     SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
     SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = eventlist->patient_events[
     event_index].patient_event_details[i].patient_event_detail_id
     IF (curqual=0)
      SET failed = delete_error
      SET request->error_message = build(
       "DEL_FROM: No values found on the credential table with credential_id = ",s_c_id)
      RETURN(0)
     ENDIF
     IF (add_detail_hist(eventlist->patient_events[event_index].patient_event_details[i].
      patient_event_detail_id)=0)
      SET failed = insert_error
      SET request->error_message = substring(1,132,build(
        "Could not insert del history for PATIENT_EVENT_DETAIL with pk=",eventlist->patient_events[
        event_index].patient_event_details[i].patient_event_detail_id))
      RETURN(0)
     ENDIF
   ENDFOR
   UPDATE  FROM patient_event frm
    SET frm.active_ind = false, frm.active_status_cd = combinedaway, frm.active_status_dt_tm =
     cnvtdatetime(trans_dt_tm),
     frm.active_status_prsnl_id = reqinfo->updt_id, frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id =
     reqinfo->updt_id,
     frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm =
     cnvtdatetime(trans_dt_tm)
    WHERE (frm.patient_event_id=eventlist->patient_events[event_index].patient_event_id)
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = eventlist->patient_events[event_index].
   patient_event_id
   SET request->xxx_combine_det[icombinedet].entity_name = "PATIENT_EVENT_DETAIL"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = 1
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = eventlist->patient_events[
   event_index].active_status_cd
   SET request->xxx_combine_det[icombinedet].attribute_name = "PATIENT_EVENT"
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "PATIENT_EVENT_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = eventlist->patient_events[
   event_index].patient_event_id
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = build(
     "DEL_FROM: No values found on the credential table with credential_id = ",s_c_id)
    RETURN(0)
   ENDIF
   IF (add_event_hist(eventlist->patient_events[event_index].patient_event_id)=0)
    SET failed = insert_error
    SET request->error_message = substring(1,132,build(
      "Could not insert del history for PATIENT_EVENT with pk=",eventlist->patient_events[event_index
      ].patient_event_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (upt_from(s_uf_pk_id=f8,s_uf_to_fk_id=f8) =i4)
   UPDATE  FROM patient_event_detail frm
    SET frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo
     ->updt_applctx,
     frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm = cnvtdatetime(trans_dt_tm), frm.pe_value_id
      = s_uf_to_fk_id
    WHERE frm.patient_event_detail_id=s_uf_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_name = "PATIENT_EVENT_DETAIL"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PE_VALUE_ID"
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "PATIENT_EVENT_DETAIL_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = s_uf_pk_id
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = build(
     "Couldn't update PATIENT_EVENT_DETAIL record with PATIENT_EVENT_DETAIL_ID = ",s_uf_pk_id)
    RETURN(0)
   ENDIF
   IF (add_detail_hist(s_uf_pk_id)=0)
    SET failed = insert_error
    SET request->error_message = substring(1,132,build(
      "Could not insert updt history for PATIENT_EVENT_DETAIL with pk=",s_uf_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (add_detail_hist(s_at_to_parent_pk_id=f8) =i4)
   DECLARE v_hist_at_new_id = f8 WITH protect, noconstant(0.0)
   CALL initialize_hist_id(null)
   IF (dhistid <= 0.0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    y = seq(encounter_seq,nextval)
    FROM dual
    DETAIL
     v_hist_at_new_id = cnvtreal(y)
    WITH nocounter
   ;end select
   SET stat = alterlist(dm_cmb_cust_cols2->add_col_val,5)
   SET dm_cmb_cust_cols2->add_col_val[1].col_name = "PATIENT_EVENT_DETAIL_HIST_ID"
   SET dm_cmb_cust_cols2->add_col_val[1].col_value = build(v_hist_at_new_id)
   SET dm_cmb_cust_cols2->add_col_val[2].col_name = "PM_HIST_TRACKING_ID"
   SET dm_cmb_cust_cols2->add_col_val[2].col_value = build(dhistid)
   SET dm_cmb_cust_cols2->add_col_val[3].col_name = "CHANGE_BIT"
   SET dm_cmb_cust_cols2->add_col_val[3].col_value = build(0)
   SET dm_cmb_cust_cols2->add_col_val[4].col_name = "TRACKING_BIT"
   SET dm_cmb_cust_cols2->add_col_val[4].col_value = build(0)
   SET dm_cmb_cust_cols2->add_col_val[5].col_name = "TRANSACTION_DT_TM"
   SET dm_cmb_cust_cols2->add_col_val[5].col_value = "null"
   SET stat = alterlist(dm_cmb_cust_cols2->where_col_val,1)
   SET dm_cmb_cust_cols2->where_col_val[1].col_name = "PATIENT_EVENT_DETAIL_ID"
   SET dm_cmb_cust_cols2->where_col_val[1].col_value = build(s_at_to_parent_pk_id)
   SET dm_cmb_cust_cols2->tbl_name = "PATIENT_EVENT_DETAIL_HIST"
   SET dm_cmb_cust_cols2->sub_select_from_tbl = "PATIENT_EVENT_DETAIL"
   EXECUTE dm_cmb_get_cust_cols  WITH replace("DM_CMB_CUST_COLS","DM_CMB_CUST_COLS2")
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   EXECUTE dm_cmb_ins_cust_row  WITH replace("DM_CMB_CUST_COLS","DM_CMB_CUST_COLS2")
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (add_event_hist(s_at_to_parent_pk_id=f8) =i4)
   DECLARE v_hist_at_new_id = f8 WITH protect, noconstant(0.0)
   CALL initialize_hist_id(null)
   IF (dhistid <= 0.0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    y = seq(encounter_seq,nextval)
    FROM dual
    DETAIL
     v_hist_at_new_id = cnvtreal(y)
    WITH nocounter
   ;end select
   SET stat = alterlist(dm_cmb_cust_cols2->add_col_val,5)
   SET dm_cmb_cust_cols2->add_col_val[1].col_name = "PATIENT_EVENT_HIST_ID"
   SET dm_cmb_cust_cols2->add_col_val[1].col_value = build(v_hist_at_new_id)
   SET dm_cmb_cust_cols2->add_col_val[2].col_name = "PM_HIST_TRACKING_ID"
   SET dm_cmb_cust_cols2->add_col_val[2].col_value = build(dhistid)
   SET dm_cmb_cust_cols2->add_col_val[3].col_name = "CHANGE_BIT"
   SET dm_cmb_cust_cols2->add_col_val[3].col_value = build(0)
   SET dm_cmb_cust_cols2->add_col_val[4].col_name = "TRACKING_BIT"
   SET dm_cmb_cust_cols2->add_col_val[4].col_value = build(0)
   SET dm_cmb_cust_cols2->add_col_val[5].col_name = "TRANSACTION_DT_TM"
   SET dm_cmb_cust_cols2->add_col_val[5].col_value = "null"
   SET stat = alterlist(dm_cmb_cust_cols2->where_col_val,1)
   SET dm_cmb_cust_cols2->where_col_val[1].col_name = "PATIENT_EVENT_ID"
   SET dm_cmb_cust_cols2->where_col_val[1].col_value = build(s_at_to_parent_pk_id)
   SET dm_cmb_cust_cols2->tbl_name = "PATIENT_EVENT_HIST"
   SET dm_cmb_cust_cols2->sub_select_from_tbl = "PATIENT_EVENT"
   EXECUTE dm_cmb_get_cust_cols  WITH replace("DM_CMB_CUST_COLS","DM_CMB_CUST_COLS2")
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   EXECUTE dm_cmb_ins_cust_row  WITH replace("DM_CMB_CUST_COLS","DM_CMB_CUST_COLS2")
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE initialize_hist_id(null)
   IF (v_hist_init_ind=0)
    SET v_hist_init_ind = 1
    SELECT INTO "nl:"
     y = seq(person_seq,nextval)
     FROM dual
     DETAIL
      dhistid = cnvtreal(y)
     WITH nocounter
    ;end select
    SET dcipht_request->pm_hist_tracking_id = dhistid
    IF (encntr_event_ind=true)
     SET dcipht_request->encntr_id = parent_entity_id
    ELSE
     SET dcipht_request->person_id = parent_entity_id
    ENDIF
    SET dcipht_request->transaction_type_txt = "CMB"
    SET dcipht_request->transaction_reason_txt = "DM_OCMB_PATIENT_EVENT_DETAIL"
    EXECUTE dm_cmb_ins_pm_hist_tracking
    IF ((dcipht_reply->status="F"))
     SET failed = insert_error
     SET request->error_message = dcipht_reply->err_msg
     SET dhistid = 0.0
     RETURN(0)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE populate_events(event_id)
   SET fromeventindex = 0
   SELECT INTO "nl:"
    pe.patient_event_id, pe.active_status_cd, j.encntr_id,
    j.person_id
    FROM patient_event pe,
     patient_event j
    PLAN (pe
     WHERE pe.active_ind=1
      AND pe.event_dt_tm IS NOT null)
     JOIN (j
     WHERE j.patient_event_id=event_id
      AND pe.event_type_cd=j.event_type_cd
      AND evaluate2(
      IF (j.encntr_id > 0) j.encntr_id
      ELSE j.person_id
      ENDIF
      )=evaluate2(
      IF (j.encntr_id > 0) pe.encntr_id
      ELSE pe.person_id
      ENDIF
      ))
    ORDER BY pe.event_dt_tm
    HEAD REPORT
     eventcount = 0
    HEAD j.patient_event_id
     IF (j.encntr_id > 0)
      encntr_event_ind = true, parent_entity_id = pe.encntr_id
     ELSE
      encntr_event_ind = false, parent_entity_id = pe.person_id
     ENDIF
    DETAIL
     eventcount += 1
     IF (mod(eventcount,10)=1)
      stat = alterlist(eventlist->patient_events,(eventcount+ 9))
     ENDIF
     eventlist->patient_events[eventcount].patient_event_id = pe.patient_event_id, eventlist->
     patient_events[eventcount].active_status_cd = pe.active_status_cd
     IF (pe.patient_event_id=event_id)
      fromeventindex = eventcount
     ENDIF
    FOOT  j.patient_event_id
     null
    FOOT REPORT
     stat = alterlist(eventlist->patient_events,eventcount)
    WITH nocounter
   ;end select
   RETURN(fromeventindex)
 END ;Subroutine
 SUBROUTINE (populate_event_details(event_index=i4,from_detail_id=f8) =i2)
   SET eventssize = size(eventlist->patient_events,5)
   SET fromeventdetailindex = 0
   SET startindex = evaluate2(
    IF (event_index > 1) (event_index - 1)
    ELSE event_index
    ENDIF
    )
   SET endindex = evaluate2(
    IF (event_index < eventssize) (event_index+ 1)
    ELSE event_index
    ENDIF
    )
   DECLARE expindex = i4
   DECLARE locateindex = i4
   SELECT INTO "nl:"
    ped.patient_event_id, ped.patient_event_detail_id, ped.pe_value_meaning,
    ped.pe_value_dt_tm, ped.pe_value_numeric, ped.pe_value_string,
    ped.pe_value_cd, ped.pe_value_id, ped.pe_value_name,
    ped.active_status_cd
    FROM patient_event_detail ped
    WHERE ((ped.active_ind=1) OR (ped.patient_event_detail_id=from_detail_id))
     AND expand(expindex,startindex,endindex,ped.patient_event_id,eventlist->patient_events[expindex]
     .patient_event_id)
    ORDER BY ped.patient_event_id
    HEAD REPORT
     eventindex = 0, eventdetailcount = 0, currenteventid = 0
    DETAIL
     IF (ped.patient_event_id != currenteventid)
      stat = alterlist(eventlist->patient_events[eventindex].patient_event_details,eventdetailcount),
      currenteventid = ped.patient_event_id, eventdetailcount = 0,
      eventindex = locateval(locateindex,startindex,endindex,ped.patient_event_id,eventlist->
       patient_events[locateindex].patient_event_id)
     ENDIF
     eventdetailcount += 1
     IF (mod(eventdetailcount,10)=1)
      stat = alterlist(eventlist->patient_events[eventindex].patient_event_details,(eventdetailcount
       + 9))
     ENDIF
     eventlist->patient_events[eventindex].patient_event_details[eventdetailcount].
     patient_event_detail_id = ped.patient_event_detail_id, eventlist->patient_events[eventindex].
     patient_event_details[eventdetailcount].pe_value_meaning = trim(nullval(ped.pe_value_meaning,""),
      3), eventlist->patient_events[eventindex].patient_event_details[eventdetailcount].
     pe_value_dt_tm = ped.pe_value_dt_tm,
     eventlist->patient_events[eventindex].patient_event_details[eventdetailcount].pe_value_numeric
      = nullval(ped.pe_value_numeric,0), eventlist->patient_events[eventindex].patient_event_details[
     eventdetailcount].pe_value_string = trim(nullval(ped.pe_value_string,""),3), eventlist->
     patient_events[eventindex].patient_event_details[eventdetailcount].pe_value_cd = nullval(ped
      .pe_value_cd,0.0),
     eventlist->patient_events[eventindex].patient_event_details[eventdetailcount].pe_value_id =
     nullval(ped.pe_value_id,0.0), eventlist->patient_events[eventindex].patient_event_details[
     eventdetailcount].pe_value_name = trim(nullval(ped.pe_value_name,""),3), eventlist->
     patient_events[eventindex].patient_event_details[eventdetailcount].active_status_cd = ped
     .active_status_cd
     IF (ped.patient_event_detail_id=from_detail_id)
      fromeventdetailindex = eventdetailcount
     ENDIF
    FOOT REPORT
     stat = alterlist(eventlist->patient_events[eventindex].patient_event_details,eventdetailcount)
    WITH nocounter
   ;end select
   RETURN(fromeventdetailindex)
 END ;Subroutine
 SUBROUTINE (are_events_duplicate(event_1_index=i4,event_2_index=i4) =i2)
   SET detailsize = size(eventlist->patient_events[event_1_index].patient_event_details,5)
   IF (detailsize != size(eventlist->patient_events[event_2_index].patient_event_details,5))
    RETURN(false)
   ENDIF
   FOR (i = 1 TO detailsize)
     SET matchingdetailfound = false
     FOR (j = 1 TO detailsize)
       SET meaningequal = evaluate2(
        IF ((eventlist->patient_events[event_1_index].patient_event_details[i].pe_value_meaning=
        eventlist->patient_events[event_2_index].patient_event_details[j].pe_value_meaning)) true
        ELSE false
        ENDIF
        )
       SET dttmequal = datetimediff(eventlist->patient_events[event_1_index].patient_event_details[i]
        .pe_value_dt_tm,eventlist->patient_events[event_2_index].patient_event_details[j].
        pe_value_dt_tm,5)
       SET numericequal = evaluate2(
        IF ((eventlist->patient_events[event_1_index].patient_event_details[i].pe_value_numeric=
        eventlist->patient_events[event_2_index].patient_event_details[j].pe_value_numeric)) true
        ELSE false
        ENDIF
        )
       SET stringequal = evaluate2(
        IF ((eventlist->patient_events[event_1_index].patient_event_details[i].pe_value_string=
        eventlist->patient_events[event_2_index].patient_event_details[j].pe_value_string)) true
        ELSE false
        ENDIF
        )
       SET cdequal = evaluate2(
        IF ((eventlist->patient_events[event_1_index].patient_event_details[i].pe_value_cd=eventlist
        ->patient_events[event_2_index].patient_event_details[j].pe_value_cd)) true
        ELSE false
        ENDIF
        )
       SET idequal = evaluate2(
        IF ((eventlist->patient_events[event_1_index].patient_event_details[i].pe_value_id=eventlist
        ->patient_events[event_2_index].patient_event_details[j].pe_value_id)) true
        ELSE false
        ENDIF
        )
       SET nameequal = evaluate2(
        IF ((eventlist->patient_events[event_1_index].patient_event_details[i].pe_value_name=
        eventlist->patient_events[event_2_index].patient_event_details[j].pe_value_name)) true
        ELSE false
        ENDIF
        )
       IF (meaningequal=true
        AND dttmequal=0.0
        AND numericequal=true
        AND stringequal=true
        AND cdequal=true
        AND idequal=true
        AND nameequal=true)
        SET matchingdetailfound = true
       ENDIF
     ENDFOR
     IF (matchingdetailfound=false)
      RETURN(false)
     ENDIF
   ENDFOR
   RETURN(true)
 END ;Subroutine
 SET ecode = 0
 SET emsg = fillstring(132," ")
 SET ecode = error(emsg,1)
 IF (ecode != 0)
  SET failed = ccl_error
 ENDIF
#exit_sub
 FREE SET rreclist
END GO
