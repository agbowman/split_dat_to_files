CREATE PROGRAM bed_aud_dta_spec_type:dba
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
 RECORD temp(
   1 dlist[*]
     2 skip_ind = i2
     2 activity_type_cd = f8
     2 activity_type_disp = vc
     2 task_assay_cd = f8
     2 dtaname = vc
     2 dtadesc = vc
     2 dta_result_type_cd = f8
     2 dta_result_type = vc
     2 norrf[*]
       3 service_resource_cd = f8
       3 service_resource = vc
       3 sr_result_type_cd = f8
       3 sr_result_type = vc
     2 rrf[*]
       3 skip_ind = i2
       3 reference_range_factor_id = f8
       3 service_resource_cd = f8
       3 service_resource = vc
       3 unknown_age_ind = i2
       3 unknown_age_str = vc
       3 sex_cd = f8
       3 sex = vc
       3 species_cd = f8
       3 species = vc
       3 specimen_type_cd = f8
       3 specimen_type = vc
       3 age_from = i4
       3 af_disp = vc
       3 age_from_units_cd = f8
       3 age_from_unit = vc
       3 age_to = i4
       3 at_disp = vc
       3 age_to_units_cd = f8
       3 age_to_unit = vc
       3 alpha_response_ind = i2
       3 normal_low = vc
       3 nl_disp = vc
       3 normal_high = vc
       3 nh_disp = vc
       3 normal_ind = i2
       3 critical_low = vc
       3 cl_disp = vc
       3 critical_high = vc
       3 ch_disp = vc
       3 critical_ind = i2
       3 review_low = vc
       3 rl_disp = vc
       3 review_high = vc
       3 rh_disp = vc
       3 review_ind = i2
       3 linear_low = vc
       3 ll_disp = vc
       3 linear_high = vc
       3 lh_disp = vc
       3 linear_ind = i2
       3 feasible_low = vc
       3 fl_disp = vc
       3 feasible_high = vc
       3 fh_disp = vc
       3 feasible_ind = i2
       3 dilute = vc
       3 units_cd = f8
       3 units = vc
       3 sr_result_type_cd = f8
       3 sr_result_type = vc
       3 max_digits = i4
       3 min_decimal_places = i4
       3 min_digits = i4
       3 delta_check_type_cd = f8
       3 delta_check_type_disp = vc
       3 delta_time_value = i4
       3 delta_time_unit = vc
       3 delta_value = vc
       3 delta_value_disp = vc
       3 al[*]
         4 nomenclature_id = f8
         4 mnemonic = vc
         4 term = vc
         4 long_desc = vc
         4 default = vc
         4 use_units = vc
         4 result_process_cd = f8
         4 result_process = vc
         4 reference = vc
         4 vocab = vc
 )
 SET minutes_per_year = 525600
 SET minutes_per_month = 43200
 SET minutes_per_week = 10080
 SET minutes_per_day = 1440
 SET minutes_per_hour = 60
 SET minutes_per_minute = 1
 DECLARE glb_disp = vc
 SET glb_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=106
    AND c.cdf_meaning="GLB")
  DETAIL
   glb_cd = c.code_value, glb_disp = c.display
  WITH nocounter
 ;end select
 DECLARE bb_disp = vc
 SET bb_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=106
    AND c.cdf_meaning="BB")
  DETAIL
   bb_cd = c.code_value, bb_disp = c.display
  WITH nocounter
 ;end select
 DECLARE days_cd = f8
 DECLARE hours_cd = f8
 DECLARE minutes_cd = f8
 DECLARE months_cd = f8
 DECLARE weeks_cd = f8
 DECLARE years_cd = f8
 SET days_cd = - (1.0)
 SET hours_cd = - (1.0)
 SET minutes_cd = - (1.0)
 SET months_cd = - (1.0)
 SET weeks_cd = - (1.0)
 SET years_cd = - (1.0)
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=340)
  DETAIL
   IF (c.cdf_meaning="DAYS")
    days_cd = c.code_value
   ELSEIF (c.cdf_meaning="HOURS")
    hours_cd = c.code_value
   ELSEIF (c.cdf_meaning="MINUTES")
    minutes_cd = c.code_value
   ELSEIF (c.cdf_meaning="MONTHS")
    months_cd = c.code_value
   ELSEIF (c.cdf_meaning="WEEKS")
    weeks_cd = c.code_value
   ELSEIF (c.cdf_meaning="YEARS")
    years_cd = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET tcnt = 0
 SET rcnt = 0
 SET nrcnt = 0
 SET acnt = 0
 SET x = 0
 SET y = 0
 SET z = 0
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM discrete_task_assay dta
   PLAN (dta
    WHERE dta.activity_type_cd IN (glb_cd, bb_cd)
     AND dta.active_ind=1)
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
 SELECT INTO "nl:"
  FROM discrete_task_assay dta,
   code_value cvdta,
   code_value rt,
   profile_task_r ptr,
   order_catalog oc
  PLAN (dta
   WHERE dta.active_ind=1
    AND dta.activity_type_cd IN (glb_cd, bb_cd))
   JOIN (cvdta
   WHERE cvdta.code_value=dta.task_assay_cd)
   JOIN (rt
   WHERE rt.code_value=dta.default_result_type_cd)
   JOIN (ptr
   WHERE ptr.task_assay_cd=dta.task_assay_cd)
   JOIN (oc
   WHERE oc.catalog_cd=ptr.catalog_cd
    AND oc.active_ind=1)
  ORDER BY dta.activity_type_cd, cnvtupper(cvdta.display), dta.task_assay_cd
  HEAD REPORT
   tcnt = 0
  HEAD dta.task_assay_cd
   tcnt = (tcnt+ 1), stat = alterlist(temp->dlist,tcnt), temp->dlist[tcnt].activity_type_cd = dta
   .activity_type_cd
   IF (dta.activity_type_cd=glb_cd)
    temp->dlist[tcnt].activity_type_disp = glb_disp
   ELSE
    temp->dlist[tcnt].activity_type_disp = bb_disp
   ENDIF
   temp->dlist[tcnt].task_assay_cd = dta.task_assay_cd, temp->dlist[tcnt].dtaname = trim(cvdta
    .display), temp->dlist[tcnt].dtadesc = trim(cvdta.description),
   temp->dlist[tcnt].dta_result_type_cd = dta.default_result_type_cd, temp->dlist[tcnt].
   dta_result_type = rt.display
  WITH nocounter
 ;end select
 IF (tcnt=0)
  GO TO skip_processing
 ENDIF
 CALL echo(build("tcnt:",tcnt))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = tcnt),
   reference_range_factor rrf,
   code_value cvts,
   code_value cvs,
   code_value cvaf,
   code_value cvat,
   code_value cvu,
   code_value cvspecies,
   code_value cvspectype,
   code_value cvdelta
  PLAN (d)
   JOIN (rrf
   WHERE (rrf.task_assay_cd=temp->dlist[d.seq].task_assay_cd)
    AND rrf.active_ind=1)
   JOIN (cvts
   WHERE cvts.code_value=rrf.service_resource_cd)
   JOIN (cvs
   WHERE cvs.code_value=rrf.sex_cd)
   JOIN (cvaf
   WHERE cvaf.code_value=rrf.age_from_units_cd)
   JOIN (cvat
   WHERE cvat.code_value=rrf.age_to_units_cd)
   JOIN (cvu
   WHERE cvu.code_value=rrf.units_cd)
   JOIN (cvspecies
   WHERE cvspecies.code_value=rrf.species_cd)
   JOIN (cvspectype
   WHERE cvspectype.code_value=rrf.specimen_type_cd)
   JOIN (cvdelta
   WHERE cvdelta.code_value=rrf.delta_check_type_cd)
  ORDER BY d.seq, rrf.precedence_sequence, cvts.display
  HEAD d.seq
   rcnt = 0
  DETAIL
   rcnt = (rcnt+ 1), stat = alterlist(temp->dlist[d.seq].rrf,rcnt), temp->dlist[d.seq].rrf[rcnt].
   skip_ind = 0,
   temp->dlist[d.seq].rrf[rcnt].reference_range_factor_id = rrf.reference_range_factor_id, temp->
   dlist[d.seq].rrf[rcnt].service_resource_cd = rrf.service_resource_cd
   IF (cvts.code_value > 0
    AND cvts.display > " ")
    temp->dlist[d.seq].rrf[rcnt].service_resource = trim(cvts.display)
   ELSE
    temp->dlist[d.seq].rrf[rcnt].service_resource = "all"
   ENDIF
   temp->dlist[d.seq].rrf[rcnt].unknown_age_ind = rrf.unknown_age_ind
   IF (rrf.unknown_age_ind=1)
    temp->dlist[d.seq].rrf[rcnt].unknown_age_str = "Yes"
   ELSEIF (rrf.unknown_age_ind=0)
    temp->dlist[d.seq].rrf[rcnt].unknown_age_str = "No"
   ENDIF
   temp->dlist[d.seq].rrf[rcnt].sex_cd = rrf.sex_cd, temp->dlist[d.seq].rrf[rcnt].species_cd = rrf
   .species_cd, temp->dlist[d.seq].rrf[rcnt].specimen_type_cd = rrf.specimen_type_cd,
   temp->dlist[d.seq].rrf[rcnt].age_from = rrf.age_from_minutes, temp->dlist[d.seq].rrf[rcnt].
   age_from_units_cd = rrf.age_from_units_cd
   IF (rrf.age_from_units_cd=years_cd)
    temp->dlist[d.seq].rrf[rcnt].age_from = (rrf.age_from_minutes/ minutes_per_year)
   ELSEIF (rrf.age_from_units_cd=months_cd)
    temp->dlist[d.seq].rrf[rcnt].age_from = (rrf.age_from_minutes/ minutes_per_month)
   ELSEIF (rrf.age_from_units_cd=weeks_cd)
    temp->dlist[d.seq].rrf[rcnt].age_from = (rrf.age_from_minutes/ minutes_per_week)
   ELSEIF (rrf.age_from_units_cd=days_cd)
    temp->dlist[d.seq].rrf[rcnt].age_from = (rrf.age_from_minutes/ minutes_per_day)
   ELSEIF (rrf.age_from_units_cd=hours_cd)
    temp->dlist[d.seq].rrf[rcnt].age_from = (rrf.age_from_minutes/ minutes_per_hour)
   ENDIF
   temp->dlist[d.seq].rrf[rcnt].age_to = rrf.age_to_minutes, temp->dlist[d.seq].rrf[rcnt].
   age_to_units_cd = rrf.age_to_units_cd
   IF (rrf.age_to_units_cd=years_cd)
    temp->dlist[d.seq].rrf[rcnt].age_to = (rrf.age_to_minutes/ minutes_per_year)
   ELSEIF (rrf.age_to_units_cd=months_cd)
    temp->dlist[d.seq].rrf[rcnt].age_to = (rrf.age_to_minutes/ minutes_per_month)
   ELSEIF (rrf.age_to_units_cd=weeks_cd)
    temp->dlist[d.seq].rrf[rcnt].age_to = (rrf.age_to_minutes/ minutes_per_week)
   ELSEIF (rrf.age_to_units_cd=days_cd)
    temp->dlist[d.seq].rrf[rcnt].age_to = (rrf.age_to_minutes/ minutes_per_day)
   ELSEIF (rrf.age_to_units_cd=hours_cd)
    temp->dlist[d.seq].rrf[rcnt].age_to = (rrf.age_to_minutes/ minutes_per_hour)
   ENDIF
   temp->dlist[d.seq].rrf[rcnt].alpha_response_ind = rrf.alpha_response_ind, temp->dlist[d.seq].rrf[
   rcnt].normal_ind = rrf.normal_ind
   IF (rrf.normal_ind=1)
    temp->dlist[d.seq].rrf[rcnt].normal_low = format(rrf.normal_low,"##########.##########;I;f")
   ELSEIF (rrf.normal_ind=2)
    temp->dlist[d.seq].rrf[rcnt].normal_high = format(rrf.normal_high,"##########.##########;I;f")
   ELSEIF (rrf.normal_ind=3)
    temp->dlist[d.seq].rrf[rcnt].normal_low = format(rrf.normal_low,"##########.##########;I;f"),
    temp->dlist[d.seq].rrf[rcnt].normal_high = format(rrf.normal_high,"##########.##########;I;f")
   ENDIF
   temp->dlist[d.seq].rrf[rcnt].critical_ind = rrf.critical_ind
   IF (rrf.critical_ind=1)
    temp->dlist[d.seq].rrf[rcnt].critical_low = format(rrf.critical_low,"##########.##########;I;f")
   ELSEIF (rrf.critical_ind=2)
    temp->dlist[d.seq].rrf[rcnt].critical_high = format(rrf.critical_high,"##########.##########;I;f"
     )
   ELSEIF (rrf.critical_ind=3)
    temp->dlist[d.seq].rrf[rcnt].critical_low = format(rrf.critical_low,"##########.##########;I;f"),
    temp->dlist[d.seq].rrf[rcnt].critical_high = format(rrf.critical_high,"##########.##########;I;f"
     )
   ENDIF
   temp->dlist[d.seq].rrf[rcnt].review_ind = rrf.review_ind
   IF (rrf.review_ind=1)
    temp->dlist[d.seq].rrf[rcnt].review_low = format(rrf.review_low,"##########.##########;I;f")
   ELSEIF (rrf.review_ind=2)
    temp->dlist[d.seq].rrf[rcnt].review_high = format(rrf.review_high,"##########.##########;I;f")
   ELSEIF (rrf.review_ind=3)
    temp->dlist[d.seq].rrf[rcnt].review_low = format(rrf.review_low,"##########.##########;I;f"),
    temp->dlist[d.seq].rrf[rcnt].review_high = format(rrf.review_high,"##########.##########;I;f")
   ENDIF
   temp->dlist[d.seq].rrf[rcnt].linear_ind = rrf.linear_ind
   IF (rrf.linear_ind=1)
    temp->dlist[d.seq].rrf[rcnt].linear_low = format(rrf.linear_low,"##########.##########;I;f")
   ELSEIF (rrf.linear_ind=2)
    temp->dlist[d.seq].rrf[rcnt].linear_high = format(rrf.linear_high,"##########.##########;I;f")
   ELSEIF (rrf.linear_ind=3)
    temp->dlist[d.seq].rrf[rcnt].linear_low = format(rrf.linear_low,"##########.##########;I;f"),
    temp->dlist[d.seq].rrf[rcnt].linear_high = format(rrf.linear_high,"##########.##########;I;f")
   ENDIF
   temp->dlist[d.seq].rrf[rcnt].feasible_ind = rrf.feasible_ind
   IF (rrf.feasible_ind=1)
    temp->dlist[d.seq].rrf[rcnt].feasible_low = format(rrf.feasible_low,"##########.##########;I;f")
   ELSEIF (rrf.feasible_ind=2)
    temp->dlist[d.seq].rrf[rcnt].feasible_high = format(rrf.feasible_high,"##########.##########;I;f"
     )
   ELSEIF (rrf.feasible_ind=3)
    temp->dlist[d.seq].rrf[rcnt].feasible_low = format(rrf.feasible_low,"##########.##########;I;f"),
    temp->dlist[d.seq].rrf[rcnt].feasible_high = format(rrf.feasible_high,"##########.##########;I;f"
     )
   ENDIF
   IF (rrf.dilute_ind=1)
    temp->dlist[d.seq].rrf[rcnt].dilute = "X"
   ELSE
    temp->dlist[d.seq].rrf[rcnt].dilute = " "
   ENDIF
   temp->dlist[d.seq].rrf[rcnt].units_cd = rrf.units_cd
   IF (cvs.code_value > 0)
    temp->dlist[d.seq].rrf[rcnt].sex = trim(cvs.display)
   ELSE
    temp->dlist[d.seq].rrf[rcnt].sex = "all"
   ENDIF
   IF (cvaf.code_value > 0)
    temp->dlist[d.seq].rrf[rcnt].age_from_unit = trim(cvaf.display)
   ENDIF
   IF (cvat.code_value > 0)
    temp->dlist[d.seq].rrf[rcnt].age_to_unit = trim(cvat.display)
   ENDIF
   IF (cvu.code_value > 0)
    temp->dlist[d.seq].rrf[rcnt].units = trim(cvu.display)
   ENDIF
   IF (cvspecies.code_value > 0)
    temp->dlist[d.seq].rrf[rcnt].species = trim(cvspecies.display)
   ENDIF
   IF (cvspectype.code_value > 0)
    temp->dlist[d.seq].rrf[rcnt].specimen_type = trim(cvspectype.display)
   ELSE
    temp->dlist[d.seq].rrf[rcnt].specimen_type = "all"
   ENDIF
   IF (cvdelta.code_value > 0)
    temp->dlist[d.seq].rrf[rcnt].delta_check_type_disp = trim(cvdelta.display), temp->dlist[d.seq].
    rrf[rcnt].delta_value = format(rrf.delta_value,"##########.##########;I;f")
    IF (rrf.delta_minutes > 0)
     rmdr = 0, rmdr = mod(rrf.delta_minutes,1440)
     IF (rmdr=0)
      temp->dlist[d.seq].rrf[rcnt].delta_time_value = (rrf.delta_minutes/ 1440), temp->dlist[d.seq].
      rrf[rcnt].delta_time_unit = "Days"
     ELSE
      rmdt = 0, rmdr = mod(rrf.delta_minutes,60)
      IF (rmdr=0)
       temp->dlist[d.seq].rrf[rcnt].delta_time_value = (rrf.delta_minutes/ 60), temp->dlist[d.seq].
       rrf[rcnt].delta_time_unit = "Hrs"
      ELSE
       temp->dlist[d.seq].rrf[rcnt].delta_time_value = rrf.delta_minutes, temp->dlist[d.seq].rrf[rcnt
       ].delta_time_unit = "Min"
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   temp->dlist[d.seq].rrf[rcnt].sr_result_type_cd = 0.0, temp->dlist[d.seq].rrf[rcnt].sr_result_type
    = "(None)"
  WITH nocounter
 ;end select
 FOR (x = 1 TO tcnt)
   SET rcnt = size(temp->dlist[x].rrf,5)
   IF (rcnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = rcnt),
      assay_processing_r apr,
      code_value c
     PLAN (d)
      JOIN (apr
      WHERE (apr.task_assay_cd=temp->dlist[x].task_assay_cd)
       AND (apr.service_resource_cd=temp->dlist[x].rrf[d.seq].service_resource_cd)
       AND apr.active_ind=1)
      JOIN (c
      WHERE c.code_value=apr.default_result_type_cd)
     DETAIL
      temp->dlist[x].rrf[d.seq].sr_result_type_cd = apr.default_result_type_cd, temp->dlist[x].rrf[d
      .seq].sr_result_type = trim(c.display)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = rcnt),
      data_map dm
     PLAN (d)
      JOIN (dm
      WHERE (dm.task_assay_cd=temp->dlist[x].task_assay_cd)
       AND (dm.service_resource_cd=temp->dlist[x].rrf[d.seq].service_resource_cd)
       AND dm.active_ind=1
       AND dm.data_map_type_flag=0)
     DETAIL
      temp->dlist[x].rrf[d.seq].max_digits = dm.max_digits, temp->dlist[x].rrf[d.seq].
      min_decimal_places = dm.min_decimal_places, temp->dlist[x].rrf[d.seq].min_digits = dm
      .min_digits
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = rcnt),
      alpha_responses ar,
      code_value cv,
      nomenclature n,
      code_value cv1
     PLAN (d)
      JOIN (ar
      WHERE (ar.reference_range_factor_id=temp->dlist[x].rrf[d.seq].reference_range_factor_id)
       AND ar.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=ar.result_process_cd)
      JOIN (n
      WHERE n.nomenclature_id=ar.nomenclature_id)
      JOIN (cv1
      WHERE cv1.code_value=outerjoin(n.source_vocabulary_cd)
       AND cv1.active_ind=outerjoin(1))
     ORDER BY d.seq, ar.sequence, ar.multi_alpha_sort_order
     HEAD d.seq
      acnt = 0
     DETAIL
      acnt = (acnt+ 1), stat = alterlist(temp->dlist[x].rrf[d.seq].al,acnt), temp->dlist[x].rrf[d.seq
      ].al[acnt].mnemonic = trim(n.mnemonic),
      temp->dlist[x].rrf[d.seq].al[acnt].long_desc = trim(n.source_string), temp->dlist[x].rrf[d.seq]
      .al[acnt].term = trim(n.short_string)
      IF (ar.use_units_ind=1)
       temp->dlist[x].rrf[d.seq].al[acnt].use_units = "Yes"
      ENDIF
      IF (ar.default_ind=1)
       temp->dlist[x].rrf[d.seq].al[acnt].default = "Yes"
      ENDIF
      temp->dlist[x].rrf[d.seq].al[acnt].result_process_cd = ar.result_process_cd
      IF (cv.code_value > 0)
       temp->dlist[x].rrf[d.seq].al[acnt].result_process = trim(cv.description)
      ENDIF
      IF (ar.reference_ind=1)
       temp->dlist[x].rrf[d.seq].al[acnt].reference = "X"
      ELSE
       temp->dlist[x].rrf[d.seq].al[acnt].reference = " "
      ENDIF
      IF (cv1.code_value > 0)
       temp->dlist[x].rrf[d.seq].al[acnt].vocab = cv1.display
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO "nl:"
    FROM assay_processing_r apr,
     code_value c,
     code_value c2,
     (dummyt d  WITH seq = 1),
     reference_range_factor rrf
    PLAN (apr
     WHERE (apr.task_assay_cd=temp->dlist[x].task_assay_cd)
      AND apr.service_resource_cd > 0
      AND apr.active_ind=1)
     JOIN (c
     WHERE c.code_value=apr.default_result_type_cd)
     JOIN (c2
     WHERE c2.code_value=apr.service_resource_cd)
     JOIN (d)
     JOIN (rrf
     WHERE rrf.task_assay_cd=apr.task_assay_cd
      AND rrf.service_resource_cd=apr.service_resource_cd)
    HEAD REPORT
     nrcnt = 0
    DETAIL
     nrcnt = (nrcnt+ 1), stat = alterlist(temp->dlist[x].norrf,nrcnt), temp->dlist[x].norrf[nrcnt].
     sr_result_type_cd = apr.default_result_type_cd,
     temp->dlist[x].norrf[nrcnt].sr_result_type = trim(c.display), temp->dlist[x].norrf[nrcnt].
     service_resource_cd = apr.service_resource_cd, temp->dlist[x].norrf[nrcnt].service_resource =
     trim(c2.display)
    WITH nocounter, outerjoin = d, dontexist
   ;end select
 ENDFOR
#skip_processing
 DECLARE header_string = vc
 DECLARE dta_string = vc
 SET normal_range_txt = fillstring(20," ")
 SET normal_low_txt = fillstring(50," ")
 SET normal_high_txt = fillstring(50," ")
 SET critical_range_txt = fillstring(20," ")
 SET critical_low_txt = fillstring(50," ")
 SET critical_high_txt = fillstring(50," ")
 SET feasible_range_txt = fillstring(20," ")
 SET feasible_low_txt = fillstring(50," ")
 SET feasible_high_txt = fillstring(50," ")
 SET review_range_txt = fillstring(20," ")
 SET review_low_txt = fillstring(50," ")
 SET review_high_txt = fillstring(50," ")
 SET linear_range_txt = fillstring(20," ")
 SET linear_low_txt = fillstring(50," ")
 SET linear_high_txt = fillstring(50," ")
 SET units_txt = fillstring(20," ")
 SET results_txt = fillstring(20," ")
 SET equation_txt = fillstring(45," ")
 SET text_nbr = fillstring(50," ")
 SET min_dec_digits = 0
 SET text_char = " "
 SET text = fillstring(50," ")
 SET save_sr_result_type = fillstring(50," ")
 SET save_service_resource = fillstring(50," ")
 SET ptr = 0
 SET start_pos = 0
 SET nbr_len = 0
 SET dec_start_pos = 0
 SET nbr_dec_digits = 0
 SET delta_value_txt = fillstring(50," ")
 SUBROUTINE convert_range_number(row_nbr)
   SET ptr = 0
   SET start_pos = 0
   SET nbr_len = 0
   SET dec_start_pos = 0
   SET nbr_dec_digits = 0
   SET text = ""
   FOR (ptr = 1 TO size(trim(text_nbr),3))
     SET text_char = substring(ptr,1,text_nbr)
     IF (text_char > " "
      AND start_pos=0)
      SET start_pos = ptr
     ENDIF
     IF (text_char=".")
      SET dec_start_pos = ptr
     ENDIF
     IF (dec_start_pos > 0
      AND text_char != "0")
      SET nbr_dec_digits = (ptr - dec_start_pos)
     ENDIF
   ENDFOR
   IF (nbr_dec_digits < min_dec_digits)
    SET nbr_dec_digits = min_dec_digits
   ENDIF
   IF (nbr_dec_digits > 0)
    SET nbr_len = ((dec_start_pos - start_pos)+ 1)
    SET nbr_len = (nbr_len+ nbr_dec_digits)
   ELSE
    SET nbr_len = (dec_start_pos - start_pos)
   ENDIF
   SET text = substring(start_pos,nbr_len,text_nbr)
   RETURN(1)
 END ;Subroutine
 SET stat = alterlist(reply->collist,44)
 SET reply->collist[1].header_text = "Activity Type"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Assay Display"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Assay Description"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Instrument/Bench"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Default Result Type"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Instrument/Bench Result Type"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Sex"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Age From"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Units"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Age To"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Units"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Species"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Specimen Type"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "Unknown Age"
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = "Min Digit"
 SET reply->collist[15].data_type = 1
 SET reply->collist[15].hide_ind = 0
 SET reply->collist[16].header_text = "Max Digit"
 SET reply->collist[16].data_type = 1
 SET reply->collist[16].hide_ind = 0
 SET reply->collist[17].header_text = "Min Decimal"
 SET reply->collist[17].data_type = 1
 SET reply->collist[17].hide_ind = 0
 SET reply->collist[18].header_text = "Normal Low"
 SET reply->collist[18].data_type = 1
 SET reply->collist[18].hide_ind = 0
 SET reply->collist[19].header_text = "Normal High"
 SET reply->collist[19].data_type = 1
 SET reply->collist[19].hide_ind = 0
 SET reply->collist[20].header_text = "Critical Low"
 SET reply->collist[20].data_type = 1
 SET reply->collist[20].hide_ind = 0
 SET reply->collist[21].header_text = "Critical High"
 SET reply->collist[21].data_type = 1
 SET reply->collist[21].hide_ind = 0
 SET reply->collist[22].header_text = "Review Low"
 SET reply->collist[22].data_type = 1
 SET reply->collist[22].hide_ind = 0
 SET reply->collist[23].header_text = "Review High"
 SET reply->collist[23].data_type = 1
 SET reply->collist[23].hide_ind = 0
 SET reply->collist[24].header_text = "Linear Low"
 SET reply->collist[24].data_type = 1
 SET reply->collist[24].hide_ind = 0
 SET reply->collist[25].header_text = "Linear High"
 SET reply->collist[25].data_type = 1
 SET reply->collist[25].hide_ind = 0
 SET reply->collist[26].header_text = "Dilute"
 SET reply->collist[26].data_type = 1
 SET reply->collist[26].hide_ind = 0
 SET reply->collist[27].header_text = "Units of Measure"
 SET reply->collist[27].data_type = 1
 SET reply->collist[27].hide_ind = 0
 SET reply->collist[28].header_text = "Feasible Low"
 SET reply->collist[28].data_type = 1
 SET reply->collist[28].hide_ind = 0
 SET reply->collist[29].header_text = "Feasible High"
 SET reply->collist[29].data_type = 1
 SET reply->collist[29].hide_ind = 0
 SET reply->collist[30].header_text = "Alpha Response/Chart Name"
 SET reply->collist[30].data_type = 1
 SET reply->collist[30].hide_ind = 0
 SET reply->collist[31].header_text = "MDI Alias"
 SET reply->collist[31].data_type = 1
 SET reply->collist[31].hide_ind = 0
 SET reply->collist[32].header_text = "Unique Identifier"
 SET reply->collist[32].data_type = 1
 SET reply->collist[32].hide_ind = 0
 SET reply->collist[33].header_text = "Vocabulary"
 SET reply->collist[33].data_type = 1
 SET reply->collist[33].hide_ind = 1
 SET reply->collist[34].header_text = "Alpha Default"
 SET reply->collist[34].data_type = 1
 SET reply->collist[34].hide_ind = 0
 SET reply->collist[35].header_text = "Use Units of Measure"
 SET reply->collist[35].data_type = 1
 SET reply->collist[35].hide_ind = 0
 SET reply->collist[36].header_text = "Report Flag"
 SET reply->collist[36].data_type = 1
 SET reply->collist[36].hide_ind = 0
 SET reply->collist[37].header_text = "Reference"
 SET reply->collist[37].data_type = 1
 SET reply->collist[37].hide_ind = 0
 SET reply->collist[38].header_text = "Delta Check Type"
 SET reply->collist[38].data_type = 1
 SET reply->collist[38].hide_ind = 0
 SET reply->collist[39].header_text = "Delta Time Frame"
 SET reply->collist[39].data_type = 1
 SET reply->collist[39].hide_ind = 0
 SET reply->collist[40].header_text = "Delta Time Frame Units"
 SET reply->collist[40].data_type = 1
 SET reply->collist[40].hide_ind = 0
 SET reply->collist[41].header_text = "Delta Value"
 SET reply->collist[41].data_type = 1
 SET reply->collist[41].hide_ind = 0
 SET reply->collist[42].header_text = "task_assay_cd"
 SET reply->collist[42].data_type = 1
 SET reply->collist[42].hide_ind = 1
 SET reply->collist[43].header_text = "service_resource_cd"
 SET reply->collist[43].data_type = 1
 SET reply->collist[43].hide_ind = 1
 SET reply->collist[44].header_text = "reference_range_factor_id"
 SET reply->collist[44].data_type = 1
 SET reply->collist[44].hide_ind = 1
 SET row_nbr = 0
 CALL echo(build("tcnt:",tcnt))
 FOR (x = 1 TO tcnt)
   SET temp->dlist[x].skip_ind = 1
   SET rcnt = size(temp->dlist[x].rrf,5)
   FOR (y = 1 TO rcnt)
     IF ((temp->dlist[x].rrf[y].specimen_type_cd > 0))
      SET temp->dlist[x].skip_ind = 0
     ENDIF
   ENDFOR
 ENDFOR
 FOR (x = 1 TO tcnt)
   IF ((temp->dlist[x].skip_ind=0))
    SET rcnt = size(temp->dlist[x].rrf,5)
    SET skip_nrrf_ind = 0
    SET save_sr_result_type = "(None)"
    FOR (y = 1 TO rcnt)
     SET skip_nrrf_ind = 1
     IF ((temp->dlist[x].rrf[y].sr_result_type != save_sr_result_type)
      AND (temp->dlist[x].rrf[y].sr_result_type != "(None)"))
      IF (save_sr_result_type="(None)")
       SET save_sr_result_type = temp->dlist[x].rrf[y].sr_result_type
      ELSE
       SET save_sr_result_type = "Multiple"
      ENDIF
     ENDIF
    ENDFOR
    IF (skip_nrrf_ind=1)
     SET nrcnt = size(temp->dlist[x].norrf,5)
     IF (nrcnt > 0)
      FOR (y = 1 TO nrcnt)
        IF ((temp->dlist[x].norrf[y].sr_result_type != save_sr_result_type)
         AND (temp->dlist[x].norrf[y].sr_result_type != "(None)"))
         IF (save_sr_result_type="(None)")
          SET save_sr_result_type = temp->dlist[x].norrf[y].sr_result_type
         ELSE
          SET save_sr_result_type = "Multiple"
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
     FOR (y = 1 TO rcnt)
       IF ((temp->dlist[x].rrf[y].service_resource="all")
        AND (temp->dlist[x].rrf[y].sr_result_type="(None)"))
        SET temp->dlist[x].rrf[y].sr_result_type = save_sr_result_type
       ENDIF
     ENDFOR
    ENDIF
    FOR (y = 1 TO rcnt)
      IF ((temp->dlist[x].rrf[y].skip_ind=0))
       SET temp->dlist[x].rrf[y].af_disp = cnvtstring(temp->dlist[x].rrf[y].age_from)
       SET temp->dlist[x].rrf[y].at_disp = cnvtstring(temp->dlist[x].rrf[y].age_to)
       SET normal_low_txt = ""
       SET normal_high_txt = ""
       SET min_dec_digits = temp->dlist[x].rrf[y].min_decimal_places
       IF ((temp->dlist[x].rrf[y].normal_ind=1))
        SET text_nbr = temp->dlist[x].rrf[y].normal_low
        SET stat = convert_range_number(row_nbr)
        SET normal_low_txt = text
        SET temp->dlist[x].rrf[y].nl_disp = trim(normal_low_txt)
       ELSEIF ((temp->dlist[x].rrf[y].normal_ind=2))
        SET text_nbr = temp->dlist[x].rrf[y].normal_high
        SET stat = convert_range_number(row_nbr)
        SET normal_high_txt = text
        SET temp->dlist[x].rrf[y].nh_disp = trim(normal_high_txt)
       ELSEIF ((temp->dlist[x].rrf[y].normal_ind=3))
        SET text_nbr = temp->dlist[x].rrf[y].normal_low
        SET stat = convert_range_number(row_nbr)
        SET normal_low_txt = text
        SET temp->dlist[x].rrf[y].nl_disp = trim(normal_low_txt)
        SET text_nbr = temp->dlist[x].rrf[y].normal_high
        SET stat = convert_range_number(row_nbr)
        SET normal_high_txt = text
        SET temp->dlist[x].rrf[y].nh_disp = trim(normal_high_txt)
       ENDIF
       SET critical_low_txt = ""
       SET critical_high_txt = ""
       IF ((temp->dlist[x].rrf[y].critical_ind=1))
        SET text_nbr = temp->dlist[x].rrf[y].critical_low
        SET stat = convert_range_number(row_nbr)
        SET critical_low_txt = text
        SET temp->dlist[x].rrf[y].cl_disp = trim(critical_low_txt)
       ELSEIF ((temp->dlist[x].rrf[y].critical_ind=2))
        SET text_nbr = temp->dlist[x].rrf[y].critical_high
        SET stat = convert_range_number(row_nbr)
        SET critical_high_txt = text
        SET temp->dlist[x].rrf[y].ch_disp = trim(critical_high_txt)
       ELSEIF ((temp->dlist[x].rrf[y].critical_ind=3))
        SET text_nbr = temp->dlist[x].rrf[y].critical_low
        SET stat = convert_range_number(row_nbr)
        SET critical_low_txt = text
        SET temp->dlist[x].rrf[y].cl_disp = trim(critical_low_txt)
        SET text_nbr = temp->dlist[x].rrf[y].critical_high
        SET stat = convert_range_number(row_nbr)
        SET critical_high_txt = text
        SET temp->dlist[x].rrf[y].ch_disp = trim(critical_high_txt)
       ENDIF
       SET review_low_txt = ""
       SET review_high_txt = ""
       IF ((temp->dlist[x].rrf[y].review_ind=1))
        SET text_nbr = temp->dlist[x].rrf[y].review_low
        SET stat = convert_range_number(row_nbr)
        SET review_low_txt = text
        SET temp->dlist[x].rrf[y].rl_disp = trim(review_low_txt)
       ELSEIF ((temp->dlist[x].rrf[y].review_ind=2))
        SET text_nbr = temp->dlist[x].rrf[y].review_high
        SET stat = convert_range_number(row_nbr)
        SET review_high_txt = text
        SET temp->dlist[x].rrf[y].rh_disp = trim(review_high_txt)
       ELSEIF ((temp->dlist[x].rrf[y].review_ind=3))
        SET text_nbr = temp->dlist[x].rrf[y].review_low
        SET stat = convert_range_number(row_nbr)
        SET review_low_txt = text
        SET temp->dlist[x].rrf[y].rl_disp = trim(review_low_txt)
        SET text_nbr = temp->dlist[x].rrf[y].review_high
        SET stat = convert_range_number(row_nbr)
        SET review_high_txt = text
        SET temp->dlist[x].rrf[y].rh_disp = trim(review_high_txt)
       ENDIF
       SET linear_low_txt = ""
       SET linear_high_txt = ""
       IF ((temp->dlist[x].rrf[y].linear_ind=1))
        SET text_nbr = temp->dlist[x].rrf[y].linear_low
        SET stat = convert_range_number(row_nbr)
        SET linear_low_txt = text
        SET temp->dlist[x].rrf[y].ll_disp = trim(linear_low_txt)
       ELSEIF ((temp->dlist[x].rrf[y].linear_ind=2))
        SET text_nbr = temp->dlist[x].rrf[y].linear_high
        SET stat = convert_range_number(row_nbr)
        SET linear_high_txt = text
        SET temp->dlist[x].rrf[y].lh_disp = trim(linear_high_txt)
       ELSEIF ((temp->dlist[x].rrf[y].linear_ind=3))
        SET text_nbr = temp->dlist[x].rrf[y].linear_low
        SET stat = convert_range_number(row_nbr)
        SET linear_low_txt = text
        SET temp->dlist[x].rrf[y].ll_disp = trim(linear_low_txt)
        SET text_nbr = temp->dlist[x].rrf[y].linear_high
        SET stat = convert_range_number(row_nbr)
        SET linear_high_txt = text
        SET temp->dlist[x].rrf[y].lh_disp = trim(linear_high_txt)
       ENDIF
       SET feasible_low_txt = ""
       SET feasible_high_txt = ""
       IF ((temp->dlist[x].rrf[y].feasible_ind=1))
        SET text_nbr = temp->dlist[x].rrf[y].feasible_low
        SET stat = convert_range_number(row_nbr)
        SET feasible_low_txt = text
        SET temp->dlist[x].rrf[y].fl_disp = trim(feasible_low_txt)
       ELSEIF ((temp->dlist[x].rrf[y].feasible_ind=2))
        SET text_nbr = temp->dlist[x].rrf[y].feasible_high
        SET stat = convert_range_number(row_nbr)
        SET feasible_high_txt = text
        SET temp->dlist[x].rrf[y].fh_disp = trim(feasible_high_txt)
       ELSEIF ((temp->dlist[x].rrf[y].feasible_ind=3))
        SET text_nbr = temp->dlist[x].rrf[y].feasible_low
        SET stat = convert_range_number(row_nbr)
        SET feasible_low_txt = text
        SET temp->dlist[x].rrf[y].fl_disp = trim(feasible_low_txt)
        SET text_nbr = temp->dlist[x].rrf[y].feasible_high
        SET stat = convert_range_number(row_nbr)
        SET feasible_high_txt = text
        SET temp->dlist[x].rrf[y].fh_disp = trim(feasible_high_txt)
       ENDIF
       IF ((temp->dlist[x].rrf[y].delta_value > " "))
        SET delta_value_txt = ""
        SET text_nbr = temp->dlist[x].rrf[y].delta_value
        SET stat = convert_range_number(row_nbr)
        SET delta_value_txt = text
        SET temp->dlist[x].rrf[y].delta_value_disp = trim(delta_value_txt)
       ENDIF
       SET row_nbr = (row_nbr+ 1)
       SET stat = alterlist(reply->rowlist,row_nbr)
       SET stat = alterlist(reply->rowlist[row_nbr].celllist,44)
       SET reply->rowlist[row_nbr].celllist[1].string_value = trim(temp->dlist[x].activity_type_disp)
       SET reply->rowlist[row_nbr].celllist[2].string_value = trim(temp->dlist[x].dtaname)
       SET reply->rowlist[row_nbr].celllist[3].string_value = trim(temp->dlist[x].dtadesc)
       SET reply->rowlist[row_nbr].celllist[4].string_value = trim(temp->dlist[x].rrf[y].
        service_resource)
       SET reply->rowlist[row_nbr].celllist[5].string_value = trim(temp->dlist[x].dta_result_type)
       SET reply->rowlist[row_nbr].celllist[6].string_value = trim(temp->dlist[x].rrf[y].
        sr_result_type)
       SET reply->rowlist[row_nbr].celllist[7].string_value = trim(temp->dlist[x].rrf[y].sex)
       SET reply->rowlist[row_nbr].celllist[8].string_value = trim(temp->dlist[x].rrf[y].af_disp)
       SET reply->rowlist[row_nbr].celllist[9].string_value = trim(temp->dlist[x].rrf[y].
        age_from_unit)
       SET reply->rowlist[row_nbr].celllist[10].string_value = trim(temp->dlist[x].rrf[y].at_disp)
       SET reply->rowlist[row_nbr].celllist[11].string_value = trim(temp->dlist[x].rrf[y].age_to_unit
        )
       SET reply->rowlist[row_nbr].celllist[12].string_value = trim(temp->dlist[x].rrf[y].species)
       SET reply->rowlist[row_nbr].celllist[13].string_value = trim(temp->dlist[x].rrf[y].
        specimen_type)
       SET reply->rowlist[row_nbr].celllist[14].string_value = trim(temp->dlist[x].rrf[y].
        unknown_age_str)
       SET reply->rowlist[row_nbr].celllist[15].string_value = cnvtstring(temp->dlist[x].rrf[y].
        min_digits)
       SET reply->rowlist[row_nbr].celllist[16].string_value = cnvtstring(temp->dlist[x].rrf[y].
        max_digits)
       SET reply->rowlist[row_nbr].celllist[17].string_value = cnvtstring(temp->dlist[x].rrf[y].
        min_decimal_places)
       SET reply->rowlist[row_nbr].celllist[18].string_value = trim(temp->dlist[x].rrf[y].nl_disp)
       SET reply->rowlist[row_nbr].celllist[19].string_value = trim(temp->dlist[x].rrf[y].nh_disp)
       SET reply->rowlist[row_nbr].celllist[20].string_value = trim(temp->dlist[x].rrf[y].cl_disp)
       SET reply->rowlist[row_nbr].celllist[21].string_value = trim(temp->dlist[x].rrf[y].ch_disp)
       SET reply->rowlist[row_nbr].celllist[22].string_value = trim(temp->dlist[x].rrf[y].rl_disp)
       SET reply->rowlist[row_nbr].celllist[23].string_value = trim(temp->dlist[x].rrf[y].rh_disp)
       SET reply->rowlist[row_nbr].celllist[24].string_value = trim(temp->dlist[x].rrf[y].ll_disp)
       SET reply->rowlist[row_nbr].celllist[25].string_value = trim(temp->dlist[x].rrf[y].lh_disp)
       SET reply->rowlist[row_nbr].celllist[26].string_value = trim(temp->dlist[x].rrf[y].dilute)
       SET reply->rowlist[row_nbr].celllist[27].string_value = trim(temp->dlist[x].rrf[y].units)
       SET reply->rowlist[row_nbr].celllist[28].string_value = trim(temp->dlist[x].rrf[y].fl_disp)
       SET reply->rowlist[row_nbr].celllist[29].string_value = trim(temp->dlist[x].rrf[y].fh_disp)
       SET reply->rowlist[row_nbr].celllist[38].string_value = trim(temp->dlist[x].rrf[y].
        delta_check_type_disp)
       IF ((temp->dlist[x].rrf[y].delta_time_value > 0))
        SET reply->rowlist[row_nbr].celllist[39].string_value = cnvtstring(temp->dlist[x].rrf[y].
         delta_time_value)
       ELSE
        SET reply->rowlist[row_nbr].celllist[39].string_value = " "
       ENDIF
       SET reply->rowlist[row_nbr].celllist[40].string_value = trim(temp->dlist[x].rrf[y].
        delta_time_unit)
       SET reply->rowlist[row_nbr].celllist[41].string_value = temp->dlist[x].rrf[y].delta_value_disp
       IF ((temp->dlist[x].task_assay_cd > 0))
        SET reply->rowlist[row_nbr].celllist[42].string_value = cnvtstring(temp->dlist[x].
         task_assay_cd)
       ELSE
        SET reply->rowlist[row_nbr].celllist[42].string_value = " "
       ENDIF
       IF ((temp->dlist[x].rrf[y].service_resource_cd > 0))
        SET reply->rowlist[row_nbr].celllist[43].string_value = cnvtstring(temp->dlist[x].rrf[y].
         service_resource_cd)
       ELSE
        SET reply->rowlist[row_nbr].celllist[43].string_value = " "
       ENDIF
       IF ((temp->dlist[x].rrf[y].reference_range_factor_id > 0))
        SET reply->rowlist[row_nbr].celllist[44].string_value = cnvtstring(temp->dlist[x].rrf[y].
         reference_range_factor_id)
       ELSE
        SET reply->rowlist[row_nbr].celllist[44].string_value = " "
       ENDIF
       SET acnt = size(temp->dlist[x].rrf[y].al,5)
       CALL echo(build("acnt:",acnt))
       FOR (z = 1 TO acnt)
         SET row_nbr = (row_nbr+ 1)
         SET stat = alterlist(reply->rowlist,row_nbr)
         SET stat = alterlist(reply->rowlist[row_nbr].celllist,44)
         SET reply->rowlist[row_nbr].celllist[1].string_value = trim(temp->dlist[x].
          activity_type_disp)
         SET reply->rowlist[row_nbr].celllist[2].string_value = trim(temp->dlist[x].dtaname)
         SET reply->rowlist[row_nbr].celllist[3].string_value = trim(temp->dlist[x].dtadesc)
         SET reply->rowlist[row_nbr].celllist[4].string_value = trim(temp->dlist[x].rrf[y].
          service_resource)
         SET reply->rowlist[row_nbr].celllist[5].string_value = "alpha_response"
         SET reply->rowlist[row_nbr].celllist[30].string_value = trim(temp->dlist[x].rrf[y].al[z].
          term)
         SET reply->rowlist[row_nbr].celllist[31].string_value = trim(temp->dlist[x].rrf[y].al[z].
          mnemonic)
         SET reply->rowlist[row_nbr].celllist[32].string_value = trim(temp->dlist[x].rrf[y].al[z].
          long_desc)
         SET reply->rowlist[row_nbr].celllist[33].string_value = trim(temp->dlist[x].rrf[y].al[z].
          vocab)
         SET reply->rowlist[row_nbr].celllist[34].string_value = trim(temp->dlist[x].rrf[y].al[z].
          default)
         SET reply->rowlist[row_nbr].celllist[35].string_value = trim(temp->dlist[x].rrf[y].al[z].
          use_units)
         SET reply->rowlist[row_nbr].celllist[36].string_value = trim(temp->dlist[x].rrf[y].al[z].
          result_process)
         SET reply->rowlist[row_nbr].celllist[37].string_value = trim(temp->dlist[x].rrf[y].al[z].
          reference)
       ENDFOR
      ENDIF
    ENDFOR
    SET nrcnt = size(temp->dlist[x].norrf,5)
    IF (nrcnt > 0
     AND skip_nrrf_ind=0)
     SET save_service_resource = " "
     CALL echo(build("nrcnt:",nrcnt))
     FOR (y = 1 TO nrcnt)
       IF ((temp->dlist[x].norrf[y].service_resource != save_service_resource))
        IF (save_service_resource=" ")
         SET save_service_resource = temp->dlist[x].norrf[y].service_resource
        ELSE
         SET save_service_resource = "Mulitple APR"
        ENDIF
       ENDIF
     ENDFOR
     FOR (y = 1 TO 1)
       SET row_nbr = (row_nbr+ 1)
       SET stat = alterlist(reply->rowlist,row_nbr)
       SET stat = alterlist(reply->rowlist[row_nbr].celllist,44)
       SET reply->rowlist[row_nbr].celllist[1].string_value = trim(temp->dlist[x].activity_type_disp)
       SET reply->rowlist[row_nbr].celllist[2].string_value = trim(temp->dlist[x].dtaname)
       SET reply->rowlist[row_nbr].celllist[3].string_value = trim(temp->dlist[x].dtadesc)
       SET reply->rowlist[row_nbr].celllist[4].string_value = trim(temp->dlist[x].rrf[y].
        service_resource)
       SET reply->rowlist[row_nbr].celllist[5].string_value = trim(temp->dlist[x].dta_result_type)
       SET reply->rowlist[row_nbr].celllist[6].string_value = trim(temp->dlist[x].rrf[y].
        sr_result_type)
       IF ((temp->dlist[x].task_assay_cd > 0))
        SET reply->rowlist[row_nbr].celllist[42].string_value = cnvtstring(temp->dlist[x].
         task_assay_cd)
       ELSE
        SET reply->rowlist[row_nbr].celllist[42].string_value = " "
       ENDIF
     ENDFOR
    ENDIF
    IF (rcnt=0
     AND nrcnt=0
     AND (temp->dlist[x].dtaname > " "))
     SET row_nbr = (row_nbr+ 1)
     SET stat = alterlist(reply->rowlist,row_nbr)
     SET stat = alterlist(reply->rowlist[row_nbr].celllist,44)
     SET reply->rowlist[row_nbr].celllist[1].string_value = trim(temp->dlist[x].activity_type_disp)
     SET reply->rowlist[row_nbr].celllist[2].string_value = trim(temp->dlist[x].dtaname)
     SET reply->rowlist[row_nbr].celllist[3].string_value = trim(temp->dlist[x].dtadesc)
     SET reply->rowlist[row_nbr].celllist[5].string_value = trim(temp->dlist[x].dta_result_type)
     IF ((temp->dlist[x].task_assay_cd > 0))
      SET reply->rowlist[row_nbr].celllist[42].string_value = cnvtstring(temp->dlist[x].task_assay_cd
       )
     ELSE
      SET reply->rowlist[row_nbr].celllist[42].string_value = " "
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("spec_type_refrange_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
