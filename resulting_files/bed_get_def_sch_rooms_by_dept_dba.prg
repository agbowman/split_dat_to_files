CREATE PROGRAM bed_get_def_sch_rooms_by_dept:dba
 FREE SET reply
 RECORD reply(
   1 sections[*]
     2 code_value = f8
     2 display = vc
     2 subsections[*]
       3 code_value = f8
       3 display = vc
       3 service_resources[*]
         4 code_value = f8
         4 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 FREE SET valid_inst
 RECORD valid_inst(
   1 inst[*]
     2 code_value = f8
 )
 SET inst_cd = 0.0
 SET dept_cd = 0.0
 SET sect_cd = 0.0
 SET subsect_cd = 0.0
 SET radexamroom_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=223
   AND cv.cdf_meaning IN ("INSTITUTION", "DEPARTMENT", "SECTION", "SUBSECTION", "RADEXAMROOM")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="INSTITUTION")
    inst_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="DEPARTMENT")
    dept_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="SECTION")
    sect_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="SUBSECTION")
    subsect_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="RADEXAMROOM")
    radexamroom_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET valid_inst_cnt = 0
 SELECT INTO "nl:"
  FROM location l,
   service_resource sr
  PLAN (l
   WHERE (l.location_cd=request->department_code_value)
    AND l.active_ind=1)
   JOIN (sr
   WHERE sr.organization_id=l.organization_id
    AND sr.service_resource_type_cd=inst_cd
    AND sr.active_ind=1)
  DETAIL
   found_ind = 0, start = 1, num = 0
   IF (valid_inst_cnt > 0)
    found_ind = locateval(num,start,valid_inst_cnt,sr.service_resource_cd,valid_inst->inst[num].
     code_value)
   ENDIF
   IF (found_ind=0)
    valid_inst_cnt = (valid_inst_cnt+ 1), stat = alterlist(valid_inst->inst,valid_inst_cnt),
    valid_inst->inst[valid_inst_cnt].code_value = sr.service_resource_cd
   ENDIF
  WITH nocounter
 ;end select
 IF (valid_inst_cnt > 0)
  SET scnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(valid_inst_cnt)),
    resource_group rg1,
    resource_group rg2,
    resource_group rg3,
    resource_group rg4,
    service_resource sr,
    code_value cv1,
    code_value cv2,
    code_value cv3,
    code_value cv4,
    code_value cv5
   PLAN (d)
    JOIN (rg1
    WHERE (rg1.parent_service_resource_cd=valid_inst->inst[d.seq].code_value)
     AND rg1.resource_group_type_cd=inst_cd
     AND rg1.active_ind=1)
    JOIN (rg2
    WHERE rg2.parent_service_resource_cd=rg1.child_service_resource_cd
     AND rg2.resource_group_type_cd=dept_cd
     AND rg2.active_ind=1)
    JOIN (rg3
    WHERE rg3.parent_service_resource_cd=rg2.child_service_resource_cd
     AND rg3.resource_group_type_cd=sect_cd
     AND rg3.active_ind=1)
    JOIN (rg4
    WHERE rg4.parent_service_resource_cd=rg3.child_service_resource_cd
     AND rg4.resource_group_type_cd=subsect_cd
     AND rg4.active_ind=1)
    JOIN (sr
    WHERE sr.service_resource_cd=rg4.child_service_resource_cd
     AND sr.service_resource_type_cd=radexamroom_cd
     AND sr.active_ind=1
     AND  NOT ( EXISTS (
    (SELECT
     s.resource_cd
     FROM sch_resource s
     WHERE s.service_resource_cd=sr.service_resource_cd
      AND s.active_ind=1))))
    JOIN (cv1
    WHERE cv1.code_value=rg1.parent_service_resource_cd
     AND cv1.active_ind=1)
    JOIN (cv2
    WHERE cv2.code_value=rg2.parent_service_resource_cd
     AND cv2.active_ind=1)
    JOIN (cv3
    WHERE cv3.code_value=rg3.parent_service_resource_cd
     AND cv3.active_ind=1)
    JOIN (cv4
    WHERE cv4.code_value=rg4.parent_service_resource_cd
     AND cv4.active_ind=1)
    JOIN (cv5
    WHERE cv5.code_value=sr.service_resource_cd
     AND cv5.active_ind=1)
   ORDER BY rg3.parent_service_resource_cd, rg4.parent_service_resource_cd
   HEAD rg3.parent_service_resource_cd
    scnt = (scnt+ 1), stat = alterlist(reply->sections,scnt), reply->sections[scnt].code_value = cv3
    .code_value,
    reply->sections[scnt].display = cv3.display, sscnt = 0
   HEAD rg4.parent_service_resource_cd
    sscnt = (sscnt+ 1), stat = alterlist(reply->sections[scnt].subsections,sscnt), reply->sections[
    scnt].subsections[sscnt].code_value = cv4.code_value,
    reply->sections[scnt].subsections[sscnt].display = cv4.display, rcnt = 0
   DETAIL
    rcnt = (rcnt+ 1), stat = alterlist(reply->sections[scnt].subsections[sscnt].service_resources,
     rcnt), reply->sections[scnt].subsections[sscnt].service_resources[rcnt].code_value = cv5
    .code_value,
    reply->sections[scnt].subsections[sscnt].service_resources[rcnt].display = cv5.display
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
