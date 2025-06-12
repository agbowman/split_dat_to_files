CREATE PROGRAM bb_get_qc_group_results:dba
 SUBROUTINE (findnextdailyschedule(linterval=i4,ltime=i4,dtstartdttm=f8,nfirstschedule=i2) =f8)
   DECLARE sinterval = c3 WITH protect, noconstant("")
   DECLARE smonth = c3 WITH protect, noconstant("")
   DECLARE nday = i2 WITH protect, noconstant(0)
   DECLARE lyear = i4 WITH protect, noconstant(0)
   DECLARE snewdttm = vc WITH protect, noconstant("")
   DECLARE dtnewdttm = f8 WITH protect, noconstant(0.0)
   DECLARE stime = vc WITH protect, noconstant("")
   IF (linterval=0)
    CALL echo("lInterval = 0")
    RETURN(0.0)
   ELSEIF (ltime=0)
    CALL echo("lTime = 0")
    RETURN(0.0)
   ELSEIF (dtstartdttm=0.0)
    CALL echo("dtStartDtTm = 0")
    RETURN(0.0)
   ENDIF
   CALL echo(build("StartDtTm: ",format(dtstartdttm,";;Q")))
   SET stime = format(ltime,"HH:MM;;M")
   IF (nfirstschedule=1)
    SET smonth = format(dtstartdttm,"MMM;;D")
    SET nday = day(dtstartdttm)
    SET lyear = year(dtstartdttm)
    SET snewdttm = build(nday,"-",smonth,"-",lyear)
    SET snewdttm = concat(snewdttm," ",stime)
    SET dtnewdttm = cnvtdatetime(snewdttm)
    IF (dtnewdttm < dtstartdttm)
     SET dtnewdttm = cnvtlookahead("1D",dtnewdttm)
    ENDIF
   ELSE
    SET sinterval = build(linterval,"D")
    SET dtnewdttm = cnvtlookahead(sinterval,cnvtdatetime(cnvtdate(dtstartdttm),ltime))
   ENDIF
   CALL echo(build("NewDtTm: ",format(dtnewdttm,";;Q")))
   RETURN(dtnewdttm)
 END ;Subroutine
 SUBROUTINE (findnextweeklyschedule(ldayofweekbit=i4,ltime=i4,dtstartdttm=f8,linterval=i4) =f8)
   DECLARE nsunday = i2 WITH protect, constant(0)
   DECLARE nmonday = i2 WITH protect, constant(1)
   DECLARE ntuesday = i2 WITH protect, constant(2)
   DECLARE nwednesday = i2 WITH protect, constant(3)
   DECLARE nthursday = i2 WITH protect, constant(4)
   DECLARE nfriday = i2 WITH protect, constant(5)
   DECLARE nsaturday = i2 WITH protect, constant(6)
   DECLARE nbitmonday = i2 WITH protect, constant(1)
   DECLARE nbittuesday = i2 WITH protect, constant(2)
   DECLARE nbitwednesday = i2 WITH protect, constant(4)
   DECLARE nbitthursday = i2 WITH protect, constant(8)
   DECLARE nbitfriday = i2 WITH protect, constant(16)
   DECLARE nbitsaturday = i2 WITH protect, constant(32)
   DECLARE nbitsunday = i2 WITH protect, constant(64)
   DECLARE nweekday = i2 WITH protect, noconstant(0)
   DECLARE stime = vc WITH protect, noconstant("")
   DECLARE ndayincrement = i2 WITH protect, noconstant(0)
   DECLARE dtnewdttm = f8 WITH protect, noconstant(0.0)
   DECLARE dtholddttm = f8 WITH protect, noconstant(0.0)
   DECLARE sholddttm = vc WITH protect, noconstant("")
   IF (linterval=0)
    CALL echo("lInterval = 0")
    RETURN(0.0)
   ELSEIF (ltime=0)
    CALL echo("lTime = 0")
    RETURN(0.0)
   ELSEIF (dtstartdttm=0.0)
    CALL echo("dtStartDtTm = 0")
    RETURN(0.0)
   ELSEIF (ldayofweekbit=0)
    CALL echo("lDayOfWeekBit = 0")
    RETURN(0.0)
   ENDIF
   SET nweekday = weekday(dtstartdttm)
   SET stime = format(ltime,"##:##")
   CALL echo(build("StartDtTm:",format(dtstartdttm,";;Q")))
   FOR (i = 0 TO 6)
     IF (band(ldayofweekbit,nbitsunday)=nbitsunday
      AND i=nsunday)
      SET ndayincrement = (nsunday - nweekday)
      IF (ndayincrement > 0)
       SET dtholddttm = cnvtlookahead(build(ndayincrement,"D"),dtstartdttm)
      ELSE
       SET dtholddttm = cnvtlookahead(build((ndayincrement+ (7 * linterval)),"D"),dtstartdttm)
      ENDIF
      SET sholddttm = build(day(dtholddttm),"-",format(dtholddttm,"MMM;;D"),"-",year(dtholddttm))
      SET sholddttm = concat(sholddttm," ",stime)
      SET dtholddttm = cnvtdatetime(sholddttm)
      IF (dtholddttm > dtstartdttm
       AND ((dtholddttm < dtnewdttm) OR (dtnewdttm=0.0)) )
       SET dtnewdttm = dtholddttm
      ENDIF
     ENDIF
     IF (band(ldayofweekbit,nbitmonday)=nbitmonday
      AND i=nmonday)
      SET ndayincrement = (nmonday - nweekday)
      IF (ndayincrement > 0)
       SET dtholddttm = cnvtlookahead(build(ndayincrement,"D"),dtstartdttm)
      ELSE
       SET dtholddttm = cnvtlookahead(build((ndayincrement+ (7 * linterval)),"D"),dtstartdttm)
      ENDIF
      SET sholddttm = build(day(dtholddttm),"-",format(dtholddttm,"MMM;;D"),"-",year(dtholddttm))
      SET sholddttm = concat(sholddttm," ",stime)
      SET dtholddttm = cnvtdatetime(sholddttm)
      IF (dtholddttm > dtstartdttm
       AND ((dtholddttm < dtnewdttm) OR (dtnewdttm=0.0)) )
       SET dtnewdttm = dtholddttm
      ENDIF
     ENDIF
     IF (band(ldayofweekbit,nbittuesday)=nbittuesday
      AND i=ntuesday)
      SET ndayincrement = (ntuesday - nweekday)
      IF (ndayincrement > 0)
       SET dtholddttm = cnvtlookahead(build(ndayincrement,"D"),dtstartdttm)
      ELSE
       SET dtholddttm = cnvtlookahead(build((ndayincrement+ (7 * linterval)),"D"),dtstartdttm)
      ENDIF
      SET sholddttm = build(day(dtholddttm),"-",format(dtholddttm,"MMM;;D"),"-",year(dtholddttm))
      SET sholddttm = concat(sholddttm," ",stime)
      SET dtholddttm = cnvtdatetime(sholddttm)
      IF (dtholddttm > dtstartdttm
       AND ((dtholddttm < dtnewdttm) OR (dtnewdttm=0.0)) )
       SET dtnewdttm = dtholddttm
      ENDIF
     ENDIF
     IF (band(ldayofweekbit,nbitwednesday)=nbitwednesday
      AND i=nwednesday)
      SET ndayincrement = (nwednesday - nweekday)
      IF (ndayincrement > 0)
       SET dtholddttm = cnvtlookahead(build(ndayincrement,"D"),dtstartdttm)
      ELSE
       SET dtholddttm = cnvtlookahead(build((ndayincrement+ (7 * linterval)),"D"),dtstartdttm)
      ENDIF
      SET sholddttm = build(day(dtholddttm),"-",format(dtholddttm,"MMM;;D"),"-",year(dtholddttm))
      SET sholddttm = concat(sholddttm," ",stime)
      SET dtholddttm = cnvtdatetime(sholddttm)
      IF (dtholddttm > dtstartdttm
       AND ((dtholddttm < dtnewdttm) OR (dtnewdttm=0.0)) )
       SET dtnewdttm = dtholddttm
      ENDIF
     ENDIF
     IF (band(ldayofweekbit,nbitthursday)=nbitthursday
      AND i=nthursday)
      SET ndayincrement = (nthursday - nweekday)
      IF (ndayincrement > 0)
       SET dtholddttm = cnvtlookahead(build(ndayincrement,"D"),dtstartdttm)
      ELSE
       SET dtholddttm = cnvtlookahead(build((ndayincrement+ (7 * linterval)),"D"),dtstartdttm)
      ENDIF
      SET sholddttm = build(day(dtholddttm),"-",format(dtholddttm,"MMM;;D"),"-",year(dtholddttm))
      SET sholddttm = concat(sholddttm," ",stime)
      SET dtholddttm = cnvtdatetime(sholddttm)
      IF (dtholddttm > dtstartdttm
       AND ((dtholddttm < dtnewdttm) OR (dtnewdttm=0.0)) )
       SET dtnewdttm = dtholddttm
      ENDIF
     ENDIF
     IF (band(ldayofweekbit,nbitfriday)=nbitfriday
      AND i=nfriday)
      SET ndayincrement = (nfriday - nweekday)
      IF (ndayincrement > 0)
       SET dtholddttm = cnvtlookahead(build(ndayincrement,"D"),dtstartdttm)
      ELSE
       SET dtholddttm = cnvtlookahead(build((ndayincrement+ (7 * linterval)),"D"),dtstartdttm)
      ENDIF
      SET sholddttm = build(day(dtholddttm),"-",format(dtholddttm,"MMM;;D"),"-",year(dtholddttm))
      SET sholddttm = concat(sholddttm," ",stime)
      SET dtholddttm = cnvtdatetime(sholddttm)
      IF (dtholddttm > dtstartdttm
       AND ((dtholddttm < dtnewdttm) OR (dtnewdttm=0.0)) )
       SET dtnewdttm = dtholddttm
      ENDIF
     ENDIF
     IF (band(ldayofweekbit,nbitsaturday)=nbitsaturday
      AND i=nsaturday)
      SET ndayincrement = (nsaturday - nweekday)
      IF (ndayincrement > 0)
       SET dtholddttm = cnvtlookahead(build(ndayincrement,"D"),dtstartdttm)
      ELSE
       SET dtholddttm = cnvtlookahead(build((ndayincrement+ (7 * linterval)),"D"),dtstartdttm)
      ENDIF
      SET sholddttm = build(day(dtholddttm),"-",format(dtholddttm,"MMM;;D"),"-",year(dtholddttm))
      SET sholddttm = concat(sholddttm," ",stime)
      SET dtholddttm = cnvtdatetime(sholddttm)
      IF (dtholddttm > dtstartdttm
       AND ((dtholddttm < dtnewdttm) OR (dtnewdttm=0.0)) )
       SET dtnewdttm = dtholddttm
      ENDIF
     ENDIF
   ENDFOR
   CALL echo(build("NewDtTm:",format(dtnewdttm,";;Q")))
   RETURN(dtnewdttm)
 END ;Subroutine
 SUBROUTINE (findnextmonthlyschedule1(linterval=i4,ndayofmonth=i2,ltime=i4,dtstartdttm=f8,
  nfirstschedule=i2) =f8)
   DECLARE sinterval = c3 WITH protect, noconstant("")
   DECLARE smonth = c3 WITH protect, noconstant("")
   DECLARE nday = i2 WITH protect, noconstant(0)
   DECLARE lyear = i4 WITH protect, noconstant(0)
   DECLARE snewdttm = vc WITH protect, noconstant("")
   DECLARE dtnewdttm = f8 WITH protect, noconstant(0.0)
   DECLARE stime = vc WITH protect, noconstant("")
   IF (linterval=0)
    CALL echo("lInterval = 0")
    RETURN(0.0)
   ELSEIF (ltime=0)
    CALL echo("lTime = 0")
    RETURN(0.0)
   ELSEIF (dtstartdttm=0.0)
    CALL echo("dtStartDtTm = 0")
    RETURN(0.0)
   ELSEIF (ndayofmonth=0)
    CALL echo("nDayOfMonth = 0")
    RETURN(0.0)
   ENDIF
   SET sinterval = build(linterval,"M")
   SET stime = format(ltime,"##:##")
   CALL echo(build("StartDtTm:",format(dtstartdttm,";;Q")))
   IF (nfirstschedule=1)
    SET smonth = format(dtstartdttm,"MMM;;D")
    SET lyear = year(dtstartdttm)
    SET snewdttm = build(ndayofmonth,"-",smonth,"-",lyear)
    SET snewdttm = concat(snewdttm," ",stime)
    SET dtnewdttm = cnvtdatetime(snewdttm)
    IF (dtnewdttm > dtstartdttm)
     SET smonth = format(dtstartdttm,"MMM;;D")
     SET nday = ndayofmonth
     SET lyear = year(dtstartdttm)
    ELSE
     SET dtnewdttm = cnvtlookahead(sinterval,dtstartdttm)
     SET smonth = format(dtnewdttm,"MMM;;D")
     SET nday = ndayofmonth
     SET lyear = year(dtnewdttm)
    ENDIF
   ELSE
    SET dtnewdttm = cnvtlookahead(sinterval,dtstartdttm)
    SET smonth = format(dtnewdttm,"MMM;;D")
    SET nday = ndayofmonth
    SET lyear = year(dtnewdttm)
   ENDIF
   SET snewdttm = build(nday,"-",smonth,"-",lyear)
   SET snewdttm = concat(snewdttm," ",stime)
   SET dtnewdttm = cnvtdatetime(snewdttm)
   CALL echo(build("NewDtTm:",format(dtnewdttm,";;Q")))
   RETURN(dtnewdttm)
 END ;Subroutine
 SUBROUTINE (findnextmonthlyschedule2(linterval=i4,nday=i2,ltime=i4,dtstartdttm=f8,lmonthinterval=i2
  ) =f8)
   DECLARE sinterval = c3 WITH protect, noconstant("")
   DECLARE smonth = c3 WITH protect, noconstant("")
   DECLARE nfirstday = i2 WITH protect, noconstant(0)
   DECLARE nholdday = i2 WITH protect, noconstant(0)
   DECLARE loffset = i4 WITH protect, noconstant(0)
   DECLARE sholddttm = vc WITH protect, noconstant("")
   DECLARE dtholddttm = f8 WITH protect, noconstant(0.0)
   DECLARE dtnewdttm = f8 WITH protect, noconstant(0.0)
   DECLARE stime = vc WITH protect, noconstant("")
   IF (linterval=0)
    CALL echo("lInterval = 0")
    RETURN(0.0)
   ELSEIF (ltime=0)
    CALL echo("lTime = 0")
    RETURN(0.0)
   ELSEIF (dtstartdttm=0.0)
    CALL echo("dtStartDtTm = 0")
    RETURN(0.0)
   ELSEIF (nday=0)
    CALL echo("nDay = 0")
    RETURN(0.0)
   ELSEIF (lmonthinterval=0)
    CALL echo("lMonthInterval = 0")
    RETURN(0.0)
   ENDIF
   SET nday -= 1
   CALL echo(build("StartDtTm:",format(dtstartdttm,";;Q")))
   SET sinterval = build(lmonthinterval,"M")
   SET stime = format(ltime,"##:##")
   SET ndatefound = 0
   WHILE (ndatefound=0)
     SET smonth = format(dtstartdttm,"MMM;;D")
     SET sholddttm = build("1-",smonth,"-",year(dtstartdttm))
     SET sholddttm = concat(sholddttm," ",stime)
     SET dtholddttm = cnvtdatetime(sholddttm)
     SET nfirstday = weekday(dtholddttm)
     IF (nday < 7)
      SET loffset = ((nfirstday - nday) * - (1))
      IF (loffset >= 0)
       SET loffset += 1
      ELSE
       SET loffset = (8+ loffset)
      ENDIF
      SET nholdday = (loffset+ (7 * (linterval - 1)))
      IF (nholdday > 28)
       IF (smonth IN ("JAN", "MAR", "MAY", "JUL", "AUG",
       "OCT", "DEC"))
        IF (nholdday > 31)
         SET nholdday -= 7
        ENDIF
       ELSEIF (smonth IN ("APR", "JUN", "SEP", "NOV"))
        IF (nholdday > 30)
         SET nholdday -= 7
        ENDIF
       ELSEIF (smonth="FEB")
        IF (nholdday > 28)
         SET nholdday -= 7
        ENDIF
       ENDIF
      ENDIF
     ELSE
      IF (linterval < 5)
       SET nholdday = ((nfirstday+ linterval) - 1)
      ELSE
       IF (smonth IN ("JAN", "MAR", "MAY", "JUL", "AUG",
       "OCT", "DEC"))
        SET nholdday = 31
       ELSEIF (smonth IN ("APR", "JUN", "SEP", "NOV"))
        SET nholdday = 30
       ELSEIF (smonth="FEB")
        SET lyear = year(dtstartdttm)
        IF (mod(lyear,4)=0
         AND ((mod(lyear,100) != 0) OR (mod(lyear,400)=0)) )
         SET nholdday = 29
        ELSE
         SET nholdday = 28
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     SET sholddttm = build(nholdday,"-",smonth,"-",year(dtstartdttm))
     SET sholddttm = concat(sholddttm," ",stime)
     SET dtholddttm = cnvtdatetime(sholddttm)
     IF (dtholddttm > dtstartdttm)
      SET dtnewdttm = dtholddttm
      SET ndatefound = 1
     ELSE
      SET dtstartdttm = cnvtlookahead(sinterval,dtholddttm)
     ENDIF
   ENDWHILE
   CALL echo(build("NewDtTm:",format(dtnewdttm,";;Q")))
   RETURN(dtnewdttm)
 END ;Subroutine
 SUBROUTINE (subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value
   )) =null WITH protect)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 RECORD temp_rsrc_security(
   1 l_cnt = i4
   1 list[*]
     2 service_resource_cd = f8
     2 viewable_srvc_rsrc_ind = i2
   1 security_enabled = i2
 )
 RECORD default_service_type_cd(
   1 service_type_cd_list[*]
     2 service_type_cd = f8
 )
 DECLARE nres_sec_failed = i2 WITH protect, constant(0)
 DECLARE nres_sec_passed = i2 WITH protect, constant(1)
 DECLARE nres_sec_err = i2 WITH protect, constant(2)
 DECLARE nres_sec_msg_type = i2 WITH protect, constant(0)
 DECLARE ncase_sec_msg_type = i2 WITH protect, constant(1)
 DECLARE ncorr_group_sec_msg_type = i2 WITH protect, constant(2)
 DECLARE sres_sec_error_msg = c23 WITH protect, constant("RESOURCE SECURITY ERROR")
 DECLARE sres_sec_failed_msg = c24 WITH protect, constant("RESOURCE SECURITY FAILED")
 DECLARE scase_sec_failed_msg = c20 WITH protect, constant("CASE SECURITY FAILED")
 DECLARE scorr_group_sec_failed_msg = c24 WITH protect, constant("CORR GRP SECURITY FAILED")
 DECLARE m_nressecind = i2 WITH protect, noconstant(0)
 DECLARE m_sressecstatus = c1 WITH protect, noconstant("S")
 DECLARE m_nressecapistatus = i2 WITH protect, noconstant(0)
 DECLARE m_nressecerrorind = i2 WITH protect, noconstant(0)
 DECLARE m_lressecfailedcnt = i4 WITH protect, noconstant(0)
 DECLARE m_lresseccheckedcnt = i4 WITH protect, noconstant(0)
 DECLARE m_nressecalterstatus = i2 WITH protect, noconstant(0)
 DECLARE m_lressecstatusblockcnt = i4 WITH protect, noconstant(0)
 DECLARE m_ntaskgrantedind = i2 WITH protect, noconstant(0)
 DECLARE m_sfailedmsg = c25 WITH protect
 DECLARE m_bresourceapicalled = i2 WITH protect, noconstant(0)
 SET temp_rsrc_security->l_cnt = 0
 SUBROUTINE (initresourcesecurity(resource_security_ind=i2) =null)
   IF (resource_security_ind=1)
    SET m_nressecind = true
   ELSE
    SET m_nressecind = false
   ENDIF
 END ;Subroutine
 SUBROUTINE (isresourceviewable(service_resource_cd=f8) =i2)
   DECLARE srvc_rsrc_idx = i4 WITH protect, noconstant(0)
   DECLARE l_srvc_rsrc_pos = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SET m_lresseccheckedcnt += 1
   IF (m_nressecind=false)
    RETURN(true)
   ENDIF
   IF (m_nressecerrorind=true)
    RETURN(false)
   ENDIF
   IF (service_resource_cd=0)
    RETURN(true)
   ENDIF
   IF (m_bresourceapicalled=true)
    IF ((temp_rsrc_security->security_enabled=1)
     AND size(temp_rsrc_security->list,5)=0)
     SET m_nressecapistatus = nres_sec_failed
    ELSEIF ((temp_rsrc_security->security_enabled=0)
     AND size(temp_rsrc_security->list,5)=0)
     SET m_nressecapistatus = nres_sec_passed
    ELSEIF ((temp_rsrc_security->l_cnt > 0))
     SET l_srvc_rsrc_pos = locateval(srvc_rsrc_idx,1,temp_rsrc_security->l_cnt,service_resource_cd,
      temp_rsrc_security->list[srvc_rsrc_idx].service_resource_cd)
     IF (l_srvc_rsrc_pos > 0)
      IF ((temp_rsrc_security->list[l_srvc_rsrc_pos].viewable_srvc_rsrc_ind=1))
       SET m_nressecapistatus = nres_sec_passed
      ELSE
       SET m_nressecapistatus = nres_sec_failed
      ENDIF
     ELSE
      SET m_nressecapistatus = nres_sec_failed
     ENDIF
    ENDIF
   ELSE
    RECORD request_3202551(
      1 prsnl_id = f8
      1 explicit_ind = i4
      1 debug_ind = i4
      1 service_type_cd_list[*]
        2 service_type_cd = f8
    )
    RECORD reply_3202551(
      1 security_enabled = i2
      1 service_resource_list[*]
        2 service_resource_cd = f8
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    SET request_3202551->prsnl_id = reqinfo->updt_id
    IF (size(default_service_type_cd->service_type_cd_list,5) > 0)
     SET stat = alterlist(request_3202551->service_type_cd_list,size(default_service_type_cd->
       service_type_cd_list,5))
     FOR (idx = 1 TO size(default_service_type_cd->service_type_cd_list,5))
       SET request_3202551->service_type_cd_list[idx].service_type_cd = default_service_type_cd->
       service_type_cd_list[idx].service_type_cd
     ENDFOR
    ELSE
     SET stat = alterlist(request_3202551->service_type_cd_list,5)
     SET request_3202551->service_type_cd_list[1].service_type_cd = uar_get_code_by("MEANING",223,
      "SECTION")
     SET request_3202551->service_type_cd_list[2].service_type_cd = uar_get_code_by("MEANING",223,
      "SUBSECTION")
     SET request_3202551->service_type_cd_list[3].service_type_cd = uar_get_code_by("MEANING",223,
      "BENCH")
     SET request_3202551->service_type_cd_list[4].service_type_cd = uar_get_code_by("MEANING",223,
      "INSTRUMENT")
     SET request_3202551->service_type_cd_list[5].service_type_cd = uar_get_code_by("MEANING",223,
      "DEPARTMENT")
    ENDIF
    EXECUTE msvc_get_prsnl_svc_resources  WITH replace("REQUEST",request_3202551), replace("REPLY",
     reply_3202551)
    SET m_bresourceapicalled = true
    IF ((reply_3202551->status_data.status != "S"))
     SET m_nressecapistatus = nres_sec_err
    ELSEIF ((reply_3202551->security_enabled=1)
     AND size(reply_3202551->service_resource_list,5)=0)
     SET temp_rsrc_security->security_enabled = 1
     SET m_nressecapistatus = nres_sec_failed
    ELSEIF ((reply_3202551->security_enabled=0)
     AND size(reply_3202551->service_resource_list,5)=0)
     SET temp_rsrc_security->security_enabled = 0
     SET m_nressecapistatus = nres_sec_passed
    ELSE
     SET temp_rsrc_security->l_cnt = size(reply_3202551->service_resource_list,5)
     SET temp_rsrc_security->security_enabled = reply_3202551->security_enabled
     IF ((temp_rsrc_security->l_cnt > 0))
      SET stat = alterlist(temp_rsrc_security->list,temp_rsrc_security->l_cnt)
      FOR (idx = 1 TO size(reply_3202551->service_resource_list,5))
       SET temp_rsrc_security->list[idx].service_resource_cd = reply_3202551->service_resource_list[
       idx].service_resource_cd
       SET temp_rsrc_security->list[idx].viewable_srvc_rsrc_ind = 1
      ENDFOR
     ENDIF
     SET l_srvc_rsrc_pos = locateval(srvc_rsrc_idx,1,temp_rsrc_security->l_cnt,service_resource_cd,
      temp_rsrc_security->list[srvc_rsrc_idx].service_resource_cd)
     IF (l_srvc_rsrc_pos > 0)
      IF ((temp_rsrc_security->list[l_srvc_rsrc_pos].viewable_srvc_rsrc_ind=1))
       SET m_nressecapistatus = nres_sec_passed
      ELSE
       SET m_nressecapistatus = nres_sec_failed
      ENDIF
     ELSE
      SET m_nressecapistatus = nres_sec_failed
     ENDIF
    ENDIF
   ENDIF
   CASE (m_nressecapistatus)
    OF nres_sec_passed:
     RETURN(true)
    OF nres_sec_failed:
     SET m_lressecfailedcnt += 1
     RETURN(false)
    ELSE
     SET m_nressecerrorind = true
     RETURN(false)
   ENDCASE
 END ;Subroutine
 SUBROUTINE (getresourcesecuritystatus(fail_all_ind=i2) =c1)
  IF (m_nressecerrorind=true)
   SET m_sressecstatus = "F"
  ELSEIF (m_lresseccheckedcnt > 0
   AND m_lresseccheckedcnt=m_lressecfailedcnt)
   SET m_sressecstatus = "Z"
  ELSEIF (fail_all_ind=1
   AND m_lressecfailedcnt > 0)
   SET m_sressecstatus = "Z"
  ELSE
   SET m_sressecstatus = "S"
  ENDIF
  RETURN(m_sressecstatus)
 END ;Subroutine
 SUBROUTINE (populateressecstatusblock(message_type=i2) =null)
   IF (((m_sressecstatus="S") OR (validate(reply->status_data.status,"-1")="-1")) )
    RETURN
   ENDIF
   SET m_lressecstatusblockcnt = size(reply->status_data.subeventstatus,5)
   IF (m_lressecstatusblockcnt=1
    AND trim(reply->status_data.subeventstatus[1].operationname)="")
    SET m_ressecalterstatus = 0
   ELSE
    SET m_lressecstatusblockcnt += 1
    SET m_nressecalterstatus = alter(reply->status_data.subeventstatus,m_lressecstatusblockcnt)
   ENDIF
   CASE (message_type)
    OF ncase_sec_msg_type:
     SET m_sfailedmsg = scase_sec_failed_msg
    OF ncorr_group_sec_msg_type:
     SET m_sfailedmsg = scorr_group_sec_failed_msg
    ELSE
     SET m_sfailedmsg = sres_sec_failed_msg
   ENDCASE
   CASE (m_sressecstatus)
    OF "F":
     SET reply->status_data.subeventstatus[m_lressecstatusblockcnt].operationname =
     sres_sec_error_msg
     SET reply->status_data.subeventstatus[m_lressecstatusblockcnt].operationstatus = "F"
    OF "Z":
     SET reply->status_data.subeventstatus[m_lressecstatusblockcnt].operationname = m_sfailedmsg
     SET reply->status_data.subeventstatus[m_lressecstatusblockcnt].operationstatus = "Z"
   ENDCASE
 END ;Subroutine
 SUBROUTINE (istaskgranted(task_number=i4) =i2)
   SET m_ntaskgrantedind = false
   SELECT INTO "nl:"
    FROM application_group ag,
     task_access ta
    PLAN (ag
     WHERE (ag.position_cd=reqinfo->position_cd)
      AND ag.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ag.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (ta
     WHERE ta.app_group_cd=ag.app_group_cd
      AND ta.task_number=task_number)
    DETAIL
     m_ntaskgrantedind = true
    WITH nocounter
   ;end select
   RETURN(m_ntaskgrantedind)
 END ;Subroutine
 RECORD reply(
   1 group_list[*]
     2 group_id = f8
     2 group_name = c40
     2 group_activity_id = f8
     2 related_group_id = f8
     2 scheduled_dt_tm = dq8
     2 schedule_cd = f8
     2 incomplete_ind = i2
     2 service_resource_cd = f8
     2 service_resource_disp = c40
     2 service_resource_mean = c40
     2 active_ind = i2
     2 reagent_list[*]
       3 reagent_cd = f8
       3 reagent_disp = c40
       3 lot_information_id = f8
       3 lot_ident = c40
       3 qc_satisfactory_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE lreagentcount = i4 WITH protect, noconstant(0)
 DECLARE nstatus = i2 WITH protect, noconstant(0)
 DECLARE dsatinterpcd = f8 WITH protect, noconstant(0.0)
 DECLARE ddiscardinterpcd = f8 WITH protect, noconstant(0.0)
 DECLARE dpendinginterpcd = f8 WITH protect, noconstant(0.0)
 DECLARE dstartdttm = f8 WITH protect, noconstant(0.0)
 DECLARE dnewdttm = f8 WITH protect, noconstant(0.0)
 DECLARE dcurrentdttm = f8 WITH protect, noconstant(0.0)
 DECLARE nqcdisabled = i2 WITH protect, noconstant(0)
 DECLARE nisresourceviewable = i2 WITH protect, noconstant(0)
 DECLARE ndaily = i2 WITH protect, constant(1)
 DECLARE nweekly = i2 WITH protect, constant(2)
 DECLARE nmonthly1 = i2 WITH protect, constant(3)
 DECLARE nmonthly2 = i2 WITH protect, constant(4)
 DECLARE nas_needed = i2 WITH protect, constant(5)
 DECLARE lerrorcode = i4 WITH protect, noconstant(0)
 DECLARE serrormsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE nfail = i2 WITH protect, constant(0)
 DECLARE nsuccess = i2 WITH protect, constant(1)
 DECLARE nno_matches = i2 WITH protect, constant(2)
 CALL initresourcesecurity(1)
 SET stat = alterlist(default_service_type_cd->service_type_cd_list,6)
 SET default_service_type_cd->service_type_cd_list[1].service_type_cd = uar_get_code_by("MEANING",223,
  "INSTITUTION")
 SET default_service_type_cd->service_type_cd_list[2].service_type_cd = uar_get_code_by("MEANING",223,
  "DEPARTMENT")
 SET default_service_type_cd->service_type_cd_list[3].service_type_cd = uar_get_code_by("MEANING",223,
  "SECTION")
 SET default_service_type_cd->service_type_cd_list[4].service_type_cd = uar_get_code_by("MEANING",223,
  "SUBSECTION")
 SET default_service_type_cd->service_type_cd_list[5].service_type_cd = uar_get_code_by("MEANING",223,
  "BENCH")
 SET default_service_type_cd->service_type_cd_list[6].service_type_cd = uar_get_code_by("MEANING",223,
  "INSTRUMENT")
 SET modify = predeclare
 SET reply->status_data.status = "F"
 SET nstatus = uar_get_meaning_by_codeset(325575,"SAT",1,dsatinterpcd)
 SET nstatus = uar_get_meaning_by_codeset(325575,"DISCARD",1,ddiscardinterpcd)
 SET nstatus = uar_get_meaning_by_codeset(325575,"PENDING",1,dpendinginterpcd)
 IF (dsatinterpcd=0)
  CALL subevent_add("UAR","F","CODE_VALUE","Satisfactory Interp Code not retrieved")
  GO TO exit_script
 ENDIF
 IF (ddiscardinterpcd=0)
  CALL subevent_add("UAR","F","CODE_VALUE","Discard Interp Code not retrieved")
  GO TO exit_script
 ENDIF
 IF (dpendinginterpcd=0)
  CALL subevent_add("UAR","F","CODE_VALUE","Pending Interp Code not retrieved")
  GO TO exit_script
 ENDIF
 SET dcurrentdttm = cnvtdatetime(sysdate)
#begin_script
 SET nqcdisabled = 0
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain="PATHNET"
    AND dm.info_name="DISABLE_BB_QC")
  DETAIL
   nqcdisabled = 1
  WITH nocounter
 ;end select
 IF (nqcdisabled=1)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 IF (size(request->group_list,5) > 0)
  SET nstatus = getqcgroupsbyid(0)
 ELSE
  SET nstatus = getallqcgroups(0)
 ENDIF
 IF (nstatus=nno_matches)
  SET reply->status_data.status = "Z"
  CALL subevent_add("SELECT","Z","BB_QC_GROUP","No groups found.")
  GO TO exit_script
 ELSEIF (nstatus=nfail)
  CALL subevent_add("SELECT","F","BB_QC_GROUP","Group query failed.")
  GO TO exit_script
 ENDIF
 SET nstatus = getreagentactivity(0)
 IF (nstatus=nfail)
  CALL subevent_add("SELECT","F","BB_QC_GRP_REAGENT_ACTIVITY","Reagent activity query failed.")
  GO TO exit_script
 ELSEIF (nstatus=nno_matches)
  CALL subevent_add("SELECT","F","BB_QC_GRP_REAGENT_ACTIVITY","Failed to find reagent activity.")
  GO TO exit_script
 ENDIF
 SET nstatus = determinenextschedule(0)
 IF (nstatus=nfail)
  CALL subevent_add("SELECT","F","BB_QC_SCHEDULE_SEGMENT","Next schedule query failed.")
  GO TO exit_script
 ELSEIF (nstatus=nno_matches)
  CALL subevent_add("SELECT","F","BB_QC_SCHEDULE_SEGMENT","Failed to find schedule segments.")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 SUBROUTINE (getallqcgroups(no_param=i2(value)) =i2 WITH private)
   SELECT INTO "nl:"
    FROM bb_qc_group bqg,
     bb_qc_group_activity bqga
    PLAN (bqg
     WHERE bqg.group_id > 0)
     JOIN (bqga
     WHERE bqga.group_id=bqg.group_id
      AND bqga.scheduled_dt_tm < cnvtdatetime(sysdate))
    ORDER BY bqga.group_id, bqga.scheduled_dt_tm DESC
    HEAD REPORT
     lgroupcount = 0, stat = alterlist(reply->group_list,10)
    HEAD bqga.group_id
     nisresourceviewable = isresourceviewable(bqg.service_resource_cd)
     IF (nisresourceviewable=true)
      lgroupcount += 1
      IF (mod(lgroupcount,10)=1
       AND lgroupcount != 1)
       stat = alterlist(reply->group_list,(lgroupcount+ 9))
      ENDIF
      reply->group_list[lgroupcount].group_id = bqg.group_id, reply->group_list[lgroupcount].
      group_name = bqg.group_name, reply->group_list[lgroupcount].service_resource_cd = bqg
      .service_resource_cd,
      reply->group_list[lgroupcount].active_ind = bqg.active_ind, reply->group_list[lgroupcount].
      group_activity_id = bqga.group_activity_id, reply->group_list[lgroupcount].schedule_cd = bqg
      .schedule_cd,
      reply->group_list[lgroupcount].related_group_id = bqga.related_group_id, reply->group_list[
      lgroupcount].scheduled_dt_tm = cnvtdatetime(bqga.scheduled_dt_tm)
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->group_list,lgroupcount)
    WITH nocounter
   ;end select
   SET lerrorcode = error(serrormsg,1)
   IF (lerrorcode > 0)
    RETURN(nfail)
   ELSEIF (size(reply->group_list,5) > 0)
    RETURN(nsuccess)
   ELSE
    RETURN(nno_matches)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getqcgroupsbyid(no_param=i2(value)) =i2 WITH private)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(request->group_list,5))),
     bb_qc_group bqg,
     bb_qc_group_activity bqga
    PLAN (d)
     JOIN (bqg
     WHERE (bqg.group_id=request->group_list[d.seq].group_id))
     JOIN (bqga
     WHERE bqga.group_id=bqg.group_id
      AND bqga.scheduled_dt_tm < cnvtdatetime(sysdate))
    ORDER BY bqga.group_id, bqga.scheduled_dt_tm DESC
    HEAD REPORT
     lgroupcount = 0, stat = alterlist(reply->group_list,10)
    HEAD bqga.group_id
     nisresourceviewable = isresourceviewable(bqg.service_resource_cd)
     IF (nisresourceviewable=true)
      lgroupcount += 1
      IF (mod(lgroupcount,10)=1
       AND lgroupcount != 1)
       stat = alterlist(reply->group_list,(lgroupcount+ 9))
      ENDIF
      reply->group_list[lgroupcount].group_id = bqg.group_id, reply->group_list[lgroupcount].
      group_name = bqg.group_name, reply->group_list[lgroupcount].group_activity_id = bqga
      .group_activity_id,
      reply->group_list[lgroupcount].schedule_cd = bqg.schedule_cd, reply->group_list[lgroupcount].
      related_group_id = bqga.related_group_id, reply->group_list[lgroupcount].scheduled_dt_tm =
      cnvtdatetime(bqga.scheduled_dt_tm),
      reply->group_list[lgroupcount].service_resource_cd = bqg.service_resource_cd, reply->
      group_list[lgroupcount].active_ind = bqg.active_ind
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->group_list,lgroupcount)
    WITH nocounter
   ;end select
   SET lerrorcode = error(serrormsg,1)
   IF (lerrorcode > 0)
    RETURN(nfail)
   ELSEIF (size(reply->group_list,5) > 0)
    RETURN(nsuccess)
   ELSE
    RETURN(nno_matches)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getreagentactivity(no_param=i2(value)) =i2 WITH private)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(reply->group_list,5))),
    bb_qc_grp_reagent_activity bqgra,
    bb_qc_grp_reagent_lot bqgrl,
    pcs_lot_information pli,
    pcs_lot_definition pld
   PLAN (d)
    JOIN (bqgra
    WHERE (bqgra.group_activity_id=reply->group_list[d.seq].group_activity_id))
    JOIN (bqgrl
    WHERE bqgrl.group_reagent_lot_id=bqgra.group_reagent_lot_id
     AND bqgrl.current_ind=1
     AND bqgrl.active_ind=1)
    JOIN (pli
    WHERE pli.lot_information_id=bqgrl.lot_information_id)
    JOIN (pld
    WHERE pld.lot_definition_id=pli.lot_definition_id)
   ORDER BY bqgra.group_activity_id
   HEAD REPORT
    lreagentcount = 0
   HEAD bqgra.group_activity_id
    lreagentcount = 0, stat = alterlist(reply->group_list[d.seq].reagent_list,10)
   DETAIL
    lreagentcount += 1
    IF (mod(lreagentcount,10)=1
     AND lreagentcount != 1)
     stat = alterlist(reply->group_list[d.seq].reagent_list,(lreagentcount+ 9))
    ENDIF
    reply->group_list[d.seq].reagent_list[lreagentcount].reagent_cd = pld.parent_entity_id, reply->
    group_list[d.seq].reagent_list[lreagentcount].lot_information_id = pli.lot_information_id, reply
    ->group_list[d.seq].reagent_list[lreagentcount].lot_ident = pli.lot_ident
    IF (bqgra.interpretation_cd=dsatinterpcd)
     reply->group_list[d.seq].reagent_list[lreagentcount].qc_satisfactory_ind = 1
    ELSEIF (bqgra.interpretation_cd=dpendinginterpcd)
     reply->group_list[d.seq].incomplete_ind = 1
    ELSE
     reply->group_list[d.seq].reagent_list[lreagentcount].qc_satisfactory_ind = 0
    ENDIF
   FOOT  bqgra.group_activity_id
    stat = alterlist(reply->group_list[d.seq].reagent_list,lreagentcount)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET lerrorcode = error(serrormsg,1)
   IF (lerrorcode > 0)
    RETURN(nfail)
   ELSE
    RETURN(nsuccess)
   ENDIF
  ELSE
   RETURN(nno_matches)
  ENDIF
 END ;Subroutine
 SUBROUTINE (determinenextschedule(no_param=i2(value)) =i2 WITH private)
   RECORD schedule_segment(
     1 qual[*]
       2 group_id = f8
       2 schedule_segment_id = f8
   ) WITH protect
   SELECT INTO "nl:"
    FROM bb_qc_schedule_segment bqss,
     (dummyt d1  WITH seq = value(size(reply->group_list,5)))
    PLAN (d1)
     JOIN (bqss
     WHERE (bqss.schedule_cd=reply->group_list[d1.seq].schedule_cd))
    HEAD REPORT
     lsegmentcnt = 0
    DETAIL
     lsegmentcnt += 1
     IF (lsegmentcnt > size(schedule_segment->qual,5))
      lstatus = alterlist(schedule_segment->qual,(lsegmentcnt+ 5))
     ENDIF
     schedule_segment->qual[lsegmentcnt].group_id = reply->group_list[d1.seq].group_id,
     schedule_segment->qual[lsegmentcnt].schedule_segment_id = bqss.schedule_segment_id
    FOOT REPORT
     lstatus = alterlist(schedule_segment->qual,lsegmentcnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM bb_qc_schedule_segment bqss,
     (dummyt d1  WITH seq = value(size(reply->group_list,5))),
     (dummyt d2  WITH seq = value(size(schedule_segment->qual,5)))
    PLAN (d1)
     JOIN (d2
     WHERE (schedule_segment->qual[d2.seq].group_id=reply->group_list[d1.seq].group_id))
     JOIN (bqss
     WHERE (bqss.schedule_segment_id=schedule_segment->qual[d2.seq].schedule_segment_id))
    DETAIL
     dstartdttm = reply->group_list[d1.seq].scheduled_dt_tm, dnewdttm = 0.0
     CASE (bqss.segment_type_flag)
      OF ndaily:
       dnewdttm = findnextdailyschedule(bqss.component1_nbr,bqss.time_nbr,dstartdttm,0),
       IF (cnvtdatetime(dnewdttm) < cnvtdatetime(dcurrentdttm))
        reply->group_list[d1.seq].incomplete_ind = 1
       ENDIF
      OF nweekly:
       dnewdttm = findnextweeklyschedule(bqss.days_of_week_bit,bqss.time_nbr,dstartdttm,bqss
        .component1_nbr),
       IF (cnvtdatetime(dnewdttm) < cnvtdatetime(dcurrentdttm))
        reply->group_list[d1.seq].incomplete_ind = 1
       ENDIF
      OF nmonthly1:
       dnewdttm = findnextmonthlyschedule1(bqss.component2_nbr,bqss.component1_nbr,bqss.time_nbr,
        dstartdttm,0),
       IF (cnvtdatetime(dnewdttm) < cnvtdatetime(dcurrentdttm))
        reply->group_list[d1.seq].incomplete_ind = 1
       ENDIF
      OF nmonthly2:
       dnewdttm = findnextmonthlyschedule2(bqss.component1_nbr,bqss.time_nbr,dstartdttm,bqss
        .component3_nbr),
       IF (cnvtdatetime(dnewdttm) < cnvtdatetime(dcurrentdttm))
        reply->group_list[d1.seq].incomplete_ind = 1
       ENDIF
      OF nas_needed:
       interval = build(bqss.component1_nbr,",MIN"),
       IF (cnvtlookahead(interval,dstartdttm) < cnvtdatetime(dcurrentdttm))
        reply->group_list[d1.seq].incomplete_ind = 1
       ENDIF
     ENDCASE
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET lerrorcode = error(serrormsg,1)
    IF (lerrorcode > 0)
     RETURN(nfail)
    ELSE
     RETURN(nsuccess)
    ENDIF
   ELSE
    RETURN(nno_matches)
   ENDIF
 END ;Subroutine
END GO
