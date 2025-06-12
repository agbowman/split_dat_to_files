CREATE PROGRAM bed_rec_sp_pick_list:dba
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
 SET reply->run_status_flag = 1
 SET inst_code = 0.0
 SET inst_code = uar_get_code_by("MEANING",223,"INSTITUTION")
 SET dept_code = 0.0
 SET dept_code = uar_get_code_by("MEANING",223,"DEPARTMENT")
 SET surg_code = 0.0
 SET surg_code = uar_get_code_by("MEANING",223,"SURGAREA")
 SELECT INTO "nl:"
  FROM sn_doc_ref sdr,
   sn_name_value_prefs snvp,
   resource_group rg_dp,
   resource_group rg_sa,
   resource_group rg_ss,
   code_value inst,
   code_value dept,
   code_value sa,
   code_value ss
  PLAN (sdr)
   JOIN (snvp
   WHERE snvp.parent_entity_id=sdr.doc_ref_id
    AND snvp.parent_entity_name="SN_DOC_REF"
    AND cnvtupper(snvp.pref_name)="BY_PROC_PICK_LIST_IND")
   JOIN (ss
   WHERE ss.code_value=sdr.stage_cd
    AND ss.active_ind=1)
   JOIN (rg_ss
   WHERE rg_ss.child_service_resource_cd=ss.code_value
    AND rg_ss.resource_group_type_cd=surg_code
    AND rg_ss.parent_service_resource_cd=sdr.area_cd
    AND rg_ss.root_service_resource_cd=0
    AND rg_ss.active_ind=1)
   JOIN (sa
   WHERE sa.code_value=rg_ss.parent_service_resource_cd
    AND sa.active_ind=1)
   JOIN (rg_sa
   WHERE rg_sa.child_service_resource_cd=sa.code_value
    AND rg_sa.resource_group_type_cd=dept_code
    AND rg_sa.root_service_resource_cd=0
    AND rg_sa.active_ind=1)
   JOIN (dept
   WHERE dept.code_value=rg_sa.parent_service_resource_cd
    AND dept.active_ind=1)
   JOIN (rg_dp
   WHERE rg_dp.child_service_resource_cd=dept.code_value
    AND rg_dp.resource_group_type_cd=inst_code
    AND rg_dp.root_service_resource_cd=0
    AND rg_dp.active_ind=1)
   JOIN (inst
   WHERE inst.code_value=rg_dp.parent_service_resource_cd
    AND inst.active_ind=1)
  DETAIL
   IF (snvp.pref_value != "1")
    reply->run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->run_status_flag = 3
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
