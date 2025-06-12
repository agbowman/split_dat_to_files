CREATE PROGRAM bed_aud_fn_ppr_filter:dba
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
   1 xlist[*]
     2 filter_entity1_id = f8
     2 facility_disp = vc
     2 facility_disp_key = vc
     2 data_element = vc
     2 data_element_name = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 display = vc
     2 display_key = vc
     2 updt_name = vc
 )
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM filter_entity_reltn fer
   PLAN (fer
    WHERE fer.updt_task=4290310
     AND fer.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND fer.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 15000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 10000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,5)
 SET reply->collist[1].header_text = "Facility"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Data Element"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Data Element Name"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Display"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Update Person"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET row_nbr = 0
 SET xcnt = 0
 SELECT INTO "nl:"
  FROM filter_entity_reltn fer,
   code_value cv1,
   code_value cv2,
   person p
  PLAN (fer
   WHERE fer.updt_task=4290310
    AND fer.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND fer.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cv1
   WHERE cv1.code_value=fer.filter_entity1_id)
   JOIN (cv2
   WHERE cv2.code_value=fer.filter_type_cd)
   JOIN (p
   WHERE p.person_id=outerjoin(fer.updt_id))
  HEAD REPORT
   xcnt = 0
  DETAIL
   xcnt = (xcnt+ 1), stat = alterlist(temp->xlist,xcnt), temp->xlist[xcnt].filter_entity1_id = fer
   .filter_entity1_id,
   temp->xlist[xcnt].facility_disp = cv1.display, temp->xlist[xcnt].facility_disp_key = cv1
   .display_key, temp->xlist[xcnt].data_element = cv2.cdf_meaning,
   temp->xlist[xcnt].data_element_name = cv2.display, temp->xlist[xcnt].parent_entity_name = fer
   .parent_entity_name, temp->xlist[xcnt].parent_entity_id = fer.parent_entity_id,
   temp->xlist[xcnt].updt_name = p.name_full_formatted
  WITH nocounter
 ;end select
 IF (xcnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = xcnt),
   code_value cv
  PLAN (d
   WHERE (temp->xlist[d.seq].parent_entity_name="CODE_VALUE"))
   JOIN (cv
   WHERE (cv.code_value=temp->xlist[d.seq].parent_entity_id)
    AND cv.active_ind=1)
  DETAIL
   temp->xlist[d.seq].display = cv.display, temp->xlist[d.seq].display_key = cv.display_key
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = xcnt),
   organization o
  PLAN (d
   WHERE (temp->xlist[d.seq].parent_entity_name="ORGANIZATION"))
   JOIN (o
   WHERE (o.organization_id=temp->xlist[d.seq].parent_entity_id)
    AND o.active_ind=1)
  DETAIL
   temp->xlist[d.seq].display = o.org_name, temp->xlist[d.seq].display_key = o.org_name_key
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = xcnt),
   health_plan hp
  PLAN (d
   WHERE (temp->xlist[d.seq].parent_entity_name="HEALTH_PLAN"))
   JOIN (hp
   WHERE (hp.health_plan_id=temp->xlist[d.seq].parent_entity_id)
    AND hp.active_ind=1)
  DETAIL
   temp->xlist[d.seq].display = hp.plan_name, temp->xlist[d.seq].display_key = hp.plan_name_key
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  fac = temp->xlist[d.seq].facility_disp_key, f_id = temp->xlist[d.seq].filter_entity1_id, de = temp
  ->xlist[d.seq].data_element,
  disp = temp->xlist[d.seq].display_key
  FROM (dummyt d  WITH seq = xcnt)
  ORDER BY fac, f_id, de,
   disp
  HEAD REPORT
   row_nbr = 0
  DETAIL
   row_nbr = (row_nbr+ 1), stat = alterlist(reply->rowlist,row_nbr), stat = alterlist(reply->rowlist[
    row_nbr].celllist,5),
   reply->rowlist[row_nbr].celllist[1].string_value = temp->xlist[d.seq].facility_disp, reply->
   rowlist[row_nbr].celllist[2].string_value = temp->xlist[d.seq].data_element, reply->rowlist[
   row_nbr].celllist[3].string_value = temp->xlist[d.seq].data_element_name,
   reply->rowlist[row_nbr].celllist[4].string_value = temp->xlist[d.seq].display, reply->rowlist[
   row_nbr].celllist[5].string_value = temp->xlist[d.seq].updt_name
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("firstnet_ppr_filter_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
