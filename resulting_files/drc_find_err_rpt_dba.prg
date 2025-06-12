CREATE PROGRAM drc_find_err_rpt:dba
 PROMPT
  "Output to File/Printer/MINE " = mine
 FREE RECORD rpt
 RECORD rpt(
   1 group[*]
     2 group_name = vc
     2 dose_range_check_id = f8
     2 grp_warn_cnt = i4
     2 warnings[*]
       3 parent_premise_id = f8
       3 type = i2
       3 group_ind = i2
       3 from_day_str = vc
       3 to_day_str = vc
       3 age_units_disp = vc
       3 age_rel_op = vc
       3 from_pma_str = vc
       3 to_pma_str = vc
       3 pma_units_disp = vc
       3 pma_rel_op = vc
       3 from_weight_str = vc
       3 to_weight_str = vc
       3 wgt_units_disp = vc
       3 wgt_rel_op = vc
       3 from_crcl_str = vc
       3 to_crcl_str = vc
       3 crcl_units_disp = vc
       3 crcl_rel_op = vc
       3 route_premise_id = f8
       3 route_disp = vc
       3 hepatic_ind = i2
       3 condition = vc
 )
 FREE RECORD rpt2
 RECORD rpt2(
   1 group[*]
     2 group_name = vc
     2 grp_warn_cnt = i4
     2 warnings[*]
       3 parent_premise_id = f8
       3 type = i2
       3 group_ind = i2
       3 from_day_str = vc
       3 to_day_str = vc
       3 age_units_disp = vc
       3 age_rel_op = vc
       3 from_pma_str = vc
       3 to_pma_str = vc
       3 pma_units_disp = vc
       3 pma_rel_op = vc
       3 from_weight_str = vc
       3 to_weight_str = vc
       3 wgt_units_disp = vc
       3 wgt_rel_op = vc
       3 from_crcl_str = vc
       3 to_crcl_str = vc
       3 crcl_units_disp = vc
       3 crcl_rel_op = vc
       3 route_premise_id = f8
       3 route_disp = vc
       3 hepatic_ind = i2
       3 condition = vc
 )
 SUBROUTINE convert_to_days(number,units_code,from_or_to)
   SET number_of_days = 0.0
   SET number_of_hrs = 0.0
   IF (units_code=years
    AND from_or_to=1
    AND number=1.0)
    SET number_of_days = 360.0
    SET number_of_hrs = (number_of_days * 24.0)
   ELSEIF (units_code=years
    AND from_or_to=1
    AND number=2.0)
    SET number_of_days = 720.0
    SET number_of_hrs = (number_of_days * 24.0)
   ELSEIF (units_code=years
    AND from_or_to=1
    AND number >= 3.0)
    SET number_of_days = round((365.0 * number),1)
    SET number_of_hrs = round(((365.0 * number) * 24.0),2)
   ELSEIF (units_code=years
    AND from_or_to=0
    AND number=1.0)
    SET number_of_days = 359.9
    SET number_of_hrs = ((360.0 * 24.0) - 0.01)
   ELSEIF (units_code=years
    AND from_or_to=0
    AND number=2.0)
    SET number_of_days = 719.9
    SET number_of_hrs = ((720.0 * 24.0) - 0.01)
   ELSEIF (units_code=years
    AND from_or_to=0
    AND number >= 3.0)
    SET number_of_days = round(((365.0 * number) - 0.1),1)
    SET number_of_hrs = round((((365.0 * number) * 24.0) - 0.01),2)
   ELSEIF (units_code=months
    AND from_or_to=1
    AND number=1.0)
    SET number_of_days = 28.0
    SET number_of_hrs = (number_of_days * 24.0)
   ELSEIF (units_code=months
    AND from_or_to=1
    AND number >= 2.0)
    SET number_of_days = round((30.0 * number),1)
    SET number_of_hrs = round(((30.0 * number) * 24.0),2)
   ELSEIF (units_code=months
    AND from_or_to=0
    AND number=1.0)
    SET number_of_days = 27.9
    SET number_of_hrs = ((28.0 * 24.0) - 0.01)
   ELSEIF (units_code=months
    AND from_or_to=0
    AND number >= 2.0)
    SET number_of_days = round(((30.0 * number) - 0.1),1)
    SET number_of_hrs = round((((30.0 * number) * 24.0) - 0.01),2)
   ELSEIF (units_code=weeks
    AND from_or_to=1)
    SET number_of_days = round((7.0 * number),1)
    SET number_of_hrs = round(((7.0 * number) * 24.0),2)
   ELSEIF (units_code=weeks
    AND from_or_to=0)
    SET number_of_days = round(((7.0 * number) - 0.1),1)
    SET number_of_hrs = round((((7.0 * number) * 24.0) - 0.01),2)
   ELSEIF (units_code=days
    AND from_or_to=1)
    SET number_of_days = round(number,1)
    SET number_of_hrs = round((number * 24.0),2)
   ELSEIF (units_code=days
    AND from_or_to=0)
    SET number_of_days = round((number - 0.1),1)
    SET number_of_hrs = round(((number * 24.0) - 0.01),2)
   ELSEIF (units_code=hours
    AND from_or_to=1)
    SET number_of_days = round((number/ 24.0),1)
    SET number_of_hrs = round(number,2)
   ELSEIF (units_code=hours
    AND from_or_to=0)
    SET number_of_days = round(((number/ 24.0) - 0.1),1)
    SET number_of_hrs = round((number - 0.01),2)
   ELSE
    SET number_of_days = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE direct_to_days(number,units_code)
  SET number_of_days = 0.0
  IF (units_code=years
   AND number=1.0)
   SET number_of_days = 360.0
  ELSEIF (units_code=years
   AND number=2.0)
   SET number_of_days = 720.0
  ELSEIF (units_code=years
   AND number >= 3.0)
   SET number_of_days = (365.0 * number)
  ELSEIF (units_code=months
   AND number=1.0)
   SET number_of_days = 28.0
  ELSEIF (units_code=months
   AND number >= 2.0)
   SET number_of_days = (30.0 * number)
  ELSEIF (units_code=weeks)
   SET number_of_days = (7.0 * number)
  ELSEIF (units_code=days)
   SET number_of_days = number
  ELSEIF (units_code=hours)
   SET number_of_days = (number/ 24.0)
  ELSE
   SET number_of_days = 0.0
  ENDIF
 END ;Subroutine
 SUBROUTINE convert_to_kgs(number,units_code,operator)
  SET number_of_kgs = 0.0
  IF (units_code=kg
   AND operator=1)
   SET number_of_kgs = round((number - 0.00001),5)
  ELSEIF (units_code=kg
   AND ((operator=3) OR (operator=4)) )
   SET number_of_kgs = round(number,5)
  ELSEIF (units_code=kg
   AND operator=2)
   SET number_of_kgs = round((number+ 0.00001),5)
  ELSEIF (units_code=gram
   AND operator=1)
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = round(((number/ 1000.0) - 0.00001),5)
   ENDIF
  ELSEIF (units_code=gram
   AND ((operator=3) OR (operator=4)) )
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = round((number/ 1000.0),5)
   ENDIF
  ELSEIF (units_code=gram
   AND operator=2)
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = round(((number/ 1000.0)+ 0.00001),5)
   ENDIF
  ELSEIF (units_code=ounce
   AND operator=1)
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = round((((number/ 16.0) * 0.4545) - 0.00001),5)
   ENDIF
  ELSEIF (units_code=ounce
   AND ((operator=3) OR (operator=4)) )
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = round(((number/ 16.0) * 0.4545),5)
   ENDIF
  ELSEIF (units_code=ounce
   AND operator=2)
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = round((((number/ 16.0) * 0.4545)+ 0.00001),5)
   ENDIF
  ELSEIF (units_code=lbs
   AND operator=1)
   SET number_of_kgs = round(((number * 0.4545) - 0.00001),5)
  ELSEIF (units_code=lbs
   AND ((operator=3) OR (operator=4)) )
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = round((number * 0.4545),5)
   ENDIF
  ELSEIF (units_code=lbs
   AND operator=2)
   SET number_of_kgs = round(((number * 0.4545)+ 0.00001),5)
  ELSE
   SET number_of_kgs = 0.0
  ENDIF
 END ;Subroutine
 SUBROUTINE direct_to_kgs(number,units_code)
  SET number_of_kgs = 0.0
  IF (units_code=kg)
   SET number_of_kgs = number
  ELSEIF (units_code=gram)
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = (number/ 1000.0)
   ENDIF
  ELSEIF (units_code=ounce)
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = ((number/ 16.0) * 0.4545)
   ENDIF
  ELSEIF (units_code=lbs)
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = (number * 0.4545)
   ENDIF
  ELSE
   SET number_of_kgs = 0.0
  ENDIF
 END ;Subroutine
 SUBROUTINE format_number(number)
   SET number_string = fillstring(255," ")
   SET number_set = false
   SET mod_value = 0.0
   SET mod_value = (number - cnvtint(number))
   IF (mod_value=0.0)
    SET number_string = trim(cnvtstring(number))
    SET number_set = true
   ELSE
    IF (mod((number * 10000),10) != 0
     AND number_set=false)
     SET number_string = trim(format(number,"##########.####"),3)
     SET number_set = true
    ELSEIF (mod((number * 1000),10) != 0
     AND number_set=false)
     SET number_string = trim(format(number,"##########.###"),3)
     SET number_set = true
    ELSEIF (mod((number * 100),10) != 0
     AND number_set=false)
     SET number_string = trim(format(number,"##########.##"),3)
     SET number_set = true
    ELSE
     SET number_string = trim(format(number,"##########.#"),3)
    ENDIF
   ENDIF
 END ;Subroutine
 RECORD reply(
   1 qual[*]
     2 dose_range_check_id = f8
     2 drc_form_reltn_id = f8
     2 reltn_build_flag = i2
     2 reltn_active_ind = i2
     2 drc_name = vc
     2 drc_content_rule_identifier = f8
     2 drc_build_flag = i2
     2 drc_active_ind = i2
     2 parent_premise[*]
       3 parent_premise_id = f8
       3 age_check_flag = i2
       3 age_text = vc
       3 weight_check_flag = i2
       3 weight_text = vc
       3 pma_check_flag = i2
       3 pma_text = vc
       3 crcl_check_flag = i2
       3 crcl_text = vc
       3 active_ind = i2
       3 premise[*]
         4 drc_premise_id = f8
         4 premise_type_flag = i2
         4 concept_cki = vc
         4 source_string = vc
         4 relational_operator_flag = i2
         4 value_unit_cd = f8
         4 value_unit_disp = c40
         4 value1 = f8
         4 value2 = f8
         4 age1_to_days = f8
         4 age2_to_days = f8
         4 sort_day_key = f8
         4 weight1_to_kgs = f8
         4 weight2_to_kgs = f8
         4 sort_weight_key = f8
         4 sort_crcl_key = f8
         4 sort_hepatic_key = f8
         4 sort_conditions_key = vc
         4 active_ind = i2
         4 premise_list[*]
           5 drc_premise_list_id = f8
           5 parent_entity_id = f8
           5 active_ind = i2
       3 dose_range[*]
         4 drc_dose_range_id = f8
         4 min_value = f8
         4 max_value = f8
         4 min_value_variance = f8
         4 max_value_variance = f8
         4 value_unit_cd = f8
         4 value_unit_disp = c40
         4 max_dose = f8
         4 max_dose_unit_cd = f8
         4 max_dose_unit_disp = c40
         4 dose_days = i4
         4 type_flag = i2
         4 long_text_id = f8
         4 long_text = vc
         4 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET doses
 RECORD doses(
   1 qual[*]
     2 parent_premise_id = f8
     2 parent_prem_index = i4
     2 single_check_ind = i2
     2 single_cnt = i4
     2 daily_check_ind = i2
     2 daily_cnt = i4
     2 dose_cnt = i4
 )
 FREE SET ranges
 RECORD ranges(
   1 rec[*]
     2 qual[*]
       3 sort_key = i4
       3 parent_premise_id = f8
       3 parent_prem_index = i4
       3 conditions = vc
       3 sort_pma_key = f8
       3 from_hr_pma = f8
       3 pma1 = vc
       3 to_hr_pma = f8
       3 pma2 = vc
       3 pma_unit = vc
       3 hepatic = i2
       3 sort_crcl_key = f8
       3 from_crcl = f8
       3 crcl1 = vc
       3 to_crcl = f8
       3 crcl2 = vc
       3 crcl_unit = vc
       3 sort_age_key = f8
       3 from_hr = f8
       3 age1 = vc
       3 to_hr = f8
       3 age2 = vc
       3 age_unit = vc
       3 sort_weight_key = f8
       3 from_weight = f8
       3 weight1 = vc
       3 to_weight = f8
       3 weight2 = vc
       3 weight_unit = vc
       3 route = f8
       3 route_prem_id = f8
       3 rel_op_flag = i2
 )
 FREE RECORD sorted_ranges
 RECORD sorted_ranges(
   1 rec[*]
     2 qual[*]
       3 sort_key = i4
       3 parent_premise_id = f8
       3 parent_prem_index = i4
       3 conditions = vc
       3 sort_pma_key = f8
       3 from_hr_pma = f8
       3 pma1 = vc
       3 to_hr_pma = f8
       3 pma2 = vc
       3 pma_unit = vc
       3 hepatic = i2
       3 sort_crcl_key = f8
       3 from_crcl = f8
       3 crcl1 = vc
       3 to_crcl = f8
       3 crcl2 = vc
       3 crcl_unit = vc
       3 sort_age_key = f8
       3 from_hr = f8
       3 age1 = vc
       3 to_hr = f8
       3 age2 = vc
       3 age_unit = vc
       3 sort_weight_key = f8
       3 from_weight = f8
       3 weight1 = vc
       3 to_weight = f8
       3 weight2 = vc
       3 weight_unit = vc
       3 route = f8
       3 route_prem_id = f8
       3 rel_op_flag = i2
 )
 DECLARE gap = i2 WITH public, constant(1)
 DECLARE overlap = i2 WITH public, constant(2)
 DECLARE iage_gap = i2 WITH public, constant(1)
 DECLARE iage_overlap = i2 WITH public, constant(2)
 DECLARE iweight_gap = i2 WITH public, constant(3)
 DECLARE iweight_overlap = i2 WITH public, constant(4)
 DECLARE icrcl_overlap = i2 WITH public, constant(5)
 DECLARE ipma_overlap = i2 WITH public, constant(6)
 DECLARE age_gap = vc WITH public, constant(concat("Age gap for ","this combination of routes."))
 DECLARE age_over = vc WITH public, constant(concat("Age overlap for ","this combination of routes.")
  )
 DECLARE age_rec = vc WITH public, constant(concat("  Possible solution: add a group ",
   "with an age range of "))
 DECLARE age_chg = vc WITH public, constant(concat("  Possible solution: change the value ","of Age")
  )
 DECLARE pma_over = vc WITH public, constant(concat("PMA overlap for ","this combination of routes.")
  )
 DECLARE pma_rec = vc WITH public, constant(concat("  Possible solution: add a group ",
   "with a PMA range of "))
 DECLARE pma_chg = vc WITH public, constant(concat("  Possible solution: change the value ","of PMA")
  )
 DECLARE crcl_over = vc WITH public, constant(concat("Crcl overlap for ",
   "this combination of routes."))
 DECLARE crcl_rec = vc WITH public, constant(concat("  Possible solution: add a group ",
   "with a crcl range of "))
 DECLARE crcl_chg = vc WITH public, constant(concat("  Possible solution: change the value ",
   "of crcl"))
 DECLARE wgt_gap = vc WITH public, constant(concat("Weight gap for ","this age range."))
 DECLARE wgt_over = vc WITH public, constant(concat("Weight overlap for ","this age range."))
 DECLARE wgt_rec = vc WITH public, constant(concat("  Possible solution: add a group ",
   "with a weight range of "))
 DECLARE wgt_chg = vc WITH public, constant(concat("  Possible solution: change the value ",
   "of Weight"))
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE number_of_days = f8 WITH public, noconstant(0.0)
 DECLARE number_of_kgs = f8 WITH public, noconstant(0.0)
 DECLARE number_of_hrs = f8 WITH public, noconstant(0.0)
 DECLARE ppcnt = i4 WITH public, noconstant(0)
 DECLARE pcnt = i4 WITH public, noconstant(0)
 DECLARE plcnt = i4 WITH public, noconstant(0)
 DECLARE sortcnt = i4 WITH public, noconstant(0)
 DECLARE qualcnt = i4 WITH public, noconstant(0)
 DECLARE pploop = i4 WITH public, noconstant(0)
 DECLARE ploop = i4 WITH public, noconstant(0)
 DECLARE sort_key = vc WITH public
 DECLARE aidx = i4 WITH public, noconstant(0)
 DECLARE bidx = i4 WITH public, noconstant(0)
 DECLARE cidx = i4 WITH public, noconstant(0)
 DECLARE par_cnt = i4 WITH public, noconstant(0)
 DECLARE chld_cnt = i4 WITH public, noconstant(0)
 DECLARE group_cnt = i4 WITH public, noconstant(0)
 DECLARE old_group_cnt = i4 WITH public, noconstant(0)
 DECLARE add = vc WITH public, noconstant("FALSE")
 DECLARE warn_cnt = i4 WITH public, noconstant(0)
 DECLARE parse_dfr = vc WITH public, noconstant(" ")
 DECLARE hours = f8 WITH public, noconstant(0.0)
 DECLARE days = f8 WITH public, noconstant(0.0)
 DECLARE weeks = f8 WITH public, noconstant(0.0)
 DECLARE months = f8 WITH public, noconstant(0.0)
 DECLARE years = f8 WITH public, noconstant(0.0)
 DECLARE kg = f8 WITH public, noconstant(0.0)
 DECLARE gram = f8 WITH public, noconstant(0.0)
 DECLARE ounce = f8 WITH public, noconstant(0.0)
 DECLARE lbs = f8 WITH public, noconstant(0.0)
 DECLARE acf = i2 WITH public, noconstant(0)
 DECLARE wcf = i2 WITH public, noconstant(0)
 DECLARE ccf = i2 WITH public, noconstant(0)
 DECLARE pcf = i2 WITH public, noconstant(0)
 SET reply->status_data.status = "F"
 SET days = uar_get_code_by_cki("CKI.CODEVALUE!8423")
 SET weeks = uar_get_code_by_cki("CKI.CODEVALUE!7994")
 SET months = uar_get_code_by_cki("CKI.CODEVALUE!7993")
 SET years = uar_get_code_by_cki("CKI.CODEVALUE!3712")
 SET hours = uar_get_code_by_cki("CKI.CODEVALUE!2743")
 SET kg = uar_get_code_by_cki("CKI.CODEVALUE!2751")
 SET gram = uar_get_code_by_cki("CKI.CODEVALUE!6123")
 SET ounce = uar_get_code_by_cki("CKI.CODEVALUE!2745")
 SET lbs = uar_get_code_by_cki("CKI.CODEVALUE!2746")
 SUBROUTINE main_query(option)
   IF (option=0)
    SET parse_dfr = "dfr.drc_group_id = request->drc_group_id"
   ELSEIF (option=1)
    SET parse_dfr = "1=1"
   ELSEIF (option=2)
    SET parse_dfr = "dfr.dose_range_check_id = request->dose_range_check_id"
   ENDIF
   SELECT INTO "nl:"
    dfr.drc_group_id, dfr.dose_range_check_id, dfr.drc_form_reltn_id,
    dfr.build_flag, dfr.active_ind, drc.dose_range_check_name,
    drc.content_rule_identifier, drc.build_flag, drc.active_ind,
    dp.drc_premise_id, dp.active_ind, dp2.drc_premise_id,
    dp2.premise_type_flag, dp2.relational_operator_flag, dp2.value_unit_cd,
    dp2.value1, dp2.value2, dp2.concept_cki,
    dp2.active_ind, dpl.drc_premise_list_id, dpl.parent_entity_id
    FROM drc_form_reltn dfr,
     dose_range_check drc,
     dummyt d,
     drc_premise dp,
     drc_premise dp2,
     drc_premise_list dpl
    PLAN (dfr
     WHERE parser(parse_dfr))
     JOIN (drc
     WHERE drc.dose_range_check_id=dfr.dose_range_check_id)
     JOIN (d)
     JOIN (dp
     WHERE dp.dose_range_check_id=drc.dose_range_check_id
      AND dp.parent_premise_id=0
      AND dp.active_ind=1)
     JOIN (dp2
     WHERE dp2.parent_premise_id=dp.drc_premise_id
      AND dp2.active_ind=1)
     JOIN (dpl
     WHERE outerjoin(dp2.drc_premise_id)=dpl.drc_premise_id
      AND dpl.active_ind=outerjoin(1))
    ORDER BY dfr.drc_group_id, dfr.dose_range_check_id, dp.drc_premise_id,
     dp2.premise_type_flag, dpl.parent_entity_id
    HEAD REPORT
     ppcnt = 0, pcnt = 0, qualcnt = 0
    HEAD dfr.dose_range_check_id
     ppcnt = 0, qualcnt = (qualcnt+ 1), stat = alterlist(reply->qual,qualcnt),
     stat = alterlist(ranges->rec,qualcnt), stat = alterlist(sorted_ranges->rec,qualcnt), reply->
     qual[qualcnt].dose_range_check_id = dfr.dose_range_check_id,
     reply->qual[qualcnt].drc_form_reltn_id = dfr.drc_form_reltn_id, reply->qual[qualcnt].
     reltn_build_flag = dfr.build_flag, reply->qual[qualcnt].reltn_active_ind = dfr.active_ind,
     reply->qual[qualcnt].drc_name = drc.dose_range_check_name, reply->qual[qualcnt].
     drc_content_rule_identifier = drc.content_rule_identifier, reply->qual[qualcnt].drc_build_flag
      = drc.build_flag,
     reply->qual[qualcnt].drc_active_ind = drc.active_ind
    HEAD dp.drc_premise_id
     IF (dp.drc_premise_id > 0.0)
      ppcnt = (ppcnt+ 1)
      IF (mod(ppcnt,10)=1)
       stat = alterlist(reply->qual[qualcnt].parent_premise,(ppcnt+ 9)), stat = alterlist(doses->qual,
        (ppcnt+ 9)), stat = alterlist(ranges->rec[qualcnt].qual,(ppcnt+ 9))
      ENDIF
      reply->qual[qualcnt].parent_premise[ppcnt].parent_premise_id = dp.drc_premise_id, reply->qual[
      qualcnt].parent_premise[ppcnt].active_ind = dp.active_ind, doses->qual[ppcnt].parent_premise_id
       = dp.drc_premise_id,
      doses->qual[ppcnt].parent_prem_index = ppcnt, ranges->rec[qualcnt].qual[ppcnt].
      parent_premise_id = dp.drc_premise_id, ranges->rec[qualcnt].qual[ppcnt].parent_prem_index =
      ppcnt,
      ranges->rec[qualcnt].qual[ppcnt].sort_key = 0, pcnt = 0, stat = alterlist(reply->qual[qualcnt].
       parent_premise[ppcnt].premise,7)
     ENDIF
    HEAD dp2.premise_type_flag
     IF (ppcnt > 0)
      pcnt = dp2.premise_type_flag
      IF (pcnt < 1)
       pcnt = 1
      ENDIF
      IF (dp2.premise_type_flag > 0)
       reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].drc_premise_id = dp2.drc_premise_id,
       reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].premise_type_flag = dp2
       .premise_type_flag, reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].
       relational_operator_flag = dp2.relational_operator_flag,
       reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].value_unit_cd = dp2.value_unit_cd,
       reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].value1 = dp2.value1, reply->qual[
       qualcnt].parent_premise[ppcnt].premise[pcnt].value2 = dp2.value2,
       reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].active_ind = dp2.active_ind
      ENDIF
      IF (dp2.premise_type_flag=1)
       ranges->rec[qualcnt].qual[ppcnt].age1 = dp2.value1_string, ranges->rec[qualcnt].qual[ppcnt].
       age2 = dp2.value2_string, ranges->rec[qualcnt].qual[ppcnt].age_unit = uar_get_code_display(dp2
        .value_unit_cd)
       CASE (dp2.relational_operator_flag)
        OF 1:
         ranges->rec[qualcnt].qual[ppcnt].from_hr = 0,
         CALL convert_to_days(dp2.value1,dp2.value_unit_cd,0)reply->qual[qualcnt].parent_premise[
         ppcnt].premise[pcnt].sort_day_key = number_of_days,
         ranges->rec[qualcnt].qual[ppcnt].sort_age_key = number_of_days,ranges->rec[qualcnt].qual[
         ppcnt].to_hr = number_of_hrs,
         CALL direct_to_days(dp2.value1,dp2.value_unit_cd)reply->qual[qualcnt].parent_premise[ppcnt].
         premise[pcnt].age1_to_days = number_of_days,reply->qual[qualcnt].parent_premise[ppcnt].
         premise[pcnt].age2_to_days = 0
        OF 4:
         CALL convert_to_days(dp2.value1,dp2.value_unit_cd,1)reply->qual[qualcnt].parent_premise[
         ppcnt].premise[pcnt].sort_day_key = number_of_days,ranges->rec[qualcnt].qual[ppcnt].
         sort_age_key = number_of_days,
         ranges->rec[qualcnt].qual[ppcnt].from_hr = number_of_hrs,
         CALL direct_to_days(dp2.value1,dp2.value_unit_cd)reply->qual[qualcnt].parent_premise[ppcnt].
         premise[pcnt].age1_to_days = number_of_days,
         CALL convert_to_days(150,years,0)reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].
         sort_day_key = (reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].sort_day_key+
         number_of_days),ranges->rec[qualcnt].qual[ppcnt].sort_age_key = (ranges->rec[qualcnt].qual[
         ppcnt].sort_age_key+ number_of_days),
         ranges->rec[qualcnt].qual[ppcnt].to_hr = number_of_hrs,reply->qual[qualcnt].parent_premise[
         ppcnt].premise[pcnt].age2_to_days = 0
        OF 6:
         CALL convert_to_days(dp2.value1,dp2.value_unit_cd,1)reply->qual[qualcnt].parent_premise[
         ppcnt].premise[pcnt].sort_day_key = number_of_days,ranges->rec[qualcnt].qual[ppcnt].
         sort_age_key = number_of_days,
         ranges->rec[qualcnt].qual[ppcnt].from_hr = number_of_hrs,
         CALL direct_to_days(dp2.value1,dp2.value_unit_cd)reply->qual[qualcnt].parent_premise[ppcnt].
         premise[pcnt].age1_to_days = number_of_days,
         CALL convert_to_days(dp2.value2,dp2.value_unit_cd,0)reply->qual[qualcnt].parent_premise[
         ppcnt].premise[pcnt].sort_day_key = (reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt
         ].sort_day_key+ number_of_days),ranges->rec[qualcnt].qual[ppcnt].sort_age_key = (ranges->
         rec[qualcnt].qual[ppcnt].sort_age_key+ number_of_days),
         ranges->rec[qualcnt].qual[ppcnt].to_hr = number_of_hrs,
         CALL direct_to_days(dp2.value2,dp2.value_unit_cd)reply->qual[qualcnt].parent_premise[ppcnt].
         premise[pcnt].age2_to_days = number_of_days
        ELSE
         CALL echo(build("Can't recognize age relational operator:",dp2.relational_operator_flag))
         CALL direct_to_days(dp2.value1,dp2.value_unit_cd)reply->qual[qualcnt].parent_premise[ppcnt].
         premise[pcnt].sort_day_key = number_of_days,
         ranges->rec[qualcnt].qual[ppcnt].sort_age_key = number_of_days,reply->qual[qualcnt].
         parent_premise[ppcnt].premise[pcnt].age1_to_days = number_of_days,reply->qual[qualcnt].
         parent_premise[ppcnt].premise[pcnt].age2_to_days = 0,
         ranges->rec[qualcnt].qual[ppcnt].rel_op_flag = 1,
         IF (dp2.value1=0.0
          AND dp2.value_unit_cd=0.0
          AND dp2.relational_operator_flag=0)
          ranges->rec[qualcnt].qual[ppcnt].rel_op_flag = 0
         ENDIF
       ENDCASE
      ELSEIF (dp2.premise_type_flag=3)
       ranges->rec[qualcnt].qual[ppcnt].weight1 = dp2.value1_string, ranges->rec[qualcnt].qual[ppcnt]
       .weight2 = dp2.value2_string, ranges->rec[qualcnt].qual[ppcnt].weight_unit =
       uar_get_code_display(dp2.value_unit_cd)
       CASE (dp2.relational_operator_flag)
        OF 1:
         ranges->rec[qualcnt].qual[ppcnt].from_weight = 0,
         CALL convert_to_kgs(dp2.value1,dp2.value_unit_cd,dp2.relational_operator_flag)reply->qual[
         qualcnt].parent_premise[ppcnt].premise[pcnt].sort_weight_key = number_of_kgs,
         ranges->rec[qualcnt].qual[ppcnt].sort_weight_key = number_of_kgs,ranges->rec[qualcnt].qual[
         ppcnt].to_weight = number_of_kgs,
         CALL direct_to_kgs(dp2.value1,dp2.value_unit_cd)reply->qual[qualcnt].parent_premise[ppcnt].
         premise[pcnt].weight1_to_kgs = number_of_kgs,reply->qual[qualcnt].parent_premise[ppcnt].
         premise[pcnt].weight2_to_kgs = 0
        OF 4:
         CALL convert_to_kgs(dp2.value1,dp2.value_unit_cd,dp2.relational_operator_flag)reply->qual[
         qualcnt].parent_premise[ppcnt].premise[pcnt].sort_weight_key = number_of_kgs,ranges->rec[
         qualcnt].qual[ppcnt].sort_weight_key = number_of_kgs,
         ranges->rec[qualcnt].qual[ppcnt].from_weight = number_of_kgs,
         CALL direct_to_kgs(dp2.value1,dp2.value_unit_cd)reply->qual[qualcnt].parent_premise[ppcnt].
         premise[pcnt].weight1_to_kgs = number_of_kgs,
         CALL convert_to_kgs(1000,kg,3)reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].
         sort_weight_key = (reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].sort_weight_key
         + number_of_kgs),ranges->rec[qualcnt].qual[ppcnt].sort_weight_key = (ranges->rec[qualcnt].
         qual[ppcnt].sort_weight_key+ number_of_kgs),
         ranges->rec[qualcnt].qual[ppcnt].to_weight = number_of_kgs,reply->qual[qualcnt].
         parent_premise[ppcnt].premise[pcnt].weight2_to_kgs = 0
        OF 6:
         CALL convert_to_kgs(dp2.value1,dp2.value_unit_cd,4)reply->qual[qualcnt].parent_premise[ppcnt
         ].premise[pcnt].sort_weight_key = number_of_kgs,ranges->rec[qualcnt].qual[ppcnt].
         sort_weight_key = number_of_kgs,
         ranges->rec[qualcnt].qual[ppcnt].from_weight = number_of_kgs,
         CALL direct_to_kgs(dp2.value1,dp2.value_unit_cd)reply->qual[qualcnt].parent_premise[ppcnt].
         premise[pcnt].weight1_to_kgs = number_of_kgs,
         CALL convert_to_kgs(dp2.value2,dp2.value_unit_cd,1)reply->qual[qualcnt].parent_premise[ppcnt
         ].premise[pcnt].sort_weight_key = (reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].
         sort_weight_key+ number_of_kgs),ranges->rec[qualcnt].qual[ppcnt].sort_weight_key = (ranges->
         rec[qualcnt].qual[ppcnt].sort_weight_key+ number_of_kgs),
         ranges->rec[qualcnt].qual[ppcnt].to_weight = number_of_kgs,
         CALL direct_to_kgs(dp2.value2,dp2.value_unit_cd)reply->qual[qualcnt].parent_premise[ppcnt].
         premise[pcnt].weight2_to_kgs = number_of_kgs
        ELSE
         CALL echo(build("Can't recognize weight relational operator:",dp2.relational_operator_flag))
         CALL direct_to_kgs(dp2.value1,dp2.value_unit_cd)reply->qual[qualcnt].parent_premise[ppcnt].
         premise[pcnt].sort_weight_key = number_of_kgs,
         ranges->rec[qualcnt].qual[ppcnt].sort_weight_key = number_of_kgs,reply->qual[qualcnt].
         parent_premise[ppcnt].premise[pcnt].weight1_to_kgs = number_of_kgs,reply->qual[qualcnt].
         parent_premise[ppcnt].premise[pcnt].weight2_to_kgs = 0,
         ranges->rec[qualcnt].qual[ppcnt].rel_op_flag = 1,
         IF (dp2.value1=0.0
          AND dp2.value_unit_cd=0.0
          AND dp2.relational_operator_flag=0)
          ranges->rec[qualcnt].qual[ppcnt].rel_op_flag = 0
         ENDIF
       ENDCASE
      ELSEIF (dp2.premise_type_flag=4)
       ranges->rec[qualcnt].qual[ppcnt].crcl1 = dp2.value1_string, ranges->rec[qualcnt].qual[ppcnt].
       crcl2 = dp2.value2_string, ranges->rec[qualcnt].qual[ppcnt].crcl_unit = uar_get_code_display(
        dp2.value_unit_cd),
       ranges->rec[qualcnt].qual[ppcnt].sort_key = (ranges->rec[qualcnt].qual[ppcnt].sort_key+ 1)
       CASE (dp2.relational_operator_flag)
        OF 1:
         ranges->rec[qualcnt].qual[ppcnt].from_crcl = 0,ranges->rec[qualcnt].qual[ppcnt].to_crcl =
         dp2.value1,reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].sort_crcl_key = dp2
         .value1,
         ranges->rec[qualcnt].qual[ppcnt].sort_crcl_key = dp2.value1
        OF 6:
         ranges->rec[qualcnt].qual[ppcnt].from_crcl = dp2.value1,ranges->rec[qualcnt].qual[ppcnt].
         to_crcl = dp2.value2,reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].sort_crcl_key
          = (dp2.value1+ dp2.value2),
         ranges->rec[qualcnt].qual[ppcnt].sort_crcl_key = (dp2.value1+ dp2.value2)
        ELSE
         CALL echo(build("Can't recognize renal relational operator:",dp2.relational_operator_flag))
         reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].sort_crcl_key = (dp2.value1+ dp2
         .value2),ranges->rec[qualcnt].qual[ppcnt].rel_op_flag = 1,
         IF (dp2.value1=0.0
          AND dp2.value_unit_cd=0.0
          AND dp2.relational_operator_flag=0)
          ranges->rec[qualcnt].qual[ppcnt].rel_op_flag = 0
         ENDIF
       ENDCASE
      ELSEIF (dp2.premise_type_flag=5)
       ranges->rec[qualcnt].qual[ppcnt].pma1 = dp2.value1_string, ranges->rec[qualcnt].qual[ppcnt].
       pma2 = dp2.value2_string, ranges->rec[qualcnt].qual[ppcnt].pma_unit = uar_get_code_display(dp2
        .value_unit_cd),
       ranges->rec[qualcnt].qual[ppcnt].sort_key = (ranges->rec[qualcnt].qual[ppcnt].sort_key+ 4)
       CASE (dp2.relational_operator_flag)
        OF 1:
         ranges->rec[qualcnt].qual[ppcnt].from_hr_pma = 0,
         CALL convert_to_days(dp2.value1,dp2.value_unit_cd,0)reply->qual[qualcnt].parent_premise[
         ppcnt].premise[pcnt].sort_day_key = number_of_days,
         ranges->rec[qualcnt].qual[ppcnt].sort_pma_key = number_of_days,ranges->rec[qualcnt].qual[
         ppcnt].to_hr_pma = number_of_hrs,
         CALL direct_to_days(dp2.value1,dp2.value_unit_cd)reply->qual[qualcnt].parent_premise[ppcnt].
         premise[pcnt].age1_to_days = number_of_days,reply->qual[qualcnt].parent_premise[ppcnt].
         premise[pcnt].age2_to_days = 0
        OF 4:
         CALL convert_to_days(dp2.value1,dp2.value_unit_cd,1)reply->qual[qualcnt].parent_premise[
         ppcnt].premise[pcnt].sort_day_key = number_of_days,ranges->rec[qualcnt].qual[ppcnt].
         sort_pma_key = number_of_days,
         ranges->rec[qualcnt].qual[ppcnt].from_hr_pma = number_of_hrs,
         CALL direct_to_days(dp2.value1,dp2.value_unit_cd)reply->qual[qualcnt].parent_premise[ppcnt].
         premise[pcnt].age1_to_days = number_of_days,
         CALL convert_to_days(150,years,0)reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].
         sort_day_key = (reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].sort_day_key+
         number_of_days),ranges->rec[qualcnt].qual[ppcnt].sort_pma_key = (ranges->rec[qualcnt].qual[
         ppcnt].sort_pma_key+ number_of_days),
         ranges->rec[qualcnt].qual[ppcnt].to_hr_pma = number_of_hrs,reply->qual[qualcnt].
         parent_premise[ppcnt].premise[pcnt].age2_to_days = 0
        OF 6:
         CALL convert_to_days(dp2.value1,dp2.value_unit_cd,1)reply->qual[qualcnt].parent_premise[
         ppcnt].premise[pcnt].sort_day_key = number_of_days,ranges->rec[qualcnt].qual[ppcnt].
         sort_pma_key = number_of_days,
         ranges->rec[qualcnt].qual[ppcnt].from_hr_pma = number_of_hrs,
         CALL direct_to_days(dp2.value1,dp2.value_unit_cd)reply->qual[qualcnt].parent_premise[ppcnt].
         premise[pcnt].age1_to_days = number_of_days,
         CALL convert_to_days(dp2.value2,dp2.value_unit_cd,0)reply->qual[qualcnt].parent_premise[
         ppcnt].premise[pcnt].sort_day_key = (reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt
         ].sort_day_key+ number_of_days),ranges->rec[qualcnt].qual[ppcnt].sort_pma_key = (ranges->
         rec[qualcnt].qual[ppcnt].sort_pma_key+ number_of_days),
         ranges->rec[qualcnt].qual[ppcnt].to_hr_pma = number_of_hrs,
         CALL direct_to_days(dp2.value2,dp2.value_unit_cd)reply->qual[qualcnt].parent_premise[ppcnt].
         premise[pcnt].age2_to_days = number_of_days
        ELSE
         CALL echo(build("Can't recognize age relational operator:",dp2.relational_operator_flag))
         CALL direct_to_days(dp2.value1,dp2.value_unit_cd)reply->qual[qualcnt].parent_premise[ppcnt].
         premise[pcnt].sort_day_key = number_of_days,
         ranges->rec[qualcnt].qual[ppcnt].sort_pma_key = number_of_days,reply->qual[qualcnt].
         parent_premise[ppcnt].premise[pcnt].age1_to_days = number_of_days,reply->qual[qualcnt].
         parent_premise[ppcnt].premise[pcnt].age2_to_days = 0,
         ranges->rec[qualcnt].qual[ppcnt].rel_op_flag = 1,
         IF (dp2.value1=0.0
          AND dp2.value_unit_cd=0.0
          AND dp2.relational_operator_flag=0)
          ranges->rec[qualcnt].qual[ppcnt].rel_op_flag = 0
         ENDIF
       ENDCASE
      ELSEIF (dp2.premise_type_flag=6)
       reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].value1 = dp2.value1
       IF ((reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].value1 > 0))
        ranges->rec[qualcnt].qual[ppcnt].sort_key = (ranges->rec[qualcnt].qual[ppcnt].sort_key+ 2),
        ranges->rec[qualcnt].qual[ppcnt].hepatic = 1, reply->qual[qualcnt].parent_premise[ppcnt].
        premise[pcnt].sort_hepatic_key = 1
       ELSE
        ranges->rec[qualcnt].qual[ppcnt].hepatic = 0, reply->qual[qualcnt].parent_premise[ppcnt].
        premise[pcnt].sort_hepatic_key = 0
       ENDIF
      ELSEIF (dp2.premise_type_flag=7)
       ranges->rec[qualcnt].qual[ppcnt].sort_key = (ranges->rec[qualcnt].qual[ppcnt].sort_key+ 8),
       reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].concept_cki = dp2.concept_cki
       IF (dp2.concept_cki > "")
        ranges->rec[qualcnt].qual[ppcnt].conditions = dp2.concept_cki
       ELSE
        ranges->rec[qualcnt].qual[ppcnt].conditions = ""
       ENDIF
      ELSEIF (dp2.premise_type_flag > 0)
       ranges->rec[qualcnt].qual[ppcnt].route = dp2.value1, ranges->rec[qualcnt].qual[ppcnt].
       route_prem_id = dp2.drc_premise_id
      ENDIF
      plcnt = 0
     ENDIF
    DETAIL
     IF (ppcnt > 0)
      IF (dp2.premise_type_flag=2
       AND dpl.drc_premise_id > 0.0
       AND dpl.parent_entity_id > 0.0)
       plcnt = (plcnt+ 1)
       IF (mod(plcnt,10)=1)
        stat = alterlist(reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].premise_list,(plcnt
         + 9))
       ENDIF
       reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].premise_list[plcnt].
       drc_premise_list_id = dpl.drc_premise_list_id, reply->qual[qualcnt].parent_premise[ppcnt].
       premise[pcnt].premise_list[plcnt].parent_entity_id = dpl.parent_entity_id, reply->qual[qualcnt
       ].parent_premise[ppcnt].premise[pcnt].premise_list[plcnt].active_ind = dpl.active_ind
       IF ((reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].value1=0.0))
        reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].value1 = (dpl.parent_entity_id/ 1000
        )
       ELSE
        reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].value1 = ((reply->qual[qualcnt].
        parent_premise[ppcnt].premise[pcnt].value1+ (dpl.parent_entity_id/ 1000)) * (22.0/ 7.0))
       ENDIF
       ranges->rec[qualcnt].qual[ppcnt].route = reply->qual[qualcnt].parent_premise[ppcnt].premise[
       pcnt].value1
      ENDIF
     ENDIF
    FOOT  dp2.premise_type_flag
     IF (ppcnt > 0)
      IF (plcnt=1)
       ranges->rec[qualcnt].qual[ppcnt].route = reply->qual[qualcnt].parent_premise[ppcnt].premise[
       pcnt].premise_list[plcnt].parent_entity_id, reply->qual[qualcnt].parent_premise[ppcnt].
       premise[pcnt].value1 = ranges->rec[qualcnt].qual[ppcnt].route
      ENDIF
      stat = alterlist(reply->qual[qualcnt].parent_premise[ppcnt].premise[pcnt].premise_list,plcnt)
     ENDIF
    FOOT  dp.drc_premise_id
     IF (ppcnt > 0)
      stat = alterlist(reply->qual[qualcnt].parent_premise[ppcnt].premise,7)
     ENDIF
    FOOT  dfr.dose_range_check_id
     IF (ppcnt > 0)
      stat = alterlist(reply->qual[qualcnt].parent_premise,ppcnt), stat = alterlist(doses->qual,ppcnt
       ), stat = alterlist(ranges->rec[qualcnt].qual,ppcnt)
     ENDIF
    WITH nocounter, outerjoin = d
   ;end select
   IF (curqual=0)
    SET failed = "T"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE sort(ranges,qualcnt)
   FOR (cnt = 1 TO qualcnt)
     IF (size(reply->qual[cnt].parent_premise,5) > 0)
      SELECT INTO "nl:"
       ranges->rec[cnt].qual[d1.seq].conditions, ranges->rec[cnt].qual[d1.seq].sort_age_key, ranges->
       rec[cnt].qual[d1.seq].from_hr,
       ranges->rec[cnt].qual[d1.seq].to_hr, ranges->rec[cnt].qual[d1.seq].sort_key, ranges->rec[cnt].
       qual[d1.seq].parent_premise_id,
       ranges->rec[cnt].qual[d1.seq].parent_prem_index, ranges->rec[cnt].qual[d1.seq].hepatic, ranges
       ->rec[cnt].qual[d1.seq].sort_pma_key,
       ranges->rec[cnt].qual[d1.seq].sort_crcl_key, ranges->rec[cnt].qual[d1.seq].sort_weight_key,
       ranges->rec[cnt].qual[d1.seq].rel_op_flag,
       ranges->rec[cnt].qual[d1.seq].route
       FROM (dummyt d1  WITH seq = value(size(reply->qual[cnt].parent_premise,5)))
       PLAN (d1)
       ORDER BY ranges->rec[cnt].qual[d1.seq].route, ranges->rec[cnt].qual[d1.seq].sort_key DESC,
        ranges->rec[cnt].qual[d1.seq].conditions,
        ranges->rec[cnt].qual[d1.seq].from_hr, ranges->rec[cnt].qual[d1.seq].to_hr, ranges->rec[cnt].
        qual[d1.seq].sort_pma_key,
        ranges->rec[cnt].qual[d1.seq].hepatic DESC, ranges->rec[cnt].qual[d1.seq].sort_pma_key,
        ranges->rec[cnt].qual[d1.seq].sort_crcl_key,
        ranges->rec[cnt].qual[d1.seq].sort_weight_key
       HEAD REPORT
        sortcnt = 0
       DETAIL
        sortcnt = (sortcnt+ 1)
        IF (mod(sortcnt,10)=1)
         stat = alterlist(sorted_ranges->rec[cnt].qual,(sortcnt+ 9))
        ENDIF
        sorted_ranges->rec[cnt].qual[sortcnt].route = ranges->rec[cnt].qual[d1.seq].route,
        sorted_ranges->rec[cnt].qual[sortcnt].route_prem_id = ranges->rec[cnt].qual[d1.seq].
        route_prem_id, sorted_ranges->rec[cnt].qual[sortcnt].sort_key = ranges->rec[cnt].qual[d1.seq]
        .sort_key,
        sorted_ranges->rec[cnt].qual[sortcnt].parent_premise_id = ranges->rec[cnt].qual[d1.seq].
        parent_premise_id, sorted_ranges->rec[cnt].qual[sortcnt].parent_prem_index = ranges->rec[cnt]
        .qual[d1.seq].parent_prem_index, sorted_ranges->rec[cnt].qual[sortcnt].conditions = ranges->
        rec[cnt].qual[d1.seq].conditions,
        sorted_ranges->rec[cnt].qual[sortcnt].sort_age_key = ranges->rec[cnt].qual[d1.seq].
        sort_age_key, sorted_ranges->rec[cnt].qual[sortcnt].from_hr = ranges->rec[cnt].qual[d1.seq].
        from_hr, sorted_ranges->rec[cnt].qual[sortcnt].age1 = ranges->rec[cnt].qual[d1.seq].age1,
        sorted_ranges->rec[cnt].qual[sortcnt].to_hr = ranges->rec[cnt].qual[d1.seq].to_hr,
        sorted_ranges->rec[cnt].qual[sortcnt].age2 = ranges->rec[cnt].qual[d1.seq].age2,
        sorted_ranges->rec[cnt].qual[sortcnt].age_unit = ranges->rec[cnt].qual[d1.seq].age_unit,
        sorted_ranges->rec[cnt].qual[sortcnt].sort_pma_key = ranges->rec[cnt].qual[d1.seq].
        sort_pma_key, sorted_ranges->rec[cnt].qual[sortcnt].from_hr_pma = ranges->rec[cnt].qual[d1
        .seq].from_hr_pma, sorted_ranges->rec[cnt].qual[sortcnt].pma1 = ranges->rec[cnt].qual[d1.seq]
        .pma1,
        sorted_ranges->rec[cnt].qual[sortcnt].to_hr_pma = ranges->rec[cnt].qual[d1.seq].to_hr_pma,
        sorted_ranges->rec[cnt].qual[sortcnt].pma2 = ranges->rec[cnt].qual[d1.seq].pma2,
        sorted_ranges->rec[cnt].qual[sortcnt].pma_unit = ranges->rec[cnt].qual[d1.seq].pma_unit,
        sorted_ranges->rec[cnt].qual[sortcnt].hepatic = ranges->rec[cnt].qual[d1.seq].hepatic,
        sorted_ranges->rec[cnt].qual[sortcnt].sort_crcl_key = ranges->rec[cnt].qual[d1.seq].
        sort_crcl_key, sorted_ranges->rec[cnt].qual[sortcnt].from_crcl = ranges->rec[cnt].qual[d1.seq
        ].from_crcl,
        sorted_ranges->rec[cnt].qual[sortcnt].crcl1 = ranges->rec[cnt].qual[d1.seq].crcl1,
        sorted_ranges->rec[cnt].qual[sortcnt].to_crcl = ranges->rec[cnt].qual[d1.seq].to_crcl,
        sorted_ranges->rec[cnt].qual[sortcnt].crcl2 = ranges->rec[cnt].qual[d1.seq].crcl2,
        sorted_ranges->rec[cnt].qual[sortcnt].crcl_unit = ranges->rec[cnt].qual[d1.seq].crcl_unit,
        sorted_ranges->rec[cnt].qual[sortcnt].sort_weight_key = ranges->rec[cnt].qual[d1.seq].
        sort_weight_key, sorted_ranges->rec[cnt].qual[sortcnt].from_weight = ranges->rec[cnt].qual[d1
        .seq].from_weight,
        sorted_ranges->rec[cnt].qual[sortcnt].weight1 = ranges->rec[cnt].qual[d1.seq].weight1,
        sorted_ranges->rec[cnt].qual[sortcnt].to_weight = ranges->rec[cnt].qual[d1.seq].to_weight,
        sorted_ranges->rec[cnt].qual[sortcnt].weight2 = ranges->rec[cnt].qual[d1.seq].weight2,
        sorted_ranges->rec[cnt].qual[sortcnt].weight_unit = ranges->rec[cnt].qual[d1.seq].weight_unit,
        sorted_ranges->rec[cnt].qual[sortcnt].rel_op_flag = ranges->rec[cnt].qual[d1.seq].rel_op_flag
       FOOT REPORT
        stat = alterlist(sorted_ranges->rec[cnt].qual,sortcnt)
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE age_gap_check(sorted_ranges,qualcnt)
   FOR (cnt = 1 TO qualcnt)
     IF (size(sorted_ranges->rec[cnt].qual,5) > 0)
      SELECT INTO "nl:"
       sorted_ranges->rec[cnt].qual[d1.seq].parent_premise_id, sorted_ranges->rec[cnt].qual[d1.seq].
       parent_prem_index, sorted_ranges->rec[cnt].qual[d1.seq].hepatic,
       sorted_ranges->rec[cnt].qual[d1.seq].conditions, sorted_ranges->rec[cnt].qual[d1.seq].
       from_crcl, sorted_ranges->rec[cnt].qual[d1.seq].to_crcl,
       sorted_ranges->rec[cnt].qual[d1.seq].from_hr_pma, sorted_ranges->rec[cnt].qual[d1.seq].
       to_hr_pma, sorted_ranges->rec[cnt].qual[d1.seq].from_hr,
       sorted_ranges->rec[cnt].qual[d1.seq].age1, sorted_ranges->rec[cnt].qual[d1.seq].to_hr,
       sorted_ranges->rec[cnt].qual[d1.seq].age2,
       sorted_ranges->rec[cnt].qual[d1.seq].age_unit, sorted_ranges->rec[cnt].qual[d1.seq].
       from_weight, sorted_ranges->rec[cnt].qual[d1.seq].rel_op_flag,
       route = cnvtstring(sorted_ranges->rec[cnt].qual[d1.seq].route,40,15,r)
       FROM (dummyt d1  WITH seq = value(size(sorted_ranges->rec[cnt].qual,5)))
       PLAN (d1
        WHERE  NOT ((((sorted_ranges->rec[cnt].qual[d1.seq].hepatic=1)) OR ((( NOT ((sorted_ranges->
        rec[cnt].qual[d1.seq].conditions IN ("", " ", null)))) OR ((((sorted_ranges->rec[cnt].qual[d1
        .seq].from_crcl > 0.0)) OR ((((sorted_ranges->rec[cnt].qual[d1.seq].to_crcl > 0.0)) OR ((((
        sorted_ranges->rec[cnt].qual[d1.seq].from_hr_pma > 0.0)) OR ((((sorted_ranges->rec[cnt].qual[
        d1.seq].to_hr_pma > 0.0)) OR ((sorted_ranges->rec[cnt].qual[d1.seq].parent_premise_id=0.0)))
        )) )) )) )) )) ))
       HEAD REPORT
        ppidx = 0, new_route = true, same_ind = true,
        lesser_ind = true, op_ind = true,
        MACRO (check_same_age)
         IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].from_hr=sorted_ranges->rec[cnt].qual[d1.seq]
         .from_hr)
          AND (sorted_ranges->rec[cnt].qual[(d1.seq - 1)].to_hr=sorted_ranges->rec[cnt].qual[d1.seq].
         to_hr))
          same_ind = true
         ELSE
          same_ind = false
         ENDIF
        ENDMACRO
        ,
        MACRO (check_op)
         IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].rel_op_flag != 1)
          AND (sorted_ranges->rec[cnt].qual[d1.seq].rel_op_flag != 1))
          op_ind = true
         ELSE
          op_ind = false
         ENDIF
        ENDMACRO
        ,
        MACRO (check_lesser)
         IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].to_hr < sorted_ranges->rec[cnt].qual[d1.seq]
         .from_hr)
          AND round((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].to_hr+ 0.01),2) != round(
          sorted_ranges->rec[cnt].qual[d1.seq].from_hr,2))
          lesser_ind = true
         ELSE
          lesser_ind = false
         ENDIF
        ENDMACRO
       HEAD route
        new_route = true
        IF ((sorted_ranges->rec[cnt].qual[d1.seq].from_hr > 0)
         AND (sorted_ranges->rec[cnt].qual[d1.seq].rel_op_flag != 1))
         ppidx = sorted_ranges->rec[cnt].qual[d1.seq].parent_prem_index, reply->qual[cnt].
         parent_premise[ppidx].age_check_flag = gap, reply->qual[cnt].parent_premise[ppidx].age_text
          = concat(age_gap,age_rec," < ",sorted_ranges->rec[cnt].qual[d1.seq].age1," ",
          sorted_ranges->rec[cnt].qual[d1.seq].age_unit,".")
        ENDIF
       DETAIL
        IF (new_route=true)
         new_route = false
        ELSE
         check_same_age, check_op
         IF (same_ind=false
          AND op_ind=true)
          check_lesser
          IF (lesser_ind
           AND op_ind)
           ppidx = sorted_ranges->rec[cnt].qual[(d1.seq - 1)].parent_prem_index, reply->qual[cnt].
           parent_premise[ppidx].age_check_flag = gap
           IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].age2 > " ")
            AND cnvtreal(sorted_ranges->rec[cnt].qual[(d1.seq - 1)].age2) > 0.0)
            reply->qual[cnt].parent_premise[ppidx].age_text = concat(age_gap,age_chg,
             "2 to be equivalent to ",sorted_ranges->rec[cnt].qual[d1.seq].age1," ",
             sorted_ranges->rec[cnt].qual[d1.seq].age_unit,".")
           ELSE
            reply->qual[cnt].parent_premise[ppidx].age_text = concat(age_gap,age_chg,
             "1 to be equivalent to ",sorted_ranges->rec[cnt].qual[d1.seq].age1," ",
             sorted_ranges->rec[cnt].qual[d1.seq].age_unit,".")
           ENDIF
           ppidx = sorted_ranges->rec[cnt].qual[d1.seq].parent_prem_index, reply->qual[cnt].
           parent_premise[ppidx].age_check_flag = gap
           IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].age2 > " ")
            AND cnvtreal(sorted_ranges->rec[cnt].qual[(d1.seq - 1)].age2) > 0.0)
            reply->qual[cnt].parent_premise[ppidx].age_text = concat(age_gap,age_chg,
             "1 to be equivalent to ",sorted_ranges->rec[cnt].qual[(d1.seq - 1)].age2," ",
             sorted_ranges->rec[cnt].qual[(d1.seq - 1)].age_unit,".")
           ELSE
            reply->qual[cnt].parent_premise[ppidx].age_text = concat(age_gap,age_chg,
             "1 to be equivalent to ",sorted_ranges->rec[cnt].qual[(d1.seq - 1)].age1," ",
             sorted_ranges->rec[cnt].qual[(d1.seq - 1)].age_unit,".")
           ENDIF
          ENDIF
         ENDIF
        ENDIF
       FOOT  route
        CALL convert_to_days(150,years,0)
        IF ((sorted_ranges->rec[cnt].qual[d1.seq].to_hr != number_of_hrs)
         AND (sorted_ranges->rec[cnt].qual[d1.seq].rel_op_flag != 1))
         ppidx = sorted_ranges->rec[cnt].qual[d1.seq].parent_prem_index, reply->qual[cnt].
         parent_premise[ppidx].age_check_flag = gap
         IF ((sorted_ranges->rec[cnt].qual[d1.seq].age2 > " ")
          AND cnvtreal(sorted_ranges->rec[cnt].qual[d1.seq].age2) > 0.0)
          reply->qual[cnt].parent_premise[ppidx].age_text = concat(age_gap,age_rec," >= ",
           sorted_ranges->rec[cnt].qual[d1.seq].age2," ",
           sorted_ranges->rec[cnt].qual[d1.seq].age_unit,".")
         ELSE
          reply->qual[cnt].parent_premise[ppidx].age_text = concat(age_gap,age_rec," >= ",
           sorted_ranges->rec[cnt].qual[d1.seq].age1," ",
           sorted_ranges->rec[cnt].qual[d1.seq].age_unit,".")
         ENDIF
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE weight_gap_check(sorted_ranges,qualcnt)
   FOR (cnt = 1 TO qualcnt)
     IF (size(sorted_ranges->rec[cnt].qual,5) > 0)
      SELECT INTO "nl:"
       sorted_ranges->rec[cnt].qual[d1.seq].parent_premise_id, sorted_ranges->rec[cnt].qual[d1.seq].
       parent_prem_index, from_hr = sorted_ranges->rec[cnt].qual[d1.seq].from_hr,
       sorted_ranges->rec[cnt].qual[d1.seq].hepatic, sorted_ranges->rec[cnt].qual[d1.seq].conditions,
       sorted_ranges->rec[cnt].qual[d1.seq].from_crcl,
       sorted_ranges->rec[cnt].qual[d1.seq].to_crcl, sorted_ranges->rec[cnt].qual[d1.seq].from_hr_pma,
       sorted_ranges->rec[cnt].qual[d1.seq].to_hr_pma,
       sorted_ranges->rec[cnt].qual[d1.seq].to_hr, sorted_ranges->rec[cnt].qual[d1.seq].from_weight,
       sorted_ranges->rec[cnt].qual[d1.seq].weight1,
       sorted_ranges->rec[cnt].qual[d1.seq].to_weight, sorted_ranges->rec[cnt].qual[d1.seq].weight2,
       sorted_ranges->rec[cnt].qual[d1.seq].weight_unit,
       route = cnvtstring(sorted_ranges->rec[cnt].qual[d1.seq].route,40,15,r)
       FROM (dummyt d1  WITH seq = value(size(sorted_ranges->rec[cnt].qual,5)))
       PLAN (d1
        WHERE  NOT ((((sorted_ranges->rec[cnt].qual[d1.seq].hepatic=1)) OR ((( NOT ((sorted_ranges->
        rec[cnt].qual[d1.seq].conditions IN ("", " ", null)))) OR ((((sorted_ranges->rec[cnt].qual[d1
        .seq].from_crcl > 0)) OR ((((sorted_ranges->rec[cnt].qual[d1.seq].to_crcl > 0)) OR ((((
        sorted_ranges->rec[cnt].qual[d1.seq].from_hr_pma > 0)) OR ((sorted_ranges->rec[cnt].qual[d1
        .seq].to_hr_pma > 0))) )) )) )) )) )
         AND (((sorted_ranges->rec[cnt].qual[d1.seq].from_weight > 0)) OR ((sorted_ranges->rec[cnt].
        qual[d1.seq].to_weight > 0))) )
       ORDER BY route, from_hr
       HEAD REPORT
        ppidx = 0, new_day = true, same_ind = true,
        op_ind = true, zero_ind = true, prev_zero_ind = true,
        lesser_ind = true,
        MACRO (check_zeros)
         IF ((((sorted_ranges->rec[cnt].qual[d1.seq].to_weight > 0.0)) OR ((sorted_ranges->rec[cnt].
         qual[d1.seq].from_weight > 0.0))) )
          zero_ind = true
         ELSE
          zero_ind = false
         ENDIF
        ENDMACRO
        ,
        MACRO (check_prev_zeros)
         IF ((((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].to_weight > 0.0)) OR ((sorted_ranges->rec[
         cnt].qual[(d1.seq - 1)].from_weight > 0.0))) )
          prev_zero_ind = true
         ELSE
          prev_zero_ind = false
         ENDIF
        ENDMACRO
        ,
        MACRO (check_same_weight)
         IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].from_weight=sorted_ranges->rec[cnt].qual[d1
         .seq].from_weight)
          AND (sorted_ranges->rec[cnt].qual[(d1.seq - 1)].to_weight=sorted_ranges->rec[cnt].qual[d1
         .seq].to_weight))
          same_ind = true
         ELSE
          same_ind = false
         ENDIF
        ENDMACRO
        ,
        MACRO (check_op)
         IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].rel_op_flag != 1)
          AND (sorted_ranges->rec[cnt].qual[d1.seq].rel_op_flag != 1))
          op_ind = true
         ELSE
          op_ind = false
         ENDIF
        ENDMACRO
        ,
        MACRO (check_lesser)
         IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].to_weight < sorted_ranges->rec[cnt].qual[d1
         .seq].from_weight)
          AND round((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].to_weight+ 0.00001),5) != round(
          sorted_ranges->rec[cnt].qual[d1.seq].from_weight,5))
          lesser_ind = true
         ELSE
          lesser_ind = false
         ENDIF
        ENDMACRO
       HEAD route
        row + 0
       HEAD from_hr
        new_day = true, check_zeros
        IF ((sorted_ranges->rec[cnt].qual[d1.seq].from_weight > 0)
         AND zero_ind
         AND (sorted_ranges->rec[cnt].qual[d1.seq].rel_op_flag != 1))
         ppidx = sorted_ranges->rec[cnt].qual[d1.seq].parent_prem_index, reply->qual[cnt].
         parent_premise[ppidx].weight_check_flag = gap, reply->qual[cnt].parent_premise[ppidx].
         weight_text = concat(wgt_gap,wgt_rec," < ",sorted_ranges->rec[cnt].qual[d1.seq].weight1," ",
          sorted_ranges->rec[cnt].qual[d1.seq].weight_unit,".")
        ENDIF
       DETAIL
        IF (new_day=true)
         new_day = false
        ELSE
         check_same_weight, check_op, check_zeros,
         check_prev_zeros
         IF (same_ind=false
          AND op_ind
          AND zero_ind
          AND prev_zero_ind)
          check_lesser
          IF (lesser_ind
           AND zero_ind
           AND op_ind
           AND prev_zero_ind)
           ppidx = sorted_ranges->rec[cnt].qual[(d1.seq - 1)].parent_prem_index, reply->qual[cnt].
           parent_premise[ppidx].weight_check_flag = gap
           IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].weight2 > " ")
            AND cnvtreal(sorted_ranges->rec[cnt].qual[(d1.seq - 1)].weight2) > 0.0)
            reply->qual[cnt].parent_premise[ppidx].weight_text = concat(wgt_gap,wgt_chg,
             "2 to be equivalent to ",sorted_ranges->rec[cnt].qual[d1.seq].weight1," ",
             sorted_ranges->rec[cnt].qual[d1.seq].weight_unit,".")
           ELSE
            reply->qual[cnt].parent_premise[ppidx].weight_text = concat(wgt_gap,wgt_chg,
             "1 to be equivalent to ",sorted_ranges->rec[cnt].qual[d1.seq].weight1," ",
             sorted_ranges->rec[cnt].qual[d1.seq].weight_unit,".")
           ENDIF
           ppidx = sorted_ranges->rec[cnt].qual[d1.seq].parent_prem_index, reply->qual[cnt].
           parent_premise[ppidx].weight_check_flag = gap
           IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].weight2 > " ")
            AND cnvtreal(sorted_ranges->rec[cnt].qual[(d1.seq - 1)].weight2) > 0.0)
            reply->qual[cnt].parent_premise[ppidx].weight_text = concat(wgt_gap,wgt_chg,
             "1 to be equivalent to ",sorted_ranges->rec[cnt].qual[(d1.seq - 1)].weight2," ",
             sorted_ranges->rec[cnt].qual[(d1.seq - 1)].weight_unit,".")
           ELSE
            reply->qual[cnt].parent_premise[ppidx].weight_text = concat(wgt_gap,wgt_chg,
             "1 to be equivalent to ",sorted_ranges->rec[cnt].qual[(d1.seq - 1)].weight1," ",
             sorted_ranges->rec[cnt].qual[(d1.seq - 1)].weight_unit,".")
           ENDIF
          ENDIF
         ENDIF
        ENDIF
       FOOT  from_hr
        check_zeros,
        CALL convert_to_kgs(1000,kg,3)
        IF ((sorted_ranges->rec[cnt].qual[d1.seq].to_weight != number_of_kgs)
         AND zero_ind
         AND (sorted_ranges->rec[cnt].qual[d1.seq].rel_op_flag != 1))
         ppidx = sorted_ranges->rec[cnt].qual[d1.seq].parent_prem_index, reply->qual[cnt].
         parent_premise[ppidx].weight_check_flag = gap
         IF ((sorted_ranges->rec[cnt].qual[d1.seq].weight2 > " ")
          AND cnvtreal(sorted_ranges->rec[cnt].qual[d1.seq].weight2) > 0.0)
          reply->qual[cnt].parent_premise[ppidx].weight_text = concat(wgt_gap,wgt_rec," >= ",
           sorted_ranges->rec[cnt].qual[d1.seq].weight2," ",
           sorted_ranges->rec[cnt].qual[d1.seq].weight_unit,".")
         ELSE
          reply->qual[cnt].parent_premise[ppidx].weight_text = concat(wgt_gap,wgt_rec," >= ",
           sorted_ranges->rec[cnt].qual[d1.seq].weight1," ",
           sorted_ranges->rec[cnt].qual[d1.seq].weight_unit,".")
         ENDIF
        ENDIF
       FOOT  route
        row + 0
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE overlap_check(ranges,qualcnt)
   FOR (cnt = 1 TO qualcnt)
     IF (size(sorted_ranges->rec[cnt].qual,5) > 0)
      SELECT INTO "nl:"
       sort_key = sorted_ranges->rec[cnt].qual[d1.seq].sort_key, sorted_ranges->rec[cnt].qual[d1.seq]
       .parent_premise_id, sorted_ranges->rec[cnt].qual[d1.seq].parent_prem_index,
       sorted_ranges->rec[cnt].qual[d1.seq].conditions, sorted_ranges->rec[cnt].qual[d1.seq].
       from_hr_pma, sorted_ranges->rec[cnt].qual[d1.seq].pma1,
       sorted_ranges->rec[cnt].qual[d1.seq].to_hr_pma, sorted_ranges->rec[cnt].qual[d1.seq].pma2,
       sorted_ranges->rec[cnt].qual[d1.seq].pma_unit,
       sorted_ranges->rec[cnt].qual[d1.seq].hepatic, sorted_ranges->rec[cnt].qual[d1.seq].from_hr,
       sorted_ranges->rec[cnt].qual[d1.seq].age1,
       sorted_ranges->rec[cnt].qual[d1.seq].to_hr, sorted_ranges->rec[cnt].qual[d1.seq].age2,
       sorted_ranges->rec[cnt].qual[d1.seq].age_unit,
       sorted_ranges->rec[cnt].qual[d1.seq].from_crcl, sorted_ranges->rec[cnt].qual[d1.seq].crcl1,
       sorted_ranges->rec[cnt].qual[d1.seq].to_crcl,
       sorted_ranges->rec[cnt].qual[d1.seq].crcl2, sorted_ranges->rec[cnt].qual[d1.seq].crcl_unit,
       sorted_ranges->rec[cnt].qual[d1.seq].from_weight,
       sorted_ranges->rec[cnt].qual[d1.seq].weight1, sorted_ranges->rec[cnt].qual[d1.seq].weight2,
       sorted_ranges->rec[cnt].qual[d1.seq].weight_unit,
       sorted_ranges->rec[cnt].qual[d1.seq].rel_op_flag, route = cnvtstring(sorted_ranges->rec[cnt].
        qual[d1.seq].route,40,15,r)
       FROM (dummyt d1  WITH seq = value(size(sorted_ranges->rec[cnt].qual,5)))
       PLAN (d1)
       HEAD REPORT
        ppidx = 0, new_route = false, cond_same_ind = false,
        pma_same_ind = false, op_ind = false, pma_zero_ind = false,
        pma_prev_zero_ind = false, weight_zero_ind = false, weight_prev_zero_ind = false,
        renal_zero_ind = false, renal_prev_zero_ind = false, pma_overlap_ind = false,
        hepatic_same_ind = false, renal_same_ind = false, renal_overlap_ind = false,
        age_same_ind = false, age_overlap_ind = false, weight_same_ind = false,
        weight_overlap_ind = false,
        MACRO (check_conditions)
         IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].conditions=sorted_ranges->rec[cnt].qual[d1
         .seq].conditions))
          cond_same_ind = true
         ELSE
          cond_same_ind = false
         ENDIF
        ENDMACRO
        ,
        MACRO (check_pma_same)
         IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].from_hr_pma=sorted_ranges->rec[cnt].qual[d1
         .seq].from_hr_pma)
          AND (sorted_ranges->rec[cnt].qual[(d1.seq - 1)].to_hr_pma=sorted_ranges->rec[cnt].qual[d1
         .seq].to_hr_pma))
          pma_same_ind = true
         ELSE
          pma_same_ind = false
         ENDIF
        ENDMACRO
        ,
        MACRO (check_pma_overlap)
         IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].to_hr_pma > sorted_ranges->rec[cnt].qual[d1
         .seq].from_hr_pma))
          pma_overlap_ind = true
         ELSE
          pma_overlap_ind = false
         ENDIF
        ENDMACRO
        ,
        MACRO (check_pma_zeros)
         IF ((((sorted_ranges->rec[cnt].qual[d1.seq].to_hr_pma > 0.0)) OR ((sorted_ranges->rec[cnt].
         qual[d1.seq].from_hr_pma > 0.0))) )
          pma_zero_ind = true
         ELSE
          pma_zero_ind = false
         ENDIF
        ENDMACRO
        ,
        MACRO (check_pma_prev_zeros)
         IF ((((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].to_hr_pma > 0.0)) OR ((sorted_ranges->rec[
         cnt].qual[(d1.seq - 1)].from_hr_pma > 0.0))) )
          pma_prev_zero_ind = true
         ELSE
          pma_prev_zero_ind = false
         ENDIF
        ENDMACRO
        ,
        MACRO (check_hepatic)
         IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].hepatic=sorted_ranges->rec[cnt].qual[d1.seq]
         .hepatic))
          hepatic_same_ind = true
         ELSE
          hepatic_same_ind = false
         ENDIF
        ENDMACRO
        ,
        MACRO (check_renal_same)
         IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].from_crcl=sorted_ranges->rec[cnt].qual[d1
         .seq].from_crcl)
          AND (sorted_ranges->rec[cnt].qual[(d1.seq - 1)].to_crcl=sorted_ranges->rec[cnt].qual[d1.seq
         ].to_crcl))
          renal_same_ind = true
         ELSE
          renal_same_ind = false
         ENDIF
        ENDMACRO
        ,
        MACRO (check_renal_overlap)
         IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].to_crcl > sorted_ranges->rec[cnt].qual[d1
         .seq].from_crcl))
          renal_overlap_ind = true
         ELSE
          renal_overlap_ind = false
         ENDIF
        ENDMACRO
        ,
        MACRO (check_renal_zeros)
         IF ((((sorted_ranges->rec[cnt].qual[d1.seq].to_crcl > 0.0)) OR ((sorted_ranges->rec[cnt].
         qual[d1.seq].from_crcl > 0.0))) )
          renal_zero_ind = true
         ELSE
          renal_zero_ind = false
         ENDIF
        ENDMACRO
        ,
        MACRO (check_renal_prev_zeros)
         IF ((((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].to_crcl > 0.0)) OR ((sorted_ranges->rec[
         cnt].qual[(d1.seq - 1)].from_crcl > 0.0))) )
          renal_prev_zero_ind = true
         ELSE
          renal_prev_zero_ind = false
         ENDIF
        ENDMACRO
        ,
        MACRO (check_age_same)
         IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].from_hr=sorted_ranges->rec[cnt].qual[d1.seq]
         .from_hr)
          AND (sorted_ranges->rec[cnt].qual[(d1.seq - 1)].to_hr=sorted_ranges->rec[cnt].qual[d1.seq].
         to_hr))
          age_same_ind = true
         ELSE
          age_same_ind = false
         ENDIF
        ENDMACRO
        ,
        MACRO (check_age_overlap)
         IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].to_hr > sorted_ranges->rec[cnt].qual[d1.seq]
         .from_hr))
          age_overlap_ind = true
         ELSE
          age_overlap_ind = false
         ENDIF
        ENDMACRO
        ,
        MACRO (check_weight_same)
         IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].from_weight=sorted_ranges->rec[cnt].qual[d1
         .seq].from_weight)
          AND (sorted_ranges->rec[cnt].qual[(d1.seq - 1)].to_weight=sorted_ranges->rec[cnt].qual[d1
         .seq].to_weight))
          weight_same_ind = true
         ELSE
          weight_same_ind = false
         ENDIF
        ENDMACRO
        ,
        MACRO (check_weight_overlap)
         IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].to_weight > sorted_ranges->rec[cnt].qual[d1
         .seq].from_weight))
          weight_overlap_ind = true
         ELSE
          weight_overlap_ind = false
         ENDIF
        ENDMACRO
        ,
        MACRO (check_weight_zeros)
         IF ((((sorted_ranges->rec[cnt].qual[d1.seq].to_weight > 0.0)) OR ((sorted_ranges->rec[cnt].
         qual[d1.seq].from_weight > 0.0))) )
          weight_zero_ind = true
         ELSE
          weight_zero_ind = false
         ENDIF
        ENDMACRO
        ,
        MACRO (check_weight_prev_zeros)
         IF ((((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].to_weight > 0.0)) OR ((sorted_ranges->rec[
         cnt].qual[(d1.seq - 1)].from_weight > 0.0))) )
          weight_prev_zero_ind = true
         ELSE
          weight_prev_zero_ind = false
         ENDIF
        ENDMACRO
       HEAD route
        row + 1
       HEAD sort_key
        new_route = true
       DETAIL
        IF (new_route=true)
         new_route = false
        ELSE
         check_conditions
         IF (cond_same_ind)
          check_age_same, check_age_overlap, check_pma_zeros,
          check_pma_prev_zeros, check_pma_same
          IF (pma_same_ind=false)
           check_pma_overlap
          ENDIF
          check_hepatic
          IF (hepatic_same_ind)
           check_renal_zeros, check_renal_prev_zeros, check_renal_same
           IF (renal_same_ind=false)
            check_renal_overlap
           ENDIF
           check_weight_zeros, check_weight_prev_zeros, check_weight_same
           IF (weight_same_ind=false)
            check_weight_overlap
           ENDIF
           IF (((age_same_ind) OR (age_overlap_ind))
            AND ((pma_same_ind) OR (pma_overlap_ind))
            AND ((renal_same_ind) OR (renal_overlap_ind))
            AND ((weight_same_ind) OR (weight_overlap_ind)) )
            ppidx = sorted_ranges->rec[cnt].qual[(d1.seq - 1)].parent_prem_index, reply->qual[cnt].
            parent_premise[ppidx].age_check_flag = overlap
            IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].age2 > " ")
             AND cnvtreal(sorted_ranges->rec[cnt].qual[(d1.seq - 1)].age2) > 0.0)
             reply->qual[cnt].parent_premise[ppidx].age_text = concat(age_over,age_chg,
              "2 to be equivalent to ",sorted_ranges->rec[cnt].qual[d1.seq].age1," ",
              sorted_ranges->rec[cnt].qual[d1.seq].age_unit,".")
            ELSE
             reply->qual[cnt].parent_premise[ppidx].age_text = concat(age_over,age_chg,
              "1 to be equivalent to ",sorted_ranges->rec[cnt].qual[d1.seq].age1," ",
              sorted_ranges->rec[cnt].qual[d1.seq].age_unit,".")
            ENDIF
            ppidx = sorted_ranges->rec[cnt].qual[d1.seq].parent_prem_index, reply->qual[cnt].
            parent_premise[ppidx].age_check_flag = overlap
            IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].age2 > " ")
             AND cnvtreal(sorted_ranges->rec[cnt].qual[(d1.seq - 1)].age2) > 0.0)
             reply->qual[cnt].parent_premise[ppidx].age_text = concat(age_over,age_chg,
              "1 to be equivalent to ",sorted_ranges->rec[cnt].qual[(d1.seq - 1)].age2," ",
              sorted_ranges->rec[cnt].qual[(d1.seq - 1)].age_unit,".")
            ELSE
             reply->qual[cnt].parent_premise[ppidx].age_text = concat(age_over,age_chg,
              "1 to be equivalent to ",sorted_ranges->rec[cnt].qual[(d1.seq - 1)].age1," ",
              sorted_ranges->rec[cnt].qual[(d1.seq - 1)].age_unit,".")
            ENDIF
           ENDIF
           IF (((pma_same_ind) OR (pma_overlap_ind))
            AND pma_zero_ind
            AND pma_prev_zero_ind
            AND age_same_ind
            AND renal_same_ind
            AND weight_same_ind)
            ppidx = sorted_ranges->rec[cnt].qual[(d1.seq - 1)].parent_prem_index, reply->qual[cnt].
            parent_premise[ppidx].pma_check_flag = overlap
            IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].pma2 > " ")
             AND cnvtreal(sorted_ranges->rec[cnt].qual[(d1.seq - 1)].pma2) > 0.0)
             reply->qual[cnt].parent_premise[ppidx].age_text = concat(pma_over,pma_chg,
              "2 to be equivalent to ",sorted_ranges->rec[cnt].qual[d1.seq].pma1," ",
              sorted_ranges->rec[cnt].qual[d1.seq].pma_unit,".")
            ELSE
             reply->qual[cnt].parent_premise[ppidx].pma_text = concat(pma_over,pma_chg,
              "1 to be equivalent to ",sorted_ranges->rec[cnt].qual[d1.seq].pma1," ",
              sorted_ranges->rec[cnt].qual[d1.seq].pma_unit,".")
            ENDIF
            ppidx = sorted_ranges->rec[cnt].qual[d1.seq].parent_prem_index, reply->qual[cnt].
            parent_premise[ppidx].pma_check_flag = overlap
            IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].pma2 > " ")
             AND cnvtreal(sorted_ranges->rec[cnt].qual[(d1.seq - 1)].pma2) > 0.0)
             reply->qual[cnt].parent_premise[ppidx].pma_text = concat(pma_over,pma_chg,
              "1 to be equivalent to ",sorted_ranges->rec[cnt].qual[(d1.seq - 1)].pma2," ",
              sorted_ranges->rec[cnt].qual[(d1.seq - 1)].pma_unit,".")
            ELSE
             reply->qual[cnt].parent_premise[ppidx].pma_text = concat(pma_over,pma_chg,
              "1 to be equivalent to ",sorted_ranges->rec[cnt].qual[(d1.seq - 1)].pma1," ",
              sorted_ranges->rec[cnt].qual[(d1.seq - 1)].pma_unit,".")
            ENDIF
           ENDIF
           IF (((renal_same_ind) OR (renal_overlap_ind))
            AND renal_zero_ind
            AND renal_prev_zero_ind
            AND age_same_ind
            AND pma_same_ind
            AND weight_same_ind)
            ppidx = sorted_ranges->rec[cnt].qual[(d1.seq - 1)].parent_prem_index, reply->qual[cnt].
            parent_premise[ppidx].crcl_check_flag = overlap
            IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].crcl2 > " ")
             AND cnvtreal(sorted_ranges->rec[cnt].qual[(d1.seq - 1)].crcl2) > 0.0)
             reply->qual[cnt].parent_premise[ppidx].crcl_text = concat(crcl_over,crcl_chg,
              "2 to be equivalent to ",sorted_ranges->rec[cnt].qual[d1.seq].crcl1," ",
              sorted_ranges->rec[cnt].qual[d1.seq].crcl_unit,".")
            ELSE
             reply->qual[cnt].parent_premise[ppidx].crcl_text = concat(crcl_over,crcl_chg,
              "1 to be equivalent to ",sorted_ranges->rec[cnt].qual[d1.seq].crcl1," ",
              sorted_ranges->rec[cnt].qual[d1.seq].crcl_unit,".")
            ENDIF
            ppidx = sorted_ranges->rec[cnt].qual[d1.seq].parent_prem_index, reply->qual[cnt].
            parent_premise[ppidx].crcl_check_flag = overlap
            IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].crcl2 > " ")
             AND cnvtreal(sorted_ranges->rec[cnt].qual[(d1.seq - 1)].crcl2) > 0.0)
             reply->qual[cnt].parent_premise[ppidx].crcl_text = concat(crcl_over,crcl_chg,
              "1 to be equivalent to ",sorted_ranges->rec[cnt].qual[(d1.seq - 1)].crcl2," ",
              sorted_ranges->rec[cnt].qual[(d1.seq - 1)].crcl_unit,".")
            ELSE
             reply->qual[cnt].parent_premise[ppidx].crcl_text = concat(crcl_over,crcl_chg,
              "1 to be equivalent to ",sorted_ranges->rec[cnt].qual[(d1.seq - 1)].crcl1," ",
              sorted_ranges->rec[cnt].qual[(d1.seq - 1)].crcl_unit,".")
            ENDIF
           ENDIF
           IF (((weight_same_ind) OR (weight_overlap_ind))
            AND weight_zero_ind
            AND weight_prev_zero_ind
            AND pma_same_ind=true
            AND renal_same_ind=true
            AND age_same_ind=true)
            ppidx = sorted_ranges->rec[cnt].qual[(d1.seq - 1)].parent_prem_index, reply->qual[cnt].
            parent_premise[ppidx].weight_check_flag = overlap
            IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].weight2 > " ")
             AND cnvtreal(sorted_ranges->rec[cnt].qual[(d1.seq - 1)].weight2) > 0.0)
             reply->qual[cnt].parent_premise[ppidx].weight_text = concat(wgt_over,wgt_chg,
              "2 to be equivalent to ",sorted_ranges->rec[cnt].qual[d1.seq].weight1," ",
              sorted_ranges->rec[cnt].qual[d1.seq].weight_unit,".")
            ELSE
             reply->qual[cnt].parent_premise[ppidx].weight_text = concat(wgt_over,wgt_chg,
              "1 to be equivalent to ",sorted_ranges->rec[cnt].qual[d1.seq].weight1," ",
              sorted_ranges->rec[cnt].qual[d1.seq].weight_unit,".")
            ENDIF
            ppidx = sorted_ranges->rec[cnt].qual[d1.seq].parent_prem_index, reply->qual[cnt].
            parent_premise[ppidx].weight_check_flag = overlap
            IF ((sorted_ranges->rec[cnt].qual[(d1.seq - 1)].weight2 > " ")
             AND cnvtreal(sorted_ranges->rec[cnt].qual[(d1.seq - 1)].weight2) > 0.0)
             reply->qual[cnt].parent_premise[ppidx].weight_text = concat(wgt_over,wgt_chg,
              "1 to be equivalent to ",sorted_ranges->rec[cnt].qual[(d1.seq - 1)].weight2," ",
              sorted_ranges->rec[cnt].qual[(d1.seq - 1)].weight_unit,".")
            ELSE
             reply->qual[cnt].parent_premise[ppidx].weight_text = concat(wgt_over,wgt_chg,
              "1 to be equivalent to ",sorted_ranges->rec[cnt].qual[(d1.seq - 1)].weight1," ",
              sorted_ranges->rec[cnt].qual[(d1.seq - 1)].weight_unit,".")
            ENDIF
           ENDIF
          ENDIF
         ENDIF
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE get_source_string(qualcnt)
   FOR (cnt = 1 TO qualcnt)
     FOR (pploop = 1 TO size(reply->qual[cnt].parent_premise,5))
       FOR (ploop = 1 TO size(reply->qual[cnt].parent_premise[pploop].premise,5))
         IF ((reply->qual[cnt].parent_premise[pploop].premise[ploop].premise_type_flag=7)
          AND  NOT ((reply->qual[cnt].parent_premise[pploop].premise[ploop].concept_cki IN (" ", "",
         null))))
          SELECT INTO "nl:"
           FROM nomenclature n
           WHERE (n.concept_cki=reply->qual[cnt].parent_premise[pploop].premise[ploop].concept_cki)
            AND n.primary_cterm_ind=1
            AND n.active_ind=1
           DETAIL
            reply->qual[cnt].parent_premise[pploop].premise[ploop].source_string = n.source_string,
            reply->qual[cnt].parent_premise[pploop].premise[ploop].sort_conditions_key = n
            .source_string
           WITH nocounter
          ;end select
         ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
 END ;Subroutine
 DECLARE set_warning_type(group_cnt=i4,warn_cnt=i4,x=i4,y=i4) = null
 SET reply->status_data.status = "F"
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE flexed = vc WITH public, noconstant("F")
 CALL main_query(1)
 CALL sort(ranges,qualcnt)
 CALL age_gap_check(sorted_ranges,qualcnt)
 CALL weight_gap_check(sorted_ranges,qualcnt)
 CALL overlap_check(ranges,qualcnt)
 CALL get_source_string(qualcnt)
 SELECT INTO "nl:"
  FROM dm_info dm
  WHERE dm.info_domain="KNOWLEDGE INDEX APPLICATIONS"
   AND dm.info_name="DRC_FLEX"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET flexed = "T"
 ENDIF
 SET group_cnt = 0
 SET old_group_cnt = 0
 FOR (aidx = 1 TO size(reply->qual,5))
   SET add = "FALSE"
   SET warn_cnt = 0
   SET group = 0
   FOR (bidx = 1 TO size(reply->qual[aidx].parent_premise,5))
     IF ((((reply->qual[aidx].parent_premise[bidx].age_check_flag != 0)) OR ((((reply->qual[aidx].
     parent_premise[bidx].weight_check_flag != 0)) OR ((((reply->qual[aidx].parent_premise[bidx].
     pma_check_flag != 0)) OR ((reply->qual[aidx].parent_premise[bidx].crcl_check_flag != 0))) )) ))
     )
      SET warn_cnt = (warn_cnt+ 1)
      FOR (cidx = 1 TO size(reply->qual[aidx].parent_premise[bidx].premise,5))
        CASE (cidx)
         OF 1:
          IF (size(reply->qual[aidx].parent_premise,5)=1
           AND (reply->qual[aidx].parent_premise[bidx].premise[cidx].value1=18)
           AND (reply->qual[aidx].parent_premise[bidx].premise[cidx].relational_operator_flag=4)
           AND uar_get_code_display(reply->qual[aidx].parent_premise[bidx].premise[cidx].
           value_unit_cd)="year(s)")
           SET cidx = size(reply->qual[aidx].parent_premise[bidx].premise,5)
          ELSE
           IF (add="FALSE")
            SET group_cnt = (group_cnt+ 1)
            SET stat = alterlist(rpt->group,group_cnt)
            SET rpt->group[group_cnt].group_name = reply->qual[aidx].drc_name
            SET rpt->group[group_cnt].dose_range_check_id = reply->qual[aidx].dose_range_check_id
            SET add = "TRUE"
           ENDIF
           SET rpt->group[group_cnt].grp_warn_cnt = warn_cnt
           SET stat = alterlist(rpt->group[group_cnt].warnings,warn_cnt)
           CALL set_warning_type(group_cnt,warn_cnt,aidx,bidx)
           SET rpt->group[group_cnt].warnings[warn_cnt].parent_premise_id = reply->qual[aidx].
           parent_premise[bidx].parent_premise_id
           IF (group=0)
            SET rpt->group[group_cnt].warnings[warn_cnt].group_ind = 0
            SET group = 1
           ELSEIF (group=1
            AND (rpt->group[group_cnt].warnings[warn_cnt].type=rpt->group[group_cnt].warnings[(
           warn_cnt - 1)].type))
            SET rpt->group[group_cnt].warnings[warn_cnt].group_ind = 1
           ELSE
            SET rpt->group[group_cnt].warnings[warn_cnt].group_ind = 0
           ENDIF
           SET rpt->group[group_cnt].warnings[warn_cnt].from_day_str = cnvtstring(reply->qual[aidx].
            parent_premise[bidx].premise[cidx].value1)
           SET rpt->group[group_cnt].warnings[warn_cnt].to_day_str = cnvtstring(reply->qual[aidx].
            parent_premise[bidx].premise[cidx].value2)
           SET rpt->group[group_cnt].warnings[warn_cnt].age_units_disp = uar_get_code_display(reply->
            qual[aidx].parent_premise[bidx].premise[cidx].value_unit_cd)
           CASE (reply->qual[aidx].parent_premise[bidx].premise[cidx].relational_operator_flag)
            OF 1:
             SET rpt->group[group_cnt].warnings[warn_cnt].age_rel_op = "<"
            OF 4:
             SET rpt->group[group_cnt].warnings[warn_cnt].age_rel_op = ">="
            OF 6:
             SET rpt->group[group_cnt].warnings[warn_cnt].age_rel_op = "Between"
           ENDCASE
          ENDIF
         OF 3:
          SET rpt->group[group_cnt].warnings[warn_cnt].from_weight_str = cnvtstring(reply->qual[aidx]
           .parent_premise[bidx].premise[cidx].value1)
          SET rpt->group[group_cnt].warnings[warn_cnt].to_weight_str = cnvtstring(reply->qual[aidx].
           parent_premise[bidx].premise[cidx].value2)
          SET rpt->group[group_cnt].warnings[warn_cnt].wgt_units_disp = uar_get_code_display(reply->
           qual[aidx].parent_premise[bidx].premise[cidx].value_unit_cd)
          CASE (reply->qual[aidx].parent_premise[bidx].premise[cidx].relational_operator_flag)
           OF 1:
            SET rpt->group[group_cnt].warnings[warn_cnt].wgt_rel_op = "<"
           OF 4:
            SET rpt->group[group_cnt].warnings[warn_cnt].wgt_rel_op = ">="
           OF 6:
            SET rpt->group[group_cnt].warnings[warn_cnt].wgt_rel_op = "Between"
          ENDCASE
         OF 4:
          SET rpt->group[group_cnt].warnings[warn_cnt].from_crcl_str = cnvtstring(reply->qual[aidx].
           parent_premise[bidx].premise[cidx].value1)
          SET rpt->group[group_cnt].warnings[warn_cnt].to_crcl_str = cnvtstring(reply->qual[aidx].
           parent_premise[bidx].premise[cidx].value2)
          SET rpt->group[group_cnt].warnings[warn_cnt].crcl_units_disp = uar_get_code_display(reply->
           qual[aidx].parent_premise[bidx].premise[cidx].value_unit_cd)
          CASE (reply->qual[aidx].parent_premise[bidx].premise[cidx].relational_operator_flag)
           OF 1:
            SET rpt->group[group_cnt].warnings[warn_cnt].crcl_rel_op = "<"
           OF 4:
            SET rpt->group[group_cnt].warnings[warn_cnt].crcl_rel_op = ">="
           OF 6:
            SET rpt->group[group_cnt].warnings[warn_cnt].crcl_rel_op = "Between"
          ENDCASE
         OF 5:
          SET rpt->group[group_cnt].warnings[warn_cnt].from_pma_str = cnvtstring(reply->qual[aidx].
           parent_premise[bidx].premise[cidx].value1)
          SET rpt->group[group_cnt].warnings[warn_cnt].to_pma_str = cnvtstring(reply->qual[aidx].
           parent_premise[bidx].premise[cidx].value2)
          SET rpt->group[group_cnt].warnings[warn_cnt].pma_units_disp = uar_get_code_display(reply->
           qual[aidx].parent_premise[bidx].premise[cidx].value_unit_cd)
          CASE (reply->qual[aidx].parent_premise[bidx].premise[cidx].relational_operator_flag)
           OF 1:
            SET rpt->group[group_cnt].warnings[warn_cnt].pma_rel_op = "<"
           OF 4:
            SET rpt->group[group_cnt].warnings[warn_cnt].pma_rel_op = ">="
           OF 6:
            SET rpt->group[group_cnt].warnings[warn_cnt].pma_rel_op = "Between"
          ENDCASE
         OF 6:
          SET rpt->group[group_cnt].warnings[warn_cnt].hepatic_ind = reply->qual[aidx].
          parent_premise[bidx].premise[cidx].sort_hepatic_key
         OF 7:
          SET rpt->group[group_cnt].warnings[warn_cnt].condition = reply->qual[aidx].parent_premise[
          bidx].premise[cidx].source_string
         ELSE
          SET rpt->group[group_cnt].warnings[warn_cnt].route_premise_id = reply->qual[aidx].
          parent_premise[bidx].premise[cidx].drc_premise_id
        ENDCASE
      ENDFOR
     ENDIF
   ENDFOR
   IF (group_cnt > 0
    AND warn_cnt > 0
    AND group_cnt > old_group_cnt)
    SET old_group_cnt = group_cnt
    SELECT INTO "nl:"
     dp.drc_premise_id, dp.value_type_flag, dpl.drc_premise_list_id,
     dpl.parent_entity_id, dpl.parent_entity_name
     FROM drc_premise dp,
      drc_premise_list dpl,
      (dummyt d  WITH seq = value(warn_cnt))
     PLAN (d
      WHERE d.seq <= warn_cnt)
      JOIN (dp
      WHERE (dp.drc_premise_id=rpt->group[group_cnt].warnings[d.seq].route_premise_id)
       AND dp.premise_type_flag=2)
      JOIN (dpl
      WHERE dpl.drc_premise_id=outerjoin(dp.drc_premise_id)
       AND dpl.active_ind=outerjoin(1))
     ORDER BY d.seq
     HEAD d.seq
      route_str = fillstring(100," "), start = 1
     DETAIL
      IF (dp.value_type_flag=3)
       route_str = uar_get_code_display(dp.value1)
      ELSEIF (dp.value_type_flag=4)
       IF (start=1)
        route_str = uar_get_code_display(dpl.parent_entity_id), start = 0
       ELSE
        code_disp = uar_get_code_display(dpl.parent_entity_id), route_str = build(route_str,",",
         code_disp)
       ENDIF
      ENDIF
     FOOT  d.seq
      rpt->group[group_cnt].warnings[d.seq].route_disp = route_str
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 IF (flexed="T")
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(rpt->group,5))),
    drc_facility_r dfr
   PLAN (d)
    JOIN (dfr
    WHERE (dfr.dose_range_check_id=rpt->group[d.seq].dose_range_check_id))
   DETAIL
    IF (dfr.facility_cd)
     rpt->group[d.seq].group_name = concat(trim(rpt->group[d.seq].group_name)," - ",
      uar_get_code_display(dfr.facility_cd))
    ELSE
     rpt->group[d.seq].group_name = concat(trim(rpt->group[d.seq].group_name)," -  Default")
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  nm = rpt->group[d1.seq].group_name, type1 = rpt->group[d1.seq].warnings[d2.seq].type
  FROM (dummyt d1  WITH seq = value(size(rpt->group,5))),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(rpt->group[d1.seq].warnings,5)))
   JOIN (d2)
  ORDER BY nm, type1
  HEAD REPORT
   par_cnt = 0, chld_cnt = 0
  HEAD nm
   par_cnt = (par_cnt+ 1)
   IF (par_cnt > size(rpt2->group,5))
    stat = alterlist(rpt2->group,(par_cnt+ 10))
   ENDIF
   rpt2->group[par_cnt].group_name = rpt->group[d1.seq].group_name, rpt2->group[par_cnt].grp_warn_cnt
    = rpt->group[d1.seq].grp_warn_cnt, chld_cnt = 0
  DETAIL
   chld_cnt = (chld_cnt+ 1)
   IF (chld_cnt > size(rpt2->group[par_cnt].warnings,5))
    stat = alterlist(rpt2->group[par_cnt].warnings,(chld_cnt+ 10))
   ENDIF
   rpt2->group[par_cnt].warnings[chld_cnt].parent_premise_id = rpt->group[d1.seq].warnings[d2.seq].
   parent_premise_id, rpt2->group[par_cnt].warnings[chld_cnt].type = rpt->group[d1.seq].warnings[d2
   .seq].type, rpt2->group[par_cnt].warnings[chld_cnt].group_ind = rpt->group[d1.seq].warnings[d2.seq
   ].group_ind,
   rpt2->group[par_cnt].warnings[chld_cnt].from_day_str = rpt->group[d1.seq].warnings[d2.seq].
   from_day_str, rpt2->group[par_cnt].warnings[chld_cnt].to_day_str = rpt->group[d1.seq].warnings[d2
   .seq].to_day_str, rpt2->group[par_cnt].warnings[chld_cnt].age_units_disp = rpt->group[d1.seq].
   warnings[d2.seq].age_units_disp,
   rpt2->group[par_cnt].warnings[chld_cnt].age_rel_op = rpt->group[d1.seq].warnings[d2.seq].
   age_rel_op, rpt2->group[par_cnt].warnings[chld_cnt].from_pma_str = rpt->group[d1.seq].warnings[d2
   .seq].from_pma_str, rpt2->group[par_cnt].warnings[chld_cnt].to_pma_str = rpt->group[d1.seq].
   warnings[d2.seq].to_pma_str,
   rpt2->group[par_cnt].warnings[chld_cnt].pma_units_disp = rpt->group[d1.seq].warnings[d2.seq].
   pma_units_disp, rpt2->group[par_cnt].warnings[chld_cnt].pma_rel_op = rpt->group[d1.seq].warnings[
   d2.seq].pma_rel_op, rpt2->group[par_cnt].warnings[chld_cnt].from_weight_str = rpt->group[d1.seq].
   warnings[d2.seq].from_weight_str,
   rpt2->group[par_cnt].warnings[chld_cnt].wgt_units_disp = rpt->group[d1.seq].warnings[d2.seq].
   wgt_units_disp, rpt2->group[par_cnt].warnings[chld_cnt].wgt_rel_op = rpt->group[d1.seq].warnings[
   d2.seq].wgt_rel_op, rpt2->group[par_cnt].warnings[chld_cnt].from_crcl_str = rpt->group[d1.seq].
   warnings[d2.seq].from_crcl_str,
   rpt2->group[par_cnt].warnings[chld_cnt].to_crcl_str = rpt->group[d1.seq].warnings[d2.seq].
   to_crcl_str, rpt2->group[par_cnt].warnings[chld_cnt].crcl_units_disp = rpt->group[d1.seq].
   warnings[d2.seq].crcl_units_disp, rpt2->group[par_cnt].warnings[chld_cnt].crcl_rel_op = rpt->
   group[d1.seq].warnings[d2.seq].crcl_rel_op,
   rpt2->group[par_cnt].warnings[chld_cnt].route_premise_id = rpt->group[d1.seq].warnings[d2.seq].
   route_premise_id, rpt2->group[par_cnt].warnings[chld_cnt].route_disp = rpt->group[d1.seq].
   warnings[d2.seq].route_disp, rpt2->group[par_cnt].warnings[chld_cnt].from_day_str = rpt->group[d1
   .seq].warnings[d2.seq].from_day_str,
   rpt2->group[par_cnt].warnings[chld_cnt].hepatic_ind = rpt->group[d1.seq].warnings[d2.seq].
   hepatic_ind, rpt2->group[par_cnt].warnings[chld_cnt].condition = rpt->group[d1.seq].warnings[d2
   .seq].condition
  FOOT  nm
   stat = alterlist(rpt2->group[par_cnt].warnings,chld_cnt)
  FOOT REPORT
   stat = alterlist(rpt2->group,par_cnt)
  WITH nocounter
 ;end select
 SET group_cnt = size(rpt2->group,5)
 IF (group_cnt > 0)
  SELECT INTO  $1
   *
   FROM (dummyt d1  WITH seq = value(group_cnt))
   PLAN (d1
    WHERE d1.seq <= group_cnt)
   ORDER BY d1.seq
   HEAD REPORT
    line = fillstring(125,"_"), end_line = fillstring(156,"_")
   HEAD PAGE
    col 0, "{PS/792 0 translate 90 rotate/}", row + 1,
    "{cpi/12}", row + 1, col 50,
    "DOSE RANGE PREMISE CHECKING REPORT", row + 1, col 1,
    "Date: ", dttm = format(cnvtdatetime(curdate,curtime3),cclfmt->shortdatetime), col 7,
    dttm, pageend = concat("Page no: ",cnvtstring(curpage)), col 110,
    pageend, row + 1, col 1,
    line, row + 1, "{cpi/15}",
    row + 1
   HEAD d1.seq
    col 1, "Group name: ", col 13,
    rpt2->group[d1.seq].group_name
   DETAIL
    row + 1
    FOR (x = 1 TO size(rpt2->group[d1.seq].warnings,5))
      IF ((rpt2->group[d1.seq].warnings[x].group_ind=0))
       row + 1
       CASE (rpt2->group[d1.seq].warnings[x].type)
        OF iage_gap:
         col 5,"AGE GAP"
        OF iage_overlap:
         col 5,"AGE OVERLAP"
        OF iweight_gap:
         col 5,"WEIGHT GAP"
        OF iweight_overlap:
         col 5,"WEIGHT OVERLAP"
        OF icrcl_overlap:
         col 5,"CRCL OVERLAP"
        OF ipma_overlap:
         col 5,"PMA OVERLAP"
        ELSE
         CALL echo(build("Can't recognize the warning type:",rpt2->group[d1.seq].warnings[x].type))
       ENDCASE
       row + 1
      ENDIF
      col 10, "Age Op", col 21,
      "Age1", col 32, "Age2",
      col 43, "Age Unit", col 54,
      "Wgt Op", col 65, "Weight1",
      col 76, "Weight2", col 87,
      "Wgt Unit", col 98, "Crcl Op",
      col 109, "Crcl1", col 118,
      "Crcl2", col 127, "Crcl Unit",
      col 138, "Route(s)", row + 1,
      col 10, rpt2->group[d1.seq].warnings[x].age_rel_op"##########;L;T", col 21,
      rpt2->group[d1.seq].warnings[x].from_day_str"##########;L;T", col 32, rpt2->group[d1.seq].
      warnings[x].to_day_str"##########;L;T",
      col 43, rpt2->group[d1.seq].warnings[x].age_units_disp"##########;L;T", col 54,
      rpt2->group[d1.seq].warnings[x].wgt_rel_op"##########;L;T", col 65, rpt2->group[d1.seq].
      warnings[x].from_weight_str"##########;L;T",
      col 76, rpt2->group[d1.seq].warnings[x].to_weight_str"##########;L;T", col 87,
      rpt2->group[d1.seq].warnings[x].wgt_units_disp"##########;L;T", col 98, rpt2->group[d1.seq].
      warnings[x].crcl_rel_op"##########;L;T",
      col 109, rpt2->group[d1.seq].warnings[x].from_crcl_str"##########;L;T", col 118,
      rpt2->group[d1.seq].warnings[x].to_crcl_str"##########;L;T", col 127, rpt2->group[d1.seq].
      warnings[x].crcl_units_disp"##########;L;T",
      col 138, rpt2->group[d1.seq].warnings[x].route_disp"##############################;L;T", row +
      1,
      col 87, "Hepatic", col 98,
      "Pma Op", col 109, "Pma1",
      col 118, "Pma2", col 127,
      "Pma Unit", col 138, "Condition",
      row + 1
      IF ((rpt2->group[d1.seq].warnings[x].hepatic_ind=0))
       col 87, "   No"
      ELSE
       col 87, "   Yes"
      ENDIF
      col 98, rpt2->group[d1.seq].warnings[x].pma_rel_op"##########;L;T", col 109,
      rpt2->group[d1.seq].warnings[x].from_pma_str"##########;L;T", col 118, rpt2->group[d1.seq].
      warnings[x].to_pma_str"##########;L;T",
      col 127, rpt2->group[d1.seq].warnings[x].pma_units_disp"##########;L;T", col 138,
      rpt2->group[d1.seq].warnings[x].condition"##############################;L;T", row + 1
    ENDFOR
   FOOT  d1.seq
    col 1, end_line, row + 1
   FOOT REPORT
    row + 1, col 1, "Total number of groupers containing errors: ",
    col 45, group_cnt, row + 1,
    col 55, "End of Report"
   WITH nocounter, nullreport, dio = 08,
    maxrow = 56, maxcol = 200
  ;end select
 ENDIF
 GO TO exit_script
 SUBROUTINE set_warning_type(group_cnt,warn_cnt,aidx,bidx)
   SET acf = reply->qual[aidx].parent_premise[bidx].age_check_flag
   SET wcf = reply->qual[aidx].parent_premise[bidx].weight_check_flag
   SET ccf = reply->qual[aidx].parent_premise[bidx].crcl_check_flag
   SET pcf = reply->qual[aidx].parent_premise[bidx].pma_check_flag
   IF (acf=1)
    SET rpt->group[group_cnt].warnings[warn_cnt].type = iage_gap
   ELSEIF (wcf=1)
    SET rpt->group[group_cnt].warnings[warn_cnt].type = iweight_gap
   ELSEIF (acf=2
    AND wcf=0
    AND ccf=0
    AND pcf=0)
    SET rpt->group[group_cnt].warnings[warn_cnt].type = iage_overlap
   ELSEIF (acf=2
    AND wcf=2
    AND ccf=0
    AND pcf=0)
    SET rpt->group[group_cnt].warnings[warn_cnt].type = iweight_overlap
   ELSEIF (acf=2
    AND wcf=0
    AND ccf=2
    AND pcf=0)
    SET rpt->group[group_cnt].warnings[warn_cnt].type = icrcl_overlap
   ELSEIF (acf=2
    AND wcf=0
    AND ccf=0
    AND pcf=2)
    SET rpt->group[group_cnt].warnings[warn_cnt].type = ipma_overlap
   ELSEIF (acf=2
    AND ((wcf=2) OR (((ccf=2) OR (pcf=2)) )) )
    SET rpt->group[group_cnt].warnings[warn_cnt].type = iage_overlap
   ENDIF
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "002 09/26/06 nc011227"
END GO
