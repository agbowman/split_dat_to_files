CREATE PROGRAM dm_pcmb_fhx_activity:dba
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
     2 related_person_id = f8
     2 end_effective_dt_tm = dq8
 )
 DECLARE v_cust_count = i4
 DECLARE v_cust_loopcount = i4
 DECLARE conflict_fhx_activity_cnt = i4
 DECLARE activity_idx = i4
 DECLARE activity_pos = i4
 SET v_cust_count = 0
 SET v_cust_loopcount = 0
 SET conflict_fhx_activity_cnt = 0
 SET activity_idx = 0
 SET activity_pos = 0
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "FHX_ACTIVITY"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PCMB_FHX_ACTIVITY"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 FREE SET conflict_fhx_activities
 RECORD conflict_fhx_activities(
   1 fhx_activity[*]
     2 fhx_activity_id = f8
 )
 SELECT INTO "nl:"
  FROM fhx_activity fht,
   fhx_activity fhf
  WHERE (fht.person_id=request->xxx_combine[icombine].to_xxx_id)
   AND (fhf.person_id=request->xxx_combine[icombine].from_xxx_id)
   AND fht.end_effective_dt_tm=fhf.end_effective_dt_tm
   AND fhf.active_ind=1
   AND fhf.type_mean="PERSON"
   AND fhf.type_mean=fht.type_mean
   AND fht.active_ind=fhf.active_ind
   AND fhf.fhx_value_flag IN (0, 2, 3, 4)
   AND fht.fhx_value_flag=fhf.fhx_value_flag
  DETAIL
   conflict_fhx_activity_cnt += 1
   IF (mod(conflict_fhx_activity_cnt,10)=1)
    stat = alterlist(conflict_fhx_activities->fhx_activity,(conflict_fhx_activity_cnt+ 9))
   ENDIF
   conflict_fhx_activities->fhx_activity[conflict_fhx_activity_cnt].fhx_activity_id = fhf
   .fhx_activity_id
  WITH nocounter
 ;end select
 SET stat = alterlist(conflict_fhx_activities->fhx_activity,conflict_fhx_activity_cnt)
 SELECT INTO "nl:"
  frm.*
  FROM fhx_activity frm
  WHERE (frm.person_id=request->xxx_combine[icombine].from_xxx_id)
  DETAIL
   v_cust_count += 1
   IF (mod(v_cust_count,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count].from_id = frm.fhx_activity_id, rreclist->from_rec[v_cust_count].
   active_ind = frm.active_ind, rreclist->from_rec[v_cust_count].active_status_cd = frm
   .active_status_cd,
   rreclist->from_rec[v_cust_count].related_person_id = frm.related_person_id, rreclist->from_rec[
   v_cust_count].end_effective_dt_tm = frm.end_effective_dt_tm
  WITH forupdatewait(frm)
 ;end select
 SET stat = alterlist(rreclist->from_rec,v_cust_count)
 FOR (v_cust_loopcount = 1 TO v_cust_count)
   IF ((rreclist->from_rec[v_cust_loopcount].active_status_cd != combinedaway))
    SET activity_pos = locateval(activity_idx,1,conflict_fhx_activity_cnt,rreclist->from_rec[
     v_cust_loopcount].from_id,conflict_fhx_activities->fhx_activity[activity_idx].fhx_activity_id)
    IF (activity_pos > 0)
     IF (del_from(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
      to_xxx_id,rreclist->from_rec[v_cust_loopcount].active_ind,rreclist->from_rec[v_cust_loopcount].
      active_status_cd,rreclist->from_rec[v_cust_loopcount].end_effective_dt_tm)=0)
      GO TO exit_sub
     ENDIF
    ELSE
     IF (upt_from(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
      to_xxx_id,rreclist->from_rec[v_cust_loopcount].related_person_id)=0)
      GO TO exit_sub
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE del_from(s_df_pk_id,s_df_to_fk_id,s_df_prev_act_ind,s_df_prev_act_status,
  s_df_prev_end_eff_dt_tm)
   UPDATE  FROM fhx_activity frm
    SET frm.active_ind = false, frm.active_status_cd = combinedaway, frm.updt_cnt = (frm.updt_cnt+ 1),
     frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task =
     reqinfo->updt_task,
     frm.updt_dt_tm = cnvtdatetime(sysdate), frm.end_effective_dt_tm = cnvtdatetime(sysdate)
    WHERE frm.fhx_activity_id=s_df_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = s_df_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "FHX_ACTIVITY"
   SET request->xxx_combine_det[icombinedet].attribute_name = "FHX_ACTIVITY_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = s_df_prev_act_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = s_df_prev_act_status
   SET request->xxx_combine_det[icombinedet].prev_end_eff_dt_tm = s_df_prev_end_eff_dt_tm
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = substring(1,132,build("Could not inactivate pk val=",s_df_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE upt_from(s_uf_pk_id,s_uf_to_fk_id,s_uf_related_person_id)
   UPDATE  FROM fhx_activity frm
    SET frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo
     ->updt_applctx,
     frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm = cnvtdatetime(sysdate), frm.person_id =
     s_uf_to_fk_id
    WHERE frm.fhx_activity_id=s_uf_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = s_uf_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "FHX_ACTIVITY"
   SET request->xxx_combine_det[icombinedet].attribute_name = "FHX_ACTIVITY_ID"
   IF (s_uf_related_person_id > 0)
    SET icombinedet += 1
    SET stat = alterlist(request->xxx_combine_det,icombinedet)
    SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
    SET request->xxx_combine_det[icombinedet].entity_id = s_uf_related_person_id
    SET request->xxx_combine_det[icombinedet].entity_name = "FHX_ACTIVITY"
    SET request->xxx_combine_det[icombinedet].attribute_name = "RELATED_PERSON_ID"
   ENDIF
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = substring(1,132,build("Could not update pk val=",s_uf_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_sub
 FREE SET conflict_fhx_activities
 FREE SET rreclist
END GO
