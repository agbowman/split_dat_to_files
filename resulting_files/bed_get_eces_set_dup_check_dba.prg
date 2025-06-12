CREATE PROGRAM bed_get_eces_set_dup_check:dba
 FREE SET reply
 RECORD reply(
   1 event_sets[*]
     2 event_set_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 FREE SET temp_sets
 RECORD temp_sets(
   1 event_sets[*]
     2 event_set_name = vc
     2 event_set_code_value = f8
     2 dup_ind = i2
 )
 SET req_cnt = size(request->event_sets,5)
 SET stat = alterlist(temp_sets->event_sets,req_cnt)
 IF (req_cnt > 0)
  FOR (x = 1 TO req_cnt)
   SET temp_sets->event_sets[x].event_set_code_value = request->event_sets[x].event_set_code_value
   SET temp_sets->event_sets[x].event_set_name = request->event_sets[x].event_set_name
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_cnt)),
    code_value cv
   PLAN (d)
    JOIN (cv
    WHERE cv.code_set=93
     AND cv.display_key=trim(cnvtupper(cnvtalphanum(temp_sets->event_sets[d.seq].event_set_name)))
     AND cnvtupper(cv.display)=trim(cnvtupper(temp_sets->event_sets[d.seq].event_set_name)))
   ORDER BY d.seq
   DETAIL
    temp_sets->event_sets[d.seq].dup_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_cnt)),
    v500_event_set_code v
   PLAN (d
    WHERE (temp_sets->event_sets[d.seq].dup_ind=0)
     AND (temp_sets->event_sets[d.seq].event_set_code_value=0))
    JOIN (v
    WHERE v.event_set_name_key=trim(cnvtupper(cnvtalphanum(temp_sets->event_sets[d.seq].
       event_set_name)))
     AND trim(cnvtupper(v.event_set_name))=trim(cnvtupper(temp_sets->event_sets[d.seq].event_set_name
      )))
   ORDER BY d.seq
   DETAIL
    temp_sets->event_sets[d.seq].dup_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_cnt))
   PLAN (d
    WHERE (temp_sets->event_sets[d.seq].dup_ind=1))
   ORDER BY d.seq
   HEAD REPORT
    cnt = 0, stat = alterlist(reply->event_sets,req_cnt)
   DETAIL
    cnt = (cnt+ 1), reply->event_sets[cnt].event_set_name = temp_sets->event_sets[d.seq].
    event_set_name
   FOOT REPORT
    stat = alterlist(reply->event_sets,cnt)
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
