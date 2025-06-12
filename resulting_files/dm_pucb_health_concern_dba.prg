CREATE PROGRAM dm_pucb_health_concern:dba
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
 FREE SET temphealthconcern
 RECORD temphealthconcern(
   1 health_concern_id = f8
   1 health_concern_group_id = f8
   1 health_concern_instance_uuid = vc
   1 health_concern_uuid = vc
   1 person_id = f8
   1 documented_encntr_id = f8
   1 active_ind = i2
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 description = vc
   1 comments = vc
   1 category_cd = f8
   1 concerned_person_reltn_cd = f8
   1 status_cd = f8
   1 onset_dt_tm = dq8
   1 recorded_prsnl_id = f8
   1 recorded_dt_tm = dq8
   1 resolved_prsnl_id = f8
   1 resolved_dt_tm = dq8
   1 last_updt_id = f8
   1 last_updt_dt_tm = dq8
   1 last_updt_encntr_id = f8
 )
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "HEALTH_CONCERN"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "dm_pucb_health_concern"
  SET dcem_request->qual[1].single_encntr_ind = 1
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 DECLARE v_current_dt_tm = dq8
 DECLARE v_hc_uuid = vc
 SET v_current_dt_tm = cnvtdatetime(sysdate)
 EXECUTE ccluarxrtl
 SELECT INTO "nl:"
  uuid = hc.health_concern_uuid
  FROM health_concern hc
  WHERE (hc.health_concern_id=rchildren->qual1[det_cnt].entity_id)
  DETAIL
   v_hc_uuid = uuid
  WITH nocounter
 ;end select
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
   UPDATE  FROM health_concern hc
    SET hc.active_ind = false, hc.active_status_cd = reqdata->inactive_status_cd, hc
     .active_status_prsnl_id = reqinfo->updt_id,
     hc.active_status_dt_tm = cnvtdatetime(v_current_dt_tm), hc.updt_cnt = (hc.updt_cnt+ 1), hc
     .updt_id = reqinfo->updt_id,
     hc.updt_applctx = reqinfo->updt_applctx, hc.updt_task = reqinfo->updt_task, hc.updt_dt_tm =
     cnvtdatetime(v_current_dt_tm),
     hc.end_effective_dt_tm = cnvtdatetime(v_current_dt_tm), hc.last_updt_id = reqinfo->updt_id, hc
     .last_updt_dt_tm = cnvtdatetime(v_current_dt_tm)
    WHERE (hc.person_id=request->xxx_uncombine[ucb_cnt].from_xxx_id)
     AND hc.health_concern_uuid=v_hc_uuid
     AND hc.active_ind=1
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET ucb_failed = delete_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt += 1
 END ;Subroutine
 SUBROUTINE cust_ucb_del2(dummy)
   SELECT INTO "nl:"
    y = seq(shx_seq,nextval)
    FROM dual
    DETAIL
     temphealthconcern->health_concern_id = cnvtreal(y)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET ucb_failed = insert_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    SET request->error_message = "Could not generate a new health_concern_id."
    GO TO exit_sub
   ENDIF
   SELECT INTO "nl:"
    FROM health_concern hc
    WHERE (hc.person_id=request->xxx_uncombine[ucb_cnt].from_xxx_id)
     AND hc.health_concern_uuid=v_hc_uuid
    ORDER BY hc.last_updt_dt_tm DESC
    HEAD REPORT
     temphealthconcern->health_concern_group_id = hc.health_concern_group_id, temphealthconcern->
     health_concern_instance_uuid = uar_createuuid(0), temphealthconcern->health_concern_uuid = hc
     .health_concern_uuid,
     temphealthconcern->person_id = hc.person_id, temphealthconcern->documented_encntr_id = hc
     .documented_encntr_id, temphealthconcern->active_ind = hc.active_ind,
     temphealthconcern->beg_effective_dt_tm = hc.beg_effective_dt_tm, temphealthconcern->
     end_effective_dt_tm = hc.end_effective_dt_tm, temphealthconcern->description = hc.description,
     temphealthconcern->comments = hc.comments, temphealthconcern->category_cd = hc.category_cd,
     temphealthconcern->concerned_person_reltn_cd = hc.concerned_person_reltn_cd,
     temphealthconcern->status_cd = hc.status_cd, temphealthconcern->onset_dt_tm = hc.onset_dt_tm,
     temphealthconcern->recorded_prsnl_id = hc.recorded_prsnl_id,
     temphealthconcern->recorded_dt_tm = hc.recorded_dt_tm, temphealthconcern->resolved_prsnl_id = hc
     .resolved_prsnl_id, temphealthconcern->resolved_dt_tm = hc.resolved_dt_tm,
     temphealthconcern->last_updt_id = hc.last_updt_id, temphealthconcern->last_updt_dt_tm = hc
     .last_updt_dt_tm, temphealthconcern->last_updt_encntr_id = hc.last_updt_encntr_id
    WITH nocounter
   ;end select
   IF ((temphealthconcern->documented_encntr_id != temphealthconcern->last_updt_encntr_id))
    SELECT INTO "nl:"
     FROM health_concern hc
     WHERE (hc.person_id=request->xxx_uncombine[ucb_cnt].to_xxx_id)
      AND hc.active_ind=0
      AND (hc.health_concern_uuid=temphealthconcern->health_concern_uuid)
     ORDER BY hc.last_updt_dt_tm DESC
     HEAD REPORT
      temphealthconcern->last_updt_encntr_id = hc.last_updt_encntr_id
     WITH nocounter
    ;end select
   ENDIF
   INSERT  FROM health_concern hc
    SET hc.health_concern_id = temphealthconcern->health_concern_id, hc.health_concern_group_id =
     temphealthconcern->health_concern_group_id, hc.health_concern_instance_uuid = temphealthconcern
     ->health_concern_instance_uuid,
     hc.health_concern_uuid = temphealthconcern->health_concern_uuid, hc.person_id = request->
     xxx_uncombine[ucb_cnt].to_xxx_id, hc.documented_encntr_id = temphealthconcern->
     documented_encntr_id,
     hc.active_ind = 1, hc.active_status_cd = reqdata->active_status_cd, hc.active_status_dt_tm =
     cnvtdatetime(v_current_dt_tm),
     hc.active_status_prsnl_id = reqinfo->updt_id, hc.beg_effective_dt_tm = cnvtdatetime(
      v_current_dt_tm), hc.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
     hc.description = temphealthconcern->description, hc.comments = temphealthconcern->comments, hc
     .category_cd = temphealthconcern->category_cd,
     hc.concerned_person_reltn_cd = temphealthconcern->concerned_person_reltn_cd, hc.status_cd =
     temphealthconcern->status_cd, hc.onset_dt_tm = cnvtdatetime(temphealthconcern->onset_dt_tm),
     hc.recorded_prsnl_id = temphealthconcern->recorded_prsnl_id, hc.recorded_dt_tm = cnvtdatetime(
      temphealthconcern->recorded_dt_tm), hc.resolved_prsnl_id = temphealthconcern->resolved_prsnl_id,
     hc.resolved_dt_tm = cnvtdatetime(temphealthconcern->resolved_dt_tm), hc.last_updt_id = reqinfo->
     updt_id, hc.last_updt_dt_tm = cnvtdatetime(v_current_dt_tm),
     hc.updt_cnt = 0, hc.updt_dt_tm = cnvtdatetime(v_current_dt_tm), hc.updt_id = reqinfo->updt_id,
     hc.updt_applctx = reqinfo->updt_applctx, hc.updt_task = reqinfo->updt_task, hc
     .last_updt_encntr_id = temphealthconcern->last_updt_encntr_id
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET ucb_failed = insert_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    SET request->error_message = "Could not insert new health_concern row."
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt += 1
 END ;Subroutine
#exit_sub
END GO
