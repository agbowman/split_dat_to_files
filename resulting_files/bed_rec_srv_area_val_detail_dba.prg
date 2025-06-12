CREATE PROGRAM bed_rec_srv_area_val_detail:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 paramlist[*]
      2 meaning = vc
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
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 res_collist[*]
      2 header_text = vc
    1 res_rowlist[*]
      2 res_celllist[*]
        3 cell_text = vc
  )
 ENDIF
 RECORD temp(
   1 loclist[*]
     2 loc_disp = vc
     2 loc_desc = vc
     2 loc_cd = f8
     2 loc_type = f8
     2 org_name = vc
     2 not_in_srvarea_ind = i2
     2 multi_srvarea_ind = i2
     2 nbr_srvareas = f8
     2 srvareas[*]
       3 display = vc
 )
 SET lab_ct_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6000
   AND cv.cdf_meaning="GENERAL LAB"
   AND cv.active_ind=1
  DETAIL
   lab_ct_cd = cv.code_value
  WITH nocounter
 ;end select
 SET nu_cd = 0.0
 SET amb_cd = 0.0
 SET cslogin_cd = 0.0
 SET srvarea_cd = 0.0
 SET bldg_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning IN ("NURSEUNIT", "AMBULATORY", "CSLOGIN", "SRVAREA", "BUILDING")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="NURSEUNIT")
    nu_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="AMBULATORY")
    amb_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="CSLOGIN")
    cslogin_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="SRVAREA")
    srvarea_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="BUILDING")
    bldg_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET plsize = size(request->paramlist,5)
 SET stat = alterlist(reply->res_collist,2)
 SET reply->res_collist[1].header_text = "Check Name"
 SET reply->res_collist[2].header_text = "Resolution"
 SET stat = alterlist(reply->res_rowlist,plsize)
 FOR (p = 1 TO plsize)
   SELECT INTO "nl:"
    FROM br_rec b,
     br_long_text bl2
    PLAN (b
     WHERE (b.rec_mean=request->paramlist[p].meaning))
     JOIN (bl2
     WHERE bl2.long_text_id=b.resolution_txt_id)
    DETAIL
     stat = alterlist(reply->res_rowlist[p].res_celllist,2), reply->res_rowlist[p].res_celllist[1].
     cell_text = b.short_desc, reply->res_rowlist[p].res_celllist[2].cell_text = bl2.long_text
    WITH nocounter
   ;end select
 ENDFOR
 SET check_miss_srvarea_ind = 0
 SET check_multi_srvarea_ind = 0
 SET miss_srvarea_col_nbr = 0
 SET multi_srvarea_col_nbr = 0
 SET col_cnt = (3+ plsize)
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Display Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Organization"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET next_col = 3
 FOR (p = 1 TO plsize)
  IF ((request->paramlist[p].meaning="SRVAREAVALMISSAREA"))
   SET check_miss_srvarea_ind = 1
   SET next_col = (next_col+ 1)
   SET miss_srvarea_col_nbr = next_col
   SET reply->collist[next_col].header_text = "Location Not in Service Area"
   SET reply->collist[next_col].data_type = 1
   SET reply->collist[next_col].hide_ind = 0
  ENDIF
  IF ((request->paramlist[p].meaning="SRVAREAVALMULTIAREA"))
   SET check_multi_srvarea_ind = 1
   SET next_col = (next_col+ 1)
   SET multi_srvarea_col_nbr = next_col
   SET reply->collist[next_col].header_text = "Location in Multiple PathNet Service Areas"
   SET reply->collist[next_col].data_type = 1
   SET reply->collist[next_col].hide_ind = 0
  ENDIF
 ENDFOR
 SET reply->run_status_flag = 1
 SET lcnt = 0
 FOR (p = 1 TO plsize)
  IF ((request->paramlist[p].meaning="SRVAREAVALMISSAREA"))
   SELECT INTO "nl:"
    FROM location l1,
     code_value cv,
     (dummyt d  WITH seq = 1),
     location_group lg,
     location l2
    PLAN (l1
     WHERE l1.location_type_cd IN (amb_cd, nu_cd, cslogin_cd)
      AND l1.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=l1.location_cd
      AND cv.active_ind=1)
     JOIN (d)
     JOIN (lg
     WHERE lg.child_loc_cd=l1.location_cd
      AND lg.location_group_type_cd=srvarea_cd
      AND lg.active_ind=1)
     JOIN (l2
     WHERE l2.location_cd=lg.parent_loc_cd
      AND l2.discipline_type_cd=lab_ct_cd
      AND l2.active_ind=1)
    DETAIL
     lcnt = (lcnt+ 1), stat = alterlist(temp->loclist,lcnt), temp->loclist[lcnt].loc_cd = l1
     .location_cd,
     temp->loclist[lcnt].loc_disp = cv.display, temp->loclist[lcnt].loc_desc = cv.description, temp->
     loclist[lcnt].loc_type = l1.location_type_cd,
     temp->loclist[lcnt].not_in_srvarea_ind = 1
    WITH nocounter, outerjoin = d, dontexist
   ;end select
  ENDIF
  IF ((request->paramlist[p].meaning="SRVAREAVALMULTIAREA"))
   SELECT INTO "nl:"
    FROM location l1,
     code_value cv,
     location_group lg1,
     location l2
    PLAN (l1
     WHERE l1.location_type_cd IN (amb_cd, nu_cd, cslogin_cd)
      AND l1.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=l1.location_cd
      AND cv.active_ind=1)
     JOIN (lg1
     WHERE lg1.child_loc_cd=l1.location_cd
      AND lg1.location_group_type_cd=srvarea_cd
      AND lg1.active_ind=1)
     JOIN (l2
     WHERE l2.location_cd=lg1.parent_loc_cd
      AND l2.discipline_type_cd=lab_ct_cd
      AND l2.active_ind=1)
    ORDER BY l1.location_cd
    HEAD l1.location_cd
     srvarea_cnt = 0
    DETAIL
     srvarea_cnt = (srvarea_cnt+ 1)
    FOOT  l1.location_cd
     IF (srvarea_cnt > 1)
      lcnt = (lcnt+ 1), stat = alterlist(temp->loclist,lcnt), temp->loclist[lcnt].loc_cd = l1
      .location_cd,
      temp->loclist[lcnt].loc_disp = cv.display, temp->loclist[lcnt].loc_desc = cv.description, temp
      ->loclist[lcnt].loc_type = l1.location_type_cd,
      temp->loclist[lcnt].multi_srvarea_ind = 1
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
 IF (lcnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = lcnt),
    location_group lg,
    location l,
    organization o
   PLAN (d
    WHERE (temp->loclist[d.seq].loc_type IN (amb_cd, nu_cd)))
    JOIN (lg
    WHERE (lg.child_loc_cd=temp->loclist[d.seq].loc_cd)
     AND lg.location_group_type_cd=bldg_cd
     AND lg.root_loc_cd=0)
    JOIN (l
    WHERE l.location_cd=lg.parent_loc_cd)
    JOIN (o
    WHERE o.organization_id=l.organization_id)
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
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = lcnt),
    location l,
    organization o
   PLAN (d
    WHERE (temp->loclist[d.seq].loc_type=cslogin_cd))
    JOIN (l
    WHERE (l.location_cd=temp->loclist[d.seq].loc_cd)
     AND l.active_ind=1)
    JOIN (o
    WHERE o.organization_id=l.organization_id)
   DETAIL
    temp->loclist[d.seq].org_name = o.org_name
   WITH counter
  ;end select
  IF (check_multi_srvarea_ind=1)
   SET max_srvareas = 0
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = lcnt),
     location_group lg1,
     location l2,
     code_value cv
    PLAN (d
     WHERE (temp->loclist[d.seq].multi_srvarea_ind=1))
     JOIN (lg1
     WHERE (lg1.child_loc_cd=temp->loclist[d.seq].loc_cd)
      AND lg1.location_group_type_cd=srvarea_cd
      AND lg1.active_ind=1)
     JOIN (l2
     WHERE l2.location_cd=lg1.parent_loc_cd
      AND l2.discipline_type_cd=lab_ct_cd
      AND l2.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=l2.location_cd
      AND cv.active_ind=1)
    HEAD d.seq
     srvarea_cnt = 0
    DETAIL
     srvarea_cnt = (srvarea_cnt+ 1), stat = alterlist(temp->loclist[d.seq].srvareas,srvarea_cnt),
     temp->loclist[d.seq].srvareas[srvarea_cnt].display = cv.display
    FOOT  d.seq
     temp->loclist[d.seq].nbr_srvareas = srvarea_cnt
     IF (srvarea_cnt > max_srvareas)
      max_srvareas = srvarea_cnt
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->collist,(col_cnt+ max_srvareas))
   FOR (x = 1 TO max_srvareas)
     SET col_cnt = (col_cnt+ 1)
     SET reply->collist[col_cnt].header_text = build2("Multiple Service Area ",cnvtstring(x))
     SET reply->collist[col_cnt].data_type = 1
     SET reply->collist[col_cnt].hide_ind = 0
   ENDFOR
  ENDIF
  SET rcnt = 0
  SELECT INTO "nl:"
   loc_disp = cnvtupper(temp->loclist[d.seq].loc_disp), loc_cd = temp->loclist[d.seq].loc_cd
   FROM (dummyt d  WITH seq = lcnt)
   ORDER BY loc_disp, loc_cd
   HEAD loc_cd
    rcnt = (rcnt+ 1), stat = alterlist(reply->rowlist,rcnt), stat = alterlist(reply->rowlist[rcnt].
     celllist,col_cnt),
    reply->rowlist[rcnt].celllist[1].string_value = temp->loclist[d.seq].loc_disp, reply->rowlist[
    rcnt].celllist[2].string_value = temp->loclist[d.seq].loc_desc, reply->rowlist[rcnt].celllist[3].
    string_value = temp->loclist[d.seq].org_name
    IF ((temp->loclist[d.seq].not_in_srvarea_ind=1)
     AND check_miss_srvarea_ind=1)
     reply->rowlist[rcnt].celllist[miss_srvarea_col_nbr].string_value = "X"
    ENDIF
    IF ((temp->loclist[d.seq].multi_srvarea_ind=1)
     AND check_multi_srvarea_ind=1)
     reply->rowlist[rcnt].celllist[multi_srvarea_col_nbr].string_value = "X", srvarea_cnt = size(temp
      ->loclist[d.seq].srvareas,5)
     FOR (s = 1 TO srvarea_cnt)
       IF (check_miss_srvarea_ind=1)
        reply->rowlist[rcnt].celllist[(5+ s)].string_value = temp->loclist[d.seq].srvareas[s].display
       ELSE
        reply->rowlist[rcnt].celllist[(4+ s)].string_value = temp->loclist[d.seq].srvareas[s].display
       ENDIF
     ENDFOR
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
END GO
