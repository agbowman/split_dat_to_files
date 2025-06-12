CREATE PROGRAM dcp_get_avail_query_templates:dba
 RECORD reply(
   1 templates[*]
     2 template_id = f8
     2 query_type_cd = f8
     2 name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE templatescnt = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM prsnl p,
   dcp_pl_query_temp_access dpqta,
   dcp_pl_query_template dpqt
  PLAN (p
   WHERE (p.person_id=request->provider_id))
   JOIN (dpqta
   WHERE dpqta.position_cd=p.position_cd)
   JOIN (dpqt
   WHERE dpqt.template_id=dpqta.template_id)
  HEAD REPORT
   templatescnt = 0
  DETAIL
   IF (mod(templatescnt,10)=0)
    stat = alterlist(reply->templates,(templatescnt+ 10))
   ENDIF
   templatescnt = (templatescnt+ 1), reply->templates[templatescnt].template_id = dpqta.template_id,
   reply->templates[templatescnt].query_type_cd = dpqt.query_type_cd,
   reply->templates[templatescnt].name = dpqt.template_name
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prsnl_group_reltn pgr,
   dcp_pl_query_temp_access dpqta,
   dcp_pl_query_template dpqt
  PLAN (pgr
   WHERE (pgr.person_id=request->provider_id))
   JOIN (dpqta
   WHERE dpqta.provider_group_id=pgr.prsnl_group_id)
   JOIN (dpqt
   WHERE dpqt.template_id=dpqta.template_id)
  DETAIL
   IF (mod(templatescnt,10)=0)
    stat = alterlist(reply->templates,(templatescnt+ 10))
   ENDIF
   templatescnt = (templatescnt+ 1), reply->templates[templatescnt].template_id = dpqta.template_id,
   reply->templates[templatescnt].query_type_cd = dpqt.query_type_cd,
   reply->templates[templatescnt].name = dpqt.template_name
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dcp_pl_query_temp_access dpqta,
   dcp_pl_query_template dpqt
  PLAN (dpqta
   WHERE (dpqta.provider_id=request->provider_id))
   JOIN (dpqt
   WHERE dpqt.template_id=dpqta.template_id)
  DETAIL
   IF (mod(templatescnt,10)=0)
    stat = alterlist(reply->templates,(templatescnt+ 10))
   ENDIF
   templatescnt = (templatescnt+ 1), reply->templates[templatescnt].template_id = dpqta.template_id,
   reply->templates[templatescnt].query_type_cd = dpqt.query_type_cd,
   reply->templates[templatescnt].name = dpqt.template_name
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->templates,templatescnt)
 DECLARE x = i4 WITH noconstant(0)
 DECLARE y = i4 WITH noconstant(0)
 DECLARE found = i2 WITH noconstant(0)
 DECLARE actcnt = i4 WITH noconstant(0)
 FOR (x = 1 TO templatescnt)
   FOR (y = (x+ 1) TO templatescnt)
     IF ((reply->templates[x].template_id=reply->templates[y].template_id))
      SET found = 1
      SET y = templatescnt
     ENDIF
   ENDFOR
   IF (found=0)
    SET actcnt = (actcnt+ 1)
    SET reply->templates[actcnt].template_id = reply->templates[x].template_id
    SET reply->templates[actcnt].query_type_cd = reply->templates[x].query_type_cd
    SET reply->templates[actcnt].name = reply->templates[x].name
   ENDIF
   SET found = 0
 ENDFOR
 SET stat = alterlist(reply->templates,actcnt)
 IF (templatescnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
