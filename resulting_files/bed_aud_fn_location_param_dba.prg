CREATE PROGRAM bed_aud_fn_location_param:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 tracking_group_code_value = f8
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
 FREE RECORD temp
 RECORD temp(
   1 tqual[*]
     2 location = vc
     2 location_color = vc
     2 base_location_ind = i2
     2 update_bed_status_ind = i2
     2 overdue_color = vc
     2 overdue_time = vc
     2 critical_color = vc
     2 critical_time = vc
     2 update_name = vc
 )
 FREE RECORD locations
 RECORD locations(
   1 units[*]
     2 code_value = f8
     2 name = vc
     2 rooms[*]
       3 code_value = f8
       3 name = vc
       3 beds[*]
         4 code_value = f8
         4 name = vc
 )
 IF ((request->tracking_group_code_value=0))
  GO TO exit_script
 ENDIF
 DECLARE color(color_string=vc) = vc WITH protect
 DECLARE time_disp(time_sec=i2) = vc WITH protect
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM track_location_param tlp
   PLAN (tlp
    WHERE tlp.active_ind=1)
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
 SET pcnt = 0
 SELECT DISTINCT INTO "NL:"
  FROM track_group tg,
   code_value cv_unit,
   location_group lg_fac,
   code_value cv_fac,
   location_group lg_bldg,
   code_value cv_bldg,
   location_group lg_room,
   code_value cv_room,
   location_group lg_bed,
   code_value cv_bed
  PLAN (tg
   WHERE tg.child_table="TRACK_ASSOC"
    AND (tg.tracking_group_cd=request->tracking_group_code_value))
   JOIN (cv_unit
   WHERE cv_unit.code_value=tg.parent_value
    AND cv_unit.cdf_meaning IN ("AMBULATORY", "NURSEUNIT")
    AND cv_unit.active_ind=1)
   JOIN (lg_bldg
   WHERE lg_bldg.child_loc_cd=tg.parent_value
    AND lg_bldg.active_ind=1)
   JOIN (cv_bldg
   WHERE cv_bldg.code_value=lg_bldg.parent_loc_cd
    AND cv_bldg.active_ind=1
    AND cv_bldg.cdf_meaning="BUILDING")
   JOIN (lg_fac
   WHERE lg_fac.child_loc_cd=lg_bldg.parent_loc_cd
    AND lg_fac.active_ind=1)
   JOIN (cv_fac
   WHERE cv_fac.code_value=lg_fac.parent_loc_cd
    AND cv_fac.active_ind=1)
   JOIN (lg_room
   WHERE lg_room.parent_loc_cd=tg.parent_value
    AND lg_room.active_ind=1)
   JOIN (cv_room
   WHERE cv_room.code_value=lg_room.child_loc_cd
    AND cv_room.active_ind=1)
   JOIN (lg_bed
   WHERE lg_bed.parent_loc_cd=outerjoin(lg_room.child_loc_cd)
    AND lg_bed.active_ind=outerjoin(1))
   JOIN (cv_bed
   WHERE cv_bed.code_value=outerjoin(lg_bed.child_loc_cd)
    AND cv_bed.active_ind=outerjoin(1))
  ORDER BY tg.parent_value, lg_room.child_loc_cd, lg_bed.child_loc_cd
  HEAD tg.parent_value
   pcnt = (pcnt+ 1), stat = alterlist(locations->units,pcnt), locations->units[pcnt].code_value =
   cv_unit.code_value,
   locations->units[pcnt].name = concat(trim(cv_fac.display),", ",trim(cv_bldg.display),", ",trim(
     cv_unit.display)), rcnt = 0
  HEAD lg_room.child_loc_cd
   bcnt = 0
   IF (cv_room.code_value > 0)
    rcnt = (rcnt+ 1), stat = alterlist(locations->units[pcnt].rooms,rcnt), locations->units[pcnt].
    rooms[rcnt].code_value = cv_room.code_value,
    locations->units[pcnt].rooms[rcnt].name = concat(trim(locations->units[pcnt].name),", ",trim(
      cv_room.display))
   ENDIF
  HEAD lg_bed.child_loc_cd
   IF (cv_bed.code_value > 0)
    bcnt = (bcnt+ 1), stat = alterlist(locations->units[pcnt].rooms[rcnt].beds,bcnt), locations->
    units[pcnt].rooms[rcnt].beds[bcnt].code_value = cv_bed.code_value,
    locations->units[pcnt].rooms[rcnt].beds[bcnt].name = concat(trim(locations->units[pcnt].rooms[
      rcnt].name),", ",trim(cv_bed.display))
   ENDIF
  WITH nocounter
 ;end select
 SET tcnt = 0
 IF (pcnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = pcnt),
    track_location_param tlp,
    person p
   PLAN (d)
    JOIN (tlp
    WHERE (tlp.location_cd=locations->units[d.seq].code_value)
     AND tlp.active_ind=1)
    JOIN (p
    WHERE p.person_id=outerjoin(tlp.updt_id))
   DETAIL
    tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].location = locations->
    units[d.seq].name,
    temp->tqual[tcnt].location_color = color(tlp.normal_color), temp->tqual[tcnt].base_location_ind
     = tlp.base_loc_ind, temp->tqual[tcnt].update_bed_status_ind = tlp.upd_bed_status_ind,
    temp->tqual[tcnt].overdue_color = color(tlp.overdue_color), temp->tqual[tcnt].overdue_time =
    time_disp(tlp.overdue_interval), temp->tqual[tcnt].critical_color = color(tlp.critical_color),
    temp->tqual[tcnt].critical_time = time_disp(tlp.critical_interval), temp->tqual[tcnt].update_name
     = p.name_full_formatted
   WITH nocounter
  ;end select
  FOR (p = 1 TO pcnt)
   SET rcnt = size(locations->units[p].rooms,5)
   IF (rcnt > 0)
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = rcnt),
      track_location_param tlp,
      person p
     PLAN (d)
      JOIN (tlp
      WHERE (tlp.location_cd=locations->units[p].rooms[d.seq].code_value)
       AND tlp.active_ind=1)
      JOIN (p
      WHERE p.person_id=outerjoin(tlp.updt_id))
     DETAIL
      tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].location = locations->
      units[p].rooms[d.seq].name,
      temp->tqual[tcnt].location_color = color(tlp.normal_color), temp->tqual[tcnt].base_location_ind
       = tlp.base_loc_ind, temp->tqual[tcnt].update_bed_status_ind = tlp.upd_bed_status_ind,
      temp->tqual[tcnt].overdue_color = color(tlp.overdue_color), temp->tqual[tcnt].overdue_time =
      time_disp(tlp.overdue_interval), temp->tqual[tcnt].critical_color = color(tlp.critical_color),
      temp->tqual[tcnt].critical_time = time_disp(tlp.critical_interval), temp->tqual[tcnt].
      update_name = p.name_full_formatted
     WITH nocounter
    ;end select
    FOR (r = 1 TO rcnt)
     SET bcnt = size(locations->units[p].rooms[r].beds,5)
     IF (bcnt > 0)
      SELECT INTO "NL:"
       FROM (dummyt d  WITH seq = bcnt),
        track_location_param tlp,
        person p
       PLAN (d)
        JOIN (tlp
        WHERE (tlp.location_cd=locations->units[p].rooms[r].beds[d.seq].code_value)
         AND tlp.active_ind=1)
        JOIN (p
        WHERE p.person_id=outerjoin(tlp.updt_id))
       DETAIL
        tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].location = locations
        ->units[p].rooms[r].beds[d.seq].name,
        temp->tqual[tcnt].location_color = color(tlp.normal_color), temp->tqual[tcnt].
        base_location_ind = tlp.base_loc_ind, temp->tqual[tcnt].update_bed_status_ind = tlp
        .upd_bed_status_ind,
        temp->tqual[tcnt].overdue_color = color(tlp.overdue_color), temp->tqual[tcnt].overdue_time =
        time_disp(tlp.overdue_interval), temp->tqual[tcnt].critical_color = color(tlp.critical_color),
        temp->tqual[tcnt].critical_time = time_disp(tlp.critical_interval), temp->tqual[tcnt].
        update_name = p.name_full_formatted
       WITH nocounter
      ;end select
     ENDIF
    ENDFOR
   ENDIF
  ENDFOR
 ENDIF
 SET stat = alterlist(reply->collist,9)
 SET reply->collist[1].header_text = "Location"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Location Color"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Base Location"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Update Bed Status"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Overdue Color"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Overdue Time"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Critical Color"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Critical Time"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Last Update By"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,9)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].location
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].location_color
   IF ((temp->tqual[x].base_location_ind=1))
    SET reply->rowlist[row_nbr].celllist[3].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[3].string_value = " "
   ENDIF
   IF ((temp->tqual[x].update_bed_status_ind=1))
    SET reply->rowlist[row_nbr].celllist[4].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[4].string_value = " "
   ENDIF
   SET reply->rowlist[row_nbr].celllist[5].string_value = temp->tqual[x].overdue_color
   SET reply->rowlist[row_nbr].celllist[6].string_value = temp->tqual[x].overdue_time
   SET reply->rowlist[row_nbr].celllist[7].string_value = temp->tqual[x].critical_color
   SET reply->rowlist[row_nbr].celllist[8].string_value = temp->tqual[x].critical_time
   SET reply->rowlist[row_nbr].celllist[9].string_value = temp->tqual[x].update_name
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("fn_location_parameter_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL echorecord(reply)
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
END GO
