CREATE PROGRAM afc_get_price_schedule:dba
 DECLARE afc_get_price_schedule_version = vc WITH private, noconstant("268523.FT.008")
 FREE RECORD reply
 RECORD reply(
   1 price_sched_qual = i4
   1 price_desc_qual[*]
     2 price_sched_id = f8
     2 price_sched_desc = c200
     2 create_dt_tm = dq8
     2 create_prsnl_id = f8
     2 warning_dt_tm = dq8
     2 warning_prsnl_id = f8
     2 warning_type_cd = f8
     2 pharm_ind = i4
     2 formula_type_flg = i2
     2 markup_level_flg = i2
     2 apply_svc_fee_ind = i2
     2 cost_basis_cd = f8
     2 price_sched_short_desc = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 pharm_type_cd = f8
     2 range_type_cd = f8
     2 round_up = f8
     2 min_price = f8
     2 conversion_factor_cd = f8
     2 operating_margin_pct = f8
     2 compliance_check_ind = i2
     2 rounding_rate_flag = i2
     2 self_pay_ind = i2
     2 apply_markup_to_flag = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE RECORD sched_list
 RECORD sched_list(
   1 sched_qual = i2
   1 sched[*]
     2 price_sched_id = f8
 )
 DECLARE getpriceschedsecuritypreference(dummy=vc) = i2
 DECLARE initializeorgschedlist(dummy=vc) = i2
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 IF (getpriceschedsecuritypreference(null))
  CALL initializeorgschedlist(null)
 ENDIF
 CASE (request->select_type)
  OF "RNG":
   SELECT DISTINCT INTO "nl:"
    p.*, psi.*
    FROM price_sched_items psi,
     price_sched p
    PLAN (psi)
     JOIN (p
     WHERE p.price_sched_id=psi.price_sched_id)
    ORDER BY p.price_sched_desc, cnvtdate(psi.beg_effective_dt_tm), cnvtdate(psi.end_effective_dt_tm)
    DETAIL
     count1 = (count1+ 1), stat = alterlist(reply->price_desc_qual,count1), reply->price_desc_qual[
     count1].price_sched_id = p.price_sched_id,
     reply->price_desc_qual[count1].price_sched_desc = p.price_sched_desc, reply->price_desc_qual[
     count1].create_dt_tm = p.create_dt_tm, reply->price_desc_qual[count1].create_prsnl_id = p
     .create_prsnl_id,
     reply->price_desc_qual[count1].warning_dt_tm = p.warning_dt_tm, reply->price_desc_qual[count1].
     warning_prsnl_id = p.warning_prsnl_id, reply->price_desc_qual[count1].warning_type_cd = p
     .warning_type_cd,
     reply->price_desc_qual[count1].pharm_ind = p.pharm_ind, reply->price_desc_qual[count1].
     formula_type_flg = p.formula_type_flg, reply->price_desc_qual[count1].markup_level_flg = p
     .markup_level_flg,
     reply->price_desc_qual[count1].apply_svc_fee_ind = p.apply_svc_fee_ind, reply->price_desc_qual[
     count1].cost_basis_cd = p.cost_basis_cd, reply->price_desc_qual[count1].price_sched_short_desc
      = p.price_sched_short_desc,
     reply->price_desc_qual[count1].beg_effective_dt_tm = cnvtdatetime(psi.beg_effective_dt_tm),
     reply->price_desc_qual[count1].end_effective_dt_tm = cnvtdatetime(psi.end_effective_dt_tm),
     reply->price_desc_qual[count1].active_ind = p.active_ind,
     reply->price_desc_qual[count1].pharm_type_cd = p.pharm_type_cd, reply->price_desc_qual[count1].
     range_type_cd = p.range_type_cd, reply->price_desc_qual[count1].round_up = p.round_up,
     reply->price_desc_qual[count1].min_price = p.min_price, reply->price_desc_qual[count1].
     conversion_factor_cd = p.conversion_factor_cd, reply->price_desc_qual[count1].
     operating_margin_pct = p.operating_margin_pct,
     reply->price_desc_qual[count1].compliance_check_ind = p.compliance_check_ind, reply->
     price_desc_qual[count1].rounding_rate_flag = p.rounding_rate_flag, reply->price_desc_qual[count1
     ].self_pay_ind = p.self_pay_ind,
     reply->price_desc_qual[count1].apply_markup_to_flag = p.apply_markup_to_flag
    WITH nocounter
   ;end select
  OF "APS_ACTIVE":
   SELECT INTO "nl:"
    p.price_sched_id
    FROM price_sched p
    WHERE p.price_sched_id > 0
     AND p.active_ind=1
    ORDER BY p.price_sched_desc
    DETAIL
     count1 = (count1+ 1), stat = alterlist(reply->price_desc_qual,count1), reply->price_desc_qual[
     count1].price_sched_id = p.price_sched_id,
     reply->price_desc_qual[count1].price_sched_desc = p.price_sched_desc, reply->price_desc_qual[
     count1].pharm_ind = p.pharm_ind, reply->price_desc_qual[count1].formula_type_flg = p
     .formula_type_flg,
     reply->price_desc_qual[count1].markup_level_flg = p.markup_level_flg, reply->price_desc_qual[
     count1].apply_svc_fee_ind = p.apply_svc_fee_ind, reply->price_desc_qual[count1].cost_basis_cd =
     p.cost_basis_cd,
     reply->price_desc_qual[count1].price_sched_short_desc = p.price_sched_short_desc, reply->
     price_desc_qual[count1].beg_effective_dt_tm = p.beg_effective_dt_tm, reply->price_desc_qual[
     count1].end_effective_dt_tm = p.end_effective_dt_tm,
     reply->price_desc_qual[count1].active_ind = p.active_ind, reply->price_desc_qual[count1].
     pharm_type_cd = p.pharm_type_cd, reply->price_desc_qual[count1].range_type_cd = p.range_type_cd,
     reply->price_desc_qual[count1].round_up = p.round_up, reply->price_desc_qual[count1].min_price
      = p.min_price, reply->price_desc_qual[count1].conversion_factor_cd = p.conversion_factor_cd,
     reply->price_desc_qual[count1].operating_margin_pct = p.operating_margin_pct, reply->
     price_desc_qual[count1].compliance_check_ind = p.compliance_check_ind, reply->price_desc_qual[
     count1].rounding_rate_flag = p.rounding_rate_flag,
     reply->price_desc_qual[count1].self_pay_ind = p.self_pay_ind, reply->price_desc_qual[count1].
     apply_markup_to_flag = p.apply_markup_to_flag
    WITH nocounter
   ;end select
  OF "APS":
   SELECT INTO "nl:"
    p.price_sched_id
    FROM price_sched p
    WHERE p.price_sched_id > 0
    ORDER BY p.price_sched_desc
    DETAIL
     count1 = (count1+ 1), stat = alterlist(reply->price_desc_qual,count1), reply->price_desc_qual[
     count1].price_sched_id = p.price_sched_id,
     reply->price_desc_qual[count1].price_sched_desc = p.price_sched_desc, reply->price_desc_qual[
     count1].pharm_ind = p.pharm_ind, reply->price_desc_qual[count1].formula_type_flg = p
     .formula_type_flg,
     reply->price_desc_qual[count1].markup_level_flg = p.markup_level_flg, reply->price_desc_qual[
     count1].apply_svc_fee_ind = p.apply_svc_fee_ind, reply->price_desc_qual[count1].cost_basis_cd =
     p.cost_basis_cd,
     reply->price_desc_qual[count1].price_sched_short_desc = p.price_sched_short_desc, reply->
     price_desc_qual[count1].beg_effective_dt_tm = p.beg_effective_dt_tm, reply->price_desc_qual[
     count1].end_effective_dt_tm = p.end_effective_dt_tm,
     reply->price_desc_qual[count1].active_ind = p.active_ind, reply->price_desc_qual[count1].
     pharm_type_cd = p.pharm_type_cd, reply->price_desc_qual[count1].range_type_cd = p.range_type_cd,
     reply->price_desc_qual[count1].round_up = p.round_up, reply->price_desc_qual[count1].min_price
      = p.min_price, reply->price_desc_qual[count1].conversion_factor_cd = p.conversion_factor_cd,
     reply->price_desc_qual[count1].operating_margin_pct = p.operating_margin_pct, reply->
     price_desc_qual[count1].compliance_check_ind = p.compliance_check_ind, reply->price_desc_qual[
     count1].rounding_rate_flag = p.rounding_rate_flag,
     reply->price_desc_qual[count1].self_pay_ind = p.self_pay_ind, reply->price_desc_qual[count1].
     apply_markup_to_flag = p.apply_markup_to_flag
    WITH nocounter
   ;end select
  ELSE
   SELECT
    IF (size(sched_list->sched,5) > 0)
     FROM (dummyt d  WITH seq = value(size(sched_list->sched,5))),
      price_sched p
     PLAN (d)
      JOIN (p
      WHERE (p.price_sched_id=sched_list->sched[d.seq].price_sched_id)
       AND (p.pharm_ind=request->pharm_ind)
       AND p.active_ind=true)
    ELSE
     FROM price_sched p
     WHERE (p.pharm_ind=request->pharm_ind)
      AND p.price_sched_id > 0
    ENDIF
    INTO "nl:"
    ORDER BY p.price_sched_desc
    DETAIL
     count1 = (count1+ 1), stat = alterlist(reply->price_desc_qual,count1), reply->price_desc_qual[
     count1].price_sched_id = p.price_sched_id,
     reply->price_desc_qual[count1].price_sched_desc = p.price_sched_desc, reply->price_desc_qual[
     count1].create_dt_tm = p.create_dt_tm, reply->price_desc_qual[count1].create_prsnl_id = p
     .create_prsnl_id,
     reply->price_desc_qual[count1].warning_dt_tm = p.warning_dt_tm, reply->price_desc_qual[count1].
     warning_prsnl_id = p.warning_prsnl_id, reply->price_desc_qual[count1].warning_type_cd = p
     .warning_type_cd,
     reply->price_desc_qual[count1].pharm_ind = p.pharm_ind, reply->price_desc_qual[count1].
     formula_type_flg = p.formula_type_flg, reply->price_desc_qual[count1].markup_level_flg = p
     .markup_level_flg,
     reply->price_desc_qual[count1].apply_svc_fee_ind = p.apply_svc_fee_ind, reply->price_desc_qual[
     count1].cost_basis_cd = p.cost_basis_cd, reply->price_desc_qual[count1].price_sched_short_desc
      = p.price_sched_short_desc,
     reply->price_desc_qual[count1].beg_effective_dt_tm = p.beg_effective_dt_tm, reply->
     price_desc_qual[count1].end_effective_dt_tm = p.end_effective_dt_tm, reply->price_desc_qual[
     count1].active_ind = p.active_ind,
     reply->price_desc_qual[count1].pharm_type_cd = p.pharm_type_cd, reply->price_desc_qual[count1].
     range_type_cd = p.range_type_cd, reply->price_desc_qual[count1].round_up = p.round_up,
     reply->price_desc_qual[count1].min_price = p.min_price, reply->price_desc_qual[count1].
     conversion_factor_cd = p.conversion_factor_cd, reply->price_desc_qual[count1].
     operating_margin_pct = p.operating_margin_pct,
     reply->price_desc_qual[count1].compliance_check_ind = p.compliance_check_ind, reply->
     price_desc_qual[count1].rounding_rate_flag = p.rounding_rate_flag, reply->price_desc_qual[count1
     ].self_pay_ind = p.self_pay_ind,
     reply->price_desc_qual[count1].apply_markup_to_flag = p.apply_markup_to_flag
    WITH nocounter
   ;end select
 ENDCASE
 SET reply->price_sched_qual = count1
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Table"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PRICE_SCHED"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 GO TO end_program
 SUBROUTINE getpriceschedsecuritypreference(dummy)
   FREE RECORD afc_dm_request
   RECORD afc_dm_request(
     1 info_name_qual = i2
     1 info[*]
       2 info_name = vc
     1 info_name = vc
   )
   FREE RECORD afc_dm_reply
   RECORD afc_dm_reply(
     1 dm_info_qual = i2
     1 dm_info[*]
       2 info_name = vc
       2 info_date = dq8
       2 info_char = vc
       2 info_number = f8
       2 info_long_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c15
         3 operationstatus = c1
         3 targetobjectname = c15
         3 targetobjectvalue = vc
   )
   SET afc_dm_request->info_name_qual = 1
   SET stat = alterlist(afc_dm_request->info,1)
   SET afc_dm_request->info[1].info_name = "PRICE SCHED SECURITY"
   EXECUTE afc_get_dm_info  WITH replace("REQUEST",afc_dm_request), replace("REPLY",afc_dm_reply)
   IF ((afc_dm_reply->status_data.status="S"))
    IF (cnvtupper(afc_dm_reply->dm_info[1].info_char)="Y")
     RETURN(true)
    ELSE
     RETURN(false)
    ENDIF
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 SUBROUTINE initializeorgschedlist(dummy)
   DECLARE cs26078_price_sched_cd = f8 WITH noconstant(0.0)
   DECLARE icnt = i4
   SET stat = uar_get_meaning_by_codeset(26078,"PRICE_SCHED",1,cs26078_price_sched_cd)
   SELECT INTO "nl:"
    FROM prsnl p,
     prsnl_org_reltn por,
     cs_org_reltn cs
    PLAN (p
     WHERE (p.person_id=reqinfo->updt_id))
     JOIN (por
     WHERE por.person_id=p.person_id
      AND por.active_ind=true)
     JOIN (cs
     WHERE cs.organization_id=por.organization_id
      AND cs.cs_org_reltn_type_cd=cs26078_price_sched_cd
      AND cs.active_ind=1)
    ORDER BY cs.key1_id
    HEAD REPORT
     icnt = 0
    HEAD cs.key1_id
     icnt = (icnt+ 1), stat = alterlist(sched_list->sched,icnt), sched_list->sched[icnt].
     price_sched_id = cs.key1_id
    WITH nocounter
   ;end select
 END ;Subroutine
#end_program
 IF (validate(debug,- (1)) > 0)
  CALL echorecord(sched_list)
  CALL echorecord(reply)
 ENDIF
 FREE RECORD sched_list
END GO
