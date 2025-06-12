CREATE PROGRAM dep_end_state_adjust
 SET windows_platform_cd = 1.0
 SET admin_env_id = 0.0
 SELECT INTO "nl:"
  r.info_number
  FROM dm_info r
  WHERE info_domain="DATA MANAGEMENT"
   AND info_name="DM_ENV_ID"
  DETAIL
   admin_env_id = r.info_number
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Unable to get environment ID from DM_INFO")
  GO TO enditnow
 ENDIF
 SET env_id = 0.0
 SELECT INTO "nl:"
  FROM dep_env_id_reltn eir
  WHERE eir.environment_id=admin_env_id
  DETAIL
   env_id = eir.dep_env_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Failure during SELECT from dep_env_id_reltn")
  GO TO enditnow
 ENDIF
 DELETE  FROM dep_end_state ez
  WHERE ez.end_state_id IN (
  (SELECT DISTINCT
   ea.end_state_id
   FROM dep_end_state ea,
    dep_end_state eb
   WHERE ea.dep_env_id=env_id
    AND eb.dep_env_id=env_id
    AND ea.platform_cd=windows_platform_cd
    AND eb.platform_cd=windows_platform_cd
    AND ea.current_ind=eb.current_ind
    AND cnvtlower(ea.end_state_name)=cnvtlower(eb.end_state_name)
    AND ea.end_state_id != eb.end_state_id
    AND ea.last_update_dt_tm < eb.last_update_dt_tm))
  WITH nocounter
 ;end delete
 CALL echo("Completed cleaning duplicate entries.")
 UPDATE  FROM dep_end_state des
  SET des.end_state_name = cnvtlower(des.end_state_name)
  WHERE des.dep_env_id=env_id
   AND des.platform_cd=windows_platform_cd
  WITH nocounter
 ;end update
 COMMIT
 CALL echo("Completed adjusting incorrect cased entries.")
#enditnow
END GO
