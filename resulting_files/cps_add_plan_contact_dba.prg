CREATE PROGRAM cps_add_plan_contact:dba
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
 RECORD reply(
   1 plan_contact_qual = i4
   1 plan_contact[*]
     2 plan_contact_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET action_begin = 1
 SET action_end = request->plan_contact_qual
 SET reply->plan_contact_qual = request->plan_contact_qual
 SET reply->status_data.status = "F"
 SET table_name = "PLAN_CONTACT"
 CALL add_plan_contact(action_begin,action_end)
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
 SUBROUTINE add_plan_contact(add_begin,add_end)
   FOR (x = add_begin TO add_end)
     SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
     SET active_code = 0.0
     IF ((request->plan_contact[x].active_status_cd=0))
      SET stat = uar_get_meaning_by_codeset(48,"ACTIVE",1,active_code)
     ENDIF
     SET new_nbr = 0.0
     SELECT INTO "nl:"
      y = seq(health_plan_seq,nextval)
      FROM dual
      DETAIL
       new_nbr = cnvtreal(y)
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET failed = gen_nbr_error
      RETURN
     ELSE
      SET request->plan_contact[x].plan_contact_id = new_nbr
     ENDIF
     INSERT  FROM plan_contact p
      SET p.plan_contact_id = new_nbr, p.health_plan_id =
       IF ((request->plan_contact[x].health_plan_id <= 0)) 0
       ELSE request->plan_contact[x].health_plan_id
       ENDIF
       , p.name_last =
       IF ((request->plan_contact[x].name_last='""')) null
       ELSE request->plan_contact[x].name_last
       ENDIF
       ,
       p.name_first =
       IF ((request->plan_contact[x].name_first='""')) null
       ELSE request->plan_contact[x].name_first
       ENDIF
       , p.name_middle =
       IF ((request->plan_contact[x].name_middle='""')) null
       ELSE request->plan_contact[x].name_middle
       ENDIF
       , p.title =
       IF ((request->plan_contact[x].title='""')) null
       ELSE request->plan_contact[x].title
       ENDIF
       ,
       p.person_ind =
       IF ((request->plan_contact[x].person_ind=false)) 0
       ELSE request->plan_contact[x].person_ind
       ENDIF
       , p.parent_contact_id =
       IF ((request->plan_contact[x].parent_contact_id <= 0)) 0
       ELSE request->plan_contact[x].parent_contact_id
       ENDIF
       , p.tier =
       IF ((request->plan_contact[x].tier=0)) null
       ELSE request->plan_contact[x].tier
       ENDIF
       ,
       p.display_order =
       IF ((request->plan_contact[x].display_order=0)) null
       ELSE request->plan_contact[x].display_order
       ENDIF
       , p.carrier_id =
       IF ((request->plan_contact[x].carrier_id <= 0)) 0
       ELSE request->plan_contact[x].carrier_id
       ENDIF
       , p.person_id =
       IF ((request->plan_contact[x].person_id <= 0)) 0
       ELSE request->plan_contact[x].person_id
       ENDIF
       ,
       p.beg_effective_dt_tm =
       IF ((request->plan_contact[x].beg_effective_dt_tm <= 0)) cnvtdatetime(sysdate)
       ELSE cnvtdatetime(request->plan_contact[x].beg_effective_dt_tm)
       ENDIF
       , p.end_effective_dt_tm =
       IF ((request->plan_contact[x].end_effective_dt_tm <= 0)) cnvtdatetime(
         "31-DEC-2100 00:00:00.00")
       ELSE cnvtdatetime(request->plan_contact[x].end_effective_dt_tm)
       ENDIF
       , p.active_ind =
       IF ((request->plan_contact[x].active_ind_ind=false)) 1
       ELSE request->plan_contact[x].active_ind
       ENDIF
       ,
       p.active_status_cd =
       IF ((request->plan_contact[x].active_status_cd=0)) active_code
       ELSE request->plan_contact[x].active_status_cd
       ENDIF
       , p.active_status_prsnl_id = reqinfo->updt_id, p.active_status_dt_tm = cnvtdatetime(sysdate),
       p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_id = reqinfo->updt_id,
       p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = insert_error
      RETURN
     ELSE
      SET reply->plan_contact[x].plan_contact_id = request->plan_contact[x].plan_contact_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
