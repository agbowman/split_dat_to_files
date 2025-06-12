CREATE PROGRAM dcp_get_prsnl_plan_by_prsnl:dba
 SET modify = predeclare
 RECORD reply(
   1 qual[*]
     2 pathway_catalog_id = f8
     2 description = vc
     2 active_ind = i2
     2 pathway_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ncnt = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM pw_cat_flex pcf,
   pathway_catalog pwc
  PLAN (pcf
   WHERE (pcf.parent_entity_id=request->prsnl_id)
    AND pcf.parent_entity_name="PRSNL")
   JOIN (pwc
   WHERE pwc.pathway_catalog_id=pcf.pathway_catalog_id
    AND pwc.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
    AND pwc.active_ind=1
    AND pwc.type_mean != "TAPERPLAN")
  ORDER BY pcf.display_description_key
  HEAD REPORT
   ncnt = 0
  HEAD pcf.display_description_key
   ncnt = (ncnt+ 1)
   IF (ncnt > size(reply->qual,5))
    stat = alterlist(reply->qual,(ncnt+ 20))
   ENDIF
   reply->qual[ncnt].pathway_catalog_id = pcf.pathway_catalog_id, reply->qual[ncnt].description =
   trim(pwc.description), reply->qual[ncnt].active_ind = pwc.active_ind,
   reply->qual[ncnt].pathway_type_cd = pwc.pathway_type_cd
  DETAIL
   dummy = 0
  FOOT  pcf.display_description_key
   ncnt = ncnt
  FOOT REPORT
   stat = alterlist(reply->qual,ncnt)
  WITH nocounter
 ;end select
 IF (size(reply->qual,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
