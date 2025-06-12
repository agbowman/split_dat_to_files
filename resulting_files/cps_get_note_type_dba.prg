CREATE PROGRAM cps_get_note_type:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 RECORD reply(
   1 qual_knt = i4
   1 qual[*]
     2 event_set_name = vc
     2 note_type_knt = i4
     2 note_type[*]
       3 event_cd = f8
       3 note_type_id = f8
       3 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ((request->qual_knt < 1))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT DISTINCT INTO "nl:"
  vsc.event_set_cd, vse.event_cd, nt.note_type_id
  FROM (dummyt d  WITH seq = value(request->qual_knt)),
   v500_event_set_code vsc,
   v500_event_set_explode vse,
   note_type nt
  PLAN (d
   WHERE d.seq > 0)
   JOIN (vsc
   WHERE (vsc.event_set_name=request->qual[d.seq].event_set_name))
   JOIN (vse
   WHERE vse.event_set_cd=vsc.event_set_cd)
   JOIN (nt
   WHERE nt.event_cd=vse.event_cd)
  HEAD REPORT
   knt = 0, stat = alterlist(reply->qual,10)
  HEAD vsc.event_set_name
   knt += 1
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->qual,(knt+ 9))
   ENDIF
   reply->qual[knt].event_set_name = vsc.event_set_name, nknt = 0, stat = alterlist(reply->qual[knt].
    note_type,10)
  DETAIL
   nknt += 1
   IF (mod(nknt,10)=1
    AND nknt != 1)
    stat = alterlist(reply->qual[knt].note_type,(nknt+ 9))
   ENDIF
   reply->qual[knt].note_type[nknt].event_cd = nt.event_cd, reply->qual[knt].note_type[nknt].
   note_type_id = nt.note_type_id, reply->qual[knt].note_type[nknt].display = nt
   .note_type_description
  FOOT  vsc.event_set_name
   reply->qual[knt].note_type_knt = nknt, stat = alterlist(reply->qual[knt].note_type,nknt)
  FOOT REPORT
   reply->qual_knt = knt, stat = alterlist(reply->qual,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "V500_EVENT_SET_CODE"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSEIF ((reply->qual_knt > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
