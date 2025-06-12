CREATE PROGRAM afc_get_tier_options_for_org:dba
 SET afc_get_tier_options_for_org_vrsn = "CHARGSRV-15373.001"
 RECORD reply(
   1 group_qual = i4
   1 group[*]
     2 tier_group_code = f8
     2 tier_group_disp = c40
     2 tier_group_desc = c60
     2 tier_group_mean = c12
     2 tier_group_updt = i4
     2 cell_qual = i4
     2 cell[*]
       3 tier_cell_id = f8
       3 tier_col_num = i4
       3 tier_row_num = i4
       3 tier_cell_type_cd = f8
       3 tier_cell_type_disp = c40
       3 tier_cell_type_desc = c60
       3 tier_cell_type_mean = c12
       3 tier_cell_value = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 active_ind = i4
       3 tier_cell_entity_name = c32
       3 tier_cell_string = c50
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD tiergroups(
   1 tiergroup[*]
     2 tier_group_cd = f8
 )
 SET reply->status_data.status = "F"
 DECLARE code_set = i4
 DECLARE code_value = f8
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 DECLARE g_price_sched_cd = f8
 DECLARE g_org_cd = f8
 DECLARE g_interface_cd = f8
 DECLARE g_flat_disc_cd = f8
 DECLARE g_diagreqd_cd = f8
 DECLARE g_physreqd_cd = f8
 DECLARE g_priceadjfactype_cd = f8
 SET code_set = 13036
 SET cdf_meaning = "PRICESCHED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,g_price_sched_cd)
 SET cdf_meaning = "ORG"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,g_org_cd)
 SET cdf_meaning = "INTERFACE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,g_interface_cd)
 SET cdf_meaning = "FLAT_DISC"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,g_flat_disc_cd)
 SET cdf_meaning = "DIAGREQD"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,g_diagreqd_cd)
 SET cdf_meaning = "PHYSREQD"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,g_physreqd_cd)
 SET cdf_meaning = "PRICEADJFAC"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,g_priceadjfactype_cd)
 SET count1 = 0
 SELECT INTO "nl:"
  FROM tier_matrix t
  WHERE t.tier_cell_type_cd=g_org_cd
   AND (t.tier_cell_value_id=request->organization_id)
   AND t.active_ind=1
  ORDER BY t.tier_group_cd
  HEAD t.tier_group_cd
   count1 += 1, stat = alterlist(tiergroups->tiergroup,count1), tiergroups->tiergroup[count1].
   tier_group_cd = t.tier_group_cd
  DETAIL
   null
  WITH nocounter
 ;end select
 CALL echorecord(tiergroups)
 SET count1 = 0
 SET count2 = 0
 IF (size(tiergroups->tiergroup,5) > 0)
  SELECT INTO "nl:"
   FROM tier_matrix t,
    (dummyt d  WITH seq = value(size(tiergroups->tiergroup,5)))
   PLAN (d)
    JOIN (t
    WHERE (t.tier_group_cd=tiergroups->tiergroup[d.seq].tier_group_cd)
     AND t.active_ind=1)
   ORDER BY t.tier_group_cd, cnvtdatetime(t.beg_effective_dt_tm), cnvtdatetime(t.end_effective_dt_tm),
    t.tier_row_num, t.tier_col_num
   HEAD t.tier_group_cd
    count1 += 1, stat = alterlist(reply->group,count1), reply->group[count1].tier_group_code = t
    .tier_group_cd,
    reply->group[count1].tier_group_mean = uar_get_code_meaning(t.tier_group_cd), reply->group[count1
    ].tier_group_disp = uar_get_code_display(t.tier_group_cd), reply->group[count1].tier_group_desc
     = uar_get_code_description(t.tier_group_cd),
    count2 = 0
   DETAIL
    IF (t.tier_cell_id > 0)
     count2 += 1, stat = alterlist(reply->group[count1].cell,count2), reply->group[count1].cell[
     count2].tier_cell_id = t.tier_cell_id,
     reply->group[count1].cell[count2].tier_col_num = t.tier_col_num, reply->group[count1].cell[
     count2].tier_row_num = t.tier_row_num, reply->group[count1].cell[count2].tier_cell_type_cd = t
     .tier_cell_type_cd,
     reply->group[count1].cell[count2].tier_cell_value =
     IF ((reply->group[count1].cell[count2].tier_cell_type_cd=g_price_sched_cd)) t.tier_cell_value_id
     ELSEIF ((reply->group[count1].cell[count2].tier_cell_type_cd=g_org_cd)) t.tier_cell_value_id
     ELSEIF ((reply->group[count1].cell[count2].tier_cell_type_cd=g_interface_cd)) t
      .tier_cell_value_id
     ELSEIF ((reply->group[count1].cell[count2].tier_cell_type_cd IN (g_flat_disc_cd,
     g_priceadjfactype_cd))) t.tier_cell_value
     ELSEIF ((reply->group[count1].cell[count2].tier_cell_type_cd=g_diagreqd_cd)) t.tier_cell_value
     ELSEIF ((reply->group[count1].cell[count2].tier_cell_type_cd=g_physreqd_cd)) t.tier_cell_value
     ELSE t.tier_cell_value_id
     ENDIF
     , reply->group[count1].cell[count2].tier_cell_string = t.tier_cell_string, reply->group[count1].
     cell[count2].beg_effective_dt_tm = cnvtdatetime(t.beg_effective_dt_tm),
     reply->group[count1].cell[count2].tier_cell_entity_name = t.tier_cell_entity_name
     IF ( NOT (t.end_effective_dt_tm BETWEEN cnvtdatetime("31-dec-2100 00:00:00.00") AND cnvtdatetime
     ("31-dec-2100 23:59:59.99")))
      reply->group[count1].cell[count2].end_effective_dt_tm = cnvtdatetime(t.end_effective_dt_tm)
     ENDIF
     reply->group[count1].cell[count2].active_ind = t.active_ind
    ENDIF
    reply->group[count1].cell_qual = count2
   WITH nocounter
  ;end select
 ENDIF
 IF (size(reply->group,5) > 0)
  SELECT INTO "nl:"
   FROM code_value cv,
    (dummyt d1  WITH seq = value(reply->group_qual))
   PLAN (d1)
    JOIN (cv
    WHERE (cv.code_value=reply->group[d1.seq].tier_group_code))
   DETAIL
    reply->group[d1.seq].tier_group_updt = cv.updt_cnt
   WITH nocounter
  ;end select
 ENDIF
 SET reply->group_qual = count1
 CALL echorecord(reply)
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "BILL_ITEM"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FREE SET tiergroups
END GO
