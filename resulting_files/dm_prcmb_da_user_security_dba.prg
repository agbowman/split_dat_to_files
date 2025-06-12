CREATE PROGRAM dm_prcmb_da_user_security:dba
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
     2 da_user_security_id = f8
     2 element_filter_txt_id = f8
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 prsnl_id = f8
     2 security_assignment_cd = f8
     2 end_effective_dt_tm = dq8
     2 cmb_col = vc
     2 cmb_actn = vc
   1 to_rec[*]
     2 active_ind = i4
     2 da_user_security_id = f8
     2 element_filter_txt_id = f8
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 prsnl_id = f8
     2 security_assignment_cd = f8
 )
 DECLARE v_cust_count1 = i4
 DECLARE v_cust_count2 = i4
 DECLARE v_cust_loopcount = i4
 DECLARE cmbstat = vc WITH protect
 DECLARE cmbstaterr = i4 WITH noconstant(0)
 DECLARE v_combined = f8 WITH noconstant(0.0)
 DECLARE v_cmbactn = f8 WITH noconstant(0.0)
 DECLARE v_perecsexist = i2 WITH noconstant(0)
 SET v_cust_count1 = 0
 SET v_cust_count2 = 0
 SET v_cust_loopcount = 0
 SET v_combined = uar_get_code_by("MEANING",48,"COMBINED")
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PRSNL"
  SET dcem_request->qual[1].child_entity = "DA_USER_SECURITY"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PRCMB_DA_USER_SECURITY"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 1
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO end_of_program
 ENDIF
 SELECT INTO "nl:"
  frm.*
  FROM da_user_security frm
  WHERE (((frm.prsnl_id=request->xxx_combine[icombine].from_xxx_id)) OR (frm.parent_entity_name=
  "PRSNL"
   AND (frm.parent_entity_id=request->xxx_combine[icombine].from_xxx_id)))
   AND frm.active_ind=1
  DETAIL
   v_cust_count1 += 1
   IF (mod(v_cust_count1,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count1].active_ind = frm.active_ind, rreclist->from_rec[v_cust_count1].
   da_user_security_id = frm.da_user_security_id, rreclist->from_rec[v_cust_count1].
   element_filter_txt_id = frm.element_filter_txt_id,
   rreclist->from_rec[v_cust_count1].parent_entity_id = frm.parent_entity_id, rreclist->from_rec[
   v_cust_count1].parent_entity_name = frm.parent_entity_name, rreclist->from_rec[v_cust_count1].
   prsnl_id = frm.prsnl_id,
   rreclist->from_rec[v_cust_count1].security_assignment_cd = frm.security_assignment_cd, rreclist->
   from_rec[v_cust_count1].cmb_col = "PRSNL_ID"
   IF (frm.parent_entity_name="PRSNL"
    AND (frm.parent_entity_id=request->xxx_combine[icombine].from_xxx_id))
    rreclist->from_rec[v_cust_count1].cmb_col = "PARENT_ENTITY_ID"
    IF ((frm.prsnl_id=request->xxx_combine[icombine].to_xxx_id))
     rreclist->from_rec[v_cust_count1].cmb_actn = "DEL"
    ELSE
     rreclist->from_rec[v_cust_count1].cmb_actn = "UPD"
    ENDIF
   ENDIF
  WITH forupdatewait(frm)
 ;end select
 SET stat = alterlist(rreclist->from_rec,v_cust_count1)
 IF (v_cust_count1 > 0)
  SELECT INTO "nl:"
   tu.da_user_security_id
   FROM da_user_security tu
   WHERE (tu.prsnl_id=request->xxx_combine[icombine].to_xxx_id)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   UPDATE  FROM da_user_security s,
     (dummyt d  WITH seq = value(size(rreclist->from_rec,5)))
    SET s.active_ind = 0, s.end_effective_dt_tm = cnvtdatetime(sysdate), s.active_status_prsnl_id =
     reqinfo->updt_id,
     s.active_status_cd = v_combined, s.active_status_dt_tm = cnvtdatetime(sysdate), s.updt_dt_tm =
     cnvtdatetime(sysdate),
     s.updt_id = reqinfo->updt_id, s.updt_applctx = reqinfo->updt_applctx, s.updt_task = reqinfo->
     updt_task,
     s.updt_cnt = (s.updt_cnt+ 1)
    PLAN (d
     WHERE (rreclist->from_rec[d.seq].cmb_col="PRSNL_ID"))
     JOIN (s
     WHERE (s.da_user_security_id=rreclist->from_rec[d.seq].da_user_security_id))
    WITH nocounter
   ;end update
   SET stat = uar_get_meaning_by_codeset(327,"DEL",1,v_cmbactn)
  ELSE
   UPDATE  FROM da_user_security s,
     (dummyt d  WITH seq = value(size(rreclist->from_rec,5)))
    SET s.prsnl_id = request->xxx_combine[icombine].to_xxx_id, s.active_status_prsnl_id = reqinfo->
     updt_id, s.active_status_cd = v_combined,
     s.active_status_dt_tm = cnvtdatetime(sysdate), s.updt_dt_tm = cnvtdatetime(sysdate), s.updt_id
      = reqinfo->updt_id,
     s.updt_applctx = reqinfo->updt_applctx, s.updt_task = reqinfo->updt_task, s.updt_cnt = (s
     .updt_cnt+ 1)
    PLAN (d
     WHERE (rreclist->from_rec[d.seq].cmb_col="PRSNL_ID"))
     JOIN (s
     WHERE (s.da_user_security_id=rreclist->from_rec[d.seq].da_user_security_id))
    WITH nocounter
   ;end update
   SET stat = uar_get_meaning_by_codeset(327,"UPT",1,v_cmbactn)
  ENDIF
  FOR (loopcount = 1 TO v_cust_count1)
    IF ((rreclist->from_rec[loopcount].cmb_col="PRSNL_ID"))
     SET icombinedet += 1
     SET stat = alterlist(request->xxx_combine_det,icombinedet)
     SET request->xxx_combine_det[icombinedet].combine_action_cd = v_cmbactn
     SET request->xxx_combine_det[icombinedet].entity_name = "DA_USER_SECURITY"
     SET request->xxx_combine_det[icombinedet].attribute_name = rreclist->from_rec[loopcount].cmb_col
     SET request->xxx_combine_det[icombinedet].prev_active_ind = rreclist->from_rec[loopcount].
     active_ind
     SET request->xxx_combine_det[icombinedet].prev_end_eff_dt_tm = rreclist->from_rec[loopcount].
     end_effective_dt_tm
     SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
     SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "DA_USER_SECURITY_ID"
     SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
     SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = rreclist->from_rec[
     loopcount].da_user_security_id
    ELSE
     SET v_perecsexist = 1
    ENDIF
  ENDFOR
  IF (v_perecsexist=1)
   UPDATE  FROM da_user_security s,
     (dummyt d  WITH seq = value(size(rreclist->from_rec,5)))
    SET s.parent_entity_id = request->xxx_combine[icombine].to_xxx_id, s.active_status_prsnl_id =
     reqinfo->updt_id, s.active_status_cd = v_combined,
     s.active_status_dt_tm = cnvtdatetime(sysdate), s.updt_dt_tm = cnvtdatetime(sysdate), s.updt_id
      = reqinfo->updt_id,
     s.updt_applctx = reqinfo->updt_applctx, s.updt_task = reqinfo->updt_task, s.updt_cnt = (s
     .updt_cnt+ 1)
    PLAN (d
     WHERE (rreclist->from_rec[d.seq].cmb_col="PARENT_ENTITY_ID")
      AND (rreclist->from_rec[d.seq].prsnl_id != request->xxx_combine[icombine].from_xxx_id))
     JOIN (s
     WHERE (s.da_user_security_id=rreclist->from_rec[d.seq].da_user_security_id))
    WITH nocounter
   ;end update
   UPDATE  FROM da_user_security s,
     (dummyt d  WITH seq = value(size(rreclist->from_rec,5)))
    SET s.active_ind = 0, s.end_effective_dt_tm = cnvtdatetime(sysdate), s.active_status_prsnl_id =
     reqinfo->updt_id,
     s.active_status_cd = v_combined, s.active_status_dt_tm = cnvtdatetime(sysdate), s.updt_dt_tm =
     cnvtdatetime(sysdate),
     s.updt_id = reqinfo->updt_id, s.updt_applctx = reqinfo->updt_applctx, s.updt_task = reqinfo->
     updt_task,
     s.updt_cnt = (s.updt_cnt+ 1)
    PLAN (d
     WHERE (rreclist->from_rec[d.seq].cmb_col="PARENT_ENTITY_ID")
      AND (rreclist->from_rec[d.seq].prsnl_id=request->xxx_combine[icombine].to_xxx_id))
     JOIN (s
     WHERE (s.da_user_security_id=rreclist->from_rec[d.seq].da_user_security_id))
    WITH nocounter
   ;end update
   SET icombinedet = size(request->xxx_combine_det,5)
   FOR (loopcount = 1 TO v_cust_count1)
     IF ((rreclist->from_rec[loopcount].cmb_col="PARENT_ENTITY_ID"))
      SET icombinedet += 1
      SET stat = alterlist(request->xxx_combine_det,icombinedet)
      SET request->xxx_combine_det[icombinedet].combine_action_cd = rreclist->from_rec[loopcount].
      cmb_actn
      SET request->xxx_combine_det[icombinedet].entity_name = "DA_USER_SECURITY"
      SET request->xxx_combine_det[icombinedet].attribute_name = rreclist->from_rec[loopcount].
      cmb_col
      SET request->xxx_combine_det[icombinedet].prev_active_ind = rreclist->from_rec[loopcount].
      active_ind
      SET request->xxx_combine_det[icombinedet].prev_end_eff_dt_tm = rreclist->from_rec[loopcount].
      end_effective_dt_tm
      SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
      SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "DA_USER_SECURITY_ID"
      SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
      SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = rreclist->from_rec[
      loopcount].da_user_security_id
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SET ecode = 0
 SET emsg = fillstring(132," ")
 SET ecode = error(emsg,1)
 IF (ecode != 0)
  SET failed = ccl_error
  SET request->error_message = emsg
 ENDIF
#end_of_program
 FREE SET rreclist
END GO
