CREATE PROGRAM bed_get_routed_assays:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 assays[*]
      2 display = vc
      2 code_value = f8
      2 rule_ind = i2
    1 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD temp(
   1 alist[*]
     2 assay_display = vc
     2 assay_code_value = f8
     2 rule_ind = i2
   1 rlist[*]
     2 serv_res_cv = f8
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 DECLARE inst_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",223,"INSTITUTION"))
 DECLARE dept_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",223,"DEPARTMENT"))
 DECLARE sect_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",223,"SECTION"))
 DECLARE subsect_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",223,"SUBSECTION"))
 DECLARE instr_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",223,"INSTRUMENT"))
 DECLARE bench_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",223,"BENCH"))
 DECLARE glb_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"GLB"))
 DECLARE bb_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"BB"))
 DECLARE hla_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"HLA"))
 DECLARE hlx_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"HLX"))
 DECLARE alpha_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",289,"2"))
 DECLARE calc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",289,"8"))
 DECLARE numeric_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",289,"3"))
 DECLARE icnt = i4 WITH protect, constant(size(request->institutions,5))
 DECLARE acnt = i4 WITH protect, noconstant(0)
 DECLARE rcnt = i4 WITH protect, noconstant(0)
 DECLARE idx1 = i4 WITH protect, noconstant(0)
 DECLARE index1 = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 SET error_flag = "F"
 SELECT DISTINCT INTO "nl:"
  rrf.task_assay_cd
  FROM reference_range_factor rrf,
   discrete_task_assay dta,
   ref_range_notify_trig rrnt
  PLAN (dta
   WHERE dta.activity_type_cd IN (glb_cd, bb_cd, hla_cd, hlx_cd)
    AND dta.default_result_type_cd IN (alpha_cd, calc_cd, numeric_cd)
    AND dta.active_ind=1)
   JOIN (rrf
   WHERE rrf.service_resource_cd=0
    AND rrf.task_assay_cd=dta.task_assay_cd
    AND rrf.active_ind=1)
   JOIN (rrnt
   WHERE rrnt.reference_range_factor_id=outerjoin(rrf.reference_range_factor_id))
  ORDER BY rrf.task_assay_cd
  HEAD REPORT
   acnt = 0
  HEAD rrf.task_assay_cd
   acnt = (acnt+ 1), stat = alterlist(temp->alist,acnt), temp->alist[acnt].assay_code_value = rrf
   .task_assay_cd,
   temp->alist[acnt].rule_ind = 0
  DETAIL
   IF (rrnt.ref_range_notify_trig_id > 0)
    temp->alist[acnt].rule_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (icnt > 0)
  SELECT INTO "nl:"
   FROM resource_group rg1,
    resource_group rg2,
    resource_group rg3,
    resource_group rg4,
    service_resource sr,
    reference_range_factor rrf,
    discrete_task_assay dta,
    assay_processing_r apr,
    ref_range_notify_trig rrnt
   PLAN (rg1
    WHERE expand(idx1,1,icnt,rg1.parent_service_resource_cd,request->institutions[idx1].code_value)
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
    JOIN (rrf
    WHERE rrf.service_resource_cd=sr.service_resource_cd
     AND rrf.active_ind=1)
    JOIN (dta
    WHERE dta.task_assay_cd=rrf.task_assay_cd
     AND dta.active_ind=1
     AND dta.activity_type_cd IN (glb_cd, bb_cd, hla_cd, hlx_cd))
    JOIN (apr
    WHERE apr.task_assay_cd=dta.task_assay_cd
     AND apr.default_result_type_cd IN (alpha_cd, calc_cd, numeric_cd)
     AND apr.active_ind=1)
    JOIN (rrnt
    WHERE rrnt.reference_range_factor_id=outerjoin(rrf.reference_range_factor_id))
   ORDER BY rrf.task_assay_cd
   HEAD rrf.task_assay_cd
    acnt = (acnt+ 1), stat = alterlist(temp->alist,acnt), temp->alist[acnt].assay_code_value = rrf
    .task_assay_cd,
    temp->alist[acnt].rule_ind = 0
   DETAIL
    IF (rrnt.ref_range_notify_trig_id > 0)
     temp->alist[acnt].rule_ind = 1
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  SET idx1 = 0
  SELECT INTO "nl:"
   FROM resource_group rg1,
    resource_group rg2,
    resource_group rg3,
    sub_section ss,
    reference_range_factor rrf,
    discrete_task_assay dta,
    assay_processing_r apr,
    ref_range_notify_trig rrnt
   PLAN (rg1
    WHERE expand(idx1,1,icnt,rg1.parent_service_resource_cd,request->institutions[idx1].code_value)
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
    JOIN (rrf
    WHERE rrf.service_resource_cd=ss.service_resource_cd
     AND rrf.active_ind=1)
    JOIN (dta
    WHERE dta.task_assay_cd=rrf.task_assay_cd
     AND dta.active_ind=1
     AND dta.activity_type_cd IN (glb_cd, bb_cd, hla_cd, hlx_cd))
    JOIN (apr
    WHERE apr.task_assay_cd=dta.task_assay_cd
     AND apr.default_result_type_cd IN (alpha_cd, calc_cd, numeric_cd)
     AND apr.active_ind=1)
    JOIN (rrnt
    WHERE rrnt.reference_range_factor_id=outerjoin(rrf.reference_range_factor_id))
   ORDER BY rrf.task_assay_cd
   HEAD rrf.task_assay_cd
    acnt = (acnt+ 1), stat = alterlist(temp->alist,acnt), temp->alist[acnt].assay_code_value = rrf
    .task_assay_cd,
    temp->alist[acnt].rule_ind = 0
   DETAIL
    IF (rrnt.ref_range_notify_trig_id > 0)
     temp->alist[acnt].rule_ind = 1
    ENDIF
   WITH nocounter, expand = 1
  ;end select
 ELSE
  SET error_flag = "T"
  SET error_msg = "No institutions in request"
  GO TO exit_script
 ENDIF
 IF (acnt > 0)
  SET stat = alterlist(reply->assays,acnt)
 ENDIF
 IF (acnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = acnt),
    reference_range_factor rrf,
    ref_range_notify_trig rrnt
   PLAN (d
    WHERE (temp->alist[d.seq].rule_ind != 1))
    JOIN (rrf
    WHERE (rrf.task_assay_cd=temp->alist[d.seq].assay_code_value)
     AND rrf.active_ind=1)
    JOIN (rrnt
    WHERE rrnt.reference_range_factor_id=rrf.reference_range_factor_id)
   DETAIL
    temp->alist[d.seq].rule_ind = 1
   WITH nocounter
  ;end select
  SET idx1 = 0
  SELECT INTO "nl:"
   FROM discrete_task_assay dta
   PLAN (dta
    WHERE expand(idx1,1,acnt,dta.task_assay_cd,temp->alist[idx1].assay_code_value))
   ORDER BY dta.mnemonic_key_cap, dta.task_assay_cd
   HEAD REPORT
    rcnt = 0
   HEAD dta.task_assay_cd
    rcnt = (rcnt+ 1), reply->assays[rcnt].code_value = dta.task_assay_cd, reply->assays[rcnt].display
     = dta.mnemonic
   DETAIL
    pos = locateval(index1,1,acnt,dta.task_assay_cd,temp->alist[index1].assay_code_value)
    IF (pos > 0)
     IF ((temp->alist[pos].rule_ind=1))
      reply->assays[rcnt].rule_ind = temp->alist[pos].rule_ind
     ENDIF
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  IF (rcnt > 0)
   SET stat = alterlist(reply->assays,rcnt)
  ENDIF
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
