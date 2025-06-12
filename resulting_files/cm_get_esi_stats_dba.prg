CREATE PROGRAM cm_get_esi_stats:dba
 RECORD reply(
   1 cs_cnt = i4
   1 cs_list[*]
     2 cs_name = c40
     2 mt_cnt = i4
     2 mt_list[*]
       3 mt_name = c8
       3 mt_count = i4
       3 mt_maxtime = i4
       3 mt_highcnt = i4
       3 mt_failcnt = i4
       3 mt_retrycnt = i4
   1 cvstag = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->cvstag = "$Name: ver4_1_20030314 $"
 SET reply->status_data.status = "F"
 SET errmsg = fillstring(132," ")
 SET error_code = 0
 SET reply->cs_cnt = 0
 SET cntcs = reply->cs_cnt
 SET cs_null = 0.999
 SET mt_null = "null"
 SELECT INTO "nl:"
  m.display, nullcheck(el.contributor_system_cd,cs_null,nullind(el.contributor_system_cd)), nullcheck
  (el.msh_msg_type,mt_null,nullind(el.msh_msg_type)),
  el.msh_msg_trig, el.error_stat, el.start_dt_tm,
  el.end_dt_tm, el.updt_dt_tm, el.create_dt_tm,
  diff = ((datetimediff(el.end_dt_tm,el.start_dt_tm) * 24.0) * 3600.0), el.esi_instance
  FROM esi_log el,
   contributor_system m
  PLAN (el
   WHERE el.create_dt_tm >= cnvtdatetimeutc(request->start_time,1)
    AND el.create_dt_tm <= cnvtdatetimeutc(request->end_time,1))
   JOIN (m
   WHERE outerjoin(el.contributor_system_cd)=m.contributor_system_cd)
  ORDER BY el.contributor_system_cd, el.msh_msg_type
  HEAD el.contributor_system_cd
   cntcs = (cntcs+ 1), reply->cs_cnt = cntcs, stat = alterlist(reply->cs_list,cntcs)
   IF (((trim(m.display,3)="") OR (trim(m.display,3)=" ")) )
    reply->cs_list[cntcs].cs_name = "BLANK"
   ELSE
    reply->cs_list[cntcs].cs_name = m.display
   ENDIF
   reply->cs_list[cntcs].mt_cnt = 0, cntmt = reply->cs_list[cntcs].mt_cnt
  HEAD el.msh_msg_type
   cntmt = (cntmt+ 1), reply->cs_list[cntcs].mt_cnt = cntmt, stat = alterlist(reply->cs_list[cntcs].
    mt_list,cntmt)
   IF (((trim(el.msh_msg_type,3)="") OR (trim(el.msh_msg_type,3)=" ")) )
    reply->cs_list[cntcs].mt_list[cntmt].mt_name = "BLANK_MT"
   ELSE
    reply->cs_list[cntcs].mt_list[cntmt].mt_name = el.msh_msg_type
   ENDIF
   reply->cs_list[cntcs].mt_list[cntmt].mt_count = 0, reply->cs_list[cntcs].mt_list[cntmt].mt_maxtime
    = 0, reply->cs_list[cntcs].mt_list[cntmt].mt_highcnt = 0,
   reply->cs_list[cntcs].mt_list[cntmt].mt_failcnt = 0, reply->cs_list[cntcs].mt_list[cntmt].
   mt_retrycnt = 0
  FOOT  el.msh_msg_type
   reply->cs_list[cntcs].mt_list[cntmt].mt_count = count(el.seq), reply->cs_list[cntcs].mt_list[cntmt
   ].mt_maxtime = max(diff), reply->cs_list[cntcs].mt_list[cntmt].mt_highcnt = count(diff
    WHERE (diff > request->esm_threshold)),
   reply->cs_list[cntcs].mt_list[cntmt].mt_failcnt = count(el.seq
    WHERE el.error_stat="ESI_STAT_FAILURE"), reply->cs_list[cntcs].mt_list[cntmt].mt_retrycnt = count
   (el.seq
    WHERE el.error_stat="ESI_STAT_RETRY")
 ;end select
 SET error_code = error(errmsg,0)
 IF (error_code=0)
  IF (cntcs=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
