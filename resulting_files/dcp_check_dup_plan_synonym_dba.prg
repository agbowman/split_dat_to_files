CREATE PROGRAM dcp_check_dup_plan_synonym:dba
 RECORD reply(
   1 duplicationslist[*]
     2 name = vc
     2 facility_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE highnames = i4 WITH noconstant(0), protect
 DECLARE cntnames = i4 WITH noconstant(0), protect
 DECLARE highfacilities = i4 WITH noconstant(0), protect
 DECLARE cntfacilities = i4 WITH noconstant(0), protect
 DECLARE icnt = i4 WITH noconstant(0), protect
 DECLARE allfacilitiesind = i1 WITH noconstant(0), protect
 DECLARE i = i2 WITH noconstant(0), protect
 DECLARE stat = i2 WITH noconstant(0), protect
 DECLARE pcf_where_clause = vc WITH noconstant(fillstring(500,""))
 DECLARE version_id = f8 WITH noconstant(0.0), protect
 SET highnames = value(size(request->plannameslist,5))
 SET highfacilities = value(size(request->facilitycdslist,5))
 IF (((highnames=0) OR (highfacilities=0)) )
  GO TO exit_program
 ENDIF
 SET cntnames = 0
 SET cntfacilities = 0
 SET allfacilitiesind = 0
 FOR (i = 1 TO highfacilities)
   IF ((request->facilitycdslist[i].facility_cd=0))
    SET allfacilitiesind = 1
   ENDIF
 ENDFOR
 FOR (i = 1 TO highnames)
   SET request->plannameslist[i].name = trim(cnvtupper(request->plannameslist[i].name))
 ENDFOR
 IF (allfacilitiesind=1)
  SET pcf_where_clause = build("1=1")
 ELSE
  SET pcf_where_clause = build("(pcf.parent_entity_id = 0 OR ",
   " expand(cntFacilities, 1, highFacilities, pcf.parent_entity_id, request->facilityCdsList[cntFacilities]->facility_cd))"
   )
 ENDIF
 SELECT INTO "nl:"
  FROM pathway_catalog pc
  WHERE (pc.pathway_catalog_id=request->pathway_catalog_id)
  DETAIL
   version_id = pc.version_pw_cat_id
  WITH nocounter
 ;end select
 CALL echo(version_id)
 SELECT INTO "nl:"
  pcs.synonym_name, pcf.parent_entity_id
  FROM pw_cat_synonym pcs,
   pathway_catalog pc,
   pw_cat_flex pcf
  PLAN (pcs
   WHERE expand(cntnames,1,highnames,pcs.synonym_name_key,request->plannameslist[cntnames].name))
   JOIN (pc
   WHERE pc.pathway_catalog_id=pcs.pathway_catalog_id
    AND pc.version_pw_cat_id != version_id)
   JOIN (pcf
   WHERE pcf.pathway_catalog_id=pc.pathway_catalog_id
    AND pcf.parent_entity_name="CODE_VALUE"
    AND parser(pcf_where_clause))
  HEAD REPORT
   icnt = 0, stat = alterlist(reply->duplicationslist,5)
  DETAIL
   icnt = (icnt+ 1)
   IF (mod(icnt,5)=1
    AND icnt != 1)
    stat = alterlist(reply->duplicationslist,(icnt+ 4))
   ENDIF
   reply->duplicationslist[icnt].name = pcs.synonym_name, reply->duplicationslist[icnt].facility_cd
    = pcf.parent_entity_id
  FOOT REPORT
   stat = alterlist(reply->duplicationslist,icnt)
  WITH nocounter
 ;end select
#exit_program
 SET reply->status_data.status = "S"
END GO
