CREATE PROGRAM dcp_migrate_plan_ref_text:dba
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
 DECLARE errmsg = vc WITH protect, noconstant("")
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed:  Starting script dcp_migrate_plan_ref_text"
 UPDATE  FROM ref_text_reltn rt
  SET rt.parent_entity_name = "PATHWAY_CATALOG", rt.updt_dt_tm = cnvtdatetime(curdate,curtime3), rt
   .updt_cnt = (rt.updt_cnt+ 1),
   rt.updt_id = reqinfo->updt_id, rt.updt_task = reqinfo->updt_task, rt.parent_entity_id =
   (SELECT
    p.pathway_catalog_id
    FROM pw_evidence_reltn p
    WHERE p.type_mean="REFTEXT"
     AND p.pw_evidence_reltn_id=rt.parent_entity_id)
  WHERE rt.parent_entity_name="PW_EVIDENCE_RELTN"
   AND  EXISTS (
  (SELECT
   1
   FROM pw_evidence_reltn pw
   WHERE pw.type_mean="REFTEXT"
    AND pw.pw_evidence_reltn_id=rt.parent_entity_id))
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme failed. Unable to read update ref_text_reltn table. ",
   errmsg)
  GO TO exit_script
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Readme complete. Data migration succesful."
  COMMIT
 ENDIF
 DELETE  FROM pw_evidence_reltn pw
  WHERE pw.type_mean="REFTEXT"
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Readme failed. Unable to remove rows from pw_evidence_reltn table. ",errmsg)
  GO TO exit_script
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Readme complete. Data migration succesful."
  COMMIT
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
