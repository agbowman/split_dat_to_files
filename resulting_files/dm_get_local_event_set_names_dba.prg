CREATE PROGRAM dm_get_local_event_set_names:dba
 RECORD reply(
   1 qual[*]
     2 event_set_name = c40
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
 SET event_set_disp = concat(trim(request->display),"*")
 SELECT
  IF (trim(request->display)=null
   AND (request->active_mode=1))
   WHERE trim(a.event_set_name) IN (null, patstring(event_set_disp))
    AND b.code_value=a.event_cd
    AND b.active_ind=1
  ELSEIF (trim(request->display)=null
   AND (request->active_mode=0))
   WHERE trim(a.event_set_name) IN (null, patstring(event_set_disp))
    AND b.code_value=0
  ELSEIF (trim(request->display) != null
   AND (request->active_mode=1))
   WHERE a.event_set_name=patstring(event_set_disp)
    AND b.code_value=a.event_cd
    AND b.active_ind=1
  ELSE
   WHERE a.event_set_name=patstring(event_set_disp)
    AND b.code_value=0
  ENDIF
  DISTINCT INTO "NL:"
  a.event_set_name
  FROM v500_event_code a,
   code_value b
  ORDER BY a.event_set_name
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].event_set_name = a
   .event_set_name
  WITH nocounter
 ;end select
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
