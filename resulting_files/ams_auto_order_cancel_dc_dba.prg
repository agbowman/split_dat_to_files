CREATE PROGRAM ams_auto_order_cancel_dc:dba
 PROMPT
  "Order" = "0"
  WITH order_id
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
 SET failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE smessage = vc WITH protect, noconstant("")
 FREE RECORD rdata
 RECORD rdata(
   1 qual_knt = i4
   1 qual[*]
     2 object_name = vc
     2 user_name = vc
     2 compiled_dt_tm = vc
     2 source_name = vc
 )
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 DECLARE order_id = f8 WITH protect, noconstant(0.0)
 DECLARE person_id = f8 WITH protect, noconstant(0.0)
 DECLARE encntr_id = f8 WITH protect, noconstant(0.0)
 DECLARE reply_info_flag = i2 WITH protect, noconstant(0)
 DECLARE action_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE order_communication_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE order_dt_tm = dq8 WITH protect
 DECLARE oe_format_id = f8 WITH protect, noconstant(0.0)
 DECLARE catalog_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE catalog_cd = f8 WITH protect, noconstant(0.0)
 DECLARE synonym_id = f8 WITH protect, noconstant(0.0)
 DECLARE order_mnemonic = vc WITH protect
 DECLARE primary_mnemonic = vc WITH protect
 DECLARE activity_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE requisition_format_cd = f8 WITH protect, noconstant(0.0)
 DECLARE requisition_routing_cd = f8 WITH protect, noconstant(0.0)
 DECLARE resource_route_lvl = i4 WITH protect, noconstant(0)
 DECLARE dept_display_name = vc WITH protect
 DECLARE orderable_type_flag = i2 WITH protect, noconstant(0)
 DECLARE dcp_clin_cat_cd = f8 WITH protect, noconstant(0.0)
 DECLARE stop_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE stop_duration = i4 WITH protect, noconstant(0)
 DECLARE stop_duration_unit_cd = f8 WITH protect, noconstant(0.0)
 DECLARE rx_mask = i4 WITH protect, noconstant(0)
 DECLARE med_order_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ordered_as_mnemonic = vc WITH protect
 DECLARE order_provider_id = f8 WITH protect, noconstant(0.0)
 DECLARE encntr_financial_id = f8 WITH protect, noconstant(0.0)
 DECLARE location_cd = f8 WITH protect, noconstant(0.0)
 DECLARE loc_facility_cd = f8 WITH protect, noconstant(0.0)
 DECLARE loc_nurse_unit_cd = f8 WITH protect, noconstant(0.0)
 DECLARE loc_room_cd = f8 WITH protect, noconstant(0.0)
 DECLARE loc_bed_cd = f8 WITH protect, noconstant(0.0)
 DECLARE valid_dose_dt_tm = dq8 WITH protect
 DECLARE last_update_action_sequence = i4 WITH protect, noconstant(0)
 DECLARE product_id = f8 WITH protect, noconstant(0.0)
 DECLARE contributor_system_cd = f8 WITH protect, noconstant(0.0)
 DECLARE action_personnel_id = f8 WITH protect, noconstant(0.0)
 DECLARE order_locn_cd = f8 WITH protect, noconstant(0.0)
 DECLARE accession = vc WITH protect
 DECLARE accession_id = f8 WITH protect, noconstant(0.0)
 DECLARE cont_order_method_flag = i2 WITH protect, noconstant(0)
 DECLARE order_review_ind = i2 WITH protect, noconstant(0)
 DECLARE print_req_ind = i2 WITH protect, noconstant(0)
 DECLARE complete_upon_order_ind = i2 WITH protect, noconstant(0)
 DECLARE activity_subtype_cd = f8 WITH protect, noconstant(0.0)
 DECLARE consent_form_format_cd = f8 WITH protect, noconstant(0.0)
 DECLARE consent_form_ind = i2 WITH protect, noconstant(0)
 DECLARE consent_form_routing_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dept_dup_check_ind = i2 WITH protect, noconstant(0)
 DECLARE dup_checking_ind = i2 WITH protect, noconstant(0)
 DECLARE ref_text_mask = i4 WITH protect, noconstant(0)
 DECLARE abn_review_ind = i2 WITH protect, noconstant(0)
 DECLARE review_hierarchy_id = f8 WITH protect, noconstant(0.0)
 DECLARE cki = vc WITH protect
 DECLARE template_order_flag = i2 WITH protect, noconstant(0)
 DECLARE template_order_id = f8 WITH protect, noconstant(0.0)
 DECLARE group_order_flag = i2 WITH protect, noconstant(0)
 DECLARE link_order_flag = i2 WITH protect, noconstant(0)
 DECLARE order_cancel_cd = f8 WITH public, constant(uar_get_code_by("DESCRIPTION",6003,"Cancel Order"
   ))
 DECLARE order_discontinue_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,
   "DISCONTINUE"))
 DECLARE communication_type_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6006,"WRITTEN"
   ))
 DECLARE system_cancel_oef_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",1309,
   "SYSTEMCANCEL"))
 DECLARE cancel_oe_field_id = f8 WITH protect, noconstant(0.0)
 DECLARE cancel_oe_field_meaning_id = f8 WITH protect, noconstant(0.0)
 DECLARE cancel_oe_field_meaning = vc WITH protect
 DECLARE cancel_oe_field_value = f8 WITH protect, noconstant(0.0)
 DECLARE cancel_oe_field_value_display = vc WITH protect
 DECLARE discontinue_oe_field_id = f8 WITH protect, noconstant(0.0)
 DECLARE discontinue_oe_field_meaning_id = f8 WITH protect, noconstant(0.0)
 DECLARE discontinue_oe_field_meaning = vc WITH protect
 DECLARE discontinue_oe_field_value = f8 WITH protect, noconstant(0.0)
 DECLARE discontinue_oe_field_value_display = vc WITH protect
 DECLARE discontinue_stop_dt_oe_field_id = f8 WITH protect, noconstant(0.0)
 DECLARE discontinue_stop_dt_oe_field_meaning_id = f8 WITH protect, noconstant(0.0)
 DECLARE discontinue_stop_dt_oe_field_meaning = vc WITH protect
 DECLARE discontinue_stop_dt_oe_field_value_dt_tm = dq8 WITH protect
 DECLARE discontinue_stop_dt_oe_field_value_display = vc WITH protect
 DECLARE group_sequence = i4 WITH protect, noconstant(0)
 DECLARE modified_ind = i2 WITH protect, constant(1)
 DECLARE cancel_flag = i4 WITH protect, noconstant(0)
 DECLARE orig_ord_as_flag = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE o.order_id=value( $1)
    AND o.active_ind=1)
  ORDER BY o.order_id
  HEAD o.order_id
   person_id = o.person_id, encntr_id = o.encntr_id, reply_info_flag = 1,
   order_id = o.order_id, order_communication_type_cd = communication_type_cd, order_dt_tm = o
   .orig_order_dt_tm,
   oe_format_id = o.oe_format_id, catalog_type_cd = o.catalog_type_cd, catalog_cd = o.catalog_cd,
   synonym_id = o.synonym_id, order_mnemonic = o.order_mnemonic, activity_type_cd = o
   .activity_type_cd,
   stop_type_cd = o.stop_type_cd, rx_mask = o.rx_mask, med_order_type_cd = o.med_order_type_cd,
   ordered_as_mnemonic = o.ordered_as_mnemonic, valid_dose_dt_tm = o.valid_dose_dt_tm,
   last_update_action_sequence = 1,
   product_id = o.product_id, contributor_system_cd = o.contributor_system_cd, template_order_flag =
   o.template_order_flag,
   template_order_id = o.template_order_id, group_order_flag = o.group_order_flag, link_order_flag =
   o.link_order_flag,
   orig_ord_as_flag = o.orig_ord_as_flag
  WITH nocounter
 ;end select
 CALL echo(build("person_id = ",person_id))
 CALL echo(build("encntr_id = ",encntr_id))
 CALL echo(build("reply_info_flag = ",reply_info_flag))
 CALL echo(build("order_id = ",order_id))
 CALL echo(build("order_communication_type_cd = ",order_communication_type_cd))
 CALL echo(build("order_dt_tm = ",order_dt_tm))
 CALL echo(build("oe_format_id = ",oe_format_id))
 CALL echo(build("catalog_type_cd = ",catalog_type_cd))
 CALL echo(build("catalog_cd = ",catalog_cd))
 CALL echo(build("synonym_id = ",synonym_id))
 CALL echo(build("order_mnemonic = ",order_mnemonic))
 CALL echo(build("activity_type_cd = ",activity_type_cd))
 CALL echo(build("stop_type_cd = ",stop_type_cd))
 CALL echo(build("rx_mask = ",rx_mask))
 CALL echo(build("med_order_type_cd = ",med_order_type_cd))
 CALL echo(build("ordered_as_mnemonic = ",ordered_as_mnemonic))
 CALL echo(build("valid_dose_dt_tm = ",valid_dose_dt_tm))
 CALL echo(build("last_update_action_sequence = ",last_update_action_sequence))
 CALL echo(build("product_id = ",product_id))
 CALL echo(build("contributor_system_cd = ",contributor_system_cd))
 CALL echo(build("template_order_flag = ",template_order_flag))
 CALL echo(build("template_order_id = ",template_order_id))
 CALL echo(build("group_order_flag = ",group_order_flag))
 CALL echo(build("link_order_flag = ",link_order_flag))
 CALL echo(build("orig_ord_as_flag = ",orig_ord_as_flag))
 SELECT INTO "nl:"
  FROM order_catalog oc
  PLAN (oc
   WHERE oc.catalog_cd=catalog_cd
    AND oc.active_ind=1)
  HEAD oc.catalog_cd
   primary_mnemonic = oc.primary_mnemonic, requisition_format_cd = oc.requisition_format_cd,
   requisition_routing_cd = oc.requisition_routing_cd,
   resource_route_lvl = oc.resource_route_lvl, orderable_type_flag = oc.orderable_type_flag,
   dept_display_name = oc.dept_display_name,
   dcp_clin_cat_cd = oc.dcp_clin_cat_cd, stop_duration = oc.stop_duration, stop_duration_unit_cd = oc
   .stop_duration_unit_cd,
   cont_order_method_flag = oc.cont_order_method_flag, order_review_ind = oc.order_review_ind,
   print_req_ind = oc.print_req_ind,
   complete_upon_order_ind = oc.complete_upon_order_ind, activity_subtype_cd = oc.activity_subtype_cd,
   resource_route_lvl = oc.resource_route_lvl,
   consent_form_format_cd = oc.consent_form_format_cd, consent_form_ind = oc.consent_form_ind,
   consent_form_routing_cd = oc.consent_form_routing_cd,
   dept_dup_check_ind = oc.dept_dup_check_ind, dup_checking_ind = oc.dup_checking_ind, ref_text_mask
    = oc.ref_text_mask,
   abn_review_ind = oc.abn_review_ind, review_hierarchy_id = oc.review_hierarchy_id, cki = oc.cki
  WITH nocounter
 ;end select
 CALL echo(build("primary_mnemonic = ",primary_mnemonic))
 CALL echo(build("requisition_format_cd = ",requisition_format_cd))
 CALL echo(build("requisition_routing_cd = ",requisition_routing_cd))
 CALL echo(build("resource_route_lvl = ",resource_route_lvl))
 CALL echo(build("orderable_type_flag = ",orderable_type_flag))
 CALL echo(build("dept_display_name = ",dept_display_name))
 CALL echo(build("dcp_clin_cat_cd = ",dcp_clin_cat_cd))
 CALL echo(build("stop_duration = ",stop_duration))
 CALL echo(build("stop_duration_unit_cd = ",stop_duration_unit_cd))
 CALL echo(build("cont_order_method_flag = ",cont_order_method_flag))
 CALL echo(build("order_review_ind = ",order_review_ind))
 CALL echo(build("print_req_ind = ",print_req_ind))
 CALL echo(build("complete_upon_order_ind = ",complete_upon_order_ind))
 CALL echo(build("activity_subtype_cd = ",activity_subtype_cd))
 CALL echo(build("resource_route_lvl = ",resource_route_lvl))
 CALL echo(build("consent_form_format_cd = ",consent_form_format_cd))
 CALL echo(build("consent_form_ind = ",consent_form_ind))
 CALL echo(build("consent_form_routing_cd = ",consent_form_routing_cd))
 CALL echo(build("dept_dup_check_ind = ",dept_dup_check_ind))
 CALL echo(build("dup_checking_ind = ",dup_checking_ind))
 CALL echo(build("ref_text_mask = ",ref_text_mask))
 CALL echo(build("abn_review_ind = ",abn_review_ind))
 CALL echo(build("review_hierarchy_id = ",review_hierarchy_id))
 CALL echo(build("cki = ",cki))
 SELECT INTO "nl:"
  FROM order_action oa
  PLAN (oa
   WHERE oa.order_id=order_id)
  HEAD oa.order_id
   order_provider_id = reqinfo->updt_id, action_personnel_id = reqinfo->updt_id, order_locn_cd = oa
   .order_locn_cd
  WITH nocounter
 ;end select
 CALL echo(build("order_provider_id = ",order_provider_id))
 CALL echo(build("action_personnel_id = ",action_personnel_id))
 CALL echo(build("order_locn_cd = ",order_locn_cd))
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE e.encntr_id=encntr_id
    AND e.active_ind=1)
  HEAD e.encntr_id
   location_cd = e.location_cd, loc_facility_cd = e.loc_facility_cd, loc_nurse_unit_cd = e
   .loc_nurse_unit_cd,
   loc_room_cd = e.loc_room_cd, loc_bed_cd = e.loc_bed_cd, encntr_financial_id = e
   .encntr_financial_id
  WITH nocounter
 ;end select
 CALL echo(build("location_cd = ",location_cd))
 CALL echo(build("loc_facility_cd = ",loc_facility_cd))
 CALL echo(build("loc_nurse_unit_cd = ",loc_nurse_unit_cd))
 CALL echo(build("loc_room_cd = ",loc_room_cd))
 CALL echo(build("loc_bed_cd = ",loc_bed_cd))
 CALL echo(build("encntr_financial_id = ",encntr_financial_id))
 SELECT INTO "nl:"
  FROM accession_order_r aor
  PLAN (aor
   WHERE aor.order_id=order_id)
  HEAD aor.order_id
   accession_id = aor.accession_id, accession = trim(aor.accession)
  WITH nocounter
 ;end select
 CALL echo(build("accession_id = ",accession_id))
 CALL echo(build("accession = ",accession))
 SELECT INTO "nl:"
  FROM order_detail od
  PLAN (od
   WHERE od.order_id=order_id
    AND od.oe_field_meaning="REQSTARTDTTM")
  DETAIL
   IF (encntr_id=0.0)
    cancel_flag = 1
   ELSE
    cancel_flag = 0
   ENDIF
   IF (encntr_id != 0.0)
    IF (od.oe_field_dt_tm_value > cnvtdatetime(curdate,curtime3))
     cancel_flag = 1
    ELSE
     cancel_flag = 0
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (cancel_flag=1)
  SELECT INTO "nl:"
   FROM order_entry_fields oef,
    oe_field_meaning ofm
   PLAN (oef
    WHERE oef.description="Cancel Reason")
    JOIN (ofm
    WHERE ofm.oe_field_meaning_id=oef.oe_field_meaning_id)
   DETAIL
    cancel_oe_field_id = oef.oe_field_id, cancel_oe_field_meaning_id = oef.oe_field_meaning_id,
    cancel_oe_field_meaning = trim(ofm.oe_field_meaning),
    cancel_oe_field_value = system_cancel_oef_cd, cancel_oe_field_value_display = trim(
     uar_get_code_display(system_cancel_oef_cd)), action_type_cd = order_cancel_cd
   WITH nocounter
  ;end select
  CALL echo(build("cancel_oe_field_id = ",cancel_oe_field_id))
  CALL echo(build("cancel_oe_field_meaning_id = ",cancel_oe_field_meaning_id))
  CALL echo(build("cancel_oe_field_meaning = ",cancel_oe_field_meaning))
  CALL echo(build("cancel_oe_field_value = ",cancel_oe_field_value))
  CALL echo(build("cancel_oe_field_value_display = ",cancel_oe_field_value_display))
 ELSE
  SELECT INTO "nl:"
   FROM order_entry_fields oef,
    oe_field_meaning ofm
   PLAN (oef
    WHERE oef.description="Discontinue Reason")
    JOIN (ofm
    WHERE ofm.oe_field_meaning_id=oef.oe_field_meaning_id)
   DETAIL
    discontinue_oe_field_id = oef.oe_field_id, discontinue_oe_field_meaning_id = oef
    .oe_field_meaning_id, discontinue_oe_field_meaning = trim(ofm.oe_field_meaning),
    discontinue_oe_field_value = system_cancel_oef_cd, discontinue_oe_field_value_display = trim(
     uar_get_code_display(system_cancel_oef_cd))
   WITH nocounter
  ;end select
  CALL echo(build("discontinue_oe_field_id = ",discontinue_oe_field_id))
  CALL echo(build("discontinue_oe_field_meaning_id = ",discontinue_oe_field_meaning_id))
  CALL echo(build("discontinue_oe_field_meaning = ",discontinue_oe_field_meaning))
  CALL echo(build("discontinue_oe_field_value = ",discontinue_oe_field_value))
  CALL echo(build("discontinue_oe_field_value_display = ",discontinue_oe_field_value_display))
  SELECT INTO "nl:"
   FROM order_entry_fields oef,
    oe_field_meaning ofm
   PLAN (oef
    WHERE oef.description="Stop Date/Time")
    JOIN (ofm
    WHERE ofm.oe_field_meaning_id=oef.oe_field_meaning_id)
   DETAIL
    discontinue_stop_dt_oe_field_id = oef.oe_field_id, discontinue_stop_dt_oe_field_meaning_id = oef
    .oe_field_meaning_id, discontinue_stop_dt_oe_field_meaning = trim(ofm.oe_field_meaning),
    discontinue_stop_dt_oe_field_value_dt_tm = cnvtdatetime(curdate,curtime3),
    discontinue_stop_dt_oe_field_value_display = concat(trim(format(cnvtdatetime(curdate,curtime3),
       "dd/mm/yyyy hh:mm:ss;;d"))," ","UAE"), action_type_cd = order_discontinue_cd
   WITH nocounter
  ;end select
  CALL echo(build("discontinue_stop_dt_oe_field_id = ",discontinue_stop_dt_oe_field_id))
  CALL echo(build("discontinue_stop_dt_oe_field_meaning_id = ",
    discontinue_stop_dt_oe_field_meaning_id))
  CALL echo(build("discontinue_stop_dt_oe_field_meaning = ",discontinue_stop_dt_oe_field_meaning))
  CALL echo(build("discontinue_stop_dt_oe_field_value_dt_tm = ",
    discontinue_stop_dt_oe_field_value_dt_tm))
  CALL echo(build("discontinue_stop_dt_oe_field_value_display = ",
    discontinue_stop_dt_oe_field_value_display))
 ENDIF
 EXECUTE crmrtl
 EXECUTE srvrtl
 DECLARE happ = i4 WITH private, noconstant(0)
 DECLARE htask = i4 WITH private, noconstant(0)
 DECLARE hstep = i4 WITH private, noconstant(0)
 DECLARE hreq = i4 WITH private, noconstant(0)
 DECLARE horderlist = i4 WITH private, noconstant(0)
 DECLARE hdetaillist = i4 WITH private, noconstant(0)
 SET crmstat = uar_crmbeginapp(600005,happ)
 IF (crmstat != 0)
  SET errorstr = build("CrmBeginApp(",600005,") stat:",crmstat)
  CALL echo(build("Error:: ",errorstr))
  RETURN(0)
 ENDIF
 SET crmstat = uar_crmbegintask(happ,560201,htask)
 IF (crmstat != 0)
  SET errorstr = build("CrmBeginTask(",560201,") stat:",crmstat)
  CALL uar_crmendapp(happ)
  CALL echo(build("Error:: ",errorstr))
  RETURN(0)
 ENDIF
 SET crmstat = uar_crmbeginreq(htask,"",560201,hstep)
 IF (crmstat != 0)
  SET errorstr = build("CrmBeginReq(",560201,") stat:",crmstat)
  CALL uar_crmendtask(htask)
  CALL uar_crmendapp(happ)
  CALL echo(build("Error:: ",errorstr))
  RETURN(0)
 ENDIF
 SET hreq = uar_crmgetrequest(hstep)
 SET stat = uar_srvsetdouble(hreq,"productId",product_id)
 SET stat = uar_srvsetdouble(hreq,"personId",person_id)
 SET stat = uar_srvsetdouble(hreq,"encntrId",encntr_id)
 SET stat = uar_srvsetdouble(hreq,"encntrFinancialId",encntr_financial_id)
 SET stat = uar_srvsetdouble(hreq,"locationCd",location_cd)
 SET stat = uar_srvsetdouble(hreq,"locFacilityCd",loc_facility_cd)
 SET stat = uar_srvsetdouble(hreq,"locNurseUnitCd",loc_nurse_unit_cd)
 SET stat = uar_srvsetdouble(hreq,"locRoomCd",loc_room_cd)
 SET stat = uar_srvsetdouble(hreq,"locBedCd",loc_bed_cd)
 SET stat = uar_srvsetdouble(hreq,"actionPersonnelId",action_personnel_id)
 SET stat = uar_srvsetdouble(hreq,"contributorSystemCd",contributor_system_cd)
 SET stat = uar_srvsetdouble(hreq,"orderLocnCd",order_locn_cd)
 SET stat = uar_srvsetshort(hreq,"replyInfoFlag",reply_info_flag)
 SET horderlist = uar_srvadditem(hreq,"orderlist")
 SET stat = uar_srvsetdouble(horderlist,"orderId",order_id)
 SET stat = uar_srvsetdouble(horderlist,"actionTypeCd",action_type_cd)
 SET stat = uar_srvsetdouble(horderlist,"communicationTypeCd",order_communication_type_cd)
 SET stat = uar_srvsetdouble(horderlist,"orderProviderId",order_provider_id)
 SET stat = uar_srvsetdate(horderlist,"orderDtTm",order_dt_tm)
 SET stat = uar_srvsetdouble(horderlist,"oeFormatId",oe_format_id)
 SET stat = uar_srvsetdouble(horderlist,"catalogTypeCd",catalog_type_cd)
 SET stat = uar_srvsetstring(horderlist,"accessionNbr",accession)
 SET stat = uar_srvsetdouble(horderlist,"accessionId",accession_id)
 IF (cancel_flag=1)
  SET hdetaillist = uar_srvadditem(horderlist,"detailList")
  SET stat = uar_srvsetdouble(hdetaillist,"oeFieldId",cancel_oe_field_id)
  SET stat = uar_srvsetdouble(hdetaillist,"oeFieldValue",cancel_oe_field_value)
  SET stat = uar_srvsetstring(hdetaillist,"oeFieldDisplayValue",cancel_oe_field_value_display)
  SET stat = uar_srvsetstring(hdetaillist,"oeFieldMeaning",trim(cancel_oe_field_meaning))
  SET stat = uar_srvsetdouble(hdetaillist,"oeFieldMeaningId",cancel_oe_field_meaning_id)
  SET stat = uar_srvsetlong(hdetaillist,"groupSeq",1)
  SET stat = uar_srvsetshort(hdetaillist,"modifiedInd",modified_ind)
 ELSE
  SET hdetaillist = uar_srvadditem(horderlist,"detailList")
  SET stat = uar_srvsetdouble(hdetaillist,"oeFieldId",discontinue_stop_dt_oe_field_id)
  SET stat = uar_srvsetdouble(hdetaillist,"oeFieldDtTmValue",cnvtdatetime(curdate,curtime3))
  SET stat = uar_srvsetstring(hdetaillist,"oeFieldDisplayValue",
   discontinue_stop_dt_oe_field_value_display)
  SET stat = uar_srvsetstring(hdetaillist,"oeFieldMeaning",trim(discontinue_stop_dt_oe_field_meaning)
   )
  SET stat = uar_srvsetdouble(hdetaillist,"oeFieldMeaningId",discontinue_stop_dt_oe_field_meaning_id)
  SET stat = uar_srvsetlong(hdetaillist,"groupSeq",1)
  SET stat = uar_srvsetshort(hdetaillist,"modifiedInd",modified_ind)
  SET hdetaillist = uar_srvadditem(horderlist,"detailList")
  SET stat = uar_srvsetdouble(hdetaillist,"oeFieldId",discontinue_oe_field_id)
  SET stat = uar_srvsetdouble(hdetaillist,"oeFieldValue",discontinue_oe_field_value)
  SET stat = uar_srvsetstring(hdetaillist,"oeFieldDisplayValue",discontinue_oe_field_value_display)
  SET stat = uar_srvsetstring(hdetaillist,"oeFieldMeaning",trim(discontinue_oe_field_meaning))
  SET stat = uar_srvsetdouble(hdetaillist,"oeFieldMeaningId",discontinue_oe_field_meaning_id)
  SET stat = uar_srvsetlong(hdetaillist,"groupSeq",2)
  SET stat = uar_srvsetshort(hdetaillist,"modifiedInd",modified_ind)
 ENDIF
 SET stat = uar_srvsetshort(horderlist,"origOrdAsFlag",orig_ord_as_flag)
 SET stat = uar_srvsetdouble(horderlist,"catalogCd",catalog_cd)
 SET stat = uar_srvsetdouble(horderlist,"synonymId",synonym_id)
 SET stat = uar_srvsetstring(horderlist,"orderMnemonic",order_mnemonic)
 SET stat = uar_srvsetstring(horderlist,"primaryMnemonic",primary_mnemonic)
 SET stat = uar_srvsetdouble(horderlist,"activityTypeCd",activity_type_cd)
 SET stat = uar_srvsetdouble(horderlist,"activitySubtypeCd",activity_subtype_cd)
 SET stat = uar_srvsetshort(horderlist,"contOrderMethodFlag",cont_order_method_flag)
 SET stat = uar_srvsetshort(horderlist,"completeUponOrderInd",complete_upon_order_ind)
 SET stat = uar_srvsetshort(horderlist,"orderReviewInd",order_review_ind)
 SET stat = uar_srvsetshort(horderlist,"printReqInd",print_req_ind)
 SET stat = uar_srvsetdouble(horderlist,"requisitionFormatCd",requisition_format_cd)
 SET stat = uar_srvsetdouble(horderlist,"requisitionRoutingCd",requisition_routing_cd)
 SET stat = uar_srvsetlong(horderlist,"resourceRouteLevel",resource_route_lvl)
 SET stat = uar_srvsetshort(horderlist,"consentFormInd",consent_form_ind)
 SET stat = uar_srvsetdouble(horderlist,"consentFormFormatCd",consent_form_format_cd)
 SET stat = uar_srvsetdouble(horderlist,"consentFormRoutingCd",consent_form_routing_cd)
 SET stat = uar_srvsetshort(horderlist,"deptDupCheckInd",dept_dup_check_ind)
 SET stat = uar_srvsetshort(horderlist,"dupCheckingInd",dup_checking_ind)
 SET stat = uar_srvsetstring(horderlist,"deptDisplayName",dept_display_name)
 SET stat = uar_srvsetlong(horderlist,"refTextMask",ref_text_mask)
 SET stat = uar_srvsetshort(horderlist,"abnReviewInd",abn_review_ind)
 SET stat = uar_srvsetdouble(horderlist,"reviewHierarchyId",review_hierarchy_id)
 SET stat = uar_srvsetshort(horderlist,"orderableTypeFlag",orderable_type_flag)
 SET stat = uar_srvsetdouble(horderlist,"dcpClinCatCd",dcp_clin_cat_cd)
 SET stat = uar_srvsetstring(horderlist,"cki",cki)
 SET stat = uar_srvsetdouble(horderlist,"stopTypeCd",stop_type_cd)
 SET stat = uar_srvsetlong(horderlist,"stopDuration",stop_duration)
 SET stat = uar_srvsetdouble(horderlist,"stopDurationUnitCd",stop_duration_unit_cd)
 SET stat = uar_srvsetshort(horderlist,"templateOrderFlag",template_order_flag)
 SET stat = uar_srvsetdouble(horderlist,"templateOrderId",template_order_id)
 SET stat = uar_srvsetshort(horderlist,"groupOrderFlag",group_order_flag)
 SET stat = uar_srvsetshort(horderlist,"linkOrderFlag",link_order_flag)
 SET stat = uar_srvsetlong(horderlist,"rxMask",rx_mask)
 SET stat = uar_srvsetdouble(horderlist,"encntrId",encntr_id)
 SET stat = uar_srvsetdouble(horderlist,"encntrFinancialId",encntr_financial_id)
 SET stat = uar_srvsetdouble(horderlist,"locationCd",location_cd)
 SET stat = uar_srvsetdouble(horderlist,"locFacilityCd",loc_facility_cd)
 SET stat = uar_srvsetdouble(horderlist,"locNurseUnitCd",loc_nurse_unit_cd)
 SET stat = uar_srvsetdouble(horderlist,"locRoomCd",loc_room_cd)
 SET stat = uar_srvsetdouble(horderlist,"locBedCd",loc_bed_cd)
 SET stat = uar_srvsetdouble(horderlist,"medOrderTypeCd",med_order_type_cd)
 SET stat = uar_srvsetstring(horderlist,"orderedAsMnemonic",ordered_as_mnemonic)
 SET stat = uar_srvsetdate(horderlist,"origOrderDtTm",order_dt_tm)
 SET stat = uar_srvsetdate(horderlist,"validDoseDtTm",valid_dose_dt_tm)
 SET stat = uar_srvsetlong(horderlist,"lastUpdateActionSequence",last_update_action_sequence)
 SET crmstat = uar_crmperform(hstep)
 IF (crmstat != 0)
  SET errorstr = build("CrmPerform(",reqid,") stat:",crmstat)
  CALL echo(build("Error:: ",errorstr))
  RETURN(0)
 ENDIF
 CALL uar_crmendreq(hstep)
 CALL uar_crmendtask(htask)
 CALL uar_crmendapp(happ)
 COMMIT
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
END GO
