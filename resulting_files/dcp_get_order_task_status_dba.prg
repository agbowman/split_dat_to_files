CREATE PROGRAM dcp_get_order_task_status:dba
 SET modify = predeclare
 RECORD reply(
   1 last_action_sequence = i4
   1 order_status_cd = f8
   1 task_status_cd = f8
   1 updt_cnt = i4
   1 check_qual[*]
     2 order_id = f8
     2 task_id = f8
     2 last_action_sequence = i4
     2 order_status_cd = f8
     2 task_status_cd = f8
     2 updt_cnt = i4
     2 order_iv_info_updt_cnt = i4
   1 order_iv_info_updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count = i4 WITH noconstant(- (1))
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE start = i4 WITH protect, noconstant(1)
 DECLARE check_qual_cnt = i4 WITH protect, noconstant(0)
 DECLARE nsize = i4 WITH protect, noconstant(20)
 DECLARE ntotal = i4 WITH noconstant(0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 IF ((request->check_type=0))
  IF ((request->order_id > 0.0))
   SET count = 0
   SELECT INTO "nl:"
    FROM orders o,
     order_iv_info oiv
    PLAN (o
     WHERE (o.order_id=request->order_id))
     JOIN (oiv
     WHERE oiv.order_id=outerjoin(o.order_id))
    DETAIL
     count = (count+ 1), reply->last_action_sequence = o.last_action_sequence, reply->order_status_cd
      = o.order_status_cd,
     reply->order_iv_info_updt_cnt = oiv.updt_cnt
   ;end select
  ELSE
   SET check_qual_cnt = size(request->check_qual,5)
   SET ntotal = (ceil((cnvtreal(check_qual_cnt)/ nsize)) * nsize)
   SET stat = alterlist(request->check_qual,ntotal)
   FOR (i = (check_qual_cnt+ 1) TO ntotal)
     SET request->check_qual[i].order_id = request->check_qual[check_qual_cnt].order_id
   ENDFOR
   SET stat = alterlist(reply->check_qual,check_qual_cnt)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     orders o,
     order_iv_info oiv
    PLAN (d1
     WHERE initarray(start,evaluate(d1.seq,1,1,(start+ nsize))))
     JOIN (o
     WHERE expand(lidx,start,(start+ (nsize - 1)),o.order_id,request->check_qual[lidx].order_id))
     JOIN (oiv
     WHERE oiv.order_id=outerjoin(o.order_id))
    HEAD REPORT
     count = 0
    DETAIL
     count = (count+ 1), reply->check_qual[count].order_id = o.order_id, reply->check_qual[count].
     last_action_sequence = o.last_action_sequence,
     reply->check_qual[count].order_status_cd = o.order_status_cd, reply->check_qual[count].
     order_iv_info_updt_cnt = oiv.updt_cnt
    FOOT REPORT
     stat = alterlist(request->check_qual,check_qual_cnt)
   ;end select
  ENDIF
 ELSEIF ((request->check_type=1))
  SET count = 0
  IF ((request->task_id > 0.0))
   SELECT INTO "nl:"
    FROM orders o,
     task_activity ta,
     order_iv_info oiv
    PLAN (ta
     WHERE (ta.task_id=request->task_id))
     JOIN (o
     WHERE o.order_id=ta.order_id)
     JOIN (oiv
     WHERE oiv.order_id=outerjoin(o.order_id))
    DETAIL
     count = (count+ 1), reply->task_status_cd = ta.task_status_cd, reply->updt_cnt = ta.updt_cnt,
     reply->last_action_sequence = o.last_action_sequence, reply->order_iv_info_updt_cnt = oiv
     .updt_cnt
   ;end select
  ELSE
   SET check_qual_cnt = size(request->check_qual,5)
   SET ntotal = (ceil((cnvtreal(check_qual_cnt)/ nsize)) * nsize)
   SET stat = alterlist(request->check_qual,ntotal)
   FOR (i = (check_qual_cnt+ 1) TO ntotal)
     SET request->check_qual[i].task_id = request->check_qual[check_qual_cnt].task_id
   ENDFOR
   SET stat = alterlist(reply->check_qual,check_qual_cnt)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     orders o,
     task_activity ta,
     order_iv_info oiv
    PLAN (d1
     WHERE initarray(start,evaluate(d1.seq,1,1,(start+ nsize))))
     JOIN (ta
     WHERE expand(lidx,start,(start+ (nsize - 1)),ta.task_id,request->check_qual[lidx].task_id))
     JOIN (o
     WHERE o.order_id=ta.order_id)
     JOIN (oiv
     WHERE oiv.order_id=outerjoin(o.order_id))
    HEAD REPORT
     count = 0
    DETAIL
     count = (count+ 1), reply->check_qual[count].task_id = ta.task_id, reply->check_qual[count].
     task_status_cd = ta.task_status_cd,
     reply->check_qual[count].updt_cnt = ta.updt_cnt, reply->check_qual[count].last_action_sequence
      = o.last_action_sequence, reply->check_qual[count].order_iv_info_updt_cnt = oiv.updt_cnt
    FOOT REPORT
     stat = alterlist(request->check_qual,check_qual_cnt)
   ;end select
  ENDIF
 ENDIF
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = concat("Get Order/Task Status - ",errmsg)
 ELSEIF (count=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus.operationname = "Zero Qual Count"
 ELSEIF (((count=1) OR (count > 1)) )
  IF ((((request->order_id > 0.0)) OR ((request->task_id > 0.0))) )
   IF (count=1)
    SET reply->status_data.status = "S"
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = "Not all data found."
   ENDIF
  ELSE
   IF (count=check_qual_cnt)
    SET reply->status_data.status = "S"
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = "Not all data found."
   ENDIF
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = build("Invalid check_type - ",request->
   check_type)
 ENDIF
 SET last_mod = "002"
 SET mod_date = "06/05/2013"
 SET modify = nopredeclare
END GO
