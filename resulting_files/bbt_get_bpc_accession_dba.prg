CREATE PROGRAM bbt_get_bpc_accession:dba
 RECORD reply(
   1 accession = c20
   1 formatted_accession = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt1 = 0
 SELECT INTO "nl:"
  a.accession
  FROM accession_order_r a
  WHERE (a.order_id=request->order_id)
   AND a.primary_flag=0
  DETAIL
   reply->accession = a.accession, reply->formatted_accession = cnvtacc(a.accession)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "S"
  SET reply->accession = " "
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
