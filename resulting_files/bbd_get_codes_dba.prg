CREATE PROGRAM bbd_get_codes:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 display = c40
     2 cdf_meaning = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET qual_idx = 0
 SELECT INTO "nl:"
  c.code_value, c.code_set, c.display,
  c.cdf_meaning
  FROM code_value c
  WHERE (c.code_set=request->code_set)
   AND c.active_ind=1
  DETAIL
   qual_idx = (qual_idx+ 1), stat = alterlist(reply->qual,qual_idx), reply->qual[qual_idx].code_value
    = c.code_value,
   reply->qual[qual_idx].display = c.display, reply->qual[qual_idx].cdf_meaning = c.cdf_meaning
  WITH nocounter
 ;end select
 IF (qual_idx=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
