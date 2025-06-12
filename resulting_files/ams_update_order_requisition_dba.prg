CREATE PROGRAM ams_update_order_requisition:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select the existing requisition format to be replaced" = 0.000000,
  "Orders using the req format selected above. Select all the orders whose req format is to be updated"
   = 0,
  "Select the new req format" = 0.000000
  WITH outdev, existingreq, ordercatalog,
  newreq
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET script_failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET script_failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 DECLARE icnt = i4
 FREE RECORD orderstoupdate
 RECORD orderstoupdate(
   1 ordercount = i4
   1 cataloglist[*]
     2 code_val = f8
     2 req_format = f8
     2 status = vc
 )
 FREE RECORD request
 RECORD request(
   1 ic_auto_verify_flag = i2
   1 discern_auto_verify_flag = i2
   1 stop_type_cd = f8
   1 stop_duration = i4
   1 stop_duration_unit_cd = f8
   1 modifiable_flag = i2
   1 dcp_clin_cat_cd = f8
   1 catalog_cd = f8
   1 consent_form_ind = i2
   1 active_ind = i2
   1 catalog_type_cd = f8
   1 activity_type_cd = f8
   1 activity_subtype_cd = f8
   1 requisition_format_cd = f8
   1 requisition_routing_cd = f8
   1 inst_restriction_ind = i2
   1 schedule_ind = i2
   1 description = vc
   1 iv_ingredient_ind = i2
   1 print_req_ind = i2
   1 oe_format_id = f8
   1 orderable_type_flag = i2
   1 complete_upon_order_ind = i2
   1 quick_chart_ind = i2
   1 comment_template_flag = i2
   1 prep_info_flag = i2
   1 dup_checking_ind = i2
   1 order_review_ind = i2
   1 bill_only_ind = i2
   1 cont_order_method_flag = i2
   1 primary_mnemonic = vc
   1 consent_form_format_cd = f8
   1 consent_form_routing_cd = f8
   1 upd_medication_ind = i2
   1 dc_display_days = i4
   1 dc_interaction_days = i4
   1 mdx_gcr_id = f8
   1 updt_cnt = i4
   1 auto_cancel_ind = i2
   1 form_level = i4
   1 form_id = f8
   1 disable_order_comment_ind = i2
   1 dept_disp_name = vc
   1 vetting_approval_flag = i2
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET lcheck = substring(1,1,reflect(parameter(3,0)))
 IF (lcheck="L")
  WHILE (lcheck > " ")
    SET icnt = (icnt+ 1)
    SET lcheck = substring(1,1,reflect(parameter(3,icnt)))
    IF (lcheck > " ")
     IF (mod(icnt,10)=1)
      SET stat = alterlist(orderstoupdate->cataloglist,(icnt+ 9))
     ENDIF
     SET orderstoupdate->cataloglist[icnt].code_val = parameter(3,icnt)
    ENDIF
  ENDWHILE
  SET stat = alterlist(orderstoupdate->cataloglist,(icnt - 1))
  SET orderstoupdate->ordercount = (icnt - 1)
 ELSE
  SET stat = alterlist(orderstoupdate->cataloglist,1)
  SET orderstoupdate->ordercount = 1
  SET orderstoupdate->cataloglist[1].code_val =  $ORDERCATALOG
 ENDIF
 CALL echorecord(orderstoupdate)
 FOR (idx = 1 TO orderstoupdate->ordercount)
   SELECT INTO "nl:"
    FROM order_catalog oc
    WHERE (oc.catalog_cd=orderstoupdate->cataloglist[idx].code_val)
    ORDER BY oc.catalog_cd
    HEAD oc.catalog_cd
     request->ic_auto_verify_flag = oc.ic_auto_verify_flag, request->discern_auto_verify_flag = oc
     .discern_auto_verify_flag, request->form_id = oc.form_id,
     request->form_level = oc.form_level, request->disable_order_comment_ind = oc
     .disable_order_comment_ind, request->stop_type_cd = oc.stop_type_cd,
     request->stop_duration = oc.stop_duration, request->stop_duration_unit_cd = oc
     .stop_duration_unit_cd, request->auto_cancel_ind = oc.auto_cancel_ind,
     request->modifiable_flag = oc.modifiable_flag, request->catalog_cd = oc.catalog_cd, request->
     consent_form_ind = oc.consent_form_ind,
     request->active_ind = oc.active_ind, request->dcp_clin_cat_cd = oc.dcp_clin_cat_cd, request->
     catalog_type_cd = oc.catalog_type_cd,
     request->activity_type_cd = oc.activity_type_cd, request->activity_subtype_cd = oc
     .activity_subtype_cd, request->requisition_format_cd =  $NEWREQ,
     request->requisition_routing_cd = oc.requisition_routing_cd, request->inst_restriction_ind = oc
     .inst_restriction_ind, request->schedule_ind = oc.schedule_ind,
     request->description = oc.description, request->print_req_ind = oc.print_req_ind, request->
     oe_format_id = oc.oe_format_id,
     request->orderable_type_flag = oc.orderable_type_flag, request->complete_upon_order_ind = oc
     .complete_upon_order_ind, request->quick_chart_ind = oc.quick_chart_ind,
     request->comment_template_flag = oc.comment_template_flag, request->prep_info_flag = oc
     .prep_info_flag, request->dup_checking_ind = oc.dup_checking_ind,
     request->order_review_ind = oc.order_review_ind, request->bill_only_ind = oc.bill_only_ind,
     request->cont_order_method_flag = oc.cont_order_method_flag,
     request->primary_mnemonic = oc.primary_mnemonic, request->consent_form_format_cd = oc
     .consent_form_format_cd, request->consent_form_routing_cd = oc.consent_form_routing_cd,
     request->dc_display_days = oc.dc_display_days, request->dc_interaction_days = oc
     .dc_interaction_days, request->updt_cnt = oc.updt_cnt,
     request->dept_disp_name = oc.dept_display_name, request->vetting_approval_flag = oc
     .vetting_approval_flag, orderstoupdate->cataloglist[idx].req_format = oc.requisition_format_cd
    WITH nocounter
   ;end select
   EXECUTE orm_chg_order_catalog:dba
   CALL echo("for loop index: ")
   CALL echo(idx)
   IF ((reply->status_data.status="S"))
    SET orderstoupdate->cataloglist[idx].status = "Req format updated"
   ELSE
    SET orderstoupdate->cataloglist[idx].status = "Failed to update req format"
   ENDIF
 ENDFOR
 SELECT INTO  $OUTDEV
  order_catalog = uar_get_code_display(orderstoupdate->cataloglist[d.seq].code_val), status =
  orderstoupdate->cataloglist[d.seq].status, existing_req_format = uar_get_code_display(
   orderstoupdate->cataloglist[d.seq].req_format),
  new_req_format = uar_get_code_display(value( $NEWREQ))
  FROM (dummyt d  WITH seq = orderstoupdate->ordercount)
  WITH nocounter, format
 ;end select
#exit_script
 IF (script_failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (script_failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
 SET last_mod = "001 06/30/15 ZA030646  Initial Release"
END GO
