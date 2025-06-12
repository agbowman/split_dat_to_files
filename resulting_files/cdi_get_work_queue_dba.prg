CREATE PROGRAM cdi_get_work_queue:dba
 SET modify = predeclare
 IF (validate(request)=0)
  RECORD request(
    1 queue_qual[*]
      2 work_queue_cd = f8
  )
 ENDIF
 IF (validate(reply)=0)
  RECORD reply(
    1 queue_qual[*]
      2 work_queue_cd = f8
      2 work_queue_id = f8
      2 display = vc
      2 description = vc
      2 active_ind = i2
      2 code_value_qual[*]
        3 code_set = i4
        3 code_value = f8
        3 collation_seq = i4
      2 prsnl_qual[*]
        3 work_queue_prsnl_reltn_id = f8
        3 person_id = f8
        3 name_full_formatted = vc
        3 exception_ind = i2
        3 position_cd = f8
      2 time_qual[*]
        3 work_queue_time_id = f8
        3 open_days_bitmap = i4
        3 open_time = i4
        3 close_time = i4
      2 rule_qual[*]
        3 cdi_rule_id = f8
        3 criteria_qual[*]
          4 cdi_rule_criteria_id = f8
          4 variable_cd = f8
          4 comparison_flag = i2
          4 value_cd = f8
          4 value_dt_tm = dq8
          4 value_nbr = i4
          4 value_txt = vc
          4 value_entity_id = f8
          4 value_entity_name = vc
      2 attr_cnfg_qual[*]
        3 attr_config_id = f8
        3 attr_code_value = f8
        3 req_ind = i2
        3 warn_ind = i2
        3 multi_select_enable_ind = i2
      2 default_authenticated_ind = i2
      2 pagination_ind = i2
      2 reg_action_keys_txt = vc
    1 elapsed_time = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE dstarttime = f8 WITH private, noconstant(curtime3)
 DECLARE delapsedtime = f8 WITH private, noconstant(0.0)
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE lquecnt = i4 WITH protect, noconstant(0)
 DECLARE lqueidx = i4 WITH protect, noconstant(0)
 DECLARE lstatuscnt = i4 WITH protect, noconstant(0)
 DECLARE lexpandidx = i4 WITH protect, noconstant(0)
 DECLARE lcvcnt = i4 WITH protect, noconstant(0)
 DECLARE lprsnlcnt = i4 WITH protect, noconstant(0)
 DECLARE ltimecnt = i4 WITH protect, noconstant(0)
 DECLARE lrulecnt = i4 WITH protect, noconstant(0)
 DECLARE lcriteriacnt = i4 WITH protect, noconstant(0)
 DECLARE lconfigcnt = i4 WITH protect, noconstant(0)
 DECLARE sscriptstatus = c1 WITH protect, noconstant("F")
 DECLARE sscriptmsg = vc WITH protect, noconstant("Script Error")
 DECLARE sline = vc WITH protect, constant(fillstring(70,"-"))
 DECLARE cblocksize = i4 WITH protect, constant(100)
 CALL echo(sline)
 CALL echo("********** BEGIN CDI_GET_WORK_QUEUE **********")
 CALL echo(sline)
 CALL echorecord(request)
 CALL echo(sline)
 SET lquecnt = size(request->queue_qual,5)
 IF (lquecnt <= 0)
  SET sscriptstatus = "F"
  SET sscriptmsg = "REQUEST WAS EMPTY"
  GO TO exit_script
 ENDIF
 SET dstat = alterlist(reply->queue_qual,lquecnt)
 FOR (lqueidx = 1 TO lquecnt)
   SET reply->queue_qual[lqueidx].work_queue_cd = request->queue_qual[lqueidx].work_queue_cd
 ENDFOR
 SELECT INTO "NL:"
  FROM cdi_work_queue wq,
   code_value cv
  PLAN (wq
   WHERE expand(lexpandidx,1,lquecnt,wq.work_queue_cd,request->queue_qual[lexpandidx].work_queue_cd)
    AND wq.work_queue_cd > 0)
   JOIN (cv
   WHERE cv.code_value=wq.work_queue_cd)
  ORDER BY wq.work_queue_cd
  HEAD REPORT
   lqueidx = 0, lstatuscnt = 0
  HEAD wq.work_queue_cd
   lqueidx = locateval(lcnt,1,lquecnt,wq.work_queue_cd,request->queue_qual[lcnt].work_queue_cd)
   IF (lqueidx > 0)
    reply->queue_qual[lqueidx].work_queue_id = wq.cdi_work_queue_id, reply->queue_qual[lqueidx].
    work_queue_cd = wq.work_queue_cd, reply->queue_qual[lqueidx].display = wq.work_queue_name,
    reply->queue_qual[lqueidx].description = wq.work_queue_description, reply->queue_qual[lqueidx].
    default_authenticated_ind = wq.default_authenticated_ind, reply->queue_qual[lqueidx].
    pagination_ind = wq.pagination_ind,
    reply->queue_qual[lqueidx].reg_action_keys_txt = wq.reg_action_keys_txt, reply->queue_qual[
    lqueidx].active_ind = cv.active_ind, lstatuscnt += 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM code_value_group cv
  PLAN (cv
   WHERE expand(lexpandidx,1,lquecnt,cv.parent_code_value,request->queue_qual[lexpandidx].
    work_queue_cd)
    AND cv.parent_code_value > 0)
  ORDER BY cv.parent_code_value, cv.child_code_value
  HEAD REPORT
   lqueidx = 0
  HEAD cv.parent_code_value
   lqueidx = locateval(lcnt,1,lquecnt,cv.parent_code_value,request->queue_qual[lcnt].work_queue_cd),
   lcvcnt = 0
  HEAD cv.child_code_value
   IF (lqueidx > 0)
    lcvcnt += 1
    IF (mod(lcvcnt,cblocksize)=1)
     dstat = alterlist(reply->queue_qual[lqueidx].code_value_qual,((lcvcnt+ cblocksize) - 1))
    ENDIF
    reply->queue_qual[lqueidx].code_value_qual[lcvcnt].code_set = cv.code_set, reply->queue_qual[
    lqueidx].code_value_qual[lcvcnt].code_value = cv.child_code_value, reply->queue_qual[lqueidx].
    code_value_qual[lcvcnt].collation_seq = cv.collation_seq
   ENDIF
  FOOT  cv.parent_code_value
   IF (lqueidx > 0)
    dstat = alterlist(reply->queue_qual[lqueidx].code_value_qual,lcvcnt)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM cdi_work_queue_prsnl_reltn r,
   prsnl p
  PLAN (r
   WHERE expand(lexpandidx,1,lquecnt,r.cdi_work_queue_id,reply->queue_qual[lexpandidx].work_queue_id)
    AND r.cdi_work_queue_id > 0)
   JOIN (p
   WHERE p.person_id=r.person_id)
  ORDER BY r.cdi_work_queue_id, r.person_id
  HEAD REPORT
   lqueidx = 0
  HEAD r.cdi_work_queue_id
   lqueidx = locateval(lcnt,1,lquecnt,r.cdi_work_queue_id,reply->queue_qual[lcnt].work_queue_id),
   lprsnlcnt = 0
  HEAD r.person_id
   IF (lqueidx > 0)
    lprsnlcnt += 1
    IF (mod(lprsnlcnt,cblocksize)=1)
     dstat = alterlist(reply->queue_qual[lqueidx].prsnl_qual,((lprsnlcnt+ cblocksize) - 1))
    ENDIF
    reply->queue_qual[lqueidx].prsnl_qual[lprsnlcnt].work_queue_prsnl_reltn_id = r
    .cdi_work_queue_prsnl_reltn_id, reply->queue_qual[lqueidx].prsnl_qual[lprsnlcnt].person_id = r
    .person_id, reply->queue_qual[lqueidx].prsnl_qual[lprsnlcnt].name_full_formatted = p
    .name_full_formatted,
    reply->queue_qual[lqueidx].prsnl_qual[lprsnlcnt].exception_ind = r.exception_ind, reply->
    queue_qual[lqueidx].prsnl_qual[lprsnlcnt].position_cd = p.position_cd
   ENDIF
  FOOT  r.cdi_work_queue_id
   IF (lqueidx > 0)
    dstat = alterlist(reply->queue_qual[lqueidx].prsnl_qual,lprsnlcnt)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM cdi_work_queue_time t
  PLAN (t
   WHERE expand(lexpandidx,1,lquecnt,t.cdi_work_queue_id,reply->queue_qual[lexpandidx].work_queue_id)
    AND t.cdi_work_queue_id > 0)
  ORDER BY t.cdi_work_queue_id, t.cdi_work_queue_time_id
  HEAD REPORT
   lqueidx = 0
  HEAD t.cdi_work_queue_id
   lqueidx = locateval(lcnt,1,lquecnt,t.cdi_work_queue_id,reply->queue_qual[lcnt].work_queue_id),
   ltimecnt = 0
  HEAD t.cdi_work_queue_time_id
   IF (lqueidx > 0)
    ltimecnt += 1
    IF (mod(ltimecnt,cblocksize)=1)
     dstat = alterlist(reply->queue_qual[lqueidx].time_qual,((ltimecnt+ cblocksize) - 1))
    ENDIF
    reply->queue_qual[lqueidx].time_qual[ltimecnt].work_queue_time_id = t.cdi_work_queue_time_id,
    reply->queue_qual[lqueidx].time_qual[ltimecnt].open_days_bitmap = t.open_days_bitmap, reply->
    queue_qual[lqueidx].time_qual[ltimecnt].open_time = t.open_time,
    reply->queue_qual[lqueidx].time_qual[ltimecnt].close_time = t.close_time
   ENDIF
  FOOT  t.cdi_work_queue_id
   IF (lqueidx > 0)
    dstat = alterlist(reply->queue_qual[lqueidx].time_qual,ltimecnt)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM cdi_rule r,
   cdi_rule_criteria rc
  PLAN (r
   WHERE expand(lexpandidx,1,lquecnt,r.parent_entity_id,reply->queue_qual[lexpandidx].work_queue_id,
    r.parent_entity_name,"CDI_WORK_QUEUE")
    AND r.parent_entity_id > 0)
   JOIN (rc
   WHERE r.cdi_rule_id=rc.cdi_rule_id)
  ORDER BY r.parent_entity_id, r.cdi_rule_id
  HEAD REPORT
   lqueidx = 0
  HEAD r.parent_entity_id
   lqueidx = locateval(lcnt,1,lquecnt,r.parent_entity_id,reply->queue_qual[lcnt].work_queue_id,
    r.parent_entity_name,"CDI_WORK_QUEUE"), lrulecnt = 0
  HEAD r.cdi_rule_id
   IF (lqueidx > 0)
    lrulecnt += 1
    IF (mod(lrulecnt,cblocksize)=1)
     dstat = alterlist(reply->queue_qual[lqueidx].rule_qual,((lrulecnt+ cblocksize) - 1))
    ENDIF
    reply->queue_qual[lqueidx].rule_qual[lrulecnt].cdi_rule_id = r.cdi_rule_id, lcriteriacnt = 0
   ENDIF
  DETAIL
   IF (lrulecnt > 0)
    lcriteriacnt += 1
    IF (mod(lcriteriacnt,cblocksize)=1)
     dstat = alterlist(reply->queue_qual[lqueidx].rule_qual[lrulecnt].criteria_qual,((lcriteriacnt+
      cblocksize) - 1))
    ENDIF
    reply->queue_qual[lqueidx].rule_qual[lrulecnt].criteria_qual[lcriteriacnt].cdi_rule_criteria_id
     = rc.cdi_rule_criteria_id, reply->queue_qual[lqueidx].rule_qual[lrulecnt].criteria_qual[
    lcriteriacnt].variable_cd = rc.variable_cd, reply->queue_qual[lqueidx].rule_qual[lrulecnt].
    criteria_qual[lcriteriacnt].comparison_flag = rc.comparison_flag,
    reply->queue_qual[lqueidx].rule_qual[lrulecnt].criteria_qual[lcriteriacnt].value_cd = rc.value_cd,
    reply->queue_qual[lqueidx].rule_qual[lrulecnt].criteria_qual[lcriteriacnt].value_dt_tm = rc
    .value_dt_tm, reply->queue_qual[lqueidx].rule_qual[lrulecnt].criteria_qual[lcriteriacnt].
    value_nbr = rc.value_nbr,
    reply->queue_qual[lqueidx].rule_qual[lrulecnt].criteria_qual[lcriteriacnt].value_txt = rc
    .value_txt, reply->queue_qual[lqueidx].rule_qual[lrulecnt].criteria_qual[lcriteriacnt].
    value_entity_id = rc.value_entity_id, reply->queue_qual[lqueidx].rule_qual[lrulecnt].
    criteria_qual[lcriteriacnt].value_entity_name = rc.value_entity_name
   ENDIF
  FOOT  rc.cdi_rule_id
   IF (lrulecnt > 0)
    dstat = alterlist(reply->queue_qual[lqueidx].rule_qual[lrulecnt].criteria_qual,lcriteriacnt)
   ENDIF
  FOOT  r.parent_entity_id
   IF (lqueidx > 0)
    dstat = alterlist(reply->queue_qual[lqueidx].rule_qual,lrulecnt)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM cdi_work_item_attrib_cnfg cnfg
  PLAN (cnfg
   WHERE expand(lexpandidx,1,lquecnt,cnfg.cdi_work_queue_id,reply->queue_qual[lexpandidx].
    work_queue_id)
    AND cnfg.cdi_work_queue_id > 0)
  ORDER BY cnfg.cdi_work_queue_id
  HEAD REPORT
   lqueidx = 0
  HEAD cnfg.cdi_work_queue_id
   lqueidx = locateval(lcnt,1,lquecnt,cnfg.cdi_work_queue_id,reply->queue_qual[lcnt].work_queue_id),
   lconfigcnt = 0
  HEAD cnfg.cdi_work_item_attrib_cnfg_id
   IF (lqueidx > 0)
    lconfigcnt += 1
    IF (mod(lconfigcnt,cblocksize)=1)
     dstat = alterlist(reply->queue_qual[lqueidx].attr_cnfg_qual,((lconfigcnt+ cblocksize) - 1))
    ENDIF
    reply->queue_qual[lqueidx].attr_cnfg_qual[lconfigcnt].attr_config_id = cnfg
    .cdi_work_item_attrib_cnfg_id, reply->queue_qual[lqueidx].attr_cnfg_qual[lconfigcnt].
    attr_code_value = cnfg.attribute_cd, reply->queue_qual[lqueidx].attr_cnfg_qual[lconfigcnt].
    req_ind = cnfg.required_ind,
    reply->queue_qual[lqueidx].attr_cnfg_qual[lconfigcnt].warn_ind = cnfg.warn_ind, reply->
    queue_qual[lqueidx].attr_cnfg_qual[lconfigcnt].multi_select_enable_ind = cnfg
    .multi_select_enable_ind
   ENDIF
  FOOT  cnfg.cdi_work_queue_id
   IF (lqueidx > 0)
    dstat = alterlist(reply->queue_qual[lqueidx].attr_cnfg_qual,lconfigcnt)
   ENDIF
  WITH nocounter
 ;end select
 SET sscriptstatus = "S"
 SET sscriptmsg = "ALL QUEUES WERE SUCCESSFULLY FOUND"
#exit_script
 SET reply->status_data.status = sscriptstatus
 SET reply->status_data.subeventstatus[1].operationstatus = sscriptstatus
 SET reply->status_data.subeventstatus[1].operationname = "GET"
 SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_GET_WORK_QUEUE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = sscriptmsg
 CALL echo(sline)
 CALL echorecord(reply)
 CALL echo(sline)
 SET delapsedtime = ((curtime3 - dstarttime)/ 100)
 CALL echo(build2("Script elapsed time in seconds: ",trim(cnvtstring(delapsedtime,12,2),3)))
 SET reply->elapsed_time = delapsedtime
 CALL echo("Last Mod: 000")
 CALL echo("Mod Date: 10/20/2010")
 CALL echo(sline)
 SET modify = nopredeclare
 CALL echo("********** END CDI_GET_WORK_QUEUE **********")
 CALL echo(sline)
END GO
