CREATE PROGRAM dm_ecmb_ppr_consent_status:dba
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
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 from_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 upd_dt_time = f8
     2 consent_status_id = f8
   1 to_rec[*]
     2 to_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 upd_dt_time = f8
     2 consent_status_id = f8
 )
 DECLARE del_to(s_dt_pk_id,s_dt_prev_act_ind,s_dt_prev_act_status) = i4
 DECLARE v_cust_count1 = i4 WITH protect, noconstant(0)
 DECLARE v_cust_count2 = i4 WITH protect, noconstant(0)
 DECLARE v_cust_loopcount = i4 WITH protect, noconstant(0)
 DECLARE v_cust_loopcount2 = i4 WITH protect, noconstant(0)
 DECLARE active_consents_present = i4 WITH protect, noconstant(0)
 DECLARE found_index = i4 WITH protect, noconstant(0)
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "ENCOUNTER"
  SET dcem_request->qual[1].child_entity = "PPR_CONSENT_STATUS"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "dm_ecmb_ppr_consent_status"
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
  frm.*
  FROM ppr_consent_status frm
  WHERE (frm.encntr_id=request->xxx_combine[icombine].from_xxx_id)
  DETAIL
   v_cust_count1 += 1
   IF (mod(v_cust_count1,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count1].from_id = frm.encntr_id, rreclist->from_rec[v_cust_count1].
   active_ind = frm.active_ind, rreclist->from_rec[v_cust_count1].active_status_cd = frm
   .active_status_cd,
   rreclist->from_rec[v_cust_count1].upd_dt_time = frm.updt_dt_tm, rreclist->from_rec[v_cust_count1].
   consent_status_id = frm.consent_status_id
  WITH forupdatewait(frm)
 ;end select
 IF (v_cust_count1 > 0)
  SELECT INTO "nl:"
   tu.*
   FROM ppr_consent_status tu
   WHERE (tu.encntr_id=request->xxx_combine[icombine].to_xxx_id)
   DETAIL
    v_cust_count2 += 1
    IF (mod(v_cust_count2,10)=1)
     stat = alterlist(rreclist->to_rec,(v_cust_count2+ 9))
    ENDIF
    rreclist->to_rec[v_cust_count2].to_id = tu.encntr_id, rreclist->to_rec[v_cust_count2].active_ind
     = tu.active_ind, rreclist->to_rec[v_cust_count2].active_status_cd = tu.active_status_cd,
    rreclist->to_rec[v_cust_count2].upd_dt_time = tu.updt_dt_tm, rreclist->to_rec[v_cust_count2].
    consent_status_id = tu.consent_status_id
   WITH forupdatewait(tu)
  ;end select
  FOR (v_cust_loopcount = 1 TO v_cust_count1)
    SET active_consents_present = 0
    FOR (v_cust_loopcount2 = 1 TO v_cust_count2)
      IF ((rreclist->from_rec[v_cust_loopcount].active_ind=1)
       AND (rreclist->to_rec[v_cust_loopcount2].active_ind=1))
       SET active_consents_present = 1
       SET found_index = v_cust_loopcount2
      ENDIF
    ENDFOR
    IF (active_consents_present=1)
     IF ((rreclist->from_rec[v_cust_loopcount].upd_dt_time > rreclist->to_rec[found_index].
     upd_dt_time))
      IF (del_to(rreclist->to_rec[found_index].consent_status_id,rreclist->to_rec[found_index].
       active_ind,rreclist->from_rec[v_cust_loopcount].active_status_cd)=0)
       GO TO exit_sub
      ELSE
       IF (upt_from(rreclist->from_rec[v_cust_loopcount].consent_status_id,request->xxx_combine[
        icombine].to_xxx_id)=0)
        GO TO exit_sub
       ENDIF
      ENDIF
     ELSE
      IF (del_from(rreclist->from_rec[v_cust_loopcount].consent_status_id,request->xxx_combine[
       icombine].from_xxx_id,rreclist->from_rec[v_cust_loopcount].active_ind,rreclist->from_rec[
       v_cust_loopcount].active_status_cd)=0)
       GO TO exit_sub
      ENDIF
     ENDIF
    ELSE
     IF (upt_from(rreclist->from_rec[v_cust_loopcount].consent_status_id,request->xxx_combine[
      icombine].to_xxx_id)=0)
      GO TO exit_sub
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE (del_from(s_df_pk_id=f8,s_df_to_fk_id=f8,s_df_prev_act_ind=i2,s_df_prev_act_status=f8) =
  i4)
   UPDATE  FROM ppr_consent_status frm
    SET frm.active_ind = false, frm.active_status_cd = combinedaway, frm.updt_cnt = (frm.updt_cnt+ 1),
     frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task =
     reqinfo->updt_task,
     frm.updt_dt_tm = cnvtdatetime(sysdate), frm.encntr_id = s_df_to_fk_id
    WHERE frm.consent_status_id=s_df_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = s_df_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "PPR_CONSENT_STATUS"
   SET request->xxx_combine_det[icombinedet].attribute_name = "ENCNTR_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = s_df_prev_act_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = s_df_prev_act_status
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = substring(1,132,build("Could not inactivate pk val=",s_df_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE del_to(s_dt_pk_id,s_dt_prev_act_ind,s_dt_prev_act_status)
   UPDATE  FROM ppr_consent_status tu
    SET tu.active_ind = false, tu.active_status_cd = combinedaway, tu.updt_cnt = (tu.updt_cnt+ 1),
     tu.updt_id = reqinfo->updt_id, tu.updt_applctx = reqinfo->updt_applctx, tu.updt_task = reqinfo->
     updt_task,
     tu.updt_dt_tm = cnvtdatetime(sysdate)
    WHERE tu.consent_status_id=s_dt_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = s_dt_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "PPR_CONSENT_STATUS"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = s_dt_prev_act_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = s_dt_prev_act_status
   SET request->xxx_combine_det[icombinedet].to_record_ind = 1
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = substring(1,132,build("Could not inactivate pk val=",s_dt_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (upt_from(s_uf_pk_id=f8,s_uf_to_fk_id=f8) =i4)
   UPDATE  FROM ppr_consent_status frm
    SET frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo
     ->updt_applctx,
     frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm = cnvtdatetime(sysdate), frm.encntr_id =
     s_uf_to_fk_id
    WHERE frm.consent_status_id=s_uf_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = s_uf_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "PPR_CONSENT_STATUS"
   SET request->xxx_combine_det[icombinedet].attribute_name = "ENCNTR_ID"
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = substring(1,132,build("Could not update pk val=",s_uf_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_sub
 FREE SET rreclist
END GO
