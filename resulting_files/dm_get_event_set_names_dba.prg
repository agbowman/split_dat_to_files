CREATE PROGRAM dm_get_event_set_names:dba
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
 SET first_null = 0
 SELECT
  IF (trim(request->display)=null
   AND (request->active_mode=1))
   WHERE trim(a.event_set_name) IN (null, patstring(event_set_disp))
    AND b.code_value=a.event_cd
    AND b.active_ind=1
  ELSEIF (trim(request->display)=null
   AND (request->active_mode=0))
   WHERE trim(a.event_set_name) IN (null, patstring(event_set_disp))
    AND b.code_value=a.event_cd
  ELSEIF (trim(request->display) != null
   AND (request->active_mode=1))
   WHERE a.event_set_name=patstring(event_set_disp)
    AND b.code_value=a.event_cd
    AND b.active_ind=1
  ELSE
   WHERE a.event_set_name=patstring(event_set_disp)
    AND b.code_value=a.event_cd
  ENDIF
  DISTINCT INTO "NL:"
  a.event_set_name
  FROM v500_event_code@loc_mrg_link a,
   code_value@loc_mrg_link b
  ORDER BY a.event_set_name
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt)
   IF (trim(a.event_set_name) != null)
    reply->qual[cnt].event_set_name = a.event_set_name
   ELSEIF (first_null=0)
    first_null = 1, reply->qual[cnt].event_set_name = a.event_set_name
   ENDIF
  WITH nocounter
 ;end select
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
