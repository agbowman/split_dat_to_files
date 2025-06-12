CREATE PROGRAM dm_pucb_hm_recommend_action:dba
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
  SET dcem_request->qual[1].child_entity = "HM_RECOMMENDATION_ACTION"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "DM_PUCB_HM_RECOMMEND_ACTION"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 CALL echo("entering dm_pucb_hm_recommend_action")
 SET cust_ucb_dummy = 0
 IF ((rchildren->qual1[det_cnt].combine_action_cd=upt))
  CALL cust_ucb_upt(null)
 ELSE
  SET ucb_failed = data_error
  SET error_table = rchildren->qual1[det_cnt].entity_name
  GO TO exit_sub
 ENDIF
 SUBROUTINE cust_ucb_upt(null)
   DECLARE from_recommendation_id = f8 WITH protect, noconstant(0)
   DECLARE to_recommendation_id = f8 WITH protect, noconstant(0)
   DECLARE expect_id = f8 WITH protect, noconstant(0)
   DECLARE from_recommendation_related_id = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    hra.recommendation_id, hra.related_action_id
    FROM hm_recommendation_action hra
    WHERE (hra.recommendation_action_id=rchildren->qual1[det_cnt].entity_id)
    DETAIL
     from_recommendation_id = hra.recommendation_id, from_recommendation_related_id = hra
     .related_action_id
    WITH forupdatewait(hra)
   ;end select
   IF (curqual=0)
    GO TO exit_sub
   ENDIF
   SELECT INTO "nl:"
    hr.expect_id
    FROM hm_recommendation hr
    WHERE hr.recommendation_id=from_recommendation_id
    DETAIL
     expect_id = hr.expect_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET ucb_failed = update_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   SELECT INTO "nl:"
    hr.recommendation_id
    FROM hm_recommendation hr
    WHERE hr.expect_id=expect_id
     AND (hr.person_id=request->xxx_uncombine[ucb_cnt].to_xxx_id)
    DETAIL
     to_recommendation_id = hr.recommendation_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET ucb_failed = update_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   UPDATE  FROM hm_recommendation_action hra
    SET hra.updt_cnt = (hra.updt_cnt+ 1), hra.updt_id = reqinfo->updt_id, hra.updt_applctx = reqinfo
     ->updt_applctx,
     hra.updt_task = reqinfo->updt_task, hra.updt_dt_tm = cnvtdatetime(sysdate), hra
     .recommendation_id = to_recommendation_id
    WHERE (((hra.recommendation_action_id=rchildren->qual1[det_cnt].entity_id)) OR (
    from_recommendation_related_id > 0
     AND hra.recommendation_action_id=from_recommendation_related_id))
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET ucb_failed = update_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt += 1
 END ;Subroutine
#exit_sub
END GO
