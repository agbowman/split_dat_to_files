CREATE PROGRAM dm_pucb_eem_trans_reltn:dba
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
 DECLARE s_log_handle = i4 WITH protect, noconstant(0)
 DECLARE s_log_status = i4 WITH protect, noconstant(0)
 DECLARE s_message = vc WITH protect, noconstant("")
 SUBROUTINE (sch_log_message(l_event=vc,l_script_name=vc,l_message=vc,l_loglevel=i2) =null)
   IF ((l_loglevel > - (1))
    AND textlen(trim(l_message,3)) > 0)
    SET s_message = build("script::",l_script_name,", message::",l_message)
    CALL uar_syscreatehandle(s_log_handle,s_log_status)
    IF (s_log_handle != 0)
     CALL uar_sysevent(s_log_handle,l_loglevel,nullterm(l_event),nullterm(s_message))
     CALL uar_sysdestroyhandle(s_log_handle)
    ENDIF
   ENDIF
 END ;Subroutine
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "EEM_TRANS_RELTN"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "DM_PUCB_EEM_TRANS_RELTN"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_script
 ENDIF
 DECLARE cust_ucb_dummy = i2
 IF ((rchildren->qual1[det_cnt].combine_action_cd=upt))
  CALL cust_ucb_upt(cust_ucb_dummy)
 ELSE
  SET ucb_failed = data_error
  SET error_table = rchildren->qual1[det_cnt].entity_name
  GO TO exit_script
 ENDIF
 SUBROUTINE (cust_ucb_upt(dummy=i2) =null)
   UPDATE  FROM eem_trans_reltn
    SET updt_id = reqinfo->updt_id, updt_dt_tm = cnvtdatetime(sysdate), updt_applctx = reqinfo->
     updt_applctx,
     updt_task = reqinfo->updt_task, parent_entity_id = request->xxx_uncombine[ucb_cnt].to_xxx_id
    WHERE (parent_entity_id=request->xxx_uncombine[ucb_cnt].from_xxx_id)
     AND (eem_trans_reltn_id=rchildren->qual1[det_cnt].entity_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_log_message = "The EEM_TRANS_RELTN update was not successful"
    CALL sch_log_message("EEM_TRANS_RELTN_UNCOMBINE","dm_pucb_eem_trans_reltn",error_log_message,2)
   ENDIF
   SET activity_updt_cnt += 1
 END ;Subroutine
#exit_script
END GO
