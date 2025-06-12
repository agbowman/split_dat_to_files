CREATE PROGRAM dm_eucb_drg_specialty:dba
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
  SET dcem_request->qual[1].child_entity = "DRG_SPECIALTY"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "dm_eucb_drg_specialty"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 2
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 UPDATE  FROM drg_specialty ds
  SET ds.active_ind = 0, ds.active_status_cd = reqdata->inactive_status_cd, ds.updt_id = reqinfo->
   updt_id,
   ds.updt_dt_tm = cnvtdatetime(sysdate), ds.updt_applctx = reqinfo->updt_applctx, ds.updt_cnt = (ds
   .updt_cnt+ 1),
   ds.updt_task = reqinfo->updt_task
  WHERE (ds.encntr_id=request->xxx_uncombine[ucb_cnt].from_xxx_id)
   AND ds.encntr_slice_id=0.0
   AND ds.active_ind=1
  WITH nocounter
 ;end update
 SET cust_ucb_dummy = 0
 IF ((rchildren->qual1[det_cnt].combine_action_cd=del))
  CALL cust_ucb_del(cust_ucb_dummy)
 ELSE
  SET ucb_failed = data_error
  SET error_table = rchildren->qual1[det_cnt].entity_name
  GO TO exit_sub
 ENDIF
 GO TO exit_sub
 SUBROUTINE cust_ucb_del(dummy)
   UPDATE  FROM drg_specialty ds
    SET ds.active_ind = rchildren->qual1[det_cnt].prev_active_ind, ds.end_effective_dt_tm =
     cnvtdatetime(rchildren->qual1[det_cnt].prev_end_eff_dt_tm), ds.updt_id = reqinfo->updt_id,
     ds.updt_dt_tm = cnvtdatetime(sysdate), ds.updt_applctx = reqinfo->updt_applctx, ds.updt_cnt = (
     ds.updt_cnt+ 1),
     ds.updt_task = reqinfo->updt_task
    WHERE (ds.drg_specialty_id=rchildren->qual1[det_cnt].entity_id)
     AND (ds.encntr_id=request->xxx_uncombine[ucb_cnt].to_xxx_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET ucb_failed = reactivate_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt += 1
 END ;Subroutine
#exit_sub
END GO
