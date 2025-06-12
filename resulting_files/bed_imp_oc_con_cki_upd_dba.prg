CREATE PROGRAM bed_imp_oc_con_cki_upd:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET catalog_code_value = 0.0
 SET numrows = size(requestin->list_0,5)
 FOR (x = 1 TO numrows)
   IF (cnvtupper(requestin->list_0[x].mnemonic_type)="PRIMARY")
    SET catalog_code_value = 0.0
    SELECT INTO "NL:"
     FROM br_auto_order_catalog o
     WHERE cnvtupper(o.primary_mnemonic)=cnvtupper(requestin->list_0[x].mnemonic)
      AND (((o.concept_cki != requestin->list_0[x].concept_cki)) OR (o.concept_cki=null))
     DETAIL
      catalog_code_value = o.catalog_cd
     WITH nocounter
    ;end select
    IF (curqual=1)
     UPDATE  FROM br_auto_order_catalog o
      SET o.concept_cki = requestin->list_0[x].concept_cki, o.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), o.updt_id = reqinfo->updt_id,
       o.updt_task = reqinfo->updt_task, o.updt_cnt = (o.updt_cnt+ 1), o.updt_applctx = reqinfo->
       updt_applctx
      WHERE o.catalog_cd=catalog_code_value
      WITH nocounter
     ;end update
    ENDIF
   ENDIF
 ENDFOR
 GO TO exit_script
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: bed_imp_oc_con_cki_upd","  >> ERROR MSG: ",
   error_msg)
 ENDIF
END GO
