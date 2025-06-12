CREATE PROGRAM dm_user_last_updt
 UPDATE  FROM dm_info
  SET info_domain = "DATA MANAGEMENT", info_name = "USERLASTUPDT", info_date = cnvtdatetime(curdate,
    curtime3),
   info_char = null, info_number = null, info_long_id = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_applctx = 0, updt_cnt = 0,
   updt_id = 0, updt_task = 0
  WHERE info_name="USERLASTUPDT"
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM dm_info
   SET info_domain = "DATA MANAGEMENT", info_name = "USERLASTUPDT", info_date = cnvtdatetime(curdate,
     curtime3),
    info_char = null, info_number = null, info_long_id = 0,
    updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_applctx = 0, updt_cnt = 0,
    updt_id = 0, updt_task = 0
   WITH nocounter
  ;end insert
 ENDIF
 COMMIT
END GO
