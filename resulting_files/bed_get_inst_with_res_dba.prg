CREATE PROGRAM bed_get_inst_with_res:dba
 FREE SET reply
 RECORD reply(
   1 institutions[*]
     2 display = vc
     2 code_value = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 ilist[*]
     2 inst_display = vc
     2 inst_code_value = f8
     2 with_res_ind = i2
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "F"
 SET inst_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="INSTITUTION")
  ORDER BY cv.code_value
  HEAD cv.code_value
   inst_cd = cv.code_value
  WITH nocounter
 ;end select
 SET dept_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="DEPARTMENT")
  ORDER BY cv.code_value
  HEAD cv.code_value
   dept_cd = cv.code_value
  WITH nocounter
 ;end select
 SET sect_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="SECTION")
  ORDER BY cv.code_value
  HEAD cv.code_value
   sect_cd = cv.code_value
  WITH nocounter
 ;end select
 SET subsect_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="SUBSECTION")
  ORDER BY cv.code_value
  HEAD cv.code_value
   subsect_cd = cv.code_value
  WITH nocounter
 ;end select
 SET instr_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="INSTRUMENT")
  ORDER BY cv.code_value
  HEAD cv.code_value
   instr_cd = cv.code_value
  WITH nocounter
 ;end select
 SET bench_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="BENCH")
  ORDER BY cv.code_value
  HEAD cv.code_value
   bench_cd = cv.code_value
  WITH nocounter
 ;end select
 SET icnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=221
    AND cv.cdf_meaning="INSTITUTION")
  ORDER BY cv.display_key
  HEAD REPORT
   icnt = 0
  DETAIL
   icnt = (icnt+ 1), stat = alterlist(temp->ilist,icnt), temp->ilist[icnt].inst_code_value = cv
   .code_value,
   temp->ilist[icnt].inst_display = cv.display, temp->ilist[icnt].with_res_ind = 0
  WITH nocounter
 ;end select
 IF (icnt=0)
  SET error_flag = "T"
  SET error_msg = "No institutions on code set 221"
  GO TO exit_script
 ENDIF
 CALL echo(build("icnt:",icnt))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = icnt),
   resource_group rg1,
   resource_group rg2,
   resource_group rg3,
   resource_group rg4,
   service_resource sr
  PLAN (d)
   JOIN (rg1
   WHERE (rg1.parent_service_resource_cd=temp->ilist[d.seq].inst_code_value)
    AND rg1.resource_group_type_cd=inst_cd)
   JOIN (rg2
   WHERE rg2.parent_service_resource_cd=rg1.child_service_resource_cd
    AND rg2.resource_group_type_cd=dept_cd)
   JOIN (rg3
   WHERE rg3.parent_service_resource_cd=rg2.child_service_resource_cd
    AND rg3.resource_group_type_cd=sect_cd)
   JOIN (rg4
   WHERE rg4.parent_service_resource_cd=rg3.child_service_resource_cd
    AND rg4.resource_group_type_cd=subsect_cd)
   JOIN (sr
   WHERE sr.service_resource_cd=rg4.child_service_resource_cd
    AND sr.service_resource_type_cd IN (bench_cd, instr_cd))
  DETAIL
   temp->ilist[d.seq].with_res_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = icnt),
   resource_group rg1,
   resource_group rg2,
   resource_group rg3,
   sub_section ss
  PLAN (d
   WHERE (temp->ilist[d.seq].with_res_ind=0))
   JOIN (rg1
   WHERE (rg1.parent_service_resource_cd=temp->ilist[d.seq].inst_code_value)
    AND rg1.resource_group_type_cd=inst_cd)
   JOIN (rg2
   WHERE rg2.parent_service_resource_cd=rg1.child_service_resource_cd
    AND rg2.resource_group_type_cd=dept_cd)
   JOIN (rg3
   WHERE rg3.parent_service_resource_cd=rg2.child_service_resource_cd
    AND rg3.resource_group_type_cd=sect_cd)
   JOIN (ss
   WHERE ss.service_resource_cd=rg3.child_service_resource_cd
    AND ss.multiplexor_ind=1)
  DETAIL
   temp->ilist[d.seq].with_res_ind = 1
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->institutions,icnt)
 SET rcnt = 0
 FOR (x = 1 TO icnt)
   IF ((temp->ilist[x].with_res_ind=1))
    SET rcnt = (rcnt+ 1)
    SET reply->institutions[rcnt].code_value = temp->ilist[x].inst_code_value
    SET reply->institutions[rcnt].display = temp->ilist[x].inst_display
   ENDIF
 ENDFOR
 IF (rcnt > 0)
  SET stat = alterlist(reply->institutions,rcnt)
 ENDIF
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 SET reply->error_msg = error_msg
 CALL echorecord(reply)
END GO
