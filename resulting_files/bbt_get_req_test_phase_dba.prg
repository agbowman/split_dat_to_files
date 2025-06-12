CREATE PROGRAM bbt_get_req_test_phase:dba
 RECORD reply(
   1 display = c40
   1 description = c40
   1 active_ind = i2
   1 cdf_meaning = c12
   1 updt_cnt = i4
   1 qual[*]
     2 phase_group_id = f8
     2 task_assay_cd = f8
     2 mnemonic = c40
     2 activity_type_cd = f8
     2 activity_type_disp = vc
     2 activity_type_mean = c12
     2 sequence = i4
     2 required_ind = i2
     2 updt_cnt = i4
     2 bb_result_processing_cd = f8
     2 bb_result_processing_disp = vc
     2 bb_result_processing_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE err_cnt = i4 WITH protect, noconstant(0)
 DECLARE phase_cnt = i4 WITH protect, noconstant(0)
 DECLARE phases_cs = i4 WITH protect, constant(1601)
 DECLARE computerxm_phase_mean = c12 WITH protect, constant("COMPUTERXM")
 DECLARE computerxm_phase_cd = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 IF ((request->get_xm_grp_ind=1))
  SET computerxm_phase_cd = uar_get_code_by("MEANING",phases_cs,nullterm(computerxm_phase_mean))
  IF (computerxm_phase_cd <= 0.0)
   SET uar_error = concat("Failed to retrieve phase code with meaning of ",trim(computerxm_phase_mean
     ),".")
   CALL errorhandler("F","uar_get_code_by",uar_error)
  ENDIF
 ENDIF
 SELECT
  IF (computerxm_phase_cd > 0.0)
   PLAN (c
    WHERE computerxm_phase_cd=c.code_value)
    JOIN (p
    WHERE c.code_value=p.phase_group_cd
     AND p.active_ind=1)
    JOIN (d
    WHERE p.task_assay_cd=d.task_assay_cd)
  ELSE
   PLAN (c
    WHERE (request->phase_group_cd=c.code_value)
     AND c.code_set=1601)
    JOIN (p
    WHERE c.code_value=p.phase_group_cd
     AND p.active_ind=1)
    JOIN (d
    WHERE p.task_assay_cd=d.task_assay_cd)
  ENDIF
  INTO "nl:"
  c.display, c.description, c.active_ind,
  c.updt_cnt, c.cdf_meaning, p.task_assay_cd,
  p.phase_group_id, p.phase_group_cd, p.sequence,
  p.required_ind, p.updt_cnt, d.mnemonic,
  d.activity_type_cd, d.bb_result_processing_cd
  FROM code_value c,
   phase_group p,
   discrete_task_assay d
  HEAD REPORT
   err_cnt = 0, phase_cnt = 0, reply->display = c.display,
   reply->description = c.description, reply->active_ind = c.active_ind, reply->updt_cnt = c.updt_cnt,
   reply->cdf_meaning = c.cdf_meaning
  DETAIL
   phase_cnt = (phase_cnt+ 1)
   IF (phase_cnt > size(reply->qual,5))
    stat = alterlist(reply->qual,(phase_cnt+ 9))
   ENDIF
   reply->qual[phase_cnt].phase_group_id = p.phase_group_id, reply->qual[phase_cnt].task_assay_cd = p
   .task_assay_cd, reply->qual[phase_cnt].sequence = p.sequence,
   reply->qual[phase_cnt].required_ind = p.required_ind, reply->qual[phase_cnt].updt_cnt = p.updt_cnt,
   reply->qual[phase_cnt].mnemonic = d.mnemonic,
   reply->qual[phase_cnt].activity_type_cd = d.activity_type_cd, reply->qual[phase_cnt].
   bb_result_processing_cd = d.bb_result_processing_cd
  WITH format, nocounter
 ;end select
 SET stat = alterlist(reply->qual,phase_cnt)
 IF (curqual=0)
  SET err_cnt = (err_cnt+ 1)
  SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "F"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "SEQUENCE"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
  "unable to return phase specified"
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 GO TO exit_script
 DECLARE errorhandler(operationstatus=c1,targetobjectname=c25,targetobjectvalue=vc) = null
 SUBROUTINE errorhandler(operationstatus,targetobjectname,targetobjectvalue)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt = (error_cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = script_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
#exit_script
END GO
