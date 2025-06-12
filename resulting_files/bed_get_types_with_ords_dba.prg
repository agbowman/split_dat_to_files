CREATE PROGRAM bed_get_types_with_ords:dba
 FREE SET reply
 RECORD reply(
   1 catalog_types[*]
     2 code_value = f8
     2 display = vc
     2 mean = vc
     2 description = vc
     2 activity_types[*]
       3 code_value = f8
       3 display = vc
       3 mean = vc
       3 description = vc
       3 subactivity_types[*]
         4 code_value = f8
         4 display = vc
         4 mean = vc
         4 description = vc
   1 outbound_catalog_types[*]
     2 code_value = f8
     2 display = vc
     2 mean = vc
     2 description = vc
     2 outbound_activity_types[*]
       3 code_value = f8
       3 display = vc
       3 mean = vc
       3 description = vc
       3 outbound_subactivity_types[*]
         4 code_value = f8
         4 display = vc
         4 mean = vc
         4 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ccnt = 0
 SET acnt = 0
 SET scnt = 0
 SELECT DISTINCT INTO "NL:"
  FROM code_value_alias cva,
   order_catalog oc,
   code_value cv1,
   code_value cv2,
   code_value cv3
  PLAN (cva
   WHERE (cva.contributor_source_cd=request->contributor_source_code_value)
    AND cva.code_set=200)
   JOIN (oc
   WHERE oc.catalog_cd=cva.code_value
    AND oc.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=oc.catalog_type_cd
    AND cv1.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=oc.activity_type_cd
    AND cv2.active_ind=1)
   JOIN (cv3
   WHERE cv3.code_value=outerjoin(oc.activity_subtype_cd)
    AND cv3.active_ind=outerjoin(1))
  ORDER BY cv1.display, oc.catalog_type_cd, cv2.display,
   oc.activity_type_cd, cv3.display, oc.activity_subtype_cd
  HEAD oc.catalog_type_cd
   ccnt = (ccnt+ 1), stat = alterlist(reply->catalog_types,ccnt), reply->catalog_types[ccnt].
   code_value = cv1.code_value,
   reply->catalog_types[ccnt].display = cv1.display, reply->catalog_types[ccnt].mean = cv1
   .cdf_meaning, reply->catalog_types[ccnt].description = cv1.description,
   acnt = 0, scnt = 0
  HEAD oc.activity_type_cd
   acnt = (acnt+ 1), stat = alterlist(reply->catalog_types[ccnt].activity_types,acnt), reply->
   catalog_types[ccnt].activity_types[acnt].code_value = cv2.code_value,
   reply->catalog_types[ccnt].activity_types[acnt].display = cv2.display, reply->catalog_types[ccnt].
   activity_types[acnt].mean = cv2.cdf_meaning, reply->catalog_types[ccnt].activity_types[acnt].
   description = cv2.description,
   scnt = 0
  HEAD oc.activity_subtype_cd
   IF (oc.activity_subtype_cd > 0)
    scnt = (scnt+ 1), stat = alterlist(reply->catalog_types[ccnt].activity_types[acnt].
     subactivity_types,scnt), reply->catalog_types[ccnt].activity_types[acnt].subactivity_types[scnt]
    .code_value = cv3.code_value,
    reply->catalog_types[ccnt].activity_types[acnt].subactivity_types[scnt].display = cv3.display,
    reply->catalog_types[ccnt].activity_types[acnt].subactivity_types[scnt].mean = cv3.cdf_meaning,
    reply->catalog_types[ccnt].activity_types[acnt].subactivity_types[scnt].description = cv3
    .description
   ENDIF
  WITH nocounter
 ;end select
 SET ccnt = 0
 SET acnt = 0
 SET scnt = 0
 SELECT DISTINCT INTO "NL:"
  FROM code_value_outbound cvo,
   order_catalog oc,
   code_value cv1,
   code_value cv2,
   code_value cv3
  PLAN (cvo
   WHERE (cvo.contributor_source_cd=request->contributor_source_code_value)
    AND cvo.code_set=200)
   JOIN (oc
   WHERE oc.catalog_cd=cvo.code_value
    AND oc.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=oc.catalog_type_cd
    AND cv1.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=oc.activity_type_cd
    AND cv2.active_ind=1)
   JOIN (cv3
   WHERE cv3.code_value=outerjoin(oc.activity_subtype_cd)
    AND cv3.active_ind=outerjoin(1))
  ORDER BY cv1.display, oc.catalog_type_cd, cv2.display,
   oc.activity_type_cd, cv3.display, oc.activity_subtype_cd
  HEAD oc.catalog_type_cd
   ccnt = (ccnt+ 1), stat = alterlist(reply->outbound_catalog_types,ccnt), reply->
   outbound_catalog_types[ccnt].code_value = cv1.code_value,
   reply->outbound_catalog_types[ccnt].display = cv1.display, reply->outbound_catalog_types[ccnt].
   mean = cv1.cdf_meaning, reply->outbound_catalog_types[ccnt].description = cv1.description,
   acnt = 0, scnt = 0
  HEAD oc.activity_type_cd
   acnt = (acnt+ 1), stat = alterlist(reply->outbound_catalog_types[ccnt].outbound_activity_types,
    acnt), reply->outbound_catalog_types[ccnt].outbound_activity_types[acnt].code_value = cv2
   .code_value,
   reply->outbound_catalog_types[ccnt].outbound_activity_types[acnt].display = cv2.display, reply->
   outbound_catalog_types[ccnt].outbound_activity_types[acnt].mean = cv2.cdf_meaning, reply->
   outbound_catalog_types[ccnt].outbound_activity_types[acnt].description = cv2.description,
   scnt = 0
  HEAD oc.activity_subtype_cd
   IF (oc.activity_subtype_cd > 0)
    scnt = (scnt+ 1), stat = alterlist(reply->outbound_catalog_types[ccnt].outbound_activity_types[
     acnt].outbound_subactivity_types,scnt), reply->outbound_catalog_types[ccnt].
    outbound_activity_types[acnt].outbound_subactivity_types[scnt].code_value = cv3.code_value,
    reply->outbound_catalog_types[ccnt].outbound_activity_types[acnt].outbound_subactivity_types[scnt
    ].display = cv3.display, reply->outbound_catalog_types[ccnt].outbound_activity_types[acnt].
    outbound_subactivity_types[scnt].mean = cv3.cdf_meaning, reply->outbound_catalog_types[ccnt].
    outbound_activity_types[acnt].outbound_subactivity_types[scnt].description = cv3.description
   ENDIF
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
