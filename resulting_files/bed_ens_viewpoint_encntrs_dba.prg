CREATE PROGRAM bed_ens_viewpoint_encntrs:dba
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
 DECLARE vp_cnt = i4 WITH noconstant(0)
 DECLARE mpage_cnt = i4 WITH noconstant(0)
 DECLARE encntr_cnt = i4 WITH noconstant(0)
 DECLARE reltn_cnt = i4 WITH noconstant(0)
 DECLARE encounter_cnt = i4 WITH noconstant(0)
 DECLARE reltn_id = f8 WITH noconstant(0.0)
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 RECORD temp_reltns(
   1 reltns[*]
     2 viewpoint_id = f8
     2 datamart_cat_id = f8
     2 reltn_id = f8
 )
 RECORD temp_encntrs(
   1 encntrs[*]
     2 reltn_id = f8
     2 encntr_type_cd = f8
 )
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 SET vp_cnt = size(request->viewpoints,5)
 FOR (j = 1 TO vp_cnt)
  SET mpage_cnt = size(request->viewpoints[j].mpages,5)
  FOR (i = 1 TO mpage_cnt)
    SET encntr_cnt = size(request->viewpoints[j].mpages[i].encntr_types,5)
    SET reltn_id = 0.0
    SELECT INTO "nl:"
     FROM mp_viewpoint_reltn m
     WHERE (m.mp_viewpoint_id=request->viewpoints[j].viewpoint_id)
      AND (m.br_datamart_category_id=request->viewpoints[j].mpages[i].datamart_cat_id)
     DETAIL
      reltn_id = m.mp_viewpoint_reltn_id
     WITH nocounter
    ;end select
    IF (reltn_id=0.0)
     SELECT INTO "nl:"
      z = seq(mpages_seq,nextval)
      FROM dual
      DETAIL
       reltn_id = cnvtreal(z)
      WITH nocounter
     ;end select
     SET reltn_cnt = (reltn_cnt+ 1)
     SET stat = alterlist(temp_reltns->reltns,reltn_cnt)
     SET temp_reltns->reltns[reltn_cnt].viewpoint_id = request->viewpoints[j].viewpoint_id
     SET temp_reltns->reltns[reltn_cnt].datamart_cat_id = request->viewpoints[j].mpages[i].
     datamart_cat_id
     SET temp_reltns->reltns[reltn_cnt].reltn_id = reltn_id
    ELSE
     DELETE  FROM mp_viewpoint_encntr mpve
      WHERE mpve.mp_viewpoint_reltn_id=reltn_id
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->status_data.subeventstatus[1].targetobjectname =
      "Error removing a records from mp_viewpoint_encntr table"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
    ENDIF
    FOR (k = 1 TO encntr_cnt)
      SET encounter_cnt = (encounter_cnt+ 1)
      SET stat = alterlist(temp_encntrs->encntrs,encounter_cnt)
      SET temp_encntrs->encntrs[encounter_cnt].reltn_id = reltn_id
      SET temp_encntrs->encntrs[encounter_cnt].encntr_type_cd = request->viewpoints[j].mpages[i].
      encntr_types[k].encntr_type_cd
    ENDFOR
  ENDFOR
 ENDFOR
 SET len = size(temp_reltns->reltns,5)
 IF (len > 0)
  INSERT  FROM mp_viewpoint_reltn vpr,
    (dummyt d  WITH seq = len)
   SET vpr.br_datamart_category_id = temp_reltns->reltns[d.seq].datamart_cat_id, vpr.mp_viewpoint_id
     = temp_reltns->reltns[d.seq].viewpoint_id, vpr.mp_viewpoint_reltn_id = temp_reltns->reltns[d.seq
    ].reltn_id,
    vpr.view_seq = 0, vpr.updt_dt_tm = cnvtdatetime(curdate,curtime3), vpr.updt_id = reqinfo->updt_id,
    vpr.updt_task = reqinfo->updt_task, vpr.updt_cnt = 0, vpr.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (vpr)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("Error inserting into mp_viewpoint_reltn table")
 ENDIF
 SET len = size(temp_encntrs->encntrs,5)
 IF (len > 0)
  INSERT  FROM mp_viewpoint_encntr vpe,
    (dummyt d  WITH seq = len)
   SET vpe.encntr_type_cd = temp_encntrs->encntrs[d.seq].encntr_type_cd, vpe.mp_viewpoint_encntr_id
     = seq(bedrock_seq,nextval), vpe.mp_viewpoint_reltn_id = temp_encntrs->encntrs[d.seq].reltn_id,
    vpe.updt_dt_tm = cnvtdatetime(curdate,curtime3), vpe.updt_id = reqinfo->updt_id, vpe.updt_task =
    reqinfo->updt_task,
    vpe.updt_cnt = 0, vpe.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (vpe)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("Error inserting into mp_viewpoint_encntr table")
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
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
