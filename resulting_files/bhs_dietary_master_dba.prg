CREATE PROGRAM bhs_dietary_master:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Please enter a facility:" = 673936.00,
  "Nursing Unit" = value(0.0),
  "TPN Order Options" = 1,
  "Order Statuses" = value(0.0),
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev, mf_facility, mf_nurse_unit,
  ml_tpn_option, mf_order_status, outdev2
 DECLARE ms_output = vc WITH protect, noconstant("")
 DECLARE ms_tepmname = vc WITH protect, noconstant(fillstring(400," "))
 DECLARE ms_temp = vc WITH protect, noconstant(fillstring(400," "))
 DECLARE ms_error_head = vc WITH protect, noconstant("Dietary Master Report")
 DECLARE ms_error = vc WITH protect, noconstant("")
 DECLARE ms_data_type = vc WITH protect, noconstant("")
 DECLARE ms_tmp_str = vc WITH protect, noconstant("")
 DECLARE ms_unit_p = vc WITH protect, noconstant("")
 DECLARE ms_order_p = vc WITH protect, noconstant("")
 DECLARE ms_custom_units_p = vc WITH protect, noconstant("")
 DECLARE ms_nunit_amb_p = vc WITH protect, noconstant("")
 DECLARE ms_status = vc WITH protect, noconstant("NULL")
 DECLARE md_day = dq8 WITH protect, noconstant(0)
 DECLARE md_month = dq8 WITH protect, noconstant(0)
 DECLARE ml_operation = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_allergy_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ord_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ing_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cmt_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_exp_cnt = i4 WITH protect, noconstant(0)
 IF (validate(request->batch_selection))
  SET ml_operation = 1
  SET ms_tepmname = replace(trim(uar_get_code_display(cnvtreal( $MF_FACILITY)))," ","_",0)
  SET ms_output = cnvtlower(concat(trim(ms_tepmname),"_",trim("dietary_master_")))
  SET md_day = day(curdate)
  SET md_month = month(curdate)
  SET time1 = format(curtime,"HHMM;;M")
  SET ms_output = build(ms_output,md_month,md_day,"_",time1,
   ".ps")
 ELSE
  SET ms_output =  $OUTDEV
 ENDIF
 DECLARE mf_inpatient_enc_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,
   "Inpatient"))
 DECLARE mf_observation_enc_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,
   "Observation"))
 DECLARE mf_daystay_enc_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,"Daystay"))
 DECLARE mf_outpatient_enc_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,
   "Outpatient"))
 DECLARE mf_emergency_enc_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,
   "Emergency"))
 DECLARE mf_inpatient_hosp_enc_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",71,
   "IP Hospice"))
 DECLARE mf_non_sel_tray_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "MEALSERVICENONSELECTTRAYSERVICE"))
 DECLARE mf_meal_w_assist_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "MEALSERVICEASSISTWITHMENUSELECTION"))
 DECLARE mf_meal_delievery_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "MEALSERVICEDELIVERY"))
 DECLARE mf_food_allergy_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",12020,"FOOD"))
 DECLARE mf_drug_allergy_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",12020,"DRUG"))
 DECLARE mf_active_allergy_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",12025,"ACTIVE"))
 DECLARE mf_tube_continuous_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",106,
   "Tube Feeding Continuous"))
 DECLARE mf_infant_formula_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",106,
   "Infant Formulas"))
 DECLARE mf_infant_formula_add_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",106,
   "Infant Formula Additives"))
 DECLARE mf_tube_feeding_add_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",106,
   "Tube Feeding Additives"))
 DECLARE mf_tube_feeding_bolus_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",106,
   "Tube Feeding Bolus"))
 DECLARE mf_nut_services_consult_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",106,
   "Nutrition Services Consults"))
 DECLARE mf_supplements_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",106,"Supplements"))
 DECLARE mf_diets_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",106,"Diets"))
 DECLARE mf_diet_spec_inst = f8 WITH protect, constant(uar_get_code_by("DISPLAY",106,
   "Diet Special Instructions"))
 DECLARE mf_pharm_act_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",106,"Pharmacy"))
 DECLARE mf_cl_diet_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"CLEARLIQUIDDIET"
   ))
 DECLARE mf_cldiet_pediadol_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CLEARLIQUIDDIETPEDIADOL"))
 DECLARE mf_cl_no_red_color_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CLEARLIQUIDNOREDCOLORDIETPEDIADO"))
 DECLARE mf_cl_break_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CLEARLIQUIDBREAKFASTNPOLUNCH"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE mf_bmc_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE MEDICAL CENTER"))
 DECLARE mf_bfmc_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE FRANKLIN MEDICAL CENTER"))
 DECLARE mf_bmlh_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE MARY LANE HOSPITAL"))
 DECLARE mf_bnh_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE NOBLE HOSPITAL"))
 DECLARE mf_bnh_rehab_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE NOBLE REHABILITATION"))
 DECLARE mf_bnh_inpt_psych_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE NOBLE HOSPITAL INPATIENT PSYCHIATRY"))
 DECLARE mf_breast_milk_diet_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "BREASTMILK"))
 DECLARE mf_breast_milk_ppid_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HUMANBREASTMILK"))
 DECLARE mf_point_of_care_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,
   "POINTOFCARE"))
 DECLARE mf_glucose_poc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"GLUCOSEPOC")
  )
 DECLARE mf_glucose_nsg_poc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "GLUCOSENSGPOC"))
 DECLARE mf_cs200_isolation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ISOLATION"))
 DECLARE mf_cs6004_ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"
   ))
 DECLARE mf_cs70_neutropenic_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",70,
   "NEUTROPENIC"))
 FREE RECORD cmts
 RECORD cmts(
   1 qual[*]
     2 index1 = i4
     2 index2 = i4
     2 order_id = f8
 ) WITH protect
 FREE RECORD diet
 RECORD diet(
   1 cnt = i4
   1 qual[*]
     2 encntr_id = f8
     2 person_id = f8
     2 has_non_sel_try = i4
     2 has_w_assist = i4
     2 has_tpn_order = i4
     2 has_diet_order = i4
     2 has_clear_order = i4
     2 has_isolation_order = i4
     2 loc_facility_cd = f8
     2 loc_nurse_unit_cd = f8
     2 loc_room_cd = f8
     2 loc_bed_cd = f8
     2 name_full_formatted = vc
     2 encntr_type_cd = f8
     2 fmrn = vc
     2 acct_num = vc
     2 allergy_cnt = i4
     2 allergies[*]
       3 allergy_id = f8
       3 nomenclature_id = f8
       3 source_string = vc
       3 severity_cd = f8
     2 order_cnt = i4
     2 orders[*]
       3 order_id = f8
       3 activity_type_cd = f8
       3 catalog_cd = f8
       3 catalog_type_cd = f8
       3 order_status_cd = f8
       3 order_mnemonic = vc
       3 clinical_display_line = vc
       3 order_detail[*]
         4 non_sel_try = vc
         4 w_assist = vc
       3 ingredients[*]
         4 component_seq = i4
         4 order_mnemonic = vc
         4 order_detail_display_line = vc
         4 hna_order_mnemonic = vc
         4 ordered_as_mnemonic = vc
       3 comments[*]
         4 long_text_id = f8
         4 order_comment = vc
       3 catalog_cd2 = f8
       3 hna_order_as2 = vc
 ) WITH protect
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 SET reply->status_data[1].status = "F"
 IF (( $MF_FACILITY=mf_bmc_cd))
  SET ms_custom_units_p = build2(
   ' cv.display_key in ( "APTU", "C5A",   "C6A",   "C6B",   "CVCU", "CVIC","EDAU", "ESHLD", "ESS2", ',
   ' "ESS6", "ICUA", "ICUB", "ICUC",  "INFCH", "LDRPA", "LDRPB", "LDRPC", "NCCN",  "NICU", "NNURA", ',
   ' "NNURB",  "NNURC", "NNURD",  "OBHLD", "PICU",  "S1", "S2",    "S3",    "S3ONC1",  "S4", "S5",  ',
   '  "S64",   "S6ADO", "W3",    "W4",     "WIN2" ) ')
 ELSEIF (( $MF_FACILITY=mf_bfmc_cd))
  SET ms_custom_units_p =
  ' cv.display_key in ( "EDHLD", "ICCU", "MHU", "NSY", "OBGN", "SPK3", "SPK4", "SPK5" ) '
 ELSEIF (( $MF_FACILITY=mf_bmlh_cd))
  SET ms_custom_units_p = ' cv.display_key in ( "DW", "ERHD", "ICU", "NURS", "SDC", "WI" ) '
 ELSEIF (( $MF_FACILITY=mf_bnh_cd))
  SET ms_custom_units_p =
  ' cv.display_key in ( "2NOR", "EDNH", "ICUN", "NTEL", "NOBLEMEDDAYSTAY", "OBSERVATION", "SCUN" ) '
 ELSEIF (( $MF_FACILITY=mf_bnh_inpt_psych_cd))
  SET ms_custom_units_p = ' cv.display_key in ( "FWLR" ) '
 ELSEIF (( $MF_FACILITY=mf_bnh_rehab_cd))
  SET ms_custom_units_p = ' cv.display_key in ( "BRHB" ) '
 ENDIF
 IF (( $MF_FACILITY=mf_bnh_cd))
  SET ms_nunit_amb_p = ' cv.cdf_meaning in ("NURSEUNIT", "AMBULATORY") '
 ELSE
  SET ms_nunit_amb_p = ' cv.cdf_meaning = "NURSEUNIT" '
 ENDIF
 IF (ml_operation=1)
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=220
    AND cv.active_ind=1
    AND cv.data_status_cd=mf_auth_cd
    AND cv.end_effective_dt_tm > sysdate
    AND parser(ms_nunit_amb_p)
    AND parser(ms_custom_units_p)
   HEAD REPORT
    ml_cnt = 0
   DETAIL
    ml_cnt += 1
    IF (ml_cnt=1)
     ms_unit_p = concat(" e.loc_nurse_unit_cd in (",cnvtstring(cv.code_value))
    ELSE
     ms_unit_p = concat(ms_unit_p,", ",cnvtstring(cv.code_value))
    ENDIF
   FOOT REPORT
    ms_unit_p = concat(ms_unit_p,")")
   WITH nocounter
  ;end select
 ELSE
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
 ENDIF
 SET ms_data_type = reflect(parameter(5,0))
 IF (substring(1,1,ms_data_type)="L")
  FOR (ml_cnt = 1 TO cnvtint(substring(2,(size(ms_data_type) - 1),ms_data_type)))
   SET ms_tmp_str = cnvtstring(parameter(5,ml_cnt),20)
   IF (ml_cnt=1)
    SET ms_order_p = concat(" o.order_status_cd in (",trim(ms_tmp_str))
   ELSE
    SET ms_order_p = concat(ms_order_p,", ",trim(ms_tmp_str))
   ENDIF
  ENDFOR
  SET ms_order_p = concat(ms_order_p,")")
 ELSEIF (parameter(5,1)=0.0)
  SET ms_order_p = concat(" 1=1")
 ELSE
  SET ms_order_p = cnvtstring(parameter(5,1),20)
  SET ms_order_p = concat(" o.order_status_cd = ",trim(ms_order_p))
 ENDIF
 SET ms_order_p2 = replace(ms_order_p,"o.order_status_cd","oc.order_status_cd",0)
 CALL echo("Select inpatient, observation, daystay, outpatient encounters")
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   allergy a,
   dummyt d,
   nomenclature n
  PLAN (e
   WHERE e.active_ind=1
    AND e.active_status_cd=mf_active_cd
    AND e.data_status_cd=mf_auth_cd
    AND e.loc_room_cd != 0
    AND e.loc_bed_cd != 0
    AND e.encntr_type_cd IN (mf_inpatient_enc_type_cd, mf_observation_enc_type_cd,
   mf_daystay_enc_type_cd, mf_outpatient_enc_type_cd, mf_inpatient_hosp_enc_type_cd)
    AND parser(ms_unit_p)
    AND cnvtdatetime(sysdate) BETWEEN e.beg_effective_dt_tm AND e.end_effective_dt_tm)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (d)
   JOIN (a
   WHERE a.person_id=e.person_id
    AND a.substance_type_cd IN (mf_food_allergy_type_cd, mf_drug_allergy_type_cd)
    AND a.active_ind=1
    AND a.reaction_status_cd=mf_active_allergy_cd)
   JOIN (n
   WHERE (n.nomenclature_id= Outerjoin(a.substance_nom_id)) )
  ORDER BY e.encntr_id, n.nomenclature_id
  HEAD REPORT
   ml_cnt = 0
  HEAD e.encntr_id
   ml_cnt += 1, ml_allergy_cnt = 0
   IF (mod(ml_cnt,100)=1)
    CALL alterlist(diet->qual,(ml_cnt+ 99))
   ENDIF
   diet->qual[ml_cnt].encntr_id = e.encntr_id, diet->qual[ml_cnt].person_id = e.person_id, diet->
   qual[ml_cnt].encntr_type_cd = e.encntr_type_cd,
   diet->qual[ml_cnt].loc_facility_cd = e.loc_facility_cd, diet->qual[ml_cnt].loc_nurse_unit_cd = e
   .loc_nurse_unit_cd, diet->qual[ml_cnt].loc_room_cd = e.loc_room_cd,
   diet->qual[ml_cnt].loc_bed_cd = e.loc_bed_cd, diet->qual[ml_cnt].name_full_formatted = p
   .name_full_formatted, diet->qual[ml_cnt].has_tpn_order = 0,
   diet->qual[ml_cnt].has_diet_order = 0, diet->qual[ml_cnt].has_clear_order = 0, diet->qual[ml_cnt].
   has_non_sel_try = 0,
   diet->qual[ml_cnt].has_w_assist = 0
  HEAD n.nomenclature_id
   IF (a.allergy_id > 0)
    ml_allergy_cnt += 1
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
  WITH nocounter, outerjoin = d
 ;end select
 CALL echo("Select Emergency encounters")
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   allergy a,
   dummyt d,
   nomenclature n,
   tracking_item te,
   tracking_locator tl
  PLAN (e
   WHERE e.active_ind=1
    AND e.active_status_cd=mf_active_cd
    AND e.data_status_cd=mf_auth_cd
    AND parser(ms_unit_p)
    AND cnvtdatetime(sysdate) BETWEEN e.beg_effective_dt_tm AND e.end_effective_dt_tm
    AND e.encntr_type_cd=mf_emergency_enc_type_cd
    AND e.encntr_id IN (
   (SELECT
    te.encntr_id
    FROM tracking_item te,
     tracking_locator tl
    WHERE te.tracking_id=tl.tracking_id
     AND tl.loc_bed_cd != 0
     AND tl.loc_room_cd != 0
     AND tl.depart_dt_tm > sysdate)))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (d)
   JOIN (a
   WHERE a.person_id=e.person_id
    AND a.substance_type_cd IN (mf_food_allergy_type_cd, mf_drug_allergy_type_cd)
    AND a.active_ind=1
    AND a.reaction_status_cd=mf_active_allergy_cd)
   JOIN (n
   WHERE (n.nomenclature_id= Outerjoin(a.substance_nom_id)) )
   JOIN (te
   WHERE (te.encntr_id= Outerjoin(e.encntr_id)) )
   JOIN (tl
   WHERE (tl.tracking_id= Outerjoin(te.tracking_id))
    AND tl.depart_dt_tm > sysdate)
  ORDER BY e.encntr_id, n.nomenclature_id
  HEAD REPORT
   ml_cnt = diet->cnt,
   CALL alterlist(diet->qual,(ml_cnt+ 99))
  HEAD e.encntr_id
   ml_cnt += 1, ml_allergy_cnt = 0
   IF (mod(ml_cnt,100)=1)
    CALL alterlist(diet->qual,(ml_cnt+ 99))
   ENDIF
   diet->qual[ml_cnt].encntr_id = e.encntr_id, diet->qual[ml_cnt].person_id = e.person_id, diet->
   qual[ml_cnt].encntr_type_cd = e.encntr_type_cd,
   diet->qual[ml_cnt].loc_facility_cd = e.loc_facility_cd, diet->qual[ml_cnt].loc_nurse_unit_cd = e
   .loc_nurse_unit_cd, diet->qual[ml_cnt].loc_bed_cd = tl.loc_bed_cd,
   diet->qual[ml_cnt].loc_room_cd = tl.loc_room_cd, diet->qual[ml_cnt].name_full_formatted = p
   .name_full_formatted, diet->qual[ml_cnt].has_tpn_order = 0,
   diet->qual[ml_cnt].has_diet_order = 0, diet->qual[ml_cnt].has_clear_order = 0, diet->qual[ml_cnt].
   has_non_sel_try = 0,
   diet->qual[ml_cnt].has_w_assist = 0
  HEAD n.nomenclature_id
   IF (a.allergy_id > 0)
    ml_allergy_cnt += 1
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
  WITH nocounter, outerjoin = d
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
 CALL echo("option 1, 3, 8 ")
 SELECT INTO "nl:"
  FROM orders o,
   (dummyt d  WITH seq = value(diet->cnt))
  PLAN (d
   WHERE ( $ML_TPN_OPTION IN (1, 3, 8)))
   JOIN (o
   WHERE (o.encntr_id=diet->qual[d.seq].encntr_id)
    AND o.template_order_flag != 2
    AND o.active_ind=1
    AND parser(ms_order_p)
    AND o.activity_type_cd IN (mf_tube_continuous_cd, mf_infant_formula_cd, mf_infant_formula_add_cd,
   mf_tube_feeding_add_cd, mf_tube_feeding_bolus_cd,
   mf_nut_services_consult_cd, mf_supplements_cd, mf_diets_cd, mf_diet_spec_inst, mf_point_of_care_cd
   ))
  ORDER BY o.encntr_id, o.order_id
  HEAD o.encntr_id
   ml_ord_cnt = 0
  HEAD o.order_id
   IF (((o.activity_type_cd != mf_point_of_care_cd) OR (o.catalog_cd IN (mf_glucose_poc_cd,
   mf_glucose_nsg_poc_cd)
    AND ( $ML_TPN_OPTION=8))) )
    ml_ord_cnt += 1
    IF (mod(ml_ord_cnt,10)=1)
     CALL alterlist(diet->qual[d.seq].orders,(ml_ord_cnt+ 9))
    ENDIF
    diet->qual[d.seq].orders[ml_ord_cnt].order_id = o.order_id, diet->qual[d.seq].orders[ml_ord_cnt].
    activity_type_cd = o.activity_type_cd, diet->qual[d.seq].orders[ml_ord_cnt].catalog_cd = o
    .catalog_cd,
    diet->qual[d.seq].orders[ml_ord_cnt].catalog_type_cd = o.catalog_type_cd, diet->qual[d.seq].
    orders[ml_ord_cnt].order_mnemonic = o.order_mnemonic, diet->qual[d.seq].orders[ml_ord_cnt].
    clinical_display_line = o.clinical_display_line,
    diet->qual[d.seq].orders[ml_ord_cnt].order_status_cd = o.order_status_cd, diet->qual[d.seq].
    has_diet_order = 1
   ENDIF
  FOOT  o.encntr_id
   CALL alterlist(diet->qual[d.seq].orders,ml_ord_cnt), diet->qual[d.seq].order_cnt = ml_ord_cnt
  WITH nocounter
 ;end select
 CALL echo("option 4 ")
 SELECT INTO "nl:"
  FROM orders o,
   (dummyt d  WITH seq = value(diet->cnt))
  PLAN (d
   WHERE ( $ML_TPN_OPTION=4))
   JOIN (o
   WHERE (o.encntr_id=diet->qual[d.seq].encntr_id)
    AND o.template_order_flag != 2
    AND o.active_ind=1
    AND parser(ms_order_p)
    AND o.catalog_cd IN (mf_cl_diet_cd, mf_cldiet_pediadol_cd, mf_cl_no_red_color_cd, mf_cl_break_cd)
   )
  ORDER BY o.encntr_id, o.order_id
  HEAD o.encntr_id
   ml_ord_cnt = 0
  HEAD o.order_id
   ml_ord_cnt += 1
   IF (mod(ml_ord_cnt,10)=1)
    CALL alterlist(diet->qual[d.seq].orders,(ml_ord_cnt+ 9))
   ENDIF
   diet->qual[d.seq].orders[ml_ord_cnt].order_id = o.order_id, diet->qual[d.seq].orders[ml_ord_cnt].
   activity_type_cd = o.activity_type_cd, diet->qual[d.seq].orders[ml_ord_cnt].catalog_cd = o
   .catalog_cd,
   diet->qual[d.seq].orders[ml_ord_cnt].catalog_type_cd = o.catalog_type_cd, diet->qual[d.seq].
   orders[ml_ord_cnt].order_mnemonic = o.order_mnemonic, diet->qual[d.seq].orders[ml_ord_cnt].
   clinical_display_line = o.clinical_display_line,
   diet->qual[d.seq].orders[ml_ord_cnt].order_status_cd = o.order_status_cd, diet->qual[d.seq].
   has_clear_order = 1
  FOOT  o.encntr_id
   CALL alterlist(diet->qual[d.seq].orders,ml_ord_cnt), diet->qual[d.seq].order_cnt = ml_ord_cnt
  WITH nocounter
 ;end select
 CALL echo("Option 5")
 SELECT INTO "nl:"
  FROM orders o,
   (dummyt d  WITH seq = value(diet->cnt))
  PLAN (d
   WHERE ( $ML_TPN_OPTION=5))
   JOIN (o
   WHERE (o.encntr_id=diet->qual[d.seq].encntr_id)
    AND o.active_ind=1
    AND parser(ms_order_p)
    AND o.activity_type_cd IN (mf_nut_services_consult_cd, mf_supplements_cd, mf_diets_cd,
   mf_diet_spec_inst)
    AND  EXISTS (
   (SELECT
    oc.encntr_id
    FROM orders oc
    WHERE oc.encntr_id=o.encntr_id
     AND oc.catalog_cd=mf_meal_delievery_cd
     AND oc.active_ind=1
     AND parser(ms_order_p2)
     AND (( EXISTS (
    (SELECT
     od.order_id
     FROM order_detail od
     WHERE od.order_id=oc.order_id
      AND od.oe_field_meaning="OTHER"
      AND od.oe_field_display_value="Non-select Tray Service"))) OR (oc.catalog_cd=mf_non_sel_tray_cd
    )) )))
  ORDER BY o.encntr_id, o.order_id
  HEAD o.encntr_id
   ml_ord_cnt = 0
  DETAIL
   ml_ord_cnt += 1
   IF (mod(ml_ord_cnt,10)=1)
    CALL alterlist(diet->qual[d.seq].orders,(ml_ord_cnt+ 9))
   ENDIF
   diet->qual[d.seq].orders[ml_ord_cnt].order_id = o.order_id, diet->qual[d.seq].orders[ml_ord_cnt].
   activity_type_cd = o.activity_type_cd, diet->qual[d.seq].orders[ml_ord_cnt].catalog_cd = o
   .catalog_cd,
   diet->qual[d.seq].orders[ml_ord_cnt].catalog_type_cd = o.catalog_type_cd, diet->qual[d.seq].
   orders[ml_ord_cnt].order_mnemonic = o.order_mnemonic, diet->qual[d.seq].orders[ml_ord_cnt].
   clinical_display_line = o.clinical_display_line,
   diet->qual[d.seq].orders[ml_ord_cnt].order_status_cd = o.order_status_cd, diet->qual[d.seq].
   has_non_sel_try = 1
  FOOT  o.encntr_id
   CALL alterlist(diet->qual[d.seq].orders,ml_ord_cnt), diet->qual[d.seq].order_cnt = ml_ord_cnt
  WITH nocounter
 ;end select
 CALL echo("Option 6")
 SELECT INTO "nl:"
  FROM orders o,
   (dummyt d  WITH seq = value(diet->cnt))
  PLAN (d
   WHERE ( $ML_TPN_OPTION=6))
   JOIN (o
   WHERE (o.encntr_id=diet->qual[d.seq].encntr_id)
    AND o.active_ind=1
    AND parser(ms_order_p)
    AND o.activity_type_cd IN (mf_nut_services_consult_cd, mf_supplements_cd, mf_diets_cd,
   mf_diet_spec_inst)
    AND  EXISTS (
   (SELECT
    oc.encntr_id
    FROM orders oc
    WHERE oc.encntr_id=o.encntr_id
     AND oc.catalog_cd=mf_meal_delievery_cd
     AND oc.active_ind=1
     AND parser(ms_order_p2)
     AND (( EXISTS (
    (SELECT
     od.order_id
     FROM order_detail od
     WHERE od.order_id=oc.order_id
      AND od.oe_field_meaning="OTHER"
      AND od.oe_field_display_value="Assist with menu selection"))) OR (o.catalog_cd=
    mf_meal_w_assist_cd)) )))
  ORDER BY o.encntr_id, o.order_id
  HEAD o.encntr_id
   ml_ord_cnt = 0
  HEAD o.order_id
   ml_ord_cnt += 1
   IF (mod(ml_ord_cnt,10)=1)
    CALL alterlist(diet->qual[d.seq].orders,(ml_ord_cnt+ 9))
   ENDIF
   diet->qual[d.seq].orders[ml_ord_cnt].order_id = o.order_id, diet->qual[d.seq].orders[ml_ord_cnt].
   activity_type_cd = o.activity_type_cd, diet->qual[d.seq].orders[ml_ord_cnt].catalog_cd = o
   .catalog_cd,
   diet->qual[d.seq].orders[ml_ord_cnt].catalog_type_cd = o.catalog_type_cd, diet->qual[d.seq].
   orders[ml_ord_cnt].order_mnemonic = o.order_mnemonic, diet->qual[d.seq].orders[ml_ord_cnt].
   clinical_display_line = o.clinical_display_line,
   diet->qual[d.seq].orders[ml_ord_cnt].order_status_cd = o.order_status_cd, diet->qual[d.seq].
   has_w_assist = 1
  FOOT  o.encntr_id
   CALL alterlist(diet->qual[d.seq].orders,ml_ord_cnt), diet->qual[d.seq].order_cnt = ml_ord_cnt
  WITH nocounter
 ;end select
 CALL echo("Options 1, 2, 8")
 SELECT INTO "nl:"
  FROM orders o,
   order_ingredient oi,
   (dummyt d  WITH seq = value(diet->cnt))
  PLAN (d
   WHERE ( $ML_TPN_OPTION IN (1, 2, 8)))
   JOIN (o
   WHERE (o.encntr_id=diet->qual[d.seq].encntr_id)
    AND o.template_order_flag != 2
    AND o.active_ind=1
    AND parser(ms_order_p)
    AND o.activity_type_cd=mf_pharm_act_type_cd
    AND o.order_mnemonic="TPN*")
   JOIN (oi
   WHERE oi.order_id=o.order_id
    AND oi.ingredient_type_flag=3
    AND oi.action_sequence=o.last_action_sequence)
  ORDER BY o.encntr_id, o.order_id, oi.comp_sequence
  HEAD o.order_id
   diet->qual[d.seq].order_cnt += 1, ml_ord_cnt = diet->qual[d.seq].order_cnt,
   CALL alterlist(diet->qual[d.seq].orders,ml_ord_cnt),
   diet->qual[d.seq].orders[ml_ord_cnt].order_id = o.order_id, diet->qual[d.seq].orders[ml_ord_cnt].
   activity_type_cd = o.activity_type_cd, diet->qual[d.seq].orders[ml_ord_cnt].catalog_cd = o
   .catalog_cd,
   diet->qual[d.seq].orders[ml_ord_cnt].catalog_type_cd = o.catalog_type_cd, diet->qual[d.seq].
   orders[ml_ord_cnt].order_mnemonic = o.order_mnemonic, diet->qual[d.seq].orders[ml_ord_cnt].
   clinical_display_line = o.clinical_display_line,
   diet->qual[d.seq].orders[ml_ord_cnt].order_status_cd = o.order_status_cd, diet->qual[d.seq].
   has_tpn_order = 1, ml_ing_cnt = 0
  DETAIL
   ml_ing_cnt += 1
   IF (mod(ml_ing_cnt,10)=1)
    CALL alterlist(diet->qual[d.seq].orders[ml_ord_cnt].ingredients,(ml_ing_cnt+ 9))
   ENDIF
   diet->qual[d.seq].orders[ml_ord_cnt].ingredients[ml_ing_cnt].component_seq = oi.comp_sequence,
   diet->qual[d.seq].orders[ml_ord_cnt].ingredients[ml_ing_cnt].order_mnemonic = oi.order_mnemonic,
   diet->qual[d.seq].orders[ml_ord_cnt].ingredients[ml_ing_cnt].hna_order_mnemonic = oi
   .hna_order_mnemonic,
   diet->qual[d.seq].orders[ml_ord_cnt].ingredients[ml_ing_cnt].ordered_as_mnemonic = oi
   .ordered_as_mnemonic, diet->qual[d.seq].orders[ml_ord_cnt].ingredients[ml_ing_cnt].
   order_detail_display_line = oi.order_detail_display_line
  FOOT  o.order_id
   CALL alterlist(diet->qual[d.seq].orders[ml_ord_cnt].ingredients,ml_ing_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(diet->cnt)),
   orders o,
   order_detail od
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=diet->qual[d.seq].encntr_id)
    AND o.catalog_cd=mf_cs200_isolation_cd
    AND o.order_status_cd=mf_cs6004_ordered_cd
    AND o.active_ind=1)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_meaning="ISOLATIONCODE")
  ORDER BY o.encntr_id, o.order_id, od.action_sequence DESC
  HEAD o.order_id
   IF (od.oe_field_value=mf_cs70_neutropenic_cd)
    diet->qual[d.seq].order_cnt += 1, ml_ord_cnt = diet->qual[d.seq].order_cnt,
    CALL alterlist(diet->qual[d.seq].orders,ml_ord_cnt),
    diet->qual[d.seq].orders[ml_ord_cnt].order_id = o.order_id, diet->qual[d.seq].orders[ml_ord_cnt].
    activity_type_cd = o.activity_type_cd, diet->qual[d.seq].orders[ml_ord_cnt].catalog_cd = o
    .catalog_cd,
    diet->qual[d.seq].orders[ml_ord_cnt].catalog_type_cd = o.catalog_type_cd, diet->qual[d.seq].
    orders[ml_ord_cnt].order_mnemonic = o.order_mnemonic, diet->qual[d.seq].orders[ml_ord_cnt].
    clinical_display_line = o.clinical_display_line,
    diet->qual[d.seq].orders[ml_ord_cnt].order_status_cd = o.order_status_cd, diet->qual[d.seq].
    has_isolation_order = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("For loop")
 SET ml_cmt_cnt = 0
 FOR (i = 1 TO diet->cnt)
   FOR (j = 1 TO diet->qual[i].order_cnt)
     SET ml_cmt_cnt += 1
     IF (mod(ml_cmt_cnt,100)=1)
      CALL alterlist(cmts->qual,(ml_cmt_cnt+ 99))
     ENDIF
     SET cmts->qual[ml_cmt_cnt].index1 = i
     SET cmts->qual[ml_cmt_cnt].index2 = j
     SET cmts->qual[ml_cmt_cnt].order_id = diet->qual[i].orders[j].order_id
   ENDFOR
 ENDFOR
 CALL alterlist(cmts->qual,ml_cmt_cnt)
 CALL echo("Extract the comments, and place them where they belong")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(ml_cmt_cnt)),
   order_comment oc,
   long_text lt
  PLAN (d)
   JOIN (oc
   WHERE (oc.order_id=cmts->qual[d.seq].order_id))
   JOIN (lt
   WHERE lt.long_text_id=oc.long_text_id)
  DETAIL
   ml_idx = (size(diet->qual[cmts->qual[d.seq].index1].orders[cmts->qual[d.seq].index2].comments,5)+
   1),
   CALL alterlist(diet->qual[cmts->qual[d.seq].index1].orders[cmts->qual[d.seq].index2].comments,
   ml_idx), diet->qual[cmts->qual[d.seq].index1].orders[cmts->qual[d.seq].index2].comments[ml_idx].
   order_comment = trim(lt.long_text)
  WITH nocounter
 ;end select
 IF (size(diet->qual,5) > 0)
  CALL echo("Select FIN, MRN")
  SELECT INTO "nl:"
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
     diet->qual[d.seq].fmrn = trim(ea.alias)
    ELSE
     diet->qual[d.seq].acct_num = trim(ea.alias)
    ENDIF
   WITH nocounter
  ;end select
  CALL echo("Display to the screen")
  SELECT INTO value(ms_output)
   encntr_id = diet->qual[d.seq].encntr_id, loc_facility = substring(1,30,uar_get_code_display(diet->
     qual[d.seq].loc_facility_cd)), loc_nurse_unit = substring(1,30,uar_get_code_display(diet->qual[d
     .seq].loc_nurse_unit_cd)),
   loc_room = substring(1,5,uar_get_code_display(diet->qual[d.seq].loc_room_cd)), loc_bed = substring
   (1,5,uar_get_code_display(diet->qual[d.seq].loc_bed_cd)), room_and_bed = build(trim(
     uar_get_code_display(diet->qual[d.seq].loc_room_cd)),"/",trim(uar_get_code_display(diet->qual[d
      .seq].loc_bed_cd))),
   enc_type_disp = substring(1,20,uar_get_code_display(diet->qual[d.seq].encntr_type_cd)),
   patient_name = substring(1,30,diet->qual[d.seq].name_full_formatted), fmrn = diet->qual[d.seq].
   fmrn,
   acct_num = diet->qual[d.seq].acct_num
   FROM (dummyt d  WITH seq = value(diet->cnt))
   PLAN (d
    WHERE ((( $ML_TPN_OPTION=1)
     AND (((diet->qual[d.seq].has_tpn_order=1)) OR ((diet->qual[d.seq].has_diet_order=1))) ) OR ((((
     $ML_TPN_OPTION=2)
     AND (diet->qual[d.seq].has_tpn_order=1)) OR (((( $ML_TPN_OPTION=3)
     AND (diet->qual[d.seq].has_diet_order=1)) OR (((( $ML_TPN_OPTION=4)
     AND (diet->qual[d.seq].has_clear_order=1)) OR (((( $ML_TPN_OPTION=5)
     AND (diet->qual[d.seq].has_non_sel_try=1)) OR (((( $ML_TPN_OPTION=6)
     AND (diet->qual[d.seq].has_w_assist=1)) OR (((( $ML_TPN_OPTION=8)
     AND (((diet->qual[d.seq].has_tpn_order=1)) OR ((diet->qual[d.seq].has_diet_order=1))) ) OR ((
    diet->qual[d.seq].has_isolation_order=1))) )) )) )) )) )) )) )
   ORDER BY loc_facility, loc_nurse_unit, loc_room,
    loc_bed
   HEAD REPORT
    event_len = 0, date_len = 0, line = fillstring(120,"="),
    line2 = fillstring(120,"*"), xcol = 0, ycol = 0,
    temp1 = fillstring(500,""), temp2 = fillstring(500,""), sord_cnt = 0,
    pord_cnt = 0, cord_cnt = 0, breakflag = 0,
    xcolvar = 0, wrapcol = 0, boldflag = 0,
    underflag = 0, leftindentsize = 0,
    MACRO (rowplusone)
     ycol += 10, row + 1
     IF (ycol > 710)
      BREAK
     ENDIF
    ENDMACRO
    ,
    MACRO (rowplusone2)
     ycol += 10, row + 1
    ENDMACRO
    ,
    MACRO (line_wrap)
     limit = 0, maxlen = wrapcol, cr = char(10),
     initialloop = 1
     WHILE (ms_temp > " "
      AND limit < 1000)
       ii = 0, limit += 1, pos = 0,
       ms_temp = trim(ms_temp,2)
       WHILE (pos=0)
        ii += 1,
        IF (substring((maxlen - ii),1,ms_temp) IN (" ", ",", cr))
         pos = (maxlen - ii)
        ELSEIF (ii=maxlen)
         pos = maxlen
        ENDIF
       ENDWHILE
       printstring = substring(1,pos,ms_temp)
       IF (boldflag=1)
        printstring = concat("{B}",printstring,"{ENDB}")
       ENDIF
       IF (underflag=1)
        printstring = concat("{U}",printstring,"{ENDU}")
       ENDIF
       CALL print(calcpos(xcol,ycol)), printstring
       IF (limit=1)
        maxlen -= 5
       ENDIF
       IF (breakflag=1)
        rowplusone
       ELSE
        rowplusone2
       ENDIF
       ms_temp = substring((pos+ 1),size(ms_temp),ms_temp)
       IF (initialloop=1)
        xcol += leftindentsize, initialloop = 0
       ENDIF
     ENDWHILE
    ENDMACRO
   HEAD PAGE
    "{cpi/10}", row + 1, ycol = 30,
    CALL print(calcpos(0,ycol)), "{CENTER/Baystate Health System/8/5}", row + 1,
    ycol += 15,
    CALL print(calcpos(0,ycol)), "{CENTER/Dietary Master Report/8/5}",
    row + 1, "{cpi/14}", row + 1,
    xcol = 30, ycol += 20,
    CALL print(calcpos(xcol,ycol)),
    "Run Time: ", curdate, " ",
    curtime, row + 1, ycol += 10,
    CALL print(calcpos(xcol,ycol)), "Facility: ", loc_facility,
    row + 1, ycol += 10,
    CALL print(calcpos(xcol,ycol)),
    "Nurse Unit: ", loc_nurse_unit, row + 1,
    ycol += 10
   HEAD loc_nurse_unit
    row + 0
   HEAD loc_bed
    row + 0
   HEAD encntr_id
    IF (ycol > 700)
     temp1 = concat("Page: ",cnvtstring(curpage)),
     CALL print(calcpos(75,760)), "{B}",
     temp1, "{ENDB}", row + 1,
     BREAK
    ENDIF
    CALL print(calcpos(50,ycol)), room_and_bed, row + 1,
    CALL print(calcpos(100,ycol)), patient_name, row + 1,
    CALL print(calcpos(350,ycol)), fmrn, row + 1,
    CALL print(calcpos(400,ycol)), acct_num, row + 1,
    CALL print(calcpos(460,ycol)), enc_type_disp, row + 1,
    ycol += 10
    IF ((diet->qual[d.seq].allergy_cnt > 0))
     ms_temp = concat("Allergies: ",trim(diet->qual[d.seq].allergies[1].source_string))
     FOR (i = 2 TO diet->qual[d.seq].allergy_cnt)
       ms_temp = concat(ms_temp,", ",trim(diet->qual[d.seq].allergies[i].source_string))
     ENDFOR
     xcol = 50, wrapcol = 110, boldflag = 1,
     line_wrap, boldflag = 0
    ENDIF
    IF ((diet->qual[d.seq].order_cnt > 0))
     FOR (i = 1 TO diet->qual[d.seq].order_cnt)
       IF (ycol > 700)
        temp1 = concat("Page: ",cnvtstring(curpage)),
        CALL print(calcpos(75,760)), "{B}",
        temp1, "{ENDB}", row + 1,
        BREAK
       ENDIF
       IF (cnvtupper(diet->qual[d.seq].orders[i].hna_order_as2)="BREAST MILK FOR PPID")
        ms_temp = substring(1,500,trim(concat(trim(diet->qual[d.seq].orders[i].order_mnemonic)," ",
           trim(diet->qual[d.seq].orders[i].clinical_display_line)," (",trim(uar_get_code_display(
             diet->qual[d.seq].orders[i].order_status_cd)),
           ")"," Ordered ",diet->qual[d.seq].orders[i].hna_order_as2)))
       ELSE
        ms_temp = substring(1,500,trim(concat(trim(diet->qual[d.seq].orders[i].order_mnemonic)," ",
           trim(diet->qual[d.seq].orders[i].clinical_display_line)," (",trim(uar_get_code_display(
             diet->qual[d.seq].orders[i].order_status_cd)),
           ")")))
       ENDIF
       xcol = 75, wrapcol = 95, leftindentsize = 10,
       line_wrap, leftindentsize = 0
       IF (size(diet->qual[d.seq].orders[i].ingredients,5) > 0)
        CALL print(calcpos(75,ycol)), "{B}Order Ingredients: {ENDB}", row + 1,
        ycol += 10
       ENDIF
       FOR (j = 1 TO size(diet->qual[d.seq].orders[i].ingredients,5))
         IF (ycol > 700)
          temp1 = concat("Page: ",cnvtstring(curpage)),
          CALL print(calcpos(75,760)), "{B}",
          temp1, "{ENDB}", row + 1,
          BREAK
         ENDIF
         beg_ycol = ycol, ms_temp = concat(trim(diet->qual[d.seq].orders[i].ingredients[j].
           hna_order_mnemonic)," (",trim(diet->qual[d.seq].orders[i].ingredients[j].
           ordered_as_mnemonic),")"), xcol = 85,
         wrapcol = 53, leftindentsize = 5, line_wrap,
         leftindentsize = 0, end_ycol = ycol, ycol = beg_ycol,
         ms_temp = trim(diet->qual[d.seq].orders[i].ingredients[j].order_detail_display_line), xcol
          = 350, wrapcol = 50,
         leftindentsize = 5, line_wrap, leftindentsize = 0
         IF (end_ycol > ycol)
          ycol = end_ycol
         ENDIF
       ENDFOR
       FOR (k = 1 TO size(diet->qual[d.seq].orders[i].comments,5))
         IF ((diet->qual[d.seq].orders[i].comments[k].order_comment > " "))
          CALL print(calcpos(75,ycol)), "{B}Order Comment: {ENDB}", row + 1,
          ms_temp = diet->qual[d.seq].orders[i].comments[k].order_comment, xcol = 150, wrapcol = 80,
          leftindentsize = 0, line_wrap
         ENDIF
       ENDFOR
       ycol += 5
     ENDFOR
    ENDIF
   FOOT  encntr_id
    ycol += 5
   FOOT  loc_nurse_unit
    IF ( NOT (curendreport))
     temp1 = concat("Page: ",cnvtstring(curpage)),
     CALL print(calcpos(75,760)), "{B}",
     temp1, "{ENDB}", row + 1,
     BREAK
    ELSE
     temp1 = concat("Page: ",trim(cnvtstring(curpage),3)),
     CALL print(calcpos(75,760)), "{B}",
     temp1, row + 1,
     CALL print(calcpos(250,760)),
     "{B}End Report{ENDB}", row + 1
    ENDIF
   WITH dio = postscript, maxrow = 10000, maxcol = 1000
  ;end select
 ELSE
  CALL echo("No Data found for Selected Units in Output Select Query")
  SET ms_status = "ERROR"
  SET ms_error = build2("No Dietary orders found at ",trim(uar_get_code_display(cnvtreal(
       $MF_NURSE_UNIT)))," nurse unit under ",trim(uar_get_code_display(cnvtreal( $MF_FACILITY))),
   " facility.")
  GO TO exit_script
 ENDIF
 IF (ms_status != "ERROR")
  SET ms_status = "SUCCESS"
 ENDIF
#exit_script
 IF (ms_status != "SUCCESS")
  CALL echo("Display Errors")
  SELECT INTO value(ms_output)
   FROM dummyt
   HEAD REPORT
    col 0, "{PS/792 0}", row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(10,10)), ms_error_head,
    row + 2, "{F/1}{CPI/12}",
    CALL print(calcpos(14,25)),
    ms_error
   WITH dio = postscript, time = 5
  ;end select
 ENDIF
 IF (ml_operation=1)
  CALL echo(build2("ms_output: ",ms_output))
  CALL echo(build2("outdev: ", $OUTDEV))
  SET spool value(ms_output) value( $OUTDEV) WITH nodeleted
  CALL echo(build2("outdev2: ", $OUTDEV2))
  SET spool value(ms_output) value( $OUTDEV2) WITH deleted
  SET reply->status_data[1].status = "S"
 ENDIF
END GO
