CREATE PROGRAM cps_get_orgs_by_user:dba
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 prsnl_org_ind = i2
    1 qual[*]
      2 organization_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD temp_data(
   1 qual[*]
     2 organization_id = f8
 )
 SET reply->status_data.status = "F"
 DECLARE network_var = f8 WITH constant(uar_get_code_by("MEANING",28881,"NETWORK")), protect
 DECLARE orgindex = i4 WITH protect, noconstant(0)
 DECLARE org_count = i4 WITH protect, noconstant(0)
 DECLARE reply_count = i4 WITH protect, noconstant(0)
 DECLARE ierrcode = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = vc WITH protect
 SET dminfo = validate(ccldminfo->mode,0)
 IF (dminfo=1)
  IF ((ccldminfo->sec_org_reltn=1))
   SET bprsnlorgsecurity = true
   SET reply->prsnl_org_ind = 1
   SET stat = alterlist(temp_data->qual,1)
   SELECT INTO "nl:"
    FROM prsnl_org_reltn por
    PLAN (por
     WHERE (por.person_id=request->prsnl_id)
      AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND por.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND por.active_ind=1)
    HEAD REPORT
     org_count = 0
    DETAIL
     org_count = (org_count+ 1)
     IF (org_count > size(temp_data->qual,5))
      stat = alterlist(temp_data->qual,(org_count+ 10))
     ENDIF
     temp_data->qual[org_count].organization_id = por.organization_id
    FOOT REPORT
     stat = alterlist(temp_data->qual,org_count)
    WITH nocounter
   ;end select
   IF (curqual < 1)
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET reply->status_data.subeventstatus[1].operationname = "SELECT"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "cps_get_orgs_by_user"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     SET failed = true
     GO TO exit_script
    ENDIF
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
   SELECT INTO "nl:"
    FROM org_set_prsnl_r ospr,
     org_set_type_r ostr,
     org_set os,
     org_set_org_r osor
    PLAN (ospr
     WHERE (ospr.prsnl_id=request->prsnl_id)
      AND ospr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ospr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND ospr.active_ind=1)
     JOIN (ostr
     WHERE ostr.org_set_id=ospr.org_set_id
      AND ostr.org_set_type_cd=network_var
      AND ostr.active_ind=1
      AND ostr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ostr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (os
     WHERE os.org_set_id=ospr.org_set_id)
     JOIN (osor
     WHERE osor.org_set_id=os.org_set_id
      AND osor.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND osor.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND osor.active_ind=1)
    DETAIL
     org_count = (org_count+ 1)
     IF (org_count > size(temp_data->qual,5))
      stat = alterlist(temp_data->qual,(org_count+ 10))
     ENDIF
     temp_data->qual[org_count].organization_id = osor.organization_id
    FOOT REPORT
     stat = alterlist(temp_data->qual,org_count)
    WITH nocounter
   ;end select
   IF (curqual < 1)
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET reply->status_data.subeventstatus[1].operationname = "SELECT"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "cps_get_orgs_by_user"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     SET failed = true
     GO TO exit_script
    ENDIF
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
   SELECT INTO "nl:"
    FROM organization o
    PLAN (o
     WHERE expand(orgindex,1,org_count,o.organization_id,temp_data->qual[orgindex].organization_id)
      AND o.organization_id > 0)
    ORDER BY o.organization_id
    HEAD REPORT
     reply_count = 0
    HEAD o.organization_id
     reply_count = (reply_count+ 1)
     IF (reply_count > size(reply->qual,5))
      stat = alterlist(reply->qual,(reply_count+ 10))
     ENDIF
     reply->qual[reply_count].organization_id = o.organization_id
    FOOT REPORT
     stat = alterlist(reply->qual,reply_count)
    WITH nocounter
   ;end select
   IF (curqual < 1)
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET reply->status_data.subeventstatus[1].operationname = "SELECT"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "cps_get_orgs_by_user"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     SET failed = true
     GO TO exit_script
    ELSE
     SET reply->status_data.status = "Z"
     SET failed = true
     GO TO exit_script
    ENDIF
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
  ELSE
   SET reply->prsnl_org_ind = 0
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
#exit_script
 SET script_ver = "001 1/12/11 SH018059"
END GO
