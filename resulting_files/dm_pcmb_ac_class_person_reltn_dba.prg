CREATE PROGRAM dm_pcmb_ac_class_person_reltn:dba
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
 FREE RECORD rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 from_id = f8
     2 encntr_focused_ind = i2
     2 suspect_flag = i2
     2 registry_id = f8
     2 condition_id = f8
     2 parent_id = f8
     2 org_id = f8
     2 loc_cd = f8
   1 to_rec[*]
     2 from_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 registry_id = f8
     2 condition_id = f8
     2 parent_id = f8
     2 org_id = f8
     2 loc_cd = f8
 )
 DECLARE match_ind = i2 WITH noconstant(false)
 DECLARE tcnt = i4 WITH noconstant(0)
 DECLARE temp_parent_id = f8 WITH noconstant(0)
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "AC_CLASS_PERSON_RELTN"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PCMB_AC_CLASS_PERSON_RELTN"
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
  FROM ac_class_person_reltn acpr,
   ac_class_person_reltn acpr2
  PLAN (acpr
   WHERE (acpr.person_id=request->xxx_combine[icombine].from_xxx_id)
    AND acpr.ac_class_person_reltn_id=acpr.parent_class_person_reltn_id)
   JOIN (acpr2
   WHERE (acpr2.parent_class_person_reltn_id= Outerjoin(acpr.ac_class_person_reltn_id)) )
  ORDER BY acpr.parent_class_person_reltn_id, acpr2.ac_class_def_id
  HEAD REPORT
   qcnt = 0
  DETAIL
   qcnt += 1
   IF (mod(qcnt,100)=1)
    stat = alterlist(rreclist->from_rec,(qcnt+ 99))
   ENDIF
   rreclist->from_rec[qcnt].registry_id = acpr.ac_class_def_id, rreclist->from_rec[qcnt].loc_cd =
   acpr.location_cd, rreclist->from_rec[qcnt].org_id = acpr.organization_id,
   rreclist->from_rec[qcnt].parent_id = acpr.parent_class_person_reltn_id
   IF (acpr2.ac_class_person_reltn_id=acpr2.parent_class_person_reltn_id)
    rreclist->from_rec[qcnt].from_id = acpr.ac_class_person_reltn_id, rreclist->from_rec[qcnt].
    condition_id = 0
   ELSE
    rreclist->from_rec[qcnt].from_id = acpr2.ac_class_person_reltn_id, rreclist->from_rec[qcnt].
    condition_id = acpr2.ac_class_def_id
   ENDIF
  FOOT REPORT
   stat = alterlist(rreclist->from_rec,qcnt)
  WITH nocounter
 ;end select
 IF (size(rreclist->from_rec,5) > 0)
  SELECT INTO "nl:"
   FROM ac_class_person_reltn acpr
   PLAN (acpr
    WHERE (acpr.person_id=request->xxx_combine[icombine].to_xxx_id))
   WITH nocounter, forupdatewait(acpr)
  ;end select
  IF (curqual > 0)
   SELECT INTO "nl:"
    FROM ac_class_person_reltn acpr,
     ac_class_person_reltn acpr2
    PLAN (acpr
     WHERE (acpr.person_id=request->xxx_combine[icombine].to_xxx_id)
      AND acpr.ac_class_person_reltn_id=acpr.parent_class_person_reltn_id)
     JOIN (acpr2
     WHERE (acpr2.parent_class_person_reltn_id= Outerjoin(acpr.ac_class_person_reltn_id)) )
    ORDER BY acpr.parent_class_person_reltn_id, acpr2.ac_class_def_id
    HEAD REPORT
     qcnt = 0
    DETAIL
     qcnt += 1
     IF (mod(qcnt,100)=1)
      stat = alterlist(rreclist->to_rec,(qcnt+ 99))
     ENDIF
     rreclist->to_rec[qcnt].registry_id = acpr.ac_class_def_id, rreclist->to_rec[qcnt].loc_cd = acpr
     .location_cd, rreclist->to_rec[qcnt].org_id = acpr.organization_id,
     rreclist->to_rec[qcnt].parent_id = acpr.parent_class_person_reltn_id
     IF (acpr2.ac_class_person_reltn_id=acpr2.parent_class_person_reltn_id)
      rreclist->to_rec[qcnt].from_id = acpr.ac_class_person_reltn_id, rreclist->to_rec[qcnt].
      condition_id = 0
     ELSE
      rreclist->to_rec[qcnt].from_id = acpr2.ac_class_person_reltn_id, rreclist->to_rec[qcnt].
      condition_id = acpr2.ac_class_def_id
     ENDIF
    FOOT REPORT
     stat = alterlist(rreclist->to_rec,qcnt)
    WITH nocounter
   ;end select
  ENDIF
  FOR (fidx = 1 TO size(rreclist->from_rec,5))
    SET match_ind = false
    SET tcnt = 1
    SET temp_parent_id = 0
    IF (size(rreclist->to_rec,5) > 0)
     WHILE (match_ind=false
      AND tcnt <= size(rreclist->to_rec,5))
      IF ((rreclist->from_rec[fidx].registry_id=rreclist->to_rec[tcnt].registry_id)
       AND (rreclist->from_rec[fidx].condition_id=rreclist->to_rec[tcnt].condition_id)
       AND (rreclist->from_rec[fidx].loc_cd=rreclist->to_rec[tcnt].loc_cd)
       AND (rreclist->from_rec[fidx].org_id=rreclist->to_rec[tcnt].org_id))
       CALL endeff_class_person_reltn(rreclist->from_rec[fidx].from_id,request->xxx_combine[icombine]
        .to_xxx_id)
       SET match_ind = true
      ELSEIF ((rreclist->from_rec[fidx].registry_id=rreclist->to_rec[tcnt].registry_id)
       AND (rreclist->from_rec[fidx].condition_id != rreclist->to_rec[tcnt].condition_id)
       AND (rreclist->from_rec[fidx].loc_cd=rreclist->to_rec[tcnt].loc_cd)
       AND (rreclist->from_rec[fidx].org_id=rreclist->to_rec[tcnt].org_id))
       SET temp_parent_id = rreclist->to_rec[tcnt].parent_id
      ENDIF
      SET tcnt += 1
     ENDWHILE
     IF (match_ind=false)
      IF (temp_parent_id > 0)
       CALL move_class_person_reltn(rreclist->from_rec[fidx].from_id,request->xxx_combine[icombine].
        to_xxx_id,temp_parent_id)
      ELSE
       CALL move_class_person_reltn(rreclist->from_rec[fidx].from_id,request->xxx_combine[icombine].
        to_xxx_id,rreclist->from_rec[fidx].parent_id)
      ENDIF
     ENDIF
    ELSE
     CALL move_class_person_reltn(rreclist->from_rec[fidx].from_id,request->xxx_combine[icombine].
      to_xxx_id,rreclist->from_rec[fidx].parent_id)
    ENDIF
  ENDFOR
 ELSE
  GO TO exit_sub
 ENDIF
 SUBROUTINE (move_class_person_reltn(acpr_id=f8,to_fk_id=f8,acpr_parent_id=f8) =null)
   UPDATE  FROM ac_class_person_reltn acpr
    SET acpr.person_id = to_fk_id, acpr.parent_class_person_reltn_id = acpr_parent_id, acpr
     .updt_applctx = reqinfo->updt_applctx,
     acpr.updt_cnt = (acpr.updt_cnt+ 1), acpr.updt_dt_tm = cnvtdatetime(sysdate), acpr.updt_id =
     reqinfo->updt_id,
     acpr.updt_task = reqinfo->updt_task
    PLAN (acpr
     WHERE acpr.ac_class_person_reltn_id=acpr_id)
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = acpr_id
   SET request->xxx_combine_det[icombinedet].entity_name = "AC_CLASS_PERSON_RELTN"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = substring(1,132,build("Could not update pk val=",acpr_id))
   ENDIF
 END ;Subroutine
 SUBROUTINE (endeff_class_person_reltn(acpr_id=f8,to_fk_id=f8) =null)
   UPDATE  FROM ac_class_person_reltn acpr
    SET acpr.person_id = to_fk_id, acpr.active_ind = 0, acpr.end_effective_dt_tm = cnvtdatetime(
      sysdate),
     acpr.updt_applctx = reqinfo->updt_applctx, acpr.updt_cnt = (acpr.updt_cnt+ 1), acpr.updt_dt_tm
      = cnvtdatetime(sysdate),
     acpr.updt_id = reqinfo->updt_id, acpr.updt_task = reqinfo->updt_task
    PLAN (acpr
     WHERE acpr.ac_class_person_reltn_id=acpr_id)
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = eff
   SET request->xxx_combine_det[icombinedet].entity_id = acpr_id
   SET request->xxx_combine_det[icombinedet].entity_name = "AC_CLASS_PERSON_RELTN"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   IF (curqual=0)
    SET failed = eff_error
    SET request->error_message = substring(1,132,build("Could not update pk val=",acpr_id))
   ENDIF
 END ;Subroutine
#exit_sub
 FREE RECORD rreclist
END GO
