CREATE PROGRAM bed_ens_pharm_legacy_items:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET lcnt = 0
 SET lcnt = size(request->legacy_items,5)
 FOR (l = 1 TO lcnt)
  UPDATE  FROM br_pharm_product_work b
   SET b.match_ind = request->legacy_items[l].match_ind, b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm
     = cnvtdatetime(curdate,curtime3),
    b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
    updt_applctx
   WHERE (b.facility_cd=request->legacy_items[l].facility_code_value)
    AND (b.ndc=request->legacy_items[l].ndc)
    AND (b.description=request->legacy_items[l].description)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET error_flag = "Y"
   SET error_msg = "Unable to update into br_pharm_product_work"
   GO TO exit_script
  ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_PHARM_LEGACY_ITEMS","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
