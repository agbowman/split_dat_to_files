CREATE PROGRAM dm_ocd_uninstall:dba
 RECORD reply(
   1 ops_event = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 EXECUTE FROM 2000_uninstall TO 2000_uninstall_exit
 GO TO 9999_exit_program
#1000_initialize
 SET u_ocd = cnvtint( $1)
 SET u_env_id = 0.0
 SELECT INTO "nl:"
  i.info_number
  FROM dm_info i
  WHERE i.info_domain="DATA MANAGEMENT"
   AND i.info_name="DM_ENV_ID"
   AND i.info_number > 0.0
  DETAIL
   u_env_id = i.info_number
  WITH nocounter
 ;end select
#1999_initialize_exit
#2000_uninstall
 DELETE  FROM dm_ocd_log l
  WHERE l.environment_id=u_env_id
   AND l.ocd=u_ocd
  WITH nocounter
 ;end delete
 IF (curqual)
  COMMIT
 ENDIF
 SET reply->status_data.status = "S"
#2000_uninstall_exit
#9999_exit_program
END GO
