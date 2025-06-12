CREATE PROGRAM bed_get_fn_filter_detail:dba
 FREE SET reply
 RECORD reply(
   1 custom_filters[*]
     2 id = f8
     2 name = vc
     2 filters[*]
       3 name_value_prefs_id = f8
       3 code_value = f8
       3 mean = vc
       3 value = vc
       3 value_display = vc
       3 value_description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SET tot_count = 0
 SET filter_cnt = size(request->custom_filters,5)
 IF (filter_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->custom_filters,filter_cnt)
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = filter_cnt),
   predefined_prefs pp
  PLAN (d)
   JOIN (pp
   WHERE pp.active_ind=1
    AND (pp.predefined_prefs_id=request->custom_filters[d.seq].id))
  DETAIL
   reply->custom_filters[d.seq].id = request->custom_filters[d.seq].id, reply->custom_filters[d.seq].
   name = pp.name
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = filter_cnt),
   name_value_prefs nvp
  PLAN (d)
   JOIN (nvp
   WHERE nvp.active_ind=1
    AND (nvp.parent_entity_id=reply->custom_filters[d.seq].id)
    AND nvp.pvc_name="FILTERFIELD")
  ORDER BY d.seq
  HEAD d.seq
   count = 0, tot_count = 0, stat = alterlist(reply->custom_filters[d.seq].filters,5)
  DETAIL
   filter_cdf = fillstring(25," "), filter_code_value = 0.0, filter_value = fillstring(200," "),
   tot_length = size(nvp.pvc_value,1), beg_pos = 1, end_pos = findstring("^",nvp.pvc_value,beg_pos,0)
   IF (end_pos > 0)
    filter_cdf = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1),
    end_pos = findstring(",",nvp.pvc_value,beg_pos,0),
    filter_code_value = cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)), beg_pos = (
    end_pos+ 1)
    IF (beg_pos < tot_length)
     filter_value = substring(beg_pos,tot_length,nvp.pvc_value)
    ENDIF
   ELSE
    end_pos = findstring(",",nvp.pvc_value,beg_pos,0), filter_cdf = substring(beg_pos,(end_pos -
     beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1)
    IF (beg_pos < tot_length)
     filter_value = substring(beg_pos,tot_length,nvp.pvc_value)
    ENDIF
   ENDIF
   count = (count+ 1), tot_count = (tot_count+ 1)
   IF (count > 5)
    stat = alterlist(reply->custom_filters[d.seq].filters,(tot_count+ 5)), count = 1
   ENDIF
   reply->custom_filters[d.seq].filters[tot_count].name_value_prefs_id = nvp.name_value_prefs_id,
   reply->custom_filters[d.seq].filters[tot_count].code_value = filter_code_value, reply->
   custom_filters[d.seq].filters[tot_count].mean = filter_cdf,
   reply->custom_filters[d.seq].filters[tot_count].value = filter_value
  FOOT  d.seq
   stat = alterlist(reply->custom_filters[d.seq].filters,tot_count)
  WITH nocounter
 ;end select
 FOR (i = 1 TO filter_cnt)
  SET filters = size(reply->custom_filters[i].filters,5)
  IF (filters > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = filters),
     code_value cv
    PLAN (d
     WHERE cnvtint(reply->custom_filters[i].filters[d.seq].value) > 0)
     JOIN (cv
     WHERE cv.code_value=cnvtint(reply->custom_filters[i].filters[d.seq].value))
    DETAIL
     reply->custom_filters[i].filters[d.seq].value_display = cv.display, reply->custom_filters[i].
     filters[d.seq].value_description = cv.description
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = filters),
     track_event t
    PLAN (d
     WHERE (reply->custom_filters[i].filters[d.seq].mean="TEEVENT"))
     JOIN (t
     WHERE t.track_event_id=cnvtint(reply->custom_filters[i].filters[d.seq].value))
    DETAIL
     reply->custom_filters[i].filters[d.seq].value_display = t.display, reply->custom_filters[i].
     filters[d.seq].value_description = t.description
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
#exit_script
 IF (filter_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
