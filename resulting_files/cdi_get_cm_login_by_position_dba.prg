CREATE PROGRAM cdi_get_cm_login_by_position:dba
 RECORD reply(
   1 username = vc
   1 password = vc
   1 datasource = vc
   1 image_repository[*]
     2 repository_name = vc
   1 webservicesurl = vc
   1 max_conn_pool = i2
   1 min_conn_pool = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 password_bytes = gvc
 )
 DECLARE curr_score = i4 WITH noconstant(0), protect
 DECLARE best_score = i4 WITH noconstant(0), protect
 DECLARE cfg_domain = vc WITH noconstant(" "), protect
 DECLARE info_domain = vc WITH constant("IMAGING DOCUMENT"), protect
 DECLARE cfg_info_name = vc WITH constant("CONTENT_CONFIG_DOMAIN"), protect
 DECLARE cfg_domain_exists_ind = i2 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SET reply->username = ""
 SET reply->password = ""
 SET reply->password_bytes = ""
 SET reply->min_conn_pool = 1
 SET reply->max_conn_pool = 1
 SELECT INTO "NL:"
  FROM cdi_cm_login cl,
   cdi_cm_login_position cp
  PLAN (cl
   WHERE (((cl.organization_id=request->organization_id)) OR (cl.organization_id=0.0)) )
   JOIN (cp
   WHERE (cp.cdi_cm_login_id= Outerjoin(cl.cdi_cm_login_id))
    AND (cp.position_cd= Outerjoin(request->position_cd)) )
  DETAIL
   curr_score = 0
   IF ((request->organization_id != 0)
    AND (cl.organization_id=request->organization_id))
    IF ((request->position_cd != 0)
     AND (cp.position_cd=request->position_cd))
     curr_score = 4
    ELSEIF (cl.org_default_ind=1)
     curr_score = 3
    ENDIF
   ELSE
    IF ((request->position_cd != 0)
     AND (cp.position_cd=request->position_cd))
     curr_score = 2
    ELSEIF (cl.organization_id=0.0
     AND cl.org_default_ind=1)
     curr_score = 1
    ENDIF
   ENDIF
   IF (curr_score > best_score)
    best_score = curr_score, reply->username = cl.cm_username, reply->password = cl.cm_password,
    reply->password_bytes = cl.cm_password
   ENDIF
  WITH nocounter
 ;end select
 IF (size(trim(reply->username),1) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 EXECUTE prefrtl
 DECLARE hpref = i4 WITH protect, noconstant(0)
 DECLARE hentry = i4 WITH protect, noconstant(0)
 DECLARE ientrycnt = i4 WITH protect, noconstant(0)
 DECLARE iattrcnt = i4 WITH protect, noconstant(0)
 DECLARE istrlen = i4 WITH protect, noconstant(255)
 DECLARE sentryname = c255 WITH noconstant("")
 DECLARE sprefval = c255 WITH noconstant("")
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE j = i4 WITH protect, noconstant(0)
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefcontext=default,prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddfilter(hpref,"prefgroup=cdi_globals")
 SET stat = uar_prefperform(hpref)
 IF (stat=false)
  SET npreferr = uar_prefgetlasterror()
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "uar_PrefPerform"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_PrefPerform"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = build("uar_PrefPerform failed, error=",
   npreferr)
  GO TO exit_script
 ENDIF
 SET stat = uar_prefgetentrycount(hpref,ientrycnt)
 FOR (i = 0 TO (ientrycnt - 1))
   SET hentry = uar_prefgetentry(hpref,i)
   SET istrlen = 255
   SET sentryname = " "
   SET stat = uar_prefgetentryname(hentry,sentryname,istrlen)
   IF (findstring("prefentry=cm_datasource",sentryname) > 0)
    SET iattrcnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,iattrcnt)
    IF (iattrcnt=1)
     SET hattr = uar_prefgetentryattr(hentry,0)
     SET istrlen = 255
     SET sprefval = " "
     SET stat = uar_prefgetattrval(hattr,sprefval,istrlen,0)
     SET reply->datasource = trim(sprefval)
    ENDIF
   ENDIF
   IF (findstring("prefentry=imagerepository",sentryname))
    SET iattrcnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,iattrcnt)
    IF (iattrcnt=1)
     SET hattr = uar_prefgetentryattr(hentry,0)
     SET ivalcnt = 0
     SET stat = uar_prefgetattrvalcount(hattr,ivalcnt)
     SET stat = alterlist(reply->image_repository,ivalcnt)
     FOR (j = 0 TO (ivalcnt - 1))
       SET istrlen = 255
       SET sprefval = " "
       SET stat = uar_prefgetattrval(hattr,sprefval,istrlen,j)
       SET reply->image_repository[(j+ 1)].repository_name = trim(sprefval)
     ENDFOR
    ENDIF
   ENDIF
   IF (findstring("prefentry=cm_webservicesurl",sentryname) > 0)
    SET iattrcnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,iattrcnt)
    IF (iattrcnt=1)
     SET hattr = uar_prefgetentryattr(hentry,0)
     SET istrlen = 255
     SET sprefval = " "
     SET stat = uar_prefgetattrval(hattr,sprefval,istrlen,0)
     SET reply->webservicesurl = trim(sprefval)
    ENDIF
   ENDIF
   IF (findstring("prefentry=cm_max_conn_pool",sentryname) > 0)
    SET iattrcnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,iattrcnt)
    IF (iattrcnt=1)
     SET hattr = uar_prefgetentryattr(hentry,0)
     SET istrlen = 20
     SET sprefval = " "
     SET stat = uar_prefgetattrval(hattr,sprefval,istrlen,0)
     SET reply->max_conn_pool = cnvtint(trim(sprefval))
    ENDIF
   ENDIF
   IF (findstring("prefentry=cm_min_conn_pool",sentryname) > 0)
    SET iattrcnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,iattrcnt)
    IF (iattrcnt=1)
     SET hattr = uar_prefgetentryattr(hentry,0)
     SET istrlen = 20
     SET sprefval = " "
     SET stat = uar_prefgetattrval(hattr,sprefval,istrlen,0)
     SET reply->min_conn_pool = cnvtint(trim(sprefval))
    ENDIF
   ENDIF
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_name=cfg_info_name
   AND di.info_domain=info_domain
  DETAIL
   cfg_domain = nullval(di.info_char," "), cfg_domain_exists_ind = 1
  WITH nocounter
 ;end select
 IF (cfg_domain_exists_ind=1
  AND cnvtupper(cfg_domain) != cnvtupper(curdomain))
  SET reply->datasource = " "
  SET reply->webservicesurl = " "
  SET reply->status_data.subeventstatus[1].operationname = "Config Domain Check"
  SET reply->status_data.subeventstatus[1].operationstatus = "W"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DM_INFO"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "The configurations domain does not match."
 ENDIF
#exit_script
END GO
