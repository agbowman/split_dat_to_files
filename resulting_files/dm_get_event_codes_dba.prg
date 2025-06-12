CREATE PROGRAM dm_get_event_codes:dba
 RECORD reply(
   1 event_set_name = c40
   1 qual[*]
     2 event_cd = f8
     2 event_display = c40
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
    AND trim(a.event_cd_disp) != null
   ORDER BY a.event_cd_disp
  ELSE
   WHERE a.event_set_name=trim(request->event_set_name)
    AND trim(a.event_cd_disp) != null
   ORDER BY a.event_cd_disp
  ENDIF
  INTO "NL:"
  a.event_cd, a.event_cd_disp, a.code_status_cd
  FROM v500_event_code@loc_mrg_link a
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].event_cd = a.event_cd,
   reply->qual[cnt].event_display = a.event_cd_disp, reply->qual[cnt].code_status_cd = a
   .code_status_cd
  WITH nocounter
 ;end select
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
