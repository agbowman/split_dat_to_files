CREATE PROGRAM dcp_get_regimen_documentation:dba
 SET modify = predeclare
 IF (validate(reply,"N")="N")
  RECORD reply(
    1 documentationlist[*]
      2 active_ind = i2
      2 regimen_id = f8
      2 regimen_detail_id = f8
      2 regimen_documentation_id = f8
      2 response_cd = f8
      2 response_text = vc
      2 chart_dt_tm = dq8
      2 chart_tz = i4
      2 chart_prsnl_id = f8
      2 chart_prsnl_name_first = vc
      2 chart_prsnl_name_last = vc
      2 chartcredentiallist[*]
        3 display = vc
      2 unchart_dt_tm = dq8
      2 unchart_tz = i4
      2 unchart_prsnl_id = f8
      2 unchart_prsnl_name_first = vc
      2 unchart_prsnl_name_last = vc
      2 unchartcredentiallist[*]
        3 display = vc
      2 type_flag = i2
      2 updt_cnt = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE cstatus = c1 WITH protect, noconstant("Z")
 DECLARE script_version = vc WITH private, noconstant("")
 DECLARE getinactivevalue = i2 WITH noconstant(0), protect
 DECLARE regimen_size = i4 WITH constant(value(size(request->regimenlist,5)))
 DECLARE regimen_list_start = i4 WITH noconstant(1), protect
 DECLARE regimenidx = i4 WITH noconstant(0), protect
 DECLARE regimencnt = i4 WITH noconstant(0), protect
 DECLARE regimensize = i4 WITH noconstant(0), protect
 DECLARE elementcnt = i4 WITH noconstant(0), protect
 DECLARE elementsize = i4 WITH noconstant(0), protect
 DECLARE documentationcnt = i4 WITH noconstant(0), protect
 DECLARE documentationsize = i4 WITH noconstant(0), protect
 DECLARE chartcredentialcnt = i4 WITH noconstant(0), protect
 DECLARE chartcredentialsize = i4 WITH noconstant(0), protect
 DECLARE unchartcredentialcnt = i4 WITH noconstant(0), protect
 DECLARE unchartcredentialsize = i4 WITH noconstant(0), protect
 IF ((request->get_all_ind=0))
  SET getinactivevalue = 1
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = regimen_size),
   regimen_documentation rd,
   long_text lt,
   prsnl p,
   credential c
  PLAN (d1
   WHERE initarray(regimen_list_start,evaluate(d1.seq,1,1,regimen_size)))
   JOIN (rd
   WHERE expand(regimenidx,regimen_list_start,regimen_size,rd.regimen_id,request->regimenlist[
    regimenidx].regimen_id)
    AND rd.active_ind IN (1, getinactivevalue))
   JOIN (lt
   WHERE (lt.long_text_id= Outerjoin(rd.long_text_id)) )
   JOIN (p
   WHERE ((p.person_id=rd.chart_prsnl_id) OR (p.person_id=rd.unchart_prsnl_id))
    AND p.person_id != 0)
   JOIN (c
   WHERE (c.prsnl_id= Outerjoin(p.person_id))
    AND (c.active_ind= Outerjoin(1)) )
  ORDER BY rd.regimen_id, rd.regimen_detail_id, rd.chart_prsnl_id,
   rd.unchart_prsnl_id, p.person_id, c.credential_id
  HEAD rd.regimen_documentation_id
   documentationcnt += 1
   IF (documentationcnt > documentationsize)
    documentationsize += 10, stat = alterlist(reply->documentationlist,documentationsize)
   ENDIF
   reply->documentationlist[documentationcnt].active_ind = rd.active_ind, reply->documentationlist[
   documentationcnt].regimen_id = rd.regimen_id, reply->documentationlist[documentationcnt].
   regimen_detail_id = rd.regimen_detail_id,
   reply->documentationlist[documentationcnt].regimen_documentation_id = rd.regimen_documentation_id,
   reply->documentationlist[documentationcnt].response_cd = rd.response_cd
   IF (lt.long_text_id > 0)
    reply->documentationlist[documentationcnt].response_text = lt.long_text
   ENDIF
   reply->documentationlist[documentationcnt].chart_dt_tm = rd.chart_dt_tm, reply->documentationlist[
   documentationcnt].chart_tz = rd.chart_tz, reply->documentationlist[documentationcnt].
   chart_prsnl_id = rd.chart_prsnl_id,
   reply->documentationlist[documentationcnt].type_flag = rd.type_flag, reply->documentationlist[
   documentationcnt].updt_cnt = rd.updt_cnt, reply->documentationlist[documentationcnt].unchart_dt_tm
    = rd.unchart_dt_tm,
   reply->documentationlist[documentationcnt].unchart_tz = rd.unchart_tz, reply->documentationlist[
   documentationcnt].unchart_prsnl_id = rd.unchart_prsnl_id
  HEAD p.person_id
   IF ((p.person_id=reply->documentationlist[documentationcnt].chart_prsnl_id))
    reply->documentationlist[documentationcnt].chart_prsnl_name_first = p.name_first, reply->
    documentationlist[documentationcnt].chart_prsnl_name_last = p.name_last
   ENDIF
   IF ((p.person_id=reply->documentationlist[documentationcnt].unchart_prsnl_id))
    reply->documentationlist[documentationcnt].unchart_prsnl_name_first = p.name_first, reply->
    documentationlist[documentationcnt].unchart_prsnl_name_last = p.name_last
   ENDIF
   chartcredentialcnt = 0, chartcredentialsize = 0, unchartcredentialcnt = 0,
   unchartcredentialsize = 0
  HEAD c.credential_id
   IF ((c.prsnl_id=reply->documentationlist[documentationcnt].chart_prsnl_id))
    IF (rd.chart_dt_tm BETWEEN c.beg_effective_dt_tm AND c.end_effective_dt_tm)
     chartcredentialcnt += 1
     IF (chartcredentialcnt > chartcredentialsize)
      chartcredentialsize += 10, stat = alterlist(reply->documentationlist[documentationcnt].
       chartcredentiallist,chartcredentialsize)
     ENDIF
     reply->documentationlist[documentationcnt].chartcredentiallist[chartcredentialcnt].display =
     uar_get_code_display(c.credential_cd)
    ENDIF
   ENDIF
   IF ((c.prsnl_id=reply->documentationlist[documentationcnt].unchart_prsnl_id))
    IF (rd.unchart_dt_tm BETWEEN c.beg_effective_dt_tm AND c.end_effective_dt_tm)
     unchartcredentialcnt += 1
     IF (unchartcredentialcnt > unchartcredentialsize)
      unchartcredentialsize += 10, stat = alterlist(reply->documentationlist[documentationcnt].
       unchartcredentiallist,unchartcredentialsize)
     ENDIF
     reply->documentationlist[documentationcnt].unchartcredentiallist[unchartcredentialcnt].display
      = uar_get_code_display(c.credential_cd)
    ENDIF
   ENDIF
  FOOT  p.person_id
   IF ((c.prsnl_id=reply->documentationlist[documentationcnt].chart_prsnl_id))
    IF (rd.chart_dt_tm BETWEEN c.beg_effective_dt_tm AND c.end_effective_dt_tm)
     stat = alterlist(reply->documentationlist[documentationcnt].chartcredentiallist,
      chartcredentialcnt), chartcredentialsize = chartcredentialcnt
    ENDIF
   ENDIF
   IF ((c.prsnl_id=reply->documentationlist[documentationcnt].unchart_prsnl_id))
    IF (rd.unchart_dt_tm BETWEEN c.beg_effective_dt_tm AND c.end_effective_dt_tm)
     stat = alterlist(reply->documentationlist[documentationcnt].unchartcredentiallist,
      unchartcredentialcnt), unchartcredentialsize = unchartcredentialcnt
    ENDIF
   ENDIF
  FOOT  rd.regimen_documentation_id
   stat = alterlist(reply->documentationlist,documentationcnt), documentationsize = documentationcnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 SET script_version = "002 11/06/2020 TJ069482"
 CALL echorecord(reply)
END GO
