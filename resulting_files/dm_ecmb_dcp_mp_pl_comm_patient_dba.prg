CREATE PROGRAM dm_ecmb_dcp_mp_pl_comm_patient:dba
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
 CALL echo("*****dm_cmb_pm_hist_routines.inc - 565951****")
 DECLARE dm_cmb_detect_pm_hist(null) = i4
 SUBROUTINE dm_cmb_detect_pm_hist(null)
   RETURN(1)
 END ;Subroutine
 IF ((validate(dcipht_request->pm_hist_tracking_id,- (9))=- (9)))
  RECORD dcipht_request(
    1 pm_hist_tracking_id = f8
    1 encntr_id = f8
    1 person_id = f8
    1 transaction_type_txt = c3
    1 transaction_reason_txt = c30
  )
 ENDIF
 IF (validate(dcipht_reply->status,"b")="b")
  RECORD dcipht_reply(
    1 status = c1
    1 err_msg = c255
  )
 ENDIF
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 from_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 comm_id = f8
   1 to_rec[*]
     2 to_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 comm_id = f8
 )
 DECLARE from_row_count = i4
 DECLARE to_row_count = i4
 DECLARE from_loop_count = i4
 DECLARE to_loop_count = i4
 DECLARE pos = i4
 DECLARE update_ind = i2
 DECLARE delete_ind = i2
 SET from_row_count = 0
 SET to_row_count = 0
 SET from_loop_count = 0
 SET to_loop_count = 0
 SET pos = 0
 SET update_ind = 0
 SET delete_ind = 0
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "ENCOUNTER"
  SET dcem_request->qual[1].child_entity = "DCP_MP_PL_COMM_PATIENT"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_ECMB_DCP_MP_PL_COMM_PATIENT"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 SELECT INTO "nl:"
  FROM dcp_mp_pl_comm_patient from_comm_patient
  WHERE (from_comm_patient.encntr_id=request->xxx_combine[icombine].from_xxx_id)
  DETAIL
   from_row_count = (from_row_count+ 1)
   IF (mod(from_row_count,10)=1)
    stat = alterlist(rreclist->from_rec,(from_row_count+ 9))
   ENDIF
   rreclist->from_rec[from_row_count].from_id = from_comm_patient.dcp_mp_pl_comm_patient_id, rreclist
   ->from_rec[from_row_count].active_ind = from_comm_patient.active_ind, rreclist->from_rec[
   from_row_count].active_status_cd = from_comm_patient.active_status_cd,
   rreclist->from_rec[from_row_count].comm_id = from_comm_patient.dcp_mp_pl_comm_id
  FOOT REPORT
   stat = alterlist(rreclist->from_rec,from_row_count)
  WITH forupdatewait(from_comm_patient)
 ;end select
 IF (from_row_count > 0)
  SELECT INTO "nl:"
   FROM dcp_mp_pl_comm_patient to_comm_patient
   WHERE (to_comm_patient.encntr_id=request->xxx_combine[icombine].to_xxx_id)
   DETAIL
    to_row_count = (to_row_count+ 1)
    IF (mod(to_row_count,10)=1)
     stat = alterlist(rreclist->to_rec,(to_row_count+ 9))
    ENDIF
    rreclist->to_rec[to_row_count].to_id = to_comm_patient.dcp_mp_pl_comm_patient_id, rreclist->
    to_rec[to_row_count].active_ind = to_comm_patient.active_ind, rreclist->to_rec[to_row_count].
    active_status_cd = to_comm_patient.active_status_cd,
    rreclist->to_rec[to_row_count].comm_id = to_comm_patient.dcp_mp_pl_comm_id
   FOOT REPORT
    stat = alterlist(rreclist->to_rec,to_row_count)
   WITH forupdatewait(to_comm_patient)
  ;end select
  FOR (from_loop_count = 1 TO from_row_count)
    SET update_ind = 0
    SET delete_ind = 0
    SET pos = 0
    IF (to_row_count=0)
     SET update_ind = 1
    ELSE
     FOR (to_loop_count = 1 TO to_row_count)
       IF ((rreclist->from_rec[from_loop_count].comm_id=rreclist->to_rec[to_loop_count].comm_id))
        SET delete_ind = 1
       ELSE
        SET update_ind = 1
       ENDIF
     ENDFOR
    ENDIF
    IF (delete_ind=1)
     CALL del_from(rreclist->from_rec[from_loop_count].from_id,request->xxx_combine[icombine].
      from_xxx_id,rreclist->from_rec[from_loop_count].active_ind,rreclist->from_rec[from_loop_count].
      active_status_cd)
    ELSEIF (update_ind=1)
     CALL upt_from(rreclist->from_rec[from_loop_count].from_id,request->xxx_combine[icombine].
      to_xxx_id)
    ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE del_from(s_df_pk_id,s_df_to_fk_id,s_df_prev_act_ind,s_df_prev_act_status)
   UPDATE  FROM dcp_mp_pl_comm_patient from_comm_patient
    SET from_comm_patient.active_ind = false, from_comm_patient.active_status_cd = combinedaway,
     from_comm_patient.updt_cnt = (from_comm_patient.updt_cnt+ 1),
     from_comm_patient.updt_id = reqinfo->updt_id, from_comm_patient.updt_applctx = reqinfo->
     updt_applctx, from_comm_patient.updt_task = reqinfo->updt_task,
     from_comm_patient.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE from_comm_patient.dcp_mp_pl_comm_patient_id=s_df_pk_id
    WITH nocounter
   ;end update
   SET icombinedet = (icombinedet+ 1)
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = s_df_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "DCP_MP_PL_COMM_PATIENT"
   SET request->xxx_combine_det[icombinedet].attribute_name = "ENCNTR_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = s_df_prev_act_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = s_df_prev_act_status
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = substring(1,132,build("Could not inactivate pk val=",s_df_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE upt_from(s_uf_pk_id,s_uf_to_fk_id)
   UPDATE  FROM dcp_mp_pl_comm_patient from_comm_patient
    SET from_comm_patient.updt_cnt = (from_comm_patient.updt_cnt+ 1), from_comm_patient.updt_id =
     reqinfo->updt_id, from_comm_patient.updt_applctx = reqinfo->updt_applctx,
     from_comm_patient.updt_task = reqinfo->updt_task, from_comm_patient.updt_dt_tm = cnvtdatetime(
      curdate,curtime3), from_comm_patient.encntr_id = s_uf_to_fk_id
    WHERE from_comm_patient.dcp_mp_pl_comm_patient_id=s_uf_pk_id
    WITH nocounter
   ;end update
   SET icombinedet = (icombinedet+ 1)
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = s_uf_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "DCP_MP_PL_COMM_PATIENT"
   SET request->xxx_combine_det[icombinedet].attribute_name = "ENCNTR_ID"
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = substring(1,132,build("Could not update pk val=",s_uf_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_sub
 FREE SET rreclist
END GO
