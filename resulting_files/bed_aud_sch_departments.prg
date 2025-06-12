CREATE PROGRAM bed_aud_sch_departments
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
 FREE SET temp
 RECORD temp(
   1 dept[*]
     2 location_cd = f8
     2 location_disp = vc
     2 building_disp = vc
     2 facility_disp = vc
     2 type_disp = vc
     2 type_id = f8
     2 prefix = vc
     2 oc_cnt = i4
     2 oc_details[*]
       3 catalog_type = vc
       3 activity_type = vc
       3 subactivity_type = vc
 )
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM br_sched_dept b
   PLAN (b)
   DETAIL
    high_volume_cnt = hv_cnt
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
 SET stat = alterlist(reply->collist,8)
 SET reply->collist[1].header_text = "Facility Display"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Building Display"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Department Name"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Department Type"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Department Prefix"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Default Catalog Type"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Default Activity Type"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Default Subactivity Type"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET building_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value c
  WHERE c.code_set=222
   AND c.cdf_meaning="BUILDING"
  DETAIL
   building_cd = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 SET facility_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value c
  WHERE c.code_set=222
   AND c.cdf_meaning="FACILITY"
  DETAIL
   facility_cd = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 SET dept_cnt = 0
 SELECT INTO "NL:"
  FROM br_sched_dept d,
   br_sched_dept_type dt,
   code_value c,
   location_group g1,
   location l1,
   code_value c1,
   location_group g2,
   location l2,
   code_value c2
  PLAN (d)
   JOIN (dt
   WHERE dt.dept_type_id=d.dept_type_id)
   JOIN (c
   WHERE c.code_value=d.location_cd
    AND c.active_ind=1)
   JOIN (g1
   WHERE g1.child_loc_cd=d.location_cd
    AND g1.active_ind=1
    AND g1.root_loc_cd=0.0)
   JOIN (l1
   WHERE l1.location_cd=g1.parent_loc_cd
    AND l1.active_ind=1
    AND l1.location_type_cd=building_cd)
   JOIN (c1
   WHERE c1.code_value=l1.location_cd)
   JOIN (g2
   WHERE g2.child_loc_cd=l1.location_cd
    AND g2.active_ind=1
    AND g2.root_loc_cd=0.0)
   JOIN (l2
   WHERE l2.location_cd=g2.parent_loc_cd
    AND l2.active_ind=1
    AND l2.location_type_cd=facility_cd)
   JOIN (c2
   WHERE c2.code_value=l2.location_cd)
  ORDER BY c2.display, c1.display, c.display
  DETAIL
   dept_cnt = (dept_cnt+ 1), stat = alterlist(temp->dept,dept_cnt), temp->dept[dept_cnt].
   facility_disp = c2.display,
   temp->dept[dept_cnt].building_disp = c1.display, temp->dept[dept_cnt].location_disp = c.display,
   temp->dept[dept_cnt].location_cd = d.location_cd,
   temp->dept[dept_cnt].prefix = d.dept_prefix, temp->dept[dept_cnt].type_disp = dt.dept_type_display,
   temp->dept[dept_cnt].type_id = d.dept_type_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM br_sched_dept_ord_r do,
   code_value oc,
   code_value at,
   code_value st,
   (dummyt d  WITH seq = dept_cnt)
  PLAN (d)
   JOIN (do
   WHERE (do.location_cd=temp->dept[d.seq].location_cd))
   JOIN (oc
   WHERE oc.code_value=do.catalog_type_cd)
   JOIN (at
   WHERE at.code_value=do.activity_type_cd)
   JOIN (st
   WHERE st.code_value=do.activity_subtype_cd)
  DETAIL
   temp->dept[d.seq].oc_cnt = (temp->dept[d.seq].oc_cnt+ 1), stat = alterlist(temp->dept[d.seq].
    oc_details,temp->dept[d.seq].oc_cnt), temp->dept[d.seq].oc_details[temp->dept[d.seq].oc_cnt].
   catalog_type = oc.display,
   temp->dept[d.seq].oc_details[temp->dept[d.seq].oc_cnt].activity_type = at.display, temp->dept[d
   .seq].oc_details[temp->dept[d.seq].oc_cnt].subactivity_type = st.display
  WITH nocounter
 ;end select
 SET rows = 0
 FOR (i = 1 TO dept_cnt)
   SET rows = (rows+ 1)
   SET stat = alterlist(reply->rowlist,rows)
   SET stat = alterlist(reply->rowlist[rows].celllist,8)
   SET reply->rowlist[rows].celllist[1].string_value = temp->dept[i].facility_disp
   SET reply->rowlist[rows].celllist[2].string_value = temp->dept[i].building_disp
   SET reply->rowlist[rows].celllist[3].string_value = temp->dept[i].location_disp
   SET reply->rowlist[rows].celllist[4].string_value = temp->dept[i].type_disp
   SET reply->rowlist[rows].celllist[5].string_value = temp->dept[i].prefix
   FOR (ii = 1 TO temp->dept[i].oc_cnt)
     IF (ii > 1)
      SET rows = (rows+ 1)
      SET stat = alterlist(reply->rowlist,rows)
      SET stat = alterlist(reply->rowlist[rows].celllist,8)
     ENDIF
     SET reply->rowlist[rows].celllist[6].string_value = temp->dept[i].oc_details[ii].catalog_type
     SET reply->rowlist[rows].celllist[7].string_value = temp->dept[i].oc_details[ii].activity_type
     SET reply->rowlist[rows].celllist[8].string_value = temp->dept[i].oc_details[ii].
     subactivity_type
   ENDFOR
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("scheduling_departments.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL echorecord(reply)
END GO
