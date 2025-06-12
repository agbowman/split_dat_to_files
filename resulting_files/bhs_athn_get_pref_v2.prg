CREATE PROGRAM bhs_athn_get_pref_v2
 RECORD t_record(
   1 pref_cnt = i4
   1 pref_qual[*]
     2 pref = vc
     2 found_ind = i2
 )
 RECORD out_rec(
   1 pref_list[*]
     2 pref_name = vc
     2 pref_value = vc
     2 position = vc
     2 prnsl = vc
 )
 DECLARE p_cnt = i4
 DECLARE t_line = vc
 DECLARE t_line2 = vc
 DECLARE done = i2
 SET t_line =  $4
 WHILE (done=0)
   IF (findstring(",",t_line)=0)
    SET t_record->pref_cnt += 1
    SET stat = alterlist(t_record->pref_qual,t_record->pref_cnt)
    SET t_record->pref_qual[t_record->pref_cnt].pref = t_line
    SET done = 1
   ELSE
    SET t_record->pref_cnt += 1
    SET t_line2 = substring(1,(findstring(",",t_line) - 1),t_line)
    SET stat = alterlist(t_record->pref_qual,t_record->pref_cnt)
    SET t_record->pref_qual[t_record->pref_cnt].pref = t_line2
    SET t_line = substring((findstring(",",t_line)+ 1),textlen(t_line),t_line)
   ENDIF
 ENDWHILE
 IF (( $2 > 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = t_record->pref_cnt),
    name_value_prefs nvp,
    app_prefs ap,
    prsnl pr
   PLAN (d)
    JOIN (nvp
    WHERE nvp.parent_entity_name="APP_PREFS"
     AND (nvp.pvc_name=t_record->pref_qual[d.seq].pref)
     AND nvp.active_ind=1)
    JOIN (ap
    WHERE ap.app_prefs_id=nvp.parent_entity_id
     AND ap.application_number=600005
     AND ap.active_ind=1
     AND (ap.prsnl_id= $2))
    JOIN (pr
    WHERE pr.person_id=ap.prsnl_id)
   DETAIL
    CALL echo(nvp.pvc_name), p_cnt += 1, stat = alterlist(out_rec->pref_list,p_cnt),
    out_rec->pref_list[p_cnt].pref_name = nvp.pvc_name, out_rec->pref_list[p_cnt].pref_value = nvp
    .pvc_value, out_rec->pref_list[p_cnt].prnsl = pr.name_full_formatted,
    t_record->pref_qual[d.seq].found_ind = 1
   WITH nocounter, time = 30
  ;end select
 ENDIF
 IF (( $3 > 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = t_record->pref_cnt),
    name_value_prefs nvp,
    app_prefs ap
   PLAN (d
    WHERE (t_record->pref_qual[d.seq].found_ind=0))
    JOIN (nvp
    WHERE nvp.parent_entity_name="APP_PREFS"
     AND (nvp.pvc_name=t_record->pref_qual[d.seq].pref)
     AND nvp.active_ind=1)
    JOIN (ap
    WHERE ap.app_prefs_id=nvp.parent_entity_id
     AND ap.application_number=600005
     AND ap.active_ind=1
     AND (ap.position_cd= $3))
   DETAIL
    p_cnt += 1, stat = alterlist(out_rec->pref_list,p_cnt), out_rec->pref_list[p_cnt].pref_name = nvp
    .pvc_name,
    out_rec->pref_list[p_cnt].pref_value = nvp.pvc_value, out_rec->pref_list[p_cnt].position =
    uar_get_code_display(ap.position_cd), t_record->pref_qual[d.seq].found_ind = 1
   WITH nocounter, time = 30
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->pref_cnt),
   name_value_prefs nvp,
   app_prefs ap
  PLAN (d
   WHERE (t_record->pref_qual[d.seq].found_ind=0))
   JOIN (nvp
   WHERE nvp.parent_entity_name="APP_PREFS"
    AND (nvp.pvc_name=t_record->pref_qual[d.seq].pref)
    AND nvp.active_ind=1)
   JOIN (ap
   WHERE ap.app_prefs_id=nvp.parent_entity_id
    AND ap.application_number=600005
    AND ap.active_ind=1
    AND ap.position_cd=0
    AND ap.prsnl_id=0)
  DETAIL
   p_cnt += 1, stat = alterlist(out_rec->pref_list,p_cnt), out_rec->pref_list[p_cnt].pref_name = nvp
   .pvc_name,
   out_rec->pref_list[p_cnt].pref_value = nvp.pvc_value
  WITH nocounter, time = 30
 ;end select
 CALL echojson(out_rec, $1)
END GO
