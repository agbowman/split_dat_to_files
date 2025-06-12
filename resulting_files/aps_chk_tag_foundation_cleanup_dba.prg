CREATE PROGRAM aps_chk_tag_foundation_cleanup:dba
 SELECT INTO "nl:"
  t.tag_group_id
  FROM tag_group_foundation t
  WHERE t.tag_group_id > 0
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "Tag Group Foundation cleanup failed"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  t.tag_group_id
  FROM tag_foundation t
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "Tag Foundation cleanup failed"
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "Tag Foundation cleanup successful"
 ENDIF
#exit_script
 EXECUTE dm_add_upt_setup_proc_log
END GO
