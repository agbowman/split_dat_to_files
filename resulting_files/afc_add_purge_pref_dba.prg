CREATE PROGRAM afc_add_purge_pref:dba
 PAINT
 SET width = 132
 SET modify = system
 CALL clear(1,1)
 CALL video(n)
 CALL video(n)
 SET message = nowindow
 SET purge_run_mode = "R"
 CALL text(4,4,"What 'mode' do you wish to run the purge scripts in?")
 CALL accept(4,100,"A;cu","R"
  WHERE curaccept IN ("C", "R"))
 SET purge_run_mode = curaccept
 DELETE  FROM dm_info d
  WHERE d.info_domain="CHARGE SERVICES"
   AND d.info_name="CS PURGE RUN MODE"
 ;end delete
 INSERT  FROM dm_info d
  SET d.info_domain = "CHARGE SERVICES", d.info_name = "CS PURGE RUN MODE", d.info_date =
   cnvtdatetime(curdate,curtime3),
   d.info_char = purge_run_mode, d.info_number = 0, d.info_long_id = 0.0,
   d.updt_cnt = 0, d.updt_applctx = 0.0, d.updt_task = 0.0,
   d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = 13659
  WITH nocounter
 ;end insert
 COMMIT
END GO
