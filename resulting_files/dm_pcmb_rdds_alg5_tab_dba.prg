CREATE PROGRAM dm_pcmb_rdds_alg5_tab:dba
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
  SET dcem_request->qual[1].child_entity = "RDDS_ALG5_TAB"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PCMB_RDDS_ALG5_TAB"
  SET dcem_request->qual[1].single_encntr_ind = 1
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 UPDATE  FROM rdds_alg5_tab r
  SET r.person_id = request->xxx_combine[icombine].to_xxx_id, r.active_ind = false, r.display =
   "Custom Script Update",
   r.display_key = cnvtupper(cnvtalphanum("Custom Script Update")), r.updt_cnt = (r.updt_cnt+ 1), r
   .updt_id = 111,
   r.updt_applctx = reqinfo->updt_applctx, r.updt_task = reqinfo->updt_task, r.updt_dt_tm =
   cnvtdatetime(sysdate)
  WHERE (r.person_id=request->xxx_combine[icombine].from_xxx_id)
  WITH nocounter
 ;end update
 SET icombinedet += 1
 SET stat = alterlist(request->xxx_combine_det,icombinedet)
 SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
 SET request->xxx_combine_det[icombinedet].entity_id = 123.0
 SET request->xxx_combine_det[icombinedet].entity_name = "RDDS_ALG5_TAB"
 SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
 SET request->xxx_combine_det[icombinedet].prev_active_ind = 0
 SET request->xxx_combine_det[icombinedet].prev_active_status_cd = 0
#exit_sub
END GO
