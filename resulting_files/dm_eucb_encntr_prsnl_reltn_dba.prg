CREATE PROGRAM dm_eucb_encntr_prsnl_reltn:dba
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
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "ENCOUNTER"
  SET dcem_request->qual[1].child_entity = "ENCNTR_PRSNL_RELTN"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "DM_EUCB_ENCNTR_PRSNL_RELTN"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 2
  SET dcem_request->qual[1].del_chg_id_ind = 1
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 DECLARE encntrtypecd_exists = i2
 DECLARE encntrtypecd_value = f8
 SET encntrtypecd_exists = 0
 SET encntrtypecd_value = 0.0
 SELECT INTO "NL:"
  l.attr_name
  FROM dtable t,
   dtableattr a,
   dtableattrl l
  WHERE t.table_name="ENCNTR_PRSNL_RELTN"
   AND t.table_name=a.table_name
   AND l.structtype="F"
   AND btest(l.stat,11)=0
   AND l.attr_name="ENCNTR_TYPE_CD"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET encntrtypecd_exists = 1
  SELECT INTO "nl:"
   FROM encounter e
   WHERE (e.encntr_id=request->xxx_uncombine[ucb_cnt].to_xxx_id)
   DETAIL
    encntrtypecd_value = e.encntr_type_cd
   WITH nocounter
  ;end select
 ENDIF
 SET cust_ucb_dummy = 0
 IF ((rchildren->qual1[det_cnt].combine_action_cd=add))
  CALL cust_ucb_add(cust_ucb_dummy)
 ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=del))
  CALL cust_ucb_del(cust_ucb_dummy)
 ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=eff))
  CALL cust_ucb_eff(cust_ucb_dummy)
 ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=upt))
  CALL cust_ucb_upt(cust_ucb_dummy)
 ELSE
  SET ucb_failed = data_error
  SET error_table = rchildren->qual1[det_cnt].entity_name
  SET request->error_message = build("Unrecognized combine action code found: ",rchildren->qual1[
   det_cnt].combine_action_cd)
  GO TO exit_sub
 ENDIF
#exit_sub
 SUBROUTINE cust_ucb_add(dummy)
  UPDATE  FROM encntr_prsnl_reltn epr
   SET epr.active_ind = false, epr.active_status_cd = reqdata->inactive_status_cd, epr.updt_id =
    reqinfo->updt_id,
    epr.updt_dt_tm = cnvtdatetime(sysdate), epr.updt_applctx = reqinfo->updt_applctx, epr.updt_cnt =
    (epr.updt_cnt+ 1),
    epr.updt_task = reqinfo->updt_task
   WHERE (epr.encntr_prsnl_reltn_id=rchildren->qual1[det_cnt].entity_id)
   WITH nocounter
  ;end update
  SET activity_updt_cnt += 1
 END ;Subroutine
 SUBROUTINE cust_ucb_del(dummy)
  IF (encntrtypecd_exists=1)
   UPDATE  FROM encntr_prsnl_reltn epr
    SET epr.encntr_type_cd = encntrtypecd_value, epr.updt_id = reqinfo->updt_id, epr.updt_dt_tm =
     cnvtdatetime(sysdate),
     epr.updt_applctx = reqinfo->updt_applctx, epr.active_ind = rchildren->qual1[det_cnt].
     prev_active_ind, epr.updt_cnt = (epr.updt_cnt+ 1),
     epr.updt_task = reqinfo->updt_task, epr.encntr_id = request->xxx_uncombine[ucb_cnt].to_xxx_id,
     epr.active_ind = rchildren->qual1[det_cnt].prev_active_ind,
     epr.active_status_cd = rchildren->qual1[det_cnt].prev_active_status_cd
    WHERE (epr.encntr_prsnl_reltn_id=rchildren->qual1[det_cnt].entity_id)
    WITH nocounter
   ;end update
  ELSE
   UPDATE  FROM encntr_prsnl_reltn epr
    SET epr.updt_id = reqinfo->updt_id, epr.updt_dt_tm = cnvtdatetime(sysdate), epr.updt_applctx =
     reqinfo->updt_applctx,
     epr.active_ind = rchildren->qual1[det_cnt].prev_active_ind, epr.updt_cnt = (epr.updt_cnt+ 1),
     epr.updt_task = reqinfo->updt_task,
     epr.encntr_id = request->xxx_uncombine[ucb_cnt].to_xxx_id, epr.active_ind = rchildren->qual1[
     det_cnt].prev_active_ind, epr.active_status_cd = rchildren->qual1[det_cnt].prev_active_status_cd
    WHERE (epr.encntr_prsnl_reltn_id=rchildren->qual1[det_cnt].entity_id)
    WITH nocounter
   ;end update
  ENDIF
  SET activity_updt_cnt += 1
 END ;Subroutine
 SUBROUTINE cust_ucb_upt(dummy)
  IF (encntrtypecd_exists=1)
   UPDATE  FROM encntr_prsnl_reltn epr
    SET epr.encntr_type_cd = encntrtypecd_value, epr.updt_id = reqinfo->updt_id, epr.updt_dt_tm =
     cnvtdatetime(sysdate),
     epr.updt_applctx = reqinfo->updt_applctx, epr.updt_cnt = (epr.updt_cnt+ 1), epr.updt_task =
     reqinfo->updt_task,
     epr.encntr_id = request->xxx_uncombine[ucb_cnt].to_xxx_id
    WHERE (epr.encntr_prsnl_reltn_id=rchildren->qual1[det_cnt].entity_id)
    WITH nocounter
   ;end update
  ELSE
   UPDATE  FROM encntr_prsnl_reltn epr
    SET epr.updt_id = reqinfo->updt_id, epr.updt_dt_tm = cnvtdatetime(sysdate), epr.updt_applctx =
     reqinfo->updt_applctx,
     epr.updt_cnt = (epr.updt_cnt+ 1), epr.updt_task = reqinfo->updt_task, epr.encntr_id = request->
     xxx_uncombine[ucb_cnt].to_xxx_id
    WHERE (epr.encntr_prsnl_reltn_id=rchildren->qual1[det_cnt].entity_id)
    WITH nocounter
   ;end update
  ENDIF
  SET activity_updt_cnt += 1
 END ;Subroutine
 SUBROUTINE cust_ucb_eff(dummy)
  IF (encntrtypecd_exists=1)
   UPDATE  FROM encntr_prsnl_reltn epr
    SET epr.encntr_type_cd = encntrtypecd_value, epr.updt_id = reqinfo->updt_id, epr.updt_dt_tm =
     cnvtdatetime(sysdate),
     epr.updt_applctx = reqinfo->updt_applctx, epr.updt_cnt = (epr.updt_cnt+ 1), epr.updt_task =
     reqinfo->updt_task,
     epr.encntr_id = request->xxx_uncombine[ucb_cnt].to_xxx_id, epr.end_effective_dt_tm =
     cnvtdatetime(rchildren->qual1[det_cnt].prev_end_eff_dt_tm)
    WHERE (epr.encntr_prsnl_reltn_id=rchildren->qual1[det_cnt].entity_id)
    WITH nocounter
   ;end update
  ELSE
   UPDATE  FROM encntr_prsnl_reltn epr
    SET epr.updt_id = reqinfo->updt_id, epr.updt_dt_tm = cnvtdatetime(sysdate), epr.updt_applctx =
     reqinfo->updt_applctx,
     epr.updt_cnt = (epr.updt_cnt+ 1), epr.updt_task = reqinfo->updt_task, epr.encntr_id = request->
     xxx_uncombine[ucb_cnt].to_xxx_id,
     epr.end_effective_dt_tm = cnvtdatetime(rchildren->qual1[det_cnt].prev_end_eff_dt_tm)
    WHERE (epr.encntr_prsnl_reltn_id=rchildren->qual1[det_cnt].entity_id)
    WITH nocounter
   ;end update
  ENDIF
  SET activity_updt_cnt += 1
 END ;Subroutine
END GO
