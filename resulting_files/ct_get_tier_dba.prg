CREATE PROGRAM ct_get_tier:dba
 RECORD reply(
   1 tier_list = i4
   1 tier[*]
     2 ct_ruleset_tier_id = f8
     2 organization_id = f8
     2 org_name = vc
     2 health_plan_id = f8
     2 health_plan_name = vc
     2 fin_class_cd = f8
     2 fin_class_disp = c40
     2 fin_class_mean = c20
     2 fin_class_desc = c40
     2 encounter_type_cd = f8
     2 encounter_type_disp = c40
     2 encounter_type_mean = c20
     2 encounter_type_desc = c40
     2 ct_ruleset_cd = f8
     2 ct_ruleset_disp = c40
     2 ct_ruleset_mean = c20
     2 ct_ruleset_desc = c40
     2 end_effective_dt_tm = dq8
     2 beg_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
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
 SET cnt = 0
 SELECT INTO "nl:"
  FROM ct_ruleset_tier ct
  WHERE ct.active_ind=1
  ORDER BY ct.ct_ruleset_tier_id
  DETAIL
   cnt += 1, stat = alterlist(reply->tier,cnt), reply->tier[cnt].ct_ruleset_tier_id = ct
   .ct_ruleset_tier_id,
   reply->tier[cnt].organization_id = ct.organization_id, reply->tier[cnt].health_plan_id = ct
   .health_plan_id, reply->tier[cnt].fin_class_cd = ct.fin_class_cd,
   reply->tier[cnt].encounter_type_cd = ct.encntr_type_cd, reply->tier[cnt].ct_ruleset_cd = ct
   .ct_ruleset_cd, reply->tier[cnt].beg_effective_dt_tm = ct.beg_effective_dt_tm,
   reply->tier[cnt].end_effective_dt_tm = ct.end_effective_dt_tm
  WITH nocounter
 ;end select
 IF (cnt > 0)
  SELECT INTO "nl:"
   o.org_name
   FROM organization o,
    (dummyt d1  WITH seq = value(size(reply->tier,5)))
   PLAN (d1)
    JOIN (o
    WHERE (o.organization_id=reply->tier[d1.seq].organization_id))
   DETAIL
    reply->tier[d1.seq].org_name = o.org_name
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   o.health_plan_name
   FROM health_plan hp,
    (dummyt d1  WITH seq = value(size(reply->tier,5)))
   PLAN (d1)
    JOIN (hp
    WHERE (hp.health_plan_id=reply->tier[d1.seq].health_plan_id))
   DETAIL
    reply->tier[d1.seq].health_plan_name = hp.plan_name
   WITH nocounter
  ;end select
 ENDIF
 FOR (i = 1 TO cnt)
   CALL echo(build("count=",i))
   CALL echo(build("Oganization_id: ",reply->tier[i].organization_id))
   CALL echo(build("Ruleset_Tier_id: ",reply->tier[i].ct_ruleset_tier_id))
   CALL echo(build("Organization_name: ",reply->tier[i].org_name))
   CALL echo(build("Health_plan_name: ",reply->tier[i].health_plan_name))
 ENDFOR
 SET reply->tier_list = cnt
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CT_RULESET_TIER"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
