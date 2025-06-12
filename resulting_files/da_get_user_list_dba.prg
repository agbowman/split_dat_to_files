CREATE PROGRAM da_get_user_list:dba
 DECLARE iorgsecurityind = i4 WITH protect, noconstant(0)
 DECLARE itaskrestrict = i4 WITH protect, noconstant(0)
 DECLARE iactivediscernuser = f8 WITH protect, noconstant(0.0)
 DECLARE ssearch = vc WITH protect
 DECLARE ssearchlast = vc WITH protect
 DECLARE ssearchfirst = vc WITH protect
 DECLARE serror = vc WITH protect, noconstant(" ")
 DECLARE scontextqual = vc WITH protect
 IF (validate(request->start_value)=1)
  DECLARE commapos = i4 WITH protect
  DECLARE spacepos = i4 WITH protect
  SET ssearch = trim(cnvtupper(nullterm(request->start_value)),3)
  SET commapos = findstring(",",ssearch)
  SET spacepos = findstring(" ",ssearch)
  IF (commapos > 0)
   SET ssearchlast = concat(trim(substring(1,(commapos - 1),ssearch),3),"*")
   SET ssearchfirst = concat(trim(substring((commapos+ 1),(size(ssearch) - commapos),ssearch),3),"*")
  ELSEIF (spacepos > 0)
   SET ssearchfirst = concat(trim(substring(1,(spacepos - 1),ssearch),3),"*")
   SET ssearchlast = concat(trim(substring((spacepos+ 1),(size(ssearch) - spacepos),ssearch),3),"*")
  ELSE
   SET ssearchlast = concat(ssearch,"*")
   SET ssearchfirst = "*"
  ENDIF
 ENDIF
 IF (validate(context_ind,0)=1)
  SET scontextqual = concat("( cnvtupper(p.name_full_formatted) > context->string1 ",
   " or ( cnvtupper(p.name_full_formatted) = context->string1 and ",
   "( p.username > context->string2 or p.person_id > context->num1 ) ) )")
 ELSE
  SET scontextqual = "p.username is not null"
 ENDIF
 IF (validate(maxqualrows)=0)
  SET maxqualrows = 100
 ENDIF
 CALL echo(build("maxqualrows=",maxqualrows))
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_name="SEC_ORG_RELTN"
   AND di.info_domain="SECURITY"
  DETAIL
   iorgsecurityind = di.info_number
  WITH nocounter
 ;end select
 IF ((request->val2="ALL"))
  SELECT
   IF (iorgsecurityind=1)
    FROM prsnl p
    WHERE ((p.username=ssearch) OR (p.name_last_key=patstring(ssearchlast)
     AND p.name_first_key=patstring(ssearchfirst)))
     AND p.active_ind=1
     AND cnvtdatetime(curdate,curtime3) >= p.beg_effective_dt_tm
     AND ((cnvtdatetime(curdate,curtime3) < p.end_effective_dt_tm) OR (p.end_effective_dt_tm = null
    ))
     AND  EXISTS (
    (SELECT
     "x"
     FROM prsnl_org_reltn por,
      organization o
     WHERE por.person_id=p.person_id
      AND por.organization_id IN (
     (SELECT
      por2.organization_id
      FROM prsnl_org_reltn por2
      WHERE (por2.person_id=reqinfo->updt_id)
       AND por2.active_ind=1
       AND cnvtdatetime(curdate,curtime) >= por2.beg_effective_dt_tm
       AND ((cnvtdatetime(curdate,curtime) < por2.end_effective_dt_tm) OR (por2.end_effective_dt_tm
       = null)) ))
      AND por.active_ind=1
      AND cnvtdatetime(curdate,curtime) >= por.beg_effective_dt_tm
      AND ((cnvtdatetime(curdate,curtime) < por.end_effective_dt_tm) OR (por.end_effective_dt_tm =
     null))
      AND o.organization_id=por.organization_id
      AND o.active_ind=1
      AND cnvtdatetime(curdate,curtime) >= o.beg_effective_dt_tm
      AND ((cnvtdatetime(curdate,curtime) < o.end_effective_dt_tm) OR (o.end_effective_dt_tm = null
     )) ))
     AND parser(scontextqual)
   ELSE
    FROM prsnl p
    WHERE p.active_ind=1
     AND cnvtdatetime(curdate,curtime3) >= p.beg_effective_dt_tm
     AND ((cnvtdatetime(curdate,curtime3) < p.end_effective_dt_tm) OR (p.end_effective_dt_tm = null
    ))
     AND ((p.username=ssearch) OR (p.name_last_key=patstring(ssearchlast)
     AND p.name_first_key=patstring(ssearchfirst)))
     AND parser(scontextqual)
   ENDIF
   DISTINCT INTO "nl:"
   name_disp = p.name_full_formatted, username = p.username, person_id = p.person_id
   ORDER BY sqlpassthru("upper(p.name_full_formatted)"), p.username, p.person_id
   HEAD REPORT
    ipersidx = 0
   DETAIL
    ipersidx = (ipersidx+ 1)
    IF (mod(ipersidx,100)=1)
     stat = alterlist(reply->datacoll,(ipersidx+ 99))
    ENDIF
    IF (((context_ind=0) OR ((((cnvtupper(p.name_full_formatted) > context->string1)) OR ((((p
    .username > context->string2)) OR ((p.person_id > context->num1))) )) )) )
     reply->datacoll[ipersidx].description = concat(trim(name_disp,3),"  [",trim(username,3),"]"),
     reply->datacoll[ipersidx].currcv = trim(build2(person_id),3)
    ENDIF
    IF (ipersidx=maxqualrows)
     context->context_ind = 1, context->string1 = cnvtupper(p.name_full_formatted), context->string2
      = p.username,
     context->num1 = p.person_id, context->maxqual = maxqualrows
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->datacoll,ipersidx)
   WITH nocounter, rdbunion, maxrec = value(maxqualrows)
  ;end select
 ELSE
  SET iactivediscernuser = uar_get_code_by_cki("CKI.CODEVALUE!4100899206")
  SELECT
   IF (iorgsecurityind=1)
    WHERE pi.info_type_cd=iactivediscernuser
     AND pi.active_ind=1
     AND cnvtdatetime(curdate,curtime3) >= pi.beg_effective_dt_tm
     AND ((cnvtdatetime(curdate,curtime3) < pi.end_effective_dt_tm) OR (pi.end_effective_dt_tm = null
    ))
     AND p.person_id=pi.person_id
     AND p.active_ind=1
     AND cnvtdatetime(curdate,curtime3) >= p.beg_effective_dt_tm
     AND ((cnvtdatetime(curdate,curtime3) < p.end_effective_dt_tm) OR (p.end_effective_dt_tm = null
    ))
     AND ((p.username=ssearch) OR (p.name_last_key=patstring(ssearchlast)
     AND p.name_first_key=patstring(ssearchfirst)))
     AND  EXISTS (
    (SELECT
     "x"
     FROM prsnl_org_reltn por,
      organization o
     WHERE por.person_id=p.person_id
      AND por.organization_id IN (
     (SELECT
      por2.organization_id
      FROM prsnl_org_reltn por2
      WHERE (por2.person_id=reqinfo->updt_id)
       AND por2.active_ind=1
       AND cnvtdatetime(curdate,curtime) >= por2.beg_effective_dt_tm
       AND ((cnvtdatetime(curdate,curtime) < por2.end_effective_dt_tm) OR (por2.end_effective_dt_tm
       = null)) ))
      AND por.active_ind=1
      AND cnvtdatetime(curdate,curtime) >= por.beg_effective_dt_tm
      AND ((cnvtdatetime(curdate,curtime) < por.end_effective_dt_tm) OR (por.end_effective_dt_tm =
     null))
      AND o.organization_id=por.organization_id
      AND o.active_ind=1
      AND cnvtdatetime(curdate,curtime) >= o.beg_effective_dt_tm
      AND ((cnvtdatetime(curdate,curtime) < o.end_effective_dt_tm) OR (o.end_effective_dt_tm = null
     )) ))
     AND parser(scontextqual)
   ELSE
    WHERE pi.info_type_cd=iactivediscernuser
     AND pi.active_ind=1
     AND cnvtdatetime(curdate,curtime3) >= pi.beg_effective_dt_tm
     AND ((cnvtdatetime(curdate,curtime3) < pi.end_effective_dt_tm) OR (pi.end_effective_dt_tm = null
    ))
     AND p.person_id=pi.person_id
     AND p.active_ind=1
     AND cnvtdatetime(curdate,curtime3) >= p.beg_effective_dt_tm
     AND ((cnvtdatetime(curdate,curtime3) < p.end_effective_dt_tm) OR (p.end_effective_dt_tm = null
    ))
     AND ((p.username=ssearch) OR (p.name_last_key=patstring(ssearchlast)
     AND p.name_first_key=patstring(ssearchfirst)))
     AND parser(scontextqual)
   ENDIF
   DISTINCT INTO "nl:"
   name_disp = p.name_full_formatted, username = p.username, person_id = p.person_id
   FROM prsnl_info pi,
    prsnl p
   ORDER BY sqlpassthru("upper(p.name_full_formatted)"), p.username, p.person_id
   HEAD REPORT
    ipersidx = 0
   DETAIL
    IF (((context_ind=0) OR ((((cnvtupper(p.name_full_formatted) > context->string1)) OR ((((p
    .username > context->string2)) OR ((p.person_id > context->num1))) )) )) )
     ipersidx = (ipersidx+ 1)
     IF (mod(ipersidx,100)=1)
      stat = alterlist(reply->datacoll,(ipersidx+ 99))
     ENDIF
     reply->datacoll[ipersidx].description = concat(trim(name_disp,3),"  [",trim(username,3),"]"),
     reply->datacoll[ipersidx].currcv = trim(build2(person_id),3)
    ENDIF
    IF (ipersidx=maxqualrows)
     context->context_ind = 1, context->string1 = cnvtupper(p.name_full_formatted), context->string2
      = p.username,
     context->num1 = p.person_id, context->maxqual = maxqualrows
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->datacoll,ipersidx)
   WITH nocounter, rdbunion, maxrec = value(maxqualrows)
  ;end select
 ENDIF
 IF (error(serror,1) != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = " "
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serror
 ELSEIF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
