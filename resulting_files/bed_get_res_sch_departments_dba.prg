CREATE PROGRAM bed_get_res_sch_departments:dba
 FREE SET reply
 RECORD reply(
   1 departments[*]
     2 dept_code_value = f8
     2 display = vc
     2 prefix = vc
     2 reviewed_ind = i2
     2 dept_type
       3 dept_type_id = f8
       3 display = vc
       3 prefix = vc
     2 meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET temp_dept
 RECORD temp_dept(
   1 departments[*]
     2 dept_code_value = f8
     2 display = vc
     2 prefix = vc
     2 reviewed_ind = i2
     2 dept_type
       3 dept_type_id = f8
       3 display = vc
       3 prefix = vc
     2 meaning = vc
 )
 SET reply->status_data.status = "F"
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
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(temp_dept->departments,100)
  HEAD bsd.location_cd
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(temp_dept->departments,(tot_cnt+ 100)), cnt = 1
   ENDIF
   temp_dept->departments[tot_cnt].dept_code_value = bsd.location_cd, temp_dept->departments[tot_cnt]
   .display = cv.display, temp_dept->departments[tot_cnt].meaning = cv.cdf_meaning,
   temp_dept->departments[tot_cnt].prefix = bsd.dept_prefix, temp_dept->departments[tot_cnt].
   dept_type.dept_type_id = bsdt.dept_type_id, temp_dept->departments[tot_cnt].dept_type.display =
   bsdt.dept_type_display,
   temp_dept->departments[tot_cnt].dept_type.prefix = bsdt.dept_type_prefix
  FOOT REPORT
   stat = alterlist(temp_dept->departments,tot_cnt)
  WITH nocounter
 ;end select
 IF (tot_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tot_cnt),
    sch_appt_loc sal,
    sch_resource_list srl
   PLAN (d)
    JOIN (sal
    WHERE (sal.location_cd=temp_dept->departments[d.seq].dept_code_value)
     AND sal.active_ind=1
     AND sal.res_list_id > 0)
    JOIN (srl
    WHERE srl.res_list_id=sal.res_list_id
     AND srl.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    temp_dept->departments[d.seq].reviewed_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tot_cnt),
    sch_appt_loc sal,
    sch_order_appt soa,
    sch_order_role sor
   PLAN (d
    WHERE (temp_dept->departments[d.seq].reviewed_ind=0))
    JOIN (sal
    WHERE (sal.location_cd=temp_dept->departments[d.seq].dept_code_value)
     AND sal.active_ind=1)
    JOIN (soa
    WHERE soa.appt_type_cd=sal.appt_type_cd
     AND soa.active_ind=1)
    JOIN (sor
    WHERE sor.catalog_cd=soa.catalog_cd
     AND sor.location_cd=sal.location_cd
     AND sor.list_role_id > 0
     AND sor.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    temp_dept->departments[d.seq].reviewed_ind = 1
   WITH nocounter
  ;end select
  IF ((request->show_all_locs_ind=1))
   SET temp_cnt = size(temp_dept->departments,5)
   SET stat = alterlist(reply->departments,temp_cnt)
   FOR (x = 1 TO temp_cnt)
     SET reply->departments[x].dept_code_value = temp_dept->departments[x].dept_code_value
     SET reply->departments[x].display = temp_dept->departments[x].display
     SET reply->departments[x].prefix = temp_dept->departments[x].prefix
     SET reply->departments[x].reviewed_ind = temp_dept->departments[x].reviewed_ind
     SET reply->departments[x].dept_type.dept_type_id = temp_dept->departments[x].dept_type.
     dept_type_id
     SET reply->departments[x].dept_type.display = temp_dept->departments[x].dept_type.display
     SET reply->departments[x].dept_type.prefix = temp_dept->departments[x].dept_type.prefix
     SET reply->departments[x].meaning = temp_dept->departments[x].meaning
   ENDFOR
  ELSEIF ((request->show_all_locs_ind=0))
   SET temp_cnt = size(temp_dept->departments,5)
   SET stat = alterlist(reply->departments,temp_cnt)
   SET rep_cnt = 0
   FOR (x = 1 TO temp_cnt)
     IF ((temp_dept->departments[x].reviewed_ind=1))
      SET rep_cnt = (rep_cnt+ 1)
      SET reply->departments[rep_cnt].dept_code_value = temp_dept->departments[x].dept_code_value
      SET reply->departments[rep_cnt].display = temp_dept->departments[x].display
      SET reply->departments[rep_cnt].prefix = temp_dept->departments[x].prefix
      SET reply->departments[rep_cnt].reviewed_ind = temp_dept->departments[x].reviewed_ind
      SET reply->departments[rep_cnt].dept_type.dept_type_id = temp_dept->departments[x].dept_type.
      dept_type_id
      SET reply->departments[rep_cnt].dept_type.display = temp_dept->departments[x].dept_type.display
      SET reply->departments[rep_cnt].dept_type.prefix = temp_dept->departments[x].dept_type.prefix
      SET reply->departments[rep_cnt].meaning = temp_dept->departments[x].meaning
     ENDIF
   ENDFOR
   SET stat = alterlist(reply->departments,rep_cnt)
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
