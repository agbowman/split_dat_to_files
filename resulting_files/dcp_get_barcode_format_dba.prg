CREATE PROGRAM dcp_get_barcode_format:dba
 RECORD reply(
   1 barcodeformat[*]
     2 alias_type_cd = f8
     2 barcode_type_cd = f8
     2 check_digit_ind = i2
     2 organization_id = f8
     2 org_barcode_format_id = f8
     2 prefix = vc
     2 z_data = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE ncnt = i4
 SET ncnt = 0
 SELECT INTO "nl:"
  FROM org_barcode_format obf
  WHERE obf.org_barcode_format_id > 0
  DETAIL
   ncnt = (ncnt+ 1)
   IF (ncnt > size(reply->barcodeformat,5))
    stat = alterlist(reply->barcodeformat,(ncnt+ 10))
   ENDIF
   reply->barcodeformat[ncnt].alias_type_cd = obf.alias_type_cd, reply->barcodeformat[ncnt].
   barcode_type_cd = obf.barcode_type_cd, reply->barcodeformat[ncnt].check_digit_ind = obf
   .check_digit_ind,
   reply->barcodeformat[ncnt].organization_id = obf.organization_id, reply->barcodeformat[ncnt].
   org_barcode_format_id = obf.org_barcode_format_id, reply->barcodeformat[ncnt].prefix = obf.prefix,
   reply->barcodeformat[ncnt].z_data = obf.z_data
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->barcodeformat,ncnt)
#exit_script
 IF (curqual=0)
  SET reply->status_data.operationname = "Select"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
