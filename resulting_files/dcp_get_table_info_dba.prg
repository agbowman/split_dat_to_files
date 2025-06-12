CREATE PROGRAM dcp_get_table_info:dba
 RECORD reply(
   1 more_ind = i4
   1 return_cnt = i4
   1 tvalue[*]
     2 display = vc
     2 pref_value = vc
     2 merge_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET max = 40
 SET reply->status_data.status = "F"
 SET search_strg = fillstring(50," ")
 SET search_strg = trim(request->start_value)
 SET cnt = 0
 IF (cnvtupper(request->table_name)="ALT_SEL_CAT")
  SELECT INTO "nl:"
   a1.short_description, a1.alt_sel_category_id
   FROM alt_sel_cat a1
   WHERE cnvtupper(a1.short_description) >= cnvtupper(search_strg)
   ORDER BY cnvtupper(a1.short_description)
   HEAD REPORT
    cnt = 0
   DETAIL
    IF (cnt < max)
     cnt = (cnt+ 1)
     IF (cnt > size(reply->tvalue,5))
      stat = alterlist(reply->tvalue,(cnt+ 10))
     ENDIF
     reply->tvalue[cnt].display = a1.short_description, reply->tvalue[cnt].pref_value = cnvtstring(a1
      .alt_sel_category_id), reply->tvalue[cnt].merge_id = a1.alt_sel_category_id
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF (cnvtupper(request->table_name)="NOTE_TYPE")
  SELECT INTO "nl:"
   nt.note_type_description, nt.event_cd, nt.note_type_id
   FROM note_type nt
   WHERE cnvtupper(nt.note_type_description) >= cnvtupper(search_strg)
   ORDER BY cnvtupper(nt.note_type_description)
   HEAD REPORT
    cnt = 0
   DETAIL
    IF (cnt < max)
     cnt = (cnt+ 1)
     IF (cnt > size(reply->tvalue,5))
      stat = alterlist(reply->tvalue,(cnt+ 10))
     ENDIF
     reply->tvalue[cnt].display = nt.note_type_description, reply->tvalue[cnt].pref_value =
     cnvtstring(nt.event_cd), reply->tvalue[cnt].merge_id = nt.event_cd
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF (cnvtupper(request->table_name)="V500_EVENT_SET_CODE")
  SELECT INTO "nl:"
   ves.event_set_name, ves.event_set_cd
   FROM v500_event_set_code ves
   WHERE cnvtupper(ves.event_set_name) >= cnvtupper(search_strg)
   ORDER BY cnvtupper(ves.event_set_name)
   HEAD REPORT
    cnt = 0
   DETAIL
    IF (cnt < max)
     cnt = (cnt+ 1)
     IF (cnt > size(reply->tvalue,5))
      stat = alterlist(reply->tvalue,(cnt+ 10))
     ENDIF
     reply->tvalue[cnt].display = ves.event_set_name, reply->tvalue[cnt].pref_value = cnvtstring(ves
      .event_set_cd), reply->tvalue[cnt].merge_id = ves.event_set_cd
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF (cnvtupper(request->table_name)="TIME_SCALE")
  SELECT INTO "nl:"
   ts.time_scale_name, ts.time_scale_name_key, ts.time_scale_id
   FROM time_scale ts
   WHERE cnvtupper(ts.time_scale_name) >= cnvtupper(search_strg)
   ORDER BY cnvtupper(ts.time_scale_name)
   HEAD REPORT
    cnt = 0
   DETAIL
    IF (cnt < max)
     cnt = (cnt+ 1)
     IF (cnt > size(reply->tvalue,5))
      stat = alterlist(reply->tvalue,(cnt+ 10))
     ENDIF
     reply->tvalue[cnt].display = ts.time_scale_name, reply->tvalue[cnt].pref_value = ts
     .time_scale_name_key, reply->tvalue[cnt].merge_id = ts.time_scale_id
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF (cnvtupper(request->table_name)="PREDEFINED_PREFS")
  SELECT INTO "nl:"
   pp.predefined_prefs_id, pp.name
   FROM predefined_prefs pp
   WHERE cnvtupper(pp.name) >= cnvtupper(search_strg)
    AND ((pp.predefined_type_meaning="DEMOGVIEW") OR (pp.predefined_type_meaning="VISITVIEW"))
   ORDER BY cnvtupper(pp.name)
   HEAD REPORT
    cnt = 0
   DETAIL
    IF (cnt < max)
     cnt = (cnt+ 1)
     IF (cnt > size(reply->tvalue,5))
      stat = alterlist(reply->tvalue,(cnt+ 10))
     ENDIF
     reply->tvalue[cnt].display = pp.name, reply->tvalue[cnt].pref_value = cnvtstring(pp
      .predefined_prefs_id), reply->tvalue[cnt].merge_id = pp.predefined_prefs_id
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF (cnvtupper(request->table_name)="APPLICATION")
  SELECT INTO "nl:"
   pp.application_number, pp.description
   FROM application pp
   WHERE cnvtupper(pp.description) >= cnvtupper(search_strg)
   ORDER BY cnvtupper(pp.description)
   HEAD REPORT
    cnt = 0
   DETAIL
    IF (cnt < max)
     cnt = (cnt+ 1)
     IF (cnt > size(reply->tvalue,5))
      stat = alterlist(reply->tvalue,(cnt+ 10))
     ENDIF
     reply->tvalue[cnt].display = pp.description, reply->tvalue[cnt].pref_value = cnvtstring(pp
      .application_number), reply->tvalue[cnt].merge_id = pp.application_number
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF (cnvtupper(request->table_name)="TL_TIME_FRAME")
  SELECT INTO "nl:"
   FROM tl_time_frame ttf
   WHERE cnvtupper(ttf.description) >= cnvtupper(search_strg)
   ORDER BY cnvtupper(ttf.description)
   HEAD REPORT
    cnt = 0
   DETAIL
    IF (cnt < max)
     cnt = (cnt+ 1)
     IF (cnt > size(reply->tvalue,5))
      stat = alterlist(reply->tvalue,(cnt+ 10))
     ENDIF
     reply->tvalue[cnt].display = ttf.description, reply->tvalue[cnt].pref_value = cnvtstring(ttf
      .tl_time_frame_id), reply->tvalue[cnt].merge_id = ttf.tl_time_frame_id
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
  SET reply->return_cnt = cnt
 ENDIF
 CALL echo(cnt)
 FOR (i = 1 TO cnt)
   CALL echo(build("display = ",reply->tvalue[i].display))
   CALL echo(build("value = ",reply->tvalue[i].pref_value))
   CALL echo(build("merge_id = ",reply->tvalue[i].merge_id))
 ENDFOR
 SET stat = alterlist(reply->tvalue,cnt)
END GO
