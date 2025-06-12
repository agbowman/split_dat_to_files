CREATE PROGRAM bed_imp_instr:dba
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
 SET nbr_instr = size(requestin->list_0,5)
 FOR (x = 1 TO nbr_instr)
  SELECT INTO "NL:"
   FROM br_instr b
   WHERE b.br_instr_id=cnvtreal(requestin->list_0[x].sequence)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SELECT INTO "NL:"
    j = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_org_id = cnvtreal(j)
    WITH format, counter
   ;end select
   INSERT  FROM br_instr b
    SET b.br_instr_id = cnvtreal(requestin->list_0[x].sequence), b.manufacturer = requestin->list_0[x
     ].supplier, b.model = requestin->list_0[x].model,
     b.type = requestin->list_0[x].type, b.point_of_care_ind =
     IF (cnvtupper(requestin->list_0[x].poc)="X") 1
     ELSE 0
     ENDIF
     , b.code_name = requestin->list_0[x].code_name,
     b.uni_ind =
     IF (cnvtupper(requestin->list_0[x].uni)="X") 1
     ELSE 0
     ENDIF
     , b.bi_ind =
     IF (cnvtupper(requestin->list_0[x].bi)="X") 1
     ELSE 0
     ENDIF
     , b.hq_ind =
     IF (cnvtupper(requestin->list_0[x].hq)="X") 1
     ELSE 0
     ENDIF
     ,
     b.multiplexor_ind =
     IF (cnvtupper(requestin->list_0[x].multiplexor)="X") 1
     ELSE 0
     ENDIF
     , b.robotics_ind =
     IF (cnvtupper(requestin->list_0[x].robotics)="X") 1
     ELSE 0
     ENDIF
     , b.prev_manufacturer = requestin->list_0[x].previous_supplier,
     b.activity_type_mean = requestin->list_0[x].activity_type, b.manufacturer_alias = requestin->
     list_0[x].supplier_alias, b.model_alias = requestin->list_0[x].model_alias,
     b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
     reqinfo->updt_task,
     b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert ",trim(requestin->list_0[x].sequence),
     " into the br_instr table.")
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
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_INSTR","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
