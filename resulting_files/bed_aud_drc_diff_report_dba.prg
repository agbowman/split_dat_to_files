CREATE PROGRAM bed_aud_drc_diff_report:dba
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE s_item = i4 WITH protect, noconstant(0)
 DECLARE tcnt = i4 WITH protect, noconstant(0)
 DECLARE operator = vc WITH protect, noconstant("")
 DECLARE route_list = vc WITH protect, noconstant("")
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE grp_name_idx = i4 WITH protect, constant(1)
 DECLARE parent_active_idx = i4 WITH protect, constant(2)
 DECLARE mill_age_idx = i4 WITH protect, constant(3)
 DECLARE age_idx = i4 WITH protect, constant(4)
 DECLARE mill_pma_idx = i4 WITH protect, constant(5)
 DECLARE pma_idx = i4 WITH protect, constant(6)
 DECLARE mill_route_idx = i4 WITH protect, constant(7)
 DECLARE route_idx = i4 WITH protect, constant(8)
 DECLARE mill_weight_idx = i4 WITH protect, constant(9)
 DECLARE weight_idx = i4 WITH protect, constant(10)
 DECLARE mill_ccl_idx = i4 WITH protect, constant(11)
 DECLARE ccl_idx = i4 WITH protect, constant(12)
 DECLARE mill_hepatic_idx = i4 WITH protect, constant(13)
 DECLARE hepatic_idx = i4 WITH protect, constant(14)
 DECLARE mill_clinic_idx = i4 WITH protect, constant(15)
 DECLARE clinic_idx = i4 WITH protect, constant(16)
 DECLARE mill_dose_idx = i4 WITH protect, constant(17)
 DECLARE source_dose_idx = i4 WITH protect, constant(18)
 DECLARE dose_diff_idx = i4 WITH protect, constant(19)
 DECLARE mill_max_dose_idx = i4 WITH protect, constant(20)
 DECLARE source_max_dose_idx = i4 WITH protect, constant(21)
 DECLARE max_dose_diff_idx = i4 WITH protect, constant(22)
 DECLARE from_var_idx = i4 WITH protect, constant(23)
 DECLARE to_var_idx = i4 WITH protect, constant(24)
 DECLARE mill_cmnt_idx = i4 WITH protect, constant(25)
 DECLARE source_cmnt_idx = i4 WITH protect, constant(26)
 DECLARE cmnt_diff_idx = i4 WITH protect, constant(27)
 DECLARE drc_idx = i4 WITH protect, constant(28)
 DECLARE premise_idx = i4 WITH protect, constant(29)
 DECLARE source_idx = i4 WITH protect, constant(30)
 DECLARE formatted_range_display(operator_text=vc,low_nbr=f8,high_nbr=f8,unit_display=vc) = vc
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD drc_items(
   1 rowlist[*]
     2 unique_id = vc
     2 parent_premise_id = f8
     2 celllist[*]
       3 date_value = dq8
       3 nbr_value = i4
       3 double_value = f8
       3 string_value = vc
       3 display_flag = i2
 )
 SET reply->status_data.status = "F"
 SET tot_col = 30
 SET stat = alterlist(reply->collist,tot_col)
 SET reply->collist[grp_name_idx].header_text = "Grouper"
 SET reply->collist[grp_name_idx].data_type = 1
 SET reply->collist[grp_name_idx].hide_ind = 0
 SET reply->collist[parent_active_idx].header_text = "Parent Premise Active Status"
 SET reply->collist[parent_active_idx].data_type = 1
 SET reply->collist[parent_active_idx].hide_ind = 0
 SET reply->collist[mill_age_idx].header_text = "Mill Age Range"
 SET reply->collist[mill_age_idx].data_type = 1
 SET reply->collist[mill_age_idx].hide_ind = 0
 SET reply->collist[age_idx].header_text = "Source Age Range"
 SET reply->collist[age_idx].data_type = 1
 SET reply->collist[age_idx].hide_ind = 0
 SET reply->collist[mill_pma_idx].header_text = "Mill Postmenstrual Age Range"
 SET reply->collist[mill_pma_idx].data_type = 1
 SET reply->collist[mill_pma_idx].hide_ind = 0
 SET reply->collist[pma_idx].header_text = "Source Postmenstrual Age Range"
 SET reply->collist[pma_idx].data_type = 1
 SET reply->collist[pma_idx].hide_ind = 0
 SET reply->collist[mill_route_idx].header_text = "Mill Route(s)"
 SET reply->collist[mill_route_idx].data_type = 1
 SET reply->collist[mill_route_idx].hide_ind = 0
 SET reply->collist[route_idx].header_text = "Source Route(s)"
 SET reply->collist[route_idx].data_type = 1
 SET reply->collist[route_idx].hide_ind = 0
 SET reply->collist[mill_weight_idx].header_text = "Mill Weight Ranges"
 SET reply->collist[mill_weight_idx].data_type = 1
 SET reply->collist[mill_weight_idx].hide_ind = 0
 SET reply->collist[weight_idx].header_text = "Source Weight Ranges"
 SET reply->collist[weight_idx].data_type = 1
 SET reply->collist[weight_idx].hide_ind = 0
 SET reply->collist[mill_ccl_idx].header_text = "Mill Creatinine Clearance Range"
 SET reply->collist[mill_ccl_idx].data_type = 1
 SET reply->collist[mill_ccl_idx].hide_ind = 0
 SET reply->collist[ccl_idx].header_text = "Source Creatinine Clearance Range"
 SET reply->collist[ccl_idx].data_type = 1
 SET reply->collist[ccl_idx].hide_ind = 0
 SET reply->collist[mill_hepatic_idx].header_text = "Mill Hepatic Dysfunction"
 SET reply->collist[mill_hepatic_idx].data_type = 1
 SET reply->collist[mill_hepatic_idx].hide_ind = 0
 SET reply->collist[hepatic_idx].header_text = "Source Hepatic Dysfunction"
 SET reply->collist[hepatic_idx].data_type = 1
 SET reply->collist[hepatic_idx].hide_ind = 0
 SET reply->collist[mill_clinic_idx].header_text = "Mill Clinical Conditions"
 SET reply->collist[mill_clinic_idx].data_type = 1
 SET reply->collist[mill_clinic_idx].hide_ind = 0
 SET reply->collist[clinic_idx].header_text = "Source Clinical Conditions"
 SET reply->collist[clinic_idx].data_type = 1
 SET reply->collist[clinic_idx].hide_ind = 0
 SET reply->collist[source_dose_idx].header_text = "Source Dose Range"
 SET reply->collist[source_dose_idx].data_type = 1
 SET reply->collist[source_dose_idx].hide_ind = 0
 SET reply->collist[mill_dose_idx].header_text = "Millennium Dose Range"
 SET reply->collist[mill_dose_idx].data_type = 1
 SET reply->collist[mill_dose_idx].hide_ind = 0
 SET reply->collist[dose_diff_idx].header_text = "Dose Range Difference"
 SET reply->collist[dose_diff_idx].data_type = 1
 SET reply->collist[dose_diff_idx].hide_ind = 0
 SET reply->collist[source_max_dose_idx].header_text = "Source Max Dose"
 SET reply->collist[source_max_dose_idx].data_type = 1
 SET reply->collist[source_max_dose_idx].hide_ind = 0
 SET reply->collist[mill_max_dose_idx].header_text = "Millennium Max Dose"
 SET reply->collist[mill_max_dose_idx].data_type = 1
 SET reply->collist[mill_max_dose_idx].hide_ind = 0
 SET reply->collist[max_dose_diff_idx].header_text = "Max Dose Difference"
 SET reply->collist[max_dose_diff_idx].data_type = 1
 SET reply->collist[max_dose_diff_idx].hide_ind = 0
 SET reply->collist[from_var_idx].header_text = "Variance From(%)"
 SET reply->collist[from_var_idx].data_type = 1
 SET reply->collist[from_var_idx].hide_ind = 0
 SET reply->collist[to_var_idx].header_text = "Variance To(%)"
 SET reply->collist[to_var_idx].data_type = 1
 SET reply->collist[to_var_idx].hide_ind = 0
 SET reply->collist[source_cmnt_idx].header_text = "Source Comment"
 SET reply->collist[source_cmnt_idx].data_type = 1
 SET reply->collist[source_cmnt_idx].hide_ind = 0
 SET reply->collist[mill_cmnt_idx].header_text = "Millennium Comment"
 SET reply->collist[mill_cmnt_idx].data_type = 1
 SET reply->collist[mill_cmnt_idx].hide_ind = 0
 SET reply->collist[cmnt_diff_idx].header_text = "Comment Difference"
 SET reply->collist[cmnt_diff_idx].data_type = 1
 SET reply->collist[cmnt_diff_idx].hide_ind = 0
 SET reply->collist[drc_idx].header_text = "Dose Range Check ID"
 SET reply->collist[drc_idx].data_type = 1
 SET reply->collist[drc_idx].hide_ind = 0
 SET reply->collist[premise_idx].header_text = "Parent Premise ID"
 SET reply->collist[premise_idx].data_type = 1
 SET reply->collist[premise_idx].hide_ind = 0
 SET reply->collist[source_idx].header_text = "Source"
 SET reply->collist[source_idx].data_type = 1
 SET reply->collist[source_idx].hide_ind = 0
 SET tcnt = 0
 SELECT INTO "nl:"
  unique_id = concat(trim(cnvtstring(m.parent_premise_id,20,0)),trim(cnvtstring(dp
     .dose_range_check_id,20,0)),trim(cnvtstring(m.drc_dose_range_id,20,0)))
  FROM drc_form_reltn dfr,
   mltm_drc_premise m,
   drc_premise dp,
   drc_dose_range ddr,
   drc_premise dp2
  PLAN (m
   WHERE m.parent_premise_id > 0.00)
   JOIN (dfr
   WHERE dfr.drc_group_id=m.grouper_id
    AND dfr.active_ind=1)
   JOIN (dp
   WHERE dp.dose_range_check_id=dfr.dose_range_check_id
    AND dp.active_ind=1
    AND dp.drc_premise_id=m.drc_premise_id
    AND dp.parent_premise_id=m.parent_premise_id
    AND dp.dose_range_check_id=m.dose_range_check_id)
   JOIN (ddr
   WHERE ddr.drc_dose_range_id=m.drc_dose_range_id
    AND ddr.active_ind=1
    AND ((((ddr.min_value != m.low_dose_value) OR (((ddr.max_value != m.high_dose_value) OR (ddr
   .max_dose != m.max_dose_amt)) ))
    AND m.dose_range_type_id != 7.00) OR (((m.low_dose_value != ddr.max_value
    AND m.dose_range_type_id=7.00) OR (ddr.max_dose != m.max_dose_amt
    AND m.dose_range_type_id=7.00)) )) )
   JOIN (dp2
   WHERE dp2.drc_premise_id=dp.parent_premise_id
    AND dp2.parent_ind=1
    AND dp2.relational_operator_flag=0
    AND dp2.parent_premise_id=0)
  ORDER BY unique_id
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(drc_items->rowlist,1000)
  HEAD unique_id
   tcnt = (tcnt+ 1)
   IF (tcnt > size(drc_items->rowlist,5))
    stat = alterlist(drc_items->rowlist,(tcnt+ 999))
   ENDIF
   stat = alterlist(drc_items->rowlist[tcnt].celllist,tot_col), drc_items->rowlist[tcnt].unique_id =
   unique_id, drc_items->rowlist[tcnt].celllist[grp_name_idx].string_value = m.grouper_name,
   drc_items->rowlist[tcnt].celllist[parent_active_idx].string_value =
   IF (dp2.active_ind=1) "Active"
   ELSE "Inactive"
   ENDIF
   , drc_items->rowlist[tcnt].celllist[age_idx].string_value = formatted_range_display(m
    .age_operator_txt,cnvtreal(m.age_low_nbr),cnvtreal(m.age_high_nbr),m.age_unit_disp), drc_items->
   rowlist[tcnt].celllist[pma_idx].string_value = formatted_range_display(m
    .corrected_gest_age_oper_txt,cnvtreal(m.corrected_gest_age_low_nbr),cnvtreal(m
     .corrected_gest_age_high_nbr),m.corrected_gest_age_unit_disp),
   drc_items->rowlist[tcnt].celllist[route_idx].string_value = m.route_disp, drc_items->rowlist[tcnt]
   .celllist[weight_idx].string_value = formatted_range_display(m.weight_operator_txt,m
    .weight_low_value,m.weight_high_value,m.weight_unit_disp), drc_items->rowlist[tcnt].celllist[
   ccl_idx].string_value = formatted_range_display(m.renal_operator_txt,m.renal_low_value,m
    .renal_high_value,m.renal_unit_disp),
   drc_items->rowlist[tcnt].celllist[hepatic_idx].string_value = m.liver_desc, drc_items->rowlist[
   tcnt].celllist[clinic_idx].string_value =
   IF ( NOT (m.condition1_desc IN ("", " "))
    AND m.condition1_desc IS NOT null
    AND  NOT (m.condition2_desc IN ("", " "))
    AND m.condition2_desc IS NOT null) build2(trim(m.condition1_desc,5),"  ",trim(m.condition2_desc,5
      ))
   ELSEIF ( NOT (m.condition1_desc IN ("", " "))
    AND m.condition1_desc IS NOT null) trim(m.condition1_desc,5)
   ELSEIF ( NOT (m.condition2_desc IN ("", " "))
    AND m.condition2_desc IS NOT null) trim(m.condition2_desc,5)
   ELSE " "
   ENDIF
   , drc_items->rowlist[tcnt].celllist[source_dose_idx].string_value = build2(trim(m.dose_range_type,
     5),":  ",concat(trim(format(m.low_dose_value,"##########.######;RT(1);F"),3)),"-",concat(trim(
      format(m.high_dose_value,"##########.######;RT(1);F"),3)),
    " ",trim(m.dose_unit_disp,5)),
   drc_items->rowlist[tcnt].celllist[mill_dose_idx].string_value =
   IF (((((ddr.min_value != m.low_dose_value) OR (ddr.max_value != m.high_dose_value))
    AND m.dose_range_type_id != 7.00) OR (m.low_dose_value != ddr.max_value
    AND m.dose_range_type_id=7.00)) ) build2(trim(m.dose_range_type,5),":  ",concat(trim(format(ddr
        .min_value,"##########.######;RT(1);F"),3)),"-",concat(trim(format(ddr.max_value,
        "##########.######;RT(1);F"),3)),
     "  ",trim(m.dose_unit_disp,5))
   ELSE " "
   ENDIF
   , drc_items->rowlist[tcnt].celllist[dose_diff_idx].string_value =
   IF (((((ddr.min_value != m.low_dose_value) OR (ddr.max_value != m.high_dose_value))
    AND m.dose_range_type_id != 7.00) OR (m.low_dose_value != ddr.max_value
    AND m.dose_range_type_id=7.00)) ) "Yes"
   ELSE " "
   ENDIF
   , drc_items->rowlist[tcnt].celllist[source_max_dose_idx].string_value =
   IF (m.max_dose_amt > 0) build2(concat(trim(format(m.max_dose_amt,"##########.######;RT(1);F"),3)),
     "  ",trim(uar_get_code_display(uar_get_code_by_cki(m.max_dose_unit_cki)),5))
   ELSE " "
   ENDIF
   ,
   drc_items->rowlist[tcnt].celllist[mill_max_dose_idx].string_value =
   IF (ddr.max_dose > 0
    AND ddr.max_dose != m.max_dose_amt) build2(concat(trim(format(ddr.max_dose,
        "##########.######;RT(1);F"),3)),"  ",trim(uar_get_code_display(ddr.max_dose_unit_cd),5))
   ELSE " "
   ENDIF
   , drc_items->rowlist[tcnt].celllist[max_dose_diff_idx].string_value =
   IF (ddr.max_dose != m.max_dose_amt) "Yes"
   ELSE " "
   ENDIF
   , drc_items->rowlist[tcnt].celllist[from_var_idx].string_value =
   IF (((ddr.min_variance_pct * 100) > 0)) concat(trim(format((ddr.min_variance_pct * 100),
       "##########.######;RT(1);F"),3))
   ELSE " "
   ENDIF
   ,
   drc_items->rowlist[tcnt].celllist[to_var_idx].string_value =
   IF (((ddr.max_variance_pct * 100) > 0)) concat(trim(format((ddr.min_variance_pct * 100),
       "##########.######;RT(1);F"),3))
   ELSE " "
   ENDIF
   , drc_items->rowlist[tcnt].celllist[source_cmnt_idx].string_value = m.comment_txt, drc_items->
   rowlist[tcnt].celllist[mill_cmnt_idx].string_value = "",
   drc_items->rowlist[tcnt].celllist[cmnt_diff_idx].string_value = " ", drc_items->rowlist[tcnt].
   celllist[drc_idx].string_value = concat(trim(format(m.dose_range_check_id,
      "##########.######;RT(1);F"),3)), drc_items->rowlist[tcnt].celllist[premise_idx].string_value
    = concat(trim(format(m.parent_premise_id,"##########.######;RT(1);F"),3)),
   drc_items->rowlist[tcnt].celllist[source_idx].string_value =
   IF (findstring("LEXI!",m.drc_identifier,1,1) > 0) "Lexi-Comp"
   ELSE "Multum"
   ENDIF
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Failure executing dose max difference query",errmsg)
  GO TO exit_script2
 ENDIF
 SELECT INTO "nl:"
  unique_id = concat(trim(cnvtstring(m.parent_premise_id,20,0)),trim(cnvtstring(dp
     .dose_range_check_id,20,0)),trim(cnvtstring(m.drc_dose_range_id,20,0)))
  FROM drc_form_reltn dfr,
   mltm_drc_premise m,
   drc_premise dp,
   drc_dose_range ddr,
   code_value cv,
   drc_premise dp2
  PLAN (m
   WHERE m.parent_premise_id > 0.00)
   JOIN (dfr
   WHERE dfr.drc_group_id=m.grouper_id
    AND dfr.active_ind=1)
   JOIN (dp
   WHERE dp.dose_range_check_id=dfr.dose_range_check_id
    AND dp.active_ind=1
    AND dp.drc_premise_id=m.drc_premise_id
    AND dp.parent_premise_id=m.parent_premise_id
    AND dp.dose_range_check_id=m.dose_range_check_id)
   JOIN (ddr
   WHERE ddr.drc_dose_range_id=m.drc_dose_range_id
    AND ddr.active_ind=1
    AND ddr.max_dose > 0)
   JOIN (cv
   WHERE cv.cki=m.max_dose_unit_cki
    AND cv.code_set=54
    AND cv.active_ind=1
    AND  NOT (m.max_dose_unit_cki IN ("", " "))
    AND m.max_dose_unit_cki IS NOT null
    AND ddr.max_dose_unit_cd != cv.code_value)
   JOIN (dp2
   WHERE dp2.drc_premise_id=dp.parent_premise_id
    AND dp2.parent_ind=1
    AND dp2.relational_operator_flag=0
    AND dp2.parent_premise_id=0)
  ORDER BY m.grouper_name
  DETAIL
   pos = 0, pos = locateval(idx,1,size(drc_items->rowlist,5),unique_id,drc_items->rowlist[idx].
    unique_id)
   IF (pos > 0)
    drc_items->rowlist[pos].celllist[mill_max_dose_idx].string_value =
    IF (ddr.max_dose > 0) build2(concat(trim(format(ddr.max_dose,"##########.######;RT(1);F"),3)),
      "  ",trim(uar_get_code_display(ddr.max_dose_unit_cd),5))
    ELSE " "
    ENDIF
    , drc_items->rowlist[pos].celllist[max_dose_diff_idx].string_value = "Yes"
   ELSE
    tcnt = (tcnt+ 1)
    IF (tcnt > size(drc_items->rowlist,5))
     stat = alterlist(drc_items->rowlist,(tcnt+ 999))
    ENDIF
    stat = alterlist(drc_items->rowlist[tcnt].celllist,tot_col), drc_items->rowlist[tcnt].celllist[
    grp_name_idx].string_value = m.grouper_name, drc_items->rowlist[tcnt].celllist[parent_active_idx]
    .string_value =
    IF (dp2.active_ind=1) "Active"
    ELSE "Inactive"
    ENDIF
    ,
    drc_items->rowlist[tcnt].celllist[age_idx].string_value = formatted_range_display(m
     .age_operator_txt,cnvtreal(m.age_low_nbr),cnvtreal(m.age_high_nbr),m.age_unit_disp), drc_items->
    rowlist[tcnt].celllist[pma_idx].string_value = formatted_range_display(m
     .corrected_gest_age_oper_txt,cnvtreal(m.corrected_gest_age_low_nbr),cnvtreal(m
      .corrected_gest_age_high_nbr),m.corrected_gest_age_unit_disp), drc_items->rowlist[tcnt].
    celllist[route_idx].string_value = m.route_disp,
    drc_items->rowlist[tcnt].celllist[weight_idx].string_value = formatted_range_display(m
     .weight_operator_txt,m.weight_low_value,m.weight_high_value,m.weight_unit_disp), drc_items->
    rowlist[tcnt].celllist[ccl_idx].string_value = formatted_range_display(m.renal_operator_txt,m
     .renal_low_value,m.renal_high_value,m.renal_unit_disp), drc_items->rowlist[tcnt].celllist[
    hepatic_idx].string_value = m.liver_desc,
    drc_items->rowlist[tcnt].celllist[clinic_idx].string_value =
    IF ( NOT (m.condition1_desc IN ("", " "))
     AND m.condition1_desc IS NOT null
     AND  NOT (m.condition2_desc IN ("", " "))
     AND m.condition2_desc IS NOT null) build2(trim(m.condition1_desc,5),"  ",trim(m.condition2_desc,
       5))
    ELSEIF ( NOT (m.condition1_desc IN ("", " "))
     AND m.condition1_desc IS NOT null) trim(m.condition1_desc,5)
    ELSEIF ( NOT (m.condition2_desc IN ("", " "))
     AND m.condition2_desc IS NOT null) trim(m.condition2_desc,5)
    ELSE " "
    ENDIF
    , drc_items->rowlist[tcnt].celllist[source_dose_idx].string_value = build2(trim(m.dose_range_type,
      5),":  ",concat(trim(format(m.low_dose_value,"##########.######;RT(1);F"),3)),"-",concat(trim(
       format(m.high_dose_value,"##########.######;RT(1);F"),3)),
     " ",trim(m.dose_unit_disp,5)), drc_items->rowlist[tcnt].celllist[mill_dose_idx].string_value =
    " ",
    drc_items->rowlist[tcnt].celllist[dose_diff_idx].string_value = " ", drc_items->rowlist[tcnt].
    celllist[source_max_dose_idx].string_value =
    IF (m.max_dose_amt > 0) build2(concat(trim(format(m.max_dose_amt,"##########.######;RT(1);F"),3)),
      "  ",trim(cv.display,5))
    ELSE " "
    ENDIF
    , drc_items->rowlist[tcnt].celllist[mill_max_dose_idx].string_value =
    IF (ddr.max_dose > 0) build2(concat(trim(format(ddr.max_dose,"##########.######;RT(1);F"),3)),
      "  ",trim(uar_get_code_display(ddr.max_dose_unit_cd),5))
    ELSE " "
    ENDIF
    ,
    drc_items->rowlist[tcnt].celllist[max_dose_diff_idx].string_value = "Yes", drc_items->rowlist[
    tcnt].celllist[from_var_idx].string_value =
    IF (((ddr.min_variance_pct * 100) > 0)) concat(trim(format((ddr.min_variance_pct * 100),
        "##########.######;RT(1);F"),3))
    ELSE " "
    ENDIF
    , drc_items->rowlist[tcnt].celllist[to_var_idx].string_value =
    IF (((ddr.max_variance_pct * 100) > 0)) concat(trim(format((ddr.min_variance_pct * 100),
        "##########.######;RT(1);F"),3))
    ELSE " "
    ENDIF
    ,
    drc_items->rowlist[tcnt].celllist[source_cmnt_idx].string_value = m.comment_txt, drc_items->
    rowlist[tcnt].celllist[mill_cmnt_idx].string_value = "", drc_items->rowlist[tcnt].celllist[
    cmnt_diff_idx].string_value = " ",
    drc_items->rowlist[tcnt].celllist[drc_idx].string_value = concat(trim(format(m
       .dose_range_check_id,"##########.######;RT(1);F"),3)), drc_items->rowlist[tcnt].celllist[
    premise_idx].string_value = concat(trim(format(m.parent_premise_id,"##########.######;RT(1);F"),3
      )), drc_items->rowlist[tcnt].celllist[source_idx].string_value =
    IF (findstring("LEXI!",m.drc_identifier,1,1) > 0) "Lexi-Comp"
    ELSE "Multum"
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Failure executing dose max difference query",errmsg)
  GO TO exit_script2
 ENDIF
 DECLARE mltm_comment_txt = vc WITH protect, noconstant("")
 DECLARE long_comment_text = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  unique_id = concat(trim(cnvtstring(m.parent_premise_id,20,0)),trim(cnvtstring(dp
     .dose_range_check_id,20,0)),trim(cnvtstring(m.drc_dose_range_id,20,0)))
  FROM drc_form_reltn dfr,
   mltm_drc_premise m,
   drc_premise dp,
   drc_dose_range ddr,
   long_text lt,
   drc_premise dp2
  PLAN (m
   WHERE m.parent_premise_id > 0.00)
   JOIN (dfr
   WHERE dfr.drc_group_id=m.grouper_id
    AND dfr.active_ind=1)
   JOIN (dp
   WHERE dp.dose_range_check_id=dfr.dose_range_check_id
    AND dp.active_ind=1
    AND dp.drc_premise_id=m.drc_premise_id
    AND dp.parent_premise_id=m.parent_premise_id
    AND dp.dose_range_check_id=m.dose_range_check_id)
   JOIN (ddr
   WHERE ddr.drc_dose_range_id=m.drc_dose_range_id
    AND ddr.active_ind=1)
   JOIN (lt
   WHERE lt.parent_entity_name="DRC_DOSE_RANGE"
    AND lt.parent_entity_id=m.drc_dose_range_id
    AND lt.active_ind=1)
   JOIN (dp2
   WHERE dp2.drc_premise_id=dp.parent_premise_id
    AND dp2.parent_ind=1
    AND dp2.relational_operator_flag=0
    AND dp2.parent_premise_id=0)
  ORDER BY m.grouper_name
  DETAIL
   outbuf = fillstring(32767," "), offset = 0, retlen = 0,
   freers = 0
   IF (freers=0)
    long_comment_text = ""
   ENDIF
   retlen = 1
   WHILE (retlen > 0)
     retlen = blobget(outbuf,offset,lt.long_text), offset = (offset+ retlen)
     IF (freers=0)
      long_comment_text = notrim(outbuf)
     ELSE
      long_comment_text = notrim(concat(notrim(long_comment_text),notrim(substring(1,retlen,outbuf)))
       )
     ENDIF
     freers = 1
   ENDWHILE
   long_comment_text = trim(long_comment_text,5), mltm_comment_txt = m.comment_txt
   IF (mltm_comment_txt != long_comment_text)
    pos = 0, pos = locateval(idx,1,size(drc_items->rowlist,5),unique_id,drc_items->rowlist[idx].
     unique_id)
    IF (pos > 0)
     drc_items->rowlist[pos].celllist[mill_cmnt_idx].string_value = long_comment_text, drc_items->
     rowlist[pos].celllist[cmnt_diff_idx].string_value = "Yes"
    ELSE
     tcnt = (tcnt+ 1)
     IF (tcnt > size(drc_items->rowlist,5))
      stat = alterlist(drc_items->rowlist,(tcnt+ 999))
     ENDIF
     stat = alterlist(drc_items->rowlist[tcnt].celllist,tot_col), drc_items->rowlist[tcnt].celllist[
     grp_name_idx].string_value = m.grouper_name, drc_items->rowlist[tcnt].celllist[parent_active_idx
     ].string_value =
     IF (dp2.active_ind=1) "Active"
     ELSE "Inactive"
     ENDIF
     ,
     drc_items->rowlist[tcnt].celllist[age_idx].string_value = formatted_range_display(m
      .age_operator_txt,cnvtreal(m.age_low_nbr),cnvtreal(m.age_high_nbr),m.age_unit_disp), drc_items
     ->rowlist[tcnt].celllist[pma_idx].string_value = formatted_range_display(m
      .corrected_gest_age_oper_txt,cnvtreal(m.corrected_gest_age_low_nbr),cnvtreal(m
       .corrected_gest_age_high_nbr),m.corrected_gest_age_unit_disp), drc_items->rowlist[tcnt].
     celllist[route_idx].string_value = m.route_disp,
     drc_items->rowlist[tcnt].celllist[weight_idx].string_value = formatted_range_display(m
      .weight_operator_txt,m.weight_low_value,m.weight_high_value,m.weight_unit_disp), drc_items->
     rowlist[tcnt].celllist[ccl_idx].string_value = formatted_range_display(m.renal_operator_txt,m
      .renal_low_value,m.renal_high_value,m.renal_unit_disp), drc_items->rowlist[tcnt].celllist[
     hepatic_idx].string_value = m.liver_desc,
     drc_items->rowlist[tcnt].celllist[clinic_idx].string_value =
     IF ( NOT (m.condition1_desc IN ("", " "))
      AND m.condition1_desc IS NOT null
      AND  NOT (m.condition2_desc IN ("", " "))
      AND m.condition2_desc IS NOT null) build2(trim(m.condition1_desc,5),"  ",trim(m.condition2_desc,
        5))
     ELSEIF ( NOT (m.condition1_desc IN ("", " "))
      AND m.condition1_desc IS NOT null) trim(m.condition1_desc,5)
     ELSEIF ( NOT (m.condition2_desc IN ("", " "))
      AND m.condition2_desc IS NOT null) trim(m.condition2_desc,5)
     ELSE " "
     ENDIF
     , drc_items->rowlist[tcnt].celllist[source_dose_idx].string_value = build2(trim(m
       .dose_range_type,5),":  ",concat(trim(format(m.low_dose_value,"##########.######;RT(1);F"),3)),
      "-",concat(trim(format(m.high_dose_value,"##########.######;RT(1);F"),3)),
      " ",trim(m.dose_unit_disp,5)), drc_items->rowlist[tcnt].celllist[mill_dose_idx].string_value =
     " ",
     drc_items->rowlist[tcnt].celllist[dose_diff_idx].string_value = " ", drc_items->rowlist[tcnt].
     celllist[source_max_dose_idx].string_value =
     IF (m.max_dose_amt > 0) build2(concat(trim(format(m.max_dose_amt,"##########.######;RT(1);F"),3)
        ),"  ",trim(uar_get_code_display(uar_get_code_by_cki(m.max_dose_unit_cki)),5))
     ELSE " "
     ENDIF
     , drc_items->rowlist[tcnt].celllist[mill_max_dose_idx].string_value = " ",
     drc_items->rowlist[tcnt].celllist[max_dose_diff_idx].string_value = " ", drc_items->rowlist[tcnt
     ].celllist[from_var_idx].string_value =
     IF (((ddr.min_variance_pct * 100) > 0)) concat(trim(format((ddr.min_variance_pct * 100),
         "##########.######;RT(1);F"),3))
     ELSE " "
     ENDIF
     , drc_items->rowlist[tcnt].celllist[to_var_idx].string_value =
     IF (((ddr.max_variance_pct * 100) > 0)) concat(trim(format((ddr.min_variance_pct * 100),
         "##########.######;RT(1);F"),3))
     ELSE " "
     ENDIF
     ,
     drc_items->rowlist[tcnt].celllist[source_cmnt_idx].string_value = m.comment_txt, drc_items->
     rowlist[tcnt].celllist[mill_cmnt_idx].string_value = long_comment_text, drc_items->rowlist[tcnt]
     .celllist[cmnt_diff_idx].string_value = "Yes",
     drc_items->rowlist[tcnt].celllist[drc_idx].string_value = concat(trim(format(m
        .dose_range_check_id,"##########.######;RT(1);F"),3)), drc_items->rowlist[tcnt].celllist[
     premise_idx].string_value = concat(trim(format(m.parent_premise_id,"##########.######;RT(1);F"),
       3)), drc_items->rowlist[tcnt].celllist[source_idx].string_value =
     IF (findstring("LEXI!",m.drc_identifier,1,1) > 0) "Lexi-Comp"
     ELSE "Multum"
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Failure executing comment difference query",errmsg)
  GO TO exit_script2
 ENDIF
 SET stat = alterlist(drc_items->rowlist,tcnt)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(drc_items->rowlist,5)),
   drc_premise dp,
   drc_premise_list dpl,
   code_value cv,
   nomenclature n
  PLAN (d)
   JOIN (dp
   WHERE dp.parent_premise_id=cnvtreal(drc_items->rowlist[d.seq].celllist[premise_idx].string_value))
   JOIN (cv
   WHERE cv.code_value=outerjoin(dp.value_unit_cd)
    AND cv.active_ind=outerjoin(1))
   JOIN (dpl
   WHERE dpl.drc_premise_id=outerjoin(dp.drc_premise_id)
    AND cv.code_value=outerjoin(dpl.parent_entity_id))
   JOIN (n
   WHERE n.concept_cki=outerjoin(dp.concept_cki)
    AND n.primary_vterm_ind=outerjoin(1)
    AND n.active_ind=outerjoin(1)
    AND n.end_effective_dt_tm > outerjoin(cnvtdatetime("30-DEC-2100")))
  ORDER BY d.seq, dp.parent_premise_id, dp.premise_type_flag,
   dpl.drc_premise_list_id
  HEAD REPORT
   route_cnt = 0
  HEAD dp.premise_type_flag
   route_list = "", route_cnt = 0
  HEAD dpl.drc_premise_list_id
   operator = " "
  FOOT  dpl.drc_premise_list_id
   IF (dp.premise_type_flag=2
    AND dp.value_type_flag=4)
    route_cnt = (route_cnt+ 1)
    IF (route_cnt=1)
     route_list = uar_get_code_display(dpl.parent_entity_id)
    ELSE
     route_list = concat(trim(route_list,5),",",uar_get_code_display(dpl.parent_entity_id))
    ENDIF
   ENDIF
  FOOT  dp.premise_type_flag
   operator = " "
   IF (dp.relational_operator_flag=1)
    operator = "<"
   ELSEIF (dp.relational_operator_flag=2)
    operator = ">"
   ELSEIF (dp.relational_operator_flag=3)
    operator = "<="
   ELSEIF (dp.relational_operator_flag=4)
    operator = ">="
   ELSEIF (dp.relational_operator_flag=5)
    operator = "!="
   ELSEIF (dp.relational_operator_flag=6)
    operator = "BETWEEN"
   ELSEIF (dp.relational_operator_flag=7)
    operator = "OUTSIDE"
   ELSEIF (dp.relational_operator_flag=8)
    operator = "INCLUDE"
   ELSEIF (dp.relational_operator_flag=9)
    operator = "EXCLUDE"
   ENDIF
   IF (dp.premise_type_flag=1)
    drc_items->rowlist[d.seq].celllist[mill_age_idx].string_value = formatted_range_display(operator,
     dp.value1,dp.value2,uar_get_code_display(dp.value_unit_cd))
   ELSEIF (dp.premise_type_flag=2)
    IF (dp.value_type_flag != 4)
     drc_items->rowlist[d.seq].celllist[mill_route_idx].string_value = dp.value1_string
    ELSEIF (dp.value_type_flag=4)
     drc_items->rowlist[d.seq].celllist[mill_route_idx].string_value = route_list
    ENDIF
   ELSEIF (dp.premise_type_flag=3)
    drc_items->rowlist[d.seq].celllist[mill_weight_idx].string_value = formatted_range_display(
     operator,dp.value1,dp.value2,uar_get_code_display(dp.value_unit_cd))
   ELSEIF (dp.premise_type_flag=4)
    drc_items->rowlist[d.seq].celllist[mill_ccl_idx].string_value = formatted_range_display(operator,
     dp.value1,dp.value2,uar_get_code_display(dp.value_unit_cd))
   ELSEIF (dp.premise_type_flag=5)
    drc_items->rowlist[d.seq].celllist[mill_pma_idx].string_value = formatted_range_display(operator,
     dp.value1,dp.value2,uar_get_code_display(dp.value_unit_cd))
   ELSEIF (dp.premise_type_flag=6)
    IF (dp.value1=1)
     drc_items->rowlist[d.seq].celllist[mill_hepatic_idx].string_value = "Yes"
    ELSEIF (dp.value1=0)
     drc_items->rowlist[d.seq].celllist[mill_hepatic_idx].string_value = "No"
    ENDIF
   ELSEIF (dp.premise_type_flag=7)
    drc_items->rowlist[d.seq].celllist[mill_clinic_idx].string_value = n.source_string
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE formatted_range_display(operator_text,low_nbr,high_nbr,unit_display)
  IF (((operator_text="<") OR (operator_text=">=")) )
   SET formatted_range_display = build2(trim(operator_text,5)," ",concat(trim(format(low_nbr,
       "##########.######;RT(1);F"),3)),"  ",trim(unit_display,5))
  ELSEIF (operator_text="BETWEEN")
   SET formatted_range_display = build2(trim(operator_text,5)," ",concat(trim(format(low_nbr,
       "##########.######;RT(1);F"),3))," AND ",concat(trim(format(high_nbr,
       "##########.######;RT(1);F"),3)),
    "  ",trim(unit_display,5))
  ELSEIF (((operator_text="<=") OR (((operator_text=">") OR (operator_text="!=")) )) )
   SET formatted_range_display = build2(trim(operator_text,5)," ",concat(trim(format(low_nbr,
       "##########.######;RT(1);F"),3)),"  ",concat(trim(format(high_nbr,"##########.######;RT(1);F"),
      3)),
    "  ",trim(unit_display,5))
  ELSE
   SET formatted_range_display = " "
  ENDIF
  RETURN(formatted_range_display)
 END ;Subroutine
 SET tcnt = size(drc_items->rowlist,5)
 DECLARE bcnt = i4 WITH protect, noconstant(0)
 SET stat = alterlist(reply->rowlist,tcnt)
 FOR (bcnt = 1 TO tcnt)
   SET stat = alterlist(reply->rowlist[bcnt].celllist,tot_col)
   SET reply->rowlist[bcnt].celllist[grp_name_idx].string_value = drc_items->rowlist[bcnt].celllist[
   grp_name_idx].string_value
   SET reply->rowlist[bcnt].celllist[parent_active_idx].string_value = drc_items->rowlist[bcnt].
   celllist[parent_active_idx].string_value
   SET reply->rowlist[bcnt].celllist[mill_age_idx].string_value = drc_items->rowlist[bcnt].celllist[
   mill_age_idx].string_value
   SET reply->rowlist[bcnt].celllist[age_idx].string_value = drc_items->rowlist[bcnt].celllist[
   age_idx].string_value
   SET reply->rowlist[bcnt].celllist[mill_pma_idx].string_value = drc_items->rowlist[bcnt].celllist[
   mill_pma_idx].string_value
   SET reply->rowlist[bcnt].celllist[pma_idx].string_value = drc_items->rowlist[bcnt].celllist[
   pma_idx].string_value
   SET reply->rowlist[bcnt].celllist[mill_route_idx].string_value = drc_items->rowlist[bcnt].
   celllist[mill_route_idx].string_value
   SET reply->rowlist[bcnt].celllist[route_idx].string_value = drc_items->rowlist[bcnt].celllist[
   route_idx].string_value
   SET reply->rowlist[bcnt].celllist[mill_weight_idx].string_value = drc_items->rowlist[bcnt].
   celllist[mill_weight_idx].string_value
   SET reply->rowlist[bcnt].celllist[weight_idx].string_value = drc_items->rowlist[bcnt].celllist[
   weight_idx].string_value
   SET reply->rowlist[bcnt].celllist[mill_ccl_idx].string_value = drc_items->rowlist[bcnt].celllist[
   mill_ccl_idx].string_value
   SET reply->rowlist[bcnt].celllist[ccl_idx].string_value = drc_items->rowlist[bcnt].celllist[
   ccl_idx].string_value
   SET reply->rowlist[bcnt].celllist[mill_hepatic_idx].string_value = drc_items->rowlist[bcnt].
   celllist[mill_hepatic_idx].string_value
   SET reply->rowlist[bcnt].celllist[hepatic_idx].string_value = drc_items->rowlist[bcnt].celllist[
   hepatic_idx].string_value
   SET reply->rowlist[bcnt].celllist[mill_clinic_idx].string_value = drc_items->rowlist[bcnt].
   celllist[mill_clinic_idx].string_value
   SET reply->rowlist[bcnt].celllist[clinic_idx].string_value = drc_items->rowlist[bcnt].celllist[
   clinic_idx].string_value
   SET reply->rowlist[bcnt].celllist[source_dose_idx].string_value = drc_items->rowlist[bcnt].
   celllist[source_dose_idx].string_value
   SET reply->rowlist[bcnt].celllist[mill_dose_idx].string_value = drc_items->rowlist[bcnt].celllist[
   mill_dose_idx].string_value
   SET reply->rowlist[bcnt].celllist[dose_diff_idx].string_value = drc_items->rowlist[bcnt].celllist[
   dose_diff_idx].string_value
   SET reply->rowlist[bcnt].celllist[source_max_dose_idx].string_value = drc_items->rowlist[bcnt].
   celllist[source_max_dose_idx].string_value
   SET reply->rowlist[bcnt].celllist[mill_max_dose_idx].string_value = drc_items->rowlist[bcnt].
   celllist[mill_max_dose_idx].string_value
   SET reply->rowlist[bcnt].celllist[max_dose_diff_idx].string_value = drc_items->rowlist[bcnt].
   celllist[max_dose_diff_idx].string_value
   SET reply->rowlist[bcnt].celllist[from_var_idx].string_value = drc_items->rowlist[bcnt].celllist[
   from_var_idx].string_value
   SET reply->rowlist[bcnt].celllist[to_var_idx].string_value = drc_items->rowlist[bcnt].celllist[
   to_var_idx].string_value
   SET reply->rowlist[bcnt].celllist[source_cmnt_idx].string_value = substring(1,250,replace(replace(
      drc_items->rowlist[bcnt].celllist[source_cmnt_idx].string_value,char(13)," ",0),char(10)," ",0)
    )
   SET reply->rowlist[bcnt].celllist[mill_cmnt_idx].string_value = substring(1,250,replace(replace(
      drc_items->rowlist[bcnt].celllist[mill_cmnt_idx].string_value,char(13)," ",0),char(10)," ",0))
   SET reply->rowlist[bcnt].celllist[cmnt_diff_idx].string_value = drc_items->rowlist[bcnt].celllist[
   cmnt_diff_idx].string_value
   SET reply->rowlist[bcnt].celllist[drc_idx].string_value = drc_items->rowlist[bcnt].celllist[
   drc_idx].string_value
   SET reply->rowlist[bcnt].celllist[premise_idx].string_value = drc_items->rowlist[bcnt].celllist[
   premise_idx].string_value
   SET reply->rowlist[bcnt].celllist[source_idx].string_value = drc_items->rowlist[bcnt].celllist[
   source_idx].string_value
 ENDFOR
 IF ((request->skip_volume_check_ind=0))
  IF (tcnt > 10000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   SET stat = alterlist(reply->collist,0)
   GO TO exit_script
  ELSEIF (tcnt > 5000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   SET stat = alterlist(reply->collist,0)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 SET reply->run_status_flag = 1
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("bed_drc_diff_report.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
#exit_script2
 CALL echorecord(reply)
END GO
