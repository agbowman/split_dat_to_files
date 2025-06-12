CREATE PROGRAM amb_rln_req:dba
 DECLARE getrelatedorders(in_rec=vc(ref)) = i2
 DECLARE getfuturereprintorders(in_rec=vc(ref)) = i4
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 RECORD request(
   1 person_id = f8
   1 print_prsnl_id = f8
   1 order_qual[*]
     2 order_id = f8
     2 encntr_id = f8
     2 conversation_id = f8
   1 printer_name = c50
 )
 IF (validate(reply)=false)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 RECORD request_hold(
   1 order_qual[*]
     2 order_id = f8
     2 parent_orderid = f8
     2 coll_class_cd = f8
     2 coll_class_flag = i2
     2 coll_class_alias = vc
     2 perf_loc_cd = f8
     2 perf_loc_disp = vc
     2 ref_lab = vc
     2 contrib_source_cd = f8
     2 client_bill = i2
 )
 RECORD labcorp_diagnosis(
   1 diag[*]
     2 nomenclature_id = f8
     2 source_ident = vc
 )
 RECORD req_data(
   1 encntr_id = f8
   1 person_id = f8
   1 name_full_formatted = vc
   1 name
     2 last = vc
     2 first = vc
     2 middle = vc
   1 sex_cd = f8
   1 race_cd = f8
   1 birth_dt_tm = dq8
   1 birth_tz = i4
   1 mrn = vc
   1 cdf_meaning_mrn = vc
   1 fin = vc
   1 raw_fin = vc
   1 ssn = vc
   1 age = vc
   1 ssn_barcode = vc
   1 loc_nurse_unit_cd = f8
   1 financial_class_cd = f8
   1 workers_comp = vc
   1 visit_dt_tm = dq8
   1 reprint_ind = i2
   1 quest_ind = i2
   1 labcorp_ind = i2
   1 std_ind = i2
   1 all_ind = i2
   1 address
     2 street_addr = vc
     2 street_addr2 = vc
     2 city = vc
     2 state = vc
     2 zipcode = vc
   1 phone
     2 number = vc
     2 format_cd = f8
   1 work
     2 number = vc
     2 format_cd = f8
   1 organization
     2 location_cd = vc
     2 org_id = f8
     2 org_name = vc
     2 street_addr = vc
     2 street_addr2 = vc
     2 city = vc
     2 state = vc
     2 zipcode = vc
     2 phone_num = vc
     2 phone_format_cd = f8
     2 fax_num = vc
     2 fax_format_cd = f8
   1 subscriber_cnt = i4
   1 subscriber[*]
     2 encntr_plan_reltn_id = f8
     2 person_plan_reltn_id = f8
     2 priority_seq = i4
     2 name = vc
     2 id = f8
     2 ssn = vc
     2 birth_dt_tm = dq8
     2 birth_tz = i4
     2 address
       3 street_addr = vc
       3 city = vc
       3 state = vc
       3 zipcode = vc
     2 phone
       3 number = vc
       3 format_cd = f8
     2 employer_name = vc
     2 relation_cd = f8
     2 health_plan
       3 id = f8
       3 financial_class_cd = f8
       3 lc_alias = vc
       3 cust_alias = vc
       3 std_alias = vc
       3 name = vc
       3 address
         4 id = f8
         4 street_addr = vc
         4 street_addr2 = vc
         4 city = vc
         4 state = vc
         4 zipcode = vc
       3 policy_nbr = vc
       3 group_nbr = vc
       3 subs_member_nbr = vc
   1 guarantor_type_cd = f8
   1 guarantor
     2 name_full_formatted = vc
     2 reltn_cd = f8
     2 ssn = vc
     2 birth_dt_tm = dq8
     2 birth_tz = i4
     2 address
       3 street_addr = vc
       3 city = vc
       3 state = vc
       3 zipcode = vc
     2 phone
       3 number = vc
       3 format_cd = f8
   1 dx_cnt = i4
   1 dx_qual[*]
     2 diagnosis_id = f8
     2 nomenclature_id = f8
     2 source_identifier = vc
   1 dx_list = vc
   1 dx_lc_list = vc
   1 dx_barcode = vc
   1 refer_physician_id = f8
   1 refer_physician_name = vc
   1 req_cnt = i4
   1 bill_to = vc
   1 bill_to_ind = i2
   1 insurance_ind = i2
   1 req_qual[*]
     2 req_type_ind = i2
     2 ref_lab = f8
     2 contrib_src_cd = f8
     2 loc_nurse_unit_alias = vc
     2 org_alias = vc
     2 collected_ind = i2
     2 client_bill_ind = i2
     2 nurse_collect_ind = i2
     2 req_control_nbr = vc
     2 spec_lab_type = i2
     2 coll_class_cd = f8
     2 transfer_temp_cd = f8
     2 collection_dt_tm = dq8
     2 abn_ind = i2
     2 order_provider
       3 id = f8
       3 name_full = vc
       3 name_first = vc
       3 name_last = vc
       3 name_middle = vc
       3 name_title = vc
       3 npi = vc
       3 external_id = vc
       3 docupin = vc
       3 quest_acct_nbr = vc
       3 labcorp_acct_nbr = vc
       3 degree = vc
       3 address
         4 street_addr = vc
         4 city = vc
         4 state = vc
         4 zipcode = vc
       3 phone
         4 number = vc
         4 format_cd = f8
       3 fax
         4 number = vc
         4 format_cd = f8
     2 sup_physician
       3 id = f8
       3 name_full = vc
       3 name_first = vc
       3 name_last = vc
       3 name_middle = vc
       3 name_title = vc
       3 npi = vc
       3 external_id = vc
       3 docupin = vc
       3 quest_acct_nbr = vc
       3 labcorp_acct_nbr = vc
       3 degree = vc
       3 address
         4 street_addr = vc
         4 city = vc
         4 state = vc
         4 zipcode = vc
       3 phone
         4 number = vc
         4 format_cd = f8
       3 fax
         4 number = vc
         4 format_cd = f8
     2 ord_cnt = i4
     2 ord_qual[*]
       3 order_id = f8
       3 reference_text_disp = gc32000
       3 hna_order_mnemonic = vc
       3 ordered_as_mnemonic = vc
       3 perf_loc_cd = f8
       3 perf_loc_disp = vc
       3 req_text = vc
       3 cpt_cd = vc
       3 alias = vc
       3 outbound_alias = vc
       3 collected_dt_tm = dq8
       3 cntnr_units = vc
       3 specimen_cd = f8
       3 specimen_type = vc
       3 specimen_description = vc
       3 lc_specimen_source = vc
       3 spec_lab_type = i2
       3 priority_cd = f8
       3 abn_ind = i2
       3 abn_status = vc
       3 abn_reason = vc
       3 special_instruct = vc
       3 container_id = f8
       3 container_info = vc
       3 detail_flag = i2
       3 detail_cnt = i4
       3 multi_cnt = i4
       3 nurse_collect = f8
       3 client_bill = f8
       3 drawn_dt_tm = dq8
       3 details[*]
         4 multi_select = i2
         4 oe_field_id = f8
         4 label_text = vc
         4 value = vc
       3 single_cnt = i4
       3 single_details[*]
         4 oe_field_id = f8
         4 label_text = vc
         4 value = vc
       3 srv_detail_cnt = i4
       3 dx_list = vc
       3 comment_knt = i4
       3 comment_line = vc
       3 comment[*]
         4 disp = vc
       3 oe_format_id = f8
       3 catalog_cd = f8
       3 subact_cd = f8
       3 order_status_cd = f8
       3 order_status = vc
       3 future_ind = i2
       3 diag_cnt = i4
       3 diag[*]
         4 wrap_diag = i2
         4 source_id = vc
         4 nomen_name = vc
   1 current_dt_tm = dq8
   1 print_quest_labels_ind = i2
   1 print_labcorp_labels_ind = i2
   1 print_misc_labels_ind = i2
 )
 RECORD insurance_data(
   1 resp_party_1 = vc
   1 reltn_1 = vc
   1 resp_street_addr_1 = vc
   1 resp_citystatezip_1 = vc
   1 resp_ssn_1 = vc
   1 resp_dob_1 = vc
   1 resp_phone_1 = vc
   1 sub_nbr_1 = vc
   1 ins_grp_nbr_1 = vc
   1 sub_empl_1 = vc
   1 carrier_code_1 = vc
   1 carrier_street_addr_1 = vc
   1 carrier_street_addr2_1 = vc
   1 carrier_citystatezip_1 = vc
   1 resp_party_2 = vc
   1 reltn_2 = vc
   1 resp_street_addr_2 = vc
   1 resp_citystatezip_2 = vc
   1 resp_ssn_2 = vc
   1 resp_dob_2 = vc
   1 resp_phone_2 = vc
   1 sub_nbr_2 = vc
   1 ins_grp_nbr_2 = vc
   1 sub_empl_2 = vc
   1 carrier_code_2 = vc
   1 carrier_street_addr_2 = vc
   1 carrier_street_addr2_2 = vc
   1 carrier_citystatezip_2 = vc
   1 bill_type_1 = vc
   1 ins_lc_alias_1 = vc
   1 ins_cust_code_1 = vc
   1 ins_std_code_1 = vc
   1 carrier_1 = vc
   1 ins_nbr_1 = vc
   1 bill_type_2 = vc
   1 ins_lc_alias_2 = vc
   1 ins_cust_code_2 = vc
   1 ins_std_code_2 = vc
   1 carrier_2 = vc
   1 ins_nbr_2 = vc
 )
 RECORD order_detail(
   1 cell1 = vc
   1 cell2 = vc
   1 cell3 = vc
 )
 RECORD ord_det_alias(
   1 codev_cnt = i4
   1 qual[*]
     2 code_value = f8
     2 display = vc
 )
 DECLARE acct_id = vc WITH protect, noconstant("")
 DECLARE req_id = vc WITH protect, noconstant("")
 DECLARE mrn = vc WITH protect, noconstant("")
 DECLARE format = vc WITH protect, noconstant("")
 DECLARE dynamic_requisition_text(format=vc,acct_id=vc,req_id=vc,mrn=vc) = vc WITH protect
 DECLARE requisition_text = vc WITH protect, noconstant("")
 DECLARE 73_ambrln = f8 WITH constant(uar_get_code_by("DISPLAYKEY",73,"AMBULATORYRLN")), protect
 DECLARE ord_conv_ind = i2 WITH noconstant(0), protect
 DECLARE conv_alias = vc
 DECLARE 104600_ambrlnpref = i4 WITH noconstant(0.0), protect
 SELECT
  cvs.code_set
  FROM code_value_set cvs
  WHERE cvs.display_key="AMBULATORYRLNPREFERENCES"
  DETAIL
   104600_ambrlnpref = cvs.code_set
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value_set cvs,
   code_value cv,
   code_value_outbound cvo
  WHERE cvs.display_key="AMBULATORYRLNPREFERENCES"
   AND cv.code_set=cvs.code_set
   AND cv.display_key="FULLORDERCONVOREQID"
   AND cvo.code_value=cv.code_value
   AND (cvo.contributor_source_cd=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=73
    AND cv.display_key="AMBULATORYRLN"))
  DETAIL
   conv_alias = trim(cnvtupper(cvo.alias),3)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  IF (conv_alias="NO")
   SET ord_conv_ind = 0
  ELSEIF (conv_alias="YES")
   SET ord_conv_ind = 1
  ENDIF
 ELSE
  SET ord_conv_ind = 0
 ENDIF
 DECLARE printlabcorplabels = vc WITH constant("PRINTLABCORPLABELS"), protect
 DECLARE printquestlabels = vc WITH constant("PRINTQUESTLABELS"), protect
 DECLARE printmisclabels = vc WITH constant("PRINTMISCLABELS"), protect
 DECLARE 16449_requestedstartdatetime = f8 WITH noconstant(0.0), protect
 DECLARE 16449_specimenttype = f8 WITH noconstant(0.0), protect
 DECLARE 16449_priority = f8 WITH noconstant(0.0), protect
 DECLARE 16449_abnreason = f8 WITH noconstant(0.0), protect
 DECLARE 16449_abnstatus = f8 WITH noconstant(0.0), protect
 DECLARE 16449_performinglocation = f8 WITH noconstant(0.0), protect
 DECLARE 16449_nursecollect = f8 WITH noconstant(0.0), protect
 DECLARE 16449_specialinstructions = f8 WITH noconstant(0.0), protect
 DECLARE 16449_specimendescription = f8 WITH noconstant(0.0), protect
 DECLARE 4_altmrn = f8 WITH noconstant(0.0), protect
 DECLARE 263_altmrn_alias = f8 WITH noconstant(0.0), protect
 DECLARE alt_mrn_desc = vc WITH noconstant(""), protect
 DECLARE loc_alias = vc WITH noconstant(""), protect
 SELECT INTO "nl:"
  FROM code_value_outbound cvo,
   code_value cv
  PLAN (cvo
   WHERE cvo.contributor_source_cd=73_ambrln
    AND cvo.code_set IN (4, 263, 16449, 43, 212,
   104600_ambrlnpref))
   JOIN (cv
   WHERE cv.code_value=cvo.code_value
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY cvo.code_set, cvo.code_value
  HEAD REPORT
   cnt = 0
  HEAD cvo.code_set
   null
  HEAD cvo.code_value
   IF (cvo.code_set=16449)
    cnt = (cnt+ 1)
    IF (mod(cnt,100)=1)
     stat = alterlist(ord_det_alias->qual,(cnt+ 99))
    ENDIF
    ord_det_alias->qual[cnt].code_value = cvo.code_value, ord_det_alias->qual[cnt].display =
    cnvtupper(trim(cvo.alias,3))
   ELSEIF (cvo.code_set=4)
    IF (trim(cnvtupper(cvo.alias),3)="ALT_MRN")
     4_altmrn = cvo.code_value, alt_mrn_desc = trim(cv.cdf_meaning,3)
    ENDIF
   ELSEIF (cvo.code_set=263)
    IF (trim(cnvtupper(cvo.alias),3)="ALT_MRN")
     263_altmrn_alias = cvo.code_value
    ENDIF
   ELSEIF (cvo.code_set IN (43, 212))
    loc_alias = trim(cvo.alias,3)
   ELSEIF (cvo.code_set=104600_ambrlnpref)
    IF (trim(cnvtupper(cvo.alias),3)="NO")
     CASE (trim(cnvtupper(cv.display_key),3))
      OF printlabcorplabels:
       req_data->print_labcorp_labels_ind = 0
      OF printquestlabels:
       req_data->print_quest_labels_ind = 0
      OF printmisclabels:
       req_data->print_misc_labels_ind = 0
     ENDCASE
    ELSEIF (trim(cnvtupper(cvo.alias),3)="YES")
     CASE (trim(cnvtupper(cv.display_key),3))
      OF printlabcorplabels:
       req_data->print_labcorp_labels_ind = 1
      OF printquestlabels:
       req_data->print_quest_labels_ind = 1
      OF printmisclabels:
       req_data->print_misc_labels_ind = 1
     ENDCASE
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(ord_det_alias->qual,cnt), ord_det_alias->codev_cnt = cnt
  WITH nocounter
 ;end select
 IF (textlen(trim(loc_alias,3))=0)
  SET loc_alias = "ORG"
 ENDIF
 DECLARE 212_business = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!8009")), protect
 DECLARE 212_home = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!4018")), protect
 DECLARE 43_business = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!9598")), protect
 DECLARE 43_home = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!4017")), protect
 DECLARE 43_fax_bus = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!9529")), protect
 DECLARE 320_npi = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!2160654021")), protect
 DECLARE 320_docupin = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!9854")), protect
 DECLARE 320_externalid = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3784")), protect
 DECLARE 27121_local = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!2961173")), protect
 DECLARE 353_person = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!9518")), protect
 DECLARE 353_org = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!9517")), protect
 DECLARE 353_subscriber = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!9462")), protect
 DECLARE 351_insured = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!9521")), protect
 DECLARE 351_defguar = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!9519")), protect
 DECLARE 333_referdoc = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!4597")), protect
 DECLARE 338_employer = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!9459")), protect
 DECLARE 319_mrn = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!8021")), protect
 DECLARE 319_fin_nbr = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!2930")), protect
 DECLARE 4_ssn = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!2626")), protect
 DECLARE 334_accountnbr = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!13753")), protect
 DECLARE 213_prsnl = f8 WITH constant(uar_get_code_by("MEANING",213,"PRSNL")), protect
 DECLARE 6003_order = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3094")), protect
 DECLARE 6003_activate = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!13773")), protect
 DECLARE 14281_dispatched = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14281,"DISPATCHED")),
 protect
 DECLARE 14_ord_comment = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3944")), protect
 DECLARE 400_icd9 = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!2953")), protect
 DECLARE 400_icd10cm_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!4101498946")), protect
 DECLARE 2061_collected_event_type_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!4908")),
 protect
 DECLARE 6004_deleted = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!44311")), protect
 DECLARE 6004_suspended = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3104")), protect
 DECLARE 6004_voidedwrslt = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!2488992")), protect
 DECLARE 6004_complete = f8 WITH constant(uar_get_code_by("MEANING",6004,"COMPLETED")), protect
 DECLARE 6004_canceled = f8 WITH constant(uar_get_code_by("MEANING",6004,"CANCELED")), protect
 DECLARE 6004_discontinued = f8 WITH constant(uar_get_code_by("MEANING",6004,"DISCONTINUED")),
 protect
 DECLARE 6004_future = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!11559")), protect
 DECLARE 6004_ordered = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3102")), protect
 DECLARE 17969_not_required = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!21505")), protect
 DECLARE 220_rlnlabcorp = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"60LABCORPAMBULATORY")),
 protect
 DECLARE 220_rlnquest = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"60SQLAMBULATORY")),
 protect
 DECLARE 13019_billcode = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3516")), protect
 DECLARE 354_workerscompensation = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!1302339")),
 protect
 DECLARE 354_selfpay = f8 WITH constant(uar_get_code_by("MEANING",354,"SELFPAY")), protect
 DECLARE cs_ambulatoryrln_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",73,"AMBULATORYRLN")),
 protect
 DECLARE in_house_lab = f8 WITH constant(1.0), protect
 DECLARE max_orders_per_req = i4 WITH noconstant(0), protect
 DECLARE max_aoe_char = i4 WITH constant(40), protect
 DECLARE diag_max_char = i4 WITH constant(107), protect
 DECLARE index = i4 WITH noconstant(0), protect
 DECLARE order_count = i4 WITH noconstant(0), protect
 DECLARE countprotocolorder = i4 WITH noconstant(0), protect
 DECLARE template_orderflag = i4 WITH constant(1), protect
 DECLARE protocol_orderflag = i4 WITH constant(7), protect
 DECLARE conv_id_digits = c5 WITH noconstant("     "), protect
 DECLARE conv_id_full = vc WITH noconstant(""), protect
 DECLARE order_dt_tm = dq8 WITH noconstant(0.0), protect
 DECLARE oa_parser = vc WITH noconstant(""), protect
 DECLARE parent_entity_name_address_parser = vc WITH noconstant(""), protect
 DECLARE parent_entity_name_phone_parser = vc WITH noconstant(""), protect
 DECLARE phone = vc WITH noconstant(""), protect
 DECLARE fax = vc WITH noconstant(""), protect
 DECLARE lab_corp_loc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",104600_ambrlnpref,
   "PRINTLABCORPLABELS"))
 DECLARE quest_loc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",104600_ambrlnpref,
   "PRINTQUESTLABELS"))
 DECLARE misc_loc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",104600_ambrlnpref,"PRINTMISCLABELS"
   ))
 DECLARE loopvar2 = i4 WITH noconstant(0), protect
 DECLARE countvar = i4 WITH noconstant(0), protect
 CALL echo("++++++++BEGIN MAIN PROGRAM++++++++")
 SET req_data->encntr_id = request->order_qual[1].encntr_id
 SET req_data->person_id = request->person_id
 SET req_data->current_dt_tm = cnvtdatetime(sysdate)
 IF ((request->print_prsnl_id > 0))
  IF ((req_data->encntr_id=0.00))
   SET countprotocolorder = getfuturereprintorders(request)
  ENDIF
  SET req_data->reprint_ind = 1
  IF (countprotocolorder=0)
   IF (getrelatedorders(request)=false)
    GO TO exit_script
   ENDIF
  ENDIF
  SET order_count = size(request_hold->order_qual,5)
 ELSE
  SET order_count = size(request->order_qual,5)
  SET stat = alterlist(request_hold->order_qual,order_count)
  FOR (index = 1 TO order_count)
    SET request_hold->order_qual[index].order_id = request->order_qual[index].order_id
  ENDFOR
 ENDIF
 SUBROUTINE getfuturereprintorders(in_rec)
   SELECT INTO "nl:"
    FROM orders o
    WHERE (o.order_id=in_rec->order_qual[1].order_id)
     AND o.protocol_order_id != 0
     AND  NOT (o.template_order_flag IN (protocol_orderflag, template_orderflag))
    ORDER BY o.order_id
    HEAD REPORT
     rel_ord_cnt = 0
    HEAD o.order_id
     rel_ord_cnt = (rel_ord_cnt+ 1)
     IF (mod(rel_ord_cnt,10)=1)
      stat = alterlist(request_hold->order_qual,(rel_ord_cnt+ 9))
     ENDIF
     request_hold->order_qual[rel_ord_cnt].order_id = o.order_id, request_hold->order_qual[
     rel_ord_cnt].parent_orderid = o.protocol_order_id
    FOOT REPORT
     stat = alterlist(request_hold->order_qual,rel_ord_cnt)
    WITH nocounter
   ;end select
   SET order_count = size(request_hold->order_qual,5)
   SET countprotocolorder = size(request_hold->order_qual,5)
   RETURN(countprotocolorder)
 END ;Subroutine
 CALL pause(10)
 SELECT INTO "nl:"
  FROM order_container_r ocr,
   container c,
   code_value_outbound cvo,
   order_detail od
  PLAN (ocr
   WHERE expand(index,1,order_count,ocr.order_id,request_hold->order_qual[index].order_id))
   JOIN (od
   WHERE od.order_id=outerjoin(ocr.order_id)
    AND od.oe_field_id=outerjoin(12667.00))
   JOIN (c
   WHERE c.container_id=ocr.container_id)
   JOIN (cvo
   WHERE cvo.code_value=outerjoin(c.coll_class_cd)
    AND cvo.contributor_source_cd=outerjoin(73_ambrln)
    AND cvo.code_set=outerjoin(231))
  ORDER BY ocr.order_id
  HEAD ocr.order_id
   pos = locateval(index,1,order_count,ocr.order_id,request_hold->order_qual[index].order_id),
   request_hold->order_qual[pos].coll_class_cd = c.coll_class_cd, alias_pos = findstring("+",trim(cvo
     .alias,4),1)
   IF (alias_pos > 0)
    alias_text = substring(1,(alias_pos - 1),trim(cvo.alias,4))
   ELSE
    alias_text = cvo.alias
   ENDIF
   CASE (trim(alias_text,3))
    OF "AP":
     request_hold->order_qual[pos].coll_class_flag = 1,request_hold->order_qual[pos].coll_class_alias
      = trim(cnvtupper(alias_text),3)
    OF "FR":
     IF (od.oe_field_id=12667
      AND trim(od.oe_field_display_value,3)="No")
      request_hold->order_qual[pos].coll_class_flag = 3, request_hold->order_qual[pos].
      coll_class_alias = trim(cnvtupper("RR"),3)
     ELSE
      request_hold->order_qual[pos].coll_class_flag = 2, request_hold->order_qual[pos].
      coll_class_alias = trim(cnvtupper(alias_text),3)
     ENDIF
    OF "RR":
     request_hold->order_qual[pos].coll_class_flag = 3,request_hold->order_qual[pos].coll_class_alias
      = trim(cnvtupper(alias_text),3)
    ELSE
     IF (textlen(trim(alias_text,3)) > 0)
      IF (alias_pos > 0)
       request_hold->order_qual[pos].coll_class_flag = 4, request_hold->order_qual[pos].
       coll_class_alias = trim(cnvtupper(alias_text),3)
      ELSE
       request_hold->order_qual[pos].coll_class_alias = trim(cnvtupper(alias_text),3), request_hold->
       order_qual[pos].coll_class_flag = 5
      ENDIF
     ELSE
      request_hold->order_qual[pos].coll_class_alias = "UNK", request_hold->order_qual[pos].
      coll_class_flag = 6
     ENDIF
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   order_detail od,
   code_value_outbound cvo,
   code_value_outbound cvo2
  PLAN (o
   WHERE expand(index,1,order_count,o.order_id,request_hold->order_qual[index].order_id))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND expand(num,1,ord_det_alias->codev_cnt,od.oe_field_id,ord_det_alias->qual[num].code_value,
    "PERFORMLOC",ord_det_alias->qual[num].display)
    AND (od.action_sequence=
   (SELECT
    max(od_s.action_sequence)
    FROM order_detail od_s
    WHERE od_s.order_id=od.order_id
     AND expand(num,1,ord_det_alias->codev_cnt,od_s.oe_field_id,ord_det_alias->qual[num].code_value,
     "PERFORMLOC",ord_det_alias->qual[num].display))))
   JOIN (cvo
   WHERE cvo.contributor_source_cd=outerjoin(73_ambrln)
    AND cvo.code_set=outerjoin(220)
    AND cvo.code_value=outerjoin(od.oe_field_value))
   JOIN (cvo2
   WHERE cvo2.contributor_source_cd=outerjoin(73_ambrln)
    AND cvo2.code_set=outerjoin(73)
    AND cvo2.code_value=outerjoin(cnvtreal(cvo.alias)))
  ORDER BY o.order_id
  HEAD o.order_id
   pos = locateval(index,1,order_count,o.order_id,request_hold->order_qual[index].order_id),
   request_hold->order_qual[pos].perf_loc_cd = od.oe_field_value, request_hold->order_qual[pos].
   perf_loc_disp = trim(od.oe_field_display_value,3),
   request_hold->order_qual[pos].ref_lab = trim(cnvtupper(cvo2.alias),3), request_hold->order_qual[
   pos].contrib_source_cd = cvo2.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   order_detail od
  PLAN (o
   WHERE expand(index,1,order_count,o.order_id,request_hold->order_qual[index].order_id))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND expand(num,1,ord_det_alias->codev_cnt,od.oe_field_id,ord_det_alias->qual[num].code_value,
    "CLIENTBILL",ord_det_alias->qual[num].display)
    AND (od.action_sequence=
   (SELECT
    max(od_s.action_sequence)
    FROM order_detail od_s
    WHERE od_s.order_id=od.order_id
     AND expand(num,1,ord_det_alias->codev_cnt,od_s.oe_field_id,ord_det_alias->qual[num].code_value,
     "CLIENTBILL",ord_det_alias->qual[num].display))))
  ORDER BY o.order_id
  HEAD o.order_id
   pos = locateval(index,1,order_count,o.order_id,request_hold->order_qual[index].order_id)
   IF (pos > 0)
    request_hold->order_qual[index].client_bill = od.oe_field_value
   ENDIF
  WITH nocounter
 ;end select
 IF ((req_data->encntr_id != 0.00))
  SELECT INTO "nl:"
   FROM encntr_alias ea
   PLAN (ea
    WHERE (ea.encntr_id=req_data->encntr_id)
     AND ea.encntr_alias_type_cd IN (319_mrn, 319_fin_nbr)
     AND ea.active_ind=1
     AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND ea.end_effective_dt_tm > cnvtdatetime(sysdate))
   DETAIL
    IF (ea.encntr_alias_type_cd=319_mrn)
     req_data->mrn = concat(req_data->mrn,",",trim(ea.alias,3)), req_data->cdf_meaning_mrn = "MRN:"
    ELSE
     req_data->fin = trim(ea.alias,3), req_data->raw_fin = ea.alias
    ENDIF
   FOOT REPORT
    req_data->mrn = trim(replace(req_data->mrn,",","",1),3), req_data->mrn = replace(req_data->mrn,
     ",",", ")
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM encntr_alias ea,
    orders o
   PLAN (o
    WHERE (o.order_id=request_hold->order_qual[1].order_id))
    JOIN (ea
    WHERE ea.encntr_id=o.originating_encntr_id
     AND ea.encntr_alias_type_cd=319_mrn
     AND ea.active_ind=1
     AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND ea.end_effective_dt_tm > cnvtdatetime(sysdate))
   DETAIL
    req_data->mrn = trim(ea.alias,3), req_data->cdf_meaning_mrn = "MRN:"
   WITH nocounter
  ;end select
 ENDIF
 IF (4_altmrn > 0
  AND 263_altmrn_alias > 0)
  SELECT INTO "nl:"
   FROM person_alias pa
   PLAN (pa
    WHERE (pa.person_id=req_data->person_id)
     AND pa.person_alias_type_cd=4_altmrn
     AND pa.alias_pool_cd=263_altmrn_alias
     AND pa.active_ind=1
     AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND pa.end_effective_dt_tm > cnvtdatetime(sysdate))
   DETAIL
    req_data->mrn = trim(pa.alias,3), req_data->cdf_meaning_mrn = build2(alt_mrn_desc,":")
   WITH nocounter
  ;end select
 ENDIF
 IF ((req_data->encntr_id != 0.0))
  SELECT INTO "nl:"
   FROM order_action oa
   PLAN (oa
    WHERE (oa.order_id=request->order_qual[1].order_id)
     AND oa.order_status_cd=6004_ordered
     AND (oa.action_sequence=
    (SELECT
     min(oa_s.action_sequence)
     FROM order_action oa_s
     WHERE oa_s.order_id=oa.order_id
      AND oa_s.order_status_cd=6004_ordered
      AND oa_s.dept_status_cd=14281_dispatched)))
   HEAD REPORT
    conv_id_digits = substring((size(trim(cnvtstring(oa.order_conversation_id),3),1) - 4),5,trim(
      cnvtstring(oa.order_conversation_id),3)), conv_id_full = trim(cnvtstring(oa
      .order_conversation_id),3), order_dt_tm = oa.action_dt_tm
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM order_action oa
   PLAN (oa
    WHERE (oa.order_id=request->order_qual[1].order_id)
     AND oa.action_type_cd=6003_order
     AND (oa.action_sequence=
    (SELECT
     min(oa_s.action_sequence)
     FROM order_action oa_s
     WHERE oa_s.order_id=oa.order_id
      AND oa_s.action_type_cd=6003_order)))
   HEAD REPORT
    order_dt_tm = oa.action_dt_tm, conv_id_full = trim(cnvtstring(oa.order_conversation_id),3)
   WITH nocounter
  ;end select
 ENDIF
 CALL echo("++++++++SPLIT REQUISITIONS++++++++")
 SELECT
  IF ((request->print_prsnl_id > 0))
   PLAN (d
    WHERE (request_hold->order_qual[d.seq].order_id > 0.00))
    JOIN (o
    WHERE (o.order_id=request_hold->order_qual[d.seq].order_id)
     AND  NOT (o.template_order_flag IN (protocol_orderflag, template_orderflag)))
    JOIN (oa
    WHERE oa.order_id=o.order_id
     AND oa.action_sequence=o.last_action_sequence)
    JOIN (ocr
    WHERE ocr.order_id=outerjoin(oa.order_id))
    JOIN (c
    WHERE c.container_id=outerjoin(ocr.container_id))
    JOIN (cc
    WHERE cc.coll_class_cd=outerjoin(c.coll_class_cd))
    JOIN (ct_e
    WHERE ct_e.container_id=outerjoin(c.container_id)
     AND ct_e.event_type_cd=outerjoin(2061_collected_event_type_cd))
    JOIN (coll
    WHERE coll.order_id=o.order_id
     AND expand(num,1,ord_det_alias->codev_cnt,coll.oe_field_id,ord_det_alias->qual[num].code_value,
     "NURSECOLL",ord_det_alias->qual[num].display)
     AND (coll.action_sequence=
    (SELECT
     max(od_s.action_sequence)
     FROM order_detail od_s
     WHERE od_s.order_id=coll.order_id
      AND expand(num,1,ord_det_alias->codev_cnt,od_s.oe_field_id,ord_det_alias->qual[num].code_value,
      "NURSECOLL",ord_det_alias->qual[num].display))))
  ELSE
   PLAN (d
    WHERE (request_hold->order_qual[d.seq].order_id > 0.00))
    JOIN (o
    WHERE (o.order_id=request_hold->order_qual[d.seq].order_id)
     AND  NOT (o.template_order_flag IN (protocol_orderflag, template_orderflag)))
    JOIN (oa
    WHERE oa.order_id=o.order_id
     AND oa.action_sequence=o.last_action_sequence
     AND oa.action_type_cd IN (6003_activate, 6003_order))
    JOIN (ocr
    WHERE ocr.order_id=outerjoin(oa.order_id))
    JOIN (c
    WHERE c.container_id=outerjoin(ocr.container_id))
    JOIN (cc
    WHERE cc.coll_class_cd=outerjoin(c.coll_class_cd))
    JOIN (ct_e
    WHERE ct_e.container_id=outerjoin(c.container_id)
     AND ct_e.event_type_cd=outerjoin(2061_collected_event_type_cd))
    JOIN (coll
    WHERE coll.order_id=o.order_id
     AND expand(num,1,ord_det_alias->codev_cnt,coll.oe_field_id,ord_det_alias->qual[num].code_value,
     "NURSECOLL",ord_det_alias->qual[num].display)
     AND (coll.action_sequence=
    (SELECT
     max(od_s.action_sequence)
     FROM order_detail od_s
     WHERE od_s.order_id=coll.order_id
      AND expand(num,1,ord_det_alias->codev_cnt,od_s.oe_field_id,ord_det_alias->qual[num].code_value,
      "NURSECOLL",ord_det_alias->qual[num].display))))
  ENDIF
  INTO "nl:"
  ref_lab =
  IF (size(request_hold->order_qual[d.seq].ref_lab)=0) in_house_lab
  ELSE request_hold->order_qual[d.seq].perf_loc_cd
  ENDIF
  , coll_class_flag = request_hold->order_qual[d.seq].coll_class_flag, coll_class_alias = substring(1,
   100,request_hold->order_qual[d.seq].coll_class_alias),
  nurse_collect = coll.oe_field_value, client_bill = request_hold->order_qual[d.seq].client_bill
  FROM (dummyt d  WITH seq = value(order_count)),
   orders o,
   order_container_r ocr,
   container c,
   order_action oa,
   collection_class cc,
   order_detail coll,
   container_event ct_e
  ORDER BY ref_lab, nurse_collect, client_bill,
   coll_class_alias, o.order_id
  HEAD REPORT
   req_cnt = 0
  HEAD ref_lab
   IF ((request_hold->order_qual[d.seq].ref_lab="QUEST"))
    max_orders_per_req = 35, contrib_src_cd = request_hold->order_qual[d.seq].contrib_source_cd,
    req_type_ind = 1
   ELSEIF ((request_hold->order_qual[d.seq].ref_lab="LABCORP"))
    max_orders_per_req = 40, contrib_src_cd = request_hold->order_qual[d.seq].contrib_source_cd,
    req_type_ind = 2
   ELSEIF (size(request_hold->order_qual[d.seq].ref_lab) > 0)
    max_orders_per_req = 35, contrib_src_cd = request_hold->order_qual[d.seq].contrib_source_cd,
    req_type_ind = 3
   ELSE
    max_orders_per_req = 35, contrib_src_cd = 0, req_type_ind = 3
   ENDIF
  HEAD nurse_collect
   null
  HEAD client_bill
   null
  HEAD coll_class_alias
   col_req_cnt = 1, req_cnt = (req_cnt+ 1)
   IF (mod(req_cnt,5)=1)
    stat = alterlist(req_data->req_qual,(req_cnt+ 4))
   ENDIF
   req_data->req_qual[req_cnt].collected_ind = coll.oe_field_value, req_data->req_qual[req_cnt].
   client_bill_ind = client_bill, req_data->req_qual[req_cnt].order_provider.id = oa
   .order_provider_id,
   req_data->req_qual[req_cnt].sup_physician.id = oa.supervising_provider_id, req_data->req_qual[
   req_cnt].coll_class_cd = c.coll_class_cd, req_data->req_qual[req_cnt].transfer_temp_cd = cc
   .transfer_temp_cd,
   req_data->req_qual[req_cnt].contrib_src_cd = contrib_src_cd, req_data->req_qual[req_cnt].ref_lab
    = ref_lab, req_data->req_qual[req_cnt].req_type_ind = req_type_ind
   IF (nurse_collect=0)
    CASE (coll_class_flag)
     OF 1:
      IF (client_bill=1)
       IF (ord_conv_ind=1)
        req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"APL","C")
       ELSE
        req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"APL",conv_id_digits,
         "C")
       ENDIF
      ELSE
       IF (ord_conv_ind=1)
        req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"APL")
       ELSE
        req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"APL",conv_id_digits)
       ENDIF
      ENDIF
     OF 3:
      IF (client_bill=1)
       IF (ord_conv_ind=1)
        req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"L","C")
       ELSE
        req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"L",conv_id_digits,"C"
         )
       ENDIF
      ELSE
       IF (ord_conv_ind=1)
        req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"L")
       ELSE
        req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"L",conv_id_digits)
       ENDIF
      ENDIF
     OF 4:
      IF (client_bill=1)
       IF (ord_conv_ind=1)
        req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,trim(coll_class_alias,3),
         "L","C")
       ELSE
        req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,trim(coll_class_alias,
          3),"L",conv_id_digits,"C")
       ENDIF
      ELSE
       IF (ord_conv_ind=1)
        req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,trim(coll_class_alias,3),
         "L")
       ELSE
        req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,trim(coll_class_alias,
          3),"L",conv_id_digits)
       ENDIF
      ENDIF
     ELSE
      IF (o.encntr_id != 0)
       IF (client_bill=1)
        IF (ord_conv_ind=1)
         req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"UNK","L","C")
        ELSE
         req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"UNK","L",
          conv_id_digits,"C")
        ENDIF
       ELSE
        IF (ord_conv_ind=1)
         req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"UNK","L")
        ELSE
         req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"UNK","L",
          conv_id_digits)
        ENDIF
       ENDIF
      ELSE
       req_data->req_qual[req_cnt].req_control_nbr = "FUTUREORDER"
      ENDIF
    ENDCASE
   ELSE
    CASE (coll_class_flag)
     OF 1:
      IF (client_bill=1)
       IF (ord_conv_ind=1)
        req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"AP","C")
       ELSE
        req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"AP",conv_id_digits,
         "C")
       ENDIF
      ELSE
       IF (ord_conv_ind=1)
        req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"AP")
       ELSE
        req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"AP",conv_id_digits)
       ENDIF
      ENDIF
     OF 2:
      IF (client_bill=1)
       IF (ord_conv_ind=1)
        req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"FR","C")
       ELSE
        req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"FR",conv_id_digits,
         "C")
       ENDIF
      ELSE
       IF (ord_conv_ind=1)
        req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"FR")
       ELSE
        req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"FR",conv_id_digits)
       ENDIF
      ENDIF
     OF 3:
      IF (client_bill=1)
       IF (ord_conv_ind=1)
        req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"RR","C")
       ELSE
        req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"RR",conv_id_digits,
         "C")
       ENDIF
      ELSE
       IF (ord_conv_ind=1)
        req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"RR")
       ELSE
        req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"RR",conv_id_digits)
       ENDIF
      ENDIF
     OF 4:
     OF 5:
      IF (client_bill=1)
       IF (ord_conv_ind=1)
        req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,trim(coll_class_alias,3),
         "C")
       ELSE
        req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,trim(coll_class_alias,
          3),conv_id_digits,"C")
       ENDIF
      ELSE
       IF (ord_conv_ind=1)
        req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,trim(coll_class_alias,3))
       ELSE
        req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,trim(coll_class_alias,
          3),conv_id_digits)
       ENDIF
      ENDIF
     ELSE
      IF (o.encntr_id != 0)
       IF (client_bill=1)
        IF (ord_conv_ind=1)
         req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"UNK","C")
        ELSE
         req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"UNK",conv_id_digits,
          "C")
        ENDIF
       ELSE
        IF (ord_conv_ind=1)
         req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"UNK")
        ELSE
         req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"UNK",conv_id_digits)
        ENDIF
       ENDIF
      ELSE
       req_data->req_qual[req_cnt].req_control_nbr = "FUTUREORDER"
      ENDIF
    ENDCASE
   ENDIF
   ord_cnt = 0
  HEAD o.order_id
   ord_cnt = (ord_cnt+ 1)
   IF (ord_cnt > max_orders_per_req)
    stat = alterlist(req_data->req_qual[req_cnt].ord_qual,max_orders_per_req), req_data->req_qual[
    req_cnt].ord_cnt = max_orders_per_req, req_cnt = (req_cnt+ 1)
    IF (mod(req_cnt,5)=1)
     stat = alterlist(req_data->req_qual,(req_cnt+ 4))
    ENDIF
    col_req_cnt = (col_req_cnt+ 1), req_data->req_qual[req_cnt].collected_ind = coll.oe_field_value,
    req_data->req_qual[req_cnt].order_provider.id = oa.order_provider_id,
    req_data->req_qual[req_cnt].sup_physician.id = oa.supervising_provider_id, req_data->req_qual[
    req_cnt].coll_class_cd = c.coll_class_cd, req_data->req_qual[req_cnt].transfer_temp_cd = cc
    .transfer_temp_cd,
    req_data->req_qual[req_cnt].contrib_src_cd = contrib_src_cd, req_data->req_qual[req_cnt].ref_lab
     = ref_lab, req_data->req_qual[req_cnt].req_type_ind = req_type_ind
    IF (nurse_collect=0)
     CASE (coll_class_flag)
      OF 1:
       IF (client_bill=1)
        IF (ord_conv_ind=1)
         req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"APL","C")
        ELSE
         req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"APL",conv_id_digits,
          "C")
        ENDIF
       ELSE
        IF (ord_conv_ind=1)
         req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"APL")
        ELSE
         req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"APL",conv_id_digits)
        ENDIF
       ENDIF
      OF 3:
       IF (client_bill=1)
        IF (ord_conv_ind=1)
         req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"L","C")
        ELSE
         req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"L",conv_id_digits,
          "C")
        ENDIF
       ELSE
        IF (ord_conv_ind=1)
         req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"L")
        ELSE
         req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"L",conv_id_digits)
        ENDIF
       ENDIF
      OF 4:
       IF (client_bill=1)
        IF (ord_conv_ind=1)
         req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,trim(coll_class_alias,3),
          "L","C")
        ELSE
         req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,trim(coll_class_alias,
           3),"L",conv_id_digits,"C")
        ENDIF
       ELSE
        IF (ord_conv_ind=1)
         req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,trim(coll_class_alias,3),
          "L")
        ELSE
         req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,trim(coll_class_alias,
           3),"L",conv_id_digits)
        ENDIF
       ENDIF
      ELSE
       IF (o.encntr_id != 0)
        IF (client_bill=1)
         IF (ord_conv_ind=1)
          req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"L","C")
         ELSE
          req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"L",conv_id_digits,
           "C")
         ENDIF
        ELSE
         IF (ord_conv_ind=1)
          req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"L")
         ELSE
          req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"L",conv_id_digits)
         ENDIF
        ENDIF
       ELSE
        req_data->req_qual[req_cnt].req_control_nbr = "FUTUREORDER"
       ENDIF
     ENDCASE
    ELSE
     CASE (coll_class_flag)
      OF 1:
       IF (client_bill=1)
        IF (ord_conv_ind=1)
         req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"AP","C")
        ELSE
         req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"AP",conv_id_digits,
          "C")
        ENDIF
       ELSE
        IF (ord_conv_ind=1)
         req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"AP")
        ELSE
         req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"AP",conv_id_digits)
        ENDIF
       ENDIF
      OF 2:
       IF (client_bill=1)
        IF (ord_conv_ind=1)
         req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"FR","C")
        ELSE
         req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"FR",conv_id_digits,
          "C")
        ENDIF
       ELSE
        IF (ord_conv_ind=1)
         req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"FR")
        ELSE
         req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"FR",conv_id_digits)
        ENDIF
       ENDIF
      OF 3:
       IF (client_bill=1)
        IF (ord_conv_ind=1)
         req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"RR","C")
        ELSE
         req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"RR",conv_id_digits,
          "C")
        ENDIF
       ELSE
        IF (ord_conv_ind=1)
         req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"RR")
        ELSE
         req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"RR",conv_id_digits)
        ENDIF
       ENDIF
      OF 4:
      OF 5:
       IF (client_bill=1)
        IF (ord_conv_ind=1)
         req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,trim(coll_class_alias,3),
          "C")
        ELSE
         req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,trim(coll_class_alias,
           3),conv_id_digits,"C")
        ENDIF
       ELSE
        IF (ord_conv_ind=1)
         req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,trim(coll_class_alias,3))
        ELSE
         req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,trim(coll_class_alias,
           3),conv_id_digits)
        ENDIF
       ENDIF
      ELSE
       IF (o.encntr_id != 0)
        IF (client_bill=1)
         IF (ord_conv_ind=1)
          req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"UNK","C")
         ELSE
          req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"UNK",conv_id_digits,
           "C")
         ENDIF
        ELSE
         IF (ord_conv_ind=1)
          req_data->req_qual[req_cnt].req_control_nbr = concat(conv_id_full,"UNK")
         ELSE
          req_data->req_qual[req_cnt].req_control_nbr = concat(req_data->raw_fin,"UNK",conv_id_digits
           )
         ENDIF
        ENDIF
       ELSE
        req_data->req_qual[req_cnt].req_control_nbr = "FUTUREORDER"
       ENDIF
     ENDCASE
    ENDIF
    ord_cnt = 1
   ENDIF
   IF (mod(ord_cnt,5)=1)
    stat = alterlist(req_data->req_qual[req_cnt].ord_qual,(ord_cnt+ 4))
   ENDIF
   req_data->req_qual[req_cnt].ord_qual[ord_cnt].order_id = o.order_id, req_data->req_qual[req_cnt].
   ord_qual[ord_cnt].perf_loc_cd = request_hold->order_qual[d.seq].perf_loc_cd, req_data->req_qual[
   req_cnt].ord_qual[ord_cnt].perf_loc_disp = request_hold->order_qual[d.seq].perf_loc_disp,
   req_data->req_qual[req_cnt].ord_qual[ord_cnt].hna_order_mnemonic = o.hna_order_mnemonic, req_data
   ->req_qual[req_cnt].ord_qual[ord_cnt].ordered_as_mnemonic = o.ordered_as_mnemonic, req_data->
   req_qual[req_cnt].ord_qual[ord_cnt].oe_format_id = o.oe_format_id,
   req_data->req_qual[req_cnt].ord_qual[ord_cnt].catalog_cd = o.catalog_cd, req_data->req_qual[
   req_cnt].ord_qual[ord_cnt].order_status_cd = o.order_status_cd, req_data->req_qual[req_cnt].
   ord_qual[ord_cnt].container_id = c.container_id,
   req_data->req_qual[req_cnt].ord_qual[ord_cnt].cntnr_units = trim(uar_get_code_display(c.units_cd)),
   req_data->req_qual[req_cnt].ord_qual[ord_cnt].order_status = concat(trim(uar_get_code_display(o
      .order_status_cd),3)," (",trim(uar_get_code_description(o.dept_status_cd),3),")"), req_data->
   req_qual[req_cnt].ord_qual[ord_cnt].nurse_collect = nurse_collect,
   req_data->req_qual[req_cnt].ord_qual[ord_cnt].client_bill = client_bill, req_data->req_qual[
   req_cnt].ord_qual[ord_cnt].drawn_dt_tm = ct_e.drawn_dt_tm
   IF (((o.order_status_cd=6004_future) OR (o.order_status_cd=6004_future
    AND (req_data->reprint_ind=1))) )
    req_data->req_qual[req_cnt].ord_qual[ord_cnt].future_ind = 1
   ENDIF
  DETAIL
   null
  FOOT  o.order_id
   null
  FOOT  coll_class_alias
   req_data->req_qual[req_cnt].ord_cnt = ord_cnt, stat = alterlist(req_data->req_qual[req_cnt].
    ord_qual,ord_cnt)
  FOOT REPORT
   req_data->req_cnt = req_cnt, stat = alterlist(req_data->req_qual,req_cnt)
  WITH nocounter
 ;end select
 CALL echo("++++++++GET REQUISITION DATA++++++++")
 DECLARE 222_building_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!2843")), protect
 DECLARE 222_nurse_unit_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!2845")), protect
 DECLARE 222_facility_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!2844")), protect
 DECLARE phone_parent_entity_id = vc WITH noconstant(""), protect
 DECLARE address_parent_entity_id = vc WITH noconstant(""), protect
 IF ((req_data->encntr_id != 0.00))
  IF (loc_alias="ORG")
   SELECT INTO "nl:"
    FROM encounter e,
     organization o
    PLAN (e
     WHERE (e.encntr_id=req_data->encntr_id))
     JOIN (o
     WHERE o.organization_id=e.organization_id)
    DETAIL
     req_data->visit_dt_tm = e.arrive_dt_tm, req_data->loc_nurse_unit_cd = e.loc_nurse_unit_cd,
     req_data->financial_class_cd = e.financial_class_cd,
     req_data->guarantor_type_cd = e.guarantor_type_cd
     IF (e.financial_class_cd=354_workerscompensation)
      req_data->workers_comp = "Yes"
     ELSE
      req_data->workers_comp = "No"
     ENDIF
     req_data->organization.org_id = e.organization_id, req_data->organization.org_name = o.org_name
    WITH nocounter
   ;end select
  ELSEIF (loc_alias IN ("BLD", "FAC", "NU"))
   SELECT INTO "nl:"
    FROM encounter e
    PLAN (e
     WHERE (e.encntr_id=req_data->encntr_id))
    ORDER BY e.encntr_id
    HEAD e.encntr_id
     req_data->visit_dt_tm = e.arrive_dt_tm, req_data->loc_nurse_unit_cd = e.loc_nurse_unit_cd,
     req_data->financial_class_cd = e.financial_class_cd,
     req_data->guarantor_type_cd = e.guarantor_type_cd
     IF (e.financial_class_cd=354_workerscompensation)
      req_data->workers_comp = "Yes"
     ELSE
      req_data->workers_comp = "No"
     ENDIF
     CASE (loc_alias)
      OF "BLD":
       req_data->organization.org_id = e.loc_building_cd,req_data->organization.org_name =
       uar_get_code_description(e.loc_building_cd)
      OF "NU":
       req_data->organization.org_id = e.loc_nurse_unit_cd,req_data->organization.org_name =
       uar_get_code_description(e.loc_nurse_unit_cd)
      OF "FAC":
       req_data->organization.org_id = e.loc_facility_cd,req_data->organization.org_name =
       uar_get_code_description(e.loc_facility_cd)
     ENDCASE
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  IF (loc_alias="ORG")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = 1),
     orders o,
     location l,
     organization org
    PLAN (d)
     JOIN (o
     WHERE (o.order_id=request->order_qual[1].order_id))
     JOIN (l
     WHERE l.location_cd=o.future_location_facility_cd
      AND l.active_ind=1)
     JOIN (org
     WHERE org.organization_id=l.organization_id)
    DETAIL
     req_data->loc_nurse_unit_cd = o.future_location_nurse_unit_cd, req_data->organization.org_id =
     org.organization_id, req_data->organization.org_name = org.org_name
    WITH nocounter
   ;end select
  ELSEIF (loc_alias IN ("NU", "FAC", "BLD"))
   IF (loc_alias IN ("FAC", "NU"))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = 1),
      orders o,
      location l
     PLAN (d)
      JOIN (o
      WHERE (o.order_id=request->order_qual[1].order_id))
      JOIN (l
      WHERE l.location_cd=o.future_location_facility_cd
       AND l.active_ind=1)
     ORDER BY o.order_id
     HEAD o.order_id
      req_data->loc_nurse_unit_cd = o.future_location_nurse_unit_cd
      IF (loc_alias="FAC")
       req_data->organization.org_name = uar_get_code_description(o.future_location_facility_cd),
       req_data->organization.org_id = o.future_location_facility_cd
      ELSEIF (loc_alias="NU")
       req_data->organization.org_name = uar_get_code_description(o.future_location_nurse_unit_cd),
       req_data->organization.org_id = o.future_location_nurse_unit_cd
      ENDIF
     WITH nocounter
    ;end select
   ELSEIF (loc_alias="BLD")
    SELECT INTO "nl:"
     FROM location_group lg
     PLAN (lg
      WHERE (lg.child_loc_cd=req_data->loc_nurse_unit_cd)
       AND lg.active_ind=1
       AND lg.root_loc_cd=0.0)
     ORDER BY lg.child_loc_cd
     HEAD lg.child_loc_cd
      IF (uar_get_code_meaning(lg.parent_loc_cd)="BUILDING")
       req_data->organization.org_name = uar_get_code_description(lg.parent_loc_cd), req_data->
       organization.org_id = lg.parent_loc_cd
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDIF
 IF (loc_alias="ORG")
  SET parent_entity_name_address_parser = "a.parent_entity_name  =  'ORGANIZATION'"
  SET parent_entity_name_phone_parser = "p.parent_entity_name  =  'ORGANIZATION'"
 ELSE
  SET parent_entity_name_address_parser = "a.parent_entity_name  =  'LOCATION'"
  SET parent_entity_name_phone_parser = "p.parent_entity_name  =  'LOCATION'"
 ENDIF
 SELECT INTO "nl:"
  FROM address a
  PLAN (a
   WHERE (a.parent_entity_id=req_data->organization.org_id)
    AND a.address_type_cd=212_business
    AND parser(parent_entity_name_address_parser)
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND a.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY a.parent_entity_id, a.address_type_seq
  HEAD a.parent_entity_id
   type_seq_gr_zero = false
  HEAD a.address_type_seq
   IF (type_seq_gr_zero=false)
    req_data->organization.street_addr = a.street_addr, req_data->organization.street_addr2 = a
    .street_addr2, req_data->organization.city = a.city,
    req_data->organization.state = evaluate(a.state_cd,0.0,a.state,uar_get_code_display(a.state_cd)),
    req_data->organization.zipcode = a.zipcode
    IF (a.address_type_seq > 0)
     type_seq_gr_zero = true
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM phone p
  PLAN (p
   WHERE (p.parent_entity_id=req_data->organization.org_id)
    AND p.phone_type_cd IN (43_business, 43_fax_bus)
    AND parser(parent_entity_name_phone_parser)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY p.parent_entity_id, p.phone_type_seq
  HEAD p.parent_entity_id
   phone = " ", phone_format_cd = 0.00, fax = " ",
   fax_format_cd = 0.00, ph_type_seq_bus_gr_zero = false, ph_type_seq_fax_gr_zero = false
  HEAD p.phone_type_cd
   CASE (p.phone_type_cd)
    OF 43_business:
     IF (ph_type_seq_bus_gr_zero=false)
      phone = p.phone_num, phone_format_cd = p.phone_format_cd
      IF (p.phone_type_seq > 0)
       ph_type_seq_bus_gr_zero = true
      ENDIF
     ENDIF
    OF 43_fax_bus:
     IF (ph_type_seq_fax_gr_zero=false)
      fax = p.phone_num, fax_format_cd = p.phone_format_cd
      IF (p.phone_type_seq > 0)
       ph_type_seq_fax_gr_zero = true
      ENDIF
     ENDIF
   ENDCASE
  FOOT  p.parent_entity_id
   req_data->organization.phone_num = phone, req_data->organization.phone_format_cd = phone_format_cd,
   req_data->organization.fax_num = fax,
   req_data->organization.fax_format_cd = fax_format_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_data->req_cnt)),
   code_value_outbound cvo
  PLAN (d)
   JOIN (cvo
   WHERE (cvo.contributor_source_cd=req_data->req_qual[d.seq].contrib_src_cd)
    AND (cvo.code_value=req_data->loc_nurse_unit_cd)
    AND cvo.alias_type_meaning IN ("AMBULATORY", "NURSEUNIT")
    AND cvo.code_set=220)
  ORDER BY d.seq
  HEAD d.seq
   req_data->req_qual[d.seq].loc_nurse_unit_alias = cvo.alias
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person_alias pa
  PLAN (pa
   WHERE (pa.person_id=req_data->person_id)
    AND pa.person_alias_type_cd=4_ssn
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate))
  DETAIL
   req_data->ssn = format(substring(6,4,pa.alias),"XXX-XX-####"), req_data->ssn_barcode = format(pa
    .alias,"#########;p0")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person p,
   address a,
   phone pn
  PLAN (p
   WHERE (p.person_id=req_data->person_id))
   JOIN (a
   WHERE a.parent_entity_id=outerjoin(p.person_id)
    AND a.parent_entity_name=outerjoin("PERSON")
    AND a.address_type_cd=outerjoin(212_home)
    AND a.active_ind=outerjoin(1)
    AND a.beg_effective_dt_tm <= outerjoin(cnvtdatetime(sysdate))
    AND a.end_effective_dt_tm > outerjoin(cnvtdatetime(sysdate)))
   JOIN (pn
   WHERE pn.parent_entity_id=outerjoin(p.person_id)
    AND pn.parent_entity_name=outerjoin("PERSON")
    AND pn.phone_type_cd=outerjoin(43_home)
    AND pn.active_ind=outerjoin(1)
    AND pn.beg_effective_dt_tm <= outerjoin(cnvtdatetime(sysdate))
    AND pn.end_effective_dt_tm > outerjoin(cnvtdatetime(sysdate)))
  ORDER BY a.address_type_seq, pn.phone_type_seq
  HEAD REPORT
   req_data->name_full_formatted = p.name_full_formatted, req_data->name.first = p.name_first,
   req_data->name.last = p.name_last,
   req_data->name.middle = p.name_middle, req_data->sex_cd = p.sex_cd, req_data->race_cd = p.race_cd,
   req_data->birth_dt_tm = p.birth_dt_tm, req_data->birth_tz = p.birth_tz, req_data->address.
   street_addr = a.street_addr,
   req_data->address.street_addr2 = a.street_addr2, req_data->address.city = a.city, req_data->
   address.state = evaluate(a.state_cd,0.0,a.state,uar_get_code_display(a.state_cd)),
   req_data->address.zipcode = a.zipcode, req_data->phone.number = pn.phone_num, req_data->phone.
   format_cd = pn.phone_format_cd
   IF (a.address_type_seq=0)
    add_type_seq_gr_zero = false
   ELSE
    add_type_seq_gr_zero = true
   ENDIF
   IF (pn.phone_type_seq=0)
    ph_type_seq_gr_zero = false
   ELSE
    ph_type_seq_gr_zero = true
   ENDIF
  DETAIL
   IF (a.address_type_seq > 0
    AND add_type_seq_gr_zero=false)
    req_data->address.street_addr = a.street_addr, req_data->address.street_addr2 = a.street_addr2,
    req_data->address.city = a.city,
    req_data->address.state = evaluate(a.state_cd,0.0,a.state,uar_get_code_display(a.state_cd)),
    req_data->address.zipcode = a.zipcode, add_type_seq_gr_zero = true
   ENDIF
   IF (pn.phone_type_seq > 0
    AND ph_type_seq_gr_zero=false)
    req_data->phone.number = pn.phone_num, req_data->phone.format_cd = pn.phone_format_cd,
    ph_type_seq_gr_zero = true
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person_name pn,
   prsnl_alias npi,
   prsnl_alias upin,
   prsnl_alias ext
  PLAN (pn
   WHERE expand(index,1,req_data->req_cnt,pn.person_id,req_data->req_qual[index].order_provider.id)
    AND pn.name_type_cd=213_prsnl
    AND pn.name_type_seq=1
    AND pn.active_ind=1
    AND pn.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pn.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (npi
   WHERE npi.person_id=outerjoin(pn.person_id)
    AND npi.prsnl_alias_type_cd=outerjoin(320_npi)
    AND npi.active_ind=outerjoin(1)
    AND npi.beg_effective_dt_tm <= outerjoin(cnvtdatetime(sysdate))
    AND npi.end_effective_dt_tm > outerjoin(cnvtdatetime(sysdate)))
   JOIN (upin
   WHERE upin.person_id=outerjoin(pn.person_id)
    AND upin.prsnl_alias_type_cd=outerjoin(320_docupin)
    AND upin.active_ind=outerjoin(1)
    AND upin.beg_effective_dt_tm <= outerjoin(cnvtdatetime(sysdate))
    AND upin.end_effective_dt_tm > outerjoin(cnvtdatetime(sysdate)))
   JOIN (ext
   WHERE ext.person_id=outerjoin(pn.person_id)
    AND ext.prsnl_alias_type_cd=outerjoin(320_externalid)
    AND ext.active_ind=outerjoin(1)
    AND ext.beg_effective_dt_tm <= outerjoin(cnvtdatetime(sysdate))
    AND ext.end_effective_dt_tm > outerjoin(cnvtdatetime(sysdate)))
  ORDER BY pn.person_id
  DETAIL
   loc = locateval(index,1,req_data->req_cnt,pn.person_id,req_data->req_qual[index].order_provider.id
    )
   WHILE (loc > 0)
     req_data->req_qual[loc].order_provider.name_full = pn.name_full, req_data->req_qual[loc].
     order_provider.name_first = pn.name_first, req_data->req_qual[loc].order_provider.name_last = pn
     .name_last,
     req_data->req_qual[loc].order_provider.name_middle = pn.name_middle, req_data->req_qual[loc].
     order_provider.name_title = pn.name_title, req_data->req_qual[loc].order_provider.npi =
     cnvtalias(npi.alias,npi.alias_pool_cd),
     req_data->req_qual[loc].order_provider.docupin = cnvtalias(upin.alias,upin.alias_pool_cd),
     req_data->req_qual[loc].order_provider.external_id = cnvtalias(ext.alias,ext.alias_pool_cd), loc
      = locateval(index,(loc+ 1),req_data->req_cnt,pn.person_id,req_data->req_qual[index].
      order_provider.id)
   ENDWHILE
  WITH expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM address a
  PLAN (a
   WHERE expand(index,1,req_data->req_cnt,a.parent_entity_id,req_data->req_qual[index].order_provider
    .id)
    AND a.parent_entity_name="PERSON"
    AND a.address_type_cd=212_business
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND a.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY a.parent_entity_id, a.address_type_seq
  HEAD a.parent_entity_id
   add_type_seq_gr_zero = false
  DETAIL
   IF (((a.address_type_seq=0) OR (a.address_type_seq > 0
    AND add_type_seq_gr_zero=false)) )
    loc = locateval(index,1,req_data->req_cnt,a.parent_entity_id,req_data->req_qual[index].
     order_provider.id)
    WHILE (loc > 0)
      req_data->req_qual[loc].order_provider.address.street_addr = a.street_addr, req_data->req_qual[
      loc].order_provider.address.city = a.city, req_data->req_qual[loc].order_provider.address.state
       = evaluate(a.state_cd,0.0,a.state,uar_get_code_display(a.state_cd)),
      req_data->req_qual[loc].order_provider.address.zipcode = a.zipcode, loc = locateval(index,(loc
       + 1),req_data->req_cnt,a.parent_entity_id,req_data->req_qual[index].order_provider.id)
    ENDWHILE
    IF (a.address_type_seq > 0)
     add_type_seq_gr_zero = true
    ENDIF
   ENDIF
  WITH expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM phone p
  PLAN (p
   WHERE expand(index,1,req_data->req_cnt,p.parent_entity_id,req_data->req_qual[index].order_provider
    .id)
    AND p.parent_entity_name="PERSON"
    AND p.phone_type_cd=43_business
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY p.parent_entity_id, p.phone_type_seq
  HEAD p.parent_entity_id
   ph_type_seq_gr_zero = false
  DETAIL
   IF (ph_type_seq_gr_zero=false)
    loc = locateval(index,1,req_data->req_cnt,p.parent_entity_id,req_data->req_qual[index].
     order_provider.id)
    WHILE (loc > 0)
      req_data->req_qual[loc].order_provider.phone.number = p.phone_num, req_data->req_qual[loc].
      order_provider.phone.format_cd = p.phone_format_cd, loc = locateval(index,(loc+ 1),req_data->
       req_cnt,p.parent_entity_id,req_data->req_qual[index].order_provider.id)
    ENDWHILE
    IF (p.phone_type_seq > 0)
     ph_type_seq_gr_zero = true
    ENDIF
   ENDIF
  WITH expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM phone p
  PLAN (p
   WHERE expand(index,1,req_data->req_cnt,p.parent_entity_id,req_data->req_qual[index].order_provider
    .id)
    AND p.parent_entity_name="PERSON"
    AND p.phone_type_cd=43_fax_bus
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY p.parent_entity_id, p.phone_type_seq
  HEAD p.parent_entity_id
   ph_type_seq_gr_zero = false
  DETAIL
   IF (ph_type_seq_gr_zero=false)
    loc = locateval(index,1,req_data->req_cnt,p.parent_entity_id,req_data->req_qual[index].
     order_provider.id)
    WHILE (loc > 0)
      req_data->req_qual[loc].order_provider.fax.number = p.phone_num, req_data->req_qual[loc].
      order_provider.fax.format_cd = p.phone_format_cd, loc = locateval(index,(loc+ 1),req_data->
       req_cnt,p.parent_entity_id,req_data->req_qual[index].order_provider.id)
    ENDWHILE
    IF (p.phone_type_seq > 0)
     ph_type_seq_gr_zero = true
    ENDIF
   ENDIF
  WITH expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM person_name pn,
   prsnl_alias npi,
   prsnl_alias upin,
   prsnl_alias ext
  PLAN (pn
   WHERE expand(index,1,req_data->req_cnt,pn.person_id,req_data->req_qual[index].sup_physician.id)
    AND pn.name_type_cd=213_prsnl
    AND pn.person_id != 0
    AND pn.name_type_seq=1
    AND pn.active_ind=1
    AND pn.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pn.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (npi
   WHERE npi.person_id=outerjoin(pn.person_id)
    AND npi.prsnl_alias_type_cd=outerjoin(320_npi)
    AND npi.active_ind=outerjoin(1)
    AND npi.beg_effective_dt_tm <= outerjoin(cnvtdatetime(sysdate))
    AND npi.end_effective_dt_tm > outerjoin(cnvtdatetime(sysdate)))
   JOIN (upin
   WHERE upin.person_id=outerjoin(pn.person_id)
    AND upin.prsnl_alias_type_cd=outerjoin(320_docupin)
    AND upin.active_ind=outerjoin(1)
    AND upin.beg_effective_dt_tm <= outerjoin(cnvtdatetime(sysdate))
    AND upin.end_effective_dt_tm > outerjoin(cnvtdatetime(sysdate)))
   JOIN (ext
   WHERE ext.person_id=outerjoin(pn.person_id)
    AND ext.prsnl_alias_type_cd=outerjoin(320_externalid)
    AND ext.active_ind=outerjoin(1)
    AND ext.beg_effective_dt_tm <= outerjoin(cnvtdatetime(sysdate))
    AND ext.end_effective_dt_tm > outerjoin(cnvtdatetime(sysdate)))
  ORDER BY pn.person_id
  DETAIL
   loc = locateval(index,1,req_data->req_cnt,pn.person_id,req_data->req_qual[index].sup_physician.id)
   WHILE (loc > 0)
     req_data->req_qual[loc].sup_physician.name_full = pn.name_full, req_data->req_qual[loc].
     sup_physician.name_first = pn.name_first, req_data->req_qual[loc].sup_physician.name_last = pn
     .name_last,
     req_data->req_qual[loc].sup_physician.name_middle = pn.name_middle, req_data->req_qual[loc].
     sup_physician.name_title = pn.name_title, req_data->req_qual[loc].sup_physician.npi = cnvtalias(
      npi.alias,npi.alias_pool_cd),
     req_data->req_qual[loc].sup_physician.docupin = cnvtalias(upin.alias,upin.alias_pool_cd),
     req_data->req_qual[loc].sup_physician.external_id = cnvtalias(ext.alias,ext.alias_pool_cd), loc
      = locateval(index,(loc+ 1),req_data->req_cnt,pn.person_id,req_data->req_qual[index].
      sup_physician.id)
   ENDWHILE
  WITH expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM address a
  PLAN (a
   WHERE expand(index,1,req_data->req_cnt,a.parent_entity_id,req_data->req_qual[index].sup_physician.
    id)
    AND a.parent_entity_name="PERSON"
    AND a.address_type_cd=212_business
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND a.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY a.parent_entity_id, a.address_type_seq
  HEAD a.parent_entity_id
   add_type_seq_gr_zero = false
  DETAIL
   IF (((a.address_type_seq=0) OR (a.address_type_seq > 0
    AND add_type_seq_gr_zero=false)) )
    loc = locateval(index,1,req_data->req_cnt,a.parent_entity_id,req_data->req_qual[index].
     sup_physician.id)
    WHILE (loc > 0)
      req_data->req_qual[loc].sup_physician.address.street_addr = a.street_addr, req_data->req_qual[
      loc].sup_physician.address.city = a.city, req_data->req_qual[loc].sup_physician.address.state
       = evaluate(a.state_cd,0.0,a.state,uar_get_code_display(a.state_cd)),
      req_data->req_qual[loc].sup_physician.address.zipcode = a.zipcode, loc = locateval(index,(loc+
       1),req_data->req_cnt,a.parent_entity_id,req_data->req_qual[index].sup_physician.id)
      IF (a.address_type_seq > 0)
       add_type_seq_gr_zero = true
      ENDIF
    ENDWHILE
   ENDIF
  WITH expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM phone p
  PLAN (p
   WHERE expand(index,1,req_data->req_cnt,p.parent_entity_id,req_data->req_qual[index].sup_physician.
    id)
    AND p.parent_entity_name="PERSON"
    AND p.phone_type_cd=43_business
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY p.parent_entity_id, p.phone_type_seq
  HEAD p.parent_entity_id
   ph_type_seq_gr_zero = false
  DETAIL
   IF (ph_type_seq_gr_zero=false)
    loc = locateval(index,1,req_data->req_cnt,p.parent_entity_id,req_data->req_qual[index].
     sup_physician.id)
    WHILE (loc > 0)
      req_data->req_qual[loc].sup_physician.phone.number = p.phone_num, req_data->req_qual[loc].
      sup_physician.phone.format_cd = p.phone_format_cd, loc = locateval(index,(loc+ 1),req_data->
       req_cnt,p.parent_entity_id,req_data->req_qual[index].sup_physician.id)
    ENDWHILE
    IF (p.phone_type_seq > 0)
     ph_type_seq_gr_zero = true
    ENDIF
   ENDIF
  WITH expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM phone p
  PLAN (p
   WHERE expand(index,1,req_data->req_cnt,p.parent_entity_id,req_data->req_qual[index].sup_physician.
    id)
    AND p.parent_entity_name="PERSON"
    AND p.phone_type_cd=43_fax_bus
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY p.parent_entity_id, p.phone_type_seq
  HEAD p.parent_entity_id
   ph_type_seq_gr_zero = false
  DETAIL
   IF (ph_type_seq_gr_zero=false)
    loc = locateval(index,1,req_data->req_cnt,p.parent_entity_id,req_data->req_qual[index].
     sup_physician.id)
    WHILE (loc > 0)
      req_data->req_qual[loc].sup_physician.fax.number = p.phone_num, req_data->req_qual[loc].
      sup_physician.fax.format_cd = p.phone_format_cd, loc = locateval(index,(loc+ 1),req_data->
       req_cnt,p.parent_entity_id,req_data->req_qual[index].sup_physician.id)
    ENDWHILE
    IF (p.phone_type_seq > 0)
     ph_type_seq_gr_zero = true
    ENDIF
   ENDIF
  WITH expand = 1
 ;end select
 IF ((req_data->encntr_id != 0.00))
  SELECT INTO "nl:"
   FROM encntr_prsnl_reltn epr,
    prsnl p
   PLAN (epr
    WHERE (epr.encntr_id=req_data->encntr_id)
     AND epr.encntr_prsnl_r_cd=333_referdoc
     AND epr.active_ind=1
     AND epr.prsnl_person_id > 0
     AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (p
    WHERE p.person_id=epr.prsnl_person_id)
   ORDER BY epr.encntr_id
   HEAD epr.encntr_id
    req_data->refer_physician_id = p.person_id, req_data->refer_physician_name = p
    .name_full_formatted
   WITH nocounter
  ;end select
 ENDIF
 IF ((req_data->encntr_id > 0.00))
  SELECT INTO "nl:"
   FROM encntr_plan_reltn epr,
    health_plan hp,
    person p,
    person_alias ssn,
    encntr_person_reltn er,
    address saddr,
    phone spn,
    person_org_reltn semp,
    organization emp
   PLAN (epr
    WHERE (epr.encntr_id=req_data->encntr_id)
     AND epr.priority_seq IN (1, 2)
     AND epr.active_ind=1
     AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (p
    WHERE p.person_id=epr.person_id)
    JOIN (ssn
    WHERE ssn.person_id=outerjoin(p.person_id)
     AND ssn.person_alias_type_cd=outerjoin(4_ssn)
     AND ssn.active_ind=outerjoin(1)
     AND ssn.beg_effective_dt_tm <= outerjoin(cnvtdatetime(sysdate))
     AND ssn.end_effective_dt_tm > outerjoin(cnvtdatetime(sysdate)))
    JOIN (hp
    WHERE hp.health_plan_id=epr.health_plan_id)
    JOIN (er
    WHERE er.encntr_id=epr.encntr_id
     AND er.related_person_id=epr.person_id
     AND er.person_reltn_type_cd=351_insured
     AND er.active_ind=1)
    JOIN (saddr
    WHERE saddr.parent_entity_id=outerjoin(epr.person_id)
     AND saddr.parent_entity_name=outerjoin("PERSON")
     AND saddr.address_type_cd=outerjoin(212_home)
     AND saddr.active_ind=outerjoin(1)
     AND saddr.beg_effective_dt_tm <= outerjoin(cnvtdatetime(sysdate))
     AND saddr.end_effective_dt_tm > outerjoin(cnvtdatetime(sysdate)))
    JOIN (spn
    WHERE spn.parent_entity_id=outerjoin(epr.person_id)
     AND spn.parent_entity_name=outerjoin("PERSON")
     AND spn.phone_type_cd=outerjoin(43_home)
     AND spn.active_ind=outerjoin(1)
     AND spn.beg_effective_dt_tm <= outerjoin(cnvtdatetime(sysdate))
     AND spn.end_effective_dt_tm > outerjoin(cnvtdatetime(sysdate)))
    JOIN (semp
    WHERE semp.person_id=outerjoin(epr.person_id)
     AND semp.person_org_reltn_cd=outerjoin(338_employer)
     AND semp.priority_seq=outerjoin(1)
     AND semp.active_ind=outerjoin(1)
     AND semp.beg_effective_dt_tm <= outerjoin(cnvtdatetime(sysdate))
     AND semp.end_effective_dt_tm > outerjoin(cnvtdatetime(sysdate)))
    JOIN (emp
    WHERE emp.organization_id=outerjoin(semp.organization_id))
   ORDER BY epr.priority_seq, saddr.address_type_seq, spn.phone_type_seq
   HEAD REPORT
    cnt = 0
   HEAD epr.priority_seq
    add_type_seq_gr_zero = false, ph_type_seq_gr_zero = false, cnt = (cnt+ 1),
    stat = alterlist(req_data->subscriber,cnt), req_data->subscriber[cnt].encntr_plan_reltn_id = epr
    .encntr_plan_reltn_id, req_data->subscriber[cnt].priority_seq = epr.priority_seq,
    req_data->subscriber[cnt].name = p.name_full_formatted, req_data->subscriber[cnt].id = epr
    .person_id, req_data->subscriber[cnt].birth_dt_tm = p.birth_dt_tm,
    req_data->subscriber[cnt].birth_tz = p.birth_tz
    IF (ssn.person_alias_id != 0)
     req_data->subscriber[cnt].ssn = format(substring(6,4,ssn.alias),"XXX-XX-####")
    ENDIF
    req_data->subscriber[cnt].employer_name = emp.org_name
    IF (er.person_reltn_cd > 0)
     req_data->subscriber[cnt].relation_cd = er.person_reltn_cd
    ELSE
     req_data->subscriber[cnt].relation_cd = er.related_person_reltn_cd
    ENDIF
    req_data->subscriber[cnt].health_plan.id = hp.health_plan_id, req_data->subscriber[cnt].
    health_plan.name = hp.plan_name, req_data->subscriber[cnt].health_plan.financial_class_cd = hp
    .financial_class_cd,
    req_data->subscriber[cnt].health_plan.policy_nbr = epr.member_nbr, req_data->subscriber[cnt].
    health_plan.group_nbr = epr.group_nbr, req_data->subscriber[cnt].health_plan.subs_member_nbr =
    epr.subs_member_nbr
   DETAIL
    IF (add_type_seq_gr_zero=false)
     req_data->subscriber[cnt].address.street_addr = trim(concat(trim(saddr.street_addr)," ",trim(
        saddr.street_addr2)),3), req_data->subscriber[cnt].address.city = saddr.city, req_data->
     subscriber[cnt].address.state = evaluate(saddr.state_cd,0.0,saddr.state,uar_get_code_display(
       saddr.state_cd)),
     req_data->subscriber[cnt].address.zipcode = saddr.zipcode
     IF (saddr.address_type_seq > 0)
      add_type_seq_gr_zero = true
     ENDIF
    ENDIF
    IF (ph_type_seq_gr_zero=false)
     req_data->subscriber[cnt].phone.number = spn.phone_num, req_data->subscriber[cnt].phone.
     format_cd = spn.phone_format_cd
     IF (spn.phone_type_seq > 0)
      ph_type_seq_gr_zero = true
     ENDIF
    ENDIF
   FOOT  epr.encntr_id
    req_data->subscriber_cnt = cnt
   WITH nocounter
  ;end select
 ENDIF
 IF ((req_data->encntr_id=0.00))
  SELECT INTO "nl:"
   FROM orders o,
    encounter e,
    encntr_plan_reltn epr,
    health_plan hp,
    person p,
    person_alias ssn,
    encntr_person_reltn er,
    address saddr,
    phone spn,
    person_org_reltn semp,
    organization emp
   PLAN (o
    WHERE (o.order_id=request->order_qual[1].order_id))
    JOIN (e
    WHERE e.encntr_id=o.originating_encntr_id)
    JOIN (epr
    WHERE epr.encntr_id=o.originating_encntr_id
     AND epr.priority_seq IN (1, 2)
     AND epr.active_ind=1
     AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (p
    WHERE p.person_id=epr.person_id)
    JOIN (ssn
    WHERE ssn.person_id=outerjoin(p.person_id)
     AND ssn.person_alias_type_cd=outerjoin(4_ssn)
     AND ssn.active_ind=outerjoin(1)
     AND ssn.beg_effective_dt_tm <= outerjoin(cnvtdatetime(sysdate))
     AND ssn.end_effective_dt_tm > outerjoin(cnvtdatetime(sysdate)))
    JOIN (hp
    WHERE hp.health_plan_id=epr.health_plan_id)
    JOIN (er
    WHERE er.encntr_id=epr.encntr_id
     AND er.related_person_id=epr.person_id
     AND er.person_reltn_type_cd=351_insured
     AND er.active_ind=1)
    JOIN (saddr
    WHERE saddr.parent_entity_id=outerjoin(epr.person_id)
     AND saddr.parent_entity_name=outerjoin("PERSON")
     AND saddr.address_type_cd=outerjoin(212_home)
     AND saddr.active_ind=outerjoin(1)
     AND saddr.beg_effective_dt_tm <= outerjoin(cnvtdatetime(sysdate))
     AND saddr.end_effective_dt_tm > outerjoin(cnvtdatetime(sysdate)))
    JOIN (spn
    WHERE spn.parent_entity_id=outerjoin(epr.person_id)
     AND spn.parent_entity_name=outerjoin("PERSON")
     AND spn.phone_type_cd=outerjoin(43_home)
     AND spn.active_ind=outerjoin(1)
     AND spn.beg_effective_dt_tm <= outerjoin(cnvtdatetime(sysdate))
     AND spn.end_effective_dt_tm > outerjoin(cnvtdatetime(sysdate)))
    JOIN (semp
    WHERE semp.person_id=outerjoin(epr.person_id)
     AND semp.person_org_reltn_cd=outerjoin(338_employer)
     AND semp.priority_seq=outerjoin(1)
     AND semp.active_ind=outerjoin(1)
     AND semp.beg_effective_dt_tm <= outerjoin(cnvtdatetime(sysdate))
     AND semp.end_effective_dt_tm > outerjoin(cnvtdatetime(sysdate)))
    JOIN (emp
    WHERE emp.organization_id=outerjoin(semp.organization_id))
   ORDER BY epr.priority_seq, saddr.address_type_seq, spn.phone_type_seq
   HEAD REPORT
    cnt = 0
   HEAD epr.priority_seq
    add_type_seq_gr_zero = false, ph_type_seq_gr_zero = false, cnt = (cnt+ 1),
    stat = alterlist(req_data->subscriber,cnt), req_data->subscriber[cnt].person_plan_reltn_id = epr
    .person_plan_reltn_id, req_data->subscriber[cnt].priority_seq = epr.priority_seq,
    req_data->subscriber[cnt].name = p.name_full_formatted, req_data->subscriber[cnt].id = epr
    .person_id, req_data->subscriber[cnt].birth_dt_tm = p.birth_dt_tm,
    req_data->subscriber[cnt].birth_tz = p.birth_tz
    IF (ssn.person_alias_id != 0)
     req_data->subscriber[cnt].ssn = format(substring(6,4,ssn.alias),"XXX-XX-####")
    ENDIF
    req_data->subscriber[cnt].employer_name = emp.org_name
    IF (er.person_reltn_cd > 0)
     req_data->subscriber[cnt].relation_cd = er.person_reltn_cd
    ELSE
     req_data->subscriber[cnt].relation_cd = er.related_person_reltn_cd
    ENDIF
    req_data->subscriber[cnt].health_plan.id = hp.health_plan_id, req_data->subscriber[cnt].
    health_plan.name = hp.plan_name, req_data->subscriber[cnt].health_plan.financial_class_cd = hp
    .financial_class_cd,
    req_data->subscriber[cnt].health_plan.policy_nbr = epr.member_nbr, req_data->subscriber[cnt].
    health_plan.group_nbr = epr.group_nbr, req_data->subscriber[cnt].health_plan.subs_member_nbr =
    epr.subs_member_nbr
   DETAIL
    IF (add_type_seq_gr_zero=false)
     req_data->subscriber[cnt].address.street_addr = trim(concat(trim(saddr.street_addr)," ",trim(
        saddr.street_addr2)),3), req_data->subscriber[cnt].address.city = saddr.city, req_data->
     subscriber[cnt].address.state = evaluate(saddr.state_cd,0.0,saddr.state,uar_get_code_display(
       saddr.state_cd)),
     req_data->subscriber[cnt].address.zipcode = saddr.zipcode
     IF (saddr.address_type_seq > 0)
      add_type_seq_gr_zero = true
     ENDIF
    ENDIF
    IF (ph_type_seq_gr_zero=false)
     req_data->subscriber[cnt].phone.number = spn.phone_num, req_data->subscriber[cnt].phone.
     format_cd = spn.phone_format_cd
     IF (spn.phone_type_seq > 0)
      ph_type_seq_gr_zero = true
     ENDIF
    ENDIF
   FOOT  epr.person_id
    req_data->financial_class_cd = e.financial_class_cd, req_data->subscriber_cnt = cnt
   WITH nocounter
  ;end select
 ENDIF
 IF ((req_data->subscriber_cnt != 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_data->subscriber_cnt)),
    address a
   PLAN (d
    WHERE (req_data->subscriber[d.seq].encntr_plan_reltn_id > 0)
     AND (req_data->subscriber[d.seq].health_plan.address.id=0)
     AND (req_data->subscriber_cnt != 0))
    JOIN (a
    WHERE (a.parent_entity_id=req_data->subscriber[d.seq].encntr_plan_reltn_id)
     AND a.parent_entity_name="ENCNTR_PLAN_RELTN"
     AND a.address_type_cd=212_business
     AND a.active_ind=1
     AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND a.end_effective_dt_tm > cnvtdatetime(sysdate))
   ORDER BY d.seq, a.address_type_seq
   HEAD d.seq
    add_type_seq_gr_zero = false
   HEAD a.address_type_seq
    IF (add_type_seq_gr_zero=false)
     req_data->subscriber[d.seq].health_plan.address.id = a.address_id, req_data->subscriber[d.seq].
     health_plan.address.street_addr = a.street_addr, req_data->subscriber[d.seq].health_plan.address
     .street_addr2 = a.street_addr2,
     req_data->subscriber[d.seq].health_plan.address.city = a.city, req_data->subscriber[d.seq].
     health_plan.address.state = evaluate(a.state_cd,0.0,a.state,uar_get_code_display(a.state_cd)),
     req_data->subscriber[d.seq].health_plan.address.zipcode = a.zipcode
     IF (a.address_type_seq > 0)
      add_type_seq_gr_zero = true
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_data->subscriber_cnt)),
    address a
   PLAN (d
    WHERE (req_data->subscriber[d.seq].health_plan.id > 0)
     AND (req_data->subscriber[d.seq].health_plan.address.id=0))
    JOIN (a
    WHERE (a.parent_entity_id=req_data->subscriber[d.seq].health_plan.id)
     AND a.parent_entity_name="HEALTH_PLAN"
     AND a.address_type_cd=212_business
     AND a.active_ind=1
     AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND a.end_effective_dt_tm > cnvtdatetime(sysdate))
   ORDER BY d.seq, a.address_type_seq
   HEAD d.seq
    add_type_seq_gr_zero = false
   DETAIL
    IF (add_type_seq_gr_zero=false)
     req_data->subscriber[d.seq].health_plan.address.id = a.address_id, req_data->subscriber[d.seq].
     health_plan.address.street_addr = a.street_addr, req_data->subscriber[d.seq].health_plan.address
     .street_addr2 = a.street_addr2,
     req_data->subscriber[d.seq].health_plan.address.city = a.city, req_data->subscriber[d.seq].
     health_plan.address.state = evaluate(a.state_cd,0.0,a.state,uar_get_code_display(a.state_cd)),
     req_data->subscriber[d.seq].health_plan.address.zipcode = a.zipcode
     IF (a.address_type_seq > 0)
      add_type_seq_gr_zero = true
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 FOR (index = 1 TO req_data->subscriber_cnt)
   IF ((req_data->subscriber[index].health_plan.address.id=0))
    SET req_data->subscriber[index].health_plan.address.street_addr = "NO QUALIFYING ADDRESS FOUND"
   ENDIF
 ENDFOR
 IF ((req_data->encntr_id > 0.00))
  SELECT INTO "nl:"
   FROM encntr_person_reltn epr,
    person p,
    address a,
    phone ph,
    person_alias pa
   PLAN (epr
    WHERE (epr.encntr_id=req_data->encntr_id)
     AND epr.person_reltn_type_cd=351_defguar
     AND epr.active_ind=1
     AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (p
    WHERE p.person_id=epr.related_person_id)
    JOIN (a
    WHERE a.parent_entity_id=outerjoin(p.person_id)
     AND a.parent_entity_name=outerjoin("PERSON")
     AND a.address_type_cd=outerjoin(212_home)
     AND a.active_ind=outerjoin(1)
     AND a.beg_effective_dt_tm <= outerjoin(cnvtdatetime(sysdate))
     AND a.end_effective_dt_tm > outerjoin(cnvtdatetime(sysdate)))
    JOIN (ph
    WHERE ph.parent_entity_id=outerjoin(p.person_id)
     AND ph.parent_entity_name=outerjoin("PERSON")
     AND ph.phone_type_cd=outerjoin(43_home)
     AND ph.active_ind=outerjoin(1)
     AND ph.beg_effective_dt_tm <= outerjoin(cnvtdatetime(sysdate))
     AND ph.end_effective_dt_tm > outerjoin(cnvtdatetime(sysdate)))
    JOIN (pa
    WHERE pa.person_id=outerjoin(p.person_id)
     AND pa.person_alias_type_cd=outerjoin(4_ssn)
     AND pa.active_ind=outerjoin(1)
     AND pa.beg_effective_dt_tm <= outerjoin(cnvtdatetime(sysdate))
     AND pa.end_effective_dt_tm > outerjoin(cnvtdatetime(sysdate)))
   ORDER BY epr.priority_seq, a.address_type_seq, ph.phone_type_seq
   HEAD REPORT
    req_data->guarantor.name_full_formatted = p.name_full_formatted
    IF (epr.person_reltn_cd > 0)
     req_data->guarantor.reltn_cd = epr.person_reltn_cd
    ELSE
     req_data->guarantor.reltn_cd = epr.related_person_reltn_cd
    ENDIF
    IF (pa.person_alias_id != 0)
     req_data->guarantor.ssn = format(substring(6,4,pa.alias),"XXX-XX-####")
    ENDIF
    req_data->guarantor.birth_dt_tm = p.birth_dt_tm, req_data->guarantor.birth_tz = p.birth_tz,
    req_data->guarantor.address.street_addr = trim(concat(trim(a.street_addr)," ",trim(a.street_addr2
       )),3),
    req_data->guarantor.address.city = a.city, req_data->guarantor.address.state = evaluate(a
     .state_cd,0.0,a.state,uar_get_code_display(a.state_cd)), req_data->guarantor.address.zipcode = a
    .zipcode,
    req_data->guarantor.phone.number = ph.phone_num, req_data->guarantor.phone.format_cd = ph
    .phone_format_cd
    IF (a.address_type_seq=0)
     add_type_seq_gr_zero = false
    ELSE
     add_type_seq_gr_zero = true
    ENDIF
    IF (ph.phone_type_seq=0)
     ph_type_seq_gr_zero = false
    ELSE
     ph_type_seq_gr_zero = true
    ENDIF
   DETAIL
    IF (add_type_seq_gr_zero=false
     AND a.address_type_seq > 0)
     req_data->guarantor.address.street_addr = trim(concat(trim(a.street_addr)," ",trim(a
        .street_addr2)),3), req_data->guarantor.address.city = a.city, req_data->guarantor.address.
     state = evaluate(a.state_cd,0.0,a.state,uar_get_code_display(a.state_cd)),
     req_data->guarantor.address.zipcode = a.zipcode, add_type_seq_gr_zero = true
    ENDIF
    IF (ph_type_seq_gr_zero=false
     AND ph.phone_type_seq > 0)
     req_data->guarantor.phone.number = ph.phone_num, req_data->guarantor.phone.format_cd = ph
     .phone_format_cd, ph_type_seq_gr_zero = true
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((req_data->encntr_id=0.00))
  SELECT INTO "nl:"
   FROM orders o,
    encntr_person_reltn epr,
    person p,
    address a,
    phone ph,
    person_alias pa
   PLAN (o
    WHERE (o.order_id=request->order_qual[1].order_id))
    JOIN (epr
    WHERE epr.encntr_id=o.originating_encntr_id
     AND epr.person_reltn_type_cd=351_defguar
     AND epr.active_ind=1
     AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (p
    WHERE p.person_id=epr.related_person_id)
    JOIN (a
    WHERE a.parent_entity_id=outerjoin(p.person_id)
     AND a.parent_entity_name=outerjoin("PERSON")
     AND a.address_type_cd=outerjoin(212_home)
     AND a.active_ind=outerjoin(1)
     AND a.beg_effective_dt_tm <= outerjoin(cnvtdatetime(sysdate))
     AND a.end_effective_dt_tm > outerjoin(cnvtdatetime(sysdate)))
    JOIN (ph
    WHERE ph.parent_entity_id=outerjoin(p.person_id)
     AND ph.parent_entity_name=outerjoin("PERSON")
     AND ph.phone_type_cd=outerjoin(43_home)
     AND ph.active_ind=outerjoin(1)
     AND ph.beg_effective_dt_tm <= outerjoin(cnvtdatetime(sysdate))
     AND ph.end_effective_dt_tm > outerjoin(cnvtdatetime(sysdate)))
    JOIN (pa
    WHERE pa.person_id=outerjoin(p.person_id)
     AND pa.person_alias_type_cd=outerjoin(4_ssn)
     AND pa.active_ind=outerjoin(1)
     AND pa.beg_effective_dt_tm <= outerjoin(cnvtdatetime(sysdate))
     AND pa.end_effective_dt_tm > outerjoin(cnvtdatetime(sysdate)))
   ORDER BY epr.priority_seq, a.address_type_seq, ph.phone_type_seq
   HEAD REPORT
    req_data->guarantor.name_full_formatted = p.name_full_formatted
    IF (epr.person_reltn_cd > 0)
     req_data->guarantor.reltn_cd = epr.person_reltn_cd
    ELSE
     req_data->guarantor.reltn_cd = epr.related_person_reltn_cd
    ENDIF
    IF (pa.person_alias_id != 0)
     req_data->guarantor.ssn = format(substring(6,4,pa.alias),"XXX-XX-####")
    ENDIF
    req_data->guarantor.birth_dt_tm = p.birth_dt_tm, req_data->guarantor.birth_tz = p.birth_tz,
    req_data->guarantor.address.street_addr = trim(concat(trim(a.street_addr)," ",trim(a.street_addr2
       )),3),
    req_data->guarantor.address.city = a.city, req_data->guarantor.address.state = evaluate(a
     .state_cd,0.0,a.state,uar_get_code_display(a.state_cd)), req_data->guarantor.address.zipcode = a
    .zipcode,
    req_data->guarantor.phone.number = ph.phone_num, req_data->guarantor.phone.format_cd = ph
    .phone_format_cd
    IF (a.address_type_seq=0)
     add_type_seq_gr_zero = false
    ELSE
     add_type_seq_gr_zero = true
    ENDIF
    IF (ph.phone_type_seq=0)
     ph_type_seq_gr_zero = false
    ELSE
     ph_type_seq_gr_zero = true
    ENDIF
   DETAIL
    IF (add_type_seq_gr_zero=false
     AND a.address_type_seq > 0)
     req_data->guarantor.address.street_addr = trim(concat(trim(a.street_addr)," ",trim(a
        .street_addr2)),3), req_data->guarantor.address.city = a.city, req_data->guarantor.address.
     state = evaluate(a.state_cd,0.0,a.state,uar_get_code_display(a.state_cd)),
     req_data->guarantor.address.zipcode = a.zipcode, add_type_seq_gr_zero = true
    ENDIF
    IF (ph_type_seq_gr_zero=false
     AND ph.phone_type_seq > 0)
     req_data->guarantor.phone.number = ph.phone_num, req_data->guarantor.phone.format_cd = ph
     .phone_format_cd, ph_type_seq_gr_zero = true
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM diagnosis d,
   nomenclature n
  PLAN (d
   WHERE (d.encntr_id=req_data->encntr_id)
    AND d.end_effective_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id
    AND ((n.source_vocabulary_cd+ 0) IN (400_icd9, 400_icd10cm_cd)))
  ORDER BY d.beg_effective_dt_tm
  HEAD REPORT
   cnt = 0, stat = alterlist(req_data->dx_qual,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt <= 10)
    IF (cnt=1)
     req_data->dx_barcode = n.source_identifier
    ENDIF
    req_data->dx_qual[cnt].diagnosis_id = d.diagnosis_id, req_data->dx_qual[cnt].nomenclature_id = n
    .nomenclature_id, req_data->dx_qual[cnt].source_identifier = n.source_identifier,
    req_data->dx_list = build(req_data->dx_list,",",n.source_identifier)
   ENDIF
  FOOT REPORT
   IF (cnt < 10)
    req_data->dx_cnt = cnt, stat = alterlist(req_data->dx_qual,cnt)
   ELSE
    req_data->dx_cnt = 10
   ENDIF
   req_data->dx_list = trim(replace(req_data->dx_list,",","",1),3), req_data->dx_list = replace(
    req_data->dx_list,",",", ")
  WITH nocounter
 ;end select
 SELECT
  IF ((req_data->encntr_id != 0.0))
   PLAN (d1
    WHERE maxrec(d2,req_data->req_qual[d1.seq].ord_cnt))
    JOIN (d2
    WHERE d2.seq > 0)
    JOIN (ner
    WHERE (ner.parent_entity_id=req_data->req_qual[d1.seq].ord_qual[d2.seq].order_id)
     AND ner.parent_entity_name="ORDERS"
     AND ner.child_entity_name="DIAGNOSIS"
     AND ner.active_ind=1
     AND ner.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND ner.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (n
    WHERE n.nomenclature_id=ner.nomenclature_id
     AND ((n.source_vocabulary_cd+ 0) IN (400_icd9, 400_icd10cm_cd)))
  ELSEIF ((req_data->encntr_id=0.0))
   PLAN (d1
    WHERE maxrec(d2,req_data->req_qual[d1.seq].ord_cnt))
    JOIN (d2
    WHERE d2.seq > 0)
    JOIN (ner
    WHERE (ner.parent_entity_id=req_data->req_qual[d1.seq].ord_qual[d2.seq].order_id)
     AND ner.parent_entity_name="ORDERS"
     AND ner.child_entity_name="NOMENCLATURE"
     AND ner.active_ind=1
     AND ner.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND ner.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (n
    WHERE n.nomenclature_id=ner.nomenclature_id
     AND ((n.source_vocabulary_cd+ 0) IN (400_icd9, 400_icd10cm_cd)))
  ELSE
  ENDIF
  INTO "nl:"
  FROM (dummyt d1  WITH seq = value(req_data->req_cnt)),
   (dummyt d2  WITH seq = 1),
   nomen_entity_reltn ner,
   nomenclature n
  ORDER BY d1.seq, d2.seq, n.source_identifier
  HEAD REPORT
   cnt = 0
  HEAD d1.seq
   row + 0
  HEAD d2.seq
   dcnt = 0
  HEAD n.source_identifier
   pos = locateval(index,1,cnt,n.nomenclature_id,labcorp_diagnosis->diag[index].nomenclature_id)
   IF (pos=0)
    cnt = (cnt+ 1), stat = alterlist(labcorp_diagnosis->diag,(cnt+ 9)), labcorp_diagnosis->diag[cnt].
    nomenclature_id = n.nomenclature_id
    IF (cnt <= 120)
     req_data->dx_lc_list = build(req_data->dx_lc_list,",",n.source_identifier)
    ENDIF
   ENDIF
   dcnt = (dcnt+ 1), req_data->req_qual[d1.seq].ord_qual[d2.seq].dx_list = build(req_data->req_qual[
    d1.seq].ord_qual[d2.seq].dx_list,",",n.source_identifier)
   IF (mod(dcnt,10)=1)
    stat = alterlist(req_data->req_qual[d1.seq].ord_qual[d2.seq].diag,(dcnt+ 9))
   ENDIF
   req_data->req_qual[d1.seq].ord_qual[d2.seq].diag[dcnt].source_id = n.source_identifier, req_data->
   req_qual[d1.seq].ord_qual[d2.seq].diag[dcnt].nomen_name = n.source_string
   IF (size(trim(req_data->req_qual[d1.seq].ord_qual[d2.seq].diag[dcnt].nomen_name,3)) >
   diag_max_char)
    req_data->req_qual[d1.seq].ord_qual[d2.seq].diag[dcnt].wrap_diag = true
   ENDIF
  FOOT  n.source_identifier
   row + 0
  FOOT  d2.seq
   req_data->req_qual[d1.seq].ord_qual[d2.seq].dx_list = trim(replace(req_data->req_qual[d1.seq].
     ord_qual[d2.seq].dx_list,",","",1),3), req_data->req_qual[d1.seq].ord_qual[d2.seq].dx_list =
   replace(req_data->req_qual[d1.seq].ord_qual[d2.seq].dx_list,",",", "), req_data->req_qual[d1.seq].
   ord_qual[d2.seq].diag_cnt = dcnt,
   stat = alterlist(req_data->req_qual[d1.seq].ord_qual[d2.seq].diag,req_data->req_qual[d1.seq].
    ord_qual[d2.seq].diag_cnt), dcnt = 0
  FOOT  d1.seq
   row + 0
  FOOT REPORT
   stat = alterlist(labcorp_diagnosis->diag,cnt), req_data->dx_lc_list = trim(replace(req_data->
     dx_lc_list,",","",1),3), req_data->dx_lc_list = replace(req_data->dx_lc_list,",",", ")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(req_data->req_cnt)),
   (dummyt d2  WITH seq = 1),
   order_comment oc,
   long_text lt
  PLAN (d1
   WHERE maxrec(d2,req_data->req_qual[d1.seq].ord_cnt))
   JOIN (d2
   WHERE d2.seq > 0)
   JOIN (oc
   WHERE (oc.order_id=req_data->req_qual[d1.seq].ord_qual[d2.seq].order_id)
    AND oc.comment_type_cd=14_ord_comment)
   JOIN (lt
   WHERE lt.long_text_id=oc.long_text_id
    AND lt.active_ind=1)
  ORDER BY d1.seq, d2.seq, oc.action_sequence DESC
  HEAD d1.seq
   row + 0
  HEAD d2.seq
   req_data->req_qual[d1.seq].ord_qual[d2.seq].comment_line = check(replace(lt.long_text,char(13),"")
    )
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(req_data->req_cnt)),
   (dummyt d2  WITH seq = 1),
   code_value_outbound cvo
  PLAN (d1
   WHERE maxrec(d2,req_data->req_qual[d1.seq].ord_cnt))
   JOIN (d2
   WHERE (req_data->req_qual[d1.seq].contrib_src_cd > 0))
   JOIN (cvo
   WHERE (cvo.code_value=req_data->req_qual[d1.seq].ord_qual[d2.seq].catalog_cd)
    AND (cvo.contributor_source_cd=req_data->req_qual[d1.seq].contrib_src_cd))
  ORDER BY d1.seq, d2.seq
  DETAIL
   req_data->req_qual[d1.seq].ord_qual[d2.seq].outbound_alias = cvo.alias
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(req_data->req_cnt)),
   (dummyt d2  WITH seq = 1),
   order_detail od,
   oe_format_fields off,
   order_entry_fields oef,
   code_value_outbound cvo
  PLAN (d1
   WHERE maxrec(d2,req_data->req_qual[d1.seq].ord_cnt))
   JOIN (d2)
   JOIN (od
   WHERE (od.order_id=req_data->req_qual[d1.seq].ord_qual[d2.seq].order_id))
   JOIN (off
   WHERE (off.oe_format_id=req_data->req_qual[d1.seq].ord_qual[d2.seq].oe_format_id)
    AND off.action_type_cd=6003_order
    AND off.oe_field_id=od.oe_field_id)
   JOIN (oef
   WHERE oef.oe_field_id=off.oe_field_id)
   JOIN (cvo
   WHERE cvo.code_value=outerjoin(oef.oe_field_id)
    AND cvo.contributor_source_cd=outerjoin(req_data->req_qual[d1.seq].contrib_src_cd))
  ORDER BY d1.seq, d2.seq, off.group_seq,
   off.field_seq, od.oe_field_id, od.action_sequence DESC,
   od.detail_sequence
  HEAD d1.seq
   null
  HEAD d2.seq
   detail_cnt = 0, multi_cnt = 0, cnt = 0
  HEAD off.group_seq
   null
  HEAD off.field_seq
   null
  HEAD od.oe_field_id
   act_seq = od.action_sequence, last_action = true
  HEAD od.action_sequence
   IF (act_seq != od.action_sequence)
    last_action = false
   ENDIF
  DETAIL
   IF (last_action=true)
    pos = locateval(num,1,ord_det_alias->codev_cnt,od.oe_field_id,ord_det_alias->qual[num].code_value
     )
    IF (pos > 0)
     IF ((ord_det_alias->qual[pos].display="REQUESTEDSTARTDTTM"))
      req_data->req_qual[d1.seq].collection_dt_tm = od.oe_field_dt_tm_value, req_data->req_qual[d1
      .seq].ord_qual[d2.seq].collected_dt_tm = od.oe_field_dt_tm_value
     ENDIF
     IF ((ord_det_alias->qual[pos].display="SPECIMENTYPE"))
      req_data->req_qual[d1.seq].ord_qual[d2.seq].specimen_cd = od.oe_field_value
     ENDIF
     IF ((ord_det_alias->qual[pos].display="*PRIORITY*"))
      req_data->req_qual[d1.seq].ord_qual[d2.seq].priority_cd = od.oe_field_value
      IF ((ord_det_alias->qual[pos].display="PRIORITY:D"))
       req_data->std_ind = 1
      ELSEIF ((ord_det_alias->qual[pos].display="PRIORITY:Q"))
       req_data->quest_ind = 1
      ELSEIF ((ord_det_alias->qual[pos].display="PRIORITY:L"))
       req_data->labcorp_ind = 1
      ELSEIF ((ord_det_alias->qual[pos].display="PRIORITY:A"))
       req_data->all_ind = 1
      ENDIF
     ENDIF
     IF ((ord_det_alias->qual[pos].display="ABNSTATUS"))
      IF (od.oe_field_value != 17969_not_required)
       req_data->req_qual[d1.seq].abn_ind = true, req_data->req_qual[d1.seq].ord_qual[d2.seq].abn_ind
        = true
      ELSE
       req_data->req_qual[d1.seq].ord_qual[d2.seq].abn_ind = false
      ENDIF
      req_data->req_qual[d1.seq].ord_qual[d2.seq].abn_status = trim(od.oe_field_display_value)
     ENDIF
     IF ((ord_det_alias->qual[pos].display="ABNREASON"))
      req_data->req_qual[d1.seq].ord_qual[d2.seq].abn_reason = trim(od.oe_field_display_value)
     ENDIF
     IF (pos > 0
      AND (ord_det_alias->qual[pos].display="SPECIALINST"))
      req_data->req_qual[d1.seq].ord_qual[d2.seq].special_instruct = od.oe_field_display_value
     ENDIF
     IF ((ord_det_alias->qual[pos].display="SPECDESC"))
      req_data->req_qual[d1.seq].ord_qual[d2.seq].specimen_description = trim(od
       .oe_field_display_value,3)
     ENDIF
    ENDIF
    IF (od.oe_field_meaning IN ("OTHER", "PROMPT")
     AND cvo.alias != "DONOTSEND")
     pos = locateval(index,1,detail_cnt,od.oe_field_id,req_data->req_qual[d1.seq].ord_qual[d2.seq].
      details[index].oe_field_id)
     IF (pos > 0)
      req_data->req_qual[d1.seq].ord_qual[d2.seq].details[pos].multi_select = true, req_data->
      req_qual[d1.seq].ord_qual[d2.seq].details[pos].value = concat(req_data->req_qual[d1.seq].
       ord_qual[d2.seq].details[pos].value,", ",trim(od.oe_field_display_value)), multi_cnt = (
      multi_cnt+ 1)
     ELSE
      detail_cnt = (detail_cnt+ 1)
      IF (mod(detail_cnt,10)=1)
       stat = alterlist(req_data->req_qual[d1.seq].ord_qual[d2.seq].details,(detail_cnt+ 9))
      ENDIF
      req_data->req_qual[d1.seq].ord_qual[d2.seq].details[detail_cnt].oe_field_id = od.oe_field_id
      IF (size(trim(off.label_text))=0)
       req_data->req_qual[d1.seq].ord_qual[d2.seq].details[detail_cnt].label_text = oef.description
      ELSE
       req_data->req_qual[d1.seq].ord_qual[d2.seq].details[detail_cnt].label_text = off.label_text
      ENDIF
      req_data->req_qual[d1.seq].ord_qual[d2.seq].details[detail_cnt].value = od
      .oe_field_display_value
      IF ((((size(trim(req_data->req_qual[d1.seq].ord_qual[d2.seq].details[detail_cnt].label_text),1)
      + size(trim(req_data->req_qual[d1.seq].ord_qual[d2.seq].details[detail_cnt].value),1))+ 2) >=
      max_aoe_char))
       multi_cnt = (multi_cnt+ 1), req_data->req_qual[d1.seq].ord_qual[d2.seq].details[detail_cnt].
       multi_select = true
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT  od.action_sequence
   null
  FOOT  od.oe_field_id
   null
  FOOT  off.field_seq
   null
  FOOT  d2.seq
   req_data->req_qual[d1.seq].ord_qual[d2.seq].multi_cnt = multi_cnt, req_data->req_qual[d1.seq].
   ord_qual[d2.seq].detail_cnt = detail_cnt, stat = alterlist(req_data->req_qual[d1.seq].ord_qual[d2
    .seq].details,detail_cnt)
   FOR (index = 1 TO detail_cnt)
     IF ((req_data->req_qual[d1.seq].ord_qual[d2.seq].details[index].multi_select=false))
      cnt = (cnt+ 1), req_data->req_qual[d1.seq].ord_qual[d2.seq].single_cnt = cnt, stat = alterlist(
       req_data->req_qual[d1.seq].ord_qual[d2.seq].single_details,cnt),
      req_data->req_qual[d1.seq].ord_qual[d2.seq].single_details[cnt].oe_field_id = req_data->
      req_qual[d1.seq].ord_qual[d2.seq].details[index].oe_field_id, req_data->req_qual[d1.seq].
      ord_qual[d2.seq].single_details[cnt].label_text = req_data->req_qual[d1.seq].ord_qual[d2.seq].
      details[index].label_text, req_data->req_qual[d1.seq].ord_qual[d2.seq].single_details[cnt].
      value = req_data->req_qual[d1.seq].ord_qual[d2.seq].details[index].value
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(req_data->req_cnt)),
   (dummyt d2  WITH seq = 1),
   bill_item bi,
   bill_item_modifier bim
  PLAN (d1
   WHERE maxrec(d2,req_data->req_qual[d1.seq].ord_cnt))
   JOIN (d2
   WHERE d2.seq > 0)
   JOIN (bi
   WHERE (bi.ext_parent_reference_id=req_data->req_qual[d1.seq].ord_qual[d2.seq].catalog_cd)
    AND bi.active_ind=1
    AND bi.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND bi.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (bim
   WHERE bim.bill_item_id=bi.bill_item_id
    AND bim.active_ind=1
    AND bim.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND bim.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND bim.bill_item_type_cd=13019_billcode
    AND bim.key1_id IN (
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=14002
     AND cv.cdf_meaning="CPT4"
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
     AND cv.end_effective_dt_tm > cnvtdatetime(sysdate))))
  ORDER BY d1.seq, d2.seq
  HEAD d1.seq
   null
  HEAD d2.seq
   req_data->req_qual[d1.seq].ord_qual[d2.seq].cpt_cd = bim.key6
  WITH nocounter
 ;end select
 IF ((req_data->req_cnt > 0))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(req_data->req_cnt)),
    (dummyt d2  WITH seq = 1),
    code_value cv,
    code_value_outbound cvo
   PLAN (d1
    WHERE maxrec(d2,req_data->req_qual[d1.seq].ord_cnt))
    JOIN (d2)
    JOIN (cvo
    WHERE cvo.contributor_source_cd=outerjoin(73_ambrln)
     AND cvo.code_set=104600_ambrlnpref)
    JOIN (cv
    WHERE cv.code_set=cvo.code_set
     AND cv.code_value=cvo.code_value
     AND cv.code_value > 0.0)
   ORDER BY d1.seq, d2.seq
   DETAIL
    IF (substring(1,(findstring("_BARCODE",trim(cnvtupper(cv.display),3),1,1) - 1),trim(cnvtupper(cv
       .display),3))=cnvtupper(req_data->req_qual[d1.seq].ord_qual[d2.seq].perf_loc_disp))
     countvar = (countvar+ 1), format = trim(cnvtupper(cvo.alias),3), acct_id = req_data->req_qual[d1
     .seq].loc_nurse_unit_alias,
     req_id = req_data->req_qual[d1.seq].req_control_nbr, mrn = req_data->mrn, req_data->req_qual[d1
     .seq].ord_qual[d2.seq].req_text = dynamic_requisition_text(format,acct_id,req_id,mrn)
    ENDIF
   WITH nocounter
  ;end select
  FOR (loopvar = 1 TO req_data->req_cnt)
    FOR (loopvar2 = 1 TO req_data->req_qual[loopvar].ord_cnt)
      IF (((countvar=0
       AND  NOT ((req_data->req_qual[loopvar].ord_qual[loopvar2].perf_loc_cd IN (lab_corp_loc,
      quest_loc, misc_loc)))) OR (countvar > 0
       AND textlen(trim(req_data->req_qual[loopvar].ord_qual[loopvar2].req_text,3))=0))
       AND (req_data->req_qual[loopvar].ord_qual[loopvar2].perf_loc_cd > 0.0))
       SET acct_id = req_data->req_qual[loopvar].loc_nurse_unit_alias
       SET req_id = req_data->req_qual[loopvar].req_control_nbr
       SET req_data->req_qual[loopvar].ord_qual[loopvar2].req_text = dynamic_requisition_text(
        "ACCT+REQ_ID",acct_id,req_id,mrn)
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
 SUBROUTINE dynamic_requisition_text(format,acct_id,req_id,mrn)
   DECLARE start_pos = i2 WITH protect, noconstant(0)
   DECLARE separator_pos = i2 WITH protect, noconstant(0)
   DECLARE string1 = vc WITH protect, noconstant("")
   DECLARE string2 = vc WITH protect, noconstant("")
   DECLARE string3 = vc WITH protect, noconstant("")
   DECLARE full_string = vc WITH protect, noconstant("")
   IF (findstring("ACCT",format) > 0)
    IF (trim(substring(1,4,format))="ACCT")
     SET string1 = acct_id
    ENDIF
   ENDIF
   IF (findstring("REQ_ID",format) > 0)
    IF (trim(substring(1,6,format))="REQ_ID")
     SET string1 = req_id
    ENDIF
   ENDIF
   IF (findstring("MRN",format) > 0)
    IF (trim(substring(1,3,format))="MRN")
     SET string1 = mrn
    ENDIF
   ENDIF
   SET separator_pos = findstring("+",format)
   IF (separator_pos != 0)
    SET start_pos = findstring("ACCT",format,(separator_pos+ 1),1)
    IF (start_pos > 0)
     IF (trim(substring((separator_pos+ 1),4,format))="ACCT")
      SET string2 = acct_id
     ENDIF
    ENDIF
    SET start_pos = findstring("REQ_ID",format,(separator_pos+ 1),1)
    IF (start_pos > 0)
     IF (trim(substring((separator_pos+ 1),6,format))="REQ_ID")
      SET string2 = req_id
     ENDIF
    ENDIF
    SET start_pos = findstring("MRN",format,(separator_pos+ 1),1)
    IF (start_pos > 0)
     IF (trim(substring((separator_pos+ 1),3,format))="MRN")
      SET string2 = mrn
     ENDIF
    ENDIF
   ENDIF
   SET separator_pos = findstring("+",format,(separator_pos+ 1),1)
   IF (separator_pos != 0)
    SET start_pos = findstring("ACCT",format,separator_pos,1)
    IF (start_pos > 0)
     IF (trim(substring((separator_pos+ 1),4,format))="ACCT")
      SET string3 = acct_id
     ENDIF
    ENDIF
    SET start_pos = findstring("REQ_ID",format,(separator_pos+ 1),1)
    IF (start_pos > 0)
     IF (trim(substring((separator_pos+ 1),6,format))="REQ_ID")
      SET string3 = req_id
     ENDIF
    ENDIF
    SET start_pos = findstring("MRN",format,(separator_pos+ 1),1)
    IF (start_pos > 0)
     IF (trim(substring((separator_pos+ 1),3,format))="MRN")
      SET string3 = mrn
     ENDIF
    ENDIF
   ENDIF
   IF (textlen(string2) > 1)
    SET string2 = concat("-",string2,"-")
   ENDIF
   IF (textlen(trim(string3,3)) > 0)
    SET string3 = concat("-",string3)
    IF (textlen(trim(string2,3)) > 0)
     SET string3 = substring(2,textlen(string3),string3)
    ENDIF
   ELSE
    IF (textlen(trim(string2,3)) > 0)
     SET string2 = substring(1,(textlen(string2) - 1),string2)
    ENDIF
   ENDIF
   SET full_string = trim(concat(string1,string2,string3),3)
   RETURN(full_string)
 END ;Subroutine
 CALL echo("++++++++END MAIN PROGRAM++++++++")
 CALL echo("++++++++EXECUTE LAYOUT++++++++")
 IF ((req_data->guarantor_type_cd=353_org))
  SET req_data->bill_to = "Client"
  SET req_data->bill_to_ind = 2
  SET req_data->insurance_ind = 1
 ELSE
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=354
     AND cv.cdf_meaning="SELFPAY"
     AND (cv.code_value=req_data->financial_class_cd))
   HEAD REPORT
    req_data->bill_to = "Patient", req_data->bill_to_ind = 2, req_data->insurance_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM code_value cv,
    code_value_outbound cvo
   PLAN (cv
    WHERE cv.code_set=354
     AND (cv.code_value=req_data->financial_class_cd)
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (cvo
    WHERE cvo.code_value=cv.code_value
     AND cvo.contributor_source_cd=cs_ambulatoryrln_cd
     AND cnvtupper(trim(cvo.alias,3))="SELFPAY")
   HEAD REPORT
    req_data->bill_to = "Patient", req_data->bill_to_ind = 2, req_data->insurance_ind = 1
   WITH nocounter
  ;end select
  IF ((req_data->bill_to_ind < 1))
   IF ((req_data->subscriber_cnt > 0))
    SET req_data->bill_to = "Third Party"
    SET req_data->bill_to_ind = 2
    SET req_data->insurance_ind = 2
   ELSE
    SET req_data->bill_to = "ERROR"
    SET req_data->bill_to_ind = 2
    SET req_data->insurance_ind = 2
   ENDIF
  ENDIF
 ENDIF
 IF ((req_data->req_cnt > 0))
  IF ((req_data->req_qual[1].client_bill_ind=1))
   SET req_data->bill_to = "Client"
   SET req_data->bill_to_ind = 2
   SET req_data->insurance_ind = 1
  ENDIF
 ENDIF
 IF ((req_data->subscriber_cnt > 0))
  SET insurance_data->resp_party_1 = req_data->subscriber[1].name
  SET insurance_data->reltn_1 = uar_get_code_display(req_data->subscriber[1].relation_cd)
  SET insurance_data->resp_street_addr_1 = req_data->subscriber[1].address.street_addr
  SET insurance_data->resp_citystatezip_1 = concat(req_data->subscriber[1].address.city,", ",req_data
   ->subscriber[1].address.state," ",req_data->subscriber[1].address.zipcode)
  SET insurance_data->resp_ssn_1 = req_data->subscriber[1].ssn
  SET insurance_data->resp_dob_1 = format(cnvtdatetimeutc(datetimezone(req_data->subscriber[1].
     birth_dt_tm,req_data->subscriber[1].birth_tz),1),"MM/DD/YYYY;;Q")
  SET insurance_data->resp_phone_1 = cnvtphone(req_data->subscriber[1].phone.number,req_data->
   subscriber[1].phone.format_cd,2)
  SET insurance_data->sub_nbr_1 = req_data->subscriber[1].health_plan.subs_member_nbr
  SET insurance_data->ins_grp_nbr_1 = req_data->subscriber[1].health_plan.group_nbr
  SET insurance_data->sub_empl_1 = req_data->subscriber[1].employer_name
  SET insurance_data->carrier_street_addr_1 = req_data->subscriber[1].health_plan.address.street_addr
  SET insurance_data->carrier_street_addr2_1 = req_data->subscriber[1].health_plan.address.
  street_addr2
  SET insurance_data->carrier_citystatezip_1 = concat(req_data->subscriber[1].health_plan.address.
   city,", ",req_data->subscriber[1].health_plan.address.state," ",req_data->subscriber[1].
   health_plan.address.zipcode)
  SET insurance_data->bill_type_1 = uar_get_code_display(req_data->subscriber[1].health_plan.
   financial_class_cd)
  SET insurance_data->ins_lc_alias_1 = req_data->subscriber[1].health_plan.lc_alias
  SET insurance_data->ins_cust_code_1 = req_data->subscriber[1].health_plan.cust_alias
  SET insurance_data->ins_std_code_1 = req_data->subscriber[1].health_plan.std_alias
  SET insurance_data->carrier_1 = req_data->subscriber[1].health_plan.name
  SET insurance_data->ins_nbr_1 = req_data->subscriber[1].health_plan.policy_nbr
  SET insurance_data->ins_grp_nbr_1 = req_data->subscriber[1].health_plan.group_nbr
 ENDIF
 IF ((req_data->subscriber_cnt > 1))
  SET insurance_data->resp_party_2 = req_data->subscriber[2].name
  SET insurance_data->reltn_2 = uar_get_code_display(req_data->subscriber[2].relation_cd)
  SET insurance_data->resp_street_addr_2 = req_data->subscriber[2].address.street_addr
  SET insurance_data->resp_citystatezip_2 = concat(req_data->subscriber[2].address.city,", ",req_data
   ->subscriber[2].address.state," ",req_data->subscriber[2].address.zipcode)
  SET insurance_data->resp_ssn_2 = req_data->subscriber[2].ssn
  SET insurance_data->resp_dob_2 = format(cnvtdatetimeutc(datetimezone(req_data->subscriber[2].
     birth_dt_tm,req_data->subscriber[2].birth_tz),1),"MM/DD/YYYY;;Q")
  SET insurance_data->resp_phone_2 = cnvtphone(req_data->subscriber[2].phone.number,req_data->
   subscriber[2].phone.format_cd,2)
  SET insurance_data->sub_nbr_2 = req_data->subscriber[2].health_plan.subs_member_nbr
  SET insurance_data->ins_grp_nbr_2 = req_data->subscriber[2].health_plan.group_nbr
  SET insurance_data->sub_empl_2 = req_data->subscriber[2].employer_name
  SET insurance_data->carrier_street_addr_2 = req_data->subscriber[2].health_plan.address.street_addr
  SET insurance_data->carrier_street_addr2_2 = req_data->subscriber[2].health_plan.address.
  street_addr2
  SET insurance_data->carrier_citystatezip_2 = concat(req_data->subscriber[2].health_plan.address.
   city,", ",req_data->subscriber[2].health_plan.address.state," ",req_data->subscriber[2].
   health_plan.address.zipcode)
  SET insurance_data->bill_type_2 = uar_get_code_display(req_data->subscriber[2].health_plan.
   financial_class_cd)
  SET insurance_data->ins_lc_alias_2 = req_data->subscriber[2].health_plan.lc_alias
  SET insurance_data->ins_cust_code_2 = req_data->subscriber[2].health_plan.cust_alias
  SET insurance_data->ins_std_code_2 = req_data->subscriber[2].health_plan.std_alias
  SET insurance_data->carrier_2 = req_data->subscriber[2].health_plan.name
  SET insurance_data->ins_nbr_2 = req_data->subscriber[2].health_plan.policy_nbr
  SET insurance_data->ins_grp_nbr_2 = req_data->subscriber[2].health_plan.group_nbr
 ENDIF
 DECLARE 6009_nurseprep_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6009,"NURSEPREPARATION")),
 protect
 FOR (loopvar = 1 TO req_data->req_cnt)
  FOR (innerloop = 1 TO size(req_data->req_qual[loopvar].ord_qual,5))
    DECLARE blobout = vc
    DECLARE blobnortf = vc
    DECLARE bsize = i4
    DECLARE text = vc
    DECLARE rtf_text = c32000
    DECLARE asc_text = c32000
    SET x1 = 0
    SET blob_in = fillstring(32000," ")
    DECLARE inbuflen = i4
    DECLARE outbuflen = i4 WITH noconstant(1000)
    DECLARE retbuflen = i4 WITH noconstant(0)
    SELECT
     *
     FROM orders o,
      long_blob_reference lb,
      ref_text_variation rtv,
      ref_text_version rtvn
     PLAN (o
      WHERE (o.order_id=req_data->req_qual[loopvar].ord_qual[innerloop].order_id))
      JOIN (lb
      WHERE lb.parent_entity_name="ORDER_CATALOG"
       AND lb.parent_entity_id=o.catalog_cd)
      JOIN (rtvn
      WHERE rtvn.long_blob_id=lb.long_blob_id
       AND rtvn.active_ind=1)
      JOIN (rtv
      WHERE rtvn.ref_text_variation_id=rtv.ref_text_variation_id
       AND rtv.text_type_cd=6009_nurseprep_cd)
     ORDER BY lb.updt_dt_tm DESC
     HEAD lb.long_blob_id
      blob_out = fillstring(32000," "), inbuflen = size(lb.long_blob), stat = uar_rtf2(lb.long_blob,
       inbuflen,blob_out,outbuflen,retbuflen,
       0),
      x1 = size(trim(blob_out)), blob_out2 = substring(1,x1,blob_out), req_data->req_qual[loopvar].
      ord_qual[innerloop].reference_text_disp = blob_out2
    ;end select
  ENDFOR
  IF ((req_data->req_qual[loopvar].req_type_ind=1))
   EXECUTE amb_rln_quest_lyt value(request->printer_name)
  ELSEIF ((req_data->req_qual[loopvar].req_type_ind=2))
   EXECUTE amb_rln_labcorp_lyt value(request->printer_name)
  ELSE
   EXECUTE amb_rln_std_lyt_2 value(request->printer_name)
  ENDIF
 ENDFOR
 SUBROUTINE getrelatedorders(in_rec)
   DECLARE temp_ord_conversation_id = f8 WITH noconstant(0.0), protect
   IF ((in_rec->order_qual[1].encntr_id != 0))
    SET oa_parser = concat("oa.order_status_cd = 6004_ORDERED ","and oa.action_sequence =",
     "(select min(oa_s.action_sequence) from order_action oa_s ","where oa_s.order_id = oa.order_id ",
     "and oa_s.order_status_cd = 6004_ORDERED ",
     "and oa_s.dept_status_cd = 14281_dispatched)")
   ELSE
    SET oa_parser = concat("oa.action_type_cd = 6003_ORDER")
   ENDIF
   SELECT INTO "nl:"
    FROM order_action oa,
     order_action oa2,
     orders o
    PLAN (oa
     WHERE (oa.order_id=in_rec->order_qual[1].order_id)
      AND parser(oa_parser)
      AND oa.order_conversation_id != 0.00)
     JOIN (oa2
     WHERE oa2.order_conversation_id=oa.order_conversation_id
      AND oa2.dept_status_cd=oa.dept_status_cd)
     JOIN (o
     WHERE o.order_id=oa2.order_id
      AND  NOT (o.template_order_flag IN (protocol_orderflag, template_orderflag)))
    ORDER BY oa2.order_id
    HEAD REPORT
     rel_ord_cnt = 0
    HEAD oa2.order_id
     rel_ord_cnt = (rel_ord_cnt+ 1)
     IF (mod(rel_ord_cnt,10)=1)
      stat = alterlist(request_hold->order_qual,(rel_ord_cnt+ 9))
     ENDIF
     request_hold->order_qual[rel_ord_cnt].order_id = oa2.order_id, request_hold->order_qual[
     rel_ord_cnt].parent_orderid = o.protocol_order_id
    FOOT REPORT
     stat = alterlist(request_hold->order_qual,rel_ord_cnt)
    WITH nocounter
   ;end select
   IF (size(request_hold->order_qual,5) > 0)
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
#exit_script
 SET last_mod =
 "06/15/23 SG105192	CCPS-23461: CERN_CPS - Need to add sig block and ordering physician name & date to Quest req"
 SET reply->status_data.status = "S"
END GO
