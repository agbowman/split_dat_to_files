CREATE PROGRAM bed_ens_prefs_by_pos:dba
 RECORD request(
   1 applications[*]
     2 application_number = i4
     2 positions[*]
       3 code_value = f8
       3 is_global_ind = i2
       3 preferences[*]
         4 name_value_prefs_id = f8
         4 pvc_value = vc
 )
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET cpy_request
 RECORD cpy_request(
   1 application = i4
   1 positions[*]
     2 position_code_value = f8
 )
 FREE SET cpy_reply
 RECORD cpy_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET 4411191_nvp_ins
 RECORD 4411191_nvp_ins(
   1 4411191_nvp_ins[*]
     2 pvc_name = vc
     2 pvc_value = vc
     2 sequence = i4
     2 merge_id = f8
     2 merge_name = vc
     2 pos_code = f8
     2 nvp_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 global_ind = i2
 )
 DECLARE logerror(message=vc,details=vc) = null
 DECLARE cpy_cnt = i4 WITH protect
 DECLARE nvp_cnt = i4 WITH protect
 DECLARE error_flag = vc WITH protect
 DECLARE app_cnt = i4 WITH protect
 DECLARE pos_cnt = i4 WITH protect
 DECLARE pref_cnt = i4 WITH protect
 DECLARE req_cnt = i4 WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 SET app_cnt = size(request->applications,5)
 IF (app_cnt=0)
  CALL logerror("No Applications","")
 ENDIF
 FOR (a = 1 TO app_cnt)
   SET pos_cnt = size(request->applications[a].positions,5)
   SET cpy_request->application = request->applications[a].application_number
   IF (pos_cnt=0)
    CALL logerror("No Positions",build("No positions at index:",a))
   ENDIF
   FOR (p = 1 TO pos_cnt)
     IF ((request->applications[a].positions[p].is_global_ind=1))
      SET cpy_cnt = (cpy_cnt+ 1)
      SET stat = alterlist(cpy_request->positions,cpy_cnt)
      SET cpy_request->positions[cpy_cnt].position_code_value = request->applications[a].positions[p]
      .code_value
     ENDIF
     SET pref_cnt = size(request->applications[a].positions[p].preferences,5)
     IF (pref_cnt=0)
      CALL logerror("No Preferences",build("No preferences at app index:",a,"position index:",p))
     ENDIF
     FOR (n = 1 TO pref_cnt)
       SET nvp_cnt = (nvp_cnt+ 1)
       SET stat = alterlist(4411191_nvp_ins->4411191_nvp_ins,nvp_cnt)
       SET 4411191_nvp_ins->4411191_nvp_ins[nvp_cnt].nvp_id = request->applications[a].positions[p].
       preferences[n].name_value_prefs_id
       SET 4411191_nvp_ins->4411191_nvp_ins[nvp_cnt].pvc_value = request->applications[a].positions[p
       ].preferences[n].pvc_value
       SET 4411191_nvp_ins->4411191_nvp_ins[nvp_cnt].pos_code = request->applications[a].positions[p]
       .code_value
       SET 4411191_nvp_ins->4411191_nvp_ins[nvp_cnt].global_ind = request->applications[a].positions[
       p].is_global_ind
     ENDFOR
   ENDFOR
 ENDFOR
 IF (nvp_cnt=0)
  CALL logerror("No Prefs","")
 ENDIF
 IF (cpy_cnt > 0)
  EXECUTE bed_cpy_app_to_pos_prefs  WITH replace("REQUEST",cpy_request), replace("REPLY",cpy_reply)
  IF ((cpy_reply->status_data.status="F"))
   CALL logerror("Copy Failed",cpy_reply->status_data.subeventstatus[1].targetobjectvalue)
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(nvp_cnt)),
   name_value_prefs n
  PLAN (d)
   JOIN (n
   WHERE (n.name_value_prefs_id=4411191_nvp_ins->4411191_nvp_ins[d.seq].nvp_id))
  ORDER BY d.seq
  HEAD d.seq
   4411191_nvp_ins->4411191_nvp_ins[d.seq].merge_id = n.merge_id, 4411191_nvp_ins->4411191_nvp_ins[d
   .seq].merge_name = n.merge_name, 4411191_nvp_ins->4411191_nvp_ins[d.seq].pvc_name = n.pvc_name,
   4411191_nvp_ins->4411191_nvp_ins[d.seq].sequence = n.sequence, 4411191_nvp_ins->4411191_nvp_ins[d
   .seq].parent_entity_id = n.parent_entity_id, 4411191_nvp_ins->4411191_nvp_ins[d.seq].
   parent_entity_name = n.parent_entity_name
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(nvp_cnt)),
   view_prefs dp,
   view_prefs dp2,
   name_value_prefs n
  PLAN (d
   WHERE (4411191_nvp_ins->4411191_nvp_ins[d.seq].global_ind=1)
    AND (4411191_nvp_ins->4411191_nvp_ins[d.seq].parent_entity_name="VIEW_PREFS"))
   JOIN (dp
   WHERE (dp.view_prefs_id=4411191_nvp_ins->4411191_nvp_ins[d.seq].parent_entity_id))
   JOIN (dp2
   WHERE dp2.view_name=dp.view_name
    AND dp2.view_seq=dp.view_seq
    AND dp2.frame_type=dp.frame_type
    AND dp2.application_number=dp.application_number
    AND (dp2.position_cd=4411191_nvp_ins->4411191_nvp_ins[d.seq].pos_code)
    AND dp2.prsnl_id=0)
   JOIN (n
   WHERE n.parent_entity_id=outerjoin(dp2.view_prefs_id)
    AND n.parent_entity_name=outerjoin("VIEW_PREFS")
    AND trim(n.pvc_name)=outerjoin(trim(4411191_nvp_ins->4411191_nvp_ins[d.seq].pvc_name))
    AND n.active_ind=outerjoin(1))
  ORDER BY d.seq, n.name_value_prefs_id
  HEAD d.seq
   4411191_nvp_ins->4411191_nvp_ins[d.seq].parent_entity_id = dp2.view_prefs_id, 4411191_nvp_ins->
   4411191_nvp_ins[d.seq].nvp_id = n.name_value_prefs_id, 4411191_nvp_ins->4411191_nvp_ins[d.seq].
   global_ind = 0
  WITH nocounter
 ;end select
 FOR (n = 1 TO nvp_cnt)
   IF ((4411191_nvp_ins->4411191_nvp_ins[n].global_ind=1))
    CALL echorecord(4411176_nvp_ins)
    CALL logerror("No Target Found",build("Pos: ",4411191_nvp_ins->4411191_nvp_ins[n].pos_code,
      " ViewId: ",4411191_nvp_ins->4411191_nvp_ins[n].view_id))
   ENDIF
 ENDFOR
 SET ierrcode = 0
 DELETE  FROM name_value_prefs n,
   (dummyt d  WITH seq = value(nvp_cnt))
  SET n.seq = 1
  PLAN (d)
   JOIN (n
   WHERE (n.name_value_prefs_id=4411191_nvp_ins->4411191_nvp_ins[d.seq].nvp_id))
  WITH nocounter
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  CALL logerror("Error on nvp delete",serrmsg)
 ENDIF
 SET ierrcode = 0
 INSERT  FROM name_value_prefs n,
   (dummyt d  WITH seq = value(nvp_cnt))
  SET n.name_value_prefs_id = seq(carenet_seq,nextval), n.pvc_value = 4411191_nvp_ins->
   4411191_nvp_ins[d.seq].pvc_value, n.merge_id = 4411191_nvp_ins->4411191_nvp_ins[d.seq].merge_id,
   n.merge_name = 4411191_nvp_ins->4411191_nvp_ins[d.seq].merge_name, n.sequence = 4411191_nvp_ins->
   4411191_nvp_ins[d.seq].sequence, n.active_ind = 1,
   n.parent_entity_id = 4411191_nvp_ins->4411191_nvp_ins[d.seq].parent_entity_id, n
   .parent_entity_name = 4411191_nvp_ins->4411191_nvp_ins[d.seq].parent_entity_name, n.pvc_name =
   4411191_nvp_ins->4411191_nvp_ins[d.seq].pvc_name,
   n.updt_applctx = reqinfo->updt_applctx, n.updt_cnt = 0, n.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo->updt_task
  PLAN (d)
   JOIN (n)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  CALL logerror("Error on nvp insert",serrmsg)
 ENDIF
 SUBROUTINE logerror(message,details)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = message
   SET reply->status_data.subeventstatus[1].targetobjectvalue = details
   GO TO exit_script
 END ;Subroutine
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
