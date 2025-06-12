CREATE PROGRAM afc_upt_max_quant_pref:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Checking max quantity site preference."
 SET max_quant = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="MAX QUANTITY"
  DETAIL
   max_quant = di.info_number
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_data->message = "Adding a new max quant site preference row."
  INSERT  FROM dm_info di
   SET di.info_domain = "CHARGE SERVICES", di.info_name = "MAX QUANTITY", di.info_number = 999,
    di.updt_cnt = 1, di.updt_applctx = 0, di.updt_task = 0,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = 0
  ;end insert
 ELSE
  IF (max_quant=0)
   SET readme_data->message = "Updating max quantity site preference."
   UPDATE  FROM dm_info
    SET info_number = 999
    WHERE info_domain="CHARGE SERVICES"
     AND info_name="MAX QUANTITY"
   ;end update
   COMMIT
  ENDIF
 ENDIF
 SET max_quant = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="MAX QUANTITY"
  DETAIL
   max_quant = di.info_number
  WITH nocounter
 ;end select
 IF (max_quant > 0)
  SET readme_data->status = "S"
  SET readme_data->message = "Max quantity updated."
 ENDIF
 EXECUTE dm_readme_status
END GO
