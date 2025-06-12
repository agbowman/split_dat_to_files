CREATE PROGRAM afc_get_bce_event_by_id:dba
 SET afc_get_bce_event_by_id_vrsn = "001"
 RECORD reply(
   1 qual[*]
     2 charge_event_id = f8
     2 ext_m_event_id = f8
     2 ext_m_event_cont_cd = f8
     2 ext_m_reference_id = f8
     2 ext_m_reference_cont_cd = f8
     2 ext_i_event_id = f8
     2 ext_i_event_cont_cd = f8
     2 ext_i_reference_id = f8
     2 ext_i_reference_cont_cd = f8
     2 ext_p_event_id = f8
     2 ext_p_event_cont_cd = f8
     2 ext_p_reference_id = f8
     2 ext_p_reference_cont_cd = f8
     2 bill_item_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 accession = vc
     2 epsdt_ind = i2
     2 perf_loc_cd = f8
     2 abn_status_cd = f8
     2 ord_phys_id = f8
     2 ref_phys_id = f8
     2 ren_phys_id = f8
     2 charge_type_cd = f8
     2 diagnosis[*]
       3 field1_id = f8
       3 field2_id = f8
       3 field3_id = f8
     2 modifier[*]
       3 field1_id = f8
       3 field2_id = f8
       3 nomen_id = f8
     2 misc_ind = i2
     2 misc_price = f8
     2 misc_desc = vc
     2 quantity = f8
     2 reason_cd = f8
     2 cea_type_cd = f8
     2 service_dt_tm = dq8
     2 institution_cd = f8
     2 department_cd = f8
     2 section_cd = f8
     2 subsection_cd = f8
     2 level5_cd = f8
     2 service_resource_cd = f8
     2 user_defined_field = vc
     2 exclude_late_charge_processing = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data[1].status = "F"
 DECLARE ce_count = i4
 DECLARE diag_count = i4
 DECLARE mod_count = i4
 DECLARE nreqsize = i4
 DECLARE orderingcd = f8
 DECLARE refferedcd = f8
 DECLARE verifyingcd = f8
 DECLARE userdefcd = f8
 DECLARE billcodecd = f8
 DECLARE othercd = f8
 DECLARE modifiercd = f8
 DECLARE icd9cd = f8
 DECLARE subsectioncd = f8
 DECLARE surgstagecd = f8
 DECLARE sectioncd = f8
 DECLARE surgareacd = f8
 DECLARE departmentcd = f8
 DECLARE institutioncd = f8
 DECLARE diagnosis_ind = i2
 DECLARE modifier_ind = i2
 DECLARE exclude_late_charge_ind = i2
 DECLARE provider_ind = i2
 SET nreqsize = size(request->qual,5)
 SET diagnosis_ind = request->load[1].diagnosis_ind
 SET modifier_ind = request->load[1].modifier_ind
 SET exclude_late_charge_ind = request->load[1].exclude_late_charge_ind
 SET provider_ind = request->load[1].provider_ind
 SET stat = uar_get_meaning_by_codeset(13029,"ORDERED",1,orderingcd)
 SET stat = uar_get_meaning_by_codeset(13029,"REFFERED",1,refferedcd)
 SET stat = uar_get_meaning_by_codeset(13029,"VERIFYING",1,verifyingcd)
 SET stat = uar_get_meaning_by_codeset(13019,"USER DEF",1,userdefcd)
 SET stat = uar_get_meaning_by_codeset(13019,"BILL CODE",1,billcodecd)
 SET stat = uar_get_meaning_by_codeset(13019,"OTHER",1,othercd)
 SET stat = uar_get_meaning_by_codeset(14002,"MODIFIER",1,modifiercd)
 SET stat = uar_get_meaning_by_codeset(14002,"ICD9",1,icd9cd)
 SET stat = uar_get_meaning_by_codeset(223,"SUBSECTION",1,subsectioncd)
 SET stat = uar_get_meaning_by_codeset(223,"SURGSTAGE",1,surgstagecd)
 SET stat = uar_get_meaning_by_codeset(223,"SECTION",1,sectioncd)
 SET stat = uar_get_meaning_by_codeset(223,"SURGAREA",1,surgareacd)
 SET stat = uar_get_meaning_by_codeset(223,"DEPARTMENT",1,departmentcd)
 SET stat = uar_get_meaning_by_codeset(223,"INSTITUTION",1,institutioncd)
 IF (nreqsize > 0)
  IF (((diagnosis_ind > 0) OR (((modifier_ind > 0) OR (exclude_late_charge_ind > 0)) ))
   AND provider_ind > 0)
   SELECT INTO "NL:"
    FROM charge_event ce,
     charge_event_act cea,
     charge_event_mod cem,
     charge_event_act_prsnl ceap,
     (dummyt d  WITH seq = value(nreqsize))
    PLAN (d)
     JOIN (ce
     WHERE (request->qual[d.seq].charge_event_id=ce.charge_event_id)
      AND ce.active_ind=1)
     JOIN (cea
     WHERE ce.charge_event_id=cea.charge_event_id
      AND cea.active_ind=1)
     JOIN (ceap
     WHERE outerjoin(cea.charge_event_act_id)=ceap.charge_event_act_id
      AND ceap.active_ind=outerjoin(1))
     JOIN (cem
     WHERE outerjoin(ce.charge_event_id)=cem.charge_event_id
      AND cem.active_ind=outerjoin(1))
    HEAD ce.charge_event_id
     ce_count = (ce_count+ 1), stat = alterlist(reply->qual,ce_count), reply->qual[ce_count].
     charge_event_id = ce.charge_event_id,
     reply->qual[ce_count].ext_m_event_id = ce.ext_m_event_id, reply->qual[ce_count].
     ext_m_event_cont_cd = ce.ext_m_event_cont_cd, reply->qual[ce_count].ext_m_reference_id = ce
     .ext_m_reference_id,
     reply->qual[ce_count].ext_m_reference_cont_cd = ce.ext_m_reference_cont_cd, reply->qual[ce_count
     ].ext_i_event_id = ce.ext_i_event_id, reply->qual[ce_count].ext_i_event_cont_cd = ce
     .ext_i_event_cont_cd,
     reply->qual[ce_count].ext_i_reference_id = ce.ext_i_reference_id, reply->qual[ce_count].
     ext_i_reference_cont_cd = ce.ext_i_reference_cont_cd, reply->qual[ce_count].ext_p_event_id = ce
     .ext_p_event_id,
     reply->qual[ce_count].ext_p_event_cont_cd = ce.ext_p_event_cont_cd, reply->qual[ce_count].
     ext_p_reference_id = ce.ext_p_reference_id, reply->qual[ce_count].ext_p_reference_cont_cd = ce
     .ext_p_reference_cont_cd,
     reply->qual[ce_count].bill_item_id = ce.bill_item_id, reply->qual[ce_count].person_id = ce
     .person_id, reply->qual[ce_count].encntr_id = ce.encntr_id,
     reply->qual[ce_count].accession = ce.accession, reply->qual[ce_count].epsdt_ind = ce.epsdt_ind,
     reply->qual[ce_count].perf_loc_cd = ce.perf_loc_cd,
     reply->qual[ce_count].abn_status_cd = ce.abn_status_cd, reply->qual[ce_count].misc_ind = cea
     .misc_ind, reply->qual[ce_count].misc_price = cea.cea_misc4_id,
     reply->qual[ce_count].misc_desc = cea.cea_misc3, reply->qual[ce_count].charge_type_cd = cea
     .charge_type_cd, reply->qual[ce_count].quantity = cea.quantity,
     reply->qual[ce_count].service_dt_tm = cea.service_dt_tm, reply->qual[ce_count].cea_type_cd = cea
     .cea_type_cd, reply->qual[ce_count].reason_cd = cea.reason_cd,
     reply->qual[ce_count].service_resource_cd = cea.service_resource_cd
    HEAD ceap.prsnl_id
     CASE (ceap.prsnl_type_cd)
      OF orderingcd:
       reply->qual[ce_count].ord_phys_id = ceap.prsnl_id
      OF refferedcd:
       reply->qual[ce_count].ref_phys_id = ceap.prsnl_id
      OF verifyingcd:
       reply->qual[ce_count].ren_phys_id = ceap.prsnl_id
     ENDCASE
     mod_count = 0, diag_count = 0
    HEAD cem.charge_event_mod_id
     CASE (cem.charge_event_mod_type_cd)
      OF userdefcd:
       reply->qual[ce_count].user_defined_field = cem.field7
      OF billcodecd:
       CASE (cem.field1_id)
        OF modifiercd:
         mod_count = (mod_count+ 1),stat = alterlist(reply->qual[ce_count].modifier,mod_count),reply
         ->qual[ce_count].modifier[mod_count].field1_id = cem.field1_id,
         reply->qual[ce_count].modifier[mod_count].field2_id = cem.field2_id,reply->qual[ce_count].
         modifier[mod_count].nomen_id = cem.nomen_id
        OF icd9cd:
         diag_count = (diag_count+ 1),stat = alterlist(reply->qual[ce_count].diagnosis,diag_count),
         reply->qual[ce_count].diagnosis[diag_count].field1_id = cem.field1_id,
         reply->qual[ce_count].diagnosis[diag_count].field2_id = cem.field2_id,reply->qual[ce_count].
         diagnosis[diag_count].field3_id = cem.field3_id
       ENDCASE
      OF othercd:
       IF (cem.field1_id > 0)
        reply->qual[ce_count].exclude_late_charge_processing = 1
       ENDIF
     ENDCASE
    WITH nocounter
   ;end select
  ELSEIF (((diagnosis_ind > 0) OR (((modifier_ind > 0) OR (exclude_late_charge_ind > 0)) )) )
   SELECT INTO "NL:"
    FROM charge_event ce,
     charge_event_act cea,
     charge_event_mod cem,
     (dummyt d  WITH seq = value(nreqsize))
    PLAN (d)
     JOIN (ce
     WHERE (request->qual[d.seq].charge_event_id=ce.charge_event_id)
      AND ce.active_ind=1)
     JOIN (cea
     WHERE ce.charge_event_id=cea.charge_event_id
      AND cea.active_ind=1)
     JOIN (cem
     WHERE outerjoin(ce.charge_event_id)=cem.charge_event_id
      AND cem.active_ind=outerjoin(1))
    HEAD ce.charge_event_id
     mod_count = 0, diag_count = 0, ce_count = (ce_count+ 1),
     stat = alterlist(reply->qual,ce_count), reply->qual[ce_count].charge_event_id = ce
     .charge_event_id, reply->qual[ce_count].ext_m_event_id = ce.ext_m_event_id,
     reply->qual[ce_count].ext_m_event_cont_cd = ce.ext_m_event_cont_cd, reply->qual[ce_count].
     ext_m_reference_id = ce.ext_m_reference_id, reply->qual[ce_count].ext_m_reference_cont_cd = ce
     .ext_m_reference_cont_cd,
     reply->qual[ce_count].ext_i_event_id = ce.ext_i_event_id, reply->qual[ce_count].
     ext_i_event_cont_cd = ce.ext_i_event_cont_cd, reply->qual[ce_count].ext_i_reference_id = ce
     .ext_i_reference_id,
     reply->qual[ce_count].ext_i_reference_cont_cd = ce.ext_i_reference_cont_cd, reply->qual[ce_count
     ].ext_p_event_id = ce.ext_p_event_id, reply->qual[ce_count].ext_p_event_cont_cd = ce
     .ext_p_event_cont_cd,
     reply->qual[ce_count].ext_p_reference_id = ce.ext_p_reference_id, reply->qual[ce_count].
     ext_p_reference_cont_cd = ce.ext_p_reference_cont_cd, reply->qual[ce_count].bill_item_id = ce
     .bill_item_id,
     reply->qual[ce_count].person_id = ce.person_id, reply->qual[ce_count].encntr_id = ce.encntr_id,
     reply->qual[ce_count].accession = ce.accession,
     reply->qual[ce_count].epsdt_ind = ce.epsdt_ind, reply->qual[ce_count].perf_loc_cd = ce
     .perf_loc_cd, reply->qual[ce_count].abn_status_cd = ce.abn_status_cd,
     reply->qual[ce_count].misc_ind = cea.misc_ind, reply->qual[ce_count].misc_price = cea
     .cea_misc4_id, reply->qual[ce_count].misc_desc = cea.cea_misc3,
     reply->qual[ce_count].charge_type_cd = cea.charge_type_cd, reply->qual[ce_count].quantity = cea
     .quantity, reply->qual[ce_count].service_dt_tm = cea.service_dt_tm,
     reply->qual[ce_count].cea_type_cd = cea.cea_type_cd, reply->qual[ce_count].reason_cd = cea
     .reason_cd, reply->qual[ce_count].service_resource_cd = cea.service_resource_cd
    HEAD cem.charge_event_mod_id
     CASE (cem.charge_event_mod_type_cd)
      OF userdefcd:
       reply->qual[ce_count].user_defined_field = cem.field7
      OF billcodecd:
       CASE (cem.field1_id)
        OF modifiercd:
         mod_count = (mod_count+ 1),stat = alterlist(reply->qual[ce_count].modifier,mod_count),reply
         ->qual[ce_count].modifier[mod_count].field1_id = cem.field1_id,
         reply->qual[ce_count].modifier[mod_count].field2_id = cem.field2_id,reply->qual[ce_count].
         modifier[mod_count].nomen_id = cem.nomen_id
        OF icd9cd:
         diag_count = (diag_count+ 1),stat = alterlist(reply->qual[ce_count].diagnosis,diag_count),
         reply->qual[ce_count].diagnosis[diag_count].field1_id = cem.field1_id,
         reply->qual[ce_count].diagnosis[diag_count].field2_id = cem.field2_id,reply->qual[ce_count].
         diagnosis[diag_count].field3_id = cem.field3_id
       ENDCASE
      OF othercd:
       IF (cem.field1_id > 0)
        reply->qual[ce_count].exclude_late_charge_processing = 1
       ENDIF
     ENDCASE
    WITH nocounter
   ;end select
  ELSEIF (provider_ind > 0)
   SELECT INTO "NL:"
    FROM charge_event ce,
     charge_event_act cea,
     charge_event_act_prsnl ceap,
     (dummyt d  WITH seq = value(nreqsize))
    PLAN (d)
     JOIN (ce
     WHERE (request->qual[d.seq].charge_event_id=ce.charge_event_id)
      AND ce.active_ind=1)
     JOIN (cea
     WHERE ce.charge_event_id=cea.charge_event_id
      AND cea.active_ind=1)
     JOIN (ceap
     WHERE outerjoin(cea.charge_event_act_id)=ceap.charge_event_act_id
      AND ceap.active_ind=outerjoin(1))
    HEAD ce.charge_event_id
     ce_count = (ce_count+ 1), stat = alterlist(reply->qual,ce_count), reply->qual[ce_count].
     charge_event_id = ce.charge_event_id,
     reply->qual[ce_count].ext_m_event_id = ce.ext_m_event_id, reply->qual[ce_count].
     ext_m_event_cont_cd = ce.ext_m_event_cont_cd, reply->qual[ce_count].ext_m_reference_id = ce
     .ext_m_reference_id,
     reply->qual[ce_count].ext_m_reference_cont_cd = ce.ext_m_reference_cont_cd, reply->qual[ce_count
     ].ext_i_event_id = ce.ext_i_event_id, reply->qual[ce_count].ext_i_event_cont_cd = ce
     .ext_i_event_cont_cd,
     reply->qual[ce_count].ext_i_reference_id = ce.ext_i_reference_id, reply->qual[ce_count].
     ext_i_reference_cont_cd = ce.ext_i_reference_cont_cd, reply->qual[ce_count].ext_p_event_id = ce
     .ext_p_event_id,
     reply->qual[ce_count].ext_p_event_cont_cd = ce.ext_p_event_cont_cd, reply->qual[ce_count].
     ext_p_reference_id = ce.ext_p_reference_id, reply->qual[ce_count].ext_p_reference_cont_cd = ce
     .ext_p_reference_cont_cd,
     reply->qual[ce_count].bill_item_id = ce.bill_item_id, reply->qual[ce_count].person_id = ce
     .person_id, reply->qual[ce_count].encntr_id = ce.encntr_id,
     reply->qual[ce_count].accession = ce.accession, reply->qual[ce_count].epsdt_ind = ce.epsdt_ind,
     reply->qual[ce_count].perf_loc_cd = ce.perf_loc_cd,
     reply->qual[ce_count].abn_status_cd = ce.abn_status_cd, reply->qual[ce_count].misc_ind = cea
     .misc_ind, reply->qual[ce_count].misc_price = cea.cea_misc4_id,
     reply->qual[ce_count].misc_desc = cea.cea_misc3, reply->qual[ce_count].charge_type_cd = cea
     .charge_type_cd, reply->qual[ce_count].quantity = cea.quantity,
     reply->qual[ce_count].service_dt_tm = cea.service_dt_tm, reply->qual[ce_count].cea_type_cd = cea
     .cea_type_cd, reply->qual[ce_count].reason_cd = cea.reason_cd,
     reply->qual[ce_count].service_resource_cd = cea.service_resource_cd
    HEAD ceap.prsnl_id
     CASE (ceap.prsnl_type_cd)
      OF orderingcd:
       reply->qual[ce_count].ord_phys_id = ceap.prsnl_id
      OF refferedcd:
       reply->qual[ce_count].ref_phys_id = ceap.prsnl_id
      OF verifyingcd:
       reply->qual[ce_count].ren_phys_id = ceap.prsnl_id
     ENDCASE
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "NL:"
    FROM charge_event ce,
     charge_event_act cea,
     (dummyt d  WITH seq = value(nreqsize))
    PLAN (d)
     JOIN (ce
     WHERE (request->qual[d.seq].charge_event_id=ce.charge_event_id)
      AND ce.active_ind=1)
     JOIN (cea
     WHERE ce.charge_event_id=cea.charge_event_id
      AND cea.active_ind=1)
    HEAD ce.charge_event_id
     ce_count = (ce_count+ 1), stat = alterlist(reply->qual,ce_count), reply->qual[ce_count].
     charge_event_id = ce.charge_event_id,
     reply->qual[ce_count].ext_m_event_id = ce.ext_m_event_id, reply->qual[ce_count].
     ext_m_event_cont_cd = ce.ext_m_event_cont_cd, reply->qual[ce_count].ext_m_reference_id = ce
     .ext_m_reference_id,
     reply->qual[ce_count].ext_m_reference_cont_cd = ce.ext_m_reference_cont_cd, reply->qual[ce_count
     ].ext_i_event_id = ce.ext_i_event_id, reply->qual[ce_count].ext_i_event_cont_cd = ce
     .ext_i_event_cont_cd,
     reply->qual[ce_count].ext_i_reference_id = ce.ext_i_reference_id, reply->qual[ce_count].
     ext_i_reference_cont_cd = ce.ext_i_reference_cont_cd, reply->qual[ce_count].ext_p_event_id = ce
     .ext_p_event_id,
     reply->qual[ce_count].ext_p_event_cont_cd = ce.ext_p_event_cont_cd, reply->qual[ce_count].
     ext_p_reference_id = ce.ext_p_reference_id, reply->qual[ce_count].ext_p_reference_cont_cd = ce
     .ext_p_reference_cont_cd,
     reply->qual[ce_count].bill_item_id = ce.bill_item_id, reply->qual[ce_count].person_id = ce
     .person_id, reply->qual[ce_count].encntr_id = ce.encntr_id,
     reply->qual[ce_count].accession = ce.accession, reply->qual[ce_count].epsdt_ind = ce.epsdt_ind,
     reply->qual[ce_count].perf_loc_cd = ce.perf_loc_cd,
     reply->qual[ce_count].abn_status_cd = ce.abn_status_cd, reply->qual[ce_count].misc_ind = cea
     .misc_ind, reply->qual[ce_count].misc_price = cea.cea_misc4_id,
     reply->qual[ce_count].misc_desc = cea.cea_misc3, reply->qual[ce_count].charge_type_cd = cea
     .charge_type_cd, reply->qual[ce_count].quantity = cea.quantity,
     reply->qual[ce_count].service_dt_tm = cea.service_dt_tm, reply->qual[ce_count].cea_type_cd = cea
     .cea_type_cd, reply->qual[ce_count].reason_cd = cea.reason_cd,
     reply->qual[ce_count].service_resource_cd = cea.service_resource_cd
    WITH nocounter
   ;end select
  ENDIF
  CALL getserviceresource(1)
  IF (ce_count > 0)
   SET reply->status_data[1].status = "S"
   SET reply->status_data[1].subeventstatus[1].operationstatus = "S"
  ELSE
   SET reply->status_data[1].status = "Z"
  ENDIF
  SET stat = alterlist(reply->qual,ce_count)
 ENDIF
 GO TO end_program
 SUBROUTINE getserviceresource(temp)
   DECLARE reply_cnt = i4
   DECLARE resource_cnt = i4
   DECLARE cur_cd = f8
   DECLARE loop_cnt = i4
   SET reply_cnt = size(reply->qual,5)
   FOR (loop_cnt = 1 TO reply_cnt)
     SET resource_cnt = 4
     SET cur_cd = reply->qual[loop_cnt].service_resource_cd
     WHILE (resource_cnt > 0)
      SELECT INTO "NL:"
       FROM resource_group r
       WHERE r.child_service_resource_cd=cur_cd
        AND r.active_ind=1
        AND r.root_service_resource_cd=0
       DETAIL
        cur_cd = r.parent_service_resource_cd
        IF (resource_cnt=4
         AND ((r.resource_group_type_cd=subsectioncd) OR (r.resource_group_type_cd=surgstagecd)) )
         reply->qual[loop_cnt].subsection_cd = r.child_service_resource_cd, reply->qual[loop_cnt].
         section_cd = r.parent_service_resource_cd
        ELSEIF (resource_cnt=3
         AND ((r.resource_group_type_cd=sectioncd) OR (r.resource_group_type_cd=surgareacd)) )
         reply->qual[loop_cnt].section_cd = r.child_service_resource_cd, reply->qual[loop_cnt].
         department_cd = r.parent_service_resource_cd
        ELSEIF (resource_cnt=2
         AND r.resource_group_type_cd=departmentcd)
         reply->qual[loop_cnt].department_cd = r.child_service_resource_cd, reply->qual[loop_cnt].
         institution_cd = r.parent_service_resource_cd
        ELSEIF (resource_cnt=1
         AND r.resource_group_type_cd=institutioncd)
         reply->qual[loop_cnt].institution_cd = r.child_service_resource_cd
        ENDIF
       WITH nocounter
      ;end select
      SET resource_cnt = (resource_cnt - 1)
     ENDWHILE
   ENDFOR
 END ;Subroutine
#end_program
END GO
