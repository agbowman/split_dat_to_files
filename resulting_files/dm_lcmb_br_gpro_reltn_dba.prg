CREATE PROGRAM dm_lcmb_br_gpro_reltn:dba
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
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 br_gpro_reltn_id = f8
     2 br_gpro_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 end_eff_dt_tm = dq8
   1 to_rec[*]
     2 br_gpro_id = f8
 )
 SET count1 = 0
 SET count2 = 0
 DECLARE v_cust_count1 = i4
 DECLARE v_cust_count2 = i4
 DECLARE loopcount = i4
 DECLARE torecordcount = i4
 DECLARE matchfound = i4
 SET v_cust_count1 = 0
 SET v_cust_count2 = 0
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "LOCATION"
  SET dcem_request->qual[1].child_entity = "BR_GPRO_RELTN"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_LCMB_BR_GPRO_RELTN"
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
  FROM br_gpro_reltn frm
  WHERE (frm.parent_entity_id=request->xxx_combine[icombine].from_xxx_id)
   AND frm.parent_entity_name="LOCATION"
   AND frm.active_ind=1
   AND frm.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  DETAIL
   v_cust_count1 = (v_cust_count1+ 1)
   IF (mod(v_cust_count1,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count1].br_gpro_reltn_id = frm.br_gpro_reltn_id, rreclist->from_rec[
   v_cust_count1].br_gpro_id = frm.br_gpro_id, rreclist->from_rec[v_cust_count1].end_eff_dt_tm = frm
   .end_effective_dt_tm,
   rreclist->from_rec[v_cust_count1].active_ind = frm.active_ind, rreclist->from_rec[v_cust_count1].
   active_status_cd = frm.active_status_cd
  WITH forupdatewait(frm)
 ;end select
 IF (v_cust_count1 > 0)
  SELECT INTO "nl:"
   tu.*
   FROM br_gpro_reltn tu
   WHERE (tu.parent_entity_id=request->xxx_combine[icombine].to_xxx_id)
    AND tu.parent_entity_name="LOCATION"
    AND tu.active_ind=1
    AND tu.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   DETAIL
    v_cust_count2 = (v_cust_count2+ 1)
    IF (mod(v_cust_count2,10)=1)
     stat = alterlist(rreclist->to_rec,(v_cust_count2+ 9))
    ENDIF
    rreclist->to_rec[v_cust_count2].br_gpro_id = tu.br_gpro_id
   WITH forupdatewait(tu)
  ;end select
 ENDIF
 FOR (loopcount = 1 TO v_cust_count1)
   SET matchfound = 0
   FOR (torecordcount = 1 TO v_cust_count2)
     IF ((rreclist->from_rec[loopcount].br_gpro_id=rreclist->to_rec[torecordcount].br_gpro_id))
      SET matchfound = 1
      IF (end_eff(rreclist->from_rec[loopcount].br_gpro_reltn_id,loopcount)=0)
       GO TO exit_sub
      ENDIF
      IF (del_from(rreclist->from_rec[loopcount].br_gpro_reltn_id,loopcount)=0)
       GO TO exit_sub
      ENDIF
     ENDIF
   ENDFOR
   IF (matchfound=0)
    IF (updt_from(rreclist->from_rec[loopcount].br_gpro_reltn_id)=0)
     GO TO exit_sub
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE del_from(s_bgr_id,s_frm_cnt)
   UPDATE  FROM br_gpro_reltn bgr
    SET bgr.active_ind = 0, bgr.active_status_cd = combinedaway, bgr.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     bgr.active_status_prsnl_id = reqinfo->updt_id, bgr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     bgr.updt_id = reqinfo->updt_id,
     bgr.updt_applctx = reqinfo->updt_applctx, bgr.updt_task = reqinfo->updt_task, bgr.updt_cnt = (
     bgr.updt_cnt+ 1)
    WHERE bgr.br_gpro_reltn_id=s_bgr_id
    WITH nocounter
   ;end update
   SET icombinedet = (icombinedet+ 1)
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = s_bgr_id
   SET request->xxx_combine_det[icombinedet].entity_name = "BR_GPRO_RELTN"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PARENT_ENTITY_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = rreclist->from_rec[s_frm_cnt].
   active_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = rreclist->from_rec[s_frm_cnt].
   active_status_cd
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "BR_GPRO_RELTN_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = s_bgr_id
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = build(
     "DEL_FROM: No values found on the BR_GPRO_RELTN table with br_gpro_reltn_id = ",s_bgr_id)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE updt_from(s_bgr_id2)
   UPDATE  FROM br_gpro_reltn bgr
    SET bgr.parent_entity_id = request->xxx_combine[icombine].to_xxx_id, bgr.updt_cnt = (bgr.updt_cnt
     + 1), bgr.updt_id = reqinfo->updt_id,
     bgr.updt_applctx = reqinfo->updt_applctx, bgr.updt_task = reqinfo->updt_task, bgr.updt_dt_tm =
     cnvtdatetime(curdate,curtime3)
    WHERE bgr.br_gpro_reltn_id=s_bgr_id2
   ;end update
   SET icombinedet = (icombinedet+ 1)
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_name = "BR_GPRO_RELTN"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PARENT_ENTITY_ID"
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "BR_GPRO_RELTN_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = s_bgr_id2
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = build(
     "Couldn't update BR_GPRO_RELTN record with br_gpro_reltn_id = ",s_bgr_id2)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE end_eff(s_bgr_id,s_frm_count)
   UPDATE  FROM br_gpro_reltn bgr
    SET bgr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), bgr.updt_dt_tm = cnvtdatetime(
      curdate,curtime3), bgr.updt_id = reqinfo->updt_id,
     bgr.updt_applctx = reqinfo->updt_applctx, bgr.updt_task = reqinfo->updt_task, bgr.updt_cnt = (
     bgr.updt_cnt+ 1)
    WHERE bgr.br_gpro_reltn_id=s_bgr_id
    WITH nocounter
   ;end update
   SET icombinedet = (icombinedet+ 1)
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = eff
   SET request->xxx_combine_det[icombinedet].entity_name = "BR_GPRO_RELTN"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PARENT_ENTITY_ID"
   SET request->xxx_combine_det[icombinedet].prev_end_eff_dt_tm = rreclist->from_rec[s_frm_count].
   end_eff_dt_tm
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "BR_GPRO_RELTN_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = s_bgr_id
   IF (curqual=0)
    SET failed = eff_error
    SET request->error_message = build(
     "END_EFF: No values found on the BR_GPRO_RELTN table with br_gpro_reltn_id = ",s_bgr_id)
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
