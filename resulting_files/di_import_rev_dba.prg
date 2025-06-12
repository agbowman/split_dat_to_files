CREATE PROGRAM di_import_rev:dba
 FREE SET input
 SET input =  $1
 SET wantlog = "N"
 SET message = noinformation
 EXECUTE eks_import
 CALL echo(concat("Creating request_processing table entries with ","EKS_BUILD_REQPROC"),2,0)
 FREE SET reqinfo
 RECORD reqinfo(
   1 commit_ind = i2
   1 updt_id = f8
   1 position_cd = f8
   1 updt_app = i4
   1 updt_task = i4
   1 updt_req = i4
   1 updt_applctx = i4
 )
 SET trace = recpersist
 EXECUTE eks_build_reqproc
 IF ((reqinfo->commit_ind=1))
  CALL echo("Committing request_processing changes.",2,0)
  COMMIT
 ELSE
  CALL echo("Rolling back request_processing changes.",2,0)
  ROLLBACK
 ENDIF
 SET trace = norecpersist
 FREE SET reqinfo
 EXECUTE di_event_log_ref_data
 IF (cursys != "AIX")
  SET message = nowindow
  CALL echo("")
  CALL echo("Be sure to do %E now to check the log for errors.")
 ENDIF
END GO
