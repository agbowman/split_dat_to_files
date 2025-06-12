CREATE PROGRAM bed_aud_sch_apt_type_set
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
   1 appts[*]
     2 name = vc
     2 cd = f8
     2 accept_format = vc
     2 locs[*]
       3 name = vc
       3 cd = f8
       3 guides[*]
         4 action = vc
         4 name = vc
         4 flex = vc
       3 preps[*]
         4 name = vc
         4 flex = vc
       3 posts[*]
         4 name = vc
       3 requests[*]
         4 action = vc
         4 request_list = vc
 )
 SET cnt = 0
 SELECT INTO "nl:"
  FROM sch_appt_type sat,
   order_entry_format_parent oef,
   sch_appt_loc sal,
   code_value cv
  PLAN (sat
   WHERE sat.active_ind=1)
   JOIN (oef
   WHERE oef.oe_format_id=outerjoin(sat.oe_format_id))
   JOIN (sal
   WHERE sal.appt_type_cd=sat.appt_type_cd
    AND sal.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=sal.location_cd
    AND cv.active_ind=1)
  ORDER BY sat.description, cv.description
  HEAD sat.description
   lcnt = 0, cnt = (cnt+ 1), stat = alterlist(temp->appts,cnt),
   temp->appts[cnt].name = sat.description, temp->appts[cnt].cd = sat.appt_type_cd, temp->appts[cnt].
   accept_format = oef.oe_format_name
  HEAD sal.location_cd
   lcnt = (lcnt+ 1), stat = alterlist(temp->appts[cnt].locs,lcnt), temp->appts[cnt].locs[lcnt].name
    = cv.description,
   temp->appts[cnt].locs[lcnt].cd = sal.location_cd
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
   IF (size(temp->appts[x].locs,5) > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(temp->appts[x].locs,5))),
      sch_text_link stl,
      sch_sub_list ssl,
      sch_template st,
      sch_flex_string sfs,
      code_value cv
     PLAN (d)
      JOIN (stl
      WHERE (stl.parent_id=temp->appts[x].cd)
       AND (stl.parent2_id=temp->appts[x].locs[d.seq].cd)
       AND stl.text_type_meaning IN ("GUIDELINE", "PREAPPT", "POSTAPPT")
       AND stl.active_ind=1)
      JOIN (ssl
      WHERE ssl.parent_table="SCH_TEXT_LINK"
       AND ssl.parent_id=stl.text_link_id
       AND ssl.active_ind=1)
      JOIN (st
      WHERE st.template_id=ssl.template_id)
      JOIN (sfs
      WHERE sfs.sch_flex_id=ssl.sch_flex_id)
      JOIN (cv
      WHERE cv.code_value=outerjoin(stl.parent3_id)
       AND cv.active_ind=outerjoin(1))
     ORDER BY d.seq, stl.text_type_cd, cv.display_key
     HEAD d.seq
      gcnt = 0, ecnt = 0, tcnt = 0
     DETAIL
      IF (stl.text_type_meaning="GUIDELINE")
       gcnt = (gcnt+ 1), stat = alterlist(temp->appts[x].locs[d.seq].guides,gcnt), temp->appts[x].
       locs[d.seq].guides[gcnt].name = st.mnemonic,
       temp->appts[x].locs[d.seq].guides[gcnt].flex = sfs.mnemonic
       IF (stl.parent3_table="CODE_VALUE")
        temp->appts[x].locs[d.seq].guides[gcnt].action = cv.display
       ENDIF
      ENDIF
      IF (stl.text_type_meaning="PREAPPT")
       ecnt = (ecnt+ 1), stat = alterlist(temp->appts[x].locs[d.seq].preps,ecnt), temp->appts[x].
       locs[d.seq].preps[ecnt].name = st.mnemonic,
       temp->appts[x].locs[d.seq].preps[ecnt].flex = sfs.mnemonic
      ENDIF
      IF (stl.text_type_meaning="POSTAPPT")
       tcnt = (tcnt+ 1), stat = alterlist(temp->appts[x].locs[d.seq].posts,tcnt), temp->appts[x].
       locs[d.seq].posts[tcnt].name = st.mnemonic
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(temp->appts[x].locs,5))),
      sch_appt_routing sar,
      sch_object so,
      code_value cv
     PLAN (d)
      JOIN (sar
      WHERE (sar.appt_type_cd=temp->appts[x].cd)
       AND (sar.location_cd=temp->appts[x].locs[d.seq].cd)
       AND sar.active_ind=1)
      JOIN (so
      WHERE so.sch_object_id=sar.routing_id)
      JOIN (cv
      WHERE cv.code_value=sar.sch_action_cd
       AND cv.active_ind=1)
     ORDER BY d.seq, cv.display_key, sar.seq_nbr
     HEAD d.seq
      j = 0
     DETAIL
      j = (j+ 1), stat = alterlist(temp->appts[x].locs[d.seq].requests,j), temp->appts[x].locs[d.seq]
      .requests[j].request_list = so.mnemonic,
      temp->appts[x].locs[d.seq].requests[j].action = cv.display
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->collist,11)
 SET reply->collist[1].header_text = "Appointment Type Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Accept Format Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Ambulatory Location"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Guideline Activity"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Guideline Name"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Appointment Type - Guideline Flexing"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Person Preps"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Person Preps Flexing"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Person Posts"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Request List Activity"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Request List Queue"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET row_nbr = 0
 SET save_row = 0
 SET max_row = 0
 SET gcnt = 0
 SET ecnt = 0
 SET tcnt = 0
 FOR (x = 1 TO cnt)
   FOR (y = 1 TO size(temp->appts[x].locs,5))
     IF (max_row IN (0, 1))
      SET row_nbr = (row_nbr+ 1)
     ELSE
      SET row_nbr = (max_row+ 1)
     ENDIF
     SET stat = alterlist(reply->rowlist,row_nbr)
     SET stat = alterlist(reply->rowlist[row_nbr].celllist,11)
     SET gcnt = size(temp->appts[x].locs[y].guides,5)
     SET ecnt = size(temp->appts[x].locs[y].preps,5)
     SET tcnt = size(temp->appts[x].locs[y].posts,5)
     SET rcnt = size(temp->appts[x].locs[y].requests,5)
     SET reply->rowlist[row_nbr].celllist[1].string_value = temp->appts[x].name
     SET reply->rowlist[row_nbr].celllist[2].string_value = temp->appts[x].accept_format
     SET reply->rowlist[row_nbr].celllist[3].string_value = temp->appts[x].locs[y].name
     SET save_row = row_nbr
     SET max_row = maxval(gcnt,ecnt,tcnt,rcnt)
     IF (max_row > 1)
      SET max_row = ((row_nbr+ max_row) - 1)
      SET stat = alterlist(reply->rowlist,max_row)
      FOR (j = row_nbr TO max_row)
        SET stat = alterlist(reply->rowlist[j].celllist,11)
      ENDFOR
     ENDIF
     FOR (z = 1 TO gcnt)
       IF (z=1)
        SET reply->rowlist[row_nbr].celllist[5].string_value = temp->appts[x].locs[y].guides[z].name
        SET reply->rowlist[row_nbr].celllist[6].string_value = temp->appts[x].locs[y].guides[z].flex
        SET reply->rowlist[row_nbr].celllist[4].string_value = temp->appts[x].locs[y].guides[z].
        action
       ELSE
        SET reply->rowlist[((save_row+ z) - 1)].celllist[5].string_value = temp->appts[x].locs[y].
        guides[z].name
        SET reply->rowlist[((save_row+ z) - 1)].celllist[6].string_value = temp->appts[x].locs[y].
        guides[z].flex
        SET reply->rowlist[((save_row+ z) - 1)].celllist[4].string_value = temp->appts[x].locs[y].
        guides[z].action
       ENDIF
     ENDFOR
     FOR (z = 1 TO ecnt)
       IF (z=1)
        SET reply->rowlist[row_nbr].celllist[7].string_value = temp->appts[x].locs[y].preps[z].name
        SET reply->rowlist[row_nbr].celllist[8].string_value = temp->appts[x].locs[y].preps[z].flex
       ELSE
        SET reply->rowlist[((save_row+ z) - 1)].celllist[7].string_value = temp->appts[x].locs[y].
        preps[z].name
        SET reply->rowlist[((save_row+ z) - 1)].celllist[8].string_value = temp->appts[x].locs[y].
        preps[z].flex
       ENDIF
     ENDFOR
     FOR (z = 1 TO tcnt)
       IF (z=1)
        SET reply->rowlist[row_nbr].celllist[9].string_value = temp->appts[x].locs[y].posts[z].name
       ELSE
        SET reply->rowlist[((save_row+ z) - 1)].celllist[9].string_value = temp->appts[x].locs[y].
        posts[z].name
       ENDIF
     ENDFOR
     FOR (z = 1 TO rcnt)
       IF (z=1)
        SET reply->rowlist[row_nbr].celllist[10].string_value = temp->appts[x].locs[y].requests[z].
        action
        SET reply->rowlist[row_nbr].celllist[11].string_value = temp->appts[x].locs[y].requests[z].
        request_list
       ELSE
        SET reply->rowlist[((save_row+ z) - 1)].celllist[10].string_value = temp->appts[x].locs[y].
        requests[z].action
        SET reply->rowlist[((save_row+ z) - 1)].celllist[11].string_value = temp->appts[x].locs[y].
        requests[z].request_list
       ENDIF
     ENDFOR
   ENDFOR
   SET high_volume_cnt = 0
   IF ((request->skip_volume_check_ind=0))
    IF (row_nbr > 5000)
     SET reply->high_volume_flag = 2
     GO TO exit_script
    ELSEIF (row_nbr > 1000)
     SET reply->high_volume_flag = 1
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("appt_type_settings.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
