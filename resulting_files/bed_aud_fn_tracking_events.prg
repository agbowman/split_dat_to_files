CREATE PROGRAM bed_aud_fn_tracking_events
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
 DECLARE color(color_string=vc) = vc WITH protect
 DECLARE time_disp(time_sec=i2) = vc WITH protect
 DECLARE icon(icon_val=i4) = vc WITH protect
 SET stat = alterlist(reply->collist,23)
 SET reply->collist[1].header_text = "Tracking Group"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Event Name Display"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Events Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Normal Icon ID"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Normal Color"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Automated"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Required for Coding"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Auto Start"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Auto Complete"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Complete on Exit"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Critical"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Critical Icon ID"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Critical Color"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "Critical Limit"
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = "Overdue"
 SET reply->collist[15].data_type = 1
 SET reply->collist[15].hide_ind = 0
 SET reply->collist[16].header_text = "Overdue Icon ID"
 SET reply->collist[16].data_type = 1
 SET reply->collist[16].hide_ind = 0
 SET reply->collist[17].header_text = "Overdue Color"
 SET reply->collist[17].data_type = 1
 SET reply->collist[17].hide_ind = 0
 SET reply->collist[18].header_text = "Overdue Limit"
 SET reply->collist[18].data_type = 1
 SET reply->collist[18].hide_ind = 0
 SET reply->collist[19].header_text = "Set Location when Event Started"
 SET reply->collist[19].data_type = 1
 SET reply->collist[19].hide_ind = 0
 SET reply->collist[20].header_text = "Set Location when Event Requested"
 SET reply->collist[20].data_type = 1
 SET reply->collist[20].hide_ind = 0
 SET reply->collist[21].header_text = "Event Meaning"
 SET reply->collist[21].data_type = 1
 SET reply->collist[21].hide_ind = 0
 SET reply->collist[22].header_text = "Default Next Event"
 SET reply->collist[22].data_type = 1
 SET reply->collist[22].hide_ind = 0
 SET reply->collist[23].header_text = "Last Update By"
 SET reply->collist[23].data_type = 1
 SET reply->collist[23].hide_ind = 0
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM code_value cv,
    track_event te
   PLAN (cv
    WHERE cv.code_set=16370
     AND cv.active_ind=1
     AND cv.cdf_meaning="ER")
    JOIN (te
    WHERE te.tracking_group_cd=cv.code_value
     AND te.active_ind=1)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 1500)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 1000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ELSEIF (high_volume_cnt=0)
   GO TO exit_script
  ENDIF
 ENDIF
 DECLARE display = vc
 SELECT DISTINCT INTO "nl:"
  FROM code_value cv,
   track_event te,
   code_value cv2,
   code_value cv3,
   dummyt d,
   track_collection_element tce,
   track_collection tc,
   code_value cv4,
   prsnl p
  PLAN (cv
   WHERE cv.code_set=16370
    AND cv.active_ind=1
    AND cv.cdf_meaning="ER")
   JOIN (te
   WHERE te.tracking_group_cd=cv.code_value
    AND te.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=te.tracking_event_type_cd)
   JOIN (cv3
   WHERE cv3.code_value=te.event_use_mean_cd)
   JOIN (p
   WHERE p.person_id=outerjoin(te.updt_id))
   JOIN (d)
   JOIN (tce
   WHERE tce.element_table="TRACK_EVENT"
    AND tce.element_value=te.track_event_id)
   JOIN (tc
   WHERE tc.track_collection_id=tce.track_collection_id)
   JOIN (cv4
   WHERE cv4.code_value=tc.collection_type_cd
    AND cv4.cdf_meaning="CODING_REQ")
  ORDER BY cv.display, te.display
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->rowlist,25)
  HEAD te.description
   cnt = (cnt+ 1)
   IF (mod(cnt,25)=0)
    stat = alterlist(reply->rowlist,(25+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,23), reply->rowlist[cnt].celllist[1].string_value =
   cv.display, reply->rowlist[cnt].celllist[2].string_value = te.display,
   reply->rowlist[cnt].celllist[2].double_value = te.tracking_group_cd
   IF (cv2.display="")
    reply->rowlist[cnt].celllist[3].string_value = "<None>"
   ELSE
    reply->rowlist[cnt].celllist[3].string_value = cv2.display
   ENDIF
   reply->rowlist[cnt].celllist[4].string_value = icon(te.normal_icon), reply->rowlist[cnt].celllist[
   5].string_value = color(te.normal_color)
   CASE (te.hide_event_ind)
    OF 0:
     reply->rowlist[cnt].celllist[6].string_value = ""
    OF 1:
     reply->rowlist[cnt].celllist[6].string_value = "X"
   ENDCASE
   IF (cv4.code_value > 0)
    reply->rowlist[cnt].celllist[7].string_value = "X"
   ENDIF
   CASE (te.auto_start_ind)
    OF 0:
     reply->rowlist[cnt].celllist[8].string_value = ""
    OF 1:
     reply->rowlist[cnt].celllist[8].string_value = "X"
   ENDCASE
   CASE (te.auto_complete_ind)
    OF 0:
     reply->rowlist[cnt].celllist[9].string_value = ""
    OF 1:
     reply->rowlist[cnt].celllist[9].string_value = "X"
   ENDCASE
   CASE (te.complete_on_exit_ind)
    OF 0:
     reply->rowlist[cnt].celllist[10].string_value = ""
    OF 1:
     reply->rowlist[cnt].celllist[10].string_value = "X"
   ENDCASE
   CASE (te.critical_blink_ind)
    OF 0:
     reply->rowlist[cnt].celllist[11].string_value = ""
    OF 1:
     reply->rowlist[cnt].celllist[11].string_value = "X"
   ENDCASE
   reply->rowlist[cnt].celllist[12].string_value = icon(te.critical_icon), reply->rowlist[cnt].
   celllist[13].string_value = color(te.critical_color), reply->rowlist[cnt].celllist[14].
   string_value = time_disp(te.critical_interval)
   CASE (te.overdue_blink_ind)
    OF 0:
     reply->rowlist[cnt].celllist[15].string_value = ""
    OF 1:
     reply->rowlist[cnt].celllist[15].string_value = "X"
   ENDCASE
   reply->rowlist[cnt].celllist[16].string_value = icon(te.overdue_icon), reply->rowlist[cnt].
   celllist[17].string_value = color(te.overdue_color), reply->rowlist[cnt].celllist[18].string_value
    = time_disp(te.overdue_interval),
   reply->rowlist[cnt].celllist[21].string_value = cv3.display, reply->rowlist[cnt].celllist[23].
   string_value = p.name_full_formatted, reply->rowlist[cnt].celllist[19].double_value = te
   .def_begin_loc_cd,
   reply->rowlist[cnt].celllist[20].double_value = te.def_request_loc_cd
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH nocounter, noheading, outerjoin = d
 ;end select
 DECLARE display = vc
 SELECT INTO "nl:"
  collection_type = tc.collection_type_cd, next_event = tce.element_value, next_event_display = te2
  .display
  FROM (dummyt d  WITH seq = value(size(reply->rowlist,5))),
   track_collection tc,
   code_value cv,
   track_collection_element tce,
   track_event te2
  PLAN (d)
   JOIN (tc
   WHERE (reply->rowlist[d.seq].celllist[2].string_value=trim(tc.display))
    AND tc.active_ind=1)
   JOIN (cv
   WHERE tc.collection_type_cd=cv.code_value
    AND cv.cdf_meaning="EVT_TRIGGER")
   JOIN (tce
   WHERE tc.track_collection_id=tce.track_collection_id)
   JOIN (te2
   WHERE tce.element_value=te2.track_event_id
    AND te2.active_ind=1)
  ORDER BY d.seq, tc.display
  HEAD d.seq
   cnt = 0, display = " "
  HEAD next_event_display
   cnt = (cnt+ 1)
   IF (cnt=1)
    display = te2.display
   ELSE
    display = concat(display,", ",te2.display)
   ENDIF
  FOOT  d.seq
   reply->rowlist[d.seq].celllist[22].string_value = display
  WITH nocounter, noheading
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(reply->rowlist,5))),
   (dummyt d2  WITH seq = 2),
   code_value cv,
   location_group lg,
   code_value cv2,
   location_group lg2,
   code_value cv3,
   dummyt d3,
   location_group lg3,
   code_value cv4
  PLAN (d)
   JOIN (d2)
   JOIN (cv
   WHERE (cv.code_value=reply->rowlist[d.seq].celllist[(18+ d2.seq)].double_value)
    AND cv.active_ind=1)
   JOIN (lg
   WHERE lg.child_loc_cd=cv.code_value
    AND lg.active_ind=1
    AND lg.root_loc_cd=0)
   JOIN (cv2
   WHERE cv2.code_value=lg.parent_loc_cd
    AND cv2.active_ind=1)
   JOIN (lg2
   WHERE lg2.child_loc_cd=cv2.code_value
    AND lg2.active_ind=1
    AND lg2.root_loc_cd=0)
   JOIN (cv3
   WHERE cv3.code_value=lg2.parent_loc_cd
    AND cv3.active_ind=1)
   JOIN (d3)
   JOIN (lg3
   WHERE lg3.child_loc_cd=cv3.code_value
    AND lg3.active_ind=1
    AND lg3.root_loc_cd=0)
   JOIN (cv4
   WHERE cv4.code_value=lg3.parent_loc_cd
    AND cv4.active_ind=1)
  ORDER BY d.seq, d2.seq
  HEAD d2.seq
   display = ""
  DETAIL
   CASE (cv.cdf_meaning)
    OF "AMBULATORY":
     reply->rowlist[d.seq].celllist[(18+ d2.seq)].string_value = concat(trim(cv2.display),", ",trim(
       cv.display))
    OF "NURSEUNIT":
     reply->rowlist[d.seq].celllist[(18+ d2.seq)].string_value = concat(trim(cv2.display),", ",trim(
       cv.display))
    OF "WAITROOM":
     reply->rowlist[d.seq].celllist[(18+ d2.seq)].string_value = concat(trim(cv3.display),", ",trim(
       cv2.display),", ",trim(cv.display))
    OF "ROOM":
     reply->rowlist[d.seq].celllist[(18+ d2.seq)].string_value = concat(trim(cv3.display),", ",trim(
       cv2.display),", ",trim(cv.display))
    OF "BED":
     reply->rowlist[d.seq].celllist[(18+ d2.seq)].string_value = concat(trim(cv4.display),", ",trim(
       cv3.display),", ",trim(cv2.display),
      ", ",trim(cv.display))
   ENDCASE
  WITH nocounter, noheading, outerjoin = d3
 ;end select
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("firstnet_tracking_events.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 SUBROUTINE color(color_string)
  IF (color_string="")
   SET color = ""
  ELSE
   DECLARE color = vc
   SET comma1 = findstring(",",color_string,1,0)
   SET comma2 = findstring(",",color_string,1,1)
   SET red = substring(1,(comma1 - 1),color_string)
   SET green = substring((comma1+ 1),((comma2 - comma1) - 1),color_string)
   SET blue = substring((comma2+ 1),size(color_string),color_string)
   IF (((red=" ") OR (((green=" ") OR (blue=" ")) )) )
    SET color = ""
   ELSE
    SET color = concat("Red=",trim(red),", Green=",trim(green),", Blue=",
     trim(blue))
   ENDIF
  ENDIF
  RETURN(color)
 END ;Subroutine
 SUBROUTINE time_disp(time_sec)
  IF (time_sec=0)
   SET cnvtdtime = ""
  ELSE
   DECLARE hours = vc
   DECLARE min = vc
   DECLARE sec = vc
   SET hours = trim(cnvtstring(abs((time_sec/ 3600))))
   SET min = trim(cnvtstring(abs(((time_sec - (cnvtint(hours) * 3600))/ 60))))
   SET sec = trim(cnvtstring(((time_sec - (cnvtint(hours) * 3600)) - (cnvtint(min) * 60))))
   IF (textlen(min) < 2)
    SET min = concat("0",min)
   ENDIF
   IF (textlen(sec) < 2)
    SET sec = concat("0",sec)
   ENDIF
   SET cnvtdtime = concat(hours,":",min,":",sec)
  ENDIF
  RETURN(cnvtdtime)
 END ;Subroutine
 SUBROUTINE icon(icon_val)
   DECLARE new_val = vc
   DECLARE new_val1 = vc
   IF (icon_val=0)
    SET new_val = ""
   ELSEIF (icon_val <= 299)
    SET new_val = cnvtstring(icon_val)
   ELSE
    SET new_val = cnvtstring(icon_val)
    SET start_val = (size(new_val) - 2)
    SET new_val = substring(start_val,3,new_val)
   ENDIF
   RETURN(new_val)
 END ;Subroutine
END GO
