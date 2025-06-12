CREATE PROGRAM dcp_add_org_barcode_org:dba
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
 SET numbertochange = size(request->orgbarcodeorg,5)
 INSERT  FROM org_barcode_org obo,
   (dummyt d  WITH seq = value(numbertochange))
  SET obo.org_barcode_seq_id = seq(carenet_seq,nextval), obo.barcode_type_cd = request->
   orgbarcodeorg[d.seq].barcode_type_cd, obo.label_organization_id = request->orgbarcodeorg[d.seq].
   label_organization_id,
   obo.scan_organization_id = request->orgbarcodeorg[d.seq].scan_organization_id, obo.updt_cnt = 0,
   obo.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   obo.updt_id = reqinfo->updt_id, obo.updt_applctx = reqinfo->updt_applctx, obo.updt_task = reqinfo
   ->updt_task
  PLAN (d)
   JOIN (obo)
  WITH nocounter
 ;end insert
#exit_script
 IF (curqual != numbertochange)
  SET reply->status_data.status = "Z"
  SET reply->status_data.operationname = "Insert"
  SET reply->status_data.operationstatus = "F"
  SET reply->status_data.targetobjectname = "Action Message"
  SET reply->status_data.targetobjectvalue = "No Rows added"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.operationname = "Insert"
  SET reply->status_data.status = "S"
  SET reply->status_data.operationstatus = "S"
 ENDIF
END GO
