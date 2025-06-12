CREATE PROGRAM bbd_get_testing_procs:dba
 RECORD reply(
   1 qual[*]
     2 mnemonic = vc
     2 synonym_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET err_cnt = 0
 SET qual_cnt = 0
 SET reply->status_data.status = "F"
 SET bbd_processing_cd = 0.0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=106
   AND c.cdf_meaning="BBDONORPROD"
   AND c.active_ind=1
  DETAIL
   bbd_processing_cd = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "6000"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unable to retrieve bbd processing cd"
  GO TO end_script
 ENDIF
 SELECT INTO "nl:"
  o.mnemonic
  FROM order_catalog_synonym o
  PLAN (o
   WHERE o.activity_type_cd=bbd_processing_cd
    AND o.orderable_type_flag=2
    AND o.active_ind=1)
  DETAIL
   qual_cnt = (qual_cnt+ 1), stat = alterlist(reply->qual,qual_cnt), reply->qual[qual_cnt].mnemonic
    = o.mnemonic,
   reply->qual[qual_cnt].synonym_id = o.synonym_id
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  SET err_cnt = (err_cnt+ 1)
  SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "order_catalog_synonym"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
  "unable to return orders specified"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#end_script
END GO
