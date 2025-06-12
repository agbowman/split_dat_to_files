CREATE PROGRAM dcp_get_outcome_action:dba
 RECORD reply(
   1 outlist[*]
     2 outcome_activity_id = f8
     2 actlist[*]
       3 action_seq = i4
       3 outcome_status_cd = f8
       3 outcome_status_disp = c40
       3 outcome_status_mean = c12
       3 outcome_status_dt_tm = dq8
       3 start_dt_tm = dq8
       3 end_dt_tm = dq8
       3 target_type_cd = f8
       3 target_type_disp = c40
       3 target_type_mean = c12
       3 action_prsnl_name = vc
       3 action_dt_tm = dq8
       3 outcome_status_tz = i4
       3 start_tz = i4
       3 end_tz = i4
       3 action_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE actcnt = i2 WITH noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE outcome_cnt = i4 WITH constant(value(size(request->idlist,5)))
 SELECT INTO "nl:"
  FROM outcome_action oa,
   prsnl pr
  PLAN (oa
   WHERE expand(i,1,outcome_cnt,oa.outcome_activity_id,request->idlist[i].outcome_activity_id))
   JOIN (pr
   WHERE oa.updt_id=pr.person_id)
  ORDER BY oa.outcome_activity_id, oa.action_seq DESC
  HEAD REPORT
   cnt = 0
  HEAD oa.outcome_activity_id
   cnt = (cnt+ 1)
   IF (cnt > value(size(reply->outlist,5)))
    stat = alterlist(reply->outlist,(cnt+ 10))
   ENDIF
   actcnt = 0, reply->outlist[cnt].outcome_activity_id = oa.outcome_activity_id
  DETAIL
   actcnt = (actcnt+ 1)
   IF (actcnt > value(size(reply->outlist[cnt].actlist,5)))
    stat = alterlist(reply->outlist[cnt].actlist,(actcnt+ 10))
   ENDIF
   reply->outlist[cnt].actlist[actcnt].action_seq = oa.action_seq, reply->outlist[cnt].actlist[actcnt
   ].outcome_status_cd = oa.outcome_status_cd, reply->outlist[cnt].actlist[actcnt].
   outcome_status_dt_tm = cnvtdatetime(oa.outcome_status_dt_tm),
   reply->outlist[cnt].actlist[actcnt].start_dt_tm = cnvtdatetime(oa.start_dt_tm), reply->outlist[cnt
   ].actlist[actcnt].end_dt_tm = cnvtdatetime(oa.end_dt_tm), reply->outlist[cnt].actlist[actcnt].
   target_type_cd = oa.target_type_cd,
   reply->outlist[cnt].actlist[actcnt].action_prsnl_name = trim(pr.name_full_formatted,3), reply->
   outlist[cnt].actlist[actcnt].action_dt_tm =
   IF (oa.action_dt_tm != null) cnvtdatetime(oa.action_dt_tm)
   ELSE cnvtdatetime(oa.updt_dt_tm)
   ENDIF
   , reply->outlist[cnt].actlist[actcnt].outcome_status_tz = oa.outcome_status_tz,
   reply->outlist[cnt].actlist[actcnt].start_tz = oa.start_tz, reply->outlist[cnt].actlist[actcnt].
   end_tz = oa.end_tz, reply->outlist[cnt].actlist[actcnt].action_tz =
   IF (oa.action_dt_tm != null) oa.action_tz
   ELSE 0
   ENDIF
  FOOT  oa.outcome_activity_id
   stat = alterlist(reply->outlist[cnt].actlist,actcnt)
  FOOT REPORT
   stat = alterlist(reply->outlist,cnt)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
