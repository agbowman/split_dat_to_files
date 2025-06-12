CREATE PROGRAM cqm_upd_cconfig_debug
 UPDATE  FROM cqm_contributor_config c
  SET c.debug_ind = value( $3), c.updt_dt_tm = cnvtdatetime(sysdate)
  WHERE c.application_name=value( $1)
   AND c.contributor_alias=value( $2)
  WITH nocounter
 ;end update
END GO
