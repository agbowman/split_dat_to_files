CREATE PROGRAM dm_cmb_get_enc_alias:dba
 SET dcgea_reply->encntr_alias_id = 0.0
 SET dcgea_reply->alias = ""
 SET dcgea_reply->status = "S"
 CALL echo("dm_cmb_get_enc_alias")
 SELECT INTO "nl:"
  FROM encntr_alias ea
  WHERE (ea.encntr_id=dcgea_request->encntr_id)
   AND (ea.encntr_alias_type_cd=dcgea_request->alias_type_cd)
   AND ea.beg_effective_dt_tm <= cnvtdatetime(dcgea_request->alias_dt_tm)
   AND ea.end_effective_dt_tm >= cnvtdatetime(dcgea_request->alias_dt_tm)
   AND ((ea.active_ind=1) OR (ea.active_ind=0
   AND ea.active_status_dt_tm > cnvtdatetime(dcgea_request->alias_dt_tm)))
  ORDER BY ea.beg_effective_dt_tm
  DETAIL
   dcgea_reply->alias = ea.alias, dcgea_reply->encntr_alias_id = ea.encntr_alias_id
  WITH nocounter
 ;end select
 IF (error(dcgea_reply->err_msg,1) != 0)
  SET dcgea_reply->status = "F"
 ENDIF
 CALL echo("dm_cmb_get_enc_alias end")
END GO
