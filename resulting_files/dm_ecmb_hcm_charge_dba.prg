CREATE PROGRAM dm_ecmb_hcm_charge:dba
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
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 from_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 charge_seq = i4
     2 details[*]
       3 hcm_charge_detail_id = f8
       3 description = vc
   1 to_rec[*]
     2 to_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
 )
 DECLARE upt_from(s_uf_pk_id=f8,s_uf_to_fk_id=f8,recs=vc(ref),cidx=i4,last_charge_seq=i4) = i4
 DECLARE formatdescription(description=vc) = vc
 DECLARE charge_cnt = i4 WITH protect, noconstant(0)
 DECLARE charge_idx = i4 WITH protect, noconstant(0)
 DECLARE details_cnt = i4 WITH protect, noconstant(0)
 DECLARE to_last_charge_seq = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "ENCOUNTER"
  SET dcem_request->qual[1].child_entity = "HCM_CHARGE"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_ECMB_HCM_CHARGE"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 1
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  frm.*
  FROM hcm_charge frm
  WHERE (frm.encntr_id=request->xxx_combine[icombine].from_xxx_id)
  HEAD REPORT
   charge_cnt = 0
  DETAIL
   charge_cnt = (charge_cnt+ 1)
   IF (mod(charge_cnt,10)=1)
    stat = alterlist(rreclist->from_rec,(charge_cnt+ 9))
   ENDIF
   rreclist->from_rec[charge_cnt].from_id = frm.hcm_charge_id, rreclist->from_rec[charge_cnt].
   active_ind = frm.active_ind, rreclist->from_rec[charge_cnt].active_status_cd = frm
   .active_status_cd
  WITH forupdatewait(frm), nocounter
 ;end select
 IF (charge_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(rreclist->from_rec,charge_cnt)
 SELECT INTO "nl:"
  FROM hcm_charge hc
  WHERE (hc.encntr_id=request->xxx_combine[icombine].to_xxx_id)
  ORDER BY hc.encntr_id, hc.charge_seq DESC
  HEAD hc.encntr_id
   to_last_charge_seq = hc.charge_seq
  WITH nocounter
 ;end select
 FOR (charge_idx = 1 TO charge_cnt)
   SELECT INTO "nl:"
    hcd.*
    FROM hcm_charge_detail hcd
    WHERE (hcd.hcm_charge_id=rreclist->from_rec[charge_idx].from_id)
    HEAD REPORT
     details_cnt = 0
    DETAIL
     details_cnt = (details_cnt+ 1)
     IF ((mod(details_cnt,10)+ 1))
      stat = alterlist(rreclist->from_rec[charge_idx].details,(details_cnt+ 9))
     ENDIF
     rreclist->from_rec[charge_idx].details[details_cnt].hcm_charge_detail_id = hcd
     .hcm_charge_detail_id, rreclist->from_rec[charge_idx].details[details_cnt].description =
     formatdescription(hcd.charge_description)
    WITH forupdatewait(hcd), nocounter
   ;end select
   SET stat = alterlist(rreclist->from_rec[charge_idx].details,details_cnt)
   SET stat = upt_from(rreclist->from_rec[charge_idx].from_id,request->xxx_combine[icombine].
    to_xxx_id,rreclist,charge_idx,to_last_charge_seq)
   IF (stat=0)
    GO TO exit_script
   ENDIF
 ENDFOR
 SUBROUTINE upt_from(s_uf_pk_id,s_uf_to_fk_id,recs,cidx,last_charge_seq)
   DECLARE active_cd = f8 WITH protect, constant(uar_get_code_by("MEAN",48,"ACTIVE"))
   DECLARE return_val = i2 WITH protect, noconstant(0)
   DECLARE detail_cnt = i4 WITH protect, noconstant(0)
   DECLARE detail_idx = i4 WITH protect, noconstant(0)
   UPDATE  FROM hcm_charge frm
    SET frm.encntr_id = s_uf_to_fk_id, frm.charge_seq = (frm.charge_seq+ to_last_charge_seq), frm
     .updt_cnt = (frm.updt_cnt+ 1),
     frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task =
     reqinfo->updt_task,
     frm.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE frm.hcm_charge_id=s_uf_pk_id
    WITH nocounter
   ;end update
   IF (curqual > 0)
    SET icombinedet = (icombinedet+ 1)
    SET stat = alterlist(request->xxx_combine_det,icombinedet)
    SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
    SET request->xxx_combine_det[icombinedet].entity_id = s_uf_pk_id
    SET request->xxx_combine_det[icombinedet].entity_name = "HCM_CHARGE"
    SET request->xxx_combine_det[icombinedet].attribute_name = "ENCNTR_ID"
    SET detail_cnt = size(recs->from_rec[cidx].details,5)
    FOR (detail_idx = 1 TO detail_cnt)
      UPDATE  FROM hcm_charge_detail hcd
       SET hcd.charge_description = recs->from_rec[cidx].details[detail_idx].description, hcd
        .updt_cnt = (hcd.updt_cnt+ 1), hcd.updt_id = reqinfo->updt_id,
        hcd.updt_applctx = reqinfo->updt_applctx, hcd.updt_task = reqinfo->updt_task, hcd.updt_dt_tm
         = cnvtdatetime(curdate,curtime3)
       WHERE (hcd.hcm_charge_detail_id=recs->from_rec[cidx].details[detail_idx].hcm_charge_detail_id)
       WITH nocounter
      ;end update
    ENDFOR
    IF (curqual=0)
     SET failed = update_error
     SET request->error_message = substring(1,132,build("Could not update hcm_charge_detail for=",
       s_uf_pk_id))
    ELSE
     SET return_val = 1
    ENDIF
   ELSE
    SET failed = update_error
    SET request->error_message = substring(1,132,build("Could not update pk val=",s_uf_pk_id))
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE formatdescription(description)
   DECLARE combined = vc WITH protect, constant("-COMBINED")
   DECLARE uncombined = vc WITH protect, constant("-UNCOMBINED")
   DECLARE uncombine_pos = i4 WITH protect, noconstant(0)
   DECLARE combine_pos = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE desc = vc WITH protect, noconstant("")
   SET uncombine_pos = findstring(uncombined,description)
   SET combine_pos = findstring(combined,description)
   IF (uncombine_pos > 0
    AND combine_pos > 0)
    IF (uncombine_pos > combine_pos)
     SET pos = (combine_pos - 1)
    ELSE
     SET pos = (uncombine_pos - 1)
    ENDIF
   ELSEIF (uncombine_pos > 0)
    SET pos = (uncombine_pos - 1)
   ELSEIF (combine_pos > 0)
    SET pos = (combine_pos - 1)
   ENDIF
   IF (pos > 0)
    SET desc = substring(1,pos,description)
   ELSE
    SET desc = trim(description)
   ENDIF
   IF (size(trim(desc),1) > 240)
    SET desc = concat(substring(1,240,trim(desc)),"...",combined)
   ELSE
    SET desc = concat(trim(desc),combined)
   ENDIF
   RETURN(desc)
 END ;Subroutine
#exit_script
 FREE SET rreclist
END GO
