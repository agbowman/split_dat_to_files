CREATE PROGRAM edw_create_hfmtransmit:dba
 DECLARE health_system_source_id = vc WITH noconstant(" ")
 DECLARE client_mnemonic = vc WITH noconstant(" ")
 DECLARE log_purge_days = vc WITH noconstant(" ")
 DECLARE edw_encrypt_flag = vc WITH noconstant(" ")
 DECLARE edw_transmit_flag = vc WITH noconstant(" ")
 DECLARE extract_dir = vc WITH noconstant(" ")
 DECLARE archive_dir = vc WITH noconstant(" ")
 DECLARE archive_purge_days = vc WITH noconstant(" ")
 DECLARE edw_target_address = vc WITH noconstant(" ")
 DECLARE edw_auth_flag = vc WITH noconstant(" ")
 DECLARE edw_user_name = vc WITH noconstant(" ")
 DECLARE edw_pswd = vc WITH noconstant(" ")
 DECLARE edw_passive_state = vc WITH noconstant(" ")
 DECLARE uar_user_name = vc WITH noconstant(" ")
 DECLARE uar_domain = vc WITH noconstant(" ")
 DECLARE uar_password = vc WITH noconstant(" ")
 DECLARE rdbms_user_name = vc WITH noconstant(" ")
 DECLARE rdbms_pswd = vc WITH noconstant(" ")
 DECLARE orphan_remote_dir = vc WITH noconstant(" ")
 DECLARE orphan_local_dir = vc WITH noconstant(" ")
 DECLARE hfmtransmit_filename = vc WITH noconstant("HFMTRANSMIT")
 DECLARE hf_encrypt_flag = vc WITH noconstant(" ")
 DECLARE hf_transmit_flag = vc WITH noconstant(" ")
 DECLARE hf_target_address = vc WITH noconstant(" ")
 DECLARE hf_auth_flag = vc WITH noconstant(" ")
 DECLARE hf_user_name = vc WITH noconstant(" ")
 DECLARE hf_pswd = vc WITH noconstant(" ")
 DECLARE hf_passive_state = vc WITH noconstant(" ")
 DECLARE edw_ind = vc WITH noconstant(" ")
 DECLARE hf_ind = vc WITH noconstant(" ")
 DECLARE hs_ind = vc WITH noconstant(" ")
 DECLARE healthaware_ind = vc WITH noconstant(" ")
 DECLARE edw_ftp_remote_dir = vc WITH noconstant(" ")
 DECLARE hf_ftp_remote_dir = vc WITH noconstant(" ")
 DECLARE stand_by_ind = vc WITH noconstant(" ")
 DECLARE q_info_domain = vc WITH noconstant(" ")
 DECLARE auto_update_ind = vc WITH noconstant(" ")
 DECLARE auto_update_dir = vc WITH noconstant(" ")
 DECLARE hi_encrypt_flag = vc WITH noconstant(" ")
 DECLARE hi_transmit_flag = vc WITH noconstant(" ")
 DECLARE hi_target_address = vc WITH noconstant(" ")
 DECLARE hi_auth_flag = vc WITH noconstant(" ")
 DECLARE hi_user_name = vc WITH noconstant(" ")
 DECLARE hi_pswd = vc WITH noconstant(" ")
 DECLARE hi_passive_state = vc WITH noconstant(" ")
 DECLARE hi_ftp_remote_dir = vc WITH noconstant(" ")
 DECLARE historic_max_threads = vc WITH noconstant(" ")
 DECLARE continuous_shell_dir = vc WITH noconstant(" ")
 DECLARE hi_retry = vc WITH noconstant(" ")
 DECLARE hf_retry = vc WITH noconstant(" ")
 DECLARE edw_retry = vc WITH noconstant(" ")
 DECLARE log_level = vc WITH noconstant(" ")
 DECLARE hf_orphan_remote_dir = vc WITH noconstant(" ")
 DECLARE hi_orphan_remote_dir = vc WITH noconstant(" ")
 DECLARE max_threads = vc WITH noconstant(" ")
 DECLARE daily_overcommit = vc WITH noconstant(" ")
 DECLARE healtheintent_ind = vc WITH noconstant(" ")
 DECLARE ftp_flg = vc WITH noconstant(" ")
 DECLARE hist_solution = vc WITH noconstant(" ")
 DECLARE manual_solution = vc WITH noconstant(" ")
 DECLARE use_hf_ftp_config = vc WITH noconstant(" ")
 DECLARE hf_use_compression = vc WITH noconstant(" ")
 DECLARE edw_cclora = vc WITH noconstant(" ")
 DECLARE batch_xfer_ind = vc WITH noconstant(" ")
 DECLARE edw_batch_compression = vc WITH noconstant(" ")
 DECLARE edw_error_parse = vc WITH noconstant(" ")
 IF (reflect(parameter(1,0))=" ")
  SET hfmtransmit_filename = "HFMTRANSMIT"
 ELSE
  SET hfmtransmit_filename = parameter(1,0)
 ENDIF
 SELECT INTO value(hfmtransmit_filename)
  FROM dm_info di
  WHERE di.info_domain IN ("PI EDW SYSTEMS CONFIGURATION|*", "PI EDW OPERATIONS|*",
  "PI EDW DATA CONFIGURATION|*")
  DETAIL
   q_info_name = substring(1,(findstring("|",di.info_name,1) - 1),di.info_name), q_info_char =
   substring(1,(findstring("|",di.info_char,1) - 1),di.info_char), q_info_domain = substring((
    findstring("|",di.info_domain,1)+ 1),(size(di.info_domain,1) - findstring("|",di.info_domain,1)),
    di.info_domain)
   CASE (q_info_name)
    OF "HEALTH_SYSTEM_SOURCE_ID":
     health_system_source_id = q_info_char
    OF "CLIENT_MNEMONIC":
     client_mnemonic = q_info_char
    OF "LOG_PURGE_DAYS":
     log_purge_days = q_info_char
    OF "ENCRYPT_FLAG":
     IF (q_info_domain="EDW FTP CONFIGURATION")
      edw_encrypt_flag = q_info_char
     ELSEIF (q_info_domain="HF/HS FTP CONFIGURATION")
      hf_encrypt_flag = q_info_char
     ELSEIF (q_info_domain="HI FTP CONFIGURATION")
      hi_encrypt_flag = q_info_char
     ENDIF
    OF "TRANSMIT_FLAG":
     IF (q_info_domain="EDW FTP CONFIGURATION")
      edw_transmit_flag = q_info_char
     ELSEIF (q_info_domain="HF/HS FTP CONFIGURATION")
      hf_transmit_flag = q_info_char
     ELSEIF (q_info_domain="HI FTP CONFIGURATION")
      hi_transmit_flag = q_info_char
     ENDIF
    OF "EXTRACT_DIR":
     extract_dir = q_info_char
    OF "ARCHIVE_DIR":
     archive_dir = q_info_char
    OF "ARCHIVE_PURGE_DAYS":
     archive_purge_days = q_info_char
    OF "TARGET_ADDRESS":
     IF (q_info_domain="EDW FTP CONFIGURATION")
      edw_target_address = q_info_char
     ELSEIF (q_info_domain="HF/HS FTP CONFIGURATION")
      hf_target_address = q_info_char
     ELSEIF (q_info_domain="HI FTP CONFIGURATION")
      hi_target_address = q_info_char
     ENDIF
    OF "AUTH_FLAG":
     IF (q_info_domain="EDW FTP CONFIGURATION")
      edw_auth_flag = q_info_char
     ELSEIF (q_info_domain="HF/HS FTP CONFIGURATION")
      hf_auth_flag = q_info_char
     ELSEIF (q_info_domain="HI FTP CONFIGURATION")
      hi_auth_flag = q_info_char
     ENDIF
    OF "USER_NAME":
     IF (q_info_domain="EDW FTP CONFIGURATION")
      edw_user_name = q_info_char
     ELSEIF (q_info_domain="HF/HS FTP CONFIGURATION")
      hf_user_name = q_info_char
     ELSEIF (q_info_domain="HI FTP CONFIGURATION")
      hi_user_name = q_info_char
     ENDIF
    OF "PASSWORD":
     IF (q_info_domain="EDW FTP CONFIGURATION")
      edw_pswd = q_info_char
     ELSEIF (q_info_domain="HF/HS FTP CONFIGURATION")
      hf_pswd = q_info_char
     ELSEIF (q_info_domain="HI FTP CONFIGURATION")
      hi_pswd = q_info_char
     ENDIF
    OF "PASSIVE_STATE":
     IF (q_info_domain="EDW FTP CONFIGURATION")
      edw_passive_state = q_info_char
     ELSEIF (q_info_domain="HF/HS FTP CONFIGURATION")
      hf_passive_state = q_info_char
     ELSEIF (q_info_domain="HI FTP CONFIGURATION")
      hi_passive_state = q_info_char
     ENDIF
    OF "UAR_USER_NAME":
     uar_user_name = q_info_char
    OF "UAR_DOMAIN":
     uar_domain = q_info_char
    OF "UAR_PASSWORD":
     uar_password = q_info_char
    OF "RDBMS_USER_NAME":
     rdbms_user_name = q_info_char
    OF "RDBMS_PSWD":
     rdbms_pswd = q_info_char
    OF "ORPHAN_REMOTE_DIR":
     IF (q_info_domain="DIRECTORIES")
      orphan_remote_dir = q_info_char
     ELSEIF (q_info_domain="HF/HS FTP CONFIGURATION")
      hf_orphan_remote_dir = q_info_char
     ELSEIF (q_info_domain="HI FTP CONFIGURATION")
      hi_orphan_remote_dir = q_info_char
     ENDIF
    OF "ORPHAN_LOCAL_DIR":
     orphan_local_dir = q_info_char
    OF "EDW_IND":
     edw_ind = q_info_char
    OF "HEALTHSENTRY_IND":
     hs_ind = q_info_char
    OF "HEALTHFACTS_IND":
     hf_ind = q_info_char
    OF "EDW_FTP_REMOTE_DIR":
     edw_ftp_remote_dir = q_info_char
    OF "HF_FTP_REMOTE_DIR":
     hf_ftp_remote_dir = q_info_char
    OF "STAND_BY_IND":
     stand_by_ind = q_info_char
    OF "HEALTHAWARE_IND":
     healthaware_ind = q_info_char
    OF "AUTO_UPDATE_IND":
     auto_update_ind = q_info_char
    OF "AUTO_UPDATE_DIR":
     auto_update_dir = q_info_char
    OF "HI_ENCRYPT_FLAG":
     hi_encrypt_flag = q_info_char
    OF "HI_TRANSMIT_FLAG":
     hi_transmit_flag = q_info_char
    OF "HI_TARGET_ADDRESS":
     hi_target_address = q_info_char
    OF "HI_AUTH_FLAG":
     hi_auth_flag = q_info_char
    OF "HI_USER_NAME":
     hi_user_name = q_info_char
    OF "HI_PSWD":
     hi_pswd = q_info_char
    OF "HI_PASSIVE_STATE":
     hi_passive_state = q_info_char
    OF "HI_FTP_REMOTE_DIR":
     hi_ftp_remote_dir = q_info_char
    OF "HISTORIC_MAX_THREADS":
     historic_max_threads = q_info_char
    OF "CONTINUOUS_SHELL_DIR":
     continuous_shell_dir = q_info_char
    OF "RETRY":
     IF (q_info_domain="EDW FTP CONFIGURATION")
      edw_retry = q_info_char
     ELSEIF (q_info_domain="HF/HS FTP CONFIGURATION")
      hf_retry = q_info_char
     ELSEIF (q_info_domain="HI FTP CONFIGURATION")
      hi_retry = q_info_char
     ENDIF
    OF "LOG_LEVEL":
     log_level = q_info_char
    OF "MAX_THREADS":
     max_threads = q_info_char
    OF "DAILY_OVERCOMMIT":
     daily_overcommit = q_info_char
    OF "HEALTHEINTENT_IND":
     healtheintent_ind = cnvtupper(q_info_char)
    OF "FTP_FLG":
     ftp_flg = cnvtupper(q_info_char)
    OF "HIST_SOLUTION":
     hist_solution = cnvtupper(q_info_char)
    OF "MANUAL_SOLUTION":
     manual_solution = cnvtupper(q_info_char)
    OF "USE_HF_FTP_CONFIG":
     use_hf_ftp_config = cnvtupper(q_info_char)
    OF "CCL_VERSION":
     IF ((((currevminor2+ (currevminor * 100))+ (currev * 10000)) >= 080903))
      edw_cclora = "Y"
     ELSE
      edw_cclora = cnvtupper(q_info_char)
     ENDIF
    OF "USE_COMPRESSION":
     IF (q_info_domain="HF/HS FTP CONFIGURATION")
      hf_use_compression = cnvtupper(q_info_char)
     ENDIF
    OF "BATCH_TRANSFER":
     IF (q_info_domain="HF/HS FTP CONFIGURATION")
      batch_xfer_ind = cnvtupper(q_info_char)
     ENDIF
    OF "EDW_BATCH_COMPRESSION":
     edw_batch_compression = cnvtupper(q_info_char)
    OF "EDW_ERROR_PARSE":
     edw_error_parse = cnvtupper(q_info_char)
   ENDCASE
  FOOT REPORT
   col 0,
   CALL print(concat("CLIENT_NBR: ",health_system_source_id)), row + 1,
   CALL print(concat("CLIENT_MNE: ",client_mnemonic)), row + 1,
   CALL print(concat("LOG_PURGE_DAYS: ",log_purge_days)),
   row + 1,
   CALL print(concat("EDW_ENCRYPT_FLAG: ",evaluate(cursys,"AIX",cnvtlower(edw_encrypt_flag),
     edw_encrypt_flag))), row + 1,
   CALL print(concat("HF_ENCRYPT_FLAG: ",evaluate(cursys,"AIX",cnvtlower(hf_encrypt_flag),
     hf_encrypt_flag))), row + 1,
   CALL print(concat("EDW_TRANSMIT_FLAG: ",evaluate(cursys,"AIX",cnvtlower(edw_transmit_flag),
     edw_transmit_flag))),
   row + 1,
   CALL print(concat("HF_TRANSMIT_FLAG: ",evaluate(cursys,"AIX",cnvtlower(hf_transmit_flag),
     hf_transmit_flag))), row + 1,
   CALL print(concat("EXTRACT_DIR: ",extract_dir)), row + 1,
   CALL print(concat("ARCHIVE_DIR: ",archive_dir)),
   row + 1,
   CALL print(concat("ARCHIVE_PURGE_DAYS: ",archive_purge_days)), row + 1,
   CALL print(concat("EDW_TARGET_ADDRESS: ",edw_target_address)), row + 1,
   CALL print(concat("HF_TARGET_ADDRESS: ",hf_target_address)),
   row + 1,
   CALL print(concat("EDW_AUTH_FLAG: ",evaluate(cursys,"AIX",cnvtlower(edw_auth_flag),edw_auth_flag))
   ), row + 1,
   CALL print(concat("HF_AUTH_FLAG: ",evaluate(cursys,"AIX",cnvtlower(hf_auth_flag),hf_auth_flag))),
   row + 1,
   CALL print(concat("EDW_USER_NAME: ",edw_user_name)),
   row + 1,
   CALL print(concat("HF_USER_NAME: ",hf_user_name)), row + 1,
   CALL print(concat("EDW_PSWD: ",edw_pswd)), row + 1,
   CALL print(concat("HF_PSWD: ",hf_pswd)),
   row + 1,
   CALL print(concat("EDW_PASSIVE_STATE: ",evaluate(cursys,"AIX",cnvtlower(edw_passive_state),
     edw_passive_state))), row + 1,
   CALL print(concat("HF_PASSIVE_STATE: ",evaluate(cursys,"AIX",cnvtlower(hf_passive_state),
     hf_passive_state))), row + 1,
   CALL print(concat("UAR_USER_NAME: ",uar_user_name)),
   row + 1,
   CALL print(concat("UAR_DOMAIN: ",uar_domain)), row + 1,
   CALL print(concat("UAR_PASSWORD: ",uar_password)), row + 1,
   CALL print(concat("RDBMS_USER_NAME: ",rdbms_user_name)),
   row + 1,
   CALL print(concat("RDBMS_PSWD: ",rdbms_pswd)), row + 1,
   CALL print(concat("ORPHAN_REMOTE_DIR: ",orphan_remote_dir)), row + 1,
   CALL print(concat("ORPHAN_LOCAL_DIR: ",orphan_local_dir)),
   row + 1,
   CALL print(concat("EDW_IND: ",edw_ind)), row + 1,
   CALL print(concat("HF_IND: ",hf_ind)), row + 1,
   CALL print(concat("HS_IND: ",hs_ind)),
   row + 1,
   CALL print(concat("EDW_FTP_REMOTE_DIR: ",edw_ftp_remote_dir)), row + 1,
   CALL print(concat("HF_FTP_REMOTE_DIR: ",hf_ftp_remote_dir)), row + 1,
   CALL print(concat("STAND_BY_IND: ",stand_by_ind)),
   row + 1,
   CALL print(concat("EDW_CCLORA: ",edw_cclora)), row + 1,
   CALL print(concat("HEALTHAWARE_IND: ",healthaware_ind)), row + 1,
   CALL print(concat("AUTO_UPDATE_IND: ",auto_update_ind)),
   row + 1,
   CALL print(concat("AUTO_UPDATE_DIR: ",auto_update_dir)), row + 1,
   CALL print(concat("HI_ENCRYPT_FLAG: ",evaluate(cursys,"AIX",cnvtlower(hi_encrypt_flag),
     hf_auth_flag))), row + 1,
   CALL print(concat("HI_TRANSMIT_FLAG: ",evaluate(cursys,"AIX",cnvtlower(hi_transmit_flag),
     hf_auth_flag))),
   row + 1,
   CALL print(concat("HI_TARGET_ADDRESS: ",hi_target_address)), row + 1,
   CALL print(concat("HI_AUTH_FLAG: ",evaluate(cursys,"AIX",cnvtlower(hi_auth_flag),hf_auth_flag))),
   row + 1,
   CALL print(concat("HI_USER_NAME: ",hi_user_name)),
   row + 1,
   CALL print(concat("HI_PSWD: ",hi_pswd)), row + 1,
   CALL print(concat("HI_PASSIVE_STATE: ",evaluate(cursys,"AIX",cnvtlower(hi_passive_state),
     hf_auth_flag))), row + 1,
   CALL print(concat("HI_FTP_REMOTE_DIR: ",hi_ftp_remote_dir)),
   row + 1,
   CALL print(concat("HISTORIC_MAX_THREADS: ",historic_max_threads)), row + 1,
   CALL print(concat("CONTINUOUS_SHELL_DIR: ",continuous_shell_dir)), row + 1,
   CALL print(concat("EDW_RETRY: ",edw_retry)),
   row + 1,
   CALL print(concat("HF_RETRY: ",hf_retry)), row + 1,
   CALL print(concat("HI_RETRY: ",hi_retry)), row + 1,
   CALL print(concat("LOG_LEVEL: ",cnvtupper(log_level))),
   row + 1,
   CALL print(concat("HF_ORPHAN_REMOTE_DIR: ",hf_orphan_remote_dir)), row + 1,
   CALL print(concat("HI_ORPHAN_REMOTE_DIR: ",hi_orphan_remote_dir)), row + 1,
   CALL print(concat("MAX_THREADS: ",max_threads)),
   row + 1,
   CALL print(concat("DAILY_OVERCOMMIT: ",daily_overcommit)), row + 1,
   CALL print(concat("HEALTHEINTENT_IND: ",healtheintent_ind)), row + 1,
   CALL print(concat("HIST_SOLUTION: ",hist_solution)),
   row + 1,
   CALL print(concat("MANUAL_SOLUTION: ",manual_solution)), row + 1,
   CALL print(concat("USE_HF_FTP_CONFIG: ",use_hf_ftp_config)), row + 1,
   CALL print(concat("HF_USE_COMPRESSION: ",hf_use_compression)),
   row + 1,
   CALL print(concat("FTP_FLG: ",ftp_flg)), row + 1,
   CALL print(concat("BATCH_XFER_IND: ",batch_xfer_ind)), row + 1,
   CALL print(concat("EDW_BATCH_COMPRESSION: ",edw_batch_compression)),
   row + 1,
   CALL print(concat("EDW_ERROR_PARSE: ",edw_error_parse)), row + 1
  WITH check, noheading, nocounter,
   format = lfstream, maxcol = 1999, maxrow = 1
 ;end select
 SET script_version = "020 02/20/2020 MF025696"
END GO
