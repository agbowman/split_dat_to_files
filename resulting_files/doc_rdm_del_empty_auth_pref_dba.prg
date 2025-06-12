CREATE PROGRAM doc_rdm_del_empty_auth_pref:dba
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
 SET readme_data->message = "Readme Failed:  Starting script doc_rdm_del_empty_auth_pref"
 DECLARE err_msg = vc WITH protect, noconstant("")
 DECLARE min_id = f8 WITH protect, noconstant(0.0)
 DECLARE max_id = f8 WITH protect, noconstant(0.0)
 DECLARE batch_start = f8 WITH protect, noconstant(0.0)
 DECLARE batch_end = f8 WITH protect, noconstant(0.0)
 DECLARE batch_size = f8 WITH protect, noconstant(2500000.0)
 SELECT INTO "nl:"
  min_val = min(name_value_prefs_id)
  FROM name_value_prefs
  WHERE name_value_prefs_id > 0
  DETAIL
   min_id = minval(cnvtreal(min_val),1.0)
  WITH nocounter
 ;end select
 IF (error(err_msg,0) != 0)
  CALL echo("Readme Failed: Could not retrive mix/max id")
  SET readme_data->message = concat("doc_rdm_del_empty_auth_pref failed to obtain min id: ",err_msg)
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  max_val = max(name_value_prefs_id)
  FROM name_value_prefs
  DETAIL
   max_id = cnvtreal(max_val)
  WITH nocounter
 ;end select
 IF (error(err_msg,0) != 0)
  CALL echo("Readme Failed: Could not retrive mix/max id")
  SET readme_data->message = concat("doc_rdm_del_empty_auth_pref failed to obtain max id: ",err_msg)
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 SET batch_start = min_id
 SET batch_end = (min_id+ batch_size)
 WHILE (batch_start <= max_id)
   DELETE  FROM name_value_prefs
    WHERE name_value_prefs_id >= batch_start
     AND name_value_prefs_id <= batch_end
     AND pvc_name IN ("ALLOWSIGNNOTE", "REQENDORSEMENT", "ALLOWCREATESHAREDPCNOTE", "ALLOWSIGNNOTE",
    "REAUTHENTICATEONSIGNNOTE",
    "ALLOWPLACEORD_DX", "VIEWEXISTINGNOTESRESTRICTION", "ALLOWDICTATIONS",
    "ALLOWNONTRANSCRIBEDDICTATIONS", "ALLOWEPSELECTIONFROMCATALOGONLY",
    "LIMITCATALOGLIST")
     AND parent_entity_name="DETAIL_PREFS"
     AND pvc_value=" "
    WITH nocounter
   ;end delete
   IF (error(err_msg,0) != 0)
    CALL echo("Readme Failed: Could not delete empty authorization preferences")
    SET readme_data->message = concat(
     "Group 2 : doc_rdm_del_empty_auth_pref failed to update table rows: ",err_msg)
    SET readme_data->status = "F"
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
   SET batch_start = (batch_start+ batch_size)
   SET batch_end = (batch_end+ batch_size)
 ENDWHILE
 SET readme_data->message = "Updated successfully."
 SET readme_data->status = "S"
#exit_script
 IF ((readme_data->status="S"))
  CALL echo("*** Updated successfully ***")
 ELSE
  ROLLBACK
  CALL echo("*** Update failed ***")
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
