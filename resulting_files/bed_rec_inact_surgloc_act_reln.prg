CREATE PROGRAM bed_rec_inact_surgloc_act_reln
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
 DECLARE inst_cd = f8
 DECLARE dept_cd = f8
 DECLARE surg_cd = f8
 DECLARE stage_cd = f8
 DECLARE op_cd = f8
 SET inst_cd = uar_get_code_by("MEANING",223,"INSTITUTION")
 SET dept_cd = uar_get_code_by("MEANING",223,"DEPARTMENT")
 SET surg_cd = uar_get_code_by("MEANING",223,"SURGAREA")
 SET stage_cd = uar_get_code_by("MEANING",223,"SURGSTAGE")
 SET op_cd = uar_get_code_by("MEANING",223,"SURGOP")
 SELECT INTO "nl:"
  FROM resource_group rg1,
   code_value cv1,
   resource_group rg2,
   code_value cv2,
   resource_group rg3,
   code_value cv3,
   resource_group rg4,
   code_value cv4,
   dummyt d,
   service_resource sr,
   code_value cv5
  PLAN (rg1
   WHERE rg1.resource_group_type_cd=inst_cd
    AND rg1.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=rg1.parent_service_resource_cd
    AND cv1.active_ind=1)
   JOIN (rg2
   WHERE rg2.parent_service_resource_cd=rg1.child_service_resource_cd
    AND rg2.resource_group_type_cd=dept_cd)
   JOIN (cv2
   WHERE cv2.code_value=rg2.parent_service_resource_cd)
   JOIN (rg3
   WHERE rg3.parent_service_resource_cd=rg2.child_service_resource_cd
    AND rg3.resource_group_type_cd=surg_cd)
   JOIN (cv3
   WHERE cv3.code_value=rg3.parent_service_resource_cd)
   JOIN (rg4
   WHERE rg4.parent_service_resource_cd=rg3.child_service_resource_cd
    AND rg4.resource_group_type_cd=stage_cd)
   JOIN (cv4
   WHERE cv4.code_value=rg4.parent_service_resource_cd)
   JOIN (d)
   JOIN (sr
   WHERE sr.service_resource_cd=rg4.child_service_resource_cd
    AND sr.service_resource_type_cd=op_cd)
   JOIN (cv5
   WHERE cv5.code_value=sr.service_resource_cd)
  DETAIL
   IF (((cv3.active_ind=0
    AND ((rg2.active_ind=1) OR (rg3.active_ind=1)) ) OR (((cv4.active_ind=0
    AND ((rg3.active_ind=1) OR (rg4.active_ind=1)) ) OR (cv5.active_ind=0
    AND rg4.active_ind=1)) )) )
    reply->run_status_flag = 3
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
