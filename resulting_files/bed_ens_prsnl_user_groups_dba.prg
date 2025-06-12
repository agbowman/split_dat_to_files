CREATE PROGRAM bed_ens_prsnl_user_groups:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 RECORD req_reltn(
   1 reltn[*]
     2 person_id = f8
     2 prsnl_group_id = f8
     2 cur_reltn_found_ind = i2
 ) WITH protect
 RECORD cur_reltn(
   1 reltn[*]
     2 prsnl_group_reltn_id = f8
     2 person_id = f8
     2 prsnl_group_id = f8
     2 req_reltn_found_ind = i2
 ) WITH protect
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
 DECLARE auditevent(auditeventflag=i2,mode=i2,participantid=f8,participantname=vc) = i2
 DECLARE logauditeventaddedusers(dummyvar=i2) = i2
 DECLARE logauditeventremovedusers(dummyvar=i2) = i2
 DECLARE batch_size = i4 WITH protect, constant(100)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE req_prsnl_cnt = i4 WITH protect, constant(size(request->personnel,5))
 DECLARE req_reltn_cnt = i4 WITH protect, noconstant(0)
 DECLARE cur_reltn_cnt = i4 WITH protect, noconstant(0)
 DECLARE audit_event_modify_user_group = i2 WITH protect, constant(2)
 DECLARE audit_event_user_to_user_group = i2 WITH protect, constant(3)
 IF (req_prsnl_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt rp  WITH seq = req_prsnl_cnt),
    (dummyt rg  WITH seq = 1),
    dummyt d,
    prsnl_group_reltn pgr
   PLAN (rp
    WHERE maxrec(rg,size(request->personnel[rp.seq].user_groups,5)))
    JOIN (rg)
    JOIN (d)
    JOIN (pgr
    WHERE (pgr.person_id=request->personnel[rp.seq].id)
     AND (pgr.prsnl_group_id=request->personnel[rp.seq].user_groups[rg.seq].id)
     AND pgr.active_ind=true)
   HEAD REPORT
    req_reltn_cnt = 0, cnt = batch_size
   DETAIL
    IF (cnt=batch_size)
     stat = alterlist(req_reltn->reltn,(req_reltn_cnt+ batch_size)), cnt = 0
    ENDIF
    cnt = (cnt+ 1), req_reltn_cnt = (req_reltn_cnt+ 1), req_reltn->reltn[req_reltn_cnt].person_id =
    request->personnel[rp.seq].id,
    req_reltn->reltn[req_reltn_cnt].prsnl_group_id = request->personnel[rp.seq].user_groups[rg.seq].
    id
    IF (pgr.prsnl_group_reltn_id > 0)
     req_reltn->reltn[req_reltn_cnt].cur_reltn_found_ind = true
    ENDIF
   FOOT REPORT
    stat = alterlist(req_reltn->reltn,req_reltn_cnt)
   WITH nocounter, outerjoin = d
  ;end select
  CALL bederrorcheck("req_reltn")
  SELECT INTO "nl:"
   FROM (dummyt rp  WITH seq = req_prsnl_cnt),
    prsnl_group_reltn pgr
   PLAN (rp)
    JOIN (pgr
    WHERE (pgr.person_id=request->personnel[rp.seq].id)
     AND pgr.active_ind=true)
   HEAD REPORT
    cur_reltn_cnt = 0, cnt = batch_size
   DETAIL
    IF (cnt=batch_size)
     stat = alterlist(cur_reltn->reltn,(cur_reltn_cnt+ batch_size)), cnt = 0
    ENDIF
    cnt = (cnt+ 1), cur_reltn_cnt = (cur_reltn_cnt+ 1), cur_reltn->reltn[cur_reltn_cnt].
    prsnl_group_reltn_id = pgr.prsnl_group_reltn_id,
    cur_reltn->reltn[cur_reltn_cnt].person_id = pgr.person_id, cur_reltn->reltn[cur_reltn_cnt].
    prsnl_group_id = pgr.prsnl_group_id, num = 0
    IF (locateval(num,1,size(request->personnel[rp.seq].user_groups,5),pgr.prsnl_group_id,request->
     personnel[rp.seq].user_groups[num].id))
     cur_reltn->reltn[cur_reltn_cnt].req_reltn_found_ind = true
    ENDIF
   FOOT REPORT
    stat = alterlist(cur_reltn->reltn,cur_reltn_cnt)
   WITH nocounter
  ;end select
  CALL bederrorcheck("cur_reltn")
  IF (req_reltn_cnt > 0)
   INSERT  FROM prsnl_group_reltn pgr,
     (dummyt rr  WITH seq = req_reltn_cnt)
    SET pgr.prsnl_group_reltn_id = seq(prsnl_seq,nextval), pgr.person_id = req_reltn->reltn[rr.seq].
     person_id, pgr.prsnl_group_id = req_reltn->reltn[rr.seq].prsnl_group_id,
     pgr.updt_dt_tm = cnvtdatetime(curdate,curtime3), pgr.updt_id = reqinfo->updt_id, pgr.updt_task
      = reqinfo->updt_task,
     pgr.updt_applctx = reqinfo->updt_applctx, pgr.active_ind = 1, pgr.active_status_cd = reqdata->
     active_status_cd,
     pgr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pgr.active_status_prsnl_id = reqinfo->
     updt_id, pgr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     pgr.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), pgr.data_status_cd = reqdata
     ->data_status_cd, pgr.data_status_dt_tm = cnvtdatetime(curdate,curtime3),
     pgr.data_status_prsnl_id = reqinfo->updt_id, pgr.contributor_system_cd = reqdata->
     contributor_system_cd
    PLAN (rr
     WHERE (req_reltn->reltn[rr.seq].cur_reltn_found_ind=false))
     JOIN (pgr)
    WITH nocounter
   ;end insert
   CALL bederrorcheck("ins reltn")
   CALL logauditeventaddedusers(0)
  ENDIF
  IF (cur_reltn_cnt > 0)
   UPDATE  FROM prsnl_group_reltn pgr,
     (dummyt cr  WITH seq = cur_reltn_cnt)
    SET pgr.active_ind = 0, pgr.active_status_cd = reqdata->inactive_status_cd, pgr
     .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
     pgr.active_status_prsnl_id = reqinfo->updt_id, pgr.end_effective_dt_tm = cnvtdatetime(curdate,
      curtime3), pgr.data_status_cd = reqdata->data_status_cd,
     pgr.data_status_dt_tm = cnvtdatetime(curdate,curtime3), pgr.data_status_prsnl_id = reqinfo->
     updt_id, pgr.updt_cnt = (pgr.updt_cnt+ 1),
     pgr.updt_dt_tm = cnvtdatetime(curdate,curtime3), pgr.updt_id = reqinfo->updt_id, pgr.updt_task
      = reqinfo->updt_task,
     pgr.updt_applctx = reqinfo->updt_applctx
    PLAN (cr)
     JOIN (pgr
     WHERE (pgr.prsnl_group_reltn_id=cur_reltn->reltn[cr.seq].prsnl_group_reltn_id)
      AND (cur_reltn->reltn[cr.seq].req_reltn_found_ind=false))
    WITH nocounter
   ;end update
   CALL bederrorcheck("upd reltn")
   CALL logauditeventremovedusers(0)
  ENDIF
 ENDIF
 SUBROUTINE logauditeventaddedusers(dummyvar)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE auditmode = i2 WITH protect, noconstant(0)
   FREE RECORD adduser
   RECORD adduser(
     1 list[*]
       2 id = f8
       2 name = vc
       2 prsnl_group_id = f8
       2 group_name = vc
   )
   SET stat = alterlist(adduser->list,req_reltn_cnt)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = req_reltn_cnt),
     prsnl p
    PLAN (d
     WHERE (req_reltn->reltn[d.seq].cur_reltn_found_ind=0))
     JOIN (p
     WHERE (p.person_id=req_reltn->reltn[d.seq].person_id))
    DETAIL
     cnt = (cnt+ 1), adduser->list[cnt].id = p.person_id, adduser->list[cnt].name = build2("Added: ",
      trim(p.name_full_formatted,3)),
     adduser->list[cnt].prsnl_group_id = req_reltn->reltn[d.seq].prsnl_group_id
    WITH nocounter
   ;end select
   IF (cnt > 0)
    SET stat = alterlist(adduser->list,cnt)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = cnt),
      prsnl_group pg,
      code_value cv
     PLAN (d)
      JOIN (pg
      WHERE (pg.prsnl_group_id=adduser->list[d.seq].prsnl_group_id))
      JOIN (cv
      WHERE cv.code_value=outerjoin(pg.prsnl_group_type_cd))
     DETAIL
      adduser->list[d.seq].group_name = trim(cv.display,3)
     WITH nocounter
    ;end select
    FOR (k = 1 TO cnt)
     CALL auditevent(audit_event_user_to_user_group,0,adduser->list[k].id,adduser->list[k].name)
     CALL auditevent(audit_event_modify_user_group,0,adduser->list[k].prsnl_group_id,adduser->list[k]
      .group_name)
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE logauditeventremovedusers(dummyvar)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   FREE RECORD remuser
   RECORD remuser(
     1 list[*]
       2 id = f8
       2 name = vc
       2 prsnl_group_id = f8
       2 group_name = vc
   )
   SET stat = alterlist(remuser->list,cur_reltn_cnt)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = cur_reltn_cnt),
     prsnl p
    PLAN (d
     WHERE (cur_reltn->reltn[d.seq].req_reltn_found_ind=false))
     JOIN (p
     WHERE (p.person_id=cur_reltn->reltn[d.seq].person_id))
    DETAIL
     cnt = (cnt+ 1), remuser->list[cnt].id = p.person_id, remuser->list[cnt].name = build2(
      "Removed: ",trim(p.name_full_formatted,3)),
     remuser->list[cnt].prsnl_group_id = cur_reltn->reltn[d.seq].prsnl_group_id
    WITH nocounter
   ;end select
   IF (cnt > 0)
    SET stat = alterlist(remuser->list,cnt)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = cnt),
      prsnl_group pg,
      code_value cv
     PLAN (d)
      JOIN (pg
      WHERE (pg.prsnl_group_id=remuser->list[d.seq].prsnl_group_id))
      JOIN (cv
      WHERE cv.code_value=pg.prsnl_group_type_cd)
     DETAIL
      remuser->list[d.seq].group_name = trim(cv.display,3)
     WITH nocounter
    ;end select
    FOR (j = 1 TO cnt)
     CALL auditevent(audit_event_user_to_user_group,0,remuser->list[j].id,remuser->list[j].name)
     CALL auditevent(audit_event_modify_user_group,0,remuser->list[j].prsnl_group_id,remuser->list[j]
      .group_name)
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE auditevent(auditeventflag,mode,participantid,participantname)
   CASE (auditeventflag)
    OF audit_event_modify_user_group:
     EXECUTE cclaudit mode, nullterm("Maintain User"), nullterm("Maintain User Group"),
     nullterm("System Object"), nullterm("Resource"), nullterm("User Group Name"),
     nullterm("Amendment"), participantid, nullterm(participantname)
    OF audit_event_user_to_user_group:
     EXECUTE cclaudit mode, nullterm("Maintain User"), nullterm("User Groupings"),
     nullterm("Person"), nullterm("Provider"), nullterm("Provider"),
     nullterm("Amendment"), participantid, nullterm(participantname)
   ENDCASE
 END ;Subroutine
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
