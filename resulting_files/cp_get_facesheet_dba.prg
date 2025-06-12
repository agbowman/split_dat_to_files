CREATE PROGRAM cp_get_facesheet:dba
 RECORD reply(
   1 qual[*]
     2 document_name = vc
     2 document_desc = vc
     2 program_name = vc
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
  pm.document_name, pm.document_desc, pm.program_name
  FROM pm_doc_document pm
  WHERE pm.active_ind=1
  ORDER BY pm.document_name
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(reply->qual,(count+ 9))
   ENDIF
   reply->qual[count].document_name = pm.document_name, reply->qual[count].document_desc = pm
   .document_desc, reply->qual[count].program_name = pm.program_name
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,count)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
