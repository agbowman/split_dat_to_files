CREATE PROGRAM cdi_get_person_demographics:dba
 SET modify = predeclare
 EXECUTE cdi_get_person_demographics_rr
 DECLARE lreq_size = i4 WITH protect, constant(size(request->person,5))
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
 DECLARE lpcnt = i4 WITH protect, noconstant(0)
 DECLARE sscriptstatus = c1 WITH protect, noconstant("F")
 DECLARE sscriptmsg = vc WITH protect, noconstant("Script Error")
 CALL echo(sline)
 CALL echo("********** BEGIN CDI_GET_PERSON_DEMOGRAPHICS **********")
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
 SET dstat = alterlist(request->person,lnewlistsize)
 SET lstart = 1
 FOR (lidx = (lcurlistsize+ 1) TO lnewlistsize)
   SET request->person[lidx].person_id = request->person[lcurlistsize].person_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(lloopcnt)),
   person p
  PLAN (d
   WHERE initarray(lstart,evaluate(d.seq,1,1,(lstart+ lbatchsize))))
   JOIN (p
   WHERE expand(lidx,lstart,(lstart+ (lbatchsize - 1)),p.person_id,request->person[lidx].person_id)
    AND p.person_id > 0
    AND ((p.active_ind+ 0)=1)
    AND ((p.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((p.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
  ORDER BY p.person_id
  HEAD REPORT
   lpcnt = 0
  HEAD p.person_id
   lpos = locateval(lidx,1,lpcnt,p.person_id,reply->person[lidx].person_id)
   IF (lpos=0)
    lpcnt = (lpcnt+ 1)
    IF (mod(lpcnt,10)=1)
     dstat = alterlist(reply->person,(lpcnt+ 9))
    ENDIF
    reply->person[lpcnt].person_id = p.person_id, reply->person[lpcnt].name_full_formatted = p
    .name_full_formatted, reply->person[lpcnt].birth_date = p.birth_dt_tm,
    reply->person[lpcnt].birth_tz = p.birth_tz, reply->person[lpcnt].age = cnvtage(p.birth_dt_tm),
    reply->person[lpcnt].gender = uar_get_code_display(p.sex_cd),
    reply->person[lpcnt].person_type = uar_get_code_display(p.person_type_cd), reply->person[lpcnt].
    language = uar_get_code_display(p.language_cd), reply->person[lpcnt].nationality =
    uar_get_code_display(p.nationality_cd),
    reply->person[lpcnt].marital_status = uar_get_code_display(p.marital_type_cd), reply->person[
    lpcnt].mother_maiden_name = p.mother_maiden_name, reply->person[lpcnt].vip = uar_get_code_display
    (p.vip_cd),
    sscriptstatus = "S"
   ENDIF
  FOOT REPORT
   reply->person_cnt = lpcnt, dstat = alterlist(reply->person,lpcnt)
  WITH nocounter
 ;end select
 SET dstat = alterlist(request->person,lreq_size)
 IF ((reply->person_cnt=0))
  SET sscriptstatus = "Z"
  SET sscriptmsg = "No Person Demographics Found"
  GO TO exit_script
 ENDIF
 SET lcurlistsize = reply->person_cnt
 SET lloopcnt = ceil((cnvtreal(lcurlistsize)/ lbatchsize))
 SET lnewlistsize = (lloopcnt * lbatchsize)
 SET dstat = alterlist(reply->person,lnewlistsize)
 SET lstart = 1
 FOR (lidx = (lcurlistsize+ 1) TO lnewlistsize)
   SET reply->person[lidx].person_id = reply->person[lcurlistsize].person_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(lloopcnt)),
   address a
  PLAN (d
   WHERE initarray(lstart,evaluate(d.seq,1,1,(lstart+ lbatchsize))))
   JOIN (a
   WHERE expand(lidx,lstart,(lstart+ (lbatchsize - 1)),a.parent_entity_id,reply->person[lidx].
    person_id)
    AND a.parent_entity_id > 0
    AND a.parent_entity_name="PERSON"
    AND ((a.active_ind+ 0)=1)
    AND ((a.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((a.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
  ORDER BY a.parent_entity_id, a.beg_effective_dt_tm DESC
  HEAD a.parent_entity_id
   lpos = locateval(lidx,1,reply->person_cnt,a.parent_entity_id,reply->person[lidx].person_id)
   IF (lpos > 0)
    reply->person[lpos].address = a.street_addr, reply->person[lpos].address_2 = a.street_addr2,
    reply->person[lpos].city = a.city,
    reply->person[lpos].state = a.state, reply->person[lpos].zip_code = a.zipcode
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(lloopcnt)),
   phone p
  PLAN (d
   WHERE initarray(lstart,evaluate(d.seq,1,1,(lstart+ lbatchsize))))
   JOIN (p
   WHERE expand(lidx,lstart,(lstart+ (lbatchsize - 1)),p.parent_entity_id,reply->person[lidx].
    person_id)
    AND p.parent_entity_id > 0
    AND p.parent_entity_name="PERSON"
    AND ((p.active_ind+ 0)=1)
    AND ((p.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((p.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
  ORDER BY p.parent_entity_id, p.beg_effective_dt_tm DESC
  HEAD p.parent_entity_id
   lpos = locateval(lidx,1,reply->person_cnt,p.parent_entity_id,reply->person[lidx].person_id)
   IF (lpos > 0)
    reply->person[lpos].phone = cnvtphone(p.phone_num,p.phone_format_cd)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(lloopcnt)),
   person_alias pa
  PLAN (d
   WHERE initarray(lstart,evaluate(d.seq,1,1,(lstart+ lbatchsize))))
   JOIN (pa
   WHERE expand(lidx,lstart,(lstart+ (lbatchsize - 1)),pa.person_id,reply->person[lidx].person_id)
    AND pa.person_id > 0
    AND ((pa.active_ind+ 0)=1)
    AND ((pa.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((pa.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
  ORDER BY pa.person_id, pa.person_alias_type_cd, pa.beg_effective_dt_tm DESC
  HEAD pa.person_id
   lcnt = 0, lpos = locateval(lidx,1,reply->person_cnt,pa.person_id,reply->person[lidx].person_id)
  HEAD pa.person_alias_type_cd
   IF (lpos > 0)
    lcnt = (lcnt+ 1)
    IF (mod(lcnt,10)=1)
     dstat = alterlist(reply->person[lpos].person_alias,(lcnt+ 9))
    ENDIF
    reply->person[lpos].person_alias[lcnt].person_alias_type_cd = pa.person_alias_type_cd, reply->
    person[lpos].person_alias[lcnt].alias = pa.alias
   ENDIF
  FOOT  pa.person_alias_type_cd
   dstat = 0
  FOOT  pa.person_id
   IF (lpos > 0)
    reply->person[lpos].person_alias_cnt = lcnt, dstat = alterlist(reply->person[lpos].person_alias,
     lcnt)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(lloopcnt)),
   person_prsnl_reltn ppr,
   prsnl p
  PLAN (d
   WHERE initarray(lstart,evaluate(d.seq,1,1,(lstart+ lbatchsize))))
   JOIN (ppr
   WHERE expand(lidx,lstart,(lstart+ (lbatchsize - 1)),ppr.person_id,reply->person[lidx].person_id)
    AND ppr.person_id > 0
    AND ((ppr.active_ind+ 0)=1)
    AND ((ppr.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((ppr.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
   JOIN (p
   WHERE p.person_id=ppr.prsnl_person_id)
  ORDER BY ppr.person_id, ppr.person_prsnl_r_cd, ppr.beg_effective_dt_tm DESC
  HEAD ppr.person_id
   lcnt = 0, lpos = locateval(lidx,1,reply->person_cnt,ppr.person_id,reply->person[lidx].person_id)
  HEAD ppr.person_prsnl_r_cd
   IF (lpos > 0)
    lcnt = (lcnt+ 1)
    IF (mod(lcnt,10)=1)
     dstat = alterlist(reply->person[lpos].person_prsnl_reltn,(lcnt+ 9))
    ENDIF
    reply->person[lpos].person_prsnl_reltn[lcnt].person_prsnl_r_cd = ppr.person_prsnl_r_cd, reply->
    person[lpos].person_prsnl_reltn[lcnt].prsnl_person_id = ppr.prsnl_person_id, reply->person[lpos].
    person_prsnl_reltn[lcnt].prsnl_name = p.name_full_formatted
   ENDIF
  FOOT  ppr.person_prsnl_r_cd
   dstat = 0
  FOOT  ppr.person_id
   IF (lpos > 0)
    reply->person[lpos].person_prsnl_reltn_cnt = lcnt, dstat = alterlist(reply->person[lpos].
     person_prsnl_reltn,lcnt)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(lloopcnt)),
   person_name pn
  PLAN (d
   WHERE initarray(lstart,evaluate(d.seq,1,1,(lstart+ lbatchsize))))
   JOIN (pn
   WHERE expand(lidx,lstart,(lstart+ (lbatchsize - 1)),pn.person_id,reply->person[lidx].person_id)
    AND pn.person_id > 0
    AND ((pn.active_ind+ 0)=1)
    AND ((pn.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((pn.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3)))
  ORDER BY pn.person_id, pn.name_type_cd, pn.beg_effective_dt_tm DESC
  HEAD pn.person_id
   lcnt = 0, lpos = locateval(lidx,1,lreq_size,pn.person_id,reply->person[lidx].person_id)
  HEAD pn.name_type_cd
   IF (lpos > 0)
    lcnt = (lcnt+ 1)
    IF (mod(lcnt,10)=1)
     dstat = alterlist(reply->person[lpos].person_name,(lcnt+ 9))
    ENDIF
    reply->person[lpos].person_name[lcnt].name_type_cd = pn.name_type_cd, reply->person[lpos].
    person_name[lcnt].name_full = pn.name_full
   ENDIF
  FOOT  pn.name_type_cd
   dstat = 0
  FOOT  pn.person_id
   IF (lpos > 0)
    reply->person[lpos].person_name_cnt = lcnt, dstat = alterlist(reply->person[lpos].person_name,
     lcnt)
   ENDIF
  WITH nocounter
 ;end select
 IF (sscriptstatus="F")
  SET sscriptstatus = "Z"
  SET sscriptmsg = "No Person Demographics Found"
 ENDIF
#exit_script
 SET reply->status_data.status = sscriptstatus
 IF (sscriptstatus="F")
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "FAILURE"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_get_person_demographics"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = sscriptmsg
 ELSEIF (sscriptstatus="Z")
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_get_person_demographics"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = sscriptmsg
 ELSE
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_get_person_demographics"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Person Demographics Found"
 ENDIF
 SET dstat = alterlist(reply->person,reply->person_cnt)
 CALL echo(sline)
 CALL echorecord(reply)
 CALL echo(sline)
 SET delapsedtime = ((curtime3 - dstarttime)/ 100)
 CALL echo(build2("Script elapsed time in seconds: ",trim(cnvtstring(delapsedtime,12,2),3)))
 CALL echo("Last Mod: 000")
 CALL echo("Mod Date: 10/12/2010")
 CALL echo(sline)
 SET modify = nopredeclare
 CALL echo("********** END CDI_GET_PERSON_DEMOGRAPHICS **********")
 CALL echo(sline)
END GO
