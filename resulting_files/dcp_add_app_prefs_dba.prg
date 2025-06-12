CREATE PROGRAM dcp_add_app_prefs:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 SET reply->status_data.status = "F"
 DECLARE failed = c1 WITH noconstant("F")
 DECLARE ap_id = f8 WITH noconstant(0.0)
 DECLARE nv_cnt = i4 WITH noconstant(size(request->nv,5))
 DECLARE count1 = i4 WITH noconstant(0)
 IF ((request->prsnl_id > 0))
  SET request->position_cd = 0
 ENDIF
 SELECT INTO "nl:"
  FROM app_prefs a
  WHERE (a.application_number=request->application_number)
   AND (a.position_cd=request->position_cd)
   AND (a.prsnl_id=request->prsnl_id)
   AND a.active_ind=1
  ORDER BY a.prsnl_id DESC, a.position_cd DESC
  HEAD REPORT
   ap_id = a.app_prefs_id
  DETAIL
   count1 = (count1+ 1)
  WITH nocounter
 ;end select
 IF (count1 > 0)
  CALL echo(build("yes there is one  ",ap_id))
  GO TO name_value
 ENDIF
 SELECT INTO "nl:"
  j = seq(carenet_seq,nextval)
  FROM dual
  DETAIL
   ap_id = cnvtreal(j)
  WITH format, nocounter
 ;end select
 INSERT  FROM app_prefs ap
  SET ap.app_prefs_id = ap_id, ap.application_number = request->application_number, ap.position_cd =
   request->position_cd,
   ap.prsnl_id = request->prsnl_id, ap.active_ind = 1, ap.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   ap.updt_id = reqinfo->updt_id, ap.updt_task = reqinfo->updt_task, ap.updt_applctx = reqinfo->
   updt_applctx,
   ap.updt_cnt = 0
  WITH nocounter
 ;end insert
 INSERT  FROM name_value_prefs nvp,
   (dummyt d1  WITH seq = value(nv_cnt))
  SET nvp.seq = 1, nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name =
   "APP_PREFS",
   nvp.parent_entity_id = ap_id, nvp.pvc_name = request->nv[d1.seq].pvc_name, nvp.pvc_value = request
   ->nv[d1.seq].pvc_value,
   nvp.merge_id = request->nv[d1.seq].merge_id, nvp.merge_name = request->nv[d1.seq].merge_name, nvp
   .sequence = request->nv[d1.seq].sequence,
   nvp.active_ind = 1, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->
   updt_id,
   nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
  PLAN (d1)
   JOIN (nvp)
  WITH nocounter
 ;end insert
 GO TO exit_script
#name_value
 SET count1 = 0
 FOR (x = 1 TO nv_cnt)
  SELECT INTO "nl:"
   FROM name_value_prefs n
   WHERE n.parent_entity_id=ap_id
    AND trim(cnvtupper(n.pvc_name))=trim(cnvtupper(request->nv[x].pvc_name))
    AND (n.sequence=request->nv[x].sequence)
   DETAIL
    ap_id = n.parent_entity_id
   WITH nocounter
  ;end select
  IF (curqual > 0)
   UPDATE  FROM name_value_prefs nvp
    SET nvp.pvc_value = request->nv[x].pvc_value, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     nvp.updt_id = reqinfo->updt_id,
     nvp.sequence = request->nv[x].sequence, nvp.merge_id = request->nv[x].merge_id, nvp.merge_name
      = request->nv[x].merge_name
    WHERE nvp.parent_entity_id=ap_id
     AND nvp.parent_entity_name="APP_PREFS"
     AND (nvp.pvc_name=request->nv[x].pvc_name)
     AND (nvp.sequence=request->nv[x].sequence)
    WITH nocounter
   ;end update
  ELSE
   INSERT  FROM name_value_prefs nvp
    SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name = "APP_PREFS", nvp
     .parent_entity_id = ap_id,
     nvp.pvc_name = request->nv[x].pvc_name, nvp.pvc_value = request->nv[x].pvc_value, nvp.merge_id
      = request->nv[x].merge_id,
     nvp.merge_name = request->nv[x].merge_name, nvp.sequence = request->nv[x].sequence, nvp
     .active_ind = 1,
     nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp.updt_task
      = reqinfo->updt_task,
     nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
    WITH nocounter
   ;end insert
  ENDIF
 ENDFOR
#exit_script
 IF (failed="F")
  CALL echo("COMMIT IND = 1")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
 SET modify = nopredeclare
END GO
