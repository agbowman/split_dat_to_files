CREATE PROGRAM dm_eucb_ce_io_total_result:dba
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
 DECLARE ucb_upd_encntr_id(null) = i2
 DECLARE ucb_perform_post_processing(null) = i2
 DECLARE ucb_upd_mark_suspects(null) = i2
 DECLARE v_cust_count1 = i4
 DECLARE v_cust_count2 = i4
 DECLARE v_cust_loopcount = i4
 DECLARE v_cust_updt_stat = i4
 DECLARE ucberrmsg = vc WITH protect, noconstant(" ")
 SET v_cust_count1 = 0
 SET v_cust_count2 = 0
 SET v_cust_loopcount = 0
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "ENCOUNTER"
  SET dcem_request->qual[1].child_entity = "CE_IO_TOTAL_RESULT"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "DM_EUCB_CE_IO_TOTAL_RESULT"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
 ELSE
  IF ((rchildren->qual1[det_cnt].combine_action_cd=upt))
   SET breturn = ucb_upd_encntr_id(null)
   IF (breturn != true)
    GO TO exit_sub
   ENDIF
   IF (ucb_perform_post_processing(null)=false)
    GO TO exit_sub
   ENDIF
   SET breturn = ucb_upd_mark_suspects(null)
   IF (breturn != true)
    GO TO exit_sub
   ENDIF
  ELSE
   SET ucb_failed = data_error
   SET error_table = rchildren->qual1[det_cnt].entity_name
   SET request->error_message = "Invalid combine_action_cd used."
   GO TO exit_sub
  ENDIF
 ENDIF
 SUBROUTINE ucb_upd_encntr_id(null)
   UPDATE  FROM ce_io_total_result iotr
    SET iotr.encntr_id = request->xxx_uncombine[ucb_cnt].to_xxx_id, iotr.updt_dt_tm = cnvtdatetime(
      sysdate), iotr.updt_applctx = reqinfo->updt_applctx,
     iotr.updt_id = reqinfo->updt_id, iotr.updt_cnt = (iotr.updt_cnt+ 1), iotr.updt_task = reqinfo->
     updt_task
    WHERE (iotr.ce_io_total_result_id=rchildren->qual1[det_cnt].entity_id)
    WITH nocounter
   ;end update
   IF (error(ucberrmsg,0) != 0)
    SET ucb_failed = update_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    SET request->error_message = concat(build("Error updating ce_io_total_result_id (",rchildren->
      qual1[det_cnt].entity_id,") to encntr_id (",request->xxx_uncombine[ucb_cnt].to_xxx_id,")"))
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE ucb_perform_post_processing(null)
   DECLARE detcnt = i4
   DECLARE nextdet = i4
   DECLARE retval = i2
   SET detcnt = size(rchildren->qual1,5)
   SET nextdet = (det_cnt+ 1)
   SET retval = true
   IF (nextdet < detcnt)
    SET nextdet = locateval(nextdet,nextdet,detcnt,"CE_IO_TOTAL_RESULT",rchildren->qual1[nextdet].
     entity_name)
    IF (nextdet)
     SET retval = false
    ENDIF
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE ucb_upd_mark_suspects(null)
   DECLARE cutoffdttm = q8
   SET cutoffdttm = datetimeadd(cnvtdatetime(sysdate),- (7))
   UPDATE  FROM ce_io_total_result iotr
    SET iotr.suspect_flag = 2, iotr.updt_dt_tm = cnvtdatetime(sysdate), iotr.updt_applctx = reqinfo->
     updt_applctx,
     iotr.updt_id = reqinfo->updt_id, iotr.updt_cnt = (iotr.updt_cnt+ 1), iotr.updt_task = reqinfo->
     updt_task
    WHERE iotr.encntr_id IN (request->xxx_uncombine[ucb_cnt].to_xxx_id, request->xxx_uncombine[
    ucb_cnt].from_xxx_id)
     AND iotr.suspect_flag != 2
     AND iotr.encntr_focused_ind != 0
     AND iotr.io_total_end_dt_tm >= cnvtdatetime(cutoffdttm)
   ;end update
   RETURN(true)
 END ;Subroutine
#exit_sub
END GO
