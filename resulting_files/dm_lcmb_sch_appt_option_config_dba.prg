CREATE PROGRAM dm_lcmb_sch_appt_option_config:dba
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
  SET dcem_request->qual[1].parent_entity = "LOCATION"
  SET dcem_request->qual[1].child_entity = "SCH_APPT_OPTION_CONFIG"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_LCMB_SCH_APPT_OPTION_CONFIG"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 sch_appt_option_config_id = f8
     2 location_cd = f8
     2 active_ind = i4
     2 active_status_cd = f8
 )
 SET from_count = 0
 DECLARE frm_index = i4 WITH protect, noconstant(0)
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 DECLARE loopcount = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  frm.*
  FROM sch_appt_option_config frm
  PLAN (frm
   WHERE (frm.location_cd=request->xxx_combine[icombine].from_xxx_id)
    AND frm.active_ind=1)
  DETAIL
   from_count += 1
   IF (mod(from_count,10)=1)
    stat = alterlist(rreclist->from_rec,(from_count+ 9))
   ENDIF
   rreclist->from_rec[from_count].location_cd = frm.location_cd, rreclist->from_rec[from_count].
   sch_appt_option_config_id = frm.sch_appt_option_config_id, rreclist->from_rec[from_count].
   active_ind = frm.active_ind,
   rreclist->from_rec[from_count].active_status_cd = frm.active_status_cd
  FOOT REPORT
   stat = alterlist(rreclist->from_rec,from_count)
  WITH nocounter
 ;end select
 FOR (loopcount = 1 TO from_count)
   CALL del_from(loopcount)
 ENDFOR
 SUBROUTINE (del_from(fromidx=i2) =null WITH protect)
  UPDATE  FROM sch_appt_option_config frm
   SET frm.active_status_cd = combinedaway, frm.active_ind = 0, frm.active_status_dt_tm =
    cnvtdatetime(sysdate),
    frm.active_status_prsnl_id = reqinfo->updt_id, frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id =
    reqinfo->updt_id,
    frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm =
    cnvtdatetime(sysdate)
   WHERE (frm.sch_appt_option_config_id=rreclist->from_rec[fromidx].sch_appt_option_config_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = delete_error
   SET request->error_message = substring(1,132,build(
     "Could not inactivate sch_appt_option_config table record with sch_appt_option_config_id =",
     s_df_pk_id))
   GO TO exit_sub
  ELSE
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = rreclist->from_rec[fromidx].
   sch_appt_option_config_id
   SET request->xxx_combine_det[icombinedet].entity_name = "SCH_APPT_OPTION_CONFIG"
   SET request->xxx_combine_det[icombinedet].attribute_name = "LOCATION_CD"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = rreclist->from_rec[fromidx].active_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = rreclist->from_rec[fromidx].
   active_status_cd
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "SCH_APPT_OPTION_CONFIG_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = rreclist->from_rec[1].
   sch_appt_option_config_id
  ENDIF
 END ;Subroutine
 IF (debug_ind=1)
  CALL echorecord(request)
 ENDIF
 SET ecode = 0
 SET emsg = fillstring(132," ")
 SET ecode = error(emsg,1)
 IF (ecode != 0)
  SET failed = ccl_error
 ENDIF
#exit_sub
 FREE SET rreclist
END GO
