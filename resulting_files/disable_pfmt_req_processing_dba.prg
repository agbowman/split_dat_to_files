CREATE PROGRAM disable_pfmt_req_processing:dba
 UPDATE  FROM request_processing
  SET active_ind = 0
  WHERE request_number IN (951097, 951048, 951074, 951049, 951364,
  951028)
   AND format_script="PFMT_E_NT_CHRG_BILLING"
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing
  SET active_ind = 0
  WHERE request_number=114001
   AND format_script="PFMT_AFC_114001"
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing
  SET active_ind = 0
  WHERE request_number IN (1150007, 1135006)
   AND format_script="PFMT_EVAL_DIAG_ASSOCIATION"
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing
  SET active_ind = 0
  WHERE request_number IN (4050149, 4057000, 4051618, 4050714, 4054891,
  4054882, 4059029, 4059700, 4059020, 4051111,
  4051110, 4051621, 4051622, 951021, 4051626,
  4054881, 4057002, 4051627, 4051625, 4051112,
  4051570, 4080007, 4080008)
   AND format_script="PFMT_LOG_EVENT_ACTION"
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing
  SET active_ind = 0
  WHERE request_number=114001
   AND format_script="PFMT_PFT_114001"
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing
  SET active_ind = 0
  WHERE request_number=114609
   AND format_script="PFMT_PFT_114609"
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing
  SET active_ind = 0
  WHERE request_number=4050147
   AND format_script="PFMT_PFT_4050147"
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing
  SET active_ind = 0
  WHERE request_number=4050149
   AND format_script="PFMT_PFT_4050149"
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing
  SET active_ind = 0
  WHERE request_number=4054880
   AND format_script="PFMT_PFT_4054880"
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing
  SET active_ind = 0
  WHERE request_number=4054881
   AND target_request_number=4059012
   AND format_script="PFMT_PFT_4054880"
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing
  SET active_ind = 0
  WHERE request_number=4054881
   AND target_request_number=4059022
   AND format_script="PFMT_PFT_4054881"
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing
  SET active_ind = 0
  WHERE request_number=114001
   AND target_request_number=4080007
   AND format_script="PFMT_PFT_APPLY_WD_HOLD"
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing
  SET active_ind = 0
  WHERE request_number=4052101
   AND format_script="PFMT_PFT_BE_CUSTOM_OBJ_IMP"
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing
  SET active_ind = 0
  WHERE request_number=4050174
   AND format_script="PFMT_PFT_BR_VALIDATION"
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing
  SET active_ind = 0
  WHERE request_number=100102
   AND target_request_number=4080103
   AND format_script="PFMT_PFT_CALL_COMBINE"
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing
  SET active_ind = 0
  WHERE request_number=100103
   AND target_request_number=4080134
   AND format_script="PFMT_PFT_CALL_UNCOMBINE"
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing
  SET active_ind = 0
  WHERE request_number=100102
   AND format_script="PFMT_PFT_COMBINE_TRIGGER"
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing
  SET active_ind = 0
  WHERE request_number IN (4050700, 4050712)
   AND format_script="PFMT_PFT_REL_BAD_RUG_DAYS_HOLD"
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing
  SET active_ind = 0
  WHERE request_number=4050712
   AND format_script="PFMT_PFT_REL_ERR_RUG_HOLD_CODE"
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing
  SET active_ind = 0
  WHERE request_number=4050700
   AND format_script="PFMT_PFT_REL_NO_RUG_CODE_HOLD"
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing
  SET active_ind = 0
  WHERE request_number=114001
   AND target_request_number=4080008
   AND format_script="PFMT_PFT_REL_WD_HOLD"
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing
  SET active_ind = 0
  WHERE request_number=4072033
   AND format_script="PFMT_PFT_SERVICE_EVENT"
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing
  SET active_ind = 0
  WHERE request_number=100103
   AND format_script="PFMT_PFT_UNCOMBINE_TRIGGER"
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing
  SET active_ind = 0
  WHERE request_number IN (1150007, 1135006)
   AND format_script="PFMT_UPT_PE_STATUS_RSN"
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing
  SET active_ind = 0
  WHERE request_number=4054881
   AND target_request_number=0
   AND format_script="PFMT_PFT_4054881"
  WITH nocounter
 ;end update
 UPDATE  FROM request_processing
  SET active_ind = 0
  WHERE request_number=114001
   AND target_request_number=0
   AND format_script="PFMT_PFT_REL_WD_HOLD"
  WITH nocounter
 ;end update
 COMMIT
END GO
