CREATE PROGRAM bed_get_eces_hier_xpld:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 event_sets[*]
      2 code_value = f8
      2 display = vc
      2 sequence = i4
      2 display_association_ind = i2
      2 event_set_name = vc
      2 parent_event_set_code = f8
      2 event_codes[*]
        3 code_value = f8
        3 display = vc
    1 too_many_results_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temp_es
 RECORD temp_es(
   1 event_sets[*]
     2 event_set_code_value = f8
 )
 SET reply->status_data.status = "F"
 DECLARE parse_txt = vc
 SET cnt = 0
 SET temp_cnt = 1
 SET stat = alterlist(temp_es->event_sets,1)
 SET temp_es->event_sets[1].event_set_code_value = request->event_set_code_value
 SET child_ind = 1
 WHILE (child_ind=1)
  SET child_ind = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(temp_es->event_sets,5))),
    v500_event_set_canon v1,
    v500_event_set_code ve
   PLAN (d)
    JOIN (v1
    WHERE (v1.parent_event_set_cd=temp_es->event_sets[d.seq].event_set_code_value))
    JOIN (ve
    WHERE ve.event_set_cd=v1.event_set_cd)
   ORDER BY d.seq
   HEAD REPORT
    cnt = size(reply->event_sets,5), list_cnt = 0, t_cnt = 0,
    stat = alterlist(reply->event_sets,(cnt+ 10)), stat = alterlist(temp_es->event_sets,10)
   DETAIL
    child_ind = 1, cnt = (cnt+ 1), list_cnt = (list_cnt+ 1),
    t_cnt = (t_cnt+ 1)
    IF (list_cnt > 10)
     stat = alterlist(reply->event_sets,(cnt+ 10)), stat = alterlist(temp_es->event_sets,(t_cnt+ 10)),
     list_cnt = 1
    ENDIF
    reply->event_sets[cnt].code_value = v1.event_set_cd, reply->event_sets[cnt].display = ve
    .event_set_cd_disp, reply->event_sets[cnt].sequence = v1.event_set_collating_seq,
    reply->event_sets[cnt].display_association_ind = ve.display_association_ind, reply->event_sets[
    cnt].event_set_name = ve.event_set_name, reply->event_sets[cnt].parent_event_set_code = v1
    .parent_event_set_cd,
    temp_es->event_sets[t_cnt].event_set_code_value = v1.event_set_cd
   FOOT REPORT
    stat = alterlist(reply->event_sets,cnt), stat = alterlist(temp_es->event_sets,t_cnt)
   WITH nocounter
  ;end select
 ENDWHILE
 IF (value(size(reply->event_sets,5)) > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(reply->event_sets,5))),
    v500_event_set_explode ves,
    v500_event_code vec
   PLAN (d)
    JOIN (ves
    WHERE (ves.event_set_cd=reply->event_sets[d.seq].code_value)
     AND ves.event_set_level=0)
    JOIN (vec
    WHERE vec.event_cd=ves.event_cd)
   ORDER BY d.seq
   HEAD d.seq
    cnt = 0, list_cnt = 0, stat = alterlist(reply->event_sets[d.seq].event_codes,10)
   DETAIL
    cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
    IF (list_cnt > 10)
     stat = alterlist(reply->event_sets[d.seq].event_codes,(cnt+ 10)), list_cnt = 1
    ENDIF
    reply->event_sets[d.seq].event_codes[cnt].code_value = ves.event_cd, reply->event_sets[d.seq].
    event_codes[cnt].display = vec.event_cd_disp
   FOOT  d.seq
    stat = alterlist(reply->event_sets[d.seq].event_codes,cnt)
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF ((value(size(reply->event_sets,5)) > request->max_reply)
  AND (request->max_reply > 0))
  SET stat = initrec(reply->event_sets)
  SET reply->too_many_results_ind = 1
 ENDIF
 SET reply->status_data.status = "S"
END GO
