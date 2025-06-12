CREATE PROGRAM cdi_chg_code_value:dba
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
 DECLARE failed_ind = i4 WITH public, noconstant(0)
 DECLARE count1 = i4 WITH public, noconstant(0)
 DECLARE number_to_chg = i4 WITH public, noconstant(size(request->changes,5))
 SELECT INTO "nl:"
  cv.*
  FROM code_value cv,
   (dummyt d  WITH seq = value(number_to_chg))
  PLAN (d)
   JOIN (cv
   WHERE (cv.code_value=request->changes[d.seq].code_value))
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
  WITH nocounter, forupdate(cv)
 ;end select
 IF (count1 != number_to_chg)
  SET failed_ind = 1
  GO TO exit_script
 ENDIF
 UPDATE  FROM code_value cv,
   (dummyt d  WITH seq = value(number_to_chg))
  SET cv.cdf_meaning =
   IF ((request->changes[d.seq].cdf_meaning=null)) cv.cdf_meaning
   ELSE request->changes[d.seq].cdf_meaning
   ENDIF
   , cv.display =
   IF ((request->changes[d.seq].display=null)) cv.display
   ELSE request->changes[d.seq].display
   ENDIF
   , cv.display_key =
   IF ((request->changes[d.seq].display=null)) cv.display_key
   ELSE cnvtupper(cnvtalphanum(request->changes[d.seq].display))
   ENDIF
   ,
   cv.description =
   IF ((request->changes[d.seq].description=null)) cv.description
   ELSE request->changes[d.seq].description
   ENDIF
   , cv.definition =
   IF ((request->changes[d.seq].definition=null)) cv.definition
   ELSE request->changes[d.seq].definition
   ENDIF
   , cv.active_ind =
   IF ((request->changes[d.seq].active_ind=null)) cv.active_ind
   ELSE request->changes[d.seq].active_ind
   ENDIF
   ,
   cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_id =
   reqinfo->updt_id,
   cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (cv
   WHERE (cv.code_value=request->changes[d.seq].code_value))
  WITH nocounter
 ;end update
 IF (curqual != number_to_chg)
  SET failed_ind = 1
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed_ind=1)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "Update"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Update failed"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
