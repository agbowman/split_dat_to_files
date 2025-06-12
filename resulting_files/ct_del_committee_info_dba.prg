CREATE PROGRAM ct_del_committee_info:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = c1 WITH protect, noconstant("S")
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE bfound = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET last_mod = "003"
 SET mod_date = "April 03, 2007"
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 SELECT INTO "nl:"
  FROM prot_amd_committee_reltn pacr
  WHERE (pacr.committee_id=request->cmt_id)
   AND pacr.validate_ind=1
   AND pacr.active_ind=1
  DETAIL
   bfound = 1
  WITH nocounter
 ;end select
 IF (curqual=0
  AND bfound=1)
  CALL report_failure("SELECT","F","CT_DEL_COMMITTEE_INFO",
   "Error finding committee/amendment relationships.")
  GO TO exit_script
 ENDIF
 IF (bfound=0)
  SELECT INTO "nl:"
   FROM ct_milestones cm
   WHERE (cm.committee_id=request->cmt_id)
   DETAIL
    bfound = 1
   WITH nocounter
  ;end select
  IF (curqual=0
   AND bfound=1)
   CALL report_failure("SELECT","F","CT_DEL_COMMITTEE_INFO",
    "Error finding committee/activity relationships.")
   GO TO exit_script
  ENDIF
 ENDIF
 IF (bfound=0)
  SELECT INTO "nl:"
   FROM prot_amd_committee_reltn pacr
   WHERE (pacr.committee_id=request->cmt_id)
    AND pacr.active_ind=1
    AND pacr.validate_ind=0
   DETAIL
    CALL echo(pacr.committee_id)
   WITH nocounter, forupdate(pacr)
  ;end select
  IF (curqual > 0)
   UPDATE  FROM prot_amd_committee_reltn pacr
    SET pacr.active_ind = 0, pacr.updt_dt_tm = cnvtdatetime(curdate,curtime3), pacr.updt_id = reqinfo
     ->updt_id,
     pacr.updt_task = reqinfo->updt_task, pacr.updt_applctx = reqinfo->updt_applctx, pacr.updt_cnt =
     (pacr.updt_cnt+ 1)
    WHERE (pacr.committee_id=request->cmt_id)
     AND pacr.active_ind=1
     AND pacr.validate_ind=0
   ;end update
   IF (curqual < 0)
    CALL report_failure("SELECT","F","CT_DEL_COMMITTEE_INFO",
     "Error deleting amendment/committee relationships.")
    GO TO exit_script
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   FROM ct_type_committee_reltn ctr
   WHERE (ctr.committee_id=request->cmt_id)
   WITH nocounter, forupdate(ctr)
  ;end select
  IF (curqual > 0)
   UPDATE  FROM ct_type_committee_reltn ctr
    SET ctr.active_ind = 0, ctr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ctr.updt_id = reqinfo->
     updt_id,
     ctr.updt_task = reqinfo->updt_task, ctr.updt_applctx = reqinfo->updt_applctx, ctr.updt_cnt = (
     ctr.updt_cnt+ 1)
    WHERE (ctr.committee_id=request->cmt_id)
   ;end update
   IF (curqual < 0)
    CALL report_failure("SELECT","F","CT_DEL_COMMITTEE_INFO",
     "Error deleting type/committee relationships.")
    GO TO exit_script
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   FROM committee_member cm
   WHERE (cm.committee_id=request->cmt_id)
   WITH nocounter, forupdate(cm)
  ;end select
  IF (curqual > 0)
   UPDATE  FROM committee_member cm
    SET cm.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), cm.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), cm.updt_id = reqinfo->updt_id,
     cm.updt_task = reqinfo->updt_task, cm.updt_applctx = reqinfo->updt_applctx, cm.updt_cnt = (cm
     .updt_cnt+ 1)
    WHERE (cm.committee_id=request->cmt_id)
   ;end update
   IF (curqual < 0)
    CALL report_failure("SELECT","F","CT_DEL_COMMITTEE_INFO","Error deleting committee members.")
    GO TO exit_script
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   FROM committee cmt
   WHERE (cmt.committee_id=request->cmt_id)
   WITH nocounter, forupdate(cmt)
  ;end select
  IF (curqual > 0)
   UPDATE  FROM committee cmt
    SET cmt.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), cmt.updt_dt_tm = cnvtdatetime(
      curdate,curtime3), cmt.updt_id = reqinfo->updt_id,
     cmt.updt_task = reqinfo->updt_task, cmt.updt_applctx = reqinfo->updt_applctx, cmt.updt_cnt = (
     cmt.updt_cnt+ 1)
    WHERE (cmt.committee_id=request->cmt_id)
   ;end update
   IF (curqual=0)
    CALL report_failure("SELECT","F","CT_DEL_COMMITTEE_INFO","Error deleting committee.")
    GO TO exit_script
   ENDIF
  ENDIF
 ELSE
  CALL report_failure("SELECT","D","CT_DEL_COMMITTEE_INFO",
   "This committee is referenced in other places therefore this committee cannot be deleted.")
 ENDIF
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   SET failed = opstatus
   SET reply->status_data.subeventstatus[1].operationname = trim(opname)
   SET reply->status_data.subeventstatus[1].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[1].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (failed != "S")
  SET reply->status_data.status = failed
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
