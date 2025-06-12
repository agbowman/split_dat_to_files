CREATE PROGRAM bed_aud_rad_srvareas:dba
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
     2 srvarea_disp = vc
     2 srvarea_disp_key = vc
     2 srvarea_cd = f8
     2 srvarea_org_id = f8
     2 srvarea_org_name = vc
     2 loc_disp = vc
     2 loc_desc = vc
     2 loc_cd = f8
     2 loc_org_name = vc
     2 loc_type_cd = f8
 )
 SET stat = alterlist(reply->collist,5)
 SET reply->collist[1].header_text = "Service Area"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Organization (of Associated Service Area)"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Location Display"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Location Description"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Organization (of Associated Location)"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET rad_ac_cd = get_code_value(106,"RADIOLOGY")
 SET rad_ct_cd = get_code_value(6000,"RADIOLOGY")
 SET nu_cd = get_code_value(222,"NURSEUNIT")
 SET amb_cd = get_code_value(222,"AMBULATORY")
 SET cslogin_cd = get_code_value(222,"CSLOGIN")
 SET srvarea_cd = get_code_value(222,"SRVAREA")
 SET bldg_cd = get_code_value(222,"BUILDING")
 SET subsect_cd = get_code_value(223,"SUBSECTION")
 SET bench_cd = get_code_value(223,"BENCH")
 SET instr_cd = get_code_value(223,"INSTRUMENT")
 SET totcnt = 0
 SET high_volume_cnt = 0
 SELECT INTO "nl:"
  hv_cnt = count(*)
  FROM location l
  PLAN (l
   WHERE l.location_type_cd=srvarea_cd
    AND l.discipline_type_cd=rad_ct_cd
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
  loc_desc = cnvtupper(cv2.description)
  FROM location l1,
   code_value cv1,
   organization o1,
   location_group lg,
   location l2,
   code_value cv2
  PLAN (l1
   WHERE l1.location_type_cd=srvarea_cd
    AND l1.discipline_type_cd=rad_ct_cd
    AND l1.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=l1.location_cd
    AND cv1.active_ind=1)
   JOIN (o1
   WHERE o1.organization_id=outerjoin(l1.organization_id))
   JOIN (lg
   WHERE lg.parent_loc_cd=outerjoin(l1.location_cd)
    AND lg.active_ind=outerjoin(1))
   JOIN (l2
   WHERE l2.location_cd=outerjoin(lg.child_loc_cd)
    AND l2.active_ind=outerjoin(1))
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(l2.location_cd)
    AND cv2.active_ind=outerjoin(1))
  ORDER BY cv1.display_key, loc_desc
  HEAD REPORT
   lcnt = 0
  DETAIL
   lcnt = (lcnt+ 1), stat = alterlist(temp->loclist,lcnt), temp->loclist[lcnt].srvarea_cd = l1
   .location_cd,
   temp->loclist[lcnt].srvarea_disp = cv1.display, temp->loclist[lcnt].srvarea_disp_key = cv1
   .display_key
   IF (o1.organization_id > 0)
    temp->loclist[lcnt].srvarea_org_id = o1.organization_id, temp->loclist[lcnt].srvarea_org_name =
    o1.org_name
   ENDIF
   IF (l2.location_cd > 0)
    temp->loclist[lcnt].loc_cd = l2.location_cd, temp->loclist[lcnt].loc_disp = cv2.display, temp->
    loclist[lcnt].loc_desc = cv2.description,
    temp->loclist[lcnt].loc_type_cd = l2.location_type_cd
   ENDIF
  WITH nocounter
 ;end select
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
     temp->loclist[d.seq].loc_org_name = "multiple orgs"
    ELSE
     temp->loclist[d.seq].loc_org_name = o.org_name
    ENDIF
   WITH counter
  ;end select
 ENDIF
 IF (lcnt > 0)
  SET rcnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = lcnt)
   DETAIL
    rcnt = (rcnt+ 1), stat = alterlist(reply->rowlist,rcnt), stat = alterlist(reply->rowlist[rcnt].
     celllist,5),
    reply->rowlist[rcnt].celllist[1].string_value = temp->loclist[d.seq].srvarea_disp, reply->
    rowlist[rcnt].celllist[2].string_value = temp->loclist[d.seq].srvarea_org_name, reply->rowlist[
    rcnt].celllist[4].string_value = temp->loclist[d.seq].loc_desc,
    reply->rowlist[rcnt].celllist[3].string_value = temp->loclist[d.seq].loc_disp, reply->rowlist[
    rcnt].celllist[5].string_value = temp->loclist[d.seq].loc_org_name
   WITH nocounter
  ;end select
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
  SET reply->output_filename = build("rad_srvareas_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
