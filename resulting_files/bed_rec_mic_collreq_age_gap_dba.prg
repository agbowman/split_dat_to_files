CREATE PROGRAM bed_rec_mic_collreq_age_gap:dba
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
 FREE SET tempage
 RECORD tempage(
   1 alist[*]
     2 ord = f8
     2 service_res = f8
     2 age_to_min = i4
     2 age_from_min = i4
 )
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
 SET apat_cd = 0.0
 SET glbat_cd = 0.0
 SET apspecast_cd = 0.0
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
 SELECT DISTINCT INTO "nl:"
  ciq.sequence
  FROM order_catalog o,
   code_value cv1,
   code_value cv2,
   code_value cv3,
   orc_resource_list orl,
   code_value cv,
   collection_info_qualifiers ciq
  PLAN (o
   WHERE o.catalog_type_cd=genlab
    AND o.activity_type_cd=microat_cd
    AND o.orderable_type_flag IN (0, 1, 5, 10)
    AND o.bill_only_ind IN (0, null)
    AND o.active_ind=1
    AND o.catalog_cd > 0
    AND ((o.resource_route_lvl < 2) OR (o.resource_route_lvl=null)) )
   JOIN (cv1
   WHERE cv1.code_value=o.catalog_type_cd)
   JOIN (cv2
   WHERE cv2.code_value=o.activity_type_cd)
   JOIN (cv3
   WHERE cv3.code_value=o.activity_subtype_cd)
   JOIN (orl
   WHERE orl.catalog_cd=o.catalog_cd
    AND orl.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=orl.service_resource_cd
    AND cv.active_ind=1)
   JOIN (ciq
   WHERE ciq.catalog_cd=o.catalog_cd
    AND ciq.specimen_type_cd > 0)
  ORDER BY ciq.catalog_cd, ciq.service_resource_cd, ciq.age_from_minutes,
   ciq.age_to_minutes
  HEAD ciq.catalog_cd
   pass_ind = 0
  HEAD ciq.service_resource_cd
   acnt = 0
  DETAIL
   acnt = (acnt+ 1), stat = alterlist(tempage->alist,acnt), tempage->alist[acnt].ord = ciq.catalog_cd,
   tempage->alist[acnt].service_res = ciq.service_resource_cd, tempage->alist[acnt].age_from_min =
   ciq.age_from_minutes, tempage->alist[acnt].age_to_min = ciq.age_to_minutes
  FOOT  ciq.service_resource_cd
   IF (min(ciq.age_from_minutes)=0
    AND max(ciq.age_to_minutes)=78840000)
    IF (acnt > 1)
     FOR (x = 1 TO (acnt - 1))
       IF ((tempage->alist[x].age_to_min=tempage->alist[(x+ 1)].age_from_min))
        pass_ind = 1
       ELSE
        reply->run_status_flag = 3
       ENDIF
     ENDFOR
    ELSEIF (acnt=1)
     IF ((tempage->alist[acnt].age_from_min=0)
      AND (tempage->alist[acnt].age_to_min=78840000))
      pass_ind = 1
     ELSE
      reply->run_status_flag = 3
     ENDIF
    ENDIF
   ELSE
    reply->run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
 IF ((reply->run_status_flag=1))
  SELECT DISTINCT INTO "nl:"
   ciq.sequence
   FROM order_catalog o,
    code_value cv1,
    code_value cv2,
    code_value cv3,
    profile_task_r ptr,
    assay_resource_list apr,
    code_value cv,
    collection_info_qualifiers ciq
   PLAN (o
    WHERE o.catalog_type_cd=genlab
     AND o.activity_type_cd=microat_cd
     AND o.orderable_type_flag IN (0, 1, 5, 10)
     AND o.bill_only_ind IN (0, null)
     AND o.active_ind=1
     AND o.catalog_cd > 0
     AND o.resource_route_lvl=2)
    JOIN (cv1
    WHERE cv1.code_value=o.catalog_type_cd)
    JOIN (cv2
    WHERE cv2.code_value=o.activity_type_cd)
    JOIN (cv3
    WHERE cv3.code_value=o.activity_subtype_cd)
    JOIN (ptr
    WHERE ptr.catalog_cd=o.catalog_cd
     AND ptr.active_ind=1)
    JOIN (apr
    WHERE apr.task_assay_cd=ptr.task_assay_cd
     AND apr.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=apr.service_resource_cd
     AND cv.active_ind=1)
    JOIN (ciq
    WHERE ciq.catalog_cd=o.catalog_cd
     AND ciq.specimen_type_cd > 0)
   ORDER BY ciq.catalog_cd, ciq.service_resource_cd, ciq.age_from_minutes,
    ciq.age_to_minutes
   HEAD ciq.catalog_cd
    pass_ind = 0
   HEAD ciq.service_resource_cd
    acnt = 0
   DETAIL
    acnt = (acnt+ 1), stat = alterlist(tempage->alist,acnt), tempage->alist[acnt].age_from_min = ciq
    .age_from_minutes,
    tempage->alist[acnt].age_to_min = ciq.age_to_minutes
   FOOT  ciq.service_resource_cd
    IF (min(ciq.age_from_minutes)=0
     AND max(ciq.age_to_minutes)=78840000)
     IF (acnt > 1)
      FOR (x = 1 TO (acnt - 1))
        IF ((tempage->alist[x].age_to_min=tempage->alist[(x+ 1)].age_from_min))
         pass_ind = 1
        ELSE
         reply->run_status_flag = 3
        ENDIF
      ENDFOR
     ELSEIF (acnt=1)
      IF ((tempage->alist[acnt].age_from_min=0)
       AND (tempage->alist[acnt].age_to_min=78840000))
       pass_ind = 1
      ELSE
       reply->run_status_flag = 3
      ENDIF
     ENDIF
    ELSE
     reply->run_status_flag = 3
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
