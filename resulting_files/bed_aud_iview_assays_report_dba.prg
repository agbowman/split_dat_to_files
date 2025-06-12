CREATE PROGRAM bed_aud_iview_assays_report:dba
 IF ( NOT (validate(request,0)))
  FREE SET request
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 iviews[*]
      2 iview_id = f8
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
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
 FREE RECORD tes
 RECORD tes(
   1 tes[*]
     2 event_set_name = vc
     2 da_ind = i2
     2 da_cd = f8
 )
 FREE RECORD dtas
 RECORD dtas(
   1 dtas[*]
     2 dta_code = f8
     2 dynamic_id = f8
     2 min_decimal_places = i4
     2 max_digits = i4
     2 min_digits = i4
 )
 FREE RECORD label_dtas
 RECORD label_dtas(
   1 dtas[*]
     2 dta_code = f8
 )
 FREE RECORD assays
 RECORD assays(
   1 rowlist[*]
     2 task_assay_cd = f8
 )
 SET reply->status_data.status = "F"
 SET minutes_per_year = 525600
 SET minutes_per_month = 44640
 SET minutes_per_week = 10080
 SET minutes_per_day = 1440
 SET minutes_per_hour = 60
 SET minutes_per_minute = 1
 SET female = 0.0
 SET female = uar_get_code_by("MEANING",57,"FEMALE")
 SET male = 0.0
 SET male = uar_get_code_by("MEANING",57,"MALE")
 SET unknown = 0.0
 SET unknown = uar_get_code_by("MEANING",57,"UNKNOWN")
 SET hours = 0.0
 SET hours = uar_get_code_by("MEANING",340,"HOURS")
 SET days = 0.0
 SET days = uar_get_code_by("MEANING",340,"DAYS")
 SET weeks = 0.0
 SET weeks = uar_get_code_by("MEANING",340,"WEEKS")
 SET months = 0.0
 SET months = uar_get_code_by("MEANING",340,"MONTHS")
 SET years = 0.0
 SET years = uar_get_code_by("MEANING",340,"YEARS")
 SET tot_col = 20
 SET stat = alterlist(reply->collist,tot_col)
 SET reply->collist[1].header_text = "Assay Mnemonic"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Assay Result Type"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Alpha Response"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "First Alpha Single Select"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Witness Required"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Alpha Details Result"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Unit of Measure"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Maximum Digits"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Minimum Digits"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Decimal Places"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Default Value"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Age Range"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Reference Low"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "Reference High"
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = "Critical Low"
 SET reply->collist[15].data_type = 1
 SET reply->collist[15].hide_ind = 0
 SET reply->collist[16].header_text = "Critical High"
 SET reply->collist[16].data_type = 1
 SET reply->collist[16].hide_ind = 0
 SET reply->collist[17].header_text = "Feasible Low"
 SET reply->collist[17].data_type = 1
 SET reply->collist[17].hide_ind = 0
 SET reply->collist[18].header_text = "Feasible High"
 SET reply->collist[18].data_type = 1
 SET reply->collist[18].hide_ind = 0
 SET reply->collist[19].header_text = "Sex"
 SET reply->collist[19].data_type = 1
 SET reply->collist[19].hide_ind = 0
 SET reply->collist[20].header_text = "Calculation"
 SET reply->collist[20].data_type = 1
 SET reply->collist[20].hide_ind = 0
 SET req_cnt = size(request->iviews,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 DECLARE num = i4
 DECLARE text_nbr = vc
 SET min_dec_digits = 0
 SET text_char = " "
 DECLARE text = vc
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
 SET tot_wvcnt = 0
 SET ttot_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   working_view wv,
   working_view_section wvs,
   v500_event_set_code vsi,
   v500_event_set_code ves,
   working_view_item wvi
  PLAN (d)
   JOIN (wv
   WHERE (wv.working_view_id=request->iviews[d.seq].view_id)
    AND wv.active_ind=1)
   JOIN (wvs
   WHERE wvs.working_view_id=wv.working_view_id)
   JOIN (wvi
   WHERE wvi.working_view_section_id=wvs.working_view_section_id)
   JOIN (vsi
   WHERE cnvtupper(vsi.event_set_name)=cnvtupper(wvi.parent_event_set_name))
   JOIN (ves
   WHERE cnvtupper(ves.event_set_name)=cnvtupper(wvi.primitive_event_set_name))
  ORDER BY ves.event_set_name
  HEAD REPORT
   tcnt = 0, ttot_cnt = 0, stat = alterlist(tes->tes,100)
  HEAD ves.event_set_name
   tcnt = (tcnt+ 1), ttot_cnt = (ttot_cnt+ 1)
   IF (tcnt > 100)
    stat = alterlist(tes->tes,(ttot_cnt+ 100)), tcnt = 1
   ENDIF
   tes->tes[ttot_cnt].event_set_name = ves.event_set_name, tes->tes[ttot_cnt].da_ind = ves
   .display_association_ind, tes->tes[ttot_cnt].da_cd = ves.event_set_cd
  FOOT REPORT
   stat = alterlist(tes->tes,ttot_cnt)
  WITH nocounter
 ;end select
 IF (ttot_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = ttot_cnt),
    v500_event_set_canon vs,
    v500_event_set_code vc
   PLAN (d
    WHERE (tes->tes[d.seq].da_ind=1))
    JOIN (vs
    WHERE (vs.parent_event_set_cd=tes->tes[d.seq].da_cd))
    JOIN (vc
    WHERE vc.event_set_cd=vs.event_set_cd)
   ORDER BY vc.event_set_name
   HEAD REPORT
    tcnt = 0, ttot_cnt = size(tes->tes,5), stat = alterlist(tes->tes,(ttot_cnt+ 100))
   HEAD vc.event_set_name
    tcnt = (tcnt+ 1), ttot_cnt = (ttot_cnt+ 1)
    IF (tcnt > 100)
     stat = alterlist(tes->tes,(ttot_cnt+ 100)), tcnt = 1
    ENDIF
    tes->tes[ttot_cnt].event_set_name = vc.event_set_name
   FOOT REPORT
    stat = alterlist(tes->tes,ttot_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (ttot_cnt > 0)
  SET dtot_cnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = ttot_cnt),
    v500_event_code vc,
    discrete_task_assay dta
   PLAN (d)
    JOIN (vc
    WHERE cnvtupper(vc.event_set_name)=cnvtupper(tes->tes[d.seq].event_set_name))
    JOIN (dta
    WHERE dta.event_cd=vc.event_cd)
   ORDER BY dta.task_assay_cd
   HEAD REPORT
    dcnt = 0, dtot_cnt = 0, stat = alterlist(dtas->dtas,100)
   HEAD dta.task_assay_cd
    dcnt = (dcnt+ 1), dtot_cnt = (dtot_cnt+ 1)
    IF (dcnt > 100)
     stat = alterlist(dtas->dtas,(dtot_cnt+ 100)), dcnt = 1
    ENDIF
    dtas->dtas[dtot_cnt].dta_code = dta.task_assay_cd, dtas->dtas[dtot_cnt].dynamic_id = dta
    .label_template_id
   FOOT REPORT
    stat = alterlist(dtas->dtas,dtot_cnt)
   WITH nocounter
  ;end select
  IF (dtot_cnt=0)
   GO TO exit_script
  ENDIF
  SET ldtot_cnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = dtot_cnt),
    dynamic_label_template dgt,
    doc_set_ref dsr,
    doc_set_element_ref der,
    doc_set_section_ref_r drr
   PLAN (d
    WHERE (dtas->dtas[d.seq].dynamic_id > 0))
    JOIN (dgt
    WHERE (dgt.label_template_id=dtas->dtas[d.seq].dynamic_id))
    JOIN (dsr
    WHERE dsr.doc_set_ref_id=dgt.doc_set_ref_id
     AND dsr.active_ind=1)
    JOIN (drr
    WHERE drr.doc_set_ref_id=dsr.doc_set_ref_id
     AND drr.active_ind=1)
    JOIN (der
    WHERE der.doc_set_section_ref_id=drr.doc_set_section_ref_id
     AND der.active_ind=1
     AND der.task_assay_cd > 0)
   ORDER BY der.task_assay_cd
   HEAD REPORT
    ldcnt = 0, ldtot_cnt = 0, stat = alterlist(label_dtas->dtas,100)
   HEAD der.task_assay_cd
    ldcnt = (ldcnt+ 1), ldtot_cnt = (ldtot_cnt+ 1)
    IF (ldcnt > 100)
     stat = alterlist(label_dtas->dtas,(ldtot_cnt+ 100)), ldcnt = 1
    ENDIF
    label_dtas->dtas[ldtot_cnt].dta_code = der.task_assay_cd
   FOOT REPORT
    stat = alterlist(label_dtas->dtas,ldtot_cnt)
   WITH nocounter
  ;end select
  FOR (x = 1 TO ldtot_cnt)
    SET num = 0
    SET pos = locateval(num,1,dtot_cnt,dtas->dtas[num].dta_code,label_dtas->dtas[x].dta_code)
    IF (pos=0)
     SET dtot_cnt = (dtot_cnt+ 1)
     SET stat = alterlist(dtas->dtas,dtot_cnt)
     SET dtas->dtas[dtot_cnt].dta_code = label_dtas->dtas[x].dta_code
    ENDIF
  ENDFOR
  IF (dtot_cnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = dtot_cnt),
     data_map map
    PLAN (d)
     JOIN (map
     WHERE (map.task_assay_cd=dtas->dtas[d.seq].dta_code)
      AND map.service_resource_cd=0)
    HEAD map.task_assay_cd
     dtas->dtas[d.seq].min_decimal_places = map.min_decimal_places, dtas->dtas[d.seq].max_digits =
     map.max_digits, dtas->dtas[d.seq].min_digits = map.min_digits
    WITH nocounter
   ;end select
  ENDIF
  SELECT INTO "nl:"
   sortvar = evaluate(ar.multi_alpha_sort_order,0,ar.sequence,ar.multi_alpha_sort_order)
   FROM (dummyt d  WITH seq = dtot_cnt),
    discrete_task_assay dta,
    alpha_responses ar,
    nomenclature n,
    reference_range_factor r,
    equation e,
    code_value_extension c
   PLAN (d)
    JOIN (dta
    WHERE (dta.task_assay_cd=dtas->dtas[d.seq].dta_code))
    JOIN (e
    WHERE e.task_assay_cd=outerjoin(dta.task_assay_cd)
     AND e.active_ind=outerjoin(1))
    JOIN (r
    WHERE r.task_assay_cd=outerjoin(dta.task_assay_cd)
     AND r.active_ind=outerjoin(1))
    JOIN (ar
    WHERE ar.reference_range_factor_id=outerjoin(r.reference_range_factor_id))
    JOIN (n
    WHERE n.nomenclature_id=outerjoin(ar.nomenclature_id))
    JOIN (c
    WHERE c.code_value=outerjoin(dta.task_assay_cd)
     AND c.code_set=outerjoin(14003)
     AND cnvtupper(c.field_name)=outerjoin("DTA_WITNESS_REQUIRED_IND"))
   ORDER BY dta.mnemonic_key_cap, dta.task_assay_cd, r.reference_range_factor_id,
    ar.multi_alpha_sort_order
   HEAD REPORT
    rcnt = 0, rtot_cnt = 0, stat = alterlist(reply->rowlist,100),
    stat = alterlist(assays->rowlist,100)
   DETAIL
    rcnt = (rcnt+ 1), rtot_cnt = (rtot_cnt+ 1)
    IF (rcnt > 100)
     stat = alterlist(reply->rowlist,(rtot_cnt+ 100)), stat = alterlist(assays->rowlist,(rtot_cnt+
      100)), rcnt = 1
    ENDIF
    stat = alterlist(reply->rowlist[rtot_cnt].celllist,tot_col)
    IF (trim(c.field_value)="1")
     reply->rowlist[rtot_cnt].celllist[5].string_value = "Required"
    ELSE
     reply->rowlist[rtot_cnt].celllist[5].string_value = "Not Required"
    ENDIF
    min_dec_digits = dtas->dtas[d.seq].min_decimal_places, age_from = 0, age_to = 0
    IF (r.age_from_units_cd=years)
     age_from = (r.age_from_minutes/ minutes_per_year)
    ELSEIF (r.age_from_units_cd=months)
     age_from = (r.age_from_minutes/ minutes_per_month)
    ELSEIF (r.age_from_units_cd=weeks)
     age_from = (r.age_from_minutes/ minutes_per_week)
    ELSEIF (r.age_from_units_cd=days)
     age_from = (r.age_from_minutes/ minutes_per_day)
    ELSEIF (r.age_from_units_cd=hours)
     age_from = (r.age_from_minutes/ minutes_per_hour)
    ENDIF
    IF (r.age_to_units_cd=years)
     age_to = (r.age_to_minutes/ minutes_per_year)
    ELSEIF (r.age_to_units_cd=months)
     age_to = (r.age_to_minutes/ minutes_per_month)
    ELSEIF (r.age_to_units_cd=weeks)
     age_to = (r.age_to_minutes/ minutes_per_week)
    ELSEIF (r.age_to_units_cd=days)
     age_to = (r.age_to_minutes/ minutes_per_day)
    ELSEIF (r.age_to_units_cd=hours)
     age_to = (r.age_to_minutes/ minutes_per_hour)
    ENDIF
    IF (r.reference_range_factor_id > 0)
     reply->rowlist[rtot_cnt].celllist[12].string_value = concat(build(age_from)," ",trim(
       uar_get_code_display(r.age_from_units_cd))," - ",build(age_to),
      " ",trim(uar_get_code_display(r.age_to_units_cd)))
    ENDIF
    reply->rowlist[rtot_cnt].celllist[3].string_value = trim(n.short_string)
    IF (dta.single_select_ind=1)
     reply->rowlist[rtot_cnt].celllist[4].string_value = "Yes"
    ELSE
     reply->rowlist[rtot_cnt].celllist[4].string_value = "No"
    ENDIF
    text_nbr = format(ar.result_value,"##########.##########;I;f"), stat = convert_range_number(
     rtot_cnt), reply->rowlist[rtot_cnt].celllist[6].string_value = trim(text),
    reply->rowlist[rtot_cnt].celllist[1].string_value = dta.mnemonic
    IF (dta.default_result_type_cd > 0)
     reply->rowlist[rtot_cnt].celllist[2].string_value = uar_get_code_display(dta
      .default_result_type_cd)
    ENDIF
    reply->rowlist[rtot_cnt].celllist[20].string_value = e.equation_description
    IF (((r.critical_high > 0) OR (r.critical_low > 0)) )
     text_nbr = format(r.critical_high,"##########.##########;I;f"), stat = convert_range_number(
      rtot_cnt), reply->rowlist[rtot_cnt].celllist[16].string_value = trim(text),
     text_nbr = format(r.critical_low,"##########.##########;I;f"), stat = convert_range_number(
      rtot_cnt), reply->rowlist[rtot_cnt].celllist[15].string_value = trim(text)
    ENDIF
    IF (ar.default_ind=1)
     reply->rowlist[rtot_cnt].celllist[11].string_value = "Yes"
    ENDIF
    IF (((r.feasible_high > 0) OR (r.feasible_low > 0)) )
     text_nbr = format(r.feasible_high,"##########.##########;I;f"), stat = convert_range_number(
      rtot_cnt), reply->rowlist[rtot_cnt].celllist[18].string_value = trim(text),
     text_nbr = format(r.feasible_low,"##########.##########;I;f"), stat = convert_range_number(
      rtot_cnt), reply->rowlist[rtot_cnt].celllist[17].string_value = trim(text)
    ENDIF
    IF ((((dtas->dtas[d.seq].max_digits > 0)) OR ((((dtas->dtas[d.seq].min_digits > 0)) OR ((dtas->
    dtas[d.seq].min_decimal_places > 0))) )) )
     reply->rowlist[rtot_cnt].celllist[8].string_value = build(dtas->dtas[d.seq].max_digits), reply->
     rowlist[rtot_cnt].celllist[9].string_value = build(dtas->dtas[d.seq].min_digits), reply->
     rowlist[rtot_cnt].celllist[10].string_value = build(dtas->dtas[d.seq].min_decimal_places)
    ENDIF
    IF (((r.normal_high > 0) OR (r.normal_low > 0)) )
     text_nbr = format(r.normal_high,"##########.##########;I;f"), stat = convert_range_number(
      rtot_cnt), reply->rowlist[rtot_cnt].celllist[14].string_value = trim(text),
     text_nbr = format(r.normal_low,"##########.##########;I;f"), stat = convert_range_number(
      rtot_cnt), reply->rowlist[rtot_cnt].celllist[13].string_value = trim(text)
    ENDIF
    IF (r.sex_cd IN (female, male, unknown))
     reply->rowlist[rtot_cnt].celllist[19].string_value = uar_get_code_display(r.sex_cd)
    ELSE
     reply->rowlist[rtot_cnt].celllist[19].string_value = "All"
    ENDIF
    IF (r.units_cd > 0)
     reply->rowlist[rtot_cnt].celllist[7].string_value = uar_get_code_display(r.units_cd)
    ENDIF
    assays->rowlist[rtot_cnt].task_assay_cd = dta.task_assay_cd
   FOOT REPORT
    stat = alterlist(reply->rowlist,rtot_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->skip_volume_check_ind=0))
  IF (row_nbr > 10000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   SET stat = alterlist(reply->collist,0)
   GO TO exit_script
  ELSEIF (row_nbr > 5000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   SET stat = alterlist(reply->collist,0)
   GO TO exit_script
  ENDIF
 ENDIF
 FREE RECORD ecomp
 RECORD ecomp(
   1 comps[*]
     2 name = vc
     2 constant_value = vc
     2 assay_mnemonic = vc
 )
 DECLARE equat_desc = vc
 DECLARE equat_build = vc
 DECLARE comp_text = vc
 SET rtot_cnt = size(reply->rowlist,5)
 FOR (r = 1 TO rtot_cnt)
   IF ((reply->rowlist[r].celllist[20].string_value > " "))
    SET ecnt = 0
    SELECT INTO "nl:"
     FROM equation e,
      equation_component ec,
      discrete_task_assay dta
     PLAN (e
      WHERE (e.task_assay_cd=assays->rowlist[r].task_assay_cd)
       AND e.active_ind=1)
      JOIN (ec
      WHERE ec.equation_id=e.equation_id)
      JOIN (dta
      WHERE dta.task_assay_cd=outerjoin(ec.included_assay_cd)
       AND dta.active_ind=outerjoin(1))
     ORDER BY ec.sequence
     DETAIL
      ecnt = (ecnt+ 1), stat = alterlist(ecomp->comps,ecnt), ecomp->comps[ecnt].name = ec.name
      IF (ec.constant_value > 0)
       ecomp->comps[ecnt].constant_value = cnvtstring(ec.constant_value)
      ELSE
       ecomp->comps[ecnt].constant_value = " "
      ENDIF
      ecomp->comps[ecnt].assay_mnemonic = dta.mnemonic
     WITH nocounter
    ;end select
    IF (ecnt > 0)
     SET equat_desc = reply->rowlist[r].celllist[20].string_value
     SET equat_desc_size = size(reply->rowlist[r].celllist[20].string_value,1)
     SET equat_build = " "
     SET start_build = 1
     FOR (e = 1 TO ecnt)
      SET continue_ind = 1
      WHILE (continue_ind=1)
        SET comp_size = size(ecomp->comps[e].name,1)
        SET comp_found = findstring(ecomp->comps[e].name,equat_desc,start_build)
        IF (comp_found > 0)
         SET comp_text = " "
         IF ((ecomp->comps[e].constant_value > " "))
          SET comp_text = ecomp->comps[e].constant_value
         ELSEIF ((ecomp->comps[e].assay_mnemonic > " "))
          SET comp_text = ecomp->comps[e].assay_mnemonic
         ENDIF
         IF (e=1)
          SET equat_build = build2(substring(start_build,(comp_found - start_build),equat_desc)," ",
           trim(comp_text)," ")
         ELSE
          SET equat_build = build2(equat_build," ",substring(start_build,(comp_found - start_build),
            equat_desc)," ",trim(comp_text),
           " ")
         ENDIF
         SET start_build = (comp_found+ comp_size)
        ELSE
         SET continue_ind = 0
        ENDIF
      ENDWHILE
     ENDFOR
     IF (start_build < equat_desc_size)
      SET equat_build = build2(equat_build," ",substring(start_build,((equat_desc_size - start_build)
        + 1),equat_desc))
     ENDIF
     SET reply->rowlist[r].celllist[20].string_value = equat_build
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 SET reply->run_status_flag = 1
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("iview_assays_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL echorecord(reply)
END GO
