CREATE PROGRAM ec_get_all_dta_details:dba
 PROMPT
  "Enter output device (default is MINE): " = "MINE",
  "Enter 1 to run for ALL DTAs (default is DTAs on documentation): " = 0
  WITH outdev, alldtas
 DECLARE header_string = vc WITH noconstant(" ")
 DECLARE cell_value = vc WITH noconstant(" ")
 DECLARE row_string = vc WITH noconstant(" ")
 DECLARE write_log(swritelogfile=vc) = null
 FREE RECORD logrec
 RECORD logrec(
   1 collist[*]
     2 header_text = vc
   1 row_cnt = i4
   1 rowlist[*]
     2 celllist[*]
       3 cell_value = vc
 )
 DECLARE num = i4 WITH noconstant(0), protect
 DECLARE idx = i4 WITH noconstant(0), protect
 DECLARE all_dtas_ind = i2 WITH noconstant(cnvtint( $ALLDTAS)), protect
 FREE RECORD cv
 RECORD cv(
   1 code_cnt = i4
   1 codes[*]
     2 code_value = f8
     2 display = vc
 )
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=106
   AND cv.active_ind=1
   AND cv.cdf_meaning IN ("GLB", "RADIOLOGY", "BB", "HLX", "HLA",
  "ONLINEFORM", "AP", "MICROBIOLOGY")
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cv->code_cnt+ 1), cv->code_cnt = cnt, stat = alterlist(cv->codes,cnt),
   cv->codes[cnt].code_value = cv.code_value, cv->codes[cnt].display = cv.display
  WITH nocounter
 ;end select
 CALL echorecord(cv)
 FREE RECORD rpt
 RECORD rpt(
   1 dta_cnt = i4
   1 dtas[*]
     2 task_assay_cd = f8
     2 located_on = vc
     2 powerform_ind = i2
     2 iview_ind = i2
     2 docset_ind = i2
     2 label_ind = i2
     2 template_ind = i2
     2 mar_charting_ind = i2
     2 not_used_ind = i2
 )
 SELECT DISTINCT INTO "nl:"
  FROM dcp_forms_ref dfr,
   dcp_forms_def dfd,
   dcp_section_ref dsr,
   dcp_input_ref dir,
   name_value_prefs nvp,
   discrete_task_assay dta
  PLAN (dfr
   WHERE dfr.active_ind=1)
   JOIN (dfd
   WHERE dfd.dcp_form_instance_id=dfr.dcp_form_instance_id
    AND dfd.active_ind=1)
   JOIN (dsr
   WHERE dsr.dcp_section_ref_id=dfd.dcp_section_ref_id
    AND dsr.active_ind=1)
   JOIN (dir
   WHERE dir.dcp_section_instance_id=dsr.dcp_section_instance_id
    AND dir.active_ind=1)
   JOIN (nvp
   WHERE nvp.parent_entity_id=dir.dcp_input_ref_id
    AND nvp.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=nvp.merge_id
    AND dta.active_ind=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   IF (((all_dtas_ind=1) OR (substring(1,2,dfr.description) != "zz*")) )
    cnt = (rpt->dta_cnt+ 1), rpt->dta_cnt = cnt, stat = alterlist(rpt->dtas,cnt),
    rpt->dtas[cnt].task_assay_cd = dta.task_assay_cd, rpt->dtas[cnt].located_on = "POWERFORM", rpt->
    dtas[cnt].powerform_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
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
  HEAD REPORT
   cnt = 0
  DETAIL
   pos = locateval(num,1,rpt->dta_cnt,dta.task_assay_cd,rpt->dtas[num].task_assay_cd)
   IF (pos > 0)
    rpt->dtas[num].located_on = build2(rpt->dtas[num].located_on,", IVIEW"), rpt->dtas[num].iview_ind
     = 1
   ELSE
    cnt = (rpt->dta_cnt+ 1), rpt->dta_cnt = cnt, stat = alterlist(rpt->dtas,cnt),
    rpt->dtas[cnt].task_assay_cd = dta.task_assay_cd, rpt->dtas[cnt].located_on = "IVIEW", rpt->dtas[
    cnt].iview_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  FROM working_view wv,
   working_view_section wvs,
   working_view_item wvi,
   v500_event_set_code vesc1,
   v500_event_set_canon vcan,
   v500_event_set_code vesc2,
   v500_event_code vec,
   discrete_task_assay dta
  PLAN (wv
   WHERE wv.active_ind=1)
   JOIN (wvs
   WHERE wvs.working_view_id=wv.working_view_id)
   JOIN (wvi
   WHERE wvi.working_view_section_id=wvs.working_view_section_id)
   JOIN (vesc1
   WHERE cnvtupper(vesc1.event_set_name)=cnvtupper(wvi.primitive_event_set_name)
    AND vesc1.display_association_ind=1)
   JOIN (vcan
   WHERE vcan.parent_event_set_cd=vesc1.event_set_cd)
   JOIN (vesc2
   WHERE vesc2.event_set_cd=vcan.event_set_cd)
   JOIN (vec
   WHERE cnvtupper(vec.event_set_name)=cnvtupper(vesc2.event_set_name))
   JOIN (dta
   WHERE dta.event_cd=vec.event_cd)
  HEAD REPORT
   cnt = 0
  DETAIL
   pos = locateval(num,1,rpt->dta_cnt,dta.task_assay_cd,rpt->dtas[num].task_assay_cd)
   IF (pos > 0)
    rpt->dtas[num].located_on = build2(rpt->dtas[num].located_on,", IVIEW"), rpt->dtas[num].iview_ind
     = 1
   ELSE
    cnt = (rpt->dta_cnt+ 1), rpt->dta_cnt = cnt, stat = alterlist(rpt->dtas,cnt),
    rpt->dtas[cnt].task_assay_cd = dta.task_assay_cd, rpt->dtas[cnt].located_on = "IVIEW", rpt->dtas[
    cnt].iview_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  FROM dynamic_label_template dlt,
   doc_set_section_ref_r dsrr,
   doc_set_element_ref dser,
   discrete_task_assay dta
  PLAN (dlt
   WHERE dlt.label_template_id > 0)
   JOIN (dsrr
   WHERE dsrr.doc_set_ref_id=dlt.doc_set_ref_id
    AND dsrr.active_ind=1
    AND dsrr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (dser
   WHERE dser.doc_set_section_ref_id=dsrr.doc_set_section_ref_id
    AND dser.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=dser.task_assay_cd)
  HEAD REPORT
   cnt = 0
  DETAIL
   pos = locateval(num,1,rpt->dta_cnt,dta.task_assay_cd,rpt->dtas[num].task_assay_cd)
   IF (pos > 0)
    rpt->dtas[num].located_on = build2(rpt->dtas[num].located_on,", DYNAMICGRPLABEL"), rpt->dtas[num]
    .label_ind = 1
   ELSE
    cnt = (rpt->dta_cnt+ 1), rpt->dta_cnt = cnt, stat = alterlist(rpt->dtas,cnt),
    rpt->dtas[cnt].task_assay_cd = dta.task_assay_cd, rpt->dtas[cnt].located_on = "DYNAMICGRPLABEL",
    rpt->dtas[cnt].label_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  FROM dynamic_label_template dlt,
   discrete_task_assay dta
  PLAN (dlt
   WHERE dlt.label_template_id > 0)
   JOIN (dta
   WHERE dta.label_template_id=dlt.label_template_id)
  HEAD REPORT
   cnt = 0
  DETAIL
   pos = locateval(num,1,rpt->dta_cnt,dta.task_assay_cd,rpt->dtas[num].task_assay_cd)
   IF (pos > 0)
    rpt->dtas[num].located_on = build2(rpt->dtas[num].located_on,", DYNAMICGRPTEMP"), rpt->dtas[num].
    template_ind = 1
   ELSE
    cnt = (rpt->dta_cnt+ 1), rpt->dta_cnt = cnt, stat = alterlist(rpt->dtas,cnt),
    rpt->dtas[cnt].task_assay_cd = dta.task_assay_cd, rpt->dtas[cnt].located_on = "DYNAMICGRPTEMP",
    rpt->dtas[cnt].template_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  FROM doc_set_element_ref der,
   doc_set_section_ref_r dsrr,
   discrete_task_assay dta
  PLAN (der
   WHERE der.active_ind=1)
   JOIN (dsrr
   WHERE dsrr.doc_set_section_ref_id=der.doc_set_section_ref_id
    AND dsrr.active_ind=1
    AND dsrr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND  NOT ( EXISTS (
   (SELECT
    dlt.doc_set_ref_id
    FROM dynamic_label_template dlt
    WHERE dlt.doc_set_ref_id=dsrr.doc_set_ref_id))))
   JOIN (dta
   WHERE dta.task_assay_cd=der.task_assay_cd)
  HEAD REPORT
   cnt = 0
  DETAIL
   pos = locateval(num,1,rpt->dta_cnt,dta.task_assay_cd,rpt->dtas[num].task_assay_cd)
   IF (pos > 0)
    rpt->dtas[num].located_on = build2(rpt->dtas[num].located_on,", ACTIVITYVIEW"), rpt->dtas[num].
    docset_ind = 1
   ELSE
    cnt = (rpt->dta_cnt+ 1), rpt->dta_cnt = cnt, stat = alterlist(rpt->dtas,cnt),
    rpt->dtas[cnt].task_assay_cd = dta.task_assay_cd, rpt->dtas[cnt].located_on = "ACTIVITYVIEW", rpt
    ->dtas[cnt].docset_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 DECLARE medtasktypecd = f8 WITH constant(uar_get_code_by("MEANING",6026,"MED")), protect
 SELECT INTO "nl:"
  FROM order_task ot,
   task_discrete_r tdr,
   discrete_task_assay dta
  PLAN (ot
   WHERE ot.task_type_cd=medtasktypecd
    AND ot.active_ind=1)
   JOIN (tdr
   WHERE tdr.reference_task_id=ot.reference_task_id
    AND tdr.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=tdr.task_assay_cd
    AND dta.active_ind=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   pos = locateval(num,1,rpt->dta_cnt,dta.task_assay_cd,rpt->dtas[num].task_assay_cd)
   IF (pos > 0)
    rpt->dtas[num].located_on = build2(rpt->dtas[num].located_on,", MARCHARTINGELEMENT"), rpt->dtas[
    num].mar_charting_ind = 1
   ELSE
    cnt = (rpt->dta_cnt+ 1), rpt->dta_cnt = cnt, stat = alterlist(rpt->dtas,cnt),
    rpt->dtas[cnt].task_assay_cd = dta.task_assay_cd, rpt->dtas[cnt].located_on =
    "MARCHARTINGELEMENT", rpt->dtas[cnt].mar_charting_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pathway_catalog pc,
   pathway_comp pco,
   discrete_task_assay dta
  PLAN (pc
   WHERE pc.active_ind=1)
   JOIN (pco
   WHERE pco.pathway_catalog_id=pc.pathway_catalog_id)
   JOIN (dta
   WHERE dta.task_assay_cd=pco.task_assay_cd
    AND dta.active_ind=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   pos = locateval(num,1,rpt->dta_cnt,dta.task_assay_cd,rpt->dtas[num].task_assay_cd)
   IF (pos > 0)
    rpt->dtas[num].located_on = build2(rpt->dtas[num].located_on,", POWERPLAN")
   ELSE
    cnt = (rpt->dta_cnt+ 1), rpt->dta_cnt = cnt, stat = alterlist(rpt->dtas,cnt),
    rpt->dtas[cnt].task_assay_cd = dta.task_assay_cd, rpt->dtas[cnt].located_on = "POWERPLAN"
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM discrete_task_assay dta
  PLAN (dta
   WHERE dta.active_ind=1
    AND dta.io_flag > 0)
  HEAD REPORT
   cnt = 0
  DETAIL
   pos = locateval(num,1,rpt->dta_cnt,dta.task_assay_cd,rpt->dtas[num].task_assay_cd)
   IF (pos > 0)
    rpt->dtas[num].located_on = build2(rpt->dtas[num].located_on,", IO2G")
   ELSE
    cnt = (rpt->dta_cnt+ 1), rpt->dta_cnt = cnt, stat = alterlist(rpt->dtas,cnt),
    rpt->dtas[cnt].task_assay_cd = dta.task_assay_cd, rpt->dtas[cnt].located_on = "IO2G"
   ENDIF
  WITH nocounter
 ;end select
 IF (all_dtas_ind=1)
  SELECT INTO "nl:"
   FROM discrete_task_assay dta
   PLAN (dta
    WHERE  NOT (expand(idx,1,cv->code_cnt,dta.activity_type_cd,cv->codes[idx].code_value))
     AND dta.active_ind=1)
   HEAD REPORT
    cnt = 0
   DETAIL
    pos = locateval(num,1,rpt->dta_cnt,dta.task_assay_cd,rpt->dtas[num].task_assay_cd)
    IF (pos=0)
     cnt = (rpt->dta_cnt+ 1), rpt->dta_cnt = cnt, stat = alterlist(rpt->dtas,cnt),
     rpt->dtas[cnt].task_assay_cd = dta.task_assay_cd, rpt->dtas[cnt].located_on = "", rpt->dtas[cnt]
     .not_used_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 FREE RECORD erec
 RECORD erec(
   1 equation_comp_cnt = i4
   1 equation_comps[*]
     2 name = vc
     2 value = vc
 )
 SET stat = alterlist(logrec->collist,27)
 SET logrec->collist[1].header_text = "Located On"
 SET logrec->collist[2].header_text = "DTA Mnemonic"
 SET logrec->collist[3].header_text = "Alpha Responses"
 SET logrec->collist[4].header_text = "DTA Result Type"
 SET logrec->collist[5].header_text = "First Alpha Single Select"
 SET logrec->collist[6].header_text = "Alpha Details Result"
 SET logrec->collist[7].header_text = "Unit of Measure"
 SET logrec->collist[8].header_text = "DTA Numeric Max"
 SET logrec->collist[9].header_text = "DTA Numeric Min"
 SET logrec->collist[10].header_text = "DTA Numeric Decimal"
 SET logrec->collist[11].header_text = "Age Range"
 SET logrec->collist[12].header_text = "Sex"
 SET logrec->collist[13].header_text = "Reference Low"
 SET logrec->collist[14].header_text = "Reference High"
 SET logrec->collist[15].header_text = "Feasible Low"
 SET logrec->collist[16].header_text = "Feasible High"
 SET logrec->collist[17].header_text = "Critical Low"
 SET logrec->collist[18].header_text = "Critical High"
 SET logrec->collist[19].header_text = "Calculation"
 SET logrec->collist[20].header_text = "Reference Text"
 SET logrec->collist[21].header_text = "Include in Intake or Output"
 SET logrec->collist[22].header_text = "Nurse Witness Required"
 SET logrec->collist[23].header_text = "Activity Type"
 SET logrec->collist[24].header_text = "Event Code"
 SET logrec->collist[25].header_text = "Event Code Display"
 SET logrec->collist[26].header_text = "Last Updated By"
 SET logrec->collist[27].header_text = "Last Updated On"
 DECLARE minutes_cd = f8 WITH constant(uar_get_code_by("MEANING",340,"MINUTES"))
 DECLARE hours_cd = f8 WITH constant(uar_get_code_by("MEANING",340,"HOURS"))
 DECLARE days_cd = f8 WITH constant(uar_get_code_by("MEANING",340,"DAYS"))
 DECLARE weeks_cd = f8 WITH constant(uar_get_code_by("MEANING",340,"WEEKS"))
 DECLARE months_cd = f8 WITH constant(uar_get_code_by("MEANING",340,"MONTHS"))
 DECLARE years_cd = f8 WITH constant(uar_get_code_by("MEANING",340,"YEARS"))
 DECLARE equation = vc
 DECLARE numericcd = f8 WITH constant(uar_get_code_by("MEANING",289,"3"))
 DECLARE icursize = i4 WITH noconstant(0)
 DECLARE iloopcnt = i4 WITH noconstant(0)
 DECLARE inewsize = i4 WITH noconstant(0)
 DECLARE istart = i4 WITH noconstant(1)
 DECLARE iexpidx = i4 WITH noconstant(0)
 DECLARE ibatchsize = i4 WITH constant(50)
 DECLARE iforcnt = i4 WITH noconstant(0)
 SET icursize = rpt->dta_cnt
 SET iloopcnt = ceil((cnvtreal(icursize)/ ibatchsize))
 SET inewsize = (iloopcnt * ibatchsize)
 SET stat = alterlist(rpt->dtas,inewsize)
 FOR (iforcnt = (icursize+ 1) TO inewsize)
   SET rpt->dtas[iforcnt].task_assay_cd = rpt->dtas[icursize].task_assay_cd
 ENDFOR
 SELECT INTO "nl:"
  sortvar = evaluate(ar.multi_alpha_sort_order,0,ar.sequence,ar.multi_alpha_sort_order)
  FROM (dummyt d  WITH seq = value(iloopcnt)),
   discrete_task_assay dta,
   v500_event_code vec,
   reference_range_factor rrf,
   alpha_responses ar,
   nomenclature n,
   data_map dm,
   equation e,
   equation_component ec,
   code_value_extension cve,
   ref_text_reltn rtr,
   prsnl pl
  PLAN (d
   WHERE initarray(istart,evaluate(d.seq,1,1,(istart+ ibatchsize))))
   JOIN (dta
   WHERE expand(iexpidx,istart,(istart+ (ibatchsize - 1)),dta.task_assay_cd,rpt->dtas[iexpidx].
    task_assay_cd)
    AND dta.active_ind=1
    AND dta.activity_type_cd > 0)
   JOIN (vec
   WHERE vec.event_cd=outerjoin(dta.event_cd))
   JOIN (rrf
   WHERE rrf.task_assay_cd=outerjoin(dta.task_assay_cd)
    AND rrf.active_ind=outerjoin(1))
   JOIN (ar
   WHERE ar.reference_range_factor_id=outerjoin(rrf.reference_range_factor_id)
    AND ar.nomenclature_id > outerjoin(0))
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(ar.nomenclature_id)
    AND n.active_ind=outerjoin(1))
   JOIN (dm
   WHERE dm.task_assay_cd=outerjoin(dta.task_assay_cd))
   JOIN (e
   WHERE e.task_assay_cd=outerjoin(dta.task_assay_cd))
   JOIN (ec
   WHERE ec.equation_id=outerjoin(e.equation_id))
   JOIN (cve
   WHERE cve.code_value=outerjoin(dta.task_assay_cd)
    AND cve.field_name=outerjoin("dta_witness_required_ind")
    AND cve.field_value=outerjoin("1"))
   JOIN (rtr
   WHERE rtr.parent_entity_name=outerjoin("DISCRETE_TASK_ASSAY")
    AND rtr.parent_entity_id=outerjoin(dta.task_assay_cd)
    AND rtr.active_ind=outerjoin(1))
   JOIN (pl
   WHERE pl.person_id=outerjoin(dta.updt_id))
  ORDER BY dta.mnemonic, rrf.reference_range_factor_id, ec.sequence,
   sortvar
  HEAD REPORT
   cnt = 0
  HEAD dta.mnemonic
   cnt = (logrec->row_cnt+ 1), logrec->row_cnt = cnt, stat = alterlist(logrec->rowlist,cnt),
   stat = alterlist(logrec->rowlist[cnt].celllist,27), stat = alterlist(erec->equation_comps,0), pos
    = locateval(num,1,icursize,dta.task_assay_cd,rpt->dtas[num].task_assay_cd),
   logrec->rowlist[cnt].celllist[1].cell_value = substring(1,100,rpt->dtas[pos].located_on), logrec->
   rowlist[cnt].celllist[2].cell_value = dta.mnemonic, logrec->rowlist[cnt].celllist[4].cell_value =
   uar_get_code_display(dta.default_result_type_cd),
   logrec->rowlist[cnt].celllist[5].cell_value = evaluate(dta.single_select_ind,1,"Yes",""), logrec->
   rowlist[cnt].celllist[8].cell_value = evaluate(dta.default_result_type_cd,numericcd,cnvtstring(dm
     .max_digits),""), logrec->rowlist[cnt].celllist[9].cell_value = evaluate(dta
    .default_result_type_cd,numericcd,cnvtstring(dm.min_digits),""),
   logrec->rowlist[cnt].celllist[10].cell_value = evaluate(dta.default_result_type_cd,numericcd,
    cnvtstring(dm.min_decimal_places),""), logrec->rowlist[cnt].celllist[20].cell_value = evaluate(
    rtr.ref_text_reltn_id,0.0,"","Yes"), logrec->rowlist[cnt].celllist[21].cell_value = evaluate(dta
    .io_flag,0,"",- (1),"",
    1,"Intake",2,"Output"),
   logrec->rowlist[cnt].celllist[22].cell_value = evaluate(cve.field_value,"1","Yes",""), logrec->
   rowlist[cnt].celllist[23].cell_value = uar_get_code_display(dta.activity_type_cd), logrec->
   rowlist[cnt].celllist[24].cell_value = cnvtstring(vec.event_cd),
   logrec->rowlist[cnt].celllist[25].cell_value = vec.event_cd_disp, logrec->rowlist[cnt].celllist[26
   ].cell_value = pl.name_full_formatted, logrec->rowlist[cnt].celllist[27].cell_value = format(dta
    .updt_dt_tm,"@SHORTDATE"),
   equation = e.equation_description, rfound = 0
  HEAD rrf.reference_range_factor_id
   IF (rfound > 0)
    cnt = (logrec->row_cnt+ 1), logrec->row_cnt = cnt, stat = alterlist(logrec->rowlist,cnt),
    stat = alterlist(logrec->rowlist[cnt].celllist,27)
   ENDIF
   logrec->rowlist[cnt].celllist[7].cell_value = uar_get_code_display(rrf.units_cd)
   IF (rrf.age_from_units_cd=days_cd)
    age_from = cnvtstring(((rrf.age_from_minutes/ 60)/ 24))
   ELSEIF (rrf.age_from_units_cd=hours_cd)
    age_from = cnvtstring((rrf.age_from_minutes/ 60))
   ELSEIF (rrf.age_from_units_cd=minutes_cd)
    age_from = cnvtstring(rrf.age_from_minutes)
   ELSEIF (rrf.age_from_units_cd=months_cd)
    age_from = cnvtstring((((rrf.age_from_minutes/ 60)/ 24)/ 31))
   ELSEIF (rrf.age_from_units_cd=weeks_cd)
    age_from = cnvtstring((((rrf.age_from_minutes/ 60)/ 24)/ 7))
   ELSEIF (rrf.age_from_units_cd=years_cd)
    age_from = cnvtstring((((rrf.age_from_minutes/ 60)/ 24)/ 365))
   ENDIF
   IF (rrf.age_to_units_cd=days_cd)
    age_to = cnvtstring(((rrf.age_to_minutes/ 60)/ 24))
   ELSEIF (rrf.age_to_units_cd=hours_cd)
    age_to = cnvtstring((rrf.age_to_minutes/ 60))
   ELSEIF (rrf.age_to_units_cd=minutes_cd)
    age_to = cnvtstring(rrf.age_to_minutes)
   ELSEIF (rrf.age_to_units_cd=months_cd)
    age_to = cnvtstring((((rrf.age_to_minutes/ 60)/ 24)/ 31))
   ELSEIF (rrf.age_to_units_cd=weeks_cd)
    age_to = cnvtstring((((rrf.age_to_minutes/ 60)/ 24)/ 7))
   ELSEIF (rrf.age_to_units_cd=years_cd)
    age_to = cnvtstring((((rrf.age_to_minutes/ 60)/ 24)/ 365))
   ENDIF
   from_units = uar_get_code_display(rrf.age_from_units_cd), to_units = uar_get_code_display(rrf
    .age_to_units_cd), logrec->rowlist[cnt].celllist[11].cell_value = build2(trim(age_from)," ",trim(
     from_units,3)," - ",trim(age_to),
    " ",trim(to_units,3)),
   logrec->rowlist[cnt].celllist[12].cell_value = uar_get_code_display(rrf.sex_cd), logrec->rowlist[
   cnt].celllist[13].cell_value = evaluate(rrf.normal_low,0.0,"",cnvtstring(rrf.normal_low)), logrec
   ->rowlist[cnt].celllist[14].cell_value = evaluate(rrf.normal_high,0.0,"",cnvtstring(rrf
     .normal_high)),
   logrec->rowlist[cnt].celllist[15].cell_value = evaluate(rrf.feasible_low,0.0,"",cnvtstring(rrf
     .feasible_low)), logrec->rowlist[cnt].celllist[16].cell_value = evaluate(rrf.feasible_high,0.0,
    "",cnvtstring(rrf.feasible_high)), logrec->rowlist[cnt].celllist[17].cell_value = evaluate(rrf
    .critical_low,0.0,"",cnvtstring(rrf.critical_low)),
   logrec->rowlist[cnt].celllist[18].cell_value = evaluate(rrf.critical_high,0.0,"",cnvtstring(rrf
     .critical_high)), rfound = 1, afound = 0
  HEAD ec.sequence
   ecnt = (erec->equation_comp_cnt+ 1), erec->equation_comp_cnt = ecnt, stat = alterlist(erec->
    equation_comps,ecnt),
   erec->equation_comps[ecnt].name = ec.name, erec->equation_comps[ecnt].value = uar_get_code_display
   (ec.included_assay_cd)
  HEAD sortvar
   IF (afound > 0)
    cnt = (logrec->row_cnt+ 1), logrec->row_cnt = cnt, stat = alterlist(logrec->rowlist,cnt),
    stat = alterlist(logrec->rowlist[cnt].celllist,27)
   ENDIF
   IF (n.short_string > " ")
    logrec->rowlist[cnt].celllist[3].cell_value = n.short_string, logrec->rowlist[cnt].celllist[6].
    cell_value = evaluate(ar.result_value,0.0,"",trim(cnvtstring(ar.result_value,10,2))), afound = 1
   ENDIF
  FOOT  dta.mnemonic
   FOR (e = 1 TO erec->equation_comp_cnt)
     equation = replace(equation,erec->equation_comps[e].name,erec->equation_comps[e].value,2)
   ENDFOR
   logrec->rowlist[cnt].celllist[19].cell_value = equation
  WITH nocounter
 ;end select
 SET stat = alterlist(rpt->dtas,icursize)
 CALL write_log( $OUTDEV)
 SUBROUTINE write_log(swritelogfile)
   FOR (x = 1 TO size(logrec->collist,5))
     IF (x=1)
      SET header_string = build('"',logrec->collist[x].header_text,'"')
     ELSE
      SET header_string = build(header_string,',"',logrec->collist[x].header_text,'"')
     ENDIF
   ENDFOR
   SELECT INTO value(swritelogfile)
    FROM dummyt d
    PLAN (d)
    DETAIL
     col 0, header_string, row + 1
     FOR (x = 1 TO size(logrec->rowlist,5))
       FOR (y = 1 TO size(logrec->rowlist[x].celllist,5))
         cell_value = " "
         IF ((logrec->rowlist[x].celllist[y].cell_value > " "))
          cell_value = logrec->rowlist[x].celllist[y].cell_value
         ENDIF
         IF (y=1)
          row_string = build('"',cell_value,'"')
         ELSE
          row_string = build(row_string,',"',cell_value,'"')
         ENDIF
       ENDFOR
       col 0, row_string, row + 1
     ENDFOR
    WITH nocounter, pcformat('"',",",1), format = stream,
     maxcol = 10000, formfeed = none
   ;end select
   SET stat = alterlist(logrec->collist,0)
   SET stat = alterlist(logrec->rowlist,0)
 END ;Subroutine
END GO
