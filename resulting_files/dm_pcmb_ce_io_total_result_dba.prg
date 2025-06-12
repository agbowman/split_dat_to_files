CREATE PROGRAM dm_pcmb_ce_io_total_result:dba
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
     2 encntr_focused_ind = i2
     2 suspect_flag = i2
   1 to_rec[*]
     2 to_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
 )
 DECLARE updt_to(s_uf_pk_id=f8) = i4
 DECLARE updt_from(s_uf_pk_id=f8,s_uf_to_fk_id=f8,suspect_flag=i2) = i4
 DECLARE v_cust_count1 = i4
 DECLARE v_cust_count2 = i4
 DECLARE v_cust_loopcount = i4
 DECLARE v_cust_updt_stat = i4
 DECLARE cutoffdttm = q8
 SET cutoffdttm = datetimeadd(cnvtdatetime(sysdate),- (7))
 SET v_cust_count1 = 0
 SET v_cust_count2 = 0
 SET v_cust_loopcount = 0
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "CE_IO_TOTAL_RESULT"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PCMB_CE_IO_TOTAL_RESULT"
  SET dcem_request->qual[1].single_encntr_ind = 1
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
 ELSE
  SELECT INTO "nl:"
   frm.*
   FROM ce_io_total_result frm
   WHERE (frm.person_id=request->xxx_combine[icombine].from_xxx_id)
   DETAIL
    IF ((request->xxx_combine[icombine].encntr_id != 0)
     AND (frm.encntr_id != request->xxx_combine[icombine].encntr_id))
     IF (frm.encntr_focused_ind=0
      AND frm.suspect_flag != 2
      AND frm.io_total_end_dt_tm >= cnvtdatetime(cutoffdttm))
      v_cust_count2 += 1
      IF (mod(v_cust_count2,10)=1)
       stat = alterlist(rreclist->to_rec,(v_cust_count2+ 9))
      ENDIF
      rreclist->to_rec[v_cust_count2].to_id = frm.ce_io_total_result_id
     ENDIF
    ELSE
     v_cust_count1 += 1
     IF (mod(v_cust_count1,10)=1)
      stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
     ENDIF
     rreclist->from_rec[v_cust_count1].from_id = frm.ce_io_total_result_id
     IF (frm.encntr_focused_ind=0
      AND frm.io_total_end_dt_tm >= cnvtdatetime(cutoffdttm))
      rreclist->from_rec[v_cust_count1].suspect_flag = 2
     ELSE
      rreclist->from_rec[v_cust_count1].suspect_flag = frm.suspect_flag
     ENDIF
    ENDIF
   WITH forupdatewait(frm)
  ;end select
  IF (v_cust_count1 > 0)
   SELECT INTO "nl:"
    tu.*
    FROM ce_io_total_result tu
    WHERE (tu.person_id=request->xxx_combine[icombine].to_xxx_id)
     AND tu.suspect_flag != 2
     AND tu.encntr_focused_ind=0
     AND tu.io_total_end_dt_tm >= cnvtdatetime(cutoffdttm)
    DETAIL
     v_cust_count2 += 1
     IF (mod(v_cust_count2,10)=1)
      stat = alterlist(rreclist->to_rec,(v_cust_count2+ 9))
     ENDIF
     rreclist->to_rec[v_cust_count2].to_id = tu.ce_io_total_result_id
    WITH forupdatewait(tu)
   ;end select
   FOR (v_cust_loopcount = 1 TO v_cust_count2)
     IF (upt_to(rreclist->to_rec[v_cust_loopcount].to_id)=0)
      GO TO exit_sub
     ENDIF
   ENDFOR
   FOR (v_cust_loopcount = 1 TO v_cust_count1)
    SET v_cust_updt_stat = upt_from(rreclist->from_rec[v_cust_loopcount].from_id,request->
     xxx_combine[icombine].to_xxx_id,rreclist->from_rec[v_cust_loopcount].suspect_flag)
    IF (v_cust_updt_stat=0)
     GO TO exit_sub
    ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SUBROUTINE upt_from(s_uf_pk_id,s_uf_to_fk_id,suspect_flag)
   UPDATE  FROM ce_io_total_result frm
    SET frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo
     ->updt_applctx,
     frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm = cnvtdatetime(sysdate), frm.person_id =
     s_uf_to_fk_id,
     frm.suspect_flag = suspect_flag
    WHERE frm.ce_io_total_result_id=s_uf_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = s_uf_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "CE_IO_TOTAL_RESULT"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = substring(1,132,build("Could not update pk val=",s_uf_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE upt_to(s_uf_pk_id)
   UPDATE  FROM ce_io_total_result frm
    SET frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo
     ->updt_applctx,
     frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm = cnvtdatetime(sysdate), frm.suspect_flag = 2
    WHERE frm.ce_io_total_result_id=s_uf_pk_id
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = substring(1,132,build("Could not update pk val=",s_uf_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_sub
 SET stat = alterlist(rreclist->to_rec,0)
 SET stat = alterlist(rreclist->from_rec,0)
 FREE SET rreclist
END GO
