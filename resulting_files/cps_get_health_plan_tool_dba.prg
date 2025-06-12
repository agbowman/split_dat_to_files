CREATE PROGRAM cps_get_health_plan_tool:dba
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
   1 hp_qual = i4
   1 health_plan[*]
     2 health_plan_id = f8
     2 plan_desc = c200
     2 person_plan_r_cd = f8
     2 person_plan_r_disp = c20
     2 organization_id = f8
     2 organization_name = vc
     2 deduct_amt = f8
     2 deduct_met_amt = f8
     2 deduct_met_dt_tm = dq8
     2 priority_seq = i4
     2 copay = f8
     2 person_org_reltn_id = f8
     2 carrier = vc
   1 status_data
     2 status = c1
     2 subeventstatus[2]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET failed = false
 SET reply->status_data.status = "F"
 SET knt = 0
 SELECT INTO "NL:"
  p.person_id, hp.health_plan_id, o.organization_id
  FROM person_plan_reltn p,
   health_plan hp,
   organization o
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (hp
   WHERE hp.health_plan_id=p.health_plan_id)
   JOIN (o
   WHERE o.organization_id=p.organization_id)
  HEAD REPORT
   knt = 0, stat = alterlist(reply->health_plan,10)
  DETAIL
   knt += 1
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->health_plan,(knt+ 9))
   ENDIF
   reply->health_plan[knt].person_plan_r_cd = p.person_plan_r_cd, reply->health_plan[knt].
   priority_seq = p.priority_seq, reply->health_plan[knt].person_org_reltn_id = p.person_org_reltn_id,
   reply->health_plan[knt].organization_id = p.organization_id, reply->health_plan[knt].
   organization_name = o.org_name, reply->health_plan[knt].health_plan_id = p.health_plan_id,
   reply->health_plan[knt].plan_desc = hp.plan_desc
  FOOT REPORT
   reply->hp_qual = knt, stat = alterlist(reply->health_plan,knt)
  WITH nocounter
 ;end select
 IF (curqual < 0)
  SET failed = select_error
  GO TO error_check
 ELSEIF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 GO TO error_check
#error_check
 IF (failed=false)
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF select_error:
    SET reply->status_data.subeventstatus[1].operationname = "GET"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
  SET reply->status_data.subeventstatus[2].targetobjectname = "CCL_ERROR"
  SET ierrcode = error(serrmsg,0)
  SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
 ENDIF
 GO TO end_program
#end_program
 SET pco_script_version = "003 10/03/02 SF3151"
END GO
