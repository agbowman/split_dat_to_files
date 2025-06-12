CREATE PROGRAM amb_rln_std_lyt_2:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE reportrtl
 DECLARE test_display_name = vc WITH protect
 DECLARE order_counter = i4 WITH protect
 DECLARE misc_location_description = vc WITH constant("A-RLN Misc Ref Lab"), protect
 RECORD request(
   1 person_id = f8
   1 print_prsnl_id = f8
   1 order_qual[*]
     2 order_id = f8
     2 encntr_id = f8
     2 conversation_id = f8
   1 printer_name = c50
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
       3 hna_order_mnemonic = vc
       3 ordered_as_mnemonic = vc
       3 cpt_cd = vc
       3 alias = vc
       3 outbound_alias = vc
       3 collected_dt_tm = dq8
       3 cntnr_units = vc
       3 specimen_cd = f8
       3 specimen_type = vc
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
       3 comment[*] = vc
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
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE query1(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headreportsection(ncalc=i2) = f8 WITH protect
 DECLARE tablerow25(ncalc=i2) = f8 WITH protect
 DECLARE tablerow25abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow26(ncalc=i2) = f8 WITH protect
 DECLARE tablerow26abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow27(ncalc=i2) = f8 WITH protect
 DECLARE tablerow27abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow32(ncalc=i2) = f8 WITH protect
 DECLARE tablerow32abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow33(ncalc=i2) = f8 WITH protect
 DECLARE tablerow33abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow35(ncalc=i2) = f8 WITH protect
 DECLARE tablerow35abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow36(ncalc=i2) = f8 WITH protect
 DECLARE tablerow36abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow34(ncalc=i2) = f8 WITH protect
 DECLARE tablerow34abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE patientinforemaining(ncalc=i2) = f8 WITH protect
 DECLARE tablerow46(ncalc=i2) = f8 WITH protect
 DECLARE tablerow46abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow47(ncalc=i2) = f8 WITH protect
 DECLARE tablerow47abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE patientinforemainingabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE patclientinfofirst(ncalc=i2) = f8 WITH protect
 DECLARE tablerow5(ncalc=i2) = f8 WITH protect
 DECLARE tablerow5abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow6(ncalc=i2) = f8 WITH protect
 DECLARE tablerow6abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow10(ncalc=i2) = f8 WITH protect
 DECLARE tablerow10abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow9(ncalc=i2) = f8 WITH protect
 DECLARE tablerow9abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow7(ncalc=i2) = f8 WITH protect
 DECLARE tablerow7abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow11(ncalc=i2) = f8 WITH protect
 DECLARE tablerow11abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow38(ncalc=i2) = f8 WITH protect
 DECLARE tablerow38abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow12(ncalc=i2) = f8 WITH protect
 DECLARE tablerow12abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow13(ncalc=i2) = f8 WITH protect
 DECLARE tablerow13abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow14(ncalc=i2) = f8 WITH protect
 DECLARE tablerow14abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow15(ncalc=i2) = f8 WITH protect
 DECLARE tablerow15abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow37(ncalc=i2) = f8 WITH protect
 DECLARE tablerow37abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow24(ncalc=i2) = f8 WITH protect
 DECLARE tablerow24abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow20(ncalc=i2) = f8 WITH protect
 DECLARE tablerow20abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow54(ncalc=i2) = f8 WITH protect
 DECLARE tablerow54abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow8(ncalc=i2) = f8 WITH protect
 DECLARE tablerow8abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow40(ncalc=i2) = f8 WITH protect
 DECLARE tablerow40abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow41(ncalc=i2) = f8 WITH protect
 DECLARE tablerow41abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow42(ncalc=i2) = f8 WITH protect
 DECLARE tablerow42abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow39(ncalc=i2) = f8 WITH protect
 DECLARE tablerow39abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE patclientinfofirstabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE orders(ncalc=i2) = f8 WITH protect
 DECLARE tablerow22(ncalc=i2) = f8 WITH protect
 DECLARE tablerow22abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE ordersabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE future_ord_msg(ncalc=i2) = f8 WITH protect
 DECLARE future_ord_msgabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE orderscontd(ncalc=i2) = f8 WITH protect
 DECLARE tablerow28(ncalc=i2) = f8 WITH protect
 DECLARE tablerow28abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE orderscontdabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE testname(ncalc=i2) = f8 WITH protect
 DECLARE tablerow45(ncalc=i2) = f8 WITH protect
 DECLARE tablerow45abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE testnameabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE specimandetailsbold(ncalc=i2) = f8 WITH protect
 DECLARE tablerow2(ncalc=i2) = f8 WITH protect
 DECLARE tablerow2abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE specimandetailsboldabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE specimendetails(ncalc=i2) = f8 WITH protect
 DECLARE tablerow49(ncalc=i2) = f8 WITH protect
 DECLARE tablerow49abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE specimendetailsabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE specimentypeanddesc(ncalc=i2) = f8 WITH protect
 DECLARE tablerow55(ncalc=i2) = f8 WITH protect
 DECLARE tablerow55abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE specimentypeanddescabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE orderdetails(ncalc=i2) = f8 WITH protect
 DECLARE tablerow23(ncalc=i2) = f8 WITH protect
 DECLARE tablerow23abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE orderdetailsabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE orderdetailmulti(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE tablerow61(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE tablerow61abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE orderdetailmultiabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE abnstatusrequired(ncalc=i2) = f8 WITH protect
 DECLARE tablerow51(ncalc=i2) = f8 WITH protect
 DECLARE tablerow51abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow52(ncalc=i2) = f8 WITH protect
 DECLARE tablerow52abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE abnstatusrequiredabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE abnstatusnotrequired(ncalc=i2) = f8 WITH protect
 DECLARE tablerow53(ncalc=i2) = f8 WITH protect
 DECLARE tablerow53abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE abnstatusnotrequiredabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE dxcodes(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE tablerow21(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE tablerow21abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE dxcodesabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE specialinstructions(ncalc=i2) = f8 WITH protect
 DECLARE tablerow(ncalc=i2) = f8 WITH protect
 DECLARE tablerowabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE specialinstructionsabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE ordercomment(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE tablerow56(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE tablerow56abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE ordercommentabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE orderseparator(ncalc=i2) = f8 WITH protect
 DECLARE orderseparatorabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footpagesectionspecimenlabel(ncalc=i2) = f8 WITH protect
 DECLARE tablerow48(ncalc=i2) = f8 WITH protect
 DECLARE tablerow48abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow50(ncalc=i2) = f8 WITH protect
 DECLARE tablerow50abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow16(ncalc=i2) = f8 WITH protect
 DECLARE tablerow16abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow63(ncalc=i2) = f8 WITH protect
 DECLARE tablerow63abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow59(ncalc=i2) = f8 WITH protect
 DECLARE tablerow59abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow57(ncalc=i2) = f8 WITH protect
 DECLARE tablerow57abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow3(ncalc=i2) = f8 WITH protect
 DECLARE tablerow3abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow4(ncalc=i2) = f8 WITH protect
 DECLARE tablerow4abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footpagesectionspecimenlabelabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footpagesectionnonlabel(ncalc=i2) = f8 WITH protect
 DECLARE tablerow17(ncalc=i2) = f8 WITH protect
 DECLARE tablerow17abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow44(ncalc=i2) = f8 WITH protect
 DECLARE tablerow44abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow1(ncalc=i2) = f8 WITH protect
 DECLARE tablerow1abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footpagesectionnonlabelabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE futureorderwatermark(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE futureorderwatermarkabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = h WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yshift = f8 WITH noconstant(0.0), protect
 DECLARE _xshift = f8 WITH noconstant(0.0), protect
 DECLARE _sendto = vc WITH noconstant( $OUTDEV), protect
 DECLARE _rpterr = i2 WITH noconstant(0), protect
 DECLARE _rptstat = i2 WITH noconstant(0), protect
 DECLARE _oldfont = i4 WITH noconstant(0), protect
 DECLARE _oldpen = i4 WITH noconstant(0), protect
 DECLARE _dummyfont = i4 WITH noconstant(0), protect
 DECLARE _dummypen = i4 WITH noconstant(0), protect
 DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
 DECLARE _rptpage = h WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontorderdetailmulti = i2 WITH noconstant(0), protect
 DECLARE _bconttablerow61 = i2 WITH noconstant(0), protect
 DECLARE _remmultiaoeval = i4 WITH noconstant(1), protect
 DECLARE _bcontdxcodes = i2 WITH noconstant(0), protect
 DECLARE _bconttablerow21 = i2 WITH noconstant(0), protect
 DECLARE _remdiagname = i4 WITH noconstant(1), protect
 DECLARE _bcontordercomment = i2 WITH noconstant(0), protect
 DECLARE _bconttablerow56 = i2 WITH noconstant(0), protect
 DECLARE _remordcommentval = i4 WITH noconstant(1), protect
 DECLARE _remwater_mark = i4 WITH noconstant(1), protect
 DECLARE _bcontfutureorderwatermark = i2 WITH noconstant(0), protect
 DECLARE _helvetica90 = i4 WITH noconstant(0), protect
 DECLARE _helvetica14b0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica14b16777215 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _helvetica60 = i4 WITH noconstant(0), protect
 DECLARE _helvetica100 = i4 WITH noconstant(0), protect
 DECLARE _helvetica9b0 = i4 WITH noconstant(0), protect
 DECLARE _times7215395562 = i4 WITH noconstant(0), protect
 DECLARE _helvetica80 = i4 WITH noconstant(0), protect
 DECLARE _pen1s0c16777215 = i4 WITH noconstant(0), protect
 DECLARE _pen14s1c0 = i4 WITH noconstant(0), protect
 DECLARE _pen13s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen0s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE query1(dummy)
   SELECT INTO "NL:"
    FROM (dummyt d1  WITH seq = value(req_data->req_qual[loopvar].ord_cnt))
    PLAN (d1
     WHERE d1.seq > 0)
    ORDER BY d1.seq
    HEAD REPORT
     _d0 = d1.seq, _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom), _fenddetail
      = (_fenddetail - footpagesectionspecimenlabel(rpt_calcheight)),
     _fdrawheight = headreportsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pageheight - rptreport->m_marginbottom)))
      CALL pagebreak(0)
     ENDIF
     dummy_val = headreportsection(rpt_render)
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
     _bcontfutureorderwatermark = 0, dummy_val = futureorderwatermarkabs(rpt_render,_xoffset,5.000,((
      rptreport->m_pageheight - rptreport->m_marginbottom) - 5.000),_bcontfutureorderwatermark),
     dummy_val = patclientinfofirst(rpt_render),
     dummy_val = patientinforemaining(rpt_render), dummy_val = orders(rpt_render), dummy_val =
     orderscontd(rpt_render),
     dummy_val = future_ord_msg(rpt_render)
    HEAD d1.seq
     order_counter = (order_counter+ 1)
     IF ((req_data->print_misc_labels_ind=1))
      IF (((curpage=1
       AND order_counter > 2) OR (curpage > 1
       AND order_counter > 6)) )
       order_counter = 0, BREAK
      ENDIF
     ENDIF
     IF ((((req_data->req_qual[loopvar].ord_qual[d1.seq].hna_order_mnemonic=req_data->req_qual[
     loopvar].ord_qual[d1.seq].ordered_as_mnemonic)) OR (size(trim(req_data->req_qual[loopvar].
       ord_qual[d1.seq].ordered_as_mnemonic))=0)) )
      test_display_name = req_data->req_qual[loopvar].ord_qual[d1.seq].hna_order_mnemonic
     ELSE
      test_display_name = concat(req_data->req_qual[loopvar].ord_qual[d1.seq].hna_order_mnemonic," (",
       req_data->req_qual[loopvar].ord_qual[d1.seq].ordered_as_mnemonic,")")
     ENDIF
     IF (size(trim(req_data->req_qual[loopvar].ord_qual[d1.seq].cpt_cd,3)) > 0
      AND size(trim(req_data->req_qual[loopvar].ord_qual[d1.seq].outbound_alias,3))=0)
      test_display_name = concat(trim(req_data->req_qual[loopvar].ord_qual[d1.seq].cpt_cd,3),"    ",
       test_display_name)
     ENDIF
     _fdrawheight = orderseparator(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ testname(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specimandetailsbold(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specimendetails(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specimentypeanddesc(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ orderdetails(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ orderdetailmulti(rpt_calcheight,((
        _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ abnstatusrequired(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ abnstatusnotrequired(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ dxcodes(rpt_calcheight,((_fenddetail -
        _yoffset) - _fdrawheight),_bholdcontinue))
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ ordercomment(rpt_calcheight,((_fenddetail -
        _yoffset) - _fdrawheight),_bholdcontinue))
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specialinstructions(rpt_calcheight))
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = orderseparator(rpt_render), _fdrawheight = testname(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specimandetailsbold(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specimendetails(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specimentypeanddesc(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ orderdetails(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ orderdetailmulti(rpt_calcheight,((
        _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ abnstatusrequired(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ abnstatusnotrequired(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ dxcodes(rpt_calcheight,((_fenddetail -
        _yoffset) - _fdrawheight),_bholdcontinue))
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ ordercomment(rpt_calcheight,((_fenddetail -
        _yoffset) - _fdrawheight),_bholdcontinue))
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specialinstructions(rpt_calcheight))
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = testname(rpt_render), _fdrawheight = specimandetailsbold(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specimendetails(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specimentypeanddesc(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ orderdetails(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ orderdetailmulti(rpt_calcheight,((
        _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ abnstatusrequired(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ abnstatusnotrequired(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ dxcodes(rpt_calcheight,((_fenddetail -
        _yoffset) - _fdrawheight),_bholdcontinue))
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ ordercomment(rpt_calcheight,((_fenddetail -
        _yoffset) - _fdrawheight),_bholdcontinue))
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specialinstructions(rpt_calcheight))
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = specimandetailsbold(rpt_render), _fdrawheight = specimendetails(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specimentypeanddesc(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ orderdetails(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ orderdetailmulti(rpt_calcheight,((
        _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ abnstatusrequired(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ abnstatusnotrequired(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ dxcodes(rpt_calcheight,((_fenddetail -
        _yoffset) - _fdrawheight),_bholdcontinue))
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ ordercomment(rpt_calcheight,((_fenddetail -
        _yoffset) - _fdrawheight),_bholdcontinue))
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specialinstructions(rpt_calcheight))
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = specimendetails(rpt_render), _fdrawheight = specimentypeanddesc(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ orderdetails(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ orderdetailmulti(rpt_calcheight,((
        _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ abnstatusrequired(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ abnstatusnotrequired(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ dxcodes(rpt_calcheight,((_fenddetail -
        _yoffset) - _fdrawheight),_bholdcontinue))
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ ordercomment(rpt_calcheight,((_fenddetail -
        _yoffset) - _fdrawheight),_bholdcontinue))
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specialinstructions(rpt_calcheight))
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = specimentypeanddesc(rpt_render), number_of_rows = ceil((cnvtreal(req_data->req_qual[
       loopvar].ord_qual[d1.seq].single_cnt)/ 3))
     FOR (ord_row = 1 TO number_of_rows)
       cell_num = (ord_row * 3)
       IF (((cell_num - 2) <= req_data->req_qual[loopvar].ord_qual[d1.seq].single_cnt))
        order_detail->cell1 = concat(req_data->req_qual[loopvar].ord_qual[d1.seq].single_details[(
         cell_num - 2)].label_text,": ",req_data->req_qual[loopvar].ord_qual[d1.seq].single_details[(
         cell_num - 2)].value)
       ELSE
        order_detail->cell1 = ""
       ENDIF
       IF (((cell_num - 1) <= req_data->req_qual[loopvar].ord_qual[d1.seq].single_cnt))
        order_detail->cell2 = concat(req_data->req_qual[loopvar].ord_qual[d1.seq].single_details[(
         cell_num - 1)].label_text,": ",req_data->req_qual[loopvar].ord_qual[d1.seq].single_details[(
         cell_num - 1)].value)
       ELSE
        order_detail->cell2 = ""
       ENDIF
       IF ((cell_num <= req_data->req_qual[loopvar].ord_qual[d1.seq].single_cnt))
        order_detail->cell3 = concat(req_data->req_qual[loopvar].ord_qual[d1.seq].single_details[
         cell_num].label_text,": ",req_data->req_qual[loopvar].ord_qual[d1.seq].single_details[
         cell_num].value)
       ELSE
        order_detail->cell3 = ""
       ENDIF
       _fdrawheight = orderdetails(rpt_calcheight)
       IF (_fdrawheight > 0)
        IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
         _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ orderdetailmulti(rpt_calcheight,((
          _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
         IF (_bholdcontinue=1)
          _fdrawheight = (_fenddetail+ 1)
         ENDIF
        ENDIF
        IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
         _fdrawheight = (_fdrawheight+ abnstatusrequired(rpt_calcheight))
        ENDIF
        IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
         _fdrawheight = (_fdrawheight+ abnstatusnotrequired(rpt_calcheight))
        ENDIF
        IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
         _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ dxcodes(rpt_calcheight,((_fenddetail -
          _yoffset) - _fdrawheight),_bholdcontinue))
         IF (_bholdcontinue=1)
          _fdrawheight = (_fenddetail+ 1)
         ENDIF
        ENDIF
        IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
         _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ ordercomment(rpt_calcheight,((_fenddetail
           - _yoffset) - _fdrawheight),_bholdcontinue))
         IF (_bholdcontinue=1)
          _fdrawheight = (_fenddetail+ 1)
         ENDIF
        ENDIF
        IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
         _fdrawheight = (_fdrawheight+ specialinstructions(rpt_calcheight))
        ENDIF
       ENDIF
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ENDIF
       dummy_val = orderdetails(rpt_render)
     ENDFOR
     ord_row = 0
     FOR (mulord_row = 1 TO req_data->req_qual[loopvar].ord_qual[d1.seq].detail_cnt)
       IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].details[mulord_row].multi_select=1))
        _bcontorderdetailmulti = 0, bfirsttime = 1
        WHILE (((_bcontorderdetailmulti=1) OR (bfirsttime=1)) )
          _bholdcontinue = _bcontorderdetailmulti, _fdrawheight = orderdetailmulti(rpt_calcheight,(
           _fenddetail - _yoffset),_bholdcontinue)
          IF (((_bholdcontinue=1) OR (_fdrawheight > 0)) )
           IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
            _fdrawheight = (_fdrawheight+ abnstatusrequired(rpt_calcheight))
           ENDIF
           IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
            _fdrawheight = (_fdrawheight+ abnstatusnotrequired(rpt_calcheight))
           ENDIF
           IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
            _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ dxcodes(rpt_calcheight,((_fenddetail -
             _yoffset) - _fdrawheight),_bholdcontinue))
            IF (_bholdcontinue=1)
             _fdrawheight = (_fenddetail+ 1)
            ENDIF
           ENDIF
           IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
            _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ ordercomment(rpt_calcheight,((
             _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
            IF (_bholdcontinue=1)
             _fdrawheight = (_fenddetail+ 1)
            ENDIF
           ENDIF
           IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
            _fdrawheight = (_fdrawheight+ specialinstructions(rpt_calcheight))
           ENDIF
          ENDIF
          IF (((_yoffset+ _fdrawheight) > _fenddetail))
           BREAK
          ENDIF
          dummy_val = orderdetailmulti(rpt_render,(_fenddetail - _yoffset),_bcontorderdetailmulti),
          bfirsttime = 0
        ENDWHILE
       ENDIF
     ENDFOR
     mulord_row = 0, _fdrawheight = abnstatusrequired(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ abnstatusnotrequired(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ dxcodes(rpt_calcheight,((_fenddetail -
        _yoffset) - _fdrawheight),_bholdcontinue))
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ ordercomment(rpt_calcheight,((_fenddetail -
        _yoffset) - _fdrawheight),_bholdcontinue))
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specialinstructions(rpt_calcheight))
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = abnstatusrequired(rpt_render), _fdrawheight = abnstatusnotrequired(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ dxcodes(rpt_calcheight,((_fenddetail -
        _yoffset) - _fdrawheight),_bholdcontinue))
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ ordercomment(rpt_calcheight,((_fenddetail -
        _yoffset) - _fdrawheight),_bholdcontinue))
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ specialinstructions(rpt_calcheight))
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = abnstatusnotrequired(rpt_render)
     FOR (d = 1 TO req_data->req_qual[loopvar].ord_qual[d1.seq].diag_cnt)
       diagid = req_data->req_qual[loopvar].ord_qual[d1.seq].diag[d].source_id, diagname = req_data->
       req_qual[loopvar].ord_qual[d1.seq].diag[d].nomen_name, maxheight_dxcodes = 2.310,
       _bcontdxcodes = 0, bfirsttime = 1
       WHILE (((_bcontdxcodes=1) OR (bfirsttime=1)) )
         _bholdcontinue = _bcontdxcodes, _fdrawheight = dxcodes(rpt_calcheight,(_fenddetail -
          _yoffset),_bholdcontinue)
         IF (((_bholdcontinue=1) OR (_fdrawheight > 0)) )
          IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
           _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ ordercomment(rpt_calcheight,((
            _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
           IF (_bholdcontinue=1)
            _fdrawheight = (_fenddetail+ 1)
           ENDIF
          ENDIF
          IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
           _fdrawheight = (_fdrawheight+ specialinstructions(rpt_calcheight))
          ENDIF
         ENDIF
         IF (((_yoffset+ _fdrawheight) > _fenddetail))
          BREAK
         ENDIF
         IF ((maxheight_dxcodes < (_fenddetail - _yoffset)))
          dummy_val = dxcodes(rpt_render,maxheight_dxcodes,_bcontdxcodes), _bcontdxcodes = 0
         ELSE
          dummy_val = dxcodes(rpt_render,(_fenddetail - _yoffset),_bcontdxcodes), maxheight_dxcodes
           = (maxheight_dxcodes - dummy_val)
         ENDIF
         bfirsttime = 0
       ENDWHILE
     ENDFOR
     d = 0, _bcontordercomment = 0, bfirsttime = 1
     WHILE (((_bcontordercomment=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontordercomment, _fdrawheight = ordercomment(rpt_calcheight,(_fenddetail
         - _yoffset),_bholdcontinue)
       IF (((_bholdcontinue=1) OR (_fdrawheight > 0)) )
        IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
         _fdrawheight = (_fdrawheight+ specialinstructions(rpt_calcheight))
        ENDIF
       ENDIF
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontordercomment=0)
        BREAK
       ENDIF
       dummy_val = ordercomment(rpt_render,(_fenddetail - _yoffset),_bcontordercomment), bfirsttime
        = 0
     ENDWHILE
     _fdrawheight = specialinstructions(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = specialinstructions(rpt_render)
    DETAIL
     row + 0
    FOOT  d1.seq
     row + 0
    FOOT PAGE
     _yhold = _yoffset, _yoffset = _fenddetail, dummy_val = footpagesectionspecimenlabel(rpt_render),
     dummy_val = footpagesectionnonlabelabs(rpt_render,_xoffset,10.300), _yoffset = _yhold
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE finalizereport(ssendreport)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptstat = uar_rptendreport(_hreport)
   DECLARE sfilename = vc WITH noconstant(trim(ssendreport)), private
   DECLARE bprint = i2 WITH noconstant(0), private
   IF (textlen(sfilename) > 0)
    SET bprint = checkqueue(sfilename)
    IF (bprint)
     EXECUTE cpm_create_file_name "RPT", "PS"
     SET sfilename = cpm_cfn_info->file_name_path
    ENDIF
   ENDIF
   SET _rptstat = uar_rptprinttofile(_hreport,nullterm(sfilename))
   IF (bprint)
    SET spool value(sfilename) value(ssendreport) WITH dio = value(_diotype)
   ENDIF
   DECLARE _errorfound = i2 WITH noconstant(0), protect
   DECLARE _errcnt = i2 WITH noconstant(0), protect
   SET _errorfound = uar_rptfirsterror(_hreport,rpterror)
   WHILE (_errorfound=rpt_errorfound
    AND _errcnt < 512)
     SET _errcnt = (_errcnt+ 1)
     SET stat = alterlist(rpterrors->errors,_errcnt)
     SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
     SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
     SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
     SET _errorfound = uar_rptnexterror(_hreport,rpterror)
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE headreportsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headreportsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow25(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow25abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow25abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.258230), private
   DECLARE __clientnameval = vc WITH noconstant(build(req_data->organization.org_name,char(0))),
   protect
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 4.938
   SET rptsd->m_height = 0.259
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica14b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__clientnameval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.050)
   SET rptsd->m_width = 2.938
   SET rptsd->m_height = 0.259
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.050),offsety,(offsetx+ 5.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow26(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow26abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow26abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.188019), private
   DECLARE __acctnbrvalue = vc WITH noconstant(build(trim(req_data->req_qual[loopvar].
      loc_nurse_unit_alias,3),char(0))), protect
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.189
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Account #",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.738)
   SET rptsd->m_width = 3.375
   SET rptsd->m_height = 0.189
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__acctnbrvalue)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.113)
   SET rptsd->m_width = 3.876
   SET rptsd->m_height = 0.189
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.737),offsety,(offsetx+ 0.737),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.112),offsety,(offsetx+ 4.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow27(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow27abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow27abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.186741), private
   DECLARE __clientstreetaddr1and2val = vc WITH noconstant(build(concat(req_data->organization.
      street_addr," ",req_data->organization.street_addr2),char(0))), protect
   DECLARE __barcodetxt = vc WITH noconstant(build(
     IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=1)) req_data->mrn
     ELSE req_data->req_qual[loopvar].ord_qual[d1.seq].req_text
     ENDIF
     ,char(0))), protect
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 4.001
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__clientstreetaddr1and2val)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.113)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 1040
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.738)
   SET rptsd->m_width = 3.250
   SET rptsd->m_height = 0.187
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__barcodetxt)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.113),offsety,(offsetx+ 4.113),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.738),offsety,(offsetx+ 4.738),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow32(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow32abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow32abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.188019), private
   DECLARE __clientcitystatezipval = vc WITH noconstant(build(concat(req_data->organization.city,", ",
      req_data->organization.state," ",req_data->organization.zipcode),char(0))), protect
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 4.000
   SET rptsd->m_height = 0.189
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__clientcitystatezipval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.113)
   SET rptsd->m_width = 0.605
   SET rptsd->m_height = 0.189
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 528
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.717)
   SET rptsd->m_width = 3.271
   SET rptsd->m_height = 0.189
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.112),offsety,(offsetx+ 4.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.717),offsety,(offsetx+ 4.717),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow33(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow33abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow33abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.197114), private
   DECLARE __clientphoneval = vc WITH noconstant(build(concat("Phone: ",cnvtphone(req_data->
       organization.phone_num,req_data->organization.phone_format_cd,2)),char(0))), protect
   DECLARE __locationval = vc WITH noconstant(build(
     IF ((req_data->req_qual[loopvar].collected_ind=1)) "In Office"
     ELSE "At Service Center"
     ENDIF
     ,char(0))), protect
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 4.000
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__clientphoneval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.113)
   SET rptsd->m_width = 0.605
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.717)
   SET rptsd->m_width = 0.584
   SET rptsd->m_height = 0.198
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.300)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Specimen Collected:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.488)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__locationval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.112),offsety,(offsetx+ 4.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.717),offsety,(offsetx+ 4.717),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.300),offsety,(offsetx+ 5.300),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.488),offsety,(offsetx+ 6.488),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow35(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow35abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow35abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.169378), private
   DECLARE __clientfaxval = vc WITH noconstant(build(concat("Fax: ",cnvtphone(req_data->organization.
       fax_num,req_data->organization.fax_format_cd,2)),char(0))), protect
   DECLARE __accnbrval = vc WITH noconstant(build(
     IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind != 1)) req_data->req_qual[loopvar].
      req_control_nbr
     ENDIF
     ,char(0))), protect
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 4.000
   SET rptsd->m_height = 0.170
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__clientfaxval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.113)
   SET rptsd->m_width = 0.001
   SET rptsd->m_height = 0.170
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.113)
   SET rptsd->m_width = 0.605
   SET rptsd->m_height = 0.170
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.717)
   SET rptsd->m_width = 0.584
   SET rptsd->m_height = 0.170
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.300)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.170
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Accession #:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.488)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = 0.170
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__accnbrval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.112),offsety,(offsetx+ 4.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.113),offsety,(offsetx+ 4.113),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.717),offsety,(offsetx+ 4.717),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.300),offsety,(offsetx+ 5.300),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.488),offsety,(offsetx+ 6.488),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow36(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow36abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow36abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.197916), private
   DECLARE __ordprovnameval = vc WITH noconstant(build(req_data->req_qual[loopvar].order_provider.
     name_full,char(0))), protect
   DECLARE __supphys = vc WITH noconstant(build(req_data->req_qual[loopvar].sup_physician.name_full,
     char(0))), protect
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 1.875
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Ord Phys (Electronically Signed):",
      char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.988)
   SET rptsd->m_width = 2.126
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ordprovnameval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.113)
   SET rptsd->m_width = 0.605
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.717)
   SET rptsd->m_width = 0.584
   SET rptsd->m_height = 0.198
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.300)
   SET rptsd->m_width = 0.688
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Sup Phys:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.988)
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__supphys)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.987),offsety,(offsetx+ 1.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.113),offsety,(offsetx+ 4.113),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.717),offsety,(offsetx+ 4.717),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.300),offsety,(offsetx+ 5.300),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.988),offsety,(offsetx+ 5.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow34(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow34abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow34abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.177084), private
   DECLARE __ordprovnpival = vc WITH noconstant(build(req_data->req_qual[loopvar].order_provider.npi,
     char(0))), protect
   DECLARE __ordprovdocupinval = vc WITH noconstant(build(req_data->req_qual[loopvar].order_provider.
     docupin,char(0))), protect
   DECLARE __supphysnpi = vc WITH noconstant(build(req_data->req_qual[loopvar].sup_physician.npi,char
     (0))), protect
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.178
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("NPI:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.426)
   SET rptsd->m_width = 0.813
   SET rptsd->m_height = 0.178
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ordprovnpival)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.238)
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.178
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->req_qual[loopvar].order_provider.docupin != " "))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("UPIN:",char(0)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.613)
   SET rptsd->m_width = 2.500
   SET rptsd->m_height = 0.178
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ordprovdocupinval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.113)
   SET rptsd->m_width = 0.001
   SET rptsd->m_height = 0.178
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.113)
   SET rptsd->m_width = 0.605
   SET rptsd->m_height = 0.178
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.717)
   SET rptsd->m_width = 0.584
   SET rptsd->m_height = 0.178
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.300)
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.178
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("NPI:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.675)
   SET rptsd->m_width = 1.563
   SET rptsd->m_height = 0.178
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__supphysnpi)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 7.238)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.178
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),offsety,(offsetx+ 0.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.238),offsety,(offsetx+ 1.238),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.613),offsety,(offsetx+ 1.613),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.113),offsety,(offsetx+ 4.113),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.113),offsety,(offsetx+ 4.113),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.717),offsety,(offsetx+ 4.717),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.300),offsety,(offsetx+ 5.300),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.675),offsety,(offsetx+ 5.675),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.238),offsety,(offsetx+ 7.238),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headreportsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.630000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.063)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.063)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow25(rpt_render))
     SET holdheight = (holdheight+ tablerow26(rpt_render))
     SET holdheight = (holdheight+ tablerow27(rpt_render))
     SET holdheight = (holdheight+ tablerow32(rpt_render))
     SET holdheight = (holdheight+ tablerow33(rpt_render))
     SET holdheight = (holdheight+ tablerow35(rpt_render))
     SET holdheight = (holdheight+ tablerow36(rpt_render))
     SET holdheight = (holdheight+ tablerow34(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _dummypen = uar_rptsetpen(_hreport,_pen13s0c0)
    SET _rptdummy = uar_rptbarcodeinit(rptbce,rpt_code128,(offsetx+ 5.050),(offsety+ 0.063))
    SET rptbce->m_recsize = 88
    SET rptbce->m_width = 2.88
    SET rptbce->m_height = 0.50
    SET rptbce->m_rotation = 0
    SET rptbce->m_ratio = 300
    SET rptbce->m_barwidth = 1
    SET rptbce->m_bscale = 1
    SET rptbce->m_bprintinterp = 0
    SET rptbce->m_startchar = "*"
    SET rptbce->m_endchar = "*"
    SET _rptstat = uar_rptbarcodeex(_hreport,rptbce,build2(
      IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=1)) req_data->mrn
      ELSE concat("*",req_data->req_qual[loopvar].ord_qual[d1.seq].req_text,"*")
      ENDIF
      ,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE patientinforemaining(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = patientinforemainingabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow46(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow46abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow46abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.229167), private
   DECLARE __acctnbrvalue = vc WITH noconstant(build(trim(req_data->req_qual[loopvar].
      loc_nurse_unit_alias,3),char(0))), protect
   DECLARE __accnbrheadval = vc WITH noconstant(build(req_data->req_qual[loopvar].req_control_nbr,
     char(0))), protect
   DECLARE __ordprovnameval = vc WITH noconstant(build(req_data->req_qual[loopvar].order_provider.
     name_full,char(0))), protect
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.230
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Account #:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.738)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.230
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__acctnbrvalue)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.863)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.230
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Accession #:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.613)
   SET rptsd->m_width = 1.563
   SET rptsd->m_height = 0.230
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__accnbrheadval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.175)
   SET rptsd->m_width = 1.875
   SET rptsd->m_height = 0.230
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Ord Phys (Electronically Signed):",
      char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.050)
   SET rptsd->m_width = 1.938
   SET rptsd->m_height = 0.230
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ordprovnameval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.737),offsety,(offsetx+ 0.737),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.862),offsety,(offsetx+ 1.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.612),offsety,(offsetx+ 2.612),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.175),offsety,(offsetx+ 4.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.050),offsety,(offsetx+ 6.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow47(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow47abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow47abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.208333), private
   DECLARE __patnamehead = vc WITH noconstant(build(req_data->name_full_formatted,char(0))), protect
   DECLARE __patmrnhead = vc WITH noconstant(build(trim(req_data->cdf_meaning_mrn,3),char(0))),
   protect
   DECLARE __patmrnlbl = vc WITH noconstant(build(req_data->mrn,char(0))), protect
   DECLARE __patfinhead = vc WITH noconstant(build(req_data->fin,char(0))), protect
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 4.063
   SET rptsd->m_height = 0.209
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patnamehead)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.175)
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.209
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patmrnhead)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.675)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = 0.209
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patmrnlbl)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.925)
   SET rptsd->m_width = 0.250
   SET rptsd->m_height = 0.209
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("FIN:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.175)
   SET rptsd->m_width = 1.813
   SET rptsd->m_height = 0.209
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patfinhead)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.175),offsety,(offsetx+ 4.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.675),offsety,(offsetx+ 4.675),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.925),offsety,(offsetx+ 5.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.175),offsety,(offsetx+ 6.175),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE patientinforemainingabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT (curpage > 1))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.063)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.063)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow46(rpt_render))
     SET holdheight = (holdheight+ tablerow47(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE patclientinfofirst(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = patclientinfofirstabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow5(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow5abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow5abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.310374), private
   DECLARE __patientnameval = vc WITH noconstant(build(req_data->name_full_formatted,char(0))),
   protect
   DECLARE __billtoval = vc WITH noconstant(build(req_data->bill_to,char(0))), protect
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = bor(bor(rpt_sdtopborder,rpt_sdbottomborder),rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 5.438
   SET rptsd->m_height = 0.311
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica14b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(234,234,234))
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientnameval)
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = bor(bor(rpt_sdtopborder,rpt_sdbottomborder),rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.550)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.311
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica14b16777215)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,rpt_black)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Bill To:",char(0)))
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = bor(bor(rpt_sdtopborder,rpt_sdbottomborder),rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.300)
   SET rptsd->m_width = 1.688
   SET rptsd->m_height = 0.311
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,rpt_black)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__billtoval)
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.550),offsety,(offsetx+ 5.550),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.300),offsety,(offsetx+ 6.300),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow6(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow6abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow6abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.190922), private
   DECLARE __patientdobval = vc WITH noconstant(build(format(cnvtdatetimeutc(datetimezone(req_data->
        birth_dt_tm,req_data->birth_tz),1),"MM/DD/YYYY;;d"),char(0))), protect
   DECLARE __patageval = vc WITH noconstant(build(cnvtage(req_data->birth_dt_tm),char(0))), protect
   DECLARE __patientgenderval = vc WITH noconstant(build(uar_get_code_display(req_data->sex_cd),char(
      0))), protect
   DECLARE __patientssnval = vc WITH noconstant(build(req_data->ssn,char(0))), protect
   DECLARE __patmrn = vc WITH noconstant(build(trim(req_data->cdf_meaning_mrn,3),char(0))), protect
   DECLARE __patientmrnval = vc WITH noconstant(build(req_data->mrn,char(0))), protect
   DECLARE __patientfinval = vc WITH noconstant(build(req_data->fin,char(0))), protect
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 0.438
   SET rptsd->m_height = 0.191
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("DOB:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.551)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.191
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientdobval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.551)
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.191
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Age:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.926)
   SET rptsd->m_width = 0.625
   SET rptsd->m_height = 0.191
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patageval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.551)
   SET rptsd->m_width = 0.563
   SET rptsd->m_height = 0.191
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Gender:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.113)
   SET rptsd->m_width = 0.813
   SET rptsd->m_height = 0.191
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientgenderval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.926)
   SET rptsd->m_width = 0.438
   SET rptsd->m_height = 0.191
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("SSN#",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.363)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = 0.191
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientssnval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.301)
   SET rptsd->m_width = 0.563
   SET rptsd->m_height = 0.191
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patmrn)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.863)
   SET rptsd->m_width = 0.751
   SET rptsd->m_height = 0.191
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientmrnval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.613)
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.191
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("FIN:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.988)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.191
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientfinval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.550),offsety,(offsetx+ 0.550),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.550),offsety,(offsetx+ 1.550),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.925),offsety,(offsetx+ 1.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.550),offsety,(offsetx+ 2.550),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.113),offsety,(offsetx+ 3.113),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.925),offsety,(offsetx+ 3.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.363),offsety,(offsetx+ 4.363),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.300),offsety,(offsetx+ 5.300),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.863),offsety,(offsetx+ 5.863),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.613),offsety,(offsetx+ 6.613),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.988),offsety,(offsetx+ 6.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow10(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow10abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow10abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.184566), private
   DECLARE __patientaddrval = vc WITH noconstant(build(req_data->address.street_addr,char(0))),
   protect
   DECLARE __patientphoneval = vc WITH noconstant(build(cnvtphone(req_data->phone.number,req_data->
      phone.format_cd,2),char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdrightborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.185
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Address:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.113)
   SET rptsd->m_width = 4.188
   SET rptsd->m_height = 0.185
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientaddrval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.301)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.185
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Home Phone:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.426)
   SET rptsd->m_width = 1.563
   SET rptsd->m_height = 0.185
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientphoneval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.112),offsety,(offsetx+ 1.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.300),offsety,(offsetx+ 5.300),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.425),offsety,(offsetx+ 6.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow9(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow9abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow9abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187554), private
   DECLARE __patientcitystatezipval = vc WITH noconstant(build(concat(req_data->address.city,", ",
      req_data->address.state," ",req_data->address.zipcode),char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdleftborder)
   SET rptsd->m_padding = bor(rpt_sdleftborder,rpt_sdrightborder)
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("City, State Zip:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.113)
   SET rptsd->m_width = 4.188
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patientcitystatezipval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.301)
   SET rptsd->m_width = 0.313
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.613)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.613)
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.988)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.112),offsety,(offsetx+ 1.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.300),offsety,(offsetx+ 5.300),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.613),offsety,(offsetx+ 5.613),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.613),offsety,(offsetx+ 6.613),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.988),offsety,(offsetx+ 6.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow7(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow7abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow7abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.249138), private
   DECLARE __primaryinsnameval = vc WITH noconstant(build(insurance_data->carrier_1,char(0))),
   protect
   DECLARE __secondaryinsnameval = vc WITH noconstant(build(insurance_data->carrier_2,char(0))),
   protect
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(234,234,234))
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Primary Insurance:",char(0)))
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.363)
   SET rptsd->m_width = 2.625
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(234,234,234))
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__primaryinsnameval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.988)
   SET rptsd->m_width = 1.438
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(234,234,234))
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Secondary Insurance:",char(0)))
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.425)
   SET rptsd->m_width = 2.563
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(234,234,234))
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__secondaryinsnameval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.362),offsety,(offsetx+ 1.362),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.987),offsety,(offsetx+ 3.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.425),offsety,(offsetx+ 5.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow11(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow11abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow11abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187056), private
   DECLARE __ins1billtypeval = vc WITH noconstant(build(insurance_data->bill_type_1,char(0))),
   protect
   DECLARE __ins2billtypeval = vc WITH noconstant(build(insurance_data->bill_type_2,char(0))),
   protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Bill Type:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.113)
   SET rptsd->m_width = 2.876
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins1billtypeval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.988)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Bill Type:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.988)
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins2billtypeval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.112),offsety,(offsetx+ 1.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.988),offsety,(offsetx+ 3.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.988),offsety,(offsetx+ 4.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow38(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow38abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow38abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187056), private
   DECLARE __ins1codeval = vc WITH noconstant(build(insurance_data->ins_std_code_1,char(0))), protect
   DECLARE __ins2codeval = vc WITH noconstant(build(insurance_data->ins_std_code_2,char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Code:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.113)
   SET rptsd->m_width = 2.876
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins1codeval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.988)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Code:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.988)
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins2codeval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.112),offsety,(offsetx+ 1.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.988),offsety,(offsetx+ 3.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.988),offsety,(offsetx+ 4.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow12(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow12abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow12abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187056), private
   DECLARE __ins1addrval = vc WITH noconstant(build(insurance_data->carrier_street_addr_1,char(0))),
   protect
   DECLARE __ins2addrval = vc WITH noconstant(build(insurance_data->carrier_street_addr_2,char(0))),
   protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Address:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.113)
   SET rptsd->m_width = 2.876
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins1addrval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.988)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Address:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.988)
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins2addrval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.112),offsety,(offsetx+ 1.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.988),offsety,(offsetx+ 3.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.988),offsety,(offsetx+ 4.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow13(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow13abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow13abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187056), private
   DECLARE __ins1citystatezipval = vc WITH noconstant(build(insurance_data->carrier_citystatezip_1,
     char(0))), protect
   DECLARE __ins2citystatezipval = vc WITH noconstant(build(insurance_data->carrier_citystatezip_2,
     char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("City, State Zip:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.113)
   SET rptsd->m_width = 2.876
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins1citystatezipval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.988)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("City, State Zip:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.988)
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins2citystatezipval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.112),offsety,(offsetx+ 1.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.988),offsety,(offsetx+ 3.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.988),offsety,(offsetx+ 4.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow14(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow14abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow14abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187056), private
   DECLARE __ins1policynbrval = vc WITH noconstant(build(
     IF (textlen(trim(insurance_data->sub_nbr_1,3)) > 0) insurance_data->sub_nbr_1
     ELSE insurance_data->ins_nbr_1
     ENDIF
     ,char(0))), protect
   DECLARE __ins2policynbrval = vc WITH noconstant(build(
     IF (textlen(trim(insurance_data->sub_nbr_2,3)) > 0) insurance_data->sub_nbr_2
     ELSE insurance_data->ins_nbr_2
     ENDIF
     ,char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Policy Number:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.113)
   SET rptsd->m_width = 2.876
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins1policynbrval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.988)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Policy Number:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.988)
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins2policynbrval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.112),offsety,(offsetx+ 1.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.988),offsety,(offsetx+ 3.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.988),offsety,(offsetx+ 4.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow15(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow15abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow15abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187056), private
   DECLARE __ins1groupnbrval = vc WITH noconstant(build(insurance_data->ins_grp_nbr_1,char(0))),
   protect
   DECLARE __ins2groupnbrval = vc WITH noconstant(build(insurance_data->ins_grp_nbr_2,char(0))),
   protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Group Number:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.113)
   SET rptsd->m_width = 2.876
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins1groupnbrval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.988)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Group Number:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.988)
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins2groupnbrval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.112),offsety,(offsetx+ 1.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.988),offsety,(offsetx+ 3.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.988),offsety,(offsetx+ 4.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow37(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow37abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow37abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187056), private
   DECLARE __ins1subval = vc WITH noconstant(build(insurance_data->resp_party_1,char(0))), protect
   DECLARE __ins2subval = vc WITH noconstant(build(insurance_data->resp_party_2,char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = bor(rpt_sdtopborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Subscriber:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdtopborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.113)
   SET rptsd->m_width = 2.876
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins1subval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = bor(rpt_sdtopborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.988)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Subscriber:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = bor(rpt_sdtopborder,rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.988)
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins2subval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.112),offsety,(offsetx+ 1.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.988),offsety,(offsetx+ 3.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.988),offsety,(offsetx+ 4.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow24(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow24abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow24abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187056), private
   DECLARE __ins1subdobval = vc WITH noconstant(build(insurance_data->resp_dob_1,char(0))), protect
   DECLARE __ins2subdobval = vc WITH noconstant(build(insurance_data->resp_dob_2,char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("DOB:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.113)
   SET rptsd->m_width = 2.876
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins1subdobval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.988)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("DOB:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.988)
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins2subdobval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.112),offsety,(offsetx+ 1.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.988),offsety,(offsetx+ 3.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.988),offsety,(offsetx+ 4.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow20(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow20abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow20abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187056), private
   DECLARE __ins1reltnval = vc WITH noconstant(build(insurance_data->reltn_1,char(0))), protect
   DECLARE __ins2reltnval = vc WITH noconstant(build(insurance_data->reltn_2,char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Relationship:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.113)
   SET rptsd->m_width = 2.876
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins1reltnval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.988)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Relationship:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.988)
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins2reltnval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.112),offsety,(offsetx+ 1.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.988),offsety,(offsetx+ 3.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.988),offsety,(offsetx+ 4.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow54(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow54abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow54abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.197217), private
   DECLARE __ins1subaddrval = vc WITH noconstant(build(insurance_data->resp_street_addr_1,char(0))),
   protect
   DECLARE __ins2subaddrval = vc WITH noconstant(build(insurance_data->resp_street_addr_2,char(0))),
   protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Address:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.113)
   SET rptsd->m_width = 2.876
   SET rptsd->m_height = 0.198
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins1subaddrval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.988)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.198
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Address:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.988)
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = 0.198
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins2subaddrval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.112),offsety,(offsetx+ 1.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.988),offsety,(offsetx+ 3.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.988),offsety,(offsetx+ 4.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow8(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow8abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow8abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.197217), private
   DECLARE __ins1subcitystatezipval = vc WITH noconstant(build(insurance_data->resp_citystatezip_1,
     char(0))), protect
   DECLARE __ins2subcitystatezipval = vc WITH noconstant(build(insurance_data->resp_citystatezip_2,
     char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("City, State Zip:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.113)
   SET rptsd->m_width = 2.876
   SET rptsd->m_height = 0.198
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins1subcitystatezipval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.988)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.198
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("City, State Zip:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.988)
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = 0.198
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->insurance_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ins2subcitystatezipval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.112),offsety,(offsetx+ 1.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.988),offsety,(offsetx+ 3.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.988),offsety,(offsetx+ 4.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow40(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow40abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow40abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.197277), private
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = bor(bor(rpt_sdbottomborder,rpt_sdleftborder),rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 7.875
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(234,234,234))
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Responsible Party / Guarantor",char(0)
      ))
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow41(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow41abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow41abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.197277), private
   DECLARE __rpguarnameval = vc WITH noconstant(build(req_data->guarantor.name_full_formatted,char(0)
     )), protect
   DECLARE __rpguardobval = vc WITH noconstant(build(format(cnvtdatetimeutc(datetimezone(req_data->
        guarantor.birth_dt_tm,req_data->guarantor.birth_tz),1),"MM/DD/YYYY;;d"),char(0))), protect
   DECLARE __rpguarreltnval = vc WITH noconstant(build(uar_get_code_display(req_data->guarantor.
      reltn_cd),char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Name:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.113)
   SET rptsd->m_width = 2.876
   SET rptsd->m_height = 0.198
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->bill_to_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__rpguarnameval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.988)
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.198
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("DOB:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.363)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = 0.198
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->bill_to_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__rpguardobval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.613)
   SET rptsd->m_width = 0.813
   SET rptsd->m_height = 0.198
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Relationship:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.426)
   SET rptsd->m_width = 1.563
   SET rptsd->m_height = 0.198
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->bill_to_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__rpguarreltnval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.112),offsety,(offsetx+ 1.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.988),offsety,(offsetx+ 3.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.363),offsety,(offsetx+ 4.363),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.613),offsety,(offsetx+ 5.613),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.425),offsety,(offsetx+ 6.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow42(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow42abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow42abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.197277), private
   DECLARE __rpguaraddrval = vc WITH noconstant(build(req_data->guarantor.address.street_addr,char(0)
     )), protect
   DECLARE __rpguarssnval = vc WITH noconstant(build(req_data->guarantor.ssn,char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdleftborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Address:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.113)
   SET rptsd->m_width = 4.501
   SET rptsd->m_height = 0.198
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->bill_to_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__rpguaraddrval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.613)
   SET rptsd->m_width = 0.813
   SET rptsd->m_height = 0.198
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("SSN#",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdrightborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.426)
   SET rptsd->m_width = 1.563
   SET rptsd->m_height = 0.198
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->bill_to_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__rpguarssnval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.112),offsety,(offsetx+ 1.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.613),offsety,(offsetx+ 5.613),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.425),offsety,(offsetx+ 6.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow39(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow39abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow39abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.197265), private
   DECLARE __rpguarcitystatezipval = vc WITH noconstant(build(concat(req_data->guarantor.address.city,
      ", ",req_data->guarantor.address.state," ",req_data->guarantor.address.zipcode),char(0))),
   protect
   DECLARE __rpguarphoneval = vc WITH noconstant(build(cnvtphone(req_data->guarantor.phone.number,
      req_data->guarantor.phone.format_cd,2),char(0))), protect
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdleftborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("City, State Zip:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.113)
   SET rptsd->m_width = 4.501
   SET rptsd->m_height = 0.198
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->bill_to_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__rpguarcitystatezipval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdbottomborder
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.613)
   SET rptsd->m_width = 0.813
   SET rptsd->m_height = 0.198
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Home Phone:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = bor(rpt_sdbottomborder,rpt_sdrightborder)
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.426)
   SET rptsd->m_width = 1.563
   SET rptsd->m_height = 0.198
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->bill_to_ind=2))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__rpguarphoneval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.112),offsety,(offsetx+ 1.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.613),offsety,(offsetx+ 5.613),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.425),offsety,(offsetx+ 6.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE patclientinfofirstabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(3.970000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT (curpage=1))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.000)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.000)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow5(rpt_render))
     SET holdheight = (holdheight+ tablerow6(rpt_render))
     SET holdheight = (holdheight+ tablerow10(rpt_render))
     SET holdheight = (holdheight+ tablerow9(rpt_render))
     SET holdheight = (holdheight+ tablerow7(rpt_render))
     SET holdheight = (holdheight+ tablerow11(rpt_render))
     SET holdheight = (holdheight+ tablerow38(rpt_render))
     SET holdheight = (holdheight+ tablerow12(rpt_render))
     SET holdheight = (holdheight+ tablerow13(rpt_render))
     SET holdheight = (holdheight+ tablerow14(rpt_render))
     SET holdheight = (holdheight+ tablerow15(rpt_render))
     SET holdheight = (holdheight+ tablerow37(rpt_render))
     SET holdheight = (holdheight+ tablerow24(rpt_render))
     SET holdheight = (holdheight+ tablerow20(rpt_render))
     SET holdheight = (holdheight+ tablerow54(rpt_render))
     SET holdheight = (holdheight+ tablerow8(rpt_render))
     SET holdheight = (holdheight+ tablerow40(rpt_render))
     SET holdheight = (holdheight+ tablerow41(rpt_render))
     SET holdheight = (holdheight+ tablerow42(rpt_render))
     SET holdheight = (holdheight+ tablerow39(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE orders(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = ordersabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow22(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow22abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow22abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.057)
   SET rptsd->m_width = 7.869
   SET rptsd->m_height = 0.243
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica14b16777215)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,rpt_black)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Orders",char(0)))
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.050),offsety,(offsetx+ 0.050),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.925),offsety,(offsetx+ 7.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.050),(offsety+ 0.000),(offsetx+ 7.926),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.050),(offsety+ sectionheight),(offsetx+ 7.926),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE ordersabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT (curpage=1))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _yoffset = (offsety+ 0.125)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.125)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow22(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE future_ord_msg(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = future_ord_msgabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE future_ord_msgabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.700000), private
   IF ( NOT ((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=1)
    AND (( NOT ((req_data->req_qual[loopvar].ref_lab IN (0, 1)))) OR (uar_get_code_description(
    req_data->req_qual[loopvar].ord_qual[d1.seq].perf_loc_cd)=misc_location_description))
    AND curpage=1))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 644
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.113)
    SET rptsd->m_width = 7.688
    SET rptsd->m_height = 0.688
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "You have attempted to print a requisition for a 3rd party lab while orders are still in a Future Order state. I",
       "n this order status, orders are not literally associated to an encounter and therefore do not have the critical ",
       "identifiers in place, namely MRN or FIN. Given the increase potential for data matching errors, the ability to p",
       "rint requisitions for these orders is disabled. Please return to PowerChart and insure orders are activated for ",
       "reference labs prior to requisition printing."),char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE orderscontd(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = orderscontdabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow28(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow28abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow28abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   SET rptsd->m_flags = 288
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.120)
   SET rptsd->m_width = 7.869
   SET rptsd->m_height = 0.243
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica14b16777215)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET oldbackcolor = uar_rptsetbackcolor(_hreport,rpt_black)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Orders (Continued...)",char(0)))
   ENDIF
   SET oldbackcolor = uar_rptresetbackcolor(_hreport)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE orderscontdabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.320000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT (curpage > 1))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _yoffset = (offsety+ 0.063)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.063)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow28(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE testname(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = testnameabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow45(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow45abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow45abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.208333), private
   DECLARE __orderalias = vc WITH noconstant(build(req_data->req_qual[loopvar].ord_qual[d1.seq].
     outbound_alias,char(0))), protect
   DECLARE __testname = vc WITH noconstant(build(trim(test_display_name),char(0))), protect
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 0.563
   SET rptsd->m_height = 0.209
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__orderalias)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.676)
   SET rptsd->m_width = 7.313
   SET rptsd->m_height = 0.209
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__testname)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),offsety,(offsetx+ 0.675),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE testnameabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT ((((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)) OR ((req_data->req_qual[
   loopvar].ord_qual[d1.seq].future_ind=1)
    AND (req_data->req_qual[loopvar].ref_lab IN (0, 1))
    AND uar_get_code_description(req_data->req_qual[loopvar].ord_qual[d1.seq].perf_loc_cd) !=
   misc_location_description)) ))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.000)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.000)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow45(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE specimandetailsbold(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = specimandetailsboldabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow2(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow2abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow2abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.166667), private
   DECLARE __orderstatusval = vc WITH noconstant(build(req_data->req_qual[loopvar].ord_qual[d1.seq].
     order_status,char(0))), protect
   DECLARE __reqdatelbl = vc WITH noconstant(build(
     IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=0.00)) "Req. Coll. Dt/Tm:"
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm != null)) "Collect. Dt/Tm:"
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm=null)) "Collect. Dt/Tm:"
     ENDIF
     ,char(0))), protect
   DECLARE __requestdateval = vc WITH noconstant(build(
     IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=0.00)) concat(format(req_data->
        req_qual[loopvar].ord_qual[d1.seq].collected_dt_tm,"MM/DD/YYYY HH:MM;;q")," (est.)")
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm != null)) format(req_data->
       req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm,"MM/DD/YYYY HH:MM;;q")
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm=null)) format(req_data->req_qual[
       loopvar].ord_qual[d1.seq].collected_dt_tm,"MM/DD/YYYY HH:MM;;q")
     ENDIF
     ,char(0))), protect
   DECLARE __priorityval = vc WITH noconstant(build(uar_get_code_description(req_data->req_qual[
      loopvar].ord_qual[d1.seq].priority_cd),char(0))), protect
   SET rptsd->m_flags = 512
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.675)
   SET rptsd->m_width = 2.188
   SET rptsd->m_height = 0.167
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__orderstatusval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.863)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.167
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__reqdatelbl)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.863)
   SET rptsd->m_width = 1.563
   SET rptsd->m_height = 0.167
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__requestdateval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.425)
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.167
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((((req_data->std_ind=1)) OR ((req_data->all_ind=1))) )
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Priority:",char(0)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.925)
   SET rptsd->m_width = 2.063
   SET rptsd->m_height = 0.167
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((((req_data->std_ind=1)) OR ((req_data->all_ind=1))) )
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__priorityval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),offsety,(offsetx+ 0.675),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.862),offsety,(offsetx+ 2.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.862),offsety,(offsetx+ 3.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.425),offsety,(offsetx+ 5.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.925),offsety,(offsetx+ 5.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE specimandetailsboldabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT ((req_data->req_qual[loopvar].ord_qual[d1.seq].order_status_cd != 6004_ordered)
    AND (((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)) OR ((req_data->req_qual[
   loopvar].ord_qual[d1.seq].future_ind=1)
    AND (req_data->req_qual[loopvar].ref_lab IN (0, 1))
    AND uar_get_code_description(req_data->req_qual[loopvar].ord_qual[d1.seq].perf_loc_cd) !=
   misc_location_description)) ))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.000)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.000)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow2(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE specimendetails(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = specimendetailsabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow49(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow49abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow49abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __orderstatusval = vc WITH noconstant(build(req_data->req_qual[loopvar].ord_qual[d1.seq].
     order_status,char(0))), protect
   DECLARE __reqdatelbl = vc WITH noconstant(build(
     IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=0.00)) "Req. Coll. Dt/Tm:"
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm != null)) "Collect. Dt/Tm:"
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm=null)) "Collect. Dt/Tm:"
     ENDIF
     ,char(0))), protect
   DECLARE __requestdateval = vc WITH noconstant(build(
     IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=0.00)) concat(format(req_data->
        req_qual[loopvar].ord_qual[d1.seq].collected_dt_tm,"MM/DD/YYYY HH:MM;;q")," (est.)")
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm != null)) format(req_data->
       req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm,"MM/DD/YYYY HH:MM;;q")
     ELSEIF ((req_data->req_qual[loopvar].ord_qual[d1.seq].nurse_collect=1.00)
      AND (req_data->req_qual[loopvar].ord_qual[d1.seq].drawn_dt_tm=null)) format(req_data->req_qual[
       loopvar].ord_qual[d1.seq].collected_dt_tm,"MM/DD/YYYY HH:MM;;q")
     ENDIF
     ,char(0))), protect
   DECLARE __priorityval = vc WITH noconstant(build(uar_get_code_description(req_data->req_qual[
      loopvar].ord_qual[d1.seq].priority_cd),char(0))), protect
   SET rptsd->m_flags = 512
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.675)
   SET rptsd->m_width = 2.188
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__orderstatusval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.863)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__reqdatelbl)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.863)
   SET rptsd->m_width = 1.563
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__requestdateval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.426)
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((((req_data->std_ind=1)) OR ((req_data->all_ind=1))) )
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Priority:",char(0)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.926)
   SET rptsd->m_width = 2.063
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((((req_data->std_ind=1)) OR ((req_data->all_ind=1))) )
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__priorityval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),offsety,(offsetx+ 0.675),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.863),offsety,(offsetx+ 2.863),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.863),offsety,(offsetx+ 3.863),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.425),offsety,(offsetx+ 5.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.925),offsety,(offsetx+ 5.925),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE specimendetailsabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT ((req_data->req_qual[loopvar].ord_qual[d1.seq].order_status_cd=6004_ordered)
    AND (((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)) OR ((req_data->req_qual[
   loopvar].ord_qual[d1.seq].future_ind=1)
    AND (req_data->req_qual[loopvar].ref_lab IN (0, 1))
    AND uar_get_code_description(req_data->req_qual[loopvar].ord_qual[d1.seq].perf_loc_cd) !=
   misc_location_description)) ))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.000)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.000)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow49(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE specimentypeanddesc(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = specimentypeanddescabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow55(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow55abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow55abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __specimentypeval = vc WITH noconstant(build(uar_get_code_display(req_data->req_qual[
      loopvar].ord_qual[d1.seq].specimen_cd),char(0))), protect
   DECLARE __specdescval = vc WITH noconstant(build(req_data->req_qual[loopvar].ord_qual[d1.seq].
     specimen_description,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.675)
   SET rptsd->m_width = 1.063
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->req_qual[loopvar].collected_ind=1))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Specimen Type:",char(0)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.738)
   SET rptsd->m_width = 2.125
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->req_qual[loopvar].collected_ind=1))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__specimentypeval)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 512
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.863)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Specimen Description:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.238)
   SET rptsd->m_width = 2.563
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__specdescval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 7.800)
   SET rptsd->m_width = 0.188
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->req_qual[loopvar].collected_ind=1))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),offsety,(offsetx+ 0.675),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.737),offsety,(offsetx+ 1.737),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.862),offsety,(offsetx+ 3.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.237),offsety,(offsetx+ 5.237),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.800),offsety,(offsetx+ 7.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE specimentypeanddescabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT ((req_data->req_qual[loopvar].ord_qual[d1.seq].order_status_cd=6004_ordered)
    AND (((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)) OR ((req_data->req_qual[
   loopvar].ord_qual[d1.seq].future_ind=1)
    AND (req_data->req_qual[loopvar].ref_lab IN (0, 1))
    AND uar_get_code_description(req_data->req_qual[loopvar].ord_qual[d1.seq].perf_loc_cd) !=
   misc_location_description)) ))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.000)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.000)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow55(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE orderdetails(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = orderdetailsabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow23(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow23abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow23abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __cellname1 = vc WITH noconstant(build(order_detail->cell1,char(0))), protect
   DECLARE __cellname2 = vc WITH noconstant(build(order_detail->cell2,char(0))), protect
   DECLARE __cellname3 = vc WITH noconstant(build(order_detail->cell3,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.675)
   SET rptsd->m_width = 2.188
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname1)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.863)
   SET rptsd->m_width = 2.563
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname2)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.425)
   SET rptsd->m_width = 2.563
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cellname3)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),offsety,(offsetx+ 0.675),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.862),offsety,(offsetx+ 2.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.425),offsety,(offsetx+ 5.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE orderdetailsabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT ((req_data->req_qual[loopvar].ord_qual[d1.seq].single_cnt > 0)
    AND (((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)) OR ((req_data->req_qual[
   loopvar].ord_qual[d1.seq].future_ind=1)
    AND (req_data->req_qual[loopvar].ref_lab IN (0, 1))
    AND uar_get_code_description(req_data->req_qual[loopvar].ord_qual[d1.seq].perf_loc_cd) !=
   misc_location_description)) ))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.000)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.000)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow23(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE orderdetailmulti(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = orderdetailmultiabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow61(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow61abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow61abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE __multiaoeval = vc WITH noconstant(build(concat(req_data->req_qual[loopvar].ord_qual[d1
      .seq].details[mulord_row].label_text,": ",req_data->req_qual[loopvar].ord_qual[d1.seq].details[
      mulord_row].value),char(0))), protect
   IF (bcontinue=0)
    SET _remmultiaoeval = 1
   ENDIF
   SET rptsd->m_flags = 517
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.665)
   SET rptsd->m_width = 7.334
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremmultiaoeval = _remmultiaoeval
   IF (_remmultiaoeval > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmultiaoeval,((size(
        __multiaoeval) - _remmultiaoeval)+ 1),__multiaoeval)))
    SET drawheight_multiaoeval = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmultiaoeval = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmultiaoeval,((size(__multiaoeval) -
       _remmultiaoeval)+ 1),__multiaoeval)))))
     SET _remmultiaoeval = (_remmultiaoeval+ rptsd->m_drawlength)
    ELSE
     SET _remmultiaoeval = 0
    ENDIF
    SET growsum = (growsum+ _remmultiaoeval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 516
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.665)
   SET rptsd->m_width = 7.334
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (_holdremmultiaoeval > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmultiaoeval,((
        size(__multiaoeval) - _holdremmultiaoeval)+ 1),__multiaoeval)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remmultiaoeval = _holdremmultiaoeval
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.665),offsety,(offsetx+ 0.665),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.998),offsety,(offsetx+ 7.998),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.665),(offsety+ 0.000),(offsetx+ 7.999),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.665),(offsety+ sectionheight),(offsetx+ 7.999),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE orderdetailmultiabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF ( NOT ((req_data->req_qual[loopvar].ord_qual[d1.seq].multi_cnt > 0)
    AND (((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)) OR ((req_data->req_qual[
   loopvar].ord_qual[d1.seq].future_ind=1)
    AND (req_data->req_qual[loopvar].ref_lab IN (0, 1))
    AND uar_get_code_description(req_data->req_qual[loopvar].ord_qual[d1.seq].perf_loc_cd) !=
   misc_location_description)) ))
    RETURN(0.0)
   ENDIF
   SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET _yoffset = (offsety+ 0.000)
   SET _fholdoffsety = (_yoffset - offsety)
   IF (ncalc=rpt_calcheight
    AND bcontinue=0)
    SET _yoffset = (offsety+ 0.000)
    SET holdheight = 0
    IF (growsum=0)
     SET maxheight_tablerow61 = (maxheight - (0.000+ holdheight))
     SET _bholdcontinue = 0
     SET holdheight = (holdheight+ tablerow61(rpt_calcheight,maxheight_tablerow61,_bholdcontinue))
     IF (((_bholdcontinue=1) OR (holdheight > maxheight_tablerow61)) )
      SET growsum = 1
     ENDIF
    ENDIF
    SET _yoffset = offsety
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _yoffset = (offsety+ 0.000)
    SET holdheight = 0
    SET maxheight_tablerow61 = (maxheight - (0.000+ holdheight))
    SET _bholdcontinue = 0
    SET holdheight = (holdheight+ tablerow61(rpt_render,maxheight_tablerow61,_bholdcontinue))
    IF (((0.000+ holdheight) > sectionheight))
     SET sectionheight = (0.000+ holdheight)
    ENDIF
    SET _yoffset = offsety
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE abnstatusrequired(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = abnstatusrequiredabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow51(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow51abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow51abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __abnstatusval = vc WITH noconstant(build(req_data->req_qual[loopvar].ord_qual[d1.seq].
     abn_status,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.675)
   SET rptsd->m_width = 0.886
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("ABN Status:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.561)
   SET rptsd->m_width = 6.438
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__abnstatusval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),offsety,(offsetx+ 0.675),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.560),offsety,(offsetx+ 1.560),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.998),offsety,(offsetx+ 7.998),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),(offsety+ 0.000),(offsetx+ 7.999),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),(offsety+ sectionheight),(offsetx+ 7.999),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow52(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow52abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow52abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __abnreasonval = vc WITH noconstant(build(req_data->req_qual[loopvar].ord_qual[d1.seq].
     abn_reason,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.675)
   SET rptsd->m_width = 0.886
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("ABN Reason:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.561)
   SET rptsd->m_width = 6.438
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__abnreasonval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),offsety,(offsetx+ 0.675),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.560),offsety,(offsetx+ 1.560),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.998),offsety,(offsetx+ 7.998),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),(offsety+ 0.000),(offsetx+ 7.999),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),(offsety+ sectionheight),(offsetx+ 7.999),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE abnstatusrequiredabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT ((req_data->req_qual[loopvar].ord_qual[d1.seq].abn_ind=1)
    AND (((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)) OR ((req_data->req_qual[
   loopvar].ord_qual[d1.seq].future_ind=1)
    AND (req_data->req_qual[loopvar].ref_lab IN (0, 1))
    AND uar_get_code_description(req_data->req_qual[loopvar].ord_qual[d1.seq].perf_loc_cd) !=
   misc_location_description)) ))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.000)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.000)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow51(rpt_render))
     SET holdheight = (holdheight+ tablerow52(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE abnstatusnotrequired(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = abnstatusnotrequiredabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow53(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow53abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow53abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __abnstatusval = vc WITH noconstant(build(req_data->req_qual[loopvar].ord_qual[d1.seq].
     abn_status,char(0))), protect
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.675)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("ABN Status:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.425)
   SET rptsd->m_width = 6.563
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__abnstatusval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),offsety,(offsetx+ 0.675),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.425),offsety,(offsetx+ 1.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE abnstatusnotrequiredabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT ((req_data->req_qual[loopvar].ord_qual[d1.seq].abn_ind=0)
    AND (((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)) OR ((req_data->req_qual[
   loopvar].ord_qual[d1.seq].future_ind=1)
    AND (req_data->req_qual[loopvar].ref_lab IN (0, 1))
    AND uar_get_code_description(req_data->req_qual[loopvar].ord_qual[d1.seq].perf_loc_cd) !=
   misc_location_description)) ))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.000)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.000)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow53(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE dxcodes(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = dxcodesabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow21(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow21abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow21abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE __diagname = vc WITH noconstant(build(diagname,char(0))), protect
   IF (bcontinue=0)
    SET _remdiagname = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.363)
   SET rptsd->m_width = 5.626
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremdiagname = _remdiagname
   IF (_remdiagname > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdiagname,((size(
        __diagname) - _remdiagname)+ 1),__diagname)))
    SET drawheight_diagname = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdiagname = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdiagname,((size(__diagname) -
       _remdiagname)+ 1),__diagname)))))
     SET _remdiagname = (_remdiagname+ rptsd->m_drawlength)
    ELSE
     SET _remdiagname = 0
    ENDIF
    SET growsum = (growsum+ _remdiagname)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.675)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     IF (d=1)
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Diagnoses:",char(0)))
     ELSE
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
     ENDIF
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 516
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.425)
   SET rptsd->m_width = 0.938
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(diagid,char(0)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.363)
   SET rptsd->m_width = 5.626
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (_holdremdiagname > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdiagname,((size(
         __diagname) - _holdremdiagname)+ 1),__diagname)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remdiagname = _holdremdiagname
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),offsety,(offsetx+ 0.675),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.425),offsety,(offsetx+ 1.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.362),offsety,(offsetx+ 2.362),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE dxcodesabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF ( NOT (d > 0
    AND (((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)) OR ((req_data->req_qual[
   loopvar].ord_qual[d1.seq].future_ind=1)
    AND (req_data->req_qual[loopvar].ref_lab IN (0, 1))
    AND uar_get_code_description(req_data->req_qual[loopvar].ord_qual[d1.seq].perf_loc_cd) !=
   misc_location_description)) ))
    RETURN(0.0)
   ENDIF
   SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET _yoffset = (offsety+ 0.000)
   SET _fholdoffsety = (_yoffset - offsety)
   IF (ncalc=rpt_calcheight
    AND bcontinue=0)
    SET _yoffset = (offsety+ 0.000)
    SET holdheight = 0
    IF (growsum=0)
     SET maxheight_tablerow21 = (maxheight - (0.000+ holdheight))
     SET _bholdcontinue = 0
     SET holdheight = (holdheight+ tablerow21(rpt_calcheight,maxheight_tablerow21,_bholdcontinue))
     IF (((_bholdcontinue=1) OR (holdheight > maxheight_tablerow21)) )
      SET growsum = 1
     ENDIF
    ENDIF
    SET _yoffset = offsety
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _yoffset = (offsety+ 0.000)
    SET holdheight = 0
    SET maxheight_tablerow21 = (maxheight - (0.000+ holdheight))
    SET _bholdcontinue = 0
    SET holdheight = (holdheight+ tablerow21(rpt_render,maxheight_tablerow21,_bholdcontinue))
    IF (((0.000+ holdheight) > sectionheight))
     SET sectionheight = (0.000+ holdheight)
    ENDIF
    SET _yoffset = offsety
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE specialinstructions(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = specialinstructionsabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerowabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerowabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE __specialinstructval = vc WITH noconstant(build(req_data->req_qual[loopvar].ord_qual[d1
     .seq].special_instruct,char(0))), protect
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.675)
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Special Instructions:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.863)
   SET rptsd->m_width = 6.126
   SET rptsd->m_height = 0.188
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__specialinstructval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),offsety,(offsetx+ 0.675),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.862),offsety,(offsetx+ 1.862),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE specialinstructionsabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT (size(trim(req_data->req_qual[loopvar].ord_qual[d1.seq].special_instruct)) > 0
    AND (((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)) OR ((req_data->req_qual[
   loopvar].ord_qual[d1.seq].future_ind=1)
    AND (req_data->req_qual[loopvar].ref_lab IN (0, 1))
    AND uar_get_code_description(req_data->req_qual[loopvar].ord_qual[d1.seq].perf_loc_cd) !=
   misc_location_description)) ))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.000)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.000)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE ordercomment(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = ordercommentabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow56(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow56abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow56abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.187500), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE __ordcommentval = vc WITH noconstant(build(req_data->req_qual[loopvar].ord_qual[d1.seq].
     comment_line,char(0))), protect
   IF (bcontinue=0)
    SET _remordcommentval = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.738)
   SET rptsd->m_width = 5.625
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremordcommentval = _remordcommentval
   IF (_remordcommentval > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remordcommentval,((size(
        __ordcommentval) - _remordcommentval)+ 1),__ordcommentval)))
    SET drawheight_ordcommentval = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remordcommentval = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remordcommentval,((size(__ordcommentval)
        - _remordcommentval)+ 1),__ordcommentval)))))
     SET _remordcommentval = (_remordcommentval+ rptsd->m_drawlength)
    ELSE
     SET _remordcommentval = 0
    ENDIF
    SET growsum = (growsum+ _remordcommentval)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.675)
   SET rptsd->m_width = 1.063
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Order Comment:",char(0)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.050
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.738)
   SET rptsd->m_width = 5.625
   SET rptsd->m_height = sectionheight
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF (_holdremordcommentval > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremordcommentval,((
        size(__ordcommentval) - _holdremordcommentval)+ 1),__ordcommentval)))
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ELSE
    SET _remordcommentval = _holdremordcommentval
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),offsety,(offsetx+ 0.675),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.738),offsety,(offsetx+ 1.738),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.362),offsety,(offsetx+ 7.362),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),(offsety+ 0.000),(offsetx+ 7.364),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.675),(offsety+ sectionheight),(offsetx+ 7.364),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE ordercommentabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF ( NOT (size(trim(req_data->req_qual[loopvar].ord_qual[d1.seq].comment_line)) > 0
    AND (((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)) OR ((req_data->req_qual[
   loopvar].ord_qual[d1.seq].future_ind=1)
    AND (req_data->req_qual[loopvar].ref_lab IN (0, 1))
    AND uar_get_code_description(req_data->req_qual[loopvar].ord_qual[d1.seq].perf_loc_cd) !=
   misc_location_description)) ))
    RETURN(0.0)
   ENDIF
   SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET _yoffset = (offsety+ 0.000)
   SET _fholdoffsety = (_yoffset - offsety)
   IF (ncalc=rpt_calcheight
    AND bcontinue=0)
    SET _yoffset = (offsety+ 0.000)
    SET holdheight = 0
    IF (growsum=0)
     SET maxheight_tablerow56 = (maxheight - (0.000+ holdheight))
     SET _bholdcontinue = 0
     SET holdheight = (holdheight+ tablerow56(rpt_calcheight,maxheight_tablerow56,_bholdcontinue))
     IF (((_bholdcontinue=1) OR (holdheight > maxheight_tablerow56)) )
      SET growsum = 1
     ENDIF
    ENDIF
    SET _yoffset = offsety
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _yoffset = (offsety+ 0.000)
    SET holdheight = 0
    SET maxheight_tablerow56 = (maxheight - (0.000+ holdheight))
    SET _bholdcontinue = 0
    SET holdheight = (holdheight+ tablerow56(rpt_render,maxheight_tablerow56,_bholdcontinue))
    IF (((0.000+ holdheight) > sectionheight))
     SET sectionheight = (0.000+ holdheight)
    ENDIF
    SET _yoffset = offsety
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE orderseparator(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = orderseparatorabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE orderseparatorabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   IF ( NOT ((d1.seq <= req_data->req_qual[loopvar].ord_cnt)
    AND (((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)) OR ((req_data->req_qual[
   loopvar].ord_qual[d1.seq].future_ind=1)
    AND (req_data->req_qual[loopvar].ref_lab IN (0, 1))
    AND uar_get_code_description(req_data->req_qual[loopvar].ord_qual[d1.seq].perf_loc_cd) !=
   misc_location_description)) ))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s1c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.063),(offsetx+ 7.916),(offsety+
     0.063))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footpagesectionspecimenlabel(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footpagesectionspecimenlabelabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow48(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow48abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow48abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.125000), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.426)
   SET rptsd->m_width = 1.062
   SET rptsd->m_height = 0.125
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica60)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.488)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.238)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_flags = 1024
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.363)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.113)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.239)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.988)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.989)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),offsety,(offsetx+ 0.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.487),offsety,(offsetx+ 1.487),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.237),offsety,(offsetx+ 2.237),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.362),offsety,(offsetx+ 3.362),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.112),offsety,(offsetx+ 4.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.238),offsety,(offsetx+ 5.238),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.987),offsety,(offsetx+ 5.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.988),offsety,(offsetx+ 6.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.737),offsety,(offsetx+ 7.737),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),(offsety+ 0.000),(offsetx+ 7.738),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),(offsety+ sectionheight),(offsetx+ 7.738),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow50(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow50abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow50abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.125000), private
   DECLARE __label1patientname = vc WITH noconstant(build(req_data->name_full_formatted,char(0))),
   protect
   DECLARE __label1dob = vc WITH noconstant(build(format(cnvtdatetimeutc(datetimezone(req_data->
        birth_dt_tm,req_data->birth_tz),1),"MM/DD/YYYY;;d"),char(0))), protect
   DECLARE __label2patientname = vc WITH noconstant(build(req_data->name_full_formatted,char(0))),
   protect
   DECLARE __label2dob = vc WITH noconstant(build(format(cnvtdatetimeutc(datetimezone(req_data->
        birth_dt_tm,req_data->birth_tz),1),"MM/DD/YYYY;;d"),char(0))), protect
   DECLARE __label3patientname = vc WITH noconstant(build(req_data->name_full_formatted,char(0))),
   protect
   DECLARE __label3dob = vc WITH noconstant(build(format(cnvtdatetimeutc(datetimezone(req_data->
        birth_dt_tm,req_data->birth_tz),1),"MM/DD/YYYY;;d"),char(0))), protect
   DECLARE __label4patientname = vc WITH noconstant(build(req_data->name_full_formatted,char(0))),
   protect
   DECLARE __label4dob = vc WITH noconstant(build(format(cnvtdatetimeutc(datetimezone(req_data->
        birth_dt_tm,req_data->birth_tz),1),"MM/DD/YYYY;;d"),char(0))), protect
   SET rptsd->m_flags = 1024
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.426)
   SET rptsd->m_width = 1.062
   SET rptsd->m_height = 0.125
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica60)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label1patientname)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.488)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label1dob)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.238)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label2patientname)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.363)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label2dob)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.113)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label3patientname)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.239)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label3dob)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.988)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label4patientname)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.989)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label4dob)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),offsety,(offsetx+ 0.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.487),offsety,(offsetx+ 1.487),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.237),offsety,(offsetx+ 2.237),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.362),offsety,(offsetx+ 3.362),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.112),offsety,(offsetx+ 4.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.238),offsety,(offsetx+ 5.238),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.987),offsety,(offsetx+ 5.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.988),offsety,(offsetx+ 6.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.737),offsety,(offsetx+ 7.737),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),(offsety+ 0.000),(offsetx+ 7.738),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),(offsety+ sectionheight),(offsetx+ 7.738),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow16(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow16abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow16abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.125000), private
   DECLARE __label1reqcntrlnbr = vc WITH noconstant(build(req_data->req_qual[loopvar].req_control_nbr,
     char(0))), protect
   DECLARE __label1patientmrn = vc WITH noconstant(build(req_data->mrn,char(0))), protect
   DECLARE __label2reqcntrlnbr = vc WITH noconstant(build(req_data->req_qual[loopvar].req_control_nbr,
     char(0))), protect
   DECLARE __label2patientmrn = vc WITH noconstant(build(req_data->mrn,char(0))), protect
   DECLARE __label3reqcntrlnbr = vc WITH noconstant(build(req_data->req_qual[loopvar].req_control_nbr,
     char(0))), protect
   DECLARE __label3patientmrn = vc WITH noconstant(build(req_data->mrn,char(0))), protect
   DECLARE __label4reqcntrlnbr = vc WITH noconstant(build(req_data->req_qual[loopvar].req_control_nbr,
     char(0))), protect
   DECLARE __label4patientmrn = vc WITH noconstant(build(req_data->mrn,char(0))), protect
   SET rptsd->m_flags = 1024
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.426)
   SET rptsd->m_width = 1.062
   SET rptsd->m_height = 0.125
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica60)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label1reqcntrlnbr)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_flags = 1056
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.488)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->req_qual[loopvar].req_control_nbr="FUTUREORDER"))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label1patientmrn)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_flags = 1024
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.238)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label2reqcntrlnbr)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_flags = 1056
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.363)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->req_qual[loopvar].req_control_nbr="FUTUREORDER"))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label2patientmrn)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_flags = 1024
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.113)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label3reqcntrlnbr)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_flags = 1056
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.239)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->req_qual[loopvar].req_control_nbr="FUTUREORDER"))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label3patientmrn)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_flags = 1024
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.988)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label4reqcntrlnbr)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_flags = 1056
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.989)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->req_qual[loopvar].req_control_nbr="FUTUREORDER"))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label4patientmrn)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),offsety,(offsetx+ 0.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.487),offsety,(offsetx+ 1.487),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.237),offsety,(offsetx+ 2.237),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.362),offsety,(offsetx+ 3.362),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.112),offsety,(offsetx+ 4.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.238),offsety,(offsetx+ 5.238),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.987),offsety,(offsetx+ 5.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.988),offsety,(offsetx+ 6.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.737),offsety,(offsetx+ 7.737),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),(offsety+ 0.000),(offsetx+ 7.738),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),(offsety+ sectionheight),(offsetx+ 7.738),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow63(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow63abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow63abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.125000), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.426)
   SET rptsd->m_width = 1.062
   SET rptsd->m_height = 0.125
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica60)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.488)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.238)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_flags = 1024
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.363)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.113)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.239)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.988)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.989)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),offsety,(offsetx+ 0.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.487),offsety,(offsetx+ 1.487),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.237),offsety,(offsetx+ 2.237),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.362),offsety,(offsetx+ 3.362),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.112),offsety,(offsetx+ 4.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.238),offsety,(offsetx+ 5.238),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.987),offsety,(offsetx+ 5.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.988),offsety,(offsetx+ 6.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.737),offsety,(offsetx+ 7.737),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),(offsety+ 0.000),(offsetx+ 7.738),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),(offsety+ sectionheight),(offsetx+ 7.738),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow59(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow59abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow59abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.125000), private
   DECLARE __label5patientname = vc WITH noconstant(build(req_data->name_full_formatted,char(0))),
   protect
   DECLARE __label5dob = vc WITH noconstant(build(format(cnvtdatetimeutc(datetimezone(req_data->
        birth_dt_tm,req_data->birth_tz),1),"MM/DD/YYYY;;d"),char(0))), protect
   DECLARE __label6patientname = vc WITH noconstant(build(req_data->name_full_formatted,char(0))),
   protect
   DECLARE __label6dob = vc WITH noconstant(build(format(cnvtdatetimeutc(datetimezone(req_data->
        birth_dt_tm,req_data->birth_tz),1),"MM/DD/YYYY;;d"),char(0))), protect
   DECLARE __label7patientname = vc WITH noconstant(build(req_data->name_full_formatted,char(0))),
   protect
   DECLARE __label7dob = vc WITH noconstant(build(format(cnvtdatetimeutc(datetimezone(req_data->
        birth_dt_tm,req_data->birth_tz),1),"MM/DD/YYYY;;d"),char(0))), protect
   DECLARE __label8patientname = vc WITH noconstant(build(req_data->name_full_formatted,char(0))),
   protect
   DECLARE __label8dob = vc WITH noconstant(build(format(cnvtdatetimeutc(datetimezone(req_data->
        birth_dt_tm,req_data->birth_tz),1),"MM/DD/YYYY;;d"),char(0))), protect
   SET rptsd->m_flags = 1024
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.426)
   SET rptsd->m_width = 1.062
   SET rptsd->m_height = 0.125
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica60)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label5patientname)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.488)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label5dob)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.238)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label6patientname)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.363)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label6dob)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.113)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label7patientname)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.239)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label7dob)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.988)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label8patientname)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.989)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.125
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label8dob)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),offsety,(offsetx+ 0.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.487),offsety,(offsetx+ 1.487),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.237),offsety,(offsetx+ 2.237),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.362),offsety,(offsetx+ 3.362),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.112),offsety,(offsetx+ 4.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.238),offsety,(offsetx+ 5.238),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.987),offsety,(offsetx+ 5.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.988),offsety,(offsetx+ 6.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.737),offsety,(offsetx+ 7.737),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),(offsety+ 0.000),(offsetx+ 7.738),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),(offsety+ sectionheight),(offsetx+ 7.738),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow57(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow57abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow57abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.114584), private
   DECLARE __label5reqcntrlnbr = vc WITH noconstant(build(req_data->req_qual[loopvar].req_control_nbr,
     char(0))), protect
   DECLARE __label5patientmrn = vc WITH noconstant(build(req_data->mrn,char(0))), protect
   DECLARE __label6reqcntrlnbr = vc WITH noconstant(build(req_data->req_qual[loopvar].req_control_nbr,
     char(0))), protect
   DECLARE __label6patientmrn = vc WITH noconstant(build(req_data->mrn,char(0))), protect
   DECLARE __label7reqcntrlnbr = vc WITH noconstant(build(req_data->req_qual[loopvar].req_control_nbr,
     char(0))), protect
   DECLARE __label7patientmrn = vc WITH noconstant(build(req_data->mrn,char(0))), protect
   DECLARE __label8reqcntrlnbr = vc WITH noconstant(build(req_data->req_qual[loopvar].req_control_nbr,
     char(0))), protect
   DECLARE __label8patientmrn = vc WITH noconstant(build(req_data->mrn,char(0))), protect
   SET rptsd->m_flags = 1024
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.426)
   SET rptsd->m_width = 1.062
   SET rptsd->m_height = 0.115
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica60)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label5reqcntrlnbr)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_flags = 1056
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 1.488)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.115
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->req_qual[loopvar].req_control_nbr="FUTUREORDER"))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label5patientmrn)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_flags = 1024
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.238)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.115
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label6reqcntrlnbr)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_flags = 1056
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 3.363)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.115
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->req_qual[loopvar].req_control_nbr="FUTUREORDER"))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label6patientmrn)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_flags = 1024
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 4.113)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.115
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label7reqcntrlnbr)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_flags = 1056
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.239)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.115
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->req_qual[loopvar].req_control_nbr="FUTUREORDER"))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label7patientmrn)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_flags = 1024
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.988)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.115
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label8reqcntrlnbr)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   SET rptsd->m_flags = 1056
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.989)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.115
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    IF ((req_data->req_qual[loopvar].req_control_nbr="FUTUREORDER"))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label8patientmrn)
    ELSE
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("",char(0)))
    ENDIF
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen1s0c16777215)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),offsety,(offsetx+ 0.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.487),offsety,(offsetx+ 1.487),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.237),offsety,(offsetx+ 2.237),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.362),offsety,(offsetx+ 3.362),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.112),offsety,(offsetx+ 4.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.238),offsety,(offsetx+ 5.238),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.987),offsety,(offsetx+ 5.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.988),offsety,(offsetx+ 6.988),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.737),offsety,(offsetx+ 7.737),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),(offsety+ 0.000),(offsetx+ 7.738),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.425),(offsety+ sectionheight),(offsetx+ 7.738),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow3(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow3abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow3abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.176786), private
   DECLARE __curdatetime = vc WITH noconstant(build(format(req_data->current_dt_tm,
      "MM/DD/YYYY HH:MM;;q"),char(0))), protect
   SET rptsd->m_flags = 272
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 2.313
   SET rptsd->m_height = 0.177
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.426)
   SET rptsd->m_width = 3.375
   SET rptsd->m_height = 0.177
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(rpt_pageofpage,char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.800)
   SET rptsd->m_width = 1.063
   SET rptsd->m_height = 0.177
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Printed:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.863)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.177
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__curdatetime)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.425),offsety,(offsetx+ 2.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.800),offsety,(offsetx+ 5.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.863),offsety,(offsetx+ 6.863),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow4(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow4abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow4abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.166964), private
   DECLARE __patnamefoot = vc WITH noconstant(build(req_data->name_full_formatted,char(0))), protect
   DECLARE __orddatetime = vc WITH noconstant(build(format(order_dt_tm,"MM/DD/YYYY HH:MM;;D"),char(0)
     )), protect
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 2.313
   SET rptsd->m_height = 0.167
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patnamefoot)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 272
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.426)
   SET rptsd->m_width = 3.375
   SET rptsd->m_height = 0.167
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.800)
   SET rptsd->m_width = 1.063
   SET rptsd->m_height = 0.167
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Order Date:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.863)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.167
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__orddatetime)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.425),offsety,(offsetx+ 2.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.800),offsety,(offsetx+ 5.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.863),offsety,(offsetx+ 6.863),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footpagesectionspecimenlabelabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.310000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT ((req_data->print_misc_labels_ind=1)
    AND (((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)) OR ((req_data->req_qual[
   loopvar].ord_qual[d1.seq].future_ind=1)
    AND (req_data->req_qual[loopvar].ref_lab IN (0, 1))
    AND uar_get_code_description(req_data->req_qual[loopvar].ord_qual[d1.seq].perf_loc_cd) !=
   misc_location_description)) ))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen1s0c16777215)
    SET _yoffset = (offsety+ 0.000)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.000)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow48(rpt_render))
     SET holdheight = (holdheight+ tablerow50(rpt_render))
     SET holdheight = (holdheight+ tablerow16(rpt_render))
     SET holdheight = (holdheight+ tablerow63(rpt_render))
     SET holdheight = (holdheight+ tablerow59(rpt_render))
     SET holdheight = (holdheight+ tablerow57(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.938)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.938)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow3(rpt_render))
     SET holdheight = (holdheight+ tablerow4(rpt_render))
     SET _yoffset = offsety
    ENDIF
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footpagesectionnonlabel(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footpagesectionnonlabelabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow17(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow17abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow17abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.160000), private
   DECLARE __transfertemperature = vc WITH noconstant(build(uar_get_code_display(req_data->req_qual[
      loopvar].transfer_temp_cd),char(0))), protect
   SET rptsd->m_flags = 272
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 2.313
   SET rptsd->m_height = 0.160
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.426)
   SET rptsd->m_width = 3.375
   SET rptsd->m_height = 0.160
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__transfertemperature)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.800)
   SET rptsd->m_width = 1.063
   SET rptsd->m_height = 0.160
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.863)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.160
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.425),offsety,(offsetx+ 2.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.800),offsety,(offsetx+ 5.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.863),offsety,(offsetx+ 6.863),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow44(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow44abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow44abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.180000), private
   DECLARE __curdatetime = vc WITH noconstant(build(format(req_data->current_dt_tm,
      "MM/DD/YYYY HH:MM;;q"),char(0))), protect
   SET rptsd->m_flags = 272
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 2.313
   SET rptsd->m_height = 0.180
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.426)
   SET rptsd->m_width = 3.375
   SET rptsd->m_height = 0.180
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(rpt_pageofpage,char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.800)
   SET rptsd->m_width = 1.063
   SET rptsd->m_height = 0.180
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Printed:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.863)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.180
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__curdatetime)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.425),offsety,(offsetx+ 2.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.800),offsety,(offsetx+ 5.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.863),offsety,(offsetx+ 6.863),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow1(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow1abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.222500), private
   DECLARE __patnamefoot = vc WITH noconstant(build(req_data->name_full_formatted,char(0))), protect
   DECLARE __orddatetime = vc WITH noconstant(build(format(order_dt_tm,"MM/DD/YYYY HH:MM;;D"),char(0)
     )), protect
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.113)
   SET rptsd->m_width = 2.313
   SET rptsd->m_height = 0.223
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patnamefoot)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 272
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 2.426)
   SET rptsd->m_width = 3.375
   SET rptsd->m_height = 0.223
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 320
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 5.800)
   SET rptsd->m_width = 1.063
   SET rptsd->m_height = 0.223
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica80)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("Order Date:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   SET rptsd->m_flags = 256
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 6.863)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.223
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__orddatetime)
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen0s0c0)
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.112),offsety,(offsetx+ 0.112),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.425),offsety,(offsetx+ 2.425),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.800),offsety,(offsetx+ 5.800),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.863),offsety,(offsetx+ 6.863),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.987),offsety,(offsetx+ 7.987),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ 0.000),(offsetx+ 7.989),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.113),(offsety+ sectionheight),(offsetx+ 7.989),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footpagesectionnonlabelabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.700000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF ( NOT ((req_data->print_misc_labels_ind != 1)
    AND (((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=0)) OR ((req_data->req_qual[
   loopvar].ord_qual[d1.seq].future_ind=1)
    AND (req_data->req_qual[loopvar].ref_lab IN (0, 1))
    AND uar_get_code_description(req_data->req_qual[loopvar].ord_qual[d1.seq].perf_loc_cd) !=
   misc_location_description)) ))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen0s0c0)
    SET _yoffset = (offsety+ 0.000)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.000)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow17(rpt_render))
     SET holdheight = (holdheight+ tablerow44(rpt_render))
     SET holdheight = (holdheight+ tablerow1(rpt_render))
     SET _yoffset = offsety
    ENDIF
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE futureorderwatermark(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = futureorderwatermarkabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE futureorderwatermarkabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(2.000000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_water_mark = f8 WITH noconstant(0.0), private
   DECLARE __water_mark = vc WITH noconstant(build2(
     IF ((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=1)) "Future Order"
     ELSEIF ((req_data->reprint_ind=1)) "Requisition Reproduction"
     ENDIF
     ,char(0))), protect
   IF ( NOT ((((req_data->req_qual[loopvar].ord_qual[d1.seq].future_ind=1)) OR ((req_data->
   reprint_ind=1))) ))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _remwater_mark = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 45
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.011)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.311)
   SET rptsd->m_width = 6.740
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times7215395562)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremwater_mark = _remwater_mark
   IF (_remwater_mark > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remwater_mark,((size(
        __water_mark) - _remwater_mark)+ 1),__water_mark)))
    SET drawheight_water_mark = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remwater_mark = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remwater_mark,((size(__water_mark) -
       _remwater_mark)+ 1),__water_mark)))))
     SET _remwater_mark = (_remwater_mark+ rptsd->m_drawlength)
    ELSE
     SET _remwater_mark = 0
    ENDIF
    SET growsum = (growsum+ _remwater_mark)
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.011)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.311)
   SET rptsd->m_width = 6.740
   SET rptsd->m_height = drawheight_water_mark
   IF (ncalc=rpt_render
    AND _holdremwater_mark > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremwater_mark,((size(
        __water_mark) - _holdremwater_mark)+ 1),__water_mark)))
   ELSE
    SET _remwater_mark = _holdremwater_mark
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "AMB_RLN_STD_LYT_2"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.20
   SET rptreport->m_marginright = 0.20
   SET rptreport->m_margintop = 0.20
   SET rptreport->m_marginbottom = 0.20
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET rptreport->m_dioflag = 0
   SET rptreport->m_needsnotonaskharabic = 0
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 62
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_helvetica
   SET rptfont->m_pointsize = 14
   SET rptfont->m_bold = rpt_on
   SET _helvetica14b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 9
   SET rptfont->m_bold = rpt_off
   SET _helvetica90 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET _helvetica9b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET _helvetica100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 14
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_rgbcolor = rpt_white
   SET _helvetica14b16777215 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 6
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _helvetica60 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET _helvetica80 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 72
   SET rptfont->m_rgbcolor = uar_rptencodecolor(234,234,234)
   SET _times7215395562 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.000
   SET _pen0s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.014
   SET _pen13s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 1
   SET _pen14s1c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.001
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_white
   SET _pen1s0c16777215 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET stat = initrec(order_detail)
 CALL initializereport(0)
 CALL query1(0)
 CALL finalizereport(_sendto)
END GO
