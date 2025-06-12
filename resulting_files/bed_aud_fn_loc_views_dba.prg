CREATE PROGRAM bed_aud_fn_loc_views:dba
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
   1 lvlist[*]
     2 loc_view_name = vc
     2 loc_view_cd = f8
     2 fcnt = i2
     2 flist[*]
       3 facility_name = vc
       3 facility_desc = vc
       3 f_location_cd = f8
       3 bcnt = i2
       3 blist[*]
         4 building_name = vc
         4 building_desc = vc
         4 b_location_cd = f8
         4 ucnt = i2
         4 ulist[*]
           5 unit_name = vc
           5 unit_desc = vc
           5 u_location_cd = f8
           5 u_type_cdf = vc
           5 rcnt = i2
           5 rlist[*]
             6 room_name = vc
             6 r_location_cd = f8
             6 updt_name = vc
             6 dcnt = i2
             6 dlist[*]
               7 bed_name = vc
               7 d_location_cd = f8
 )
 DECLARE facility = f8 WITH public, noconstant(0.0)
 SET fcnt = 0
 SET bcnt = 0
 SET ucnt = 0
 SET rcnt = 0
 SET dcnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=222
    AND cv.cdf_meaning="FACILITY"
    AND cv.active_ind=1)
  DETAIL
   facility = cv.code_value
  WITH nocounter
 ;end select
 SET request->skip_volume_check_ind = 1
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM location_group l
   PLAN (l
    WHERE l.root_loc_cd=0
     AND l.active_ind=1)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 20000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 10000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET f_cnt = 0
 SELECT INTO "nl:"
  FROM code_value cv1,
   location_group lg1,
   code_value cv2,
   location_group lg2,
   code_value cv3,
   location_group lg3,
   code_value cv4,
   location_group lg4,
   code_value cv5,
   person p,
   (dummyt d  WITH seq = 1),
   location_group lg5,
   code_value cv6
  PLAN (cv1
   WHERE cv1.code_set=220
    AND cv1.cdf_meaning="PTTRACKROOT"
    AND cv1.active_ind=1)
   JOIN (lg1
   WHERE lg1.parent_loc_cd=cv1.code_value
    AND lg1.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=lg1.child_loc_cd
    AND cv2.active_ind=1)
   JOIN (lg2
   WHERE lg2.parent_loc_cd=lg1.child_loc_cd
    AND lg2.root_loc_cd=cv1.code_value
    AND lg2.active_ind=1)
   JOIN (cv3
   WHERE cv3.code_value=lg2.child_loc_cd
    AND cv3.active_ind=1)
   JOIN (lg3
   WHERE lg3.parent_loc_cd=lg2.child_loc_cd
    AND lg3.root_loc_cd=cv1.code_value
    AND lg3.active_ind=1)
   JOIN (cv4
   WHERE cv4.code_value=lg3.child_loc_cd
    AND cv4.active_ind=1)
   JOIN (lg4
   WHERE lg4.parent_loc_cd=lg3.child_loc_cd
    AND lg4.root_loc_cd=cv1.code_value
    AND lg4.active_ind=1)
   JOIN (cv5
   WHERE cv5.code_value=lg4.child_loc_cd
    AND cv5.active_ind=1)
   JOIN (p
   WHERE p.person_id=outerjoin(lg4.updt_id))
   JOIN (d)
   JOIN (lg5
   WHERE lg5.parent_loc_cd=lg4.child_loc_cd
    AND lg5.root_loc_cd=cv1.code_value
    AND lg5.active_ind=1)
   JOIN (cv6
   WHERE cv6.code_value=lg5.child_loc_cd
    AND cv6.active_ind=1)
  ORDER BY cv1.display_key, lg1.sequence, lg2.sequence,
   lg3.sequence, lg4.sequence, lg5.sequence
  HEAD REPORT
   lvcnt = 0
  HEAD cv1.code_value
   lvcnt = (lvcnt+ 1), stat = alterlist(temp->lvlist,lvcnt), temp->lvlist[lvcnt].loc_view_name = cv1
   .display,
   temp->lvlist[lvcnt].loc_view_cd = cv1.code_value, fcnt = 0
  HEAD cv2.code_value
   fcnt = (fcnt+ 1), stat = alterlist(temp->lvlist[lvcnt].flist,fcnt), temp->lvlist[lvcnt].flist[fcnt
   ].facility_name = cv2.display,
   temp->lvlist[lvcnt].flist[fcnt].f_location_cd = cv2.code_value, bcnt = 0
  HEAD cv3.code_value
   bcnt = (bcnt+ 1), stat = alterlist(temp->lvlist[lvcnt].flist[fcnt].blist,bcnt), temp->lvlist[lvcnt
   ].flist[fcnt].blist[bcnt].building_name = cv3.display,
   temp->lvlist[lvcnt].flist[fcnt].blist[bcnt].b_location_cd = cv3.code_value, ucnt = 0
  HEAD cv4.code_value
   ucnt = (ucnt+ 1), stat = alterlist(temp->lvlist[lvcnt].flist[fcnt].blist[bcnt].ulist,ucnt), temp->
   lvlist[lvcnt].flist[fcnt].blist[bcnt].ulist[ucnt].unit_name = cv4.display,
   temp->lvlist[lvcnt].flist[fcnt].blist[bcnt].ulist[ucnt].u_location_cd = cv4.code_value, rcnt = 0
  HEAD cv5.code_value
   rcnt = (rcnt+ 1), stat = alterlist(temp->lvlist[lvcnt].flist[fcnt].blist[bcnt].ulist[ucnt].rlist,
    rcnt), temp->lvlist[lvcnt].flist[fcnt].blist[bcnt].ulist[ucnt].rlist[rcnt].room_name = cv5
   .display,
   temp->lvlist[lvcnt].flist[fcnt].blist[bcnt].ulist[ucnt].rlist[rcnt].r_location_cd = cv5.code_value,
   temp->lvlist[lvcnt].flist[fcnt].blist[bcnt].ulist[ucnt].rlist[rcnt].updt_name = p
   .name_full_formatted, dcnt = 0
  DETAIL
   IF (cv6.code_value > 0)
    dcnt = (dcnt+ 1), stat = alterlist(temp->lvlist[lvcnt].flist[fcnt].blist[bcnt].ulist[ucnt].rlist[
     rcnt].dlist,dcnt), temp->lvlist[lvcnt].flist[fcnt].blist[bcnt].ulist[ucnt].rlist[rcnt].dlist[
    dcnt].bed_name = cv6.display,
    temp->lvlist[lvcnt].flist[fcnt].blist[bcnt].ulist[ucnt].rlist[rcnt].dlist[dcnt].d_location_cd =
    cv6.code_value
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 SET stat = alterlist(reply->collist,13)
 SET reply->collist[1].header_text = "Patient Tracking View"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Facility Display"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Building"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Ambulatory Unit"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Room"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Bed"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Last Update By"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "track_view_cd"
 SET reply->collist[8].data_type = 2
 SET reply->collist[8].hide_ind = 1
 SET reply->collist[9].header_text = "facility_cd"
 SET reply->collist[9].data_type = 2
 SET reply->collist[9].hide_ind = 1
 SET reply->collist[10].header_text = "building_cd"
 SET reply->collist[10].data_type = 2
 SET reply->collist[10].hide_ind = 1
 SET reply->collist[11].header_text = "unit_cd"
 SET reply->collist[11].data_type = 2
 SET reply->collist[11].hide_ind = 1
 SET reply->collist[12].header_text = "room_cd"
 SET reply->collist[12].data_type = 2
 SET reply->collist[12].hide_ind = 1
 SET reply->collist[13].header_text = "bed_cd"
 SET reply->collist[13].data_type = 2
 SET reply->collist[13].hide_ind = 1
 SET row_nbr = 0
 SET first_bed = 1
 SET first_room = 1
 SET first_unit = 1
 SET first_bldg = 1
 SET first_fac = 1
 SET first_lv = 1
 SET lvcnt = size(temp->lvlist,5)
 FOR (x = 1 TO lvcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,13)
   SET first_fac = 1
   SET first_bldg = 1
   SET first_unit = 1
   SET first_room = 1
   SET first_bed = 1
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->lvlist[x].loc_view_name
   SET reply->rowlist[row_nbr].celllist[8].double_value = temp->lvlist[x].loc_view_cd
   SET fcnt = size(temp->lvlist[x].flist,5)
   FOR (y = 1 TO fcnt)
     IF (first_fac=0)
      SET row_nbr = (row_nbr+ 1)
      SET stat = alterlist(reply->rowlist,row_nbr)
      SET stat = alterlist(reply->rowlist[row_nbr].celllist,13)
     ELSE
      SET first_fac = 0
     ENDIF
     SET first_bldg = 1
     SET first_unit = 1
     SET first_room = 1
     SET first_bed = 1
     SET reply->rowlist[row_nbr].celllist[2].string_value = temp->lvlist[x].flist[y].facility_name
     SET reply->rowlist[row_nbr].celllist[9].double_value = temp->lvlist[x].flist[y].f_location_cd
     SET reply->rowlist[row_nbr].celllist[8].double_value = temp->lvlist[x].loc_view_cd
     SET bcnt = size(temp->lvlist[x].flist[y].blist,5)
     FOR (z = 1 TO bcnt)
       IF (first_bldg=0)
        SET row_nbr = (row_nbr+ 1)
        SET stat = alterlist(reply->rowlist,row_nbr)
        SET stat = alterlist(reply->rowlist[row_nbr].celllist,13)
       ELSE
        SET first_bldg = 0
       ENDIF
       SET first_unit = 1
       SET first_room = 1
       SET first_bed = 1
       SET reply->rowlist[row_nbr].celllist[3].string_value = temp->lvlist[x].flist[y].blist[z].
       building_name
       SET reply->rowlist[row_nbr].celllist[10].double_value = temp->lvlist[x].flist[y].blist[z].
       b_location_cd
       SET reply->rowlist[row_nbr].celllist[9].double_value = temp->lvlist[x].flist[y].f_location_cd
       SET reply->rowlist[row_nbr].celllist[8].double_value = temp->lvlist[x].loc_view_cd
       SET ucnt = size(temp->lvlist[x].flist[y].blist[z].ulist,5)
       FOR (w = 1 TO ucnt)
         IF (first_unit=0)
          SET row_nbr = (row_nbr+ 1)
          SET stat = alterlist(reply->rowlist,row_nbr)
          SET stat = alterlist(reply->rowlist[row_nbr].celllist,13)
         ELSE
          SET first_unit = 0
         ENDIF
         SET first_room = 1
         SET first_bed = 1
         SET reply->rowlist[row_nbr].celllist[4].string_value = temp->lvlist[x].flist[y].blist[z].
         ulist[w].unit_name
         SET reply->rowlist[row_nbr].celllist[11].double_value = temp->lvlist[x].flist[y].blist[z].
         ulist[w].u_location_cd
         SET reply->rowlist[row_nbr].celllist[10].double_value = temp->lvlist[x].flist[y].blist[z].
         b_location_cd
         SET reply->rowlist[row_nbr].celllist[9].double_value = temp->lvlist[x].flist[y].
         f_location_cd
         SET reply->rowlist[row_nbr].celllist[8].double_value = temp->lvlist[x].loc_view_cd
         SET rcnt = size(temp->lvlist[x].flist[y].blist[z].ulist[w].rlist,5)
         FOR (u = 1 TO rcnt)
           IF (first_room=0)
            SET row_nbr = (row_nbr+ 1)
            SET stat = alterlist(reply->rowlist,row_nbr)
            SET stat = alterlist(reply->rowlist[row_nbr].celllist,13)
           ELSE
            SET first_room = 0
           ENDIF
           SET first_bed = 1
           SET reply->rowlist[row_nbr].celllist[5].string_value = temp->lvlist[x].flist[y].blist[z].
           ulist[w].rlist[u].room_name
           SET reply->rowlist[row_nbr].celllist[7].string_value = temp->lvlist[x].flist[y].blist[z].
           ulist[w].rlist[u].updt_name
           SET reply->rowlist[row_nbr].celllist[12].double_value = temp->lvlist[x].flist[y].blist[z].
           ulist[w].rlist[u].r_location_cd
           SET reply->rowlist[row_nbr].celllist[11].double_value = temp->lvlist[x].flist[y].blist[z].
           ulist[w].u_location_cd
           SET reply->rowlist[row_nbr].celllist[10].double_value = temp->lvlist[x].flist[y].blist[z].
           b_location_cd
           SET reply->rowlist[row_nbr].celllist[9].double_value = temp->lvlist[x].flist[y].
           f_location_cd
           SET reply->rowlist[row_nbr].celllist[8].double_value = temp->lvlist[x].loc_view_cd
           SET dcnt = size(temp->lvlist[x].flist[y].blist[z].ulist[w].rlist[u].dlist,5)
           FOR (v = 1 TO dcnt)
             IF (first_bed=0)
              SET row_nbr = (row_nbr+ 1)
              SET stat = alterlist(reply->rowlist,row_nbr)
              SET stat = alterlist(reply->rowlist[row_nbr].celllist,13)
             ELSE
              SET first_bed = 0
             ENDIF
             SET reply->rowlist[row_nbr].celllist[6].string_value = temp->lvlist[x].flist[y].blist[z]
             .ulist[w].rlist[u].dlist[v].bed_name
             SET reply->rowlist[row_nbr].celllist[13].double_value = temp->lvlist[x].flist[y].blist[z
             ].ulist[w].rlist[u].dlist[v].d_location_cd
             SET reply->rowlist[row_nbr].celllist[12].double_value = temp->lvlist[x].flist[y].blist[z
             ].ulist[w].rlist[u].r_location_cd
             SET reply->rowlist[row_nbr].celllist[11].double_value = temp->lvlist[x].flist[y].blist[z
             ].ulist[w].u_location_cd
             SET reply->rowlist[row_nbr].celllist[10].double_value = temp->lvlist[x].flist[y].blist[z
             ].b_location_cd
             SET reply->rowlist[row_nbr].celllist[9].double_value = temp->lvlist[x].flist[y].
             f_location_cd
             SET reply->rowlist[row_nbr].celllist[8].double_value = temp->lvlist[x].loc_view_cd
           ENDFOR
         ENDFOR
       ENDFOR
     ENDFOR
   ENDFOR
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("firstnet_loc_view_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
