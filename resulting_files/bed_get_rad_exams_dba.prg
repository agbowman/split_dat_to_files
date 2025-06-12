CREATE PROGRAM bed_get_rad_exams:dba
 FREE SET reply
 RECORD reply(
   1 exams[*]
     2 code_value = f8
     2 display = c40
     2 description = c60
     2 assigned_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 service_resources[*]
     2 code_value = f8
 )
 SET reply->status_data.status = "F"
 SET dcnt = size(request->departments,5)
 SET rad_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=106
   AND cv.cdf_meaning="RADIOLOGY"
   AND cv.active_ind=1
  DETAIL
   rad_cd = cv.code_value
  WITH nocounter
 ;end select
 SET datetime_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=289
   AND cv.cdf_meaning="11"
   AND cv.active_ind=1
  DETAIL
   datetime_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE oc_parse = vc
 IF ((request->activity_subtype_code_value=0))
  SET oc_parse = concat("oc.orderable_type_flag != 6 and oc.orderable_type_flag != 2",
   " and oc.catalog_cd = ptr.catalog_cd and oc.active_ind = 1")
 ELSE
  SET subtype = build(request->activity_subtype_code_value)
  SET oc_parse = concat("oc.orderable_type_flag != 6 and oc.orderable_type_flag != 2",
   " and oc.catalog_cd = ptr.catalog_cd and oc.active_ind = 1"," and oc.activity_subtype_cd = ",
   subtype)
 ENDIF
 CALL echo(oc_parse)
 SET ecnt = 0
 SET alterlist_ecnt = 0
 SET stat = alterlist(reply->exams,100)
 SELECT INTO "nl:"
  FROM discrete_task_assay dta,
   code_value cv,
   profile_task_r ptr,
   order_catalog oc
  PLAN (dta
   WHERE dta.activity_type_cd=rad_cd
    AND dta.default_result_type_cd=datetime_cd
    AND dta.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=dta.task_assay_cd
    AND cv.active_ind=1)
   JOIN (ptr
   WHERE ptr.task_assay_cd=cv.code_value
    AND ptr.active_ind=1)
   JOIN (oc
   WHERE parser(oc_parse))
  ORDER BY cv.code_value
  HEAD cv.code_value
   ecnt = (ecnt+ 1), alterlist_ecnt = (alterlist_ecnt+ 1)
   IF (alterlist_ecnt > 100)
    stat = alterlist(reply->exams,(ecnt+ 100)), alterlist_ecnt = 1
   ENDIF
   reply->exams[ecnt].code_value = cv.code_value, reply->exams[ecnt].display = cv.display, reply->
   exams[ecnt].description = cv.description
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->exams,ecnt)
 SET stat = alterlist(temp->service_resources,100)
 SET scnt = 0
 SET tot_scnt = 0
 IF (dcnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = dcnt),
    code_value cv,
    resource_group r1,
    resource_group r2,
    resource_group r3
   PLAN (d)
    JOIN (r1
    WHERE (r1.parent_service_resource_cd=request->departments[d.seq].code_value)
     AND r1.active_ind=1)
    JOIN (r2
    WHERE r2.parent_service_resource_cd=r1.child_service_resource_cd
     AND r2.active_ind=1)
    JOIN (r3
    WHERE r3.parent_service_resource_cd=r2.child_service_resource_cd
     AND r3.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=r3.child_service_resource_cd
     AND cv.active_ind=1
     AND cv.code_set=221
     AND cv.cdf_meaning="RADEXAMROOM")
   DETAIL
    tot_scnt = (tot_scnt+ 1), scnt = (scnt+ 1)
    IF (scnt > 100)
     stat = alterlist(temp->service_resources,(tot_scnt+ 100)), scnt = 0
    ENDIF
    temp->service_resources[tot_scnt].code_value = cv.code_value
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->load_assigned_ind=1))
  IF (dcnt > 0)
   IF (tot_scnt > 0
    AND ecnt > 0)
    FOR (e = 1 TO ecnt)
      SELECT INTO "NL:"
       FROM (dummyt d  WITH seq = tot_scnt),
        assay_resource_list arl
       PLAN (d
        WHERE (reply->exams[e].assigned_ind=0))
        JOIN (arl
        WHERE (arl.task_assay_cd=reply->exams[e].code_value)
         AND (arl.service_resource_cd=temp->service_resources[d.seq].code_value)
         AND arl.active_ind=1)
       DETAIL
        reply->exams[e].assigned_ind = 1
       WITH nocounter
      ;end select
    ENDFOR
   ENDIF
  ELSE
   IF (ecnt > 0)
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = ecnt),
      assay_resource_list asl,
      code_value cv
     PLAN (d)
      JOIN (asl
      WHERE (asl.task_assay_cd=reply->exams[d.seq].code_value)
       AND asl.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=asl.service_resource_cd
       AND cv.active_ind=1)
     DETAIL
      reply->exams[d.seq].assigned_ind = 1
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
