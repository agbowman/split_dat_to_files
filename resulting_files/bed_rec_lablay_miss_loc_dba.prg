CREATE PROGRAM bed_rec_lablay_miss_loc:dba
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
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET reply->run_status_flag = 1
 SET lab_ct_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6000
   AND cv.cdf_meaning="GENERAL LAB"
   AND cv.active_ind=1
  DETAIL
   lab_ct_cd = cv.code_value
  WITH nocounter
 ;end select
 SET inst_cd = 0.0
 SET dept_cd = 0.0
 SET sect_cd = 0.0
 SET subsect_cd = 0.0
 SET bench_cd = 0.0
 SET instr_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=223
   AND cv.cdf_meaning IN ("INSTITUTION", "DEPARTMENT", "SECTION", "SUBSECTION", "BENCH",
  "INSTRUMENT")
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
   ELSEIF (cv.cdf_meaning="BENCH")
    bench_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="INSTRUMENT")
    instr_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET missing_loc_ind = 0
 SELECT INTO "nl:"
  FROM service_resource sr,
   code_value cv,
   dummyt d1,
   resource_group rg1,
   service_resource sr1,
   code_value cv1,
   dummyt d2,
   resource_group rg2,
   service_resource sr2,
   code_value cv2,
   dummyt d3,
   resource_group rg3,
   service_resource sr3,
   code_value cv3,
   sub_section ss,
   dummyt d4,
   resource_group rg4,
   service_resource sr4,
   code_value cv4
  PLAN (sr
   WHERE sr.service_resource_type_cd=inst_cd
    AND sr.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=sr.service_resource_cd
    AND cv.active_ind=1)
   JOIN (d1)
   JOIN (rg1
   WHERE rg1.parent_service_resource_cd=cv.code_value
    AND rg1.resource_group_type_cd=inst_cd
    AND rg1.active_ind=1)
   JOIN (sr1
   WHERE sr1.service_resource_cd=rg1.child_service_resource_cd
    AND sr1.service_resource_type_cd=dept_cd
    AND sr1.active_ind=1
    AND sr1.discipline_type_cd IN (0, lab_ct_cd))
   JOIN (cv1
   WHERE cv1.code_value=sr1.service_resource_cd
    AND cv1.active_ind=1)
   JOIN (d2)
   JOIN (rg2
   WHERE rg2.parent_service_resource_cd=cv1.code_value
    AND rg2.resource_group_type_cd=dept_cd
    AND rg2.active_ind=1)
   JOIN (sr2
   WHERE sr2.service_resource_cd=rg2.child_service_resource_cd
    AND sr2.service_resource_type_cd=sect_cd
    AND sr2.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=sr2.service_resource_cd
    AND cv2.active_ind=1)
   JOIN (d3)
   JOIN (rg3
   WHERE rg3.parent_service_resource_cd=cv2.code_value
    AND rg3.resource_group_type_cd=sect_cd
    AND rg3.active_ind=1)
   JOIN (sr3
   WHERE sr3.service_resource_cd=rg3.child_service_resource_cd
    AND sr3.service_resource_type_cd=subsect_cd
    AND sr3.active_ind=1)
   JOIN (cv3
   WHERE cv3.code_value=sr3.service_resource_cd
    AND cv3.active_ind=1)
   JOIN (ss
   WHERE ss.service_resource_cd=sr3.service_resource_cd)
   JOIN (d4)
   JOIN (rg4
   WHERE rg4.parent_service_resource_cd=cv3.code_value
    AND rg4.resource_group_type_cd=subsect_cd
    AND rg4.active_ind=1)
   JOIN (sr4
   WHERE sr4.service_resource_cd=rg4.child_service_resource_cd
    AND sr4.service_resource_type_cd IN (bench_cd, instr_cd)
    AND sr4.active_ind=1)
   JOIN (cv4
   WHERE cv4.code_value=sr4.service_resource_cd
    AND cv4.active_ind=1)
  ORDER BY sr.service_resource_cd, sr1.service_resource_cd, sr2.service_resource_cd,
   sr3.service_resource_cd, sr4.service_resource_cd
  HEAD sr.service_resource_cd
   missing_loc_ind = missing_loc_ind
  HEAD sr1.service_resource_cd
   missing_loc_ind = missing_loc_ind
  HEAD sr2.service_resource_cd
   missing_loc_ind = missing_loc_ind
  HEAD sr3.service_resource_cd
   IF (sr3.service_resource_cd > 0
    AND ss.multiplexor_ind=1
    AND sr3.location_cd=0)
    missing_loc_ind = 1
   ENDIF
  HEAD sr4.service_resource_cd
   IF (sr4.service_resource_cd > 0
    AND sr4.location_cd=0)
    missing_loc_ind = 1
   ENDIF
  WITH nocounter, outerjoin = d1, outerjoin = d2,
   outerjoin = d3, outerjoin = d4
 ;end select
 IF (missing_loc_ind=1)
  SET reply->run_status_flag = 3
  GO TO exit_script
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
