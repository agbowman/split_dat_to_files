CREATE PROGRAM co_readme_ccday1_correct:dba
 FREE RECORD reply
 RECORD reply(
   1 reclist[*]
     2 risk_adjustment_id = f8
     2 risk_adjustment_day_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE failure = c2 WITH private, noconstant("F")
 DECLARE errmsg = vc WITH public, noconstant(" ")
 DECLARE errcode = i4 WITH public, noconstant(0)
 FREE RECORD ra_recs
 RECORD ra_recs(
   1 qual[*]
     2 risk_adjustment_id = f8
     2 risk_adjustment_day_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 icu_admit_dt_tm = dq8
     2 icu_disch_dt_tm = dq8
     2 cc_beg_dt_tm = dq8
     2 cc_end_dt_tm = dq8
 )
 SELECT INTO "nl:"
  rad.active_ind, rad.cc_day, rad.cc_beg_dt_tm,
  rad.cc_end_dt_tm, rad.risk_adjustment_day_id, rad.risk_adjustment_id,
  ra.active_ind, ra.person_id, ra.encntr_id,
  ra.risk_adjustment_id, ra.icu_admit_dt_tm, ra.icu_disch_dt_tm
  FROM risk_adjustment_day rad,
   risk_adjustment ra
  PLAN (rad
   WHERE rad.active_ind=1
    AND rad.cc_day=1
    AND (datetimediff(rad.cc_end_dt_tm,rad.cc_beg_dt_tm) < (1/ 3)))
   JOIN (ra
   WHERE ra.risk_adjustment_id=rad.risk_adjustment_id
    AND datetimediff(ra.icu_disch_dt_tm,rad.cc_end_dt_tm) > 0
    AND ra.active_ind=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(ra_recs->qual,(cnt+ 9))
   ENDIF
   ra_recs->qual[cnt].risk_adjustment_day_id = rad.risk_adjustment_day_id, ra_recs->qual[cnt].
   risk_adjustment_id = rad.risk_adjustment_id, ra_recs->qual[cnt].cc_beg_dt_tm = rad.cc_beg_dt_tm,
   ra_recs->qual[cnt].cc_end_dt_tm = rad.cc_end_dt_tm, ra_recs->qual[cnt].person_id = ra.person_id,
   ra_recs->qual[cnt].encntr_id = ra.encntr_id,
   ra_recs->qual[cnt].icu_admit_dt_tm = ra.icu_admit_dt_tm, ra_recs->qual[cnt].icu_disch_dt_tm = ra
   .icu_disch_dt_tm
  FOOT REPORT
   stat = alterlist(ra_recs->qual,cnt)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  GO TO exit_script
 ENDIF
 DECLARE size_ra_recs = i4 WITH noconstant(size(ra_recs->qual,5))
 IF (size_ra_recs > 0)
  DECLARE applicationid = i4 WITH constant(600700)
  DECLARE taskid = i4 WITH constant(600720)
  DECLARE requestid = i4 WITH constant(4173036)
  DECLARE happ = i4 WITH noconstant(0)
  DECLARE htask = i4 WITH noconstant(0)
  DECLARE hstep = i4 WITH noconstant(0)
  DECLARE iret = i4 WITH noconstant(0)
  DECLARE srvstat = i4 WITH noconstant(0)
  SET iret = uar_crmbeginapp(applicationid,happ)
  IF (iret != 0)
   SET errmsg = build("uar_CrmBeginApp error - applicationId: ",applicationid)
   SET reply->status_data.subeventstatus[1].operationname = "BEGINAPP"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
   GO TO exit_script
  ENDIF
  SET iret = uar_crmbegintask(happ,taskid,htask)
  IF (iret != 0)
   SET errmsg = build("uar_CrmBeginTask error - taskId: ",taskid)
   SET reply->status_data.subeventstatus[1].operationname = "BEGINTASK"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
   GO TO exit_script
  ENDIF
  SET iret = uar_crmbeginreq(htask,"",requestid,hstep)
  IF (iret != 0)
   SET errmsg = build("uar_CrmBeginReq error - requestId: ",requestid)
   SET reply->status_data.subeventstatus[1].operationname = "BEGINREQ"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
   GO TO exit_script
  ENDIF
  SET hreq = uar_crmgetrequest(hstep)
  FOR (i = 1 TO size_ra_recs)
    UPDATE  FROM risk_adjustment_day rad
     SET rad.cc_end_dt_tm = datetimeadd(rad.cc_end_dt_tm,1), rad.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), rad.updt_cnt = (rad.updt_cnt+ 1),
      rad.updt_id = reqinfo->updt_id, rad.updt_task = reqinfo->updt_task, rad.updt_applctx = reqinfo
      ->updt_applctx
     WHERE (rad.risk_adjustment_day_id=ra_recs->qual[i].risk_adjustment_day_id)
     WITH nocounter
    ;end update
    SET errcode = error(errmsg,1)
    IF (errcode != 0)
     SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
     GO TO exit_script
    ELSE
     COMMIT
     SET ra_recs->qual[i].cc_end_dt_tm = datetimeadd(ra_recs->qual[i].cc_end_dt_tm,1)
     SET srvstat = uar_srvsetdouble(hreq,"person_id",ra_recs->qual[i].person_id)
     SET srvstat = uar_srvsetdouble(hreq,"encntr_id",ra_recs->qual[i].encntr_id)
     SET srvstat = uar_srvsetdate(hreq,"icu_admit_dt_tm",cnvtdatetime(ra_recs->qual[i].
       icu_admit_dt_tm))
     SET srvstat = uar_srvsetlong(hreq,"cc_day",1)
     SET srvstat = uar_srvsetdate(hreq,"cc_beg_dt_tm",cnvtdatetime(ra_recs->qual[i].cc_beg_dt_tm))
     SET srvstat = uar_srvsetdate(hreq,"cc_end_dt_tm",cnvtdatetime(ra_recs->qual[i].cc_end_dt_tm))
     SET iret = uar_crmperform(hstep)
     IF (iret != 0)
      SET errmsg = build("uar_CrmPerform returned: ",iret," for risk_adjustment_id: ",ra_recs->qual[i
       ].risk_adjustment_id," at index: ",
       i)
      SET reply->status_data.subeventstatus[1].operationname = "PERFORM"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
      GO TO exit_script
     ENDIF
     SET stat = alterlist(reply->reclist,i)
     SET reply->reclist[i].risk_adjustment_id = ra_recs->qual[i].risk_adjustment_id
     SET reply->reclist[i].risk_adjustment_day_id = ra_recs->qual[i].risk_adjustment_day_id
     SET failure = "S"
    ENDIF
  ENDFOR
  CALL uar_crmendreq(hstep)
  CALL uar_crmendtask(htask)
  CALL uar_crmendapp(happ)
 ELSE
  SET failure = "S"
  GO TO exit_script
 ENDIF
#exit_script
 SET reply->status_data.subeventstatus[1].targetobjectname = "co_readme_ccday1_correct"
 IF (failure="S")
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.status = "S"
  COMMIT
 ELSEIF (failure="F")
  SET reply->status_data.status = "F"
  ROLLBACK
 ENDIF
 CALL echorecord(reply)
END GO
