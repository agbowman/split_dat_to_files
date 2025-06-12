CREATE PROGRAM dfr_rxreqgen02:dba
 RECORD request(
   1 person_id = f8
   1 print_prsnl_id = f8
   1 order_qual[*]
     2 order_id = f8
     2 encntr_id = f8
     2 conversation_id = f8
   1 printer_name = c50
 )
 SET stat = alterlist(request->order_qual,1)
 SET request->person_id = 857224
 SET request->print_prsnl_id = 0
 SET request->order_qual[1].order_id = 2027239
 SET request->order_qual[1].encntr_id = 2443052
 SET request->order_qual[1].conversation_id = 0
 SET request->printer_name = "NPI6d2ea6"
 CALL echorecord(request)
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
 DECLARE order_cd = f8 WITH public, noconstant(0.0)
 DECLARE complete_cd = f8 WITH public, noconstant(0.0)
 DECLARE modify_cd = f8 WITH public, noconstant(0.0)
 DECLARE studactivate_cd = f8 WITH public, noconstant(0.0)
 DECLARE docdea_cd = f8 WITH public, noconstant(0.0)
 DECLARE licensenbr_cd = f8 WITH public, noconstant(0.0)
 DECLARE canceled_allergy_cd = f8 WITH public, noconstant(0.0)
 DECLARE emrn_cd = f8 WITH public, noconstant(0.0)
 DECLARE pmrn_cd = f8 WITH public, noconstant(0.0)
 DECLARE ord_comment_cd = f8 WITH public, noconstant(0.0)
 DECLARE prsnl_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE eprsnl_ind = i2 WITH public, noconstant(false)
 DECLARE code_set = i4 WITH public, noconstant(0)
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 SET code_set = 212
 SET cdf_meaning = "HOME"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,home_add_cd)
 IF (home_add_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Unable to find the Code Value for ",trim(cdf_meaning)," in Code Set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_set = 212
 SET cdf_meaning = "BUSINESS"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,work_add_cd)
 IF (work_add_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Unable to find the Code Value for ",trim(cdf_meaning)," in Code Set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_set = 212
 SET cdf_meaning = "PROFESSIONAL"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,clinic_add_cd)
 IF (work_add_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Unable to find the Code Value for ",trim(cdf_meaning)," in Code Set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_set = 43
 SET cdf_meaning = "HOME"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,home_phone_cd)
 IF (home_phone_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Unable to find the Code Value for ",trim(cdf_meaning)," in Code Set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_set = 43
 SET cdf_meaning = "BUSINESS"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,work_phone_cd)
 IF (work_phone_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Unable to find the Code Value for ",trim(cdf_meaning)," in Code Set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_set = 43
 SET cdf_meaning = "PROFESSIONAL"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,clinic_phone_cd)
 IF (work_phone_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Unable to find the Code Value for ",trim(cdf_meaning)," in Code Set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_set = 6003
 SET cdf_meaning = "ORDER"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,order_cd)
 IF (order_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Unable to find the Code Value for ",trim(cdf_meaning)," in Code Set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_set = 6003
 SET cdf_meaning = "COMPLETE"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,complete_cd)
 IF (complete_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Unable to find the Code Value for ",trim(cdf_meaning)," in Code Set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_set = 6003
 SET cdf_meaning = "MODIFY"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,modify_cd)
 IF (modify_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Unable to find the Code Value for ",trim(cdf_meaning)," in Code Set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_set = 6003
 SET cdf_meaning = "STUDACTIVATE"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,studactivate_cd)
 IF (studactivate_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Unable to find the Code Value for ",trim(cdf_meaning)," in Code Set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_set = 12025
 SET cdf_meaning = "CANCELED"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,canceled_allergy_cd)
 IF (canceled_allergy_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Unable to find the Code Value for ",trim(cdf_meaning)," in Code Set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_set = 320
 SET cdf_meaning = "LICENSENBR"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,licensenbr_cd)
 IF (licensenbr_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Unable to find the Code Value for ",trim(cdf_meaning)," in Code Set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_set = 320
 SET cdf_meaning = "DOCDEA"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,docdea_cd)
 IF (docdea_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Unable to find the Code Value for ",trim(cdf_meaning)," in Code Set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_set = 319
 SET cdf_meaning = "MRN"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,emrn_cd)
 IF (emrn_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Unable to find the Code Value for ",trim(cdf_meaning)," in Code Set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_set = 4
 SET cdf_meaning = "MRN"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,pmrn_cd)
 IF (pmrn_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Unable to find the Code Value for ",trim(cdf_meaning)," in Code Set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_set = 14
 SET cdf_meaning = "ORD COMMENT"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,ord_comment_cd)
 IF (ord_comment_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Failed to find the code_value for ",trim(cdf_meaning)," in code_set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_set = 213
 SET cdf_meaning = "PRSNL"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,prsnl_type_cd)
 IF (prsnl_type_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Failed to find the code_value for ",trim(cdf_meaning)," in code_set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
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
 CALL echo("***")
 CALL echo(build("*** username :",username))
 CALL echo("***")
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
   WHERE a.parent_entity_id=outerjoin(p.person_id)
    AND a.parent_entity_name=outerjoin("PERSON")
    AND a.address_type_cd=outerjoin(home_add_cd)
    AND a.active_ind=outerjoin(1)
    AND a.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND a.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
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
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
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
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM allergy a,
   nomenclature n
  PLAN (a
   WHERE (a.person_id=request->person_id)
    AND a.reaction_status_cd != canceled_allergy_cd
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (n
   WHERE n.nomenclature_id=a.substance_nom_id)
  HEAD REPORT
   knt = 0
  DETAIL
   knt = (knt+ 1)
   IF (knt=1)
    IF (n.nomenclature_id > 0)
     demo_info->allergy_line = trim(n.source_string)
    ELSE
     demo_info->allergy_line = trim(a.substance_ftdesc)
    ENDIF
   ELSE
    IF (n.nomenclature_id > 0)
     demo_info->allergy_line = concat(trim(demo_info->allergy_line),", ",trim(n.source_string))
    ELSE
     demo_info->allergy_line = concat(trim(demo_info->allergy_line),", ",trim(a.substance_ftdesc))
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ALLERGY"
  GO TO exit_script
 ENDIF
 FREE RECORD pt
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 IF ( NOT ((demo_info->allergy_line > " ")))
  SET demo_info->allergy_knt = 1
  SET stat = alterlist(demo_info->allergy,demo_info->allergy_knt)
  SET demo_info->allergy[1].disp = "No Allergy Information Has Been Recorded"
 ELSE
  SET pt->line_cnt = 0
  SET max_length = 90
  EXECUTE dcp_parse_text value(demo_info->allergy_line), value(max_length)
  SET demo_info->allergy_knt = pt->line_cnt
  SET stat = alterlist(demo_info->allergy,demo_info->allergy_knt)
  FOR (c = 1 TO pt->line_cnt)
    SET demo_info->allergy[c].disp = trim(pt->lns[c].line)
  ENDFOR
 ENDIF
 FREE RECORD temp_req
 RECORD temp_req(
   1 qual_knt = i4
   1 qual[*]
     2 order_id = f8
     2 encntr_id = f8
     2 organization_id = f8
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
     2 phys_lnbr = vc
     2 phys_phone = vc
     2 eprsnl_ind = i2
     2 eprsnl_id = f8
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
     2 req_refill_date = dq8
     2 nbr_refills_txt = vc
     2 nbr_refills = f8
     2 total_refills = f8
     2 add_refills = vc
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
 )
 SET eprsnl_ind = false
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DECLARE encntr_id = f8
 SET encntr_id = 0.0
 DECLARE prt_encntr_id = f8
 SET prt_encntr_id = 0.0
 SELECT INTO "nl:"
  encntr_id = request->order_qual[d.seq].encntr_id, oa.order_provider_id, o.order_id,
  cki_len = textlen(o.cki)
  FROM (dummyt d  WITH seq = value(size(request->order_qual,5))),
   orders o,
   order_action oa,
   dummyt d1,
   prsnl p
  PLAN (d
   WHERE d.seq > 0)
   JOIN (o
   WHERE (o.order_id=request->order_qual[d.seq].order_id)
    AND (o.encntr_id=request->order_qual[d.seq].encntr_id))
   JOIN (oa
   WHERE oa.order_id=o.order_id)
   JOIN (d1)
   JOIN (p
   WHERE p.person_id=oa.order_provider_id)
  HEAD REPORT
   knt = 0, stat = alterlist(temp_req->qual,10)
  HEAD o.order_id
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(temp_req->qual,(knt+ 9))
   ENDIF
   temp_req->qual[knt].order_id = o.order_id, prt_encntr_id = o.encntr_id, temp_req->qual[knt].
   encntr_id = o.encntr_id,
   temp_req->qual[knt].oe_format_id = o.oe_format_id, temp_req->qual[knt].phys_id = oa
   .order_provider_id, temp_req->qual[knt].eprsnl_id = oa.action_personnel_id,
   temp_req->qual[knt].ord_det_disp = o.order_detail_display_line
   IF (oa.order_provider_id != oa.action_personnel_id)
    temp_req->qual[knt].eprsnl_ind = true, eprsnl_ind = true
   ENDIF
   temp_req->qual[knt].phys_name = trim(p.name_full_formatted), temp_req->qual[knt].order_dt =
   cnvtdatetime(cnvtdate(oa.action_dt_tm),0), temp_req->qual[knt].print_loc = request->printer_name,
   temp_req->qual[knt].order_mnemonic = o.hna_order_mnemonic, temp_req->qual[knt].order_as_mnemonic
    = o.ordered_as_mnemonic
   IF (band(o.comment_type_mask,1)=1)
    temp_req->qual[knt].get_comment_ind = true
   ENDIF
   d_pos = findstring("!d",o.cki)
   IF (d_pos > 0)
    temp_req->qual[knt].d_nbr = trim(substring((d_pos+ 1),cki_len,o.cki))
   ENDIF
  FOOT REPORT
   temp_req->qual_knt = knt, stat = alterlist(temp_req->qual,knt)
  WITH nocounter, outerjoin = d1
 ;end select
 SELECT INTO "nl:"
  encntr_id = temp_req->qual[d.seq].encntr_id
  FROM (dummyt d  WITH seq = value(temp_req->qual_knt)),
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
    AND a.address_type_cd=work_add_cd)
   JOIN (p
   WHERE p.parent_entity_id=l.organization_id
    AND p.parent_entity_name="ORGANIZATION"
    AND p.phone_type_cd=work_phone_cd)
  DETAIL
   temp_req->qual[d.seq].organization_id = o.organization_id, temp_req->qual[d.seq].location_cd = l
   .location_cd, temp_req->qual[d.seq].loc_addr = a.street_addr,
   temp_req->qual[d.seq].loc_addr2 = a.street_addr2, temp_req->qual[d.seq].loc_city = a.city,
   temp_req->qual[d.seq].loc_state = a.state,
   temp_req->qual[d.seq].loc_zip = a.zipcode, temp_req->qual[d.seq].loc_ph = p.phone_num
  WITH check, nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ORDER_INFO"
  GO TO exit_script
 ENDIF
 IF ((temp_req->qual_knt < 1))
  CALL echo("***")
  CALL echo("***   No items found to print")
  CALL echo("***")
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Get Phys Title")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(temp_req->qual_knt)),
   person_name p
  PLAN (d
   WHERE d.seq > 0)
   JOIN (p
   WHERE (p.person_id=temp_req->qual[d.seq].phys_id)
    AND p.name_type_cd=prsnl_type_cd
    AND p.active_ind=true
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
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
     ENDIF
    ELSEIF (p.name_last > " ")
     temp_req->qual[d.seq].phys_bname = concat(trim(temp_req->qual[d.seq].phys_bname)," ",trim(p
       .name_last))
    ENDIF
   ELSEIF (p.name_middle > " ")
    temp_req->qual[d.seq].phys_bname = trim(p.name_middle)
    IF (p.name_last > " ")
     temp_req->qual[d.seq].phys_bname = concat(trim(temp_req->qual[d.seq].phys_bname)," ",trim(p
       .name_last))
    ENDIF
   ELSEIF (p.name_last > " ")
    temp_req->qual[d.seq].phys_bname = concat(trim(temp_req->qual[d.seq].phys_bname)," ",trim(p
      .name_last))
   ELSE
    temp_req->qual[d.seq].phys_bname = temp_req->qual[d.seq].phys_name
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
  GO TO exit_script
 ENDIF
 IF (eprsnl_ind=true)
  CALL echo("***")
  CALL echo("***   Get Eprsnl Title")
  CALL echo("***")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(temp_req->qual_knt)),
    person_name p
   PLAN (d
    WHERE d.seq > 0
     AND (temp_req->qual[d.seq].eprsnl_ind=true))
    JOIN (p
    WHERE (p.person_id=temp_req->qual[d.seq].eprsnl_id)
     AND p.name_type_cd=prsnl_type_cd
     AND p.active_ind=true
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   DETAIL
    temp_req->qual[d.seq].eprsnl_name = trim(p.name_full), temp_req->qual[d.seq].eprsnl_fname = trim(
     p.name_first), temp_req->qual[d.seq].eprsnl_mname = trim(p.name_middle),
    temp_req->qual[d.seq].eprsnl_lname = trim(p.name_last), temp_req->qual[d.seq].eprsnl_title = trim
    (p.name_title)
    IF (p.name_first > " ")
     temp_req->qual[d.seq].eprsnl_bname = trim(p.name_first)
     IF (p.name_middle > " ")
      temp_req->qual[d.seq].eprsnl_bname = concat(trim(temp_req->qual[d.seq].eprsnl_bname)," ",trim(p
        .name_middle))
      IF (p.name_last > " ")
       temp_req->qual[d.seq].eprsnl_bname = concat(trim(temp_req->qual[d.seq].eprsnl_bname)," ",trim(
         p.name_last))
      ENDIF
     ELSEIF (p.name_last > " ")
      temp_req->qual[d.seq].eprsnl_bname = concat(trim(temp_req->qual[d.seq].eprsnl_bname)," ",trim(p
        .name_last))
     ENDIF
    ELSEIF (p.name_middle > " ")
     temp_req->qual[d.seq].eprsnl_bname = trim(p.name_middle)
     IF (p.name_last > " ")
      temp_req->qual[d.seq].eprsnl_bname = concat(trim(temp_req->qual[d.seq].eprsnl_bname)," ",trim(p
        .name_last))
     ENDIF
    ELSEIF (p.name_last > " ")
     temp_req->qual[d.seq].eprsnl_bname = concat(trim(temp_req->qual[d.seq].eprsnl_bname)," ",trim(p
       .name_last))
    ELSE
     temp_req->qual[d.seq].eprsnl_bname = temp_req->qual[d.seq].eprsnl_name
    ENDIF
    IF ((temp_req->qual[d.seq].eprsnl_bname > " ")
     AND p.name_title > " ")
     temp_req->qual[d.seq].eprsnl_bname = concat(trim(temp_req->qual[d.seq].eprsnl_bname),", ",trim(p
       .name_title))
    ENDIF
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "EPRSNL_NAME"
   GO TO exit_script
  ENDIF
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM dba_tables d
  PLAN (d
   WHERE d.table_name="MLTM_NDC_MAIN_DRUG_CODE"
    AND d.owner="V500")
  DETAIL
   use_pco = true
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "DBA_TABLES"
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo(build("***   use_pco",use_pco))
 CALL echo("***")
 IF (use_pco=false)
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM dba_tables d
   PLAN (d
    WHERE d.table_name="NDC_MAIN_MULTUM_DRUG_CODE"
     AND d.owner="V500")
   DETAIL
    v500_ind = true
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "DBA_TABLES"
   GO TO exit_script
  ENDIF
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 CALL echo(use_pco)
 IF (use_pco=true)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(temp_req->qual_knt)),
    mltm_ndc_main_drug_code n
   PLAN (d
    WHERE d.seq > 0
     AND (temp_req->qual[d.seq].d_nbr > " "))
    JOIN (n
    WHERE (n.drug_identifier=temp_req->qual[d.seq].d_nbr))
   ORDER BY d.seq, n.csa_schedule
   HEAD d.seq
    mltm_loaded = true, temp_req->qual[d.seq].csa_schedule = n.csa_schedule
    IF (n.csa_schedule="0")
     temp_req->qual[d.seq].csa_group = "C"
    ELSEIF (((n.csa_schedule="1") OR (n.csa_schedule="2")) )
     temp_req->qual[d.seq].csa_group = "A"
    ELSEIF (((n.csa_schedule="3") OR (((n.csa_schedule="4") OR (n.csa_schedule="5")) )) )
     temp_req->qual[d.seq].csa_group = "B"
    ELSE
     temp_req->qual[d.seq].csa_group = "C"
    ENDIF
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (((ierrcode > 0) OR (mltm_loaded=false)) )
   SET failed = select_error
   SET table_name = "MLTM_CSA_SCHEDULE"
   IF (mltm_loaded=false)
    SET serrmsg = "Table is Empty"
   ENDIF
   GO TO exit_script
  ENDIF
 ELSEIF (v500_ind=true)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(temp_req->qual_knt)),
    ndc_main_multum_drug_code n
   PLAN (d
    WHERE d.seq > 0
     AND (temp_req->qual[d.seq].d_nbr > " "))
    JOIN (n
    WHERE (n.drug_identifier=temp_req->qual[d.seq].d_nbr))
   ORDER BY d.seq, n.csa_schedule
   HEAD d.seq
    mltm_loaded = true, temp_req->qual[d.seq].csa_schedule = n.csa_schedule
    IF (n.csa_schedule="0")
     temp_req->qual[d.seq].csa_group = "C"
    ELSEIF (((n.csa_schedule="1") OR (n.csa_schedule="2")) )
     temp_req->qual[d.seq].csa_group = "A"
    ELSEIF (((n.csa_schedule="3") OR (((n.csa_schedule="4") OR (n.csa_schedule="5")) )) )
     temp_req->qual[d.seq].csa_group = "B"
    ELSE
     temp_req->qual[d.seq].csa_group = "C"
    ENDIF
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (((ierrcode > 0) OR (mltm_loaded=false)) )
   SET failed = select_error
   SET table_name = "CSA_SCHEDULE"
   IF (mltm_loaded=false)
    SET serrmsg = "Table is Empty"
   ENDIF
   GO TO exit_script
  ENDIF
 ELSE
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(temp_req->qual_knt)),
    (v500_ref.ndc_main_multum_drug_code n)
   PLAN (d
    WHERE d.seq > 0
     AND (temp_req->qual[d.seq].d_nbr > " "))
    JOIN (n
    WHERE (n.drug_id=temp_req->qual[d.seq].d_nbr))
   ORDER BY d.seq, n.csa_schedule
   HEAD d.seq
    mltm_loaded = true, temp_req->qual[d.seq].csa_schedule = n.csa_schedule
    IF (n.csa_schedule="0")
     temp_req->qual[d.seq].csa_group = "C"
    ELSEIF (((n.csa_schedule="1") OR (n.csa_schedule="2")) )
     temp_req->qual[d.seq].csa_group = "A"
    ELSEIF (((n.csa_schedule="3") OR (((n.csa_schedule="4") OR (n.csa_schedule="5")) )) )
     temp_req->qual[d.seq].csa_group = "B"
    ELSE
     temp_req->qual[d.seq].csa_group = "C"
    ENDIF
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (((ierrcode > 0) OR (mltm_loaded=false)) )
   SET failed = select_error
   SET table_name = "V500_CSA_SCHEDULE"
   IF (mltm_loaded=false)
    SET serrmsg = "Table is Empty"
   ENDIF
   GO TO exit_script
  ENDIF
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM order_detail od,
   oe_format_fields oef,
   (dummyt d1  WITH seq = value(temp_req->qual_knt))
  PLAN (d1
   WHERE d1.seq > 0)
   JOIN (od
   WHERE (od.order_id=temp_req->qual[d1.seq].order_id))
   JOIN (oef
   WHERE (oef.oe_format_id=temp_req->qual[d1.seq].oe_format_id)
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
    IF (od.oe_field_meaning_id=2107)
     temp_req->qual[d1.seq].print_dea = od.oe_field_value
    ELSEIF (od.oe_field_meaning_id=2056)
     temp_req->qual[d1.seq].strength_dose = trim(od.oe_field_display_value)
    ELSEIF (od.oe_field_meaning_id=2057)
     temp_req->qual[d1.seq].strength_dose_unit = trim(od.oe_field_display_value)
    ELSEIF (od.oe_field_meaning_id=2058)
     temp_req->qual[d1.seq].volume_dose = trim(od.oe_field_display_value)
    ELSEIF (od.oe_field_meaning_id=2059)
     temp_req->qual[d1.seq].volume_dose_unit = trim(od.oe_field_display_value)
    ELSEIF (od.oe_field_meaning_id=2063)
     temp_req->qual[d1.seq].freetext_dose = trim(od.oe_field_display_value)
    ELSEIF (od.oe_field_meaning_id=2050)
     temp_req->qual[d1.seq].rx_route = trim(od.oe_field_display_value)
    ELSEIF (od.oe_field_meaning_id=2011)
     temp_req->qual[d1.seq].frequency = trim(od.oe_field_display_value)
    ELSEIF (od.oe_field_meaning_id=2061)
     temp_req->qual[d1.seq].duration = trim(od.oe_field_display_value)
    ELSEIF (od.oe_field_meaning_id=2062)
     temp_req->qual[d1.seq].duration_unit = trim(od.oe_field_display_value)
    ELSEIF (od.oe_field_meaning_id=2015)
     temp_req->qual[d1.seq].dispense_qty = trim(od.oe_field_display_value)
    ELSEIF (od.oe_field_meaning_id=2102)
     temp_req->qual[d1.seq].dispense_qty_unit = trim(od.oe_field_display_value)
    ELSEIF (od.oe_field_meaning_id=67)
     temp_req->qual[d1.seq].nbr_refills_txt = trim(od.oe_field_display_value), temp_req->qual[d1.seq]
     .nbr_refills = od.oe_field_value
    ELSEIF (od.oe_field_meaning_id=2101)
     temp_req->qual[d1.seq].prn_inst = trim(od.oe_field_display_value), temp_req->qual[d1.seq].
     prn_ind = 1
    ELSEIF (od.oe_field_meaning_id=1103)
     temp_req->qual[d1.seq].special_inst = trim(od.oe_field_display_value)
    ELSEIF (od.oe_field_meaning_id=15)
     temp_req->qual[d1.seq].indications = trim(od.oe_field_display_value)
    ELSEIF (od.oe_field_meaning_id=2017)
     temp_req->qual[d1.seq].daw = od.oe_field_value
    ELSEIF (od.oe_field_meaning_id=18)
     temp_req->qual[d1.seq].perform_loc = trim(od.oe_field_display_value)
    ELSEIF (od.oe_field_meaning_id=2108)
     temp_req->qual[d1.seq].phys_addr_id = od.oe_field_value
    ELSEIF (od.oe_field_meaning_id=1)
     temp_req->qual[d1.seq].free_txt_ord = trim(od.oe_field_display_value)
    ELSEIF (od.oe_field_meaning_id=1560)
     temp_req->qual[d1.seq].req_refill_date = od.oe_field_dt_tm_value
    ELSEIF (od.oe_field_meaning_id=51)
     temp_req->qual[d1.seq].req_start_date = od.oe_field_dt_tm_value
    ELSEIF (od.oe_field_meaning_id=1558)
     temp_req->qual[d1.seq].total_refills = od.oe_field_value
    ELSEIF (od.oe_field_meaning_id=1557)
     temp_req->qual[d1.seq].add_refills = trim(od.oe_field_display_value), temp_req->qual[d1.seq].
     refill_ind = true
    ELSEIF (od.oe_field_meaning_id=2105
     AND od.oe_field_value > 0
     AND  NOT (is_a_reprint))
     temp_req->qual[d1.seq].no_print = true
    ELSEIF (od.oe_field_meaning_id=138
     AND is_a_reprint=false
     AND (temp_req->qual[d1.seq].csa_group != "A"))
     temp_req->qual[d1.seq].output_dest_cd = od.oe_field_value
    ELSEIF (od.oe_field_meaning_id=139
     AND is_a_reprint=false
     AND (temp_req->qual[d1.seq].csa_group != "A"))
     temp_req->qual[d1.seq].free_text_nbr = trim(od.oe_field_display_value)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ORDER_DETAIL"
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
    AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY ea.beg_effective_dt_tm DESC
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
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 CALL echo(build("*** pmrn_cd :",pmrn_cd))
 SELECT INTO "nl:"
  d.seq, pa.beg_effective_dt_tm
  FROM (dummyt d  WITH seq = value(temp_req->qual_knt)),
   person_alias pa
  PLAN (d
   WHERE d.seq > 0
    AND (temp_req->qual[d.seq].found_emrn=false))
   JOIN (pa
   WHERE (pa.person_id=request->person_id)
    AND pa.person_alias_type_cd=pmrn_cd
    AND pa.active_ind=true
    AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY pa.beg_effective_dt_tm DESC
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
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(temp_req->qual_knt)),
   address a
  PLAN (d
   WHERE d.seq > 0
    AND (temp_req->qual[d.seq].no_print=false)
    AND (temp_req->qual[d.seq].phys_addr_id > 0))
   JOIN (a
   WHERE (a.address_id=temp_req->qual[d.seq].phys_addr_id))
  HEAD d.seq
   temp_req->qual[d.seq].found_phys_addr_ind = true, temp_req->qual[d.seq].phys_addr1 = trim(a
    .street_addr)
   IF (a.street_addr2 > " ")
    temp_req->qual[d.seq].phys_addr2 = trim(a.street_addr2)
   ENDIF
   IF (a.street_addr3 > " ")
    temp_req->qual[d.seq].phys_addr3 = trim(a.street_addr3)
   ENDIF
   IF (a.street_addr4 > " ")
    temp_req->qual[d.seq].phys_addr4 = trim(a.street_addr4)
   ENDIF
   IF (a.city > " ")
    temp_req->qual[d.seq].phys_city = trim(a.city)
   ENDIF
   IF (((a.state > " ") OR (a.state_cd > 0)) )
    IF ((temp_req->qual[d.seq].phys_city > " "))
     IF (a.state_cd > 0)
      temp_req->qual[d.seq].phys_city = concat(trim(temp_req->qual[d.seq].phys_city),", ",trim(
        uar_get_code_display(a.state_cd)))
     ELSE
      temp_req->qual[d.seq].phys_city = concat(trim(temp_req->qual[d.seq].phys_city),", ",trim(a
        .state))
     ENDIF
    ELSE
     IF (a.state_cd > 0)
      temp_req->qual[d.seq].phys_city = trim(uar_get_code_display(a.state_cd))
     ELSE
      temp_req->qual[d.seq].phys_city = trim(a.state)
     ENDIF
    ENDIF
   ENDIF
   IF (a.zipcode > " ")
    IF ((temp_req->qual[d.seq].phys_city > " "))
     temp_req->qual[d.seq].phys_city = concat(trim(temp_req->qual[d.seq].phys_city)," ",trim(a
       .zipcode))
    ELSE
     temp_req->qual[d.seq].phys_city = trim(a.zipcode)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PHYS_ADDR1"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  d.seq, pa.prsnl_alias_type_cd, pa.beg_effective_dt_tm
  FROM (dummyt d  WITH seq = value(temp_req->qual_knt)),
   prsnl_alias pa
  PLAN (d
   WHERE d.seq > 0
    AND (temp_req->qual[d.seq].no_print=false)
    AND (temp_req->qual[d.seq].phys_id > 0))
   JOIN (pa
   WHERE (pa.person_id=temp_req->qual[d.seq].phys_id)
    AND pa.prsnl_alias_type_cd=docdea_cd
    AND pa.active_ind=true
    AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
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
     temp_req->qual[d.seq].phys_dea = trim(cnvtalias(pa.alias,pa.alias_pool_cd))
    ELSE
     temp_req->qual[d.seq].phys_dea = trim(pa.alias)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PHYS_DEA"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  d.seq, a.beg_effective_dt_tm
  FROM (dummyt d  WITH seq = value(temp_req->qual_knt)),
   address a
  PLAN (d
   WHERE d.seq > 0
    AND (temp_req->qual[d.seq].no_print=false)
    AND (temp_req->qual[d.seq].found_phys_addr_ind=false)
    AND (temp_req->qual[d.seq].phys_id > 0))
   JOIN (a
   WHERE (a.parent_entity_id=temp_req->qual[d.seq].phys_id)
    AND a.parent_entity_name IN ("PERSON", "PRSNL")
    AND a.address_type_cd=work_add_cd
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY d.seq, a.beg_effective_dt_tm DESC
  HEAD d.seq
   IF ((temp_req->qual[d.seq].found_phys_addr_ind=false))
    temp_req->qual[d.seq].phys_addr_id = a.address_id, temp_req->qual[d.seq].found_phys_addr_ind =
    true, temp_req->qual[d.seq].phys_addr1 = trim(a.street_addr)
    IF (a.street_addr2 > " ")
     temp_req->qual[d.seq].phys_addr2 = trim(a.street_addr2)
    ENDIF
    IF (a.street_addr3 > " ")
     temp_req->qual[d.seq].phys_addr3 = trim(a.street_addr3)
    ENDIF
    IF (a.street_addr4 > " ")
     temp_req->qual[d.seq].phys_addr4 = trim(a.street_addr4)
    ENDIF
    IF (a.city > " ")
     temp_req->qual[d.seq].phys_city = trim(a.city)
    ENDIF
    IF (((a.state > " ") OR (a.state_cd > 0)) )
     IF ((temp_req->qual[d.seq].phys_city > " "))
      IF (a.state_cd > 0)
       temp_req->qual[d.seq].phys_city = concat(trim(temp_req->qual[d.seq].phys_city),", ",trim(
         uar_get_code_display(a.state_cd)))
      ELSE
       temp_req->qual[d.seq].phys_city = concat(trim(temp_req->qual[d.seq].phys_city),", ",trim(a
         .state))
      ENDIF
     ELSE
      IF (a.state_cd > 0)
       temp_req->qual[d.seq].phys_city = trim(uar_get_code_display(a.state_cd))
      ELSE
       temp_req->qual[d.seq].phys_city = trim(a.state)
      ENDIF
     ENDIF
    ENDIF
    IF (a.zipcode > " ")
     IF ((temp_req->qual[d.seq].phys_city > " "))
      temp_req->qual[d.seq].phys_city = concat(trim(temp_req->qual[d.seq].phys_city)," ",trim(a
        .zipcode))
     ELSE
      temp_req->qual[d.seq].phys_city = trim(a.zipcode)
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PHYS_ADDR2"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(temp_req->qual_knt)),
   phone p
  PLAN (d
   WHERE d.seq > 0)
   JOIN (p
   WHERE (p.parent_entity_id=temp_req->qual[d.seq].phys_id)
    AND p.parent_entity_name IN ("PERSON", "PRSNL")
    AND p.phone_type_cd=work_phone_cd
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY d.seq, p.beg_effective_dt_tm DESC
  HEAD d.seq
   temp_req->qual[d.seq].phys_phone = trim(cnvtphone(p.phone_num,p.phone_format_cd,2))
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  d.seq, epr.beg_effective_dt_tm
  FROM (dummyt d  WITH seq = value(temp_req->qual_knt)),
   encntr_plan_reltn epr,
   health_plan hp,
   organization o
  PLAN (d
   WHERE d.seq > 0
    AND (temp_req->qual[d.seq].encntr_id > 0))
   JOIN (epr
   WHERE (epr.encntr_id=temp_req->qual[d.seq].encntr_id)
    AND epr.priority_seq IN (1, 2, 99)
    AND epr.active_ind=true
    AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (hp
   WHERE hp.health_plan_id=epr.health_plan_id
    AND hp.active_ind=true)
   JOIN (o
   WHERE o.organization_id=epr.organization_id)
  ORDER BY d.seq, epr.beg_effective_dt_tm DESC
  HEAD REPORT
   hp_99_name = fillstring(100," "), hp_99_polgrp = fillstring(200," ")
  HEAD d.seq
   found_pri_hp = false, found_sec_hp = false, found_99_hp = false
  DETAIL
   IF (epr.priority_seq=1
    AND found_pri_hp=false)
    temp_req->qual[d.seq].hp_pri_found = true, temp_req->qual[d.seq].hp_pri_name = trim(o.org_name),
    temp_req->qual[d.seq].hp_pri_polgrp = concat(trim(epr.member_nbr),"/",trim(hp.group_nbr)),
    found_pri_hp = true
   ENDIF
   IF (epr.priority_seq=2
    AND found_sec_hp=false)
    temp_req->qual[d.seq].hp_sec_found = true, temp_req->qual[d.seq].hp_sec_name = trim(o.org_name),
    temp_req->qual[d.seq].hp_sec_polgrp = concat(trim(epr.member_nbr),"/",trim(hp.group_nbr)),
    found_sec_hp = true
   ENDIF
   IF (epr.priority_seq=99
    AND found_99_hp=false)
    hp_99_name = trim(o.org_name), hp_99_polgrp = concat(trim(epr.member_nbr),"/",trim(hp.group_nbr)),
    found_99_hp = true
   ENDIF
  FOOT  d.seq
   IF (found_pri_hp=false
    AND found_99_hp=true)
    temp_req->qual[d.seq].hp_pri_found = true, temp_req->qual[d.seq].hp_pri_name = trim(hp_99_name),
    temp_req->qual[d.seq].hp_pri_polgrp = trim(hp_99_polgrp),
    found_pri_hp = true
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ENCNTR_HEALTH"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  d.seq, ppr.beg_effective_dt_tm
  FROM (dummyt d  WITH seq = value(temp_req->qual_knt)),
   person_plan_reltn ppr,
   health_plan hp,
   organization o
  PLAN (d
   WHERE d.seq > 0
    AND (((temp_req->qual[d.seq].hp_pri_found=false)) OR ((temp_req->qual[d.seq].hp_sec_found=false)
   )) )
   JOIN (ppr
   WHERE (ppr.person_id=request->person_id)
    AND ppr.priority_seq IN (1, 2, 99)
    AND ppr.active_ind=true
    AND ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (hp
   WHERE hp.health_plan_id=ppr.health_plan_id
    AND hp.active_ind=true)
   JOIN (o
   WHERE o.organization_id=ppr.organization_id)
  ORDER BY d.seq, ppr.beg_effective_dt_tm DESC
  HEAD REPORT
   hp_99_name = fillstring(100," "), hp_99_polgrp = fillstring(200," ")
  HEAD d.seq
   found_pri_hp = false, found_sec_hp = false, found_99_hp = false
  DETAIL
   IF (ppr.priority_seq=1
    AND found_pri_hp=false
    AND (temp_req->qual[d.seq].hp_pri_found=false))
    temp_req->qual[d.seq].hp_pri_found = true, temp_req->qual[d.seq].hp_pri_name = trim(o.org_name),
    temp_req->qual[d.seq].hp_pri_polgrp = concat(trim(ppr.member_nbr),"/",trim(hp.group_nbr)),
    found_pri_hp = true
   ENDIF
   IF (ppr.priority_seq=2
    AND found_sec_hp=false
    AND (temp_req->qual[d.seq].hp_sec_found=false))
    temp_req->qual[d.seq].hp_sec_found = true, temp_req->qual[d.seq].hp_sec_name = trim(o.org_name),
    temp_req->qual[d.seq].hp_sec_polgrp = concat(trim(ppr.member_nbr),"/",trim(hp.group_nbr)),
    found_sec_hp = true
   ENDIF
   IF (ppr.priority_seq=99
    AND found_99_hp=false
    AND (temp_req->qual[d.seq].hp_pri_found=false))
    hp_99_name = trim(o.org_name), hp_99_polgrp = concat(trim(ppr.member_nbr),"/",trim(hp.group_nbr)),
    found_99_hp = true
   ENDIF
  FOOT  d.seq
   IF (found_pri_hp=false
    AND found_99_hp=true)
    temp_req->qual[d.seq].hp_pri_found = true, temp_req->qual[d.seq].hp_pri_name = trim(hp_99_name),
    temp_req->qual[d.seq].hp_pri_polgrp = trim(hp_99_polgrp),
    found_pri_hp = true
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PERSON_HEALTH"
  GO TO exit_script
 ENDIF
 FOR (a = 1 TO temp_req->qual_knt)
   IF ((temp_req->qual[a].no_print=false))
    IF ((temp_req->qual[a].free_txt_ord > " "))
     SET temp_req->qual[a].med_name = trim(temp_req->qual[a].free_txt_ord)
    ELSE
     SET temp_req->qual[a].med_name = trim(temp_req->qual[a].order_as_mnemonic)
    ENDIF
    IF ((temp_req->qual[a].add_refills > " "))
     SET temp_req->qual[a].med_name = concat(trim(temp_req->qual[a].add_refills)," Refill(s) of: ",
      trim(temp_req->qual[a].med_name))
    ELSE
     IF ((temp_req->qual[a].nbr_refills_txt > " "))
      IF ((temp_req->qual[a].nbr_refills=temp_req->qual[a].total_refills))
       SET temp_req->qual[a].refill_line = trim(temp_req->qual[a].nbr_refills_txt)
      ENDIF
     ENDIF
     IF ((temp_req->qual[a].refill_line > " "))
      SET pt->line_cnt = 0
      SET max_length = 60
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
      CALL echo("****alix****")
      CALL echo(temp_req->qual[a].med[c].disp)
      CALL echo("****alix****")
    ENDFOR
    IF ((temp_req->qual[a].nbr_refills=temp_req->qual[a].total_refills))
     SET temp_req->qual[a].start_date = cnvtdatetime(cnvtdate(temp_req->qual[a].req_start_date),0)
    ELSE
     SET temp_req->qual[a].start_date = cnvtdatetime(cnvtdate(temp_req->qual[a].req_refill_date),0)
    ENDIF
    IF ((temp_req->qual[a].strength_dose > " ")
     AND (temp_req->qual[a].volume_dose > " "))
     SET temp_req->qual[a].sig_line = trim(temp_req->qual[a].strength_dose)
     IF ((temp_req->qual[a].strength_dose_unit > " "))
      SET temp_req->qual[a].sig_line = concat(trim(temp_req->qual[a].sig_line)," ",trim(temp_req->
        qual[a].strength_dose_unit))
     ENDIF
     SET temp_req->qual[a].sig_line = concat(trim(temp_req->qual[a].sig_line),"/",trim(temp_req->
       qual[a].volume_dose))
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
    ELSEIF ((temp_req->qual[a].strength_dose > " "))
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
     SET temp_req->qual[a].sig_line = trim(temp_req->qual[a].freetext_dose)
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
    ENDIF
    IF ((temp_req->qual[a].prn_ind=true))
     SET temp_req->qual[a].sig_line = concat(trim(temp_req->qual[a].sig_line)," PRN ",trim(temp_req->
       qual[a].prn_inst))
    ENDIF
    IF ((temp_req->qual[a].sig_line > " "))
     SET pt->line_cnt = 0
     SET max_length = 60
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
    IF ((temp_req->qual[a].dispense_line > " "))
     SET pt->line_cnt = 0
     SET max_length = 60
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
     SET max_length = 60
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
     SET max_length = 60
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
     SET max_length = 60
     EXECUTE dcp_parse_text value(temp_req->qual[a].comments), value(max_length)
     SET temp_req->qual[a].comment_knt = pt->line_cnt
     SET stat = alterlist(temp_req->qual[a].comment,temp_req->qual[a].comment_knt)
     FOR (c = 1 TO pt->line_cnt)
       SET temp_req->qual[a].comment[c].disp = trim(pt->lns[c].line)
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
 FREE RECORD tprint_req
 RECORD tprint_req(
   1 job_knt = i4
   1 job[*]
     2 refill_ind = i2
     2 phys_name = vc
     2 phys_bname = vc
     2 phys_fname = vc
     2 phys_mname = vc
     2 phys_lname = vc
     2 eprsnl_ind = i2
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
       3 med_knt = i4
       3 med[*]
         4 disp = vc
       3 sig_knt = i4
       3 sig[*]
         4 disp = vc
       3 dispense_knt = i4
       3 dispense[*]
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
     2 organization_id = f8
     2 location_cd = f8
     2 loc_addr = c30
     2 loc_addr2 = c30
     2 loc_city = c30
     2 loc_state = c2
     2 loc_zip = c5
     2 loc_ph = c14
 )
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  encntr_id = temp_req->qual[d.seq].encntr_id, print_loc = temp_req->qual[d.seq].print_loc, order_dt
   = format(cnvtdatetime(temp_req->qual[d.seq].order_dt),"mm/dd/yyyy;;d"),
  print_dea = temp_req->qual[d.seq].print_dea, csa_schedule = temp_req->qual[d.seq].csa_schedule,
  csa_group = temp_req->qual[d.seq].csa_group,
  daw = temp_req->qual[d.seq].daw, output_dest_cd = temp_req->qual[d.seq].output_dest_cd,
  free_text_nbr = temp_req->qual[d.seq].free_text_nbr,
  fax_seq = build(temp_req->qual[d.seq].output_dest_cd,temp_req->qual[d.seq].free_text_nbr), phys_id
   = temp_req->qual[d.seq].phys_id, phys_addr_id = temp_req->qual[d.seq].phys_addr_id,
  phys_seq = build(temp_req->qual[d.seq].phys_id,temp_req->qual[d.seq].phys_addr_id), refill_ind =
  temp_req->qual[d.seq].refill_ind, o_seq_1 = build(temp_req->qual[d.seq].refill_ind,temp_req->qual[d
   .seq].encntr_id),
  d.seq
  FROM (dummyt d  WITH seq = value(temp_req->qual_knt))
  PLAN (d
   WHERE d.seq > 0
    AND (temp_req->qual[d.seq].no_print=false))
  ORDER BY o_seq_1, order_dt, daw,
   csa_group, csa_schedule, print_loc,
   fax_seq, phys_seq, print_dea,
   d.seq
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
   IF (temp_csa_group != csa_group)
    new_job = true
   ENDIF
   IF (new_job=true)
    new_job = false
    IF (jknt > 0)
     tprint_req->job[jknt].req_knt = rknt, stat = alterlist(tprint_req->job[jknt].req,rknt)
    ENDIF
    jknt = (jknt+ 1)
    IF (mod(jknt,10)=1
     AND jknt != 1)
     stat = alterlist(tprint_req->job,(jknt+ 9))
    ENDIF
    tprint_req->job[jknt].csa_group = csa_group, tprint_req->job[jknt].refill_ind = temp_req->qual[d
    .seq].refill_ind, tprint_req->job[jknt].phys_name = temp_req->qual[d.seq].phys_name,
    tprint_req->job[jknt].phys_bname = temp_req->qual[d.seq].phys_bname, tprint_req->job[jknt].
    phys_fname = temp_req->qual[d.seq].phys_fname, tprint_req->job[jknt].phys_mname = temp_req->qual[
    d.seq].phys_mname,
    tprint_req->job[jknt].phys_lname = temp_req->qual[d.seq].phys_lname, tprint_req->job[jknt].
    eprsnl_ind = temp_req->qual[d.seq].eprsnl_ind, tprint_req->job[jknt].eprsnl_bname = temp_req->
    qual[d.seq].eprsnl_bname,
    tprint_req->job[jknt].phys_addr1 = temp_req->qual[d.seq].phys_addr1, tprint_req->job[jknt].
    phys_addr2 = temp_req->qual[d.seq].phys_addr2, tprint_req->job[jknt].phys_addr3 = temp_req->qual[
    d.seq].phys_addr3,
    tprint_req->job[jknt].phys_addr4 = temp_req->qual[d.seq].phys_addr4, tprint_req->job[jknt].
    phys_city = temp_req->qual[d.seq].phys_city, tprint_req->job[jknt].phys_dea = temp_req->qual[d
    .seq].phys_dea,
    tprint_req->job[jknt].phys_lnbr = temp_req->qual[d.seq].phys_lnbr, tprint_req->job[jknt].
    phys_phone = temp_req->qual[d.seq].phys_phone, tprint_req->job[jknt].phys_ord_dt = order_dt,
    tprint_req->job[jknt].organization_id = temp_req->qual[d.seq].organization_id, tprint_req->job[
    jknt].location_cd = temp_req->qual[d.seq].location_cd, tprint_req->job[jknt].loc_addr = temp_req
    ->qual[d.seq].loc_addr,
    tprint_req->job[jknt].loc_addr2 = temp_req->qual[d.seq].loc_addr2, tprint_req->job[jknt].loc_city
     = temp_req->qual[d.seq].loc_city, tprint_req->job[jknt].loc_state = temp_req->qual[d.seq].
    loc_state,
    tprint_req->job[jknt].loc_zip = temp_req->qual[d.seq].loc_zip, tprint_req->job[jknt].loc_ph =
    temp_req->qual[d.seq].loc_ph
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
    temp_csa_group = csa_group, temp_csa_schedule = csa_schedule, rknt = 0,
    stat = alterlist(tprint_req->job[jknt].req,10)
   ENDIF
   IF (jknt > 0)
    rknt = (rknt+ 1)
    IF (mod(rknt,10)=1
     AND rknt != 1)
     stat = alterlist(tprint_req->job[jknt].req,(rknt+ 9))
    ENDIF
    tprint_req->job[jknt].req[rknt].print_dea = temp_req->qual[d.seq].print_dea, tprint_req->job[jknt
    ].req[rknt].order_id = temp_req->qual[d.seq].order_id, tprint_req->job[jknt].req[rknt].
    ord_det_disp = temp_req->qual[d.seq].ord_det_disp,
    tprint_req->job[jknt].req[rknt].csa_sched = csa_schedule, tprint_req->job[jknt].req[rknt].
    start_dt = format(cnvtdatetime(temp_req->qual[d.seq].start_date),"mm/dd/yyyy;;d"), tprint_req->
    job[jknt].req[rknt].med_knt = temp_req->qual[d.seq].med_knt,
    stat = alterlist(tprint_req->job[jknt].req[rknt].med,tprint_req->job[jknt].req[rknt].med_knt)
    FOR (z = 1 TO tprint_req->job[jknt].req[rknt].med_knt)
      tprint_req->job[jknt].req[rknt].med[z].disp = temp_req->qual[d.seq].med[z].disp
    ENDFOR
    tprint_req->job[jknt].req[rknt].sig_knt = temp_req->qual[d.seq].sig_knt, stat = alterlist(
     tprint_req->job[jknt].req[rknt].sig,tprint_req->job[jknt].req[rknt].sig_knt)
    FOR (z = 1 TO tprint_req->job[jknt].req[rknt].sig_knt)
      tprint_req->job[jknt].req[rknt].sig[z].disp = temp_req->qual[d.seq].sig[z].disp
    ENDFOR
    tprint_req->job[jknt].req[rknt].dispense_knt = temp_req->qual[d.seq].dispense_knt, stat =
    alterlist(tprint_req->job[jknt].req[rknt].dispense,tprint_req->job[jknt].req[rknt].dispense_knt)
    FOR (z = 1 TO tprint_req->job[jknt].req[rknt].dispense_knt)
      tprint_req->job[jknt].req[rknt].dispense[z].disp = temp_req->qual[d.seq].dispense[z].disp
    ENDFOR
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
   ENDIF
  FOOT REPORT
   tprint_req->job_knt = jknt, stat = alterlist(tprint_req->job,jknt), tprint_req->job[jknt].req_knt
    = rknt,
   stat = alterlist(tprint_req->job[jknt].req,rknt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "BUILD_TPRINT"
  GO TO exit_script
 ENDIF
 CALL echorecord(demo_info)
 CALL echorecord(temp_req)
 FREE RECORD temp_req
 CALL echorecord(tprint_req)
 FOR (i = 1 TO tprint_req->job_knt)
   SELECT INTO value(tprint_req->job[i].print_loc)
    org = substring(1,30,o.org_name), location = uar_get_code_display(e.loc_nurse_unit_cd), street =
    a.street_addr,
    city = a.city, st = a.state, zip = a.zipcode,
    phone = cnvtphone(p.phone_num,p.phone_format_cd)
    FROM (dummyt d  WITH seq = 1),
     encounter e,
     dummyt d1,
     address a,
     phone p,
     organization o
    PLAN (d)
     JOIN (e
     WHERE e.encntr_id=prt_encntr_id
      AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (d1)
     JOIN (a
     WHERE a.parent_entity_id=e.loc_nurse_unit_cd
      AND a.address_type_cd=clinic_add_cd)
     JOIN (p
     WHERE p.parent_entity_id=e.loc_nurse_unit_cd
      AND p.phone_type_cd=clinic_phone_cd)
     JOIN (o
     WHERE (o.organization_id=tprint_req->job[i].organization_id))
    HEAD REPORT
     y_pos = 0, x_pos = 0, top_left_x = 65,
     top_left_y = 36, top_right_x = 350, top_right_y = 36,
     bottom_left_x = 65, bottom_left_y = 450, bottom_right_x = 350,
     bottom_right_y = 450, center_x = 208, center_y = 243,
     size_fac = 0, y_jump = 8, sig_x = 84,
     txt_line1 = "INTERCHANGE MANDATED UNLESS PRACTITIONER WRITES THE ", txt_line2 =
     'WORDS "NO SUBSTITUTION" AND "BRAND NAME MEDICALLY ', txt_line3 = 'NECESSARY" BELOW.',
     MACRO (strip)
      x = findstring(">",exp), len = size(trim(exp)), x2 = (len - 2),
      exp2 = substring(2,x2,exp)
     ENDMACRO
     , line1 = fillstring(58,"_"), line2 = fillstring(50,"_"),
     line3 = fillstring(62,"_"), tr10 = "{f/4}{cpi/10}{lpi/6}", tr10i = "{f/6}{cpi/10}{lpi/6}",
     tr12 = "{f/4}{cpi/12}{lpi/8}", tr12i = "{f/6}{cpi/12}{lpi/8}", tr15 = "{f/4}{cpi/15}{lpi/8}",
     tr15i = "{f/6}{cpi/15}{lpi/8}", hel10 = "{f/8}{cpi/10}{lpi/6}", hel10i = "{f/10}{cpi/10}{lpi/6}",
     hel12 = "{f/8}{cpi/12}{lpi/8}", hel12i = "{f/10}{cpi/12}{lpi/8}", hel15 = "{f/8}{cpi/15}{lpi/8}",
     hel15i = "{f/10}{cpi/15}{lpi/8}", x_pos = 154, y_pos = 39,
     hel15,
     CALL print(calcpos(x_pos,y_pos)), "{b}BAYSTATE HEALTH SYSTEMS{endb}",
     row + 1, x_pos = 179, y_pos = (y_pos+ y_jump),
     nur_unit = trim(location,3),
     CALL print(calcpos(x_pos,y_pos)), nur_unit,
     row + 1, x_pos = 181, y_pos = (y_pos+ y_jump),
     str = trim(street),
     CALL print(calcpos(x_pos,y_pos)), str,
     row + 1, x_pos = 174, y_pos = (y_pos+ y_jump),
     csz = concat(trim(city),", ",trim(st),"  ",trim(zip)),
     CALL print(calcpos(x_pos,y_pos)), csz,
     row + 1, x_pos = 172, y_pos = (y_pos+ y_jump),
     p_phone = trim(phone),
     CALL print(calcpos(x_pos,y_pos)), "{b}Phone: {endb}",
     p_phone, row + 1, x_pos = top_left_x,
     y_pos = (y_pos+ (y_jump * 2)),
     CALL print(calcpos(x_pos,y_pos)), "{b}Date: {endb}",
     tprint_req->job[i].req[1].start_dt, row + 1, x_pos = top_left_x,
     y_pos = (y_pos+ (y_jump * 1.5)),
     CALL print(calcpos(x_pos,y_pos)), "{b}",
     demo_info->pat_name, "{endb}", row + 1,
     x_pos = top_left_x, y_pos = (y_pos+ (y_jump * 1.5)),
     CALL print(calcpos(x_pos,y_pos)),
     "Date Of Birth: ", demo_info->pat_bday, row + 1,
     x_pos = top_left_x, y_pos = (y_pos+ y_jump),
     CALL print(calcpos(x_pos,y_pos)),
     demo_info->pat_addr, row + 1, x_pos = top_left_x,
     y_pos = (y_pos+ y_jump),
     CALL print(calcpos(x_pos,y_pos)), demo_info->pat_city,
     row + 1, x_pos = top_left_x, y_pos = (y_pos+ (y_jump * 2)),
     CALL print(calcpos(x_pos,y_pos)), "{b}RX: {endb}", tprint_req->job[i].req[1].med[1].disp,
     row + 1, x_pos = top_left_x, y_pos = (y_pos+ (y_jump * 2)),
     CALL print(calcpos(x_pos,y_pos)), "{b}SIG: {endb}", tprint_req->job[i].req[1].sig[1].disp,
     row + 1, x_pos = top_left_x, y_pos = (y_pos+ (y_jump * 2)),
     CALL print(calcpos(x_pos,y_pos)), "{b}DISP: {endb}", exp = tprint_req->job[i].req[1].dispense[1]
     .disp,
     strip, exp2, row + 1,
     x_pos = top_left_x, y_pos = (y_pos+ (y_jump * 2)),
     CALL print(calcpos(x_pos,y_pos)),
     "{b}REFILL: {endb}", exp = tprint_req->job[i].req[1].refill[1].disp, strip,
     exp2, row + 1, x_pos = top_left_x,
     y_pos = (y_pos+ (y_jump * 6)),
     CALL print(calcpos(x_pos,y_pos)), "{b}DX: {endb}",
     line1, row + 1, x_pos = top_left_x,
     y_pos = (y_pos+ (y_jump * 6)),
     CALL print(calcpos(x_pos,y_pos)), "{b}SIGNATURE: {endb}",
     line2, row + 1, x_pos = top_left_x,
     y_pos = (y_pos+ (y_jump * 4)),
     CALL print(calcpos(x_pos,y_pos)), "{b}DEA NUMBER: {endb}",
     tprint_req->job[i].req[1].print_dea, row + 1, x_pos = top_left_x,
     y_pos = (y_pos+ (y_jump * 4)),
     CALL print(calcpos(x_pos,y_pos)), txt_line1,
     row + 1, x_pos = top_left_x, y_pos = (y_pos+ y_jump),
     CALL print(calcpos(x_pos,y_pos)), txt_line2, row + 1,
     x_pos = top_left_x, y_pos = (y_pos+ y_jump),
     CALL print(calcpos(x_pos,y_pos)),
     txt_line3, row + 1, x_pos = top_left_x,
     y_pos = (y_pos+ (y_jump * 4)),
     CALL print(calcpos(x_pos,y_pos)), line3,
     row + 1
    WITH dio = postscript, maxrow = 600, maxcol = 5000,
     outerjoin = d1
   ;end select
 ENDFOR
#exit_script
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
 CALL echorecord(reply)
 SET script_version = "006 07/02/03 SF3151"
 SET rx_version = "01"
END GO
