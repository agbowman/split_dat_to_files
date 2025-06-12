CREATE PROGRAM dm_eucb_hcm_charge:dba
 FREE SET charge_details
 RECORD charge_details(
   1 details[*]
     2 hcm_charge_detail_id = f8
     2 description = vc
 )
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
 DECLARE cust_ucb_upt(null) = i4
 DECLARE formatdescription(description=vc) = vc
 DECLARE child_cnt = i4 WITH protect, noconstant(0)
 DECLARE child_idx = i4 WITH protect, noconstant(0)
 DECLARE charge_cnt = i4 WITH protect, noconstant(0)
 DECLARE charge_idx = i4 WITH protect, noconstant(0)
 DECLARE details_cnt = i4 WITH protect, noconstant(0)
 DECLARE activity_updt_cnt = i4 WITH protect, noconstant(0)
 DECLARE children_idx = i4 WITH protect, noconstant(0)
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "ENCOUNTER"
  SET dcem_request->qual[1].child_entity = "HCM_CHARGE"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "DM_EUCB_HCM_CHARGE"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 1
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_script
 ENDIF
 IF ((rchildren->qual1[det_cnt].combine_action_cd=upt))
  CALL cust_ucb_upt(null)
 ELSE
  SET ucb_failed = data_error
  SET error_table = substring(1,132,build(rchildren->qual1[det_cnt].entity_name,
    " - an invalid combine_action_cd was used"))
  GO TO exit_script
 ENDIF
 SUBROUTINE cust_ucb_upt(null)
   DECLARE detail_cnt = i4 WITH protect, noconstant(0)
   DECLARE detail_idx = i4 WITH protect, noconstant(0)
   DECLARE cust_upt_buff = vc WITH protect
   DECLARE chg_detail_cnt = i4 WITH protect, noconstant(0)
   DECLARE to_last_charge_seq = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM hcm_charge hc
    WHERE (hc.encntr_id=request->xxx_uncombine[ucb_cnt].to_xxx_id)
    ORDER BY hc.encntr_id, hc.charge_seq DESC
    HEAD hc.encntr_id
     to_last_charge_seq = hc.charge_seq
    WITH nocounter
   ;end select
   SET to_last_charge_seq = (to_last_charge_seq+ 1)
   SET cust_upt_buff = fillstring(500," ")
   SET cust_upt_buff = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name),
    " set updt_id = reqinfo->updt_id, ","updt_dt_tm = cnvtdatetime(curdate,curtime3), ",
    "updt_applctx = reqinfo->updt_applctx, ",
    "updt_cnt = updt_cnt + 1, ","updt_task = reqinfo->updt_task, ",
    "charge_seq = to_last_charge_seq, ",trim(rchildren->qual1[det_cnt].attribute_name),
    " = REQUEST->XXX_UNCOMBINE[ucb_cnt]->TO_XXX_ID ",
    "where ",trim(rchildren->qual1[det_cnt].attribute_name),
    " = REQUEST->XXX_UNCOMBINE[ucb_cnt]->FROM_XXX_ID "," and ",trim(rchildren->qual1[det_cnt].
     primary_key_attr),
    " = rChildren->QUAL1[det_cnt]->ENTITY_ID ","with nocounter go ")
   CALL parser(cust_upt_buff)
   IF (curqual=0)
    SET ucb_failed = update_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_script
   ELSE
    SELECT INTO "nl:"
     FROM hcm_charge_detail hcd
     WHERE (hcd.hcm_charge_id=rchildren->qual1[det_cnt].entity_id)
     HEAD REPORT
      chg_detail_cnt = 0
     DETAIL
      chg_detail_cnt = (chg_detail_cnt+ 1)
      IF ((mod(chg_detail_cnt,10)+ 1))
       stat = alterlist(charge_details->details,(chg_detail_cnt+ 9))
      ENDIF
      charge_details->details[chg_detail_cnt].hcm_charge_detail_id = hcd.hcm_charge_detail_id,
      charge_details->details[chg_detail_cnt].description = formatdescription(hcd.charge_description)
     WITH forupdatewait(hcd), nocounter
    ;end select
    SET stat = alterlist(charge_details->details,chg_detail_cnt)
    SET chg_detail_cnt = size(charge_details->details,5)
    FOR (detail_idx = 0 TO chg_detail_cnt)
      UPDATE  FROM hcm_charge_detail hcd
       SET hcd.charge_description = charge_details->details[detail_idx].description, hcd.updt_cnt = (
        hcd.updt_cnt+ 1), hcd.updt_id = reqinfo->updt_id,
        hcd.updt_applctx = reqinfo->updt_applctx, hcd.updt_task = reqinfo->updt_task, hcd.updt_dt_tm
         = cnvtdatetime(curdate,curtime3)
       WHERE (hcd.hcm_charge_detail_id=charge_details->details[detail_idx].hcm_charge_detail_id)
        AND (hcd.hcm_charge_id=rchildren->qual1[det_cnt].entity_id)
       WITH nocounter
      ;end update
    ENDFOR
    IF (curqual=0)
     SET ucb_failed = update_error
     SET error_table = substring(1,132,build("Could not update hcm_charge_detail for=",cnvtstring(
        rchildren->qual1[det_cnt].entity_id)))
    ENDIF
    SET stat = initrec(charge_details)
   ENDIF
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
    SET desc = concat(substring(1,240,trim(desc)),"...",uncombined)
   ELSE
    SET desc = concat(trim(desc),uncombined)
   ENDIF
   RETURN(desc)
 END ;Subroutine
#exit_script
 FREE SET charge_details
END GO
