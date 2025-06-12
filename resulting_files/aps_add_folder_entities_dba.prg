CREATE PROGRAM aps_add_folder_entities:dba
 RECORD reply(
   1 folder_entity_qual[*]
     2 entity_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 comment_qual[*]
     2 comment_id = f8
 )
#script
 SET failed = "F"
 SET reply->status_data.status = "F"
 DECLARE entity_id = f8 WITH protect, noconstant(0.0)
 DECLARE long_text_id = f8 WITH protect, noconstant(0.0)
 SET entity_cnt = cnvtint(size(request->folder_entity_qual,5))
 SET x = 0
 SET comment_cnt = 0
 SET stat = alterlist(reply->folder_entity_qual,entity_cnt)
 SET stat = alterlist(temp->comment_qual,entity_cnt)
 FOR (x = 1 TO entity_cnt)
   SELECT INTO "nl:"
    seq_nbr = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     entity_id = seq_nbr, reply->folder_entity_qual[x].entity_id = entity_id
    WITH format, counter
   ;end select
   IF (curqual=0)
    GO TO seq_failed
   ENDIF
   IF ((request->folder_entity_qual[x].comment != ""))
    SELECT INTO "nl:"
     seq_nbr = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      long_text_id = seq_nbr, temp->comment_qual[x].comment_id = long_text_id
     WITH format, counter
    ;end select
    IF (curqual=0)
     GO TO lt_seq_failed
    ENDIF
    INSERT  FROM long_text lt
     SET lt.long_text_id = temp->comment_qual[x].comment_id, lt.long_text = request->
      folder_entity_qual[x].comment, lt.parent_entity_name = "AP_FOLDER_ENTITY",
      lt.parent_entity_id = reply->folder_entity_qual[x].entity_id, lt.active_ind = 1, lt
      .active_status_cd = reqdata->active_status_cd,
      lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
      updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
      updt_applctx,
      lt.updt_cnt = 0
     PLAN (lt
      WHERE (lt.long_text_id=temp->comment_qual[x].comment_id))
     WITH nocounter, dontexist
    ;end insert
    IF (curqual != 1)
     GO TO lt_ins_failed
    ENDIF
   ENDIF
 ENDFOR
 INSERT  FROM ap_folder_entity afe,
   (dummyt d  WITH seq = value(entity_cnt))
  SET afe.entity_id = reply->folder_entity_qual[d.seq].entity_id, afe.folder_id = request->folder_id,
   afe.create_prsnl_id = request->folder_entity_qual[d.seq].create_prsnl_id,
   afe.parent_entity_id = request->folder_entity_qual[d.seq].parent_entity_id, afe.parent_entity_name
    = request->folder_entity_qual[d.seq].parent_entity_name, afe.entity_type_flag = request->
   folder_entity_qual[d.seq].entity_type_flag,
   afe.display = request->folder_entity_qual[d.seq].display, afe.accession_nbr = request->
   folder_entity_qual[d.seq].accession_nbr, afe.comment_id = temp->comment_qual[d.seq].comment_id,
   afe.updt_dt_tm = cnvtdatetime(curdate,curtime3), afe.updt_id = reqinfo->updt_id, afe.updt_task =
   reqinfo->updt_task,
   afe.updt_applctx = reqinfo->updt_applctx, afe.updt_cnt = 0
  PLAN (d)
   JOIN (afe
   WHERE (afe.entity_id=reply->folder_entity_qual[d.seq].entity_id))
  WITH nocounter, outerjoin = d, dontexist
 ;end insert
 IF (curqual != entity_cnt)
  GO TO afe_ins_failed
 ENDIF
 GO TO exit_script
#seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "reference_seq"
 SET failed = "T"
 GO TO exit_script
#lt_seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "long_data_seq"
 SET failed = "T"
 GO TO exit_script
#afe_ins_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_FOLDER_ENTITY"
 SET failed = "T"
 GO TO exit_script
#lt_ins_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
#exit_script
 SET stat = alterlist(temp->comment_qual,0)
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
