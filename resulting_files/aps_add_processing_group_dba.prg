CREATE PROGRAM aps_add_processing_group:dba
 RECORD reply(
   1 parent_entity_id = f8
   1 parent_entity_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET nbr_to_insert = cnvtint(size(request->qual,5))
 SELECT INTO "nl:"
  seq_nbr = seq(reference_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   reply->parent_entity_id = cnvtreal(seq_nbr)
  WITH format, counter
 ;end select
 IF (curqual=0)
  GO TO seq_failed
 ENDIF
 INSERT  FROM code_value cv
  SET cv.code_value = reply->parent_entity_id, cv.code_set = request->code_set, cv.display = trim(
    request->short_name),
   cv.display_key = cnvtupper(cnvtalphanum(trim(request->short_name))), cv.description = trim(request
    ->description), cv.active_ind = request->active_ind,
   cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv.updt_task =
   reqinfo->updt_task,
   cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual != 1)
  GO TO c_failed
 ENDIF
 INSERT  FROM ap_processing_grp_r agi,
   (dummyt d  WITH seq = value(nbr_to_insert))
  SET agi.parent_entity_id = reply->parent_entity_id, agi.parent_entity_name = "CODE_VALUE", agi
   .task_assay_cd = request->qual[d.seq].task_assay_cd,
   agi.begin_section = request->qual[d.seq].begin_section, agi.begin_level = request->qual[d.seq].
   begin_level, agi.end_section = request->qual[d.seq].begin_section,
   agi.end_level = request->qual[d.seq].begin_level, agi.no_charge_ind = request->qual[d.seq].
   no_charge_ind, agi.sequence = request->qual[d.seq].sequence,
   agi.updt_dt_tm = cnvtdatetime(curdate,curtime3), agi.updt_id = reqinfo->updt_id, agi.updt_task =
   reqinfo->updt_task,
   agi.updt_applctx = reqinfo->updt_applctx, agi.updt_cnt = 0
  PLAN (d)
   JOIN (agi
   WHERE (agi.parent_entity_id=reply->parent_entity_id)
    AND agi.parent_entity_name="CODE_VALUE"
    AND (agi.sequence=request->qual[d.seq].sequence))
  WITH nocounter, outerjoin = d, dontexist
 ;end insert
 IF (curqual != nbr_to_insert)
  GO TO agi_failed
 ENDIF
 GO TO exit_script
#seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "reference_seq"
 SET failed = "T"
 GO TO exit_script
#c_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
 SET failed = "T"
 GO TO exit_script
#agi_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PROCESSING_GRP_R"
 SET failed = "T"
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
