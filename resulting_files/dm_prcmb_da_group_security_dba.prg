CREATE PROGRAM dm_prcmb_da_group_security:dba
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
     2 da_group_security_id = f8
     2 security_group_cd = f8
     2 element_filter_txt_id = f8
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 security_assignment_cd = f8
     2 end_effective_dt_tm = dq8
     2 cmb_actn = vc
   1 to_rec[*]
     2 active_ind = i4
     2 da_group_security_id = f8
     2 security_group_cd = f8
     2 element_filter_txt_id = f8
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 security_assignment_cd = f8
 )
 DECLARE v_cust_count1 = i4
 DECLARE v_cust_count2 = i4
 DECLARE v_cust_loopcount = i4
 DECLARE cmbstat = vc WITH protect
 DECLARE cmbstaterr = i4 WITH noconstant(0)
 DECLARE v_combined = f8 WITH noconstant(0.0)
 DECLARE v_cmbactn = f8 WITH noconstant(0.0)
 SET v_cust_count1 = 0
 SET v_cust_count2 = 0
 SET v_cust_loopcount = 0
 SET v_combined = uar_get_code_by("MEANING",48,"COMBINED")
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PRSNL"
  SET dcem_request->qual[1].child_entity = "DA_GROUP_SECURITY"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PRCMB_DA_GROUP_SECURITY"
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
  FROM da_group_security frm
  WHERE (frm.parent_entity_id=request->xxx_combine[icombine].from_xxx_id)
   AND frm.parent_entity_name="PRSNL"
  DETAIL
   v_cust_count1 += 1
   IF (mod(v_cust_count1,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count1].active_ind = frm.active_ind, rreclist->from_rec[v_cust_count1].
   da_group_security_id = frm.da_group_security_id, rreclist->from_rec[v_cust_count1].
   security_group_cd = frm.security_group_cd,
   rreclist->from_rec[v_cust_count1].element_filter_txt_id = frm.element_filter_txt_id, rreclist->
   from_rec[v_cust_count1].parent_entity_id = frm.parent_entity_id, rreclist->from_rec[v_cust_count1]
   .parent_entity_name = frm.parent_entity_name,
   rreclist->from_rec[v_cust_count1].security_assignment_cd = frm.security_assignment_cd
  WITH forupdatewait(frm)
 ;end select
 SET stat = alterlist(rreclist->from_rec,v_cust_count1)
 IF (v_cust_count1 > 0)
  SELECT INTO "nl:"
   tu.*
   FROM da_group_security tu
   WHERE (tu.parent_entity_id=request->xxx_combine[icombine].to_xxx_id)
    AND tu.parent_entity_name="PRSNL"
   DETAIL
    v_cust_count2 += 1
    IF (mod(v_cust_count2,10)=1)
     stat = alterlist(rreclist->to_rec,(v_cust_count2+ 9))
    ENDIF
    rreclist->to_rec[v_cust_count2].active_ind = tu.active_ind, rreclist->to_rec[v_cust_count2].
    da_group_security_id = tu.da_group_security_id, rreclist->to_rec[v_cust_count2].security_group_cd
     = tu.security_group_cd,
    rreclist->to_rec[v_cust_count2].element_filter_txt_id = tu.element_filter_txt_id, rreclist->
    to_rec[v_cust_count2].parent_entity_id = tu.parent_entity_id, rreclist->to_rec[v_cust_count2].
    parent_entity_name = tu.parent_entity_name,
    rreclist->to_rec[v_cust_count2].security_assignment_cd = tu.security_assignment_cd
   WITH forupdatewait(tu)
  ;end select
  SET stat = alterlist(rreclist->to_rec,v_cust_count2)
  FOR (loopcount = 1 TO v_cust_count1)
    SET cmbstaterr = 0
    SET cmbstat = getcmbaction(v_cust_count2,loopcount,cmbstaterr)
    IF (cmbstat="UPT")
     SET stat = uar_get_meaning_by_codeset(327,"UPT",1,v_cmbactn)
    ELSEIF (cmbstat="DEL")
     SET stat = uar_get_meaning_by_codeset(327,"DEL",1,v_cmbactn)
    ELSE
     SET failed = cmbstaterr
     SET request->error_message = concat("Failed to update group security settings for prsnl_id: ",
      build(request->xxx_combine[icombine].from_xxx_id))
     GO TO end_of_program
    ENDIF
    SET icombinedet += 1
    SET stat = alterlist(request->xxx_combine_det,icombinedet)
    SET request->xxx_combine_det[icombinedet].combine_action_cd = v_cmbactn
    SET request->xxx_combine_det[icombinedet].entity_name = "DA_GROUP_SECURITY"
    SET request->xxx_combine_det[icombinedet].attribute_name = rreclist->from_rec[loopcount].cmb_col
    SET request->xxx_combine_det[icombinedet].prev_active_ind = rreclist->from_rec[loopcount].
    active_ind
    SET request->xxx_combine_det[icombinedet].prev_end_eff_dt_tm = rreclist->from_rec[loopcount].
    end_effective_dt_tm
    SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
    SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "DA_GROUP_SECURITY_ID"
    SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
    SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = rreclist->from_rec[loopcount
    ].da_group_security_id
  ENDFOR
 ENDIF
 SUBROUTINE (getcmbaction(tocount=i4,frmndx=i4,actnerr=i4) =vc WITH protect)
   DECLARE bfound = i4 WITH noconstant(0)
   DECLARE tondx = i4 WITH noconstant(0)
   DECLARE strstatus = vc WITH protect
   SET strstatus = "ERR"
   SET bfound = false
   IF (tocount > 0)
    FOR (tondx = 1 TO tocount)
      IF ((rreclist->to_rec[tondx].parent_entity_name=rreclist->from_rec[frmndx].parent_entity_name)
       AND (rreclist->to_rec[tondx].security_assignment_cd=rreclist->from_rec[frmndx].
      security_assignment_cd)
       AND (rreclist->to_rec[tondx].element_filter_txt_id=rreclist->from_rec[frmndx].
      element_filter_txt_id)
       AND (rreclist->to_rec[tondx].security_group_cd=rreclist->from_rec[frmndx].security_group_cd))
       SET bfound = true
       GO TO update_rec
      ENDIF
    ENDFOR
   ENDIF
#update_rec
   IF (bfound=true)
    UPDATE  FROM da_group_security s
     SET s.active_ind = 0, s.end_effective_dt_tm = cnvtdatetime(sysdate), s.active_status_prsnl_id =
      reqinfo->updt_id,
      s.active_status_cd = v_combined, s.active_status_dt_tm = cnvtdatetime(sysdate), s.updt_dt_tm =
      cnvtdatetime(sysdate),
      s.updt_id = reqinfo->updt_id, s.updt_applctx = reqinfo->updt_applctx, s.updt_task = reqinfo->
      updt_task,
      s.updt_cnt = (s.updt_cnt+ 1)
     WHERE (s.da_group_security_id=rreclist->from_rec[frmndx].da_group_security_id)
     WITH nocounter
    ;end update
    IF (curqual > 0)
     SET strstatus = "DEL"
    ELSE
     SET actnerr = delete_error
    ENDIF
   ELSE
    SET updt_prsnl_id = request->xxx_combine[icombine].to_xxx_id
    SET updt_parent_entity_id = rreclist->from_rec[frmndx].parent_entity_id
    UPDATE  FROM da_group_security s
     SET s.parent_entity_id = request->xxx_combine[icombine].to_xxx_id, s.active_status_cd =
      v_combined, s.active_status_dt_tm = cnvtdatetime(sysdate),
      s.updt_dt_tm = cnvtdatetime(sysdate), s.updt_id = reqinfo->updt_id, s.updt_applctx = reqinfo->
      updt_applctx,
      s.updt_task = reqinfo->updt_task, s.updt_cnt = (s.updt_cnt+ 1)
     WHERE (s.da_group_security_id=rreclist->from_rec[frmndx].da_group_security_id)
     WITH nocounter
    ;end update
    IF (curqual > 0)
     SET strstatus = "UPT"
    ELSE
     SET actnerr = update_error
    ENDIF
   ENDIF
   RETURN(strstatus)
 END ;Subroutine
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
