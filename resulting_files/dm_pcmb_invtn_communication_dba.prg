CREATE PROGRAM dm_pcmb_invtn_communication:dba
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
     2 status_flag = i2
 )
 DECLARE v_cust_count1 = i4 WITH protect, noconstant(0)
 DECLARE v_cust_loopcount = i4 WITH protect, noconstant(0)
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "INVTN_COMMUNICATION"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "dm_pcmb_invtn_communication"
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
  frm.communication_id, frm.status_flag
  FROM invtn_communication frm
  WHERE (frm.person_id=request->xxx_combine[icombine].from_xxx_id)
   AND frm.status_flag IN (2, 3, 4, 5)
   AND frm.active_ind=1
  DETAIL
   v_cust_count1 += 1
   IF (mod(v_cust_count1,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count1].from_id = frm.communication_id, rreclist->from_rec[v_cust_count1
   ].status_flag = frm.status_flag
  FOOT REPORT
   stat = alterlist(rreclist->from_rec,v_cust_count1)
  WITH forupdatewait(frm)
 ;end select
 FOR (v_cust_loopcount = 1 TO v_cust_count1)
   IF ((rreclist->from_rec[v_cust_loopcount].status_flag=2))
    SET stat = del_from(rreclist->from_rec[v_cust_loopcount].from_id)
   ELSE
    SET stat = upt_from(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
     to_xxx_id)
   ENDIF
 ENDFOR
 SUBROUTINE (del_from(s_df_pk_id=f8) =i4)
   UPDATE  FROM invtn_communication ic
    SET ic.active_ind = false, ic.active_status_cd = combinedaway, ic.active_status_dt_tm =
     cnvtdatetime(sysdate),
     ic.active_status_prsnl_id = reqinfo->updt_id, ic.updt_cnt = (ic.updt_cnt+ 1), ic.updt_id =
     reqinfo->updt_id,
     ic.updt_applctx = reqinfo->updt_applctx, ic.updt_task = reqinfo->updt_task, ic.updt_dt_tm =
     cnvtdatetime(sysdate)
    WHERE ic.communication_id=s_df_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = s_df_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "INVTN_COMMUNICATION"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = true
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = 0
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = substring(1,132,build("Could not inactivate pk val=",s_df_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (upt_from(s_uf_pk_id=f8,s_uf_to_fk_id=f8) =i4)
   UPDATE  FROM invtn_communication ic
    SET ic.updt_cnt = (ic.updt_cnt+ 1), ic.updt_id = reqinfo->updt_id, ic.updt_applctx = reqinfo->
     updt_applctx,
     ic.updt_task = reqinfo->updt_task, ic.updt_dt_tm = cnvtdatetime(sysdate), ic.person_id =
     s_uf_to_fk_id
    WHERE ic.communication_id=s_uf_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = s_uf_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "INVTN_COMMUNICATION"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
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
