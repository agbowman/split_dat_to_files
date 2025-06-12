CREATE PROGRAM dcp_check_pw_catalog
 RECORD reply(
   1 duplicate_ind = i2
   1 dup_pathway_catalog_id = f8
   1 prsnl_plan_dup_ind = i2
   1 prsnl_plan_list[*]
     2 pathway_catalog_id = f8
     2 ref_owner_person_id = f8
     2 owner_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
   1 taper_plan_dup_ind = i2
   1 taper_plan_list[*]
     2 pathway_catalog_id = f8
     2 ref_owner_person_id = f8
     2 owner_name = vc
 )
 SET reply->status_data.status = "F"
 SET reply->duplicate_ind = 0
 SET reply->dup_pathway_catalog_id = 0
 SET reply->prsnl_plan_dup_ind = 0
 SET reply->taper_plan_dup_ind = 0
 SET dup_id = 0
 SET prsnlplancnt = 0
 SET taperplancnt = 0
 SELECT INTO "nl:"
  pwc.pathway_catalog_id
  FROM pathway_catalog pwc
  WHERE pwc.description_key=trim(cnvtupper(request->description))
   AND ((pwc.type_mean IN ("PATHWAY", "CAREPLAN")) OR (nullind(pwc.type_mean)=1))
   AND pwc.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND (pwc.pathway_catalog_id != request->pathway_catalog_id)
   AND pwc.ref_owner_person_id=0
  DETAIL
   reply->duplicate_ind = 1, reply->dup_pathway_catalog_id = pwc.pathway_catalog_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pwc.pathway_catalog_id, name = trim(pr.name_full_formatted)
  FROM pathway_catalog pwc,
   prsnl pr
  PLAN (pwc
   WHERE pwc.description_key=trim(cnvtupper(request->description))
    AND pwc.type_mean IN ("CAREPLAN", "TAPERPLAN")
    AND (pwc.pathway_catalog_id != request->pathway_catalog_id)
    AND pwc.active_ind=1
    AND pwc.ref_owner_person_id > 0)
   JOIN (pr
   WHERE pr.person_id=pwc.ref_owner_person_id)
  ORDER BY name
  HEAD REPORT
   prsnlplancnt = 0, taperplancnt = 0
  DETAIL
   IF (pwc.type_mean="CAREPLAN")
    prsnlplancnt = (prsnlplancnt+ 1), reply->prsnl_plan_dup_ind = 1, stat = alterlist(reply->
     prsnl_plan_list,prsnlplancnt),
    reply->prsnl_plan_list[prsnlplancnt].pathway_catalog_id = pwc.pathway_catalog_id, reply->
    prsnl_plan_list[prsnlplancnt].ref_owner_person_id = pwc.ref_owner_person_id, reply->
    prsnl_plan_list[prsnlplancnt].owner_name = name
   ELSEIF (pwc.type_mean="TAPERPLAN")
    taperplancnt = (taperplancnt+ 1), reply->taper_plan_dup_ind = 1, stat = alterlist(reply->
     taper_plan_list,taperplancnt),
    reply->taper_plan_list[taperplancnt].pathway_catalog_id = pwc.pathway_catalog_id, reply->
    taper_plan_list[taperplancnt].ref_owner_person_id = pwc.ref_owner_person_id, reply->
    taper_plan_list[taperplancnt].owner_name = name
   ENDIF
  FOOT REPORT
   prsnlplancnt = 0, taperplancnt = 0
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
END GO
