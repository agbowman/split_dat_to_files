CREATE PROGRAM bed_rec_mic_collreq_all_row:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 run_status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE genlab = f8 WITH public, noconstant(0.0)
 DECLARE microat_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="GENERAL LAB"
    AND cv.active_ind=1)
  DETAIL
   genlab = cv.code_value
  WITH nocounter
 ;end select
 SET glbat_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="MICROBIOLOGY"
    AND cv.active_ind=1)
  DETAIL
   microat_cd = cv.code_value
  WITH nocounter
 ;end select
 SET reply->run_status_flag = 1
 SELECT INTO "nl:"
  FROM order_catalog o,
   orc_resource_list orl,
   code_value cv,
   dummyt d,
   collection_info_qualifiers ciq
  PLAN (o
   WHERE o.catalog_type_cd=genlab
    AND o.activity_type_cd=microat_cd
    AND o.orderable_type_flag IN (0, 1, 5, 10)
    AND o.bill_only_ind IN (0, null)
    AND o.active_ind=1
    AND o.catalog_cd > 0
    AND ((o.resource_route_lvl < 2) OR (o.resource_route_lvl=null)) )
   JOIN (orl
   WHERE orl.catalog_cd=o.catalog_cd
    AND orl.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=orl.service_resource_cd
    AND cv.active_ind=1)
   JOIN (d)
   JOIN (ciq
   WHERE ciq.catalog_cd=o.catalog_cd
    AND ciq.specimen_type_cd > 0
    AND ciq.service_resource_cd=0)
  DETAIL
   reply->run_status_flag = 3
  WITH nocounter, outerjoin = d, dontexist
 ;end select
 IF ((reply->run_status_flag=1))
  SELECT INTO "nl:"
   FROM order_catalog o,
    profile_task_r ptr,
    assay_resource_list apr,
    code_value cv,
    dummyt d,
    collection_info_qualifiers ciq
   PLAN (o
    WHERE o.catalog_type_cd=genlab
     AND o.activity_type_cd=microat_cd
     AND o.orderable_type_flag IN (0, 1, 5, 10)
     AND o.bill_only_ind IN (0, null)
     AND o.active_ind=1
     AND o.catalog_cd > 0
     AND o.resource_route_lvl=2)
    JOIN (ptr
    WHERE ptr.catalog_cd=o.catalog_cd
     AND ptr.active_ind=1)
    JOIN (apr
    WHERE apr.task_assay_cd=ptr.task_assay_cd
     AND apr.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=apr.service_resource_cd
     AND cv.active_ind=1)
    JOIN (d)
    JOIN (ciq
    WHERE ciq.catalog_cd=o.catalog_cd
     AND ciq.specimen_type_cd > 0
     AND ciq.service_resource_cd=0)
   DETAIL
    reply->run_status_flag = 3
   WITH nocounter, outerjoin = d, dontexist
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
