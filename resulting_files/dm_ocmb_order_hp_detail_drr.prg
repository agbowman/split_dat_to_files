CREATE PROGRAM dm_ocmb_order_hp_detail_drr
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
     2 pk_col1 = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 updt_dt_tm = dq8
     2 order_id = f8
     2 action_seq = i4
     2 health_plan_id = f8
 )
 SET count1 = 0
 SET count2 = 0
 DECLARE v_cust_count1 = i4
 SET v_cust_count1 = 0
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "ORGANIZATION"
  SET dcem_request->qual[1].child_entity = "ORDER_HEALTH_PLAN_8797DRR"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_OCMB_ORDER_HP_DETAIL_DRR"
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
  FROM order_health_plan_8797drr frm
  WHERE (frm.detail_field_value=request->xxx_combine[icombine].from_xxx_id)
   AND frm.detail_field_ident=2448
  DETAIL
   v_cust_count1 += 1
   IF (mod(v_cust_count1,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count1].pk_col1 = frm.order_health_plan_dtl_id, rreclist->from_rec[
   v_cust_count1].updt_dt_tm = frm.updt_dt_tm, rreclist->from_rec[v_cust_count1].order_id = frm
   .order_id,
   rreclist->from_rec[v_cust_count1].action_seq = frm.action_seq, rreclist->from_rec[v_cust_count1].
   health_plan_id = frm.health_plan_id
  WITH forupdatewait(frm)
 ;end select
 IF (v_cust_count1 > 0)
  FOR (loopcount = 1 TO v_cust_count1)
    CALL updt_from(loopcount)
  ENDFOR
 ENDIF
 SUBROUTINE (updt_from(lidx=i4) =i2)
   UPDATE  FROM order_health_plan_8797drr frm
    SET frm.detail_field_value = request->xxx_combine[icombine].to_xxx_id, frm.updt_applctx = reqinfo
     ->updt_applctx, frm.updt_cnt = (frm.updt_cnt+ 1),
     frm.updt_dt_tm = cnvtdatetime(sysdate), frm.updt_id = reqinfo->updt_id, frm.updt_task = reqinfo
     ->updt_task
    WHERE (frm.order_health_plan_dtl_id=rreclist->from_rec[lidx].pk_col1)
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_name = "ORDER_HEALTH_PLAN_8797DRR"
   SET request->xxx_combine_det[icombinedet].attribute_name = "DETAIL_FIELD_VALUE"
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "ORDER_HEALTH_PLAN_DTL_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = rreclist->from_rec[lidx].
   pk_col1
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = build("Error updating into order_health_plan_8797drr with id=",
     rreclist->from_rec[lidx].pk_col1)
    GO TO exit_sub
   ENDIF
 END ;Subroutine
 SET ecode = 0
 SET emsg = fillstring(132," ")
 SET ecode = error(emsg,1)
 IF (ecode != 0)
  SET failed = ccl_error
 ENDIF
#exit_sub
 FREE SET rreclist
END GO
