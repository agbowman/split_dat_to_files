CREATE PROGRAM bed_aud_cn_ref_ranges:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
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
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 tcnt = i2
   1 tqual[*]
     2 assay_display = vc
     2 result_type = vc
     2 unit_of_measure = vc
     2 num_map_max_digits = i4
     2 num_map_min_digits = i4
     2 num_map_min_dec_places = i4
     2 age_range_from = i4
     2 age_range_to = i4
     2 normal_low = f8
     2 normal_high = f8
     2 feasible_low = f8
     2 feasible_high = f8
     2 critical_low = f8
     2 critical_high = f8
 )
 DECLARE numeric = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=289
    AND cv.cdf_meaning="3"
    AND cv.active_ind=1)
  DETAIL
   numeric = cv.code_value
  WITH nocounter
 ;end select
 DECLARE gen_lab_cd = f8 WITH public, noconstant(0.0)
 DECLARE rad_cd = f8 WITH public, noconstant(0.0)
 DECLARE surg_cd = f8 WITH public, noconstant(0.0)
 DECLARE pharm_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning IN ("GLB", "RADIOLOGY", "SURGERY", "PHARMACY")
    AND cv.active_ind=1)
  DETAIL
   IF (cv.cdf_meaning="GLB")
    gen_lab_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="RADIOLOGY")
    rad_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="SURGERY")
    surg_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="PHARMACY")
    pharm_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM discrete_task_assay dta,
    reference_range_factor rrf,
    data_map dm
   PLAN (dta
    WHERE dta.default_result_type_cd=numeric
     AND dta.activity_type_cd != gen_lab_cd
     AND dta.activity_type_cd != rad_cd
     AND dta.activity_type_cd != surg_cd
     AND dta.activity_type_cd != pharm_cd
     AND dta.active_ind=1)
    JOIN (rrf
    WHERE rrf.task_assay_cd=dta.task_assay_cd
     AND rrf.active_ind=1)
    JOIN (dm
    WHERE dm.task_assay_cd=dta.task_assay_cd
     AND dm.active_ind=1)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM discrete_task_assay dta,
   reference_range_factor rrf,
   data_map dm,
   code_value cv1,
   code_value cv2
  PLAN (dta
   WHERE dta.default_result_type_cd=numeric
    AND dta.activity_type_cd != gen_lab_cd
    AND dta.activity_type_cd != rad_cd
    AND dta.activity_type_cd != surg_cd
    AND dta.activity_type_cd != pharm_cd
    AND dta.active_ind=1)
   JOIN (rrf
   WHERE rrf.task_assay_cd=dta.task_assay_cd
    AND rrf.active_ind=1)
   JOIN (dm
   WHERE dm.task_assay_cd=dta.task_assay_cd
    AND dm.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=dta.default_result_type_cd
    AND cv1.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=rrf.units_cd
    AND cv2.active_ind=1)
  ORDER BY dta.mnemonic
  DETAIL
   tcnt = (tcnt+ 1), temp->tcnt = tcnt, stat = alterlist(temp->tqual,tcnt),
   temp->tqual[tcnt].assay_display = dta.mnemonic, temp->tqual[tcnt].result_type = cv1.display, temp
   ->tqual[tcnt].unit_of_measure = cv2.display,
   temp->tqual[tcnt].num_map_max_digits = dm.max_digits, temp->tqual[tcnt].num_map_min_digits = dm
   .min_digits, temp->tqual[tcnt].num_map_min_dec_places = dm.min_decimal_places,
   temp->tqual[tcnt].age_range_from = rrf.age_from_minutes, temp->tqual[tcnt].age_range_to = rrf
   .age_to_minutes, temp->tqual[tcnt].normal_low = rrf.normal_low,
   temp->tqual[tcnt].normal_high = rrf.normal_high, temp->tqual[tcnt].feasible_low = rrf.feasible_low,
   temp->tqual[tcnt].feasible_high = rrf.feasible_high,
   temp->tqual[tcnt].critical_low = rrf.critical_low, temp->tqual[tcnt].critical_high = rrf
   .critical_high
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,14)
 SET reply->collist[1].header_text = "Assay Display"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Result Type"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Unit of Measure"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Numeric Map Maximum Digits"
 SET reply->collist[4].data_type = 3
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Numeric Map Minimum Digits"
 SET reply->collist[5].data_type = 3
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Numeric Map Minimum Decimal Places"
 SET reply->collist[6].data_type = 3
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Age Range From"
 SET reply->collist[7].data_type = 3
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Age Range To"
 SET reply->collist[8].data_type = 3
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Normal Low"
 SET reply->collist[9].data_type = 2
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Normal High"
 SET reply->collist[10].data_type = 2
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Feasible Low"
 SET reply->collist[11].data_type = 2
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Feasible High"
 SET reply->collist[12].data_type = 2
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Critical Low"
 SET reply->collist[13].data_type = 2
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "Critical High"
 SET reply->collist[14].data_type = 2
 SET reply->collist[14].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,14)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].assay_display
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].result_type
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].unit_of_measure
   SET reply->rowlist[row_nbr].celllist[4].nbr_value = temp->tqual[x].num_map_max_digits
   SET reply->rowlist[row_nbr].celllist[5].nbr_value = temp->tqual[x].num_map_min_digits
   SET reply->rowlist[row_nbr].celllist[6].nbr_value = temp->tqual[x].num_map_min_dec_places
   SET reply->rowlist[row_nbr].celllist[7].nbr_value = temp->tqual[x].age_range_from
   SET reply->rowlist[row_nbr].celllist[8].nbr_value = temp->tqual[x].age_range_to
   SET reply->rowlist[row_nbr].celllist[9].double_value = temp->tqual[x].normal_low
   SET reply->rowlist[row_nbr].celllist[10].double_value = temp->tqual[x].normal_high
   SET reply->rowlist[row_nbr].celllist[11].double_value = temp->tqual[x].feasible_low
   SET reply->rowlist[row_nbr].celllist[12].double_value = temp->tqual[x].feasible_high
   SET reply->rowlist[row_nbr].celllist[13].double_value = temp->tqual[x].critical_low
   SET reply->rowlist[row_nbr].celllist[14].double_value = temp->tqual[x].critical_high
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("cn_referance_ranges_for_vital_signs.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
