CREATE PROGRAM dcp_upd_org_barcode_org:dba
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
 SET numbertochange = size(request->orgbarcodeorg,5)
 IF (numbertochange=0)
  SET failed = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM org_barcode_org obo,
   (dummyt d  WITH seq = value(numbertochange))
  PLAN (d)
   JOIN (obo
   WHERE (obo.org_barcode_seq_id=request->orgbarcodeorg[d.seq].org_barcode_seq_id))
  DETAIL
   updatecnt = (updatecnt+ 1)
  WITH nocounter, forupdate(obo)
 ;end select
 IF (updatecnt != numbertochange)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 UPDATE  FROM org_barcode_org obo,
   (dummyt d  WITH seq = value(numbertochange))
  SET obo.barcode_type_cd = request->orgbarcodeorg[d.seq].barcode_type_cd, obo.label_organization_id
    = request->orgbarcodeorg[d.seq].label_organization_id, obo.scan_organization_id = request->
   orgbarcodeorg[d.seq].scan_organization_id,
   obo.updt_cnt = (obo.updt_cnt+ 1), obo.updt_dt_tm = cnvtdatetime(curdate,curtime3), obo.updt_id =
   reqinfo->updt_id,
   obo.updt_applctx = reqinfo->updt_applctx, obo.updt_task = reqinfo->updt_task
  PLAN (d)
   JOIN (obo
   WHERE (obo.org_barcode_seq_id=request->orgbarcodeorg[d.seq].org_barcode_seq_id))
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
