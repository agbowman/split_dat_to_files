CREATE PROGRAM dcp_chk_multipat_entity:dba
 SET tmx_records = 0
 SET tmcc_records = 0
 SELECT INTO "nl:"
  tmx.parent_entity_id, tmx.parent_entity_name
  FROM tl_multipatient_xref tmx
  WHERE tmx.parent_entity_id > 0
   AND ((tmx.parent_entity_name != "PRSNL"
   AND tmx.parent_entity_name != "CODE_VALUE"
   AND tmx.parent_entity_name != "TL_MASTER_TAB_SET") OR (tmx.parent_entity_name=null))
  DETAIL
   tmx_records = (tmx_records+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  tmcc.parent_entity_id, tmcc.parent_entity_name
  FROM tl_multpat_col_content tmcc
  WHERE tmcc.parent_entity_id > 0
   AND ((tmcc.parent_entity_name != "PRSNL"
   AND tmcc.parent_entity_name != "CODE_VALUE"
   AND tmcc.parent_entity_name != "TL_MASTER_TAB_SET") OR (tmcc.parent_entity_name=null))
  DETAIL
   tmcc_records = (tmcc_records+ 1)
  WITH nocounter
 ;end select
 SET request->setup_proc[1].process_id = 805
 IF (tmx_records != 0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "The parent_entity_name field on the tl_multipatient_xref table was not updated correctly."
 ELSEIF (tmcc_records != 0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "The parent_entity_name field on the tl_multpat_col_content table was not updated correctly."
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "The parent_entity_name field was updated correctly on both the tl_multipatient_xref and tl_multpat_col_content tbls"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
