CREATE PROGRAM dm_eucb_wl_activity:dba
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
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "ENCOUNTER"
  SET dcem_request->qual[1].child_entity = "WL_ACTIVITY"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "DM_EUCB_WL_ACTIVITY"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 IF ((rchildren->qual1[det_cnt].combine_action_cd=del))
  CALL cust_ucb_del2(null)
 ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=upt))
  IF ((rchildren->qual1[det_cnt].attribute_name="ENCNTR_ID"))
   CALL cust_ucb_upt_wl_activity(null)
  ELSE
   CALL cust_ucb_upt_wl_activity_detail(null)
  ENDIF
 ELSE
  SET ucb_failed = data_error
  SET error_table = rchildren->qual1[det_cnt].entity_name
  GO TO exit_sub
 ENDIF
 SUBROUTINE cust_ucb_del2(null)
   CALL echo("Begin cust_ucb_del2")
   DECLARE active_cd = f8
   SET active_cd = uar_get_code_by("MEANING",48,"ACTIVE")
   UPDATE  FROM wl_activity wl
    SET wl.active_ind = 1, wl.active_status_cd = active_cd, wl.active_status_dt_tm = cnvtdatetime(
      curdate,curtime3),
     wl.active_status_prsnl_id = reqinfo->updt_id, wl.beg_effective_dt_tm = cnvtdatetime(curdate,
      curtime), wl.updt_id = reqinfo->updt_id,
     wl.updt_dt_tm = cnvtdatetime(curdate,curtime3), wl.updt_applctx = reqinfo->updt_applctx, wl
     .updt_cnt = (updt_cnt+ 1),
     wl.updt_task = reqinfo->updt_task
    WHERE (wl.wl_activity_id=rchildren->qual1[det_cnt].entity_id)
   ;end update
   IF (curqual=0)
    SET ucb_failed = reactivate_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt = (activity_updt_cnt+ 1)
   CALL echo("End cust_ucb_del2")
 END ;Subroutine
 SUBROUTINE cust_ucb_upt_wl_activity(null)
   CALL echo("Begin cust_ucb_upt_wl_activity")
   UPDATE  FROM wl_activity wl
    SET wl.encntr_id = request->xxx_uncombine[ucb_cnt].to_xxx_id, wl.updt_id = reqinfo->updt_id, wl
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     wl.updt_applctx = reqinfo->updt_applctx, wl.updt_cnt = (updt_cnt+ 1), wl.updt_task = reqinfo->
     updt_task,
     wl.end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (wl.wl_activity_id=rchildren->qual1[det_cnt].entity_id)
   ;end update
   IF (curqual=0)
    SET ucb_failed = update_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt = (activity_updt_cnt+ 1)
   CALL echo("End cust_ucb_upt_wl_activity")
 END ;Subroutine
 SUBROUTINE cust_ucb_upt_wl_activity_detail(null)
   CALL echo("Begin cust_ucb_upt_wl_activity_detail")
   UPDATE  FROM wl_activity_detail wl
    SET wl.wl_activity_id = rchildren->qual1[det_cnt].entity_id, wl.updt_id = reqinfo->updt_id, wl
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     wl.updt_applctx = reqinfo->updt_applctx, wl.updt_cnt = (updt_cnt+ 1), wl.updt_task = reqinfo->
     updt_task
    WHERE wl.wl_activity_detail_id=cnvtreal(rchildren->qual1[det_cnt].attribute_name)
   ;end update
   IF (curqual=0)
    SET ucb_failed = update_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt = (activity_updt_cnt+ 1)
   CALL echo("End cust_ucb_upt_wl_activity_detail")
 END ;Subroutine
#exit_sub
END GO
