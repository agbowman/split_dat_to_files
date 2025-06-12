CREATE PROGRAM bb_upt_isbt_add_info:dba
 SET failures = 0
 RECORD request(
   1 add_info_list[*]
     2 bb_isbt_add_info_id = f8
     2 bb_isbt_product_type_id = f8
     2 attribute_cd = f8
     2 active_ind = i2
     2 updt_cnt = i4
 )
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
  FROM bb_isbt_add_info bia,
   (dummyt d  WITH seq = value(size(request->add_info_list,5)))
  PLAN (d)
   JOIN (bia
   WHERE (request->add_info_list[d.seq].bb_isbt_add_info_id=bia.bb_isbt_add_info_id)
    AND (request->add_info_list[d.seq].updt_cnt=bia.updt_cnt))
  WITH nocounter, forupdate(bia)
 ;end select
 IF (curqual=0)
  SET failures = (failures+ 1)
  GO TO exit_script
 ELSE
  UPDATE  FROM bb_isbt_add_info bia,
    (dummyt d1  WITH seq = value(size(request->add_info_list,5)))
   SET bia.bb_isbt_product_type_id = request->add_info_list[d1.seq].bb_isbt_product_type_id, bia
    .attribute_cd = request->add_info_list[d1.seq].attribute_cd, bia.active_ind = request->
    add_info_list[d1.seq].active_ind,
    bia.active_status_cd =
    IF ((request->add_info_list[d1.seq].active_ind=0)) reqdata->inactive_status_cd
    ELSE reqdata->active_status_cd
    ENDIF
    , bia.active_status_dt_tm = cnvtdatetime(curdate,curtime3), bia.active_status_prsnl_id = reqinfo
    ->updt_id,
    bia.updt_cnt = (bia.updt_cnt+ 1), bia.updt_dt_tm = cnvtdatetime(curdate,curtime3), bia.updt_id =
    reqinfo->updt_id,
    bia.updt_task = reqinfo->updt_task, bia.updt_applctx = reqinfo->updt_applctx
   PLAN (d1)
    JOIN (bia
    WHERE (request->add_info_list[d1.seq].bb_isbt_add_info_id=bia.bb_isbt_add_info_id)
     AND (request->add_info_list[d1.seq].updt_cnt=bia.updt_cnt))
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
