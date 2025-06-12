CREATE PROGRAM bed_aud_loc_hierarchy:dba
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
   1 client = vc
   1 user = vc
   1 fcnt = i2
   1 flist[*]
     2 facility_name = vc
     2 facility_desc = vc
     2 f_location_cd = f8
     2 bcnt = i2
     2 blist[*]
       3 building_name = vc
       3 building_desc = vc
       3 b_location_cd = f8
       3 ucnt = i2
       3 ulist[*]
         4 unit_name = vc
         4 unit_desc = vc
         4 u_location_cd = f8
         4 u_type_cdf = vc
         4 rcnt = i2
         4 rlist[*]
           5 room_name = vc
           5 r_location_cd = f8
           5 dcnt = i2
           5 dlist[*]
             6 bed_name = vc
             6 d_location_cd = f8
 )
 DECLARE facility = f8 WITH public, noconstant(0.0)
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
 SELECT INTO "nl:"
  FROM br_prsnl bp
  PLAN (bp
   WHERE (bp.br_prsnl_id=reqinfo->updt_id))
  DETAIL
   temp->user = bp.name_full_formatted
  WITH nocounter
 ;end select
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
  FROM location l,
   organization o,
   code_value cv
  PLAN (l
   WHERE l.location_type_cd=facility
    AND l.active_ind=1)
   JOIN (o
   WHERE o.organization_id=l.organization_id
    AND o.active_ind=1
    AND o.org_name > "")
   JOIN (cv
   WHERE cv.code_value=l.location_cd)
  ORDER BY o.org_name_key
  HEAD REPORT
   f_cnt = 0
  HEAD l.location_cd
   f_cnt = (f_cnt+ 1), stat = alterlist(temp->flist,f_cnt), temp->flist[f_cnt].facility_name = cv
   .display,
   temp->flist[f_cnt].facility_desc = cv.description, temp->flist[f_cnt].f_location_cd = l
   .location_cd
  WITH nocounter
 ;end select
 SET temp->fcnt = f_cnt
 CALL echo(build("1st temp fac:",temp->flist[1].facility_name))
 CALL echo(build("1st temp fac cd:",temp->flist[1].f_location_cd))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(f_cnt)),
   location_group lg,
   location l,
   code_value cv,
   code_value lt
  PLAN (d)
   JOIN (lg
   WHERE (lg.parent_loc_cd=temp->flist[d.seq].f_location_cd)
    AND lg.active_ind=1
    AND lg.root_loc_cd=0)
   JOIN (l
   WHERE l.location_cd=lg.child_loc_cd
    AND l.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=l.location_cd)
   JOIN (lt
   WHERE lt.code_value=l.location_type_cd)
  ORDER BY d.seq, lg.sequence
  HEAD lg.parent_loc_cd
   b_cnt = 0
  HEAD l.location_cd
   b_cnt = (b_cnt+ 1), temp->flist[d.seq].bcnt = b_cnt, stat = alterlist(temp->flist[d.seq].blist,
    b_cnt),
   temp->flist[d.seq].blist[b_cnt].b_location_cd = l.location_cd, temp->flist[d.seq].blist[b_cnt].
   building_name = cv.display, temp->flist[d.seq].blist[b_cnt].building_desc = cv.description
   IF (lt.cdf_meaning != "BUILDING")
    temp->flist[d.seq].blist[b_cnt].building_name = concat(temp->flist[d.seq].blist[b_cnt].
     building_name," (",trim(lt.cdf_meaning),")")
   ENDIF
  WITH nocounter
 ;end select
 FOR (x = 1 TO size(temp->flist,5))
   FOR (y = 1 TO size(temp->flist[x].blist,5))
     SET u_cnt = 0
     SELECT INTO "nl:"
      FROM location_group lg,
       location l,
       code_value cv,
       code_value lt
      PLAN (lg
       WHERE (lg.parent_loc_cd=temp->flist[x].blist[y].b_location_cd)
        AND lg.active_ind=1
        AND lg.root_loc_cd=0)
       JOIN (l
       WHERE l.location_cd=lg.child_loc_cd
        AND l.active_ind=1)
       JOIN (cv
       WHERE cv.code_value=l.location_cd)
       JOIN (lt
       WHERE lt.code_value=l.location_type_cd)
      ORDER BY lg.sequence
      HEAD REPORT
       u_cnt = 0
      HEAD l.location_cd
       IF (((lt.cdf_meaning="NURSEUNIT") OR (lt.cdf_meaning="AMBULATORY")) )
        u_cnt = (u_cnt+ 1), stat = alterlist(temp->flist[x].blist[y].ulist,u_cnt), temp->flist[x].
        blist[y].ulist[u_cnt].u_location_cd = l.location_cd,
        temp->flist[x].blist[y].ulist[u_cnt].u_type_cdf = lt.cdf_meaning, temp->flist[x].blist[y].
        ulist[u_cnt].unit_name = cv.display, temp->flist[x].blist[y].ulist[u_cnt].unit_desc = cv
        .description
       ELSE
        IF (lt.cdf_meaning != "ANCILSURG"
         AND lt.cdf_meaning != "APPTLOC"
         AND lt.cdf_meaning != "RAD"
         AND lt.cdf_meaning != "LAB"
         AND lt.cdf_meaning != "PHARM")
         u_cnt = (u_cnt+ 1), stat = alterlist(temp->flist[x].blist[y].ulist,u_cnt), temp->flist[x].
         blist[y].ulist[u_cnt].u_location_cd = l.location_cd,
         temp->flist[x].blist[y].ulist[u_cnt].u_type_cdf = lt.cdf_meaning, temp->flist[x].blist[y].
         ulist[u_cnt].unit_name = cv.display, temp->flist[x].blist[y].ulist[u_cnt].unit_desc = cv
         .description,
         temp->flist[x].blist[y].ulist[u_cnt].unit_name = concat(temp->flist[x].blist[y].ulist[u_cnt]
          .unit_name," (",trim(lt.cdf_meaning),")")
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     SET temp->flist[x].blist[y].ucnt = u_cnt
     FOR (z = 1 TO u_cnt)
       SET r_cnt = 0
       SELECT INTO "nl:"
        FROM location_group lg,
         location l,
         code_value cv,
         code_value lt
        PLAN (lg
         WHERE (lg.parent_loc_cd=temp->flist[x].blist[y].ulist[z].u_location_cd)
          AND lg.active_ind=1
          AND lg.root_loc_cd=0)
         JOIN (l
         WHERE l.location_cd=lg.child_loc_cd
          AND l.active_ind=1)
         JOIN (cv
         WHERE cv.code_value=l.location_cd)
         JOIN (lt
         WHERE lt.code_value=l.location_type_cd)
        ORDER BY lg.sequence
        HEAD REPORT
         r_cnt = 0
        HEAD l.location_cd
         IF (((lt.cdf_meaning="ROOM"
          AND (temp->flist[x].blist[y].ulist[z].u_type_cdf="NURSEUNIT")) OR (((lt.cdf_meaning="ROOM")
          OR (((lt.cdf_meaning="CHECKOUT") OR (((lt.cdf_meaning="TRANSPORT") OR (lt.cdf_meaning=
         "WAITROOM"
          AND (temp->flist[x].blist[y].ulist[z].u_type_cdf="AMBULATORY"))) )) )) )) )
          r_cnt = (r_cnt+ 1), stat = alterlist(temp->flist[x].blist[y].ulist[z].rlist,r_cnt), temp->
          flist[x].blist[y].ulist[z].rlist[r_cnt].r_location_cd = l.location_cd,
          temp->flist[x].blist[y].ulist[z].rlist[r_cnt].room_name = cv.description
         ELSE
          IF (lt.cdf_meaning != "INVLOC")
           r_cnt = (r_cnt+ 1), stat = alterlist(temp->flist[x].blist[y].ulist[z].rlist,r_cnt), temp->
           flist[x].blist[y].ulist[z].rlist[r_cnt].r_location_cd = l.location_cd,
           temp->flist[x].blist[y].ulist[z].rlist[r_cnt].room_name = cv.description, temp->flist[x].
           blist[y].ulist[z].rlist[r_cnt].room_name = concat(temp->flist[x].blist[y].ulist[z].rlist[
            r_cnt].room_name," (",trim(lt.cdf_meaning),")")
          ENDIF
         ENDIF
        WITH nocounter
       ;end select
       SET temp->flist[x].blist[y].ulist[z].rcnt = r_cnt
       FOR (i = 1 TO r_cnt)
         SET d_cnt = 0
         SELECT INTO "nl:"
          FROM location_group lg,
           location l,
           code_value cv,
           code_value lt
          PLAN (lg
           WHERE (lg.parent_loc_cd=temp->flist[x].blist[y].ulist[z].rlist[i].r_location_cd)
            AND lg.active_ind=1
            AND lg.root_loc_cd=0)
           JOIN (l
           WHERE l.location_cd=lg.child_loc_cd
            AND l.active_ind=1)
           JOIN (cv
           WHERE cv.code_value=l.location_cd)
           JOIN (lt
           WHERE lt.code_value=l.location_type_cd)
          ORDER BY lg.sequence
          HEAD REPORT
           d_cnt = 0
          HEAD l.location_cd
           d_cnt = (d_cnt+ 1), stat = alterlist(temp->flist[x].blist[y].ulist[z].rlist[i].dlist,d_cnt
            ), temp->flist[x].blist[y].ulist[z].rlist[i].dlist[d_cnt].d_location_cd = l.location_cd,
           temp->flist[x].blist[y].ulist[z].rlist[i].dlist[d_cnt].bed_name = cv.description
           IF (lt.cdf_meaning != "BED")
            temp->flist[x].blist[y].ulist[z].rlist[i].dlist[d_cnt].bed_name = concat(trim(cv
              .description)," (",trim(lt.cdf_meaning),")")
           ENDIF
          WITH nocounter
         ;end select
         SET temp->flist[x].blist[y].ulist[z].rlist[i].dcnt = d_cnt
       ENDFOR
     ENDFOR
   ENDFOR
 ENDFOR
 SET stat = alterlist(reply->collist,13)
 SET reply->collist[1].header_text = "Facility Display"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Facility Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Building Display"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Building Description"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Unit Display"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Unit Description"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Room"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Bed"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
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
 CALL echo(build("fcnt:",temp->fcnt))
 FOR (x = 1 TO temp->fcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,13)
   SET first_fac = 0
   SET first_bldg = 1
   SET first_unit = 1
   SET first_room = 1
   SET first_bed = 1
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->flist[x].facility_name
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->flist[x].facility_desc
   SET reply->rowlist[row_nbr].celllist[9].double_value = temp->flist[x].f_location_cd
   FOR (y = 1 TO temp->flist[x].bcnt)
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
     SET reply->rowlist[row_nbr].celllist[3].string_value = temp->flist[x].blist[y].building_name
     SET reply->rowlist[row_nbr].celllist[4].string_value = temp->flist[x].blist[y].building_desc
     SET reply->rowlist[row_nbr].celllist[10].double_value = temp->flist[x].blist[y].b_location_cd
     SET reply->rowlist[row_nbr].celllist[9].double_value = temp->flist[x].f_location_cd
     FOR (z = 1 TO temp->flist[x].blist[y].ucnt)
       IF (first_unit=0)
        SET row_nbr = (row_nbr+ 1)
        SET stat = alterlist(reply->rowlist,row_nbr)
        SET stat = alterlist(reply->rowlist[row_nbr].celllist,13)
       ELSE
        SET first_unit = 0
       ENDIF
       SET first_room = 1
       SET first_bed = 1
       SET reply->rowlist[row_nbr].celllist[5].string_value = temp->flist[x].blist[y].ulist[z].
       unit_name
       SET reply->rowlist[row_nbr].celllist[6].string_value = temp->flist[x].blist[y].ulist[z].
       unit_desc
       SET reply->rowlist[row_nbr].celllist[11].double_value = temp->flist[x].blist[y].ulist[z].
       u_location_cd
       SET reply->rowlist[row_nbr].celllist[10].double_value = temp->flist[x].blist[y].b_location_cd
       SET reply->rowlist[row_nbr].celllist[9].double_value = temp->flist[x].f_location_cd
       FOR (w = 1 TO temp->flist[x].blist[y].ulist[z].rcnt)
         IF (first_room=0)
          SET row_nbr = (row_nbr+ 1)
          SET stat = alterlist(reply->rowlist,row_nbr)
          SET stat = alterlist(reply->rowlist[row_nbr].celllist,13)
         ELSE
          SET first_room = 0
         ENDIF
         SET first_bed = 1
         SET reply->rowlist[row_nbr].celllist[7].string_value = temp->flist[x].blist[y].ulist[z].
         rlist[w].room_name
         SET reply->rowlist[row_nbr].celllist[12].double_value = temp->flist[x].blist[y].ulist[z].
         rlist[w].r_location_cd
         SET reply->rowlist[row_nbr].celllist[11].double_value = temp->flist[x].blist[y].ulist[z].
         u_location_cd
         SET reply->rowlist[row_nbr].celllist[10].double_value = temp->flist[x].blist[y].
         b_location_cd
         SET reply->rowlist[row_nbr].celllist[9].double_value = temp->flist[x].f_location_cd
         FOR (u = 1 TO temp->flist[x].blist[y].ulist[z].rlist[w].dcnt)
           IF (first_bed=0)
            SET row_nbr = (row_nbr+ 1)
            SET stat = alterlist(reply->rowlist,row_nbr)
            SET stat = alterlist(reply->rowlist[row_nbr].celllist,13)
           ELSE
            SET first_bed = 0
           ENDIF
           SET reply->rowlist[row_nbr].celllist[8].string_value = temp->flist[x].blist[y].ulist[z].
           rlist[w].dlist[u].bed_name
           SET reply->rowlist[row_nbr].celllist[13].double_value = temp->flist[x].blist[y].ulist[z].
           rlist[w].dlist[u].d_location_cd
           SET reply->rowlist[row_nbr].celllist[12].double_value = temp->flist[x].blist[y].ulist[z].
           rlist[w].r_location_cd
           SET reply->rowlist[row_nbr].celllist[11].double_value = temp->flist[x].blist[y].ulist[z].
           u_location_cd
           SET reply->rowlist[row_nbr].celllist[10].double_value = temp->flist[x].blist[y].
           b_location_cd
           SET reply->rowlist[row_nbr].celllist[9].double_value = temp->flist[x].f_location_cd
         ENDFOR
       ENDFOR
     ENDFOR
   ENDFOR
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("location_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
