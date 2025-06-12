CREATE PROGRAM bb_add_isbt_attribute_r:dba
 RECORD reply(
   1 isbt_attribute_r[*]
     2 ref_num = f8
     2 new_attribute_r_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 DECLARE failures = i2
 DECLARE ncnt = i2
 SET reply->status_data.status = "F"
 SET failures = 0
 SET stat = alterlist(reply->isbt_attribute_r,size(request->isbt_attribute_r,5))
 SET ncnt = size(request->isbt_attribute_r,5)
 SET next_pathnet_seq = 0.0
 FOR (index = 1 TO ncnt)
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     reply->isbt_attribute_r[index].new_attribute_r_id = cnvtreal(seqn), reply->isbt_attribute_r[
     index].ref_num = request->isbt_attribute_r[index].ref_num
    WITH nocounter
   ;end select
 ENDFOR
 INSERT  FROM bb_isbt_attribute_r bia,
   (dummyt d1  WITH seq = value(size(request->isbt_attribute_r,5)))
  SET bia.bb_isbt_attribute_r_id = reply->isbt_attribute_r[d1.seq].new_attribute_r_id, bia
   .attribute_cd = request->isbt_attribute_r[d1.seq].attribute_cd, bia.bb_isbt_attribute_id = request
   ->isbt_attribute_r[d1.seq].bb_isbt_attribute_id,
   bia.active_ind = 1, bia.active_status_cd = reqdata->active_status_cd, bia.active_status_dt_tm =
   cnvtdatetime(curdate,curtime3),
   bia.active_status_prsnl_id = reqinfo->updt_id, bia.updt_cnt = 0, bia.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   bia.updt_id = reqinfo->updt_id, bia.updt_task = reqinfo->updt_task, bia.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d1)
   JOIN (bia)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failures = (failures+ 1)
  GO TO exit_script
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
