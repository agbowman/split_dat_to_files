CREATE PROGRAM bb_upt_isbt_product_type:dba
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
  FROM bb_isbt_product_type bipt,
   (dummyt d  WITH seq = value(size(request->product_type_list,5)))
  PLAN (d)
   JOIN (bipt
   WHERE (request->product_type_list[d.seq].bb_isbt_product_type_id=bipt.bb_isbt_product_type_id)
    AND (request->product_type_list[d.seq].updt_cnt=bipt.updt_cnt))
  WITH nocounter, forupdate(bipt)
 ;end select
 IF (curqual=0)
  SET failures += 1
  GO TO exit_script
 ELSE
  UPDATE  FROM bb_isbt_product_type bipt,
    (dummyt d1  WITH seq = value(size(request->product_type_list,5)))
   SET bipt.product_cd = request->product_type_list[d1.seq].product_cd, bipt.isbt_barcode = request->
    product_type_list[d1.seq].isbt_barcode, bipt.active_ind = request->product_type_list[d1.seq].
    active_ind,
    bipt.active_status_cd =
    IF ((request->product_type_list[d1.seq].active_ind=0)) reqdata->inactive_status_cd
    ELSE reqdata->active_status_cd
    ENDIF
    , bipt.active_status_dt_tm = cnvtdatetime(sysdate), bipt.active_status_prsnl_id = reqinfo->
    updt_id,
    bipt.updt_cnt = (bipt.updt_cnt+ 1), bipt.updt_dt_tm = cnvtdatetime(sysdate), bipt.updt_id =
    reqinfo->updt_id,
    bipt.updt_task = reqinfo->updt_task, bipt.updt_applctx = reqinfo->updt_applctx
   PLAN (d1)
    JOIN (bipt
    WHERE (request->product_type_list[d1.seq].bb_isbt_product_type_id=bipt.bb_isbt_product_type_id)
     AND (request->product_type_list[d1.seq].updt_cnt=bipt.updt_cnt))
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failures += 1
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
