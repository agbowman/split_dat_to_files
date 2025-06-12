CREATE PROGRAM bed_aud_rad_loc_srvarea:dba
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
 RECORD temp(
   1 loclist[*]
     2 loc_disp = vc
     2 loc_desc = vc
     2 loc_cd = f8
     2 org_id = f8
     2 org_name = vc
     2 loc_type_cd = f8
     2 not_in_srvarea_ind = i2
     2 mult_srvarea_ind = i2
     2 srvarea_disp1 = vc
     2 srvarea_cd1 = f8
     2 srvarea_disp2 = vc
     2 srvarea_cd2 = f8
 )
 SET stat = alterlist(reply->collist,7)
 SET reply->collist[1].header_text = "Location Description"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Location Display"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Organization"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Location Not in Service Area"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Location in more than one Service Area"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Multiple Service Area 1"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Multiple Service Area 2"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET rad_ac_cd = get_code_value(106,"RADIOLOGY")
 SET rad_ct_cd = get_code_value(6000,"RADIOLOGY")
 SET nu_cd = get_code_value(222,"NURSEUNIT")
 SET amb_cd = get_code_value(222,"AMBULATORY")
 SET srvarea_cd = get_code_value(222,"SRVAREA")
 SET bldg_cd = get_code_value(222,"BUILDING")
 SET totcnt = 0
 SET high_volume_cnt = 0
 SELECT INTO "nl:"
  hv_cnt = count(*)
  FROM location l
  PLAN (l
   WHERE l.location_type_cd IN (amb_cd, nu_cd)
    AND l.active_ind=1)
  DETAIL
   high_volume_cnt = hv_cnt
  WITH nocounter
 ;end select
 IF ((request->skip_volume_check_ind=0))
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt=3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET lcnt = 0
 SELECT INTO "nl:"
  FROM location l1,
   (dummyt d  WITH seq = 1),
   location_group lg,
   location l2
  PLAN (l1
   WHERE l1.location_type_cd IN (amb_cd, nu_cd)
    AND l1.active_ind=1)
   JOIN (d)
   JOIN (lg
   WHERE lg.child_loc_cd=l1.location_cd
    AND lg.location_group_type_cd=srvarea_cd
    AND lg.active_ind=1)
   JOIN (l2
   WHERE l2.location_cd=lg.parent_loc_cd
    AND l2.discipline_type_cd=rad_ct_cd)
  HEAD REPORT
   lcnt = 0
  DETAIL
   lcnt = (lcnt+ 1), stat = alterlist(temp->loclist,lcnt), temp->loclist[lcnt].loc_cd = l1
   .location_cd,
   temp->loclist[lcnt].loc_type_cd = l1.location_type_cd, temp->loclist[lcnt].org_id = l1
   .organization_id, temp->loclist[lcnt].not_in_srvarea_ind = 1
  WITH nocounter, outerjoin = d, dontexist
 ;end select
 SELECT INTO "nl:"
  FROM location l1,
   location_group lg1,
   location l2,
   location_group lg2,
   location l3
  PLAN (l1
   WHERE l1.location_type_cd IN (amb_cd, nu_cd)
    AND l1.active_ind=1)
   JOIN (lg1
   WHERE lg1.child_loc_cd=l1.location_cd
    AND lg1.location_group_type_cd=srvarea_cd
    AND lg1.active_ind=1)
   JOIN (l2
   WHERE l2.location_cd=lg1.parent_loc_cd
    AND l2.discipline_type_cd=rad_ct_cd)
   JOIN (lg2
   WHERE lg2.child_loc_cd=l1.location_cd
    AND lg2.location_group_type_cd=srvarea_cd
    AND lg2.active_ind=1
    AND lg2.parent_loc_cd > lg1.parent_loc_cd)
   JOIN (l3
   WHERE l3.location_cd=lg2.parent_loc_cd
    AND l3.discipline_type_cd=rad_ct_cd)
  DETAIL
   lcnt = (lcnt+ 1), stat = alterlist(temp->loclist,lcnt), temp->loclist[lcnt].loc_cd = l1
   .location_cd,
   temp->loclist[lcnt].loc_type_cd = l1.location_type_cd, temp->loclist[lcnt].org_id = l1
   .organization_id, temp->loclist[lcnt].mult_srvarea_ind = 1,
   temp->loclist[lcnt].srvarea_cd1 = lg1.parent_loc_cd, temp->loclist[lcnt].srvarea_cd2 = lg2
   .parent_loc_cd
  WITH nocounter
 ;end select
 IF (lcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = lcnt),
    code_value cv1
   PLAN (d)
    JOIN (cv1
    WHERE (cv1.code_value=temp->loclist[d.seq].loc_cd))
   DETAIL
    temp->loclist[d.seq].loc_disp = cv1.display, temp->loclist[d.seq].loc_desc = cv1.description
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = lcnt),
    code_value cv1,
    code_value cv2
   PLAN (d
    WHERE (temp->loclist[d.seq].mult_srvarea_ind=1))
    JOIN (cv1
    WHERE (cv1.code_value=temp->loclist[d.seq].srvarea_cd1))
    JOIN (cv2
    WHERE (cv2.code_value=temp->loclist[d.seq].srvarea_cd2))
   DETAIL
    temp->loclist[d.seq].srvarea_disp1 = cv1.display, temp->loclist[d.seq].srvarea_disp2 = cv2
    .display
   WITH nocounter
  ;end select
  SET not_in_srvarea_cnt = 0
  SET mult_srvarea_cnt = 0
  IF (lcnt > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = lcnt),
     location_group lg,
     location l,
     organization o
    PLAN (d)
     JOIN (lg
     WHERE (lg.child_loc_cd=temp->loclist[d.seq].loc_cd)
      AND lg.location_group_type_cd=bldg_cd
      AND lg.active_ind=1)
     JOIN (l
     WHERE l.location_cd=lg.parent_loc_cd
      AND l.active_ind=1)
     JOIN (o
     WHERE o.organization_id=l.organization_id
      AND o.active_ind=1)
    HEAD d.seq
     total_bldgs = 0
    DETAIL
     total_bldgs = (total_bldgs+ 1)
     IF (total_bldgs > 1)
      temp->loclist[d.seq].org_name = "multiple orgs"
     ELSE
      temp->loclist[d.seq].org_name = o.org_name
     ENDIF
    WITH counter
   ;end select
  ENDIF
  SET rcnt = 0
  SELECT INTO "nl:"
   loc_desc = cnvtupper(temp->loclist[d.seq].loc_desc), org_disp = cnvtupper(temp->loclist[d.seq].
    org_name)
   FROM (dummyt d  WITH seq = lcnt)
   ORDER BY loc_desc, org_disp
   DETAIL
    rcnt = (rcnt+ 1), stat = alterlist(reply->rowlist,rcnt), stat = alterlist(reply->rowlist[rcnt].
     celllist,7),
    reply->rowlist[rcnt].celllist[1].string_value = temp->loclist[d.seq].loc_desc, reply->rowlist[
    rcnt].celllist[2].string_value = temp->loclist[d.seq].loc_disp, reply->rowlist[rcnt].celllist[3].
    string_value = temp->loclist[d.seq].org_name
    IF ((temp->loclist[d.seq].not_in_srvarea_ind=1))
     reply->rowlist[rcnt].celllist[4].string_value = "X", not_in_srvarea_cnt = (not_in_srvarea_cnt+ 1
     )
    ELSE
     reply->rowlist[rcnt].celllist[4].string_value = " "
    ENDIF
    IF ((temp->loclist[d.seq].mult_srvarea_ind=1))
     mult_srvarea_cnt = (mult_srvarea_cnt+ 1), reply->rowlist[rcnt].celllist[5].string_value = "X",
     reply->rowlist[rcnt].celllist[6].string_value = temp->loclist[d.seq].srvarea_disp1,
     reply->rowlist[rcnt].celllist[7].string_value = temp->loclist[d.seq].srvarea_disp2
    ELSE
     reply->rowlist[rcnt].celllist[5].string_value = " ", reply->rowlist[rcnt].celllist[6].
     string_value = " ", reply->rowlist[rcnt].celllist[7].string_value = " "
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (rcnt > 0)
  SET reply->run_status_flag = 3
 ELSE
  SET reply->run_status_flag = 1
 ENDIF
 SET stat = alterlist(reply->statlist,2)
 SET reply->statlist[1].statistic_meaning = "RADLOCNOSRVAREA"
 SET reply->statlist[1].total_items = high_volume_cnt
 SET reply->statlist[1].qualifying_items = not_in_srvarea_cnt
 IF (not_in_srvarea_cnt > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
 SET reply->statlist[2].statistic_meaning = "RADLOCMULTSRVAREA"
 SET reply->statlist[2].total_items = high_volume_cnt
 SET reply->statlist[2].qualifying_items = mult_srvarea_cnt
 IF (mult_srvarea_cnt > 0)
  SET reply->statlist[2].status_flag = 3
 ELSE
  SET reply->statlist[2].status_flag = 1
 ENDIF
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf
      AND c.active_ind=1)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("rad_loc_srvarea_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
