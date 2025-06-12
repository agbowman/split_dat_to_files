CREATE PROGRAM dcp_get_equation_for_dta:dba
 RECORD reply(
   1 qual[*]
     2 equation_id = f8
     2 species_disp = vc
     2 age_from_units_disp = vc
     2 age_to_units_disp = vc
     2 equation_desc = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET ncnt = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  e.equation_id, speciesdisp = uar_get_code_display(e.species_cd), fromage = uar_get_code_display(e
   .age_from_units_cd),
  toage = uar_get_code_display(e.age_to_units_cd), e.equation_description
  FROM equation e
  WHERE (e.task_assay_cd=request->task_assay_cd)
   AND e.active_ind=1
  HEAD REPORT
   ncnt = 0
  DETAIL
   ncnt = (ncnt+ 1)
   IF (ncnt > size(reply->qual,5))
    stat = alterlist(reply->qual,(ncnt+ 10))
   ENDIF
   CALL echo(e.equation_id), reply->qual[ncnt].equation_id = e.equation_id, reply->qual[ncnt].
   species_disp = trim(speciesdisp),
   reply->qual[ncnt].age_from_units_disp = trim(fromage), reply->qual[ncnt].age_to_units_disp = trim(
    toage), reply->qual[ncnt].equation_desc = e.equation_description
  WITH nocounter
 ;end select
 CALL echo("Here is the Count")
 CALL echo(ncnt)
 SET reply->status_data.status = "S"
 SET stat = alterlist(reply->qual,ncnt)
END GO
