CREATE PROGRAM bbt_get_orders_by_prcs:dba
 RECORD reply(
   1 qual[*]
     2 active_ind = i2
     2 catalog_cd = f8
     2 qual2[*]
       3 active_ind = i2
       3 mnemonic = vc
       3 synonym_id = f8
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
 SET qual2_cnt = 0
 SET reply->status_data.status = "F"
 SET bb_processing_cd = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = request->cdf_meaning
 SET stat = uar_get_meaning_by_codeset(1635,cdf_meaning,1,bb_processing_cd)
 IF (stat=1)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "UAR"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "1635"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unable to retrieve bb processing cd"
  GO TO end_script
 ENDIF
 CALL echo(bb_processing_cd)
 SELECT INTO "nl:"
  s.catalog_cd, o.mnemonic
  FROM service_directory s,
   order_catalog_synonym o
  PLAN (s
   WHERE s.bb_processing_cd=bb_processing_cd
    AND s.active_ind=1)
   JOIN (o
   WHERE o.catalog_cd=s.catalog_cd
    AND o.active_ind=1)
  HEAD REPORT
   qual_cnt = (qual_cnt+ 1), qual_cnt2 = 0, stat = alterlist(reply->qual,qual_cnt),
   stat = alterlist(reply->qual[qual_cnt].qual2,qual2_cnt), reply->qual[qual_cnt].catalog_cd = s
   .catalog_cd, reply->qual[qual_cnt].active_ind = s.active_ind
  DETAIL
   qual2_cnt = (qual2_cnt+ 1), stat = alterlist(reply->qual[qual_cnt].qual2,qual2_cnt), reply->qual.
   qual2[qual2_cnt].mnemonic = o.mnemonic,
   reply->qual.qual2[qual2_cnt].synonym_id = o.synonym_id, reply->qual.qual2[qual2_cnt].active_ind =
   o.active_ind
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  SET err_cnt = (err_cnt+ 1)
  SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname =
  "service_directory and order_catalog_synonym"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
  "unable to return orders specified"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#end_script
END GO
