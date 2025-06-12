CREATE PROGRAM bed_aud_sch_resources
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
 FREE SET temp_dept
 RECORD temp_dept(
   1 departments[*]
     2 dept_code_value = f8
     2 display = vc
     2 prefix = vc
     2 dept_type
       3 display = vc
     2 r_cnt = i4
     2 resource[*]
       3 name = vc
 )
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM sch_resource s
   WHERE s.active_ind=1
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 2000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,3)
 SET reply->collist[1].header_text = "Department Type"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Department Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Resource Name"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET tot_cnt = 0
 SELECT INTO "nl:"
  FROM br_sched_dept bsd,
   br_sched_dept_type bsdt,
   sch_appt_loc sal,
   code_value cv,
   code_value cv2
  PLAN (bsd
   WHERE bsd.location_cd > 0)
   JOIN (bsdt
   WHERE bsdt.dept_type_id=bsd.dept_type_id)
   JOIN (sal
   WHERE sal.location_cd=bsd.location_cd
    AND sal.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=bsd.location_cd
    AND cv.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=sal.appt_type_cd
    AND cv2.active_ind=1)
  ORDER BY bsdt.dept_type_display, cv.display
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(temp_dept->departments,100)
  HEAD bsd.location_cd
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(temp_dept->departments,(tot_cnt+ 100)), cnt = 1
   ENDIF
   temp_dept->departments[tot_cnt].dept_code_value = bsd.location_cd, temp_dept->departments[tot_cnt]
   .display = cv.display, temp_dept->departments[tot_cnt].prefix = bsd.dept_prefix,
   temp_dept->departments[tot_cnt].dept_type.display = bsdt.dept_type_display
  FOOT REPORT
   stat = alterlist(temp_dept->departments,tot_cnt)
  WITH nocounter
 ;end select
 IF (tot_cnt=0)
  GO TO exit_script
 ENDIF
 SELECT DISTINCT INTO "nl:"
  c.display
  FROM (dummyt d  WITH seq = tot_cnt),
   sch_order_role sor,
   sch_list_res sr,
   code_value c
  PLAN (d)
   JOIN (sor
   WHERE (sor.location_cd=temp_dept->departments[d.seq].dept_code_value)
    AND sor.active_ind=1)
   JOIN (sr
   WHERE sor.list_role_id=sr.list_role_id
    AND sr.active_ind=1)
   JOIN (c
   WHERE sr.resource_cd=c.code_value
    AND c.active_ind=1)
  ORDER BY c.display
  DETAIL
   temp_dept->departments[d.seq].r_cnt = (temp_dept->departments[d.seq].r_cnt+ 1), stat = alterlist(
    temp_dept->departments[d.seq].resource,temp_dept->departments[d.seq].r_cnt), temp_dept->
   departments[d.seq].resource[temp_dept->departments[d.seq].r_cnt].name = c.display
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  c.display
  FROM (dummyt d  WITH seq = tot_cnt),
   sch_appt_loc sal,
   sch_resource_list srl,
   sch_list_role slr,
   sch_list_res sr,
   code_value c
  PLAN (d)
   JOIN (sal
   WHERE (sal.location_cd=temp_dept->departments[d.seq].dept_code_value)
    AND sal.active_ind=1)
   JOIN (srl
   WHERE srl.res_list_id=sal.res_list_id
    AND srl.active_ind=1)
   JOIN (slr
   WHERE slr.res_list_id=srl.res_list_id
    AND slr.active_ind=1)
   JOIN (sr
   WHERE sr.list_role_id=slr.list_role_id
    AND sr.active_ind=1)
   JOIN (c
   WHERE sr.resource_cd=c.code_value
    AND c.active_ind=1)
  ORDER BY c.display
  DETAIL
   temp_dept->departments[d.seq].r_cnt = (temp_dept->departments[d.seq].r_cnt+ 1), stat = alterlist(
    temp_dept->departments[d.seq].resource,temp_dept->departments[d.seq].r_cnt), temp_dept->
   departments[d.seq].resource[temp_dept->departments[d.seq].r_cnt].name = c.display
  WITH nocounter
 ;end select
 SET rows = 0
 SET cells = 3
 FOR (i = 1 TO tot_cnt)
   IF ((temp_dept->departments[i].r_cnt > 0))
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = temp_dept->departments[i].r_cnt)
     PLAN (d)
     ORDER BY temp_dept->departments[i].resource[d.seq].name
     DETAIL
      IF (((d.seq=1) OR (d.seq > 1
       AND (reply->rowlist[rows].celllist[3].string_value != temp_dept->departments[i].resource[d.seq
      ].name))) )
       rows = (rows+ 1), stat = alterlist(reply->rowlist,rows), stat = alterlist(reply->rowlist[rows]
        .celllist,cells),
       reply->rowlist[rows].celllist[1].string_value = temp_dept->departments[i].dept_type.display,
       reply->rowlist[rows].celllist[2].string_value = temp_dept->departments[i].display, reply->
       rowlist[rows].celllist[3].string_value = temp_dept->departments[i].resource[d.seq].name
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("scheduling_resources.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL echorecord(reply)
END GO
