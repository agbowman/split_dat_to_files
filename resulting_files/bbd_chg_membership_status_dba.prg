CREATE PROGRAM bbd_chg_membership_status:dba
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
 SET failed = "F"
 SET y = 0
 SET donor_org_cd = 0.0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=338
   AND c.cdf_meaning="DONOR"
   AND c.active_ind=1
  DETAIL
   donor_org_cd = c.code_value
  WITH nocounter
 ;end select
 IF ((request->active_ind=1))
  SELECT INTO "nl:"
   po.*
   FROM person_org_reltn po
   WHERE (po.organization_id=request->organization_id)
    AND po.person_org_reltn_cd=donor_org_cd
    AND (po.person_id=request->person_id)
    AND (po.active_ind=request->active_ind)
   WITH counter, forupdate(po)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_membership_status"
   SET reply->status_data.subeventstatus[1].operationname = "lock"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "person organization relation"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "person_org_reltn"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  UPDATE  FROM person_org_reltn po
   SET po.updt_dt_tm = cnvtdatetime(curdate,curtime3), po.updt_id = reqinfo->updt_id, po.updt_task =
    reqinfo->updt_task,
    po.updt_applctx = reqinfo->updt_applctx, po.updt_cnt = (po.updt_cnt+ 1), po.active_ind = 0,
    po.active_status_cd = reqdata->inactive_status_cd, po.active_status_dt_tm = cnvtdatetime(curdate,
     curtime3), po.active_status_prsnl_id = reqinfo->updt_id
   WHERE (po.organization_id=request->organization_id)
    AND (po.person_id=request->person_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_membership_status"
   SET reply->status_data.subeventstatus[1].operationname = "update"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "person organization relation"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "person_org_reltn"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ELSE
  SELECT INTO "nl:"
   po.*
   FROM person_org_reltn po
   WHERE (po.organization_id=request->organization_id)
    AND po.person_org_reltn_cd=donor_org_cd
    AND (po.person_id=request->person_id)
    AND po.active_ind=0
   WITH counter, forupdate(po)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_membership_status"
   SET reply->status_data.subeventstatus[1].operationname = "lock"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "person organization relation"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "person_org_reltn"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
  UPDATE  FROM person_org_reltn po
   SET po.updt_dt_tm = cnvtdatetime(curdate,curtime3), po.updt_id = reqinfo->updt_id, po.updt_task =
    reqinfo->updt_task,
    po.updt_applctx = reqinfo->updt_applctx, po.updt_cnt = (po.updt_cnt+ 1), po.active_ind = 1,
    po.active_status_cd = reqdata->active_status_cd, po.active_status_dt_tm = cnvtdatetime(curdate,
     curtime3), po.active_status_prsnl_id = reqinfo->updt_id
   WHERE (po.organization_id=request->organization_id)
    AND (po.person_id=request->person_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_membership_status"
   SET reply->status_data.subeventstatus[1].operationname = "update"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "person organization relation"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "person_org_reltn"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  ROLLBACK
  SET reply->status_data.status = "F"
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
END GO
