CREATE PROGRAM dm_prcmb_credential:dba
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
 IF ((validate(rev_cmb_request->reverse_ind,- (1))=- (1))
  AND (validate(rev_cmb_request->application_flag,- (999))=- (999)))
  FREE RECORD rev_cmb_request
  RECORD rev_cmb_request(
    1 reverse_ind = i2
    1 application_flag = i4
  )
 ENDIF
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PRSNL"
  SET dcem_request->qual[1].child_entity = "CREDENTIAL"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PRCMB_CREDENTIAL"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO end_of_program
 ENDIF
 DECLARE count1 = i4
 DECLARE count2 = i4 WITH protect, noconstant(0)
 FREE RECORD rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 credential_id = f8
     2 updt_from = i2
     2 del_from = i2
     2 prev_active_status_cd = f8
   1 to_rec[*]
     2 credential_id = f8
     2 revupdt_from = i2
     2 del_to = i2
     2 prev_active_status_cd = f8
 )
 SET count1 = 0
 SELECT INTO "nl:"
  frm.*
  FROM credential frm
  WHERE (((frm.prsnl_id=request->xxx_combine[icombine].from_xxx_id)
   AND frm.active_ind=1) OR ((frm.notify_prsnl_id=request->xxx_combine[icombine].from_xxx_id)))
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1)
    stat = alterlist(rreclist->from_rec,(count1+ 9))
   ENDIF
   rreclist->from_rec[count1].updt_from = 0
   IF ((frm.notify_prsnl_id=request->xxx_combine[icombine].from_xxx_id))
    rreclist->from_rec[count1].updt_from = 1
   ENDIF
   rreclist->from_rec[count1].del_from = 0
   IF ((frm.prsnl_id=request->xxx_combine[icombine].from_xxx_id)
    AND frm.active_ind=1)
    rreclist->from_rec[count1].del_from = 1
   ENDIF
   rreclist->from_rec[count1].credential_id = frm.credential_id, rreclist->from_rec[count1].
   prev_active_status_cd = frm.active_status_cd
  WITH forupdatewait(frm)
 ;end select
 SET stat = alterlist(rreclist->from_rec,count1)
 IF ((rev_cmb_request->reverse_ind=1))
  SELECT INTO "nl:"
   tu.*
   FROM credential tu
   WHERE (tu.prsnl_id=request->xxx_combine[icombine].to_xxx_id)
    AND tu.active_ind=1
   DETAIL
    count2 += 1
    IF (mod(count2,10)=1)
     stat = alterlist(rreclist->to_rec,(count2+ 9))
    ENDIF
    rreclist->to_rec[count2].credential_id = tu.credential_id, rreclist->to_rec[count2].
    prev_active_status_cd = tu.active_status_cd
   FOOT REPORT
    stat = alterlist(rreclist->to_rec,count2)
   WITH forupdatewait(tu)
  ;end select
  IF (count2 > 0)
   FOR (loopcount2 = 1 TO count2)
     IF (del_to(rreclist->to_rec[loopcount2].credential_id,loopcount2)=0)
      GO TO end_of_program
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF (count1 > 0)
  FOR (loopcount = 1 TO count1)
   IF ((rreclist->from_rec[loopcount].updt_from=1))
    IF (updt_from(rreclist->from_rec[loopcount].credential_id)=0)
     GO TO end_of_program
    ENDIF
   ENDIF
   IF ((rreclist->from_rec[loopcount].del_from=1))
    IF ((rev_cmb_request->reverse_ind=0))
     IF (del_from(rreclist->from_rec[loopcount].credential_id,loopcount)=0)
      GO TO end_of_program
     ENDIF
    ELSE
     IF (revupdt_from(rreclist->from_rec[loopcount].credential_id)=0)
      GO TO end_of_program
     ENDIF
    ENDIF
   ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE del_from(s_c_id,s_frm_cnt)
   UPDATE  FROM credential c
    SET c.active_ind = 0, c.active_status_cd = combinedaway, c.active_status_dt_tm = cnvtdatetime(
      sysdate),
     c.active_status_prsnl_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id =
     reqinfo->updt_id,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->updt_task, c.updt_cnt = (c
     .updt_cnt+ 1)
    WHERE c.credential_id=s_c_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = s_c_id
   SET request->xxx_combine_det[icombinedet].entity_name = "CREDENTIAL"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PRSNL_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = 1
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = rreclist->from_rec[s_frm_cnt].
   prev_active_status_cd
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "CREDENTIAL_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = s_c_id
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = build(
     "DEL_FROM: No values found on the credential table with credential_id = ",s_c_id)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE updt_from(s_c_id2)
   UPDATE  FROM credential frm
    SET frm.notify_prsnl_id = request->xxx_combine[icombine].to_xxx_id, frm.updt_cnt = (frm.updt_cnt
     + 1), frm.updt_id = reqinfo->updt_id,
     frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm =
     cnvtdatetime(sysdate)
    WHERE frm.credential_id=s_c_id2
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_name = "CREDENTIAL"
   SET request->xxx_combine_det[icombinedet].attribute_name = "NOTIFY_PRSNL_ID"
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "CREDENTIAL_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = s_c_id2
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = build("Couldn't update CREDENTIAL record with credential_id = ",
     s_c_id2)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE del_to(dts_c_id,dts_tu_cnt)
   UPDATE  FROM credential c
    SET c.active_ind = 0, c.active_status_cd = combinedaway, c.active_status_dt_tm = cnvtdatetime(
      sysdate),
     c.active_status_prsnl_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id =
     reqinfo->updt_id,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->updt_task, c.updt_cnt = (c
     .updt_cnt+ 1)
    WHERE c.credential_id=dts_c_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = revdel
   SET request->xxx_combine_det[icombinedet].entity_id = dts_c_id
   SET request->xxx_combine_det[icombinedet].entity_name = "CREDENTIAL"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PRSNL_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = 1
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = rreclist->to_rec[dts_tu_cnt].
   prev_active_status_cd
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "CREDENTIAL_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = dts_c_id
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = build(
     "DEL_TO: No values found on the credential table with credential_id = ",dts_c_id)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE revupdt_from(rfs_c_id2)
   UPDATE  FROM credential frm
    SET frm.prsnl_id = request->xxx_combine[icombine].to_xxx_id, frm.updt_cnt = (frm.updt_cnt+ 1),
     frm.updt_id = reqinfo->updt_id,
     frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm =
     cnvtdatetime(sysdate)
    WHERE frm.credential_id=rfs_c_id2
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_name = "CREDENTIAL"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PRSNL_ID"
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "CREDENTIAL_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = rfs_c_id2
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = build("Couldn't update CREDENTIAL record with prsnl_id = ",request->
     xxx_combine[icombine].from_xxx_id)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#end_of_program
 FREE RECORD rreclist
END GO
