CREATE PROGRAM bb_upt_isbt_attribute_r:dba
 SET failures = 0
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT INTO "nl:"
  *
  FROM bb_isbt_attribute_r bia,
   (dummyt d  WITH seq = value(size(request->isbt_attribute_r,5)))
  PLAN (d)
   JOIN (bia
   WHERE (request->isbt_attribute_r[d.seq].bb_isbt_attribute_r_id=bia.bb_isbt_attribute_r_id)
    AND (request->isbt_attribute_r[d.seq].update_cnt=bia.updt_cnt))
  WITH nocounter, forupdate(bia)
 ;end select
 IF (curqual=0)
  SET failures = (failures+ 1)
  GO TO exit_script
 ELSE
  UPDATE  FROM bb_isbt_attribute_r bia,
    (dummyt d1  WITH seq = value(size(request->isbt_attribute_r,5)))
   SET bia.attribute_cd = request->isbt_attribute_r[d1.seq].attribute_cd, bia.bb_isbt_attribute_id =
    request->isbt_attribute_r[d1.seq].bb_isbt_attribute_id, bia.active_ind = request->
    isbt_attribute_r[d1.seq].active_ind,
    bia.active_status_cd =
    IF ((request->isbt_attribute_r[d1.seq].active_ind=0)) reqdata->inactive_status_cd
    ELSE reqdata->active_status_cd
    ENDIF
    , bia.active_status_dt_tm = cnvtdatetime(curdate,curtime3), bia.active_status_prsnl_id = reqinfo
    ->updt_id,
    bia.updt_cnt = (bia.updt_cnt+ 1), bia.updt_dt_tm = cnvtdatetime(curdate,curtime3), bia.updt_id =
    reqinfo->updt_id,
    bia.updt_task = reqinfo->updt_task, bia.updt_applctx = reqinfo->updt_applctx
   PLAN (d1)
    JOIN (bia
    WHERE (request->isbt_attribute_r[d1.seq].bb_isbt_attribute_r_id=bia.bb_isbt_attribute_r_id)
     AND (request->isbt_attribute_r[d1.seq].update_cnt=bia.updt_cnt))
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failures = (failures+ 1)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failures > 0)
  ROLLBACK
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO
