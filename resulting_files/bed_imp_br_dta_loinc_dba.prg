CREATE PROGRAM bed_imp_br_dta_loinc:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 FOR (x = 1 TO size(requestin->list_0,5))
   SET ierrcode = 0
   SET failed = "N"
   SET loinc_id = 0.0
   SELECT INTO "nl:"
    y = seq(bedrock_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     loinc_id = cnvtreal(y)
    WITH format, counter
   ;end select
   INSERT  FROM br_dta_loinc bdl
    SET bdl.activity_type_txt = requestin->list_0[x].activity_type, bdl.br_dta_loinc_id = loinc_id,
     bdl.loinc_txt = requestin->list_0[x].loinc,
     bdl.long_dta_name = requestin->list_0[x].long_name, bdl.short_dta_name = requestin->list_0[x].
     short_name, bdl.source_identifier_name = requestin->list_0[x].source_identifier,
     bdl.specimen_type_txt = requestin->list_0[x].specimen_type, bdl.updt_applctx = reqinfo->
     updt_applctx, bdl.updt_cnt = 0,
     bdl.updt_dt_tm = cnvtdatetime(curdate,curtime3), bdl.updt_id = reqinfo->updt_id, bdl.updt_task
      = reqinfo->updt_task,
     bdl.wizard_mean_txt = requestin->list_0[x].wizard_mean
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
