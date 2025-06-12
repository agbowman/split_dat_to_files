CREATE PROGRAM drc_find_invalid_operator2:dba
 PROMPT
  "Output to File/Printer/MINE " = mine
 FREE SET reply
 RECORD reply(
   1 group[*]
     2 group_name = vc
     2 grp_warn_cnt = i4
     2 warnings[*]
       3 parent_premise_id = f8
       3 group_cnt = i4
       3 from_day_str = vc
       3 to_day_str = vc
       3 age_units_disp = vc
       3 age_rel_op = vc
       3 from_weight_str = vc
       3 to_weight_str = vc
       3 wgt_units_disp = vc
       3 wgt_rel_op = vc
       3 route_prem_id = f8
       3 route_disp = vc
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
     2 premise_cnt = i4
     2 premises[*]
       3 parent_premise_id = f8
       3 from_day = f8
       3 to_day = f8
       3 from_day_str = vc
       3 to_day_str = vc
       3 age_units_disp = vc
       3 age_rel_op = vc
       3 age_rel_op_flag = i2
       3 from_weight = f8
       3 to_weight = f8
       3 from_weight_str = vc
       3 to_weight_str = vc
       3 wgt_units_disp = vc
       3 wgt_rel_op = vc
       3 wgt_rel_op_flag = i2
       3 route_key = f8
       3 route_prem_id = f8
 )
 FREE SET sorted_ranges
 RECORD sorted_ranges(
   1 groupers[*]
     2 group_name = vc
     2 premise_cnt = i4
     2 premises[*]
       3 parent_premise_id = f8
       3 from_day = f8
       3 to_day = f8
       3 from_day_str = vc
       3 to_day_str = vc
       3 age_units_disp = vc
       3 age_rel_op = vc
       3 age_rel_op_flag = i2
       3 from_weight = f8
       3 to_weight = f8
       3 from_weight_str = vc
       3 to_weight_str = vc
       3 wgt_units_disp = vc
       3 wgt_rel_op = vc
       3 wgt_rel_op_flag = i2
       3 route_key = f8
       3 route_prem_id = f8
 )
 DECLARE store_warn_info(aidx=i4,bidx=i4,cidx=i4,didx=i4) = null
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE number_of_days = f8 WITH public, noconstant(0.0)
 DECLARE number_of_kgs = f8 WITH public, noconstant(0.0)
 DECLARE grpcnt = i4 WITH public, noconstant(0)
 DECLARE x = i4 WITH public, noconstant(0)
 DECLARE warn_cnt = i4 WITH public, noconstant(0)
 DECLARE grp_warn_cnt = i4 WITH public, noconstant(0)
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
 SELECT INTO "nl:"
  drc.dose_range_check_name, drc.content_rule_identifier, drc.build_flag,
  drc.active_ind, dp.drc_premise_id, dp.active_ind,
  dp2.drc_premise_id, dp2.premise_type_flag, dp2.relational_operator_flag,
  dp2.value_unit_cd, dp2.value1, dp2.value2,
  dp2.active_ind, dpl.drc_premise_list_id, dpl.parent_entity_id
  FROM dose_range_check drc,
   drc_premise dp,
   drc_premise dp2,
   drc_premise_list dpl
  PLAN (drc)
   JOIN (dp
   WHERE dp.dose_range_check_id=drc.dose_range_check_id
    AND dp.parent_premise_id=0
    AND ((drc.active_ind=1
    AND dp.active_ind=1) OR (drc.active_ind=0
    AND dp.active_ind IN (0, 1))) )
   JOIN (dp2
   WHERE dp2.parent_premise_id=dp.drc_premise_id
    AND ((drc.active_ind=1
    AND dp2.active_ind=1) OR (drc.active_ind=0
    AND dp2.active_ind IN (0, 1))) )
   JOIN (dpl
   WHERE dpl.drc_premise_id=outerjoin(dp2.drc_premise_id))
  ORDER BY drc.dose_range_check_name, dp.drc_premise_id, dp2.drc_premise_id,
   dpl.parent_entity_id
  HEAD REPORT
   grpcnt = 0
  HEAD drc.dose_range_check_name
   grpcnt = (grpcnt+ 1)
   IF (mod(grpcnt,10)=1)
    stat = alterlist(ranges->groupers,(grpcnt+ 9))
   ENDIF
   ranges->groupers[grpcnt].group_name = drc.dose_range_check_name, ppcnt = 0
  HEAD dp.drc_premise_id
   ppcnt = (ppcnt+ 1)
   IF (mod(ppcnt,10)=1)
    stat = alterlist(ranges->groupers[grpcnt].premises,(ppcnt+ 9))
   ENDIF
   ranges->groupers[grpcnt].premises[ppcnt].parent_premise_id = dp.drc_premise_id
  HEAD dp2.drc_premise_id
   IF (dp2.premise_type_flag=1)
    ranges->groupers[grpcnt].premises[ppcnt].from_day_str = dp2.value1_string, ranges->groupers[
    grpcnt].premises[ppcnt].to_day_str = dp2.value2_string, ranges->groupers[grpcnt].premises[ppcnt].
    age_units_disp = uar_get_code_display(dp2.value_unit_cd)
    CASE (dp2.relational_operator_flag)
     OF 0:
      IF (dp2.value1 > 0.0
       AND dp2.value_unit_cd > 0.0)
       ranges->groupers[grpcnt].premises[ppcnt].age_rel_op = "=", ranges->groupers[grpcnt].premises[
       ppcnt].age_rel_op_flag = 1
      ENDIF
     OF 1:
      ranges->groupers[grpcnt].premises[ppcnt].age_rel_op = "<",ranges->groupers[grpcnt].premises[
      ppcnt].from_day = 0,
      CALL convert_to_days(dp2.value1,dp2.value_unit_cd,0)ranges->groupers[grpcnt].premises[ppcnt].
      to_day = number_of_days
     OF 2:
      ranges->groupers[grpcnt].premises[ppcnt].age_rel_op = ">",ranges->groupers[grpcnt].premises[
      ppcnt].age_rel_op_flag = 1
     OF 3:
      ranges->groupers[grpcnt].premises[ppcnt].age_rel_op = "<=",ranges->groupers[grpcnt].premises[
      ppcnt].age_rel_op_flag = 1
     OF 4:
      ranges->groupers[grpcnt].premises[ppcnt].age_rel_op = ">=",
      CALL convert_to_days(dp2.value1,dp2.value_unit_cd,1)ranges->groupers[grpcnt].premises[ppcnt].
      from_day = number_of_days,
      CALL convert_to_days(150,years,0)ranges->groupers[grpcnt].premises[ppcnt].to_day =
      number_of_days
     OF 5:
      ranges->groupers[grpcnt].premises[ppcnt].age_rel_op = "!=",ranges->groupers[grpcnt].premises[
      ppcnt].age_rel_op_flag = 1
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
       ranges->groupers[grpcnt].premises[ppcnt].wgt_rel_op = "=", ranges->groupers[grpcnt].premises[
       ppcnt].wgt_rel_op_flag = 1
      ENDIF
     OF 1:
      ranges->groupers[grpcnt].premises[ppcnt].wgt_rel_op = "<",ranges->groupers[grpcnt].premises[
      ppcnt].from_weight = 0,
      CALL convert_to_kgs(dp2.value1,dp2.value_unit_cd,dp2.relational_operator_flag)ranges->groupers[
      grpcnt].premises[ppcnt].to_weight = number_of_kgs
     OF 2:
      ranges->groupers[grpcnt].premises[ppcnt].wgt_rel_op = ">",ranges->groupers[grpcnt].premises[
      ppcnt].wgt_rel_op_flag = 1
     OF 3:
      ranges->groupers[grpcnt].premises[ppcnt].wgt_rel_op = "<=",ranges->groupers[grpcnt].premises[
      ppcnt].wgt_rel_op_flag = 1
     OF 4:
      ranges->groupers[grpcnt].premises[ppcnt].wgt_rel_op = ">=",
      CALL convert_to_kgs(dp2.value1,dp2.value_unit_cd,dp2.relational_operator_flag)ranges->groupers[
      grpcnt].premises[ppcnt].from_weight = number_of_kgs,
      CALL convert_to_kgs(1000,kg,3)ranges->groupers[grpcnt].premises[ppcnt].to_weight =
      number_of_kgs
     OF 5:
      ranges->groupers[grpcnt].premises[ppcnt].wgt_rel_op = "!=",ranges->groupers[grpcnt].premises[
      ppcnt].wgt_rel_op_flag = 1
     OF 6:
      ranges->groupers[grpcnt].premises[ppcnt].wgt_rel_op = "between",
      CALL convert_to_kgs(dp2.value1,dp2.value_unit_cd,4)ranges->groupers[grpcnt].premises[ppcnt].
      from_weight = number_of_kgs,
      CALL convert_to_kgs(dp2.value2,dp2.value_unit_cd,1)ranges->groupers[grpcnt].premises[ppcnt].
      to_weight = number_of_kgs
     ELSE
      CALL echo(build("Can't recognize relational operator:",dp2.relational_operator_flag))
    ENDCASE
   ELSE
    ranges->groupers[grpcnt].premises[ppcnt].route_prem_id = dp2.drc_premise_id
    IF (dp2.value1 > 0.0)
     ranges->groupers[grpcnt].premises[ppcnt].route_key = dp2.value1
    ENDIF
   ENDIF
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
   ENDIF
  FOOT  dpl.parent_entity_id
   row + 0
  FOOT  dp2.drc_premise_id
   row + 0
  FOOT  dp.drc_premise_id
   row + 0
  FOOT  drc.dose_range_check_name
   ranges->groupers[grpcnt].premise_cnt = ppcnt, stat = alterlist(ranges->groupers[grpcnt].premises,
    ppcnt)
  FOOT REPORT
   stat = alterlist(ranges->groupers,grpcnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET failed = "T"
  CALL echo("No dose range information found.")
  GO TO exit_script
 ENDIF
 SET stat = alterlist(sorted_ranges->groupers,grpcnt)
 FOR (x = 1 TO grpcnt)
   SELECT INTO "nl:"
    *
    FROM (dummyt d  WITH seq = value(ranges->groupers[x].premise_cnt))
    PLAN (d
     WHERE (d.seq <= ranges->groupers[x].premise_cnt))
    ORDER BY ranges->groupers[x].premises[d.seq].route_key, ranges->groupers[x].premises[d.seq].
     from_day, ranges->groupers[x].premises[d.seq].to_day,
     ranges->groupers[x].premises[d.seq].from_weight, ranges->groupers[x].premises[d.seq].to_weight
    HEAD REPORT
     stat = alterlist(sorted_ranges->groupers[x].premises,ranges->groupers[x].premise_cnt), sortcnt
      = 0, sorted_ranges->groupers[x].group_name = ranges->groupers[x].group_name,
     sorted_ranges->groupers[x].premise_cnt = ranges->groupers[x].premise_cnt
    DETAIL
     sortcnt = (sortcnt+ 1), sorted_ranges->groupers[x].premises[sortcnt].parent_premise_id = ranges
     ->groupers[x].premises[d.seq].parent_premise_id, sorted_ranges->groupers[x].premises[sortcnt].
     from_day = ranges->groupers[x].premises[d.seq].from_day,
     sorted_ranges->groupers[x].premises[sortcnt].to_day = ranges->groupers[x].premises[d.seq].to_day,
     sorted_ranges->groupers[x].premises[sortcnt].age_rel_op = ranges->groupers[x].premises[d.seq].
     age_rel_op, sorted_ranges->groupers[x].premises[sortcnt].from_day_str = ranges->groupers[x].
     premises[d.seq].from_day_str,
     sorted_ranges->groupers[x].premises[sortcnt].to_day_str = ranges->groupers[x].premises[d.seq].
     to_day_str, sorted_ranges->groupers[x].premises[sortcnt].age_units_disp = ranges->groupers[x].
     premises[d.seq].age_units_disp, sorted_ranges->groupers[x].premises[sortcnt].age_rel_op_flag =
     ranges->groupers[x].premises[d.seq].age_rel_op_flag,
     sorted_ranges->groupers[x].premises[sortcnt].from_weight = ranges->groupers[x].premises[d.seq].
     from_weight, sorted_ranges->groupers[x].premises[sortcnt].to_weight = ranges->groupers[x].
     premises[d.seq].to_weight, sorted_ranges->groupers[x].premises[sortcnt].from_weight_str = ranges
     ->groupers[x].premises[d.seq].from_weight_str,
     sorted_ranges->groupers[x].premises[sortcnt].to_weight_str = ranges->groupers[x].premises[d.seq]
     .to_weight_str, sorted_ranges->groupers[x].premises[sortcnt].wgt_units_disp = ranges->groupers[x
     ].premises[d.seq].wgt_units_disp, sorted_ranges->groupers[x].premises[sortcnt].wgt_rel_op =
     ranges->groupers[x].premises[d.seq].wgt_rel_op,
     sorted_ranges->groupers[x].premises[sortcnt].wgt_rel_op_flag = ranges->groupers[x].premises[d
     .seq].wgt_rel_op_flag, sorted_ranges->groupers[x].premises[sortcnt].route_key = ranges->
     groupers[x].premises[d.seq].route_key, sorted_ranges->groupers[x].premises[sortcnt].
     route_prem_id = ranges->groupers[x].premises[d.seq].route_prem_id
    FOOT REPORT
     row + 0
    WITH nocounter
   ;end select
 ENDFOR
 FREE RECORD ranges
 SET x = 0
#start_loop
 SET x = (x+ 1)
 FOR (x = x TO grpcnt)
   CALL echo(build("Checking group:",sorted_ranges->groupers[x].group_name))
   SET grp_warn_cnt = 0
   IF ((sorted_ranges->groupers[x].premise_cnt <= 0))
    GO TO start_loop
   ENDIF
   SELECT INTO "nl:"
    from_day = sorted_ranges->groupers[x].premises[d1.seq].from_day, route = sorted_ranges->groupers[
    x].premises[d1.seq].route_key
    FROM (dummyt d1  WITH seq = value(sorted_ranges->groupers[x].premise_cnt))
    PLAN (d1
     WHERE (d1.seq <= sorted_ranges->groupers[x].premise_cnt))
    ORDER BY route, from_day, sorted_ranges->groupers[x].premises[d1.seq].to_day
    HEAD REPORT
     new_day = true
    HEAD route
     row + 0
    HEAD from_day
     day_index = d1.seq, rel_op_flag = 0
    DETAIL
     IF ((sorted_ranges->groupers[x].premises[d1.seq].wgt_rel_op_flag=1))
      rel_op_flag = 1
     ENDIF
    FOOT  from_day
     IF (rel_op_flag=1)
      FOR (z = day_index TO d1.seq)
        IF (grp_warn_cnt=0)
         warn_cnt = (warn_cnt+ 1), stat = alterlist(reply->group,warn_cnt), reply->group[warn_cnt].
         group_name = sorted_ranges->groupers[x].group_name
        ENDIF
        grp_warn_cnt = (grp_warn_cnt+ 1), reply->group[warn_cnt].grp_warn_cnt = grp_warn_cnt, stat =
        alterlist(reply->group[warn_cnt].warnings,grp_warn_cnt),
        CALL store_warn_info(warn_cnt,grp_warn_cnt,x,z)
      ENDFOR
     ENDIF
    FOOT  route
     row + 0
    WITH nocounter
   ;end select
   IF (grp_warn_cnt > 0
    AND warn_cnt > 0)
    SELECT INTO "nl:"
     dp.drc_premise_id, dp.value_type_flag, dpl.drc_premise_list_id,
     dpl.parent_entity_id, dpl.parent_entity_name
     FROM drc_premise dp,
      drc_premise_list dpl,
      (dummyt d  WITH seq = value(grp_warn_cnt))
     PLAN (d
      WHERE d.seq <= grp_warn_cnt)
      JOIN (dp
      WHERE (dp.drc_premise_id=reply->group[warn_cnt].warnings[d.seq].route_prem_id)
       AND dp.premise_type_flag=2)
      JOIN (dpl
      WHERE dpl.drc_premise_id=outerjoin(dp.drc_premise_id)
       AND dpl.active_ind=outerjoin(1))
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
      reply->group[warn_cnt].warnings[d.seq].route_disp = route_str
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 FREE RECORD sorted_ranges
 SELECT INTO  $1
  *
  FROM (dummyt d1  WITH seq = value(warn_cnt)),
   (dummyt d2  WITH seq = 100)
  PLAN (d1
   WHERE d1.seq <= warn_cnt)
   JOIN (d2
   WHERE (d2.seq <= reply->group[d1.seq].grp_warn_cnt))
  HEAD REPORT
   line = fillstring(130,"-")
  HEAD PAGE
   col 30, "DOSE RANGE CHECKING: INVALID WEIGHT OPERATOR REPORT", row + 1,
   col 1, "Date: ", dttm = format(cnvtdatetime(curdate,curtime3),cclfmt->shortdatetime),
   col 7, dttm, pageend = concat("Page no: ",cnvtstring(curpage)),
   col 110, pageend, row + 1,
   col 1, line, row + 1
  HEAD d1.seq
   col 1, "Group name: ", col 13,
   reply->group[d1.seq].group_name, row + 1, col 5,
   "Age Op", col 16, "Age1",
   col 27, "Age2", col 38,
   "Age Unit", col 49, "Wgt Op",
   col 60, "Weight1", col 71,
   "Weight2", col 82, "Wgt Unit",
   col 93, "Route(s)", row + 1
  DETAIL
   col 5, reply->group[d1.seq].warnings[d2.seq].age_rel_op"##########;L;T", col 16,
   reply->group[d1.seq].warnings[d2.seq].from_day_str"##########;L;T", col 27, reply->group[d1.seq].
   warnings[d2.seq].to_day_str"##########;L;T",
   col 38, reply->group[d1.seq].warnings[d2.seq].age_units_disp"##########;L;T", col 49,
   reply->group[d1.seq].warnings[d2.seq].wgt_rel_op"##########;L;T", col 60, reply->group[d1.seq].
   warnings[d2.seq].from_weight_str"##########;L;T",
   col 71, reply->group[d1.seq].warnings[d2.seq].to_weight_str"##########;L;T", col 82,
   reply->group[d1.seq].warnings[d2.seq].wgt_units_disp"##########;L;T", col 93, reply->group[d1.seq]
   .warnings[d2.seq].route_disp"##############################;L;T",
   row + 1
  FOOT  d1.seq
   col 1, line, row + 1
  FOOT REPORT
   row + 1, col 1, "Total number of groupers containing invalid weight operators: ",
   col 61, warn_cnt, row + 2,
   col 55, "End of Report"
  WITH nocounter, nullreport
 ;end select
 GO TO exit_script
 SUBROUTINE store_warn_info(aidx,bidx,cidx,didx)
   SET reply->group[aidx].warnings[bidx].parent_premise_id = sorted_ranges->groupers[cidx].premises[
   didx].parent_premise_id
   SET reply->group[aidx].warnings[bidx].from_day_str = sorted_ranges->groupers[cidx].premises[didx].
   from_day_str
   SET reply->group[aidx].warnings[bidx].to_day_str = sorted_ranges->groupers[cidx].premises[didx].
   to_day_str
   SET reply->group[aidx].warnings[bidx].age_units_disp = sorted_ranges->groupers[cidx].premises[didx
   ].age_units_disp
   SET reply->group[aidx].warnings[bidx].age_rel_op = sorted_ranges->groupers[cidx].premises[didx].
   age_rel_op
   SET reply->group[aidx].warnings[bidx].from_weight_str = sorted_ranges->groupers[cidx].premises[
   didx].from_weight_str
   SET reply->group[aidx].warnings[bidx].to_weight_str = sorted_ranges->groupers[cidx].premises[didx]
   .to_weight_str
   SET reply->group[aidx].warnings[bidx].wgt_units_disp = sorted_ranges->groupers[cidx].premises[didx
   ].wgt_units_disp
   SET reply->group[aidx].warnings[bidx].wgt_rel_op = sorted_ranges->groupers[cidx].premises[didx].
   wgt_rel_op
   SET reply->group[aidx].warnings[bidx].route_prem_id = sorted_ranges->groupers[cidx].premises[didx]
   .route_prem_id
 END ;Subroutine
 SUBROUTINE convert_to_days(number,units_code,from_or_to)
  SET number_of_days = 0.0
  IF (units_code=years
   AND from_or_to=1
   AND number=1.0)
   SET number_of_days = 360.0
  ELSEIF (units_code=years
   AND from_or_to=1
   AND number=2.0)
   SET number_of_days = 720.0
  ELSEIF (units_code=years
   AND from_or_to=1
   AND number >= 3.0)
   SET number_of_days = round((365.0 * number),1)
  ELSEIF (units_code=years
   AND from_or_to=0
   AND number=1.0)
   SET number_of_days = 359.9
  ELSEIF (units_code=years
   AND from_or_to=0
   AND number=2.0)
   SET number_of_days = 719.9
  ELSEIF (units_code=years
   AND from_or_to=0
   AND number >= 3.0)
   SET number_of_days = round(((365.0 * number) - 0.1),1)
  ELSEIF (units_code=months
   AND from_or_to=1
   AND number=1.0)
   SET number_of_days = 28.0
  ELSEIF (units_code=months
   AND from_or_to=1
   AND number >= 2.0)
   SET number_of_days = round((30.0 * number),1)
  ELSEIF (units_code=months
   AND from_or_to=0
   AND number=1.0)
   SET number_of_days = 27.9
  ELSEIF (units_code=months
   AND from_or_to=0
   AND number >= 2.0)
   SET number_of_days = round(((30.0 * number) - 0.1),1)
  ELSEIF (units_code=weeks
   AND from_or_to=1)
   SET number_of_days = round((7.0 * number),1)
  ELSEIF (units_code=weeks
   AND from_or_to=0)
   SET number_of_days = round(((7.0 * number) - 0.1),1)
  ELSEIF (units_code=days
   AND from_or_to=1)
   SET number_of_days = round(number,1)
  ELSEIF (units_code=days
   AND from_or_to=0)
   SET number_of_days = round((number - 0.1),1)
  ELSEIF (units_code=hours
   AND from_or_to=1)
   SET number_of_days = round((number/ 24.0),1)
  ELSEIF (units_code=hours
   AND from_or_to=0)
   SET number_of_days = round(((number/ 24.0) - 0.1),1)
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
   SET number_of_kgs = round((number - 0.1),1)
  ELSEIF (units_code=kg
   AND ((operator=3) OR (operator=4)) )
   SET number_of_kgs = round(number,1)
  ELSEIF (units_code=kg
   AND operator=2)
   SET number_of_kgs = round((number+ 0.1),1)
  ELSEIF (units_code=gram
   AND operator=1)
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = round(((number/ 1000.0) - 0.1),1)
   ENDIF
  ELSEIF (units_code=gram
   AND ((operator=3) OR (operator=4)) )
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = round((number/ 1000.0),1)
   ENDIF
  ELSEIF (units_code=gram
   AND operator=2)
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = round(((number/ 1000.0)+ 0.1),1)
   ENDIF
  ELSEIF (units_code=ounce
   AND operator=1)
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = round((((number/ 16.0) * 0.4545) - 0.1),1)
   ENDIF
  ELSEIF (units_code=ounce
   AND ((operator=3) OR (operator=4)) )
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = round(((number/ 16.0) * 0.4545),1)
   ENDIF
  ELSEIF (units_code=ounce
   AND operator=2)
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = round((((number/ 16.0) * 0.4545)+ 0.1),1)
   ENDIF
  ELSEIF (units_code=lbs
   AND operator=1)
   SET number_of_kgs = round(((number * 0.4545) - 0.1),1)
  ELSEIF (units_code=lbs
   AND ((operator=3) OR (operator=4)) )
   IF (number=0.0)
    SET number_of_kgs = 0.0
   ELSE
    SET number_of_kgs = round((number * 0.4545),1)
   ENDIF
  ELSEIF (units_code=lbs
   AND operator=2)
   SET number_of_kgs = round(((number * 0.4545)+ 0.1),1)
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
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
