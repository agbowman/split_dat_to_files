CREATE PROGRAM dm_prcmb_prsnl_reltn:dba
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
 IF ((validate(rev_cmb_request->reverse_ind,- (1))=- (1))
  AND (validate(rev_cmb_request->application_flag,- (999))=- (999)))
  FREE RECORD rev_cmb_request
  RECORD rev_cmb_request(
    1 reverse_ind = i2
    1 application_flag = i4
  )
 ENDIF
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PRSNL"
  SET dcem_request->qual[1].child_entity = "PRSNL_RELTN"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PRCMB_PRSNL_RELTN"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO end_of_program
 ENDIF
 DECLARE count1 = i4
 DECLARE child_count1 = i4
 DECLARE exp_ndx = i4
 DECLARE count2 = i4 WITH protect, noconstant(0)
 DECLARE child_count2 = i4 WITH protect, noconstant(0)
 DECLARE exp_ndx2 = i4 WITH protect, noconstant(0)
 FREE RECORD rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 prsnl_reltn_id = f8
     2 prev_active_status_cd = f8
   1 to_rec[*]
     2 prsnl_reltn_id = f8
     2 prev_active_status_cd = f8
 )
 FREE RECORD rreclistchild
 RECORD rreclistchild(
   1 from_rec[*]
     2 prsnl_reltn_child_id = f8
     2 prev_end_eff_dt_tm = dq8
   1 to_rec[*]
     2 prsnl_reltn_child_id = f8
     2 prev_end_eff_dt_tm = dq8
 )
 SET count1 = 0
 SET child_count1 = 0
 SELECT INTO "nl:"
  frm.*
  FROM prsnl_reltn frm
  WHERE (frm.person_id=request->xxx_combine[icombine].from_xxx_id)
   AND frm.active_ind=1
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1)
    stat = alterlist(rreclist->from_rec,(count1+ 9))
   ENDIF
   rreclist->from_rec[count1].prsnl_reltn_id = frm.prsnl_reltn_id, rreclist->from_rec[count1].
   prev_active_status_cd = frm.active_status_cd
  WITH forupdatewait(frm)
 ;end select
 SET stat = alterlist(rreclist->from_rec,count1)
 IF (count1 > 0
  AND (rev_cmb_request->reverse_ind=0))
  FOR (loopcount = 1 TO count1)
    IF (del_from(rreclist->from_rec[loopcount].prsnl_reltn_id,loopcount)=0)
     GO TO end_of_program
    ENDIF
  ENDFOR
  SELECT INTO "nl:"
   prc.*
   FROM prsnl_reltn_child prc
   WHERE expand(exp_ndx,1,count1,prc.prsnl_reltn_id,rreclist->from_rec[exp_ndx].prsnl_reltn_id)
   DETAIL
    child_count1 += 1
    IF (mod(child_count1,10)=1)
     stat = alterlist(rreclistchild->from_rec,(child_count1+ 9))
    ENDIF
    rreclistchild->from_rec[child_count1].prsnl_reltn_child_id = prc.prsnl_reltn_child_id,
    rreclistchild->from_rec[child_count1].prev_end_eff_dt_tm = prc.end_effective_dt_tm
   WITH forupdatewait(prc)
  ;end select
  SET stat = alterlist(rreclistchild->from_rec,child_count1)
  IF (child_count1 > 0)
   FOR (loopcount2 = 1 TO child_count1)
     IF (end_eff(rreclistchild->from_rec[loopcount2].prsnl_reltn_child_id,loopcount2)=0)
      GO TO end_of_program
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF ((rev_cmb_request->reverse_ind=1))
  SELECT INTO "nl:"
   tu.*
   FROM prsnl_reltn tu
   WHERE (tu.person_id=request->xxx_combine[icombine].to_xxx_id)
    AND tu.active_ind=1
   DETAIL
    count2 += 1
    IF (mod(count2,10)=1)
     stat = alterlist(rreclist->to_rec,(count2+ 9))
    ENDIF
    rreclist->to_rec[count2].prsnl_reltn_id = tu.prsnl_reltn_id, rreclist->to_rec[count2].
    prev_active_status_cd = tu.active_status_cd
   FOOT REPORT
    stat = alterlist(rreclist->to_rec,count2)
   WITH forupdatewait(tu)
  ;end select
  IF (count2 > 0)
   FOR (loopcount = 1 TO count2)
     IF (del_to(rreclist->to_rec[loopcount].prsnl_reltn_id,loopcount)=0)
      GO TO end_of_program
     ENDIF
   ENDFOR
   SELECT INTO "nl:"
    prc.*
    FROM prsnl_reltn_child prc
    WHERE expand(exp_ndx2,1,count2,prc.prsnl_reltn_id,rreclist->to_rec[exp_ndx2].prsnl_reltn_id)
    DETAIL
     child_count2 += 1
     IF (mod(child_count2,10)=1)
      stat = alterlist(rreclistchild->to_rec,(child_count2+ 9))
     ENDIF
     rreclistchild->to_rec[child_count2].prsnl_reltn_child_id = prc.prsnl_reltn_child_id,
     rreclistchild->to_rec[child_count2].prev_end_eff_dt_tm = prc.end_effective_dt_tm
    FOOT REPORT
     stat = alterlist(rreclistchild->to_rec,child_count2)
    WITH forupdatewait(prc)
   ;end select
   IF (child_count2 > 0)
    FOR (loopcount2 = 1 TO child_count2)
      IF (revend_eff(rreclistchild->to_rec[loopcount2].prsnl_reltn_child_id,loopcount2)=0)
       GO TO end_of_program
      ENDIF
    ENDFOR
   ENDIF
   FOR (loopcount = 1 TO count1)
     IF (updt_from(rreclist->from_rec[loopcount].prsnl_reltn_id)=0)
      GO TO end_of_program
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SUBROUTINE del_from(s_pr_id,s_frm_cnt)
   UPDATE  FROM prsnl_reltn pr
    SET pr.active_ind = 0, pr.active_status_cd = combinedaway, pr.active_status_dt_tm = cnvtdatetime(
      sysdate),
     pr.active_status_prsnl_id = reqinfo->updt_id, pr.updt_dt_tm = cnvtdatetime(sysdate), pr.updt_id
      = reqinfo->updt_id,
     pr.updt_applctx = reqinfo->updt_applctx, pr.updt_task = reqinfo->updt_task, pr.updt_cnt = (pr
     .updt_cnt+ 1)
    WHERE pr.prsnl_reltn_id=s_pr_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_name = "PRSNL_RELTN"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = 1
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = rreclist->from_rec[s_frm_cnt].
   prev_active_status_cd
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "PRSNL_RELTN_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = s_pr_id
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = build(
     "DEL_FROM: No values found on the prsnl_reltn table with prsnl_reltn_id = ",s_pr_id)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE end_eff(s_prchild_id,s_frm_count)
   UPDATE  FROM prsnl_reltn_child prc
    SET prc.end_effective_dt_tm = cnvtdatetime(sysdate), prc.updt_dt_tm = cnvtdatetime(sysdate), prc
     .updt_id = reqinfo->updt_id,
     prc.updt_applctx = reqinfo->updt_applctx, prc.updt_task = reqinfo->updt_task, prc.updt_cnt = (
     prc.updt_cnt+ 1)
    WHERE prc.prsnl_reltn_child_id=s_prchild_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = eff
   SET request->xxx_combine_det[icombinedet].entity_name = "PRSNL_RELTN_CHILD"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PRSNL_RELTN_ID"
   SET request->xxx_combine_det[icombinedet].prev_end_eff_dt_tm = rreclistchild->from_rec[s_frm_count
   ].prev_end_eff_dt_tm
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "PRSNL_RELTN_CHILD_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = s_prchild_id
   IF (curqual=0)
    SET failed = eff_error
    SET request->error_message = build(
     "END_EFF: No values found on the prsnl_reltn_child table with prsnl_reltn_child_id = ",
     s_prchild_id)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (del_to(dts_pr_id=f8,dts_frm_cnt=i4) =i2)
   UPDATE  FROM prsnl_reltn pr
    SET pr.active_ind = 0, pr.active_status_cd = combinedaway, pr.active_status_dt_tm = cnvtdatetime(
      sysdate),
     pr.active_status_prsnl_id = reqinfo->updt_id, pr.updt_dt_tm = cnvtdatetime(sysdate), pr.updt_id
      = reqinfo->updt_id,
     pr.updt_applctx = reqinfo->updt_applctx, pr.updt_task = reqinfo->updt_task, pr.updt_cnt = (pr
     .updt_cnt+ 1)
    WHERE pr.prsnl_reltn_id=dts_pr_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = revdel
   SET request->xxx_combine_det[icombinedet].entity_name = "PRSNL_RELTN"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = 1
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = rreclist->to_rec[dts_frm_cnt].
   prev_active_status_cd
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "PRSNL_RELTN_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = dts_pr_id
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = build(
     "DEL_TO: No values found on the prsnl_reltn table with prsnl_reltn_id = ",dts_pr_id)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (updt_from(ufs_pr_id=f8) =i2)
   UPDATE  FROM prsnl_reltn frm
    SET frm.person_id = request->xxx_combine[icombine].to_xxx_id, frm.updt_cnt = (frm.updt_cnt+ 1),
     frm.updt_id = reqinfo->updt_id,
     frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm =
     cnvtdatetime(sysdate)
    WHERE frm.prsnl_reltn_id=ufs_pr_id
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = ufs_pr_id
   SET request->xxx_combine_det[icombinedet].entity_name = "PRSNL_RELTN"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "PRSNL_RELTN_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = ufs_pr_id
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = concat("Couldn't update prsnl_reltn record with prsnl_reltn_id=",
     cnvtstring(ufs_pr_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (revend_eff(res_prchild_id=f8,res_to_count=i4) =i2)
   UPDATE  FROM prsnl_reltn_child prc
    SET prc.end_effective_dt_tm = cnvtdatetime(sysdate), prc.updt_dt_tm = cnvtdatetime(sysdate), prc
     .updt_id = reqinfo->updt_id,
     prc.updt_applctx = reqinfo->updt_applctx, prc.updt_task = reqinfo->updt_task, prc.updt_cnt = (
     prc.updt_cnt+ 1)
    WHERE prc.prsnl_reltn_child_id=res_prchild_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = revendeff
   SET request->xxx_combine_det[icombinedet].entity_name = "PRSNL_RELTN_CHILD"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PRSNL_RELTN_ID"
   SET request->xxx_combine_det[icombinedet].prev_end_eff_dt_tm = rreclistchild->to_rec[res_to_count]
   .prev_end_eff_dt_tm
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "PRSNL_RELTN_CHILD_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = res_prchild_id
   IF (curqual=0)
    SET failed = eff_error
    SET request->error_message = build(
     "END_EFF: No values found on the prsnl_reltn_child table with prsnl_reltn_child_id = ",
     res_prchild_id)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#end_of_program
 FREE RECORD rreclist
 FREE RECORD rreclistchild
END GO
