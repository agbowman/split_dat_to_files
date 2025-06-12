CREATE PROGRAM aps_get_signline_data_elements:dba
 RECORD reply(
   1 date_now = dq8
   1 data_elem_qual[*]
     2 display = c40
     2 code_value = f8
     2 active_ind = i2
     2 data_fmt_qual[*]
       3 fmt_cd = f8
       3 fmt_disp = c40
       3 fmt_mean = c12
       3 fmt_def = c100
       3 fmt_ex = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD req_srv_rsrc_tz(
   1 qual[*]
     2 service_resource_cd = f8
 )
 RECORD rep_srv_rsrc_tz(
   1 qual[*]
     2 service_resource_cd = f8
     2 facility_tz = i4
 )
 RECORD temp_hold_date(
   1 date_value = dq8
 )
 DECLARE time_zone_err_msg = vc WITH protect, noconstant("")
 DECLARE addtimezonerequest(service_resource_cd=f8) = null
 SUBROUTINE addtimezonerequest(service_resource_cd)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE size_rep = i4 WITH protect, noconstant(0)
   DECLARE size_req = i4 WITH protect, noconstant(0)
   SET size_rep = size(rep_srv_rsrc_tz->qual,5)
   SET size_req = size(req_srv_rsrc_tz->qual,5)
   FOR (idx = 1 TO size_rep)
     IF ((service_resource_cd=rep_srv_rsrc_tz->qual[idx].service_resource_cd))
      RETURN
     ENDIF
   ENDFOR
   FOR (idx = 1 TO size_req)
     IF ((service_resource_cd=req_srv_rsrc_tz->qual[idx].service_resource_cd))
      RETURN
     ENDIF
   ENDFOR
   SET size_req = (size_req+ 1)
   SET stat = alterlist(req_srv_rsrc_tz->qual,size_req)
   SET req_srv_rsrc_tz->qual[size_req].service_resource_cd = service_resource_cd
 END ;Subroutine
 DECLARE getrequestedtimezone(service_resource_cd=f8) = i4
 SUBROUTINE getrequestedtimezone(service_resource_cd)
   DECLARE idx = i4 WITH protect, noconstant(0)
   FOR (idx = 1 TO size(rep_srv_rsrc_tz->qual,5))
     IF ((rep_srv_rsrc_tz->qual[idx].service_resource_cd=service_resource_cd))
      RETURN(rep_srv_rsrc_tz->qual[idx].facility_tz)
     ENDIF
   ENDFOR
   RETURN(curtimezoneapp)
 END ;Subroutine
 DECLARE loadrequestedtimezone() = i4
 SUBROUTINE loadrequestedtimezone(null)
   DECLARE lapp_num = i4 WITH protect, constant(5000)
   DECLARE ltask_num = i4 WITH protect, constant(1050001)
   DECLARE lreq_num = i4 WITH protect, constant(1050064)
   DECLARE ecrmok = i2 WITH protect, constant(0)
   DECLARE happ = i4 WITH protect, noconstant(0)
   DECLARE htask = i4 WITH protect, noconstant(0)
   DECLARE hstep = i4 WITH protect, noconstant(0)
   DECLARE hreq = i4 WITH protect, noconstant(0)
   DECLARE hrep = i4 WITH protect, noconstant(0)
   DECLARE hstatusdata = i4 WITH protect, noconstant(0)
   DECLARE ncrmstat = i2 WITH protect, noconstant(0)
   DECLARE nsrvstat = i2 WITH protect, noconstant(0)
   DECLARE sstatus = c1 WITH protect, noconstant(" ")
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE size_req = i4 WITH protect, noconstant(0)
   SET size_req = size(req_srv_rsrc_tz->qual,5)
   IF (size_req=0)
    RETURN(1)
   ELSE
    SET ncrmstat = uar_crmbeginapp(lapp_num,happ)
    IF (((ncrmstat != ecrmok) OR (happ=0)) )
     SET time_zone_err_msg = build("CrmBeginApp returned:",ncrmstat)
     RETURN(0)
    ENDIF
    SET ncrmstat = uar_crmbegintask(happ,ltask_num,htask)
    IF (((ncrmstat != ecrmok) OR (htask=0)) )
     SET time_zone_err_msg = build("CrmBeginTask returned:",ncrmstat)
     CALL exit_1050064(happ,htask,hreq)
     RETURN(0)
    ENDIF
    FOR (idx = 1 TO size_req)
      SET ncrmstat = uar_crmbeginreq(htask,0,lreq_num,hstep)
      IF (((ncrmstat != ecrmok) OR (hstep=0)) )
       SET time_zone_err_msg = build("CrmBeginReq returned:",ncrmstat)
       CALL exit_1050064(happ,htask,hreq)
       RETURN(0)
      ENDIF
      SET hreq = uar_crmgetrequest(hstep)
      IF (hreq=0)
       SET time_zone_err_msg = build("CrmGetRequest returned:",ncrmstat)
       CALL exit_1050064(happ,htask,hreq)
       RETURN(0)
      ENDIF
      SET nsrvstat = uar_srvsetdouble(hreq,"service_resource_cd",req_srv_rsrc_tz->qual[idx].
       service_resource_cd)
      SET ncrmstat = uar_crmperform(hstep)
      IF (ncrmstat=ecrmok)
       SET hrep = uar_crmgetreply(hstep)
       SET hstatusdata = uar_srvgetstruct(hrep,"status_data")
       SET sstatus = uar_srvgetstringptr(hstatusdata,"status")
       IF (sstatus="S")
        SET stat = alterlist(rep_srv_rsrc_tz->qual,(size(rep_srv_rsrc_tz->qual,5)+ 1))
        SET rep_srv_rsrc_tz->qual[size(rep_srv_rsrc_tz->qual,5)].facility_tz = uar_srvgetdouble(hrep,
         "time_zone")
        SET rep_srv_rsrc_tz->qual[size(rep_srv_rsrc_tz->qual,5)].service_resource_cd =
        req_srv_rsrc_tz->qual[idx].service_resource_cd
        IF (hreq != 0)
         SET ncrmstat = uar_crmendreq(hstep)
        ENDIF
       ELSE
        SET time_zone_err_msg = build("CrmGetReply returned:",ncrmstat)
        CALL exit_1050064(happ,htask,hreq)
        RETURN(0)
       ENDIF
      ELSE
       SET time_zone_err_msg = build("CrmPerform returned:",ncrmstat)
       CALL exit_1050064(happ,htask,hreq)
       RETURN(0)
      ENDIF
    ENDFOR
    CALL exit_1050064(happ,htask,hreq)
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE exit_1050064(happ,htask,hreq)
   IF (hreq != 0)
    SET ncrmstat = uar_crmendreq(hstep)
   ENDIF
   IF (htask != 0)
    SET ncrmstat = uar_crmendtask(htask)
   ENDIF
   IF (happ != 0)
    SET ncrmstat = uar_crmendapp(happ)
   ENDIF
 END ;Subroutine
 DECLARE gettimezoneshortname(tz=i4) = vc
 SUBROUTINE gettimezoneshortname(tz)
   DECLARE offset = i4 WITH protect, noconstant(0)
   DECLARE daylight = i4 WITH protect, noconstant(0)
   DECLARE short_name = vc WITH protect, noconstant("")
   IF ((temp_hold_date->date_value > 0.0))
    SET short_name = datetimezonebyindex(tz,offset,daylight,7,temp_hold_date->date_value)
   ELSE
    SET short_name = datetimezonebyindex(tz,offset,daylight,7)
   ENDIF
   RETURN(short_name)
 END ;Subroutine
 DECLARE gettimezoneerrmsg() = vc
 SUBROUTINE gettimezoneerrmsg(null)
   RETURN(time_zone_err_msg)
 END ;Subroutine
 DECLARE formatname(formatdesc=vc,retstring=vc(ref),firstname=vc,middlename=vc,lastname=vc,
  namefullformat=vc) = null WITH protect
 SUBROUTINE formatname(formatdesc,retstring,firstname,middlename,lastname,namefullformat)
   DECLARE iposnameformat = i4 WITH noconstant(0)
   DECLARE curpos = i4 WITH noconstant(0)
   DECLARE nextpos = i4 WITH noconstant(0)
   DECLARE sresult = vc WITH noconstant("")
   DECLARE token = vc WITH noconstant("")
   DECLARE bcontinueloop = i2 WITH noconstant(1)
   SET retstring = ""
   SET iposnameformat = findstring("#NameFormat#",formatdesc)
   IF (iposnameformat=0)
    SET sresult = namefullformat
   ELSE
    SET iformatdesclen = textlen(trim(formatdesc))
    SET curpos = findstring("#",formatdesc,(iposnameformat+ 1),0)
    SET nextpos = findstring("%",formatdesc,1,0)
    IF (nextpos=0)
     SET token = notrim(substring((curpos+ 1),((iformatdesclen - curpos) - 1),formatdesc))
     IF (sresult="")
      SET sresult = notrim(token)
     ELSE
      SET sresult = notrim(build2(notrim(sresult),notrim(token)))
     ENDIF
    ELSE
     SET bcontinueloop = 1
     WHILE (((curpos+ 1) <= iformatdesclen)
      AND bcontinueloop != 0)
       SET token = notrim(substring((curpos+ 1),((nextpos - curpos) - 1),formatdesc))
       IF (token="FN")
        IF (sresult="")
         SET sresult = trim(firstname)
        ELSE
         SET sresult = notrim(build2(notrim(sresult),trim(firstname)))
        ENDIF
       ELSEIF (token="MN")
        IF (sresult="")
         SET sresult = trim(middlename)
        ELSE
         SET sresult = notrim(build2(notrim(sresult),trim(middlename)))
        ENDIF
       ELSEIF (token="LN")
        IF (sresult="")
         SET sresult = trim(lastname)
        ELSE
         SET sresult = notrim(build2(notrim(sresult),trim(lastname)))
        ENDIF
       ELSEIF (token="NFF")
        IF (sresult="")
         SET sresult = namefullformat
        ELSE
         SET sresult = notrim(build2(notrim(sresult),trim(namefullformat)))
        ENDIF
       ELSE
        IF (sresult="")
         SET sresult = notrim(token)
        ELSE
         SET sresult = notrim(build2(notrim(sresult),notrim(token)))
        ENDIF
       ENDIF
       SET curpos = nextpos
       SET nextpos = findstring("%",formatdesc,(curpos+ 1),0)
       IF (nextpos=0)
        SET token = notrim(substring((curpos+ 1),((iformatdesclen - curpos) - 1),formatdesc))
        SET bcontinueloop = 0
        IF (sresult="")
         SET sresult = notrim(token)
        ELSE
         SET sresult = notrim(build2(notrim(sresult),notrim(token)))
        ENDIF
       ENDIF
     ENDWHILE
    ENDIF
   ENDIF
   SET retstring = notrim(sresult)
 END ;Subroutine
#script
 SET reply->status_data.status = "F"
 SET elem_cnt = 0
 SET data_elem_string = fillstring(50," ")
 SET data_elem_string = build(cnvtupper(cnvtalphanum(request->data_elem)),"*")
 SET data_elem_string = concat("CV1.CDF_MEANING = PATSTRING('",trim(data_elem_string),"')")
 SELECT INTO "nl:"
  cv2_exists = evaluate(nullind(cv2.code_value),1,0,1)
  FROM code_value cv1,
   code_value cv2,
   code_value_group cvg
  PLAN (cv1
   WHERE cv1.code_set=14287
    AND parser(data_elem_string))
   JOIN (cvg
   WHERE cvg.parent_code_value=outerjoin(cv1.code_value))
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(cvg.child_code_value))
  ORDER BY cv1.display, cv1.code_value
  HEAD REPORT
   elem_cnt = 0, stat = alterlist(reply->data_elem_qual,10), reply->date_now = cnvtdatetime(curdate,
    curtime3)
  HEAD cv1.code_value
   fmt_cnt = 0, elem_cnt = (elem_cnt+ 1)
   IF (mod(elem_cnt,10)=1)
    stat = alterlist(reply->data_elem_qual,(elem_cnt+ 9))
   ENDIF
   reply->data_elem_qual[elem_cnt].display = cv1.display, reply->data_elem_qual[elem_cnt].code_value
    = cv1.code_value, reply->data_elem_qual[elem_cnt].active_ind = cv1.active_ind
  DETAIL
   IF (cv2_exists=1)
    fmt_cnt = (fmt_cnt+ 1)
    IF (mod(fmt_cnt,10)=1)
     stat = alterlist(reply->data_elem_qual[elem_cnt].data_fmt_qual,(fmt_cnt+ 9))
    ENDIF
    reply->data_elem_qual[elem_cnt].data_fmt_qual[fmt_cnt].fmt_cd = cv2.code_value, reply->
    data_elem_qual[elem_cnt].data_fmt_qual[fmt_cnt].fmt_def = cv2.description
   ENDIF
  FOOT  cv1.code_value
   stat = alterlist(reply->data_elem_qual[elem_cnt].data_fmt_qual,fmt_cnt)
  FOOT REPORT
   stat = alterlist(reply->data_elem_qual,elem_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE_GROUP"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET x = 0
 SET y = 0
 SET qual_size1 = 0
 SET qual_size2 = 0
 DECLARE date_example = vc
 DECLARE date_mask = vc
 DECLARE time_mask = vc
 DECLARE time_now = vc
 DECLARE name_example = vc WITH noconstant("")
 IF (curutc=1)
  SET local_datetime = datetimezone(reply->date_now,curtimezoneapp)
 ELSE
  SET local_datetime = reply->date_now
 ENDIF
 SET temp_hold_date->date_value = cnvtdatetime(local_datetime)
 SET qual_size1 = cnvtint(size(reply->data_elem_qual,5))
 FOR (x = 1 TO qual_size1)
  SET qual_size2 = cnvtint(size(reply->data_elem_qual[x].data_fmt_qual,5))
  FOR (y = 1 TO qual_size2)
    IF ((reply->data_elem_qual[x].data_fmt_qual[y].fmt_cd > 0))
     SET iposnameformat = findstring("#NameFormat#",reply->data_elem_qual[x].data_fmt_qual[y].fmt_def
      )
     IF (iposnameformat != 0)
      CALL formatname(reply->data_elem_qual[x].data_fmt_qual[y].fmt_def,name_example,"John","Thomas",
       "Smith",
       "")
      SET reply->data_elem_qual[x].data_fmt_qual[y].fmt_ex = name_example
     ELSE
      SET findptf = findstring("|",reply->data_elem_qual[x].data_fmt_qual[y].fmt_def)
      IF (findptf=0)
       SET date_mask = reply->data_elem_qual[x].data_fmt_qual[y].fmt_def
       SET date_example = format(local_datetime,date_mask)
       CALL echo(build("date_mask :",date_mask))
       CALL echo(build("date :",date_example))
      ELSE
       SET findptl = findstring("|",reply->data_elem_qual[x].data_fmt_qual[y].fmt_def,1,1)
       SET deflength = textlen(trim(reply->data_elem_qual[x].data_fmt_qual[y].fmt_def))
       SET date_mask = substring(1,(findptf - 1),reply->data_elem_qual[x].data_fmt_qual[y].fmt_def)
       IF (findptl != findptf)
        SET time_mask = substring((findptf+ 1),((findptl - 1) - findptf),reply->data_elem_qual[x].
         data_fmt_qual[y].fmt_def)
        SET zone_mask = substring((findptl+ 1),deflength,reply->data_elem_qual[x].data_fmt_qual[y].
         fmt_def)
        SET zone_now = gettimezoneshortname(curtimezoneapp)
       ELSE
        SET time_mask = substring((findptf+ 1),deflength,reply->data_elem_qual[x].data_fmt_qual[y].
         fmt_def)
       ENDIF
       IF (substring(textlen(trim(time_mask)),textlen(trim(time_mask)),reply->data_elem_qual[x].
        data_fmt_qual[y].fmt_def)="S")
        SET time_now = format(local_datetime,time_mask)
        IF (substring(1,1,time_now)="0")
         SET time_now = substring(2,textlen(time_now),time_now)
        ENDIF
       ELSE
        SET time_now = format(local_datetime,time_mask)
       ENDIF
       IF (findptl != findptf)
        SET date_example = concat(format(local_datetime,date_mask)," ",time_now," ",zone_now)
       ELSE
        SET date_example = concat(format(local_datetime,date_mask)," ",time_now)
       ENDIF
      ENDIF
      SET reply->data_elem_qual[x].data_fmt_qual[y].fmt_ex = date_example
     ENDIF
    ENDIF
  ENDFOR
 ENDFOR
END GO
