CREATE PROGRAM dm_import_abs_date:dba
 FREE SET dm_info_request
 RECORD dm_info_request(
   1 info_domain = vc
   1 info_name = vc
   1 info_char = vc
   1 info_number = f8
   1 info_long_id = f8
   1 info_date = dq8
 )
 SET dm_info_request->info_domain = "ABSOLUTE DATE"
 SET dm_info_request->info_name = requestin->list_0[1].table_name
 SET dm_info_request->info_char = requestin->list_0[1].column_name
 SET dm_info_request->info_number = 0
 SET dm_info_request->info_long_id = 0
 SET dm_info_request->info_date = cnvtdatetime(requestin->list_0[1].create_date)
 UPDATE  FROM dm_info di
  SET di.info_date = cnvtdatetime(dm_info_request->info_date), di.info_char = dm_info_request->
   info_char, di.info_number = dm_info_request->info_number,
   di.info_long_id = dm_info_request->info_long_id, di.updt_cnt = (di.updt_cnt+ 1), di.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   di.updt_applctx = 0, di.updt_id = 0, di.updt_task = 1610
  WHERE (di.info_domain=dm_info_request->info_domain)
   AND (di.info_name=dm_info_request->info_name)
   AND (di.info_char=dm_info_request->info_char)
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM dm_info di
   SET di.info_date = cnvtdatetime(dm_info_request->info_date), di.info_char = dm_info_request->
    info_char, di.info_number = dm_info_request->info_number,
    di.info_long_id = dm_info_request->info_long_id, di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    di.updt_applctx = 0, di.updt_id = 0, di.updt_task = 1610,
    di.info_domain = dm_info_request->info_domain, di.info_name = dm_info_request->info_name
   WITH nocounter
  ;end insert
 ENDIF
 FREE SET dm_info_request
 COMMIT
#end_prg
END GO
