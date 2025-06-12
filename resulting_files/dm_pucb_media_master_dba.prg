CREATE PROGRAM dm_pucb_media_master:dba
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
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "MEDIA_MASTER"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "DM_PUCB_MEDIA_MASTER"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 SET cust_ucb_dummy = 0
 IF ((rchildren->qual1[det_cnt].combine_action_cd=del))
  CALL cust_ucb_del(cust_ucb_dummy)
 ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=upt))
  CALL cust_ucb_upt(cust_ucb_dummy)
 ELSE
  SET ucb_failed = data_error
  SET error_table = rchildren->qual1[det_cnt].entity_name
  GO TO exit_sub
 ENDIF
#exit_sub
 SUBROUTINE cust_ucb_del(dummy)
   UPDATE  FROM media_master mm
    SET mm.active_ind = 1, mm.active_status_cd = reqdata->active_status_cd, mm.end_effective_dt_tm =
     cnvtdatetime(rchildren->qual1[det_cnt].prev_end_eff_dt_tm),
     mm.active_status_dt_tm = cnvtdatetime(sysdate), mm.active_status_prsnl_id = reqinfo->updt_id, mm
     .updt_id = reqinfo->updt_id,
     mm.updt_dt_tm = cnvtdatetime(sysdate), mm.updt_applctx = reqinfo->updt_applctx, mm.updt_task =
     reqinfo->updt_task
    WHERE (mm.media_master_id=rchildren->qual1[det_cnt].entity_id)
    WITH nocounter
   ;end update
   UPDATE  FROM media_master_alias ma
    SET ma.active_ind = 1, ma.active_status_cd = reqdata->active_status_cd, ma.end_effective_dt_tm =
     cnvtdatetime(rchildren->qual1[det_cnt].prev_end_eff_dt_tm),
     ma.active_status_dt_tm = cnvtdatetime(sysdate), ma.active_status_prsnl_id = reqinfo->updt_id, ma
     .updt_id = reqinfo->updt_id,
     ma.updt_dt_tm = cnvtdatetime(sysdate), ma.updt_applctx = reqinfo->updt_applctx, ma.updt_task =
     reqinfo->updt_task
    WHERE (ma.media_master_id=rchildren->qual1[det_cnt].entity_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET ucb_failed = reactivate_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt += 1
 END ;Subroutine
 SUBROUTINE cust_ucb_upt(dummy)
   UPDATE  FROM media_master mm
    SET mm.active_ind = rchildren->qual1[det_cnt].prev_active_ind, mm.updt_id = reqinfo->updt_id, mm
     .updt_dt_tm = cnvtdatetime(sysdate),
     mm.updt_applctx = reqinfo->updt_applctx, mm.updt_cnt = (updt_cnt+ 1), mm.updt_task = reqinfo->
     updt_task,
     mm.person_id = request->xxx_uncombine[ucb_cnt].to_xxx_id
    WHERE (mm.media_master_id=rchildren->qual1[det_cnt].entity_id)
    WITH nocounter
   ;end update
   UPDATE  FROM media_encntr_reltn mr
    SET mr.active_ind = 0, mr.active_status_cd = reqdata->inactive_status_cd, mr
     .active_status_prsnl_id = reqinfo->updt_id,
     mr.updt_id = reqinfo->updt_id, mr.updt_dt_tm = cnvtdatetime(sysdate), mr.updt_applctx = reqinfo
     ->updt_applctx,
     mr.updt_cnt = (mr.updt_cnt+ 1), mr.updt_task = reqinfo->updt_task
    WHERE (mr.media_master_id=rchildren->qual1[det_cnt].entity_id)
    WITH nocounter
   ;end update
   SET activity_updt_cnt += 1
 END ;Subroutine
END GO
