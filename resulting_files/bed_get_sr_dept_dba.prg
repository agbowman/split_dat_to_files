CREATE PROGRAM bed_get_sr_dept:dba
 FREE SET reply
 RECORD reply(
   1 dept_list[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 prefix = c2
     2 section_found_ind = i2
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET tot_sr = 0
 SET sr_count = 0
 SET inst_type_cd = 0.0
 IF ((request->institution_code_value=0))
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=223
    AND cv.active_ind=1
    AND cv.cdf_meaning="INSTITUTION"
   DETAIL
    inst_type_cd = cv.code_value
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   FROM service_resource s
   PLAN (s
    WHERE (s.organization_id=request->org_id)
     AND s.service_resource_type_cd=inst_type_cd
     AND s.active_ind=1)
   ORDER BY s.service_resource_cd
   HEAD s.service_resource_cd
    request->institution_code_value = s.service_resource_cd
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->institution_code_value > 0))
  SET stat = alterlist(reply->dept_list,100)
  SELECT INTO "NL:"
   FROM resource_group inst_r,
    code_value cv,
    service_resource s,
    resource_group r,
    br_name_value bnv
   PLAN (inst_r
    WHERE inst_r.active_ind=1
     AND (inst_r.parent_service_resource_cd=request->institution_code_value))
    JOIN (s
    WHERE s.active_ind=1
     AND (s.discipline_type_cd=request->discipline_type_code_value)
     AND s.service_resource_cd=inst_r.child_service_resource_cd)
    JOIN (cv
    WHERE cv.code_value=s.service_resource_cd
     AND cv.active_ind=1
     AND cv.code_set=221
     AND cv.cdf_meaning="DEPARTMENT")
    JOIN (r
    WHERE r.parent_service_resource_cd=outerjoin(cv.code_value)
     AND r.active_ind=outerjoin(1))
    JOIN (bnv
    WHERE bnv.br_nv_key1=outerjoin("SR_DEPTPREFIX")
     AND bnv.br_value=outerjoin(cnvtstring(s.service_resource_cd)))
   ORDER BY cv.display_key
   HEAD cv.code_value
    tot_sr = (tot_sr+ 1), sr_count = (sr_count+ 1)
    IF (sr_count > 100)
     stat = alterlist(reply->dept_list,(tot_sr+ 100)), sr_count = 0
    ENDIF
    reply->dept_list[tot_sr].code_value = cv.code_value, reply->dept_list[tot_sr].display = cv
    .display, reply->dept_list[tot_sr].description = cv.description
    IF (bnv.br_name > "  ")
     reply->dept_list[tot_sr].prefix = bnv.br_name
    ENDIF
   DETAIL
    IF (r.parent_service_resource_cd > 0)
     reply->dept_list[tot_sr].section_found_ind = 1
    ELSE
     reply->dept_list[tot_sr].section_found_ind = 0
    ENDIF
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->dept_list,tot_sr)
 ENDIF
#exit_script
 IF (tot_sr > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
