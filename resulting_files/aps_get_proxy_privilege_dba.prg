CREATE PROGRAM aps_get_proxy_privilege:dba
 RECORD reply(
   1 name_full_formatted = vc
   1 person_id = f8
   1 qual[*]
     2 privilege_cd = f8
     2 privilege_disp = c40
     2 privilege_mean = c12
     2 privilege_id = f8
     2 parent_entity_qual[*]
       3 parent_entity_id = f8
       3 parent_entity_name = c32
       3 entity_name = vc
       3 proxy_beg_dt_tm = dq8
       3 proxy_end_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE (reqinfo->updt_id=p.person_id)
  DETAIL
   reply->name_full_formatted = p.name_full_formatted, reply->person_id = p.person_id
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT INTO "nl:"
   app.prsnl_id, app.privilege_id, app.privilege_cd,
   appr.parent_entity_name, appr.parent_entity_id, appr.proxy_beg_dt_tm,
   appr.proxy_end_dt_tm
   FROM prsnl p,
    prsnl_group pg,
    ap_prsnl_priv app,
    ap_prsnl_priv_r appr,
    code_value cv,
    dummyt d1,
    dummyt d2
   PLAN (app
    WHERE (app.prsnl_id=reply->person_id))
    JOIN (cv
    WHERE cv.code_value=app.privilege_cd
     AND parser(
     IF (nullval(request->proxy_type_flag,0) != 0)
      "cv.definition = cnvtstring(request->proxy_type_flag)"
     ELSE "1=1"
     ENDIF
     ))
    JOIN (appr
    WHERE appr.privilege_id=app.privilege_id)
    JOIN (d1)
    JOIN (((pg
    WHERE appr.parent_entity_id=pg.prsnl_group_id
     AND appr.parent_entity_name="PRSNL_GROUP")
    ) ORJOIN ((d2)
    JOIN (p
    WHERE appr.parent_entity_id=p.person_id
     AND appr.parent_entity_name="PRSNL")
    ))
   ORDER BY app.privilege_id
   HEAD REPORT
    priv_cnt = 0
   HEAD app.privilege_id
    entity_cnt = 0, priv_cnt = (priv_cnt+ 1)
    IF (mod(priv_cnt,10)=1)
     stat = alterlist(reply->qual,(priv_cnt+ 9))
    ENDIF
    reply->qual[priv_cnt].privilege_cd = app.privilege_cd, reply->qual[priv_cnt].privilege_id = app
    .privilege_id
   DETAIL
    entity_cnt = (entity_cnt+ 1)
    IF (mod(entity_cnt,10)=1)
     stat = alterlist(reply->qual[priv_cnt].parent_entity_qual,(entity_cnt+ 9))
    ENDIF
    reply->qual[priv_cnt].parent_entity_qual[entity_cnt].parent_entity_id = appr.parent_entity_id,
    reply->qual[priv_cnt].parent_entity_qual[entity_cnt].parent_entity_name = appr.parent_entity_name
    IF (appr.parent_entity_name="PRSNL")
     reply->qual[priv_cnt].parent_entity_qual[entity_cnt].entity_name = p.name_full_formatted
    ELSE
     reply->qual[priv_cnt].parent_entity_qual[entity_cnt].entity_name = pg.prsnl_group_name
    ENDIF
    reply->qual[priv_cnt].parent_entity_qual[entity_cnt].proxy_beg_dt_tm = appr.proxy_beg_dt_tm,
    reply->qual[priv_cnt].parent_entity_qual[entity_cnt].proxy_end_dt_tm = appr.proxy_end_dt_tm
   FOOT  app.privilege_id
    stat = alterlist(reply->qual[priv_cnt].parent_entity_qual,entity_cnt)
   FOOT REPORT
    stat = alterlist(reply->qual,priv_cnt)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PRSNL_PRIV_R"
  ENDIF
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PERSON"
 ENDIF
END GO
