CREATE PROGRAM bhs_dietary_report_b_rmilk2:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility:" = 673936.00,
  "Nursing Unit(s):" = value(0.0),
  "Order Status:" = value(2550.00)
  WITH outdev, mf_facility, mf_nurse_unit,
  mf_order_status
 DECLARE mf_inpatient_enc_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,
   "Inpatient"))
 DECLARE mf_observation_enc_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,
   "Observation"))
 DECLARE mf_daystay_enc_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,"Daystay"))
 DECLARE mf_outpatient_enc_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,
   "Outpatient"))
 DECLARE mf_emergency_enc_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,
   "Emergency"))
 DECLARE mf_food_allergy_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",12020,"FOOD"))
 DECLARE mf_active_allergy_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",12025,"ACTIVE"))
 DECLARE mf_breast_milk_diet_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "BREASTMILK"))
 DECLARE mf_breast_milk_ppid_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HUMANBREASTMILK"))
 DECLARE mf_breast_milk_donor_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "DONORBREASTMILK"))
 DECLARE mf_ordered = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE ms_output = vc WITH protect, noconstant(trim( $OUTDEV))
 DECLARE ms_temp = vc WITH protect, noconstant(" ")
 DECLARE ms_error = vc WITH protect, noconstant("")
 DECLARE ms_data_type = vc WITH protect, noconstant("")
 DECLARE ms_tmp_str = vc WITH protect, noconstant("")
 DECLARE ms_unit_p = vc WITH protect, noconstant("")
 DECLARE ms_order_p = vc WITH protect, noconstant("")
 DECLARE ms_status = vc WITH protect, noconstant("NULL")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_allergy_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_location = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_start = i4 WITH protect, noconstant(0)
 DECLARE ml_type = i4 WITH protect, noconstant(0)
 FREE RECORD diet
 RECORD diet(
   1 cnt = i4
   1 qual[*]
     2 encntr_id = f8
     2 encntr_type_cd = f8
     2 loc_facility_cd = f8
     2 loc_nurse_unit_cd = f8
     2 loc_room_cd = f8
     2 loc_bed_cd = f8
     2 person_id = f8
     2 name_full_formatted = vc
     2 fmrn = vc
     2 acct_num = vc
     2 allergy_cnt = i4
     2 allergies[*]
       3 allergy_id = f8
       3 nomenclature_id = f8
       3 source_string = vc
       3 severity_cd = f8
     2 bm_order_cnt = i4
     2 bm_ppid_cnt = i4
     2 breast_milk[*]
       3 order_id = f8
       3 order_status = vc
       3 order_name = vc
       3 order_status_cd = vc
       3 order_detail = vc
       3 ppid_id = f8
       3 ppid_status = vc
       3 ppid_name = vc
       3 ppid_status_cd = vc
       3 ppid_detail = vc
     2 dbm_order_cnt = i4
     2 dbm_ppid_cnt = i4
     2 donor_breast_milk[*]
       3 order_id = f8
       3 order_status = vc
       3 order_name = vc
       3 order_status_cd = vc
       3 order_detail = vc
       3 ppid_id = f8
       3 ppid_status = vc
       3 ppid_name = vc
       3 ppid_status_cd = vc
       3 ppid_detail = vc
 ) WITH protect
 SET ms_data_type = reflect(parameter(3,0))
 IF (substring(1,1,ms_data_type)="L")
  FOR (ml_cnt = 1 TO cnvtint(substring(2,(size(ms_data_type) - 1),ms_data_type)))
   SET ms_tmp_str = cnvtstring(parameter(3,ml_cnt),20)
   IF (ml_cnt=1)
    SET ms_unit_p = concat(" e.loc_nurse_unit_cd in (",trim(ms_tmp_str))
   ELSE
    SET ms_unit_p = concat(ms_unit_p,", ",trim(ms_tmp_str))
   ENDIF
  ENDFOR
  SET ms_unit_p = concat(ms_unit_p,")")
 ELSEIF (parameter(3,1)=0.0)
  SET ms_unit_p = concat(" e.loc_facility_cd = ",cnvtstring( $MF_FACILITY))
 ELSE
  SET ms_unit_p = cnvtstring(parameter(3,1),20)
  SET ms_unit_p = concat(" e.loc_nurse_unit_cd = ",trim(ms_unit_p))
 ENDIF
 SET ms_data_type = reflect(parameter(4,0))
 IF (substring(1,1,ms_data_type)="L")
  FOR (ml_cnt = 1 TO cnvtint(substring(2,(size(ms_data_type) - 1),ms_data_type)))
   SET ms_tmp_str = cnvtstring(parameter(4,ml_cnt),20)
   IF (ml_cnt=1)
    SET ms_order_p = concat(" o.order_status_cd in (",trim(ms_tmp_str))
   ELSE
    SET ms_order_p = concat(ms_order_p,", ",trim(ms_tmp_str))
   ENDIF
  ENDFOR
  SET ms_order_p = concat(ms_order_p,")")
 ELSEIF (parameter(4,1)=0.0)
  SET ms_order_p = concat(" 1=1")
 ELSE
  SET ms_order_p = cnvtstring(parameter(4,1),20)
  SET ms_order_p = concat(" o.order_status_cd = ",trim(ms_order_p))
 ENDIF
 CALL echo("Select inpatient, observation, daystay, outpatient encounters")
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   allergy a,
   nomenclature n
  PLAN (e
   WHERE e.active_ind=1
    AND e.active_status_cd=mf_active_cd
    AND e.data_status_cd=mf_auth_cd
    AND e.loc_room_cd != 0
    AND e.loc_bed_cd != 0
    AND e.encntr_type_cd IN (mf_inpatient_enc_type_cd, mf_observation_enc_type_cd,
   mf_daystay_enc_type_cd, mf_outpatient_enc_type_cd)
    AND parser(ms_unit_p)
    AND cnvtdatetime(curdate,curtime3) BETWEEN e.beg_effective_dt_tm AND e.end_effective_dt_tm)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (a
   WHERE a.person_id=outerjoin(e.person_id)
    AND a.substance_type_cd=outerjoin(mf_food_allergy_type_cd)
    AND a.active_ind=outerjoin(1)
    AND a.reaction_status_cd=outerjoin(mf_active_allergy_cd))
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(a.substance_nom_id))
  ORDER BY e.encntr_id, n.nomenclature_id
  HEAD REPORT
   ml_cnt = 0
  HEAD e.encntr_id
   ml_cnt = (ml_cnt+ 1), ml_allergy_cnt = 0
   IF (mod(ml_cnt,100)=1)
    CALL alterlist(diet->qual,(ml_cnt+ 99))
   ENDIF
   diet->qual[ml_cnt].encntr_id = e.encntr_id, diet->qual[ml_cnt].person_id = e.person_id, diet->
   qual[ml_cnt].encntr_type_cd = e.encntr_type_cd,
   diet->qual[ml_cnt].loc_facility_cd = e.loc_facility_cd, diet->qual[ml_cnt].loc_nurse_unit_cd = e
   .loc_nurse_unit_cd, diet->qual[ml_cnt].loc_room_cd = e.loc_room_cd,
   diet->qual[ml_cnt].loc_bed_cd = e.loc_bed_cd, diet->qual[ml_cnt].name_full_formatted = trim(p
    .name_full_formatted)
  HEAD n.nomenclature_id
   IF (a.allergy_id > 0)
    ml_allergy_cnt = (ml_allergy_cnt+ 1)
    IF (mod(ml_allergy_cnt,10)=1)
     CALL alterlist(diet->qual[ml_cnt].allergies,(ml_allergy_cnt+ 9))
    ENDIF
    diet->qual[ml_cnt].allergies[ml_allergy_cnt].allergy_id = a.allergy_id, diet->qual[ml_cnt].
    allergies[ml_allergy_cnt].nomenclature_id = n.nomenclature_id, diet->qual[ml_cnt].allergies[
    ml_allergy_cnt].source_string = concat(trim(substring(1,40,n.source_string)),trim(substring(1,40,
       a.substance_ftdesc))),
    diet->qual[ml_cnt].allergies[ml_allergy_cnt].severity_cd = a.severity_cd
   ENDIF
  FOOT  e.encntr_id
   CALL alterlist(diet->qual[ml_cnt].allergies,ml_allergy_cnt), diet->qual[ml_cnt].allergy_cnt =
   ml_allergy_cnt
  FOOT REPORT
   CALL alterlist(diet->qual,ml_cnt), diet->cnt = ml_cnt
  WITH nocounter
 ;end select
 CALL echo("Select emergency encounters")
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   allergy a,
   nomenclature n,
   tracking_item te,
   tracking_locator tl
  PLAN (e
   WHERE e.active_ind=1
    AND e.active_status_cd=mf_active_cd
    AND e.data_status_cd=mf_auth_cd
    AND parser(ms_unit_p)
    AND cnvtdatetime(curdate,curtime3) BETWEEN e.beg_effective_dt_tm AND e.end_effective_dt_tm
    AND e.encntr_type_cd=mf_emergency_enc_type_cd)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (a
   WHERE a.person_id=outerjoin(e.person_id)
    AND a.substance_type_cd=outerjoin(mf_food_allergy_type_cd)
    AND a.active_ind=outerjoin(1)
    AND a.reaction_status_cd=outerjoin(mf_active_allergy_cd))
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(a.substance_nom_id))
   JOIN (te
   WHERE te.encntr_id=e.encntr_id)
   JOIN (tl
   WHERE tl.tracking_id=te.tracking_id
    AND tl.loc_bed_cd != 0
    AND tl.loc_room_cd != 0
    AND tl.depart_dt_tm > sysdate)
  ORDER BY e.encntr_id, n.nomenclature_id
  HEAD REPORT
   ml_cnt = diet->cnt,
   CALL alterlist(diet->qual,(ml_cnt+ 99))
  HEAD e.encntr_id
   ml_cnt = (ml_cnt+ 1), ml_allergy_cnt = 0
   IF (mod(ml_cnt,100)=1)
    CALL alterlist(diet->qual,(ml_cnt+ 99))
   ENDIF
   diet->qual[ml_cnt].encntr_id = e.encntr_id, diet->qual[ml_cnt].person_id = e.person_id, diet->
   qual[ml_cnt].encntr_type_cd = e.encntr_type_cd,
   diet->qual[ml_cnt].loc_facility_cd = e.loc_facility_cd, diet->qual[ml_cnt].loc_nurse_unit_cd = e
   .loc_nurse_unit_cd, diet->qual[ml_cnt].loc_bed_cd = tl.loc_bed_cd,
   diet->qual[ml_cnt].loc_room_cd = tl.loc_room_cd, diet->qual[ml_cnt].name_full_formatted = trim(p
    .name_full_formatted)
  HEAD n.nomenclature_id
   IF (a.allergy_id > 0)
    ml_allergy_cnt = (ml_allergy_cnt+ 1)
    IF (mod(ml_allergy_cnt,10)=1)
     CALL alterlist(diet->qual[ml_cnt].allergies,(ml_allergy_cnt+ 9))
    ENDIF
    diet->qual[ml_cnt].allergies[ml_allergy_cnt].allergy_id = a.allergy_id, diet->qual[ml_cnt].
    allergies[ml_allergy_cnt].nomenclature_id = n.nomenclature_id, diet->qual[ml_cnt].allergies[
    ml_allergy_cnt].source_string = concat(trim(substring(1,40,n.source_string)),trim(substring(1,40,
       a.substance_ftdesc))),
    diet->qual[ml_cnt].allergies[ml_allergy_cnt].severity_cd = a.severity_cd
   ENDIF
  FOOT  e.encntr_id
   CALL alterlist(diet->qual[ml_cnt].allergies,ml_allergy_cnt), diet->qual[ml_cnt].allergy_cnt =
   ml_allergy_cnt
  FOOT REPORT
   CALL alterlist(diet->qual,ml_cnt), diet->cnt = ml_cnt
  WITH nocounter
 ;end select
 CALL echo("Select MRN and Account Number")
 SELECT INTO "nl:"
  *
  FROM (dummyt d  WITH seq = value(diet->cnt)),
   encntr_alias ea
  PLAN (d)
   JOIN (ea
   WHERE (ea.encntr_id=diet->qual[d.seq].encntr_id)
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd IN (mf_fin_cd, mf_mrn_cd)
    AND ea.active_ind=1)
  DETAIL
   IF (ea.encntr_alias_type_cd=mf_mrn_cd)
    diet->qual[d.seq].fmrn = trim(cnvtalias(ea.alias,ea.alias_pool_cd))
   ELSE
    diet->qual[d.seq].acct_num = trim(cnvtalias(ea.alias,ea.alias_pool_cd))
   ENDIF
  WITH nocounter
 ;end select
 IF ((diet->cnt <= 0))
  CALL echo("No Data found for Selected Units after first Select Query")
  SET ms_status = "ERROR"
  IF (cnvtreal( $MF_NURSE_UNIT)=0.0)
   SET ms_error = build2("No encounters found at all nurse units under ",trim(uar_get_code_display(
      cnvtreal( $MF_FACILITY)))," facility.")
  ELSE
   SET ms_error = build2("No encounters found at ",trim(uar_get_code_display(cnvtreal( $MF_NURSE_UNIT
       )))," nurse unit under ",trim(uar_get_code_display(cnvtreal( $MF_FACILITY)))," facility.")
  ENDIF
  GO TO exit_script
 ENDIF
 CALL echo("Select Breast Milk Orders")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(diet->cnt)),
   orders o
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=diet->qual[d.seq].encntr_id)
    AND o.template_order_flag != 2
    AND o.active_ind=1
    AND parser(ms_order_p)
    AND o.catalog_cd=mf_breast_milk_diet_cd)
  ORDER BY o.encntr_id, o.order_id
  HEAD o.encntr_id
   ord_cnt = 0
  HEAD o.order_id
   ord_cnt = (ord_cnt+ 1)
   IF (mod(ord_cnt,10)=1)
    CALL alterlist(diet->qual[d.seq].breast_milk,(ord_cnt+ 9))
   ENDIF
   diet->qual[d.seq].breast_milk[ord_cnt].order_id = o.order_id, diet->qual[d.seq].breast_milk[
   ord_cnt].order_status = "", diet->qual[d.seq].breast_milk[ord_cnt].order_name = trim(o
    .order_mnemonic),
   diet->qual[d.seq].breast_milk[ord_cnt].order_status_cd = trim(uar_get_code_display(o
     .order_status_cd)), diet->qual[d.seq].breast_milk[ord_cnt].order_detail = trim(o
    .clinical_display_line), diet->qual[d.seq].breast_milk[ord_cnt].ppid_id = 0,
   diet->qual[d.seq].breast_milk[ord_cnt].ppid_status = "No PPID Order for Breast Milk", diet->qual[d
   .seq].breast_milk[ord_cnt].ppid_name = "", diet->qual[d.seq].breast_milk[ord_cnt].ppid_status_cd
    = "",
   diet->qual[d.seq].breast_milk[ord_cnt].ppid_detail = ""
  FOOT  o.encntr_id
   CALL alterlist(diet->qual[d.seq].breast_milk,ord_cnt), diet->qual[d.seq].bm_order_cnt = ord_cnt
  WITH nocounter
 ;end select
 CALL echo("Select Donor Breast Milk Orders")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(diet->cnt)),
   orders o
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=diet->qual[d.seq].encntr_id)
    AND o.template_order_flag != 2
    AND o.active_ind=1
    AND parser(ms_order_p)
    AND o.catalog_cd=mf_breast_milk_donor_cd)
  ORDER BY o.encntr_id, o.order_id
  HEAD o.encntr_id
   ord_cnt = 0
  HEAD o.order_id
   ord_cnt = (ord_cnt+ 1)
   IF (mod(ord_cnt,10)=1)
    CALL alterlist(diet->qual[d.seq].donor_breast_milk,(ord_cnt+ 9))
   ENDIF
   diet->qual[d.seq].donor_breast_milk[ord_cnt].order_id = o.order_id, diet->qual[d.seq].
   donor_breast_milk[ord_cnt].order_status = "", diet->qual[d.seq].donor_breast_milk[ord_cnt].
   order_name = trim(o.order_mnemonic),
   diet->qual[d.seq].donor_breast_milk[ord_cnt].order_status_cd = trim(uar_get_code_display(o
     .order_status_cd)), diet->qual[d.seq].donor_breast_milk[ord_cnt].order_detail = trim(o
    .clinical_display_line), diet->qual[d.seq].donor_breast_milk[ord_cnt].ppid_id = 0,
   diet->qual[d.seq].donor_breast_milk[ord_cnt].ppid_status = "No PPID Order for Donor Breast Milk",
   diet->qual[d.seq].donor_breast_milk[ord_cnt].ppid_name = "", diet->qual[d.seq].donor_breast_milk[
   ord_cnt].ppid_status_cd = "",
   diet->qual[d.seq].donor_breast_milk[ord_cnt].ppid_detail = ""
  FOOT  o.encntr_id
   CALL alterlist(diet->qual[d.seq].donor_breast_milk,ord_cnt), diet->qual[d.seq].dbm_order_cnt =
   ord_cnt
  WITH nocounter
 ;end select
 CALL echo("Select PPID Orders for Breast Milk")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(diet->cnt)),
   orders o
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=diet->qual[d.seq].encntr_id)
    AND o.template_order_flag != 2
    AND o.template_order_id=0
    AND o.active_ind=1
    AND o.synonym_id=264665546.00
    AND o.order_status_cd=mf_ordered
    AND o.catalog_cd=mf_breast_milk_ppid_cd)
  ORDER BY o.encntr_id, o.order_id
  HEAD o.encntr_id
   ord_cnt = 0
  HEAD o.order_id
   ord_cnt = (ord_cnt+ 1)
   IF ((ord_cnt > diet->qual[d.seq].bm_order_cnt))
    CALL alterlist(diet->qual[d.seq].breast_milk,ord_cnt), diet->qual[d.seq].breast_milk[ord_cnt].
    order_id = 0, diet->qual[d.seq].breast_milk[ord_cnt].order_status = "No Breast Milk Order",
    diet->qual[d.seq].breast_milk[ord_cnt].order_name = "", diet->qual[d.seq].breast_milk[ord_cnt].
    order_status_cd = "", diet->qual[d.seq].breast_milk[ord_cnt].order_detail = ""
   ENDIF
   diet->qual[d.seq].breast_milk[ord_cnt].ppid_id = o.order_id, diet->qual[d.seq].breast_milk[ord_cnt
   ].ppid_status = "Ordered Breast Milk for PPID", diet->qual[d.seq].breast_milk[ord_cnt].ppid_name
    = trim(o.ordered_as_mnemonic),
   diet->qual[d.seq].breast_milk[ord_cnt].ppid_status_cd = trim(uar_get_code_display(o
     .order_status_cd)), diet->qual[d.seq].breast_milk[ord_cnt].ppid_detail = trim(o
    .clinical_display_line)
  FOOT  o.encntr_id
   diet->qual[d.seq].bm_ppid_cnt = ord_cnt
  WITH nocounter
 ;end select
 CALL echo("Select PPID Orders for Donor Breast Milk")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(diet->cnt)),
   orders o
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=diet->qual[d.seq].encntr_id)
    AND o.template_order_flag != 2
    AND o.template_order_id=0
    AND o.active_ind=1
    AND o.synonym_id=633029790.00
    AND o.order_status_cd=mf_ordered
    AND o.catalog_cd=mf_breast_milk_ppid_cd)
  ORDER BY o.encntr_id, o.order_id
  HEAD o.encntr_id
   ord_cnt = 0
  HEAD o.order_id
   ord_cnt = (ord_cnt+ 1)
   IF ((ord_cnt > diet->qual[d.seq].dbm_order_cnt))
    CALL alterlist(diet->qual[d.seq].donor_breast_milk,ord_cnt), diet->qual[d.seq].donor_breast_milk[
    ord_cnt].order_id = 0, diet->qual[d.seq].donor_breast_milk[ord_cnt].order_status =
    "No Donor Breast Milk Order",
    diet->qual[d.seq].donor_breast_milk[ord_cnt].order_name = "", diet->qual[d.seq].
    donor_breast_milk[ord_cnt].order_status_cd = "", diet->qual[d.seq].donor_breast_milk[ord_cnt].
    order_detail = ""
   ENDIF
   diet->qual[d.seq].donor_breast_milk[ord_cnt].ppid_id = o.order_id, diet->qual[d.seq].
   donor_breast_milk[ord_cnt].ppid_status = "Ordered Donor Breast Milk for PPID", diet->qual[d.seq].
   donor_breast_milk[ord_cnt].ppid_name = trim(o.ordered_as_mnemonic),
   diet->qual[d.seq].donor_breast_milk[ord_cnt].ppid_status_cd = trim(uar_get_code_display(o
     .order_status_cd)), diet->qual[d.seq].donor_breast_milk[ord_cnt].ppid_detail = trim(o
    .clinical_display_line)
  FOOT  o.encntr_id
   diet->qual[d.seq].dbm_ppid_cnt = ord_cnt
  WITH nocounter
 ;end select
 FOR (ml_cnt = 1 TO size(diet->qual,5))
   IF ((diet->qual[ml_cnt].bm_ppid_cnt < diet->qual[ml_cnt].bm_order_cnt)
    AND (diet->qual[ml_cnt].bm_ppid_cnt > 0))
    SET ml_last_cnt = diet->qual[ml_cnt].bm_ppid_cnt
    FOR (ml_cnt2 = (diet->qual[ml_cnt].bm_ppid_cnt+ 1) TO diet->qual[ml_cnt].bm_order_cnt)
      SET diet->qual[ml_cnt].breast_milk[ml_cnt2].ppid_id = diet->qual[ml_cnt].breast_milk[
      ml_last_cnt].ppid_id
      SET diet->qual[ml_cnt].breast_milk[ml_cnt2].ppid_status = concat("Copied - ",diet->qual[ml_cnt]
       .breast_milk[ml_last_cnt].ppid_status)
      SET diet->qual[ml_cnt].breast_milk[ml_cnt2].ppid_name = diet->qual[ml_cnt].breast_milk[
      ml_last_cnt].ppid_name
      SET diet->qual[ml_cnt].breast_milk[ml_cnt2].ppid_status_cd = diet->qual[ml_cnt].breast_milk[
      ml_last_cnt].ppid_status_cd
      SET diet->qual[ml_cnt].breast_milk[ml_cnt2].ppid_detail = diet->qual[ml_cnt].breast_milk[
      ml_last_cnt].ppid_detail
    ENDFOR
   ENDIF
 ENDFOR
 FOR (ml_cnt = 1 TO size(diet->qual,5))
   IF ((diet->qual[ml_cnt].dbm_ppid_cnt < diet->qual[ml_cnt].dbm_order_cnt)
    AND (diet->qual[ml_cnt].dbm_ppid_cnt > 0))
    SET ml_last_cnt = diet->qual[ml_cnt].dbm_ppid_cnt
    FOR (ml_cnt2 = (diet->qual[ml_cnt].dbm_ppid_cnt+ 1) TO diet->qual[ml_cnt].dbm_order_cnt)
      SET diet->qual[ml_cnt].donor_breast_milk[ml_cnt2].ppid_id = diet->qual[ml_cnt].
      donor_breast_milk[ml_last_cnt].ppid_id
      SET diet->qual[ml_cnt].donor_breast_milk[ml_cnt2].ppid_status = concat("Copied - ",diet->qual[
       ml_cnt].donor_breast_milk[ml_last_cnt].ppid_status)
      SET diet->qual[ml_cnt].donor_breast_milk[ml_cnt2].ppid_name = diet->qual[ml_cnt].
      donor_breast_milk[ml_last_cnt].ppid_name
      SET diet->qual[ml_cnt].donor_breast_milk[ml_cnt2].ppid_status_cd = diet->qual[ml_cnt].
      donor_breast_milk[ml_last_cnt].ppid_status_cd
      SET diet->qual[ml_cnt].donor_breast_milk[ml_cnt2].ppid_detail = diet->qual[ml_cnt].
      donor_breast_milk[ml_last_cnt].ppid_detail
    ENDFOR
   ENDIF
 ENDFOR
 CALL echo("Dispaly to the screen")
 SELECT INTO value(ms_output)
  encntr_id = diet->qual[d.seq].encntr_id, loc_facility = substring(1,30,uar_get_code_display(diet->
    qual[d.seq].loc_facility_cd)), loc_nurse_unit = substring(1,30,uar_get_code_display(diet->qual[d
    .seq].loc_nurse_unit_cd)),
  room_and_bed = build(trim(uar_get_code_display(diet->qual[d.seq].loc_room_cd)),"/",trim(
    uar_get_code_display(diet->qual[d.seq].loc_bed_cd))), patient_name = substring(1,30,diet->qual[d
   .seq].name_full_formatted), fmrn = diet->qual[d.seq].fmrn,
  acct_num = diet->qual[d.seq].acct_num, enc_type_disp = substring(1,20,uar_get_code_display(diet->
    qual[d.seq].encntr_type_cd)), loc_room = substring(1,5,uar_get_code_display(diet->qual[d.seq].
    loc_room_cd)),
  loc_bed = substring(1,5,uar_get_code_display(diet->qual[d.seq].loc_bed_cd))
  FROM (dummyt d  WITH seq = value(size(diet->qual,5)))
  PLAN (d
   WHERE ((size(diet->qual[d.seq].breast_milk,5) > 0) OR (size(diet->qual[d.seq].donor_breast_milk,5)
    > 0)) )
  ORDER BY loc_facility, loc_nurse_unit, loc_room,
   loc_bed
  HEAD PAGE
   "{cpi/10}", col 30, "{CENTER/Breast Milk PPID Report/8/5}",
   "{cpi/14}", row + 2, col 0,
   "Run Time: ", curdate, " ",
   curtime, row + 1, col 0,
   "Facility: ", loc_facility, row + 1,
   col 0, "Nurse Unit: ", loc_nurse_unit,
   row + 1, col 5, "Room/Bed",
   col 20, "Patient Name", col 60,
   "FMRN", col 70, "Account #",
   col 90, "Encounter Type", row + 2
  HEAD encntr_id
   IF (row > 69)
    BREAK
   ENDIF
   col 5, room_and_bed, col 20,
   patient_name, col 60, fmrn,
   col 70, acct_num, col 90,
   enc_type_disp, row + 1
   IF ((diet->qual[d.seq].allergy_cnt > 0))
    ms_temp = concat("Allergies: ",trim(diet->qual[d.seq].allergies[1].source_string))
    FOR (i = 2 TO diet->qual[d.seq].allergy_cnt)
      ms_temp = concat(ms_temp,", ",trim(diet->qual[d.seq].allergies[i].source_string))
    ENDFOR
    col 50, "{B}", ms_temp,
    "{ENDB}", row + 1
   ENDIF
   IF (size(diet->qual[d.seq].breast_milk,5) > 0)
    ml_cnt = 0
    FOR (ml_cnt = 1 TO size(diet->qual[d.seq].breast_milk,5))
      order_id = diet->qual[d.seq].breast_milk[ml_cnt].order_id, order_status = substring(1,60,concat
       (diet->qual[d.seq].breast_milk[ml_cnt].order_status)), order_name = substring(1,50,concat(diet
        ->qual[d.seq].breast_milk[ml_cnt].order_name)),
      order_status_cd = substring(1,50,concat(diet->qual[d.seq].breast_milk[ml_cnt].order_status_cd)),
      order_detail = substring(1,200,diet->qual[d.seq].breast_milk[ml_cnt].order_detail), ppid_status
       = substring(1,60,concat(diet->qual[d.seq].breast_milk[ml_cnt].ppid_status)),
      ppid_name = substring(1,50,concat(diet->qual[d.seq].breast_milk[ml_cnt].ppid_name)),
      ppid_status_cd = substring(1,50,concat(diet->qual[d.seq].breast_milk[ml_cnt].ppid_status_cd)),
      ppid_detail = substring(1,200,diet->qual[d.seq].breast_milk[ml_cnt].ppid_detail)
      IF (substring(1,2,order_status)="No")
       ms_temp = concat("{B}",trim(order_status),"{ENDB}"), col 8, ms_temp,
       row + 1
      ELSE
       ms_temp = concat(cnvtstring(order_id),trim(order_name)," - ",trim(order_status_cd)), col 8,
       ms_temp,
       row + 1, col 8, "{f/6}",
       order_detail, "{f/0}", row + 1
      ENDIF
      IF (substring(1,2,ppid_status)="No")
       ms_temp = concat("{B}",trim(ppid_status),"{ENDB}"), col 8, ms_temp,
       row + 1
      ELSE
       ms_temp = concat(trim(ppid_name)," - ",trim(ppid_status_cd)," - ",trim(ppid_status)), col 8,
       ms_temp,
       row + 1, col 8, "{f/6}",
       ppid_detail, "{f/0}"
      ENDIF
      row + 2, ms_temp = ""
      IF (row > 69)
       BREAK
      ENDIF
    ENDFOR
   ENDIF
   IF (size(diet->qual[d.seq].donor_breast_milk,5) > 0)
    ml_cnt = 0
    FOR (ml_cnt = 1 TO size(diet->qual[d.seq].donor_breast_milk,5))
      donor_order_id = diet->qual[d.seq].donor_breast_milk[ml_cnt].order_id, donor_order_status =
      substring(1,60,concat(diet->qual[d.seq].donor_breast_milk[ml_cnt].order_status)),
      donor_order_name = substring(1,50,concat(diet->qual[d.seq].donor_breast_milk[ml_cnt].order_name
        )),
      donor_order_status_cd = substring(1,50,concat(diet->qual[d.seq].donor_breast_milk[ml_cnt].
        order_status_cd)), donor_order_detail = substring(1,200,diet->qual[d.seq].donor_breast_milk[
       ml_cnt].order_detail), donor_ppid_status = substring(1,60,concat(diet->qual[d.seq].
        donor_breast_milk[ml_cnt].ppid_status)),
      donor_ppid_name = substring(1,50,concat(diet->qual[d.seq].donor_breast_milk[ml_cnt].ppid_name)),
      donor_ppid_status_cd = substring(1,50,concat(diet->qual[d.seq].donor_breast_milk[ml_cnt].
        ppid_status_cd)), donor_ppid_detail = substring(1,200,diet->qual[d.seq].donor_breast_milk[
       ml_cnt].ppid_detail),
      ms_temp = ""
      IF (substring(1,2,donor_order_status)="No")
       ms_temp = concat("{B}",trim(donor_order_status),"{ENDB}"), col 8, ms_temp,
       row + 1
      ELSE
       ms_temp = concat(cnvtstring(donor_order_id),trim(donor_order_name)," - ",trim(
         donor_order_status_cd)), col 8, ms_temp,
       row + 1, col 8, "{f/6}",
       donor_order_detail, "{f/0}", row + 1
      ENDIF
      IF (substring(1,2,donor_ppid_status)="No")
       ms_temp = concat("{B}",trim(donor_ppid_status),"{ENDB}"), col 8, ms_temp,
       row + 1
      ELSE
       ms_temp = concat(trim(donor_ppid_name)," - ",trim(donor_ppid_status_cd)," - ",trim(
         donor_ppid_status)), col 8, ms_temp,
       row + 1, col 8, "{f/6}",
       donor_ppid_detail, "{f/0}"
      ENDIF
      row + 2, ms_temp = ""
      IF (row > 69)
       BREAK
      ENDIF
    ENDFOR
   ENDIF
  FOOT PAGE
   ms_temp = concat("Page: ",cnvtstring(curpage)),
   CALL print(calcpos(550,750)), "{B}",
   ms_temp, "{ENDB}"
  WITH dio = postscript, maxcol = 1000, maxrow = 80
 ;end select
 IF (ms_status != "ERROR")
  SET ms_status = "SUCCESS"
 ENDIF
#exit_script
 IF (ms_status != "SUCCESS")
  SELECT INTO value(ms_output)
   FROM dummyt
   HEAD REPORT
    col 0, "{PS/792 0}", row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(10,10)), value("Breast Milk PPID Report"),
    row + 2, "{F/1}{CPI/12}",
    CALL print(calcpos(14,25)),
    ms_error
   WITH dio = postscript, time = 5
  ;end select
 ENDIF
END GO
