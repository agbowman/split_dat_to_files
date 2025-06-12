CREATE PROGRAM dm_prcmb_mp_notification:dba
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
 DECLARE upt_from(s_uf_pk_id=f8,s_uf_to_fk_id=f8,encntr_id=f8,notif_flag=i2) = i2
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 from_id = f8
     2 encntr_id = f8
     2 notification_seq = i4
     2 notification_type_flag = i2
     2 prsnl_id = f8
 )
 DECLARE v_cust_count1 = i4 WITH protect, noconstant(0)
 DECLARE v_cust_loopcount1 = i4 WITH protect, noconstant(0)
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PRSNL"
  SET dcem_request->qual[1].child_entity = "MP_NOTIFICATION"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PRCMB_MP_NOTIFICATION"
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
  frm.*
  FROM mp_notification frm
  WHERE (frm.prsnl_id=request->xxx_combine[icombine].from_xxx_id)
  DETAIL
   v_cust_count1 = (v_cust_count1+ 1)
   IF (mod(v_cust_count1,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count1].from_id = frm.mp_notification_id, rreclist->from_rec[
   v_cust_count1].encntr_id = frm.encntr_id, rreclist->from_rec[v_cust_count1].notification_seq = frm
   .notification_seq,
   rreclist->from_rec[v_cust_count1].notification_type_flag = frm.notification_type_flag, rreclist->
   from_rec[v_cust_count1].prsnl_id = frm.prsnl_id
  WITH forupdatewait(frm)
 ;end select
 IF (v_cust_count1 > 0)
  FOR (v_cust_loopcount1 = 1 TO v_cust_count1)
    IF (upt_from(rreclist->from_rec[v_cust_loopcount1].from_id,request->xxx_combine[icombine].
     to_xxx_id,rreclist->from_rec[v_cust_loopcount1].encntr_id,rreclist->from_rec[v_cust_loopcount1].
     notification_type_flag)=0)
     GO TO exit_sub
    ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE upt_from(s_uf_pk_id,s_uf_to_fk_id,encntr_id,notif_flag)
   DECLARE notif_seq = i4 WITH protect, noconstant(0)
   DECLARE cur_row = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    max_notif_seq = max(mn.notification_seq)
    FROM mp_notification mn
    WHERE mn.prsnl_id=s_uf_to_fk_id
     AND mn.encntr_id=encntr_id
     AND mn.notification_type_flag=notif_flag
    DETAIL
     notif_seq = max_notif_seq, cur_row = 1
    WITH nocounter
   ;end select
   IF (cur_row > 0)
    UPDATE  FROM mp_notification frm
     SET frm.notification_seq = (notif_seq+ 1), frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id =
      reqinfo->updt_id,
      frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm = cnvtdatetime(curdate,curtime3), frm
      .prsnl_id = s_uf_to_fk_id
     WHERE frm.mp_notification_id=s_uf_pk_id
     WITH nocounter
    ;end update
   ELSE
    UPDATE  FROM mp_notification frm
     SET frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id = reqinfo->updt_id, frm.updt_task = reqinfo->
      updt_task,
      frm.updt_dt_tm = cnvtdatetime(curdate,curtime3), frm.prsnl_id = s_uf_to_fk_id
     WHERE frm.mp_notification_id=s_uf_pk_id
     WITH nocounter
    ;end update
   ENDIF
   SET icombinedet = (icombinedet+ 1)
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_name = "MP_NOTIFICATION"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PRSNL_ID"
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "MP_NOTIFICATION_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = s_uf_pk_id
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
