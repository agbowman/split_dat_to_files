CREATE PROGRAM afc_add_b_o_p
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE bill_perf_type_cd = f8
 DECLARE perfcode = i4
 SET code_set = 13031
 SET cdf_meaning = "BILLPERFORG"
 SET perfcode = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,perfcode,bill_perf_type_cd)
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE clientbill_cd = f8
 DECLARE clientcode = i4
 SET code_set = 13031
 SET cdf_meaning = "CLIENTBILL"
 SET clientcode = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,clientcode,clientbill_cd)
 CALL echo(concat("************CLIENT BILL: ",cnvtstring(clientbill_cd,17,2)))
 SET reply->status_data.status = "F"
 SET table_name = "BILL_ORG_PAYOR"
 CALL add_bill_org_payor(action_begin,action_end)
 CALL echo(build("Failed = ",failed))
 IF (failed != false)
  GO TO check_error
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF replace_error:
    SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   OF undelete_error:
    SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
   OF remove_error:
    SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
   OF attribute_error:
    SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
 GO TO end_program
 SUBROUTINE add_bill_org_payor(add_begin,add_end)
   FOR (x = add_begin TO add_end)
     SET active_code = 0.0
     IF ((request->bill_org_payor[x].active_status_cd=0))
      DECLARE code_set = i4
      DECLARE cdf_meaning = c12
      DECLARE active_code = f8
      DECLARE cnt1 = i4
      SET code_set = 48
      SET cdf_meaning = "ACTIVE"
      SET cnt1 = 1
      SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt1,active_code)
     ENDIF
     SET new_nbr = 0.0
     SELECT INTO "nl:"
      y = seq(price_sched_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_nbr = cnvtreal(y)
      WITH format, counter
     ;end select
     IF (curqual=0)
      SET failed = gen_nbr_error
      RETURN
     ELSE
      SET request->bill_org_payor[x].org_payor_id = new_nbr
     ENDIF
     CALL echo(build("Next new_nbr is: ",new_nbr))
     INSERT  FROM bill_org_payor b
      SET b.org_payor_id = new_nbr, b.organization_id =
       IF ((request->bill_org_payor[x].organization_id=0)) 0
       ELSE request->bill_org_payor[x].organization_id
       ENDIF
       , b.bill_org_type_cd =
       IF ((request->bill_org_payor[x].bill_org_type_cd=0)) 0
       ELSEIF ((request->bill_org_payor[x].bill_org_type_cd=bill_perf_type_cd)) bill_perf_type_cd
       ELSEIF ((request->bill_org_payor[x].bill_org_type_cd=clientbill_cd)) clientbill_cd
       ELSE request->bill_org_payor[x].bill_org_type_cd
       ENDIF
       ,
       b.bill_org_type_id =
       IF ((request->bill_org_payor[x].bill_org_type_id=0)) 0
       ELSE request->bill_org_payor[x].bill_org_type_id
       ENDIF
       , b.bill_org_type_ind =
       IF ((request->bill_org_payor[x].bill_org_type_ind=0)) 0
       ELSE request->bill_org_payor[x].bill_org_type_ind
       ENDIF
       , b.bill_org_type_string =
       IF ((request->bill_org_payor[x].bill_org_type_string=" ")) null
       ELSE request->bill_org_payor[x].bill_org_type_string
       ENDIF
       ,
       b.interface_file_cd =
       IF ((request->bill_org_payor[x].interface_file_cd=0)) 0
       ELSE request->bill_org_payor[x].interface_file_cd
       ENDIF
       , b.priority =
       IF ((request->bill_org_payor[x].priority=0)) 0
       ELSE request->bill_org_payor[x].priority
       ENDIF
       , b.beg_effective_dt_tm =
       IF ((request->bill_org_payor[x].beg_effective_dt_tm <= 0)) cnvtdatetime(sysdate)
       ELSE cnvtdatetime(request->bill_org_payor[x].beg_effective_dt_tm)
       ENDIF
       ,
       b.end_effective_dt_tm =
       IF ((request->bill_org_payor[x].end_effective_dt_tm <= 0)) cnvtdatetime("31-DEC-2100 00:00:00"
         )
       ELSE cnvtdatetime(request->bill_org_payor[x].end_effective_dt_tm)
       ENDIF
       , b.active_ind =
       IF ((request->bill_org_payor[x].active_ind=false)) true
       ELSE request->bill_org_payor[x].active_ind
       ENDIF
       , b.active_status_cd =
       IF ((request->bill_org_payor[x].active_status_cd=0)) active_code
       ELSE request->bill_org_payor[x].active_status_cd
       ENDIF
       ,
       b.active_status_prsnl_id =
       IF ((request->bill_org_payor[x].active_status_prsnl_id=0)) reqinfo->updt_id
       ELSE request->bill_org_payor[x].active_status_prsnl_id
       ENDIF
       , b.active_status_dt_tm =
       IF ((request->bill_org_payor[x].active_status_dt_tm <= 0)) cnvtdatetime(sysdate)
       ELSE cnvtdatetime(request->bill_org_payor[x].active_status_dt_tm)
       ENDIF
       , b.updt_cnt = 0,
       b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id, b.updt_applctx = reqinfo->
       updt_applctx,
       b.updt_task = reqinfo->updt_task, b.parent_entity_name =
       IF ((request->bill_org_payor[x].bill_org_type_cd=wl_standard_cd)) "WORKLOAD_STANDARD"
       ELSEIF ((request->bill_org_payor[x].bill_org_type_cd=bill_perf_type_cd)) "ORGANIZATION"
       ELSEIF ( $1) "CODE_VALUE"
       ELSE " "
       ENDIF
      WITH nocounter
     ;end insert
     CALL echo(build("Qual is : ",curqual))
     IF (curqual=0)
      SET failed = insert_error
      RETURN
     ELSE
      SET reply->bill_org_payor[x].org_payor_id = request->bill_org_payor[x].org_payor_id
     ENDIF
     CALL echo(build("Org payor id : ",reply->bill_org_payor[x].org_payor_id))
   ENDFOR
 END ;Subroutine
#end_program
 FREE SET tiergroup_cv
 FREE SET parent_entity
END GO
