CREATE PROGRAM bed_aud_ref_range_notify_rules:dba
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
     2 activity_type_cd = f8
     2 activity_type_disp = vc
     2 task_assay_cd = f8
     2 dtaname = vc
     2 dtadesc = vc
     2 dta_result_type_cd = f8
     2 dta_result_type = vc
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
       3 delta_value = f8
       3 al[*]
         4 mnemonic = vc
       3 notify_rules[*]
         4 trigger_name = vc
 )
 SET minutes_per_year = 525600
 SET minutes_per_month = 43200
 SET minutes_per_week = 10080
 SET minutes_per_day = 1440
 SET minutes_per_hour = 60
 SET minutes_per_minute = 1
 DECLARE glb_cd = f8
 DECLARE glb_disp = vc
 DECLARE bb_cd = f8
 DECLARE bb_disp = vc
 DECLARE hla_cd = f8
 DECLARE hla_disp = vc
 DECLARE hlx_cd = f8
 DECLARE hlx_disp = vc
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=106
   AND cv.cdf_meaning IN ("GLB", "BB", "HLA", "HLX")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="GLB")
    glb_cd = cv.code_value, glb_disp = cv.display
   ELSEIF (cv.cdf_meaning="BB")
    bb_cd = cv.code_value, bb_disp = cv.display
   ELSEIF (cv.cdf_meaning="HLA")
    hla_cd = cv.code_value, hla_disp = cv.display
   ELSEIF (cv.cdf_meaning="HLX")
    hlx_cd = cv.code_value, hlx_disp = cv.display
   ENDIF
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
   WHERE c.code_set=340
    AND c.active_ind=1)
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
  SELECT DISTINCT INTO "NL:"
   FROM ref_range_notify_trig nt,
    reference_range_factor rrf,
    discrete_task_assay dta,
    code_value cvdta,
    code_value rt,
    profile_task_r ptr,
    order_catalog oc
   PLAN (nt)
    JOIN (rrf
    WHERE rrf.reference_range_factor_id=nt.reference_range_factor_id
     AND rrf.active_ind=1)
    JOIN (dta
    WHERE dta.task_assay_cd=rrf.task_assay_cd
     AND dta.activity_type_cd IN (glb_cd, bb_cd, hla_cd, hlx_cd)
     AND dta.active_ind=1)
    JOIN (cvdta
    WHERE cvdta.code_value=dta.task_assay_cd)
    JOIN (rt
    WHERE rt.code_value=dta.default_result_type_cd)
    JOIN (ptr
    WHERE ptr.task_assay_cd=dta.task_assay_cd)
    JOIN (oc
    WHERE oc.catalog_cd=ptr.catalog_cd
     AND oc.active_ind=1)
   ORDER BY nt.ref_range_notify_trig_id
   HEAD nt.ref_range_notify_trig_id
    high_volume_cnt = (high_volume_cnt+ 1)
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
 SELECT DISTINCT INTO "NL:"
  FROM ref_range_notify_trig nt,
   reference_range_factor rrf,
   discrete_task_assay dta,
   code_value cvdta,
   code_value rt,
   profile_task_r ptr,
   order_catalog oc
  PLAN (nt)
   JOIN (rrf
   WHERE rrf.reference_range_factor_id=nt.reference_range_factor_id
    AND rrf.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=rrf.task_assay_cd
    AND dta.activity_type_cd IN (glb_cd, bb_cd, hla_cd, hlx_cd)
    AND dta.active_ind=1)
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
   ELSEIF (dta.activity_type_cd=bb_cd)
    temp->dlist[tcnt].activity_type_disp = bb_disp
   ELSEIF (dta.activity_type_cd=hla_cd)
    temp->dlist[tcnt].activity_type_disp = hla_disp
   ELSEIF (dta.activity_type_cd=hlx_cd)
    temp->dlist[tcnt].activity_type_disp = hlx_disp
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
 SELECT INTO "nl:"
  servres =
  IF (cvts.code_value > 0
   AND cvts.display > " ") cvts.display
  ELSE "All                                   "
  ENDIF
  FROM (dummyt d  WITH seq = tcnt),
   reference_range_factor rrf,
   code_value cvts,
   code_value cvs,
   code_value cvaf,
   code_value cvat,
   code_value cvu,
   code_value cvspecies,
   code_value cvspectype,
   code_value cvdelta,
   ref_range_notify_trig nt
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
   JOIN (nt
   WHERE nt.reference_range_factor_id=rrf.reference_range_factor_id)
  ORDER BY d.seq, servres, rrf.precedence_sequence,
   cvts.display, rrf.reference_range_factor_id
  HEAD d.seq
   rcnt = 0
  HEAD rrf.reference_range_factor_id
   rcnt = (rcnt+ 1), stat = alterlist(temp->dlist[d.seq].rrf,rcnt), temp->dlist[d.seq].rrf[rcnt].
   skip_ind = 0,
   temp->dlist[d.seq].rrf[rcnt].reference_range_factor_id = rrf.reference_range_factor_id, temp->
   dlist[d.seq].rrf[rcnt].service_resource_cd = rrf.service_resource_cd
   IF (cvts.code_value > 0
    AND cvts.display > " ")
    temp->dlist[d.seq].rrf[rcnt].service_resource = trim(cvts.display)
   ELSE
    temp->dlist[d.seq].rrf[rcnt].service_resource = "All"
   ENDIF
   temp->dlist[d.seq].rrf[rcnt].unknown_age_ind = rrf.unknown_age_ind
   IF (rrf.unknown_age_ind=1)
    temp->dlist[d.seq].rrf[rcnt].unknown_age_str = "Yes"
   ELSEIF (rrf.unknown_age_ind=0)
    temp->dlist[d.seq].rrf[rcnt].unknown_age_str = " "
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
   ENDIF
   temp->dlist[d.seq].rrf[rcnt].units_cd = rrf.units_cd
   IF (cvs.code_value > 0)
    temp->dlist[d.seq].rrf[rcnt].sex = trim(cvs.display)
   ELSE
    temp->dlist[d.seq].rrf[rcnt].sex = "All"
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
    temp->dlist[d.seq].rrf[rcnt].specimen_type = "All"
   ENDIF
   IF (cvdelta.code_value > 0)
    temp->dlist[d.seq].rrf[rcnt].delta_check_type_disp = trim(cvdelta.display), temp->dlist[d.seq].
    rrf[rcnt].delta_value = rrf.delta_value
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
    = "(None)", ncnt = 0
  DETAIL
   ncnt = (ncnt+ 1), stat = alterlist(temp->dlist[d.seq].rrf[rcnt].notify_rules,ncnt), temp->dlist[d
   .seq].rrf[rcnt].notify_rules[ncnt].trigger_name = nt.trigger_name
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
     min_decimal_places = dm.min_decimal_places, temp->dlist[x].rrf[d.seq].min_digits = dm.min_digits
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
     acnt = (acnt+ 1), stat = alterlist(temp->dlist[x].rrf[d.seq].al,acnt), temp->dlist[x].rrf[d.seq]
     .al[acnt].mnemonic = trim(n.mnemonic)
    WITH nocounter
   ;end select
  ENDIF
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
 SET stat = alterlist(reply->collist,29)
 SET reply->collist[1].header_text = "Activity Type"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Assay Display"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Instrument/Bench"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Notify Rule"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Age From"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Unit"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Age To"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Unit"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Unknown Age"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Sex"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Specimen Type"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Reference Low"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Reference High"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "Critical Low"
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = "Critical High"
 SET reply->collist[15].data_type = 1
 SET reply->collist[15].hide_ind = 0
 SET reply->collist[16].header_text = "Review Low"
 SET reply->collist[16].data_type = 1
 SET reply->collist[16].hide_ind = 0
 SET reply->collist[17].header_text = "Review High"
 SET reply->collist[17].data_type = 1
 SET reply->collist[17].hide_ind = 0
 SET reply->collist[18].header_text = "Linear Low"
 SET reply->collist[18].data_type = 1
 SET reply->collist[18].hide_ind = 0
 SET reply->collist[19].header_text = "Linear High"
 SET reply->collist[19].data_type = 1
 SET reply->collist[19].hide_ind = 0
 SET reply->collist[20].header_text = "Feasible Low"
 SET reply->collist[20].data_type = 1
 SET reply->collist[20].hide_ind = 0
 SET reply->collist[21].header_text = "Feasible High"
 SET reply->collist[21].data_type = 1
 SET reply->collist[21].hide_ind = 0
 SET reply->collist[22].header_text = "Alpha Response"
 SET reply->collist[22].data_type = 1
 SET reply->collist[22].hide_ind = 0
 SET reply->collist[23].header_text = "Delta Check Type"
 SET reply->collist[23].data_type = 1
 SET reply->collist[23].hide_ind = 0
 SET reply->collist[24].header_text = "Delta Time Frame"
 SET reply->collist[24].data_type = 1
 SET reply->collist[24].hide_ind = 0
 SET reply->collist[25].header_text = "Delta Time Frame Units"
 SET reply->collist[25].data_type = 1
 SET reply->collist[25].hide_ind = 0
 SET reply->collist[26].header_text = "Delta Value"
 SET reply->collist[26].data_type = 1
 SET reply->collist[26].hide_ind = 0
 SET reply->collist[27].header_text = "task_assay_cd"
 SET reply->collist[27].data_type = 1
 SET reply->collist[27].hide_ind = 1
 SET reply->collist[28].header_text = "service_resource_cd"
 SET reply->collist[28].data_type = 1
 SET reply->collist[28].hide_ind = 1
 SET reply->collist[29].header_text = "reference_range_factor_id"
 SET reply->collist[29].data_type = 1
 SET reply->collist[29].hide_ind = 1
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET rcnt = size(temp->dlist[x].rrf,5)
   SET save_sr_result_type = "(None)"
   FOR (y = 1 TO rcnt)
     IF ((temp->dlist[x].rrf[y].sr_result_type != save_sr_result_type)
      AND (temp->dlist[x].rrf[y].sr_result_type != "(None)"))
      IF (save_sr_result_type="(None)")
       SET save_sr_result_type = temp->dlist[x].rrf[y].sr_result_type
      ELSE
       SET save_sr_result_type = "Multiple"
      ENDIF
     ENDIF
   ENDFOR
   FOR (y = 1 TO rcnt)
     IF ((temp->dlist[x].rrf[y].service_resource="All")
      AND (temp->dlist[x].rrf[y].sr_result_type="(None)"))
      SET temp->dlist[x].rrf[y].sr_result_type = save_sr_result_type
     ENDIF
   ENDFOR
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
      SET row_nbr = (row_nbr+ 1)
      SET stat = alterlist(reply->rowlist,row_nbr)
      SET stat = alterlist(reply->rowlist[row_nbr].celllist,29)
      SET reply->rowlist[row_nbr].celllist[1].string_value = trim(temp->dlist[x].activity_type_disp)
      SET reply->rowlist[row_nbr].celllist[2].string_value = trim(temp->dlist[x].dtaname)
      SET reply->rowlist[row_nbr].celllist[3].string_value = trim(temp->dlist[x].rrf[y].
       service_resource)
      SET reply->rowlist[row_nbr].celllist[5].string_value = temp->dlist[x].rrf[y].af_disp
      SET reply->rowlist[row_nbr].celllist[6].string_value = temp->dlist[x].rrf[y].age_from_unit
      SET reply->rowlist[row_nbr].celllist[7].string_value = temp->dlist[x].rrf[y].at_disp
      SET reply->rowlist[row_nbr].celllist[8].string_value = temp->dlist[x].rrf[y].age_to_unit
      SET reply->rowlist[row_nbr].celllist[9].string_value = trim(temp->dlist[x].rrf[y].
       unknown_age_str)
      SET reply->rowlist[row_nbr].celllist[10].string_value = trim(temp->dlist[x].rrf[y].sex)
      SET reply->rowlist[row_nbr].celllist[11].string_value = trim(temp->dlist[x].rrf[y].
       specimen_type)
      SET reply->rowlist[row_nbr].celllist[12].string_value = trim(temp->dlist[x].rrf[y].nl_disp)
      SET reply->rowlist[row_nbr].celllist[13].string_value = trim(temp->dlist[x].rrf[y].nh_disp)
      SET reply->rowlist[row_nbr].celllist[14].string_value = trim(temp->dlist[x].rrf[y].cl_disp)
      SET reply->rowlist[row_nbr].celllist[15].string_value = trim(temp->dlist[x].rrf[y].ch_disp)
      SET reply->rowlist[row_nbr].celllist[16].string_value = trim(temp->dlist[x].rrf[y].rl_disp)
      SET reply->rowlist[row_nbr].celllist[17].string_value = trim(temp->dlist[x].rrf[y].rh_disp)
      SET reply->rowlist[row_nbr].celllist[18].string_value = trim(temp->dlist[x].rrf[y].ll_disp)
      SET reply->rowlist[row_nbr].celllist[19].string_value = trim(temp->dlist[x].rrf[y].lh_disp)
      SET reply->rowlist[row_nbr].celllist[20].string_value = trim(temp->dlist[x].rrf[y].fl_disp)
      SET reply->rowlist[row_nbr].celllist[21].string_value = trim(temp->dlist[x].rrf[y].fh_disp)
      SET reply->rowlist[row_nbr].celllist[23].string_value = trim(temp->dlist[x].rrf[y].
       delta_check_type_disp)
      IF ((temp->dlist[x].rrf[y].delta_time_value > 0))
       SET reply->rowlist[row_nbr].celllist[24].string_value = cnvtstring(temp->dlist[x].rrf[y].
        delta_time_value)
      ELSE
       SET reply->rowlist[row_nbr].celllist[24].string_value = " "
      ENDIF
      SET reply->rowlist[row_nbr].celllist[25].string_value = trim(temp->dlist[x].rrf[y].
       delta_time_unit)
      IF ((temp->dlist[x].rrf[y].delta_value > 0))
       SET reply->rowlist[row_nbr].celllist[26].string_value = cnvtstring(temp->dlist[x].rrf[y].
        delta_value)
      ELSE
       SET reply->rowlist[row_nbr].celllist[26].string_value = " "
      ENDIF
      SET reply->rowlist[row_nbr].celllist[27].string_value = cnvtstring(temp->dlist[x].task_assay_cd
       )
      SET reply->rowlist[row_nbr].celllist[28].string_value = cnvtstring(temp->dlist[x].rrf[y].
       service_resource_cd)
      SET reply->rowlist[row_nbr].celllist[29].string_value = cnvtstring(temp->dlist[x].rrf[y].
       reference_range_factor_id)
      SET acnt = size(temp->dlist[x].rrf[y].al,5)
      IF (acnt > 0)
       SET reply->rowlist[row_nbr].celllist[22].string_value = "Yes"
      ELSE
       SET reply->rowlist[row_nbr].celllist[22].string_value = "No"
      ENDIF
      SET reply->rowlist[row_nbr].celllist[4].string_value = trim(temp->dlist[x].rrf[y].notify_rules[
       1].trigger_name)
      SET ncnt = size(temp->dlist[x].rrf[y].notify_rules,5)
      FOR (z = 2 TO ncnt)
        SET row_nbr = (row_nbr+ 1)
        SET stat = alterlist(reply->rowlist,row_nbr)
        SET stat = alterlist(reply->rowlist[row_nbr].celllist,29)
        SET reply->rowlist[row_nbr].celllist[1].string_value = trim(temp->dlist[x].activity_type_disp
         )
        SET reply->rowlist[row_nbr].celllist[2].string_value = trim(temp->dlist[x].dtaname)
        SET reply->rowlist[row_nbr].celllist[3].string_value = trim(temp->dlist[x].rrf[y].
         service_resource)
        SET reply->rowlist[row_nbr].celllist[4].string_value = trim(temp->dlist[x].rrf[y].
         notify_rules[z].trigger_name)
      ENDFOR
     ENDIF
   ENDFOR
   IF (rcnt=0
    AND nrcnt=0
    AND (temp->dlist[x].dtaname > " "))
    SET row_nbr = (row_nbr+ 1)
    SET stat = alterlist(reply->rowlist,row_nbr)
    SET stat = alterlist(reply->rowlist[row_nbr].celllist,29)
    SET reply->rowlist[row_nbr].celllist[1].string_value = trim(temp->dlist[x].activity_type_disp)
    SET reply->rowlist[row_nbr].celllist[2].string_value = trim(temp->dlist[x].dtaname)
    SET reply->rowlist[row_nbr].celllist[27].string_value = cnvtstring(temp->dlist[x].task_assay_cd)
   ENDIF
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("ref_range_notify_rules_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
