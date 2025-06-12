CREATE PROGRAM bed_ens_xr_destination_xrefs:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE xref_id = f8 WITH noconstant(request->xref_id)
 DECLARE active_status_cd = f8 WITH noconstant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE dms_identifier = vc WITH noconstant(evaluate2(
   IF ((request->destination_cd=0)) trim(request->dms_service_identifier)
   ELSE ""
   ENDIF
   ))
 IF ((request->action_ind=0))
  IF (xref_id=0)
   DELETE  FROM cr_destination_xref cdx
    WHERE (cdx.parent_entity_name=request->entity_type)
     AND (cdx.parent_entity_id=request->entity_id)
   ;end delete
  ELSE
   DELETE  FROM cr_destination_xref cdx
    WHERE (cdx.cr_destination_xref_id=request->xref_id)
   ;end delete
  ENDIF
  IF (curqual=0)
   CALL echo("unable to delete row in CR_DESTINATION_XREF")
   GO TO exit_script
  ENDIF
 ELSE
  IF (xref_id=0)
   SELECT
    cdx.cr_destination_xref_id
    FROM cr_destination_xref cdx
    WHERE (cdx.parent_entity_name=request->entity_type)
     AND (cdx.parent_entity_id=request->entity_id)
    DETAIL
     xref_id = cdx.cr_destination_xref_id
    WITH nocounter
   ;end select
  ENDIF
  IF (xref_id=0)
   INSERT  FROM cr_destination_xref cdx
    SET cdx.cr_destination_xref_id = seq(reference_seq,nextval), cdx.parent_entity_name = request->
     entity_type, cdx.parent_entity_id = request->entity_id,
     cdx.device_cd = request->destination_cd, cdx.destination_type_cd = request->destination_type_cd,
     cdx.dms_service_identifier = dms_identifier,
     cdx.active_ind = 1, cdx.active_status_dt_tm = cnvtdatetime(curdate,curtime3), cdx
     .active_status_prsnl_id = reqinfo->updt_id,
     cdx.active_status_cd = active_status_cd, cdx.updt_cnt = 0, cdx.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     cdx.updt_id = reqinfo->updt_id, cdx.updt_task = reqinfo->updt_task, cdx.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL echo("unable to insert new row in CR_DESTINATION_XREF")
    GO TO exit_script
   ENDIF
  ELSE
   UPDATE  FROM cr_destination_xref cdx
    SET cdx.device_cd = request->destination_cd, cdx.destination_type_cd = request->
     destination_type_cd, cdx.dms_service_identifier = dms_identifier,
     cdx.updt_cnt = (cdx.updt_cnt+ 1), cdx.updt_dt_tm = cnvtdatetime(curdate,curtime3), cdx.updt_id
      = reqinfo->updt_id,
     cdx.updt_task = reqinfo->updt_task, cdx.updt_applctx = reqinfo->updt_applctx
    WHERE cdx.cr_destination_xref_id=xref_id
   ;end update
   IF (curqual=0)
    CALL echo("unable to update row in CR_DESTINATION_XREF")
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
END GO
