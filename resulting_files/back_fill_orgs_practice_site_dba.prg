CREATE PROGRAM back_fill_orgs_practice_site:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed:  Starting script back_fill_orgs_practice_site..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE valcnt = i4 WITH protect, noconstant(0)
 FREE RECORD psd
 RECORD psd(
   1 dr[*]
     2 ps_id = f8
     2 ps_primary_entity_id = f8
     2 ps_primary_entity_name = vc
 )
 CALL getallpracticesites(null)
 CALL setorgvalues(null)
 SUBROUTINE getallpracticesites(null)
   SELECT INTO "nl:"
    FROM practice_site ps
    WHERE ps.practice_site_id != 0
    DETAIL
     valcnt = (valcnt+ 1)
     IF (mod(valcnt,10)=1)
      stat = alterlist(psd->dr,(valcnt+ 10))
     ENDIF
     psd->dr[valcnt].ps_id = ps.practice_site_id, psd->dr[valcnt].ps_primary_entity_id = ps
     .primary_entity_id, psd->dr[valcnt].ps_primary_entity_name = ps.primary_entity_name
    WITH nocounter
   ;end select
   SET stat = alterlist(psd->dr,valcnt)
   IF (error(errmsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to retrieve data for practice site: ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE setorgvalues(null)
   DECLARE practicesitesize = i4 WITH protect, noconstant(0)
   DECLARE temporgvalue = i4 WITH protect, noconstant(0)
   FOR (valsids = 1 TO size(psd->dr,5))
    IF (trim(psd->dr[valsids].ps_primary_entity_name)="ORGANIZATION")
     SET temporgvalue = getorgidfromorganization(psd->dr[valsids].ps_primary_entity_id)
     CALL updateorgid(temporgvalue,psd->dr[valsids].ps_id)
    ENDIF
    IF (trim(psd->dr[valsids].ps_primary_entity_name)="LOCATION")
     SET temporgvalue = getorgvalueforlocationcd(psd->dr[valsids].ps_primary_entity_id)
     SET temporgvalue = getorgidfromorganization(temporgvalue)
     CALL updateorgid(temporgvalue,psd->dr[valsids].ps_id)
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE updateorgid(org_id,practice_site_id)
  UPDATE  FROM practice_site ps
   SET ps.organization_id = org_id, ps.updt_dt_tm = cnvtdatetime(curdate,curtime3), ps.updt_id =
    reqinfo->updt_id,
    ps.updt_task = reqinfo->updt_task, ps.updt_applctx = reqinfo->updt_applctx, ps.updt_cnt = (ps
    .updt_cnt+ 1)
   WHERE ps.practice_site_id=practice_site_id
   WITH nocounter
  ;end update
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to Update organization ids data for practice site: ",
    errmsg)
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE getorgvalueforlocationcd(primary_entity_id)
   DECLARE orgid = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM location l
    WHERE l.location_cd=primary_entity_id
    DETAIL
     orgid = l.organization_id
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat(
     "Failed to retrieve location to organization data for practice site: ",errmsg)
    GO TO exit_script
   ENDIF
   RETURN(orgid)
 END ;Subroutine
 SUBROUTINE getorgidfromorganization(organizationid)
   DECLARE orgid = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM organization o
    WHERE o.organization_id=organizationid
    DETAIL
     orgid = o.organization_id
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to retrieve organization data: ",errmsg)
    GO TO exit_script
   ENDIF
   RETURN(orgid)
 END ;Subroutine
 COMMIT
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 FREE RECORD psd
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
