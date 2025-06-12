CREATE PROGRAM br_auto_multum_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_auto_multum_config.prg> script"
 DECLARE error_msg = c132 WITH public, noconstant(" ")
 DECLARE errcode = i4 WITH public, noconstant(0)
 INSERT  FROM br_auto_multum b,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  SET b.mmdc = requestin->list_0[d1.seq].mmdc, b.generic_name = requestin->list_0[d1.seq].
   generic_name, b.brand_name = requestin->list_0[d1.seq].brand_name,
   b.label_description = requestin->list_0[d1.seq].label_description, b.product_type = requestin->
   list_0[d1.seq].product_type, b.concentration_per_ml =
   IF ((requestin->list_0[d1.seq].concentration_per_ml > " ")) cnvtreal(requestin->list_0[d1.seq].
     concentration_per_ml)
   ELSE 0
   ENDIF
   ,
   b.concentration_unit = requestin->list_0[d1.seq].concentration_unit, b.concentration_unit_cki =
   requestin->list_0[d1.seq].concentration_unit_cki, b.strength =
   IF ((requestin->list_0[d1.seq].strength > " ")) cnvtreal(requestin->list_0[d1.seq].strength)
   ELSE 0
   ENDIF
   ,
   b.strength_unit = requestin->list_0[d1.seq].strength_unit, b.strength_unit_cki = requestin->
   list_0[d1.seq].strength_unit_cki, b.volume =
   IF ((requestin->list_0[d1.seq].volume > " ")) cnvtreal(requestin->list_0[d1.seq].volume)
   ELSE 0
   ENDIF
   ,
   b.volume_unit = requestin->list_0[d1.seq].volume_unit, b.volume_unit_cki = requestin->list_0[d1
   .seq].volume_unit_cki, b.dispense_qty =
   IF ((requestin->list_0[d1.seq].dispense_qty > " ")) cnvtreal(requestin->list_0[d1.seq].
     dispense_qty)
   ELSE 0
   ENDIF
   ,
   b.dispense_qty_unit = requestin->list_0[d1.seq].dispense_qty_unit, b.dispense_qty_unit_cki =
   requestin->list_0[d1.seq].dispense_qty_unit_cki, b.dc_display_days =
   IF ((requestin->list_0[d1.seq].dc_display_days > " ")) cnvtint(requestin->list_0[d1.seq].
     dc_display_days)
   ELSE 0
   ENDIF
   ,
   b.dc_inter_days =
   IF ((requestin->list_0[d1.seq].dc_inter_days > " ")) cnvtint(requestin->list_0[d1.seq].
     dc_inter_days)
   ELSE 0
   ENDIF
   , b.def_format =
   IF ((requestin->list_0[d1.seq].def_format > " ")) cnvtint(requestin->list_0[d1.seq].def_format)
   ELSE 0
   ENDIF
   , b.search_med =
   IF ((requestin->list_0[d1.seq].search_med > " ")) cnvtint(requestin->list_0[d1.seq].search_med)
   ELSE 0
   ENDIF
   ,
   b.search_intermit =
   IF ((requestin->list_0[d1.seq].search_intermit > " ")) cnvtint(requestin->list_0[d1.seq].
     search_intermit)
   ELSE 0
   ENDIF
   , b.search_cont =
   IF ((requestin->list_0[d1.seq].search_cont > " ")) cnvtint(requestin->list_0[d1.seq].search_cont)
   ELSE 0
   ENDIF
   , b.divisible_ind =
   IF ((requestin->list_0[d1.seq].divisible_ind > " ")) cnvtint(requestin->list_0[d1.seq].
     divisible_ind)
   ELSE 0
   ENDIF
   ,
   b.infinite_div_ind =
   IF ((requestin->list_0[d1.seq].infinite_div_ind > " ")) cnvtint(requestin->list_0[d1.seq].
     infinite_div_ind)
   ELSE 0
   ENDIF
   , b.minimum_dose_qty =
   IF ((requestin->list_0[d1.seq].minimum_dose_qty > " ")) cnvtreal(requestin->list_0[d1.seq].
     minimum_dose_qty)
   ELSE 0
   ENDIF
   , b.updt_cnt = 0,
   b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo
   ->updt_task,
   b.updt_applctx = reqinfo->updt_applctx
  PLAN (d1
   WHERE (requestin->list_0[d1.seq].mmdc > " "))
   JOIN (b)
  WITH nocounter
 ;end insert
 SET errcode = error(error_msg,0)
 IF (errcode != 0)
  SET readme_data->message = error_msg
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded.  Rows inserted into BR_AUTO_MULTUM."
#exit_script
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 CALL echorecord(readme_data)
END GO
