CREATE PROGRAM dm_pcmb_mars_suite_response:dba
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
   1 rec[*]
     2 id = f8
     2 active_ind = i4
     2 active_status_cd = f8
 )
 DECLARE v_cust_count = i4 WITH protect, noconstant(0)
 DECLARE v_cust_loopcount = i4 WITH protect, noconstant(0)
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "MARS_SUITE_RESPONSE"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PCMB_MARS_SUITE_RESPONSE"
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
  msr.mars_suite_response_id, msr.active_ind, msr.active_status_cd
  FROM mars_suite_response msr
  WHERE (((msr.person_id=request->xxx_combine[icombine].from_xxx_id)) OR ((msr.person_id=request->
  xxx_combine[icombine].to_xxx_id)))
   AND msr.active_ind=1
  DETAIL
   v_cust_count += 1
   IF (mod(v_cust_count,10)=1)
    stat = alterlist(rreclist->rec,(v_cust_count+ 9))
   ENDIF
   rreclist->rec[v_cust_count].id = msr.mars_suite_response_id, rreclist->rec[v_cust_count].
   active_ind = msr.active_ind, rreclist->rec[v_cust_count].active_status_cd = msr.active_status_cd
  WITH forupdatewait(msr)
 ;end select
 FOR (v_cust_loopcount = 1 TO v_cust_count)
   IF (del_from(rreclist->rec[v_cust_loopcount].id,rreclist->rec[v_cust_loopcount].active_ind,
    rreclist->rec[v_cust_loopcount].active_status_cd)=0)
    GO TO exit_sub
   ENDIF
 ENDFOR
 SET icombinedet += 1
 SET stat = alterlist(request->xxx_combine_det,icombinedet)
 SET request->xxx_combine_det[icombinedet].combine_action_cd = del
 SET request->xxx_combine_det[icombinedet].entity_id = 0
 SET request->xxx_combine_det[icombinedet].entity_name = "MARS_SUITE_RESPONSE"
 SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
 SET request->xxx_combine_det[icombinedet].prev_active_ind = 0
 SET request->xxx_combine_det[icombinedet].prev_active_status_cd = 0
 SUBROUTINE (del_from(s_df_pk_id=f8,s_df_prev_act_ind=i2,s_df_prev_act_status=f8) =i4)
   UPDATE  FROM mars_suite_response msr
    SET msr.active_ind = false, msr.active_status_cd = combinedaway, msr.updt_cnt = (msr.updt_cnt+ 1),
     msr.updt_id = reqinfo->updt_id, msr.updt_applctx = reqinfo->updt_applctx, msr.updt_task =
     reqinfo->updt_task,
     msr.updt_dt_tm = cnvtdatetime(sysdate)
    WHERE msr.mars_suite_response_id=s_df_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = s_df_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "MARS_SUITE_RESPONSE"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = s_df_prev_act_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = s_df_prev_act_status
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = substring(1,132,build("Could not inactivate pk val=",s_df_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_sub
 FREE SET rreclist
END GO
