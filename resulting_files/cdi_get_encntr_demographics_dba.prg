CREATE PROGRAM cdi_get_encntr_demographics:dba
 SET modify = predeclare
 EXECUTE cdi_get_encntr_demographics_rr
 EXECUTE cdi_get_person_demographics_rr  WITH replace("REQUEST","CDI_GPD_REQ"), replace("REPLY",
  "CDI_GPD_REP")
 DECLARE lreq_size = i4 WITH protect, constant(size(request->encntr,5))
 DECLARE sline = vc WITH protect, constant(fillstring(70,"-"))
 DECLARE dstarttime = f8 WITH private, noconstant(curtime3)
 DECLARE delapsedtime = f8 WITH private, noconstant(0.0)
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE lnewlistsize = i4 WITH protect, noconstant(0)
 DECLARE lcurlistsize = i4 WITH protect, noconstant(0)
 DECLARE lstart = i4 WITH protect, noconstant(0)
 DECLARE lloopcnt = i4 WITH protect, noconstant(0)
 DECLARE lbatchsize = i4 WITH protect, noconstant(20)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE lpos = i4 WITH protect, noconstant(0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE lecnt = i4 WITH protect, noconstant(0)
 DECLARE lpcnt = i4 WITH protect, noconstant(0)
 DECLARE sscriptstatus = c1 WITH protect, noconstant("F")
 DECLARE sscriptmsg = vc WITH protect, noconstant("Script Error")
 CALL echo(sline)
 CALL echo("********** BEGIN CDI_GET_ENCNTR_DEMOGRAPHICS **********")
 CALL echo(sline)
 CALL echorecord(request)
 CALL echo(sline)
 IF (lreq_size <= 0)
  SET sscriptstatus = "Z"
  SET sscriptmsg = "Request was empty"
  GO TO exit_script
 ENDIF
 SET lcurlistsize = lreq_size
 SET lloopcnt = ceil((cnvtreal(lcurlistsize)/ lbatchsize))
 SET lnewlistsize = (lloopcnt * lbatchsize)
 SET dstat = alterlist(request->encntr,lnewlistsize)
 SET lstart = 1
 FOR (lidx = (lcurlistsize+ 1) TO lnewlistsize)
   SET request->encntr[lidx].encntr_id = request->encntr[lcurlistsize].encntr_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(lloopcnt)),
   encounter e,
   (left JOIN prsnl p1 ON p1.person_id=e.pre_reg_prsnl_id),
   (left JOIN prsnl p2 ON p2.person_id=e.reg_prsnl_id),
   (left JOIN organization o ON o.organization_id=e.organization_id),
   (left JOIN be_org_reltn bor ON bor.organization_id=e.organization_id
    AND ((bor.active_ind+ 0)=1)
    AND ((bor.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((bor.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3))),
   (left JOIN billing_entity be ON be.billing_entity_id=bor.billing_entity_id),
   (left JOIN episode_encntr_reltn eer ON eer.encntr_id=e.encntr_id
    AND ((eer.active_ind+ 0)=1)
    AND ((eer.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((eer.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3))),
   (left JOIN episode ep ON ep.episode_id=eer.episode_id)
  PLAN (d
   WHERE initarray(lstart,evaluate(d.seq,1,1,(lstart+ lbatchsize))))
   JOIN (e
   WHERE expand(lidx,lstart,(lstart+ (lbatchsize - 1)),e.encntr_id,request->encntr[lidx].encntr_id)
    AND e.encntr_id > 0
    AND ((e.active_ind+ 0)=1)
    AND ((e.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((e.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
   JOIN (p1)
   JOIN (p2)
   JOIN (o)
   JOIN (bor)
   JOIN (be)
   JOIN (eer)
   JOIN (ep)
  ORDER BY e.encntr_id
  HEAD REPORT
   lecnt = 0, lpcnt = 0
  HEAD e.encntr_id
   lpos = locateval(lidx,1,reply->encntr_cnt,e.encntr_id,reply->encntr[lidx].encntr_id)
   IF (lpos=0)
    lecnt = (lecnt+ 1)
    IF (mod(lecnt,10)=1)
     dstat = alterlist(reply->encntr,(lecnt+ 9))
    ENDIF
    reply->encntr[lecnt].encntr_id = e.encntr_id, reply->encntr[lecnt].person_id = e.person_id, lidx
     = locateval(lidx,1,size(cdi_gpd_req->person,5),e.person_id,cdi_gpd_req->person[lidx].person_id)
    IF (e.person_id > 0
     AND lidx=0)
     lpcnt = (lpcnt+ 1)
     IF (mod(lpcnt,10)=1)
      dstat = alterlist(cdi_gpd_req->person,(lpcnt+ 9))
     ENDIF
     cdi_gpd_req->person[lpcnt].person_id = e.person_id
    ENDIF
    reply->encntr[lecnt].admit_type = uar_get_code_display(e.admit_type_cd), reply->encntr[lecnt].
    arrive_date = e.arrive_dt_tm
    IF (be.billing_entity_id > 0)
     reply->encntr[lecnt].billing_entity = be.be_name
    ENDIF
    reply->encntr[lecnt].building = uar_get_code_display(e.loc_building_cd)
    IF (o.organization_id > 0)
     reply->encntr[lecnt].client = o.org_name
    ENDIF
    reply->encntr[lecnt].depart_date = e.depart_dt_tm, reply->encntr[lecnt].disch_date = e
    .disch_dt_tm, reply->encntr[lecnt].disch_to_location = uar_get_code_display(e.disch_to_loctn_cd),
    reply->encntr[lecnt].encntr_type = uar_get_code_display(e.encntr_type_cd), reply->encntr[lecnt].
    encntr_type_class = uar_get_code_display(e.encntr_type_class_cd)
    IF (ep.episode_id > 0)
     reply->encntr[lecnt].episode_name = ep.display
    ENDIF
    reply->encntr[lecnt].est_arrive_date = e.est_arrive_dt_tm, reply->encntr[lecnt].facility =
    uar_get_code_display(e.loc_facility_cd), reply->encntr[lecnt].fin_class = uar_get_code_display(e
     .financial_class_cd),
    reply->encntr[lecnt].med_service = uar_get_code_display(e.med_service_cd), reply->encntr[lecnt].
    nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd)
    IF (p1.person_id > 0)
     reply->encntr[lecnt].pre_reg_prsnl = p1.name_full_formatted
    ENDIF
    reply->encntr[lecnt].pre_reg_date = e.pre_reg_dt_tm, reply->encntr[lecnt].reason_for_visit = e
    .reason_for_visit
    IF (p2.person_id > 0)
     reply->encntr[lecnt].reg_prsnl = p2.name_full_formatted
    ENDIF
    reply->encntr[lecnt].reg_date = e.reg_dt_tm, reply->encntr[lecnt].room = uar_get_code_display(e
     .loc_room_cd), reply->encntr[lecnt].vip = uar_get_code_display(e.vip_cd),
    sscriptstatus = "S"
   ENDIF
  FOOT REPORT
   reply->encntr_cnt = lecnt, dstat = alterlist(reply->encntr,lecnt), dstat = alterlist(cdi_gpd_req->
    person,lpcnt)
  WITH nocounter
 ;end select
 SET dstat = alterlist(request->encntr,lreq_size)
 IF ((reply->encntr_cnt=0))
  SET sscriptstatus = "Z"
  SET sscriptmsg = "No Encounter Demographics Found"
  GO TO exit_script
 ENDIF
 SET lcurlistsize = reply->encntr_cnt
 SET lloopcnt = ceil((cnvtreal(lcurlistsize)/ lbatchsize))
 SET lnewlistsize = (lloopcnt * lbatchsize)
 SET dstat = alterlist(reply->encntr,lnewlistsize)
 SET lstart = 1
 FOR (lidx = (lcurlistsize+ 1) TO lnewlistsize)
   SET reply->encntr[lidx].encntr_id = reply->encntr[lcurlistsize].encntr_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(lloopcnt)),
   encntr_alias ea
  PLAN (d
   WHERE initarray(lstart,evaluate(d.seq,1,1,(lstart+ lbatchsize))))
   JOIN (ea
   WHERE expand(lidx,lstart,(lstart+ (lbatchsize - 1)),ea.encntr_id,reply->encntr[lidx].encntr_id)
    AND ea.encntr_id > 0
    AND ((ea.active_ind+ 0)=1)
    AND ((ea.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((ea.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
  ORDER BY ea.encntr_id, ea.encntr_alias_type_cd, ea.beg_effective_dt_tm DESC
  HEAD ea.encntr_id
   lcnt = 0, lpos = locateval(lidx,1,reply->encntr_cnt,ea.encntr_id,reply->encntr[lidx].encntr_id)
  HEAD ea.encntr_alias_type_cd
   IF (lpos > 0)
    lcnt = (lcnt+ 1)
    IF (mod(lcnt,10)=1)
     dstat = alterlist(reply->encntr[lpos].encntr_alias,(lcnt+ 9))
    ENDIF
    reply->encntr[lpos].encntr_alias[lcnt].encntr_alias_type_cd = ea.encntr_alias_type_cd, reply->
    encntr[lpos].encntr_alias[lcnt].alias = ea.alias
   ENDIF
  FOOT  ea.encntr_alias_type_cd
   dstat = 0
  FOOT  ea.encntr_id
   IF (lpos > 0)
    reply->encntr[lpos].encntr_alias_cnt = lcnt, dstat = alterlist(reply->encntr[lpos].encntr_alias,
     lcnt)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(lloopcnt)),
   encntr_prsnl_reltn epr,
   prsnl p
  PLAN (d
   WHERE initarray(lstart,evaluate(d.seq,1,1,(lstart+ lbatchsize))))
   JOIN (epr
   WHERE expand(lidx,lstart,(lstart+ (lbatchsize - 1)),epr.encntr_id,reply->encntr[lidx].encntr_id)
    AND epr.encntr_id > 0
    AND ((epr.active_ind+ 0)=1)
    AND ((epr.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((epr.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id)
  ORDER BY epr.encntr_id, epr.encntr_prsnl_r_cd, epr.beg_effective_dt_tm DESC
  HEAD epr.encntr_id
   lcnt = 0, lpos = locateval(lidx,1,reply->encntr_cnt,epr.encntr_id,reply->encntr[lidx].encntr_id)
  HEAD epr.encntr_prsnl_r_cd
   IF (lpos > 0)
    lcnt = (lcnt+ 1)
    IF (mod(lcnt,10)=1)
     dstat = alterlist(reply->encntr[lpos].encntr_prsnl_reltn,(lcnt+ 9))
    ENDIF
    reply->encntr[lpos].encntr_prsnl_reltn[lcnt].encntr_prsnl_r_cd = epr.encntr_prsnl_r_cd, reply->
    encntr[lpos].encntr_prsnl_reltn[lcnt].prsnl_person_id = epr.prsnl_person_id, reply->encntr[lpos].
    encntr_prsnl_reltn[lcnt].prsnl_name = p.name_full_formatted
   ENDIF
  FOOT  epr.encntr_prsnl_r_cd
   dstat = 0
  FOOT  epr.encntr_id
   IF (lpos > 0)
    reply->encntr[lpos].encntr_prsnl_reltn_cnt = lcnt, dstat = alterlist(reply->encntr[lpos].
     encntr_prsnl_reltn,lcnt)
   ENDIF
  WITH nocounter
 ;end select
 IF (size(cdi_gpd_req->person,5) > 0)
  EXECUTE cdi_get_person_demographics  WITH replace("REQUEST","CDI_GPD_REQ"), replace("REPLY",
   "CDI_GPD_REP")
  SET modify = predeclare
  IF ((cdi_gpd_rep->status_data.status="S"))
   SET reply->person_cnt = cdi_gpd_rep->person_cnt
   SET dstat = moverec(cdi_gpd_rep->person,reply->person)
  ENDIF
 ENDIF
 IF (sscriptstatus="F")
  SET sscriptstatus = "Z"
  SET sscriptmsg = "No Encounter Demographics Found"
 ENDIF
#exit_script
 SET reply->status_data.status = sscriptstatus
 IF (sscriptstatus="F")
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "FAILURE"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_get_encntr_demographics"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = sscriptmsg
 ELSEIF (sscriptstatus="Z")
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_get_encntr_demographics"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = sscriptmsg
 ELSE
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_get_encntr_demographics"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Encounter Demographics Found"
 ENDIF
 SET dstat = alterlist(reply->encntr,reply->encntr_cnt)
 CALL echo(sline)
 CALL echorecord(reply)
 CALL echo(sline)
 SET delapsedtime = ((curtime3 - dstarttime)/ 100)
 CALL echo(build2("Script elapsed time in seconds: ",trim(cnvtstring(delapsedtime,12,2),3)))
 CALL echo("Last Mod: 000")
 CALL echo("Mod Date: 10/12/2010")
 CALL echo(sline)
 SET modify = nopredeclare
 CALL echo("********** END CDI_GET_ENCNTR_DEMOGRAPHICS **********")
 CALL echo(sline)
END GO
