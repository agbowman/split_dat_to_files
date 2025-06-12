CREATE PROGRAM dcp_get_org_barcode_org:dba
 RECORD reply(
   1 orgbarcodeorg[*]
     2 barcode_type_cd = f8
     2 label_organization_id = f8
     2 scan_organization_id = f8
     2 org_barcode_seq_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ncnt = i4
 SET ncnt = 0
 SELECT INTO "nl:"
  FROM org_barcode_org obg
  WHERE obg.org_barcode_seq_id > 0
  DETAIL
   ncnt = (ncnt+ 1)
   IF (ncnt > size(reply->orgbarcodeorg,5))
    stat = alterlist(reply->orgbarcodeorg,(ncnt+ 10))
   ENDIF
   reply->orgbarcodeorg[ncnt].barcode_type_cd = obg.barcode_type_cd, reply->orgbarcodeorg[ncnt].
   label_organization_id = obg.label_organization_id, reply->orgbarcodeorg[ncnt].scan_organization_id
    = obg.scan_organization_id,
   reply->orgbarcodeorg[ncnt].org_barcode_seq_id = obg.org_barcode_seq_id
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->orgbarcodeorg,ncnt)
#exit_script
 IF (curqual=0)
  SET reply->status_data.operationname = "SELECT"
  SET reply->status_data.operationstatus = "F"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
