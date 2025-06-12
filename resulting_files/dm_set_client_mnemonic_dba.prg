CREATE PROGRAM dm_set_client_mnemonic:dba
 DECLARE dm_mnemonic = c10
 DECLARE rdm_errmsg = vc
 DECLARE rdm_errcode = i4
 SET width = 132
 SET message = window
 CALL clear(1,1)
 CALL text(8,5,"Please enter your Cerner client mnemonic.")
 CALL accept(8,47,"P(13);CU")
 SET message = nowindow
 IF (textlen(trim(curaccept,3)) > 10)
  SET dm_mnemonic = substring(1,10,trim(curaccept,3))
 ELSE
  SET dm_mnemonic = trim(curaccept,3)
 ENDIF
 SELECT INTO "nl:"
  d.info_domain
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="CLIENT MNEMONIC"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  UPDATE  FROM dm_info d
   SET d.info_char = dm_mnemonic, d.updt_dt_tm = cnvtdatetime(curdate,curtime)
   WHERE d.info_domain="DATA MANAGEMENT"
    AND d.info_name="CLIENT MNEMONIC"
  ;end update
 ELSE
  INSERT  FROM dm_info d
   (d.info_domain, d.info_name, d.info_char,
   d.updt_dt_tm)
   VALUES("DATA MANAGEMENT", "CLIENT MNEMONIC", dm_mnemonic,
   cnvtdatetime(curdate,curtime))
  ;end insert
 ENDIF
 SET rdm_errcode = error(rdm_errmsg,0)
 IF (rdm_errcode != 0)
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
#exit_script
END GO
