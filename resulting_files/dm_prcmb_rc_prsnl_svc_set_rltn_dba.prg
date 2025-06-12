CREATE PROGRAM dm_prcmb_rc_prsnl_svc_set_rltn:dba
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
     2 active_ind = i4
     2 active_status_cd = f8
     2 rc_prsnl_service_set_reltn_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
   1 to_rec[*]
     2 active_ind = i4
     2 active_status_cd = f8
     2 rc_prsnl_service_set_reltn_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
 )
 DECLARE from_count = i4
 DECLARE to_count = i4
 SET from_count = 0
 SET to_count = 0
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "prsnl"
  SET dcem_request->qual[1].child_entity = "rc_prsnl_service_set_reltn"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PRCMB_RC_PRSNL_SVC_SET_RLTN"
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
  FROM rc_prsnl_service_set_reltn frm
  WHERE frm.parent_entity_name="PRSNL"
   AND (frm.parent_entity_id=request->xxx_combine[icombine].from_xxx_id)
  DETAIL
   from_count += 1
   IF (mod(from_count,10)=1)
    stat = alterlist(rreclist->from_rec,(from_count+ 9))
   ENDIF
   rreclist->from_rec[from_count].active_ind = frm.active_ind, rreclist->from_rec[from_count].
   active_status_cd = frm.active_status_cd, rreclist->from_rec[from_count].
   rc_prsnl_service_set_reltn_id = frm.rc_prsnl_service_set_reltn_id,
   rreclist->from_rec[from_count].parent_entity_name = frm.parent_entity_name, rreclist->from_rec[
   from_count].parent_entity_id = frm.parent_entity_id
  WITH forupdatewait(frm)
 ;end select
 IF (from_count > 0)
  SELECT INTO "nl:"
   tu.*
   FROM rc_prsnl_service_set_reltn tu
   WHERE tu.parent_entity_name="PRSNL"
    AND (tu.parent_entity_id=request->xxx_combine[icombine].to_xxx_id)
   DETAIL
    to_count += 1
    IF (mod(to_count,10)=1)
     stat = alterlist(rreclist->to_rec,(to_count+ 9))
    ENDIF
    rreclist->to_rec[to_count].active_ind = tu.active_ind, rreclist->to_rec[to_count].
    active_status_cd = tu.active_status_cd, rreclist->to_rec[to_count].rc_prsnl_service_set_reltn_id
     = tu.rc_prsnl_service_set_reltn_id,
    rreclist->to_rec[to_count].parent_entity_name = tu.parent_entity_name, rreclist->to_rec[to_count]
    .parent_entity_id = tu.parent_entity_id
   WITH forupdatewait(tu)
  ;end select
  FOR (from_loop_count = 1 TO from_count)
    FOR (to_loop_count = 1 TO to_count)
      IF ((rreclist->from_rec[from_loop_count].rc_prsnl_service_set_reltn_id=rreclist->to_rec[
      to_loop_count].rc_prsnl_service_set_reltn_id))
       IF (del_from(from_loop_count)=0)
        GO TO exit_sub
       ENDIF
      ELSE
       IF (to_loop_count=to_count)
        IF (updt_from(from_loop_count)=0)
         GO TO exit_sub
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
 SUBROUTINE del_from(s_frm_index)
   UPDATE  FROM rc_prsnl_service_set_reltn frm
    SET frm.active_ind = false, frm.active_status_cd = combinedaway, frm.active_status_prsnl_id =
     reqinfo->updt_id,
     frm.active_status_dt_tm = cnvtdatetime(sysdate), frm.updt_cnt = (frm.updt_cnt+ 1), frm
     .updt_dt_tm = cnvtdatetime(sysdate),
     frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task =
     reqinfo->updt_task
    WHERE (frm.rc_prsnl_service_set_reltn_id=rreclist->from_rec[s_frm_index].
    rc_prsnl_service_set_reltn_id)
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_name = "RC_PRSNL_SERVICE_SET_RELTN"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PRSNL_ID"
   SET request->xxx_combine_det[icombinedet].entity_id = rreclist->from_rec[s_frm_index].
   parent_entity_id
   SET request->xxx_combine_det[icombinedet].prev_active_ind = 1
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = rreclist->from_rec[s_frm_index].
   prev_active_status_cd
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "PARENT_ENTITY_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = rreclist->from_rec[
   s_frm_index].parent_entity_id
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = build(
     "Failed to delete rc_prsnl_service_set_reltn record with rc_prsnl_service_set_reltn_id = ",
     rreclist->from_rec[s_frm_index].rc_prsnl_service_set_reltn_id)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE updt_from(s_frm_index)
   UPDATE  FROM rc_prsnl_service_set_reltn frm
    SET frm.notify_prsnl_id = request->xxx_combine[icombine].to_xxx_id, frm.updt_cnt = (frm.updt_cnt
     + 1), frm.updt_dt_tm = cnvtdatetime(sysdate),
     frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task =
     reqinfo->updt_task
    WHERE (frm.rc_prsnl_service_set_reltn_id=rreclist->to_rec[s_frm_index].
    rc_prsnl_service_set_reltn_id)
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_name = "RC_PRSNL_SERVICE_SET_RELTN"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PRSNL_ID"
   SET request->xxx_combine_det[icombinedet].entity_id = rreclist->to_rec[s_frm_index].entity_id
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "PARENT_ENTITY_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = rreclist->to_rec[s_frm_index]
   .entity_id
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = build(
     "Failed to update rc_prsnl_service_set_reltn record with rc_prsnl_service_set_reltn_id = ",
     rreclist->to_rec[s_frm_index].rc_prsnl_service_set_reltn_id)
    RETURN(0)
   ENDIF
   RETURN(1)
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
