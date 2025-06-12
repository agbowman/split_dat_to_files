CREATE PROGRAM bed_aud_iview_view_assays:dba
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
      2 yes_no_ind = i2
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
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET stat = alterlist(reply->collist,19)
 SET reply->collist[1].header_text = "View"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Assay"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Result Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Service Resource"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Units of Measure"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Numeric Map Maximum Digits"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Numeric Map Minimum Digits"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Numeric Map Minimum Decimal Places"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Age Range From"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Age Range To"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Normal Low"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Normal High"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Critical Low"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "Critical High"
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = "Feasible Low"
 SET reply->collist[15].data_type = 1
 SET reply->collist[15].hide_ind = 0
 SET reply->collist[16].header_text = "Feasible High"
 SET reply->collist[16].data_type = 1
 SET reply->collist[16].hide_ind = 0
 SET reply->collist[17].header_text = "Sex"
 SET reply->collist[17].data_type = 1
 SET reply->collist[17].hide_ind = 0
 SET reply->collist[18].header_text = "Alpha Responses"
 SET reply->collist[18].data_type = 1
 SET reply->collist[18].hide_ind = 0
 SET reply->collist[19].header_text = "Calculation"
 SET reply->collist[19].data_type = 1
 SET reply->collist[19].hide_ind = 0
 SET minutes_per_year = 525600
 SET minutes_per_month = 43200
 SET minutes_per_week = 10080
 SET minutes_per_day = 1440
 SET minutes_per_hour = 60
 SET minutes_per_minute = 1
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
 RECORD temp(
   1 vlist[*]
     2 view_name = vc
     2 dlist[*]
       3 task_assay_cd = f8
       3 mnemonic = vc
       3 result_type = vc
       3 rlist[*]
         4 id = f8
         4 service_resource_cd = f8
         4 service_resource = vc
         4 sex = vc
         4 age_from = i4
         4 af_disp = vc
         4 age_from_units = vc
         4 age_to = i4
         4 at_disp = vc
         4 age_to_units = vc
         4 normal_low = vc
         4 nl_disp = vc
         4 normal_high = vc
         4 nh_disp = vc
         4 normal_ind = i2
         4 critical_low = vc
         4 cl_disp = vc
         4 critical_high = vc
         4 ch_disp = vc
         4 critical_ind = i2
         4 feasible_low = vc
         4 fl_disp = vc
         4 feasible_high = vc
         4 fh_disp = vc
         4 feasible_ind = i2
         4 units = vc
         4 max_digits = i4
         4 min_decimal_places = i4
         4 min_digits = i4
         4 alist[*]
           5 short_string = vc
 )
 SET vcnt = 0
 SET dcnt = 0
 SET rcnt = 0
 SET acnt = 0
 SELECT INTO "nl:"
  FROM working_view wv,
   working_view_section wvs,
   working_view_item wvi,
   v500_event_code vec,
   discrete_task_assay dta
  PLAN (wv
   WHERE wv.active_ind=1)
   JOIN (wvs
   WHERE wvs.working_view_id=wv.working_view_id)
   JOIN (wvi
   WHERE wvi.working_view_section_id=wvs.working_view_section_id)
   JOIN (vec
   WHERE cnvtupper(vec.event_set_name)=cnvtupper(wvi.primitive_event_set_name))
   JOIN (dta
   WHERE dta.event_cd=vec.event_cd)
  ORDER BY wv.display_name, dta.mnemonic
  HEAD wv.display_name
   dcnt = 0, vcnt = (vcnt+ 1), stat = alterlist(temp->vlist,vcnt),
   temp->vlist[vcnt].view_name = wv.display_name
  HEAD dta.mnemonic
   dcnt = (dcnt+ 1), stat = alterlist(temp->vlist[vcnt].dlist,dcnt), temp->vlist[vcnt].dlist[dcnt].
   task_assay_cd = dta.task_assay_cd,
   temp->vlist[vcnt].dlist[dcnt].mnemonic = dta.mnemonic, temp->vlist[vcnt].dlist[dcnt].result_type
    = uar_get_code_display(dta.default_result_type_cd)
  WITH nocounter
 ;end select
 FOR (x = 1 TO vcnt)
  SET dcnt = size(temp->vlist[x].dlist,5)
  IF (dcnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(dcnt)),
     reference_range_factor rrf
    PLAN (d)
     JOIN (rrf
     WHERE (rrf.task_assay_cd=temp->vlist[x].dlist[d.seq].task_assay_cd)
      AND rrf.active_ind=1)
    ORDER BY d.seq
    HEAD d.seq
     rcnt = 0
    DETAIL
     rcnt = (rcnt+ 1), stat = alterlist(temp->vlist[x].dlist[d.seq].rlist,rcnt), temp->vlist[x].
     dlist[d.seq].rlist[rcnt].id = rrf.reference_range_factor_id,
     temp->vlist[x].dlist[d.seq].rlist[rcnt].service_resource_cd = rrf.service_resource_cd
     IF (rrf.service_resource_cd > 0)
      temp->vlist[x].dlist[d.seq].rlist[rcnt].service_resource = uar_get_code_display(rrf
       .service_resource_cd)
     ELSE
      temp->vlist[x].dlist[d.seq].rlist[rcnt].service_resource = "All"
     ENDIF
     temp->vlist[x].dlist[d.seq].rlist[rcnt].sex = uar_get_code_display(rrf.sex_cd), temp->vlist[x].
     dlist[d.seq].rlist[rcnt].units = uar_get_code_display(rrf.units_cd), temp->vlist[x].dlist[d.seq]
     .rlist[rcnt].age_from = rrf.age_from_minutes,
     temp->vlist[x].dlist[d.seq].rlist[rcnt].age_from_units = uar_get_code_display(rrf
      .age_from_units_cd)
     IF (rrf.age_from_units_cd=years_cd)
      temp->vlist[x].dlist[d.seq].rlist[rcnt].age_from = (rrf.age_from_minutes/ minutes_per_year)
     ELSEIF (rrf.age_from_units_cd=months_cd)
      temp->vlist[x].dlist[d.seq].rlist[rcnt].age_from = (rrf.age_from_minutes/ minutes_per_month)
     ELSEIF (rrf.age_from_units_cd=weeks_cd)
      temp->vlist[x].dlist[d.seq].rlist[rcnt].age_from = (rrf.age_from_minutes/ minutes_per_week)
     ELSEIF (rrf.age_from_units_cd=days_cd)
      temp->vlist[x].dlist[d.seq].rlist[rcnt].age_from = (rrf.age_from_minutes/ minutes_per_day)
     ELSEIF (rrf.age_from_units_cd=hours_cd)
      temp->vlist[x].dlist[d.seq].rlist[rcnt].age_from = (rrf.age_from_minutes/ minutes_per_hour)
     ENDIF
     temp->vlist[x].dlist[d.seq].rlist[rcnt].age_to = rrf.age_to_minutes, temp->vlist[x].dlist[d.seq]
     .rlist[rcnt].age_to_units = uar_get_code_display(rrf.age_to_units_cd)
     IF (rrf.age_to_units_cd=years_cd)
      temp->vlist[x].dlist[d.seq].rlist[rcnt].age_to = (rrf.age_to_minutes/ minutes_per_year)
     ELSEIF (rrf.age_to_units_cd=months_cd)
      temp->vlist[x].dlist[d.seq].rlist[rcnt].age_to = (rrf.age_to_minutes/ minutes_per_month)
     ELSEIF (rrf.age_to_units_cd=weeks_cd)
      temp->vlist[x].dlist[d.seq].rlist[rcnt].age_to = (rrf.age_to_minutes/ minutes_per_week)
     ELSEIF (rrf.age_to_units_cd=days_cd)
      temp->vlist[x].dlist[d.seq].rlist[rcnt].age_to = (rrf.age_to_minutes/ minutes_per_day)
     ELSEIF (rrf.age_to_units_cd=hours_cd)
      temp->vlist[x].dlist[d.seq].rlist[rcnt].age_to = (rrf.age_to_minutes/ minutes_per_hour)
     ENDIF
     temp->vlist[x].dlist[d.seq].rlist[rcnt].normal_ind = rrf.normal_ind
     IF (rrf.normal_ind=1)
      temp->vlist[x].dlist[d.seq].rlist[rcnt].normal_low = format(rrf.normal_low,
       "##########.##########;I;f")
     ELSEIF (rrf.normal_ind=2)
      temp->vlist[x].dlist[d.seq].rlist[rcnt].normal_high = format(rrf.normal_high,
       "##########.##########;I;f")
     ELSEIF (rrf.normal_ind=3)
      temp->vlist[x].dlist[d.seq].rlist[rcnt].normal_low = format(rrf.normal_low,
       "##########.##########;I;f"), temp->vlist[x].dlist[d.seq].rlist[rcnt].normal_high = format(rrf
       .normal_high,"##########.##########;I;f")
     ENDIF
     temp->vlist[x].dlist[d.seq].rlist[rcnt].critical_ind = rrf.critical_ind
     IF (rrf.critical_ind=1)
      temp->vlist[x].dlist[d.seq].rlist[rcnt].critical_low = format(rrf.critical_low,
       "##########.##########;I;f")
     ELSEIF (rrf.critical_ind=2)
      temp->vlist[x].dlist[d.seq].rlist[rcnt].critical_high = format(rrf.critical_high,
       "##########.##########;I;f")
     ELSEIF (rrf.critical_ind=3)
      temp->vlist[x].dlist[d.seq].rlist[rcnt].critical_low = format(rrf.critical_low,
       "##########.##########;I;f"), temp->vlist[x].dlist[d.seq].rlist[rcnt].critical_high = format(
       rrf.critical_high,"##########.##########;I;f")
     ENDIF
     temp->vlist[x].dlist[d.seq].rlist[rcnt].feasible_ind = rrf.feasible_ind
     IF (rrf.feasible_ind=1)
      temp->vlist[x].dlist[d.seq].rlist[rcnt].feasible_low = format(rrf.feasible_low,
       "##########.##########;I;f")
     ELSEIF (rrf.feasible_ind=2)
      temp->vlist[x].dlist[d.seq].rlist[rcnt].feasible_high = format(rrf.feasible_high,
       "##########.##########;I;f")
     ELSEIF (rrf.feasible_ind=3)
      temp->vlist[x].dlist[d.seq].rlist[rcnt].feasible_low = format(rrf.feasible_low,
       "##########.##########;I;f"), temp->vlist[x].dlist[d.seq].rlist[rcnt].feasible_high = format(
       rrf.feasible_high,"##########.##########;I;f")
     ENDIF
    WITH nocounter
   ;end select
   FOR (y = 1 TO dcnt)
    SET rcnt = size(temp->vlist[x].dlist[y].rlist,5)
    IF (rcnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(rcnt)),
       data_map dm
      PLAN (d)
       JOIN (dm
       WHERE (dm.task_assay_cd=temp->vlist[x].dlist[y].task_assay_cd)
        AND (dm.service_resource_cd=temp->vlist[x].dlist[y].rlist[d.seq].service_resource_cd)
        AND dm.active_ind=1
        AND dm.data_map_type_flag=0)
      ORDER BY d.seq
      HEAD d.seq
       temp->vlist[x].dlist[y].rlist[d.seq].max_digits = dm.max_digits, temp->vlist[x].dlist[y].
       rlist[d.seq].min_digits = dm.min_digits, temp->vlist[x].dlist[y].rlist[d.seq].
       min_decimal_places = dm.min_decimal_places
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(rcnt)),
       alpha_responses ar,
       nomenclature n
      PLAN (d)
       JOIN (ar
       WHERE (ar.reference_range_factor_id=temp->vlist[x].dlist[y].rlist[d.seq].id)
        AND ar.active_ind=1)
       JOIN (n
       WHERE n.nomenclature_id=ar.nomenclature_id
        AND n.active_ind=1)
      ORDER BY d.seq, ar.sequence
      HEAD d.seq
       acnt = 0
      DETAIL
       acnt = (acnt+ 1), stat = alterlist(temp->vlist[x].dlist[y].rlist[d.seq].alist,acnt), temp->
       vlist[x].dlist[y].rlist[d.seq].alist[acnt].short_string = n.short_string
      WITH nocounter
     ;end select
    ENDIF
   ENDFOR
  ENDIF
 ENDFOR
 SET normal_range_txt = fillstring(20," ")
 SET normal_low_txt = fillstring(50," ")
 SET normal_high_txt = fillstring(50," ")
 SET critical_range_txt = fillstring(20," ")
 SET critical_low_txt = fillstring(50," ")
 SET critical_high_txt = fillstring(50," ")
 SET feasible_range_txt = fillstring(20," ")
 SET feasible_low_txt = fillstring(50," ")
 SET feasible_high_txt = fillstring(50," ")
 SET text_nbr = fillstring(50," ")
 SET min_dec_digits = 0
 SET text_char = " "
 SET text = fillstring(50," ")
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
 SET row_nbr = 0
 SET rowcnt = 0
 FOR (w = 1 TO vcnt)
  SET dcnt = size(temp->vlist[w].dlist,5)
  IF (dcnt > 0)
   SET rowcnt = (rowcnt+ 1)
   SET stat = alterlist(reply->rowlist,rowcnt)
   SET stat = alterlist(reply->rowlist[rowcnt].celllist,19)
   SET reply->rowlist[rowcnt].celllist[1].string_value = temp->vlist[w].view_name
   FOR (x = 1 TO dcnt)
     IF (x != 1)
      SET rowcnt = (rowcnt+ 1)
      SET stat = alterlist(reply->rowlist,rowcnt)
      SET stat = alterlist(reply->rowlist[rowcnt].celllist,19)
     ENDIF
     SET reply->rowlist[rowcnt].celllist[2].string_value = temp->vlist[w].dlist[x].mnemonic
     SET reply->rowlist[rowcnt].celllist[3].string_value = temp->vlist[w].dlist[x].result_type
     SET rcnt = size(temp->vlist[w].dlist[x].rlist,5)
     IF (rcnt > 0)
      FOR (y = 1 TO rcnt)
        IF (y != 1)
         SET rowcnt = (rowcnt+ 1)
         SET stat = alterlist(reply->rowlist,rowcnt)
         SET stat = alterlist(reply->rowlist[rowcnt].celllist,19)
        ENDIF
        SET reply->rowlist[rowcnt].celllist[4].string_value = temp->vlist[w].dlist[x].rlist[y].
        service_resource
        SET reply->rowlist[rowcnt].celllist[5].string_value = temp->vlist[w].dlist[x].rlist[y].units
        SET reply->rowlist[rowcnt].celllist[6].string_value = cnvtstring(temp->vlist[w].dlist[x].
         rlist[y].max_digits)
        SET reply->rowlist[rowcnt].celllist[7].string_value = cnvtstring(temp->vlist[w].dlist[x].
         rlist[y].min_digits)
        SET reply->rowlist[rowcnt].celllist[8].string_value = cnvtstring(temp->vlist[w].dlist[x].
         rlist[y].min_decimal_places)
        SET reply->rowlist[rowcnt].celllist[9].string_value = concat(cnvtstring(temp->vlist[w].dlist[
          x].rlist[y].age_from)," ",temp->vlist[w].dlist[x].rlist[y].age_from_units)
        SET reply->rowlist[rowcnt].celllist[10].string_value = concat(cnvtstring(temp->vlist[w].
          dlist[x].rlist[y].age_to)," ",temp->vlist[w].dlist[x].rlist[y].age_to_units)
        SET min_dec_digits = temp->vlist[w].dlist[x].rlist[y].min_decimal_places
        SET normal_low_txt = ""
        SET normal_high_txt = ""
        IF ((temp->vlist[w].dlist[x].rlist[y].normal_ind=1))
         SET text_nbr = temp->vlist[w].dlist[x].rlist[y].normal_low
         SET stat = convert_range_number(row_nbr)
         SET normal_low_txt = text
         SET temp->vlist[w].dlist[x].rlist[y].nl_disp = trim(normal_low_txt)
        ELSEIF ((temp->vlist[w].dlist[x].rlist[y].normal_ind=2))
         SET text_nbr = temp->vlist[w].dlist[x].rlist[y].normal_high
         SET stat = convert_range_number(row_nbr)
         SET normal_high_txt = text
         SET temp->vlist[w].dlist[x].rlist[y].nh_disp = trim(normal_high_txt)
        ELSEIF ((temp->vlist[w].dlist[x].rlist[y].normal_ind=3))
         SET text_nbr = temp->vlist[w].dlist[x].rlist[y].normal_low
         SET stat = convert_range_number(row_nbr)
         SET normal_low_txt = text
         SET temp->vlist[w].dlist[x].rlist[y].nl_disp = trim(normal_low_txt)
         SET text_nbr = temp->vlist[w].dlist[x].rlist[y].normal_high
         SET stat = convert_range_number(row_nbr)
         SET normal_high_txt = text
         SET temp->vlist[w].dlist[x].rlist[y].nh_disp = trim(normal_high_txt)
        ENDIF
        IF ((temp->vlist[w].dlist[x].rlist[y].critical_ind=1))
         SET text_nbr = temp->vlist[w].dlist[x].rlist[y].critical_low
         SET stat = convert_range_number(row_nbr)
         SET critical_low_txt = text
         SET temp->vlist[w].dlist[x].rlist[y].cl_disp = trim(critical_low_txt)
        ELSEIF ((temp->vlist[w].dlist[x].rlist[y].critical_ind=2))
         SET text_nbr = temp->vlist[w].dlist[x].rlist[y].critical_high
         SET stat = convert_range_number(row_nbr)
         SET critical_high_txt = text
         SET temp->vlist[w].dlist[x].rlist[y].ch_disp = trim(critical_high_txt)
        ELSEIF ((temp->vlist[w].dlist[x].rlist[y].critical_ind=3))
         SET text_nbr = temp->vlist[w].dlist[x].rlist[y].critical_low
         SET stat = convert_range_number(row_nbr)
         SET critical_low_txt = text
         SET temp->vlist[w].dlist[x].rlist[y].cl_disp = trim(critical_low_txt)
         SET text_nbr = temp->vlist[w].dlist[x].rlist[y].critical_high
         SET stat = convert_range_number(row_nbr)
         SET critical_high_txt = text
         SET temp->vlist[w].dlist[x].rlist[y].ch_disp = trim(critical_high_txt)
        ENDIF
        IF ((temp->vlist[w].dlist[x].rlist[y].feasible_ind=1))
         SET text_nbr = temp->vlist[w].dlist[x].rlist[y].feasible_low
         SET stat = convert_range_number(row_nbr)
         SET feasible_low_txt = text
         SET temp->vlist[w].dlist[x].rlist[y].fl_disp = trim(feasible_low_txt)
        ELSEIF ((temp->vlist[w].dlist[x].rlist[y].feasible_ind=2))
         SET text_nbr = temp->vlist[w].dlist[x].rlist[y].feasible_high
         SET stat = convert_range_number(row_nbr)
         SET feasible_high_txt = text
         SET temp->vlist[w].dlist[x].rlist[y].fh_disp = trim(feasible_high_txt)
        ELSEIF ((temp->vlist[w].dlist[x].rlist[y].feasible_ind=3))
         SET text_nbr = temp->vlist[w].dlist[x].rlist[y].feasible_low
         SET stat = convert_range_number(row_nbr)
         SET feasible_low_txt = text
         SET temp->vlist[w].dlist[x].rlist[y].fl_disp = trim(feasible_low_txt)
         SET text_nbr = temp->vlist[w].dlist[x].rlist[y].feasible_high
         SET stat = convert_range_number(row_nbr)
         SET feasible_high_txt = text
         SET temp->vlist[w].dlist[x].rlist[y].fh_disp = trim(feasible_high_txt)
        ENDIF
        SET reply->rowlist[rowcnt].celllist[11].string_value = temp->vlist[w].dlist[x].rlist[y].
        nl_disp
        SET reply->rowlist[rowcnt].celllist[12].string_value = temp->vlist[w].dlist[x].rlist[y].
        nh_disp
        SET reply->rowlist[rowcnt].celllist[13].string_value = temp->vlist[w].dlist[x].rlist[y].
        cl_disp
        SET reply->rowlist[rowcnt].celllist[14].string_value = temp->vlist[w].dlist[x].rlist[y].
        ch_disp
        SET reply->rowlist[rowcnt].celllist[15].string_value = temp->vlist[w].dlist[x].rlist[y].
        fl_disp
        SET reply->rowlist[rowcnt].celllist[16].string_value = temp->vlist[w].dlist[x].rlist[y].
        fh_disp
        SET reply->rowlist[rowcnt].celllist[17].string_value = temp->vlist[w].dlist[x].rlist[y].sex
        SET acnt = size(temp->vlist[w].dlist[x].rlist[y].alist,5)
        IF (acnt > 0)
         FOR (z = 1 TO acnt)
          IF (z != 1)
           SET rowcnt = (rowcnt+ 1)
           SET stat = alterlist(reply->rowlist,rowcnt)
           SET stat = alterlist(reply->rowlist[rowcnt].celllist,19)
          ENDIF
          SET reply->rowlist[rowcnt].celllist[18].string_value = temp->vlist[w].dlist[x].rlist[y].
          alist[z].short_string
         ENDFOR
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
  ENDIF
 ENDFOR
 CALL echo(rowcnt)
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("iview_view_assay_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 SET reply->status_data.status = "S"
END GO
