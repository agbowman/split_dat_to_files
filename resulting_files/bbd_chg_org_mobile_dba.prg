CREATE PROGRAM bbd_chg_org_mobile:dba
 RECORD reply(
   1 qual[*]
     2 mobile_pref_id = f8
     2 updt_cnt = i4
     2 active_ind = i2
     2 row_number = i2
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
 DECLARE donorgroup_cd = f8 WITH protect, noconstant(0.0)
 DECLARE org_count = i4 WITH protect, noconstant(0)
 DECLARE mobile_count = i4 WITH protect, noconstant(size(request->qual,5))
 DECLARE cdf_meaning = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE code_set = i4 WITH protect, noconstant(0)
 DECLARE code_cnt = i4 WITH protect, noconstant(1)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE new_org_mobile_seq = f8 WITH protect, noconstant(0.0)
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
 FOR (y = 1 TO mobile_count)
   IF ((request->qual[y].add_row=1))
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      new_org_mobile_seq = seqn
     WITH format, nocounter
    ;end select
    INSERT  FROM bbd_mobile_pref m
     SET m.mobile_pref_id = new_org_mobile_seq, m.updt_cnt = 0, m.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      m.updt_id = reqinfo->updt_id, m.updt_task = reqinfo->updt_task, m.updt_applctx = reqinfo->
      updt_applctx,
      m.active_ind = 1, m.active_status_cd = reqdata->active_status_cd, m.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      m.active_status_prsnl_id = reqinfo->updt_id, m.beg_effective_dt_tm = cnvtdatetime(request->
       qual[y].beg_effective_dt_tm), m.end_effective_dt_tm = cnvtdatetime(request->qual[y].
       end_effective_dt_tm),
      m.month_cd = request->qual[y].month_cd, m.week = request->qual[y].week, m.sunday_ind = request
      ->qual[y].sunday_ind,
      m.monday_ind = request->qual[y].monday_ind, m.tuesday_ind = request->qual[y].tuesday_ind, m
      .wednesday_ind = request->qual[y].wednesday_ind,
      m.thursday_ind = request->qual[y].thursday_ind, m.friday_ind = request->qual[y].friday_ind, m
      .saturday_ind = request->qual[y].saturday_ind,
      m.length_in_hours = request->qual[y].length_in_hours, m.organization_id = request->
      organization_id
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].operationname = "insert"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "ORGANIZATION MOBILE"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORGANIZATION MOBILE INSERT"
     GO TO exit_script
    ELSE
     SET stat = alterlist(reply->qual,y)
     SET reply->qual[y].mobile_pref_id = new_org_mobile_seq
     SET reply->qual[y].row_number = request->qual[y].row_number
     SET reply->qual[y].updt_cnt = 0
     SET reply->qual[y].active_ind = 1
    ENDIF
   ELSEIF ((request->qual[y].active_ind=1))
    SELECT INTO "nl:"
     m.*
     FROM bbd_mobile_pref m
     WHERE (m.organization_id=request->organization_id)
      AND (m.updt_cnt=request->qual[y].updt_cnt)
      AND (m.mobile_pref_id=request->qual[y].mobile_pref_id)
      AND m.active_ind=1
     WITH counter, forupdate(q)
    ;end select
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].operationname = "lock"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "organization mobile preference"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd_mobile_pref"
     GO TO exit_script
    ENDIF
    UPDATE  FROM bbd_mobile_pref m
     SET m.week = request->qual[y].week, m.sunday_ind = request->qual[y].sunday_ind, m.monday_ind =
      request->qual[y].monday_ind,
      m.tuesday_ind = request->qual[y].tuesday_ind, m.wednesday_ind = request->qual[y].wednesday_ind,
      m.thursday_ind = request->qual[y].thursday_ind,
      m.friday_ind = request->qual[y].friday_ind, m.saturday_ind = request->qual[y].saturday_ind, m
      .length_in_hours = request->qual[y].length_in_hours,
      m.updt_dt_tm = cnvtdatetime(curdate,curtime3), m.updt_id = reqinfo->updt_id, m.updt_cnt = (
      request->qual[y].updt_cnt+ 1),
      m.updt_task = reqinfo->updt_task, m.updt_applctx = reqinfo->updt_applctx
     WHERE (m.organization_id=request->organization_id)
      AND (m.updt_cnt=request->qual[y].updt_cnt)
      AND (m.mobile_pref_id=request->qual[y].mobile_pref_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].operationname = "update"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "organization mobile preference"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd_mobile_pref"
     GO TO exit_script
    ELSE
     SET stat = alterlist(reply->qual,y)
     SET reply->qual[y].mobile_pref_id = request->qual[y].mobile_pref_id
     SET reply->qual[y].updt_cnt = (request->qual[y].updt_cnt+ 1)
     SET reply->qual[y].row_number = request->qual[y].row_number
     SET reply->qual[y].active_ind = request->qual[y].active_ind
    ENDIF
   ELSE
    SELECT INTO "nl:"
     m.*
     FROM bbd_mobile_pref m
     WHERE (m.organization_id=request->organization_id)
      AND (m.updt_cnt=request->qual[y].updt_cnt)
      AND (m.mobile_pref_id=request->qual[y].mobile_pref_id)
      AND m.active_ind=1
     WITH counter, forupdate(q)
    ;end select
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].operationname = "lock"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "organization mobile preference"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd_mobile_pref"
     GO TO exit_script
    ENDIF
    UPDATE  FROM bbd_mobile_pref m
     SET m.updt_dt_tm = cnvtdatetime(curdate,curtime3), m.updt_id = reqinfo->updt_id, m.updt_task =
      reqinfo->updt_task,
      m.updt_applctx = reqinfo->updt_applctx, m.updt_cnt = (request->qual[y].updt_cnt+ 1), m
      .active_ind = 0,
      m.active_status_cd = reqdata->active_status_cd, m.active_status_dt_tm = cnvtdatetime(curdate,
       curtime3), m.active_status_prsnl_id = reqinfo->updt_id
     WHERE (m.organization_id=request->organization_id)
      AND (m.updt_cnt=request->qual[y].updt_cnt)
      AND (m.mobile_pref_id=request->qual[y].mobile_pref_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].operationname = "update"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "organization mobile preference"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd_mobile_pref"
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
