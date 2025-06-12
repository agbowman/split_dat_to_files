CREATE PROGRAM dm_pucb_rc_timeline:dba
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
 RECORD rctimeline(
   1 objarray[*]
     2 rc_timeline_id = f8
     2 activity_created_dt_tm = dq8
     2 activity_created_prsnl_id = f8
     2 activity_type_cd = f8
     2 applied_to_cd = f8
     2 applied_to_txt = vc
     2 comment_clob = vc
     2 description_txt = vc
     2 parent_entity_name = vc
     2 priority_nbr = i4
     2 solution_cd = f8
     2 source_reference_ident = vc
 ) WITH protect
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "RC_TIMELINE"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "DM_PUCB_RC_TIMELINE"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 2
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 DECLARE v_current_dt_tm = dq8
 SET v_current_dt_tm = cnvtdatetime(sysdate)
 IF ((rchildren->qual1[det_cnt].combine_action_cd=add))
  CALL cust_ucb_add(1)
 ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=del))
  CALL cust_ucb_del2(1)
 ELSE
  SET ucb_failed = data_error
  SET error_table = rchildren->qual1[det_cnt].entity_name
  GO TO exit_sub
 ENDIF
 SUBROUTINE cust_ucb_add(dummy)
   UPDATE  FROM rc_timeline rct
    SET rct.updt_id = reqinfo->updt_id, rct.updt_dt_tm = cnvtdatetime(v_current_dt_tm), rct
     .updt_applctx = reqinfo->updt_applctx,
     rct.updt_cnt = (rct.updt_cnt+ 1), rct.updt_task = reqinfo->updt_task, rct.active_ind = false,
     rct.active_status_cd = reqdata->inactive_status_cd, rct.active_status_prsnl_id = reqinfo->
     updt_id, rct.active_status_dt_tm = cnvtdatetime(v_current_dt_tm)
    WHERE (rct.parent_entity_id=request->xxx_uncombine[ucb_cnt].from_xxx_id)
     AND (rct.rc_timeline_id=rchildren->qual1[det_cnt].entity_id)
   ;end update
   IF (curqual=0)
    SET ucb_failed = delete_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt += 1
 END ;Subroutine
 SUBROUTINE cust_ucb_del2(dummy)
   DECLARE rctimelinecnt = i4 WITH protect, noconstant(0)
   DECLARE rctimelineidx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM rc_timeline rct
    WHERE (rct.parent_entity_id=request->xxx_uncombine[ucb_cnt].to_xxx_id)
     AND rct.active_ind=false
     AND (rct.rc_timeline_id=rchildren->qual1[det_cnt].entity_id)
    DETAIL
     rctimelinecnt += 1
     IF (mod(rctimelinecnt,10)=1)
      stat = alterlist(rctimeline->objarray,(rctimelinecnt+ 9))
     ENDIF
     stat = alterlist(rctimeline->objarray,rctimelinecnt), rctimeline->objarray[rctimelinecnt].
     activity_created_dt_tm = rct.activity_created_dt_tm, rctimeline->objarray[rctimelinecnt].
     activity_created_prsnl_id = rct.activity_created_prsnl_id,
     rctimeline->objarray[rctimelinecnt].activity_type_cd = rct.activity_type_cd, rctimeline->
     objarray[rctimelinecnt].applied_to_cd = rct.applied_to_cd, rctimeline->objarray[rctimelinecnt].
     applied_to_txt = rct.applied_to_txt,
     rctimeline->objarray[rctimelinecnt].comment_clob = rct.comment_clob, rctimeline->objarray[
     rctimelinecnt].description_txt = rct.description_txt, rctimeline->objarray[rctimelinecnt].
     parent_entity_name = rct.parent_entity_name,
     rctimeline->objarray[rctimelinecnt].priority_nbr = rct.priority_nbr, rctimeline->objarray[
     rctimelinecnt].solution_cd = rct.solution_cd, rctimeline->objarray[rctimelinecnt].
     source_reference_ident = rct.source_reference_ident
    WITH nocounter
   ;end select
   IF (rctimelinecnt > 0)
    SET stat = alterlist(rctimeline->objarray,rctimelinecnt)
   ENDIF
   FOR (rctimelineidx = 1 TO size(rctimeline->objarray,5))
     SELECT INTO "nl:"
      y = seq(rc_timeline_seq,nextval)
      FROM dual
      DETAIL
       rctimeline->objarray[rctimelineidx].rc_timeline_id = cnvtreal(y)
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET failed = insert_error
      SET error_table = rchildren->qual1[det_cnt].entity_name
      SET request->error_message = "Could not generate a new rc_timeline_id"
      GO TO exit_sub
     ENDIF
     INSERT  FROM rc_timeline rct
      SET rct.rc_timeline_id = rctimeline->objarray[rctimelineidx].rc_timeline_id, rct
       .activity_created_dt_tm = cnvtdatetime(v_current_dt_tm), rct.activity_created_prsnl_id =
       rctimeline->objarray[rctimelineidx].activity_created_prsnl_id,
       rct.activity_type_cd = rctimeline->objarray[rctimelineidx].activity_type_cd, rct.applied_to_cd
        = rctimeline->objarray[rctimelineidx].applied_to_cd, rct.applied_to_txt = rctimeline->
       objarray[rctimelineidx].applied_to_txt,
       rct.comment_clob = rctimeline->objarray[rctimelineidx].comment_clob, rct.description_txt =
       rctimeline->objarray[rctimelineidx].description_txt, rct.parent_entity_id = request->
       xxx_uncombine[ucb_cnt].to_xxx_id,
       rct.parent_entity_name = rctimeline->objarray[rctimelineidx].parent_entity_name, rct
       .priority_nbr = rctimeline->objarray[rctimelineidx].priority_nbr, rct.solution_cd = rctimeline
       ->objarray[rctimelineidx].solution_cd,
       rct.source_reference_ident = rctimeline->objarray[rctimelineidx].source_reference_ident, rct
       .active_ind = true, rct.active_status_cd = reqdata->active_status_cd,
       rct.active_status_dt_tm = cnvtdatetime(v_current_dt_tm), rct.active_status_prsnl_id = reqinfo
       ->updt_id, rct.updt_cnt = 0,
       rct.updt_dt_tm = cnvtdatetime(v_current_dt_tm), rct.updt_id = reqinfo->updt_id, rct
       .updt_applctx = reqinfo->updt_applctx,
       rct.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET ucb_failed = insert_error
      SET error_table = rchildren->qual1[det_cnt].entity_name
      SET request->error_message = "Could not insert new rc_timeline row."
      GO TO exit_sub
     ENDIF
     SET activity_updt_cnt += 1
   ENDFOR
 END ;Subroutine
#exit_sub
END GO
