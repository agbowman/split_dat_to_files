CREATE PROGRAM cp_get_xencntr_info:dba
 RECORD reply(
   1 encntr_list[*]
     2 encntr_id = f8
     2 reg_dt_tm = dq8
     2 loc_facility_cd = f8
     2 loc_facility_disp = c40
     2 loc_facility_desc = c60
     2 loc_facility_mean = c12
     2 loc_building_cd = f8
     2 loc_building_disp = c40
     2 loc_building_desc = vc
     2 loc_building_mean = c12
     2 loc_nurse_unit_cd = f8
     2 loc_nurse_unit_disp = c40
     2 loc_nurse_unit_desc = vc
     2 loc_nurse_unit_mean = c12
     2 disch_dt_tm = dq8
     2 organization_id = f8
     2 diag_ftdesc = vc
     2 client_name = vc
     2 encntr_type_cd = f8
     2 encntr_type_disp = c40
     2 encntr_type_desc = vc
     2 encntr_type_mean = c12
     2 mrn = vc
     2 fin_nbr = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET code_set = 0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET diag_type_cd = 0.0
 SET mrn_cd = 0.0
 SET fin_nbr_cd = 0.0
 SET cdf_meaning = "ADMIT"
 SET code_set = 17
 SET code_value = 0
 EXECUTE cpm_get_cd_for_cdf
 SET diag_type_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET fin_nbr_cd = code_value
 SET cr_count = size(request->encntr_list,5)
 SET count = 0
 SELECT
  IF ((request->sort_flag=0))
   ORDER BY e.reg_dt_tm
  ELSE
   ORDER BY e.reg_dt_tm DESC
  ENDIF
  DISTINCT INTO "nl:"
  e.encntr_id
  FROM encounter e,
   (dummyt d1  WITH seq = value(cr_count)),
   encntr_alias ea1,
   (dummyt d2  WITH seq = 1),
   encntr_alias ea2,
   (dummyt d3  WITH seq = 1),
   diagnosis d,
   nomenclature n,
   (dummyt d4  WITH seq = 1),
   organization o,
   (dummyt d5  WITH seq = 1)
  PLAN (d1)
   JOIN (e
   WHERE (e.encntr_id=request->encntr_list[d1.seq].encntr_id)
    AND e.active_ind=1
    AND e.encntr_id > 0
    AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d2)
   JOIN (ea1
   WHERE (ea1.encntr_id=request->encntr_list[d1.seq].encntr_id)
    AND ea1.encntr_alias_type_cd=mrn_cd
    AND ea1.active_ind=1
    AND ea1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ea1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d3)
   JOIN (ea2
   WHERE (ea2.encntr_id=request->encntr_list[d1.seq].encntr_id)
    AND ea2.encntr_alias_type_cd=fin_nbr_cd
    AND ea2.active_ind=1
    AND ea2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ea2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d4)
   JOIN (d
   WHERE (d.encntr_id=request->encntr_list[d1.seq].encntr_id)
    AND d.active_ind=1
    AND d.diag_type_cd=diag_type_cd
    AND d.diag_priority=1)
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id
    AND n.active_ind=1)
   JOIN (d5)
   JOIN (o
   WHERE o.organization_id=e.organization_id
    AND o.active_ind=1)
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(reply->encntr_list,(count+ 9))
   ENDIF
   reply->encntr_list[count].encntr_id = e.encntr_id, reply->encntr_list[count].reg_dt_tm = e
   .reg_dt_tm, reply->encntr_list[count].encntr_type_cd = e.encntr_type_cd,
   reply->encntr_list[count].loc_facility_cd = e.loc_facility_cd, reply->encntr_list[count].
   loc_building_cd = e.loc_building_cd, reply->encntr_list[count].loc_nurse_unit_cd = e
   .loc_nurse_unit_cd,
   reply->encntr_list[count].disch_dt_tm = e.disch_dt_tm, reply->encntr_list[count].organization_id
    = e.organization_id, reply->encntr_list[count].mrn = cnvtalias(ea1.alias,ea1.alias_pool_cd),
   reply->encntr_list[count].fin_nbr = cnvtalias(ea2.alias,ea2.alias_pool_cd), reply->encntr_list[
   count].diag_ftdesc =
   IF (d.nomenclature_id=0) d.diag_ftdesc
   ELSE n.source_string
   ENDIF
   , reply->encntr_list[count].client_name = o.org_name
  WITH dontcare = ea1, dontcare = ea2, dontcare = d,
   outerjoin = d2, outerjoin = d3, outerjoin = d4,
   outerjoin = d5, nocounter
 ;end select
 IF (count > 0)
  SET stat = alterlist(reply->encntr_list,count)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
