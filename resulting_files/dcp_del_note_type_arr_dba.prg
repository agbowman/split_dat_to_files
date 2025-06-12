CREATE PROGRAM dcp_del_note_type_arr:dba
 RECORD reply(
   1 delete_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temparr(
   1 qual[*]
     2 note_type_id = f8
 )
 SET reply->status_data.status = "S"
 SET failed = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  nt.note_type_id
  FROM note_type nt
  WHERE nt.note_type_id > 0
   AND (nt.event_cd !=
  (SELECT
   event_cd
   FROM v500_event_code))
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > size(temparr->qual,5))
    stat = alterlist(temparr->qual,(cnt+ 10))
   ENDIF
   temparr->qual[cnt].note_type_id = nt.note_type_id
  WITH nocounter
 ;end select
 SET stat = alterlist(temparr->qual,cnt)
 SET reply->delete_cnt = cnt
 FOR (i = 1 TO cnt)
   DELETE  FROM note_type_list nl
    WHERE (nl.note_type_id=temparr->qual[i].note_type_id)
   ;end delete
   DELETE  FROM note_type_template_reltn ntl
    WHERE (ntl.note_type_id=temparr->qual[i].note_type_id)
   ;end delete
   DELETE  FROM note_type nt
    WHERE (nt.note_type_id=temparr->qual[i].note_type_id)
   ;end delete
 ENDFOR
 IF (cnt=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET reqinfo->commit_ind = 1
#exit_script
 IF ((reply->status_data.status="F"))
  SET reqinfo->commit_ind = 0
  SET reply->status_data.subeventstatus[1].operationname = "DELETE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "NOTE_TYPE"
 ENDIF
END GO
