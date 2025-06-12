CREATE PROGRAM cdi_del_scanners
 IF (validate(reply)=0)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE scanner_rows = i4 WITH noconstant(value(size(request->scanners,5))), protect
 DECLARE num = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 DELETE  FROM cdi_scanner s
  WHERE expand(num,1,scanner_rows,s.cdi_scanner_id,request->scanners[num].cdi_scanner_id)
  WITH nocounter
 ;end delete
 IF (curqual != scanner_rows)
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
