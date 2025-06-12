CREATE PROGRAM dcp_upd_barcode_format:dba
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
 DECLARE updatecnt = i4
 SET updatecnt = 0
 DECLARE errmsg = c132
 SET errmsg = fillstring(132," ")
 DECLARE failed = c1
 SET failed = "F"
 DECLARE numbertochange = i4
 SET numbertochange = size(request->barcodeformat,5)
 IF (numbertochange=0)
  SET failed = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM org_barcode_format obf,
   (dummyt d  WITH seq = value(numbertochange))
  PLAN (d)
   JOIN (obf
   WHERE (obf.org_barcode_format_id=request->barcodeformat[d.seq].org_barcode_format_id))
  DETAIL
   updatecnt = (updatecnt+ 1)
  WITH nocounter, forupdate(obf)
 ;end select
 IF (updatecnt != numbertochange)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 UPDATE  FROM org_barcode_format obf,
   (dummyt d  WITH seq = value(numbertochange))
  SET obf.barcode_type_cd = request->barcodeformat[d.seq].barcode_type_cd, obf.alias_type_cd =
   request->barcodeformat[d.seq].alias_type_cd, obf.check_digit_ind = request->barcodeformat[d.seq].
   check_digit_ind,
   obf.organization_id = request->barcodeformat[d.seq].organization_id, obf.prefix = request->
   barcodeformat[d.seq].prefix, obf.z_data = request->barcodeformat[d.seq].z_data,
   obf.updt_cnt = (obf.updt_cnt+ 1), obf.updt_dt_tm = cnvtdatetime(curdate,curtime3), obf.updt_id =
   reqinfo->updt_id,
   obf.updt_applctx = reqinfo->updt_applctx, obf.updt_task = reqinfo->updt_task
  PLAN (d)
   JOIN (obf
   WHERE (obf.org_barcode_format_id=request->barcodeformat[d.seq].org_barcode_format_id))
  WITH nocounter
 ;end update
 IF (curqual != numbertochange)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.operationname = "Update"
  SET reply->status_data.operationstatus = "F"
  SET reqinfo->commit_ind = 0
  SET reply->status_data.targetobjectname = "ScriptMessage"
  SET reply->status_data.targetobjectvalue = "Exit -- Locked Records Not Equal to Updated Records"
 ELSEIF (failed="Z")
  SET reply->status_data.status = "Z"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
