CREATE PROGRAM bbd_chg_org_quota:dba
 RECORD reply(
   1 qual[*]
     2 org_quota_id = f8
     2 updt_cnt = i4
     2 active_ind = i2
     2 row_number = i4
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
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE y = i4 WITH protect, noconstant(0)
 DECLARE quota_id = f8 WITH protect, noconstant(0.0)
 DECLARE donorgroup_cd = f8 WITH protect, noconstant(0.0)
 DECLARE org_count = i4 WITH protect, noconstant(0)
 DECLARE quota_count = i4 WITH protect, noconstant(size(request->qual,5))
 DECLARE cdf_meaning = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE code_set = i4 WITH protect, noconstant(0)
 DECLARE code_cnt = i4 WITH protect, noconstant(1)
 DECLARE stat = i4 WITH protect, noconstant(0)
 SET code_set = 278
 SET cdf_meaning = "DONORGROUP"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,donorgroup_cd)
 SELECT INTO "nl:"
  o.org_type_cd
  FROM org_type_reltn o
  WHERE (o.organization_id=request->organization_id)
   AND o.org_type_cd=donorgroup_cd
   AND o.active_ind=1
  DETAIL
   org_count = (org_count+ 1)
  WITH nocounter
 ;end select
 IF (org_count=0)
  INSERT  FROM org_type_reltn ot
   SET ot.organization_id = request->organization_id, ot.org_type_cd = donorgroup_cd, ot.updt_cnt = 0,
    ot.updt_dt_tm = cnvtdatetime(curdate,curtime3), ot.updt_id = reqinfo->updt_id, ot.updt_task =
    reqinfo->updt_task,
    ot.updt_applctx = reqinfo->updt_applctx, ot.active_ind = 1, ot.active_status_cd = reqdata->
    active_status_cd,
    ot.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ot.active_status_prsnl_id = reqinfo->
    updt_id, ot.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
    ot.end_effective_dt_tm = cnvtdatetime("01-dec-2100")
   WITH nocounter
  ;end insert
 ENDIF
 FOR (y = 1 TO quota_count)
   IF ((request->qual[y].add_row=1))
    SET new_org_quota_seq = 0.0
    SELECT INTO "nl:"
     seqn = seq(organization_seq,nextval)
     FROM dual
     DETAIL
      new_org_quota_seq = seqn, quota_id = new_org_quota_seq
     WITH format, nocounter
    ;end select
    INSERT  FROM bbd_org_quota q
     SET q.org_quota_id = quota_id, q.updt_cnt = 0, q.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      q.updt_id = reqinfo->updt_id, q.updt_task = reqinfo->updt_task, q.updt_applctx = reqinfo->
      updt_applctx,
      q.active_ind = 1, q.active_status_cd = reqdata->active_status_cd, q.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      q.active_status_prsnl_id = reqinfo->updt_id, q.beg_effective_dt_tm = cnvtdatetime(request->
       qual[y].beg_effective_dt_tm), q.end_effective_dt_tm = cnvtdatetime(request->qual[y].
       end_effective_dt_tm),
      q.quota = request->qual[y].quota, q.organization_id = request->organization_id
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].operationname = "insert"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "ORGANIZATION QUOTA"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORGANIZATION QUOTA insert"
     GO TO exit_script
    ELSE
     SET stat = alterlist(reply->qual,y)
     SET reply->qual[y].org_quota_id = quota_id
     SET reply->qual[y].row_number = request->qual[y].row_number
     SET reply->qual[y].updt_cnt = 0
     SET reply->qual[y].active_ind = 1
    ENDIF
   ELSEIF ((request->qual[y].active_ind=1))
    SELECT INTO "nl:"
     q.*
     FROM bbd_org_quota q
     WHERE (q.organization_id=request->organization_id)
      AND (q.updt_cnt=request->qual[y].updt_cnt)
      AND (q.org_quota_id=request->qual[y].org_quota_id)
      AND q.active_ind=1
     WITH counter, forupdate(q)
    ;end select
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].operationname = "lock"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "organization quota"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd_org_quota"
     GO TO exit_script
    ENDIF
    UPDATE  FROM bbd_org_quota q
     SET q.beg_effective_dt_tm = cnvtdatetime(request->qual[y].beg_effective_dt_tm), q
      .end_effective_dt_tm = cnvtdatetime(request->qual[y].end_effective_dt_tm), q.quota = request->
      qual[y].quota,
      q.updt_dt_tm = cnvtdatetime(curdate,curtime3), q.updt_id = reqinfo->updt_id, q.updt_cnt = (
      request->qual[y].updt_cnt+ 1),
      q.updt_task = reqinfo->updt_task, q.updt_applctx = reqinfo->updt_applctx
     WHERE (q.organization_id=request->organization_id)
      AND (q.updt_cnt=request->qual[y].updt_cnt)
      AND (q.org_quota_id=request->qual[y].org_quota_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].operationname = "update"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "organization quota"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd_org_quota"
     GO TO exit_script
    ELSE
     SET stat = alterlist(reply->qual,y)
     SET reply->qual[y].org_quota_id = request->qual[y].org_quota_id
     SET reply->qual[y].updt_cnt = (request->qual[y].updt_cnt+ 1)
     SET reply->qual[y].row_number = request->qual[y].row_number
     SET reply->qual[y].active_ind = request->qual[y].active_ind
    ENDIF
   ELSE
    SELECT INTO "nl:"
     q.*
     FROM bbd_org_quota q
     WHERE (q.organization_id=request->organization_id)
      AND (q.updt_cnt=request->qual[y].updt_cnt)
      AND (q.org_quota_id=request->qual[y].org_quota_id)
      AND q.active_ind=1
     WITH counter, forupdate(q)
    ;end select
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].operationname = "lock"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "organization quota"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd_org_quota"
     GO TO exit_script
    ENDIF
    UPDATE  FROM bbd_org_quota q
     SET q.updt_dt_tm = cnvtdatetime(curdate,curtime3), q.updt_id = reqinfo->updt_id, q.updt_task =
      reqinfo->updt_task,
      q.updt_applctx = reqinfo->updt_applctx, q.updt_cnt = (request->qual[y].updt_cnt+ 1), q
      .active_ind = 0,
      q.active_status_cd = reqdata->active_status_cd, q.active_status_dt_tm = cnvtdatetime(curdate,
       curtime3), q.active_status_prsnl_id = reqinfo->updt_id
     WHERE (q.organization_id=request->organization_id)
      AND (q.updt_cnt=request->qual[y].updt_cnt)
      AND (q.org_quota_id=request->qual[y].org_quota_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].operationname = "update"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "organization quota"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd_org_quota"
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (failed="T")
  ROLLBACK
  SET reply->status_data.status = "F"
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
END GO
