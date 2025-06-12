CREATE PROGRAM afc_add_global_mode_pref:dba
 PAINT
 SET width = 132
 SET modify = system
 CALL clear(1,1)
 CALL video(n)
 CALL video(n)
 SET message = nowindow
 SET views_mode = "N"
 CALL text(4,4,"Can the user choose between Profit and default views?")
 CALL accept(4,100,"A;cu","N"
  WHERE curaccept IN ("Y", "N"))
 SET views_mode = curaccept
 DELETE  FROM dm_info d
  WHERE d.info_domain="CHARGE SERVICES"
   AND d.info_name="GLOBAL MODE PREF"
 ;end delete
 INSERT  FROM dm_info d
  SET d.info_domain = "CHARGE SERVICES", d.info_name = "GLOBAL MODE PREF", d.info_date = cnvtdatetime
   (curdate,curtime3),
   d.info_char = views_mode, d.info_number = 0, d.info_long_id = 0.0,
   d.updt_cnt = 1, d.updt_applctx = reqinfo->updt_applctx, d.updt_task = reqinfo->updt_task,
   d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->updt_id
  WITH nocounter
 ;end insert
 COMMIT
END GO
