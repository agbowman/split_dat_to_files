CREATE PROGRAM bed_imp_rli_alias
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
 FREE SET alias_request
 RECORD alias_request(
   1 alias_list[*]
     2 supplier_flag = i2
     2 code_set = i4
     2 alias = vc
     2 code_value = f8
     2 display = vc
     2 cdf_meaning = vc
     2 action_flag = i4
     2 description = vc
     2 definition = vc
     2 unit_meaning = vc
 )
 FREE SET alias_reply
 RECORD alias_reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE error_msg = vc WITH private
 DECLARE error_flag = vc WITH private
 DECLARE numrows = i4
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET numrows = size(requestin->list_0,5)
 FOR (x = 1 TO numrows)
   SET stat = alterlist(alias_request->alias_list,x)
   SELECT INTO "nl:"
    FROM br_rli_supplier brs
    PLAN (brs
     WHERE brs.supplier_meaning=trim(requestin->list_0[1].supplier))
    DETAIL
     alias_request->alias_list[x].supplier_flag = brs.supplier_flag
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat(error_msg,"Invalid supplier code: ",requestin->list_0[1].supplier,
     "  Load program terminating.")
    GO TO exit_script
   ENDIF
   SET alias_request->alias_list[x].code_set = cnvtint(requestin->list_0[x].code_set)
   SET alias_request->alias_list[x].alias = requestin->list_0[x].alias
   SET alias_request->alias_list[x].code_value = cnvtreal(requestin->list_0[x].code_value)
   SET alias_request->alias_list[x].display = requestin->list_0[x].display
   SET alias_request->alias_list[x].cdf_meaning = requestin->list_0[x].cdf_meaning
   IF ((alias_request->alias_list[x].cdf_meaning=" "))
    SET alias_request->alias_list[x].cdf_meaning = null
   ENDIF
   SET alias_request->alias_list[x].action_flag = cnvtint(requestin->list_0[x].action_flag)
   SET alias_request->alias_list[x].description = requestin->list_0[x].description
   SET alias_request->alias_list[x].definition = requestin->list_0[x].definition
   SET alias_request->alias_list[x].unit_meaning = requestin->list_0[x].unit_meaning
 ENDFOR
 SET trace = recpersist
 EXECUTE bed_ens_rli_alias  WITH replace("REQUEST",alias_request), replace("REPLY",alias_reply)
 GO TO exit_script
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_RLI_ALIAS","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
