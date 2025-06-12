CREATE PROGRAM dm_ocmb_prsnl_org_reltn:dba
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
  SET dcem_request->qual[1].parent_entity = "ORGANIZATION"
  SET dcem_request->qual[1].child_entity = "PRSNL_ORG_RELTN"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_OCMB_PRSNL_ORG_RELTN"
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
 FREE RECORD rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 prsnl_org_reltn_id = f8
     2 prev_end_eff_dt_tm = dq8
     2 prev_active_ind = i2
 )
 SET count1 = 0
 SELECT INTO "nl:"
  frm.*
  FROM prsnl_org_reltn frm
  WHERE (frm.organization_id=request->xxx_combine[icombine].from_xxx_id)
   AND frm.end_effective_dt_tm > cnvtdatetime(sysdate)
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1)
    stat = alterlist(rreclist->from_rec,(count1+ 9))
   ENDIF
   rreclist->from_rec[count1].prsnl_org_reltn_id = frm.prsnl_org_reltn_id, rreclist->from_rec[count1]
   .prev_end_eff_dt_tm = frm.end_effective_dt_tm, rreclist->from_rec[count1].prev_active_ind = frm
   .active_ind
  WITH forupdatewait(frm)
 ;end select
 SET stat = alterlist(rreclist->from_rec,count1)
 IF (count1 > 0)
  FOR (loopcount = 1 TO count1)
    IF (end_eff(rreclist->from_rec[loopcount].prsnl_org_reltn_id,loopcount)=0)
     GO TO end_of_program
    ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE end_eff(s_por_id,s_frm_count)
   UPDATE  FROM prsnl_org_reltn por
    SET por.end_effective_dt_tm = cnvtdatetime(sysdate), por.updt_dt_tm = cnvtdatetime(sysdate), por
     .updt_id = reqinfo->updt_id,
     por.updt_applctx = reqinfo->updt_applctx, por.updt_task = reqinfo->updt_task, por.updt_cnt = (
     por.updt_cnt+ 1)
    WHERE por.prsnl_org_reltn_id=s_por_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = eff
   SET request->xxx_combine_det[icombinedet].entity_name = "PRSNL_ORG_RELTN"
   SET request->xxx_combine_det[icombinedet].attribute_name = "ORGANIZATION_ID"
   SET request->xxx_combine_det[icombinedet].prev_end_eff_dt_tm = rreclist->from_rec[s_frm_count].
   prev_end_eff_dt_tm
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "PRSNL_ORG_RELTN_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = s_por_id
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = build(
     "DEL_FROM: No values found on the prsnl_org_reltn table with prsnl_org_reltn_id = ",s_por_id)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#end_of_program
 FREE RECORD rreclist
END GO
