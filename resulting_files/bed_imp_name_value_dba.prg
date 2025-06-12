CREATE PROGRAM bed_imp_name_value:dba
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
 SET nbr_value = size(requestin->list_0,5)
 FOR (x = 1 TO nbr_value)
  SELECT INTO "NL:"
   FROM br_name_value b
   WHERE cnvtupper(b.br_nv_key1)=cnvtupper(requestin->list_0[x].key1)
    AND cnvtupper(b.br_name)=cnvtupper(requestin->list_0[x].mean)
    AND cnvtupper(b.br_value)=cnvtupper(requestin->list_0[x].display)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET new_name_id = 0.0
   SELECT INTO "NL:"
    j = seq(bedrock_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_name_id = cnvtreal(j)
    WITH format, counter
   ;end select
   IF (((cnvtupper(requestin->list_0[x].mean)="EDWAITAREA") OR (cnvtupper(requestin->list_0[x].mean)=
   "EDCOAREA")) )
    SELECT INTO "NL:"
     FROM br_name_value b
     WHERE cnvtupper(b.br_nv_key1)=cnvtupper(requestin->list_0[x].mean)
     DETAIL
      requestin->list_0[x].mean = cnvtstring(b.br_name_value_id)
     WITH nocounter
    ;end select
   ENDIF
   INSERT  FROM br_name_value b
    SET b.br_name_value_id = new_name_id, b.br_nv_key1 = requestin->list_0[x].key1, b.br_name =
     requestin->list_0[x].mean,
     b.br_value = requestin->list_0[x].display, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b
     .updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert ",trim(requestin->list_0[x].display),
     " into the br_name_value table.")
    GO TO exit_script
   ENDIF
  ENDIF
 ENDFOR
 GO TO exit_script
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_NAME_VALUE","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
