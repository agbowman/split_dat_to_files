CREATE PROGRAM bhs_req_oxy:dba
 PROMPT
  "Output to File/Printer/MINE" = "bmc362isam1rx",
  "order_id:" = ""
  WITH outdev, ordid
 IF (validate(request->person_id)=0)
  CALL echo("setting request")
  FREE RECORD request
  RECORD request(
    1 person_id = f8
    1 print_prsnl_id = f8
    1 order_qual[*]
      2 order_id = f8
      2 encntr_id = f8
      2 conversation_id = f8
    1 printer_name = c50
  )
 ENDIF
 DECLARE orderaction = vc
 DECLARE w_print = vc
 IF (reflect(parameter(1,0)) > " ")
  IF (cnvtreal(parameter(2,0)) > 0.00)
   SELECT INTO "NL:"
    FROM orders o,
     order_action oa
    PLAN (o
     WHERE o.order_id=cnvtreal( $2))
     JOIN (oa
     WHERE o.order_id=oa.order_id
      AND o.last_action_sequence=oa.action_sequence)
    HEAD o.order_id
     request->person_id = o.person_id, stat = alterlist(request->order_qual,1), request->order_qual[1
     ].order_id = o.order_id,
     request->order_qual[1].encntr_id = o.encntr_id, request->order_qual[1].conversation_id = oa
     .order_conversation_id
    WITH nocounter
   ;end select
   SET request->printer_name =  $1
  ENDIF
  IF ((request->person_id <= 0.00))
   CALL echo("Invalid ORDER_ID passed in. Exiting Program")
   GO TO exit_script
  ENDIF
 ENDIF
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DECLARE new_rx_text = c19 WITH public, constant("NEW Prescription(s)")
 DECLARE refill_rx_text = c22 WITH public, constant("REFILL Prescription(s)")
 DECLARE reprint_text = c24 WITH public, constant("RE-PRINT Prescription(s)")
 DECLARE mf_work_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17,"WORKING"))
 DECLARE mf_admit_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17,"ADMIT"))
 DECLARE mf_discharge_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17,"DISCHARGE"))
 DECLARE is_a_reprint = i2 WITH public, noconstant(false)
 DECLARE v500_ind = i2 WITH public, noconstant(false)
 DECLARE use_pco = i2 WITH public, noconstant(false)
 DECLARE mltm_loaded = i2 WITH public, noconstant(false)
 DECLARE username = vc WITH public, noconstant(" ")
 DECLARE file_name = vc WITH public, noconstant(" ")
 DECLARE work_add_cd = f8 WITH public, noconstant(0.0)
 DECLARE home_add_cd = f8 WITH public, noconstant(0.0)
 DECLARE clinic_add_cd = f8 WITH public, noconstant(0.0)
 DECLARE work_phone_cd = f8 WITH public, noconstant(0.0)
 DECLARE home_phone_cd = f8 WITH public, noconstant(0.0)
 DECLARE clinic_phone_cd = f8 WITH public, noconstant(0.0)
 DECLARE canceled_cd = f8 WITH public, noconstant(0.0)
 DECLARE completed_cd = f8 WITH public, noconstant(0.0)
 DECLARE modify_cd = f8 WITH public, noconstant(0.0)
 DECLARE studactivate_cd = f8 WITH public, noconstant(0.0)
 DECLARE docdea_cd = f8 WITH public, noconstant(0.0)
 DECLARE docnpi_cd = f8 WITH public, noconstant(0.0)
 DECLARE licensenbr_cd = f8 WITH public, noconstant(0.0)
 DECLARE canceled_allergy_cd = f8 WITH public, noconstant(0.0)
 DECLARE emrn_cd = f8 WITH public, noconstant(0.0)
 DECLARE pmrn_cd = f8 WITH public, noconstant(0.0)
 DECLARE ord_comment_cd = f8 WITH public, noconstant(0.0)
 DECLARE position_cd1 = f8 WITH public, noconstant(0.0)
 DECLARE position_cd2 = f8 WITH public, noconstant(0.0)
 DECLARE prsnl_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE eprsnl_ind = i2 WITH public, noconstant(false)
 DECLARE code_set = i4 WITH public, noconstant(0)
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE csa_group_cnt = i4 WITH public, noconstant(0)
 DECLARE ml_dxcnt = i4 WITH public, noconstant(0)
 DECLARE ml_dx_maxcnt = i4 WITH public, noconstant(0)
 DECLARE temp_csa_group = vc WITH public, noconstant(" ")
 DECLARE inpatient_cd = f8 WITH public, noconstant(0.0)
 DECLARE ms_erx_ind = vc WITH public, noconstant("N")
 DECLARE text_line = vc
 DECLARE pod_loc_bed_cd = f8 WITH public, noconstant(0.0)
 DECLARE pod_loc_room_cd = f8 WITH public, noconstant(0.0)
 DECLARE pod_loc_nurse_unit_cd = f8 WITH public, noconstant(0.0)
 DECLARE pod_loc_building_cd = f8 WITH public, noconstant(0.0)
 DECLARE pod_loc_facility_cd = f8 WITH public, noconstant(0.0)
 DECLARE pod_roombed = vc WITH public, noconstant("")
 DECLARE pod_printername = vc WITH public, noconstant("")
 DECLARE ms_order_str = vc WITH public, constant("ORDERS")
 DECLARE ms_diag_str = vc WITH public, constant("DIAGNOSIS")
 DECLARE ezscriptphone_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",43,"EZSCRIPT")), protect
 DECLARE ezscriptaddress_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",212,"EZSCRIPT")),
 protect
 DECLARE provider_id = f8 WITH public, noconstant(0.0)
 DECLARE c = i4 WITH protect, noconstant(0)
 DECLARE ms_txt_line33 = vc WITH protect, noconstant("")
 DECLARE ms_txt_line34 = vc WITH protect, noconstant("")
 DECLARE mf_o2_amt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"AMOUNTOFO2"))
 DECLARE mf_o2_other_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"OTHERO2"))
 DECLARE mf_o2_portable_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "PORTABLEO2NEEDED"))
 DECLARE mf_duration_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"OTHERNURSING"
   ))
 SET home_add_cd = uar_get_code_by("meaning",212,"HOME")
 SET work_add_cd = uar_get_code_by("meaning",212,"BUSINESS")
 SET completed_cd = uar_get_code_by("meaning",6004,"COMPLETED")
 SET canceled_cd = 0
 SET discontinued_cd = 0
 SET canceled_cd = uar_get_code_by("displaykey",6004,"CANCELED")
 SET discontinued_cd = uar_get_code_by("displaykey",6004,"DISCONTINUED")
 SET clinic_phone_cd = uar_get_code_by("meaning",43,"PROFESSIONAL")
 SET work_phone_cd = uar_get_code_by("meaning",43,"BUSINESS")
 SET clinic_add_cd = uar_get_code_by("meaning",212,"PROFESSIONAL")
 SET home_phone_cd = uar_get_code_by("meaning",43,"HOME")
 SET modify_cd = uar_get_code_by("meaning",6003,"MODIFY")
 SET studactivate_cd = uar_get_code_by("meaning",6003,"STUDACTIVATE")
 SET canceled_allergy_cd = uar_get_code_by("meaning",12025,"CANCELED")
 SET licensenbr_cd = uar_get_code_by("meaning",320,"LICENSENBR")
 SET docdea_cd = uar_get_code_by("meaning",320,"DOCDEA")
 SET docnpi_cd = uar_get_code_by("meaning",320,"NPI")
 SET inpatient_cd = uar_get_code_by("displaykey",69,"INPATIENT")
 SET observation_cd = uar_get_code_by("displaykey",69,"OBSERVATION")
 SET daystay_cd = uar_get_code_by("displaykey",69,"DAYSTAY")
 SET inpatient_ind = 0
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id=request->order_qual[1].encntr_id)
    AND e.encntr_type_class_cd IN (389, 390))
  DETAIL
   inpatient_ind = 1
  WITH counter
 ;end select
 IF (curqual > 0)
  CALL echo("go to exit 1")
  GO TO exit_script
 ENDIF
 SET pmrn_cd = uar_get_code_by("meaning",4,"MRN")
 SET emrn_cd = uar_get_code_by("meaning",319,"MRN")
 SET ord_comment_cd = uar_get_code_by("meaning",14,"ORD COMMENT")
 SET prsnl_type_cd = uar_get_code_by("meaning",213,"PRSNL")
 SET np_ind = 0
 SET phy_ind = 0
 DECLARE sup_phy_name = vc
 DECLARE sup_phy_dea = vc
 DECLARE sup_phy_id = f8
 IF ((request->print_prsnl_id > 0))
  SET is_a_reprint = true
 ENDIF
 IF (is_a_reprint=false)
  SELECT INTO "nl:"
   FROM prsnl p
   PLAN (p
    WHERE (p.person_id=reqinfo->updt_id))
   HEAD REPORT
    username = trim(substring(1,12,p.username))
   WITH nocounter
  ;end select
 ENDIF
 IF ( NOT (username > " "))
  SET username = "faxreq"
 ENDIF
 FREE RECORD demo_info
 RECORD demo_info(
   1 pat_name = vc
   1 pat_sex = vc
   1 pat_bday = vc
   1 pat_age = vc
   1 pat_addr = vc
   1 pat_city = vc
   1 pat_hphone = vc
   1 pat_wphone = vc
   1 allergy_line = vc
   1 allergy_knt = i4
   1 allergy[*]
     2 disp = vc
 )
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM person p,
   address a
  PLAN (p
   WHERE (p.person_id=request->person_id))
   JOIN (a
   WHERE (a.parent_entity_id= Outerjoin(p.person_id))
    AND (a.parent_entity_name= Outerjoin("PERSON"))
    AND (a.address_type_cd= Outerjoin(home_add_cd))
    AND (a.active_ind= Outerjoin(1))
    AND (a.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
    AND (a.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
  ORDER BY a.beg_effective_dt_tm DESC
  HEAD REPORT
   demo_info->pat_name = trim(p.name_full_formatted), demo_info->pat_sex = trim(uar_get_code_display(
     p.sex_cd)), demo_info->pat_bday = format(cnvtdatetime(p.birth_dt_tm),"mm/dd/yyyy;;d"),
   demo_info->pat_age = cnvtage(p.birth_dt_tm), found_address = false
  HEAD a.address_id
   IF (a.address_id > 0
    AND found_address=false)
    found_address = true, demo_info->pat_addr = trim(substring(1,33,a.street_addr))
    IF (a.street_addr2 > " ")
     demo_info->pat_addr = trim(substring(1,33,trim(concat(trim(demo_info->pat_addr),", ",trim(a
          .street_addr2)))))
    ENDIF
    demo_info->pat_city = trim(a.city)
    IF (a.state_cd > 0)
     demo_info->pat_city = concat(trim(demo_info->pat_city),", ",trim(uar_get_code_display(a.state_cd
        )))
    ELSEIF (a.state > " ")
     demo_info->pat_city = concat(trim(demo_info->pat_city),", ",trim(a.state))
    ENDIF
    IF (a.zipcode > " ")
     demo_info->pat_city = concat(trim(demo_info->pat_city)," ",trim(a.zipcode))
    ENDIF
    demo_info->pat_city = trim(substring(1,33,demo_info->pat_city))
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "NAME_ADDRESS"
  CALL echo("go to exit 2")
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM phone p
  PLAN (p
   WHERE (p.parent_entity_id=request->person_id)
    AND p.parent_entity_name="PERSON"
    AND p.phone_type_cd IN (home_phone_cd, work_phone_cd)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY p.beg_effective_dt_tm DESC
  HEAD REPORT
   found_home = false, found_work = false
  DETAIL
   IF (found_home=false
    AND p.phone_type_cd=home_phone_cd)
    found_home = true, demo_info->pat_hphone = trim(cnvtphone(p.phone_num,p.phone_format_cd,2))
   ENDIF
   IF (found_work=false
    AND p.phone_type_cd=work_phone_cd)
    found_work = true, demo_info->pat_wphone = trim(cnvtphone(p.phone_num,p.phone_format_cd,2))
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PATIENT_PHONE"
  CALL echo("go to exit 3")
  GO TO exit_script
 ENDIF
 FREE RECORD pt
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 FREE RECORD temp_req
 RECORD temp_req(
   1 qual_knt = i4
   1 qual[*]
     2 f_person_id = f8
     2 order_id = f8
     2 encntr_id = f8
     2 order_status = f8
     2 organization_id = f8
     2 org_name = vc
     2 location_cd = f8
     2 loc_addr = c30
     2 loc_addr2 = c30
     2 loc_city = c30
     2 loc_state = c2
     2 loc_zip = c5
     2 loc_ph = c14
     2 d_nbr = vc
     2 csa_schedule = c1
     2 csa_group = c1
     2 mrn = vc
     2 found_emrn = i2
     2 hp_pri_found = i2
     2 hp_pri_name = vc
     2 hp_pri_polgrp = vc
     2 hp_sec_found = i2
     2 hp_sec_name = vc
     2 hp_sec_polgrp = vc
     2 oe_format_id = f8
     2 phys_id = f8
     2 position_cd = f8
     2 phys_name = vc
     2 phys_fname = vc
     2 phys_mname = vc
     2 phys_lname = vc
     2 phys_title = vc
     2 phys_bname = vc
     2 found_phys_addr_ind = i2
     2 phys_addr_id = f8
     2 phys_addr1 = vc
     2 phys_addr2 = vc
     2 phys_addr3 = vc
     2 phys_addr4 = vc
     2 phys_city = vc
     2 phys_dea = vc
     2 phys_npi = vc
     2 phys_lnbr = vc
     2 phys_phone = vc
     2 eprsnl_ind = i2
     2 eprsnl_id = f8
     2 eprsnl_dea = vc
     2 eprsnl_npi = vc
     2 eprsnl_name = vc
     2 eprsnl_fname = vc
     2 eprsnl_mname = vc
     2 eprsnl_lname = vc
     2 eprsnl_title = vc
     2 eprsnl_bname = vc
     2 order_dt = dq8
     2 output_dest_cd = f8
     2 free_text_nbr = vc
     2 print_loc = vc
     2 no_print = i2
     2 print_dea = i2
     2 daw = i2
     2 start_date = dq8
     2 req_start_date = dq8
     2 perform_loc = vc
     2 order_mnemonic = vc
     2 order_as_mnemonic = vc
     2 free_txt_ord = vc
     2 med_name = vc
     2 med_knt = i4
     2 med[*]
       3 disp = vc
     2 strength_dose = vc
     2 strength_dose_unit = vc
     2 volume_dose = vc
     2 volume_dose_unit = vc
     2 freetext_dose = vc
     2 rx_route = vc
     2 frequency = vc
     2 duration = vc
     2 duration_unit = vc
     2 ord_det_disp = vc
     2 ms_rx_product_type = vc
     2 sig_line = vc
     2 sig_knt = i4
     2 sig[*]
       3 disp = vc
     2 dispense_qty = vc
     2 dispense_qty_unit = vc
     2 dispense_line = vc
     2 dispense_knt = i4
     2 dispense[*]
       3 disp = vc
     2 dispense_duration = vc
     2 dispense_duration_unit = vc
     2 dispense_duration_line = vc
     2 dispense_duration_knt = i4
     2 dispense_duration_qual[*]
       3 disp = vc
     2 action_seq = i2
     2 nbrrefills = f8
     2 additionalrefills = f8
     2 req_refill_date = dq8
     2 nbr_refills_txt = vc
     2 nbr_refills = f8
     2 total_refills = f8
     2 add_refills_txt = vc
     2 add_refills = f8
     2 refill_ind = i2
     2 refill_line = vc
     2 refill_knt = i4
     2 refill[*]
       3 disp = vc
     2 special_inst = vc
     2 special_knt = i4
     2 special[*]
       3 disp = vc
     2 prn_ind = i2
     2 prn_inst = vc
     2 prn_knt = i4
     2 prn[*]
       3 disp = vc
     2 indications = vc
     2 indic_knt = i4
     2 indic[*]
       3 disp = vc
     2 get_comment_ind = i2
     2 comments = vc
     2 comment_knt = i4
     2 comment[*]
       3 disp = vc
     2 n_rxreq_ind = i2
     2 s_diagname = vc
     2 s_o2_amt = vc
     2 s_o2_other = vc
     2 s_o2_portable = vc
     2 s_o2_duration = vc
 )
 SET eprsnl_ind = false
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DECLARE encntr_id = f8
 SET encntr_id = request->order_qual[1].encntr_id
 DECLARE prt_encntr_id = f8
 SET prt_encntr_id = request->order_qual[1].encntr_id
 CALL echo("get order data")
 SELECT INTO "nl:"
  encntr_id = request->order_qual[d.seq].encntr_id, oa.order_provider_id, o.order_id,
  cki_len = textlen(o.cki), p.position_cd
  FROM (dummyt d  WITH seq = value(size(request->order_qual,5))),
   orders o,
   order_action oa,
   prsnl p,
   prsnl p2
  PLAN (d
   WHERE d.seq > 0)
   JOIN (o
   WHERE (o.order_id=request->order_qual[d.seq].order_id)
    AND (o.encntr_id=request->order_qual[d.seq].encntr_id)
    AND  NOT (o.order_id IN (
   (SELECT
    od.order_id
    FROM order_detail od
    WHERE o.order_id=od.order_id
     AND trim(od.oe_field_meaning)="DONTPRINTRXREASON"
     AND od.oe_field_value > 0))))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=o.last_action_sequence
    AND oa.action_type_cd IN (2534, 1849400, 2535, 2524, 2533))
   JOIN (p
   WHERE (p.person_id= Outerjoin(oa.order_provider_id)) )
   JOIN (p2
   WHERE (p2.person_id= Outerjoin(oa.supervising_provider_id)) )
  ORDER BY o.order_id
  HEAD REPORT
   knt = 0, stat = alterlist(temp_req->qual,10),
   CALL echo("head report get order data")
  HEAD o.order_id
   knt += 1
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(temp_req->qual,(knt+ 9))
   ENDIF
   temp_req->qual[knt].order_id = o.order_id, temp_req->qual[knt].order_status = o.order_status_cd,
   temp_req->qual[knt].encntr_id = o.encntr_id,
   temp_req->qual[knt].f_person_id = o.person_id, temp_req->qual[knt].oe_format_id = o.oe_format_id,
   temp_req->qual[knt].eprsnl_id = oa.order_provider_id,
   temp_req->qual[knt].ord_det_disp = o.order_detail_display_line, orderaction = uar_get_code_display
   (oa.action_type_cd)
   IF (oa.order_provider_id != oa.action_personnel_id)
    temp_req->qual[knt].eprsnl_ind = true, eprsnl_ind = true
   ENDIF
   IF (oa.supervising_provider_id > 0)
    temp_req->qual[knt].phys_id = oa.supervising_provider_id, temp_req->qual[knt].phys_name = trim(p2
     .name_full_formatted), np_ind = true
   ELSE
    phy_ind = true, temp_req->qual[knt].phys_name = trim(p.name_full_formatted), temp_req->qual[knt].
    phys_id = oa.order_provider_id
   ENDIF
   temp_req->qual[knt].order_dt = cnvtdatetime(cnvtdate(oa.action_dt_tm),0), temp_req->qual[knt].
   print_loc = request->printer_name, temp_req->qual[knt].order_mnemonic = o.hna_order_mnemonic,
   temp_req->qual[knt].order_as_mnemonic = o.ordered_as_mnemonic, temp_req->qual[knt].position_cd = p
   .position_cd
   IF (band(o.comment_type_mask,1)=1)
    temp_req->qual[knt].get_comment_ind = true
   ENDIF
   d_pos = findstring("!d",o.cki)
   IF (d_pos > 0)
    temp_req->qual[knt].d_nbr = trim(substring((d_pos+ 1),cki_len,o.cki))
   ENDIF
  FOOT REPORT
   CALL echo(build2("temp_req knt: ",knt)), temp_req->qual_knt = knt, stat = alterlist(temp_req->qual,
    knt)
  WITH nocounter
 ;end select
 CALL echo(build("***************curqual:",curqual))
 CALL echo(build2("print loc1: ",temp_req->qual[1].print_loc))
 SET temp_req_size = size(temp_req->qual,5)
 CALL echo("facility addr and phone")
 SELECT INTO "nl:"
  encntr_id = temp_req->qual[d.seq].encntr_id
  FROM (dummyt d  WITH seq = value(temp_req_size)),
   encounter e,
   location l,
   organization o,
   address a,
   phone p
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=temp_req->qual[d.seq].encntr_id))
   JOIN (l
   WHERE l.location_cd=e.location_cd
    AND l.active_ind=1)
   JOIN (o
   WHERE o.organization_id=l.organization_id)
   JOIN (a
   WHERE a.parent_entity_id=l.organization_id
    AND a.parent_entity_name="ORGANIZATION"
    AND a.address_type_cd=work_add_cd
    AND a.active_ind=1)
   JOIN (p
   WHERE (p.parent_entity_id= Outerjoin(l.organization_id))
    AND (p.parent_entity_name= Outerjoin("ORGANIZATION"))
    AND (p.phone_type_cd= Outerjoin(work_phone_cd))
    AND (p.active_ind= Outerjoin(1)) )
  DETAIL
   temp_req->qual[d.seq].organization_id = o.organization_id, temp_req->qual[d.seq].org_name = trim(o
    .org_name), temp_req->qual[d.seq].location_cd = l.location_cd,
   temp_req->qual[d.seq].loc_addr = trim(a.street_addr), temp_req->qual[d.seq].loc_addr2 = trim(a
    .street_addr2), temp_req->qual[d.seq].loc_city = trim(a.city)
   IF (a.state_cd=0)
    temp_req->qual[d.seq].loc_state = a.state
   ELSE
    temp_req->qual[d.seq].loc_state = uar_get_code_display(a.state_cd)
   ENDIF
   temp_req->qual[d.seq].loc_zip = a.zipcode, temp_req->qual[d.seq].loc_ph = p.phone_num,
   pod_loc_bed_cd = e.loc_bed_cd,
   pod_loc_room_cd = e.loc_room_cd, pod_loc_nurse_unit_cd = e.loc_nurse_unit_cd, pod_loc_building_cd
    = e.loc_building_cd,
   pod_loc_facility_cd = e.loc_facility_cd
  WITH nocounter
 ;end select
 CALL echo("pod logic code")
 SELECT INTO "nl:"
  sort_order =
  IF (pod_loc_bed_cd=cv.code_value) 1
  ELSEIF (pod_loc_room_cd=cv.code_value) 2
  ELSEIF (pod_loc_nurse_unit_cd=cv.code_value) 3
  ELSEIF (pod_loc_building_cd=cv.code_value) 4
  ELSEIF (pod_loc_facility_cd=cv.code_value) 5
  ENDIF
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=220
    AND cv.code_value IN (pod_loc_bed_cd, pod_loc_room_cd, pod_loc_nurse_unit_cd, pod_loc_building_cd,
   pod_loc_facility_cd))
  ORDER BY sort_order
  DETAIL
   pod_roombed = trim(build(cv.display_key,pod_roombed),3)
  WITH nocounter
 ;end select
 CALL echo("end pod logic code")
 CALL echo("enhanced view logic")
 SELECT INTO "nl:"
  FROM order_detail od
  PLAN (od
   WHERE (od.order_id=temp_req->qual[1].order_id)
    AND od.oe_field_meaning="PERFORMLOC")
  ORDER BY od.updt_dt_tm
  DETAIL
   w_print = od.oe_field_display_value
  WITH nocounter
 ;end select
 CALL echo(build("1w_print:",w_print))
 DECLARE queuename = vc
 EXECUTE bhs_sys_get_rxqueue_name value(request->order_qual[1].order_id)
 IF (queuename > " ")
  SET request->printer_name = queuename
  SET w_print = queuename
 ENDIF
 CALL echo(build("2w_print:",w_print))
 SET pod_printername = request->printer_name
 CALL echo("pod printername")
 SELECT INTO "nl:"
  cv1.display, cv2.definition
  FROM code_value cv1,
   code_value cv2
  PLAN (cv1
   WHERE cv1.code_set=103026
    AND cv1.display_key=pod_roombed)
   JOIN (cv2
   WHERE cv2.code_set=104103
    AND cv1.definition=cv2.display)
  DETAIL
   pod_printername = cv2.definition, w_print = cv2.definition
  WITH nocounter
 ;end select
 IF ((request->printer_name != "CER_T*"))
  SET request->printer_name = pod_printername
 ENDIF
 FOR (x = 1 TO size(temp_req->qual,5))
  CALL echo(build2("change print_loc1: ",request->printer_name))
  SET temp_req->qual[x].print_loc = request->printer_name
 ENDFOR
 CALL echo(build("3w_print:",w_print))
 CALL echo("ezscript addr and phone")
 SET ezscript_ind = 0
 FREE RECORD phy_phone_list
 RECORD phy_phone_list(
   1 cnt = i2
   1 qual[*]
     2 phone = c20
 )
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp_req->qual,5))),
   address a,
   phone p
  PLAN (d)
   JOIN (a
   WHERE (a.parent_entity_id=temp_req->qual[d.seq].phys_id)
    AND a.parent_entity_name="PERSON"
    AND a.address_type_cd=ezscriptaddress_var
    AND a.active_ind=1)
   JOIN (p
   WHERE (p.parent_entity_id= Outerjoin(temp_req->qual[d.seq].phys_id))
    AND (p.parent_entity_name= Outerjoin("PERSON"))
    AND (p.phone_type_cd= Outerjoin(ezscriptphone_var))
    AND (p.active_ind= Outerjoin(1)) )
  DETAIL
   temp_req->qual[d.seq].phys_addr_id = a.address_id, temp_req->qual[d.seq].phys_addr1 = trim(a
    .street_addr), temp_req->qual[d.seq].phys_addr2 = trim(a.street_addr2),
   temp_req->qual[d.seq].phys_addr3 = a.street_addr3, temp_req->qual[d.seq].phys_addr4 = a
   .street_addr4, temp_req->qual[d.seq].phys_city = concat(trim(a.city),", ",trim(a.state,3),"  ",
    trim(a.zipcode,3)),
   temp_req->qual[d.seq].phys_phone = p.phone_num
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET ezscript_ind = 1
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp_req->qual,5))),
   phone p
  PLAN (d)
   JOIN (p
   WHERE (p.parent_entity_id=temp_req->qual[d.seq].phys_id)
    AND p.parent_entity_name="PERSON"
    AND p.phone_type_cd=ezscriptphone_var
    AND p.active_ind=1)
  HEAD REPORT
   cnt = 0, ph_phone = fillstring(20,"")
  DETAIL
   ph_phone = replace(p.phone_num,"(","",0), ph_phone = replace(ph_phone,")","",0), ph_phone =
   replace(ph_phone,"-","",0),
   cnt += 1, stat = alterlist(phy_phone_list->qual,cnt), phy_phone_list->qual[cnt].phone = ph_phone
  FOOT REPORT
   phy_phone_list->cnt = cnt
  WITH nocounter
 ;end select
 IF ((temp_req->qual_knt < 1))
  CALL echo("***")
  CALL echo("***   No items found to print")
  CALL echo("***")
 ENDIF
 CALL echo("***")
 CALL echo("***   Get Phys Title")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(temp_req_size)),
   person_name p
  PLAN (d
   WHERE d.seq > 0)
   JOIN (p
   WHERE (p.person_id=temp_req->qual[d.seq].phys_id)
    AND p.name_type_cd=prsnl_type_cd
    AND p.active_ind=true
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
  DETAIL
   temp_req->qual[d.seq].phys_fname = trim(p.name_first), temp_req->qual[d.seq].phys_mname = trim(p
    .name_middle), temp_req->qual[d.seq].phys_lname = trim(p.name_last),
   temp_req->qual[d.seq].phys_title = trim(p.name_title)
   IF (p.name_first > " ")
    temp_req->qual[d.seq].phys_bname = trim(p.name_first)
    IF (p.name_middle > " ")
     temp_req->qual[d.seq].phys_bname = concat(trim(temp_req->qual[d.seq].phys_bname)," ",trim(p
       .name_middle))
     IF (p.name_last > " ")
      temp_req->qual[d.seq].phys_bname = concat(trim(temp_req->qual[d.seq].phys_bname)," ",trim(p
        .name_last))
      IF (p.name_suffix > " ")
       temp_req->qual[d.seq].phys_bname = concat(trim(temp_req->qual[d.seq].phys_bname)," ",trim(p
         .name_suffix))
      ENDIF
     ENDIF
    ELSEIF (p.name_last > " ")
     temp_req->qual[d.seq].phys_bname = concat(trim(temp_req->qual[d.seq].phys_bname)," ",trim(p
       .name_last))
     IF (p.name_suffix > " ")
      temp_req->qual[d.seq].phys_bname = concat(trim(temp_req->qual[d.seq].phys_bname)," ",trim(p
        .name_suffix))
     ENDIF
    ENDIF
   ELSEIF (p.name_middle > " ")
    temp_req->qual[d.seq].phys_bname = trim(p.name_middle)
    IF (p.name_last > " ")
     temp_req->qual[d.seq].phys_bname = concat(trim(temp_req->qual[d.seq].phys_bname)," ",trim(p
       .name_last))
     IF (p.name_suffix > " ")
      temp_req->qual[d.seq].phys_bname = concat(trim(temp_req->qual[d.seq].phys_bname)," ",trim(p
        .name_suffix))
     ENDIF
    ENDIF
   ELSEIF (p.name_last > " ")
    temp_req->qual[d.seq].phys_bname = concat(trim(temp_req->qual[d.seq].phys_bname)," ",trim(p
      .name_last))
    IF (p.name_suffix > " ")
     temp_req->qual[d.seq].phys_bname = concat(trim(temp_req->qual[d.seq].phys_bname)," ",trim(p
       .name_suffix))
    ENDIF
   ELSE
    temp_req->qual[d.seq].phys_bname = temp_req->qual[d.seq].phys_name
    IF (p.name_suffix > " ")
     temp_req->qual[d.seq].phys_bname = concat(trim(temp_req->qual[d.seq].phys_bname)," ",trim(p
       .name_suffix))
    ENDIF
   ENDIF
   IF ((temp_req->qual[d.seq].phys_bname > " ")
    AND p.name_title > " ")
    temp_req->qual[d.seq].phys_bname = concat(trim(temp_req->qual[d.seq].phys_bname),", ",trim(p
      .name_title))
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PERSON_NAME"
  CALL echo("go to exit 4")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(temp_req->qual_knt)),
   prsnl p
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=temp_req->qual[d.seq].eprsnl_id))
  DETAIL
   temp_req->qual[d.seq].eprsnl_name = p.name_full_formatted
  WITH nocounter
 ;end select
 CALL echo("Getting Diagnosis information")
 SELECT INTO "nl:"
  order_id = ner.parent_entity_id, diag = n.source_string
  FROM (dummyt d  WITH seq = value(size(temp_req->qual,5))),
   diagnosis dx,
   nomen_entity_reltn ner,
   nomenclature n
  PLAN (d)
   JOIN (ner
   WHERE (ner.parent_entity_id=temp_req->qual[d.seq].order_id)
    AND ner.parent_entity_name=ms_order_str
    AND ner.child_entity_name=ms_diag_str)
   JOIN (dx
   WHERE dx.diagnosis_id=ner.child_entity_id
    AND dx.diag_type_cd IN (mf_admit_cd, mf_work_cd, mf_discharge_cd)
    AND dx.active_ind=1
    AND dx.end_effective_dt_tm > sysdate)
   JOIN (n
   WHERE n.nomenclature_id=dx.nomenclature_id
    AND n.active_ind=1)
  HEAD dx.encntr_id
   ml_dxcnt = 0, ml_dx_maxcnt = 0
  DETAIL
   ml_dxcnt += 1, stat = alterlist(temp_req->qual,ml_dxcnt)
   IF (ml_dx_maxcnt <= 3
    AND dx.diag_type_cd IN (mf_admit_cd, mf_work_cd, mf_discharge_cd))
    ml_dx_maxcnt += 1
   ENDIF
   CALL echo(build("ML_DX_MAXCNT=",ml_dx_maxcnt))
   IF (ml_dx_maxcnt <= 3)
    CALL echo("Hitting if statement"),
    CALL echo(build("ML_DX_MAXCNT 2=",ml_dx_maxcnt))
    CASE (dx.diag_type_cd)
     OF mf_admit_cd:
      ms_diag_id = trim(n.source_identifier),ms_diag_dx_desc = trim(n.source_string),
      CALL echo(build("admitting=",ms_diag_dx_desc))temp_req->qual[d.seq].s_diagname = concat(trim(
        temp_req->qual[d.seq].s_diagname)," ",trim(ms_diag_dx_desc),"/ ")
     OF mf_work_cd:
      ms_diag_id = trim(n.source_identifier),ms_diag_dx_desc = trim(n.source_string),
      CALL echo(build("working=",ms_diag_dx_desc))temp_req->qual[d.seq].s_diagname = concat(trim(
        temp_req->qual[d.seq].s_diagname)," ",trim(ms_diag_dx_desc),"/ ")
     OF mf_discharge_cd:
      ms_diag_id = trim(n.source_identifier),ms_diag_dx_desc = trim(n.source_string),
      CALL echo(build("discharge=",ms_diag_dx_desc))temp_req->qual[d.seq].s_diagname = concat(trim(
        temp_req->qual[d.seq].s_diagname)," ",trim(ms_diag_dx_desc),"/ ")
     ELSE
      ms_diag_id = trim(n.source_identifier),ms_diag_dx_desc = trim(n.source_string),
      CALL echo(build("other=",ms_diag_dx_desc))temp_req->qual[d.seq].s_diagname = concat(trim(
        temp_req->qual[d.seq].s_diagname)," ",trim(ms_diag_dx_desc),"/ ")
    ENDCASE
    CALL echo(build("ms_diag_dx_desc=",ms_diag_dx_desc))
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build2("print loc2: ",temp_req->qual[1].print_loc))
 FOR (x = 1 TO temp_req_size)
   SELECT INTO "nl:"
    FROM order_detail od,
     oe_format_fields oef
    PLAN (od
     WHERE (od.order_id=temp_req->qual[x].order_id))
     JOIN (oef
     WHERE (oef.oe_format_id=temp_req->qual[x].oe_format_id)
      AND oef.oe_field_id=od.oe_field_id)
    ORDER BY od.order_id, oef.group_seq, oef.field_seq,
     od.oe_field_id, od.action_sequence DESC
    HEAD od.oe_field_id
     act_seq = od.action_sequence, odflag = true
    HEAD od.action_sequence
     IF (act_seq != od.action_sequence)
      odflag = false
     ENDIF
    DETAIL
     IF (odflag=true)
      IF (trim(od.oe_field_meaning)=trim("PRINTDEANUMBER"))
       temp_req->qual[x].print_dea = od.oe_field_value
      ELSEIF (trim(od.oe_field_meaning)=trim("STRENGTHDOSE"))
       temp_req->qual[x].strength_dose = trim(od.oe_field_display_value)
      ELSEIF (trim(od.oe_field_meaning)=trim("STRENGTHDOSEUNIT"))
       temp_req->qual[x].strength_dose_unit = trim(od.oe_field_display_value)
      ELSEIF (trim(od.oe_field_meaning)=trim("VOLUMEDOSE"))
       temp_req->qual[x].volume_dose = trim(od.oe_field_display_value)
      ELSEIF (trim(od.oe_field_meaning)=trim("VOLUMEDOSEUNIT"))
       temp_req->qual[x].volume_dose_unit = trim(od.oe_field_display_value)
      ELSEIF (trim(od.oe_field_meaning)=trim("FREETXTDOSE"))
       temp_req->qual[x].freetext_dose = trim(od.oe_field_display_value)
      ELSEIF (trim(od.oe_field_meaning)=trim("RXROUTE"))
       temp_req->qual[x].rx_route = trim(od.oe_field_display_value)
      ELSEIF (trim(od.oe_field_meaning)=trim("FREQ"))
       temp_req->qual[x].frequency = trim(od.oe_field_display_value)
      ELSEIF (trim(od.oe_field_meaning)=trim("DURATION"))
       temp_req->qual[x].duration = trim(od.oe_field_display_value)
      ELSEIF (trim(od.oe_field_meaning)=trim("DURATIONUNIT"))
       temp_req->qual[x].duration_unit = trim(od.oe_field_display_value)
      ELSEIF (trim(od.oe_field_meaning)="RXREQDISPENSEDURATION")
       IF (trim(temp_req->qual[x].duration) <= " ")
        temp_req->qual[x].n_rxreq_ind = 1, temp_req->qual[x].duration = trim(od
         .oe_field_display_value)
       ENDIF
      ELSEIF (trim(od.oe_field_meaning)="RXREQDISPENSEDURATIONUNIT")
       IF (trim(temp_req->qual[x].duration_unit) <= " ")
        temp_req->qual[x].n_rxreq_ind = 1, temp_req->qual[x].duration_unit = trim(od
         .oe_field_display_value)
       ENDIF
      ELSEIF (trim(od.oe_field_meaning)=trim("DISPENSEQTY"))
       temp_req->qual[x].dispense_qty = trim(od.oe_field_display_value)
      ELSEIF (trim(od.oe_field_meaning)=trim("DISPENSEQTYUNIT"))
       temp_req->qual[x].dispense_qty_unit = trim(od.oe_field_display_value)
      ELSEIF (trim(od.oe_field_meaning)=trim("NBRREFILLS"))
       temp_req->qual[x].nbr_refills_txt = trim(od.oe_field_display_value), temp_req->qual[x].
       nbr_refills = od.oe_field_value
      ELSEIF (trim(od.oe_field_meaning)=trim("ADDITIONALREFILLS")
       AND od.oe_field_value > 0)
       temp_req->qual[x].add_refills_txt = trim(od.oe_field_display_value), temp_req->qual[x].
       additionalrefills = od.oe_field_value
      ELSEIF (trim(od.oe_field_meaning)=trim("PRNINSTRUCTIONS")
       AND trim(od.oe_field_display_value) > "")
       temp_req->qual[x].prn_inst = trim(od.oe_field_display_value), temp_req->qual[x].prn_ind = 1
      ELSEIF (trim(od.oe_field_meaning)=trim("SPECINX"))
       temp_req->qual[x].special_inst = trim(od.oe_field_display_value)
      ELSEIF (trim(od.oe_field_meaning)=trim("INDICATION"))
       temp_req->qual[x].indications = trim(od.oe_field_display_value)
      ELSEIF (trim(od.oe_field_meaning)=trim("PRINTDEANUMBER"))
       temp_req->qual[x].daw = od.oe_field_value
      ELSEIF (trim(od.oe_field_meaning)=trim("PERFORMLOC"))
       temp_req->qual[x].perform_loc = trim(od.oe_field_display_value)
      ELSEIF (od.oe_field_meaning_id=1)
       temp_req->qual[x].free_txt_ord = trim(od.oe_field_display_value)
      ELSEIF (trim(od.oe_field_meaning)=trim("TOTALREFILLS"))
       temp_req->qual[x].total_refills = od.oe_field_value
      ELSEIF (trim(od.oe_field_meaning)=trim("ADDREFILLS"))
       temp_req->qual[x].add_refills_txt = trim(od.oe_field_display_value), temp_req->qual[x].
       add_refills = od.oe_field_value, temp_req->qual[x].refill_ind = true
      ELSEIF (trim(od.oe_field_meaning)="DONTPRINTRXREASON"
       AND od.oe_field_value > 0
       AND  NOT (is_a_reprint))
       temp_req->qual[x].no_print = true
      ELSEIF (trim(od.oe_field_meaning)=trim("ORDEROUTPUTDEST")
       AND is_a_reprint=false)
       temp_req->qual[x].output_dest_cd = od.oe_field_value
      ELSEIF (trim(od.oe_field_meaning)=trim("FREETEXTORDERFAXNUMBER")
       AND is_a_reprint=false)
       temp_req->qual[x].free_text_nbr = trim(od.oe_field_display_value,3)
      ELSEIF (trim(od.oe_field_meaning)=trim("OTHER")
       AND od.oe_field_id=mf_o2_amt_cd)
       temp_req->qual[x].s_o2_amt = trim(od.oe_field_display_value,3)
      ELSEIF (trim(od.oe_field_meaning)=trim("OTHER")
       AND od.oe_field_id=mf_o2_other_cd)
       temp_req->qual[x].s_o2_other = trim(od.oe_field_display_value,3)
      ELSEIF (trim(od.oe_field_meaning)=trim("OTHER")
       AND od.oe_field_id=mf_o2_portable_cd)
       temp_req->qual[x].s_o2_portable = trim(od.oe_field_display_value,3)
      ELSEIF (trim(od.oe_field_meaning)=trim("OTHER")
       AND od.oe_field_id=mf_duration_cd)
       temp_req->qual[x].s_o2_duration = trim(od.oe_field_display_value,3)
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (trim(temp_req->qual[x].freetext_dose) > " "
    AND trim(temp_req->qual[x].special_inst) > " "
    AND (temp_req->qual[x].n_rxreq_ind=1))
    CALL echo("spec_inst blank")
    SET temp_req->qual[x].sig_line = trim(temp_req->qual[x].special_inst)
    SET temp_req->qual[x].special_inst = ""
   ENDIF
   SELECT INTO "nl:"
    FROM orders o
    PLAN (o
     WHERE (o.order_id=temp_req->qual[x].order_id))
    DETAIL
     temp_req->qual[x].req_start_date = cnvtdatetime(curdate,0), temp_req->qual[x].req_refill_date =
     cnvtdatetime(curdate,0)
    WITH nocounter
   ;end select
 ENDFOR
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ORDER_DETAIL"
  CALL echo("go to exit 5")
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(temp_req->qual_knt)),
   order_comment oc,
   long_text lt
  PLAN (d
   WHERE d.seq > 0
    AND (temp_req->qual[d.seq].get_comment_ind=true))
   JOIN (oc
   WHERE (oc.order_id=temp_req->qual[d.seq].order_id)
    AND oc.comment_type_cd=ord_comment_cd)
   JOIN (lt
   WHERE lt.long_text_id=oc.long_text_id)
  ORDER BY oc.order_id, oc.action_sequence DESC
  HEAD oc.order_id
   found_comment = false
  DETAIL
   IF (found_comment=false)
    found_comment = true, temp_req->qual[d.seq].comments = lt.long_text
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ORDER_DETAIL"
  CALL echo("go to exit 6")
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  d.seq, ea.beg_effective_dt_tm
  FROM (dummyt d  WITH seq = value(temp_req->qual_knt)),
   encntr_alias ea
  PLAN (d
   WHERE d.seq > 0
    AND (temp_req->qual[d.seq].encntr_id > 0))
   JOIN (ea
   WHERE (ea.encntr_id=temp_req->qual[d.seq].encntr_id)
    AND ea.encntr_alias_type_cd=emrn_cd
    AND ea.active_ind=true
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY d.seq
  HEAD d.seq
   temp_req->qual[d.seq].found_emrn = true
   IF (ea.alias_pool_cd > 0)
    temp_req->qual[d.seq].mrn = trim(cnvtalias(ea.alias,ea.alias_pool_cd))
   ELSE
    temp_req->qual[d.seq].mrn = trim(ea.alias)
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "LOAD_EMRN"
  CALL echo("go to exit 7")
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  d.seq, pa.beg_effective_dt_tm
  FROM (dummyt d  WITH seq = value(temp_req_size)),
   person_alias pa
  PLAN (d
   WHERE d.seq > 0
    AND (temp_req->qual[d.seq].found_emrn=false))
   JOIN (pa
   WHERE (pa.person_id=request->person_id)
    AND pa.person_alias_type_cd=pmrn_cd
    AND pa.active_ind=true
    AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY d.seq
  HEAD d.seq
   temp_req->qual[d.seq].found_emrn = true
   IF (pa.alias_pool_cd > 0)
    temp_req->qual[d.seq].mrn = trim(cnvtalias(pa.alias,pa.alias_pool_cd))
   ELSE
    temp_req->qual[d.seq].mrn = trim(pa.alias)
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "LOAD_PMRN"
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  d.seq, pa.prsnl_alias_type_cd, pa.beg_effective_dt_tm
  FROM (dummyt d  WITH seq = value(temp_req_size)),
   prsnl_alias pa
  PLAN (d
   WHERE d.seq > 0
    AND (temp_req->qual[d.seq].no_print=false)
    AND (temp_req->qual[d.seq].phys_id > 0))
   JOIN (pa
   WHERE pa.person_id IN (temp_req->qual[d.seq].phys_id, sup_phy_id)
    AND pa.prsnl_alias_type_cd IN (docdea_cd, docnpi_cd)
    AND pa.active_ind=true
    AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY d.seq, pa.prsnl_alias_type_cd, pa.beg_effective_dt_tm DESC
  DETAIL
   IF (pa.prsnl_alias_type_cd=docdea_cd)
    IF ((pa.person_id=temp_req->qual[d.seq].phys_id))
     temp_req->qual[d.seq].phys_dea = trim(pa.alias)
    ELSE
     sup_phy_dea = trim(pa.alias)
    ENDIF
   ENDIF
   IF (pa.prsnl_alias_type_cd=docnpi_cd)
    IF ((pa.person_id=temp_req->qual[d.seq].phys_id))
     temp_req->qual[d.seq].phys_npi = trim(pa.alias)
    ELSE
     sup_phy_dea = trim(pa.alias)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  d.seq, pa.prsnl_alias_type_cd, pa.beg_effective_dt_tm
  FROM (dummyt d  WITH seq = value(temp_req_size)),
   prsnl_alias pa
  PLAN (d
   WHERE d.seq > 0
    AND (temp_req->qual[d.seq].no_print=false)
    AND (temp_req->qual[d.seq].eprsnl_id > 0))
   JOIN (pa
   WHERE (pa.person_id=temp_req->qual[d.seq].eprsnl_id)
    AND pa.prsnl_alias_type_cd IN (docdea_cd, docnpi_cd)
    AND pa.active_ind=true
    AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY d.seq, pa.prsnl_alias_type_cd, pa.beg_effective_dt_tm DESC
  HEAD REPORT
   found_dea = false
  HEAD d.seq
   found_dea = false
  HEAD pa.prsnl_alias_type_cd
   IF (found_dea=false
    AND pa.prsnl_alias_type_cd=docdea_cd)
    found_dea = true
    IF (pa.alias_pool_cd > 0)
     temp_req->qual[d.seq].eprsnl_dea = trim(cnvtalias(pa.alias,pa.alias_pool_cd))
    ELSE
     temp_req->qual[d.seq].eprsnl_dea = trim(pa.alias)
    ENDIF
   ENDIF
   IF (pa.prsnl_alias_type_cd=docnpi_cd)
    IF (pa.alias_pool_cd > 0)
     temp_req->qual[d.seq].eprsnl_npi = trim(cnvtalias(pa.alias,pa.alias_pool_cd))
    ELSE
     temp_req->qual[d.seq].eprsnl_npi = trim(pa.alias)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PHYS_DEA"
 ENDIF
 CALL echo("for loops")
 FOR (a = 1 TO temp_req->qual_knt)
   IF ((temp_req->qual[a].no_print=false))
    IF ((temp_req->qual[a].free_txt_ord > " "))
     SET temp_req->qual[a].med_name = trim(temp_req->qual[a].free_txt_ord)
    ELSE
     SET temp_req->qual[a].med_name = trim(temp_req->qual[a].order_as_mnemonic)
    ENDIF
    IF ((temp_req->qual[a].add_refills_txt > " ")
     AND (temp_req->qual[a].add_refills > 0))
     SET temp_req->qual[a].med_name = trim(temp_req->qual[a].med_name)
    ELSE
     IF ((temp_req->qual[a].nbr_refills_txt > " ")
      AND (temp_req->qual[a].nbr_refills > 0))
      IF ((temp_req->qual[a].nbr_refills=temp_req->qual[a].total_refills))
       SET temp_req->qual[a].refill_line = trim(temp_req->qual[a].nbr_refills_txt)
      ENDIF
     ENDIF
     IF ((temp_req->qual[a].refill_line > " "))
      SET pt->line_cnt = 0
      SET max_length = 45
      EXECUTE dcp_parse_text value(temp_req->qual[a].refill_line), value(max_length)
      SET temp_req->qual[a].refill_knt = pt->line_cnt
      SET stat = alterlist(temp_req->qual[a].refill,temp_req->qual[a].refill_knt)
      FOR (c = 1 TO pt->line_cnt)
        SET temp_req->qual[a].refill[c].disp = concat("<",trim(pt->lns[c].line),">")
      ENDFOR
     ENDIF
    ENDIF
    SET pt->line_cnt = 0
    SET max_length = 55
    EXECUTE dcp_parse_text value(temp_req->qual[a].med_name), value(max_length)
    SET temp_req->qual[a].med_knt = pt->line_cnt
    SET stat = alterlist(temp_req->qual[a].med,temp_req->qual[a].med_knt)
    FOR (c = 1 TO pt->line_cnt)
      SET temp_req->qual[a].med[c].disp = trim(pt->lns[c].line)
    ENDFOR
    IF ((temp_req->qual[a].additionalrefills=0))
     SET temp_req->qual[a].start_date = cnvtdatetime(cnvtdate(temp_req->qual[a].req_start_date),0)
    ELSE
     SET temp_req->qual[a].start_date = cnvtdatetime(cnvtdate(temp_req->qual[a].req_refill_date),0)
    ENDIF
    IF ((temp_req->qual[a].strength_dose > " ")
     AND (temp_req->qual[a].volume_dose > " "))
     CALL echo("***** sig line 1")
     SET temp_req->qual[a].sig_line = trim(temp_req->qual[a].volume_dose)
     IF ((temp_req->qual[a].strength_dose_unit > " "))
      SET temp_req->qual[a].sig_line = concat(trim(temp_req->qual[a].sig_line)," ",trim(temp_req->
        qual[a].volume_dose_unit))
     ENDIF
     IF ((temp_req->qual[a].rx_route > " "))
      SET temp_req->qual[a].sig_line = concat(trim(temp_req->qual[a].sig_line)," ",trim(temp_req->
        qual[a].rx_route))
     ENDIF
     IF ((temp_req->qual[a].frequency > " "))
      SET temp_req->qual[a].sig_line = concat(trim(temp_req->qual[a].sig_line)," ",trim(temp_req->
        qual[a].frequency))
     ENDIF
     IF ((temp_req->qual[a].duration > " "))
      SET temp_req->qual[a].sig_line = concat(trim(temp_req->qual[a].sig_line)," for ",trim(temp_req
        ->qual[a].duration))
     ENDIF
     IF ((temp_req->qual[a].duration_unit > " "))
      SET temp_req->qual[a].sig_line = concat(trim(temp_req->qual[a].sig_line)," ",trim(temp_req->
        qual[a].duration_unit))
     ENDIF
    ELSEIF ((temp_req->qual[a].strength_dose > " "))
     CALL echo("**** sig line 2")
     SET temp_req->qual[a].sig_line = trim(temp_req->qual[a].strength_dose)
     IF ((temp_req->qual[a].strength_dose_unit > " "))
      SET temp_req->qual[a].sig_line = concat(trim(temp_req->qual[a].sig_line)," ",trim(temp_req->
        qual[a].strength_dose_unit))
     ENDIF
     IF ((temp_req->qual[a].rx_route > " "))
      SET temp_req->qual[a].sig_line = concat(trim(temp_req->qual[a].sig_line)," ",trim(temp_req->
        qual[a].rx_route))
     ENDIF
     IF ((temp_req->qual[a].frequency > " "))
      SET temp_req->qual[a].sig_line = concat(trim(temp_req->qual[a].sig_line)," ",trim(temp_req->
        qual[a].frequency))
     ENDIF
     IF ((temp_req->qual[a].duration > " "))
      SET temp_req->qual[a].sig_line = concat(trim(temp_req->qual[a].sig_line)," for ",trim(temp_req
        ->qual[a].duration))
     ENDIF
     IF ((temp_req->qual[a].duration_unit > " "))
      SET temp_req->qual[a].sig_line = concat(trim(temp_req->qual[a].sig_line)," ",trim(temp_req->
        qual[a].duration_unit))
     ENDIF
    ELSEIF ((temp_req->qual[a].volume_dose > " "))
     CALL echo("***** sig line 3")
     SET temp_req->qual[a].sig_line = trim(temp_req->qual[a].volume_dose)
     IF ((temp_req->qual[a].volume_dose_unit > " "))
      SET temp_req->qual[a].sig_line = concat(trim(temp_req->qual[a].sig_line)," ",trim(temp_req->
        qual[a].volume_dose_unit))
     ENDIF
     IF ((temp_req->qual[a].rx_route > " "))
      SET temp_req->qual[a].sig_line = concat(trim(temp_req->qual[a].sig_line)," ",trim(temp_req->
        qual[a].rx_route))
     ENDIF
     IF ((temp_req->qual[a].frequency > " "))
      SET temp_req->qual[a].sig_line = concat(trim(temp_req->qual[a].sig_line)," ",trim(temp_req->
        qual[a].frequency))
     ENDIF
     IF ((temp_req->qual[a].duration > " "))
      SET temp_req->qual[a].sig_line = concat(trim(temp_req->qual[a].sig_line)," for ",trim(temp_req
        ->qual[a].duration))
     ENDIF
     IF ((temp_req->qual[a].duration_unit > " "))
      SET temp_req->qual[a].sig_line = concat(trim(temp_req->qual[a].sig_line)," ",trim(temp_req->
        qual[a].duration_unit))
     ENDIF
    ELSE
     CALL echo("***** sig line 4")
     IF (trim(temp_req->qual[a].freetext_dose) != "See Instructions")
      SET temp_req->qual[a].sig_line = trim(temp_req->qual[a].freetext_dose)
     ENDIF
     IF ((temp_req->qual[a].rx_route > " "))
      SET temp_req->qual[a].sig_line = concat(trim(temp_req->qual[a].sig_line)," ",trim(temp_req->
        qual[a].rx_route))
     ENDIF
     IF ((temp_req->qual[a].frequency > " "))
      SET temp_req->qual[a].sig_line = concat(trim(temp_req->qual[a].sig_line)," ",trim(temp_req->
        qual[a].frequency))
     ENDIF
     IF ((temp_req->qual[a].n_rxreq_ind=0))
      IF ((temp_req->qual[a].duration > " "))
       SET temp_req->qual[a].sig_line = concat(trim(temp_req->qual[a].sig_line)," for ",trim(temp_req
         ->qual[a].duration))
      ENDIF
      IF ((temp_req->qual[a].duration_unit > " "))
       SET temp_req->qual[a].sig_line = concat(trim(temp_req->qual[a].sig_line)," ",trim(temp_req->
         qual[a].duration_unit))
      ENDIF
     ENDIF
    ENDIF
    IF ((temp_req->qual[a].prn_ind=true))
     SET temp_req->qual[a].sig_line = concat(trim(temp_req->qual[a].sig_line)," PRN ",trim(temp_req->
       qual[a].prn_inst))
    ENDIF
    CALL echo("***** eprescribe comments")
    IF ((temp_req->qual[a].sig_line > " "))
     SET pt->line_cnt = 0
     SET max_length = 45
     EXECUTE dcp_parse_text value(temp_req->qual[a].sig_line), value(max_length)
     SET temp_req->qual[a].sig_knt = pt->line_cnt
     SET stat = alterlist(temp_req->qual[a].sig,temp_req->qual[a].sig_knt)
     FOR (c = 1 TO pt->line_cnt)
       SET temp_req->qual[a].sig[c].disp = trim(pt->lns[c].line)
     ENDFOR
    ENDIF
    IF ((temp_req->qual[a].dispense_qty > " "))
     SET temp_req->qual[a].dispense_line = trim(temp_req->qual[a].dispense_qty)
     IF ((temp_req->qual[a].dispense_qty_unit > " "))
      SET temp_req->qual[a].dispense_line = trim(concat(temp_req->qual[a].dispense_line," ",trim(
         temp_req->qual[a].dispense_qty_unit)))
     ENDIF
    ELSEIF ((temp_req->qual[a].dispense_qty_unit > " "))
     SET temp_req->qual[a].dispense_line = trim(temp_req->qual[a].dispense_qty_unit)
    ENDIF
    IF (trim(temp_req->qual[a].dispense_qty) <= " ")
     IF (trim(temp_req->qual[a].duration) > " ")
      SET temp_req->qual[a].dispense_line = trim(temp_req->qual[a].duration)
      IF (trim(temp_req->qual[a].duration_unit) > " ")
       SET temp_req->qual[a].dispense_line = trim(concat(temp_req->qual[a].dispense_line," ",trim(
          temp_req->qual[a].duration_unit)))
      ENDIF
     ELSEIF (trim(temp_req->qual[a].duration_unit) > " ")
      SET temp_req->qual[a].dispense_line = trim(temp_req->qual[a].duration_unit)
     ENDIF
     IF (trim(temp_req->qual[a].dispense_line) > " ")
      SET temp_req->qual[a].dispense_line = concat(temp_req->qual[a].dispense_line," supply")
     ENDIF
    ENDIF
    IF ((temp_req->qual[a].dispense_line > " "))
     SET pt->line_cnt = 0
     SET max_length = 45
     EXECUTE dcp_parse_text value(temp_req->qual[a].dispense_line), value(max_length)
     SET temp_req->qual[a].dispense_knt = pt->line_cnt
     SET stat = alterlist(temp_req->qual[a].dispense,temp_req->qual[a].dispense_knt)
     FOR (c = 1 TO pt->line_cnt)
       SET temp_req->qual[a].dispense[c].disp = concat("<",trim(pt->lns[c].line),">")
     ENDFOR
    ENDIF
    IF ((temp_req->qual[a].dispense_line > " "))
     SET pt->line_cnt = 0
     SET max_length = 45
     EXECUTE dcp_parse_text value(temp_req->qual[a].dispense_line), value(max_length)
     SET temp_req->qual[a].dispense_knt = pt->line_cnt
     SET stat = alterlist(temp_req->qual[a].dispense,temp_req->qual[a].dispense_knt)
     FOR (c = 1 TO pt->line_cnt)
       SET temp_req->qual[a].dispense[c].disp = concat("<",trim(pt->lns[c].line),">")
     ENDFOR
    ENDIF
    IF ((temp_req->qual[a].special_inst > " "))
     SET temp_req->qual[a].special_inst = trim(temp_req->qual[a].special_inst)
     SET pt->line_cnt = 0
     SET max_length = 45
     EXECUTE dcp_parse_text value(temp_req->qual[a].special_inst), value(max_length)
     SET temp_req->qual[a].special_knt = pt->line_cnt
     SET stat = alterlist(temp_req->qual[a].special,temp_req->qual[a].special_knt)
     FOR (c = 1 TO pt->line_cnt)
       SET temp_req->qual[a].special[c].disp = trim(pt->lns[c].line)
     ENDFOR
    ENDIF
    IF ((temp_req->qual[a].indications > " "))
     SET temp_req->qual[a].indications = trim(temp_req->qual[a].indications)
     SET pt->line_cnt = 0
     SET max_length = 45
     EXECUTE dcp_parse_text value(temp_req->qual[a].indications), value(max_length)
     SET temp_req->qual[a].indic_knt = pt->line_cnt
     SET stat = alterlist(temp_req->qual[a].indic,temp_req->qual[a].indic_knt)
     FOR (c = 1 TO pt->line_cnt)
       SET temp_req->qual[a].indic[c].disp = trim(pt->lns[c].line)
     ENDFOR
    ENDIF
    IF ((temp_req->qual[a].comments > " "))
     SET temp_req->qual[a].comments = trim(temp_req->qual[a].comments)
     SET pt->line_cnt = 0
     SET max_length = 45
     EXECUTE dcp_parse_text value(temp_req->qual[a].comments), value(max_length)
     SET temp_req->qual[a].comment_knt = pt->line_cnt
     SET stat = alterlist(temp_req->qual[a].comment,temp_req->qual[a].comment_knt)
     FOR (c = 1 TO pt->line_cnt)
       SET temp_req->qual[a].comment[c].disp = trim(pt->lns[c].line)
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
 CALL echo(build2("print loc3: ",temp_req->qual[1].print_loc))
 CALL echo("build print record")
 FREE RECORD tprint_req
 RECORD tprint_req(
   1 job_knt = i4
   1 job[*]
     2 refill_ind = i2
     2 position_cd = f8
     2 phys_name = vc
     2 phys_bname = vc
     2 phys_fname = vc
     2 phys_mname = vc
     2 phys_lname = vc
     2 eprsnl_ind = i2
     2 eprsnl_dea = vc
     2 eprsnl_npi = vc
     2 eprsnl_name = vc
     2 eprsnl_bname = vc
     2 eprsnl_fname = vc
     2 eprsnl_mname = vc
     2 eprsnl_lname = vc
     2 phys_addr1 = vc
     2 phys_addr2 = vc
     2 phys_addr3 = vc
     2 phys_addr4 = vc
     2 phys_city = vc
     2 phys_dea = vc
     2 phys_npi = vc
     2 phys_lnbr = vc
     2 phys_phone = vc
     2 csa_group = c1
     2 phys_ord_dt = vc
     2 output_dest_cd = f8
     2 free_text_nbr = vc
     2 print_loc = vc
     2 daw = i2
     2 mrn = vc
     2 hp_found = i2
     2 hp_pri_name = vc
     2 hp_pri_polgrp = vc
     2 hp_sec_name = vc
     2 hp_sec_polgrp = vc
     2 req_knt = i4
     2 req[*]
       3 order_id = f8
       3 ord_det_disp = vc
       3 print_dea = i2
       3 csa_sched = c1
       3 start_dt = vc
       3 total_refill = c3
       3 med_knt = i4
       3 med[*]
         4 disp = vc
       3 sig_knt = i4
       3 sig[*]
         4 disp = vc
       3 dispense_knt = i4
       3 dispense[*]
         4 disp = vc
       3 dispense_duration_knt = i4
       3 dispense_duration[*]
         4 disp = vc
       3 refill_knt = i4
       3 refill[*]
         4 disp = vc
       3 special_knt = i4
       3 special[*]
         4 disp = vc
       3 prn_knt = i4
       3 prn[*]
         4 disp = vc
       3 indic_knt = i4
       3 indic[*]
         4 disp = vc
       3 comment_knt = i4
       3 comment[*]
         4 disp = vc
       3 special_inst = vc
       3 s_o2_amt = vc
       3 s_o2_other = vc
       3 s_o2_portable = vc
       3 s_o2_duration = vc
     2 organization_id = f8
     2 org_name = vc
     2 location_cd = f8
     2 loc_addr = c30
     2 loc_addr2 = c30
     2 loc_city = c30
     2 loc_state = c2
     2 loc_zip = c5
     2 loc_ph = c14
     2 s_diagname = vc
 )
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  encntr_id = temp_req->qual[d.seq].encntr_id, print_loc = temp_req->qual[d.seq].print_loc,
  order_status = temp_req->qual[d.seq].order_status,
  order_dt = format(cnvtdatetime(temp_req->qual[d.seq].order_dt),"mm/dd/yyyy;;d"), print_dea =
  temp_req->qual[d.seq].print_dea, daw = temp_req->qual[d.seq].daw,
  output_dest_cd = temp_req->qual[d.seq].output_dest_cd, free_text_nbr = temp_req->qual[d.seq].
  free_text_nbr, fax_seq = build(temp_req->qual[d.seq].output_dest_cd,temp_req->qual[d.seq].
   free_text_nbr),
  phys_id = temp_req->qual[d.seq].phys_id, phys_addr_id = temp_req->qual[d.seq].phys_addr_id,
  phys_seq = build(temp_req->qual[d.seq].phys_id,temp_req->qual[d.seq].phys_addr_id),
  refill_ind = temp_req->qual[d.seq].nbr_refills, o_seq_1 = build(temp_req->qual[d.seq].refill_ind,
   temp_req->qual[d.seq].encntr_id), d.seq
  FROM (dummyt d  WITH seq = value(temp_req_size))
  PLAN (d
   WHERE d.seq > 0
    AND (temp_req->qual[d.seq].no_print=false)
    AND  NOT ((temp_req->qual[d.seq].order_status IN (canceled_cd, completed_cd, discontinued_cd,
   9314, 2545,
   2544, 2552))))
  ORDER BY o_seq_1, order_dt, daw,
   print_loc, fax_seq, phys_seq,
   print_dea, d.seq
  HEAD REPORT
   jknt = 0, rknt = 0, stat = alterlist(tprint_req->job,10),
   new_job = false, temp_o_seq_1 = fillstring(255," "), temp_order_dt = fillstring(12," "),
   temp_print_loc = fillstring(255," "), temp_output_dest_cd = 0.0, temp_free_text_nbr = fillstring(
    255," "),
   temp_phys_id = 0.0, temp_phys_addr_id = 0.0, temp_daw = 0,
   temp_csa_group = fillstring(1," "), temp_csa_scheudle = fillstring(1," ")
  DETAIL
   IF (temp_o_seq_1 != o_seq_1)
    new_job = true
   ENDIF
   IF (temp_order_dt != order_dt)
    new_job = true
   ENDIF
   IF (temp_print_loc != print_loc)
    new_job = true
   ENDIF
   IF (temp_output_dest_cd != output_dest_cd)
    new_job = true
   ENDIF
   IF (temp_free_text_nbr != free_text_nbr)
    new_job = true
   ENDIF
   IF (temp_phys_id != phys_id)
    new_job = true
   ENDIF
   IF (temp_phys_addr_id != phys_addr_id)
    new_job = true
   ENDIF
   IF (temp_daw != daw)
    new_job = true
   ENDIF
   IF (new_job=true)
    new_job = false
    IF (jknt > 0)
     tprint_req->job[jknt].req_knt = rknt, stat = alterlist(tprint_req->job[jknt].req,rknt)
    ENDIF
    jknt += 1
    IF (mod(jknt,10)=1
     AND jknt != 1)
     stat = alterlist(tprint_req->job,(jknt+ 9))
    ENDIF
    tprint_req->job[jknt].refill_ind = temp_req->qual[d.seq].refill_ind, tprint_req->job[jknt].
    phys_name = temp_req->qual[d.seq].phys_name, tprint_req->job[jknt].position_cd = temp_req->qual[d
    .seq].position_cd,
    tprint_req->job[jknt].phys_bname = temp_req->qual[d.seq].phys_bname, tprint_req->job[jknt].
    phys_fname = temp_req->qual[d.seq].phys_fname, tprint_req->job[jknt].phys_mname = temp_req->qual[
    d.seq].phys_mname,
    tprint_req->job[jknt].phys_lname = temp_req->qual[d.seq].phys_lname, tprint_req->job[jknt].
    eprsnl_ind = temp_req->qual[d.seq].eprsnl_ind, tprint_req->job[jknt].eprsnl_name = temp_req->
    qual[d.seq].eprsnl_name,
    tprint_req->job[jknt].phys_addr1 = temp_req->qual[d.seq].phys_addr1, tprint_req->job[jknt].
    phys_addr2 = temp_req->qual[d.seq].phys_addr2, tprint_req->job[jknt].phys_addr3 = temp_req->qual[
    d.seq].phys_addr3,
    tprint_req->job[jknt].phys_addr4 = temp_req->qual[d.seq].phys_addr4, tprint_req->job[jknt].
    phys_city = temp_req->qual[d.seq].phys_city, tprint_req->job[jknt].phys_dea = temp_req->qual[d
    .seq].phys_dea,
    tprint_req->job[jknt].phys_npi = temp_req->qual[d.seq].phys_npi, tprint_req->job[jknt].phys_lnbr
     = temp_req->qual[d.seq].phys_lnbr, tprint_req->job[jknt].phys_phone = temp_req->qual[d.seq].
    phys_phone,
    tprint_req->job[jknt].phys_ord_dt = order_dt, tprint_req->job[jknt].organization_id = temp_req->
    qual[d.seq].organization_id, tprint_req->job[jknt].org_name = temp_req->qual[d.seq].org_name,
    tprint_req->job[jknt].location_cd = temp_req->qual[d.seq].location_cd, tprint_req->job[jknt].
    loc_addr = temp_req->qual[d.seq].loc_addr, tprint_req->job[jknt].loc_addr2 = temp_req->qual[d.seq
    ].loc_addr2,
    tprint_req->job[jknt].loc_city = temp_req->qual[d.seq].loc_city, tprint_req->job[jknt].loc_state
     = temp_req->qual[d.seq].loc_state, tprint_req->job[jknt].loc_zip = temp_req->qual[d.seq].loc_zip,
    tprint_req->job[jknt].loc_ph = temp_req->qual[d.seq].loc_ph, tprint_req->job[jknt].eprsnl_dea =
    temp_req->qual[d.seq].eprsnl_dea, tprint_req->job[jknt].eprsnl_npi = temp_req->qual[d.seq].
    eprsnl_npi,
    tprint_req->job[jknt].s_diagname = temp_req->qual[d.seq].s_diagname
    IF ((tprint_req->job[jknt].csa_group="A"))
     tprint_req->job[jknt].output_dest_cd = - (1), tprint_req->job[jknt].free_text_nbr = "1"
    ELSE
     tprint_req->job[jknt].output_dest_cd = temp_req->qual[d.seq].output_dest_cd, tprint_req->job[
     jknt].free_text_nbr = trim(temp_req->qual[d.seq].free_text_nbr)
    ENDIF
    tprint_req->job[jknt].print_loc = trim(temp_req->qual[d.seq].print_loc), tprint_req->job[jknt].
    daw = temp_req->qual[d.seq].daw, tprint_req->job[jknt].mrn = temp_req->qual[d.seq].mrn
    IF ((((temp_req->qual[d.seq].hp_pri_found=true)) OR ((temp_req->qual[d.seq].hp_sec_found=true)))
    )
     tprint_req->job[jknt].hp_found = true
    ENDIF
    tprint_req->job[jknt].hp_pri_name = temp_req->qual[d.seq].hp_pri_name, tprint_req->job[jknt].
    hp_pri_polgrp = temp_req->qual[d.seq].hp_pri_polgrp, tprint_req->job[jknt].hp_sec_name = temp_req
    ->qual[d.seq].hp_sec_name,
    tprint_req->job[jknt].hp_sec_polgrp = temp_req->qual[d.seq].hp_sec_polgrp, temp_o_seq_1 = o_seq_1,
    temp_order_dt = order_dt,
    temp_print_loc = print_loc, temp_output_dest_cd = output_dest_cd, temp_free_text_nbr =
    free_text_nbr,
    temp_phys_id = phys_id, temp_phys_addr_id = phys_addr_id, temp_daw = daw,
    rknt = 0, stat = alterlist(tprint_req->job[jknt].req,10)
   ENDIF
   IF (jknt > 0)
    rknt += 1
    IF (mod(rknt,10)=1
     AND rknt != 1)
     stat = alterlist(tprint_req->job[jknt].req,(rknt+ 9))
    ENDIF
    tprint_req->job[jknt].req[rknt].print_dea = temp_req->qual[d.seq].print_dea, tprint_req->job[jknt
    ].req[rknt].order_id = temp_req->qual[d.seq].order_id, tprint_req->job[jknt].req[rknt].
    ord_det_disp = temp_req->qual[d.seq].ord_det_disp,
    tprint_req->job[jknt].req[rknt].start_dt = format(cnvtdatetime(temp_req->qual[d.seq].start_date),
     "mm/dd/yyyy;;d"), tprint_req->job[jknt].req[rknt].med_knt = temp_req->qual[d.seq].med_knt, stat
     = alterlist(tprint_req->job[jknt].req[rknt].med,tprint_req->job[jknt].req[rknt].med_knt)
    FOR (z = 1 TO tprint_req->job[jknt].req[rknt].med_knt)
      tprint_req->job[jknt].req[rknt].med[z].disp = temp_req->qual[d.seq].med[z].disp
    ENDFOR
    tprint_req->job[jknt].req[rknt].sig_knt = temp_req->qual[d.seq].sig_knt, stat = alterlist(
     tprint_req->job[jknt].req[rknt].sig,tprint_req->job[jknt].req[rknt].sig_knt)
    FOR (z = 1 TO tprint_req->job[jknt].req[rknt].sig_knt)
      tprint_req->job[jknt].req[rknt].sig[z].disp = temp_req->qual[d.seq].sig[z].disp
    ENDFOR
    IF ((temp_req->qual[d.seq].dispense_knt > 0))
     tprint_req->job[jknt].req[rknt].dispense_knt = temp_req->qual[d.seq].dispense_knt, stat =
     alterlist(tprint_req->job[jknt].req[rknt].dispense,tprint_req->job[jknt].req[rknt].dispense_knt)
     FOR (z = 1 TO tprint_req->job[jknt].req[rknt].dispense_knt)
       tprint_req->job[jknt].req[rknt].dispense[z].disp = temp_req->qual[d.seq].dispense[z].disp
     ENDFOR
    ELSE
     tprint_req->job[jknt].req[rknt].dispense_duration_knt = temp_req->qual[d.seq].
     dispense_duration_knt, stat = alterlist(tprint_req->job[jknt].req[rknt].dispense_duration,
      tprint_req->job[jknt].req[rknt].dispense_duration_knt)
     FOR (z = 1 TO tprint_req->job[jknt].req[rknt].dispense_duration_knt)
       tprint_req->job[jknt].req[rknt].dispense_duration[z].disp = temp_req->qual[d.seq].
       dispense_duration_qual[z].disp
     ENDFOR
    ENDIF
    tprint_req->job[jknt].req[rknt].refill_knt = temp_req->qual[d.seq].refill_knt, stat = alterlist(
     tprint_req->job[jknt].req[rknt].refill,tprint_req->job[jknt].req[rknt].refill_knt)
    FOR (z = 1 TO tprint_req->job[jknt].req[rknt].refill_knt)
      tprint_req->job[jknt].req[rknt].refill[z].disp = temp_req->qual[d.seq].refill[z].disp
    ENDFOR
    tprint_req->job[jknt].req[rknt].special_knt = temp_req->qual[d.seq].special_knt, stat = alterlist
    (tprint_req->job[jknt].req[rknt].special,tprint_req->job[jknt].req[rknt].special_knt)
    FOR (z = 1 TO tprint_req->job[jknt].req[rknt].special_knt)
      tprint_req->job[jknt].req[rknt].special[z].disp = temp_req->qual[d.seq].special[z].disp
    ENDFOR
    tprint_req->job[jknt].req[rknt].prn_knt = temp_req->qual[d.seq].prn_knt, stat = alterlist(
     tprint_req->job[jknt].req[rknt].prn,tprint_req->job[jknt].req[rknt].prn_knt)
    FOR (z = 1 TO tprint_req->job[jknt].req[rknt].prn_knt)
      tprint_req->job[jknt].req[rknt].prn[z].disp = temp_req->qual[d.seq].prn[z].disp
    ENDFOR
    tprint_req->job[jknt].req[rknt].indic_knt = temp_req->qual[d.seq].indic_knt, stat = alterlist(
     tprint_req->job[jknt].req[rknt].indic,tprint_req->job[jknt].req[rknt].indic_knt)
    FOR (z = 1 TO tprint_req->job[jknt].req[rknt].indic_knt)
      tprint_req->job[jknt].req[rknt].indic[z].disp = temp_req->qual[d.seq].indic[z].disp
    ENDFOR
    tprint_req->job[jknt].req[rknt].comment_knt = temp_req->qual[d.seq].comment_knt, stat = alterlist
    (tprint_req->job[jknt].req[rknt].comment,tprint_req->job[jknt].req[rknt].comment_knt)
    FOR (z = 1 TO tprint_req->job[jknt].req[rknt].comment_knt)
      tprint_req->job[jknt].req[rknt].comment[z].disp = temp_req->qual[d.seq].comment[z].disp
    ENDFOR
    tprint_req->job[jknt].req[rknt].s_o2_amt = temp_req->qual[d.seq].s_o2_amt, tprint_req->job[jknt].
    req[rknt].s_o2_other = temp_req->qual[d.seq].s_o2_other, tprint_req->job[jknt].req[rknt].
    s_o2_portable = temp_req->qual[d.seq].s_o2_portable,
    tprint_req->job[jknt].req[rknt].s_o2_duration = temp_req->qual[d.seq].s_o2_duration
   ENDIF
  FOOT REPORT
   tprint_req->job_knt = jknt, stat = alterlist(tprint_req->job,jknt), tprint_req->job[jknt].req_knt
    = rknt,
   stat = alterlist(tprint_req->job[jknt].req,rknt)
  WITH nocounter
 ;end select
 CALL echo(build2("print loc4: ",tprint_req->job[1].print_loc))
 CALL echo(build2("print loc5: ",temp_req->qual[1].print_loc))
 SET tprint_job_size = size(tprint_req->job,5)
 FOR (i = 1 TO tprint_job_size)
   FOR (ii = 1 TO size(tprint_req->job[i].req,5))
     FOR (x = 1 TO size(temp_req->qual,5))
       IF ((temp_req->qual[x].order_id=tprint_req->job[i].req[ii].order_id))
        IF ((temp_req->qual[x].additionalrefills > 0))
         SET tprint_req->job[i].req[ii].total_refill = trim(cnvtstring((temp_req->qual[x].
           additionalrefills - 1)))
        ELSE
         IF (trim(temp_req->qual[x].nbr_refills_txt) > "")
          SET tprint_req->job[i].req[ii].total_refill = trim(temp_req->qual[x].nbr_refills_txt)
         ELSE
          SET tprint_req->job[i].req[ii].total_refill = "0"
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
 FOR (i = 1 TO tprint_req->job_knt)
   FOR (ii = 1 TO tprint_req->job[i].req_knt)
     SET oid = 0.0
     SET oid = tprint_req->job[i].req[ii].order_id
     IF (reflect(parameter(1,0)) > " ")
      SET tprint_req->job[i].print_loc =  $1
      SET request->printer_name =  $1
      SET temp_req->qual[i].print_loc =  $1
      SET tprint_req->job[i].output_dest_cd = 0
      SET xoffdyn = 100
     ELSE
      SET xoffdyn = 15
     ENDIF
     IF ((tprint_req->job[i].output_dest_cd < 1))
      CALL echo("zebra printing 1")
      IF (trim(tprint_req->job[i].print_loc) IN ("bmc34rxpain1", "bmc34rxpain2", "bis361rn1_fold",
      "bis361rn1"))
       CALL echo(tprint_req->job[1].organization_id)
       CALL echo(work_phone_cd)
       CALL echo(clinic_add_cd)
       CALL echo(prt_encntr_id)
       CALL echo(tprint_req->job[i].print_loc)
       SELECT INTO value(tprint_req->job[i].print_loc)
        org = substring(1,30,o.org_name), location = uar_get_code_display(e.loc_nurse_unit_cd),
        street = a.street_addr,
        city = a.city, st = a.state, zip = a.zipcode,
        phone = p.phone_num
        FROM encounter e,
         address a,
         phone p,
         organization o
        PLAN (e
         WHERE e.encntr_id=prt_encntr_id
          AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
          AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
         JOIN (a
         WHERE (a.parent_entity_id= Outerjoin(e.loc_nurse_unit_cd))
          AND (a.address_type_cd= Outerjoin(clinic_add_cd)) )
         JOIN (p
         WHERE (p.parent_entity_id= Outerjoin(e.loc_nurse_unit_cd))
          AND (p.phone_type_cd= Outerjoin(work_phone_cd)) )
         JOIN (o
         WHERE (o.organization_id=tprint_req->job[1].organization_id))
        HEAD REPORT
         xpos = 0, xpos1 = 0, ypos = 0,
         ypos1 = 0, xoffset = 0, yoffset = 0,
         y_jump = 0, ct_xpos = 0, sig_x = 36,
         sig_1st = 1, assoc_1 = concat("{b}","Supervising Physician","{endb}"), yvar = 0,
         yvar1 = 0,
         MACRO (strip)
          x = 0, len = 0, x = findstring(">",exp),
          len = size(trim(exp)), x2 = (len - 2), exp2 = substring(2,x2,exp)
         ENDMACRO
         , line1 = fillstring(60,"_"),
         line2 = fillstring(53,"_"), line3 = fillstring(64,"_"),
         MACRO (set_font_a)
          y_jump = 5, "{f/0/3}{lpi/32}{cpi/24}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_1)
          y_jump = 12, "{f/2/1}{lpi/6}{cpi/18}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_2)
          y_jump = 7, "{f/2/1}{lpi/8}{cpi/18}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_3)
          y_jump = 10, "{f/0/5}{lpi/32}{cpi/18}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_4)
          y_jump = 10, "{f/1/1}{cpi/12}{lpi/6}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_5)
          y_jump = 10, "{f/5/1}{cpi/17}{lpi/12}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_6)
          y_jump = 14, "{f/2/1}{lpi/4}{cpi/18}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_7)
          y_jump = 15, "{f/1/1}{lpi/6}{cpi/18}{b}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_8)
          y_jump = 12, "{f/1/1}{lpi/8}{cpi/18}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_9)
          y_jump = 5, "{f/1/1}{cpi/23}{lpi/12}", row + 1
         ENDMACRO
         ,
         MACRO (calc_pos)
          row + 1, xpos = (xpos1+ xoffset), ypos = (ypos1+ yoffset),
          CALL print(calcpos(xpos,ypos)), xpos1 = 0
         ENDMACRO
         , set_font_2, lt_xpos = xoffdyn,
         ct_xpos = 150, ypos = 15, bay = concat("{b}","BAYSTATE HEALTH","{endb}"),
         xpos = (ct_xpos - 45),
         CALL print(calcpos(xpos,ypos)), bay,
         row + 1, ypos += y_jump, xoffset = cnvtint(((size(trim(location)) * 4)/ 2)),
         xpos = (ct_xpos - xoffset), nur_unit = trim(location,3),
         CALL print(calcpos(xpos,ypos)),
         nur_unit, row + 1, ypos += y_jump,
         xoffset = cnvtint(((size(trim(street)) * 4)/ 2)), xpos = (ct_xpos - xoffset), str = trim(
          street),
         CALL print(calcpos(xpos,ypos)), str, row + 1,
         ypos += y_jump, csz = concat(trim(city),", ",trim(st),"  ",trim(zip)), xoffset = cnvtint(((
          size(trim(csz)) * 4)/ 2)),
         xpos = (ct_xpos - xoffset),
         CALL print(calcpos(xpos,ypos)), csz,
         row + 1, ypos += y_jump, p_phone = trim(phone),
         xoffset = cnvtint(((size(trim(concat("Phone: ",p_phone))) * 4)/ 2)), xpos = (ct_xpos -
         xoffset),
         CALL print(calcpos(xpos,ypos)),
         "{b}Phone: {endb}", p_phone, row + 1,
         ypos += (y_jump * 2), xpos = lt_xpos,
         CALL print(calcpos(xpos,ypos)),
         "{b}Date: {endb}", tprint_req->job[i].req[ii].start_dt, row + 1,
         ypos += (y_jump * 2), set_font_4,
         CALL print(calcpos(xpos,ypos)),
         "{b}", demo_info->pat_name, "{endb}",
         ypos += (y_jump * 2), row + 1, set_font_2,
         CALL print(calcpos(xpos,ypos)), "Date Of Birth: ", demo_info->pat_bday,
         row + 1, ypos += (y_jump * 1.5),
         CALL print(calcpos(xpos,ypos)),
         "Address: ", demo_info->pat_addr, row + 1,
         ypos += y_jump,
         CALL print(calcpos(xpos,ypos)), "City: ",
         demo_info->pat_city, row + 1, ypos += (y_jump * 2),
         CALL echo("amount O2"),
         CALL print(calcpos(xpos,ypos)), "{b}Home Oxygen: {endb}",
         tprint_req->job[i].req[ii].s_o2_amt, row + 1, ypos += (y_jump * 2)
         IF (textlen(trim(tprint_req->job[i].req[ii].s_o2_other,3)) > 0)
          CALL echo("other O2"),
          CALL print(calcpos(xpos,ypos)), "{b}Other O2: {endb}",
          tprint_req->job[i].req[ii].s_o2_other, row + 1, ypos += (y_jump * 2)
         ENDIF
         CALL echo("portable O2 needed"),
         CALL print(calcpos(xpos,ypos)), "{b}Portable O2 Needed: {endb}",
         tprint_req->job[i].req[ii].s_o2_portable, row + 1, ypos += (y_jump * 2)
         IF ((tprint_req->job[i].req[ii].special_knt > 0))
          xpos = lt_xpos, ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)),
          "{b}Spe. Inst: {endb}", xpos = (65+ lt_xpos)
          FOR (x = 1 TO tprint_req->job[i].req[ii].special_knt)
            CALL print(calcpos(xpos,ypos)), spe_inst = cnvtupper(tprint_req->job[i].req[ii].special[x
             ].disp), spe_inst,
            row + 1, ypos += (y_jump * 2)
          ENDFOR
         ENDIF
         row + 1, xpos = lt_xpos,
         CALL echo("O2 duration"),
         CALL print(calcpos(xpos,ypos)), "{b}Duration: {endb}", tprint_req->job[i].req[ii].
         s_o2_duration,
         row + 1, ypos += (y_jump * 2), row + 1,
         xpos = lt_xpos, ypos += (y_jump * 2)
         FOR (x = 1 TO tprint_req->job[i].req[ii].indic_knt)
           IF (x=1)
            CALL print(calcpos(xpos,ypos)), "{b}Indications : ", ind = cnvtupper(trim(tprint_req->
              job[i].req[ii].indic[x].disp)),
            ind, row + 1
           ELSE
            xpos = lt_xpos, ypos += (y_jump * 2),
            CALL print(calcpos(xpos,ypos)),
            ind = cnvtupper(trim(tprint_req->job[i].req[ii].indic[x].disp)), ind, row + 1
           ENDIF
         ENDFOR
         xpos = lt_xpos, ypos += (y_jump * 2),
         CALL echo("zebra printing 3"),
         ypos += (y_jump * 2),
         CALL print(calcpos(xpos,ypos)), "{b}Comment : ",
         xpos = 65
         FOR (x = 1 TO tprint_req->job[i].req[ii].comment_knt)
           CALL print(calcpos(xpos,ypos)), comment = cnvtupper(tprint_req->job[i].req[ii].comment[x].
            disp), comment,
           ypos += (y_jump * 2)
         ENDFOR
         row + 1, xpos = lt_xpos, ypos += (y_jump * 2),
         CALL print(calcpos(xpos,ypos)), "{b}DISP: ", exp = cnvtupper(tprint_req->job[i].req[ii].
          dispense[1].disp),
         strip, exp2, row + 1,
         ypos = 250
         IF (np_ind=true)
          xpos = lt_xpos, ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)),
          "{b}DX: {endb}", tprint_req->job[i].s_diagname, row + 1,
          ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)), "{b}SIGNATURE: {endb}",
          line2, row + 1, ypos += y_jump,
          xoffset = cnvtint(((size(trim(tprint_req->job[i].eprsnl_name)) * 2)/ 2)), xpos = (ct_xpos
           - xoffset),
          CALL print(calcpos(xpos,ypos)),
          tprint_req->job[i].eprsnl_name, row + 1, xpos = lt_xpos,
          ypos += (y_jump * 1.5),
          CALL print(calcpos(xpos,ypos)), "{b}DEA NUMBER: {endb}",
          tprint_req->job[i].eprsnl_dea, "           NPI:", tprint_req->job[i].eprsnl_npi,
          row + 1, xpos = lt_xpos, ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)), "{b}Supervising Physician: {endb}", row + 1,
          xoffset = cnvtint(((size(trim(tprint_req->job[i].phys_bname)) * 2)/ 2)), xpos = (ct_xpos -
          xoffset),
          CALL print(calcpos(xpos,ypos)),
          tprint_req->job[i].phys_bname, row + 1, xpos = lt_xpos,
          ypos += (y_jump * 1.5),
          CALL print(calcpos(xpos,ypos)), "{b}DEA: {endb}",
          tprint_req->job[i].phys_dea, "{b}            NPI:{endb}", tprint_req->job[i].phys_npi,
          row + 1, ypos += (y_jump * 2)
         ELSE
          xpos = lt_xpos, ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)),
          "{b}DX: {endb}", tprint_req->job[i].s_diagname, row + 1,
          ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)), "{b}SIGNATURE: {endb}",
          line2, row + 1, ypos += y_jump,
          xoffset = cnvtint(((size(trim(tprint_req->job[i].phys_bname)) * 2)/ 2)), xpos = (ct_xpos -
          xoffset),
          CALL print(calcpos(xpos,ypos)),
          tprint_req->job[i].phys_bname, row + 1, xpos = lt_xpos,
          ypos += (y_jump * 1.5),
          CALL print(calcpos(xpos,ypos)), "{b}DEA: {endb}",
          tprint_req->job[i].phys_dea, "{b}          NPI: {endb}", tprint_req->job[i].phys_npi,
          row + 1, ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)),
          txt_line1, row + 1, ypos += y_jump,
          CALL print(calcpos(xpos,ypos)), txt_line2, row + 1
         ENDIF
        FOOT REPORT
         orderid = build("[",oid,"]"), ypos += y_jump,
         CALL print(calcpos(xpos,ypos)),
         orderid, row + 1
        WITH dio = 16, maxrow = 600, maxcol = 5000
       ;end select
       CALL echo(build("curqul:",curqual))
      ELSEIF (((trim(tprint_req->job[i].print_loc) IN ("bmc361rxtst1", "bmc362isam1rx",
      "bmcmm2hvcare2rx", "bmcmm2hvcare5rx", "bmcmm3hvccu2rx",
      "bmcmm3hvpcu2rx", "bmcmm5hvint5rx", "bmcmm5hvint8rx", "bmcmm6hvsrg5rx", "bmcmm6hvsrg8rx",
      "bmcmm7hvmed5rx", "bmcmm6hvmed8rx", "bmcmm7hvmed8rx", "bisis1pharm1", "bmcdl5bsicu2rx",
      "bmcdl5bniu2rx", "bmcmm3hvccu8rx", "bmcch2surgcrx", "bmcch2surgdrx", "bmcch2surgarx",
      "bmcch2surgbrx", "bmcmb1devp2rx", "bmcmm3hvcc8rx", "bmcmm3hvcc2rx", "bmcmm1edd4rx",
      "bmcmm1edp4rx", "bmcmm1edc2rx", "bmcmm1edb1rx", "bmcmm1ede2rx", "fmc482msplty4rx",
      "fmc482msplty2rx", "bmcdl4bpicu2rx", "bmc332cardi6rx", "bapop1mlorth1rx")) OR (trim(tprint_req
       ->job[i].print_loc)="*zx")) )
       CALL echo("entered rx zebra printer logic")
       CALL echo(build2("print loc6: ",temp_req->qual[1].print_loc))
       CALL echo(build2("print loc6: ",tprint_req->job[1].print_loc))
       CALL echorecord(tprint_req)
       SELECT INTO value(tprint_req->job[i].print_loc)
        org = substring(1,30,tprint_req->job[i].org_name), street =
        IF (trim(tprint_req->job[i].loc_addr2) > "") concat(trim(tprint_req->job[i].loc_addr),", ",
          trim(tprint_req->job[i].loc_addr2))
        ELSE tprint_req->job[i].loc_addr
        ENDIF
        , city = tprint_req->job[i].loc_city,
        st = tprint_req->job[i].loc_state, zip = tprint_req->job[i].loc_zip, phone = tprint_req->job[
        i].loc_ph"(###) ###-####"
        FROM dummyt d
        HEAD REPORT
         xpos = 0, xpos1 = 0, ypos = 0,
         ypos1 = 0, xoffset = 0, yoffset = 0,
         y_jump = 0, ct_xpos = 0, sig_x = 30,
         sig_1st = 1, assoc_1 = concat("{b}","Supervising Physician","{endb}"), txt_line4 =
         "** Autofaxed Transmission **",
         yvar = 0, yvar1 = 0,
         MACRO (strip)
          x = 0, len = 0, x = findstring(">",exp),
          len = size(trim(exp)), x2 = (len - 2), exp2 = substring(2,x2,exp)
         ENDMACRO
         ,
         line1 = fillstring(60,"_"), line2 = fillstring(53,"_"), line3 = fillstring(64,"_"),
         MACRO (set_font_a)
          y_jump = 5, "{f/0/3}{lpi/32}{cpi/24}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_1)
          y_jump = 12, "{f/2/1}{lpi/6}{cpi/18}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_2)
          y_jump = 7, "{f/2/1}{lpi/8}{cpi/18}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_3)
          y_jump = 10, "{f/0/5}{lpi/32}{cpi/18}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_4)
          y_jump = 10, "{f/1/1}{cpi/12}{lpi/6}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_5)
          y_jump = 10, "{f/5/1}{cpi/17}{lpi/12}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_6)
          y_jump = 14, "{f/2/1}{lpi/4}{cpi/18}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_7)
          y_jump = 15, "{f/1/1}{lpi/6}{cpi/18}{b}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_8)
          y_jump = 12, "{f/1/1}{lpi/8}{cpi/18}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_9)
          y_jump = 5, "{f/1/1}{cpi/23}{lpi/12}", row + 1
         ENDMACRO
         ,
         MACRO (calc_pos)
          row + 1, xpos = (xpos1+ xoffset), ypos = (ypos1+ yoffset),
          CALL print(calcpos(xpos,ypos)), xpos1 = 0
         ENDMACRO
         , set_font_2,
         lt_xpos = 0, ct_xpos = 150, ypos = 40,
         bay = "BAYSTATE HEALTH", xoffset = cnvtint(((size(trim(bay)) * 4)/ 2)), xpos = (ct_xpos -
         xoffset),
         CALL print(calcpos(xpos,ypos)), "{b}", bay,
         "{endb}", row + 1
         IF ((temp_req->qual[i].phys_addr_id=0))
          ypos += y_jump, xoffset = cnvtint(((size(trim(org)) * 4)/ 2)), xpos = (ct_xpos - xoffset),
          org_name = trim(org),
          CALL print(calcpos(xpos,ypos)), org_name,
          row + 1, ypos += y_jump, xoffset = cnvtint(((size(trim(street)) * 4)/ 2)),
          xpos = (ct_xpos - xoffset), str = trim(street),
          CALL print(calcpos(xpos,ypos)),
          street, row + 1, ypos += y_jump,
          csz = concat(trim(city),", ",trim(st),"  ",trim(zip)), xoffset = cnvtint(((size(trim(csz))
            * 4)/ 2)), xpos = (ct_xpos - xoffset),
          CALL print(calcpos(xpos,ypos)), csz, row + 1,
          ypos += y_jump, p_phone = trim(phone), xoffset = cnvtint(((size(trim(concat("Phone: ",
              p_phone))) * 4)/ 2)),
          xpos = (ct_xpos - xoffset),
          CALL print(calcpos(xpos,ypos)), "{b}Phone: {endb}",
          p_phone, row + 1
         ELSE
          ypos += y_jump, street2 = trim(temp_req->qual[i].phys_addr1), street3 = trim(temp_req->
           qual[i].phys_addr2)
          IF (trim(street2) > "")
           xoffset = cnvtint(((size(trim(street2)) * 4)/ 2)), xpos = (ct_xpos - xoffset),
           CALL print(calcpos(xpos,ypos)),
           street2, row + 1, ypos += y_jump,
           xoffset = cnvtint(((size(trim(street3)) * 4)/ 2)), xpos = (ct_xpos - xoffset),
           CALL print(calcpos(xpos,ypos)),
           street3, row + 1
          ELSE
           xoffset = cnvtint(((size(trim(street3)) * 4)/ 2)), xpos = (ct_xpos - xoffset),
           CALL print(calcpos(xpos,ypos)),
           street3, row + 1
          ENDIF
          ypos += y_jump, csz = trim(temp_req->qual[i].phys_city), xoffset = cnvtint(((size(trim(csz)
            ) * 4)/ 2)),
          xpos = (ct_xpos - xoffset),
          CALL print(calcpos(xpos,ypos)), csz,
          row + 1, ypos += y_jump, p_phone = format(phy_phone_list->qual[1].phone,"(###) ###-####"),
          xoffset = cnvtint(((size(trim(concat("Phone: ",p_phone))) * 4)/ 2)), xpos = (ct_xpos -
          xoffset),
          CALL print(calcpos(xpos,ypos)),
          "{b}Phone: {endb}", p_phone, row + 1
         ENDIF
         ypos += (y_jump * 2), xpos = lt_xpos,
         CALL print(calcpos(xpos,ypos)),
         "{b}Date: {endb}", tprint_req->job[i].req[ii].start_dt, row + 1,
         ypos += (y_jump * 2), set_font_4,
         CALL print(calcpos(xpos,ypos)),
         "{b}", demo_info->pat_name, "{endb}",
         ypos += (y_jump * 2), row + 1, set_font_2,
         CALL print(calcpos(xpos,ypos)), "Date Of Birth: ", demo_info->pat_bday,
         row + 1, ypos += (y_jump * 1.5),
         CALL print(calcpos(xpos,ypos)),
         "Address: ", demo_info->pat_addr, row + 1,
         ypos += y_jump,
         CALL print(calcpos(xpos,ypos)), "City: ",
         demo_info->pat_city, row + 1, ypos += (y_jump * 2),
         CALL echo("amount O2"),
         CALL print(calcpos(xpos,ypos)), "{b}Home Oxygen: {endb}",
         tprint_req->job[i].req[ii].s_o2_amt, row + 1, ypos += (y_jump * 2)
         IF (textlen(trim(tprint_req->job[i].req[ii].s_o2_other,3)) > 0)
          CALL echo("other O2"),
          CALL print(calcpos(xpos,ypos)), "{b}Other O2: {endb}",
          tprint_req->job[i].req[ii].s_o2_other, row + 1, ypos += (y_jump * 2)
         ENDIF
         CALL echo("portable O2 needed"),
         CALL print(calcpos(xpos,ypos)), "{b}Portable O2 Needed: {endb}",
         tprint_req->job[i].req[ii].s_o2_portable, row + 1, ypos += (y_jump * 2)
         IF ((tprint_req->job[i].req[ii].special_knt > 0))
          xpos = lt_xpos, ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)),
          "{b}Spe. Inst: {endb}", xpos = (65+ lt_xpos)
          FOR (x = 1 TO tprint_req->job[i].req[ii].special_knt)
            CALL print(calcpos(xpos,ypos)), spe_inst = cnvtupper(tprint_req->job[i].req[ii].special[x
             ].disp), spe_inst,
            row + 1, ypos += (y_jump * 2)
          ENDFOR
         ENDIF
         row + 1, xpos = lt_xpos,
         CALL echo("O2 duration"),
         CALL print(calcpos(xpos,ypos)), "{b}Duration: {endb}", tprint_req->job[i].req[ii].
         s_o2_duration,
         row + 1, ypos += (y_jump * 2), row + 1,
         CALL echo("zebra printing 5"),
         CALL print(calcpos(xpos,ypos)), "{b}RX: "
         FOR (x = 1 TO tprint_req->job[i].req[ii].med_knt)
           xpos = sig_x,
           CALL print(calcpos(xpos,ypos)), rx = build(cnvtupper(tprint_req->job[i].req[ii].med[x].
             disp)),
           rx, row + 1, ypos += (y_jump * 2)
         ENDFOR
         xpos = lt_xpos,
         CALL print(calcpos(xpos,ypos)), "{b}SIG: {endb}"
         IF ((tprint_req->job[i].req[ii].sig_knt > 0))
          xpos = sig_x
          FOR (x = 1 TO tprint_req->job[i].req[ii].sig_knt)
            CALL echo("**** 1"),
            CALL print(calcpos(xpos,ypos)), sig_disp = build(tprint_req->job[i].req[ii].sig[x].disp),
            sig_disp, row + 1, ypos += (y_jump * 2)
          ENDFOR
         ELSE
          CALL echo("**** 2"), xpos = sig_x
          FOR (x = 1 TO tprint_req->job[i].req[ii].special_knt)
            CALL print(calcpos(xpos,ypos)), spe_inst = cnvtupper(tprint_req->job[i].req[ii].special[x
             ].disp), spe_inst,
            row + 1, ypos += (y_jump * 2)
          ENDFOR
         ENDIF
         ypos -= (y_jump * 2)
         IF ((tprint_req->job[i].req[ii].special_knt > 0)
          AND (tprint_req->job[i].req[ii].sig_knt > 0))
          CALL echo("**** 3"), xpos = lt_xpos, ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)), "{b}Spe. Inst: {endb}", xpos = (65+ lt_xpos)
          FOR (x = 1 TO tprint_req->job[i].req[ii].special_knt)
            CALL print(calcpos(xpos,ypos)), spe_inst = cnvtupper(tprint_req->job[i].req[ii].special[x
             ].disp), spe_inst,
            row + 1, ypos += (y_jump * 2)
          ENDFOR
          ypos -= (y_jump * 2)
         ENDIF
         row + 1, xpos = lt_xpos, ypos += (y_jump * 2)
         FOR (x = 1 TO tprint_req->job[i].req[ii].indic_knt)
           IF (x=1)
            CALL print(calcpos(xpos,ypos)), "{b}Indications: {endb}", ind = cnvtupper(trim(tprint_req
              ->job[i].req[ii].indic[x].disp)),
            ind, row + 1
           ELSE
            xpos = lt_xpos, ypos += (y_jump * 2),
            CALL print(calcpos(xpos,ypos)),
            ind = cnvtupper(trim(tprint_req->job[i].req[ii].indic[x].disp)), ind, row + 1
           ENDIF
         ENDFOR
         xpos = lt_xpos, ypos += (y_jump * 2), xpos = lt_xpos,
         ypos += (y_jump * 2),
         CALL print(calcpos(xpos,ypos)), "{b}DISP: ",
         exp = cnvtupper(tprint_req->job[i].req[ii].dispense[1].disp), strip, exp2,
         row + 1
         IF (np_ind=true)
          xpos = lt_xpos, ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)),
          "{b}DX: {endb}", tprint_req->job[i].s_diagname, row + 1,
          ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)), "{b}Supervising Physician: {endb}",
          row + 1, xoffset = cnvtint(((size(trim(tprint_req->job[i].phys_bname)) * 2)/ 2)), xpos = (
          ct_xpos - xoffset),
          CALL print(calcpos(xpos,ypos)), tprint_req->job[i].phys_bname, row + 1,
          xpos = lt_xpos, ypos += (y_jump * 1.5),
          CALL print(calcpos(xpos,ypos)),
          "{b}PHY DEA NUMBER: {endb}", tprint_req->job[i].phys_dea, "{b}          NPI: {endb}",
          tprint_req->job[i].phys_npi, row + 1, ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)), "{b}SIGNATURE: {endb}", line2,
          row + 1, ypos += y_jump, xoffset = cnvtint(((size(trim(tprint_req->job[i].eprsnl_name)) * 2
           )/ 2)),
          xpos = (ct_xpos - xoffset),
          CALL print(calcpos(xpos,ypos)), tprint_req->job[i].eprsnl_name,
          row + 1, xpos = lt_xpos, ypos += (y_jump * 1.5),
          CALL print(calcpos(xpos,ypos)), "{b}DEA NUMBER: {endb}", tprint_req->job[i].eprsnl_dea,
          "{b}           NPI:{endb}", tprint_req->job[i].eprsnl_npi, row + 1,
          xpos = lt_xpos, ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)),
          ms_txt_line33, row + 1, ypos += y_jump,
          CALL print(calcpos(xpos,ypos)), ms_txt_line34, row + 1
         ELSE
          xpos = lt_xpos, ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)),
          "{b}DX: {endb}", tprint_req->job[i].s_diagname, row + 1,
          ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)), "{b}SIGNATURE: {endb}",
          line2, row + 1, ypos += y_jump,
          xoffset = cnvtint(((size(trim(tprint_req->job[i].phys_name)) * 2)/ 2)), xpos = (ct_xpos -
          xoffset),
          CALL print(calcpos(xpos,ypos)),
          tprint_req->job[i].phys_bname, row + 1, ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)), xpos = lt_xpos,
          CALL print(calcpos(xpos,ypos)),
          "{b}DEA NUMBER: {endb}", tprint_req->job[i].phys_dea, "{b}           NPI:{endb}",
          tprint_req->job[i].eprsnl_npi, row + 1, xpos = lt_xpos,
          ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)), ms_txt_line33,
          row + 1, ypos += y_jump,
          CALL print(calcpos(xpos,ypos)),
          ms_txt_line34, row + 1
         ENDIF
        FOOT REPORT
         orderid = build("[",oid,"]"), ypos += y_jump,
         CALL print(calcpos(xpos,ypos)),
         orderid, row + 1
        WITH dio = 16, maxrow = 600, maxcol = 5000
       ;end select
      ELSE
       CALL echo("*** postscript ***")
       CALL echo(concat("select into: ",tprint_req->job[i].print_loc))
       CALL echo(build2("print loc7: ",temp_req->qual[1].print_loc))
       CALL echo(build2("print loc7: ",tprint_req->job[1].print_loc))
       CALL echorecord(tprint_req)
       SELECT INTO value(tprint_req->job[i].print_loc)
        org = substring(1,30,tprint_req->job[i].org_name), street =
        IF (trim(tprint_req->job[i].loc_addr2) > "") concat(trim(tprint_req->job[i].loc_addr),", ",
          trim(tprint_req->job[i].loc_addr2))
        ELSE tprint_req->job[i].loc_addr
        ENDIF
        , city = tprint_req->job[i].loc_city,
        st = tprint_req->job[i].loc_state, zip = tprint_req->job[i].loc_zip, phone = tprint_req->job[
        i].loc_ph"(###) ###-####"
        FROM dummyt d
        HEAD REPORT
         xpos = 0, xpos1 = 0, ypos = 0,
         ypos1 = 0, xoffset = 0, yoffset = 0,
         y_jump = 0, ct_xpos = 0, sig_x = 96,
         sig_1st = 1, assoc_1 = concat("{b}","Supervising Physician","{endb}"), txt_line4 =
         "** Autofaxed Transmission **",
         yvar = 0, yvar1 = 0,
         MACRO (strip)
          x = 0, len = 0, x = findstring(">",exp),
          len = size(trim(exp)), x2 = (len - 2), exp2 = substring(2,x2,exp)
         ENDMACRO
         ,
         line1 = fillstring(60,"_"), line2 = fillstring(53,"_"), line3 = fillstring(64,"_"),
         MACRO (set_font_a)
          y_jump = 5, "{f/0/3}{lpi/32}{cpi/24}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_1)
          y_jump = 12, "{f/2/1}{lpi/6}{cpi/18}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_2)
          y_jump = 7, "{f/2/1}{lpi/8}{cpi/18}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_3)
          y_jump = 10, "{f/0/5}{lpi/32}{cpi/18}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_4)
          y_jump = 10, "{f/1/1}{cpi/12}{lpi/6}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_5)
          y_jump = 10, "{f/5/1}{cpi/17}{lpi/12}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_6)
          y_jump = 14, "{f/2/1}{lpi/4}{cpi/18}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_7)
          y_jump = 15, "{f/1/1}{lpi/6}{cpi/18}{b}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_8)
          y_jump = 12, "{f/1/1}{lpi/8}{cpi/18}", row + 1
         ENDMACRO
         ,
         MACRO (set_font_9)
          y_jump = 5, "{f/1/1}{cpi/23}{lpi/12}", row + 1
         ENDMACRO
         ,
         MACRO (calc_pos)
          row + 1, xpos = (xpos1+ xoffset), ypos = (ypos1+ yoffset),
          CALL print(calcpos(xpos,ypos)), xpos1 = 0
         ENDMACRO
         , set_font_2,
         lt_xpos = 75, ct_xpos = 210, ypos = 75,
         bay = "BAYSTATE HEALTH", xoffset = cnvtint(((size(trim(bay)) * 4)/ 2)), xpos = (ct_xpos -
         xoffset),
         CALL print(calcpos(xpos,ypos)), "{b}", bay,
         "{endb}", row + 1,
         CALL echo(build("phy ind=",temp_req->qual[i].phys_addr_id))
         IF ((temp_req->qual[i].phys_addr_id=0))
          ypos += y_jump, xoffset = cnvtint(((size(trim(org)) * 4)/ 2)), xpos = (ct_xpos - xoffset),
          org_name = trim(org),
          CALL print(calcpos(xpos,ypos)), org_name,
          row + 1, ypos += y_jump, xoffset = cnvtint(((size(trim(street)) * 4)/ 2)),
          xpos = (ct_xpos - xoffset), str = trim(street),
          CALL print(calcpos(xpos,ypos)),
          street, row + 1, ypos += y_jump,
          CALL echo(build("city",city)),
          CALL echo(build("state",st)),
          CALL echo(build("zip",zip)),
          csz = concat(trim(city),", ",trim(st),"  ",trim(zip)), xoffset = cnvtint(((size(trim(csz))
            * 4)/ 2)), xpos = (ct_xpos - xoffset),
          CALL print(calcpos(xpos,ypos)), csz, row + 1,
          ypos += y_jump, p_phone = trim(phone), xoffset = cnvtint(((size(trim(concat("Phone: ",
              p_phone))) * 4)/ 2)),
          xpos = (ct_xpos - xoffset),
          CALL print(calcpos(xpos,ypos)), "{b}Phone: {endb}",
          p_phone, row + 1
         ELSE
          ypos += y_jump, street2 = trim(temp_req->qual[i].phys_addr1), street3 = trim(temp_req->
           qual[i].phys_addr2)
          IF (trim(street2) > "")
           xoffset = cnvtint(((size(trim(street2)) * 4)/ 2)), xpos = (ct_xpos - xoffset),
           CALL print(calcpos(xpos,ypos)),
           street2, row + 1, ypos += y_jump,
           xoffset = cnvtint(((size(trim(street3)) * 4)/ 2)), xpos = (ct_xpos - xoffset),
           CALL print(calcpos(xpos,ypos)),
           street3, row + 1
          ELSE
           xoffset = cnvtint(((size(trim(street3)) * 4)/ 2)), xpos = (ct_xpos - xoffset),
           CALL print(calcpos(xpos,ypos)),
           street3, row + 1
          ENDIF
          ypos += y_jump, csz = trim(temp_req->qual[i].phys_city), xoffset = cnvtint(((size(trim(csz)
            ) * 4)/ 2)),
          xpos = (ct_xpos - xoffset),
          CALL print(calcpos(xpos,ypos)), csz,
          row + 1, ypos += y_jump, p_phone = format(phy_phone_list->qual[1].phone,"(###) ###-####"),
          xoffset = cnvtint(((size(trim(concat("Phone: ",p_phone))) * 4)/ 2)), xpos = (ct_xpos -
          xoffset),
          CALL print(calcpos(xpos,ypos)),
          "{b}Phone: {endb}", p_phone, row + 1
         ENDIF
         ypos += (y_jump * 2), xpos = lt_xpos,
         CALL print(calcpos(xpos,ypos)),
         "{b}Date: {endb}", tprint_req->job[i].req[ii].start_dt, row + 1,
         ypos += (y_jump * 2), set_font_4,
         CALL print(calcpos(xpos,ypos)),
         "{b}", demo_info->pat_name, "{endb}",
         ypos += (y_jump * 2), row + 1, set_font_2,
         CALL print(calcpos(xpos,ypos)), "Date Of Birth: ", demo_info->pat_bday,
         row + 1, ypos += (y_jump * 1.5),
         CALL print(calcpos(xpos,ypos)),
         "Address: ", demo_info->pat_addr, row + 1,
         ypos += y_jump,
         CALL print(calcpos(xpos,ypos)), "City: ",
         demo_info->pat_city, row + 1, ypos += (y_jump * 2),
         CALL echo("amount O2"),
         CALL print(calcpos(xpos,ypos)), "{b}Home Oxygen: {endb}",
         tprint_req->job[i].req[ii].s_o2_amt, row + 1, ypos += (y_jump * 2)
         IF (textlen(trim(tprint_req->job[i].req[ii].s_o2_other,3)) > 0)
          CALL echo("other O2"),
          CALL print(calcpos(xpos,ypos)), "{b}Other O2: {endb}",
          tprint_req->job[i].req[ii].s_o2_other, row + 1, ypos += (y_jump * 2)
         ENDIF
         CALL echo("portable O2 needed"),
         CALL print(calcpos(xpos,ypos)), "{b}Portable O2 Needed: {endb}",
         tprint_req->job[i].req[ii].s_o2_portable, row + 1, ypos += (y_jump * 2)
         IF ((tprint_req->job[i].req[ii].special_knt > 0))
          xpos = lt_xpos, ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)),
          "{b}Spe. Inst: {endb}", xpos = (65+ lt_xpos)
          FOR (x = 1 TO tprint_req->job[i].req[ii].special_knt)
            CALL print(calcpos(xpos,ypos)), spe_inst = cnvtupper(tprint_req->job[i].req[ii].special[x
             ].disp), spe_inst,
            row + 1, ypos += (y_jump * 2)
          ENDFOR
         ENDIF
         row + 1, xpos = lt_xpos,
         CALL echo("O2 duration"),
         CALL print(calcpos(xpos,ypos)), "{b}Duration: {endb}", tprint_req->job[i].req[ii].
         s_o2_duration,
         row + 1, ypos += (y_jump * 2), xpos = lt_xpos,
         ypos += (y_jump * 2)
         FOR (x = 1 TO tprint_req->job[i].req[ii].indic_knt)
           IF (x=1)
            CALL print(calcpos(xpos,ypos)), "{b}Indications: {endb}", ind = cnvtupper(trim(tprint_req
              ->job[i].req[ii].indic[x].disp)),
            ind, row + 1
           ELSE
            xpos = lt_xpos, ypos += (y_jump * 2),
            CALL print(calcpos(xpos,ypos)),
            ind = cnvtupper(trim(tprint_req->job[i].req[ii].indic[x].disp)), ind, row + 1
           ENDIF
         ENDFOR
         xpos = lt_xpos, ypos += (y_jump * 2)
         IF (size(tprint_req->job[i].req[ii].dispense,5) > 0)
          xpos = lt_xpos, ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)),
          "{b}DISP: {endb}", exp = cnvtupper(tprint_req->job[i].req[ii].dispense[1].disp), strip,
          exp2, row + 1
         ENDIF
         IF (np_ind=true)
          xpos = lt_xpos, ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)),
          "{b}DX: {endb}", tprint_req->job[i].s_diagname, row + 1,
          ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)), "{b}Supervising Physician: {endb}",
          row + 1, xoffset = cnvtint(((size(trim(tprint_req->job[i].phys_bname)) * 2)/ 2)), xpos = (
          ct_xpos - xoffset),
          CALL print(calcpos(xpos,ypos)), tprint_req->job[i].phys_bname, row + 1,
          xpos = lt_xpos, ypos += (y_jump * 1.5),
          CALL print(calcpos(xpos,ypos)),
          "{b}PHY DEA NUMBER: {endb}", tprint_req->job[i].phys_dea, "{b}          NPI: {endb}",
          tprint_req->job[i].phys_npi, row + 1, ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)), "{b}SIGNATURE: {endb}", line2,
          row + 1, ypos += y_jump, xoffset = cnvtint(((size(trim(tprint_req->job[i].eprsnl_name)) * 2
           )/ 2)),
          xpos = (ct_xpos - xoffset),
          CALL print(calcpos(xpos,ypos)), tprint_req->job[i].eprsnl_name,
          row + 1, xpos = lt_xpos, ypos += (y_jump * 1.5),
          CALL print(calcpos(xpos,ypos)), "{b}DEA NUMBER: {endb}", tprint_req->job[i].eprsnl_dea,
          "{b}           NPI:{endb}", tprint_req->job[i].eprsnl_npi, row + 1,
          xpos = lt_xpos, ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)),
          ms_txt_line33, row + 1
         ELSE
          xpos = lt_xpos, ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)),
          "{b}DX: {endb}", tprint_req->job[i].s_diagname, row + 1,
          ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)), "{b}SIGNATURE: {endb}",
          line2, row + 1, ypos += y_jump,
          xoffset = cnvtint(((size(trim(tprint_req->job[i].phys_name)) * 2)/ 2)), xpos = (ct_xpos -
          xoffset),
          CALL print(calcpos(xpos,ypos)),
          tprint_req->job[i].phys_bname, row + 1, ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)), xpos = lt_xpos,
          CALL print(calcpos(xpos,ypos)),
          "{b}DEA NUMBER: {endb}", tprint_req->job[i].phys_dea, "{b}           NPI:{endb}",
          tprint_req->job[i].eprsnl_npi, row + 1, xpos = lt_xpos,
          ypos += (y_jump * 2),
          CALL print(calcpos(xpos,ypos)), ms_txt_line33,
          row + 1
         ENDIF
        FOOT REPORT
         orderid = build("[",oid,"]"), ypos += y_jump,
         CALL print(calcpos(xpos,ypos)),
         orderid, row + 1
        WITH dio = postscript, maxrow = 600, maxcol = 5000
       ;end select
      ENDIF
     ELSE
      SET toad = 1
      SET file_name = concat("cer_print:",trim(cnvtlower(username)),"_",trim(cnvtstring(oid,13,0,r)),
       ".dat")
      CALL echo("***")
      CALL echo(build("***   file_name :",file_name))
      CALL echo("***")
      SET tprint_req->job[i].print_loc = trim(file_name)
      SET rhead =
      "{\rtf1\ansi\deff0{\fonttbl{\f0\fswissArial;}}{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134"
      SET rh2r = "\plain \f0 \fs18 \cb2 \pard\sl0 "
      SET rh2r36 = "\plain \f0 \fs36 \cb2 \pard\sl0 "
      SET rh2r28 = "\plain \f0 \fs28 \cb2 \pard\sl0 "
      SET rh2b = "\plain \f0 \fs18 \b \cb2 \pard\sl0 "
      SET rh2b36 = "\plain \f0 \fs36 \b \cb2 \pard\sl0 "
      SET rh2b28 = "\plain \f0 \fs28 \b \cb2 \pard\sl0 "
      SET rh2bu = "\plain \f0 \fs18 \b \ul \cb2 \pard\sl0 "
      SET rh2u = "\plain \f0 \fs18 \u \cb2 \pard\sl0 "
      SET rh2i = "\plain \f0 \fs18 \i \cb2 \pard\sl0 "
      SET reol = "\par "
      SET rtab = "\tab "
      SET wr = " \plain \f0 \fs18 \cb2 "
      SET wr28 = " \plain \f0 \fs18 \cb2 "
      SET wb = " \plain \f0 \fs18 \b \cb2 "
      SET wb28 = " \plain \f0 \fs18 \b \cb2 "
      SET wb36 = " \plain \f0 \fs28 \b \cb2 "
      SET wu = " \plain \f0 \fs18 \ul \cb2 "
      SET wbu = " \plain \f0 \fs18 \ul \cb2 \b "
      SET wi = " \plain \f0 \fs18 \i \cb2 "
      SET wbi = " \plain \f0 \fs18 \b \i \cb2 "
      SET wiu = " \plain \f0 \fs18 \i \ul \cb2 "
      SET wbiu = " \plain \f0 \fs18 \b \ul \i \cb2 "
      SET center = "\qc"
      SET rtfeof = "}"
      RECORD drec(
        1 line_cnt = i4
        1 line_qual[*]
          2 disp_line = vc
      )
      CALL echorecord(tprint_req)
      CALL echo(build2("print loc9: ",tprint_req->job[1].print_loc))
      SELECT INTO "nl:"
       org = substring(1,30,tprint_req->job[i].org_name), street =
       IF (trim(tprint_req->job[i].loc_addr2) > "") concat(tprint_req->job[i].loc_addr,", ",
         tprint_req->job[i].loc_addr2)
       ELSE tprint_req->job[i].loc_addr
       ENDIF
       , city = tprint_req->job[i].loc_city,
       st = tprint_req->job[i].loc_state, zip = tprint_req->job[i].loc_zip, phone = tprint_req->job[i
       ].loc_ph"(###) ###-####"
       FROM dummyt d
       HEAD REPORT
        lidx = 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
         rhead,rtab,rtab,rtab,rh2bu,
         reol,wr),
        xpos = 0, xpos1 = 0, ypos = 0,
        ypos1 = 0, xoffset = 0, yoffset = 0,
        y_jump = 0, ct_xpos = 0, lt_xpos = 0,
        sig_x = 36, sig_1st = 1, assoc_1 = concat("{b}","Supervising Physician","{endb}"),
        txt_line4 = "** Autofaxed Transmission **", t1_line =
        "This information is intended to be for the use of the addressed individual or entity.",
        t2_line =
        "If you are not the intended recipient, be aware that any disclosure, copying, distribution (verbal or written)",
        t3_line =
        "of the contents of this transmission is in violation of Baystate Health policy and subject to disciplinary action.",
        t4_line =
        "If you received this transmission in error, please call  (413) 794 - 5840 and we will arrange retrieval of the ",
        t5_line = "documents at no cost to you.",
        yvar = 0, yvar1 = 0,
        MACRO (strip)
         x = 0, len = 0, x = findstring(">",exp),
         len = size(trim(exp)), x2 = (len - 2), exp2 = substring(2,x2,exp)
        ENDMACRO
        ,
        line1 = fillstring(60,"_"), line2 = fillstring(58,"_"), line3 = fillstring(64,"_"),
        lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
         wb,center," ","BAYSTATE HEALTH",reol),
        row + 1
        IF ((temp_req->qual[i].phys_addr_id=0))
         nur_unit = trim(org), lidx += 1, stat = alterlist(drec->line_qual,lidx),
         drec->line_qual[lidx].disp_line = concat(wb,center," ",nur_unit,reol), row + 1, str = trim(
          street),
         lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
          wb,center," ",str,reol),
         row + 1, csz = concat(build(city),", ",build(st),"  ",build(zip)), lidx += 1,
         stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(center,wb,
          " ",csz,reol), row + 1,
         p_phone = concat("Phone : ",trim(phone)), lidx += 1, stat = alterlist(drec->line_qual,lidx),
         drec->line_qual[lidx].disp_line = concat("\ql",wb," ","Phone: ",phone,
          reol,wr), row + 1
        ELSE
         str1 = trim(temp_req->qual[i].phys_addr1), str2 = trim(temp_req->qual[i].phys_addr2)
         IF (trim(str1) > "")
          lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
          (wb,center," ",str1,reol),
          row + 1, lidx += 1, stat = alterlist(drec->line_qual,lidx),
          drec->line_qual[lidx].disp_line = concat(wb,center," ",str2,reol), row + 1
         ELSE
          lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
          (wb,center," ",str2,reol),
          row + 1
         ENDIF
         csz = trim(temp_req->qual[i].phys_city), lidx += 1, stat = alterlist(drec->line_qual,lidx),
         drec->line_qual[lidx].disp_line = concat(center,wb," ",csz,reol), row + 1, phone = format(
          phy_phone_list->qual[1].phone,"(###) ###-####"),
         p_phone = concat("Phone : ",trim(phone)), lidx += 1, stat = alterlist(drec->line_qual,lidx),
         drec->line_qual[lidx].disp_line = concat("\ql",wb," ","Phone: ",phone,
          reol,wr), row + 1
        ENDIF
        lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
         " ",wb,"Date : ",tprint_req->job[i].req[ii].start_dt,reol),
        row + 1, name = trim(demo_info->pat_name), row + 1,
        lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
         " ","Patient Name : ",name," ",reol,
         wr),
        lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
         wb," ","Date of Birth: ",demo_info->pat_bday,reol),
        row + 1, lidx += 1, stat = alterlist(drec->line_qual,lidx),
        drec->line_qual[lidx].disp_line = concat(wb," ","Address : ",demo_info->pat_addr,reol), row
         + 1, lidx += 1,
        stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb," ",
         "City: ",demo_info->pat_city,reol), row + 1
        IF ((tprint_req->job[i].req[ii].special_knt > 0)
         AND (tprint_req->job[i].req[ii].sig_knt > 0))
         FOR (x = 1 TO tprint_req->job[i].req[ii].special_knt)
           IF (x=1)
            spe_inst = cnvtupper(tprint_req->job[i].req[ii].special[x].disp), lidx += 1, stat =
            alterlist(drec->line_qual,lidx),
            drec->line_qual[lidx].disp_line = concat(wb," ","Spe. Inst.: ",spe_inst," ",
             reol)
           ELSE
            spe_inst = cnvtupper(tprint_req->job[i].req[ii].special[x].disp), lidx += 1, stat =
            alterlist(drec->line_qual,lidx),
            drec->line_qual[lidx].disp_line = concat(wb," ",spe_inst," ",reol)
           ENDIF
         ENDFOR
        ENDIF
        FOR (x = 1 TO tprint_req->job[i].req[ii].indic_knt)
          IF (x=1)
           ind = fillstring(60,""), ind = cnvtupper(trim(tprint_req->job[i].req[ii].indic[x].disp)),
           lidx += 1,
           stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb," ",
            "Indications: "," ",ind,
            " ",reol), row + 1
          ELSE
           ind = fillstring(60,""), ind = cnvtupper(trim(tprint_req->job[i].req[ii].indic[x].disp)),
           lidx += 1,
           stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb," ",
            " ",ind," ",
            reol), row + 1
          ENDIF
        ENDFOR
        line1 = "    ", lidx += 1, stat = alterlist(drec->line_qual,lidx),
        drec->line_qual[lidx].disp_line = concat(wb," ",line1," ",reol), row + 1
        IF (np_ind=true)
         phys_name = trim(tprint_req->job[i].phys_bname), lidx += 1, stat = alterlist(drec->line_qual,
          lidx),
         drec->line_qual[lidx].disp_line = concat(rtab,rtab,wb,"Supervising Physician: "," ",
          phys_name," ",reol), row + 1, lidx += 1,
         stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb," ",
          "PHY DEA NUMBER: ",tprint_req->job[i].phys_dea,wb,
          "           ","PHY NPI NUMBER: ",tprint_req->job[i].phys_npi,reol), row + 1,
         lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
          wb," ","___________________________________"," ",reol),
         row + 1, lidx += 1, stat = alterlist(drec->line_qual,lidx),
         drec->line_qual[lidx].disp_line = concat(wb,"Ordered By: ",tprint_req->job[i].eprsnl_name,
          " ",reol), row + 1, lidx += 1,
         stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb," ",
          "DEA NUMBER: ",tprint_req->job[i].eprsnl_dea,"           ",
          "NPI:",tprint_req->job[i].eprsnl_npi,reol)
        ELSE
         lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
          wb,"Ordered By: ",tprint_req->job[i].phys_bname," ",reol),
         row + 1, lidx += 1, stat = alterlist(drec->line_qual,lidx),
         drec->line_qual[lidx].disp_line = concat(wb," ","DEA NUMBER: ",tprint_req->job[i].phys_dea,
          reol)
        ENDIF
        lidx += 1, stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(
         " ",txt_line1," ",reol),
        row + 1, lidx += 1, stat = alterlist(drec->line_qual,lidx),
        drec->line_qual[lidx].disp_line = concat(wb," ",txt_line2," ",reol), row + 1, lidx += 1,
        stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat(wb," ",
         "___________________________________"," ",reol), row + 1
       FOOT REPORT
        orderid = build("[",oid,"]"), lidx += 1, stat = alterlist(drec->line_qual,lidx),
        drec->line_qual[lidx].disp_line = concat(rtab," ",orderid," ",rtfeof)
       WITH nocounter, outerjoin = d1
      ;end select
      SELECT INTO value(tprint_req->job[i].print_loc)
       FROM dummyt d
       DETAIL
        FOR (x = 1 TO size(drec->line_qual,5))
          disp = build(drec->line_qual[x].disp_line), col 0, disp,
          row + 1
        ENDFOR
       WITH nocounter, maxcol = 5000
      ;end select
      CALL echorecord(drec)
      FREE RECORD prequest
      RECORD prequest(
        1 output_dest_cd = f8
        1 file_name = vc
        1 copies = i4
        1 output_handle_id = f8
        1 number_of_pages = i4
        1 transmit_dt_tm = dq8
        1 priority_value = i4
        1 report_title = vc
        1 server = vc
        1 country_code = c3
        1 area_code = c10
        1 exchange = c10
        1 suffix = c50
      )
      SET prequest->output_dest_cd = tprint_req->job[i].output_dest_cd
      SET prequest->file_name = tprint_req->job[i].print_loc
      SET prequest->number_of_pages = 1
      SET prequest->report_title = concat("RX","|",trim(cnvtstring(tprint_req->job[i].req[1].order_id
         )),"|",trim(demo_info->pat_name),
       "|","0","|"," ","|",
       " ","|",trim(cnvtstring(demo_info->pat_id)),"|",trim(cnvtstring(tprint_req->job[i].eprsnl_id)),
       "|"," ","|","0")
      IF (size(tprint_req->job[i].free_text_nbr,1) > 0
       AND (tprint_req->job[i].free_text_nbr != "0"))
       SET prequest->suffix = tprint_req->job[i].free_text_nbr
      ENDIF
      FREE RECORD preply
      RECORD preply(
        1 sts = i4
        1 status_data
          2 status = c1
          2 subeventstatus[1]
            3 operationname = c15
            3 operationstatus = c1
            3 targetojbectname = c15
            3 targetobjectvalue = c100
      )
      CALL echo("***")
      CALL echo("***   Executing SYS_OUTPUTDEST_PRINT")
      CALL echo("***")
      EXECUTE sys_outputdest_print  WITH replace("REQUEST",prequest), replace("REPLY",preply)
      CALL echo("***")
      CALL echo("***   Finished executing SYS_OUTPUTDEST_PRINT")
      CALL echo("***")
      CALL echorecord(preply)
     ENDIF
   ENDFOR
 ENDFOR
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "042 11/15/2016 VK049365"
 SET rx_version = "01"
#exit_script
 CALL echorecord(request,concat("bhscust:je_oxy_req",trim(cnvtstring(request->order_qual[1].order_id),
    3),".txt"))
 CALL echorecord(reply,concat("bhscust:je_oxy_reply",trim(cnvtstring(request->order_qual[1].order_id),
    3),".txt"))
 CALL echorecord(tprint_req,concat("bhscust:je_oxy_tprint",trim(cnvtstring(request->order_qual[1].
     order_id),3),".txt"))
 CALL echorecord(temp_req,concat("bhscust:je_oxy_temp",trim(cnvtstring(request->order_qual[1].
     order_id),3),".txt"))
 CALL echorecord(reply)
 CALL echo("exit script")
END GO
