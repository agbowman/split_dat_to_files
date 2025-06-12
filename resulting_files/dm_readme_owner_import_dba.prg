CREATE PROGRAM dm_readme_owner_import:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "f"
 CALL echo(cnvtstring(requestin->list_0[1].process_id))
 IF ((requestin->list_0[1].process_id=" "))
  CALL echo("Blank row detected")
  GO TO ext_prg
 ENDIF
 UPDATE  FROM dm_pkt_setup_process dsp
  SET dsp.owner_email = cnvtupper(substring(1,20,requestin->list_0[1].owner_id))
  WHERE cnvtreal(requestin->list_0[1].process_id)=dsp.process_id
  WITH nocounter
 ;end update
 SET reqinfo->commit_ind = 1
 SET reply->status_data.status = "S"
 COMMIT
#ext_prg
END GO
