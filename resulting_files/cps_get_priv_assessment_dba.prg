CREATE PROGRAM cps_get_priv_assessment:dba
 RECORD reply(
   1 restrict_ind = i2
   1 qual[*]
     2 encntr_id = f8
     2 arrive_dt_tm = dq8
     2 reg_dt_tm = dq8
     2 disch_dt_tm = dq8
     2 location_cd = f8
     2 location_disp = vc
     2 loc_facility_cd = f8
     2 loc_facility_disp = vc
     2 loc_building_cd = f8
     2 loc_building_disp = vc
     2 loc_nurse_unit_cd = f8
     2 loc_nurse_unit_disp = vc
     2 loc_room_cd = f8
     2 loc_room_disp = vc
     2 loc_bed_cd = f8
     2 loc_bed_disp = vc
     2 fin_nbr = vc
     2 dsm_assessment_id = f8
     2 person_id = f8
     2 diag_prsnl_id = f8
     2 diag_dt_tm = dq8
     2 assessment_type_cd = f8
     2 assessment_dt_tm = dq8
     2 status_ind = i2
     2 active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 cgi1_cd = f8
     2 cgi2_cd = f8
     2 name_full_formatted = vc
     2 qual[*]
       3 dsm_component_id = f8
       3 axis_flag = i2
       3 nomenclature_id = f8
       3 component_desc1 = vc
       3 component_desc2 = vc
       3 component_seq = i2
       3 primary_diag_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD internal(
   1 organizations[*]
     2 organization_id = f8
     2 confid_cd = f8
     2 confid_level = i4
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET count2 = 0
 SET org_cnt = 0
 SET encntr_org_sec_ind = 0
 SET confid_ind = 0
 SET fin_nbr_type_cd = 0.0
 SET code_value = 0.0
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET fin_nbr_type_cd = code_value
 SELECT INTO "nl:"
  FROM dm_info di
  PLAN (di
   WHERE di.info_domain="SECURITY"
    AND di.info_name IN ("SEC_ORG_RELTN", "SEC_CONFID"))
  DETAIL
   CASE (di.info_name)
    OF "SEC_ORG_RELTN":
     IF (di.info_number=1)
      encntr_org_sec_ind = 1
     ENDIF
    OF "SEC_CONFID":
     IF (di.info_number=1)
      confid_ind = 1
     ENDIF
   ENDCASE
  WITH nocounter
 ;end select
 IF (((encntr_org_sec_ind=1) OR (confid_ind=1)) )
  SET reply->restrict_ind = 1
  EXECUTE sac_get_user_organizations  WITH replace("REPLY","INTERNAL")
  SET org_cnt = size(internal->organizations,5)
 ENDIF
 IF (confid_ind=0
  AND encntr_org_sec_ind=0)
  SELECT INTO "nl:"
   e.person_id, da.encntr_id, p.name_full_formatted,
   ea.encntr_alias, arrive_null = nullind(e.arrive_dt_tm), reg_null = nullind(e.reg_dt_tm),
   disch_null = nullind(e.disch_dt_tm), da_null = nullind(da.dsm_assessment_id), p_null = nullind(p
    .person_id)
   FROM encounter e,
    dsm_assessment da,
    prsnl p,
    encntr_alias ea
   PLAN (e
    WHERE (e.person_id=request->person_id)
     AND e.active_ind=1)
    JOIN (ea
    WHERE ea.encntr_id=e.encntr_id
     AND ea.encntr_alias_type_cd=fin_nbr_type_cd
     AND ea.active_ind=1
     AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (da
    WHERE da.encntr_id=outerjoin(e.encntr_id))
    JOIN (p
    WHERE p.person_id=outerjoin(da.diag_prsnl_id))
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1)
    IF (mod(count1,10)=1)
     stat = alterlist(reply->qual,(count1+ 9))
    ENDIF
    reply->qual[count1].encntr_id = e.encntr_id
    IF (arrive_null=0)
     reply->qual[count1].arrive_dt_tm = cnvtdatetime(e.arrive_dt_tm)
    ENDIF
    IF (reg_null=0)
     reply->qual[count1].reg_dt_tm = cnvtdatetime(e.reg_dt_tm)
    ENDIF
    IF (disch_null=0)
     reply->qual[count1].disch_dt_tm = cnvtdatetime(e.disch_dt_tm)
    ENDIF
    reply->qual[count1].location_cd = e.location_cd, reply->qual[count1].loc_facility_cd = e
    .loc_facility_cd, reply->qual[count1].loc_building_cd = e.loc_building_cd,
    reply->qual[count1].loc_nurse_unit_cd = e.loc_nurse_unit_cd, reply->qual[count1].loc_room_cd = e
    .loc_room_cd, reply->qual[count1].loc_bed_cd = e.loc_bed_cd
    IF (da_null=0)
     reply->qual[count1].dsm_assessment_id = da.dsm_assessment_id, reply->qual[count1].person_id = da
     .person_id, reply->qual[count1].diag_prsnl_id = da.diag_prsnl_id,
     reply->qual[count1].diag_dt_tm = da.diag_dt_tm, reply->qual[count1].assessment_type_cd = da
     .assessment_type_cd, reply->qual[count1].assessment_dt_tm = da.assessment_dt_tm
     IF (da.active_ind=1
      AND da.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND da.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
      reply->qual[count1].status_ind = 1
     ELSE
      reply->qual[count1].status_ind = 0
     ENDIF
     reply->qual[count1].active_ind = da.active_ind, reply->qual[count1].beg_effective_dt_tm = da
     .beg_effective_dt_tm, reply->qual[count1].end_effective_dt_tm = da.end_effective_dt_tm,
     reply->qual[count1].cgi1_cd = da.cgi1_cd, reply->qual[count1].cgi2_cd = da.cgi2_cd
    ENDIF
    IF (p_null=0)
     reply->qual[count1].name_full_formatted = p.name_full_formatted
    ENDIF
    IF (e.encntr_id > 0)
     reply->qual[count1].fin_nbr = cnvtalias(ea.alias,ea.alias_pool_cd)
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->qual,count1)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   e.person_id, da.encntr_id, p.name_full_formatted,
   ea.encntr_alias, arrive_null = nullind(e.arrive_dt_tm), reg_null = nullind(e.reg_dt_tm),
   disch_null = nullind(e.disch_dt_tm), da_null = nullind(da.dsm_assessment_id), p_null = nullind(p
    .person_id)
   FROM encounter e,
    (dummyt d1  WITH seq = value(org_cnt)),
    encntr_alias ea,
    prsnl p,
    dsm_assessment da
   PLAN (d1)
    JOIN (e
    WHERE (e.person_id=request->person_id)
     AND (e.organization_id=internal->organizations[d1.seq].organization_id)
     AND e.active_ind=1)
    JOIN (ea
    WHERE ea.encntr_id=e.encntr_id
     AND ea.encntr_alias_type_cd=fin_nbr_type_cd
     AND ea.active_ind=1
     AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (da
    WHERE da.encntr_id=outerjoin(e.encntr_id))
    JOIN (p
    WHERE p.person_id=outerjoin(da.diag_prsnl_id))
   HEAD REPORT
    count1 = 0
   DETAIL
    IF (((confid_ind=1
     AND (uar_get_collation_seq(e.confid_level_cd) <= internal->organizations[d1.seq].confid_level))
     OR (confid_ind=0)) )
     count1 = (count1+ 1)
     IF (mod(count1,10)=1)
      stat = alterlist(reply->qual,(count1+ 9))
     ENDIF
     reply->qual[count1].encntr_id = e.encntr_id
     IF (arrive_null=0)
      reply->qual[count1].arrive_dt_tm = cnvtdatetime(e.arrive_dt_tm)
     ENDIF
     IF (reg_null=0)
      reply->qual[count1].reg_dt_tm = cnvtdatetime(e.reg_dt_tm)
     ENDIF
     IF (disch_null=0)
      reply->qual[count1].disch_dt_tm = cnvtdatetime(e.disch_dt_tm)
     ENDIF
     reply->qual[count1].location_cd = e.location_cd, reply->qual[count1].loc_facility_cd = e
     .loc_facility_cd, reply->qual[count1].loc_building_cd = e.loc_building_cd,
     reply->qual[count1].loc_nurse_unit_cd = e.loc_nurse_unit_cd, reply->qual[count1].loc_room_cd = e
     .loc_room_cd, reply->qual[count1].loc_bed_cd = e.loc_bed_cd
     IF (da_null=0
      AND da.dsm_assessment_id > 0.0)
      reply->qual[count1].dsm_assessment_id = da.dsm_assessment_id, reply->qual[count1].
      assessment_type_cd = da.assessment_type_cd, reply->qual[count1].assessment_dt_tm = da
      .assessment_dt_tm,
      reply->qual[count1].person_id = da.person_id, reply->qual[count1].diag_prsnl_id = da
      .diag_prsnl_id, reply->qual[count1].diag_dt_tm = da.diag_dt_tm,
      reply->qual[count1].assessment_type_cd = da.assessment_type_cd, reply->qual[count1].
      assessment_dt_tm = da.assessment_dt_tm
      IF (da.active_ind=1
       AND da.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND da.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
       reply->qual[count1].status_ind = 1
      ELSE
       reply->qual[count1].status_ind = 0
      ENDIF
      reply->qual[count1].cgi1_cd = da.cgi1_cd, reply->qual[count1].cgi2_cd = da.cgi2_cd
      IF (p_null=0)
       reply->qual[count1].name_full_formatted = p.name_full_formatted
      ENDIF
      IF (e.encntr_id > 0)
       reply->qual[count1].fin_nbr = cnvtalias(ea.alias,ea.alias_pool_cd)
      ENDIF
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->qual,count1)
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  dc.dsm_component_id
  FROM dsm_component dc,
   (dummyt d  WITH seq = value(count1))
  PLAN (d)
   JOIN (dc
   WHERE (dc.dsm_assessment_id=reply->qual[d.seq].dsm_assessment_id)
    AND dc.dsm_assessment_id > 0)
  ORDER BY dc.dsm_assessment_id
  HEAD dc.dsm_assessment_id
   count2 = 0
  DETAIL
   count2 = (count2+ 1)
   IF (mod(count2,10)=1)
    stat = alterlist(reply->qual[d.seq].qual,(count2+ 9))
   ENDIF
   reply->qual[d.seq].qual[count2].dsm_component_id = dc.dsm_component_id, reply->qual[d.seq].qual[
   count2].axis_flag = dc.axis_flag, reply->qual[d.seq].qual[count2].nomenclature_id = dc
   .nomenclature_id,
   reply->qual[d.seq].qual[count2].component_desc1 = dc.component_desc1, reply->qual[d.seq].qual[
   count2].component_desc2 = dc.component_desc2, reply->qual[d.seq].qual[count2].component_seq = dc
   .component_seq,
   reply->qual[d.seq].qual[count2].primary_diag_ind = dc.primary_diag_ind
  FOOT  dc.dsm_assessment_id
   stat = alterlist(reply->qual[d.seq].qual,count2)
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
