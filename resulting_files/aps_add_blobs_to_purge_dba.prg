CREATE PROGRAM aps_add_blobs_to_purge:dba
 RECORD temp_insert(
   1 qual[*]
     2 blob_identifier = vc
     2 storage_cd = f8
 )
#script
 IF (validate(purge_output->status_data.status,"N")="N")
  SET bfromeventserver = "T"
  SET input_cnt = cnvtint(size(request->qual,5))
 ELSE
  SET bfromeventserver = "F"
  SET input_cnt = cnvtint(size(purge_input->qual,5))
 ENDIF
 SET index = 0
 SET stat = alterlist(temp_insert->qual,input_cnt)
 FOR (index = 1 TO input_cnt)
   IF (bfromeventserver="T")
    SET temp_insert->qual[index].blob_identifier = request->qual[index].blob_identifier
    SET temp_insert->qual[index].storage_cd = request->qual[index].storage_cd
   ELSE
    SET temp_insert->qual[index].blob_identifier = purge_input->qual[index].blob_identifier
    SET temp_insert->qual[index].storage_cd = purge_input->qual[index].storage_cd
   ENDIF
 ENDFOR
 INSERT  FROM ap_blob_cleanup abc,
   (dummyt d  WITH seq = value(input_cnt))
  SET abc.blob_identifier = temp_insert->qual[d.seq].blob_identifier, abc.updt_dt_tm = cnvtdatetime(
    curdate,curtime3), abc.updt_id = reqinfo->updt_id,
   abc.updt_task = reqinfo->updt_task, abc.updt_cnt = 0, abc.updt_applctx = reqinfo->updt_applctx,
   abc.storage_cd = temp_insert->qual[d.seq].storage_cd
  PLAN (d)
   JOIN (abc)
  WITH nocounter
 ;end insert
 IF (curqual != input_cnt)
  IF (bfromeventserver="T")
   SET reply->status_data.status = "F"
  ELSE
   SET purge_output->status_data.subeventstatus[1].operationname = "INSERT"
   SET purge_output->status_data.subeventstatus[1].operationstatus = "F"
   SET purge_output->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET purge_output->status_data.subeventstatus[1].targetobjectvalue = "AP_BLOB_CLEANUP"
   SET purge_output->status_data.status = "F"
  ENDIF
 ELSE
  IF (bfromeventserver="T")
   SET reply->status_data.status = "S"
  ELSE
   SET purge_output->status_data.status = "S"
  ENDIF
 ENDIF
END GO
