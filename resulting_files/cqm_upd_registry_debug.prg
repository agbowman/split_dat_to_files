CREATE PROGRAM cqm_upd_registry_debug
 UPDATE  FROM cqm_listener_registry r
  SET r.debug_ind = value( $3), r.updt_dt_tm = cnvtdatetime(sysdate)
  WHERE r.listener_id IN (
  (SELECT
   l.listener_id
   FROM cqm_listener_config l
   WHERE l.application_name=value( $1)
    AND l.listener_alias=value( $2)
   WITH nocounter))
  WITH nocounter
 ;end update
END GO
