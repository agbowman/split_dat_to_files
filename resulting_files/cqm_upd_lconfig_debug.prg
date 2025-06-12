CREATE PROGRAM cqm_upd_lconfig_debug
 UPDATE  FROM cqm_listener_config l
  SET l.debug_ind = value( $3), l.updt_dt_tm = cnvtdatetime(sysdate)
  WHERE l.application_name=value( $1)
   AND l.listener_alias=value( $2)
  WITH nocounter
 ;end update
END GO
