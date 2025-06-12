CREATE PROGRAM dcp_del_encntr_event_set_io:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 qual[*]
     2 event_set_cd = f8
     2 event_set_name = vc
 )
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 SET cnt = size(request->qual,5)
 SET stat = alterlist(temp->qual,cnt)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   v500_event_set_code v
  PLAN (d)
   JOIN (v
   WHERE (request->qual[d.seq].event_set_cd=v.event_set_cd))
  ORDER BY d.seq
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), temp->qual[cnt].event_set_cd = request->qual[d.seq].event_set_cd, temp->qual[cnt].
   event_set_name = v.event_set_name
  WITH nocounter
 ;end select
 FOR (i = 1 TO cnt)
   DELETE  FROM encntr_event_set_io e
    WHERE (e.person_id=request->person_id)
     AND (e.encntr_id=request->encntr_id)
     AND (e.event_set_name=temp->qual[i].event_set_name)
    WITH nocounter
   ;end delete
 ENDFOR
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
END GO
