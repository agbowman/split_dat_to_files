CREATE PROGRAM bed_get_mltm_drc_exist_detail:dba
 FREE SET reply
 RECORD reply(
   1 new_drc_info[*]
     2 drc_identifier = vc
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
       3 drc_cki = vc
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
     2 age_unit_meaning = vc
     2 pma_age_unit_meaning = vc
   1 current_drc_info[*]
     2 parent_premise_id = f8
     2 active_ind = i2
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
     2 route_list[*]
       3 display = vc
       3 code_value = f8
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
     2 age_unit_meaning = vc
     2 pma_age_unit_meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_curr
 RECORD temp_curr(
   1 current_drc_info[*]
     2 dose_range_list[*]
       3 dose_range_id = f8
 )
 DECLARE operator = vc
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET list_cnt = 0
 SET sub_cnt = 0
 SET sub_list_cnt = 0
 SET drc_id = 0.0
 SELECT INTO "nl:"
  FROM mltm_drc_premise m
  WHERE (m.grouper_id=request->grouper_id)
  ORDER BY m.dose_range_check_id
  HEAD m.dose_range_check_id
   drc_id = m.dose_range_check_id
  WITH nocoutner
 ;end select
 SELECT INTO "nl:"
  FROM mltm_drc_premise m,
   code_value cv,
   dcp_entity_reltn d,
   code_value cv2
  PLAN (m
   WHERE (m.grouper_id=request->grouper_id)
    AND m.parent_premise_id=0
    AND m.dose_range_type_id != 5
    AND m.dose_unit_cki > " "
    AND m.max_dose_unit_cki IN ("", " ", null)
    AND m.condition_concept_cki IN ("", " ", null))
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
   cnt = 0, list_cnt = 0, stat = alterlist(reply->new_drc_info,100)
  HEAD m.drc_identifier
   sub_cnt = 0, sub_list_cnt = 0, list_cnt = (list_cnt+ 1),
   cnt = (cnt+ 1)
   IF (list_cnt > 100)
    stat = alterlist(reply->new_drc_info,(cnt+ 100)), list_cnt = 1
   ENDIF
   reply->new_drc_info[cnt].drc_identifier = m.drc_identifier, reply->new_drc_info[cnt].
   age_operator_txt = m.age_operator_txt, reply->new_drc_info[cnt].age_low_nbr = m.age_low_nbr,
   reply->new_drc_info[cnt].age_high_nbr = m.age_high_nbr, reply->new_drc_info[cnt].age_unit_disp = m
   .age_unit_disp, reply->new_drc_info[cnt].age_unit_cki = m.age_unit_cki,
   reply->new_drc_info[cnt].pma_age_operator_txt = m.corrected_gest_age_oper_txt, reply->
   new_drc_info[cnt].pma_age_low_nbr = m.corrected_gest_age_low_nbr, reply->new_drc_info[cnt].
   pma_age_high_nbr = m.corrected_gest_age_high_nbr,
   reply->new_drc_info[cnt].pma_age_unit_disp = m.corrected_gest_age_unit_disp, reply->new_drc_info[
   cnt].pma_age_unit_cki = m.corrected_gest_age_cki, reply->new_drc_info[cnt].route_display = cv2
   .display,
   reply->new_drc_info[cnt].route_code_value = cv2.code_value, reply->new_drc_info[cnt].
   weight_operator_txt = m.weight_operator_txt, reply->new_drc_info[cnt].weight_low_value = m
   .weight_low_value,
   reply->new_drc_info[cnt].weight_high_value = m.weight_high_value, reply->new_drc_info[cnt].
   weight_unit_disp = m.weight_unit_disp, reply->new_drc_info[cnt].weight_unit_cki = m
   .weight_unit_cki,
   reply->new_drc_info[cnt].crcl_age_operator_txt = m.renal_operator_txt, reply->new_drc_info[cnt].
   crcl_age_low_nbr = m.renal_low_value, reply->new_drc_info[cnt].crcl_age_high_nbr = m
   .renal_high_value,
   reply->new_drc_info[cnt].crcl_age_unit_disp = m.renal_unit_disp, reply->new_drc_info[cnt].
   crcl_age_unit_cki = m.renal_unit_cki
   IF (cnvtupper(m.liver_desc)="YES")
    reply->new_drc_info[cnt].hepatic = "Yes"
   ELSE
    reply->new_drc_info[cnt].hepatic = "NO"
   ENDIF
   stat = alterlist(reply->new_drc_info[cnt].dose_range_list,5)
  HEAD m.dose_range_type_id
   sub_cnt = (sub_cnt+ 1), sub_list_cnt = (sub_list_cnt+ 1)
   IF (sub_list_cnt > 5)
    stat = alterlist(reply->new_drc_info[cnt].dose_range_list,(sub_cnt+ 5)), sub_list_cnt = 1
   ENDIF
   reply->new_drc_info[cnt].dose_range_list[sub_cnt].dose_range_type = m.dose_range_type, reply->
   new_drc_info[cnt].dose_range_list[sub_cnt].dose_range_type_id = m.dose_range_type_id, reply->
   new_drc_info[cnt].dose_range_list[sub_cnt].low_dose_value = m.low_dose_value,
   reply->new_drc_info[cnt].dose_range_list[sub_cnt].high_dose_value = m.high_dose_value, reply->
   new_drc_info[cnt].dose_range_list[sub_cnt].dose_unit_disp = cv.display, reply->new_drc_info[cnt].
   dose_range_list[sub_cnt].dose_unit_cki = m.dose_unit_cki,
   reply->new_drc_info[cnt].dose_range_list[sub_cnt].comment_txt = m.comment_txt, ftemp = findstring(
    "LEXI!",m.drc_identifier,1,1)
   IF (ftemp > 0)
    reply->new_drc_info[cnt].dose_range_list[sub_cnt].source = "Lexi-Comp"
   ELSE
    reply->new_drc_info[cnt].dose_range_list[sub_cnt].source = "Multum"
   ENDIF
  FOOT  m.drc_identifier
   stat = alterlist(reply->new_drc_info[cnt].dose_range_list,sub_cnt)
  FOOT REPORT
   stat = alterlist(reply->new_drc_info,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM mltm_drc_premise m,
   code_value cv,
   dcp_entity_reltn d,
   code_value cv2,
   code_value cv3
  PLAN (m
   WHERE (m.grouper_id=request->grouper_id)
    AND m.parent_premise_id=0
    AND m.dose_range_type_id != 5
    AND m.dose_unit_cki > " "
    AND m.max_dose_unit_cki > " "
    AND m.condition_concept_cki IN ("", " ", null))
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
    AND cv.active_ind=1)
  ORDER BY m.drc_identifier, m.dose_range_type_id
  HEAD REPORT
   cnt = size(reply->new_drc_info,5), list_cnt = 0, stat = alterlist(reply->new_drc_info,(cnt+ 100))
  HEAD m.drc_identifier
   sub_cnt = 0, sub_list_cnt = 0, list_cnt = (list_cnt+ 1),
   cnt = (cnt+ 1)
   IF (list_cnt > 100)
    stat = alterlist(reply->new_drc_info,(cnt+ 100)), list_cnt = 1
   ENDIF
   reply->new_drc_info[cnt].drc_identifier = m.drc_identifier, reply->new_drc_info[cnt].
   age_operator_txt = m.age_operator_txt, reply->new_drc_info[cnt].age_low_nbr = m.age_low_nbr,
   reply->new_drc_info[cnt].age_high_nbr = m.age_high_nbr, reply->new_drc_info[cnt].age_unit_disp = m
   .age_unit_disp, reply->new_drc_info[cnt].age_unit_cki = m.age_unit_cki,
   reply->new_drc_info[cnt].pma_age_operator_txt = m.corrected_gest_age_oper_txt, reply->
   new_drc_info[cnt].pma_age_low_nbr = m.corrected_gest_age_low_nbr, reply->new_drc_info[cnt].
   pma_age_high_nbr = m.corrected_gest_age_high_nbr,
   reply->new_drc_info[cnt].pma_age_unit_disp = m.corrected_gest_age_unit_disp, reply->new_drc_info[
   cnt].pma_age_unit_cki = m.corrected_gest_age_cki, reply->new_drc_info[cnt].route_display = cv2
   .display,
   reply->new_drc_info[cnt].route_code_value = cv2.code_value, reply->new_drc_info[cnt].
   weight_operator_txt = m.weight_operator_txt, reply->new_drc_info[cnt].weight_low_value = m
   .weight_low_value,
   reply->new_drc_info[cnt].weight_high_value = m.weight_high_value, reply->new_drc_info[cnt].
   weight_unit_disp = m.weight_unit_disp, reply->new_drc_info[cnt].weight_unit_cki = m
   .weight_unit_cki,
   reply->new_drc_info[cnt].crcl_age_operator_txt = m.renal_operator_txt, reply->new_drc_info[cnt].
   crcl_age_low_nbr = m.renal_low_value, reply->new_drc_info[cnt].crcl_age_high_nbr = m
   .renal_high_value,
   reply->new_drc_info[cnt].crcl_age_unit_disp = m.renal_unit_disp, reply->new_drc_info[cnt].
   crcl_age_unit_cki = m.renal_unit_cki
   IF (cnvtupper(m.liver_desc)="YES")
    reply->new_drc_info[cnt].hepatic = "Yes"
   ELSE
    reply->new_drc_info[cnt].hepatic = "NO"
   ENDIF
   stat = alterlist(reply->new_drc_info[cnt].dose_range_list,5)
  HEAD m.dose_range_type_id
   sub_cnt = (sub_cnt+ 1), sub_list_cnt = (sub_list_cnt+ 1)
   IF (sub_list_cnt > 5)
    stat = alterlist(reply->new_drc_info[cnt].dose_range_list,(sub_cnt+ 5)), sub_list_cnt = 1
   ENDIF
   reply->new_drc_info[cnt].dose_range_list[sub_cnt].dose_range_type = m.dose_range_type, reply->
   new_drc_info[cnt].dose_range_list[sub_cnt].dose_range_type_id = m.dose_range_type_id, reply->
   new_drc_info[cnt].dose_range_list[sub_cnt].low_dose_value = m.low_dose_value,
   reply->new_drc_info[cnt].dose_range_list[sub_cnt].high_dose_value = m.high_dose_value, reply->
   new_drc_info[cnt].dose_range_list[sub_cnt].dose_unit_disp = cv.display, reply->new_drc_info[cnt].
   dose_range_list[sub_cnt].dose_unit_cki = m.dose_unit_cki,
   reply->new_drc_info[cnt].dose_range_list[sub_cnt].comment_txt = m.comment_txt, reply->
   new_drc_info[cnt].dose_range_list[sub_cnt].max_dose_amt = m.max_dose_amt, reply->new_drc_info[cnt]
   .dose_range_list[sub_cnt].max_dose_unit_disp = cv3.display,
   reply->new_drc_info[cnt].dose_range_list[sub_cnt].max_dose_unit_cki = m.max_dose_unit_cki, ftemp
    = findstring("LEXI!",m.drc_identifier,1,1)
   IF (ftemp > 0)
    reply->new_drc_info[cnt].dose_range_list[sub_cnt].source = "Lexi-Comp"
   ELSE
    reply->new_drc_info[cnt].dose_range_list[sub_cnt].source = "Multum"
   ENDIF
  FOOT  m.drc_identifier
   stat = alterlist(reply->new_drc_info[cnt].dose_range_list,sub_cnt)
  FOOT REPORT
   stat = alterlist(reply->new_drc_info,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM mltm_drc_premise m,
   code_value cv,
   dcp_entity_reltn d
  PLAN (m
   WHERE (m.grouper_id=request->grouper_id)
    AND m.parent_premise_id=0
    AND m.dose_range_type_id=5
    AND m.comment_txt > " "
    AND m.condition_concept_cki IN ("", " ", null))
   JOIN (d
   WHERE d.entity_reltn_mean="DRC/ROUTE"
    AND d.entity1_id=m.route_id
    AND d.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=d.entity2_id)
  ORDER BY m.drc_identifier, m.dose_range_type_id
  HEAD REPORT
   cnt = size(reply->new_drc_info,5), list_cnt = 0, stat = alterlist(reply->new_drc_info,(cnt+ 100))
  HEAD m.drc_identifier
   sub_cnt = 0, sub_list_cnt = 0, list_cnt = (list_cnt+ 1),
   cnt = (cnt+ 1)
   IF (list_cnt > 100)
    stat = alterlist(reply->new_drc_info,(cnt+ 100)), list_cnt = 1
   ENDIF
   reply->new_drc_info[cnt].drc_identifier = m.drc_identifier, reply->new_drc_info[cnt].
   age_operator_txt = m.age_operator_txt, reply->new_drc_info[cnt].age_low_nbr = m.age_low_nbr,
   reply->new_drc_info[cnt].age_high_nbr = m.age_high_nbr, reply->new_drc_info[cnt].age_unit_disp = m
   .age_unit_disp, reply->new_drc_info[cnt].age_unit_cki = m.age_unit_cki,
   reply->new_drc_info[cnt].pma_age_operator_txt = m.corrected_gest_age_oper_txt, reply->
   new_drc_info[cnt].pma_age_low_nbr = m.corrected_gest_age_low_nbr, reply->new_drc_info[cnt].
   pma_age_high_nbr = m.corrected_gest_age_high_nbr,
   reply->new_drc_info[cnt].pma_age_unit_disp = m.corrected_gest_age_unit_disp, reply->new_drc_info[
   cnt].pma_age_unit_cki = m.corrected_gest_age_cki, reply->new_drc_info[cnt].route_display = cv
   .display,
   reply->new_drc_info[cnt].route_code_value = cv.code_value, reply->new_drc_info[cnt].
   weight_operator_txt = m.weight_operator_txt, reply->new_drc_info[cnt].weight_low_value = m
   .weight_low_value,
   reply->new_drc_info[cnt].weight_high_value = m.weight_high_value, reply->new_drc_info[cnt].
   weight_unit_disp = m.weight_unit_disp, reply->new_drc_info[cnt].weight_unit_cki = m
   .weight_unit_cki,
   reply->new_drc_info[cnt].crcl_age_operator_txt = m.renal_operator_txt, reply->new_drc_info[cnt].
   crcl_age_low_nbr = m.renal_low_value, reply->new_drc_info[cnt].crcl_age_high_nbr = m
   .renal_high_value,
   reply->new_drc_info[cnt].crcl_age_unit_disp = m.renal_unit_disp, reply->new_drc_info[cnt].
   crcl_age_unit_cki = m.renal_unit_cki
   IF (cnvtupper(m.liver_desc)="YES")
    reply->new_drc_info[cnt].hepatic = "Yes"
   ELSE
    reply->new_drc_info[cnt].hepatic = "NO"
   ENDIF
   stat = alterlist(reply->new_drc_info[cnt].dose_range_list,5)
  HEAD m.dose_range_type_id
   sub_cnt = (sub_cnt+ 1), sub_list_cnt = (sub_list_cnt+ 1)
   IF (sub_list_cnt > 5)
    stat = alterlist(reply->new_drc_info[cnt].dose_range_list,(sub_cnt+ 5)), sub_list_cnt = 1
   ENDIF
   reply->new_drc_info[cnt].dose_range_list[sub_cnt].dose_range_type = m.dose_range_type, reply->
   new_drc_info[cnt].dose_range_list[sub_cnt].dose_range_type_id = m.dose_range_type_id, reply->
   new_drc_info[cnt].dose_range_list[sub_cnt].low_dose_value = m.low_dose_value,
   reply->new_drc_info[cnt].dose_range_list[sub_cnt].high_dose_value = m.high_dose_value, reply->
   new_drc_info[cnt].dose_range_list[sub_cnt].dose_unit_disp = m.dose_unit_disp, reply->new_drc_info[
   cnt].dose_range_list[sub_cnt].dose_unit_cki = m.dose_unit_cki,
   reply->new_drc_info[cnt].dose_range_list[sub_cnt].comment_txt = m.comment_txt, ftemp = findstring(
    "LEXI!",m.drc_identifier,1,1)
   IF (ftemp > 0)
    reply->new_drc_info[cnt].dose_range_list[sub_cnt].source = "Lexi-Comp"
   ELSE
    reply->new_drc_info[cnt].dose_range_list[sub_cnt].source = "Multum"
   ENDIF
  FOOT  m.drc_identifier
   stat = alterlist(reply->new_drc_info[cnt].dose_range_list,sub_cnt)
  FOOT REPORT
   stat = alterlist(reply->new_drc_info,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM mltm_drc_premise m,
   code_value cv,
   dcp_entity_reltn d,
   code_value cv2,
   nomenclature n
  PLAN (m
   WHERE (m.grouper_id=request->grouper_id)
    AND m.parent_premise_id=0
    AND m.dose_range_type_id != 5
    AND m.dose_unit_cki > " "
    AND m.max_dose_unit_cki IN ("", " ", null)
    AND m.condition_concept_cki > " ")
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
   cnt = 0, list_cnt = 0, stat = alterlist(reply->new_drc_info,100)
  HEAD m.drc_identifier
   sub_cnt = 0, sub_list_cnt = 0, list_cnt = (list_cnt+ 1),
   cnt = (cnt+ 1)
   IF (list_cnt > 100)
    stat = alterlist(reply->new_drc_info,(cnt+ 100)), list_cnt = 1
   ENDIF
   reply->new_drc_info[cnt].drc_identifier = m.drc_identifier, reply->new_drc_info[cnt].
   age_operator_txt = m.age_operator_txt, reply->new_drc_info[cnt].age_low_nbr = m.age_low_nbr,
   reply->new_drc_info[cnt].age_high_nbr = m.age_high_nbr, reply->new_drc_info[cnt].age_unit_disp = m
   .age_unit_disp, reply->new_drc_info[cnt].age_unit_cki = m.age_unit_cki,
   reply->new_drc_info[cnt].pma_age_operator_txt = m.corrected_gest_age_oper_txt, reply->
   new_drc_info[cnt].pma_age_low_nbr = m.corrected_gest_age_low_nbr, reply->new_drc_info[cnt].
   pma_age_high_nbr = m.corrected_gest_age_high_nbr,
   reply->new_drc_info[cnt].pma_age_unit_disp = m.corrected_gest_age_unit_disp, reply->new_drc_info[
   cnt].pma_age_unit_cki = m.corrected_gest_age_cki, reply->new_drc_info[cnt].route_display = cv2
   .display,
   reply->new_drc_info[cnt].route_code_value = cv2.code_value, reply->new_drc_info[cnt].
   weight_operator_txt = m.weight_operator_txt, reply->new_drc_info[cnt].weight_low_value = m
   .weight_low_value,
   reply->new_drc_info[cnt].weight_high_value = m.weight_high_value, reply->new_drc_info[cnt].
   weight_unit_disp = m.weight_unit_disp, reply->new_drc_info[cnt].weight_unit_cki = m
   .weight_unit_cki,
   reply->new_drc_info[cnt].crcl_age_operator_txt = m.renal_operator_txt, reply->new_drc_info[cnt].
   crcl_age_low_nbr = m.renal_low_value, reply->new_drc_info[cnt].crcl_age_high_nbr = m
   .renal_high_value,
   reply->new_drc_info[cnt].crcl_age_unit_disp = m.renal_unit_disp, reply->new_drc_info[cnt].
   crcl_age_unit_cki = m.renal_unit_cki
   IF (cnvtupper(m.liver_desc)="YES")
    reply->new_drc_info[cnt].hepatic = "Yes"
   ELSE
    reply->new_drc_info[cnt].hepatic = "NO"
   ENDIF
   reply->new_drc_info[cnt].clinical_condition = n.source_string, stat = alterlist(reply->
    new_drc_info[cnt].dose_range_list,5)
  HEAD m.dose_range_type_id
   sub_cnt = (sub_cnt+ 1), sub_list_cnt = (sub_list_cnt+ 1)
   IF (sub_list_cnt > 5)
    stat = alterlist(reply->new_drc_info[cnt].dose_range_list,(sub_cnt+ 5)), sub_list_cnt = 1
   ENDIF
   reply->new_drc_info[cnt].dose_range_list[sub_cnt].dose_range_type = m.dose_range_type, reply->
   new_drc_info[cnt].dose_range_list[sub_cnt].dose_range_type_id = m.dose_range_type_id, reply->
   new_drc_info[cnt].dose_range_list[sub_cnt].low_dose_value = m.low_dose_value,
   reply->new_drc_info[cnt].dose_range_list[sub_cnt].high_dose_value = m.high_dose_value, reply->
   new_drc_info[cnt].dose_range_list[sub_cnt].dose_unit_disp = cv.display, reply->new_drc_info[cnt].
   dose_range_list[sub_cnt].dose_unit_cki = m.dose_unit_cki,
   reply->new_drc_info[cnt].dose_range_list[sub_cnt].comment_txt = m.comment_txt, ftemp = findstring(
    "LEXI!",m.drc_identifier,1,1)
   IF (ftemp > 0)
    reply->new_drc_info[cnt].dose_range_list[sub_cnt].source = "Lexi-Comp"
   ELSE
    reply->new_drc_info[cnt].dose_range_list[sub_cnt].source = "Multum"
   ENDIF
  FOOT  m.drc_identifier
   stat = alterlist(reply->new_drc_info[cnt].dose_range_list,sub_cnt)
  FOOT REPORT
   stat = alterlist(reply->new_drc_info,cnt)
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
   WHERE (m.grouper_id=request->grouper_id)
    AND m.parent_premise_id=0
    AND m.dose_range_type_id != 5
    AND m.dose_unit_cki > " "
    AND m.max_dose_unit_cki > " "
    AND m.condition_concept_cki > " ")
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
   cnt = size(reply->new_drc_info,5), list_cnt = 0, stat = alterlist(reply->new_drc_info,(cnt+ 100))
  HEAD m.drc_identifier
   sub_cnt = 0, sub_list_cnt = 0, list_cnt = (list_cnt+ 1),
   cnt = (cnt+ 1)
   IF (list_cnt > 100)
    stat = alterlist(reply->new_drc_info,(cnt+ 100)), list_cnt = 1
   ENDIF
   reply->new_drc_info[cnt].drc_identifier = m.drc_identifier, reply->new_drc_info[cnt].
   age_operator_txt = m.age_operator_txt, reply->new_drc_info[cnt].age_low_nbr = m.age_low_nbr,
   reply->new_drc_info[cnt].age_high_nbr = m.age_high_nbr, reply->new_drc_info[cnt].age_unit_disp = m
   .age_unit_disp, reply->new_drc_info[cnt].age_unit_cki = m.age_unit_cki,
   reply->new_drc_info[cnt].pma_age_operator_txt = m.corrected_gest_age_oper_txt, reply->
   new_drc_info[cnt].pma_age_low_nbr = m.corrected_gest_age_low_nbr, reply->new_drc_info[cnt].
   pma_age_high_nbr = m.corrected_gest_age_high_nbr,
   reply->new_drc_info[cnt].pma_age_unit_disp = m.corrected_gest_age_unit_disp, reply->new_drc_info[
   cnt].pma_age_unit_cki = m.corrected_gest_age_cki, reply->new_drc_info[cnt].route_display = cv2
   .display,
   reply->new_drc_info[cnt].route_code_value = cv2.code_value, reply->new_drc_info[cnt].
   weight_operator_txt = m.weight_operator_txt, reply->new_drc_info[cnt].weight_low_value = m
   .weight_low_value,
   reply->new_drc_info[cnt].weight_high_value = m.weight_high_value, reply->new_drc_info[cnt].
   weight_unit_disp = m.weight_unit_disp, reply->new_drc_info[cnt].weight_unit_cki = m
   .weight_unit_cki,
   reply->new_drc_info[cnt].crcl_age_operator_txt = m.renal_operator_txt, reply->new_drc_info[cnt].
   crcl_age_low_nbr = m.renal_low_value, reply->new_drc_info[cnt].crcl_age_high_nbr = m
   .renal_high_value,
   reply->new_drc_info[cnt].crcl_age_unit_disp = m.renal_unit_disp, reply->new_drc_info[cnt].
   crcl_age_unit_cki = m.renal_unit_cki
   IF (cnvtupper(m.liver_desc)="YES")
    reply->new_drc_info[cnt].hepatic = "Yes"
   ELSE
    reply->new_drc_info[cnt].hepatic = "NO"
   ENDIF
   reply->new_drc_info[cnt].clinical_condition = n.source_string, stat = alterlist(reply->
    new_drc_info[cnt].dose_range_list,5)
  HEAD m.dose_range_type_id
   sub_cnt = (sub_cnt+ 1), sub_list_cnt = (sub_list_cnt+ 1)
   IF (sub_list_cnt > 5)
    stat = alterlist(reply->new_drc_info[cnt].dose_range_list,(sub_cnt+ 5)), sub_list_cnt = 1
   ENDIF
   reply->new_drc_info[cnt].dose_range_list[sub_cnt].dose_range_type = m.dose_range_type, reply->
   new_drc_info[cnt].dose_range_list[sub_cnt].dose_range_type_id = m.dose_range_type_id, reply->
   new_drc_info[cnt].dose_range_list[sub_cnt].low_dose_value = m.low_dose_value,
   reply->new_drc_info[cnt].dose_range_list[sub_cnt].high_dose_value = m.high_dose_value, reply->
   new_drc_info[cnt].dose_range_list[sub_cnt].dose_unit_disp = cv.display, reply->new_drc_info[cnt].
   dose_range_list[sub_cnt].dose_unit_cki = m.dose_unit_cki,
   reply->new_drc_info[cnt].dose_range_list[sub_cnt].comment_txt = m.comment_txt, reply->
   new_drc_info[cnt].dose_range_list[sub_cnt].max_dose_amt = m.max_dose_amt, reply->new_drc_info[cnt]
   .dose_range_list[sub_cnt].max_dose_unit_disp = cv3.display,
   reply->new_drc_info[cnt].dose_range_list[sub_cnt].max_dose_unit_cki = m.max_dose_unit_cki, ftemp
    = findstring("LEXI!",m.drc_identifier,1,1)
   IF (ftemp > 0)
    reply->new_drc_info[cnt].dose_range_list[sub_cnt].source = "Lexi-Comp"
   ELSE
    reply->new_drc_info[cnt].dose_range_list[sub_cnt].source = "Multum"
   ENDIF
  FOOT  m.drc_identifier
   stat = alterlist(reply->new_drc_info[cnt].dose_range_list,sub_cnt)
  FOOT REPORT
   stat = alterlist(reply->new_drc_info,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM mltm_drc_premise m,
   code_value cv,
   dcp_entity_reltn d,
   nomenclature n
  PLAN (m
   WHERE (m.grouper_id=request->grouper_id)
    AND m.parent_premise_id=0
    AND m.dose_range_type_id=5
    AND m.comment_txt > " "
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
   cnt = size(reply->new_drc_info,5), list_cnt = 0, stat = alterlist(reply->new_drc_info,(cnt+ 100))
  HEAD m.drc_identifier
   sub_cnt = 0, sub_list_cnt = 0, list_cnt = (list_cnt+ 1),
   cnt = (cnt+ 1)
   IF (list_cnt > 100)
    stat = alterlist(reply->new_drc_info,(cnt+ 100)), list_cnt = 1
   ENDIF
   reply->new_drc_info[cnt].drc_identifier = m.drc_identifier, reply->new_drc_info[cnt].
   age_operator_txt = m.age_operator_txt, reply->new_drc_info[cnt].age_low_nbr = m.age_low_nbr,
   reply->new_drc_info[cnt].age_high_nbr = m.age_high_nbr, reply->new_drc_info[cnt].age_unit_disp = m
   .age_unit_disp, reply->new_drc_info[cnt].age_unit_cki = m.age_unit_cki,
   reply->new_drc_info[cnt].pma_age_operator_txt = m.corrected_gest_age_oper_txt, reply->
   new_drc_info[cnt].pma_age_low_nbr = m.corrected_gest_age_low_nbr, reply->new_drc_info[cnt].
   pma_age_high_nbr = m.corrected_gest_age_high_nbr,
   reply->new_drc_info[cnt].pma_age_unit_disp = m.corrected_gest_age_unit_disp, reply->new_drc_info[
   cnt].pma_age_unit_cki = m.corrected_gest_age_cki, reply->new_drc_info[cnt].route_display = cv
   .display,
   reply->new_drc_info[cnt].route_code_value = cv.code_value, reply->new_drc_info[cnt].
   weight_operator_txt = m.weight_operator_txt, reply->new_drc_info[cnt].weight_low_value = m
   .weight_low_value,
   reply->new_drc_info[cnt].weight_high_value = m.weight_high_value, reply->new_drc_info[cnt].
   weight_unit_disp = m.weight_unit_disp, reply->new_drc_info[cnt].weight_unit_cki = m
   .weight_unit_cki,
   reply->new_drc_info[cnt].crcl_age_operator_txt = m.renal_operator_txt, reply->new_drc_info[cnt].
   crcl_age_low_nbr = m.renal_low_value, reply->new_drc_info[cnt].crcl_age_high_nbr = m
   .renal_high_value,
   reply->new_drc_info[cnt].crcl_age_unit_disp = m.renal_unit_disp, reply->new_drc_info[cnt].
   crcl_age_unit_cki = m.renal_unit_cki
   IF (cnvtupper(m.liver_desc)="YES")
    reply->new_drc_info[cnt].hepatic = "Yes"
   ELSE
    reply->new_drc_info[cnt].hepatic = "NO"
   ENDIF
   reply->new_drc_info[cnt].clinical_condition = n.source_string, stat = alterlist(reply->
    new_drc_info[cnt].dose_range_list,5)
  HEAD m.dose_range_type_id
   sub_cnt = (sub_cnt+ 1), sub_list_cnt = (sub_list_cnt+ 1)
   IF (sub_list_cnt > 5)
    stat = alterlist(reply->new_drc_info[cnt].dose_range_list,(sub_cnt+ 5)), sub_list_cnt = 1
   ENDIF
   reply->new_drc_info[cnt].dose_range_list[sub_cnt].dose_range_type = m.dose_range_type, reply->
   new_drc_info[cnt].dose_range_list[sub_cnt].dose_range_type_id = m.dose_range_type_id, reply->
   new_drc_info[cnt].dose_range_list[sub_cnt].low_dose_value = m.low_dose_value,
   reply->new_drc_info[cnt].dose_range_list[sub_cnt].high_dose_value = m.high_dose_value, reply->
   new_drc_info[cnt].dose_range_list[sub_cnt].dose_unit_disp = m.dose_unit_disp, reply->new_drc_info[
   cnt].dose_range_list[sub_cnt].dose_unit_cki = m.dose_unit_cki,
   reply->new_drc_info[cnt].dose_range_list[sub_cnt].comment_txt = m.comment_txt, ftemp = findstring(
    "LEXI!",m.drc_identifier,1,1)
   IF (ftemp > 0)
    reply->new_drc_info[cnt].dose_range_list[sub_cnt].source = "Lexi-Comp"
   ELSE
    reply->new_drc_info[cnt].dose_range_list[sub_cnt].source = "Multum"
   ENDIF
  FOOT  m.drc_identifier
   stat = alterlist(reply->new_drc_info[cnt].dose_range_list,sub_cnt)
  FOOT REPORT
   stat = alterlist(reply->new_drc_info,cnt)
  WITH nocounter
 ;end select
 SET rsize = size(reply->new_drc_info,5)
 IF (rsize > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(rsize)),
    code_value cv
   PLAN (d
    WHERE (reply->new_drc_info[d.seq].age_unit_cki > " "))
    JOIN (cv
    WHERE cv.code_set=54
     AND (cv.cki=reply->new_drc_info[d.seq].age_unit_cki))
   ORDER BY d.seq
   DETAIL
    reply->new_drc_info[d.seq].age_unit_disp = cv.display, reply->new_drc_info[d.seq].
    age_unit_meaning = cv.cdf_meaning
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(rsize)),
    code_value cv
   PLAN (d
    WHERE (reply->new_drc_info[d.seq].pma_age_unit_cki > " "))
    JOIN (cv
    WHERE cv.code_set=54
     AND (cv.cki=reply->new_drc_info[d.seq].pma_age_unit_cki))
   ORDER BY d.seq
   DETAIL
    reply->new_drc_info[d.seq].pma_age_unit_disp = cv.display, reply->new_drc_info[d.seq].
    pma_age_unit_meaning = cv.cdf_meaning
   WITH nocounter
  ;end select
 ENDIF
 SET cnt = 0
 IF (drc_id > 0)
  SELECT INTO "nl:"
   FROM drc_premise dp,
    drc_dose_range ddr,
    code_value cv
   PLAN (dp
    WHERE dp.dose_range_check_id=drc_id
     AND dp.premise_type_flag > 0
     AND dp.parent_premise_id > 0)
    JOIN (ddr
    WHERE dp.parent_premise_id=ddr.drc_premise_id
     AND dp.premise_type_flag > 0
     AND ddr.active_ind=1)
    JOIN (cv
    WHERE cv.code_set=4001990
     AND cv.cdf_meaning=trim(cnvtstring(ddr.type_flag))
     AND cv.active_ind=1)
   ORDER BY dp.parent_premise_id, ddr.drc_dose_range_id
   HEAD REPORT
    cnt = 0, list_cnt = 0, stat = alterlist(reply->current_drc_info,100),
    stat = alterlist(temp_curr->current_drc_info,100)
   HEAD dp.parent_premise_id
    sub_cnt = 0, sub_list_cnt = 0, list_cnt = (list_cnt+ 1),
    cnt = (cnt+ 1)
    IF (list_cnt > 100)
     stat = alterlist(reply->current_drc_info,(cnt+ 100)), stat = alterlist(temp_curr->
      current_drc_info,(cnt+ 100)), list_cnt = 1
    ENDIF
    reply->current_drc_info[cnt].parent_premise_id = dp.parent_premise_id, reply->current_drc_info[
    cnt].active_ind = 0, stat = alterlist(reply->current_drc_info[cnt].dose_range_list,5),
    stat = alterlist(temp_curr->current_drc_info[cnt].dose_range_list,5)
   HEAD ddr.drc_dose_range_id
    sub_cnt = (sub_cnt+ 1), sub_list_cnt = (sub_list_cnt+ 1)
    IF (sub_list_cnt > 5)
     stat = alterlist(reply->current_drc_info[cnt].dose_range_list,(sub_cnt+ 5)), stat = alterlist(
      temp_curr->current_drc_info[cnt].dose_range_list,(sub_cnt+ 5)), sub_list_cnt = 1
    ENDIF
    temp_curr->current_drc_info[cnt].dose_range_list[sub_cnt].dose_range_id = ddr.drc_dose_range_id,
    reply->current_drc_info[cnt].dose_range_list[sub_cnt].dose_range_type = cv.display, reply->
    current_drc_info[cnt].dose_range_list[sub_cnt].dose_range_type_id = ddr.type_flag,
    reply->current_drc_info[cnt].dose_range_list[sub_cnt].low_dose_value = ddr.min_value, reply->
    current_drc_info[cnt].dose_range_list[sub_cnt].high_dose_value = ddr.max_value, reply->
    current_drc_info[cnt].dose_range_list[sub_cnt].max_dose_amt = ddr.max_dose,
    reply->current_drc_info[cnt].dose_range_list[sub_cnt].source = "Multum"
   FOOT  dp.parent_premise_id
    stat = alterlist(reply->current_drc_info[cnt].dose_range_list,sub_cnt), stat = alterlist(
     temp_curr->current_drc_info[cnt].dose_range_list,sub_cnt)
   FOOT REPORT
    stat = alterlist(reply->current_drc_info,cnt), stat = alterlist(temp_curr->current_drc_info,cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    drc_premise dp,
    code_value cv,
    dummyt d2
   PLAN (d)
    JOIN (dp
    WHERE (dp.parent_premise_id=reply->current_drc_info[d.seq].parent_premise_id))
    JOIN (d2)
    JOIN (cv
    WHERE cv.code_value=dp.value_unit_cd)
   ORDER BY d.seq, dp.parent_premise_id
   DETAIL
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
     reply->current_drc_info[d.seq].age_operator_txt = operator, reply->current_drc_info[d.seq].
     age_low_nbr = dp.value1, reply->current_drc_info[d.seq].age_high_nbr = dp.value2,
     reply->current_drc_info[d.seq].age_unit_disp = cv.display, reply->current_drc_info[d.seq].
     age_unit_cki = cv.cki, reply->current_drc_info[d.seq].age_unit_meaning = cv.cdf_meaning
    ELSEIF (dp.premise_type_flag=3)
     reply->current_drc_info[d.seq].weight_operator_txt = operator, reply->current_drc_info[d.seq].
     weight_low_value = dp.value1, reply->current_drc_info[d.seq].weight_high_value = dp.value2,
     reply->current_drc_info[d.seq].weight_unit_disp = cv.display, reply->current_drc_info[d.seq].
     weight_unit_cki = cv.cki
    ELSEIF (dp.premise_type_flag=4)
     reply->current_drc_info[d.seq].crcl_age_operator_txt = operator, reply->current_drc_info[d.seq].
     crcl_age_low_nbr = dp.value1, reply->current_drc_info[d.seq].crcl_age_high_nbr = dp.value2,
     reply->current_drc_info[d.seq].crcl_age_unit_disp = cv.display, reply->current_drc_info[d.seq].
     crcl_age_unit_cki = cv.cki
    ELSEIF (dp.premise_type_flag=5)
     reply->current_drc_info[d.seq].pma_age_operator_txt = operator, reply->current_drc_info[d.seq].
     pma_age_low_nbr = dp.value1, reply->current_drc_info[d.seq].pma_age_high_nbr = dp.value2,
     reply->current_drc_info[d.seq].pma_age_unit_disp = cv.display, reply->current_drc_info[d.seq].
     pma_age_unit_cki = cv.cki, reply->current_drc_info[d.seq].pma_age_unit_meaning = cv.cdf_meaning
    ELSEIF (dp.premise_type_flag=6)
     IF (dp.value1=1)
      reply->current_drc_info[d.seq].hepatic = "Yes"
     ELSEIF (dp.value1=0)
      reply->current_drc_info[d.seq].hepatic = "NO"
     ENDIF
    ELSEIF (dp.premise_type_flag=7)
     reply->current_drc_info[d.seq].clinical_condition = dp.concept_cki
    ENDIF
   WITH nocoutner, outerjoin = d2
  ;end select
  FOR (x = 1 TO cnt)
    SET list_cnt = size(reply->current_drc_info[x].dose_range_list,5)
    IF (list_cnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = list_cnt),
       drc_dose_range ddr,
       code_value cv,
       code_value cv2
      PLAN (d
       WHERE (reply->current_drc_info[x].dose_range_list[d.seq].dose_range_type_id != 5))
       JOIN (ddr
       WHERE (ddr.drc_dose_range_id=temp_curr->current_drc_info[x].dose_range_list[d.seq].
       dose_range_id))
       JOIN (cv
       WHERE cv.code_value=ddr.value_unit_cd)
       JOIN (cv2
       WHERE cv2.code_value=outerjoin(ddr.max_dose_unit_cd))
      ORDER BY d.seq
      DETAIL
       reply->current_drc_info[x].dose_range_list[d.seq].dose_unit_disp = cv.display, reply->
       current_drc_info[x].dose_range_list[d.seq].dose_unit_cki = cv.cki
       IF (cv2.code_value > 0)
        reply->current_drc_info[x].dose_range_list[d.seq].max_dose_unit_cki = cv2.cki, reply->
        current_drc_info[x].dose_range_list[d.seq].max_dose_unit_disp = cv2.display
       ENDIF
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = list_cnt),
       drc_dose_range ddr,
       long_text lt
      PLAN (d)
       JOIN (ddr
       WHERE (ddr.drc_dose_range_id=temp_curr->current_drc_info[x].dose_range_list[d.seq].
       dose_range_id)
        AND ddr.long_text_id > 0)
       JOIN (lt
       WHERE lt.long_text_id=ddr.long_text_id)
      ORDER BY d.seq
      DETAIL
       reply->current_drc_info[x].dose_range_list[d.seq].comment_txt = lt.long_text
      WITH nocounter
     ;end select
    ENDIF
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = list_cnt),
      drc_premise dp,
      mltm_drc_premise m,
      nomenclature n
     PLAN (d)
      JOIN (dp
      WHERE (dp.drc_premise_id=reply->current_drc_info[x].parent_premise_id))
      JOIN (m
      WHERE m.dose_range_check_id=outerjoin(dp.dose_range_check_id)
       AND m.drc_identifier=outerjoin(dp.drc_identifier)
       AND m.dose_range_type_id=outerjoin(reply->current_drc_info[x].dose_range_list[d.seq].
       dose_range_type_id))
      JOIN (n
      WHERE n.concept_cki=outerjoin(m.condition_concept_cki)
       AND n.concept_cki > outerjoin(" ")
       AND n.primary_cterm_ind=outerjoin(1)
       AND n.active_ind=outerjoin(1)
       AND n.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
     ORDER BY d.seq
     HEAD d.seq
      mod_ind = 0
     DETAIL
      IF (m.grouper_id=0
       AND dp.drc_identifier IN ("", " ", null))
       reply->current_drc_info[x].dose_range_list[d.seq].source = "Client"
      ELSEIF (m.grouper_id > 0)
       IF ((((m.age_high_nbr != reply->current_drc_info[x].age_high_nbr)) OR ((((m.age_low_nbr !=
       reply->current_drc_info[x].age_low_nbr)) OR ((((m.age_operator_txt != reply->current_drc_info[
       x].age_operator_txt)) OR ((m.age_unit_cki != reply->current_drc_info[x].age_unit_cki))) )) ))
       )
        mod_ind = 1
       ENDIF
       IF ((((m.corrected_gest_age_cki != reply->current_drc_info[x].pma_age_unit_cki)) OR ((((m
       .corrected_gest_age_high_nbr != reply->current_drc_info[x].pma_age_high_nbr)) OR ((((m
       .corrected_gest_age_low_nbr != reply->current_drc_info[x].pma_age_low_nbr)) OR ((m
       .corrected_gest_age_oper_txt != reply->current_drc_info[x].pma_age_operator_txt))) )) )) )
        mod_ind = 1
       ENDIF
       IF ((((m.weight_high_value != reply->current_drc_info[x].weight_high_value)) OR ((((m
       .weight_low_value != reply->current_drc_info[x].weight_low_value)) OR ((((m
       .weight_operator_txt != reply->current_drc_info[x].weight_operator_txt)) OR ((m
       .weight_unit_cki != reply->current_drc_info[x].weight_unit_cki))) )) )) )
        mod_ind = 1
       ENDIF
       IF ((((m.renal_high_value != reply->current_drc_info[x].crcl_age_high_nbr)) OR ((((m
       .renal_low_value != reply->current_drc_info[x].crcl_age_low_nbr)) OR ((((m.renal_operator_txt
        != reply->current_drc_info[x].crcl_age_operator_txt)) OR ((m.renal_unit_cki != reply->
       current_drc_info[x].crcl_age_unit_cki))) )) )) )
        mod_ind = 1
       ENDIF
       IF (cnvtupper(m.liver_desc) != cnvtupper(reply->current_drc_info[x].hepatic))
        mod_ind = 1
       ENDIF
       IF ((n.source_string != reply->current_drc_info[x].clinical_condition)
        AND (reply->current_drc_info[x].clinical_condition > " "))
        mod_ind = 1
       ENDIF
       IF ((((m.low_dose_value != reply->current_drc_info[x].dose_range_list[d.seq].low_dose_value))
        OR ((((m.high_dose_value != reply->current_drc_info[x].dose_range_list[d.seq].high_dose_value
       )) OR ((((m.dose_unit_cki != reply->current_drc_info[x].dose_range_list[d.seq].dose_unit_cki))
        OR ((((m.max_dose_amt != reply->current_drc_info[x].dose_range_list[d.seq].max_dose_amt)) OR
       ((m.max_dose_unit_cki != reply->current_drc_info[x].dose_range_list[d.seq].max_dose_unit_cki)
        AND m.dose_range_type_id != 5)) )) )) )) )
        mod_ind = 1
       ENDIF
       IF ((m.comment_txt != reply->current_drc_info[x].dose_range_list[d.seq].comment_txt)
        AND m.dose_range_type_id=5)
        mod_ind = 1
       ENDIF
      ENDIF
      ftemp = findstring("LEXI!",dp.drc_identifier,1,1)
      IF (ftemp > 0)
       reply->current_drc_info[x].dose_range_list[d.seq].source = "Lexi-Comp"
      ENDIF
      IF (mod_ind=1)
       reply->current_drc_info[x].dose_range_list[d.seq].source = "Modified"
      ENDIF
     WITH nocounter
    ;end select
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    drc_premise dp,
    code_value cv
   PLAN (d)
    JOIN (dp
    WHERE (dp.parent_premise_id=reply->current_drc_info[d.seq].parent_premise_id)
     AND dp.premise_type_flag=2
     AND dp.value_type_flag != 4
     AND dp.value1 > 0)
    JOIN (cv
    WHERE cv.code_value=dp.value1)
   ORDER BY d.seq, dp.parent_premise_id
   DETAIL
    stat = alterlist(reply->current_drc_info[d.seq].route_list,1), reply->current_drc_info[d.seq].
    route_list[1].code_value = cv.code_value, reply->current_drc_info[d.seq].route_list[1].display =
    cv.display
   WITH nocoutner
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    drc_premise dp,
    drc_premise_list dpl,
    code_value cv
   PLAN (d)
    JOIN (dp
    WHERE (dp.parent_premise_id=reply->current_drc_info[d.seq].parent_premise_id)
     AND dp.premise_type_flag=2
     AND dp.value_type_flag=4)
    JOIN (dpl
    WHERE dpl.drc_premise_id=dp.drc_premise_id)
    JOIN (cv
    WHERE cv.code_value=dpl.parent_entity_id)
   ORDER BY dpl.drc_premise_id
   HEAD dpl.drc_premise_id
    sub_cnt = size(reply->current_drc_info[d.seq].route_list,5), sub_list_cnt = 0, stat = alterlist(
     reply->current_drc_info[d.seq].route_list,(sub_cnt+ 10))
   DETAIL
    sub_list_cnt = (sub_list_cnt+ 1), sub_cnt = (sub_cnt+ 1)
    IF (sub_list_cnt > 10)
     stat = alterlist(reply->current_drc_info[d.seq].route_list,(sub_cnt+ 10)), sub_list_cnt = 1
    ENDIF
    reply->current_drc_info[d.seq].route_list[sub_cnt].code_value = cv.code_value, reply->
    current_drc_info[d.seq].route_list[sub_cnt].display = cv.display
   FOOT  dpl.drc_premise_id
    stat = alterlist(reply->current_drc_info[d.seq].route_list,sub_cnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    nomenclature n
   PLAN (d
    WHERE (reply->current_drc_info[d.seq].clinical_condition > " "))
    JOIN (n
    WHERE (n.concept_cki=reply->current_drc_info[d.seq].clinical_condition)
     AND n.primary_cterm_ind=1
     AND n.active_ind=1
     AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   DETAIL
    reply->current_drc_info[d.seq].clinical_condition = n.source_string
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    drc_premise dp
   PLAN (d)
    JOIN (dp
    WHERE (dp.drc_premise_id=reply->current_drc_info[d.seq].parent_premise_id))
   DETAIL
    reply->current_drc_info[d.seq].active_ind = dp.active_ind
   WITH nocounter
  ;end select
 ENDIF
 SET cnt2 = size(reply->new_drc_info,5)
#exit_script
 IF (((cnt > 0) OR (cnt2 > 0)) )
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
