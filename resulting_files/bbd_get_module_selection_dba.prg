CREATE PROGRAM bbd_get_module_selection:dba
 RECORD reply(
   1 qual[*]
     2 module_mean = c12
     2 module_display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SELECT INTO "nl:"
  m.cdf_meaning, m.display
  FROM code_value m
  WHERE m.code_set=1660
   AND ((m.cdf_meaning="BB DONOR") OR (m.cdf_meaning="BB TRANSF"))
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].module_mean = m
   .cdf_meaning,
   reply->qual[count].module_display = m.display
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
