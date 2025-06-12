CREATE PROGRAM bed_imp_contractinfo:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET nbr_steps = size(requestin->list_0,5)
 SET hold_br_client_id = 0.0
 IF ((requestin->list_0[1].mnemonic > " "))
  SELECT INTO "nl:"
   FROM br_client bc
   PLAN (bc
    WHERE bc.client_mnemonic=trim(requestin->list_0[1].mnemonic))
   DETAIL
    hold_br_client_id = bc.br_client_id
   WITH nocounter, skipbedrock = 1
  ;end select
 ENDIF
 IF (hold_br_client_id=0)
  SET error_flag = "Y"
  SET error_msg = concat("Client not found on BR_CLIENT for mnemonic: ",trim(requestin->list_0[1].
    mnemonic))
  GO TO exit_script
 ENDIF
 DELETE  FROM br_client_item_reltn bcir
  PLAN (bcir
   WHERE bcir.br_client_id=hold_br_client_id
    AND bcir.item_type IN ("LICENSE", "SUBSCRT"))
  WITH nocounter, skipbedrock = 1
 ;end delete
 FOR (x = 1 TO nbr_steps)
   IF (trim(requestin->list_0[x].product) > " "
    AND trim(requestin->list_0[x].productid) > " "
    AND trim(requestin->list_0[x].businessmodel) IN ("LICENSE", "SUBSCRT"))
    INSERT  FROM br_client_item_reltn bcir
     SET bcir.br_client_item_reltn_id = seq(bedrock_seq,nextval), bcir.br_client_id =
      hold_br_client_id, bcir.item_type = trim(requestin->list_0[x].businessmodel),
      bcir.item_mean = trim(requestin->list_0[x].productid), bcir.item_display = trim(requestin->
       list_0[x].product), bcir.updt_dt_tm = cnvtdatetime(curdate,curtime),
      bcir.updt_id = 13
     WITH nocounter, skipbedrock = 1
    ;end insert
   ENDIF
 ENDFOR
 GO TO exit_script
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_CONTRACTSOFTWARE","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
