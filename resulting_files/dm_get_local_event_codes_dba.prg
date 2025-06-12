CREATE PROGRAM dm_get_local_event_codes:dba
 RECORD reply(
   1 event_set_name = c40
   1 qual[*]
     2 event_cd = f8
     2 event_disp = c40
     2 code_status_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET cnt = 0
 SET reply->status_data.status = "F"
 SELECT
  IF (trim(request->event_set_name)=null)
   WHERE trim(a.event_set_name)=null
    AND trim(a.event_code_disp) != null
  ELSE
   WHERE trim(a.event_set_name)=trim(request->event_set_name)
    AND trim(a.event_code_disp) != null
  ENDIF
  INTO "NL:"
  a.event_cd, a.event_cd_disp, a.code_status_cd
  FROM v500_event_code a
  ORDER BY a.event_cd_disp
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].event_cd = a.event_cd,
   reply->qual[cnt].event_disp = a.event_cd_disp, reply->qual[cnt].code_status_cd = a.code_status_cd
  WITH nocounter
 ;end select
 CALL echo(cnt)
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
