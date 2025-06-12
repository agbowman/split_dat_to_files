CREATE PROGRAM bed_get_mltm_drc_content_group:dba
 FREE SET reply
 RECORD reply(
   1 drc_info[*]
     2 age_operator_txt = vc
     2 age_low_nbr = i4
     2 age_high_nbr = i4
     2 age_unit_disp = vc
     2 age_unit_cki = vc
     2 pma_age_operator_txt = vc
     2 pma_age_low_nbr = i4
     2 pma_age_high_nbr = i4
     2 pma_age_unit_disp = vc
     2 pma_age_unit_cki = vc
     2 route_display = vc
     2 route_code_value = f8
     2 weight_operator_txt = vc
     2 weight_low_value = f8
     2 weight_high_value = f8
     2 weight_unit_disp = vc
     2 weight_unit_cki = vc
     2 crcl_age_operator_txt = vc
     2 crcl_age_low_nbr = i4
     2 crcl_age_high_nbr = i4
     2 crcl_age_unit_disp = vc
     2 crcl_age_unit_cki = vc
     2 hepatic = vc
     2 clinical_condition = vc
     2 dose_range_list[*]
       3 dose_range_type = vc
       3 dose_range_type_id = f8
       3 low_dose_value = f8
       3 high_dose_value = f8
       3 dose_unit_disp = vc
       3 dose_unit_cki = vc
       3 comment_txt = vc
       3 max_dose_amt = f8
       3 max_dose_unit_disp = vc
       3 max_dose_unit_cki = vc
       3 source = vc
     2 drc_identifier = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET list_count = 0
 SET sub_cnt = 0
 SET sub_list_cnt = 0
 SELECT INTO "nl:"
  FROM mltm_drc_premise m,
   code_value cv,
   dcp_entity_reltn d,
   code_value cv2
  PLAN (m
   WHERE (m.grouper_id=request->group_id)
    AND m.dose_unit_cki > " "
    AND m.dose_range_type_id != 5
    AND m.condition_concept_cki IN (" ", "", null)
    AND m.max_dose_unit_cki IN ("", " ", null))
   JOIN (cv
   WHERE cv.cki=m.dose_unit_cki
    AND cv.code_set=54
    AND cv.active_ind=1)
   JOIN (d
   WHERE d.entity_reltn_mean="DRC/ROUTE"
    AND d.entity1_id=m.route_id
    AND d.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=d.entity2_id)
  ORDER BY m.drc_identifier, m.dose_range_type_id
  HEAD REPORT
   cnt = 0, list_count = 0, stat = alterlist(reply->drc_info,100)
  HEAD m.drc_identifier
   sub_cnt = 0, sub_list_cnt = 0, list_count = (list_count+ 1),
   cnt = (cnt+ 1)
   IF (list_count > 100)
    stat = alterlist(reply->drc_info,(cnt+ 100)), list_count = 1
   ENDIF
   reply->drc_info[cnt].drc_identifier = m.drc_identifier, reply->drc_info[cnt].age_operator_txt = m
   .age_operator_txt, reply->drc_info[cnt].age_low_nbr = m.age_low_nbr,
   reply->drc_info[cnt].age_high_nbr = m.age_high_nbr, reply->drc_info[cnt].age_unit_disp = m
   .age_unit_disp, reply->drc_info[cnt].age_unit_cki = m.age_unit_cki,
   reply->drc_info[cnt].pma_age_operator_txt = m.corrected_gest_age_oper_txt, reply->drc_info[cnt].
   pma_age_low_nbr = m.corrected_gest_age_low_nbr, reply->drc_info[cnt].pma_age_high_nbr = m
   .corrected_gest_age_high_nbr,
   reply->drc_info[cnt].pma_age_unit_disp = m.corrected_gest_age_unit_disp, reply->drc_info[cnt].
   pma_age_unit_cki = m.corrected_gest_age_cki, reply->drc_info[cnt].route_display = cv2.display,
   reply->drc_info[cnt].route_code_value = cv2.code_value, reply->drc_info[cnt].weight_operator_txt
    = m.weight_operator_txt, reply->drc_info[cnt].weight_low_value = m.weight_low_value,
   reply->drc_info[cnt].weight_high_value = m.weight_high_value, reply->drc_info[cnt].
   weight_unit_disp = m.weight_unit_disp, reply->drc_info[cnt].weight_unit_cki = m.weight_unit_cki,
   reply->drc_info[cnt].crcl_age_operator_txt = m.renal_operator_txt, reply->drc_info[cnt].
   crcl_age_low_nbr = m.renal_low_value, reply->drc_info[cnt].crcl_age_high_nbr = m.renal_high_value,
   reply->drc_info[cnt].crcl_age_unit_disp = m.renal_unit_disp, reply->drc_info[cnt].
   crcl_age_unit_cki = m.renal_unit_cki
   IF (cnvtupper(m.liver_desc)="YES")
    reply->drc_info[cnt].hepatic = "Yes"
   ELSE
    reply->drc_info[cnt].hepatic = "NO"
   ENDIF
   stat = alterlist(reply->drc_info[cnt].dose_range_list,5)
  HEAD m.dose_range_type_id
   sub_cnt = (sub_cnt+ 1), sub_list_cnt = (sub_list_cnt+ 1)
   IF (sub_list_cnt > 5)
    stat = alterlist(reply->drc_info[cnt].dose_range_list,(sub_cnt+ 5)), sub_list_cnt = 1
   ENDIF
   reply->drc_info[cnt].dose_range_list[sub_cnt].dose_range_type = m.dose_range_type, reply->
   drc_info[cnt].dose_range_list[sub_cnt].dose_range_type_id = m.dose_range_type_id, reply->drc_info[
   cnt].dose_range_list[sub_cnt].low_dose_value = m.low_dose_value,
   reply->drc_info[cnt].dose_range_list[sub_cnt].high_dose_value = m.high_dose_value, reply->
   drc_info[cnt].dose_range_list[sub_cnt].dose_unit_disp = cv.display, reply->drc_info[cnt].
   dose_range_list[sub_cnt].dose_unit_cki = m.dose_unit_cki,
   reply->drc_info[cnt].dose_range_list[sub_cnt].comment_txt = m.comment_txt, ftemp = findstring(
    "LEXI!",m.drc_identifier,1,1)
   IF (ftemp > 0)
    reply->drc_info[cnt].dose_range_list[sub_cnt].source = "Lexi-Comp"
   ELSE
    reply->drc_info[cnt].dose_range_list[sub_cnt].source = "Multum"
   ENDIF
  FOOT  m.drc_identifier
   stat = alterlist(reply->drc_info[cnt].dose_range_list,sub_cnt)
  FOOT REPORT
   stat = alterlist(reply->drc_info,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM mltm_drc_premise m,
   code_value cv,
   dcp_entity_reltn d,
   code_value cv2,
   code_value cv3
  PLAN (m
   WHERE (m.grouper_id=request->group_id)
    AND m.dose_unit_cki > " "
    AND m.dose_range_type_id != 5
    AND m.condition_concept_cki IN (" ", "", null)
    AND m.max_dose_unit_cki > " ")
   JOIN (cv
   WHERE cv.cki=m.dose_unit_cki
    AND cv.code_set=54
    AND cv.active_ind=1)
   JOIN (d
   WHERE d.entity_reltn_mean="DRC/ROUTE"
    AND d.entity1_id=m.route_id
    AND d.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=d.entity2_id)
   JOIN (cv3
   WHERE cv3.cki=m.max_dose_unit_cki
    AND cv3.code_set=54
    AND cv3.active_ind=1)
  ORDER BY m.drc_identifier, m.dose_range_type_id
  HEAD REPORT
   cnt = size(reply->drc_info,5), list_count = 0, stat = alterlist(reply->drc_info,(cnt+ 100))
  HEAD m.drc_identifier
   sub_cnt = 0, sub_list_cnt = 0, list_count = (list_count+ 1),
   cnt = (cnt+ 1)
   IF (list_count > 100)
    stat = alterlist(reply->drc_info,(cnt+ 100)), list_count = 1
   ENDIF
   reply->drc_info[cnt].drc_identifier = m.drc_identifier, reply->drc_info[cnt].age_operator_txt = m
   .age_operator_txt, reply->drc_info[cnt].age_low_nbr = m.age_low_nbr,
   reply->drc_info[cnt].age_high_nbr = m.age_high_nbr, reply->drc_info[cnt].age_unit_disp = m
   .age_unit_disp, reply->drc_info[cnt].age_unit_cki = m.age_unit_cki,
   reply->drc_info[cnt].pma_age_operator_txt = m.corrected_gest_age_oper_txt, reply->drc_info[cnt].
   pma_age_low_nbr = m.corrected_gest_age_low_nbr, reply->drc_info[cnt].pma_age_high_nbr = m
   .corrected_gest_age_high_nbr,
   reply->drc_info[cnt].pma_age_unit_disp = m.corrected_gest_age_unit_disp, reply->drc_info[cnt].
   pma_age_unit_cki = m.corrected_gest_age_cki, reply->drc_info[cnt].route_display = cv2.display,
   reply->drc_info[cnt].route_code_value = cv2.code_value, reply->drc_info[cnt].weight_operator_txt
    = m.weight_operator_txt, reply->drc_info[cnt].weight_low_value = m.weight_low_value,
   reply->drc_info[cnt].weight_high_value = m.weight_high_value, reply->drc_info[cnt].
   weight_unit_disp = m.weight_unit_disp, reply->drc_info[cnt].weight_unit_cki = m.weight_unit_cki,
   reply->drc_info[cnt].crcl_age_operator_txt = m.renal_operator_txt, reply->drc_info[cnt].
   crcl_age_low_nbr = m.renal_low_value, reply->drc_info[cnt].crcl_age_high_nbr = m.renal_high_value,
   reply->drc_info[cnt].crcl_age_unit_disp = m.renal_unit_disp, reply->drc_info[cnt].
   crcl_age_unit_cki = m.renal_unit_cki
   IF (cnvtupper(m.liver_desc)="YES")
    reply->drc_info[cnt].hepatic = "Yes"
   ELSE
    reply->drc_info[cnt].hepatic = "NO"
   ENDIF
   stat = alterlist(reply->drc_info[cnt].dose_range_list,5)
  HEAD m.dose_range_type_id
   sub_cnt = (sub_cnt+ 1), sub_list_cnt = (sub_list_cnt+ 1)
   IF (sub_list_cnt > 5)
    stat = alterlist(reply->drc_info[cnt].dose_range_list,(sub_cnt+ 5)), sub_list_cnt = 1
   ENDIF
   reply->drc_info[cnt].dose_range_list[sub_cnt].dose_range_type = m.dose_range_type, reply->
   drc_info[cnt].dose_range_list[sub_cnt].dose_range_type_id = m.dose_range_type_id, reply->drc_info[
   cnt].dose_range_list[sub_cnt].low_dose_value = m.low_dose_value,
   reply->drc_info[cnt].dose_range_list[sub_cnt].high_dose_value = m.high_dose_value, reply->
   drc_info[cnt].dose_range_list[sub_cnt].dose_unit_disp = cv.display, reply->drc_info[cnt].
   dose_range_list[sub_cnt].dose_unit_cki = m.dose_unit_cki,
   reply->drc_info[cnt].dose_range_list[sub_cnt].comment_txt = m.comment_txt, reply->drc_info[cnt].
   dose_range_list[sub_cnt].max_dose_amt = m.max_dose_amt, reply->drc_info[cnt].dose_range_list[
   sub_cnt].max_dose_unit_disp = cv3.display,
   reply->drc_info[cnt].dose_range_list[sub_cnt].max_dose_unit_cki = m.max_dose_unit_cki, ftemp =
   findstring("LEXI!",m.drc_identifier,1,1)
   IF (ftemp > 0)
    reply->drc_info[cnt].dose_range_list[sub_cnt].source = "Lexi-Comp"
   ELSE
    reply->drc_info[cnt].dose_range_list[sub_cnt].source = "Multum"
   ENDIF
  FOOT  m.drc_identifier
   stat = alterlist(reply->drc_info[cnt].dose_range_list,sub_cnt)
  FOOT REPORT
   stat = alterlist(reply->drc_info,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM mltm_drc_premise m,
   code_value cv,
   dcp_entity_reltn d,
   code_value cv2,
   nomenclature n
  PLAN (m
   WHERE (m.grouper_id=request->group_id)
    AND m.dose_unit_cki > " "
    AND m.dose_range_type_id != 5
    AND m.condition_concept_cki > " "
    AND m.max_dose_unit_cki IN ("", " ", null))
   JOIN (cv
   WHERE cv.cki=m.dose_unit_cki
    AND cv.code_set=54
    AND cv.active_ind=1)
   JOIN (d
   WHERE d.entity_reltn_mean="DRC/ROUTE"
    AND d.entity1_id=m.route_id
    AND d.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=d.entity2_id)
   JOIN (n
   WHERE n.concept_cki=m.condition_concept_cki
    AND n.primary_cterm_ind=1
    AND n.active_ind=1
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY m.drc_identifier, m.dose_range_type_id
  HEAD REPORT
   cnt = size(reply->drc_info,5), list_count = 0, stat = alterlist(reply->drc_info,(cnt+ 100))
  HEAD m.drc_identifier
   sub_cnt = 0, sub_list_cnt = 0, list_count = (list_count+ 1),
   cnt = (cnt+ 1)
   IF (list_count > 100)
    stat = alterlist(reply->drc_info,(cnt+ 100)), list_count = 1
   ENDIF
   reply->drc_info[cnt].drc_identifier = m.drc_identifier, reply->drc_info[cnt].age_operator_txt = m
   .age_operator_txt, reply->drc_info[cnt].age_low_nbr = m.age_low_nbr,
   reply->drc_info[cnt].age_high_nbr = m.age_high_nbr, reply->drc_info[cnt].age_unit_disp = m
   .age_unit_disp, reply->drc_info[cnt].age_unit_cki = m.age_unit_cki,
   reply->drc_info[cnt].pma_age_operator_txt = m.corrected_gest_age_oper_txt, reply->drc_info[cnt].
   pma_age_low_nbr = m.corrected_gest_age_low_nbr, reply->drc_info[cnt].pma_age_high_nbr = m
   .corrected_gest_age_high_nbr,
   reply->drc_info[cnt].pma_age_unit_disp = m.corrected_gest_age_unit_disp, reply->drc_info[cnt].
   pma_age_unit_cki = m.corrected_gest_age_cki, reply->drc_info[cnt].route_display = cv2.display,
   reply->drc_info[cnt].route_code_value = cv2.code_value, reply->drc_info[cnt].weight_operator_txt
    = m.weight_operator_txt, reply->drc_info[cnt].weight_low_value = m.weight_low_value,
   reply->drc_info[cnt].weight_high_value = m.weight_high_value, reply->drc_info[cnt].
   weight_unit_disp = m.weight_unit_disp, reply->drc_info[cnt].weight_unit_cki = m.weight_unit_cki,
   reply->drc_info[cnt].crcl_age_operator_txt = m.renal_operator_txt, reply->drc_info[cnt].
   crcl_age_low_nbr = m.renal_low_value, reply->drc_info[cnt].crcl_age_high_nbr = m.renal_high_value,
   reply->drc_info[cnt].crcl_age_unit_disp = m.renal_unit_disp, reply->drc_info[cnt].
   crcl_age_unit_cki = m.renal_unit_cki
   IF (cnvtupper(m.liver_desc)="YES")
    reply->drc_info[cnt].hepatic = "Yes"
   ELSE
    reply->drc_info[cnt].hepatic = "NO"
   ENDIF
   reply->drc_info[cnt].clinical_condition = n.source_string, stat = alterlist(reply->drc_info[cnt].
    dose_range_list,5)
  HEAD m.dose_range_type_id
   sub_cnt = (sub_cnt+ 1), sub_list_cnt = (sub_list_cnt+ 1)
   IF (sub_list_cnt > 5)
    stat = alterlist(reply->drc_info[cnt].dose_range_list,(sub_cnt+ 5)), sub_list_cnt = 1
   ENDIF
   reply->drc_info[cnt].dose_range_list[sub_cnt].dose_range_type = m.dose_range_type, reply->
   drc_info[cnt].dose_range_list[sub_cnt].dose_range_type_id = m.dose_range_type_id, reply->drc_info[
   cnt].dose_range_list[sub_cnt].low_dose_value = m.low_dose_value,
   reply->drc_info[cnt].dose_range_list[sub_cnt].high_dose_value = m.high_dose_value, reply->
   drc_info[cnt].dose_range_list[sub_cnt].dose_unit_disp = cv.display, reply->drc_info[cnt].
   dose_range_list[sub_cnt].dose_unit_cki = m.dose_unit_cki,
   reply->drc_info[cnt].dose_range_list[sub_cnt].comment_txt = m.comment_txt, ftemp = findstring(
    "LEXI!",m.drc_identifier,1,1)
   IF (ftemp > 0)
    reply->drc_info[cnt].dose_range_list[sub_cnt].source = "Lexi-Comp"
   ELSE
    reply->drc_info[cnt].dose_range_list[sub_cnt].source = "Multum"
   ENDIF
  FOOT  m.drc_identifier
   stat = alterlist(reply->drc_info[cnt].dose_range_list,sub_cnt)
  FOOT REPORT
   stat = alterlist(reply->drc_info,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM mltm_drc_premise m,
   code_value cv,
   dcp_entity_reltn d,
   code_value cv2,
   nomenclature n,
   code_value cv3
  PLAN (m
   WHERE (m.grouper_id=request->group_id)
    AND m.dose_unit_cki > " "
    AND m.dose_range_type_id != 5
    AND m.condition_concept_cki > " "
    AND m.max_dose_unit_cki > " ")
   JOIN (cv
   WHERE cv.cki=m.dose_unit_cki
    AND cv.code_set=54
    AND cv.active_ind=1)
   JOIN (d
   WHERE d.entity_reltn_mean="DRC/ROUTE"
    AND d.entity1_id=m.route_id
    AND d.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=d.entity2_id)
   JOIN (n
   WHERE n.concept_cki=m.condition_concept_cki
    AND n.primary_cterm_ind=1
    AND n.active_ind=1
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (cv3
   WHERE cv3.cki=m.max_dose_unit_cki
    AND cv3.code_set=54
    AND cv3.active_ind=1)
  ORDER BY m.drc_identifier, m.dose_range_type_id
  HEAD REPORT
   cnt = size(reply->drc_info,5), list_count = 0, stat = alterlist(reply->drc_info,(cnt+ 100))
  HEAD m.drc_identifier
   sub_cnt = 0, sub_list_cnt = 0, list_count = (list_count+ 1),
   cnt = (cnt+ 1)
   IF (list_count > 100)
    stat = alterlist(reply->drc_info,(cnt+ 100)), list_count = 1
   ENDIF
   reply->drc_info[cnt].drc_identifier = m.drc_identifier, reply->drc_info[cnt].age_operator_txt = m
   .age_operator_txt, reply->drc_info[cnt].age_low_nbr = m.age_low_nbr,
   reply->drc_info[cnt].age_high_nbr = m.age_high_nbr, reply->drc_info[cnt].age_unit_disp = m
   .age_unit_disp, reply->drc_info[cnt].age_unit_cki = m.age_unit_cki,
   reply->drc_info[cnt].pma_age_operator_txt = m.corrected_gest_age_oper_txt, reply->drc_info[cnt].
   pma_age_low_nbr = m.corrected_gest_age_low_nbr, reply->drc_info[cnt].pma_age_high_nbr = m
   .corrected_gest_age_high_nbr,
   reply->drc_info[cnt].pma_age_unit_disp = m.corrected_gest_age_unit_disp, reply->drc_info[cnt].
   pma_age_unit_cki = m.corrected_gest_age_cki, reply->drc_info[cnt].route_display = cv2.display,
   reply->drc_info[cnt].route_code_value = cv2.code_value, reply->drc_info[cnt].weight_operator_txt
    = m.weight_operator_txt, reply->drc_info[cnt].weight_low_value = m.weight_low_value,
   reply->drc_info[cnt].weight_high_value = m.weight_high_value, reply->drc_info[cnt].
   weight_unit_disp = m.weight_unit_disp, reply->drc_info[cnt].weight_unit_cki = m.weight_unit_cki,
   reply->drc_info[cnt].crcl_age_operator_txt = m.renal_operator_txt, reply->drc_info[cnt].
   crcl_age_low_nbr = m.renal_low_value, reply->drc_info[cnt].crcl_age_high_nbr = m.renal_high_value,
   reply->drc_info[cnt].crcl_age_unit_disp = m.renal_unit_disp, reply->drc_info[cnt].
   crcl_age_unit_cki = m.renal_unit_cki
   IF (cnvtupper(m.liver_desc)="YES")
    reply->drc_info[cnt].hepatic = "Yes"
   ELSE
    reply->drc_info[cnt].hepatic = "NO"
   ENDIF
   reply->drc_info[cnt].clinical_condition = n.source_string, stat = alterlist(reply->drc_info[cnt].
    dose_range_list,5)
  HEAD m.dose_range_type_id
   sub_cnt = (sub_cnt+ 1), sub_list_cnt = (sub_list_cnt+ 1)
   IF (sub_list_cnt > 5)
    stat = alterlist(reply->drc_info[cnt].dose_range_list,(sub_cnt+ 5)), sub_list_cnt = 1
   ENDIF
   reply->drc_info[cnt].dose_range_list[sub_cnt].dose_range_type = m.dose_range_type, reply->
   drc_info[cnt].dose_range_list[sub_cnt].dose_range_type_id = m.dose_range_type_id, reply->drc_info[
   cnt].dose_range_list[sub_cnt].low_dose_value = m.low_dose_value,
   reply->drc_info[cnt].dose_range_list[sub_cnt].high_dose_value = m.high_dose_value, reply->
   drc_info[cnt].dose_range_list[sub_cnt].dose_unit_disp = cv.display, reply->drc_info[cnt].
   dose_range_list[sub_cnt].dose_unit_cki = m.dose_unit_cki,
   reply->drc_info[cnt].dose_range_list[sub_cnt].comment_txt = m.comment_txt, reply->drc_info[cnt].
   dose_range_list[sub_cnt].max_dose_amt = m.max_dose_amt, reply->drc_info[cnt].dose_range_list[
   sub_cnt].max_dose_unit_disp = cv3.display,
   reply->drc_info[cnt].dose_range_list[sub_cnt].max_dose_unit_cki = m.max_dose_unit_cki, ftemp =
   findstring("LEXI!",m.drc_identifier,1,1)
   IF (ftemp > 0)
    reply->drc_info[cnt].dose_range_list[sub_cnt].source = "Lexi-Comp"
   ELSE
    reply->drc_info[cnt].dose_range_list[sub_cnt].source = "Multum"
   ENDIF
  FOOT  m.drc_identifier
   stat = alterlist(reply->drc_info[cnt].dose_range_list,sub_cnt)
  FOOT REPORT
   stat = alterlist(reply->drc_info,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM mltm_drc_premise m,
   dcp_entity_reltn d,
   code_value cv
  PLAN (m
   WHERE (m.grouper_id=request->group_id)
    AND m.dose_range_type_id=5
    AND m.condition_concept_cki IN (" ", "", null))
   JOIN (d
   WHERE d.entity_reltn_mean="DRC/ROUTE"
    AND d.entity1_id=m.route_id
    AND d.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=d.entity2_id)
  ORDER BY m.drc_identifier, m.dose_range_type_id
  HEAD REPORT
   cnt = size(reply->drc_info,5), list_count = 0, stat = alterlist(reply->drc_info,(cnt+ 100))
  HEAD m.drc_identifier
   sub_cnt = 0, sub_list_cnt = 0, list_count = (list_count+ 1),
   cnt = (cnt+ 1)
   IF (list_count > 100)
    stat = alterlist(reply->drc_info,(cnt+ 100)), list_count = 1
   ENDIF
   reply->drc_info[cnt].drc_identifier = m.drc_identifier, reply->drc_info[cnt].age_operator_txt = m
   .age_operator_txt, reply->drc_info[cnt].age_low_nbr = m.age_low_nbr,
   reply->drc_info[cnt].age_high_nbr = m.age_high_nbr, reply->drc_info[cnt].age_unit_disp = m
   .age_unit_disp, reply->drc_info[cnt].age_unit_cki = m.age_unit_cki,
   reply->drc_info[cnt].pma_age_operator_txt = m.corrected_gest_age_oper_txt, reply->drc_info[cnt].
   pma_age_low_nbr = m.corrected_gest_age_low_nbr, reply->drc_info[cnt].pma_age_high_nbr = m
   .corrected_gest_age_high_nbr,
   reply->drc_info[cnt].pma_age_unit_disp = m.corrected_gest_age_unit_disp, reply->drc_info[cnt].
   pma_age_unit_cki = m.corrected_gest_age_cki, reply->drc_info[cnt].route_display = cv.display,
   reply->drc_info[cnt].route_code_value = cv.code_value, reply->drc_info[cnt].weight_operator_txt =
   m.weight_operator_txt, reply->drc_info[cnt].weight_low_value = m.weight_low_value,
   reply->drc_info[cnt].weight_high_value = m.weight_high_value, reply->drc_info[cnt].
   weight_unit_disp = m.weight_unit_disp, reply->drc_info[cnt].weight_unit_cki = m.weight_unit_cki,
   reply->drc_info[cnt].crcl_age_operator_txt = m.renal_operator_txt, reply->drc_info[cnt].
   crcl_age_low_nbr = m.renal_low_value, reply->drc_info[cnt].crcl_age_high_nbr = m.renal_high_value,
   reply->drc_info[cnt].crcl_age_unit_disp = m.renal_unit_disp, reply->drc_info[cnt].
   crcl_age_unit_cki = m.renal_unit_cki
   IF (cnvtupper(m.liver_desc)="YES")
    reply->drc_info[cnt].hepatic = "Yes"
   ELSE
    reply->drc_info[cnt].hepatic = "NO"
   ENDIF
   stat = alterlist(reply->drc_info[cnt].dose_range_list,5)
  HEAD m.dose_range_type_id
   sub_cnt = (sub_cnt+ 1), sub_list_cnt = (sub_list_cnt+ 1)
   IF (sub_list_cnt > 5)
    stat = alterlist(reply->drc_info[cnt].dose_range_list,(sub_cnt+ 5)), sub_list_cnt = 1
   ENDIF
   reply->drc_info[cnt].dose_range_list[sub_cnt].dose_range_type = m.dose_range_type, reply->
   drc_info[cnt].dose_range_list[sub_cnt].dose_range_type_id = m.dose_range_type_id, reply->drc_info[
   cnt].dose_range_list[sub_cnt].low_dose_value = m.low_dose_value,
   reply->drc_info[cnt].dose_range_list[sub_cnt].high_dose_value = m.high_dose_value, reply->
   drc_info[cnt].dose_range_list[sub_cnt].dose_unit_disp = m.dose_unit_disp, reply->drc_info[cnt].
   dose_range_list[sub_cnt].dose_unit_cki = m.dose_unit_cki,
   reply->drc_info[cnt].dose_range_list[sub_cnt].comment_txt = m.comment_txt, ftemp = findstring(
    "LEXI!",m.drc_identifier,1,1)
   IF (ftemp > 0)
    reply->drc_info[cnt].dose_range_list[sub_cnt].source = "Lexi-Comp"
   ELSE
    reply->drc_info[cnt].dose_range_list[sub_cnt].source = "Multum"
   ENDIF
  FOOT  m.drc_identifier
   stat = alterlist(reply->drc_info[cnt].dose_range_list,sub_cnt)
  FOOT REPORT
   stat = alterlist(reply->drc_info,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM mltm_drc_premise m,
   dcp_entity_reltn d,
   code_value cv,
   nomenclature n
  PLAN (m
   WHERE (m.grouper_id=request->group_id)
    AND m.dose_range_type_id=5
    AND m.condition_concept_cki > " ")
   JOIN (d
   WHERE d.entity_reltn_mean="DRC/ROUTE"
    AND d.entity1_id=m.route_id
    AND d.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=d.entity2_id)
   JOIN (n
   WHERE n.concept_cki=m.condition_concept_cki
    AND n.primary_cterm_ind=1
    AND n.active_ind=1
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY m.drc_identifier, m.dose_range_type_id
  HEAD REPORT
   cnt = size(reply->drc_info,5), list_count = 0, stat = alterlist(reply->drc_info,(cnt+ 100))
  HEAD m.drc_identifier
   sub_cnt = 0, sub_list_cnt = 0, list_count = (list_count+ 1),
   cnt = (cnt+ 1)
   IF (list_count > 100)
    stat = alterlist(reply->drc_info,(cnt+ 100)), list_count = 1
   ENDIF
   reply->drc_info[cnt].drc_identifier = m.drc_identifier, reply->drc_info[cnt].age_operator_txt = m
   .age_operator_txt, reply->drc_info[cnt].age_low_nbr = m.age_low_nbr,
   reply->drc_info[cnt].age_high_nbr = m.age_high_nbr, reply->drc_info[cnt].age_unit_disp = m
   .age_unit_disp, reply->drc_info[cnt].age_unit_cki = m.age_unit_cki,
   reply->drc_info[cnt].pma_age_operator_txt = m.corrected_gest_age_oper_txt, reply->drc_info[cnt].
   pma_age_low_nbr = m.corrected_gest_age_low_nbr, reply->drc_info[cnt].pma_age_high_nbr = m
   .corrected_gest_age_high_nbr,
   reply->drc_info[cnt].pma_age_unit_disp = m.corrected_gest_age_unit_disp, reply->drc_info[cnt].
   pma_age_unit_cki = m.corrected_gest_age_cki, reply->drc_info[cnt].route_display = cv.display,
   reply->drc_info[cnt].route_code_value = cv.code_value, reply->drc_info[cnt].weight_operator_txt =
   m.weight_operator_txt, reply->drc_info[cnt].weight_low_value = m.weight_low_value,
   reply->drc_info[cnt].weight_high_value = m.weight_high_value, reply->drc_info[cnt].
   weight_unit_disp = m.weight_unit_disp, reply->drc_info[cnt].weight_unit_cki = m.weight_unit_cki,
   reply->drc_info[cnt].crcl_age_operator_txt = m.renal_operator_txt, reply->drc_info[cnt].
   crcl_age_low_nbr = m.renal_low_value, reply->drc_info[cnt].crcl_age_high_nbr = m.renal_high_value,
   reply->drc_info[cnt].crcl_age_unit_disp = m.renal_unit_disp, reply->drc_info[cnt].
   crcl_age_unit_cki = m.renal_unit_cki
   IF (cnvtupper(m.liver_desc)="YES")
    reply->drc_info[cnt].hepatic = "Yes"
   ELSE
    reply->drc_info[cnt].hepatic = "NO"
   ENDIF
   reply->drc_info[cnt].clinical_condition = n.source_string, stat = alterlist(reply->drc_info[cnt].
    dose_range_list,5)
  HEAD m.dose_range_type_id
   sub_cnt = (sub_cnt+ 1), sub_list_cnt = (sub_list_cnt+ 1)
   IF (sub_list_cnt > 5)
    stat = alterlist(reply->drc_info[cnt].dose_range_list,(sub_cnt+ 5)), sub_list_cnt = 1
   ENDIF
   reply->drc_info[cnt].dose_range_list[sub_cnt].dose_range_type = m.dose_range_type, reply->
   drc_info[cnt].dose_range_list[sub_cnt].dose_range_type_id = m.dose_range_type_id, reply->drc_info[
   cnt].dose_range_list[sub_cnt].low_dose_value = m.low_dose_value,
   reply->drc_info[cnt].dose_range_list[sub_cnt].high_dose_value = m.high_dose_value, reply->
   drc_info[cnt].dose_range_list[sub_cnt].dose_unit_disp = m.dose_unit_disp, reply->drc_info[cnt].
   dose_range_list[sub_cnt].dose_unit_cki = m.dose_unit_cki,
   reply->drc_info[cnt].dose_range_list[sub_cnt].comment_txt = m.comment_txt, ftemp = findstring(
    "LEXI!",m.drc_identifier,1,1)
   IF (ftemp > 0)
    reply->drc_info[cnt].dose_range_list[sub_cnt].source = "Lexi-Comp"
   ELSE
    reply->drc_info[cnt].dose_range_list[sub_cnt].source = "Multum"
   ENDIF
  FOOT  m.drc_identifier
   stat = alterlist(reply->drc_info[cnt].dose_range_list,sub_cnt)
  FOOT REPORT
   stat = alterlist(reply->drc_info,cnt)
  WITH nocounter
 ;end select
 SET rsize = size(reply->drc_info,5)
 IF (rsize > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(rsize)),
    code_value cv
   PLAN (d
    WHERE (reply->drc_info[d.seq].age_unit_cki > " "))
    JOIN (cv
    WHERE cv.code_set=54
     AND (cv.cki=reply->drc_info[d.seq].age_unit_cki))
   ORDER BY d.seq
   DETAIL
    reply->drc_info[d.seq].age_unit_disp = cv.display
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
