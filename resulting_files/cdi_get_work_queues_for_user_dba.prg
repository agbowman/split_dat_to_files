CREATE PROGRAM cdi_get_work_queues_for_user:dba
 SET modify = predeclare
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 qual[*]
      2 prsnl_id = f8
      2 position_cd = f8
    1 skip_workitems_ind = i2
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual_cnt = i4
    1 qual[*]
      2 prsnl_id = f8
      2 work_queue_cnt = i4
      2 work_queue[*]
        3 work_queue_id = f8
        3 work_queue_cd = f8
        3 display = vc
        3 attribute_cnt = i4
        3 attribute[*]
          4 code_set = i4
          4 code_value = f8
          4 display = vc
          4 sequence = i4
          4 category_ext = vc
          4 field_ext = vc
        3 work_item_cnt = i4
        3 work_item[*]
          4 work_item_id = f8
          4 priority_cd = f8
          4 status_cd = f8
        3 default_authenticated_ind = i2
        3 pagination_ind = i2
        3 reg_action_keys_txt = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE sline = vc WITH protect, constant(fillstring(70,"-"))
 DECLARE lposition_cs = i4 WITH protect, constant(88)
 DECLARE lwork_queue_cs = i4 WITH protect, constant(4002600)
 DECLARE lperson_alias_cs = i4 WITH protect, constant(4)
 DECLARE lperson_type_cs = i4 WITH protect, constant(213)
 DECLARE lperson_prsnl_reltn_cs = i4 WITH protect, constant(331)
 DECLARE lencntr_alias_cs = i4 WITH protect, constant(319)
 DECLARE lencntr_prsnl_reltn_cs = i4 WITH protect, constant(333)
 DECLARE lwork_item_attr_cs = i4 WITH protect, constant(4002582)
 DECLARE luser_defined_attr_cs = i4 WITH protect, constant(4002583)
 DECLARE dcomplete = f8 WITH protect, constant(uar_get_code_by("MEANING",4002621,"COMPLETE"))
 DECLARE ddelete = f8 WITH protect, constant(uar_get_code_by("MEANING",4002621,"DELETE"))
 DECLARE dstarttime = f8 WITH private, noconstant(curtime3)
 DECLARE delapsedtime = f8 WITH private, noconstant(0.0)
 DECLARE lreqsize = i4 WITH protect, noconstant(size(request->qual,5))
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE lidx = i2 WITH protect, noconstant(0)
 DECLARE lpos = i2 WITH protect, noconstant(0)
 DECLARE lqpos = i2 WITH protect, noconstant(0)
 DECLARE lqcnt = i2 WITH protect, noconstant(0)
 DECLARE sscriptstatus = c1 WITH protect, noconstant("F")
 DECLARE sscriptmsg = vc WITH protect, noconstant("Script Error")
 CALL echo(sline)
 CALL echo("********** BEGIN CDI_GET_WORK_QUEUES_FOR_USER **********")
 CALL echo(sline)
 CALL echorecord(request)
 CALL echo(sline)
 IF (lreqsize=0)
  SET dstat = alterlist(request->qual,1)
  SET request->qual[1].prsnl_id = reqinfo->updt_id
 ELSEIF (lreqsize=1)
  IF ((request->qual[1].prsnl_id=0.0))
   SET request->qual[1].prsnl_id = reqinfo->updt_id
  ENDIF
 ENDIF
 SET lreqsize = size(request->qual,5)
 FOR (i = 1 TO lreqsize)
   IF ((request->qual[i].position_cd=0.0))
    SELECT INTO "nl:"
     p.position_cd
     FROM prsnl p
     WHERE (p.person_id=request->qual[i].prsnl_id)
     DETAIL
      request->qual[i].position_cd = p.position_cd
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 CALL echo(sline)
 CALL echorecord(request)
 CALL echo(sline)
 SET lcnt = 0
 SET reply->qual_cnt = lreqsize
 SET dstat = alterlist(reply->qual,lreqsize)
 FOR (lidx = 1 TO lreqsize)
  SET reply->qual[lidx].prsnl_id = request->qual[lidx].prsnl_id
  SET reply->qual[lidx].work_queue_cnt = 0
 ENDFOR
 SELECT INTO "nl:"
  FROM cdi_work_queue_prsnl_reltn prs,
   cdi_work_queue queue,
   code_value cv
  PLAN (prs
   WHERE expand(lidx,1,lreqsize,prs.person_id,request->qual[lidx].prsnl_id)
    AND prs.person_id > 0
    AND prs.cdi_work_queue_id > 0
    AND ((prs.exception_ind+ 0)=0))
   JOIN (queue
   WHERE queue.cdi_work_queue_id=prs.cdi_work_queue_id)
   JOIN (cv
   WHERE cv.code_value=queue.work_queue_cd
    AND ((cv.active_ind+ 0)=1))
  ORDER BY prs.person_id
  HEAD prs.person_id
   lpos = locateval(lidx,1,lreqsize,prs.person_id,request->qual[lidx].prsnl_id)
   IF (lpos > 0)
    lcnt = reply->qual[lpos].work_queue_cnt
   ENDIF
  DETAIL
   IF (lpos > 0)
    lcnt += 1
    IF (mod(lcnt,10)=1)
     dstat = alterlist(reply->qual[lpos].work_queue,(lcnt+ 9))
    ENDIF
    reply->qual[lpos].work_queue[lcnt].work_queue_id = queue.cdi_work_queue_id, reply->qual[lpos].
    work_queue[lcnt].work_queue_cd = queue.work_queue_cd, reply->qual[lpos].work_queue[lcnt].display
     = cv.display,
    reply->qual[lpos].work_queue[lcnt].default_authenticated_ind = queue.default_authenticated_ind,
    reply->qual[lpos].work_queue[lcnt].pagination_ind = queue.pagination_ind, reply->qual[lpos].
    work_queue[lcnt].reg_action_keys_txt = queue.reg_action_keys_txt,
    sscriptstatus = "S"
   ENDIF
  FOOT  prs.person_id
   IF (lpos > 0)
    reply->qual[lpos].work_queue_cnt = lcnt, dstat = alterlist(reply->qual[lpos].work_queue,lcnt)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(lreqsize)),
   prsnl p,
   code_value_group cvg,
   code_value cv,
   cdi_work_queue queue,
   dummyt d2,
   cdi_work_queue_prsnl_reltn prs
  PLAN (d1
   WHERE (request->qual[d1.seq].prsnl_id > 0))
   JOIN (p
   WHERE (p.person_id=request->qual[d1.seq].prsnl_id))
   JOIN (cvg
   WHERE (cvg.child_code_value=request->qual[d1.seq].position_cd)
    AND ((cvg.code_set+ 0)=lposition_cs))
   JOIN (cv
   WHERE cv.code_value=cvg.parent_code_value
    AND ((cv.code_set+ 0)=lwork_queue_cs)
    AND ((cv.active_ind+ 0)=1))
   JOIN (queue
   WHERE queue.work_queue_cd=cv.code_value
    AND queue.logical_domain_id=p.logical_domain_id)
   JOIN (d2)
   JOIN (prs
   WHERE prs.cdi_work_queue_id=queue.cdi_work_queue_id
    AND prs.person_id=p.person_id)
  DETAIL
   IF (prs.exception_ind=0)
    lpos = locateval(lidx,1,lreqsize,p.person_id,reply->qual[lidx].prsnl_id)
    IF (lpos > 0)
     lqpos = locateval(lidx,1,reply->qual[lpos].work_queue_cnt,queue.cdi_work_queue_id,reply->qual[
      lpos].work_queue[lidx].work_queue_id)
     IF (lqpos=0)
      lqcnt = (reply->qual[lpos].work_queue_cnt+ 1), reply->qual[lpos].work_queue_cnt = lqcnt, dstat
       = alterlist(reply->qual[lpos].work_queue,lqcnt),
      reply->qual[lpos].work_queue[lqcnt].work_queue_id = queue.cdi_work_queue_id, reply->qual[lpos].
      work_queue[lqcnt].work_queue_cd = queue.work_queue_cd, reply->qual[lpos].work_queue[lqcnt].
      display = cv.display,
      reply->qual[lpos].work_queue[lqcnt].default_authenticated_ind = queue.default_authenticated_ind,
      reply->qual[lpos].work_queue[lqcnt].pagination_ind = queue.pagination_ind, reply->qual[lpos].
      work_queue[lqcnt].reg_action_keys_txt = queue.reg_action_keys_txt,
      sscriptstatus = "S"
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d2
 ;end select
 SELECT INTO "nl:"
  FROM prsnl p,
   code_value cv,
   cdi_work_queue wq
  PLAN (cv
   WHERE cv.code_set=lwork_queue_cs
    AND cv.cdf_meaning="ERROR_QUEUE")
   JOIN (p
   WHERE expand(lidx,1,lreqsize,p.person_id,request->qual[lidx].prsnl_id))
   JOIN (wq
   WHERE wq.work_queue_cd=cv.code_value
    AND wq.logical_domain_id=p.logical_domain_id)
  DETAIL
   lpos = locateval(lidx,1,lreqsize,p.person_id,reply->qual[lidx].prsnl_id), lcnt = (reply->qual[lpos
   ].work_queue_cnt+ 1), reply->qual[lpos].work_queue_cnt = lcnt,
   dstat = alterlist(reply->qual[lpos].work_queue,lcnt), reply->qual[lpos].work_queue[lcnt].
   work_queue_id = wq.cdi_work_queue_id, reply->qual[lpos].work_queue[lcnt].work_queue_cd = wq
   .work_queue_cd,
   reply->qual[lpos].work_queue[lcnt].display = cv.display, reply->qual[lpos].work_queue[lcnt].
   default_authenticated_ind = wq.default_authenticated_ind, reply->qual[lpos].work_queue[lcnt].
   pagination_ind = wq.pagination_ind,
   reply->qual[lpos].work_queue[lcnt].reg_action_keys_txt = wq.reg_action_keys_txt
  WITH maxrec = 1
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(lreqsize)),
   cdi_work_queue queue,
   code_value_group cvg,
   (left JOIN code_value_extension cve ON cve.code_value=cvg.child_code_value
    AND cve.field_name IN ("Category", "Field")
    AND cve.code_set=cvg.code_set)
  PLAN (d1
   WHERE (reply->qual[d1.seq].work_queue_cnt > 0))
   JOIN (queue
   WHERE expand(lidx,1,reply->qual[d1.seq].work_queue_cnt,queue.cdi_work_queue_id,reply->qual[d1.seq]
    .work_queue[lidx].work_queue_id))
   JOIN (cvg
   WHERE cvg.parent_code_value=queue.work_queue_cd
    AND ((cvg.code_set+ 0) IN (lperson_alias_cs, lperson_type_cs, lperson_prsnl_reltn_cs,
   lencntr_alias_cs, lencntr_prsnl_reltn_cs,
   lwork_item_attr_cs, luser_defined_attr_cs)))
   JOIN (cve)
  ORDER BY queue.cdi_work_queue_id, cvg.collation_seq, cve.field_name
  HEAD queue.cdi_work_queue_id
   lcnt = 0, lpos = locateval(lidx,1,reply->qual[d1.seq].work_queue_cnt,queue.cdi_work_queue_id,reply
    ->qual[d1.seq].work_queue[lidx].work_queue_id)
  HEAD cvg.collation_seq
   IF (lpos > 0)
    lcnt += 1
    IF (mod(lcnt,10)=1)
     dstat = alterlist(reply->qual[d1.seq].work_queue[lpos].attribute,(lcnt+ 9))
    ENDIF
    reply->qual[d1.seq].work_queue[lpos].attribute[lcnt].code_set = cvg.code_set, reply->qual[d1.seq]
    .work_queue[lpos].attribute[lcnt].code_value = cvg.child_code_value, reply->qual[d1.seq].
    work_queue[lpos].attribute[lcnt].display = uar_get_code_display(cvg.child_code_value),
    reply->qual[d1.seq].work_queue[lpos].attribute[lcnt].sequence = cvg.collation_seq
   ENDIF
  HEAD cve.field_name
   IF (lpos > 0
    AND lcnt > 0
    AND cve.code_value > 0)
    CASE (cve.field_name)
     OF "Category":
      reply->qual[d1.seq].work_queue[lpos].attribute[lcnt].category_ext = cve.field_value
     OF "Field":
      reply->qual[d1.seq].work_queue[lpos].attribute[lcnt].field_ext = cve.field_value
    ENDCASE
   ENDIF
  FOOT  cve.field_name
   dstat = 0
  FOOT  cvg.collation_seq
   dstat = 0
  FOOT  queue.cdi_work_queue_id
   IF (lpos > 0)
    reply->qual[d1.seq].work_queue[lpos].attribute_cnt = lcnt, dstat = alterlist(reply->qual[d1.seq].
     work_queue[lpos].attribute,lcnt)
   ENDIF
  WITH nocounter
 ;end select
 IF ((request->skip_workitems_ind=0))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(lreqsize)),
    cdi_work_queue_item_reltn wqir,
    cdi_work_item wi
   PLAN (d1
    WHERE (reply->qual[d1.seq].work_queue_cnt > 0))
    JOIN (wqir
    WHERE expand(lidx,1,reply->qual[d1.seq].work_queue_cnt,wqir.cdi_work_queue_id,reply->qual[d1.seq]
     .work_queue[lidx].work_queue_id)
     AND wqir.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (wi
    WHERE wi.cdi_work_item_id=wqir.cdi_work_item_id
     AND  NOT (wi.status_cd IN (dcomplete, ddelete)))
   ORDER BY wqir.cdi_work_queue_id, wi.cdi_work_item_id
   HEAD wqir.cdi_work_queue_id
    lcnt = 0, lpos = locateval(lidx,1,reply->qual[d1.seq].work_queue_cnt,wqir.cdi_work_queue_id,reply
     ->qual[d1.seq].work_queue[lidx].work_queue_id)
   HEAD wi.cdi_work_item_id
    IF (lpos > 0)
     lcnt += 1
     IF (mod(lcnt,10)=1)
      dstat = alterlist(reply->qual[d1.seq].work_queue[lpos].work_item,(lcnt+ 9))
     ENDIF
     reply->qual[d1.seq].work_queue[lpos].work_item[lcnt].work_item_id = wi.cdi_work_item_id, reply->
     qual[d1.seq].work_queue[lpos].work_item[lcnt].priority_cd = wi.priority_cd, reply->qual[d1.seq].
     work_queue[lpos].work_item[lcnt].status_cd = wi.status_cd
    ENDIF
   FOOT  wi.cdi_work_item_id
    dstat = 0
   FOOT  wqir.cdi_work_queue_id
    IF (lpos > 0)
     reply->qual[d1.seq].work_queue[lpos].work_item_cnt = lcnt, dstat = alterlist(reply->qual[d1.seq]
      .work_queue[lpos].work_item,lcnt)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (sscriptstatus="F")
  SET sscriptstatus = "Z"
  SET sscriptmsg = "No work queues found"
 ENDIF
#exit_script
 SET reply->status_data.status = sscriptstatus
 IF (sscriptstatus="F")
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "FAILURE"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_get_work_queues_for_user"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = sscriptmsg
 ELSEIF (sscriptstatus="Z")
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_get_work_queues_for_user"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = sscriptmsg
 ELSE
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_get_work_queues_for_user"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Work Queues Found"
 ENDIF
 CALL echo(sline)
 CALL echorecord(reply)
 CALL echo(sline)
 SET delapsedtime = ((curtime3 - dstarttime)/ 100)
 CALL echo(build2("Script elapsed time in seconds: ",trim(cnvtstring(delapsedtime,12,2),3)))
 CALL echo("Last Mod: 000")
 CALL echo("Mod Date: 10/12/2010")
 CALL echo(sline)
 SET modify = nopredeclare
 CALL echo("********** END CDI_GET_WORK_QUEUES_FOR_USER **********")
 CALL echo(sline)
END GO
