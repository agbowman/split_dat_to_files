CREATE PROGRAM afc_call_pbm:dba
 DECLARE afc_call_pbm_version = vc WITH constant("323720.FT.007")
 RECORD temp_encntr_request(
   1 encntr_id = f8
 )
 RECORD temp_encntr_reply(
   1 person_encounter_qual = i2
   1 person_encounter[*]
     2 person_name = vc
     2 person_id = f8
     2 mrn = vc
     2 fin = vc
     2 dob = dq8
     2 age = vc
     2 sex_cd = f8
     2 sex_disp = c40
     2 sex_desc = c60
     2 sex_mean = c12
     2 location_cd = f8
     2 location_disp = c40
     2 location_desc = c60
     2 location_mean = c12
     2 room_cd = f8
     2 room_disp = c40
     2 room_desc = c60
     2 room_mean = c12
     2 bed_cd = f8
     2 bed_disp = c40
     2 bed_desc = c60
     2 bed_mean = c12
     2 attending_physician = vc
     2 physician_id = f8
     2 admitting_physician = vc
     2 admit_phys_id = f8
     2 admit_type_cd = f8
     2 registration_dt_tm = dq8
     2 discharge_dt_tm = dq8
     2 encntr_type_cd = f8
     2 encntr_type_disp = c40
     2 encntr_type_desc = c60
     2 encntr_type_mean = c12
     2 ssn = vc
     2 person_mrn = vc
     2 person_community_mrn = vc
     2 organization_id = f8
     2 loc_nurse_unit_cd = f8
     2 loc_facility_cd = f8
     2 loc_building_cd = f8
     2 health_plan_id = f8
     2 primary_health_plan = vc
     2 financial_class_cd = f8
     2 financial_class_disp = c40
     2 financial_class_desc = c60
     2 financial_class_mean = c12
     2 ref_phys_id = f8
     2 referring_physician = vc
     2 ord_phys_id = f8
     2 ordering_physician = vc
     2 ren_phys_id = f8
     2 rendering_physician = vc
     2 perf_loc_cd = f8
     2 perf_loc_disp = c40
     2 perf_loc_desc = c60
     2 perf_loc_mean = c12
     2 secondary_health_plan_id = f8
     2 secondary_health_plan = vc
     2 deduct_amt = f8
     2 program_service_cd = f8
     2 birth_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD pbm_request(
   1 qual[*]
     2 param_name = vc
     2 param_value = vc
 )
 RECORD pbm_reply(
   1 qual[*]
     2 param_name = vc
     2 param_value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD afc_chk_profit_install_reply(
   1 profit_installed = i2
 )
 DECLARE temp_ext_price = f8
 DECLARE new_charge_quant = i4
 DECLARE syear = vc WITH noconstant("")
 DECLARE smonth = vc WITH noconstant("")
 DECLARE sday = vc WITH noconstant("")
 DECLARE shour = vc WITH noconstant("")
 DECLARE sminutes = vc WITH noconstant("")
 DECLARE sseconds = vc WITH noconstant("")
 DECLARE promptcd = f8
 SET code_set = 13019
 SET cdf_meaning = "PROMPT"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,promptcd)
 DECLARE tempdocdate = vc WITH noconstant("")
 SET temp_encntr_request->encntr_id = reply->charges[1].encntr_id
 EXECUTE afc_chk_profit_install  WITH replace("REPLY",afc_chk_profit_install_reply)
 IF ((afc_chk_profit_install_reply->profit_installed=0))
  GO TO end_program
 ENDIF
 EXECUTE afc_get_person_encounter_info  WITH replace("REQUEST",temp_encntr_request), replace("REPLY",
  temp_encntr_reply)
 SET i = 0
 IF ((temp_encntr_reply->person_encounter[1].loc_facility_cd > 0))
  SET i += 1
  SET stat = alterlist(pbm_request->qual,i)
  SET pbm_request->qual[i].param_name = "FACILITY_CD"
  SET pbm_request->qual[i].param_value = cnvtstring(temp_encntr_reply->person_encounter[1].
   loc_facility_cd,17,2)
 ENDIF
 IF ((reply->charges[1].bill_item_id > 0))
  SET i += 1
  SET stat = alterlist(pbm_request->qual,i)
  SET pbm_request->qual[i].param_name = "BILL_ITEM_ID"
  SET pbm_request->qual[i].param_value = cnvtstring(reply->charges[1].bill_item_id,17,2)
 ENDIF
 IF ((reply->charges[1].health_plan_id > 0))
  SET i += 1
  SET stat = alterlist(pbm_request->qual,i)
  SET pbm_request->qual[i].param_name = "HEALTH_PLAN_ID"
  SET pbm_request->qual[i].param_value = cnvtstring(reply->charges[1].health_plan_id,17,2)
 ENDIF
 IF ((reply->charges[1].activity_type_cd > 0))
  SET i += 1
  SET stat = alterlist(pbm_request->qual,i)
  SET pbm_request->qual[i].param_name = "ACTIVITY_TYPE"
  SET pbm_request->qual[i].param_value = cnvtstring(reply->charges[1].activity_type_cd,17,2)
 ENDIF
 IF ((temp_encntr_reply->person_encounter[1].encntr_type_cd > 0))
  SET i += 1
  SET stat = alterlist(pbm_request->qual,i)
  SET pbm_request->qual[i].param_name = "ENCNTR_TYPE"
  SET pbm_request->qual[i].param_value = cnvtstring(temp_encntr_reply->person_encounter[1].
   encntr_type_cd,17,2)
 ENDIF
 IF ((temp_encntr_reply->person_encounter[1].financial_class_cd > 0))
  SET i += 1
  SET stat = alterlist(pbm_request->qual,i)
  SET pbm_request->qual[i].param_name = "FIN_CLASS"
  SET pbm_request->qual[i].param_value = cnvtstring(temp_encntr_reply->person_encounter[1].
   financial_class_cd,17,2)
 ENDIF
 IF ((temp_encntr_reply->person_encounter[1].program_service_cd > 0))
  SET i += 1
  SET stat = alterlist(pbm_request->qual,i)
  SET pbm_request->qual[i].param_name = "PROGRAM_SERVICE"
  SET pbm_request->qual[i].param_value = cnvtstring(temp_encntr_reply->person_encounter[1].
   program_service_cd,17,2)
 ENDIF
 IF ((temp_encntr_reply->person_encounter[1].secondary_health_plan_id > 0))
  SET i += 1
  SET stat = alterlist(pbm_request->qual,i)
  SET pbm_request->qual[i].param_name = "SECONDARY_HEALTH_PLAN_ID"
  SET pbm_request->qual[i].param_value = cnvtstring(temp_encntr_reply->person_encounter[1].
   secondary_health_plan_id,17,2)
 ENDIF
 IF ((temp_encntr_reply->person_encounter[1].deduct_amt > 0))
  SET i += 1
  SET stat = alterlist(pbm_request->qual,i)
  SET pbm_request->qual[i].param_name = "MONTHLY_SOC"
  SET pbm_request->qual[i].param_value = cnvtstring(temp_encntr_reply->person_encounter[1].deduct_amt,
   17,2)
 ENDIF
 IF ((temp_encntr_reply->person_encounter[1].loc_nurse_unit_cd > 0))
  SET i += 1
  SET stat = alterlist(pbm_request->qual,i)
  SET pbm_request->qual[i].param_name = "LOC_NURSE_UNIT_CD"
  SET pbm_request->qual[i].param_value = cnvtstring(temp_encntr_reply->person_encounter[1].
   loc_nurse_unit_cd,17,2)
 ENDIF
 IF ((temp_encntr_reply->person_encounter[1].loc_building_cd > 0))
  SET i += 1
  SET stat = alterlist(pbm_request->qual,i)
  SET pbm_request->qual[i].param_name = "LOC_BUILDING_CD"
  SET pbm_request->qual[i].param_value = cnvtstring(temp_encntr_reply->person_encounter[1].
   loc_building_cd,17,2)
 ENDIF
 IF ((reply->charges[1].service_dt_tm != 0))
  SET i += 1
  SET stat = alterlist(pbm_request->qual,i)
  SET pbm_request->qual[i].param_name = "SERVICE_DT_TM"
  SET pbm_request->qual[i].param_value = cnvtstring(cnvtdatetime(reply->charges[1].service_dt_tm))
 ENDIF
 IF ((reply->charges[1].item_quantity > 0))
  SET i += 1
  SET stat = alterlist(pbm_request->qual,i)
  SET pbm_request->qual[i].param_name = "QUANTITY"
  SET pbm_request->qual[i].param_value = cnvtstring(reply->charges[1].item_quantity)
 ENDIF
 FOR (j = 1 TO size(reply->charges[1].mods.charge_mods,5))
   IF ((reply->charges[1].mods.charge_mods[j].charge_mod_type_cd=promptcd))
    SET tempmeaning = uar_get_code_meaning(reply->charges[1].mods.charge_mods[j].field1_id)
    SET i += 1
    SET stat = alterlist(pbm_request->qual,i)
    IF (tempmeaning="DOCDATE")
     SET tempdocdate = reply->charges[1].mods.charge_mods[j].field6
     SET pbm_request->qual[i].param_name = cnvtstring(reply->charges[1].mods.charge_mods[j].field1_id,
      17,2)
     SET syear = substring(1,4,tempdocdate)
     SET smonth = substring(5,2,tempdocdate)
     SET sday = substring(7,2,tempdocdate)
     SET shour = substring(9,2,tempdocdate)
     SET sminutes = substring(11,2,tempdocdate)
     SET pbm_request->qual[i].param_value = cnvtstring(cnvtdatetime(cnvtdate2(build(smonth,sday,syear
         ),"MMDDYYYY"),cnvtint(build(shour,sminutes))))
    ELSE
     SET pbm_request->qual[i].param_name = cnvtstring(reply->charges[1].mods.charge_mods[j].field1_id,
      17,2)
     SET pbm_request->qual[i].param_value = cnvtstring(reply->charges[1].mods.charge_mods[j].
      field2_id,17,2)
    ENDIF
   ENDIF
 ENDFOR
 EXECUTE pft_pbm_charge_event  WITH replace("REQUEST",pbm_request), replace("REPLY",pbm_reply)
 SET new_charge_quant = 0
 FOR (j = 1 TO size(pbm_reply->qual,5))
   IF ((pbm_reply->qual[j].param_name="QUANTITY"))
    SET reply->charges[1].item_quantity = cnvtreal(pbm_reply->qual[j].param_value)
    SET temp_ext_price = (cnvtreal(pbm_reply->qual[j].param_value) * reply->charges[1].item_price)
    SET reply->charges[1].item_extended_price = temp_ext_price
   ELSEIF ((pbm_reply->qual[j].param_name="BILL_ITEM_ID"))
    SET stat = alterlist(reply->charges,2)
    SET reply->charges[2].charge_item_id = reply->charges[1].charge_item_id
    SET reply->charges[2].charge_act_id = reply->charges[1].charge_act_id
    SET reply->charges[2].charge_event_id = reply->charges[1].charge_event_id
    SET reply->charges[2].bill_item_id = reply->charges[1].bill_item_id
    SET reply->charges[2].charge_description = reply->charges[1].charge_description
    SET reply->charges[2].price_sched_id = reply->charges[1].price_sched_id
    SET reply->charges[2].payor_id = reply->charges[1].payor_id
    SET reply->charges[2].item_quantity = reply->charges[1].item_quantity
    SET reply->charges[2].item_price = reply->charges[1].item_price
    SET reply->charges[2].item_extended_price = reply->charges[1].item_extended_price
    SET reply->charges[2].charge_type_cd = reply->charges[1].charge_type_cd
    SET reply->charges[2].suspense_rsn_cd = reply->charges[1].suspense_rsn_cd
    SET reply->charges[2].reason_comment = reply->charges[1].reason_comment
    SET reply->charges[2].posted_cd = reply->charges[1].posted_cd
    SET reply->charges[2].ord_phys_id = reply->charges[1].ord_phys_id
    SET reply->charges[2].perf_phys_id = reply->charges[1].perf_phys_id
    SET reply->charges[2].order_id = reply->charges[1].order_id
    SET reply->charges[2].beg_effective_dt_tm = reply->charges[1].beg_effective_dt_tm
    SET reply->charges[2].person_id = reply->charges[1].person_id
    SET reply->charges[2].encntr_id = reply->charges[1].encntr_id
    SET reply->charges[2].admit_type_cd = reply->charges[1].admit_type_cd
    SET reply->charges[2].med_service_cd = reply->charges[1].med_service_cd
    SET reply->charges[2].institution_cd = reply->charges[1].institution_cd
    SET reply->charges[2].department_cd = reply->charges[1].department_cd
    SET reply->charges[2].section_cd = reply->charges[1].section_cd
    SET reply->charges[2].subsection_cd = reply->charges[1].subsection_cd
    SET reply->charges[2].level5_cd = reply->charges[1].level5_cd
    SET reply->charges[2].service_dt_tm = reply->charges[1].service_dt_tm
    SET reply->charges[2].process_flg = reply->charges[1].process_flg
    SET reply->charges[2].parent_charge_item_id = reply->charges[1].parent_charge_item_id
    SET reply->charges[2].interface_id = reply->charges[1].interface_id
    SET reply->charges[2].tier_group_cd = reply->charges[1].tier_group_cd
    SET reply->charges[2].def_bill_item_id = reply->charges[1].def_bill_item_id
    SET reply->charges[2].verify_phys_id = reply->charges[1].verify_phys_id
    SET reply->charges[2].gross_price = reply->charges[1].gross_price
    SET reply->charges[2].discount_amount = reply->charges[1].discount_amount
    SET reply->charges[2].activity_type_cd = reply->charges[1].activity_type_cd
    SET reply->charges[2].research_acct_id = reply->charges[1].research_acct_id
    SET reply->charges[2].cost_center_cd = reply->charges[1].cost_center_cd
    SET reply->charges[2].abn_status_cd = reply->charges[1].abn_status_cd
    SET reply->charges[2].perf_loc_cd = reply->charges[1].perf_loc_cd
    SET reply->charges[2].inst_fin_nbr = reply->charges[1].inst_fin_nbr
    SET reply->charges[2].ord_loc_cd = reply->charges[1].ord_loc_cd
    SET reply->charges[2].fin_class_cd = reply->charges[1].fin_class_cd
    SET reply->charges[2].health_plan_id = reply->charges[1].health_plan_id
    SET reply->charges[2].manual_ind = reply->charges[1].manual_ind
    SET reply->charges[2].updt_ind = reply->charges[1].updt_ind
    SET reply->charges[2].payor_type_cd = reply->charges[1].payor_type_cd
    SET reply->charges[2].item_copay = reply->charges[1].item_copay
    SET reply->charges[2].item_reimbursement = reply->charges[1].item_reimbursement
    SET reply->charges[2].posted_dt_tm = reply->charges[1].posted_dt_tm
    SET reply->charges[2].item_interval_id = reply->charges[1].item_interval_id
    SET reply->charges[2].list_price = reply->charges[1].list_price
    SET reply->charges[2].list_price_sched_id = reply->charges[1].list_price_sched_id
    SET reply->charges[2].realtime_ind = reply->charges[1].realtime_ind
    SET reply->charges[2].epsdt_ind = reply->charges[1].epsdt_ind
    SET reply->charges[2].ref_phys_id = reply->charges[1].ref_phys_id
    SET reply->charges[2].alpha_nomen_id = reply->charges[1].alpha_nomen_id
    SET reply->charges[2].server_process_flag = reply->charges[1].server_process_flag
    SET reply->charges[2].offset_charge_item_id = reply->charges[1].offset_charge_item_id
    SET reply->charges[2].patient_responsibility_flag = reply->charges[1].patient_responsibility_flag
    SET reply->charges[2].item_deductible_amt = reply->charges[1].item_deductible_amt
    SELECT INTO "nl:"
     FROM bill_item b
     WHERE b.bill_item_id=cnvtreal(pbm_reply->qual[j].param_value)
     DETAIL
      reply->charges[2].bill_item_id = b.bill_item_id, reply->charges[2].charge_description = b
      .ext_description
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM price_sched_items psi
     WHERE (psi.bill_item_id=reply->charges[2].bill_item_id)
      AND (psi.price_sched_id=reply->charges[2].price_sched_id)
      AND psi.beg_effective_dt_tm <= cnvtdatetime(reply->charges[2].service_dt_tm)
      AND psi.end_effective_dt_tm > cnvtdatetime(reply->charges[2].service_dt_tm)
      AND psi.active_ind=1
     DETAIL
      reply->charges[2].item_price = psi.price
     WITH nocounter
    ;end select
    SET reply->charges[2].item_quantity = new_charge_quant
    IF (new_charge_quant > 0)
     SET temp_ext_price = (new_charge_quant * reply->charges[2].item_price)
     SET reply->charges[2].item_extended_price = temp_ext_price
    ENDIF
    SET reply->charges[2].process_flg = 1111
    SET reply->charges[2].service_dt_tm = cnvtdatetime(cnvtdate2(substring(1,8,tempdocdate),
      "YYYYMMDD"),cnvtint(substring(9,6,tempdocdate)))
   ELSEIF ((pbm_reply->qual[j].param_name="PROMPT_CD"))
    FOR (p = 1 TO size(reply->charges[1].mods.charge_mods,5))
      IF ((reply->charges[1].mods.charge_mods[p].charge_mod_type_cd=promptcd))
       IF ((cnvtreal(pbm_reply->qual[j].param_value)=reply->charges[1].mods.charge_mods[p].field1_id)
       )
        IF (size(reply->charges,5) > 1)
         SET reply->charges[2].item_quantity = reply->charges[1].mods.charge_mods[p].field2_id
         SET temp_ext_price = (new_charge_quant * reply->charges[2].item_price)
         SET reply->charges[2].item_extended_price = temp_ext_price
        ELSE
         SET new_charge_quant = reply->charges[1].mods.charge_mods[p].field2_id
        ENDIF
        SET p = size(reply->charges[1].mods.charge_mods,5)
       ENDIF
      ENDIF
    ENDFOR
   ELSEIF ((pbm_reply->qual[j].param_name="CUSTOM_SCRIPT_NAME"))
    SET reply->charges[1].reason_comment = pbm_reply->qual[j].param_value
   ENDIF
 ENDFOR
 CALL echorecord(reply)
#end_program
 FREE SET afc_chk_profit_install_reply
END GO
