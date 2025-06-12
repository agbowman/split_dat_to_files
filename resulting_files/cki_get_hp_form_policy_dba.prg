CREATE PROGRAM cki_get_hp_form_policy:dba
 DECLARE getcodevaluebymeaning(code_set=i4(value),cdf_meaning=vc(value)) = f8
 SUBROUTINE getcodevaluebymeaning(code_set,cdf_meaning)
   DECLARE _code_set = i4 WITH noconstant(code_set), protect
   DECLARE _code_value = f8 WITH noconstant(0.0), protect
   DECLARE _cdf_meaning = c12 WITH noconstant, protect
   IF (((code_set=0) OR (size(trim(cdf_meaning,1),1)=0)) )
    RETURN(_code_value)
   ENDIF
   SET _cdf_meaning = fillstring(12," ")
   SET _cdf_meaning = cnvtupper(cdf_meaning)
   SET stat = uar_get_meaning_by_codeset(_code_set,_cdf_meaning,1,_code_value)
   IF (_code_value=0.0)
    SELECT INTO "nl:"
     c.code_value
     FROM code_value c
     WHERE c.code_set=_code_set
      AND c.cdf_meaning=_cdf_meaning
      AND c.active_ind=1
      AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     HEAD REPORT
      _code_value = c.code_value
     WITH nocounter
    ;end select
   ENDIF
   RETURN(_code_value)
 END ;Subroutine
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 health_plan_list[*]
      2 health_plan_id = f8
      2 formulary_identifier = c10
      2 non_formu_cvrg_flag = i2
      2 policy_unlisted_drug_flag = i2
      2 policy_generic_drug_flag = i2
      2 policy_brand_reimburse_flag = i2
      2 policy_brand_interchg_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE health_plan_alias_type_cd = f8 WITH constant(value(getcodevaluebymeaning(27121,"FORMULARY"))
  ), protect
 SET reply->status_data.status = "F"
#begin_script
 IF (size(request->health_plan_list,5)=0)
  CALL subevent_add("REQUEST","F","REQUEST","No items in health_plan_list")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  hpa.health_plan_id, io.formulary_identifier
  FROM (dummyt d1  WITH seq = value(size(request->health_plan_list,5))),
   health_plan_alias hpa,
   infoscan_org io
  PLAN (d1)
   JOIN (hpa
   WHERE (hpa.health_plan_id=request->health_plan_list[d1.seq].health_plan_id)
    AND hpa.plan_alias_type_cd=health_plan_alias_type_cd
    AND hpa.active_ind=1)
   JOIN (io
   WHERE io.infoscan_org_identifier=hpa.alias)
  ORDER BY d1.seq, hpa.health_plan_id
  HEAD REPORT
   hp_cnt = 0
  HEAD hpa.health_plan_id
   hp_cnt = (hp_cnt+ 1)
   IF (hp_cnt > size(reply->health_plan_list,5))
    stat = alterlist(reply->health_plan_list,(hp_cnt+ 10))
   ENDIF
   reply->health_plan_list[hp_cnt].health_plan_id = hpa.health_plan_id, reply->health_plan_list[
   hp_cnt].formulary_identifier = io.formulary_identifier, reply->health_plan_list[hp_cnt].
   non_formu_cvrg_flag = io.non_formu_cvrg_flag,
   reply->health_plan_list[hp_cnt].policy_unlisted_drug_flag = io.policy_unlisted_drug_flag, reply->
   health_plan_list[hp_cnt].policy_generic_drug_flag = io.policy_generic_drug_flag, reply->
   health_plan_list[hp_cnt].policy_brand_reimburse_flag = io.policy_brand_reimburse_flag,
   reply->health_plan_list[hp_cnt].policy_brand_interchg_flag = io.policy_brand_interchg_flag
  DETAIL
   row + 0
  FOOT REPORT
   stat = alterlist(reply->health_plan_list,hp_cnt)
  WITH nocounter
 ;end select
#exit_script
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  CALL subevent_add("SELECT","F","HEALTH_PLAN_ALIAS/INFOSCAN_ORG","Health Plan Information not found"
   )
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
