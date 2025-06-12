CREATE PROGRAM dm_ecmb_drg_specialty:dba
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
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 from_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 end_effective_dt_tm = dq8
   1 to_rec[*]
     2 to_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 end_effective_dt_tm = dq8
 )
 DECLARE ml_count1 = i4
 DECLARE ml_count2 = i4
 DECLARE ml_loopcount = i4
 DECLARE mf_encntr_slice_id = f8
 SET ml_count1 = 0
 SET ml_count2 = 0
 SET ml_loopcount = 0
 SET mf_encntr_slice_id = 0.0
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "ENCOUNTER"
  SET dcem_request->qual[1].child_entity = "DRG_SPECIALTY"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "dm_ecmb_drg_specialty"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 2
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 SELECT INTO "nl:"
  frm.*
  FROM drg_specialty frm
  WHERE (frm.encntr_id=request->xxx_combine[icombine].from_xxx_id)
  DETAIL
   ml_count1 += 1
   IF (mod(ml_count1,10)=1)
    stat = alterlist(rreclist->from_rec,(ml_count1+ 9))
   ENDIF
   rreclist->from_rec[ml_count1].from_id = frm.drg_specialty_id, rreclist->from_rec[ml_count1].
   active_ind = frm.active_ind, rreclist->from_rec[ml_count1].active_status_cd = frm.active_status_cd,
   rreclist->from_rec[ml_count1].end_effective_dt_tm = frm.end_effective_dt_tm
  WITH forupdatewait(frm), nocounter
 ;end select
 SET stat = alterlist(rreclist->from_rec,ml_count1)
 IF (ml_count1 > 0)
  FOR (ml_loopcount = 1 TO ml_count1)
    CALL del_from(rreclist->from_rec[ml_loopcount].from_id,rreclist->from_rec[ml_loopcount].
     active_ind,rreclist->from_rec[ml_loopcount].active_status_cd,rreclist->from_rec[ml_loopcount].
     end_effective_dt_tm)
  ENDFOR
 ENDIF
 SELECT INTO "nl:"
  tu.*
  FROM drg_specialty tu
  WHERE (tu.encntr_id=request->xxx_combine[icombine].to_xxx_id)
  DETAIL
   mf_encntr_slice_id = 0.0, mf_encntr_slice_id = validate(tu.encntr_slice_id,0.0)
   IF (mf_encntr_slice_id=0.0)
    ml_count2 += 1
    IF (mod(ml_count2,10)=1)
     stat = alterlist(rreclist->to_rec,(ml_count2+ 9))
    ENDIF
    rreclist->to_rec[ml_count2].to_id = tu.drg_specialty_id, rreclist->to_rec[ml_count2].active_ind
     = tu.active_ind, rreclist->to_rec[ml_count2].active_status_cd = tu.active_status_cd,
    rreclist->to_rec[ml_count2].end_effective_dt_tm = tu.end_effective_dt_tm
   ENDIF
  WITH forupdatewait(tu), nocounter
 ;end select
 SET stat = alterlist(rreclist->to_rec,ml_count2)
 IF (ml_count2 > 0)
  FOR (ml_loopcount = 1 TO ml_count2)
    CALL del_from(rreclist->to_rec[ml_loopcount].to_id,rreclist->to_rec[ml_loopcount].active_ind,
     rreclist->to_rec[ml_loopcount].active_status_cd,rreclist->to_rec[ml_loopcount].
     end_effective_dt_tm)
  ENDFOR
 ENDIF
 SUBROUTINE (del_from(sf_drg_specialty_id=f8,si_prev_act_ind=i2,sf_prev_act_status=f8,
  sdt_prev_end_effective_dt=dq8) =null)
   UPDATE  FROM drg_specialty frm
    SET frm.active_ind = 0, frm.active_status_cd = reqdata->inactive_status_cd, frm.updt_cnt = (frm
     .updt_cnt+ 1),
     frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task =
     reqinfo->updt_task,
     frm.updt_dt_tm = cnvtdatetime(sysdate), frm.end_effective_dt_tm = cnvtdatetime(sysdate)
    WHERE frm.drg_specialty_id=sf_drg_specialty_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = sf_drg_specialty_id
   SET request->xxx_combine_det[icombinedet].entity_name = "DRG_SPECIALTY"
   SET request->xxx_combine_det[icombinedet].attribute_name = "ENCNTR_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = si_prev_act_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = sf_prev_act_status
   SET request->xxx_combine_det[icombinedet].prev_end_eff_dt_tm = sdt_prev_end_effective_dt
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = substring(1,132,build("Could not inactivate drg_specialty_id=",
      sf_drg_specialty_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_sub
 FREE SET rreclist
END GO
