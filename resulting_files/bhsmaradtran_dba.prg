CREATE PROGRAM bhsmaradtran:dba
 CALL echo("*****START OF ACCESSION SUBROUTINE *****")
 DECLARE formataccession(c2) = c11
 SUBROUTINE formataccession(acc_string)
   SET return_string = fillstring(25," ")
   SET return_string = uar_fmt_accession(acc_string,size(acc_string,1))
   RETURN(return_string)
 END ;Subroutine
 SET req_ndx = value( $1)
 SET sect_ndx = value( $2)
 SET print_sub = value( $3)
 DECLARE mn_pt_in_ed = i4 WITH noconstant(0)
 DECLARE ms_pt_rm_ed = vc WITH noconstant(" ")
 DECLARE ms_pt_bd_ed = vc WITH noconstant(" ")
 DECLARE mf_esa = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"ESA")), protect
 DECLARE mf_esb = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"ESB")), protect
 DECLARE mf_esc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"ESC")), protect
 DECLARE mf_esd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"ESD")), protect
 DECLARE mf_ese = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"ESE")), protect
 DECLARE mf_esp = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"ESP")), protect
 DECLARE mf_esw = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"ESW")), protect
 DECLARE mf_esx = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"ESX")), protect
 DECLARE mf_eshld = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"ESHLD")), protect
 EXECUTE reportrtl
 CALL echo("*******************Begin Order Details sets***************")
 DECLARE o2 = c8 WITH public, noconstant("PTOXYGEN")
 DECLARE iv = c7 WITH public, noconstant("PTHASIV")
 DECLARE preg = c8 WITH public, noconstant("PREGNANT")
 DECLARE lnmp = c4 WITH public, noconstant("LNMP")
 DECLARE isolation = c WITH public, noconstant("ISOLATIONCODE")
 DECLARE comment1 = vc WITH public, noconstant("COMMENTTYPE1")
 DECLARE comment2 = vc WITH public, noconstant("COMMENTTYPE2")
 DECLARE commenttext1 = vc WITH public, noconstant("COMMENTTEXT1")
 DECLARE commenttext2 = vc WITH public, noconstant("COMMENTTEXT2")
 DECLARE detail1 = vc WITH public, noconstant("DETAIL1")
 DECLARE detail2 = vc WITH public, noconstant("DETAIL2")
 DECLARE detail3 = vc WITH public, noconstant("DETAIL3")
 DECLARE detail4 = vc WITH public, noconstant("DETAIL4")
 DECLARE detail5 = vc WITH public, noconstant("DETAIL5")
 DECLARE detail6 = i4 WITH public, noconstant(0)
 DECLARE detail7 = i4 WITH public, noconstant(0)
 DECLARE detail8 = i4 WITH public, noconstant(0)
 DECLARE detail9 = i4 WITH public, noconstant(0)
 DECLARE detail10 = i4 WITH public, noconstant(0)
 CALL echo("*******************End Order Details sets***************")
 CALL echo("****************START OF ALLERGY SELECT********************")
 DECLARE active_allergy_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",12025,"ACTIVE"))
 SELECT INTO "nl:"
  d1.seq, hd_packet = request->qual[d1.seq].packet_id
  FROM (dummyt d1  WITH seq = value(size(data->req,5))),
   allergy alrgy,
   nomenclature nm
  PLAN (d1)
   JOIN (alrgy
   WHERE (alrgy.person_id=data->req[d1.seq].patient_data.person_id)
    AND alrgy.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND alrgy.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND alrgy.active_ind=1
    AND alrgy.reaction_status_cd=active_allergy_cd)
   JOIN (nm
   WHERE nm.nomenclature_id=alrgy.substance_nom_id)
  HEAD hd_packet
   xcounter = 0
  DETAIL
   xcounter = (xcounter+ 1), stat = alterlist(data->req[d1.seq].patient_data.allergy,xcounter), data
   ->req[d1.seq].patient_data.allergy[xcounter].substance_ftdesc = alrgy.substance_ftdesc,
   data->req[d1.seq].patient_data.allergy[xcounter].onset_dt_tm = cnvtdatetime(alrgy.onset_dt_tm),
   data->req[d1.seq].patient_data.allergy[xcounter].source_string = nm.source_string
   IF (alrgy.substance_ftdesc != " ")
    data->req[d1.seq].patient_data.allergy[xcounter].flexed_desc = alrgy.substance_ftdesc
   ELSE
    data->req[d1.seq].patient_data.allergy[xcounter].flexed_desc = nm.source_string
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("****************START OF CDM CODES********************")
 DECLARE bill_code_var = f8 WITH public, noconstant(uar_get_code_by("MEANING",13019,"BILL CODE"))
 CALL echo("Beginning of CDM code list")
 DECLARE total_remaining = i4
 DECLARE start_index = i4
 DECLARE occurances = i4
 DECLARE temp_cpt4_list[1] = f8
 SET start_index = 1
 SET occurances = 1
 CALL uar_get_code_list_by_meaning(14002,"CDM_SCHED",start_index,occurances,total_remaining,
  temp_cpt4_list)
 DECLARE total_cdm_codes = i4 WITH public, noconstant((occurances+ total_remaining))
 DECLARE code_list[value(total_cdm_codes)] = f8
 SET occurances = total_cdm_codes
 CALL uar_get_code_list_by_meaning(14002,"CDM_SCHED",start_index,occurances,total_remaining,
  code_list)
 CALL echo("Begin CDM Bill Item Select")
 SELECT INTO "nl:"
  bi.bill_item_id
  FROM (dummyt d1  WITH seq = value(size(data->req,5))),
   (dummyt d2  WITH seq = value(max_sect_cnt)),
   (dummyt d3  WITH seq = value(max_page_cnt)),
   (dummyt d4  WITH seq = value(max_exam_cnt)),
   bill_item bi,
   (dummyt d  WITH seq = total_cdm_codes),
   bill_item_modifier bim
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(data->req[d1.seq].sections,5))
   JOIN (d3
   WHERE d3.seq <= size(data->req[d1.seq].sections[d2.seq].exam_data,5))
   JOIN (d4
   WHERE d4.seq <= size(data->req[d1.seq].sections[d2.seq].exam_data[d3.seq].for_this_page,5))
   JOIN (bi
   WHERE (bi.ext_parent_reference_id=data->req[d1.seq].sections[d2.seq].exam_data[d3.seq].
   for_this_page[d4.seq].catalog_cd)
    AND bi.active_ind=1
    AND bi.parent_qual_cd=0
    AND bi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND bi.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (d)
   JOIN (bim
   WHERE bim.bill_item_id=bi.bill_item_id
    AND ((bim.bill_item_type_cd+ 0)=bill_code_var)
    AND (bim.key1_id=code_list[d.seq])
    AND bim.active_ind=1
    AND bim.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND bim.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  HEAD REPORT
   cdm_ndx = 0
  DETAIL
   cdm_ndx = (cdm_ndx+ 1), stat = alterlist(data->req[d1.seq].sections[d2.seq].exam_data[d3.seq].
    for_this_page[d4.seq].cdm_codes,cdm_ndx), data->req[d1.seq].sections[d2.seq].exam_data[d3.seq].
   for_this_page[d4.seq].cdm_codes[cdm_ndx].cdm_code = bim.key6,
   data->req[d1.seq].sections[d2.seq].exam_data[d3.seq].for_this_page[d4.seq].cdm_codes[cdm_ndx].
   cdm_desc = bim.key7
  WITH nocounter
 ;end select
 CALL echo("****************START OF CPT4 SELECT********************")
 DECLARE contrib_ord_cat_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",13016,"ORD CAT"))
 CALL echo(build("contrib:",contrib_ord_cat_cd))
 DECLARE contrib_task_assay = f8 WITH public, noconstant(uar_get_code_by("MEANING",13016,"TASK ASSAY"
   ))
 CALL echo(build("contrib task:",contrib_task_assay))
 CALL echo("Beginning of cpt4 code list")
 DECLARE temp_cdm_list[1] = f8
 DECLARE total_remaining_cpt = i4
 DECLARE start_index_cpt = i4
 DECLARE occurances_cpt = i4
 DECLARE meaning_cpt = c12
 SET start_index_cpt = 1
 SET occurances_cpt = 1
 CALL uar_get_code_list_by_meaning(14002,"CPT4",start_index_cpt,occurances_cpt,total_remaining_cpt,
  temp_cdm_list)
 DECLARE total_cpt4_codes = i4 WITH public, noconstant((occurances_cpt+ total_remaining_cpt))
 DECLARE cpt_code_list[value(total_cpt4_codes)] = f8
 SET occurances_cpt = total_cpt4_codes
 CALL uar_get_code_list_by_meaning(14002,"CPT4",start_index_cpt,occurances_cpt,total_remaining_cpt,
  cpt_code_list)
 CALL echo("Begin CPT4 Bill Item Select")
 CALL echo(build("catalog:",data->req[1].sections[1].exam_data[1].for_this_page[1].catalog_cd))
 SELECT INTO "nl:"
  bi.bill_item_id
  FROM (dummyt d1  WITH seq = value(size(data->req,5))),
   (dummyt d2  WITH seq = value(max_sect_cnt)),
   (dummyt d3  WITH seq = value(max_page_cnt)),
   (dummyt d4  WITH seq = value(max_exam_cnt)),
   bill_item bi,
   (dummyt d  WITH seq = total_cpt4_codes),
   bill_item_modifier bim
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(data->req[d1.seq].sections,5))
   JOIN (d3
   WHERE d3.seq <= size(data->req[d1.seq].sections[d2.seq].exam_data,5))
   JOIN (d4
   WHERE d4.seq <= size(data->req[d1.seq].sections[d2.seq].exam_data[d3.seq].for_this_page,5))
   JOIN (bi
   WHERE (bi.ext_parent_reference_id=data->req[d1.seq].sections[d2.seq].exam_data[d3.seq].
   for_this_page[d4.seq].catalog_cd)
    AND bi.ext_parent_contributor_cd=contrib_ord_cat_cd
    AND bi.active_ind=1
    AND bi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND bi.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (d)
   JOIN (bim
   WHERE bim.bill_item_id=bi.bill_item_id
    AND (bim.key1_id=cpt_code_list[d.seq])
    AND bim.active_ind=1
    AND bim.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND bim.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY d1.seq, d2.seq, d3.seq,
   d4.seq, bi.ext_parent_reference_id
  HEAD bi.ext_parent_reference_id
   cpt_ndx = 0
  DETAIL
   cpt_ndx = (cpt_ndx+ 1), stat = alterlist(data->req[d1.seq].sections[d2.seq].exam_data[d3.seq].
    for_this_page[d4.seq].cpt_codes,cpt_ndx), data->req[d1.seq].sections[d2.seq].exam_data[d3.seq].
   for_this_page[d4.seq].cpt_codes[cpt_ndx].cpt4_code = bim.key6,
   CALL echo(data->req[d1.seq].sections[d2.seq].exam_data[d3.seq].for_this_page[d4.seq].cpt_codes[
   cpt_ndx].cpt4_code), data->req[d1.seq].sections[d2.seq].exam_data[d3.seq].for_this_page[d4.seq].
   cpt_codes[cpt_ndx].cpt4_desc = bim.key7,
   CALL echo(data->req[d1.seq].sections[d2.seq].exam_data[d3.seq].for_this_page[d4.seq].cpt_codes[
   cpt_ndx].cpt4_desc)
  WITH nocounter
 ;end select
 DECLARE source_voc_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",400,"ICD9"))
 FREE RECORD icd9
 RECORD icd9(
   1 exam[*]
     2 code[*]
       3 desc = vc
       3 value = vc
 )
 SELECT INTO "nl:"
  nm.source_string, nm.nomenclature_id, od.oe_field_display_value,
  od.oe_field_value, od.order_id
  FROM (dummyt d1  WITH seq = value(max_page_cnt)),
   (dummyt d2  WITH seq = value(max_exam_cnt)),
   order_detail od,
   nomenclature nm
  PLAN (d1
   WHERE d1.seq <= size(data->req[req_ndx].sections[sect_ndx].exam_data,5))
   JOIN (d2
   WHERE d2.seq <= size(data->req[req_ndx].sections[sect_ndx].exam_data[d1.seq].for_this_page,5))
   JOIN (od
   WHERE (od.order_id=data->req[req_ndx].sections[sect_ndx].exam_data[d1.seq].for_this_page[d2.seq].
   order_id)
    AND od.oe_field_meaning="ICD9")
   JOIN (nm
   WHERE nm.nomenclature_id=outerjoin(od.oe_field_value)
    AND nm.primary_vterm_ind=outerjoin(1)
    AND nm.source_vocabulary_cd=outerjoin(source_voc_cd)
    AND nm.active_ind=outerjoin(1))
  ORDER BY od.order_id, od.action_sequence DESC
  HEAD REPORT
   count = 0, max_action_seq = 0
  HEAD od.order_id
   count = (count+ 1), max_action_seq = od.action_sequence
   IF (mod(count,50)=1)
    stat = alterlist(icd9->exam,(count+ 49))
   ENDIF
   tmb_idx = 0
  DETAIL
   IF (od.action_sequence=max_action_seq)
    tmb_idx = (tmb_idx+ 1)
    IF (mod(tmb_idx,10)=1)
     stat = alterlist(icd9->exam[count].code,(tmb_idx+ 9))
    ENDIF
    icd9->exam[count].code[tmb_idx].value = nm.source_identifier, icd9->exam[count].code[tmb_idx].
    desc = nm.source_string
   ENDIF
   CALL echo("made it after detail in icd9"),
   CALL echo(build("icd9 code: ",icd9->exam[count].code[tmb_idx].value)),
   CALL echo(build("icd9 desc: ",icd9->exam[count].code[tmb_idx].desc))
  FOOT  od.order_id
   stat = alterlist(icd9->exam[count].code,tmb_idx)
  FOOT REPORT
   stat = alterlist(icd9->exam,count)
  WITH nocounter
 ;end select
 CALL echo("*****START OF LAST EXAMS*****")
 DECLARE getallfac(null) = null
 DECLARE getonefac(null) = null
 DECLARE getlibgrp(null) = null
 DECLARE getactsubtype(null) = null
 DECLARE count = i4
 DECLARE stat = i4
 DECLARE p = i4
 DECLARE r = i4
 DECLARE y = i4
 FREE RECORD rad_all
 RECORD rad_all(
   1 last_exam[*]
     2 exam_name = vc
     2 request_date_time = dq8
     2 complete_date_time = dq8
     2 transcribe_date_time = dq8
     2 final_date_time = dq8
     2 accession = c20
     2 facility_display = vc
     2 facility_description = vc
     2 completing_location_display = vc
     2 completing_location_description = vc
     2 image_class_type_display = vc
     2 image_class_type_description = vc
     2 exam_status = vc
 )
 FREE RECORD fac
 RECORD fac(
   1 last_exam[*]
     2 exam_name = vc
     2 request_date_time = dq8
     2 complete_date_time = dq8
     2 transcribe_date_time = dq8
     2 final_date_time = dq8
     2 accession = c20
     2 facility_display = vc
     2 facility_description = vc
     2 completing_location_display = vc
     2 completing_location_description = vc
     2 image_class_type_display = vc
     2 image_class_type_description = vc
     2 exam_status = vc
 )
 FREE RECORD lib
 RECORD lib(
   1 last_exam[*]
     2 exam_name = vc
     2 request_date_time = dq8
     2 complete_date_time = dq8
     2 transcribe_date_time = dq8
     2 final_date_time = dq8
     2 accession = c20
     2 facility_display = vc
     2 facility_description = vc
     2 completing_location_display = vc
     2 completing_location_description = vc
     2 image_class_type_display = vc
     2 image_class_type_description = vc
     2 exam_status = vc
 )
 FREE RECORD act
 RECORD act(
   1 last_exam[*]
     2 exam_name = vc
     2 request_date_time = dq8
     2 complete_date_time = dq8
     2 transcribe_date_time = dq8
     2 final_date_time = dq8
     2 accession = c20
     2 facility_display = vc
     2 facility_description = vc
     2 completing_location_display = vc
     2 completing_location_description = vc
     2 image_class_type_display = vc
     2 image_class_type_description = vc
     2 exam_status = vc
 )
 CALL getallfac(null)
 CALL getonefac(null)
 CALL getlibgrp(null)
 CALL getactsubtype(null)
 SUBROUTINE getlibgrp(null)
   SET count = 0
   FOR (p = 1 TO size(data->req[req_ndx].sections[sect_ndx].exam_data,5))
     FOR (r = 1 TO size(data->req[req_ndx].sections[sect_ndx].exam_data[p].for_this_page,5))
       FOR (y = 1 TO size(data->req[req_ndx].last_exams,5))
         IF ((data->req[req_ndx].last_exams[y].library_group_cd=data->req[req_ndx].sections[sect_ndx]
         .exam_data[p].for_this_page[r].lib_grp_cd))
          SET count = (count+ 1)
          IF (mod(count,10)=1)
           SET stat = alterlist(lib->last_exam,(count+ 10))
          ENDIF
          SET lib->last_exam[count].complete_date_time = data->req[req_ndx].last_exams[y].comp_dt_tm
          SET lib->last_exam[count].exam_name = data->req[req_ndx].last_exams[y].catalog_mnemonic
          SET lib->last_exam[count].image_class_type_display = data->req[req_ndx].last_exams[y].
          image_class_type_disp
          SET lib->last_exam[count].image_class_type_description = data->req[req_ndx].last_exams[y].
          image_class_type_desc
          SET lib->last_exam[count].completing_location_description = data->req[req_ndx].last_exams[y
          ].complete_locn_desc
          SET lib->last_exam[count].completing_location_display = data->req[req_ndx].last_exams[y].
          complete_locn_disp
          SET lib->last_exam[count].facility_display = data->req[req_ndx].last_exams[y].facility_disp
          SET lib->last_exam[count].facility_description = data->req[req_ndx].last_exams[y].
          facility_desc
          SET lib->last_exam[count].accession = data->req[req_ndx].last_exams[y].accession
          SET lib->last_exam[count].transcribe_date_time = data->req[req_ndx].last_exams[y].
          transcribe_dt_tm
          SET lib->last_exam[count].final_date_time = data->req[req_ndx].last_exams[y].final_dt_tm
          SET lib->last_exam[count].request_date_time = data->req[req_ndx].last_exams[y].
          request_dt_tm
          SET lib->last_exam[count].exam_status = data->req[req_ndx].last_exams[y].exam_status_disp
         ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
   SET stat = alterlist(lib->last_exam,count)
 END ;Subroutine
 SUBROUTINE getallfac(null)
   SET count = 0
   FOR (y = 1 TO size(data->req[req_ndx].last_exams,5))
     SET count = (count+ 1)
     IF (mod(count,10)=1)
      SET stat = alterlist(rad_all->last_exam,(count+ 10))
     ENDIF
     SET rad_all->last_exam[y].complete_date_time = data->req[req_ndx].last_exams[y].comp_dt_tm
     SET rad_all->last_exam[y].exam_name = data->req[req_ndx].last_exams[y].catalog_mnemonic
     SET rad_all->last_exam[y].image_class_type_display = data->req[req_ndx].last_exams[y].
     image_class_type_disp
     SET rad_all->last_exam[y].image_class_type_description = data->req[req_ndx].last_exams[y].
     image_class_type_desc
     SET rad_all->last_exam[y].completing_location_description = data->req[req_ndx].last_exams[y].
     complete_locn_desc
     SET rad_all->last_exam[y].completing_location_display = data->req[req_ndx].last_exams[y].
     complete_locn_disp
     SET rad_all->last_exam[y].facility_display = data->req[req_ndx].last_exams[y].facility_disp
     SET rad_all->last_exam[y].facility_description = data->req[req_ndx].last_exams[y].facility_desc
     SET rad_all->last_exam[y].accession = data->req[req_ndx].last_exams[y].accession
     SET rad_all->last_exam[y].transcribe_date_time = data->req[req_ndx].last_exams[y].
     transcribe_dt_tm
     SET rad_all->last_exam[y].final_date_time = data->req[req_ndx].last_exams[y].final_dt_tm
     SET rad_all->last_exam[y].request_date_time = data->req[req_ndx].last_exams[y].request_dt_tm
     SET rad_all->last_exam[y].exam_status = data->req[req_ndx].last_exams[y].exam_status_disp
   ENDFOR
   SET stat = alterlist(rad_all->last_exam,count)
 END ;Subroutine
 SUBROUTINE getonefac(null)
   SET count = 0
   FOR (y = 1 TO size(data->req[req_ndx].last_exams,5))
     IF ((data->req[req_ndx].last_exams[y].facility_cd=data->req[req_ndx].patient_data.facility_cd))
      SET count = (count+ 1)
      IF (mod(count,10)=1)
       SET stat = alterlist(fac->last_exam,(count+ 10))
      ENDIF
      SET fac->last_exam[count].complete_date_time = data->req[req_ndx].last_exams[y].comp_dt_tm
      SET fac->last_exam[count].exam_name = data->req[req_ndx].last_exams[y].catalog_mnemonic
      SET fac->last_exam[count].image_class_type_display = data->req[req_ndx].last_exams[y].
      image_class_type_disp
      SET fac->last_exam[count].image_class_type_description = data->req[req_ndx].last_exams[y].
      image_class_type_desc
      SET fac->last_exam[count].completing_location_description = data->req[req_ndx].last_exams[y].
      complete_locn_desc
      SET fac->last_exam[count].completing_location_display = data->req[req_ndx].last_exams[y].
      complete_locn_disp
      SET fac->last_exam[count].facility_display = data->req[req_ndx].last_exams[y].facility_disp
      SET fac->last_exam[count].facility_description = data->req[req_ndx].last_exams[y].facility_desc
      SET fac->last_exam[count].accession = data->req[req_ndx].last_exams[y].accession
      SET fac->last_exam[count].transcribe_date_time = data->req[req_ndx].last_exams[y].
      transcribe_dt_tm
      SET fac->last_exam[count].final_date_time = data->req[req_ndx].last_exams[y].final_dt_tm
      SET fac->last_exam[count].request_date_time = data->req[req_ndx].last_exams[y].request_dt_tm
      SET fac->last_exam[count].exam_status = data->req[req_ndx].last_exams[y].exam_status_disp
     ENDIF
   ENDFOR
   SET stat = alterlist(fac->last_exam,count)
 END ;Subroutine
 SUBROUTINE getactsubtype(null)
   SET count = 0
   FOR (p = 1 TO size(data->req[req_ndx].sections[sect_ndx].exam_data,5))
     FOR (r = 1 TO size(data->req[req_ndx].sections[sect_ndx].exam_data[p].for_this_page,5))
       FOR (y = 1 TO size(data->req[req_ndx].last_exams,5))
         IF ((data->req[req_ndx].last_exams[y].activity_subtype_cd=data->req[req_ndx].sections[
         sect_ndx].exam_data[p].for_this_page[r].activity_subtype_cd))
          SET count = (count+ 1)
          IF (mod(count,10)=1)
           SET stat = alterlist(act->last_exam,(count+ 10))
          ENDIF
          SET act->last_exam[count].complete_date_time = data->req[req_ndx].last_exams[y].comp_dt_tm
          SET act->last_exam[count].exam_name = data->req[req_ndx].last_exams[y].catalog_mnemonic
          SET act->last_exam[count].image_class_type_display = data->req[req_ndx].last_exams[y].
          image_class_type_disp
          SET act->last_exam[count].image_class_type_description = data->req[req_ndx].last_exams[y].
          image_class_type_desc
          SET act->last_exam[count].completing_location_description = data->req[req_ndx].last_exams[y
          ].complete_locn_desc
          SET act->last_exam[count].completing_location_display = data->req[req_ndx].last_exams[y].
          complete_locn_disp
          SET act->last_exam[count].facility_display = data->req[req_ndx].last_exams[y].facility_disp
          SET act->last_exam[count].facility_description = data->req[req_ndx].last_exams[y].
          facility_desc
          SET act->last_exam[count].accession = data->req[req_ndx].last_exams[y].accession
          SET act->last_exam[count].transcribe_date_time = data->req[req_ndx].last_exams[y].
          transcribe_dt_tm
          SET act->last_exam[count].final_date_time = data->req[req_ndx].last_exams[y].final_dt_tm
          SET act->last_exam[count].request_date_time = data->req[req_ndx].last_exams[y].
          request_dt_tm
          SET act->last_exam[count].exam_status = data->req[req_ndx].last_exams[y].exam_status_disp
         ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
   SET stat = alterlist(act->last_exam,count)
 END ;Subroutine
 CALL echo("*****START OF MODIFY SELECT*****")
 DECLARE modify_flag = i4 WITH public, noconstant(0)
 DECLARE modify_type_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",6003,"MODIFY"))
 SELECT INTO "nl: "
  oa.action_type_cd
  FROM order_action oa
  WHERE (oa.order_id=data->req[req_ndx].sections[sect_ndx].exam_data[1].for_this_page[1].order_id)
  ORDER BY oa.action_sequence DESC
  DETAIL
   IF (oa.action_type_cd=modify_type_cd)
    modify_flag = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("****************START OF ADDRESS RECORD********************")
 FREE RECORD a_facility
 RECORD a_facility(
   1 facility_name = vc
   1 inst_name = vc
   1 sect_disp = vc
   1 dept_name = vc
   1 dept_desc = vc
   1 address = vc
   1 city = vc
   1 state = vc
   1 zip = vc
 )
 CALL echo("****************START OF ALLERGY RECORD********************")
 FREE RECORD a_allergy
 RECORD a_allergy(
   1 allergy_1 = vc
   1 allergy_2 = vc
   1 allergy_3 = vc
   1 allergy_4 = vc
   1 allergy_5 = vc
   1 allergy_6 = vc
   1 allergy_7 = vc
   1 allergy_8 = vc
   1 allergy_9 = vc
   1 allergy_10 = vc
   1 allergy_11 = vc
   1 allergy_12 = vc
 )
 CALL echo("****************START OF CDM RECORD********************")
 FREE RECORD a_cdm
 RECORD a_cdm(
   1 code1_1 = vc
   1 code1_2 = vc
   1 code1_3 = vc
   1 code1_4 = vc
   1 desc1_1 = vc
   1 desc1_2 = vc
   1 desc1_3 = vc
   1 desc1_4 = vc
   1 code2_1 = vc
   1 code2_2 = vc
   1 code2_3 = vc
   1 code2_4 = vc
   1 desc2_1 = vc
   1 desc2_2 = vc
   1 desc2_3 = vc
   1 desc2_4 = vc
   1 code3_1 = vc
   1 code3_2 = vc
   1 code3_3 = vc
   1 code3_4 = vc
   1 desc3_1 = vc
   1 desc3_2 = vc
   1 desc3_3 = vc
   1 desc3_4 = vc
   1 code4_1 = vc
   1 code4_2 = vc
   1 code4_3 = vc
   1 code4_4 = vc
   1 desc4_1 = vc
   1 desc4_2 = vc
   1 desc4_3 = vc
   1 desc4_4 = vc
   1 code5_1 = vc
   1 code5_2 = vc
   1 code5_3 = vc
   1 code5_4 = vc
   1 desc5_1 = vc
   1 desc5_2 = vc
   1 desc5_3 = vc
   1 desc5_4 = vc
   1 code6_1 = vc
   1 code6_2 = vc
   1 code6_3 = vc
   1 code6_4 = vc
   1 desc6_1 = vc
   1 desc6_2 = vc
   1 desc6_3 = vc
   1 desc6_4 = vc
   1 code7_1 = vc
   1 code7_2 = vc
   1 code7_3 = vc
   1 code7_4 = vc
   1 desc7_1 = vc
   1 desc7_2 = vc
   1 desc7_3 = vc
   1 desc7_4 = vc
   1 code8_1 = vc
   1 code8_2 = vc
   1 code8_3 = vc
   1 code8_4 = vc
   1 desc8_1 = vc
   1 desc8_2 = vc
   1 desc8_3 = vc
   1 desc8_4 = vc
   1 code9_1 = vc
   1 code9_2 = vc
   1 code9_3 = vc
   1 code9_4 = vc
   1 desc9_1 = vc
   1 desc9_2 = vc
   1 desc9_3 = vc
   1 desc9_4 = vc
   1 code10_1 = vc
   1 code10_2 = vc
   1 code10_3 = vc
   1 code10_4 = vc
   1 desc10_1 = vc
   1 desc10_2 = vc
   1 desc10_3 = vc
   1 desc10_4 = vc
 )
 CALL echo("****************START OF CPT4 RECORD********************")
 FREE RECORD a_cpt4
 RECORD a_cpt4(
   1 code1_1 = vc
   1 code1_2 = vc
   1 code1_3 = vc
   1 code1_4 = vc
   1 desc1_1 = vc
   1 desc1_2 = vc
   1 desc1_3 = vc
   1 desc1_4 = vc
   1 code2_1 = vc
   1 code2_2 = vc
   1 code2_3 = vc
   1 code2_4 = vc
   1 desc2_1 = vc
   1 desc2_2 = vc
   1 desc2_3 = vc
   1 desc2_4 = vc
   1 code3_1 = vc
   1 code3_2 = vc
   1 code3_3 = vc
   1 code3_4 = vc
   1 desc3_1 = vc
   1 desc3_2 = vc
   1 desc3_3 = vc
   1 desc3_4 = vc
   1 code4_1 = vc
   1 code4_2 = vc
   1 code4_3 = vc
   1 code4_4 = vc
   1 desc4_1 = vc
   1 desc4_2 = vc
   1 desc4_3 = vc
   1 desc4_4 = vc
   1 code5_1 = vc
   1 code5_2 = vc
   1 code5_3 = vc
   1 code5_4 = vc
   1 desc5_1 = vc
   1 desc5_2 = vc
   1 desc5_3 = vc
   1 desc5_4 = vc
   1 code6_1 = vc
   1 code6_2 = vc
   1 code6_3 = vc
   1 code6_4 = vc
   1 desc6_1 = vc
   1 desc6_2 = vc
   1 desc6_3 = vc
   1 desc6_4 = vc
   1 code7_1 = vc
   1 code7_2 = vc
   1 code7_3 = vc
   1 code7_4 = vc
   1 desc7_1 = vc
   1 desc7_2 = vc
   1 desc7_3 = vc
   1 desc7_4 = vc
   1 code8_1 = vc
   1 code8_2 = vc
   1 code8_3 = vc
   1 code8_4 = vc
   1 desc8_1 = vc
   1 desc8_2 = vc
   1 desc8_3 = vc
   1 desc8_4 = vc
   1 code9_1 = vc
   1 code9_2 = vc
   1 code9_3 = vc
   1 code9_4 = vc
   1 desc9_1 = vc
   1 desc9_2 = vc
   1 desc9_3 = vc
   1 desc9_4 = vc
   1 code10_1 = vc
   1 code10_2 = vc
   1 code10_3 = vc
   1 code10_4 = vc
   1 desc10_1 = vc
   1 desc10_2 = vc
   1 desc10_3 = vc
   1 desc10_4 = vc
 )
 CALL echo("****************START OF DETAIL RECORD********************")
 FREE RECORD a_detail
 RECORD a_detail(
   1 iv = c15
   1 o2 = c15
   1 preg = c15
   1 iso = c20
   1 lmp = c15
   1 comment_type1 = vc
   1 comment_type2 = vc
   1 comment_text1 = vc
   1 comment_text2 = vc
   1 detail1 = vc
   1 detail2 = vc
   1 detail3 = vc
   1 detail4 = vc
   1 detail5 = vc
   1 detail6 = vc
   1 detail7 = vc
   1 detail8 = vc
   1 detail9 = vc
   1 detail10 = vc
 )
 CALL echo("****************START OF EXAM RECORD********************")
 FREE RECORD a_exam
 RECORD a_exam(
   1 accession = c20
   1 bc_acc_nbr = c22
   1 exam_name_1 = vc
   1 order_date_1 = dq8
   1 order_time_1 = dq8
   1 rqst_date_1 = dq8
   1 rqst_time_1 = dq8
   1 start_date_1 = dq8
   1 start_time_1 = dq8
   1 exam_section_1 = vc
   1 reason_for_exam_1 = vc
   1 special_instr_1 = vc
   1 comments_1 = vc
   1 priority_1 = vc
   1 transport_mode_1 = vc
   1 order_by_id_1 = c20
   1 order_by_name_1 = vc
   1 order_by_user_name_1 = vc
   1 exam_room_1 = vc
   1 order_location_1 = vc
   1 order_loc_phone_1 = vc
   1 exam_name_2 = vc
   1 order_date_2 = dq8
   1 order_time_2 = dq8
   1 rqst_date_2 = dq8
   1 rqst_time_2 = dq8
   1 start_date_2 = dq8
   1 start_time_2 = dq8
   1 exam_section_2 = vc
   1 reason_for_exam_2 = vc
   1 special_instr_2 = vc
   1 priority_2 = vc
   1 transport_mode_2 = vc
   1 order_by_id_2 = c20
   1 order_by_name_2 = vc
   1 order_by_user_name_2 = vc
   1 exam_room_2 = vc
   1 order_location_2 = vc
   1 order_loc_phone_2 = vc
   1 exam_name_3 = vc
   1 order_date_3 = dq8
   1 order_time_3 = dq8
   1 rqst_date_3 = dq8
   1 rqst_time_3 = dq8
   1 start_date_3 = dq8
   1 start_time_3 = dq8
   1 exam_section_3 = vc
   1 reason_for_exam_3 = vc
   1 special_instr_3 = vc
   1 priority_3 = vc
   1 transport_mode_3 = vc
   1 order_by_id_3 = c20
   1 order_by_name_3 = vc
   1 order_by_user_name_3 = vc
   1 exam_room_3 = vc
   1 order_location_3 = vc
   1 order_loc_phone_3 = vc
   1 exam_name_4 = vc
   1 order_date_4 = dq8
   1 order_time_4 = dq8
   1 rqst_date_4 = dq8
   1 rqst_time_4 = dq8
   1 start_date_4 = dq8
   1 start_time_4 = dq8
   1 reason_for_exam_4 = vc
   1 special_instr_4 = vc
   1 exam_section_4 = vc
   1 priority_4 = vc
   1 transport_mode_4 = vc
   1 order_by_id_4 = c20
   1 order_by_name_4 = vc
   1 order_by_user_name_4 = vc
   1 exam_room_4 = vc
   1 order_location_4 = vc
   1 order_loc_phone_4 = vc
   1 exam_name_5 = vc
   1 order_date_5 = dq8
   1 order_time_5 = dq8
   1 rqst_date_5 = dq8
   1 rqst_time_5 = dq8
   1 start_date_5 = dq8
   1 start_time_5 = dq8
   1 exam_section_5 = vc
   1 reason_for_exam_5 = vc
   1 special_instr_5 = vc
   1 priority_5 = vc
   1 transport_mode_5 = vc
   1 order_by_id_5 = c20
   1 order_by_name_5 = vc
   1 order_by_user_name_5 = vc
   1 exam_room_5 = vc
   1 order_location_5 = vc
   1 order_loc_phone_5 = vc
   1 exam_name_6 = vc
   1 order_date_6 = dq8
   1 order_time_6 = dq8
   1 rqst_date_6 = dq8
   1 rqst_time_6 = dq8
   1 start_date_6 = dq8
   1 start_time_6 = dq8
   1 exam_section_6 = vc
   1 reason_for_exam_6 = vc
   1 special_instr_6 = vc
   1 priority_6 = vc
   1 transport_mode_6 = vc
   1 order_by_id_6 = c20
   1 order_by_name_6 = vc
   1 order_by_user_name_6 = vc
   1 exam_room_6 = vc
   1 order_location_6 = vc
   1 order_loc_phone_6 = vc
   1 exam_name_7 = vc
   1 order_date_7 = dq8
   1 order_time_7 = dq8
   1 rqst_date_7 = dq8
   1 rqst_time_7 = dq8
   1 start_date_7 = dq8
   1 start_time_7 = dq8
   1 exam_section_7 = vc
   1 reason_for_exam_7 = vc
   1 special_instr_7 = vc
   1 priority_7 = vc
   1 transport_mode_7 = vc
   1 order_by_id_7 = c20
   1 order_by_name_7 = vc
   1 order_by_user_name_7 = vc
   1 exam_room_7 = vc
   1 order_location_7 = vc
   1 order_loc_phone_7 = vc
   1 exam_name_8 = vc
   1 order_date_8 = dq8
   1 order_time_8 = dq8
   1 rqst_date_8 = dq8
   1 rqst_time_8 = dq8
   1 start_date_8 = dq8
   1 start_time_8 = dq8
   1 exam_section_8 = vc
   1 reason_for_exam_8 = vc
   1 special_instr_8 = vc
   1 priority_8 = vc
   1 transport_mode_8 = vc
   1 order_by_id_8 = c20
   1 order_by_name_8 = vc
   1 order_by_user_name_8 = vc
   1 exam_room_8 = vc
   1 order_location_8 = vc
   1 order_loc_phone_8 = vc
   1 exam_name_9 = vc
   1 order_date_9 = dq8
   1 order_time_9 = dq8
   1 rqst_date_9 = dq8
   1 rqst_time_9 = dq8
   1 start_date_9 = dq8
   1 start_time_9 = dq8
   1 exam_section_9 = vc
   1 reason_for_exam_9 = vc
   1 special_instr_9 = vc
   1 priority_9 = vc
   1 transport_mode_9 = vc
   1 order_by_id_9 = c20
   1 order_by_name_9 = vc
   1 order_by_user_name_9 = vc
   1 exam_room_9 = vc
   1 order_location_9 = vc
   1 order_loc_phone_9 = vc
   1 exam_name_10 = vc
   1 order_date_10 = dq8
   1 order_time_10 = dq8
   1 rqst_date_10 = dq8
   1 rqst_time_10 = dq8
   1 start_date_10 = dq8
   1 start_time_10 = dq8
   1 exam_section_10 = vc
   1 reason_for_exam_10 = vc
   1 special_instr_10 = vc
   1 priority_10 = vc
   1 transport_mode_10 = vc
   1 order_by_id_10 = c20
   1 order_by_name_10 = vc
   1 order_by_user_name_10 = vc
   1 exam_room_10 = vc
   1 order_location_10 = vc
   1 order_loc_phone_10 = vc
 )
 CALL echo("*****START OF ICD9 CODES RECORD*****")
 FREE RECORD a_icd9
 RECORD a_icd9(
   1 icd9_1_1 = vc
   1 icd9_1_2 = vc
   1 icd9_1_3 = vc
   1 icd9_1_4 = vc
   1 icd9_1_desc_1 = vc
   1 icd9_1_desc_2 = vc
   1 icd9_1_desc_3 = vc
   1 icd9_1_desc_4 = vc
   1 icd9_2_1 = vc
   1 icd9_2_2 = vc
   1 icd9_2_3 = vc
   1 icd9_2_4 = vc
   1 icd9_2_desc_1 = vc
   1 icd9_2_desc_2 = vc
   1 icd9_2_desc_3 = vc
   1 icd9_2_desc_4 = vc
   1 icd9_3_1 = vc
   1 icd9_3_2 = vc
   1 icd9_3_3 = vc
   1 icd9_3_4 = vc
   1 icd9_3_desc_1 = vc
   1 icd9_3_desc_2 = vc
   1 icd9_3_desc_3 = vc
   1 icd9_3_desc_4 = vc
   1 icd9_4_1 = vc
   1 icd9_4_2 = vc
   1 icd9_4_3 = vc
   1 icd9_4_4 = vc
   1 icd9_4_desc_1 = vc
   1 icd9_4_desc_2 = vc
   1 icd9_4_desc_3 = vc
   1 icd9_4_desc_4 = vc
   1 icd9_5_1 = vc
   1 icd9_5_2 = vc
   1 icd9_5_3 = vc
   1 icd9_5_4 = vc
   1 icd9_5_desc_1 = vc
   1 icd9_5_desc_2 = vc
   1 icd9_5_desc_3 = vc
   1 icd9_5_desc_4 = vc
   1 icd9_6_1 = vc
   1 icd9_6_2 = vc
   1 icd9_6_3 = vc
   1 icd9_6_4 = vc
   1 icd9_6_desc_1 = vc
   1 icd9_6_desc_2 = vc
   1 icd9_6_desc_3 = vc
   1 icd9_6_desc_4 = vc
   1 icd9_7_1 = vc
   1 icd9_7_2 = vc
   1 icd9_7_3 = vc
   1 icd9_7_4 = vc
   1 icd9_7_desc_1 = vc
   1 icd9_7_desc_2 = vc
   1 icd9_7_desc_3 = vc
   1 icd9_7_desc_4 = vc
   1 icd9_8_1 = vc
   1 icd9_8_2 = vc
   1 icd9_8_3 = vc
   1 icd9_8_4 = vc
   1 icd9_8_desc_1 = vc
   1 icd9_8_desc_2 = vc
   1 icd9_8_desc_3 = vc
   1 icd9_8_desc_4 = vc
   1 icd9_9_1 = vc
   1 icd9_9_2 = vc
   1 icd9_9_3 = vc
   1 icd9_9_4 = vc
   1 icd9_9_desc_1 = vc
   1 icd9_9_desc_2 = vc
   1 icd9_9_desc_3 = vc
   1 icd9_9_desc_4 = vc
   1 icd9_10_1 = vc
   1 icd9_10_2 = vc
   1 icd9_10_3 = vc
   1 icd9_10_4 = vc
   1 icd9_10_desc_1 = vc
   1 icd9_10_desc_2 = vc
   1 icd9_10_desc_3 = vc
   1 icd9_10_desc_4 = vc
 )
 CALL echo("*****START OF LAST EXAMS RECORD*****")
 FREE RECORD a_previous_exam_all_1
 RECORD a_previous_exam_all_1(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_all_2
 RECORD a_previous_exam_all_2(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_all_3
 RECORD a_previous_exam_all_3(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_all_4
 RECORD a_previous_exam_all_4(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_all_5
 RECORD a_previous_exam_all_5(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_all_6
 RECORD a_previous_exam_all_6(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_all_7
 RECORD a_previous_exam_all_7(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_all_8
 RECORD a_previous_exam_all_8(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_all_9
 RECORD a_previous_exam_all_9(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_all_10
 RECORD a_previous_exam_all_10(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_fac_1
 RECORD a_previous_exam_fac_1(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_fac_2
 RECORD a_previous_exam_fac_2(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_fac_3
 RECORD a_previous_exam_fac_3(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_fac_4
 RECORD a_previous_exam_fac_4(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_fac_5
 RECORD a_previous_exam_fac_5(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_fac_6
 RECORD a_previous_exam_fac_6(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_fac_7
 RECORD a_previous_exam_fac_7(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_fac_8
 RECORD a_previous_exam_fac_8(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_fac_9
 RECORD a_previous_exam_fac_9(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_fac_10
 RECORD a_previous_exam_fac_10(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_lib_1
 RECORD a_previous_exam_lib_1(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_lib_2
 RECORD a_previous_exam_lib_2(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_lib_3
 RECORD a_previous_exam_lib_3(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_lib_4
 RECORD a_previous_exam_lib_4(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_lib_5
 RECORD a_previous_exam_lib_5(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_lib_6
 RECORD a_previous_exam_lib_6(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_lib_7
 RECORD a_previous_exam_lib_7(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_lib_8
 RECORD a_previous_exam_lib_8(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_lib_9
 RECORD a_previous_exam_lib_9(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_lib_10
 RECORD a_previous_exam_lib_10(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_act_1
 RECORD a_previous_exam_act_1(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_act_2
 RECORD a_previous_exam_act_2(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_act_3
 RECORD a_previous_exam_act_3(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_act_4
 RECORD a_previous_exam_act_4(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_act_5
 RECORD a_previous_exam_act_5(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_act_6
 RECORD a_previous_exam_act_6(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_act_7
 RECORD a_previous_exam_act_7(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_act_8
 RECORD a_previous_exam_act_8(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_act_9
 RECORD a_previous_exam_act_9(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 FREE RECORD a_previous_exam_act_10
 RECORD a_previous_exam_act_10(
   1 exam_name = vc
   1 request_date_time = dq8
   1 complete_date_time = dq8
   1 transcribe_date_time = dq8
   1 final_date_time = dq8
   1 accession = vc
   1 facility_display = vc
   1 facility_description = vc
   1 completing_location_display = vc
   1 completing_location_description = vc
   1 image_class_type_display = vc
   1 image_class_type_description = vc
   1 exam_status = vc
 )
 CALL echo("*****START OF MODIFY/REPRINT RECORD*****")
 FREE RECORD a_mod
 RECORD a_mod(
   1 status = c8
   1 reprint = c7
 )
 CALL echo("*****START OF OTHER EXAMS RECORD*****")
 FREE RECORD a_other_exam_1
 RECORD a_other_exam_1(
   1 other_name_1 = vc
   1 other_accession_1 = c20
   1 other_facility_1 = vc
 )
 FREE RECORD a_other_exam_2
 RECORD a_other_exam_2(
   1 other_name_2 = vc
   1 other_accession_2 = c20
   1 other_facility_2 = vc
 )
 FREE RECORD a_other_exam_3
 RECORD a_other_exam_3(
   1 other_name_3 = vc
   1 other_accession_3 = c20
   1 other_facility_3 = vc
 )
 FREE RECORD a_other_exam_4
 RECORD a_other_exam_4(
   1 other_name_4 = vc
   1 other_accession_4 = c20
   1 other_facility_4 = vc
 )
 FREE RECORD a_other_exam_5
 RECORD a_other_exam_5(
   1 other_name_5 = vc
   1 other_accession_5 = c20
   1 other_facility_5 = vc
 )
 FREE RECORD a_other_exam_6
 RECORD a_other_exam_6(
   1 other_name_6 = vc
   1 other_accession_6 = c20
   1 other_facility_6 = vc
 )
 FREE RECORD a_other_exam_7
 RECORD a_other_exam_7(
   1 other_name_7 = vc
   1 other_accession_7 = c20
   1 other_facility_7 = vc
 )
 FREE RECORD a_other_exam_8
 RECORD a_other_exam_8(
   1 other_name_8 = vc
   1 other_accession_8 = c20
   1 other_facility_8 = vc
 )
 FREE RECORD a_other_exam_9
 RECORD a_other_exam_9(
   1 other_name_9 = vc
   1 other_accession_9 = c20
   1 other_facility_9 = vc
 )
 FREE RECORD a_other_exam_10
 RECORD a_other_exam_10(
   1 other_name_10 = vc
   1 other_accession_10 = c20
   1 other_facility_10 = vc
 )
 CALL echo("*****START OF PACS ID RECORD*****")
 FREE RECORD a_pacs
 RECORD a_pacs(
   1 pacs_id_1 = c20
   1 bc_pacs_id_1 = vc
   1 pacs_id_2 = c20
   1 bc_pacs_id_2 = vc
   1 pacs_id_3 = c20
   1 bc_pacs_id_3 = vc
   1 pacs_id_4 = c20
   1 bc_pacs_id_4 = vc
   1 pacs_id_5 = c20
   1 bc_pacs_id_5 = vc
   1 pacs_id_6 = c20
   1 bc_pacs_id_6 = vc
   1 pacs_id_7 = c20
   1 bc_pacs_id_7 = vc
   1 pacs_id_8 = c20
   1 bc_pacs_id_8 = vc
   1 pacs_id_9 = c20
   1 bc_pacs_id_9 = vc
   1 pacs_id_10 = c20
   1 bc_pacs_id_10 = vc
 )
 CALL echo("*****START OF PATIENT RECORD*****")
 FREE RECORD a_pat_data
 RECORD a_pat_data(
   1 person_id = f8
   1 full_name = vc
   1 last_name = vc
   1 first_name = vc
   1 mid_name = vc
   1 dob = dq8
   1 age = vc
   1 short_age = c10
   1 gender = vc
   1 short_gender = c10
   1 race = vc
   1 encounter_id = f8
   1 location = vc
   1 pat_type = vc
   1 arrival_date = dq8
   1 facility = vc
   1 building = vc
   1 nurse_unit = vc
   1 nurse_unit_phone = vc
   1 room = c10
   1 bed = c10
   1 admitting_diag = vc
   1 isolation = vc
   1 med_service = vc
   1 fin_class = vc
   1 client = vc
   1 ssn = vc
   1 cmrn = vc
   1 med_nbr = vc
   1 bc_med_nbr = vc
   1 fin_nbr = vc
   1 bc_fin_nbr = vc
   1 home_phone = vc
   1 work_phone = vc
   1 address = vc
   1 city = vc
   1 state = vc
   1 zip = c12
 )
 CALL echo("*****START OF PHYSICIAN RECORD*****")
 FREE RECORD a_doc
 RECORD a_doc(
   1 admit_doc_name = vc
   1 admit_doc_phone = vc
   1 admit_doc_pager = vc
   1 admit_doc_fax = vc
   1 refer_doc_name = vc
   1 refer_doc_phone = vc
   1 refer_doc_pager = vc
   1 refer_doc_fax = vc
   1 order_doc_name = vc
   1 order_doc_phone = vc
   1 order_doc_pager = vc
   1 order_doc_fax = vc
   1 attend_doc_name = vc
   1 attend_doc_phone = vc
   1 attend_doc_pager = vc
   1 attend_doc_fax = vc
   1 family_doc_name = vc
   1 family_doc_phone = vc
   1 family_doc_pager = vc
   1 family_doc_fax = vc
   1 consult_doc_name_1 = vc
   1 consult_doc_phone_1 = vc
   1 consult_doc_pager_1 = vc
   1 consult_doc_fax_1 = vc
   1 consult_doc_name_2 = vc
   1 consult_doc_phone_2 = vc
   1 consult_doc_pager_2 = vc
   1 consult_doc_fax_2 = vc
   1 consult_doc_name_3 = vc
   1 consult_doc_phone_3 = vc
   1 consult_doc_pager_3 = vc
   1 consult_doc_fax_3 = vc
   1 consult_doc_name_4 = vc
   1 consult_doc_phone_4 = vc
   1 consult_doc_pager_4 = vc
   1 consult_doc_fax_4 = vc
   1 consult_doc_name_5 = vc
   1 consult_doc_phone_5 = vc
   1 consult_doc_pager_5 = vc
   1 consult_doc_fax_5 = vc
   1 consult_doc_name_6 = vc
   1 consult_doc_phone_6 = vc
   1 consult_doc_pager_6 = vc
   1 consult_doc_fax_6 = vc
 )
 CALL echo("*****START OF SITE SPECIFIC RECORD*****")
 FREE RECORD a_site
 RECORD a_site(
   1 more_allergy = vc
 )
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE layoutsection0(ncalc=i2) = f8 WITH protect
 DECLARE layoutsection0abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE layoutsection1(ncalc=i2) = f8 WITH protect
 DECLARE layoutsection1abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yshift = f8 WITH noconstant(0.0), protect
 DECLARE _xshift = f8 WITH noconstant(0.0), protect
 DECLARE _sendto = vc WITH noconstant(""), protect
 DECLARE _rpterr = i2 WITH noconstant(0), protect
 DECLARE _rptstat = i2 WITH noconstant(0), protect
 DECLARE _oldfont = i4 WITH noconstant(0), protect
 DECLARE _oldpen = i4 WITH noconstant(0), protect
 DECLARE _dummyfont = i4 WITH noconstant(0), protect
 DECLARE _dummypen = i4 WITH noconstant(0), protect
 DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
 DECLARE _rptpage = i4 WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _times140 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times16b0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE finalizereport(ssendreport)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptstat = uar_rptendreport(_hreport)
   DECLARE sfilename = vc WITH noconstant(trim(ssendreport)), private
   DECLARE bprint = i2 WITH noconstant(0), private
   IF (textlen(sfilename) > 0)
    SET bprint = checkqueue(sfilename)
    IF (bprint)
     EXECUTE cpm_create_file_name "RPT", "PS"
     SET sfilename = cpm_cfn_info->file_name_path
    ENDIF
   ENDIF
   SET _rptstat = uar_rptprinttofile(_hreport,nullterm(sfilename))
   IF (bprint)
    SET spool value(sfilename) value(ssendreport) WITH deleted
   ENDIF
   DECLARE _errorfound = i2 WITH noconstant(0), protect
   DECLARE _errcnt = i2 WITH noconstant(0), protect
   SET _errorfound = uar_rptfirsterror(_hreport,rpterror)
   WHILE (_errorfound=rpt_errorfound
    AND _errcnt < 512)
     SET _errcnt = (_errcnt+ 1)
     SET stat = alterlist(rpterrors->errors,_errcnt)
     SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
     SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
     SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
     SET _errorfound = uar_rptnexterror(_hreport,rpterror)
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE layoutsection0(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = layoutsection0abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE layoutsection0abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(10.000000), private
   DECLARE __a_facility_inst_name = vc WITH noconstant(build2(a_facility->inst_name,char(0))),
   protect
   DECLARE __a_facility_sect_disp = vc WITH noconstant(build2(a_facility->sect_disp,char(0))),
   protect
   DECLARE __a_exam_rqst_date_1 = vc WITH noconstant(build2(format(a_exam->rqst_date_1,
      "@SHORTDATETIME"),char(0))), protect
   DECLARE __a_pat_data_full_name = vc WITH noconstant(build2(a_pat_data->full_name,char(0))),
   protect
   DECLARE __a_pat_data_dob = vc WITH noconstant(build2(format(a_pat_data->dob,"@SHORTDATETIME"),char
     (0))), protect
   DECLARE __a_pat_data_gender = vc WITH noconstant(build2(a_pat_data->gender,char(0))), protect
   DECLARE __a_pat_data_med_nbr = vc WITH noconstant(build2(a_pat_data->med_nbr,char(0))), protect
   DECLARE __a_pat_data_nurse_unit = vc WITH noconstant(build2(a_pat_data->nurse_unit,char(0))),
   protect
   DECLARE __a_pat_data_room = vc WITH noconstant(build2(
     IF (mn_pt_in_ed=1) ms_pt_rm_ed
     ELSE a_pat_data->room
     ENDIF
     ,char(0))), protect
   DECLARE __a_pat_data_bed = vc WITH noconstant(build2(
     IF (mn_pt_in_ed=1) ms_pt_bd_ed
     ELSE a_pat_data->bed
     ENDIF
     ,char(0))), protect
   DECLARE __a_exam_exam_name_1 = vc WITH noconstant(build2(a_exam->exam_name_1,char(0))), protect
   DECLARE __a_exam_priority_1 = vc WITH noconstant(build2(a_exam->priority_1,char(0))), protect
   DECLARE __a_doc_order_doc_name = vc WITH noconstant(build2(a_doc->order_doc_name,char(0))),
   protect
   DECLARE __a_exam_rqst_date_4 = vc WITH noconstant(build2(format(a_exam->rqst_date_1,
      "@SHORTDATETIME"),char(0))), protect
   DECLARE __a_pat_data_med_nbr5 = vc WITH noconstant(build2(a_pat_data->med_nbr,char(0))), protect
   DECLARE __a_pat_data_full_name6 = vc WITH noconstant(build2(a_pat_data->full_name,char(0))),
   protect
   DECLARE __a_pat_data_age = vc WITH noconstant(build2(a_pat_data->age,char(0))), protect
   DECLARE __a_pat_data_nurse_unit7 = vc WITH noconstant(build2(a_pat_data->nurse_unit,char(0))),
   protect
   DECLARE __a_pat_data_room8 = vc WITH noconstant(build2(
     IF (mn_pt_in_ed=1) ms_pt_rm_ed
     ELSE a_pat_data->room
     ENDIF
     ,char(0))), protect
   DECLARE __a_pat_data_bed9 = vc WITH noconstant(build2(
     IF (mn_pt_in_ed=1) ms_pt_bd_ed
     ELSE a_pat_data->bed
     ENDIF
     ,char(0))), protect
   DECLARE __a_exam_exam_name_10 = vc WITH noconstant(build2(a_exam->exam_name_1,char(0))), protect
   DECLARE __a_pat_data_full_name14 = vc WITH noconstant(build2(a_pat_data->full_name,char(0))),
   protect
   DECLARE __a_pat_data_nurse_unit15 = vc WITH noconstant(build2(a_pat_data->nurse_unit,char(0))),
   protect
   DECLARE __a_pat_data_room16 = vc WITH noconstant(build2(
     IF (mn_pt_in_ed=1) ms_pt_rm_ed
     ELSE a_pat_data->room
     ENDIF
     ,char(0))), protect
   DECLARE __a_pat_data_bed17 = vc WITH noconstant(build2(
     IF (mn_pt_in_ed=1) ms_pt_bd_ed
     ELSE a_pat_data->bed
     ENDIF
     ,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 1.302)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.260
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name:",char(0)))
    SET rptsd->m_y = (offsety+ 1.646)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.073
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MR#:",char(0)))
    SET rptsd->m_y = (offsety+ 1.917)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Location:",char(0)))
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DOB:",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 3.807),(offsetx+ 7.417),(offsety+
     3.807))
    SET rptsd->m_y = (offsety+ 0.552)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.281
    SET _dummyfont = uar_rptsetfont(_hreport,_times16b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Transport Request",char(0)))
    SET rptsd->m_y = (offsety+ 2.750)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 0.823
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Exam Name:",char(0)))
    SET rptsd->m_flags = 256
    SET rptsd->m_y = (offsety+ 3.000)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 0.823
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Priority:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 3.969)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.333
    SET _dummyfont = uar_rptsetfont(_hreport,_times16b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("RETRIEVE PATIENT",char(0)))
    SET rptsd->m_y = (offsety+ 5.052)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.260
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name:",char(0)))
    SET rptsd->m_y = (offsety+ 4.750)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.073
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MR#:",char(0)))
    SET rptsd->m_y = (offsety+ 5.375)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Location:",char(0)))
    SET rptsd->m_y = (offsety+ 1.052)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.302
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date of Exam:",char(0)))
    SET rptsd->m_y = (offsety+ 4.500)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.302
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date of Exam:",char(0)))
    SET rptsd->m_y = (offsety+ 5.052)
    SET rptsd->m_x = (offsetx+ 3.500)
    SET rptsd->m_width = 0.333
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Age:",char(0)))
    SET rptsd->m_y = (offsety+ 6.125)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.583
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Exam Name:",char(0)))
    SET rptsd->m_y = (offsety+ 3.427)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Ordering Physician:",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.021),(offsety+ 6.807),(offsetx+ 7.365),(offsety+
     6.807))
    SET rptsd->m_y = (offsety+ 6.927)
    SET rptsd->m_x = (offsetx+ 2.927)
    SET rptsd->m_width = 2.302
    SET rptsd->m_height = 0.302
    SET _dummyfont = uar_rptsetfont(_hreport,_times16b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("RETURN PATIENT",char(0)))
    SET rptsd->m_y = (offsety+ 7.500)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name:",char(0)))
    SET rptsd->m_y = (offsety+ 7.750)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 0.698
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Location:",char(0)))
    SET rptsd->m_y = (offsety+ 8.875)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 1.302
    SET rptsd->m_height = 0.333
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Received By:",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.375),(offsety+ 9.005),(offsetx+ 3.250),(offsety+
     9.005))
    SET rptsd->m_flags = 256
    SET rptsd->m_y = (offsety+ 7.177)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.219
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Request:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 7.927)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 0.708
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Fat Meal",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.000),(offsety+ 8.057),(offsetx+ 7.250),(offsety+
     8.057))
    SET rptsd->m_y = (offsety+ 8.250)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Clear Liquids Only",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.000),(offsety+ 8.380),(offsetx+ 7.250),(offsety+
     8.380))
    SET rptsd->m_y = (offsety+ 7.427)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Return for X-Ray at",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.000),(offsety+ 7.557),(offsetx+ 6.677),(offsety+
     7.557))
    SET rptsd->m_y = (offsety+ 7.677)
    SET rptsd->m_x = (offsetx+ 4.625)
    SET rptsd->m_width = 0.323
    SET rptsd->m_height = 0.219
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("On",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.000),(offsety+ 7.807),(offsetx+ 6.698),(offsety+
     7.807))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.000),(offsety+ 9.896),(offsetx+ 5.875),(offsety+
     9.896))
    SET rptsd->m_flags = 256
    SET rptsd->m_y = (offsety+ 9.729)
    SET rptsd->m_x = (offsetx+ 6.125)
    SET rptsd->m_width = 1.344
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("M.D. Radiologist",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 8.500)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Nothing by Mouth",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.000),(offsety+ 8.630),(offsetx+ 7.250),(offsety+
     8.630))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 8.750)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 1.323
    SET rptsd->m_height = 0.323
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Repeat Prep for                         Tomorrow",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.000),(offsety+ 8.974),(offsetx+ 7.260),(offsety+
     8.974))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 9.125)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 0.698
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Prepare for",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.552),(offsety+ 9.255),(offsetx+ 5.552),(offsety+
     9.255))
    SET rptsd->m_y = (offsety+ 9.125)
    SET rptsd->m_x = (offsetx+ 5.802)
    SET rptsd->m_width = 0.250
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("on",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.125),(offsety+ 9.240),(offsetx+ 7.208),(offsety+
     9.240))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 9.302)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 1.198
    SET rptsd->m_height = 0.375
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "May Resume Usual                             Diet ",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.000),(offsety+ 9.526),(offsetx+ 7.198),(offsety+
     9.526))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.052)
    SET rptsd->m_x = (offsetx+ 2.125)
    SET rptsd->m_width = 2.375
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times140)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_facility_inst_name)
    SET rptsd->m_flags = 272
    SET rptsd->m_y = (offsety+ 0.302)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 2.448
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_facility_sect_disp)
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.052)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 1.448
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_exam_rqst_date_1)
    SET rptsd->m_flags = 256
    SET rptsd->m_y = (offsety+ 1.302)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 1.948
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_pat_data_full_name)
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 4.125)
    SET rptsd->m_width = 0.573
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_pat_data_dob)
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_pat_data_gender)
    SET rptsd->m_y = (offsety+ 1.625)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 1.031
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_pat_data_med_nbr)
    SET rptsd->m_y = (offsety+ 1.875)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_pat_data_nurse_unit)
    SET rptsd->m_y = (offsety+ 2.063)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 2.125
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_pat_data_room)
    SET rptsd->m_y = (offsety+ 2.302)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 2.375
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_pat_data_bed)
    SET rptsd->m_y = (offsety+ 2.750)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 2.448
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_exam_exam_name_1)
    SET rptsd->m_y = (offsety+ 3.052)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_exam_priority_1)
    SET rptsd->m_y = (offsety+ 3.500)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 2.625
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_doc_order_doc_name)
    SET rptsd->m_y = (offsety+ 6.500)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 3.177
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Transport Mode: _______________________________",char(0)))
    SET rptsd->m_y = (offsety+ 4.500)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 1.365
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_exam_rqst_date_4)
    SET rptsd->m_y = (offsety+ 4.750)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 1.177
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_pat_data_med_nbr5)
    SET rptsd->m_y = (offsety+ 5.063)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_pat_data_full_name6)
    SET rptsd->m_y = (offsety+ 5.052)
    SET rptsd->m_x = (offsetx+ 3.802)
    SET rptsd->m_width = 0.667
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_pat_data_age)
    SET rptsd->m_y = (offsety+ 5.375)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_pat_data_nurse_unit7)
    SET rptsd->m_y = (offsety+ 5.552)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 1.177
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_pat_data_room8)
    SET rptsd->m_y = (offsety+ 5.750)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 0.958
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_pat_data_bed9)
    SET rptsd->m_y = (offsety+ 6.125)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_exam_exam_name_10)
    SET rptsd->m_y = (offsety+ 4.500)
    SET rptsd->m_x = (offsetx+ 3.500)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Bring at: ___________________",char(0
       )))
    SET rptsd->m_y = (offsety+ 7.500)
    SET rptsd->m_x = (offsetx+ 1.302)
    SET rptsd->m_width = 2.385
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_pat_data_full_name14)
    SET rptsd->m_y = (offsety+ 7.750)
    SET rptsd->m_x = (offsetx+ 1.302)
    SET rptsd->m_width = 2.260
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_pat_data_nurse_unit15)
    SET rptsd->m_y = (offsety+ 8.000)
    SET rptsd->m_x = (offsetx+ 1.302)
    SET rptsd->m_width = 1.302
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_pat_data_room16)
    SET rptsd->m_y = (offsety+ 8.250)
    SET rptsd->m_x = (offsetx+ 1.313)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__a_pat_data_bed17)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE layoutsection1(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = layoutsection1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE layoutsection1abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.000000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHSMARADTRAN"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 52
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 16
   SET rptfont->m_bold = rpt_on
   SET _times16b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 14
   SET rptfont->m_bold = rpt_off
   SET _times140 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 FOR (x = 1 TO size(data->req[req_ndx].sections[sect_ndx].exam_data,5))
   IF ((data->req[req_ndx].patient_data.encntr_type_disp IN ("Inpatient", "Emergency", "Observation",
   "Daystay")))
    SET order_id = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
     order_id)
    SET tempdir = "cer_temp:radtrns"
    IF (validate(_outfile,"1") != "1")
     SET tempfile = _outfile
    ELSE
     SET tempfile = concat(tempdir,"_",trim(cnvtstring(curtime3)),"_",trim(order_id),
      ".dat")
    ENDIF
    CALL echo(value(tempfile))
    SELECT INTO "nl:"
     FROM encntr_domain ed,
      tracking_item ti,
      tracking_locator tl
     PLAN (ed
      WHERE (ed.encntr_id=data->req[req_ndx].patient_data.encntr_id)
       AND ed.active_ind=1
       AND ed.encntr_id != 0
       AND cnvtdatetime(curdate,curtime3) BETWEEN ed.beg_effective_dt_tm AND ed.end_effective_dt_tm)
      JOIN (ti
      WHERE ed.encntr_id=ti.encntr_id
       AND ti.tracking_status_flag=1)
      JOIN (tl
      WHERE tl.tracking_locator_id=ti.cur_tracking_locator_id)
     HEAD REPORT
      mn_pt_in_ed = 0
     DETAIL
      IF (ed.loc_nurse_unit_cd IN (mf_eshld, mf_esa, mf_esb, mf_esc, mf_esd,
      mf_ese, mf_esp, mf_esw, mf_esx))
       ms_pt_rm_ed = trim(uar_get_code_display(tl.loc_room_cd),3), ms_pt_bd_ed = trim(
        uar_get_code_display(tl.loc_bed_cd),3), mn_pt_in_ed = 1,
       CALL echo(build("ms_pt_rm_ed = ",ms_pt_rm_ed)),
       CALL echo(build("ms_pt_bd_ed = ",ms_pt_bd_ed))
      ENDIF
     WITH nocounter
    ;end select
    CALL initializereport(0)
    SELECT INTO "nl:"
     DETAIL
      FOR (exam_ndx = 1 TO size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5)
       BY data->req[req_ndx].sections[sect_ndx].nbr_of_exams_per_req)
        CALL echo("****************START ADDRESS DATA********************")
        IF ((data->req[req_ndx].patient_data.facility_desc > " "))
         a_facility->facility_name = data->req[req_ndx].patient_data.facility_desc
        ELSE
         a_facility->facility_name = " "
        ENDIF
        IF ((data->req[req_ndx].sections[sect_ndx].inst_desc > " "))
         a_facility->inst_name = data->req[req_ndx].sections[sect_ndx].inst_desc
        ELSE
         a_facility->inst_name = " "
        ENDIF
        IF ((data->req[req_ndx].sections[sect_ndx].section_disp > " "))
         a_facility->sect_disp = data->req[req_ndx].sections[sect_ndx].section_disp
        ELSE
         a_facility->sect_disp = " "
        ENDIF
        IF ((data->req[req_ndx].sections[sect_ndx].dept_name > " "))
         a_facility->dept_name = data->req[req_ndx].sections[sect_ndx].dept_name
        ELSE
         a_facility->dept_name = " "
        ENDIF
        IF ((data->req[req_ndx].sections[sect_ndx].dept_desc > " "))
         a_facility->dept_desc = data->req[req_ndx].sections[sect_ndx].dept_desc
        ELSE
         a_facility->dept_desc = " "
        ENDIF
        IF ((data->req[req_ndx].patient_data.fac_addr > " "))
         a_facility->address = data->req[req_ndx].patient_data.fac_addr
        ELSE
         a_facility->address = " "
        ENDIF
        IF ((data->req[req_ndx].patient_data.fac_city > " "))
         a_facility->city = data->req[req_ndx].patient_data.fac_city
        ELSE
         a_facility->city = " "
        ENDIF
        IF ((data->req[req_ndx].patient_data.fac_state > " "))
         a_facility->state = data->req[req_ndx].patient_data.fac_state
        ELSE
         a_facility->state = " "
        ENDIF
        IF ((data->req[req_ndx].patient_data.fac_zip > " "))
         a_facility->zip = data->req[req_ndx].patient_data.fac_zip
        ELSE
         a_facility->zip = " "
        ENDIF
        CALL echo("****************START OF ALLERGY DATA********************")
        IF (size(data->req[req_ndx].allergy,5) > 0)
         IF (trim(data->req[req_ndx].allergy[1].flexed_desc) != " ")
          a_allergy->allergy_1 = data->req[req_ndx].allergy[1].flexed_desc
         ELSE
          a_allergy->allergy_1 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].allergy,5) > 1)
         IF (trim(data->req[req_ndx].allergy[2].flexed_desc) != " ")
          a_allergy->allergy_2 = data->req[req_ndx].allergy[2].flexed_desc
         ELSE
          a_allergy->allergy_2 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].allergy,5) > 2)
         IF (trim(data->req[req_ndx].allergy[3].flexed_desc) != " ")
          a_allergy->allergy_3 = data->req[req_ndx].allergy[3].flexed_desc
         ELSE
          a_allergy->allergy_3 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].allergy,5) > 3)
         IF (trim(data->req[req_ndx].allergy[4].flexed_desc) != " ")
          a_allergy->allergy_4 = data->req[req_ndx].allergy[4].flexed_desc
         ELSE
          a_allergy->allergy_4 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].allergy,5) > 4)
         IF (trim(data->req[req_ndx].allergy[5].flexed_desc) != " ")
          a_allergy->allergy_5 = data->req[req_ndx].allergy[5].flexed_desc
         ELSE
          a_allergy->allergy_5 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].allergy,5) > 5)
         IF (trim(data->req[req_ndx].allergy[6].flexed_desc) != " ")
          a_allergy->allergy_6 = data->req[req_ndx].allergy[6].flexed_desc
         ELSE
          a_allergy->allergy_6 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].allergy,5) > 6)
         IF (trim(data->req[req_ndx].allergy[7].flexed_desc) != " ")
          a_allergy->allergy_7 = data->req[req_ndx].allergy[7].flexed_desc
         ELSE
          a_allergy->allergy_7 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].allergy,5) > 7)
         IF (trim(data->req[req_ndx].allergy[8].flexed_desc) != " ")
          a_allergy->allergy_8 = data->req[req_ndx].allergy[8].flexed_desc
         ELSE
          a_allergy->allergy_8 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].allergy,5) > 8)
         IF (trim(data->req[req_ndx].allergy[9].flexed_desc) != " ")
          a_allergy->allergy_9 = data->req[req_ndx].allergy[9].flexed_desc
         ELSE
          a_allergy->allergy_9 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].allergy,5) > 9)
         IF (trim(data->req[req_ndx].allergy[10].flexed_desc) != " ")
          a_allergy->allergy_10 = data->req[req_ndx].allergy[10].flexed_desc
         ELSE
          a_allergy->allergy_10 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].allergy,5) > 10)
         IF (trim(data->req[req_ndx].allergy[11].flexed_desc) != " ")
          a_allergy->allergy_11 = data->req[req_ndx].allergy[11].flexed_desc
         ELSE
          a_allergy->allergy_11 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].allergy,5) > 11)
         IF (trim(data->req[req_ndx].allergy[12].flexed_desc) != " ")
          a_allergy->allergy_12 = data->req[req_ndx].allergy[12].flexed_desc
         ELSE
          a_allergy->allergy_12 = " "
         ENDIF
        ENDIF
        CALL echo("****************START OF CDM DATA********************")
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 0)
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
          cdm_codes,5) > 0)
          a_cdm->code1_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx]
          .cdm_codes[1].cdm_code, a_cdm->desc1_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x]
          .for_this_page[exam_ndx].cdm_codes[1].cdm_desc
         ELSE
          a_cdm->code1_1 = " ", a_cdm->desc1_1 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
          cdm_codes,5) > 1)
          a_cdm->code1_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx]
          .cdm_codes[2].cdm_code, a_cdm->desc1_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x]
          .for_this_page[exam_ndx].cdm_codes[2].cdm_desc
         ELSE
          a_cdm->code1_2 = " ", a_cdm->desc1_2 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
          cdm_codes,5) > 2)
          a_cdm->code1_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx]
          .cdm_codes[3].cdm_code, a_cdm->desc1_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x]
          .for_this_page[exam_ndx].cdm_codes[3].cdm_desc
         ELSE
          a_cdm->code1_3 = " ", a_cdm->desc1_3 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
          cdm_codes,5) > 3)
          a_cdm->code1_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx]
          .cdm_codes[4].cdm_code, a_cdm->desc1_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x]
          .for_this_page[exam_ndx].cdm_codes[4].cdm_desc
         ELSE
          a_cdm->code1_4 = " ", a_cdm->desc1_4 = " "
         ENDIF
        ELSE
         a_cdm->code1_1 = " ", a_cdm->code1_2 = " ", a_cdm->code1_3 = " ",
         a_cdm->code1_4 = " ", a_cdm->desc1_1 = " ", a_cdm->desc1_2 = " ",
         a_cdm->desc1_3 = " ", a_cdm->desc1_4 = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 1)
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)],5)
          >= (exam_ndx+ 1)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].
           cdm_codes,5) > 0)
           a_cdm->code2_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 1)].cdm_codes[1].cdm_code, a_cdm->desc2_1 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 1)].cdm_codes[1].cdm_desc
          ELSE
           a_cdm->code2_1 = " ", a_cdm->desc2_1 = " "
          ENDIF
         ELSE
          a_cdm->code2_1 = " ", a_cdm->desc2_1 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)],5)
          >= (exam_ndx+ 1)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].
           cdm_codes,5) > 1)
           a_cdm->code2_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 1)].cdm_codes[2].cdm_code, a_cdm->desc2_2 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 1)].cdm_codes[2].cdm_desc
          ELSE
           a_cdm->code2_2 = " ", a_cdm->desc2_2 = " "
          ENDIF
         ELSE
          a_cdm->code2_2 = " ", a_cdm->desc2_2 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)],5)
          >= (exam_ndx+ 1)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].
           cdm_codes,5) > 2)
           a_cdm->code2_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 1)].cdm_codes[3].cdm_code, a_cdm->desc2_3 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 1)].cdm_codes[3].cdm_desc
          ELSE
           a_cdm->code2_3 = " ", a_cdm->desc2_3 = " "
          ENDIF
         ELSE
          a_cdm->code2_3 = " ", a_cdm->desc2_3 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)],5)
          >= (exam_ndx+ 1)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].
           cdm_codes,5) > 3)
           a_cdm->code2_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 1)].cdm_codes[4].cdm_code, a_cdm->desc2_4 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 1)].cdm_codes[4].cdm_desc
          ELSE
           a_cdm->code2_4 = " ", a_cdm->desc2_4 = " "
          ENDIF
         ELSE
          a_cdm->code2_4 = " ", a_cdm->desc2_4 = " "
         ENDIF
        ELSE
         a_cdm->code2_1 = " ", a_cdm->code2_2 = " ", a_cdm->code2_3 = " ",
         a_cdm->code2_4 = " ", a_cdm->desc2_1 = " ", a_cdm->desc2_2 = " ",
         a_cdm->desc2_3 = " ", a_cdm->desc2_4 = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 2)
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)],5)
          >= (exam_ndx+ 2)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].
           cdm_codes,5) > 0)
           a_cdm->code3_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 2)].cdm_codes[1].cdm_code, a_cdm->desc3_1 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 2)].cdm_codes[1].cdm_desc
          ELSE
           a_cdm->code3_1 = " ", a_cdm->desc3_1 = " "
          ENDIF
         ELSE
          a_cdm->code3_1 = " ", a_cdm->desc3_1 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)],5)
          >= (exam_ndx+ 2)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].
           cdm_codes,5) > 1)
           a_cdm->code3_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 2)].cdm_codes[2].cdm_code, a_cdm->desc3_2 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 2)].cdm_codes[2].cdm_desc
          ELSE
           a_cdm->code3_2 = " ", a_cdm->desc3_2 = " "
          ENDIF
         ELSE
          a_cdm->code3_2 = " ", a_cdm->desc3_2 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)],5)
          >= (exam_ndx+ 2)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].
           cdm_codes,5) > 2)
           a_cdm->code3_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 2)].cdm_codes[3].cdm_code, a_cdm->desc3_3 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 2)].cdm_codes[3].cdm_desc
          ELSE
           a_cdm->code3_3 = " ", a_cdm->desc3_3 = " "
          ENDIF
         ELSE
          a_cdm->code3_3 = " ", a_cdm->desc3_3 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)],5)
          >= (exam_ndx+ 2)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].
           cdm_codes,5) > 3)
           a_cdm->code3_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 2)].cdm_codes[4].cdm_code, a_cdm->desc3_4 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 2)].cdm_codes[4].cdm_desc
          ELSE
           a_cdm->code3_4 = " ", a_cdm->desc3_4 = " "
          ENDIF
         ELSE
          a_cdm->code3_4 = " ", a_cdm->desc3_4 = " "
         ENDIF
        ELSE
         a_cdm->code3_1 = " ", a_cdm->code3_2 = " ", a_cdm->code3_3 = " ",
         a_cdm->code3_4 = " ", a_cdm->desc3_1 = " ", a_cdm->desc3_2 = " ",
         a_cdm->desc3_3 = " ", a_cdm->desc3_4 = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 3)
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)],5)
          >= (exam_ndx+ 3)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].
           cdm_codes,5) > 0)
           a_cdm->code4_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 3)].cdm_codes[1].cdm_code, a_cdm->desc4_1 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 3)].cdm_codes[1].cdm_desc
          ELSE
           a_cdm->code4_1 = " ", a_cdm->desc4_1 = " "
          ENDIF
         ELSE
          a_cdm->code4_1 = " ", a_cdm->desc4_1 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)],5)
          >= (exam_ndx+ 3)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].
           cdm_codes,5) > 0)
           a_cdm->code4_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 3)].cdm_codes[2].cdm_code, a_cdm->desc4_2 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 3)].cdm_codes[2].cdm_desc
          ELSE
           a_cdm->code4_2 = " ", a_cdm->desc4_2 = " "
          ENDIF
         ELSE
          a_cdm->code4_2 = " ", a_cdm->desc4_2 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)],5)
          >= (exam_ndx+ 3)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].
           cdm_codes,5) > 0)
           a_cdm->code4_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 3)].cdm_codes[3].cdm_code, a_cdm->desc4_3 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 2)].cdm_codes[3].cdm_desc
          ELSE
           a_cdm->code4_3 = " ", a_cdm->desc4_3 = " "
          ENDIF
         ELSE
          a_cdm->code4_3 = " ", a_cdm->desc4_3 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)],5)
          >= (exam_ndx+ 3)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].
           cdm_codes,5) > 0)
           a_cdm->code4_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 3)].cdm_codes[4].cdm_code, a_cdm->desc4_4 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 3)].cdm_codes[4].cdm_desc
          ELSE
           a_cdm->code4_4 = " ", a_cdm->desc4_4 = " "
          ENDIF
         ELSE
          a_cdm->code4_4 = " ", a_cdm->desc4_4 = " "
         ENDIF
        ELSE
         a_cdm->code4_1 = " ", a_cdm->code4_2 = " ", a_cdm->code4_3 = " ",
         a_cdm->code4_4 = " ", a_cdm->desc4_1 = " ", a_cdm->desc4_2 = " ",
         a_cdm->desc4_3 = " ", a_cdm->desc4_4 = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 4)
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)],5)
          >= (exam_ndx+ 4)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].
           cdm_codes,5) > 0)
           a_cdm->code5_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 4)].cdm_codes[1].cdm_code, a_cdm->desc5_1 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 4)].cdm_codes[1].cdm_desc
          ELSE
           a_cdm->code5_1 = " ", a_cdm->desc5_1 = " "
          ENDIF
         ELSE
          a_cdm->code5_1 = " ", a_cdm->desc5_1 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)],5)
          >= (exam_ndx+ 4)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].
           cdm_codes,5) > 0)
           a_cdm->code5_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 4)].cdm_codes[2].cdm_code, a_cdm->desc5_2 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 4)].cdm_codes[2].cdm_desc
          ELSE
           a_cdm->code5_2 = " ", a_cdm->desc5_2 = " "
          ENDIF
         ELSE
          a_cdm->code5_2 = " ", a_cdm->desc5_2 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)],5)
          >= (exam_ndx+ 4)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].
           cdm_codes,5) > 0)
           a_cdm->code5_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 4)].cdm_codes[3].cdm_code, a_cdm->desc5_3 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 4)].cdm_codes[3].cdm_desc
          ELSE
           a_cdm->code5_3 = " ", a_cdm->desc5_3 = " "
          ENDIF
         ELSE
          a_cdm->code5_3 = " ", a_cdm->desc5_3 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)],5)
          >= (exam_ndx+ 4)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].
           cdm_codes,5) > 0)
           a_cdm->code5_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 4)].cdm_codes[4].cdm_code, a_cdm->desc5_4 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 4)].cdm_codes[4].cdm_desc
          ELSE
           a_cdm->code5_4 = " ", a_cdm->desc5_4 = " "
          ENDIF
         ELSE
          a_cdm->code5_4 = " ", a_cdm->desc5_4 = " "
         ENDIF
        ELSE
         a_cdm->code5_1 = " ", a_cdm->code5_2 = " ", a_cdm->code5_3 = " ",
         a_cdm->code5_4 = " ", a_cdm->desc5_1 = " ", a_cdm->desc5_2 = " ",
         a_cdm->desc5_3 = " ", a_cdm->desc5_4 = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 5)
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)],5)
          >= (exam_ndx+ 5)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].
           cdm_codes,5) > 0)
           a_cdm->code6_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 5)].cdm_codes[1].cdm_code, a_cdm->desc6_1 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 5)].cdm_codes[1].cdm_desc
          ELSE
           a_cdm->code6_1 = " ", a_cdm->desc6_1 = " "
          ENDIF
         ELSE
          a_cdm->code6_1 = " ", a_cdm->desc6_1 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)],5)
          >= (exam_ndx+ 5)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].
           cdm_codes,5) > 0)
           a_cdm->code6_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 5)].cdm_codes[2].cdm_code, a_cdm->desc6_2 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 5)].cdm_codes[2].cdm_desc
          ELSE
           a_cdm->code6_2 = " ", a_cdm->desc6_2 = " "
          ENDIF
         ELSE
          a_cdm->code6_2 = " ", a_cdm->desc6_2 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)],5)
          >= (exam_ndx+ 5)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].
           cdm_codes,5) > 0)
           a_cdm->code6_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 5)].cdm_codes[3].cdm_code, a_cdm->desc6_3 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 5)].cdm_codes[3].cdm_desc
          ELSE
           a_cdm->code6_3 = " ", a_cdm->desc6_3 = " "
          ENDIF
         ELSE
          a_cdm->code6_3 = " ", a_cdm->desc6_3 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)],5)
          >= (exam_ndx+ 5)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].
           cdm_codes,5) > 0)
           a_cdm->code6_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 5)].cdm_codes[4].cdm_code, a_cdm->desc6_4 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 5)].cdm_codes[4].cdm_desc
          ELSE
           a_cdm->code6_4 = " ", a_cdm->desc6_4 = " "
          ENDIF
         ELSE
          a_cdm->code6_4 = " ", a_cdm->desc6_4 = " "
         ENDIF
        ELSE
         a_cdm->code6_1 = " ", a_cdm->code6_2 = " ", a_cdm->code6_3 = " ",
         a_cdm->code6_4 = " ", a_cdm->desc6_1 = " ", a_cdm->desc6_2 = " ",
         a_cdm->desc6_3 = " ", a_cdm->desc6_4 = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 6)
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)],5)
          >= (exam_ndx+ 6)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].
           cdm_codes,5) > 0)
           a_cdm->code7_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 6)].cdm_codes[1].cdm_code, a_cdm->desc7_1 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 6)].cdm_codes[1].cdm_desc
          ELSE
           a_cdm->code7_1 = " ", a_cdm->desc7_1 = " "
          ENDIF
         ELSE
          a_cdm->code7_1 = " ", a_cdm->desc7_1 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)],5)
          >= (exam_ndx+ 6)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].
           cdm_codes,5) > 0)
           a_cdm->code7_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 6)].cdm_codes[2].cdm_code, a_cdm->desc7_2 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 6)].cdm_codes[2].cdm_desc
          ELSE
           a_cdm->code7_2 = " ", a_cdm->desc7_2 = " "
          ENDIF
         ELSE
          a_cdm->code7_2 = " ", a_cdm->desc7_2 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)],5)
          >= (exam_ndx+ 6)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].
           cdm_codes,5) > 0)
           a_cdm->code7_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 6)].cdm_codes[3].cdm_code, a_cdm->desc7_3 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 6)].cdm_codes[3].cdm_desc
          ELSE
           a_cdm->code7_3 = " ", a_cdm->desc7_3 = " "
          ENDIF
         ELSE
          a_cdm->code7_3 = " ", a_cdm->desc7_3 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)],5)
          >= (exam_ndx+ 6)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].
           cdm_codes,5) > 0)
           a_cdm->code7_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 6)].cdm_codes[4].cdm_code, a_cdm->desc7_4 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 6)].cdm_codes[4].cdm_desc
          ELSE
           a_cdm->code7_4 = " ", a_cdm->desc7_4 = " "
          ENDIF
         ELSE
          a_cdm->code7_4 = " ", a_cdm->desc7_4 = " "
         ENDIF
        ELSE
         a_cdm->code7_1 = " ", a_cdm->code7_2 = " ", a_cdm->code7_3 = " ",
         a_cdm->code7_4 = " ", a_cdm->desc7_1 = " ", a_cdm->desc7_2 = " ",
         a_cdm->desc7_3 = " ", a_cdm->desc7_4 = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 7)
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)],5)
          >= (exam_ndx+ 7)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].
           cdm_codes,5) > 0)
           a_cdm->code8_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 7)].cdm_codes[1].cdm_code, a_cdm->desc8_1 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 7)].cdm_codes[1].cdm_desc
          ELSE
           a_cdm->code8_1 = " ", a_cdm->desc8_1 = " "
          ENDIF
         ELSE
          a_cdm->code8_1 = " ", a_cdm->desc8_1 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)],5)
          >= (exam_ndx+ 7)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].
           cdm_codes,5) > 0)
           a_cdm->code8_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 7)].cdm_codes[2].cdm_code, a_cdm->desc8_2 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 7)].cdm_codes[2].cdm_desc
          ELSE
           a_cdm->code8_2 = " ", a_cdm->desc8_2 = " "
          ENDIF
         ELSE
          a_cdm->code8_2 = " ", a_cdm->desc8_2 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)],5)
          >= (exam_ndx+ 7)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].
           cdm_codes,5) > 0)
           a_cdm->code8_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 7)].cdm_codes[3].cdm_code, a_cdm->desc8_3 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 7)].cdm_codes[3].cdm_desc
          ELSE
           a_cdm->code8_3 = " ", a_cdm->desc8_3 = " "
          ENDIF
         ELSE
          a_cdm->code8_3 = " ", a_cdm->desc8_3 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)],5)
          >= (exam_ndx+ 7)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].
           cdm_codes,5) > 0)
           a_cdm->code8_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 7)].cdm_codes[4].cdm_code, a_cdm->desc8_4 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 7)].cdm_codes[4].cdm_desc
          ELSE
           a_cdm->code8_4 = " ", a_cdm->desc8_4 = " "
          ENDIF
         ELSE
          a_cdm->code8_4 = " ", a_cdm->desc8_4 = " "
         ENDIF
        ELSE
         a_cdm->code8_1 = " ", a_cdm->code8_2 = " ", a_cdm->code8_3 = " ",
         a_cdm->code8_4 = " ", a_cdm->desc8_1 = " ", a_cdm->desc8_2 = " ",
         a_cdm->desc8_3 = " ", a_cdm->desc8_4 = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 8)
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)],5)
          >= (exam_ndx+ 8)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].
           cdm_codes,5) > 0)
           a_cdm->code9_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 8)].cdm_codes[1].cdm_code, a_cdm->desc9_1 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 8)].cdm_codes[1].cdm_desc
          ELSE
           a_cdm->code9_1 = " ", a_cdm->desc9_1 = " "
          ENDIF
         ELSE
          a_cdm->code9_1 = " ", a_cdm->desc9_1 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)],5)
          >= (exam_ndx+ 8)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].
           cdm_codes,5) > 0)
           a_cdm->code9_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 8)].cdm_codes[2].cdm_code, a_cdm->desc9_2 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 8)].cdm_codes[2].cdm_desc
          ELSE
           a_cdm->code9_2 = " ", a_cdm->desc9_2 = " "
          ENDIF
         ELSE
          a_cdm->code9_2 = " ", a_cdm->desc9_2 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)],5)
          >= (exam_ndx+ 8)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].
           cdm_codes,5) > 0)
           a_cdm->code9_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 8)].cdm_codes[3].cdm_code, a_cdm->desc9_3 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 8)].cdm_codes[3].cdm_desc
          ELSE
           a_cdm->code9_3 = " ", a_cdm->desc9_3 = " "
          ENDIF
         ELSE
          a_cdm->code9_3 = " ", a_cdm->desc9_3 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)],5)
          >= (exam_ndx+ 8)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].
           cdm_codes,5) > 0)
           a_cdm->code9_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 8)].cdm_codes[4].cdm_code, a_cdm->desc9_4 = data->req[req_ndx].sections[sect_ndx
           ].exam_data[x].for_this_page[(exam_ndx+ 8)].cdm_codes[4].cdm_desc
          ELSE
           a_cdm->code9_4 = " ", a_cdm->desc9_4 = " "
          ENDIF
         ELSE
          a_cdm->code9_4 = " ", a_cdm->desc9_4 = " "
         ENDIF
        ELSE
         a_cdm->code9_1 = " ", a_cdm->code9_2 = " ", a_cdm->code9_3 = " ",
         a_cdm->code9_4 = " ", a_cdm->desc9_1 = " ", a_cdm->desc9_2 = " ",
         a_cdm->desc9_3 = " ", a_cdm->desc9_4 = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 9)
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)],5)
          >= (exam_ndx+ 9)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].
           cdm_codes,5) > 0)
           a_cdm->code10_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 9)].cdm_codes[1].cdm_code, a_cdm->desc10_1 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].cdm_codes[1].cdm_desc
          ELSE
           a_cdm->code10_1 = " ", a_cdm->desc10_1 = " "
          ENDIF
         ELSE
          a_cdm->code10_1 = " ", a_cdm->desc10_1 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)],5)
          >= (exam_ndx+ 9)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].
           cdm_codes,5) > 0)
           a_cdm->code10_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 9)].cdm_codes[2].cdm_code, a_cdm->desc10_2 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].cdm_codes[2].cdm_desc
          ELSE
           a_cdm->code10_2 = " ", a_cdm->desc10_2 = " "
          ENDIF
         ELSE
          a_cdm->code10_2 = " ", a_cdm->desc10_2 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)],5)
          >= (exam_ndx+ 9)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].
           cdm_codes,5) > 0)
           a_cdm->code10_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 9)].cdm_codes[3].cdm_code, a_cdm->desc10_3 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].cdm_codes[3].cdm_desc
          ELSE
           a_cdm->code10_3 = " ", a_cdm->desc10_3 = " "
          ENDIF
         ELSE
          a_cdm->code10_3 = " ", a_cdm->desc10_3 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)],5)
          >= (exam_ndx+ 9)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].
           cdm_codes,5) > 0)
           a_cdm->code10_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 9)].cdm_codes[4].cdm_code, a_cdm->desc10_4 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].cdm_codes[4].cdm_desc
          ELSE
           a_cdm->code10_4 = " ", a_cdm->desc10_4 = " "
          ENDIF
         ELSE
          a_cdm->code10_4 = " ", a_cdm->desc10_4 = " "
         ENDIF
        ELSE
         a_cdm->code10_1 = " ", a_cdm->code10_2 = " ", a_cdm->code10_3 = " ",
         a_cdm->code10_4 = " ", a_cdm->desc10_1 = " ", a_cdm->desc10_2 = " ",
         a_cdm->desc10_3 = " ", a_cdm->desc10_4 = " "
        ENDIF
        CALL echo("****************START OF CPT4 DATA********************")
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 0)
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
          cpt_codes,5) > 0)
          a_cpt4->code1_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx
          ].cpt_codes[1].cpt4_code, a_cpt4->desc1_1 = data->req[req_ndx].sections[sect_ndx].
          exam_data[x].for_this_page[exam_ndx].cpt_codes[1].cpt4_desc
         ELSE
          a_cpt4->code1_1 = " ", a_cpt4->desc1_1 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
          cpt_codes,5) > 1)
          a_cpt4->code1_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx
          ].cpt_codes[2].cpt4_code, a_cpt4->desc1_2 = data->req[req_ndx].sections[sect_ndx].
          exam_data[x].for_this_page[exam_ndx].cpt_codes[2].cpt4_desc
         ELSE
          a_cpt4->code1_2 = " ", a_cpt4->desc1_2 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
          cpt_codes,5) > 2)
          a_cpt4->code1_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx
          ].cpt_codes[3].cpt4_code, a_cpt4->desc1_3 = data->req[req_ndx].sections[sect_ndx].
          exam_data[x].for_this_page[exam_ndx].cpt_codes[3].cpt4_desc
         ELSE
          a_cpt4->code1_3 = " ", a_cpt4->desc1_3 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
          cpt_codes,5) > 3)
          a_cpt4->code1_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx
          ].cpt_codes[4].cpt4_code, a_cpt4->desc1_4 = data->req[req_ndx].sections[sect_ndx].
          exam_data[x].for_this_page[exam_ndx].cpt_codes[4].cpt4_desc
         ELSE
          a_cpt4->code1_4 = " ", a_cpt4->desc1_4 = " "
         ENDIF
        ELSE
         a_cpt4->code1_1 = " ", a_cpt4->code1_2 = " ", a_cpt4->code1_3 = " ",
         a_cpt4->code1_4 = " ", a_cpt4->desc1_1 = " ", a_cpt4->desc1_2 = " ",
         a_cpt4->desc1_3 = " ", a_cpt4->desc1_4 = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 1)
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)],5)
          >= (exam_ndx+ 1)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].
           cpt_codes,5) > 0)
           a_cpt4->code2_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 1)].cpt_codes[1].cpt4_code, a_cpt4->desc2_1 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].cpt_codes[1].cpt4_desc
          ELSE
           a_cpt4->code2_1 = " ", a_cpt4->desc2_1 = " "
          ENDIF
         ELSE
          a_cpt4->code2_1 = " ", a_cpt4->desc2_1 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)],5)
          >= (exam_ndx+ 1)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].
           cpt_codes,5) > 1)
           a_cpt4->code2_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 1)].cpt_codes[2].cpt4_code, a_cpt4->desc2_2 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].cpt_codes[2].cpt4_desc
          ELSE
           a_cpt4->code2_2 = " ", a_cpt4->desc2_2 = " "
          ENDIF
         ELSE
          a_cpt4->code2_2 = " ", a_cpt4->desc2_2 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)],5)
          >= (exam_ndx+ 1)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].
           cpt_codes,5) > 2)
           a_cpt4->code2_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 1)].cpt_codes[3].cpt4_code, a_cpt4->desc2_3 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].cpt_codes[3].cpt4_desc
          ELSE
           a_cpt4->code2_3 = " ", a_cpt4->desc2_3 = " "
          ENDIF
         ELSE
          a_cpt4->code2_3 = " ", a_cpt4->desc2_3 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)],5)
          >= (exam_ndx+ 1)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].
           cpt_codes,5) > 3)
           a_cpt4->code2_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 1)].cpt_codes[4].cpt4_code, a_cpt4->desc2_4 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].cpt_codes[4].cpt4_desc
          ELSE
           a_cpt4->code2_4 = " ", a_cpt4->desc2_4 = " "
          ENDIF
         ELSE
          a_cpt4->code2_4 = " ", a_cpt4->desc2_4 = " "
         ENDIF
        ELSE
         a_cpt4->code2_1 = " ", a_cpt4->code2_2 = " ", a_cpt4->code2_3 = " ",
         a_cpt4->code2_4 = " ", a_cpt4->desc2_1 = " ", a_cpt4->desc2_2 = " ",
         a_cpt4->desc2_3 = " ", a_cpt4->desc2_4 = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 2)
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)],5)
          >= (exam_ndx+ 2)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].
           cpt_codes,5) > 0)
           a_cpt4->code3_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 2)].cpt_codes[1].cpt4_code, a_cpt4->desc3_1 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].cpt_codes[1].cpt4_desc
          ELSE
           a_cpt4->code3_1 = " ", a_cpt4->desc3_1 = " "
          ENDIF
         ELSE
          a_cpt4->code3_1 = " ", a_cpt4->desc3_1 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)],5)
          >= (exam_ndx+ 2)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].
           cpt_codes,5) > 1)
           a_cpt4->code3_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 2)].cpt_codes[2].cpt4_code, a_cpt4->desc3_2 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].cpt_codes[2].cpt4_desc
          ELSE
           a_cpt4->code3_2 = " ", a_cpt4->desc3_2 = " "
          ENDIF
         ELSE
          a_cpt4->code3_2 = " ", a_cpt4->desc3_2 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)],5)
          >= (exam_ndx+ 2)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].
           cpt_codes,5) > 2)
           a_cpt4->code3_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 2)].cpt_codes[3].cpt4_code, a_cpt4->desc3_3 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].cpt_codes[3].cpt4_desc
          ELSE
           a_cpt4->code3_3 = " ", a_cpt4->desc3_3 = " "
          ENDIF
         ELSE
          a_cpt4->code3_3 = " ", a_cpt4->desc3_3 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)],5)
          >= (exam_ndx+ 2)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].
           cpt_codes,5) > 3)
           a_cpt4->code3_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 2)].cpt_codes[4].cpt4_code, a_cpt4->desc3_4 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].cpt_codes[4].cpt4_desc
          ELSE
           a_cpt4->code3_4 = " ", a_cpt4->desc3_4 = " "
          ENDIF
         ELSE
          a_cpt4->code3_4 = " ", a_cpt4->desc3_4 = " "
         ENDIF
        ELSE
         a_cpt4->code3_1 = " ", a_cpt4->code3_2 = " ", a_cpt4->code3_3 = " ",
         a_cpt4->code3_4 = " ", a_cpt4->desc3_1 = " ", a_cpt4->desc3_2 = " ",
         a_cpt4->desc3_3 = " ", a_cpt4->desc3_4 = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 3)
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)],5)
          >= (exam_ndx+ 3)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].
           cpt_codes,5) > 0)
           a_cpt4->code4_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 3)].cpt_codes[1].cpt4_code, a_cpt4->desc4_1 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].cpt_codes[1].cpt4_desc
          ELSE
           a_cpt4->code4_1 = " ", a_cpt4->desc4_1 = " "
          ENDIF
         ELSE
          a_cpt4->code4_1 = " ", a_cpt4->desc4_1 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)],5)
          >= (exam_ndx+ 3)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].
           cpt_codes,5) > 0)
           a_cpt4->code4_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 3)].cpt_codes[2].cpt4_code, a_cpt4->desc4_2 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].cpt_codes[2].cpt4_desc
          ELSE
           a_cpt4->code4_2 = " ", a_cpt4->desc4_2 = " "
          ENDIF
         ELSE
          a_cpt4->code4_2 = " ", a_cpt4->desc4_2 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)],5)
          >= (exam_ndx+ 3)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].
           cpt_codes,5) > 0)
           a_cpt4->code4_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 3)].cpt_codes[3].cpt4_code, a_cpt4->desc4_3 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].cpt_codes[3].cpt4_desc
          ELSE
           a_cpt4->code4_3 = " ", a_cpt4->desc4_3 = " "
          ENDIF
         ELSE
          a_cpt4->code4_3 = " ", a_cpt4->desc4_3 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)],5)
          >= (exam_ndx+ 3)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].
           cpt_codes,5) > 0)
           a_cpt4->code4_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 3)].cpt_codes[4].cpt4_code, a_cpt4->desc4_4 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].cpt_codes[4].cpt4_desc
          ELSE
           a_cpt4->code4_4 = " ", a_cpt4->desc4_4 = " "
          ENDIF
         ELSE
          a_cpt4->code4_4 = " ", a_cpt4->desc4_4 = " "
         ENDIF
        ELSE
         a_cpt4->code4_1 = " ", a_cpt4->code4_2 = " ", a_cpt4->code4_3 = " ",
         a_cpt4->code4_4 = " ", a_cpt4->desc4_1 = " ", a_cpt4->desc4_2 = " ",
         a_cpt4->desc4_3 = " ", a_cpt4->desc4_4 = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 4)
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)],5)
          >= (exam_ndx+ 4)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].
           cpt_codes,5) > 0)
           a_cpt4->code5_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 4)].cpt_codes[1].cpt4_code, a_cpt4->desc5_1 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].cpt_codes[1].cpt4_desc
          ELSE
           a_cpt4->code5_1 = " ", a_cpt4->desc5_1 = " "
          ENDIF
         ELSE
          a_cpt4->code5_1 = " ", a_cpt4->desc5_1 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)],5)
          >= (exam_ndx+ 4)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].
           cpt_codes,5) > 0)
           a_cpt4->code5_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 4)].cpt_codes[2].cpt4_code, a_cpt4->desc5_2 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].cpt_codes[2].cpt4_desc
          ELSE
           a_cpt4->code5_2 = " ", a_cpt4->desc5_2 = " "
          ENDIF
         ELSE
          a_cpt4->code5_2 = " ", a_cpt4->desc5_2 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)],5)
          >= (exam_ndx+ 4)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].
           cpt_codes,5) > 0)
           a_cpt4->code5_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 4)].cpt_codes[3].cpt4_code, a_cpt4->desc5_3 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].cpt_codes[3].cpt4_desc
          ELSE
           a_cpt4->code5_3 = " ", a_cpt4->desc5_3 = " "
          ENDIF
         ELSE
          a_cpt4->code5_3 = " ", a_cpt4->desc5_3 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)],5)
          >= (exam_ndx+ 4)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].
           cpt_codes,5) > 0)
           a_cpt4->code5_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 4)].cpt_codes[4].cpt4_code, a_cpt4->desc5_4 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].cpt_codes[4].cpt4_desc
          ELSE
           a_cpt4->code5_4 = " ", a_cpt4->desc5_4 = " "
          ENDIF
         ELSE
          a_cpt4->code5_4 = " ", a_cpt4->desc5_4 = " "
         ENDIF
        ELSE
         a_cpt4->code5_1 = " ", a_cpt4->code5_2 = " ", a_cpt4->code5_3 = " ",
         a_cpt4->code5_4 = " ", a_cpt4->desc5_1 = " ", a_cpt4->desc5_2 = " ",
         a_cpt4->desc5_3 = " ", a_cpt4->desc5_4 = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 5)
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)],5)
          >= (exam_ndx+ 5)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].
           cpt_codes,5) > 0)
           a_cpt4->code6_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 5)].cpt_codes[1].cpt4_code, a_cpt4->desc6_1 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].cpt_codes[1].cpt4_desc
          ELSE
           a_cpt4->code6_1 = " ", a_cpt4->desc6_1 = " "
          ENDIF
         ELSE
          a_cpt4->code6_1 = " ", a_cpt4->desc6_1 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)],5)
          >= (exam_ndx+ 5)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].
           cpt_codes,5) > 0)
           a_cpt4->code6_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 5)].cpt_codes[2].cpt4_code, a_cpt4->desc6_2 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].cpt_codes[2].cpt4_desc
          ELSE
           a_cpt4->code6_2 = " ", a_cpt4->desc6_2 = " "
          ENDIF
         ELSE
          a_cpt4->code6_2 = " ", a_cpt4->desc6_2 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)],5)
          >= (exam_ndx+ 5)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].
           cpt_codes,5) > 0)
           a_cpt4->code6_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 5)].cpt_codes[3].cpt4_code, a_cpt4->desc6_3 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].cpt_codes[3].cpt4_desc
          ELSE
           a_cpt4->code6_3 = " ", a_cpt4->desc6_3 = " "
          ENDIF
         ELSE
          a_cpt4->code6_3 = " ", a_cpt4->desc6_3 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)],5)
          >= (exam_ndx+ 5)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].
           cpt_codes,5) > 0)
           a_cpt4->code6_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 5)].cpt_codes[4].cpt4_code, a_cpt4->desc6_4 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].cpt_codes[4].cpt4_desc
          ELSE
           a_cpt4->code6_4 = " ", a_cpt4->desc6_4 = " "
          ENDIF
         ELSE
          a_cpt4->code6_4 = " ", a_cpt4->desc6_4 = " "
         ENDIF
        ELSE
         a_cpt4->code6_1 = " ", a_cpt4->code6_2 = " ", a_cpt4->code6_3 = " ",
         a_cpt4->code6_4 = " ", a_cpt4->desc6_1 = " ", a_cpt4->desc6_2 = " ",
         a_cpt4->desc6_3 = " ", a_cpt4->desc6_4 = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 6)
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)],5)
          >= (exam_ndx+ 6)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].
           cpt_codes,5) > 0)
           a_cpt4->code7_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 6)].cpt_codes[1].cpt4_code, a_cpt4->desc7_1 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].cpt_codes[1].cpt4_desc
          ELSE
           a_cpt4->code7_1 = " ", a_cpt4->desc7_1 = " "
          ENDIF
         ELSE
          a_cpt4->code7_1 = " ", a_cpt4->desc7_1 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)],5)
          >= (exam_ndx+ 6)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].
           cpt_codes,5) > 0)
           a_cpt4->code7_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 6)].cpt_codes[2].cpt4_code, a_cpt4->desc7_2 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].cpt_codes[2].cpt4_desc
          ELSE
           a_cpt4->code7_2 = " ", a_cpt4->desc7_2 = " "
          ENDIF
         ELSE
          a_cpt4->code7_2 = " ", a_cpt4->desc7_2 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)],5)
          >= (exam_ndx+ 6)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].
           cpt_codes,5) > 0)
           a_cpt4->code7_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 6)].cpt_codes[3].cpt4_code, a_cpt4->desc7_3 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].cpt_codes[3].cpt4_desc
          ELSE
           a_cpt4->code7_3 = " ", a_cpt4->desc7_3 = " "
          ENDIF
         ELSE
          a_cpt4->code7_3 = " ", a_cpt4->desc7_3 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)],5)
          >= (exam_ndx+ 6)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].
           cpt_codes,5) > 0)
           a_cpt4->code7_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 6)].cpt_codes[4].cpt4_code, a_cpt4->desc7_4 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].cpt_codes[4].cpt4_desc
          ELSE
           a_cpt4->code7_4 = " ", a_cpt4->desc7_4 = " "
          ENDIF
         ELSE
          a_cpt4->code7_4 = " ", a_cpt4->desc7_4 = " "
         ENDIF
        ELSE
         a_cpt4->code7_1 = " ", a_cpt4->code7_2 = " ", a_cpt4->code7_3 = " ",
         a_cpt4->code7_4 = " ", a_cpt4->desc7_1 = " ", a_cpt4->desc7_2 = " ",
         a_cpt4->desc7_3 = " ", a_cpt4->desc7_4 = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 7)
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)],5)
          >= (exam_ndx+ 7)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].
           cpt_codes,5) > 0)
           a_cpt4->code8_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 7)].cpt_codes[1].cpt4_code, a_cpt4->desc8_1 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].cpt_codes[1].cpt4_desc
          ELSE
           a_cpt4->code8_1 = " ", a_cpt4->desc8_1 = " "
          ENDIF
         ELSE
          a_cpt4->code8_1 = " ", a_cpt4->desc8_1 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)],5)
          >= (exam_ndx+ 7)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].
           cpt_codes,5) > 0)
           a_cpt4->code8_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 7)].cpt_codes[2].cpt4_code, a_cpt4->desc8_2 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].cpt_codes[2].cpt4_desc
          ELSE
           a_cpt4->code8_2 = " ", a_cpt4->desc8_2 = " "
          ENDIF
         ELSE
          a_cpt4->code8_2 = " ", a_cpt4->desc8_2 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)],5)
          >= (exam_ndx+ 7)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].
           cpt_codes,5) > 0)
           a_cpt4->code8_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 7)].cpt_codes[3].cpt4_code, a_cpt4->desc8_3 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].cpt_codes[3].cpt4_desc
          ELSE
           a_cpt4->code8_3 = " ", a_cpt4->desc8_3 = " "
          ENDIF
         ELSE
          a_cpt4->code8_3 = " ", a_cpt4->desc8_3 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)],5)
          >= (exam_ndx+ 7)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].
           cpt_codes,5) > 0)
           a_cpt4->code8_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 7)].cpt_codes[4].cpt4_code, a_cpt4->desc8_4 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].cpt_codes[4].cpt4_desc
          ELSE
           a_cpt4->code8_4 = " ", a_cpt4->desc8_4 = " "
          ENDIF
         ELSE
          a_cpt4->code8_4 = " ", a_cpt4->desc8_4 = " "
         ENDIF
        ELSE
         a_cpt4->code8_1 = " ", a_cpt4->code8_2 = " ", a_cpt4->code8_3 = " ",
         a_cpt4->code8_4 = " ", a_cpt4->desc8_1 = " ", a_cpt4->desc8_2 = " ",
         a_cpt4->desc8_3 = " ", a_cpt4->desc8_4 = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 8)
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)],5)
          >= (exam_ndx+ 8)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].
           cpt_codes,5) > 0)
           a_cpt4->code9_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 8)].cpt_codes[1].cpt4_code, a_cpt4->desc9_1 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].cpt_codes[1].cpt4_desc
          ELSE
           a_cpt4->code9_1 = " ", a_cpt4->desc9_1 = " "
          ENDIF
         ELSE
          a_cpt4->code9_1 = " ", a_cpt4->desc9_1 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)],5)
          >= (exam_ndx+ 8)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].
           cpt_codes,5) > 0)
           a_cpt4->code9_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 8)].cpt_codes[2].cpt4_code, a_cpt4->desc9_2 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].cpt_codes[2].cpt4_desc
          ELSE
           a_cpt4->code9_2 = " ", a_cpt4->desc9_2 = " "
          ENDIF
         ELSE
          a_cpt4->code9_2 = " ", a_cpt4->desc9_2 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)],5)
          >= (exam_ndx+ 8)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].
           cpt_codes,5) > 0)
           a_cpt4->code9_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 8)].cpt_codes[3].cpt4_code, a_cpt4->desc9_3 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].cpt_codes[3].cpt4_desc
          ELSE
           a_cpt4->code9_3 = " ", a_cpt4->desc9_3 = " "
          ENDIF
         ELSE
          a_cpt4->code9_3 = " ", a_cpt4->desc9_3 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)],5)
          >= (exam_ndx+ 8)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].
           cpt_codes,5) > 0)
           a_cpt4->code9_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 8)].cpt_codes[4].cpt4_code, a_cpt4->desc9_4 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].cpt_codes[4].cpt4_desc
          ELSE
           a_cpt4->code9_4 = " ", a_cpt4->desc9_4 = " "
          ENDIF
         ELSE
          a_cpt4->code9_4 = " ", a_cpt4->desc9_4 = " "
         ENDIF
        ELSE
         a_cpt4->code9_1 = " ", a_cpt4->code9_2 = " ", a_cpt4->code9_3 = " ",
         a_cpt4->code9_4 = " ", a_cpt4->desc9_1 = " ", a_cpt4->desc9_2 = " ",
         a_cpt4->desc9_3 = " ", a_cpt4->desc9_4 = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 9)
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)],5)
          >= (exam_ndx+ 9)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].
           cpt_codes,5) > 0)
           a_cpt4->code10_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 9)].cpt_codes[1].cpt4_code, a_cpt4->desc10_1 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].cpt_codes[1].cpt4_desc
          ELSE
           a_cpt4->code10_1 = " ", a_cpt4->desc10_1 = " "
          ENDIF
         ELSE
          a_cpt4->code10_1 = " ", a_cpt4->desc10_1 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)],5)
          >= (exam_ndx+ 9)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].
           cpt_codes,5) > 0)
           a_cpt4->code10_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 9)].cpt_codes[2].cpt4_code, a_cpt4->desc10_2 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].cpt_codes[2].cpt4_desc
          ELSE
           a_cpt4->code10_2 = " ", a_cpt4->desc10_2 = " "
          ENDIF
         ELSE
          a_cpt4->code10_2 = " ", a_cpt4->desc10_2 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)],5)
          >= (exam_ndx+ 9)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].
           cpt_codes,5) > 0)
           a_cpt4->code10_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 9)].cpt_codes[3].cpt4_code, a_cpt4->desc10_3 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].cpt_codes[3].cpt4_desc
          ELSE
           a_cpt4->code10_3 = " ", a_cpt4->desc10_3 = " "
          ENDIF
         ELSE
          a_cpt4->code10_3 = " ", a_cpt4->desc10_3 = " "
         ENDIF
         IF ((size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)],5)
          >= (exam_ndx+ 9)))
          IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].
           cpt_codes,5) > 0)
           a_cpt4->code10_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
           exam_ndx+ 9)].cpt_codes[4].cpt4_code, a_cpt4->desc10_4 = data->req[req_ndx].sections[
           sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].cpt_codes[4].cpt4_desc
          ELSE
           a_cpt4->code10_4 = " ", a_cpt4->desc10_4 = " "
          ENDIF
         ELSE
          a_cpt4->code10_4 = " ", a_cpt4->desc10_4 = " "
         ENDIF
        ELSE
         a_cpt4->code10_1 = " ", a_cpt4->code10_2 = " ", a_cpt4->code10_3 = " ",
         a_cpt4->code10_4 = " ", a_cpt4->desc10_1 = " ", a_cpt4->desc10_2 = " ",
         a_cpt4->desc10_3 = " ", a_cpt4->desc10_4 = " "
        ENDIF
        CALL echo("****************START OF DETAIL DATA********************"), cnt = size(data->req[
         req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].order_detail_array,5), row + 1,
        cndx = 0
        FOR (c = 1 TO cnt)
          IF (trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[c].oe_field_meaning)=iv)
           cndx = c, c = (cnt+ 1)
          ENDIF
        ENDFOR
        IF (cndx > 0)
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[cndx].oe_field_display_value)) > 0)
          a_detail->iv = trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[cndx].oe_field_display_value)
         ELSE
          a_detail->iv = " "
         ENDIF
        ELSE
         a_detail->iv = " "
        ENDIF
        cnt = size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
         order_detail_array,5), row + 1, cndx = 0
        FOR (c = 1 TO cnt)
          IF (trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[c].oe_field_meaning)=o2)
           cndx = c, c = (cnt+ 1)
          ENDIF
        ENDFOR
        IF (cndx > 0)
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[cndx].oe_field_display_value)) > 0)
          a_detail->o2 = trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[cndx].oe_field_display_value)
         ELSE
          a_detail->o2 = " "
         ENDIF
        ELSE
         a_detail->o2 = " "
        ENDIF
        cnt = size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
         order_detail_array,5), row + 1, cndx = 0
        FOR (c = 1 TO cnt)
          IF (trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[c].oe_field_meaning)=preg)
           cndx = c, c = (cnt+ 1)
          ENDIF
        ENDFOR
        IF (cndx > 0)
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[cndx].oe_field_display_value)) > 0)
          a_detail->preg = trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[cndx].oe_field_display_value)
         ELSE
          a_detail->preg = " "
         ENDIF
        ELSE
         a_detail->preg = " "
        ENDIF
        cnt = size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
         order_detail_array,5), row + 1, cndx = 0
        FOR (c = 1 TO cnt)
          IF (trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[c].oe_field_meaning)=isolation)
           cndx = c, c = (cnt+ 1)
          ENDIF
        ENDFOR
        IF (cndx > 0)
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[cndx].oe_field_display_value)) > 0)
          a_detail->iso = trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[cndx].oe_field_display_value)
         ELSE
          a_detail->iso = " "
         ENDIF
        ELSE
         a_detail->iso = " "
        ENDIF
        cnt = size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
         order_detail_array,5), row + 1, cndx = 0
        FOR (c = 1 TO cnt)
          IF (trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[c].oe_field_meaning)=lnmp)
           cndx = c, c = (cnt+ 1)
          ENDIF
        ENDFOR
        IF (cndx > 0)
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[cndx].oe_field_display_value)) > 0)
          a_detail->lmp = trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[cndx].oe_field_display_value)
         ELSE
          a_detail->lmp = " "
         ENDIF
        ELSE
         a_detail->lmp = " "
        ENDIF
        cnt = size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         order_detail_array,5), row + 1, cndx = 0
        FOR (c = 1 TO cnt)
          IF (trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           order_detail_array[c].oe_field_meaning)=comment1)
           cndx = c, c = (cnt+ 1)
          ENDIF
        ENDFOR
        IF (cndx > 0)
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           order_detail_array[cndx].oe_field_display_value)) > 0)
          a_detail->comment_type1 = trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].
           for_this_page[exam_ndx].order_detail_array[cndx].oe_field_display_value)
         ELSE
          a_detail->comment_type1 = " "
         ENDIF
        ELSE
         a_detail->comment_type1 = " "
        ENDIF
        cnt = size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         order_detail_array,5), row + 1, cndx = 0
        FOR (c = 1 TO cnt)
          IF (trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           order_detail_array[c].oe_field_meaning)=comment2)
           cndx = c, c = (cnt+ 1)
          ENDIF
        ENDFOR
        IF (cndx > 0)
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           order_detail_array[cndx].oe_field_display_value)) > 0)
          a_detail->comment_type2 = trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].
           for_this_page[exam_ndx].order_detail_array[cndx].oe_field_display_value)
         ELSE
          a_detail->comment_type2 = " "
         ENDIF
        ELSE
         a_detail->comment_type2 = " "
        ENDIF
        cnt = size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         order_detail_array,5), row + 1, cndx = 0
        FOR (c = 1 TO cnt)
          IF (trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           order_detail_array[c].oe_field_meaning)=commenttext1)
           cndx = c, c = (cnt+ 1)
          ENDIF
        ENDFOR
        IF (cndx > 0)
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           order_detail_array[cndx].oe_field_display_value)) > 0)
          a_detail->comment_text1 = trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].
           for_this_page[exam_ndx].order_detail_array[cndx].oe_field_display_value)
         ELSE
          a_detail->comment_text1 = " "
         ENDIF
        ELSE
         a_detail->comment_text1 = " "
        ENDIF
        cnt = size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         order_detail_array,5), row + 1, cndx = 0
        FOR (c = 1 TO cnt)
          IF (trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           order_detail_array[c].oe_field_meaning)=commenttext2)
           cndx = c, c = (cnt+ 1)
          ENDIF
        ENDFOR
        IF (cndx > 0)
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           order_detail_array[cndx].oe_field_display_value)) > 0)
          a_detail->comment_text2 = trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].
           for_this_page[exam_ndx].order_detail_array[cndx].oe_field_display_value)
         ELSE
          a_detail->comment_text2 = " "
         ENDIF
        ELSE
         a_detail->comment_text2 = " "
        ENDIF
        IF (detail1 != "DETAIL1")
         cnt = size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
          order_detail_array,5), row + 1, cndx = 0
         FOR (c = 1 TO cnt)
           IF (trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
            order_detail_array[c].oe_field_meaning)=detail1
            AND (data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[c].used_ind=0))
            cndx = c, data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
            order_detail_array[c].used_ind = 1, c = (cnt+ 1)
           ENDIF
         ENDFOR
         IF (cndx > 0)
          IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
            order_detail_array[cndx].oe_field_display_value)) > 0)
           a_detail->detail1 = trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
            1].order_detail_array[cndx].oe_field_display_value)
          ELSE
           a_detail->detail1 = " "
          ENDIF
         ELSE
          a_detail->detail1 = " "
         ENDIF
        ENDIF
        IF (detail2 != "DETAIL2")
         cnt = size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
          order_detail_array,5), row + 1, cndx = 0
         FOR (c = 1 TO cnt)
           IF (trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
            order_detail_array[c].oe_field_meaning)=detail2
            AND (data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[c].used_ind=0))
            cndx = c, data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
            order_detail_array[c].used_ind = 1, c = (cnt+ 1)
           ENDIF
         ENDFOR
         IF (cndx > 0)
          IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
            order_detail_array[cndx].oe_field_display_value)) > 0)
           a_detail->detail2 = trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
            1].order_detail_array[cndx].oe_field_display_value)
          ELSE
           a_detail->detail2 = " "
          ENDIF
         ELSE
          a_detail->detail2 = " "
         ENDIF
        ENDIF
        IF (detail3 != "DETAIL3")
         cnt = size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
          order_detail_array,5), row + 1, cndx = 0
         FOR (c = 1 TO cnt)
           IF (trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
            order_detail_array[c].oe_field_meaning)=detail3
            AND (data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[c].used_ind=0))
            cndx = c, data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
            order_detail_array[c].used_ind = 1, c = (cnt+ 1)
           ENDIF
         ENDFOR
         IF (cndx > 0)
          IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
            order_detail_array[cndx].oe_field_display_value)) > 0)
           a_detail->detail3 = trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
            1].order_detail_array[cndx].oe_field_display_value)
          ELSE
           a_detail->detail3 = " "
          ENDIF
         ELSE
          a_detail->detail3 = " "
         ENDIF
        ENDIF
        IF (detail4 != "DETAIL4")
         cnt = size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
          order_detail_array,5), row + 1, cndx = 0
         FOR (c = 1 TO cnt)
           IF (trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
            order_detail_array[c].oe_field_meaning)=detail4
            AND (data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[c].used_ind=0))
            cndx = c, data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
            order_detail_array[c].used_ind = 1, c = (cnt+ 1)
           ENDIF
         ENDFOR
         IF (cndx > 0)
          IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
            order_detail_array[cndx].oe_field_display_value)) > 0)
           a_detail->detail4 = trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
            1].order_detail_array[cndx].oe_field_display_value)
          ELSE
           a_detail->detail4 = " "
          ENDIF
         ELSE
          a_detail->detail4 = " "
         ENDIF
        ENDIF
        IF (detail5 != "DETAIL5")
         cnt = size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
          order_detail_array,5), row + 1, cndx = 0
         FOR (c = 1 TO cnt)
           IF (trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
            order_detail_array[c].oe_field_meaning)=detail5
            AND (data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[c].used_ind=0))
            cndx = c, data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
            order_detail_array[c].used_ind = 1, c = (cnt+ 1)
           ENDIF
         ENDFOR
         IF (cndx > 0)
          IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
            order_detail_array[cndx].oe_field_display_value)) > 0)
           a_detail->detail5 = trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
            1].order_detail_array[cndx].oe_field_display_value)
          ELSE
           a_detail->detail5 = " "
          ENDIF
         ELSE
          a_detail->detail5 = " "
         ENDIF
        ENDIF
        IF (detail6 > 0)
         cnt = size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
          order_detail_array,5), row + 1, cndx = 0
         FOR (c = 1 TO cnt)
           IF ((data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[c].oe_field_id=detail6)
            AND (data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[c].used_ind=0))
            cndx = c, data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
            order_detail_array[c].used_ind = 1, c = (cnt+ 1)
           ENDIF
         ENDFOR
         IF (cndx > 0)
          IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
            order_detail_array[cndx].oe_field_display_value)) > 0)
           a_detail->detail6 = trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
            1].order_detail_array[cndx].oe_field_display_value)
          ELSE
           a_detail->detail6 = " "
          ENDIF
         ELSE
          a_detail->detail6 = " "
         ENDIF
        ENDIF
        IF (detail7 > 0)
         cnt = size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
          order_detail_array,5), row + 1, cndx = 0
         FOR (c = 1 TO cnt)
           IF ((data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[c].oe_field_id=detail7)
            AND (data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[c].used_ind=0))
            cndx = c, data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
            order_detail_array[c].used_ind = 1, c = (cnt+ 1)
           ENDIF
         ENDFOR
         IF (cndx > 0)
          IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
            order_detail_array[cndx].oe_field_display_value)) > 0)
           a_detail->detail7 = trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
            1].order_detail_array[cndx].oe_field_display_value)
          ELSE
           a_detail->detail7 = " "
          ENDIF
         ELSE
          a_detail->detail7 = " "
         ENDIF
        ENDIF
        IF (detail8 > 0)
         cnt = size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
          order_detail_array,5), row + 1, cndx = 0
         FOR (c = 1 TO cnt)
           IF ((data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[c].oe_field_id=detail8)
            AND (data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[c].used_ind=0))
            cndx = c, data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
            order_detail_array[c].used_ind = 1, c = (cnt+ 1)
           ENDIF
         ENDFOR
         IF (cndx > 0)
          IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
            order_detail_array[cndx].oe_field_display_value)) > 0)
           a_detail->detail8 = trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
            1].order_detail_array[cndx].oe_field_display_value)
          ELSE
           a_detail->detail8 = " "
          ENDIF
         ELSE
          a_detail->detail8 = " "
         ENDIF
        ENDIF
        IF (detail9 > 0)
         cnt = size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
          order_detail_array,5), row + 1, cndx = 0
         FOR (c = 1 TO cnt)
           IF ((data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[c].oe_field_id=detail9)
            AND (data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[c].used_ind=0))
            cndx = c, data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
            order_detail_array[c].used_ind = 1, c = (cnt+ 1)
           ENDIF
         ENDFOR
         IF (cndx > 0)
          IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
            order_detail_array[cndx].oe_field_display_value)) > 0)
           a_detail->detail9 = trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
            1].order_detail_array[cndx].oe_field_display_value)
          ELSE
           a_detail->detail9 = " "
          ENDIF
         ELSE
          a_detail->detail9 = " "
         ENDIF
        ENDIF
        IF (detail10 > 0)
         cnt = size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
          order_detail_array,5), row + 1, cndx = 0
         FOR (c = 1 TO cnt)
           IF ((data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[c].oe_field_id=detail10)
            AND (data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
           order_detail_array[c].used_ind=0))
            cndx = c, data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
            order_detail_array[c].used_ind = 1, c = (cnt+ 1)
           ENDIF
         ENDFOR
         IF (cndx > 0)
          IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[1].
            order_detail_array[cndx].oe_field_display_value)) > 0)
           a_detail->detail10 = trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].
            for_this_page[1].order_detail_array[cndx].oe_field_display_value)
          ELSE
           a_detail->detail10 = " "
          ENDIF
         ELSE
          a_detail->detail10 = " "
         ENDIF
        ENDIF
        CALL echo("****************START OF EXAM DATA********************")
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 0)
         a_exam->exam_name_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
         exam_ndx].exam_name, a_exam->order_date_1 = cnvtdatetime(data->req[req_ndx].sections[
          sect_ndx].exam_data[x].for_this_page[exam_ndx].order_dt_tm), a_exam->order_time_1 =
         cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
          order_dt_tm),
         a_exam->rqst_date_1 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].request_dt_tm), a_exam->rqst_time_1 = cnvtdatetime(data->req[
          req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].request_dt_tm), a_exam->
         start_date_1 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].start_dt_tm),
         a_exam->start_time_1 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].start_dt_tm)
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           activity_subtype_disp)) > 0)
          a_exam->exam_section_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
          exam_ndx].activity_subtype_disp
         ELSE
          a_exam->exam_section_1 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           reason_for_exam)) > 0)
          a_exam->reason_for_exam_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].reason_for_exam
         ELSE
          a_exam->reason_for_exam_1 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           special_instructions)) > 0)
          a_exam->special_instr_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
          exam_ndx].special_instructions
         ELSE
          a_exam->special_instr_1 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           order_comment_chartable)) > 0)
          a_exam->comments_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
          exam_ndx].order_comment_chartable
         ELSE
          a_exam->comments_1 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           accession)) > 0)
          a_exam->accession = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
          exam_ndx].accession, a_exam->bc_acc_nbr = concat("*",trim(cnvtalphanum(a_exam->accession)),
           "*"),
          CALL echo(build("bc_accession:",a_exam->bc_acc_nbr))
         ELSE
          a_exam->accession = " ", a_exam->bc_acc_nbr = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           priority)) > 0)
          a_exam->priority_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
          exam_ndx].priority
         ELSE
          a_exam->priority_1 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           transport_mode)) > 0)
          a_exam->transport_mode_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].transport_mode
         ELSE
          a_exam->transport_mode_1 = " "
         ENDIF
         a_exam->order_by_id_1 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].order_by_prsnl_id,15,0,l), a_exam->order_by_name_1 = data->req[
         req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].order_by_prsnl_name, a_exam
         ->order_by_user_name_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
         exam_ndx].order_by_prsnl_username
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           exam_room_disp)) > 0)
          a_exam->exam_room_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
          exam_ndx].exam_room_disp
         ELSE
          a_exam->exam_room_1 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           ord_loc_disp)) > 0)
          a_exam->order_location_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].ord_loc_disp
         ELSE
          a_exam->order_location_1 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           ord_loc_phone)) > 0)
          a_exam->order_loc_phone_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].ord_loc_phone
         ELSE
          a_exam->order_loc_phone_1 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 1)
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)
           ].exam_name)) > 0)
          a_exam->exam_name_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 1)].exam_name
         ELSE
          a_exam->exam_name_2 = " "
         ENDIF
         a_exam->order_date_2 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 1)].order_dt_tm), a_exam->order_time_2 = cnvtdatetime(data->req[
          req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].order_dt_tm), a_exam
         ->rqst_date_2 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 1)].request_dt_tm),
         a_exam->rqst_time_2 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 1)].request_dt_tm), a_exam->start_date_2 = cnvtdatetime(data->req[
          req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].start_dt_tm), a_exam
         ->start_time_2 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 1)].start_dt_tm)
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)
           ].activity_subtype_disp)) > 0)
          a_exam->exam_section_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 1)].activity_subtype_disp
         ELSE
          a_exam->exam_section_2 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)
           ].reason_for_exam)) > 0)
          a_exam->reason_for_exam_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 1)].reason_for_exam
         ELSE
          a_exam->reason_for_exam_2 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)
           ].special_instructions)) > 0)
          a_exam->special_instr_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
          (exam_ndx+ 1)].special_instructions
         ELSE
          a_exam->special_instr_2 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)
           ].priority)) > 0)
          a_exam->priority_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 1)].priority
         ELSE
          a_exam->priority_2 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)
           ].transport_mode)) > 0)
          a_exam->transport_mode_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 1)].transport_mode
         ELSE
          a_exam->transport_mode_2 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_id_2 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
           for_this_page[(exam_ndx+ 1)].order_by_prsnl_id,15,0,l)
         ELSE
          a_exam->order_by_id_2 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_name_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
          (exam_ndx+ 1)].order_by_prsnl_name
         ELSE
          a_exam->order_by_name_2 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_user_name_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 1)].order_by_prsnl_username
         ELSE
          a_exam->order_by_user_name_2 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)
           ].exam_room_disp)) > 0)
          a_exam->exam_room_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 1)].exam_room_disp
         ELSE
          a_exam->exam_room_2 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)
           ].ord_loc_disp)) > 0)
          a_exam->order_location_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 1)].ord_loc_disp
         ELSE
          a_exam->order_location_2 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)
           ].ord_loc_phone)) > 0)
          a_exam->order_loc_phone_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 1)].ord_loc_phone
         ELSE
          a_exam->order_loc_phone_2 = " "
         ENDIF
        ELSE
         a_exam->exam_name_2 = " ", a_exam->exam_section_2 = " ", a_exam->order_date_2 = null,
         a_exam->order_time_2 = null, a_exam->rqst_date_2 = null, a_exam->rqst_time_2 = null,
         a_exam->start_date_2 = null, a_exam->start_time_2 = null, a_exam->reason_for_exam_2 = " ",
         a_exam->special_instr_2 = " ", a_exam->priority_2 = " ", a_exam->transport_mode_2 = " ",
         a_exam->order_by_id_2 = " ", a_exam->order_by_name_2 = " ", a_exam->order_by_user_name_2 =
         " ",
         a_exam->exam_room_2 = " ", a_exam->order_location_2 = " ", a_exam->order_loc_phone_2 = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 2)
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)
           ].exam_name)) > 0)
          a_exam->exam_name_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 2)].exam_name
         ELSE
          a_exam->exam_name_3 = " "
         ENDIF
         a_exam->order_date_3 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 2)].order_dt_tm), a_exam->order_time_3 = cnvtdatetime(data->req[
          req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].order_dt_tm), a_exam
         ->rqst_date_3 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 2)].request_dt_tm),
         a_exam->rqst_time_3 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 2)].request_dt_tm), a_exam->start_date_3 = cnvtdatetime(data->req[
          req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].start_dt_tm), a_exam
         ->start_time_3 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 2)].start_dt_tm)
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)
           ].activity_subtype_disp)) > 0)
          a_exam->exam_section_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 2)].activity_subtype_disp
         ELSE
          a_exam->exam_section_3 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)
           ].reason_for_exam)) > 0)
          a_exam->reason_for_exam_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 2)].reason_for_exam
         ELSE
          a_exam->reason_for_exam_3 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)
           ].special_instructions)) > 0)
          a_exam->special_instr_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
          (exam_ndx+ 2)].special_instructions
         ELSE
          a_exam->special_instr_3 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)
           ].priority)) > 0)
          a_exam->priority_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 2)].priority
         ELSE
          a_exam->priority_3 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)
           ].transport_mode)) > 0)
          a_exam->transport_mode_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 2)].transport_mode
         ELSE
          a_exam->transport_mode_3 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_id_3 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
           for_this_page[(exam_ndx+ 2)].order_by_prsnl_id,15,0,l)
         ELSE
          a_exam->order_by_id_3 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_name_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
          (exam_ndx+ 2)].order_by_prsnl_name
         ELSE
          a_exam->order_by_name_3 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_user_name_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 2)].order_by_prsnl_username
         ELSE
          a_exam->order_by_user_name_3 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)
           ].exam_room_disp)) > 0)
          a_exam->exam_room_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 2)].exam_room_disp
         ELSE
          a_exam->exam_room_3 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)
           ].ord_loc_disp)) > 0)
          a_exam->order_location_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 2)].ord_loc_disp
         ELSE
          a_exam->order_location_3 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)
           ].ord_loc_phone)) > 0)
          a_exam->order_loc_phone_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 2)].ord_loc_phone
         ELSE
          a_exam->order_loc_phone_3 = " "
         ENDIF
        ELSE
         a_exam->exam_name_3 = " ", a_exam->exam_section_3 = " ", a_exam->order_date_3 = null,
         a_exam->order_time_3 = null, a_exam->rqst_date_3 = null, a_exam->rqst_time_3 = null,
         a_exam->start_date_3 = null, a_exam->start_time_3 = null, a_exam->reason_for_exam_3 = " ",
         a_exam->special_instr_3 = " ", a_exam->priority_3 = " ", a_exam->transport_mode_3 = " ",
         a_exam->order_by_id_3 = " ", a_exam->order_by_user_name_3 = " ", a_exam->order_by_name_3 =
         " ",
         a_exam->exam_room_3 = " ", a_exam->order_location_3 = " ", a_exam->order_loc_phone_3 = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 3)
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)
           ].exam_name)) > 0)
          a_exam->exam_name_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 3)].exam_name
         ELSE
          a_exam->exam_name_4 = " "
         ENDIF
         a_exam->order_date_4 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 3)].order_dt_tm), a_exam->order_time_4 = cnvtdatetime(data->req[
          req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].order_dt_tm), a_exam
         ->rqst_date_4 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 3)].request_dt_tm),
         a_exam->rqst_time_4 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 3)].request_dt_tm), a_exam->start_date_4 = cnvtdatetime(data->req[
          req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].start_dt_tm), a_exam
         ->start_time_4 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 3)].start_dt_tm)
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)
           ].activity_subtype_disp)) > 0)
          a_exam->exam_section_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 3)].activity_subtype_disp
         ELSE
          a_exam->exam_section_4 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)
           ].reason_for_exam)) > 0)
          a_exam->reason_for_exam_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 3)].reason_for_exam
         ELSE
          a_exam->reason_for_exam_4 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)
           ].special_instructions)) > 0)
          a_exam->special_instr_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
          (exam_ndx+ 3)].special_instructions
         ELSE
          a_exam->special_instr_4 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)
           ].priority)) > 0)
          a_exam->priority_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 3)].priority
         ELSE
          a_exam->priority_4 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)
           ].transport_mode)) > 0)
          a_exam->transport_mode_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 3)].transport_mode
         ELSE
          a_exam->transport_mode_4 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_id_4 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
           for_this_page[(exam_ndx+ 3)].order_by_prsnl_id,15,0,l)
         ELSE
          a_exam->order_by_id_4 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_name_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
          (exam_ndx+ 3)].order_by_prsnl_name
         ELSE
          a_exam->order_by_name_4 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_user_name_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 3)].order_by_prsnl_username
         ELSE
          a_exam->order_by_user_name_4 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)
           ].exam_room_disp)) > 0)
          a_exam->exam_room_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 3)].exam_room_disp
         ELSE
          a_exam->exam_room_4 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)
           ].ord_loc_disp)) > 0)
          a_exam->order_location_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 3)].ord_loc_disp
         ELSE
          a_exam->order_location_4 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)
           ].ord_loc_phone)) > 0)
          a_exam->order_loc_phone_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 3)].ord_loc_phone
         ELSE
          a_exam->order_loc_phone_4 = " "
         ENDIF
        ELSE
         a_exam->exam_name_4 = " ", a_exam->exam_section_4 = " ", a_exam->order_date_4 = null,
         a_exam->order_time_4 = null, a_exam->rqst_date_4 = null, a_exam->rqst_time_4 = null,
         a_exam->start_date_4 = null, a_exam->start_time_4 = null, a_exam->reason_for_exam_4 = " ",
         a_exam->special_instr_4 = " ", a_exam->priority_4 = " ", a_exam->transport_mode_4 = " ",
         a_exam->order_by_id_4 = " ", a_exam->order_by_user_name_4 = " ", a_exam->order_by_name_4 =
         " ",
         a_exam->exam_room_4 = " ", a_exam->order_location_4 = " ", a_exam->order_loc_phone_4 = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 4)
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)
           ].exam_name)) > 0)
          a_exam->exam_name_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 4)].exam_name
         ELSE
          a_exam->exam_name_5 = " "
         ENDIF
         a_exam->order_date_5 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 4)].order_dt_tm), a_exam->order_time_5 = cnvtdatetime(data->req[
          req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].order_dt_tm), a_exam
         ->rqst_date_5 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 4)].request_dt_tm),
         a_exam->rqst_time_5 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 4)].request_dt_tm), a_exam->start_date_5 = cnvtdatetime(data->req[
          req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].start_dt_tm), a_exam
         ->start_time_5 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 4)].start_dt_tm)
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)
           ].activity_subtype_disp)) > 0)
          a_exam->exam_section_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 4)].activity_subtype_disp
         ELSE
          a_exam->exam_section_5 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)
           ].reason_for_exam)) > 0)
          a_exam->reason_for_exam_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 4)].reason_for_exam
         ELSE
          a_exam->reason_for_exam_5 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)
           ].special_instructions)) > 0)
          a_exam->special_instr_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
          (exam_ndx+ 4)].special_instructions
         ELSE
          a_exam->special_instr_5 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)
           ].priority)) > 0)
          a_exam->priority_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 4)].priority
         ELSE
          a_exam->priority_5 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)
           ].transport_mode)) > 0)
          a_exam->transport_mode_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 4)].transport_mode
         ELSE
          a_exam->transport_mode_5 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_id_5 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
           for_this_page[(exam_ndx+ 4)].order_by_prsnl_id,15,0,l)
         ELSE
          a_exam->order_by_id_5 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_name_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
          (exam_ndx+ 4)].order_by_prsnl_name
         ELSE
          a_exam->order_by_name_5 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_user_name_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 4)].order_by_prsnl_username
         ELSE
          a_exam->order_by_user_name_5 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)
           ].exam_room_disp)) > 0)
          a_exam->exam_room_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 4)].exam_room_disp
         ELSE
          a_exam->exam_room_5 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)
           ].ord_loc_disp)) > 0)
          a_exam->order_location_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 4)].ord_loc_disp
         ELSE
          a_exam->order_location_5 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)
           ].ord_loc_phone)) > 0)
          a_exam->order_loc_phone_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 4)].ord_loc_phone
         ELSE
          a_exam->order_loc_phone_5 = " "
         ENDIF
        ELSE
         a_exam->exam_name_5 = " ", a_exam->exam_section_5 = " ", a_exam->order_date_5 = null,
         a_exam->order_time_5 = null, a_exam->rqst_date_5 = null, a_exam->rqst_time_5 = null,
         a_exam->start_date_5 = null, a_exam->start_time_5 = null, a_exam->reason_for_exam_5 = " ",
         a_exam->special_instr_5 = " ", a_exam->priority_5 = " ", a_exam->transport_mode_5 = " ",
         a_exam->order_by_id_5 = " ", a_exam->order_by_name_5 = " ", a_exam->order_by_user_name_5 =
         " ",
         a_exam->exam_room_5 = " ", a_exam->order_location_5 = " ", a_exam->order_loc_phone_5 = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 5)
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)
           ].exam_name)) > 0)
          a_exam->exam_name_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 5)].exam_name
         ELSE
          a_exam->exam_name_6 = " "
         ENDIF
         a_exam->order_date_6 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 5)].order_dt_tm), a_exam->order_time_6 = cnvtdatetime(data->req[
          req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].order_dt_tm), a_exam
         ->rqst_date_6 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 5)].request_dt_tm),
         a_exam->rqst_time_6 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 5)].request_dt_tm), a_exam->start_date_6 = cnvtdatetime(data->req[
          req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].start_dt_tm), a_exam
         ->start_time_6 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 5)].start_dt_tm)
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)
           ].activity_subtype_disp)) > 0)
          a_exam->exam_section_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 5)].activity_subtype_disp
         ELSE
          a_exam->exam_section_6 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)
           ].reason_for_exam)) > 0)
          a_exam->reason_for_exam_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 5)].reason_for_exam
         ELSE
          a_exam->reason_for_exam_6 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)
           ].special_instructions)) > 0)
          a_exam->special_instr_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
          (exam_ndx+ 5)].special_instructions
         ELSE
          a_exam->special_instr_6 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)
           ].priority)) > 0)
          a_exam->priority_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 5)].priority
         ELSE
          a_exam->priority_6 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)
           ].transport_mode)) > 0)
          a_exam->transport_mode_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 5)].transport_mode
         ELSE
          a_exam->transport_mode_6 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_id_6 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
           for_this_page[(exam_ndx+ 5)].order_by_prsnl_id,15,0,l)
         ELSE
          a_exam->order_by_id_6 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_name_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
          (exam_ndx+ 5)].order_by_prsnl_name
         ELSE
          a_exam->order_by_name_6 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_user_name_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 5)].order_by_prsnl_username
         ELSE
          a_exam->order_by_user_name_6 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)
           ].exam_room_disp)) > 0)
          a_exam->exam_room_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 5)].exam_room_disp
         ELSE
          a_exam->exam_room_6 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)
           ].ord_loc_disp)) > 0)
          a_exam->order_location_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 5)].ord_loc_disp
         ELSE
          a_exam->order_location_6 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)
           ].ord_loc_phone)) > 0)
          a_exam->order_loc_phone_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 5)].ord_loc_phone
         ELSE
          a_exam->order_loc_phone_6 = " "
         ENDIF
        ELSE
         a_exam->exam_name_6 = " ", a_exam->exam_section_6 = " ", a_exam->order_date_6 = null,
         a_exam->order_time_6 = null, a_exam->rqst_date_6 = null, a_exam->rqst_time_6 = null,
         a_exam->start_date_6 = null, a_exam->start_time_6 = null, a_exam->reason_for_exam_6 = " ",
         a_exam->special_instr_6 = " ", a_exam->priority_6 = " ", a_exam->transport_mode_6 = " ",
         a_exam->order_by_id_6 = " ", a_exam->order_by_name_6 = " ", a_exam->order_by_user_name_6" ",
         a_exam->exam_room_6 = " ", a_exam->order_location_6 = " ", a_exam->order_loc_phone_6 = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 6)
         a_exam->exam_name_7 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
         exam_ndx+ 6)].exam_name, a_exam->order_date_7 = cnvtdatetime(data->req[req_ndx].sections[
          sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].order_dt_tm), a_exam->order_time_7 =
         cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)]
          .order_dt_tm),
         a_exam->rqst_date_7 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 6)].request_dt_tm), a_exam->rqst_time_7 = cnvtdatetime(data->req[
          req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].request_dt_tm),
         a_exam->start_date_7 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 6)].start_dt_tm),
         a_exam->start_time_7 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 6)].start_dt_tm)
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)
           ].activity_subtype_disp)) > 0)
          a_exam->exam_section_7 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 6)].activity_subtype_disp
         ELSE
          a_exam->exam_section_7 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)
           ].reason_for_exam)) > 0)
          a_exam->reason_for_exam_7 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 6)].reason_for_exam
         ELSE
          a_exam->reason_for_exam_7 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)
           ].special_instructions)) > 0)
          a_exam->special_instr_7 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
          (exam_ndx+ 6)].special_instructions
         ELSE
          a_exam->special_instr_7 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)
           ].priority)) > 0)
          a_exam->priority_7 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 6)].priority
         ELSE
          a_exam->priority_7 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)
           ].transport_mode)) > 0)
          a_exam->transport_mode_7 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 6)].transport_mode
         ELSE
          a_exam->transport_mode_7 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_id_7 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
           for_this_page[(exam_ndx+ 6)].order_by_prsnl_id,15,0,l)
         ELSE
          a_exam->order_by_id_7 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_name_7 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
          (exam_ndx+ 6)].order_by_prsnl_name
         ELSE
          a_exam->order_by_name_7 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_user_name_7 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 6)].order_by_prsnl_username
         ELSE
          a_exam->order_by_user_name_7 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)
           ].exam_room_disp)) > 0)
          a_exam->exam_room_7 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 6)].exam_room_disp
         ELSE
          a_exam->exam_room_7 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)
           ].ord_loc_disp)) > 0)
          a_exam->order_location_7 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 6)].ord_loc_disp
         ELSE
          a_exam->order_location_7 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)
           ].ord_loc_phone)) > 0)
          a_exam->order_loc_phone_7 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 6)].ord_loc_phone
         ELSE
          a_exam->order_loc_phone_7 = " "
         ENDIF
        ELSE
         a_exam->exam_name_7 = " ", a_exam->exam_section_7 = " ", a_exam->order_date_7 = null,
         a_exam->order_time_7 = null, a_exam->rqst_date_7 = null, a_exam->rqst_time_7 = null,
         a_exam->start_date_7 = null, a_exam->start_time_7 = null, a_exam->reason_for_exam_7 = " ",
         a_exam->special_instr_7 = " ", a_exam->priority_7 = " ", a_exam->transport_mode_7 = " ",
         a_exam->order_by_id_7 = " ", a_exam->order_by_name_7 = " ", a_exam->order_by_user_name_7 =
         " ",
         a_exam->exam_room_7 = " ", a_exam->order_location_7 = " ", a_exam->order_loc_phone_7 = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 7)
         a_exam->exam_name_8 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
         exam_ndx+ 7)].exam_name, a_exam->order_date_8 = cnvtdatetime(data->req[req_ndx].sections[
          sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].order_dt_tm), a_exam->order_time_8 =
         cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)]
          .order_dt_tm),
         a_exam->rqst_date_8 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 7)].request_dt_tm), a_exam->rqst_time_8 = cnvtdatetime(data->req[
          req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].request_dt_tm),
         a_exam->start_date_8 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 7)].start_dt_tm),
         a_exam->start_time_8 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 7)].start_dt_tm)
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)
           ].activity_subtype_disp)) > 0)
          a_exam->exam_section_8 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 7)].activity_subtype_disp
         ELSE
          a_exam->exam_section_8 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)
           ].reason_for_exam)) > 0)
          a_exam->reason_for_exam_8 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 7)].reason_for_exam
         ELSE
          a_exam->reason_for_exam_8 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)
           ].special_instructions)) > 0)
          a_exam->special_instr_8 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
          (exam_ndx+ 7)].special_instructions
         ELSE
          a_exam->special_instr_8 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)
           ].priority)) > 0)
          a_exam->priority_8 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 7)].priority
         ELSE
          a_exam->priority_8 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)
           ].transport_mode)) > 0)
          a_exam->transport_mode_8 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 7)].transport_mode
         ELSE
          a_exam->transport_mode_8 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_id_8 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
           for_this_page[(exam_ndx+ 7)].order_by_prsnl_id,15,0,l)
         ELSE
          a_exam->order_by_id_8 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_name_8 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
          (exam_ndx+ 7)].order_by_prsnl_name
         ELSE
          a_exam->order_by_name_8 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_user_name_8 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 7)].order_by_prsnl_username
         ELSE
          a_exam->order_by_user_name_8 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)
           ].exam_room_disp)) > 0)
          a_exam->exam_room_8 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 7)].exam_room_disp
         ELSE
          a_exam->exam_room_8 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)
           ].ord_loc_disp)) > 0)
          a_exam->order_location_8 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 7)].ord_loc_disp
         ELSE
          a_exam->order_location_8 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)
           ].ord_loc_phone)) > 0)
          a_exam->order_loc_phone_8 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 7)].ord_loc_phone
         ELSE
          a_exam->order_loc_phone_8 = " "
         ENDIF
        ELSE
         a_exam->exam_name_8 = " ", a_exam->exam_section_8 = " ", a_exam->order_date_8 = null,
         a_exam->order_time_8 = null, a_exam->rqst_date_8 = null, a_exam->rqst_time_8 = null,
         a_exam->start_date_8 = null, a_exam->start_time_8 = null, a_exam->reason_for_exam_8 = " ",
         a_exam->special_instr_8 = " ", a_exam->priority_8 = " ", a_exam->transport_mode_8 = " ",
         a_exam->order_by_id_8 = " ", a_exam->order_by_name_8 = " ", a_exam->order_by_user_name_8 =
         " ",
         a_exam->exam_room_8 = " ", a_exam->order_location_8 = " ", a_exam->order_loc_phone_8 = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 8)
         a_exam->exam_name_9 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
         exam_ndx+ 8)].exam_name, a_exam->order_date_9 = cnvtdatetime(data->req[req_ndx].sections[
          sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].order_dt_tm), a_exam->order_time_9 =
         cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)]
          .order_dt_tm),
         a_exam->rqst_date_9 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 8)].request_dt_tm), a_exam->rqst_time_9 = cnvtdatetime(data->req[
          req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].request_dt_tm),
         a_exam->start_date_9 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 8)].start_dt_tm),
         a_exam->start_time_9 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 8)].start_dt_tm)
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)
           ].activity_subtype_disp)) > 0)
          a_exam->exam_section_9 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 8)].activity_subtype_disp
         ELSE
          a_exam->exam_section_9 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)
           ].reason_for_exam)) > 0)
          a_exam->reason_for_exam_9 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 8)].reason_for_exam
         ELSE
          a_exam->reason_for_exam_9 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)
           ].special_instructions)) > 0)
          a_exam->special_instr_9 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
          (exam_ndx+ 8)].special_instructions
         ELSE
          a_exam->special_instr_9 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)
           ].priority)) > 0)
          a_exam->priority_9 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 8)].priority
         ELSE
          a_exam->priority_9 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)
           ].transport_mode)) > 0)
          a_exam->transport_mode_9 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 8)].transport_mode
         ELSE
          a_exam->transport_mode_9 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_id_9 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
           for_this_page[(exam_ndx+ 8)].order_by_prsnl_id,15,0,l)
         ELSE
          a_exam->order_by_id_9 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_name_9 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
          (exam_ndx+ 8)].order_by_prsnl_name
         ELSE
          a_exam->order_by_name_9 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_user_name_9 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 8)].order_by_prsnl_username
         ELSE
          a_exam->order_by_user_name_9 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)
           ].exam_room_disp)) > 0)
          a_exam->exam_room_9 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 8)].exam_room_disp
         ELSE
          a_exam->exam_room_9 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)
           ].ord_loc_disp)) > 0)
          a_exam->order_location_9 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 8)].ord_loc_disp
         ELSE
          a_exam->order_location_9 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)
           ].ord_loc_phone)) > 0)
          a_exam->order_loc_phone_9 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 8)].ord_loc_phone
         ELSE
          a_exam->order_loc_phone_9 = " "
         ENDIF
        ELSE
         a_exam->exam_name_9 = " ", a_exam->exam_section_9 = " ", a_exam->order_date_9 = null,
         a_exam->order_time_9 = null, a_exam->rqst_date_9 = null, a_exam->rqst_time_9 = null,
         a_exam->start_date_9 = null, a_exam->start_time_9 = null, a_exam->reason_for_exam_9 = " ",
         a_exam->special_instr_9 = " ", a_exam->priority_9 = " ", a_exam->transport_mode_9 = " ",
         a_exam->order_by_id_9 = " ", a_exam->order_by_name_9 = " ", a_exam->order_by_user_name_9 =
         " ",
         a_exam->exam_room_9 = " ", a_exam->order_location_9 = " ", a_exam->order_loc_phone_9 = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 9)
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)
           ].exam_name)) > 0)
          a_exam->exam_name_10 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 9)].exam_name
         ELSE
          a_exam->exam_name_10 = " "
         ENDIF
         a_exam->order_date_10 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 9)].order_dt_tm), a_exam->order_time_10 = cnvtdatetime(data->req[
          req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].order_dt_tm), a_exam
         ->rqst_date_10 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 9)].request_dt_tm),
         a_exam->rqst_time_10 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 9)].request_dt_tm), a_exam->start_date_10 = cnvtdatetime(data->
          req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].start_dt_tm),
         a_exam->start_time_10 = cnvtdatetime(data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 9)].start_dt_tm)
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)
           ].activity_subtype_disp)) > 0)
          a_exam->exam_section_10 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
          (exam_ndx+ 9)].activity_subtype_disp
         ELSE
          a_exam->exam_section_10 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)
           ].reason_for_exam)) > 0)
          a_exam->reason_for_exam_10 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 9)].reason_for_exam
         ELSE
          a_exam->reason_for_exam_10 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)
           ].special_instructions)) > 0)
          a_exam->special_instr_10 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 9)].special_instructions
         ELSE
          a_exam->special_instr_10 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)
           ].priority)) > 0)
          a_exam->priority_10 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 9)].priority
         ELSE
          a_exam->priority_10 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)
           ].transport_mode)) > 0)
          a_exam->transport_mode_10 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 9)].transport_mode
         ELSE
          a_exam->transport_mode_10 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_id_10 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
           for_this_page[(exam_ndx+ 9)].order_by_prsnl_id,15,0,l)
         ELSE
          a_exam->order_by_id_10 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_name_10 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 9)].order_by_prsnl_name
         ELSE
          a_exam->order_by_name_10 = " "
         ENDIF
         IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].
          order_by_prsnl_id) > 0)
          a_exam->order_by_user_name_10 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 9)].order_by_prsnl_username
         ELSE
          a_exam->order_by_user_name_10 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)
           ].exam_room_disp)) > 0)
          a_exam->exam_room_10 = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(
          exam_ndx+ 9)].exam_room_disp
         ELSE
          a_exam->exam_room_10 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)
           ].ord_loc_disp)) > 0)
          a_exam->order_location_10 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 9)].ord_loc_disp
         ELSE
          a_exam->order_location_10 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)
           ].ord_loc_phone)) > 0)
          a_exam->order_loc_phone_10 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[(exam_ndx+ 9)].ord_loc_phone
         ELSE
          a_exam->order_loc_phone_10 = " "
         ENDIF
        ELSE
         a_exam->exam_name_10 = " ", a_exam->exam_section_10 = " ", a_exam->order_date_10 = null,
         a_exam->order_time_10 = null, a_exam->rqst_date_10 = null, a_exam->rqst_time_10 = null,
         a_exam->start_date_10 = null, a_exam->start_time_10 = null, a_exam->reason_for_exam_10 = " ",
         a_exam->special_instr_10 = " ", a_exam->priority_10 = " ", a_exam->transport_mode_10 = " ",
         a_exam->order_by_id_10 = " ", a_exam->order_by_name_10 = " ", a_exam->order_by_user_name_10
          = " ",
         a_exam->exam_room_10 = " ", a_exam->order_location_10 = " ", a_exam->order_loc_phone_10 =
         " "
        ENDIF
        CALL echo("*****START OF ICD9 CODES DATA*****")
        IF ((size(icd9->exam,5) > data->req[req_ndx].sections[sect_ndx].nbr_of_exams_per_req))
         exam_ndx = (exam_ndx+ ((x - 1) * data->req[req_ndx].sections[sect_ndx].nbr_of_exams_per_req)
         )
        ENDIF
        stat = initrec(a_icd9)
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 0)
         IF (size(icd9->exam,5) >= exam_ndx)
          IF (size(icd9->exam[exam_ndx].code,5) > 0)
           IF ((icd9->exam[exam_ndx].code[1].value != " "))
            a_icd9->icd9_1_1 = icd9->exam[exam_ndx].code[1].value, a_icd9->icd9_1_desc_1 = icd9->
            exam[exam_ndx].code[1].desc
           ELSE
            a_icd9->icd9_1_1 = " ", a_icd9->icd9_1_desc_1 = " "
           ENDIF
          ELSE
           a_icd9->icd9_1_1 = " ", a_icd9->icd9_1_desc_1 = " "
          ENDIF
         ELSE
          a_icd9->icd9_1_1 = " ", a_icd9->icd9_1_desc_1 = " "
         ENDIF
         IF (size(icd9->exam,5) >= exam_ndx)
          IF (size(icd9->exam[exam_ndx].code,5) > 1)
           IF ((icd9->exam[exam_ndx].code[2].value != " "))
            a_icd9->icd9_1_2 = icd9->exam[exam_ndx].code[2].value, a_icd9->icd9_1_desc_2 = icd9->
            exam[exam_ndx].code[2].desc
           ELSE
            a_icd9->icd9_1_2 = " ", a_icd9->icd9_1_desc_2 = " "
           ENDIF
          ELSE
           a_icd9->icd9_1_2 = " ", a_icd9->icd9_1_desc_2 = " "
          ENDIF
         ELSE
          a_icd9->icd9_1_2 = " ", a_icd9->icd9_1_desc_2 = " "
         ENDIF
         IF (size(icd9->exam,5) >= exam_ndx)
          IF (size(icd9->exam[exam_ndx].code,5) > 2)
           IF ((icd9->exam[exam_ndx].code[3].value != " "))
            a_icd9->icd9_1_3 = icd9->exam[exam_ndx].code[3].value, a_icd9->icd9_1_desc_3 = icd9->
            exam[exam_ndx].code[3].desc
           ELSE
            a_icd9->icd9_1_3 = " ", a_icd9->icd9_1_desc_3 = " "
           ENDIF
          ELSE
           a_icd9->icd9_1_3 = " ", a_icd9->icd9_1_desc_3 = " "
          ENDIF
         ELSE
          a_icd9->icd9_1_3 = " ", a_icd9->icd9_1_desc_3 = " "
         ENDIF
         IF (size(icd9->exam,5) >= exam_ndx)
          IF (size(icd9->exam[exam_ndx].code,5) > 3)
           IF ((icd9->exam[exam_ndx].code[4].value != " "))
            a_icd9->icd9_1_4 = icd9->exam[exam_ndx].code[3].value, a_icd9->icd9_1_desc_4 = icd9->
            exam[exam_ndx].code[4].desc
           ELSE
            a_icd9->icd9_1_4 = " ", a_icd9->icd9_1_desc_4 = " "
           ENDIF
          ELSE
           a_icd9->icd9_1_4 = " ", a_icd9->icd9_1_desc_4 = " "
          ENDIF
         ELSE
          a_icd9->icd9_1_4 = " ", a_icd9->icd9_1_desc_4 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 1)
         IF ((size(icd9->exam,5) >= (exam_ndx+ 1)))
          IF (size(icd9->exam[(exam_ndx+ 1)].code,5) > 0)
           IF ((icd9->exam[(exam_ndx+ 1)].code[1].value != " "))
            a_icd9->icd9_2_1 = icd9->exam[(exam_ndx+ 1)].code[1].value, a_icd9->icd9_2_desc_1 = icd9
            ->exam[(exam_ndx+ 1)].code[1].desc
           ELSE
            a_icd9->icd9_2_1 = " ", a_icd9->icd9_2_desc_1 = " "
           ENDIF
          ELSE
           a_icd9->icd9_2_1 = " ", a_icd9->icd9_2_desc_1 = " "
          ENDIF
         ELSE
          a_icd9->icd9_2_1 = " ", a_icd9->icd9_2_desc_1 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 1)))
          IF (size(icd9->exam[(exam_ndx+ 1)].code,5) > 1)
           IF ((icd9->exam[(exam_ndx+ 1)].code[2].value != " "))
            a_icd9->icd9_2_2 = icd9->exam[(exam_ndx+ 1)].code[2].value, a_icd9->icd9_2_desc_2 = icd9
            ->exam[(exam_ndx+ 1)].code[2].desc
           ELSE
            a_icd9->icd9_2_2 = " ", a_icd9->icd9_2_desc_2 = " "
           ENDIF
          ELSE
           a_icd9->icd9_2_2 = " ", a_icd9->icd9_2_desc_2 = " "
          ENDIF
         ELSE
          a_icd9->icd9_2_2 = " ", a_icd9->icd9_2_desc_2 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 1)))
          IF (size(icd9->exam[(exam_ndx+ 1)].code,5) > 2)
           IF ((icd9->exam[(exam_ndx+ 1)].code[3].value != " "))
            a_icd9->icd9_2_3 = icd9->exam[(exam_ndx+ 1)].code[3].value, a_icd9->icd9_2_desc_3 = icd9
            ->exam[(exam_ndx+ 1)].code[3].desc
           ELSE
            a_icd9->icd9_2_3 = " ", a_icd9->icd9_2_desc_3 = " "
           ENDIF
          ELSE
           a_icd9->icd9_2_3 = " ", a_icd9->icd9_2_desc_3 = " "
          ENDIF
         ELSE
          a_icd9->icd9_2_3 = " ", a_icd9->icd9_2_desc_3 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 1)))
          IF (size(icd9->exam[(exam_ndx+ 1)].code,5) > 3)
           IF ((icd9->exam[(exam_ndx+ 1)].code[4].value != " "))
            a_icd9->icd9_2_4 = icd9->exam[(exam_ndx+ 1)].code[4].value, a_icd9->icd9_2_desc_4 = icd9
            ->exam[(exam_ndx+ 1)].code[4].desc
           ELSE
            a_icd9->icd9_2_4 = " ", a_icd9->icd9_2_desc_4 = " "
           ENDIF
          ELSE
           a_icd9->icd9_2_4 = " ", a_icd9->icd9_2_desc_4 = " "
          ENDIF
         ELSE
          a_icd9->icd9_2_4 = " ", a_icd9->icd9_2_desc_4 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 2)
         IF ((size(icd9->exam,5) >= (exam_ndx+ 2)))
          IF (size(icd9->exam[(exam_ndx+ 2)].code,5) > 0)
           IF ((icd9->exam[(exam_ndx+ 2)].code[1].value != " "))
            a_icd9->icd9_3_1 = icd9->exam[(exam_ndx+ 2)].code[1].value, a_icd9->icd9_3_desc_1 = icd9
            ->exam[(exam_ndx+ 2)].code[1].desc
           ELSE
            a_icd9->icd9_3_1 = " ", a_icd9->icd9_3_desc_1 = " "
           ENDIF
          ELSE
           a_icd9->icd9_3_1 = " ", a_icd9->icd9_3_desc_1 = " "
          ENDIF
         ELSE
          a_icd9->icd9_3_1 = " ", a_icd9->icd9_3_desc_1 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 2)))
          IF (size(icd9->exam[(exam_ndx+ 2)].code,5) > 1)
           IF ((icd9->exam[(exam_ndx+ 2)].code[2].value != " "))
            a_icd9->icd9_3_2 = icd9->exam[(exam_ndx+ 2)].code[2].value, a_icd9->icd9_3_desc_2 = icd9
            ->exam[(exam_ndx+ 2)].code[2].desc
           ELSE
            a_icd9->icd9_3_2 = " ", a_icd9->icd9_3_desc_2 = " "
           ENDIF
          ELSE
           a_icd9->icd9_3_2 = " ", a_icd9->icd9_3_desc_2 = " "
          ENDIF
         ELSE
          a_icd9->icd9_3_2 = " ", a_icd9->icd9_3_desc_2 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 2)))
          IF (size(icd9->exam[(exam_ndx+ 2)].code,5) > 2)
           IF ((icd9->exam[(exam_ndx+ 2)].code[3].value != " "))
            a_icd9->icd9_3_3 = icd9->exam[(exam_ndx+ 2)].code[3].value, a_icd9->icd9_3_desc_3 = icd9
            ->exam[(exam_ndx+ 2)].code[3].desc
           ELSE
            a_icd9->icd9_3_3 = " ", a_icd9->icd9_3_desc_3 = " "
           ENDIF
          ELSE
           a_icd9->icd9_3_3 = " ", a_icd9->icd9_3_desc_3 = " "
          ENDIF
         ELSE
          a_icd9->icd9_3_3 = " ", a_icd9->icd9_3_desc_3 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 2)))
          IF (size(icd9->exam[(exam_ndx+ 2)].code,5) > 3)
           IF ((icd9->exam[(exam_ndx+ 2)].code[4].value != " "))
            a_icd9->icd9_3_4 = icd9->exam[(exam_ndx+ 2)].code[4].value, a_icd9->icd9_3_desc_4 = icd9
            ->exam[(exam_ndx+ 2)].code[4].desc
           ELSE
            a_icd9->icd9_3_4 = " ", a_icd9->icd9_3_desc_4 = " "
           ENDIF
          ELSE
           a_icd9->icd9_3_4 = " ", a_icd9->icd9_3_desc_4 = " "
          ENDIF
         ELSE
          a_icd9->icd9_3_4 = " ", a_icd9->icd9_3_desc_4 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 3)
         IF ((size(icd9->exam,5) >= (exam_ndx+ 3)))
          IF (size(icd9->exam[(exam_ndx+ 3)].code,5) > 0)
           IF ((icd9->exam[(exam_ndx+ 3)].code[1].value != " "))
            a_icd9->icd9_4_1 = icd9->exam[(exam_ndx+ 3)].code[1].value, a_icd9->icd9_4_desc_1 = icd9
            ->exam[(exam_ndx+ 3)].code[1].desc
           ELSE
            a_icd9->icd9_4_1 = " ", a_icd9->icd9_4_desc_1 = " "
           ENDIF
          ELSE
           a_icd9->icd9_4_1 = " ", a_icd9->icd9_4_desc_1 = " "
          ENDIF
         ELSE
          a_icd9->icd9_4_1 = " ", a_icd9->icd9_4_desc_1 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 3)))
          IF (size(icd9->exam[(exam_ndx+ 3)].code,5) > 1)
           IF ((icd9->exam[(exam_ndx+ 3)].code[2].value != " "))
            a_icd9->icd9_4_2 = icd9->exam[(exam_ndx+ 3)].code[2].value, a_icd9->icd9_4_desc_2 = icd9
            ->exam[(exam_ndx+ 3)].code[2].desc
           ELSE
            a_icd9->icd9_4_2 = " ", a_icd9->icd9_4_desc_2 = " "
           ENDIF
          ELSE
           a_icd9->icd9_4_2 = " ", a_icd9->icd9_4_desc_2 = " "
          ENDIF
         ELSE
          a_icd9->icd9_4_2 = " ", a_icd9->icd9_4_desc_2 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 3)))
          IF (size(icd9->exam[(exam_ndx+ 3)].code,5) > 2)
           IF ((icd9->exam[(exam_ndx+ 3)].code[3].value != " "))
            a_icd9->icd9_4_3 = icd9->exam[(exam_ndx+ 3)].code[3].value, a_icd9->icd9_4_desc_3 = icd9
            ->exam[(exam_ndx+ 3)].code[3].desc
           ELSE
            a_icd9->icd9_4_3 = " ", a_icd9->icd9_4_desc_3 = " "
           ENDIF
          ELSE
           a_icd9->icd9_4_3 = " ", a_icd9->icd9_4_desc_3 = " "
          ENDIF
         ELSE
          a_icd9->icd9_4_3 = " ", a_icd9->icd9_4_desc_3 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 3)))
          IF (size(icd9->exam[(exam_ndx+ 3)].code,5) > 3)
           IF ((icd9->exam[(exam_ndx+ 3)].code[4].value != " "))
            a_icd9->icd9_4_4 = icd9->exam[(exam_ndx+ 3)].code[4].value, a_icd9->icd9_4_desc_4 = icd9
            ->exam[(exam_ndx+ 3)].code[4].desc
           ELSE
            a_icd9->icd9_4_4 = " ", a_icd9->icd9_4_desc_4 = " "
           ENDIF
          ELSE
           a_icd9->icd9_4_4 = " ", a_icd9->icd9_4_desc_4 = " "
          ENDIF
         ELSE
          a_icd9->icd9_4_4 = " ", a_icd9->icd9_4_desc_4 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 4)
         IF ((size(icd9->exam,5) >= (exam_ndx+ 4)))
          IF (size(icd9->exam[(exam_ndx+ 4)].code,5) > 0)
           IF ((icd9->exam[(exam_ndx+ 4)].code[1].value != " "))
            a_icd9->icd9_5_1 = icd9->exam[(exam_ndx+ 4)].code[1].value, a_icd9->icd9_5_desc_1 = icd9
            ->exam[(exam_ndx+ 4)].code[1].desc
           ELSE
            a_icd9->icd9_5_1 = " ", a_icd9->icd9_5_desc_1 = " "
           ENDIF
          ELSE
           a_icd9->icd9_5_1 = " ", a_icd9->icd9_5_desc_1 = " "
          ENDIF
         ELSE
          a_icd9->icd9_5_1 = " ", a_icd9->icd9_5_desc_1 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 4)))
          IF (size(icd9->exam[(exam_ndx+ 4)].code,5) > 1)
           IF ((icd9->exam[(exam_ndx+ 4)].code[2].value != " "))
            a_icd9->icd9_5_2 = icd9->exam[(exam_ndx+ 4)].code[2].value, a_icd9->icd9_5_desc_2 = icd9
            ->exam[(exam_ndx+ 4)].code[2].desc
           ELSE
            a_icd9->icd9_5_2 = " ", a_icd9->icd9_5_desc_2 = " "
           ENDIF
          ELSE
           a_icd9->icd9_5_2 = " ", a_icd9->icd9_5_desc_2 = " "
          ENDIF
         ELSE
          a_icd9->icd9_5_2 = " ", a_icd9->icd9_5_desc_2 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 4)))
          IF (size(icd9->exam[(exam_ndx+ 4)].code,5) > 2)
           IF ((icd9->exam[(exam_ndx+ 4)].code[3].value != " "))
            a_icd9->icd9_5_3 = icd9->exam[(exam_ndx+ 4)].code[3].value, a_icd9->icd9_5_desc_3 = icd9
            ->exam[(exam_ndx+ 4)].code[3].desc
           ELSE
            a_icd9->icd9_5_3 = " ", a_icd9->icd9_5_desc_3 = " "
           ENDIF
          ELSE
           a_icd9->icd9_5_3 = " ", a_icd9->icd9_5_desc_3 = " "
          ENDIF
         ELSE
          a_icd9->icd9_5_3 = " ", a_icd9->icd9_5_desc_3 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 4)))
          IF (size(icd9->exam[(exam_ndx+ 4)].code,5) > 3)
           IF ((icd9->exam[(exam_ndx+ 4)].code[4].value != " "))
            a_icd9->icd9_5_4 = icd9->exam[(exam_ndx+ 4)].code[4].value, a_icd9->icd9_5_desc_4 = icd9
            ->exam[(exam_ndx+ 4)].code[4].desc
           ELSE
            a_icd9->icd9_5_4 = " ", a_icd9->icd9_5_desc_4 = " "
           ENDIF
          ELSE
           a_icd9->icd9_5_4 = " ", a_icd9->icd9_5_desc_4 = " "
          ENDIF
         ELSE
          a_icd9->icd9_5_4 = " ", a_icd9->icd9_5_desc_4 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 5)
         IF ((size(icd9->exam,5) >= (exam_ndx+ 5)))
          IF (size(icd9->exam[(exam_ndx+ 5)].code,5) > 0)
           IF ((icd9->exam[(exam_ndx+ 5)].code[1].value != " "))
            a_icd9->icd9_6_1 = icd9->exam[(exam_ndx+ 5)].code[1].value, a_icd9->icd9_6_desc_1 = icd9
            ->exam[(exam_ndx+ 5)].code[1].desc
           ELSE
            a_icd9->icd9_6_1 = " ", a_icd9->icd9_6_desc_1 = " "
           ENDIF
          ELSE
           a_icd9->icd9_6_1 = " ", a_icd9->icd9_6_desc_1 = " "
          ENDIF
         ELSE
          a_icd9->icd9_6_1 = " ", a_icd9->icd9_6_desc_1 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 5)))
          IF (size(icd9->exam[(exam_ndx+ 5)].code,5) > 1)
           IF ((icd9->exam[(exam_ndx+ 5)].code[2].value != " "))
            a_icd9->icd9_6_2 = icd9->exam[(exam_ndx+ 5)].code[2].value, a_icd9->icd9_6_desc_2 = icd9
            ->exam[(exam_ndx+ 5)].code[2].desc
           ELSE
            a_icd9->icd9_6_2 = " ", a_icd9->icd9_6_desc_2 = " "
           ENDIF
          ELSE
           a_icd9->icd9_6_2 = " ", a_icd9->icd9_6_desc_2 = " "
          ENDIF
         ELSE
          a_icd9->icd9_6_2 = " ", a_icd9->icd9_6_desc_2 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 5)))
          IF (size(icd9->exam[(exam_ndx+ 5)].code,5) > 2)
           IF ((icd9->exam[(exam_ndx+ 5)].code[3].value != " "))
            a_icd9->icd9_6_3 = icd9->exam[(exam_ndx+ 5)].code[3].value, a_icd9->icd9_6_desc_3 = icd9
            ->exam[(exam_ndx+ 5)].code[3].desc
           ELSE
            a_icd9->icd9_6_3 = " ", a_icd9->icd9_6_desc_3 = " "
           ENDIF
          ELSE
           a_icd9->icd9_6_3 = " ", a_icd9->icd9_6_desc_3 = " "
          ENDIF
         ELSE
          a_icd9->icd9_6_3 = " ", a_icd9->icd9_6_desc_3 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 5)))
          IF (size(icd9->exam[(exam_ndx+ 5)].code,5) > 3)
           IF ((icd9->exam[(exam_ndx+ 5)].code[4].value != " "))
            a_icd9->icd9_6_4 = icd9->exam[(exam_ndx+ 5)].code[4].value, a_icd9->icd9_6_desc_4 = icd9
            ->exam[(exam_ndx+ 5)].code[4].desc
           ELSE
            a_icd9->icd9_6_4 = " ", a_icd9->icd9_6_desc_4 = " "
           ENDIF
          ELSE
           a_icd9->icd9_6_4 = " ", a_icd9->icd9_6_desc_4 = " "
          ENDIF
         ELSE
          a_icd9->icd9_6_4 = " ", a_icd9->icd9_6_desc_4 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 6)
         IF ((size(icd9->exam,5) >= (exam_ndx+ 6)))
          IF (size(icd9->exam[(exam_ndx+ 6)].code,5) > 0)
           IF ((icd9->exam[(exam_ndx+ 6)].code[1].value != " "))
            a_icd9->icd9_7_1 = icd9->exam[(exam_ndx+ 6)].code[1].value, a_icd9->icd9_7_desc_1 = icd9
            ->exam[(exam_ndx+ 6)].code[1].desc
           ELSE
            a_icd9->icd9_7_1 = " ", a_icd9->icd9_7_desc_1 = " "
           ENDIF
          ELSE
           a_icd9->icd9_7_1 = " ", a_icd9->icd9_7_desc_1 = " "
          ENDIF
         ELSE
          a_icd9->icd9_7_1 = " ", a_icd9->icd9_7_desc_1 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 6)))
          IF (size(icd9->exam[(exam_ndx+ 6)].code,5) > 1)
           IF ((icd9->exam[(exam_ndx+ 6)].code[2].value != " "))
            a_icd9->icd9_7_2 = icd9->exam[(exam_ndx+ 6)].code[2].value, a_icd9->icd9_7_desc_2 = icd9
            ->exam[(exam_ndx+ 6)].code[2].desc
           ELSE
            a_icd9->icd9_7_2 = " ", a_icd9->icd9_7_desc_2 = " "
           ENDIF
          ELSE
           a_icd9->icd9_7_2 = " ", a_icd9->icd9_7_desc_2 = " "
          ENDIF
         ELSE
          a_icd9->icd9_7_2 = " ", a_icd9->icd9_7_desc_2 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 6)))
          IF (size(icd9->exam[(exam_ndx+ 6)].code,5) > 2)
           IF ((icd9->exam[(exam_ndx+ 6)].code[3].value != " "))
            a_icd9->icd9_7_3 = icd9->exam[(exam_ndx+ 6)].code[3].value, a_icd9->icd9_7_desc_3 = icd9
            ->exam[(exam_ndx+ 6)].code[3].desc
           ELSE
            a_icd9->icd9_7_3 = " ", a_icd9->icd9_7_desc_3 = " "
           ENDIF
          ELSE
           a_icd9->icd9_7_3 = " ", a_icd9->icd9_7_desc_3 = " "
          ENDIF
         ELSE
          a_icd9->icd9_7_3 = " ", a_icd9->icd9_7_desc_3 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 6)))
          IF (size(icd9->exam[(exam_ndx+ 6)].code,5) > 3)
           IF ((icd9->exam[(exam_ndx+ 6)].code[4].value != " "))
            a_icd9->icd9_7_4 = icd9->exam[(exam_ndx+ 6)].code[4].value, a_icd9->icd9_7_desc_4 = icd9
            ->exam[(exam_ndx+ 6)].code[4].desc
           ELSE
            a_icd9->icd9_7_4 = " ", a_icd9->icd9_7_desc_4 = " "
           ENDIF
          ELSE
           a_icd9->icd9_7_4 = " ", a_icd9->icd9_7_desc_4 = " "
          ENDIF
         ELSE
          a_icd9->icd9_7_4 = " ", a_icd9->icd9_7_desc_4 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 7)
         IF ((size(icd9->exam,5) >= (exam_ndx+ 7)))
          IF (size(icd9->exam[(exam_ndx+ 7)].code,5) > 0)
           IF ((icd9->exam[(exam_ndx+ 7)].code[1].value != " "))
            a_icd9->icd9_8_1 = icd9->exam[(exam_ndx+ 7)].code[1].value, a_icd9->icd9_8_desc_1 = icd9
            ->exam[(exam_ndx+ 7)].code[1].desc
           ELSE
            a_icd9->icd9_8_1 = " ", a_icd9->icd9_8_desc_1 = " "
           ENDIF
          ELSE
           a_icd9->icd9_8_1 = " ", a_icd9->icd9_8_desc_1 = " "
          ENDIF
         ELSE
          a_icd9->icd9_8_1 = " ", a_icd9->icd9_8_desc_1 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 7)))
          IF (size(icd9->exam[(exam_ndx+ 7)].code,5) > 1)
           IF ((icd9->exam[(exam_ndx+ 7)].code[2].value != " "))
            a_icd9->icd9_8_2 = icd9->exam[(exam_ndx+ 7)].code[2].value, a_icd9->icd9_8_desc_2 = icd9
            ->exam[(exam_ndx+ 7)].code[2].desc
           ELSE
            a_icd9->icd9_8_2 = " ", a_icd9->icd9_8_desc_2 = " "
           ENDIF
          ELSE
           a_icd9->icd9_8_2 = " ", a_icd9->icd9_8_desc_2 = " "
          ENDIF
         ELSE
          a_icd9->icd9_8_2 = " ", a_icd9->icd9_8_desc_2 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 7)))
          IF (size(icd9->exam[(exam_ndx+ 7)].code,5) > 2)
           IF ((icd9->exam[(exam_ndx+ 7)].code[3].value != " "))
            a_icd9->icd9_8_3 = icd9->exam[(exam_ndx+ 7)].code[3].value, a_icd9->icd9_8_desc_3 = icd9
            ->exam[(exam_ndx+ 7)].code[3].desc
           ELSE
            a_icd9->icd9_8_3 = " ", a_icd9->icd9_8_desc_3 = " "
           ENDIF
          ELSE
           a_icd9->icd9_8_3 = " ", a_icd9->icd9_8_desc_3 = " "
          ENDIF
         ELSE
          a_icd9->icd9_8_3 = " ", a_icd9->icd9_8_desc_3 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 7)))
          IF (size(icd9->exam[(exam_ndx+ 7)].code,5) > 3)
           IF ((icd9->exam[(exam_ndx+ 7)].code[4].value != " "))
            a_icd9->icd9_8_4 = icd9->exam[(exam_ndx+ 7)].code[4].value, a_icd9->icd9_8_desc_4 = icd9
            ->exam[(exam_ndx+ 7)].code[4].desc
           ELSE
            a_icd9->icd9_8_4 = " ", a_icd9->icd9_8_desc_4 = " "
           ENDIF
          ELSE
           a_icd9->icd9_8_4 = " ", a_icd9->icd9_8_desc_4 = " "
          ENDIF
         ELSE
          a_icd9->icd9_8_4 = " ", a_icd9->icd9_8_desc_4 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 8)
         IF ((size(icd9->exam,5) >= (exam_ndx+ 8)))
          IF (size(icd9->exam[(exam_ndx+ 8)].code,5) > 0)
           IF ((icd9->exam[(exam_ndx+ 8)].code[1].value != " "))
            a_icd9->icd9_9_1 = icd9->exam[(exam_ndx+ 8)].code[1].value, a_icd9->icd9_9_desc_1 = icd9
            ->exam[(exam_ndx+ 8)].code[1].desc
           ELSE
            a_icd9->icd9_9_1 = " ", a_icd9->icd9_9_desc_1 = " "
           ENDIF
          ELSE
           a_icd9->icd9_9_1 = " ", a_icd9->icd9_9_desc_1 = " "
          ENDIF
         ELSE
          a_icd9->icd9_9_1 = " ", a_icd9->icd9_9_desc_1 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 8)))
          IF (size(icd9->exam[(exam_ndx+ 8)].code,5) > 1)
           IF ((icd9->exam[(exam_ndx+ 8)].code[2].value != " "))
            a_icd9->icd9_9_2 = icd9->exam[(exam_ndx+ 8)].code[2].value, a_icd9->icd9_9_desc_2 = icd9
            ->exam[(exam_ndx+ 8)].code[2].desc
           ELSE
            a_icd9->icd9_9_2 = " ", a_icd9->icd9_9_desc_2 = " "
           ENDIF
          ELSE
           a_icd9->icd9_9_2 = " ", a_icd9->icd9_9_desc_2 = " "
          ENDIF
         ELSE
          a_icd9->icd9_9_2 = " ", a_icd9->icd9_9_desc_2 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 8)))
          IF (size(icd9->exam[(exam_ndx+ 8)].code,5) > 2)
           IF ((icd9->exam[(exam_ndx+ 8)].code[3].value != " "))
            a_icd9->icd9_9_3 = icd9->exam[(exam_ndx+ 8)].code[3].value, a_icd9->icd9_9_desc_3 = icd9
            ->exam[(exam_ndx+ 8)].code[3].desc
           ELSE
            a_icd9->icd9_9_3 = " ", a_icd9->icd9_9_desc_3 = " "
           ENDIF
          ELSE
           a_icd9->icd9_9_3 = " ", a_icd9->icd9_9_desc_3 = " "
          ENDIF
         ELSE
          a_icd9->icd9_9_3 = " ", a_icd9->icd9_9_desc_3 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 8)))
          IF (size(icd9->exam[(exam_ndx+ 8)].code,5) > 3)
           IF ((icd9->exam[(exam_ndx+ 8)].code[4].value != " "))
            a_icd9->icd9_9_4 = icd9->exam[(exam_ndx+ 8)].code[4].value, a_icd9->icd9_9_desc_4 = icd9
            ->exam[(exam_ndx+ 8)].code[4].desc
           ELSE
            a_icd9->icd9_9_4 = " ", a_icd9->icd9_9_desc_4 = " "
           ENDIF
          ELSE
           a_icd9->icd9_9_4 = " ", a_icd9->icd9_9_desc_4 = " "
          ENDIF
         ELSE
          a_icd9->icd9_9_4 = " ", a_icd9->icd9_9_desc_4 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 9)
         IF ((size(icd9->exam,5) >= (exam_ndx+ 9)))
          IF (size(icd9->exam[(exam_ndx+ 9)].code,5) > 0)
           IF ((icd9->exam[(exam_ndx+ 9)].code[1].value != " "))
            a_icd9->icd9_10_1 = icd9->exam[(exam_ndx+ 9)].code[1].value, a_icd9->icd9_10_desc_1 =
            icd9->exam[(exam_ndx+ 9)].code[1].desc
           ELSE
            a_icd9->icd9_10_1 = " ", a_icd9->icd9_10_desc_1 = " "
           ENDIF
          ELSE
           a_icd9->icd9_10_1 = " ", a_icd9->icd9_10_desc_1 = " "
          ENDIF
         ELSE
          a_icd9->icd9_10_1 = " ", a_icd9->icd9_10_desc_1 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 9)))
          IF (size(icd9->exam[(exam_ndx+ 9)].code,5) > 1)
           IF ((icd9->exam[(exam_ndx+ 9)].code[2].value != " "))
            a_icd9->icd9_10_2 = icd9->exam[(exam_ndx+ 9)].code[2].value, a_icd9->icd9_10_desc_2 =
            icd9->exam[(exam_ndx+ 9)].code[2].desc
           ELSE
            a_icd9->icd9_10_2 = " ", a_icd9->icd9_10_desc_2 = " "
           ENDIF
          ELSE
           a_icd9->icd9_10_2 = " ", a_icd9->icd9_10_desc_2 = " "
          ENDIF
         ELSE
          a_icd9->icd9_10_2 = " ", a_icd9->icd9_10_desc_2 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 9)))
          IF (size(icd9->exam[(exam_ndx+ 9)].code,5) > 2)
           IF ((icd9->exam[(exam_ndx+ 9)].code[3].value != " "))
            a_icd9->icd9_10_3 = icd9->exam[(exam_ndx+ 9)].code[3].value, a_icd9->icd9_10_desc_3 =
            icd9->exam[(exam_ndx+ 9)].code[3].desc
           ELSE
            a_icd9->icd9_10_3 = " ", a_icd9->icd9_10_desc_3 = " "
           ENDIF
          ELSE
           a_icd9->icd9_10_3 = " ", a_icd9->icd9_10_desc_3 = " "
          ENDIF
         ELSE
          a_icd9->icd9_10_3 = " ", a_icd9->icd9_10_desc_3 = " "
         ENDIF
         IF ((size(icd9->exam,5) >= (exam_ndx+ 9)))
          IF (size(icd9->exam[(exam_ndx+ 9)].code,5) > 3)
           IF ((icd9->exam[(exam_ndx+ 9)].code[4].value != " "))
            a_icd9->icd9_10_4 = icd9->exam[(exam_ndx+ 9)].code[4].value, a_icd9->icd9_10_desc_4 =
            icd9->exam[(exam_ndx+ 9)].code[4].desc
           ELSE
            a_icd9->icd9_10_4 = " ", a_icd9->icd9_10_desc_4 = " "
           ENDIF
          ELSE
           a_icd9->icd9_10_4 = " ", a_icd9->icd9_10_desc_4 = " "
          ENDIF
         ELSE
          a_icd9->icd9_10_4 = " ", a_icd9->icd9_10_desc_4 = " "
         ENDIF
        ENDIF
        IF ((size(icd9->exam,5) > data->req[req_ndx].sections[sect_ndx].nbr_of_exams_per_req))
         exam_ndx = (exam_ndx - ((x - 1) * data->req[req_ndx].sections[sect_ndx].nbr_of_exams_per_req
         ))
        ENDIF
        CALL echo("*****START OF LAST EXAMS DATA*****")
        IF (size(rad_all->last_exam,5) > 0)
         a_previous_exam_all_1->exam_name = rad_all->last_exam[1].exam_name, a_previous_exam_all_1->
         request_date_time = rad_all->last_exam[1].request_date_time, a_previous_exam_all_1->
         complete_date_time = rad_all->last_exam[1].complete_date_time,
         a_previous_exam_all_1->transcribe_date_time = rad_all->last_exam[1].transcribe_date_time,
         a_previous_exam_all_1->final_date_time = rad_all->last_exam[1].final_date_time,
         a_previous_exam_all_1->accession = formataccession(rad_all->last_exam[1].accession),
         a_previous_exam_all_1->facility_display = rad_all->last_exam[1].facility_display,
         a_previous_exam_all_1->facility_description = rad_all->last_exam[1].facility_description,
         a_previous_exam_all_1->completing_location_display = rad_all->last_exam[1].
         completing_location_display,
         a_previous_exam_all_1->completing_location_description = rad_all->last_exam[1].
         completing_location_description, a_previous_exam_all_1->image_class_type_display = rad_all->
         last_exam[1].image_class_type_display, a_previous_exam_all_1->image_class_type_description
          = rad_all->last_exam[1].image_class_type_description,
         a_previous_exam_all_1->exam_status = rad_all->last_exam[1].exam_status,
         CALL echo(build("Previous1 ALL -->",a_previous_exam_all_1->complete_date_time)),
         CALL echo(build("Previous1 ALL -->",a_previous_exam_all_1->exam_name)),
         CALL echo(build("Previous1 ALL -->",a_previous_exam_all_1->image_class_type_display)),
         CALL echo(build("Previous1 ALL -->",a_previous_exam_all_1->image_class_type_description)),
         CALL echo(build("Previous1 ALL -->",a_previous_exam_all_1->completing_location_display)),
         CALL echo(build("Previous1 ALL -->",a_previous_exam_all_1->completing_location_description)),
         CALL echo(build("Previous1 ALL -->",a_previous_exam_all_1->facility_display)),
         CALL echo(build("Previous1 ALL -->",a_previous_exam_all_1->facility_description)),
         CALL echo(build("Previous1 ALL -->",a_previous_exam_all_1->accession)),
         CALL echo(build("Previous1 ALL -->",a_previous_exam_all_1->transcribe_date_time)),
         CALL echo(build("Previous1 ALL -->",a_previous_exam_all_1->final_date_time)),
         CALL echo(build("Previous1 ALL -->",a_previous_exam_all_1->request_date_time)),
         CALL echo(build("Previous1 ALL -->",a_previous_exam_all_1->exam_status))
        ENDIF
        IF (size(rad_all->last_exam,5) > 1)
         a_previous_exam_all_2->complete_date_time = rad_all->last_exam[2].complete_date_time,
         a_previous_exam_all_2->exam_name = rad_all->last_exam[2].exam_name, a_previous_exam_all_2->
         image_class_type_display = rad_all->last_exam[2].image_class_type_display,
         a_previous_exam_all_2->image_class_type_description = rad_all->last_exam[2].
         image_class_type_description, a_previous_exam_all_2->completing_location_display = rad_all->
         last_exam[2].completing_location_display, a_previous_exam_all_2->
         completing_location_description = rad_all->last_exam[2].completing_location_description,
         a_previous_exam_all_2->facility_display = rad_all->last_exam[2].facility_display,
         a_previous_exam_all_2->facility_description = rad_all->last_exam[2].facility_description,
         a_previous_exam_all_2->accession = formataccession(rad_all->last_exam[2].accession),
         a_previous_exam_all_2->transcribe_date_time = rad_all->last_exam[2].transcribe_date_time,
         a_previous_exam_all_2->final_date_time = rad_all->last_exam[2].final_date_time,
         a_previous_exam_all_2->request_date_time = rad_all->last_exam[2].request_date_time,
         a_previous_exam_all_2->exam_status = rad_all->last_exam[2].exam_status
        ENDIF
        IF (size(rad_all->last_exam,5) > 2)
         a_previous_exam_all_3->complete_date_time = rad_all->last_exam[3].complete_date_time,
         a_previous_exam_all_3->exam_name = rad_all->last_exam[3].exam_name, a_previous_exam_all_3->
         image_class_type_display = rad_all->last_exam[3].image_class_type_display,
         a_previous_exam_all_3->image_class_type_description = rad_all->last_exam[3].
         image_class_type_description, a_previous_exam_all_3->completing_location_display = rad_all->
         last_exam[3].completing_location_display, a_previous_exam_all_3->
         completing_location_description = rad_all->last_exam[3].completing_location_description,
         a_previous_exam_all_3->facility_display = rad_all->last_exam[3].facility_display,
         a_previous_exam_all_3->facility_description = rad_all->last_exam[3].facility_description,
         a_previous_exam_all_3->accession = formataccession(rad_all->last_exam[3].accession),
         a_previous_exam_all_3->transcribe_date_time = rad_all->last_exam[3].transcribe_date_time,
         a_previous_exam_all_3->final_date_time = rad_all->last_exam[3].final_date_time,
         a_previous_exam_all_3->request_date_time = rad_all->last_exam[3].request_date_time,
         a_previous_exam_all_3->exam_status = rad_all->last_exam[3].exam_status
        ENDIF
        IF (size(rad_all->last_exam,5) > 3)
         a_previous_exam_all_4->complete_date_time = rad_all->last_exam[4].complete_date_time,
         a_previous_exam_all_4->exam_name = rad_all->last_exam[4].exam_name, a_previous_exam_all_4->
         image_class_type_display = rad_all->last_exam[4].image_class_type_display,
         a_previous_exam_all_4->image_class_type_description = rad_all->last_exam[4].
         image_class_type_description, a_previous_exam_all_4->completing_location_display = rad_all->
         last_exam[4].completing_location_display, a_previous_exam_all_4->
         completing_location_description = rad_all->last_exam[4].completing_location_description,
         a_previous_exam_all_4->facility_display = rad_all->last_exam[4].facility_display,
         a_previous_exam_all_4->facility_description = rad_all->last_exam[4].facility_description,
         a_previous_exam_all_4->accession = formataccession(rad_all->last_exam[4].accession),
         a_previous_exam_all_4->transcribe_date_time = rad_all->last_exam[4].transcribe_date_time,
         a_previous_exam_all_4->final_date_time = rad_all->last_exam[4].final_date_time,
         a_previous_exam_all_4->request_date_time = rad_all->last_exam[4].request_date_time,
         a_previous_exam_all_4->exam_status = rad_all->last_exam[4].exam_status
        ENDIF
        IF (size(rad_all->last_exam,5) > 4)
         a_previous_exam_all_5->complete_date_time = rad_all->last_exam[5].complete_date_time,
         a_previous_exam_all_5->exam_name = rad_all->last_exam[5].exam_name, a_previous_exam_all_5->
         image_class_type_display = rad_all->last_exam[5].image_class_type_display,
         a_previous_exam_all_5->image_class_type_description = rad_all->last_exam[5].
         image_class_type_description, a_previous_exam_all_5->completing_location_display = rad_all->
         last_exam[5].completing_location_display, a_previous_exam_all_5->
         completing_location_description = rad_all->last_exam[5].completing_location_description,
         a_previous_exam_all_5->facility_display = rad_all->last_exam[5].facility_display,
         a_previous_exam_all_5->facility_description = rad_all->last_exam[5].facility_description,
         a_previous_exam_all_5->accession = formataccession(rad_all->last_exam[5].accession),
         a_previous_exam_all_5->transcribe_date_time = rad_all->last_exam[5].transcribe_date_time,
         a_previous_exam_all_5->final_date_time = rad_all->last_exam[5].final_date_time,
         a_previous_exam_all_5->request_date_time = rad_all->last_exam[5].request_date_time,
         a_previous_exam_all_5->exam_status = rad_all->last_exam[5].exam_status
        ENDIF
        IF (size(rad_all->last_exam,5) > 5)
         a_previous_exam_all_6->complete_date_time = rad_all->last_exam[6].complete_date_time,
         a_previous_exam_all_6->exam_name = rad_all->last_exam[6].exam_name, a_previous_exam_all_6->
         image_class_type_display = rad_all->last_exam[6].image_class_type_display,
         a_previous_exam_all_6->image_class_type_description = rad_all->last_exam[6].
         image_class_type_description, a_previous_exam_all_6->completing_location_display = rad_all->
         last_exam[6].completing_location_display, a_previous_exam_all_6->
         completing_location_description = rad_all->last_exam[6].completing_location_description,
         a_previous_exam_all_6->facility_display = rad_all->last_exam[6].facility_display,
         a_previous_exam_all_6->facility_description = rad_all->last_exam[6].facility_description,
         a_previous_exam_all_6->accession = formataccession(rad_all->last_exam[6].accession),
         a_previous_exam_all_6->transcribe_date_time = rad_all->last_exam[6].transcribe_date_time,
         a_previous_exam_all_6->final_date_time = rad_all->last_exam[6].final_date_time,
         a_previous_exam_all_6->request_date_time = rad_all->last_exam[6].request_date_time,
         a_previous_exam_all_6->exam_status = rad_all->last_exam[6].exam_status
        ENDIF
        IF (size(rad_all->last_exam,5) > 6)
         a_previous_exam_all_7->complete_date_time = rad_all->last_exam[7].complete_date_time,
         a_previous_exam_all_7->exam_name = rad_all->last_exam[7].exam_name, a_previous_exam_all_7->
         image_class_type_display = rad_all->last_exam[7].image_class_type_display,
         a_previous_exam_all_7->image_class_type_description = rad_all->last_exam[7].
         image_class_type_description, a_previous_exam_all_7->completing_location_display = rad_all->
         last_exam[7].completing_location_display, a_previous_exam_all_7->
         completing_location_description = rad_all->last_exam[7].completing_location_description,
         a_previous_exam_all_7->facility_display = rad_all->last_exam[7].facility_display,
         a_previous_exam_all_7->facility_description = rad_all->last_exam[7].facility_description,
         a_previous_exam_all_7->accession = formataccession(rad_all->last_exam[7].accession),
         a_previous_exam_all_7->transcribe_date_time = rad_all->last_exam[7].transcribe_date_time,
         a_previous_exam_all_7->final_date_time = rad_all->last_exam[7].final_date_time,
         a_previous_exam_all_7->request_date_time = rad_all->last_exam[7].request_date_time,
         a_previous_exam_all_7->exam_status = rad_all->last_exam[7].exam_status
        ENDIF
        IF (size(rad_all->last_exam,5) > 7)
         a_previous_exam_all_8->complete_date_time = rad_all->last_exam[8].complete_date_time,
         a_previous_exam_all_8->exam_name = rad_all->last_exam[8].exam_name, a_previous_exam_all_8->
         image_class_type_display = rad_all->last_exam[8].image_class_type_display,
         a_previous_exam_all_8->image_class_type_description = rad_all->last_exam[8].
         image_class_type_description, a_previous_exam_all_8->completing_location_display = rad_all->
         last_exam[8].completing_location_display, a_previous_exam_all_8->
         completing_location_description = rad_all->last_exam[8].completing_location_description,
         a_previous_exam_all_8->facility_display = rad_all->last_exam[8].facility_display,
         a_previous_exam_all_8->facility_description = rad_all->last_exam[8].facility_description,
         a_previous_exam_all_8->accession = formataccession(rad_all->last_exam[8].accession),
         a_previous_exam_all_8->transcribe_date_time = rad_all->last_exam[8].transcribe_date_time,
         a_previous_exam_all_8->final_date_time = rad_all->last_exam[8].final_date_time,
         a_previous_exam_all_8->request_date_time = rad_all->last_exam[8].request_date_time,
         a_previous_exam_all_8->exam_status = rad_all->last_exam[8].exam_status
        ENDIF
        IF (size(rad_all->last_exam,5) > 8)
         a_previous_exam_all_9->complete_date_time = rad_all->last_exam[9].complete_date_time,
         a_previous_exam_all_9->exam_name = rad_all->last_exam[9].exam_name, a_previous_exam_all_9->
         image_class_type_display = rad_all->last_exam[9].image_class_type_display,
         a_previous_exam_all_9->image_class_type_description = rad_all->last_exam[9].
         image_class_type_description, a_previous_exam_all_9->completing_location_display = rad_all->
         last_exam[9].completing_location_display, a_previous_exam_all_9->
         completing_location_description = rad_all->last_exam[9].completing_location_description,
         a_previous_exam_all_9->facility_display = rad_all->last_exam[9].facility_display,
         a_previous_exam_all_9->facility_description = rad_all->last_exam[9].facility_description,
         a_previous_exam_all_9->accession = formataccession(rad_all->last_exam[9].accession),
         a_previous_exam_all_9->transcribe_date_time = rad_all->last_exam[9].transcribe_date_time,
         a_previous_exam_all_9->final_date_time = rad_all->last_exam[9].final_date_time,
         a_previous_exam_all_9->request_date_time = rad_all->last_exam[9].request_date_time,
         a_previous_exam_all_9->exam_status = rad_all->last_exam[9].exam_status
        ENDIF
        IF (size(rad_all->last_exam,5) > 9)
         a_previous_exam_all_10->complete_date_time = rad_all->last_exam[10].complete_date_time,
         a_previous_exam_all_10->exam_name = rad_all->last_exam[10].exam_name, a_previous_exam_all_10
         ->image_class_type_display = rad_all->last_exam[10].image_class_type_display,
         a_previous_exam_all_10->image_class_type_description = rad_all->last_exam[10].
         image_class_type_description, a_previous_exam_all_10->completing_location_display = rad_all
         ->last_exam[10].completing_location_display, a_previous_exam_all_10->
         completing_location_description = rad_all->last_exam[10].completing_location_description,
         a_previous_exam_all_10->facility_display = rad_all->last_exam[10].facility_display,
         a_previous_exam_all_10->facility_description = rad_all->last_exam[10].facility_description,
         a_previous_exam_all_10->accession = formataccession(rad_all->last_exam[10].accession),
         a_previous_exam_all_10->transcribe_date_time = rad_all->last_exam[10].transcribe_date_time,
         a_previous_exam_all_10->final_date_time = rad_all->last_exam[10].final_date_time,
         a_previous_exam_all_10->request_date_time = rad_all->last_exam[10].request_date_time,
         a_previous_exam_all_10->exam_status = rad_all->last_exam[10].exam_status
        ENDIF
        IF (size(fac->last_exam,5) > 0)
         a_previous_exam_fac_1->complete_date_time = fac->last_exam[1].complete_date_time,
         a_previous_exam_fac_1->exam_name = fac->last_exam[1].exam_name, a_previous_exam_fac_1->
         image_class_type_display = fac->last_exam[1].image_class_type_display,
         a_previous_exam_fac_1->image_class_type_description = fac->last_exam[1].
         image_class_type_description, a_previous_exam_fac_1->completing_location_display = fac->
         last_exam[1].completing_location_display, a_previous_exam_fac_1->
         completing_location_description = fac->last_exam[1].completing_location_description,
         a_previous_exam_fac_1->facility_display = fac->last_exam[1].facility_display,
         a_previous_exam_fac_1->facility_description = fac->last_exam[1].facility_description,
         a_previous_exam_fac_1->accession = formataccession(fac->last_exam[1].accession),
         a_previous_exam_fac_1->transcribe_date_time = fac->last_exam[1].transcribe_date_time,
         a_previous_exam_fac_1->final_date_time = fac->last_exam[1].final_date_time,
         a_previous_exam_fac_1->request_date_time = fac->last_exam[1].request_date_time,
         a_previous_exam_fac_1->exam_status = fac->last_exam[1].exam_status,
         CALL echo(build("Previous1 FAC ---->",a_previous_exam_fac_1->complete_date_time)),
         CALL echo(build("Previous1 FAC ---->",a_previous_exam_fac_1->exam_name)),
         CALL echo(build("Previous1 FAC ---->",a_previous_exam_fac_1->image_class_type_display)),
         CALL echo(build("Previous1 FAC ---->",a_previous_exam_fac_1->image_class_type_description)),
         CALL echo(build("Previous1 FAC ---->",a_previous_exam_fac_1->completing_location_display)),
         CALL echo(build("Previous1 FAC ---->",a_previous_exam_fac_1->completing_location_description
          )),
         CALL echo(build("Previous1 FAC ---->",a_previous_exam_fac_1->facility_display)),
         CALL echo(build("Previous1 FAC ---->",a_previous_exam_fac_1->facility_description)),
         CALL echo(build("Previous1 FAC ---->",a_previous_exam_fac_1->accession)),
         CALL echo(build("Previous1 FAC ---->",a_previous_exam_fac_1->transcribe_date_time)),
         CALL echo(build("Previous1 FAC ---->",a_previous_exam_fac_1->final_date_time)),
         CALL echo(build("Previous1 FAC ---->",a_previous_exam_fac_1->request_date_time)),
         CALL echo(build("Previous1 FAC ---->",a_previous_exam_fac_1->exam_status))
        ENDIF
        IF (size(fac->last_exam,5) > 1)
         a_previous_exam_fac_2->complete_date_time = fac->last_exam[2].complete_date_time,
         a_previous_exam_fac_2->exam_name = fac->last_exam[2].exam_name, a_previous_exam_fac_2->
         image_class_type_display = fac->last_exam[2].image_class_type_display,
         a_previous_exam_fac_2->image_class_type_description = fac->last_exam[2].
         image_class_type_description, a_previous_exam_fac_2->completing_location_display = fac->
         last_exam[2].completing_location_display, a_previous_exam_fac_2->
         completing_location_description = fac->last_exam[2].completing_location_description,
         a_previous_exam_fac_2->facility_display = fac->last_exam[2].facility_display,
         a_previous_exam_fac_2->facility_description = fac->last_exam[2].facility_description,
         a_previous_exam_fac_2->accession = formataccession(fac->last_exam[2].accession),
         a_previous_exam_fac_2->transcribe_date_time = fac->last_exam[2].transcribe_date_time,
         a_previous_exam_fac_2->final_date_time = fac->last_exam[2].final_date_time,
         a_previous_exam_fac_2->request_date_time = fac->last_exam[2].request_date_time,
         a_previous_exam_fac_2->exam_status = fac->last_exam[2].exam_status
        ENDIF
        IF (size(fac->last_exam,5) > 2)
         a_previous_exam_fac_3->complete_date_time = fac->last_exam[3].complete_date_time,
         a_previous_exam_fac_3->exam_name = fac->last_exam[3].exam_name, a_previous_exam_fac_3->
         image_class_type_display = fac->last_exam[3].image_class_type_display,
         a_previous_exam_fac_3->image_class_type_description = fac->last_exam[3].
         image_class_type_description, a_previous_exam_fac_3->completing_location_display = fac->
         last_exam[3].completing_location_display, a_previous_exam_fac_3->
         completing_location_description = fac->last_exam[3].completing_location_description,
         a_previous_exam_fac_3->facility_display = fac->last_exam[3].facility_display,
         a_previous_exam_fac_3->facility_description = fac->last_exam[3].facility_description,
         a_previous_exam_fac_3->accession = formataccession(fac->last_exam[3].accession),
         a_previous_exam_fac_3->transcribe_date_time = fac->last_exam[3].transcribe_date_time,
         a_previous_exam_fac_3->final_date_time = fac->last_exam[3].final_date_time,
         a_previous_exam_fac_3->request_date_time = fac->last_exam[3].request_date_time,
         a_previous_exam_fac_3->exam_status = fac->last_exam[3].exam_status
        ENDIF
        IF (size(fac->last_exam,5) > 3)
         a_previous_exam_fac_4->complete_date_time = fac->last_exam[4].complete_date_time,
         a_previous_exam_fac_4->exam_name = fac->last_exam[4].exam_name, a_previous_exam_fac_4->
         image_class_type_display = fac->last_exam[4].image_class_type_display,
         a_previous_exam_fac_4->image_class_type_description = fac->last_exam[4].
         image_class_type_description, a_previous_exam_fac_4->completing_location_display = fac->
         last_exam[4].completing_location_display, a_previous_exam_fac_4->
         completing_location_description = fac->last_exam[4].completing_location_description,
         a_previous_exam_fac_4->facility_display = fac->last_exam[4].facility_display,
         a_previous_exam_fac_4->facility_description = fac->last_exam[4].facility_description,
         a_previous_exam_fac_4->accession = formataccession(fac->last_exam[4].accession),
         a_previous_exam_fac_4->transcribe_date_time = fac->last_exam[4].transcribe_date_time,
         a_previous_exam_fac_4->final_date_time = fac->last_exam[4].final_date_time,
         a_previous_exam_fac_4->request_date_time = fac->last_exam[4].request_date_time,
         a_previous_exam_fac_4->exam_status = fac->last_exam[4].exam_status
        ENDIF
        IF (size(fac->last_exam,5) > 4)
         a_previous_exam_fac_5->complete_date_time = fac->last_exam[5].complete_date_time,
         a_previous_exam_fac_5->exam_name = fac->last_exam[5].exam_name, a_previous_exam_fac_5->
         image_class_type_display = fac->last_exam[5].image_class_type_display,
         a_previous_exam_fac_5->image_class_type_description = fac->last_exam[5].
         image_class_type_description, a_previous_exam_fac_5->completing_location_display = fac->
         last_exam[5].completing_location_display, a_previous_exam_fac_5->
         completing_location_description = fac->last_exam[5].completing_location_description,
         a_previous_exam_fac_5->facility_display = fac->last_exam[5].facility_display,
         a_previous_exam_fac_5->facility_description = fac->last_exam[5].facility_description,
         a_previous_exam_fac_5->accession = formataccession(fac->last_exam[5].accession),
         a_previous_exam_fac_5->transcribe_date_time = fac->last_exam[5].transcribe_date_time,
         a_previous_exam_fac_5->final_date_time = fac->last_exam[5].final_date_time,
         a_previous_exam_fac_5->request_date_time = fac->last_exam[5].request_date_time,
         a_previous_exam_fac_5->exam_status = fac->last_exam[5].exam_status
        ENDIF
        IF (size(fac->last_exam,5) > 5)
         a_previous_exam_fac_6->complete_date_time = fac->last_exam[6].complete_date_time,
         a_previous_exam_fac_6->exam_name = fac->last_exam[6].exam_name, a_previous_exam_fac_6->
         image_class_type_display = fac->last_exam[6].image_class_type_display,
         a_previous_exam_fac_6->image_class_type_description = fac->last_exam[6].
         image_class_type_description, a_previous_exam_fac_6->completing_location_display = fac->
         last_exam[6].completing_location_display, a_previous_exam_fac_6->
         completing_location_description = fac->last_exam[6].completing_location_description,
         a_previous_exam_fac_6->facility_display = fac->last_exam[6].facility_display,
         a_previous_exam_fac_6->facility_description = fac->last_exam[6].facility_description,
         a_previous_exam_fac_6->accession = formataccession(fac->last_exam[6].accession),
         a_previous_exam_fac_6->transcribe_date_time = fac->last_exam[6].transcribe_date_time,
         a_previous_exam_fac_6->final_date_time = fac->last_exam[6].final_date_time,
         a_previous_exam_fac_6->request_date_time = fac->last_exam[6].request_date_time,
         a_previous_exam_fac_6->exam_status = fac->last_exam[6].exam_status
        ENDIF
        IF (size(fac->last_exam,5) > 6)
         a_previous_exam_fac_7->complete_date_time = fac->last_exam[7].complete_date_time,
         a_previous_exam_fac_7->exam_name = fac->last_exam[7].exam_name, a_previous_exam_fac_7->
         image_class_type_display = fac->last_exam[7].image_class_type_display,
         a_previous_exam_fac_7->image_class_type_description = fac->last_exam[7].
         image_class_type_description, a_previous_exam_fac_7->completing_location_display = fac->
         last_exam[7].completing_location_display, a_previous_exam_fac_7->
         completing_location_description = fac->last_exam[7].completing_location_description,
         a_previous_exam_fac_7->facility_display = fac->last_exam[7].facility_display,
         a_previous_exam_fac_7->facility_description = fac->last_exam[7].facility_description,
         a_previous_exam_fac_7->accession = formataccession(fac->last_exam[7].accession),
         a_previous_exam_fac_7->transcribe_date_time = fac->last_exam[7].transcribe_date_time,
         a_previous_exam_fac_7->final_date_time = fac->last_exam[7].final_date_time,
         a_previous_exam_fac_7->request_date_time = fac->last_exam[7].request_date_time,
         a_previous_exam_fac_7->exam_status = fac->last_exam[7].exam_status
        ENDIF
        IF (size(fac->last_exam,5) > 7)
         a_previous_exam_fac_8->complete_date_time = fac->last_exam[8].complete_date_time,
         a_previous_exam_fac_8->exam_name = fac->last_exam[8].exam_name, a_previous_exam_fac_8->
         image_class_type_display = fac->last_exam[8].image_class_type_display,
         a_previous_exam_fac_8->image_class_type_description = fac->last_exam[8].
         image_class_type_description, a_previous_exam_fac_8->completing_location_display = fac->
         last_exam[8].completing_location_display, a_previous_exam_fac_8->
         completing_location_description = fac->last_exam[8].completing_location_description,
         a_previous_exam_fac_8->facility_display = fac->last_exam[8].facility_display,
         a_previous_exam_fac_8->facility_description = fac->last_exam[8].facility_description,
         a_previous_exam_fac_8->accession = formataccession(fac->last_exam[8].accession),
         a_previous_exam_fac_8->transcribe_date_time = fac->last_exam[8].transcribe_date_time,
         a_previous_exam_fac_8->final_date_time = fac->last_exam[8].final_date_time,
         a_previous_exam_fac_8->request_date_time = fac->last_exam[8].request_date_time,
         a_previous_exam_fac_8->exam_status = fac->last_exam[8].exam_status
        ENDIF
        IF (size(fac->last_exam,5) > 8)
         a_previous_exam_fac_9->complete_date_time = fac->last_exam[9].complete_date_time,
         a_previous_exam_fac_9->exam_name = fac->last_exam[9].exam_name, a_previous_exam_fac_9->
         image_class_type_display = fac->last_exam[9].image_class_type_display,
         a_previous_exam_fac_9->image_class_type_description = fac->last_exam[9].
         image_class_type_description, a_previous_exam_fac_9->completing_location_display = fac->
         last_exam[9].completing_location_display, a_previous_exam_fac_9->
         completing_location_description = fac->last_exam[9].completing_location_description,
         a_previous_exam_fac_9->facility_display = fac->last_exam[9].facility_display,
         a_previous_exam_fac_9->facility_description = fac->last_exam[9].facility_description,
         a_previous_exam_fac_9->accession = formataccession(fac->last_exam[9].accession),
         a_previous_exam_fac_9->transcribe_date_time = fac->last_exam[9].transcribe_date_time,
         a_previous_exam_fac_9->final_date_time = fac->last_exam[9].final_date_time,
         a_previous_exam_fac_9->request_date_time = fac->last_exam[9].request_date_time,
         a_previous_exam_fac_9->exam_status = fac->last_exam[9].exam_status
        ENDIF
        IF (size(fac->last_exam,5) > 9)
         a_previous_exam_fac_10->complete_date_time = fac->last_exam[10].complete_date_time,
         a_previous_exam_fac_10->exam_name = fac->last_exam[10].exam_name, a_previous_exam_fac_10->
         image_class_type_display = fac->last_exam[10].image_class_type_display,
         a_previous_exam_fac_10->image_class_type_description = fac->last_exam[10].
         image_class_type_description, a_previous_exam_fac_10->completing_location_display = fac->
         last_exam[10].completing_location_display, a_previous_exam_fac_10->
         completing_location_description = fac->last_exam[10].completing_location_description,
         a_previous_exam_fac_10->facility_display = fac->last_exam[10].facility_display,
         a_previous_exam_fac_10->facility_description = fac->last_exam[10].facility_description,
         a_previous_exam_fac_10->accession = formataccession(fac->last_exam[10].accession),
         a_previous_exam_fac_10->transcribe_date_time = fac->last_exam[10].transcribe_date_time,
         a_previous_exam_fac_10->final_date_time = fac->last_exam[10].final_date_time,
         a_previous_exam_fac_10->request_date_time = fac->last_exam[10].request_date_time,
         a_previous_exam_fac_10->exam_status = fac->last_exam[10].exam_status
        ENDIF
        IF (size(lib->last_exam,5) > 0)
         a_previous_exam_lib_1->complete_date_time = lib->last_exam[1].complete_date_time,
         a_previous_exam_lib_1->exam_name = lib->last_exam[1].exam_name, a_previous_exam_lib_1->
         image_class_type_display = lib->last_exam[1].image_class_type_display,
         a_previous_exam_lib_1->image_class_type_description = lib->last_exam[1].
         image_class_type_description, a_previous_exam_lib_1->completing_location_display = lib->
         last_exam[1].completing_location_display, a_previous_exam_lib_1->
         completing_location_description = lib->last_exam[1].completing_location_description,
         a_previous_exam_lib_1->facility_display = lib->last_exam[1].facility_display,
         a_previous_exam_lib_1->facility_description = lib->last_exam[1].facility_description,
         a_previous_exam_lib_1->accession = formataccession(lib->last_exam[1].accession),
         a_previous_exam_lib_1->transcribe_date_time = lib->last_exam[1].transcribe_date_time,
         a_previous_exam_lib_1->final_date_time = lib->last_exam[1].final_date_time,
         a_previous_exam_lib_1->request_date_time = lib->last_exam[1].request_date_time,
         a_previous_exam_lib_1->exam_status = lib->last_exam[1].exam_status,
         CALL echo(build("Previous1 LIB ---->",a_previous_exam_lib_1->complete_date_time)),
         CALL echo(build("Previous1 LIB ---->",a_previous_exam_lib_1->exam_name)),
         CALL echo(build("Previous1 LIB ---->",a_previous_exam_lib_1->image_class_type_display)),
         CALL echo(build("Previous1 LIB ---->",a_previous_exam_lib_1->image_class_type_description)),
         CALL echo(build("Previous1 LIB ---->",a_previous_exam_lib_1->completing_location_display)),
         CALL echo(build("Previous1 LIB ---->",a_previous_exam_lib_1->completing_location_description
          )),
         CALL echo(build("Previous1 LIB ---->",a_previous_exam_lib_1->facility_display)),
         CALL echo(build("Previous1 LIB ---->",a_previous_exam_lib_1->facility_description)),
         CALL echo(build("Previous1 LIB ---->",a_previous_exam_lib_1->accession)),
         CALL echo(build("Previous1 LIB ---->",a_previous_exam_lib_1->transcribe_date_time)),
         CALL echo(build("Previous1 LIB ---->",a_previous_exam_lib_1->final_date_time)),
         CALL echo(build("Previous1 LIB ---->",a_previous_exam_lib_1->request_date_time)),
         CALL echo(build("Previous1 LIB ---->",a_previous_exam_lib_1->exam_status))
        ENDIF
        IF (size(lib->last_exam,5) > 1)
         a_previous_exam_lib_2->complete_date_time = lib->last_exam[2].complete_date_time,
         a_previous_exam_lib_2->exam_name = lib->last_exam[2].exam_name, a_previous_exam_lib_2->
         image_class_type_display = lib->last_exam[2].image_class_type_display,
         a_previous_exam_lib_2->image_class_type_description = lib->last_exam[2].
         image_class_type_description, a_previous_exam_lib_2->completing_location_display = lib->
         last_exam[2].completing_location_display, a_previous_exam_lib_2->
         completing_location_description = lib->last_exam[2].completing_location_description,
         a_previous_exam_lib_2->facility_display = lib->last_exam[2].facility_display,
         a_previous_exam_lib_2->facility_description = lib->last_exam[2].facility_description,
         a_previous_exam_lib_2->accession = formataccession(lib->last_exam[2].accession),
         a_previous_exam_lib_2->transcribe_date_time = lib->last_exam[2].transcribe_date_time,
         a_previous_exam_lib_2->final_date_time = lib->last_exam[2].final_date_time,
         a_previous_exam_lib_2->request_date_time = lib->last_exam[2].request_date_time,
         a_previous_exam_lib_2->exam_status = lib->last_exam[2].exam_status
        ENDIF
        IF (size(lib->last_exam,5) > 2)
         a_previous_exam_lib_3->complete_date_time = lib->last_exam[3].complete_date_time,
         a_previous_exam_lib_3->exam_name = lib->last_exam[3].exam_name, a_previous_exam_lib_3->
         image_class_type_display = lib->last_exam[3].image_class_type_display,
         a_previous_exam_lib_3->image_class_type_description = lib->last_exam[3].
         image_class_type_description, a_previous_exam_lib_3->completing_location_display = lib->
         last_exam[3].completing_location_display, a_previous_exam_lib_3->
         completing_location_description = lib->last_exam[3].completing_location_description,
         a_previous_exam_lib_3->facility_display = lib->last_exam[3].facility_display,
         a_previous_exam_lib_3->facility_description = lib->last_exam[3].facility_description,
         a_previous_exam_lib_3->accession = formataccession(lib->last_exam[3].accession),
         a_previous_exam_lib_3->transcribe_date_time = lib->last_exam[3].transcribe_date_time,
         a_previous_exam_lib_3->final_date_time = lib->last_exam[3].final_date_time,
         a_previous_exam_lib_3->request_date_time = lib->last_exam[3].request_date_time,
         a_previous_exam_lib_3->exam_status = lib->last_exam[3].exam_status
        ENDIF
        IF (size(lib->last_exam,5) > 3)
         a_previous_exam_lib_4->complete_date_time = lib->last_exam[4].complete_date_time,
         a_previous_exam_lib_4->exam_name = lib->last_exam[4].exam_name, a_previous_exam_lib_4->
         image_class_type_display = lib->last_exam[4].image_class_type_display,
         a_previous_exam_lib_4->image_class_type_description = lib->last_exam[4].
         image_class_type_description, a_previous_exam_lib_4->completing_location_display = lib->
         last_exam[4].completing_location_display, a_previous_exam_lib_4->
         completing_location_description = lib->last_exam[4].completing_location_description,
         a_previous_exam_lib_4->facility_display = lib->last_exam[4].facility_display,
         a_previous_exam_lib_4->facility_description = lib->last_exam[4].facility_description,
         a_previous_exam_lib_4->accession = formataccession(lib->last_exam[4].accession),
         a_previous_exam_lib_4->transcribe_date_time = lib->last_exam[4].transcribe_date_time,
         a_previous_exam_lib_4->final_date_time = lib->last_exam[4].final_date_time,
         a_previous_exam_lib_4->request_date_time = lib->last_exam[4].request_date_time,
         a_previous_exam_lib_4->exam_status = lib->last_exam[4].exam_status
        ENDIF
        IF (size(lib->last_exam,5) > 4)
         a_previous_exam_lib_5->complete_date_time = lib->last_exam[5].complete_date_time,
         a_previous_exam_lib_5->exam_name = lib->last_exam[5].exam_name, a_previous_exam_lib_5->
         image_class_type_display = lib->last_exam[5].image_class_type_display,
         a_previous_exam_lib_5->image_class_type_description = lib->last_exam[5].
         image_class_type_description, a_previous_exam_lib_5->completing_location_display = lib->
         last_exam[5].completing_location_display, a_previous_exam_lib_5->
         completing_location_description = lib->last_exam[5].completing_location_description,
         a_previous_exam_lib_5->facility_display = lib->last_exam[5].facility_display,
         a_previous_exam_lib_5->facility_description = lib->last_exam[5].facility_description,
         a_previous_exam_lib_5->accession = formataccession(lib->last_exam[5].accession),
         a_previous_exam_lib_5->transcribe_date_time = lib->last_exam[5].transcribe_date_time,
         a_previous_exam_lib_5->final_date_time = lib->last_exam[5].final_date_time,
         a_previous_exam_lib_5->request_date_time = lib->last_exam[5].request_date_time,
         a_previous_exam_lib_5->exam_status = lib->last_exam[5].exam_status
        ENDIF
        IF (size(lib->last_exam,5) > 5)
         a_previous_exam_lib_6->complete_date_time = lib->last_exam[6].complete_date_time,
         a_previous_exam_lib_6->exam_name = lib->last_exam[6].exam_name, a_previous_exam_lib_6->
         image_class_type_display = lib->last_exam[6].image_class_type_display,
         a_previous_exam_lib_6->image_class_type_description = lib->last_exam[6].
         image_class_type_description, a_previous_exam_lib_6->completing_location_display = lib->
         last_exam[6].completing_location_display, a_previous_exam_lib_6->
         completing_location_description = lib->last_exam[6].completing_location_description,
         a_previous_exam_lib_6->facility_display = lib->last_exam[6].facility_display,
         a_previous_exam_lib_6->facility_description = lib->last_exam[6].facility_description,
         a_previous_exam_lib_6->accession = formataccession(lib->last_exam[6].accession),
         a_previous_exam_lib_6->transcribe_date_time = lib->last_exam[6].transcribe_date_time,
         a_previous_exam_lib_6->final_date_time = lib->last_exam[6].final_date_time,
         a_previous_exam_lib_6->request_date_time = lib->last_exam[6].request_date_time,
         a_previous_exam_lib_6->exam_status = lib->last_exam[6].exam_status
        ENDIF
        IF (size(lib->last_exam,5) > 6)
         a_previous_exam_lib_7->complete_date_time = lib->last_exam[7].complete_date_time,
         a_previous_exam_lib_7->exam_name = lib->last_exam[7].exam_name, a_previous_exam_lib_7->
         image_class_type_display = lib->last_exam[7].image_class_type_display,
         a_previous_exam_lib_7->image_class_type_description = lib->last_exam[7].
         image_class_type_description, a_previous_exam_lib_7->completing_location_display = lib->
         last_exam[7].completing_location_display, a_previous_exam_lib_7->
         completing_location_description = lib->last_exam[7].completing_location_description,
         a_previous_exam_lib_7->facility_display = lib->last_exam[7].facility_display,
         a_previous_exam_lib_7->facility_description = lib->last_exam[7].facility_description,
         a_previous_exam_lib_7->accession = formataccession(lib->last_exam[7].accession),
         a_previous_exam_lib_7->transcribe_date_time = lib->last_exam[7].transcribe_date_time,
         a_previous_exam_lib_7->final_date_time = lib->last_exam[7].final_date_time,
         a_previous_exam_lib_7->request_date_time = lib->last_exam[7].request_date_time,
         a_previous_exam_lib_7->exam_status = lib->last_exam[7].exam_status
        ENDIF
        IF (size(lib->last_exam,5) > 7)
         a_previous_exam_lib_8->complete_date_time = lib->last_exam[8].complete_date_time,
         a_previous_exam_lib_8->exam_name = lib->last_exam[8].exam_name, a_previous_exam_lib_8->
         image_class_type_display = lib->last_exam[8].image_class_type_display,
         a_previous_exam_lib_8->image_class_type_description = lib->last_exam[8].
         image_class_type_description, a_previous_exam_lib_8->completing_location_display = lib->
         last_exam[8].completing_location_display, a_previous_exam_lib_8->
         completing_location_description = lib->last_exam[8].completing_location_description,
         a_previous_exam_lib_8->facility_display = lib->last_exam[8].facility_display,
         a_previous_exam_lib_8->facility_description = lib->last_exam[8].facility_description,
         a_previous_exam_lib_8->accession = formataccession(lib->last_exam[8].accession),
         a_previous_exam_lib_8->transcribe_date_time = lib->last_exam[8].transcribe_date_time,
         a_previous_exam_lib_8->final_date_time = lib->last_exam[8].final_date_time,
         a_previous_exam_lib_8->request_date_time = lib->last_exam[8].request_date_time,
         a_previous_exam_lib_8->exam_status = lib->last_exam[8].exam_status
        ENDIF
        IF (size(lib->last_exam,5) > 8)
         a_previous_exam_lib_9->complete_date_time = lib->last_exam[9].complete_date_time,
         a_previous_exam_lib_9->exam_name = lib->last_exam[9].exam_name, a_previous_exam_lib_9->
         image_class_type_display = lib->last_exam[9].image_class_type_display,
         a_previous_exam_lib_9->image_class_type_description = lib->last_exam[9].
         image_class_type_description, a_previous_exam_lib_9->completing_location_display = lib->
         last_exam[9].completing_location_display, a_previous_exam_lib_9->
         completing_location_description = lib->last_exam[9].completing_location_description,
         a_previous_exam_lib_9->facility_display = lib->last_exam[9].facility_display,
         a_previous_exam_lib_9->facility_description = lib->last_exam[9].facility_description,
         a_previous_exam_lib_9->accession = formataccession(lib->last_exam[9].accession),
         a_previous_exam_lib_9->transcribe_date_time = lib->last_exam[9].transcribe_date_time,
         a_previous_exam_lib_9->final_date_time = lib->last_exam[9].final_date_time,
         a_previous_exam_lib_9->request_date_time = lib->last_exam[9].request_date_time,
         a_previous_exam_lib_9->exam_status = lib->last_exam[9].exam_status
        ENDIF
        IF (size(lib->last_exam,5) > 9)
         a_previous_exam_lib_10->complete_date_time = lib->last_exam[10].complete_date_time,
         a_previous_exam_lib_10->exam_name = lib->last_exam[10].exam_name, a_previous_exam_lib_10->
         image_class_type_display = lib->last_exam[10].image_class_type_display,
         a_previous_exam_lib_10->image_class_type_description = lib->last_exam[10].
         image_class_type_description, a_previous_exam_lib_10->completing_location_display = lib->
         last_exam[10].completing_location_display, a_previous_exam_lib_10->
         completing_location_description = lib->last_exam[10].completing_location_description,
         a_previous_exam_lib_10->facility_display = lib->last_exam[10].facility_display,
         a_previous_exam_lib_10->facility_description = lib->last_exam[10].facility_description,
         a_previous_exam_lib_10->accession = formataccession(lib->last_exam[10].accession),
         a_previous_exam_lib_10->transcribe_date_time = lib->last_exam[10].transcribe_date_time,
         a_previous_exam_lib_10->final_date_time = lib->last_exam[10].final_date_time,
         a_previous_exam_lib_10->request_date_time = lib->last_exam[10].request_date_time,
         a_previous_exam_lib_10->exam_status = lib->last_exam[10].exam_status
        ENDIF
        IF (size(act->last_exam,5) > 0)
         a_previous_exam_act_1->complete_date_time = act->last_exam[1].complete_date_time,
         a_previous_exam_act_1->exam_name = act->last_exam[1].exam_name, a_previous_exam_act_1->
         image_class_type_display = act->last_exam[1].image_class_type_display,
         a_previous_exam_act_1->image_class_type_description = act->last_exam[1].
         image_class_type_description, a_previous_exam_act_1->completing_location_display = act->
         last_exam[1].completing_location_display, a_previous_exam_act_1->
         completing_location_description = act->last_exam[1].completing_location_description,
         a_previous_exam_act_1->facility_display = act->last_exam[1].facility_display,
         a_previous_exam_act_1->facility_description = act->last_exam[1].facility_description,
         a_previous_exam_act_1->accession = formataccession(act->last_exam[1].accession),
         a_previous_exam_act_1->transcribe_date_time = act->last_exam[1].transcribe_date_time,
         a_previous_exam_act_1->final_date_time = act->last_exam[1].final_date_time,
         a_previous_exam_act_1->request_date_time = act->last_exam[1].request_date_time,
         a_previous_exam_act_1->exam_status = act->last_exam[1].exam_status,
         CALL echo(build("Previous1 ACT ---->",a_previous_exam_act_1->complete_date_time)),
         CALL echo(build("Previous1 ACT ---->",a_previous_exam_act_1->exam_name)),
         CALL echo(build("Previous1 ACT ---->",a_previous_exam_act_1->image_class_type_display)),
         CALL echo(build("Previous1 ACT ---->",a_previous_exam_act_1->image_class_type_description)),
         CALL echo(build("Previous1 ACT ---->",a_previous_exam_act_1->completing_location_display)),
         CALL echo(build("Previous1 ACT ---->",a_previous_exam_act_1->completing_location_description
          )),
         CALL echo(build("Previous1 ACT ---->",a_previous_exam_act_1->facility_display)),
         CALL echo(build("Previous1 ACT ---->",a_previous_exam_act_1->facility_description)),
         CALL echo(build("Previous1 ACT ---->",a_previous_exam_act_1->accession)),
         CALL echo(build("Previous1 ACT ---->",a_previous_exam_act_1->transcribe_date_time)),
         CALL echo(build("Previous1 ACT ---->",a_previous_exam_act_1->final_date_time)),
         CALL echo(build("Previous1 ACT ---->",a_previous_exam_act_1->request_date_time)),
         CALL echo(build("Previous1 ACT ---->",a_previous_exam_act_1->exam_status))
        ENDIF
        IF (size(act->last_exam,5) > 1)
         a_previous_exam_act_2->complete_date_time = act->last_exam[2].complete_date_time,
         a_previous_exam_act_2->exam_name = act->last_exam[2].exam_name, a_previous_exam_act_2->
         image_class_type_display = act->last_exam[2].image_class_type_display,
         a_previous_exam_act_2->image_class_type_description = act->last_exam[2].
         image_class_type_description, a_previous_exam_act_2->completing_location_display = act->
         last_exam[2].completing_location_display, a_previous_exam_act_2->
         completing_location_description = act->last_exam[2].completing_location_description,
         a_previous_exam_act_2->facility_display = act->last_exam[2].facility_display,
         a_previous_exam_act_2->facility_description = act->last_exam[2].facility_description,
         a_previous_exam_act_2->accession = formataccession(act->last_exam[2].accession),
         a_previous_exam_act_2->transcribe_date_time = act->last_exam[2].transcribe_date_time,
         a_previous_exam_act_2->final_date_time = act->last_exam[2].final_date_time,
         a_previous_exam_act_2->request_date_time = act->last_exam[2].request_date_time,
         a_previous_exam_act_2->exam_status = act->last_exam[2].exam_status,
         CALL echo(build("Previous2 ACT ---->",a_previous_exam_act_2->exam_name))
        ENDIF
        IF (size(act->last_exam,5) > 2)
         a_previous_exam_act_3->complete_date_time = act->last_exam[3].complete_date_time,
         a_previous_exam_act_3->exam_name = act->last_exam[3].exam_name,
         CALL echo(build("Previous3 ACT ---->",a_previous_exam_act_3->exam_name)),
         a_previous_exam_act_3->image_class_type_display = act->last_exam[3].image_class_type_display,
         a_previous_exam_act_3->image_class_type_description = act->last_exam[3].
         image_class_type_description, a_previous_exam_act_3->completing_location_display = act->
         last_exam[3].completing_location_display,
         a_previous_exam_act_3->completing_location_description = act->last_exam[3].
         completing_location_description, a_previous_exam_act_3->facility_display = act->last_exam[3]
         .facility_display, a_previous_exam_act_3->facility_description = act->last_exam[3].
         facility_description,
         a_previous_exam_act_3->accession = formataccession(act->last_exam[3].accession),
         a_previous_exam_act_3->transcribe_date_time = act->last_exam[3].transcribe_date_time,
         a_previous_exam_act_3->final_date_time = act->last_exam[3].final_date_time,
         a_previous_exam_act_3->request_date_time = act->last_exam[3].request_date_time,
         a_previous_exam_act_3->exam_status = act->last_exam[3].exam_status
        ENDIF
        IF (size(act->last_exam,5) > 3)
         a_previous_exam_act_4->complete_date_time = act->last_exam[4].complete_date_time,
         a_previous_exam_act_4->exam_name = act->last_exam[4].exam_name, a_previous_exam_act_4->
         image_class_type_display = act->last_exam[4].image_class_type_display,
         a_previous_exam_act_4->image_class_type_description = act->last_exam[4].
         image_class_type_description, a_previous_exam_act_4->completing_location_display = act->
         last_exam[4].completing_location_display, a_previous_exam_act_4->
         completing_location_description = act->last_exam[4].completing_location_description,
         a_previous_exam_act_4->facility_display = act->last_exam[4].facility_display,
         a_previous_exam_act_4->facility_description = act->last_exam[4].facility_description,
         a_previous_exam_act_4->accession = formataccession(act->last_exam[4].accession),
         a_previous_exam_act_4->transcribe_date_time = act->last_exam[4].transcribe_date_time,
         a_previous_exam_act_4->final_date_time = act->last_exam[4].final_date_time,
         a_previous_exam_act_4->request_date_time = act->last_exam[4].request_date_time,
         a_previous_exam_act_4->exam_status = act->last_exam[4].exam_status
        ENDIF
        IF (size(act->last_exam,5) > 4)
         a_previous_exam_act_5->complete_date_time = act->last_exam[5].complete_date_time,
         a_previous_exam_act_5->exam_name = act->last_exam[5].exam_name, a_previous_exam_act_5->
         image_class_type_display = act->last_exam[5].image_class_type_display,
         a_previous_exam_act_5->image_class_type_description = act->last_exam[5].
         image_class_type_description, a_previous_exam_act_5->completing_location_display = act->
         last_exam[5].completing_location_display, a_previous_exam_act_5->
         completing_location_description = act->last_exam[5].completing_location_description,
         a_previous_exam_act_5->facility_display = act->last_exam[5].facility_display,
         a_previous_exam_act_5->facility_description = act->last_exam[5].facility_description,
         a_previous_exam_act_5->accession = formataccession(act->last_exam[5].accession),
         a_previous_exam_act_5->transcribe_date_time = act->last_exam[5].transcribe_date_time,
         a_previous_exam_act_5->final_date_time = act->last_exam[5].final_date_time,
         a_previous_exam_act_5->request_date_time = act->last_exam[5].request_date_time,
         a_previous_exam_act_5->exam_status = act->last_exam[5].exam_status
        ENDIF
        IF (size(act->last_exam,5) > 5)
         a_previous_exam_act_6->complete_date_time = act->last_exam[6].complete_date_time,
         a_previous_exam_act_6->exam_name = act->last_exam[6].exam_name, a_previous_exam_act_6->
         image_class_type_display = act->last_exam[6].image_class_type_display,
         a_previous_exam_act_6->image_class_type_description = act->last_exam[6].
         image_class_type_description, a_previous_exam_act_6->completing_location_display = act->
         last_exam[6].completing_location_display, a_previous_exam_act_6->
         completing_location_description = act->last_exam[6].completing_location_description,
         a_previous_exam_act_6->facility_display = act->last_exam[6].facility_display,
         a_previous_exam_act_6->facility_description = act->last_exam[6].facility_description,
         a_previous_exam_act_6->accession = formataccession(act->last_exam[6].accession),
         a_previous_exam_act_6->transcribe_date_time = act->last_exam[6].transcribe_date_time,
         a_previous_exam_act_6->final_date_time = act->last_exam[6].final_date_time,
         a_previous_exam_act_6->request_date_time = act->last_exam[6].request_date_time,
         a_previous_exam_act_6->exam_status = act->last_exam[6].exam_status
        ENDIF
        IF (size(act->last_exam,5) > 6)
         a_previous_exam_act_7->complete_date_time = act->last_exam[7].complete_date_time,
         a_previous_exam_act_7->exam_name = act->last_exam[7].exam_name, a_previous_exam_act_7->
         image_class_type_display = act->last_exam[7].image_class_type_display,
         a_previous_exam_act_7->image_class_type_description = act->last_exam[7].
         image_class_type_description, a_previous_exam_act_7->completing_location_display = act->
         last_exam[7].completing_location_display, a_previous_exam_act_7->
         completing_location_description = act->last_exam[7].completing_location_description,
         a_previous_exam_act_7->facility_display = act->last_exam[7].facility_display,
         a_previous_exam_act_7->facility_description = act->last_exam[7].facility_description,
         a_previous_exam_act_7->accession = formataccession(act->last_exam[7].accession),
         a_previous_exam_act_7->transcribe_date_time = act->last_exam[7].transcribe_date_time,
         a_previous_exam_act_7->final_date_time = act->last_exam[7].final_date_time,
         a_previous_exam_act_7->request_date_time = act->last_exam[7].request_date_time,
         a_previous_exam_act_7->exam_status = act->last_exam[7].exam_status
        ENDIF
        IF (size(act->last_exam,5) > 7)
         a_previous_exam_act_8->complete_date_time = act->last_exam[8].complete_date_time,
         a_previous_exam_act_8->exam_name = act->last_exam[8].exam_name, a_previous_exam_act_8->
         image_class_type_display = act->last_exam[8].image_class_type_display,
         a_previous_exam_act_8->image_class_type_description = act->last_exam[8].
         image_class_type_description, a_previous_exam_act_8->completing_location_display = act->
         last_exam[8].completing_location_display, a_previous_exam_act_8->
         completing_location_description = act->last_exam[8].completing_location_description,
         a_previous_exam_act_8->facility_display = act->last_exam[8].facility_display,
         a_previous_exam_act_8->facility_description = act->last_exam[8].facility_description,
         a_previous_exam_act_8->accession = formataccession(act->last_exam[8].accession),
         a_previous_exam_act_8->transcribe_date_time = act->last_exam[8].transcribe_date_time,
         a_previous_exam_act_8->final_date_time = act->last_exam[8].final_date_time,
         a_previous_exam_act_8->request_date_time = act->last_exam[8].request_date_time,
         a_previous_exam_act_8->exam_status = act->last_exam[8].exam_status
        ENDIF
        IF (size(act->last_exam,5) > 8)
         a_previous_exam_act_9->complete_date_time = act->last_exam[9].complete_date_time,
         a_previous_exam_act_9->exam_name = act->last_exam[9].exam_name, a_previous_exam_act_9->
         image_class_type_display = act->last_exam[9].image_class_type_display,
         a_previous_exam_act_9->image_class_type_description = act->last_exam[9].
         image_class_type_description, a_previous_exam_act_9->completing_location_display = act->
         last_exam[9].completing_location_display, a_previous_exam_act_9->
         completing_location_description = act->last_exam[9].completing_location_description,
         a_previous_exam_act_9->facility_display = act->last_exam[9].facility_display,
         a_previous_exam_act_9->facility_description = act->last_exam[9].facility_description,
         a_previous_exam_act_9->accession = formataccession(act->last_exam[9].accession),
         a_previous_exam_act_9->transcribe_date_time = act->last_exam[9].transcribe_date_time,
         a_previous_exam_act_9->final_date_time = act->last_exam[9].final_date_time,
         a_previous_exam_act_9->request_date_time = act->last_exam[9].request_date_time,
         a_previous_exam_act_9->exam_status = act->last_exam[9].exam_status
        ENDIF
        IF (size(act->last_exam,5) > 9)
         a_previous_exam_act_10->complete_date_time = act->last_exam[10].complete_date_time,
         a_previous_exam_act_10->exam_name = act->last_exam[10].exam_name, a_previous_exam_act_10->
         image_class_type_display = act->last_exam[10].image_class_type_display,
         a_previous_exam_act_10->image_class_type_description = act->last_exam[10].
         image_class_type_description, a_previous_exam_act_10->completing_location_display = act->
         last_exam[10].completing_location_display, a_previous_exam_act_10->
         completing_location_description = act->last_exam[10].completing_location_description,
         a_previous_exam_act_10->facility_display = act->last_exam[10].facility_display,
         a_previous_exam_act_10->facility_description = act->last_exam[10].facility_description,
         a_previous_exam_act_10->accession = formataccession(act->last_exam[10].accession),
         a_previous_exam_act_10->transcribe_date_time = act->last_exam[10].transcribe_date_time,
         a_previous_exam_act_10->final_date_time = act->last_exam[10].final_date_time,
         a_previous_exam_act_10->request_date_time = act->last_exam[10].request_date_time,
         a_previous_exam_act_10->exam_status = act->last_exam[10].exam_status
        ENDIF
        CALL echo("*****START OF MODIFY/REPRINT DATA*****")
        IF (modify_flag=1)
         a_mod->status = "MODIFIED"
        ENDIF
        IF ((working_array->reprint_flag="Y"))
         a_mod->reprint = "REPRINT"
        ENDIF
        CALL echo("*****START OF OTHER EXAMS DATA*****")
        IF (size(data->req[req_ndx].other_exams,5) > 0)
         IF (size(trim(data->req[req_ndx].other_exams[1].catalog_mnemonic)) > 0)
          a_other_exam_1->other_name_1 = data->req[req_ndx].other_exams[1].catalog_mnemonic,
          a_other_exam_1->other_accession_1 = formataccession(data->req[req_ndx].other_exams[1].
           accession)
         ELSE
          a_other_exam_1->other_name_1 = " ", a_other_exam_1->other_accession_1 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].other_exams,5) > 1)
         IF (size(trim(data->req[req_ndx].other_exams[2].catalog_mnemonic)) > 0)
          a_other_exam_2->other_name_2 = data->req[req_ndx].other_exams[2].catalog_mnemonic,
          a_other_exam_2->other_accession_2 = formataccession(data->req[req_ndx].other_exams[2].
           accession)
         ELSE
          a_other_exam_2->other_name_2 = " ", a_other_exam_2->other_accession_2 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].other_exams,5) > 2)
         IF (size(trim(data->req[req_ndx].other_exams[3].catalog_mnemonic)) > 0)
          a_other_exam_3->other_name_3 = data->req[req_ndx].other_exams[3].catalog_mnemonic,
          a_other_exam_3->other_accession_3 = formataccession(data->req[req_ndx].other_exams[3].
           accession)
         ELSE
          a_other_exam_3->other_name_3 = " ", a_other_exam_3->other_accession_3 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].other_exams,5) > 3)
         IF (size(trim(data->req[req_ndx].other_exams[4].catalog_mnemonic)) > 0)
          a_other_exam_4->other_name_4 = data->req[req_ndx].other_exams[4].catalog_mnemonic,
          a_other_exam_4->other_accession_4 = formataccession(data->req[req_ndx].other_exams[4].
           accession)
         ELSE
          a_other_exam_4->other_name_4 = " ", a_other_exam_4->other_accession_4 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].other_exams,5) > 4)
         IF (size(trim(data->req[req_ndx].other_exams[5].catalog_mnemonic)) > 0)
          a_other_exam_5->other_name_5 = data->req[req_ndx].other_exams[5].catalog_mnemonic,
          a_other_exam_5->other_accession_5 = formataccession(data->req[req_ndx].other_exams[5].
           accession)
         ELSE
          a_other_exam_5->other_name_5 = " ", a_other_exam_5->other_accession_5 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].other_exams,5) > 5)
         IF (size(trim(data->req[req_ndx].other_exams[6].catalog_mnemonic)) > 0)
          a_other_exam_6->other_name_6 = data->req[req_ndx].other_exams[6].catalog_mnemonic,
          a_other_exam_6->other_accession_6 = formataccession(data->req[req_ndx].other_exams[6].
           accession)
         ELSE
          a_other_exam_6->other_name_6 = " ", a_other_exam_6->other_accession_6 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].other_exams,5) > 6)
         IF (size(trim(data->req[req_ndx].other_exams[7].catalog_mnemonic)) > 0)
          a_other_exam_7->other_name_7 = data->req[req_ndx].other_exams[7].catalog_mnemonic,
          a_other_exam_7->other_accession_7 = formataccession(data->req[req_ndx].other_exams[7].
           accession)
         ELSE
          a_other_exam_7->other_name_7 = " ", a_other_exam_7->other_accession_7 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].other_exams,5) > 7)
         IF (size(trim(data->req[req_ndx].other_exams[8].catalog_mnemonic)) > 0)
          a_other_exam_8->other_name_8 = data->req[req_ndx].other_exams[8].catalog_mnemonic,
          a_other_exam_8->other_accession_8 = formataccession(data->req[req_ndx].other_exams[8].
           accession)
         ELSE
          a_other_exam_8->other_name_8 = " ", a_other_exam_8->other_accession_8 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].other_exams,5) > 8)
         IF (size(trim(data->req[req_ndx].other_exams[9].catalog_mnemonic)) > 0)
          a_other_exam_9->other_name_9 = data->req[req_ndx].other_exams[9].catalog_mnemonic,
          a_other_exam_9->other_accession_9 = formataccession(data->req[req_ndx].other_exams[9].
           accession)
         ELSE
          a_other_exam_9->other_name_9 = " ", a_other_exam_9->other_accession_9 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].other_exams,5) > 9)
         IF (size(trim(data->req[req_ndx].other_exams[10].catalog_mnemonic)) > 0)
          a_other_exam_10->other_name_10 = data->req[req_ndx].other_exams[10].catalog_mnemonic,
          a_other_exam_10->other_accession_10 = formataccession(data->req[req_ndx].other_exams[10].
           accession)
         ELSE
          a_other_exam_10->other_name_10 = " ", a_other_exam_10->other_accession_10 = " "
         ENDIF
        ENDIF
        CALL echo("*****START OF PACS ID DATA*****")
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 0)
         IF ((data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].pacs_id > 0)
         )
          a_pacs->pacs_id_1 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
           for_this_page[exam_ndx].pacs_id), a_pacs->bc_pacs_id_1 = concat("*",trim(a_pacs->pacs_id_1
            ),"*")
         ELSE
          a_pacs->pacs_id_1 = " ", a_pacs->bc_pacs_id_1 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 1)
         IF ((data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 1)].pacs_id
          > 1))
          a_pacs->pacs_id_2 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
           for_this_page[(exam_ndx+ 1)].pacs_id), a_pacs->bc_pacs_id_2 = concat("*",trim(a_pacs->
            pacs_id_2),"*")
         ELSE
          a_pacs->pacs_id_2 = " ", a_pacs->bc_pacs_id_2 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 2)
         IF ((data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 2)].pacs_id
          > 0))
          a_pacs->pacs_id_3 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
           for_this_page[(exam_ndx+ 2)].pacs_id), a_pacs->bc_pacs_id_3 = concat("*",trim(a_pacs->
            pacs_id_3),"*")
         ELSE
          a_pacs->pacs_id_3 = " ", a_pacs->bc_pacs_id_3 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 3)
         IF ((data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 3)].pacs_id
          > 0))
          a_pacs->pacs_id_4 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
           for_this_page[(exam_ndx+ 3)].pacs_id), a_pacs->bc_pacs_id_4 = concat("*",trim(a_pacs->
            pacs_id_4),"*")
         ELSE
          a_pacs->pacs_id_4 = " ", a_pacs->bc_pacs_id_4 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 4)
         IF ((data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 4)].pacs_id
          > 0))
          a_pacs->pacs_id_5 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
           for_this_page[(exam_ndx+ 4)].pacs_id), a_pacs->bc_pacs_id_5 = concat("*",trim(a_pacs->
            pacs_id_5),"*")
         ELSE
          a_pacs->pacs_id_5 = " ", a_pacs->bc_pacs_id_5 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 5)
         IF ((data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 5)].pacs_id
          > 0))
          a_pacs->pacs_id_6 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
           for_this_page[(exam_ndx+ 5)].pacs_id), a_pacs->bc_pacs_id_6 = concat("*",trim(a_pacs->
            pacs_id_6),"*")
         ELSE
          a_pacs->pacs_id_6 = " ", a_pacs->bc_pacs_id_6 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 6)
         IF ((data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 6)].pacs_id
          > 0))
          a_pacs->pacs_id_7 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
           for_this_page[(exam_ndx+ 6)].pacs_id), a_pacs->bc_pacs_id_7 = concat("*",trim(a_pacs->
            pacs_id_7),"*")
         ELSE
          a_pacs->pacs_id_7 = " ", a_pacs->bc_pacs_id_7 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 7)
         IF ((data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 7)].pacs_id
          > 0))
          a_pacs->pacs_id_8 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
           for_this_page[(exam_ndx+ 7)].pacs_id), a_pacs->bc_pacs_id_8 = concat("*",trim(a_pacs->
            pacs_id_8),"*")
         ELSE
          a_pacs->pacs_id_8 = " ", a_pacs->bc_pacs_id_8 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 8)
         IF ((data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 8)].pacs_id
          > 0))
          a_pacs->pacs_id_9 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
           for_this_page[(exam_ndx+ 8)].pacs_id), a_pacs->bc_pacs_id_9 = concat("*",trim(a_pacs->
            pacs_id_9),"*")
         ELSE
          a_pacs->pacs_id_9 = " ", a_pacs->bc_pacs_id_9 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page,5) > 9)
         IF ((data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[(exam_ndx+ 9)].pacs_id
          > 0))
          a_pacs->pacs_id_10 = cnvtstring(data->req[req_ndx].sections[sect_ndx].exam_data[x].
           for_this_page[(exam_ndx+ 9)].pacs_id), a_pacs->bc_pacs_id_10 = concat("*",trim(a_pacs->
            pacs_id_10),"*")
         ELSE
          a_pacs->pacs_id_10 = " ", a_pacs->bc_pacs_id_10 = " "
         ENDIF
        ENDIF
        CALL echo("*****START OF PATIENT DATA *****"), a_pat_data->person_id = data->req[req_ndx].
        patient_data.person_id, a_pat_data->full_name = data->req[req_ndx].patient_data.name,
        CALL echo(build("Patient Name ------->",a_pat_data->full_name)),
        CALL echo(build("From Get Info------->",data->req[req_ndx].patient_data.name)), a_pat_data->
        last_name = data->req[req_ndx].patient_data.name_last,
        a_pat_data->first_name = data->req[req_ndx].patient_data.name_first, a_pat_data->mid_name =
        data->req[req_ndx].patient_data.name_middle, a_pat_data->dob = data->req[req_ndx].
        patient_data.dob,
        a_pat_data->age = data->req[req_ndx].patient_data.age, a_pat_data->short_age = data->req[
        req_ndx].patient_data.short_age, a_pat_data->gender = data->req[req_ndx].patient_data.gender,
        a_pat_data->short_gender = data->req[req_ndx].patient_data.short_gender, a_pat_data->race =
        data->req[req_ndx].patient_data.race, a_pat_data->encounter_id = data->req[req_ndx].
        patient_data.encntr_id,
        a_pat_data->location = data->req[req_ndx].patient_data.location, a_pat_data->pat_type = data
        ->req[req_ndx].patient_data.encntr_type_disp, a_pat_data->arrival_date = data->req[req_ndx].
        patient_data.date_of_arrival,
        a_pat_data->facility = data->req[req_ndx].patient_data.facility, a_pat_data->building = data
        ->req[req_ndx].patient_data.building, a_pat_data->nurse_unit = data->req[req_ndx].
        patient_data.nurse_unit,
        a_pat_data->nurse_unit_phone = data->req[req_ndx].patient_data.nurse_unit_phone, a_pat_data->
        room = data->req[req_ndx].patient_data.room, a_pat_data->bed = data->req[req_ndx].
        patient_data.bed,
        a_pat_data->admitting_diag = data->req[req_ndx].patient_data.reason_for_visit, a_pat_data->
        isolation = data->req[req_ndx].patient_data.isolation, a_pat_data->med_service = data->req[
        req_ndx].patient_data.med_service,
        a_pat_data->fin_class = data->req[req_ndx].patient_data.financial_class, a_pat_data->client
         = data->req[req_ndx].patient_data.client, a_pat_data->ssn = data->req[req_ndx].patient_data.
        person_ssn,
        a_pat_data->cmrn = data->req[req_ndx].patient_data.community_med_nbr, a_pat_data->med_nbr =
        data->req[req_ndx].patient_data.person_alias
        IF (size(trim(data->req[req_ndx].patient_data.person_alias)) > 0)
         a_pat_data->bc_med_nbr = concat("*",trim(data->req[req_ndx].patient_data.person_alias),"*")
        ELSE
         a_pat_data->bc_med_nbr = " "
        ENDIF
        a_pat_data->fin_nbr = data->req[req_ndx].patient_data.fin_nbr_alias
        IF (size(data->req[req_ndx].patient_data.fin_nbr_alias) > 0)
         a_pat_data->bc_fin_nbr = concat("*",a_pat_data->fin_nbr,"*")
        ELSE
         a_pat_data->bc_fin_nbr = " "
        ENDIF
        a_pat_data->home_phone = data->req[req_ndx].patient_data.phone, a_pat_data->work_phone = data
        ->req[req_ndx].patient_data.work_phone, a_pat_data->address = data->req[req_ndx].patient_data
        .address[1].street_addr,
        a_pat_data->city = data->req[req_ndx].patient_data.address[1].city, a_pat_data->state = data
        ->req[req_ndx].patient_data.address[1].state, a_pat_data->zip = data->req[req_ndx].
        patient_data.address[1].zipcode,
        CALL echo("*****START OF PHYSICIAN DATA*****")
        IF (size(data->req[req_ndx].patient_data.admit_phy_name) > 0)
         a_doc->admit_doc_name = data->req[req_ndx].patient_data.admit_phy_name
        ELSE
         a_doc->admit_doc_name = " "
        ENDIF
        IF (size(data->req[req_ndx].patient_data.admit_phy_phone) > 0)
         a_doc->admit_doc_phone = data->req[req_ndx].patient_data.admit_phy_phone
        ELSE
         a_doc->admit_doc_phone = " "
        ENDIF
        IF (size(data->req[req_ndx].patient_data.admit_phy_fax) > 0)
         a_doc->admit_doc_fax = data->req[req_ndx].patient_data.admit_phy_fax
        ELSE
         a_doc->admit_doc_fax = " "
        ENDIF
        IF (size(data->req[req_ndx].patient_data.admit_phy_pager) > 0)
         a_doc->admit_doc_pager = data->req[req_ndx].patient_data.admit_phy_pager
        ELSE
         a_doc->admit_doc_pager = " "
        ENDIF
        IF (size(data->req[req_ndx].patient_data.refer_phy_name) > 0)
         a_doc->refer_doc_name = data->req[req_ndx].patient_data.refer_phy_name
        ELSE
         a_doc->refer_doc_name = " "
        ENDIF
        IF (size(data->req[req_ndx].patient_data.refer_phy_phone) > 0)
         a_doc->refer_doc_phone = data->req[req_ndx].patient_data.refer_phy_phone
        ELSE
         a_doc->refer_doc_phone = " "
        ENDIF
        IF (size(data->req[req_ndx].patient_data.refer_phy_fax) > 0)
         a_doc->refer_doc_fax = data->req[req_ndx].patient_data.refer_phy_fax
        ELSE
         a_doc->refer_doc_fax = " "
        ENDIF
        IF (size(data->req[req_ndx].patient_data.refer_phy_pager) > 0)
         a_doc->refer_doc_pager = data->req[req_ndx].patient_data.refer_phy_pager
        ELSE
         a_doc->refer_doc_pager = " "
        ENDIF
        IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
          order_physician)) > 0)
         a_doc->order_doc_name = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
         exam_ndx].order_physician
        ELSE
         a_doc->order_doc_name = " "
        ENDIF
        IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
          order_phy_phone)) > 0)
         a_doc->order_doc_phone = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
         exam_ndx].order_phy_phone
        ELSE
         a_doc->order_doc_phone = " "
        ENDIF
        IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
          order_phy_phone)) > 0)
         a_doc->order_doc_fax = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
         exam_ndx].order_phy_fax
        ELSE
         a_doc->order_doc_fax = " "
        ENDIF
        IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
          order_phy_phone)) > 0)
         a_doc->order_doc_pager = data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[
         exam_ndx].order_phy_pager
        ELSE
         a_doc->order_doc_pager = " "
        ENDIF
        IF (size(data->req[req_ndx].patient_data.attend_phy_name) > 0)
         a_doc->attend_doc_name = data->req[req_ndx].patient_data.attend_phy_name
        ELSE
         a_doc->attend_doc_name = " "
        ENDIF
        IF (size(data->req[req_ndx].patient_data.attend_phy_phone) > 0)
         a_doc->attend_doc_phone = data->req[req_ndx].patient_data.attend_phy_phone
        ELSE
         a_doc->attend_doc_phone = " "
        ENDIF
        IF (size(data->req[req_ndx].patient_data.attend_phy_fax) > 0)
         a_doc->attend_doc_fax = data->req[req_ndx].patient_data.attend_phy_fax
        ELSE
         a_doc->attend_doc_fax = " "
        ENDIF
        IF (size(data->req[req_ndx].patient_data.attend_phy_pager) > 0)
         a_doc->attend_doc_pager = data->req[req_ndx].patient_data.attend_phy_pager
        ELSE
         a_doc->attend_doc_pager = " "
        ENDIF
        IF (size(data->req[req_ndx].patient_data.family_phy_name) > 0)
         a_doc->family_doc_name = data->req[req_ndx].patient_data.family_phy_name
        ELSE
         a_doc->family_doc_name = " "
        ENDIF
        IF (size(data->req[req_ndx].patient_data.family_phy_phone) > 0)
         a_doc->family_doc_phone = data->req[req_ndx].patient_data.family_phy_phone
        ELSE
         a_doc->family_doc_phone = " "
        ENDIF
        IF (size(data->req[req_ndx].patient_data.family_phy_fax) > 0)
         a_doc->family_doc_fax = data->req[req_ndx].patient_data.family_phy_fax
        ELSE
         a_doc->family_doc_fax = " "
        ENDIF
        IF (size(data->req[req_ndx].patient_data.family_phy_pager) > 0)
         a_doc->family_doc_pager = data->req[req_ndx].patient_data.family_phy_pager
        ELSE
         a_doc->family_doc_pager = " "
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         consult_doc,5) > 0)
         IF (trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
          consult_doc[1].consult_phy_name) != " ")
          a_doc->consult_doc_name_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].consult_doc[1].consult_phy_name
         ELSE
          a_doc->consult_doc_name_1 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           consult_doc[1].consult_phy_phone)) > 0)
          a_doc->consult_doc_phone_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].consult_doc[1].consult_phy_phone
         ELSE
          a_doc->consult_doc_phone_1 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           consult_doc[1].consult_phy_pager)) > 0)
          a_doc->consult_doc_pager_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].consult_doc[1].consult_phy_pager
         ELSE
          a_doc->consult_doc_pager_1 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           consult_doc[1].consult_phy_fax)) > 0)
          a_doc->consult_doc_fax_1 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].consult_doc[1].consult_phy_fax
         ELSE
          a_doc->consult_doc_fax_1 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         consult_doc,5) > 1)
         IF (trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
          consult_doc[2].consult_phy_name) != " ")
          a_doc->consult_doc_name_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].consult_doc[2].consult_phy_name
         ELSE
          a_doc->consult_doc_name_2 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           consult_doc[2].consult_phy_phone)) > 0)
          a_doc->consult_doc_phone_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].consult_doc[2].consult_phy_phone
         ELSE
          a_doc->consult_doc_phone_2 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           consult_doc[2].consult_phy_pager)) > 0)
          a_doc->consult_doc_pager_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].consult_doc[2].consult_phy_pager
         ELSE
          a_doc->consult_doc_pager_2 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           consult_doc[2].consult_phy_fax)) > 0)
          a_doc->consult_doc_fax_2 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].consult_doc[2].consult_phy_fax
         ELSE
          a_doc->consult_doc_fax_2 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         consult_doc,5) > 2)
         IF (trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
          consult_doc[3].consult_phy_name) != " ")
          a_doc->consult_doc_name_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].consult_doc[3].consult_phy_name
         ELSE
          a_doc->consult_doc_name_3 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           consult_doc[3].consult_phy_phone)) > 0)
          a_doc->consult_doc_phone_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].consult_doc[3].consult_phy_phone
         ELSE
          a_doc->consult_doc_phone_3 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           consult_doc[3].consult_phy_pager)) > 0)
          a_doc->consult_doc_pager_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].consult_doc[3].consult_phy_pager
         ELSE
          a_doc->consult_doc_pager_3 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           consult_doc[3].consult_phy_fax)) > 0)
          a_doc->consult_doc_fax_3 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].consult_doc[3].consult_phy_fax
         ELSE
          a_doc->consult_doc_fax_3 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         consult_doc,5) > 3)
         IF (trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
          consult_doc[4].consult_phy_name) != " ")
          a_doc->consult_doc_name_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].consult_doc[4].consult_phy_name
         ELSE
          a_doc->consult_doc_name_4 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           consult_doc[4].consult_phy_phone)) > 0)
          a_doc->consult_doc_phone_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].consult_doc[4].consult_phy_phone
         ELSE
          a_doc->consult_doc_phone_4 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           consult_doc[4].consult_phy_pager)) > 0)
          a_doc->consult_doc_pager_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].consult_doc[4].consult_phy_pager
         ELSE
          a_doc->consult_doc_pager_4 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           consult_doc[4].consult_phy_fax)) > 0)
          a_doc->consult_doc_fax_4 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].consult_doc[4].consult_phy_fax
         ELSE
          a_doc->consult_doc_fax_4 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         consult_doc,5) > 4)
         IF (trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
          consult_doc[5].consult_phy_name) != " ")
          a_doc->consult_doc_name_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].consult_doc[5].consult_phy_name
         ELSE
          a_doc->consult_doc_name_5 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           consult_doc[5].consult_phy_phone)) > 0)
          a_doc->consult_doc_phone_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].consult_doc[5].consult_phy_phone
         ELSE
          a_doc->consult_doc_phone_5 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           consult_doc[5].consult_phy_pager)) > 0)
          a_doc->consult_doc_pager_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].consult_doc[5].consult_phy_pager
         ELSE
          a_doc->consult_doc_pager_5 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           consult_doc[5].consult_phy_fax)) > 0)
          a_doc->consult_doc_fax_5 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].consult_doc[5].consult_phy_fax
         ELSE
          a_doc->consult_doc_fax_5 = " "
         ENDIF
        ENDIF
        IF (size(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
         consult_doc,5) > 5)
         IF (trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
          consult_doc[6].consult_phy_name) != " ")
          a_doc->consult_doc_name_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].consult_doc[6].consult_phy_name
         ELSE
          a_doc->consult_doc_name_6 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           consult_doc[6].consult_phy_phone)) > 0)
          a_doc->consult_doc_phone_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].consult_doc[6].consult_phy_phone
         ELSE
          a_doc->consult_doc_phone_6 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           consult_doc[6].consult_phy_pager)) > 0)
          a_doc->consult_doc_pager_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].consult_doc[6].consult_phy_pager
         ELSE
          a_doc->consult_doc_pager_6 = " "
         ENDIF
         IF (size(trim(data->req[req_ndx].sections[sect_ndx].exam_data[x].for_this_page[exam_ndx].
           consult_doc[6].consult_phy_fax)) > 0)
          a_doc->consult_doc_fax_6 = data->req[req_ndx].sections[sect_ndx].exam_data[x].
          for_this_page[exam_ndx].consult_doc[6].consult_phy_fax
         ELSE
          a_doc->consult_doc_fax_6 = " "
         ENDIF
        ENDIF
        CALL echo("*****START OF SITE SPECIFIC DATA*****")
        IF ((a_allergy->allergy_5 != " "))
         a_site->more_allergy = "More Allergies, check system"
        ELSE
         a_site->more_allergy = " "
        ENDIF
        dummy_val = layoutsection0(rpt_render)
      ENDFOR
     WITH nocounter
    ;end select
    CALL echorecord(data)
    CALL finalizereport(tempfile)
    IF ((working_array->print_flag != "N"))
     IF ((working_array->debug_flag="Y"))
      SET spool value(trim(tempfile))  $4 WITH notify
     ELSE
      SET spool value(concat(trim(tempfile)))  $4 WITH deleted
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
END GO
