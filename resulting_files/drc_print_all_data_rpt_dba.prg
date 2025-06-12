CREATE PROGRAM drc_print_all_data_rpt:dba
 PROMPT
  "Output to File/Printer/MINE (defaults to MINE)> " = mine,
  "Grouper name begin (defaults to '0')> " = "0",
  "Grouper name end (defaults to 'Z')> " = "Z"
 SET modify = predeclare
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
 FREE SET ranges
 RECORD ranges(
   1 groupers[*]
     2 group_name = vc
     2 facility_display = vc
     2 premise_cnt = i4
     2 premises[*]
       3 parent_premise_id = f8
       3 sort_key = i4
       3 from_day = f8
       3 to_day = f8
       3 from_day_str = vc
       3 to_day_str = vc
       3 age_units_disp = vc
       3 age_rel_op = vc
       3 from_weight = f8
       3 to_weight = f8
       3 from_weight_str = vc
       3 to_weight_str = vc
       3 wgt_units_disp = vc
       3 wgt_rel_op = vc
       3 sort_crcl_key = f8
       3 from_crcl_str = vc
       3 to_crcl_str = vc
       3 crcl_units_disp = vc
       3 crcl_rel_op = vc
       3 from_pmaday = f8
       3 to_pmaday = f8
       3 from_pmaday_str = vc
       3 to_pmaday_str = vc
       3 pma_age_units_disp = vc
       3 pma_age_rel_op = vc
       3 pma_sort_key = f8
       3 sort_hepatic_key = i2
       3 hepatic_flag = vc
       3 sort_concept_key = vc
       3 concept_cki = vc
       3 source_string = vc
       3 route_key = f8
       3 route_prem_id = f8
       3 route_disp = vc
       3 dose_range_cnt = i4
       3 dose_range[*]
         4 drc_dose_range_id = f8
         4 min_value = vc
         4 max_value = vc
         4 value_unit_disp = c40
         4 max_dose = vc
         4 max_unit_disp = c40
         4 type_disp = vc
         4 long_text_id = f8
         4 min_variance_percent = vc
         4 max_variance_percent = vc
 )
 FREE SET sorted_ranges
 RECORD sorted_ranges(
   1 groupers[*]
     2 group_name = vc
     2 facility_display = vc
     2 premise_cnt = i4
     2 premises[*]
       3 parent_premise_id = f8
       3 sort_key = i4
       3 from_day = f8
       3 to_day = f8
       3 from_day_str = vc
       3 to_day_str = vc
       3 age_units_disp = vc
       3 age_rel_op = vc
       3 from_weight = f8
       3 to_weight = f8
       3 from_weight_str = vc
       3 to_weight_str = vc
       3 wgt_units_disp = vc
       3 wgt_rel_op = vc
       3 sort_crcl_key = f8
       3 from_crcl_str = vc
       3 to_crcl_str = vc
       3 crcl_units_disp = vc
       3 crcl_rel_op = vc
       3 from_pmaday = f8
       3 to_pmaday = f8
       3 from_pmaday_str = vc
       3 to_pmaday_str = vc
       3 pma_age_units_disp = vc
       3 pma_age_rel_op = vc
       3 pma_sort_key = f8
       3 sort_hepatic_key = i2
       3 hepatic_flag = vc
       3 sort_concept_key = vc
       3 concept_cki = vc
       3 source_string = vc
       3 route_key = f8
       3 route_prem_id = f8
       3 route_disp = vc
       3 dose_range_cnt = i4
       3 dose_range[*]
         4 drc_dose_range_id = f8
         4 min_value = vc
         4 max_value = vc
         4 value_unit_disp = c40
         4 max_dose = vc
         4 max_unit_disp = c40
         4 type_disp = vc
         4 long_text_id = vc
         4 min_variance_percent = vc
         4 max_variance_percent = vc
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
 DECLARE parsezeroes(f8) = c6
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE number_of_days = f8 WITH public, noconstant(0.0)
 DECLARE number_of_kgs = f8 WITH public, noconstant(0.0)
 DECLARE grpcnt = i4 WITH public, noconstant(0)
 DECLARE x = i4 WITH public, noconstant(0)
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE stat = i2 WITH public, noconstant(0)
 DECLARE number_string = vc WITH public, noconstant(fillstring(255," "))
 DECLARE grp_beg = vc WITH public, noconstant(" ")
 DECLARE grp_end = vc WITH public, noconstant(" ")
 DECLARE sort_key = vc WITH public
 DECLARE flexed = vc WITH public, noconstant("F")
 DECLARE dsreturn = vc WITH public, noconstant(fillstring(12," "))
 DECLARE dsvalue = vc WITH public, noconstant(fillstring(12," "))
 DECLARE move_fld = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE strfld = vc WITH public, noconstant(fillstring(12," "))
 DECLARE sig_dig = i2 WITH public, noconstant(0)
 DECLARE sig_dec = i2 WITH public, noconstant(0)
 DECLARE str_cnt = i4 WITH public, noconstant(0)
 DECLARE len = i4 WITH public, noconstant(0)
 DECLARE p1 = f8 WITH public, noconstant(0.0)
 DECLARE hours = f8 WITH public, noconstant(0.0)
 DECLARE days = f8 WITH public, noconstant(0.0)
 DECLARE weeks = f8 WITH public, noconstant(0.0)
 DECLARE months = f8 WITH public, noconstant(0.0)
 DECLARE years = f8 WITH public, noconstant(0.0)
 DECLARE kg = f8 WITH public, noconstant(0.0)
 DECLARE gram = f8 WITH public, noconstant(0.0)
 DECLARE ounce = f8 WITH public, noconstant(0.0)
 DECLARE lbs = f8 WITH public, noconstant(0.0)
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
 SET grp_beg = cnvtupper(build( $2,"*"))
 SET grp_end = cnvtupper(build( $3,"ZZZZZZZZZZZZZZZZZZZZ"))
 SELECT INTO "nl:"
  FROM dm_info dm
  WHERE dm.info_domain="KNOWLEDGE INDEX APPLICATIONS"
   AND dm.info_name="DRC_FLEX"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET flexed = "T"
 ENDIF
 SELECT INTO "nl:"
  dfr.drc_group_id, dfr.facility_cd, drc.dose_range_check_name,
  drc.content_rule_identifier, drc.build_flag, drc.active_ind,
  dp.drc_premise_id, dp.active_ind, dp2.drc_premise_id,
  dp2.premise_type_flag, dp2.relational_operator_flag, dp2.value_unit_cd,
  dp2.value1, dp2.value2, dp2.active_ind,
  dpl.drc_premise_list_id, dpl.parent_entity_id
  FROM dose_range_check drc,
   drc_facility_r dfr,
   drc_premise dp,
   drc_premise dp2,
   drc_premise_list dpl
  PLAN (dfr
   WHERE dfr.active_ind=1)
   JOIN (drc
   WHERE dfr.dose_range_check_id=drc.dose_range_check_id
    AND drc.active_ind=1
    AND cnvtupper(drc.dose_range_check_name) BETWEEN grp_beg AND grp_end)
   JOIN (dp
   WHERE dp.dose_range_check_id=drc.dose_range_check_id
    AND dp.parent_premise_id=0
    AND dp.active_ind=1)
   JOIN (dp2
   WHERE dp2.parent_premise_id=dp.drc_premise_id
    AND dp2.active_ind=1)
   JOIN (dpl
   WHERE dpl.drc_premise_id=outerjoin(dp2.drc_premise_id)
    AND dpl.active_ind=outerjoin(1))
  ORDER BY drc.dose_range_check_name, uar_get_code_display(dfr.facility_cd), dp.drc_premise_id,
   dp2.drc_premise_id, dpl.parent_entity_id
  HEAD REPORT
   grpcnt = 0
  HEAD dfr.dose_range_check_id
   grpcnt = (grpcnt+ 1)
   IF (mod(grpcnt,10)=1)
    stat = alterlist(ranges->groupers,(grpcnt+ 9))
   ENDIF
   IF (dfr.facility_cd > 0.0)
    ranges->groupers[grpcnt].facility_display = uar_get_code_display(dfr.facility_cd)
   ELSE
    ranges->groupers[grpcnt].facility_display = "Default"
   ENDIF
  HEAD drc.dose_range_check_name
   ranges->groupers[grpcnt].group_name = drc.dose_range_check_name
   IF (flexed="T")
    ranges->groupers[grpcnt].group_name = concat(trim(ranges->groupers[grpcnt].group_name)," - ",
     ranges->groupers[grpcnt].facility_display)
   ENDIF
   ppcnt = 0
  HEAD dp.drc_premise_id
   ppcnt = (ppcnt+ 1)
   IF (mod(ppcnt,10)=1)
    stat = alterlist(ranges->groupers[grpcnt].premises,(ppcnt+ 9))
   ENDIF
   ranges->groupers[grpcnt].premises[ppcnt].parent_premise_id = dp.drc_premise_id, ranges->groupers[
   grpcnt].premises[ppcnt].sort_key = 0, ranges->groupers[grpcnt].premises[ppcnt].hepatic_flag = "NO",
   ranges->groupers[grpcnt].premises[ppcnt].sort_hepatic_key = 0
  HEAD dp2.drc_premise_id
   IF (dp2.premise_type_flag=1)
    ranges->groupers[grpcnt].premises[ppcnt].from_day_str = dp2.value1_string, ranges->groupers[
    grpcnt].premises[ppcnt].to_day_str = dp2.value2_string, ranges->groupers[grpcnt].premises[ppcnt].
    age_units_disp = uar_get_code_display(dp2.value_unit_cd)
    CASE (dp2.relational_operator_flag)
     OF 0:
      IF (dp2.value1 > 0.0
       AND dp2.value_unit_cd > 0.0)
       ranges->groupers[grpcnt].premises[ppcnt].age_rel_op = "="
      ENDIF
     OF 1:
      ranges->groupers[grpcnt].premises[ppcnt].age_rel_op = "<",ranges->groupers[grpcnt].premises[
      ppcnt].from_day = 0,
      CALL convert_to_days(dp2.value1,dp2.value_unit_cd,0)ranges->groupers[grpcnt].premises[ppcnt].
      to_day = number_of_days
     OF 2:
      ranges->groupers[grpcnt].premises[ppcnt].age_rel_op = ">"
     OF 3:
      ranges->groupers[grpcnt].premises[ppcnt].age_rel_op = "<="
     OF 4:
      ranges->groupers[grpcnt].premises[ppcnt].age_rel_op = ">=",
      CALL convert_to_days(dp2.value1,dp2.value_unit_cd,1)ranges->groupers[grpcnt].premises[ppcnt].
      from_day = number_of_days,
      CALL convert_to_days(150,years,0)ranges->groupers[grpcnt].premises[ppcnt].to_day =
      number_of_days
     OF 5:
      ranges->groupers[grpcnt].premises[ppcnt].age_rel_op = "!="
     OF 6:
      ranges->groupers[grpcnt].premises[ppcnt].age_rel_op = "between",
      CALL convert_to_days(dp2.value1,dp2.value_unit_cd,1)ranges->groupers[grpcnt].premises[ppcnt].
      from_day = number_of_days,
      CALL convert_to_days(dp2.value2,dp2.value_unit_cd,0)ranges->groupers[grpcnt].premises[ppcnt].
      to_day = number_of_days
     ELSE
      CALL echo(build("Can't recognize relational operator:",dp2.relational_operator_flag))
    ENDCASE
   ELSEIF (dp2.premise_type_flag=3)
    ranges->groupers[grpcnt].premises[ppcnt].from_weight_str = dp2.value1_string, ranges->groupers[
    grpcnt].premises[ppcnt].to_weight_str = dp2.value2_string, ranges->groupers[grpcnt].premises[
    ppcnt].wgt_units_disp = uar_get_code_display(dp2.value_unit_cd)
    CASE (dp2.relational_operator_flag)
     OF 0:
      IF (dp2.value1 > 0.0
       AND dp2.value_unit_cd > 0.0)
       ranges->groupers[grpcnt].premises[ppcnt].wgt_rel_op = "="
      ENDIF
     OF 1:
      ranges->groupers[grpcnt].premises[ppcnt].wgt_rel_op = "<",ranges->groupers[grpcnt].premises[
      ppcnt].from_weight = 0,
      CALL convert_to_kgs(dp2.value1,dp2.value_unit_cd,dp2.relational_operator_flag)ranges->groupers[
      grpcnt].premises[ppcnt].to_weight = number_of_kgs
     OF 2:
      ranges->groupers[grpcnt].premises[ppcnt].wgt_rel_op = ">"
     OF 3:
      ranges->groupers[grpcnt].premises[ppcnt].wgt_rel_op = "<="
     OF 4:
      ranges->groupers[grpcnt].premises[ppcnt].wgt_rel_op = ">=",
      CALL convert_to_kgs(dp2.value1,dp2.value_unit_cd,dp2.relational_operator_flag)ranges->groupers[
      grpcnt].premises[ppcnt].from_weight = number_of_kgs,
      CALL convert_to_kgs(1000,kg,3)ranges->groupers[grpcnt].premises[ppcnt].to_weight =
      number_of_kgs
     OF 5:
      ranges->groupers[grpcnt].premises[ppcnt].wgt_rel_op = "!="
     OF 6:
      ranges->groupers[grpcnt].premises[ppcnt].wgt_rel_op = "between",
      CALL convert_to_kgs(dp2.value1,dp2.value_unit_cd,4)ranges->groupers[grpcnt].premises[ppcnt].
      from_weight = number_of_kgs,
      CALL convert_to_kgs(dp2.value2,dp2.value_unit_cd,1)ranges->groupers[grpcnt].premises[ppcnt].
      to_weight = number_of_kgs
     ELSE
      CALL echo(build("Can't recognize relational operator:",dp2.relational_operator_flag))
    ENDCASE
   ELSEIF (dp2.premise_type_flag=4)
    ranges->groupers[grpcnt].premises[ppcnt].from_crcl_str = dp2.value1_string, ranges->groupers[
    grpcnt].premises[ppcnt].to_crcl_str = dp2.value2_string, ranges->groupers[grpcnt].premises[ppcnt]
    .crcl_units_disp = uar_get_code_display(dp2.value_unit_cd),
    ranges->groupers[grpcnt].premises[ppcnt].sort_crcl_key = (dp2.value1+ dp2.value2), ranges->
    groupers[grpcnt].premises[ppcnt].sort_key = (ranges->groupers[grpcnt].premises[ppcnt].sort_key+ 1
    )
    CASE (dp2.relational_operator_flag)
     OF 0:
      IF (dp2.value1 > 0.0
       AND dp2.value_unit_cd > 0.0)
       ranges->groupers[grpcnt].premises[ppcnt].crcl_rel_op = "="
      ENDIF
     OF 1:
      ranges->groupers[grpcnt].premises[ppcnt].crcl_rel_op = "<"
     OF 2:
      ranges->groupers[grpcnt].premises[ppcnt].crcl_rel_op = ">"
     OF 3:
      ranges->groupers[grpcnt].premises[ppcnt].crcl_rel_op = "<="
     OF 4:
      ranges->groupers[grpcnt].premises[ppcnt].crcl_rel_op = ">="
     OF 5:
      ranges->groupers[grpcnt].premises[ppcnt].crcl_rel_op = "!="
     OF 6:
      ranges->groupers[grpcnt].premises[ppcnt].crcl_rel_op = "between"
     ELSE
      CALL echo(build("Can't recognize relational operator:",dp2.relational_operator_flag))
    ENDCASE
   ELSEIF (dp2.premise_type_flag=5)
    ranges->groupers[grpcnt].premises[ppcnt].from_pmaday_str = dp2.value1_string, ranges->groupers[
    grpcnt].premises[ppcnt].to_pmaday_str = dp2.value2_string, ranges->groupers[grpcnt].premises[
    ppcnt].pma_age_units_disp = uar_get_code_display(dp2.value_unit_cd),
    ranges->groupers[grpcnt].premises[ppcnt].sort_key = (ranges->groupers[grpcnt].premises[ppcnt].
    sort_key+ 4)
    CASE (dp2.relational_operator_flag)
     OF 1:
      ranges->groupers[grpcnt].premises[ppcnt].pma_age_rel_op = "<",ranges->groupers[grpcnt].
      premises[ppcnt].from_pmaday = 0,
      CALL convert_to_days(dp2.value1,dp2.value_unit_cd,0)ranges->groupers[grpcnt].premises[ppcnt].
      to_pmaday = number_of_days,ranges->groupers[grpcnt].premises[ppcnt].pma_sort_key =
      number_of_days
     OF 4:
      ranges->groupers[grpcnt].premises[ppcnt].pma_age_rel_op = ">=",
      CALL convert_to_days(dp2.value1,dp2.value_unit_cd,1)ranges->groupers[grpcnt].premises[ppcnt].
      from_pmaday = number_of_days,
      ranges->groupers[grpcnt].premises[ppcnt].pma_sort_key = number_of_days,
      CALL convert_to_days(150,years,0)ranges->groupers[grpcnt].premises[ppcnt].to_pmaday =
      number_of_days,
      ranges->groupers[grpcnt].premises[ppcnt].pma_sort_key = (ranges->groupers[grpcnt].premises[
      ppcnt].pma_sort_key+ number_of_days)
     OF 6:
      ranges->groupers[grpcnt].premises[ppcnt].pma_age_rel_op = "between",
      CALL convert_to_days(dp2.value1,dp2.value_unit_cd,1)ranges->groupers[grpcnt].premises[ppcnt].
      from_pmaday = number_of_days,
      ranges->groupers[grpcnt].premises[ppcnt].pma_sort_key = number_of_days,
      CALL convert_to_days(dp2.value2,dp2.value_unit_cd,0)ranges->groupers[grpcnt].premises[ppcnt].
      to_pmaday = number_of_days,
      ranges->groupers[grpcnt].premises[ppcnt].pma_sort_key = (ranges->groupers[grpcnt].premises[
      ppcnt].pma_sort_key+ number_of_days)
     ELSE
      CALL echo(build("Can't recognize relational operator:",dp2.relational_operator_flag))
    ENDCASE
   ELSEIF (dp2.premise_type_flag=6)
    IF (dp2.value1=0)
     ranges->groupers[grpcnt].premises[ppcnt].hepatic_flag = "NO"
    ELSE
     ranges->groupers[grpcnt].premises[ppcnt].hepatic_flag = "YES"
    ENDIF
    ranges->groupers[grpcnt].premises[ppcnt].sort_hepatic_key = dp2.value1, ranges->groupers[grpcnt].
    premises[ppcnt].sort_key = (ranges->groupers[grpcnt].premises[ppcnt].sort_key+ 2)
   ELSEIF (dp2.premise_type_flag=7)
    ranges->groupers[grpcnt].premises[ppcnt].concept_cki = dp2.concept_cki, ranges->groupers[grpcnt].
    premises[ppcnt].sort_key = (ranges->groupers[grpcnt].premises[ppcnt].sort_key+ 8)
   ELSE
    ranges->groupers[grpcnt].premises[ppcnt].route_prem_id = dp2.drc_premise_id
    IF (dp2.value1 > 0.0)
     ranges->groupers[grpcnt].premises[ppcnt].route_key = dp2.value1, ranges->groupers[grpcnt].
     premises[ppcnt].route_disp = dp2.value1_string
    ENDIF
   ENDIF
   route_str = fillstring(100," "), start = 1
  HEAD dpl.parent_entity_id
   row + 0
  DETAIL
   IF (dp2.premise_type_flag=2
    AND dpl.drc_premise_id > 0.0
    AND dpl.parent_entity_id > 0.0)
    IF ((ranges->groupers[grpcnt].premises[ppcnt].route_key=0.0))
     ranges->groupers[grpcnt].premises[ppcnt].route_key = (dpl.parent_entity_id/ 1000)
    ELSE
     ranges->groupers[grpcnt].premises[ppcnt].route_key = ((ranges->groupers[grpcnt].premises[ppcnt].
     route_key+ (dpl.parent_entity_id/ 1000)) * (22.0/ 7.0))
    ENDIF
    IF (start=1)
     route_str = uar_get_code_display(dpl.parent_entity_id), start = 0
    ELSE
     code_disp = uar_get_code_display(dpl.parent_entity_id), route_str = build(route_str,",",
      code_disp)
    ENDIF
   ENDIF
  FOOT  dpl.parent_entity_id
   row + 0
  FOOT  dp2.drc_premise_id
   IF (trim(route_str) > " "
    AND dp2.premise_type_flag=2)
    ranges->groupers[grpcnt].premises[ppcnt].route_disp = route_str
   ENDIF
  FOOT  dp.drc_premise_id
   row + 0
  FOOT  drc.dose_range_check_name
   ranges->groupers[grpcnt].premise_cnt = ppcnt, stat = alterlist(ranges->groupers[grpcnt].premises,
    ppcnt)
  FOOT  dfr.dose_range_check_id
   row + 0
  FOOT REPORT
   stat = alterlist(ranges->groupers,grpcnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET failed = "T"
  CALL echo("No dose range information found.")
  GO TO exit_script
 ENDIF
 FOR (gloop = 1 TO grpcnt)
   FOR (ploop = 1 TO size(ranges->groupers[gloop].premises,5))
     IF ( NOT ((ranges->groupers[gloop].premises[ploop].concept_cki IN (" ", "", null))))
      SELECT INTO "nl:"
       FROM nomenclature n
       WHERE (n.concept_cki=ranges->groupers[gloop].premises[ploop].concept_cki)
        AND n.primary_cterm_ind=1
        AND n.active_ind=1
       DETAIL
        ranges->groupers[gloop].premises[ploop].source_string = n.source_string, ranges->groupers[
        gloop].premises[ploop].sort_concept_key = n.source_string
       WITH nocounter
      ;end select
     ELSE
      SET ranges->groupers[gloop].premises[ploop].sort_concept_key = "zzzzzzzzzzzzzz"
     ENDIF
   ENDFOR
 ENDFOR
 IF (curqual=0)
  CALL echo("No premises for this given grouper.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  ddr.*
  FROM (dummyt d1  WITH seq = value(grpcnt)),
   (dummyt d2  WITH seq = 100),
   drc_dose_range ddr
  PLAN (d1
   WHERE d1.seq <= grpcnt)
   JOIN (d2
   WHERE (d2.seq <= ranges->groupers[d1.seq].premise_cnt))
   JOIN (ddr
   WHERE (ddr.drc_premise_id=ranges->groupers[d1.seq].premises[d2.seq].parent_premise_id)
    AND ddr.active_ind=1)
  ORDER BY ddr.drc_premise_id, ddr.type_flag
  HEAD ddr.drc_premise_id
   dcnt = 0
  DETAIL
   dcnt = (dcnt+ 1)
   IF (mod(dcnt,10)=1)
    stat = alterlist(ranges->groupers[d1.seq].premises[d2.seq].dose_range,(dcnt+ 9))
   ENDIF
   ranges->groupers[d1.seq].premises[d2.seq].dose_range[dcnt].drc_dose_range_id = ddr
   .drc_dose_range_id,
   CALL format_number(ddr.min_value), ranges->groupers[d1.seq].premises[d2.seq].dose_range[dcnt].
   min_value = number_string,
   CALL format_number(ddr.max_value), ranges->groupers[d1.seq].premises[d2.seq].dose_range[dcnt].
   max_value = number_string, ranges->groupers[d1.seq].premises[d2.seq].dose_range[dcnt].
   value_unit_disp = uar_get_code_display(ddr.value_unit_cd),
   CALL format_number(ddr.max_dose), ranges->groupers[d1.seq].premises[d2.seq].dose_range[dcnt].
   max_dose = number_string, ranges->groupers[d1.seq].premises[d2.seq].dose_range[dcnt].max_unit_disp
    = uar_get_code_display(ddr.max_dose_unit_cd),
   dsvalue = parsezeroes((ddr.min_variance_pct * 100)), ranges->groupers[d1.seq].premises[d2.seq].
   dose_range[dcnt].min_variance_percent = dsvalue, dsvalue = parsezeroes((ddr.max_variance_pct * 100
    )),
   ranges->groupers[d1.seq].premises[d2.seq].dose_range[dcnt].max_variance_percent = dsvalue
   CASE (ddr.type_flag)
    OF 1:
     ranges->groupers[d1.seq].premises[d2.seq].dose_range[dcnt].type_disp = "single"
    OF 2:
     ranges->groupers[d1.seq].premises[d2.seq].dose_range[dcnt].type_disp = "daily"
    OF 3:
     ranges->groupers[d1.seq].premises[d2.seq].dose_range[dcnt].type_disp = "therapy"
    OF 4:
     ranges->groupers[d1.seq].premises[d2.seq].dose_range[dcnt].type_disp = concat(trim(cnvtstring(
        ddr.dose_days))," days")
    OF 5:
     ranges->groupers[d1.seq].premises[d2.seq].dose_range[dcnt].type_disp = "n/a"
    OF 6:
     ranges->groupers[d1.seq].premises[d2.seq].dose_range[dcnt].type_disp = "cont infusion"
    OF 7:
     ranges->groupers[d1.seq].premises[d2.seq].dose_range[dcnt].type_disp = "lifetime"
    ELSE
     ranges->groupers[d1.seq].premises[d2.seq].dose_range[dcnt].type_disp = ""
   ENDCASE
   IF (ddr.min_value=0.0
    AND ddr.max_value=0.0)
    ranges->groupers[d1.seq].premises[d2.seq].dose_range[dcnt].type_disp = "n/a"
   ENDIF
   ranges->groupers[d1.seq].premises[d2.seq].dose_range[dcnt].long_text_id = ddr.long_text_id
  FOOT  ddr.drc_premise_id
   stat = alterlist(ranges->groupers[d1.seq].premises[d2.seq].dose_range,dcnt), ranges->groupers[d1
   .seq].premises[d2.seq].dose_range_cnt = dcnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SET stat = alterlist(sorted_ranges->groupers,grpcnt)
 FOR (x = 1 TO grpcnt)
   SELECT INTO "nl:"
    ranges->groupers[x].premises[d.seq].route_key, ranges->groupers[x].premises[d.seq].
    sort_concept_key, ranges->groupers[x].premises[d.seq].sort_hepatic_key,
    ranges->groupers[x].premises[d.seq].from_day, ranges->groupers[x].premises[d.seq].to_day, ranges
    ->groupers[x].premises[d.seq].from_weight,
    ranges->groupers[x].premises[d.seq].to_weight, ranges->groupers[x].premises[d.seq].sort_crcl_key,
    sort_key = ranges->groupers[x].premises[d.seq].sort_key,
    pma_key = ranges->groupers[x].premises[d.seq].pma_sort_key
    FROM (dummyt d  WITH seq = value(ranges->groupers[x].premise_cnt))
    PLAN (d
     WHERE (d.seq <= ranges->groupers[x].premise_cnt))
    ORDER BY ranges->groupers[x].premises[d.seq].route_key, sort_key DESC, ranges->groupers[x].
     premises[d.seq].sort_concept_key,
     ranges->groupers[x].premises[d.seq].from_day, ranges->groupers[x].premises[d.seq].to_day,
     pma_key,
     ranges->groupers[x].premises[d.seq].sort_hepatic_key, ranges->groupers[x].premises[d.seq].
     sort_crcl_key, ranges->groupers[x].premises[d.seq].from_weight,
     ranges->groupers[x].premises[d.seq].to_weight
    HEAD REPORT
     stat = alterlist(sorted_ranges->groupers[x].premises,ranges->groupers[x].premise_cnt), sortcnt
      = 0, sorted_ranges->groupers[x].group_name = ranges->groupers[x].group_name,
     sorted_ranges->groupers[x].facility_display = ranges->groupers[x].facility_display,
     sorted_ranges->groupers[x].premise_cnt = ranges->groupers[x].premise_cnt
    HEAD d.seq
     sortcnt = (sortcnt+ 1), sorted_ranges->groupers[x].premises[sortcnt].parent_premise_id = ranges
     ->groupers[x].premises[d.seq].parent_premise_id, sorted_ranges->groupers[x].premises[sortcnt].
     sort_key = ranges->groupers[x].premises[d.seq].sort_key,
     sorted_ranges->groupers[x].premises[sortcnt].from_day = ranges->groupers[x].premises[d.seq].
     from_day, sorted_ranges->groupers[x].premises[sortcnt].to_day = ranges->groupers[x].premises[d
     .seq].to_day, sorted_ranges->groupers[x].premises[sortcnt].age_rel_op = ranges->groupers[x].
     premises[d.seq].age_rel_op,
     sorted_ranges->groupers[x].premises[sortcnt].from_day_str = ranges->groupers[x].premises[d.seq].
     from_day_str, sorted_ranges->groupers[x].premises[sortcnt].to_day_str = ranges->groupers[x].
     premises[d.seq].to_day_str, sorted_ranges->groupers[x].premises[sortcnt].age_units_disp = ranges
     ->groupers[x].premises[d.seq].age_units_disp,
     sorted_ranges->groupers[x].premises[sortcnt].from_weight = ranges->groupers[x].premises[d.seq].
     from_weight, sorted_ranges->groupers[x].premises[sortcnt].to_weight = ranges->groupers[x].
     premises[d.seq].to_weight, sorted_ranges->groupers[x].premises[sortcnt].from_weight_str = ranges
     ->groupers[x].premises[d.seq].from_weight_str,
     sorted_ranges->groupers[x].premises[sortcnt].to_weight_str = ranges->groupers[x].premises[d.seq]
     .to_weight_str, sorted_ranges->groupers[x].premises[sortcnt].wgt_units_disp = ranges->groupers[x
     ].premises[d.seq].wgt_units_disp, sorted_ranges->groupers[x].premises[sortcnt].wgt_rel_op =
     ranges->groupers[x].premises[d.seq].wgt_rel_op,
     sorted_ranges->groupers[x].premises[sortcnt].from_crcl_str = ranges->groupers[x].premises[d.seq]
     .from_crcl_str, sorted_ranges->groupers[x].premises[sortcnt].to_crcl_str = ranges->groupers[x].
     premises[d.seq].to_crcl_str, sorted_ranges->groupers[x].premises[sortcnt].crcl_units_disp =
     ranges->groupers[x].premises[d.seq].crcl_units_disp,
     sorted_ranges->groupers[x].premises[sortcnt].crcl_rel_op = ranges->groupers[x].premises[d.seq].
     crcl_rel_op, sorted_ranges->groupers[x].premises[sortcnt].from_pmaday = ranges->groupers[x].
     premises[d.seq].from_pmaday, sorted_ranges->groupers[x].premises[sortcnt].to_pmaday = ranges->
     groupers[x].premises[d.seq].to_pmaday,
     sorted_ranges->groupers[x].premises[sortcnt].pma_age_rel_op = ranges->groupers[x].premises[d.seq
     ].pma_age_rel_op, sorted_ranges->groupers[x].premises[sortcnt].from_pmaday_str = ranges->
     groupers[x].premises[d.seq].from_pmaday_str, sorted_ranges->groupers[x].premises[sortcnt].
     to_pmaday_str = ranges->groupers[x].premises[d.seq].to_pmaday_str,
     sorted_ranges->groupers[x].premises[sortcnt].pma_age_units_disp = ranges->groupers[x].premises[d
     .seq].pma_age_units_disp, sorted_ranges->groupers[x].premises[sortcnt].pma_sort_key = ranges->
     groupers[x].premises[d.seq].pma_sort_key, sorted_ranges->groupers[x].premises[sortcnt].
     sort_hepatic_key = ranges->groupers[x].premises[d.seq].sort_hepatic_key,
     sorted_ranges->groupers[x].premises[sortcnt].hepatic_flag = ranges->groupers[x].premises[d.seq].
     hepatic_flag
     IF ((ranges->groupers[x].premises[d.seq].sort_concept_key="zzzzzzzzzzzzzz"))
      sorted_ranges->groupers[x].premises[sortcnt].sort_concept_key = ""
     ELSE
      sorted_ranges->groupers[x].premises[sortcnt].sort_concept_key = ranges->groupers[x].premises[d
      .seq].sort_concept_key
     ENDIF
     sorted_ranges->groupers[x].premises[sortcnt].concept_cki = ranges->groupers[x].premises[d.seq].
     concept_cki, sorted_ranges->groupers[x].premises[sortcnt].source_string = ranges->groupers[x].
     premises[d.seq].source_string, sorted_ranges->groupers[x].premises[sortcnt].route_key = ranges->
     groupers[x].premises[d.seq].route_key,
     sorted_ranges->groupers[x].premises[sortcnt].route_disp = ranges->groupers[x].premises[d.seq].
     route_disp, sorted_ranges->groupers[x].premises[sortcnt].route_prem_id = ranges->groupers[x].
     premises[d.seq].route_prem_id, sorted_ranges->groupers[x].premises[sortcnt].dose_range_cnt =
     ranges->groupers[x].premises[d.seq].dose_range_cnt,
     stat = alterlist(sorted_ranges->groupers[x].premises[sortcnt].dose_range,ranges->groupers[x].
      premises[d.seq].dose_range_cnt)
     FOR (y = 1 TO ranges->groupers[x].premises[d.seq].dose_range_cnt)
       sorted_ranges->groupers[x].premises[sortcnt].dose_range[y].drc_dose_range_id = ranges->
       groupers[x].premises[d.seq].dose_range[y].drc_dose_range_id, sorted_ranges->groupers[x].
       premises[sortcnt].dose_range[y].min_value = ranges->groupers[x].premises[d.seq].dose_range[y].
       min_value, sorted_ranges->groupers[x].premises[sortcnt].dose_range[y].max_value = ranges->
       groupers[x].premises[d.seq].dose_range[y].max_value,
       sorted_ranges->groupers[x].premises[sortcnt].dose_range[y].value_unit_disp = ranges->groupers[
       x].premises[d.seq].dose_range[y].value_unit_disp, sorted_ranges->groupers[x].premises[sortcnt]
       .dose_range[y].max_dose = ranges->groupers[x].premises[d.seq].dose_range[y].max_dose,
       sorted_ranges->groupers[x].premises[sortcnt].dose_range[y].max_unit_disp = ranges->groupers[x]
       .premises[d.seq].dose_range[y].max_unit_disp
       IF ((ranges->groupers[x].premises[d.seq].dose_range[y].min_variance_percent=""))
        sorted_ranges->groupers[x].premises[sortcnt].dose_range[y].min_variance_percent = "0"
       ELSE
        sorted_ranges->groupers[x].premises[sortcnt].dose_range[y].min_variance_percent = ranges->
        groupers[x].premises[d.seq].dose_range[y].min_variance_percent
       ENDIF
       IF ((ranges->groupers[x].premises[d.seq].dose_range[y].max_variance_percent=""))
        sorted_ranges->groupers[x].premises[sortcnt].dose_range[y].max_variance_percent = "0"
       ELSE
        sorted_ranges->groupers[x].premises[sortcnt].dose_range[y].max_variance_percent = ranges->
        groupers[x].premises[d.seq].dose_range[y].max_variance_percent
       ENDIF
       sorted_ranges->groupers[x].premises[sortcnt].dose_range[y].type_disp = ranges->groupers[x].
       premises[d.seq].dose_range[y].type_disp
       IF ((ranges->groupers[x].premises[d.seq].dose_range[y].long_text_id > 0))
        sorted_ranges->groupers[x].premises[sortcnt].dose_range[y].long_text_id = "Y"
       ELSE
        sorted_ranges->groupers[x].premises[sortcnt].dose_range[y].long_text_id = "N"
       ENDIF
     ENDFOR
    FOOT REPORT
     row + 0
    WITH nocounter
   ;end select
 ENDFOR
 FREE RECORD ranges
 SELECT INTO  $1
  *
  FROM (dummyt d1  WITH seq = value(grpcnt)),
   (dummyt d2  WITH seq = 100)
  PLAN (d1)
   JOIN (d2
   WHERE (d2.seq <= sorted_ranges->groupers[d1.seq].premise_cnt))
  HEAD REPORT
   line = fillstring(125,"_"), end_line = fillstring(156,"_")
  HEAD PAGE
   col 0, "{PS/792 0 translate 90 rotate/}", row + 1,
   "{cpi/12}", row + 1, col 50,
   "DOSE RANGE CHECKING DATA REPORT", row + 1, col 1,
   "Date: ", dttm = format(cnvtdatetime(curdate,curtime3),cclfmt->shortdatetime), col 7,
   dttm, pageend = concat("Page no: ",cnvtstring(curpage)), col 110,
   pageend, row + 1, rpt_range = concat("Grouper name(s) ranging from '",build( $2,"*"),"' to '",
    build( $3,"*"),"'"),
   col 1, rpt_range, row + 1,
   col 1, line, row + 1,
   "{cpi/15}", row + 1
  HEAD d1.seq
   col 1, "Group name: ", col 13,
   sorted_ranges->groupers[d1.seq].group_name, row + 2, col 1,
   "Age Op", col 9, "Age1",
   col 15, "Age2", col 21,
   "AGE Unit", col 31, "PMA Op",
   col 39, "PMA1", col 45,
   "PMA2", col 51, "PMA Unit",
   col 61, "Wgt Op", col 69,
   "Wgt1", col 75, "Wgt2",
   col 81, "Wgt Unit", col 91,
   "CrCl Op", col 100, "CrCl1",
   col 107, "CrCl2", col 114,
   "CrCl Unit", col 125, "Hep Dysf",
   col 135, "Route(s)", col 148,
   "Clin Cond", row + 1, col 1,
   "-------", col 9, "-----",
   col 15, "-----", col 21,
   "--------", col 31, "-------",
   col 39, "-----", col 45,
   "-----", col 51, "--------",
   col 61, "-------", col 69,
   "-----", col 75, "-----",
   col 81, "---------", col 91,
   "--------", col 100, "-----",
   col 107, "-----", col 114,
   "---------", col 125, "--------",
   col 135, "-----------", col 148,
   "---------", row + 1
  HEAD d2.seq
   col 1, sorted_ranges->groupers[d1.seq].premises[d2.seq].age_rel_op"########;L;T", col 9,
   sorted_ranges->groupers[d1.seq].premises[d2.seq].from_day_str"#####;L;T", col 15, sorted_ranges->
   groupers[d1.seq].premises[d2.seq].to_day_str"#####;L;T",
   col 21, sorted_ranges->groupers[d1.seq].premises[d2.seq].age_units_disp"#########;L;T", col 31,
   sorted_ranges->groupers[d1.seq].premises[d2.seq].pma_age_rel_op"########;L;T", col 39,
   sorted_ranges->groupers[d1.seq].premises[d2.seq].from_pmaday_str"#####;L;T",
   col 45, sorted_ranges->groupers[d1.seq].premises[d2.seq].to_pmaday_str"#####;L;T", col 51,
   sorted_ranges->groupers[d1.seq].premises[d2.seq].pma_age_units_disp"#########;L;T", col 61,
   sorted_ranges->groupers[d1.seq].premises[d2.seq].wgt_rel_op"########;L;T",
   col 69, sorted_ranges->groupers[d1.seq].premises[d2.seq].from_weight_str"#####;L;T", col 75,
   sorted_ranges->groupers[d1.seq].premises[d2.seq].to_weight_str"#####;L;T", col 81, sorted_ranges->
   groupers[d1.seq].premises[d2.seq].wgt_units_disp"#########;L;T",
   col 91, sorted_ranges->groupers[d1.seq].premises[d2.seq].crcl_rel_op"########;L;T", col 100,
   sorted_ranges->groupers[d1.seq].premises[d2.seq].from_crcl_str"#####;L;T", col 107, sorted_ranges
   ->groupers[d1.seq].premises[d2.seq].to_crcl_str"#####;L;T",
   col 114, sorted_ranges->groupers[d1.seq].premises[d2.seq].crcl_units_disp"#########;L;T", col 127,
   sorted_ranges->groupers[d1.seq].premises[d2.seq].hepatic_flag"###;L;T", col 135, sorted_ranges->
   groupers[d1.seq].premises[d2.seq].route_disp"###########;L;T",
   col 148, sorted_ranges->groupers[d1.seq].premises[d2.seq].source_string"#########;L;T", row + 1
   IF ((sorted_ranges->groupers[d1.seq].premises[d2.seq].dose_range_cnt > 0))
    col 75, "Ds Type", col 89,
    "Ds1", col 96, "Ds2",
    col 103, "Ds Unit", col 115,
    "Mx Ds", col 123, "Mx Ds Unit",
    col 135, "Var1%", col 142,
    "Var2%", col 149, "Cmnts",
    row + 1, col 75, "------------",
    col 89, "-----", col 96,
    "-----", col 103, "----------",
    col 115, "-----", col 123,
    "----------", col 135, "-----",
    col 142, "-----", col 149,
    "-----", row + 1
   ENDIF
   FOR (x = 1 TO sorted_ranges->groupers[d1.seq].premises[d2.seq].dose_range_cnt)
     col 75, sorted_ranges->groupers[d1.seq].premises[d2.seq].dose_range[x].type_disp"#######;L;T",
     col 89,
     sorted_ranges->groupers[d1.seq].premises[d2.seq].dose_range[x].min_value"#####;L;T", col 96,
     sorted_ranges->groupers[d1.seq].premises[d2.seq].dose_range[x].max_value"#####;L;T",
     col 103, sorted_ranges->groupers[d1.seq].premises[d2.seq].dose_range[x].value_unit_disp
     "##########;L;T", col 115,
     sorted_ranges->groupers[d1.seq].premises[d2.seq].dose_range[x].max_dose"#####;L;T", col 123,
     sorted_ranges->groupers[d1.seq].premises[d2.seq].dose_range[x].max_unit_disp"##########;L;T",
     col 135, sorted_ranges->groupers[d1.seq].premises[d2.seq].dose_range[x].min_variance_percent
     "###.##;R;T", col 142,
     sorted_ranges->groupers[d1.seq].premises[d2.seq].dose_range[x].max_variance_percent"###.##;R;T",
     col 149, sorted_ranges->groupers[d1.seq].premises[d2.seq].dose_range[x].long_text_id"#;L;T",
     row + 1
     IF ((x=sorted_ranges->groupers[d1.seq].premises[d2.seq].dose_range_cnt))
      row + 1
     ENDIF
   ENDFOR
  DETAIL
   row + 0
  FOOT  d2.seq
   row + 0
  FOOT  d1.seq
   col 1, end_line, row + 1
  FOOT REPORT
   row + 1, col 55, "End of Report"
  WITH nocounter, nullreport, dio = 08,
   maxrow = 56, maxcol = 200
 ;end select
 GO TO exit_script
 SUBROUTINE parsezeroes(p1)
   SET dsreturn = fillstring(12," ")
   SET dsvalue = fillstring(12," ")
   SET move_fld = fillstring(12," ")
   SET strfld = fillstring(12," ")
   SET sig_dig = 0
   SET sig_dec = 0
   SET strfld = cnvtstring(p1,12,4,r)
   SET str_cnt = 1
   SET len = 0
   WHILE (str_cnt < 8
    AND substring(str_cnt,1,strfld) IN ("0", " "))
     SET str_cnt = (str_cnt+ 1)
   ENDWHILE
   SET sig_dig = (str_cnt - 1)
   SET str_cnt = 12
   WHILE (str_cnt > 7
    AND substring(str_cnt,1,strfld) IN ("0", " "))
     SET str_cnt = (str_cnt - 1)
   ENDWHILE
   IF (str_cnt=8
    AND substring(str_cnt,1,strfld)=".")
    SET str_cnt = (str_cnt - 1)
   ENDIF
   SET sig_dec = str_cnt
   IF (sig_dig=7
    AND str_cnt=7)
    SET dsvalue = ""
   ELSE
    SET len = movestring(strfld,(sig_dig+ 1),move_fld,1,(sig_dec - sig_dig))
    SET dsvalue = trim(move_fld)
    IF (substring(1,1,dsvalue)=".")
     SET dsvalue = concat("0",trim(move_fld))
    ENDIF
   ENDIF
   RETURN(dsvalue)
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "003 09/26/2006 NC011227"
END GO
