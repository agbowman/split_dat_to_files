CREATE PROGRAM ap_processing_grp_r_fix2:dba
 UPDATE  FROM ap_processing_grp_r ap
  SET ap.grouper_cd = ap.parent_entity_id
  WHERE 1=1
  WITH nocounter
 ;end update
 IF (curqual=0)
  ROLLBACK
  CALL echo("Error updating ap_processing_grp_r...")
 ELSE
  COMMIT
  CALL echo("ap_processing_grp_r updated successfully!")
 ENDIF
END GO
