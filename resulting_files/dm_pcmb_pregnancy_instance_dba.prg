CREATE PROGRAM dm_pcmb_pregnancy_instance:dba
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
     2 active_status_cd = f8
     2 pregnancy_id = f8
     2 end_effective_dt_tm = dq8
     2 preg_end_dt_tm = dq8
     2 organization_id = f8
   1 to_rec[*]
     2 to_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 pregnancy_id = f8
     2 end_effective_dt_tm = dq8
     2 preg_end_dt_tm = dq8
     2 organization_id = f8
 )
 DECLARE v_cust_count1 = i4
 DECLARE v_cust_count2 = i4
 DECLARE v_cust_loopcount = i4
 DECLARE v_cust_loopcount2 = i4
 DECLARE conflict_preg_cnt = i4
 DECLARE preg_idx = i4
 DECLARE preg_pos = i4
 DECLARE preg_org_sec_ind = i4
 SET v_cust_count1 = 0
 SET v_cust_count2 = 0
 SET v_cust_loopcount = 0
 SET v_cust_loopcount2 = 0
 SET conflict_preg_cnt = 0
 SET preg_idx = 0
 SET preg_pos = 0
 SET preg_org_sec_ind = 0
 FREE SET conflict_pregs
 RECORD conflict_pregs(
   1 pregnancies[*]
     2 pregnancy_id = f8
 )
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "PREGNANCY_INSTANCE"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PCMB_PREGNANCY_INSTANCE"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 2
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info d1,
   dm_info d2
  WHERE d1.info_domain="SECURITY"
   AND d1.info_name="SEC_ORG_RELTN"
   AND d1.info_number=1
   AND d2.info_domain="SECURITY"
   AND d2.info_name="SEC_PREG_ORG_RELTN"
   AND d2.info_number=1
  DETAIL
   preg_org_sec_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  frm.*
  FROM pregnancy_instance frm
  WHERE (frm.person_id=request->xxx_combine[icombine].from_xxx_id)
  DETAIL
   v_cust_count1 += 1
   IF (mod(v_cust_count1,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count1].from_id = frm.pregnancy_instance_id, rreclist->from_rec[
   v_cust_count1].active_ind = frm.active_ind, rreclist->from_rec[v_cust_count1].active_status_cd =
   frm.active_status_cd,
   rreclist->from_rec[v_cust_count1].end_effective_dt_tm = frm.end_effective_dt_tm, rreclist->
   from_rec[v_cust_count1].preg_end_dt_tm = frm.preg_end_dt_tm, rreclist->from_rec[v_cust_count1].
   pregnancy_id = frm.pregnancy_id,
   rreclist->from_rec[v_cust_count1].organization_id = frm.organization_id
  WITH forupdatewait(frm)
 ;end select
 IF (v_cust_count1 > 0)
  SELECT INTO "nl:"
   tu.*
   FROM pregnancy_instance tu
   WHERE (tu.person_id=request->xxx_combine[icombine].to_xxx_id)
   DETAIL
    v_cust_count2 += 1
    IF (mod(v_cust_count2,10)=1)
     stat = alterlist(rreclist->to_rec,(v_cust_count2+ 9))
    ENDIF
    rreclist->to_rec[v_cust_count2].to_id = tu.pregnancy_instance_id, rreclist->to_rec[v_cust_count2]
    .active_ind = tu.active_ind, rreclist->to_rec[v_cust_count2].active_status_cd = tu
    .active_status_cd,
    rreclist->to_rec[v_cust_count2].end_effective_dt_tm = tu.end_effective_dt_tm, rreclist->to_rec[
    v_cust_count2].preg_end_dt_tm = tu.preg_end_dt_tm, rreclist->to_rec[v_cust_count2].pregnancy_id
     = tu.pregnancy_id,
    rreclist->to_rec[v_cust_count2].organization_id = tu.organization_id
   WITH forupdatewait(tu)
  ;end select
  FOR (v_cust_loopcount = 1 TO v_cust_count1)
    IF ((rreclist->from_rec[v_cust_loopcount].active_ind=1)
     AND (rreclist->from_rec[v_cust_loopcount].preg_end_dt_tm=cnvtdatetime("31-DEC-2100")))
     SET preg_pos = locateval(preg_idx,1,conflict_preg_cnt,rreclist->from_rec[v_cust_loopcount].
      pregnancy_id,conflict_pregs->pregnancies[preg_idx].pregnancy_id)
     IF (preg_pos=0)
      FOR (v_cust_loopcount2 = 1 TO v_cust_count2)
        IF ((rreclist->to_rec[v_cust_loopcount2].active_ind=1)
         AND (rreclist->to_rec[v_cust_loopcount2].preg_end_dt_tm=cnvtdatetime("31-DEC-2100")))
         IF (((preg_org_sec_ind=0) OR ((((rreclist->from_rec[v_cust_loopcount].organization_id=0))
          OR ((((rreclist->to_rec[v_cust_loopcount2].organization_id=0)) OR ((rreclist->from_rec[
         v_cust_loopcount].organization_id=rreclist->to_rec[v_cust_loopcount2].organization_id))) ))
         )) )
          SET conflict_preg_cnt += 1
          IF (mod(conflict_preg_cnt,10)=1)
           SET stat = alterlist(conflict_pregs->pregnancies,(conflict_preg_cnt+ 9))
          ENDIF
          SET conflict_pregs->pregnancies[conflict_preg_cnt].pregnancy_id = rreclist->from_rec[
          v_cust_loopcount].pregnancy_id
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
  ENDFOR
  SET stat = alterlist(conflict_pregs->pregnancies,conflict_preg_cnt)
  SET preg_pos = 0
  SET preg_idx = 0
  FOR (v_cust_loopcount = 1 TO v_cust_count1)
    IF ((rreclist->from_rec[v_cust_loopcount].active_status_cd != combinedaway))
     SET preg_pos = locateval(preg_idx,1,size(conflict_pregs->pregnancies,5),rreclist->from_rec[
      v_cust_loopcount].pregnancy_id,conflict_pregs->pregnancies[preg_idx].pregnancy_id)
     IF (preg_pos > 0)
      IF (del_from(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
       to_xxx_id,rreclist->from_rec[v_cust_loopcount].active_ind,rreclist->from_rec[v_cust_loopcount]
       .active_status_cd,rreclist->from_rec[v_cust_loopcount].end_effective_dt_tm)=0)
       GO TO exit_sub
      ENDIF
     ELSE
      IF (upt_from(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
       to_xxx_id)=0)
       GO TO exit_sub
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE del_from(s_df_pk_id,s_df_to_fk_id,s_df_prev_act_ind,s_df_prev_act_status,
  s_df_prev_end_eff_dt_tm)
   UPDATE  FROM pregnancy_instance frm
    SET frm.active_ind = false, frm.active_status_cd = combinedaway, frm.updt_cnt = (frm.updt_cnt+ 1),
     frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task =
     reqinfo->updt_task,
     frm.updt_dt_tm = cnvtdatetime(sysdate), frm.end_effective_dt_tm = cnvtdatetime(sysdate)
    WHERE frm.pregnancy_instance_id=s_df_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = s_df_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "PREGNANCY_INSTANCE"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
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
 SUBROUTINE upt_from(s_uf_pk_id,s_uf_to_fk_id)
   UPDATE  FROM pregnancy_instance frm
    SET frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo
     ->updt_applctx,
     frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm = cnvtdatetime(sysdate), frm.person_id =
     s_uf_to_fk_id
    WHERE frm.pregnancy_instance_id=s_uf_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = s_uf_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "PREGNANCY_INSTANCE"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
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
