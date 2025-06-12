CREATE PROGRAM bed_get_bb_assays:dba
 FREE SET reply
 RECORD reply(
   1 assays[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
   1 too_many_results_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_count = 0
 SET max_cnt = 0
 IF ((request->max_reply > 0))
  SET max_cnt = request->max_reply
 ELSE
  SET max_cnt = 10000
 ENDIF
 SET bb_act_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=106
   AND cv.cdf_meaning="BB"
   AND cv.active_ind=1
  DETAIL
   bb_act_cd = cv.code_value
  WITH nocounter
 ;end select
 SET alpha_cd = 0.0
 SET interp_cd = 0.0
 SET numeric_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=289
   AND cv.cdf_meaning IN ("2", "4", "3")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="2")
    alpha_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="4")
    interp_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="3")
    numeric_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->assays,100)
 SELECT DISTINCT INTO "NL:"
  FROM discrete_task_assay dta,
   profile_task_r ptr,
   order_catalog oc,
   orc_resource_list orl,
   assay_processing_r apr,
   code_value cv
  PLAN (dta
   WHERE dta.activity_type_cd=bb_act_cd
    AND dta.active_ind=1)
   JOIN (ptr
   WHERE ptr.task_assay_cd=dta.task_assay_cd
    AND ptr.active_ind=1)
   JOIN (oc
   WHERE oc.catalog_cd=ptr.catalog_cd
    AND oc.active_ind=1)
   JOIN (orl
   WHERE orl.catalog_cd=ptr.catalog_cd
    AND orl.service_resource_cd > 0
    AND orl.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=orl.service_resource_cd
    AND cv.active_ind=1)
   JOIN (apr
   WHERE apr.active_ind=outerjoin(1)
    AND apr.task_assay_cd=outerjoin(dta.task_assay_cd))
  ORDER BY dta.task_assay_cd
  HEAD dta.task_assay_cd
   temp_field = 0
  DETAIL
   move_ind = 0
   IF ((request->alpha_ind=1)
    AND ((dta.default_result_type_cd IN (alpha_cd, interp_cd)) OR (apr.default_result_type_cd IN (
   alpha_cd, interp_cd))) )
    move_ind = 1
   ENDIF
   IF ((request->numeric_ind=1)
    AND ((dta.default_result_type_cd=numeric_cd) OR (apr.default_result_type_cd=numeric_cd)) )
    move_ind = 1
   ENDIF
   IF (move_ind=1)
    found = 0
    FOR (i = 1 TO tot_count)
      IF ((reply->assays[i].code_value=dta.task_assay_cd))
       found = 1, i = tot_count
      ENDIF
    ENDFOR
    IF (found=0)
     tot_count = (tot_count+ 1), stat = alterlist(reply->assays,tot_count), reply->assays[tot_count].
     code_value = dta.task_assay_cd,
     reply->assays[tot_count].display = dta.mnemonic, reply->assays[tot_count].description = dta
     .description
    ENDIF
   ENDIF
  WITH maxqual(p,value((max_cnt+ 2))), nocounter
 ;end select
 SELECT DISTINCT INTO "NL:"
  FROM discrete_task_assay dta,
   profile_task_r ptr,
   order_catalog oc,
   assay_processing_r apr,
   code_value cv
  PLAN (dta
   WHERE dta.activity_type_cd=bb_act_cd
    AND dta.active_ind=1)
   JOIN (ptr
   WHERE ptr.task_assay_cd=dta.task_assay_cd
    AND ptr.active_ind=1)
   JOIN (oc
   WHERE oc.catalog_cd=ptr.catalog_cd
    AND oc.resource_route_lvl=2
    AND oc.active_ind=1)
   JOIN (apr
   WHERE apr.active_ind=1
    AND apr.task_assay_cd=dta.task_assay_cd)
   JOIN (cv
   WHERE cv.code_value=apr.service_resource_cd
    AND cv.active_ind=1)
  ORDER BY dta.task_assay_cd
  HEAD dta.task_assay_cd
   temp_field = 0
  DETAIL
   move_ind = 0
   IF ((request->alpha_ind=1)
    AND ((dta.default_result_type_cd IN (alpha_cd, interp_cd)) OR (apr.default_result_type_cd IN (
   alpha_cd, interp_cd))) )
    move_ind = 1
   ENDIF
   IF ((request->numeric_ind=1)
    AND ((dta.default_result_type_cd=numeric_cd) OR (apr.default_result_type_cd=numeric_cd)) )
    move_ind = 1
   ENDIF
   IF (move_ind=1)
    found = 0
    FOR (i = 1 TO tot_count)
      IF ((reply->assays[i].code_value=dta.task_assay_cd))
       found = 1, i = tot_count
      ENDIF
    ENDFOR
    IF (found=0)
     tot_count = (tot_count+ 1), stat = alterlist(reply->assays,tot_count), reply->assays[tot_count].
     code_value = dta.task_assay_cd,
     reply->assays[tot_count].display = dta.mnemonic, reply->assays[tot_count].description = dta
     .description
    ENDIF
   ENDIF
  WITH maxqual(p,value((max_cnt+ 2))), nocounter
 ;end select
 IF (tot_count > max_cnt)
  SET stat = alterlist(reply->assays,0)
  SET reply->too_many_results_ind = 1
 ELSE
  SET stat = alterlist(reply->assays,tot_count)
 ENDIF
#exit_script
 IF (tot_count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
