CREATE PROGRAM cv_getnormalcycdforecg:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 normalcy_cd = f8
 ) WITH persistscript
 SELECT INTO "nl:"
  FROM cv_normalcy_classification c
  WHERE (c.classification_statement=request->ecgclassifcation_statement)
  DETAIL
   reply->normalcy_cd = c.normalcy_indicator_cd
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echojson(reply,"cv_filewrittenagainewithcd.dat",0)
END GO
