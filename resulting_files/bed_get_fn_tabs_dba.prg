CREATE PROGRAM bed_get_fn_tabs:dba
 FREE SET reply
 RECORD reply(
   1 positions[*]
     2 code_value = f8
     2 display = vc
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
 DECLARE nvp_parser = vc
 IF ((request->trk_group_code_value > 0))
  DECLARE search_string = vc
  SET search_string = build('"*',trim(cnvtstring(request->trk_group_code_value,20,0)),'*"')
  SET nvp_parser = concat('nvp.active_ind = 1 and nvp.pvc_name = "TABINFO" and ',
   'nvp.parent_entity_name = "DETAIL_PREFS" and ',"nvp.pvc_value = ",search_string)
 ELSE
  SET nvp_parser = concat('nvp.active_ind = 1 and nvp.pvc_name = "TABINFO" and ',
   'nvp.parent_entity_name = "DETAIL_PREFS" ')
 ENDIF
 SELECT INTO "NL:"
  FROM name_value_prefs nvp,
   detail_prefs dp
  PLAN (nvp
   WHERE parser(nvp_parser))
   JOIN (dp
   WHERE dp.detail_prefs_id=nvp.parent_entity_id
    AND dp.active_ind=1
    AND dp.application_number=4250111
    AND dp.position_cd > 0
    AND dp.prsnl_id=0.0
    AND dp.person_id=0.0
    AND dp.view_name="TRKLISTVIEW"
    AND dp.comp_name="CUSTOM"
    AND dp.comp_seq=1)
  ORDER BY dp.position_cd
  HEAD REPORT
   stat = alterlist(reply->positions,20), count = 0, tot_count = 0
  HEAD dp.position_cd
   count = (count+ 1), tot_count = (tot_count+ 1)
   IF (count > 20)
    stat = alterlist(reply->positions,(tot_count+ 20)), count = 1
   ENDIF
   reply->positions[tot_count].code_value = dp.position_cd
  FOOT REPORT
   stat = alterlist(reply->positions,tot_count)
  WITH nocounter
 ;end select
 IF (tot_count > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tot_count),
    code_value cv
   PLAN (d
    WHERE (reply->positions[d.seq].code_value > 0))
    JOIN (cv
    WHERE (cv.code_value=reply->positions[d.seq].code_value))
   DETAIL
    reply->positions[d.seq].display = cv.display
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (tot_count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
