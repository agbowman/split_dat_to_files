CREATE PROGRAM charge_cmb_add_interface_flg:dba
 INSERT  FROM dm_info di
  SET di.info_domain = "CHARGE SERVICES", di.info_name = "COMBINE INTERFACE FLAG", di.info_number = 0,
   di.updt_cnt = 1, di.updt_applctx = 0, di.updt_task = 0,
   di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = 0
  WITH nocounter
 ;end insert
 COMMIT
END GO
