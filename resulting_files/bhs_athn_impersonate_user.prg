CREATE PROGRAM bhs_athn_impersonate_user
 IF (validate(request)=0)
  FREE RECORD request
  RECORD request(
    1 prsnl_id = f8
  ) WITH protect
 ENDIF
 IF (validate(request)=0)
  FREE RECORD reply
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 DECLARE seccntxt = i4 WITH protect, noconstant(0)
 DECLARE namelen = i4 WITH protect, noconstant(0)
 DECLARE domainnamelen = i4 WITH protect, noconstant(0)
 DECLARE statval = i4 WITH protect, noconstant(0)
 DECLARE username = vc WITH protect, noconstant("")
 SET reply->status_data.status = "F"
 IF ((request->prsnl_id <= 0.0))
  CALL echo("INVALID REQUEST PRSNL_ID...EXITING")
  GO TO exit_script
 ENDIF
 CALL echo(build2("IMPERSONATION USER_ID IS: ",request->prsnl_id))
 SELECT INTO "NL:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id=request->prsnl_id)
    AND p.active_ind=1)
  DETAIL
   username = p.username,
   CALL echo(build2("IMPERSONATION USERNAME IS: ",username))
  WITH nocounter
 ;end select
 IF (textlen(username))
  SET stat = uar_secreleaseclientcontext()
  SET namelen = (textlen(username)+ 1)
  SET domainnamelen = (textlen(curdomain)+ 2)
  SET statval = memalloc(name,1,build("C",namelen))
  SET statval = memalloc(domainname,1,build("C",domainnamelen))
  SET name = username
  SET domainname = curdomain
  CALL echo(build2("NAME: ",name,"DOMAINNAME: ",domainname))
  SET setcntxt = uar_secimpersonate(nullterm(username),nullterm(domainname))
  CALL echo(build2("SETCNTXT: ",setcntxt))
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
