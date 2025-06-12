CREATE PROGRAM dcp_add_barcode_format:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE failed = c1
 SET failed = "F"
 DECLARE numbertochange = i4
 SET numbertochange = size(request->barcodeformat,5)
 INSERT  FROM org_barcode_format obf,
   (dummyt d  WITH seq = value(numbertochange))
  SET obf.org_barcode_format_id = seq(carenet_seq,nextval), obf.barcode_type_cd = request->
   barcodeformat[d.seq].barcode_type_cd, obf.alias_type_cd = request->barcodeformat[d.seq].
   alias_type_cd,
   obf.check_digit_ind = request->barcodeformat[d.seq].check_digit_ind, obf.organization_id = request
   ->barcodeformat[d.seq].organization_id, obf.prefix = request->barcodeformat[d.seq].prefix,
   obf.z_data = request->barcodeformat[d.seq].z_data, obf.parent_entity_name = " ", obf
   .parent_entity_id = 0,
   obf.updt_cnt = 0, obf.updt_dt_tm = cnvtdatetime(curdate,curtime3), obf.updt_id = reqinfo->updt_id,
   obf.updt_applctx = reqinfo->updt_applctx, obf.updt_task = reqinfo->updt_task
  PLAN (d)
   JOIN (obf)
  WITH nocounter
 ;end insert
#exit_script
 IF (curqual != numbertochange)
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "Z"
  SET reply->status_data.operationname = "Insert"
  SET reply->status_data.operationstatus = "F"
  SET reply->status_data.targetobjectname = "Action Message"
  SET reply->status_data.targetobjectvalue = "No rows added"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
