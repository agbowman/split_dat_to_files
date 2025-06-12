CREATE PROGRAM aps_chg_station_associations:dba
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
 SET ais_updt_cnt = 0
 SET count1 = 0
 SET cnt = 0
 SET chg_updt_cnts[500] = 0
 SET station_name = ""
 SET station_id = 0.0
 SET source_device_cd = 0.0
 IF ((request->station_id=0))
  SELECT INTO "nl:"
   seq_nbr = seq(reference_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    station_id = cnvtreal(seq_nbr)
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "NEXTVAL"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "SEQ"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "REFERENCE_SEQ"
   ROLLBACK
   GO TO exit_script
  ENDIF
  INSERT  FROM ap_image_station ais
   SET ais.station_id = station_id, ais.station_name = trim(request->station_name), ais
    .source_device_cd = request->source_device_cd,
    ais.updt_cnt = 0, ais.updt_dt_tm = cnvtdatetime(curdate,curtime3), ais.updt_id = reqinfo->updt_id,
    ais.updt_task = reqinfo->updt_task, ais.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual != 1)
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = "AP_IMAGE_STATION"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = request->station_name
   ROLLBACK
   GO TO exit_script
  ENDIF
 ELSE
  SELECT INTO "nl:"
   ais.station_id
   FROM ap_image_station ais
   WHERE (ais.station_id=request->station_id)
   DETAIL
    ais_updt_cnt = ais.updt_cnt, station_id = ais.station_id, station_name = ais.station_name,
    source_device_cd = ais.source_device_cd
   WITH nocounter, forupdate(ais)
  ;end select
  IF (curqual=0)
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   SET reply->status_data.subeventstatus[1].targetobjectname = "AP_IMAGE_STATION"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("station_id: ",request->
    station_id)
   ROLLBACK
   GO TO exit_script
  ENDIF
  IF ((ais_updt_cnt != request->updt_cnt))
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "CHANGED"
   SET reply->status_data.subeventstatus[1].targetobjectname = "AP_IMAGE_STATION"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("station_id: ",request->
    station_id)
   ROLLBACK
   GO TO exit_script
  ENDIF
  IF ((((request->station_name != station_name)) OR ((request->source_device_cd != source_device_cd)
  )) )
   UPDATE  FROM ap_image_station ais
    SET ais.station_id = request->station_id, ais.station_name = trim(request->station_name), ais
     .source_device_cd = request->source_device_cd,
     ais.updt_cnt = (ais.updt_cnt+ 1), ais.updt_dt_tm = cnvtdatetime(curdate,curtime3), ais.updt_id
      = reqinfo->updt_id,
     ais.updt_task = reqinfo->updt_task, ais.updt_applctx = reqinfo->updt_applctx
    WHERE (ais.station_id=request->station_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET stat = alter(reply->status_data.subeventstatus,1)
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].targetobjectname = "AP_IMAGE_STATION"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = build("station_id: ",request->
     station_id)
    ROLLBACK
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 IF ((request->task_add_cnt > 0))
  INSERT  FROM ap_prefix_station_r apsr,
    (dummyt d  WITH seq = value(request->task_add_cnt))
   SET apsr.station_id = station_id, apsr.prefix_id = request->task_add_qual[d.seq].prefix_id, apsr
    .catalog_cd = request->task_add_qual[d.seq].catalog_cd,
    apsr.task_assay_cd = request->task_add_qual[d.seq].task_assay_cd, apsr.publish_flag = request->
    task_add_qual[d.seq].publish_flag, apsr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    apsr.updt_id = reqinfo->updt_id, apsr.updt_task = reqinfo->updt_task, apsr.updt_applctx = reqinfo
    ->updt_applctx,
    apsr.updt_cnt = 0
   PLAN (d)
    JOIN (apsr
    WHERE (apsr.station_id=request->station_id)
     AND (apsr.prefix_id=request->task_add_qual[d.seq].prefix_id))
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  IF ((curqual != request->task_add_cnt))
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = "AP_PREFIX_STATION_R"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("station_id: ",request->
    station_id)
   ROLLBACK
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->task_chg_cnt > 0))
  SELECT INTO "nl:"
   apsr.prefix_id, apsr.catalog_cd, apsr.task_assay_cd
   FROM ap_prefix_station_r apsr,
    (dummyt d  WITH seq = value(request->task_chg_cnt))
   PLAN (d)
    JOIN (apsr
    WHERE (apsr.prefix_id=request->task_chg_qual[d.seq].prefix_id)
     AND (apsr.station_id=request->station_id))
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), chg_updt_cnts[count1] = apsr.updt_cnt
   WITH nocounter, forupdate(apsr)
  ;end select
  IF ((count1 != request->task_chg_cnt))
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   SET reply->status_data.subeventstatus[1].targetobjectname = "AP_PREFIX_STATION_R"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("station_id: ",request->
    station_id)
   ROLLBACK
   GO TO exit_script
  ENDIF
  FOR (cnt = 1 TO request->task_chg_cnt)
    IF ((request->task_chg_qual[cnt].updt_cnt != chg_updt_cnts[cnt]))
     SET stat = alter(reply->status_data.subeventstatus,1)
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].operationname = "VERIFYCHG"
     SET reply->status_data.subeventstatus[1].targetobjectname = "AP_PREFIX_STATION_R"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = build("prefix_id: ",request->
      task_chg_qual[cnt].prefix_id)
     ROLLBACK
     GO TO exit_script
    ENDIF
  ENDFOR
  UPDATE  FROM ap_prefix_station_r apsr,
    (dummyt d  WITH seq = value(request->task_chg_cnt))
   SET apsr.catalog_cd = request->task_chg_qual[d.seq].catalog_cd, apsr.task_assay_cd = request->
    task_chg_qual[d.seq].task_assay_cd, apsr.publish_flag = request->task_chg_qual[d.seq].
    publish_flag,
    apsr.updt_dt_tm = cnvtdatetime(curdate,curtime3), apsr.updt_id = reqinfo->updt_id, apsr.updt_task
     = reqinfo->updt_task,
    apsr.updt_applctx = reqinfo->updt_applctx, apsr.updt_cnt = (apsr.updt_cnt+ 1)
   PLAN (d)
    JOIN (apsr
    WHERE (apsr.prefix_id=request->task_chg_qual[d.seq].prefix_id)
     AND (apsr.station_id=request->station_id))
   WITH nocounter, outerjoin = d
  ;end update
  IF ((curqual != request->task_chg_cnt))
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].targetobjectname = "AP_PREFIX_STATION_R"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("station_id: ",request->
    station_id)
   ROLLBACK
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->task_del_cnt > 0))
  SELECT INTO "nl:"
   apsr.prefix_id, apsr.catalog_cd, apsr.task_assay_cd
   FROM ap_prefix_station_r apsr,
    (dummyt d  WITH seq = value(request->task_del_cnt))
   PLAN (d)
    JOIN (apsr
    WHERE (apsr.station_id=request->station_id)
     AND (apsr.prefix_id=request->task_del_qual[d.seq].prefix_id)
     AND (apsr.catalog_cd=request->task_del_qual[d.seq].catalog_cd)
     AND (apsr.task_assay_cd=request->task_del_qual[d.seq].task_assay_cd))
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1)
   WITH nocounter, forupdate(apsr)
  ;end select
  IF ((count1 != request->task_del_cnt))
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   SET reply->status_data.subeventstatus[1].targetobjectname = "AP_PREFIX_STATION_R"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("station_id: ",request->
    station_id)
   ROLLBACK
   GO TO exit_script
  ENDIF
  DELETE  FROM ap_prefix_station_r apsr,
    (dummyt d  WITH seq = value(request->task_del_cnt))
   SET apsr.seq = 1
   PLAN (d)
    JOIN (apsr
    WHERE (apsr.station_id=request->station_id)
     AND (apsr.prefix_id=request->task_del_qual[d.seq].prefix_id)
     AND (apsr.catalog_cd=request->task_del_qual[d.seq].catalog_cd)
     AND (apsr.task_assay_cd=request->task_del_qual[d.seq].task_assay_cd))
   WITH nocounter
  ;end delete
  IF ((curqual != request->task_del_cnt))
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   SET reply->status_data.subeventstatus[1].targetobjectname = "AP_PREFIX_STATION_R"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("station_id: ",request->
    station_id)
   ROLLBACK
   GO TO exit_script
  ENDIF
 ENDIF
 COMMIT
 SET reply->status_data.status = "S"
#exit_script
END GO
