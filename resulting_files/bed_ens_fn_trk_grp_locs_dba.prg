CREATE PROGRAM bed_ens_fn_trk_grp_locs:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET lcnt = size(request->locations,5)
 IF (lcnt > 0)
  INSERT  FROM track_group tg,
    (dummyt d  WITH seq = lcnt)
   SET tg.parent_value = request->locations[d.seq].code_value, tg.child_value = 0.0, tg
    .tracking_group_cd = request->tracking_group_code_value,
    tg.child_table = "TRACK_ASSOC", tg.tracking_rule = " ", tg.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    tg.updt_id = reqinfo->updt_id, tg.updt_task = reqinfo->updt_task, tg.updt_cnt = 0,
    tg.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (tg)
   WITH nocounter
  ;end insert
 ENDIF
 IF (curqual=0)
  SET error_flag = "F"
  SET error_msg = concat("Error adding tracking group locations")
 ENDIF
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = build2(">> PROGRAM NAME: BED_ENS_FN_TRK_GRP_LOCS  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
