CREATE PROGRAM dm_prucb_da_group_security:dba
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
  SET dcem_request->qual[1].parent_entity = "PRSNL"
  SET dcem_request->qual[1].child_entity = "DA_GROUP_SECURITY"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "DM_PRUCB_DA_GROUP_SECURITY"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 1
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO end_of_program
 ENDIF
 IF ((rchildren->qual1[det_cnt].combine_action_cd=del))
  CALL cust_ucb_del(0)
 ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=upt))
  CALL cust_ucb_upt(0)
 ELSE
  SET ucb_failed = data_error
  SET error_table = rchildren->qual1[det_cnt].entity_name
  GO TO end_of_program
 ENDIF
 SUBROUTINE cust_ucb_del(dummy)
   SET cust_del_buff = fillstring(1000," ")
   SET cust_del_buff = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name),
    " set updt_id = reqinfo->updt_id, ","updt_dt_tm = cnvtdatetime(curdate,curtime3), ",
    "updt_applctx = reqinfo->updt_applctx, ",
    "updt_cnt = updt_cnt + 1, ","updt_task = reqinfo->updt_task, ",trim(rchildren->qual1[det_cnt].
     attribute_name)," = REQUEST->XXX_UNCOMBINE[ucb_cnt]->TO_XXX_ID, ",
    "active_ind = rChildren->QUAL1[det_cnt]->PREV_ACTIVE_IND, ",
    "end_effective_dt_tm = rChildren->QUAL1[det_cnt]->PREV_END_EFFECTIVE_DT_TM, ",
    "active_status_prsnl_id = reqinfo->updt_id ","where ",trim(rchildren->qual1[det_cnt].
     primary_key_attr)," = rChildren->QUAL1[det_cnt]->ENTITY_ID ",
    "with nocounter go ")
   CALL parser(cust_del_buff)
   IF (curqual=0)
    SET ucb_failed = reactivate_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO end_of_program
   ENDIF
   SET activity_updt_cnt += 1
 END ;Subroutine
 SUBROUTINE cust_ucb_upt(dummy)
   SET cust_upt_buff = fillstring(500," ")
   SET cust_upt_buff = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name),
    " set updt_id = reqinfo->updt_id, ","updt_dt_tm = cnvtdatetime(curdate,curtime3), ",
    "updt_applctx = reqinfo->updt_applctx, ",
    "updt_cnt = updt_cnt + 1, ","updt_task = reqinfo->updt_task, ",trim(rchildren->qual1[det_cnt].
     attribute_name)," = REQUEST->XXX_UNCOMBINE[ucb_cnt]->TO_XXX_ID ","where ",
    trim(rchildren->qual1[det_cnt].attribute_name)," = REQUEST->XXX_UNCOMBINE[ucb_cnt]->FROM_XXX_ID ",
    " and ",trim(rchildren->qual1[det_cnt].primary_key_attr),
    " = rChildren->QUAL1[det_cnt]->ENTITY_ID ",
    "with nocounter go ")
   CALL parser(cust_upt_buff)
   IF (curqual=0)
    SET ucb_failed = update_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO end_of_program
   ENDIF
   SET activity_updt_cnt += 1
 END ;Subroutine
#end_of_program
END GO
