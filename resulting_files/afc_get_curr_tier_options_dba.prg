CREATE PROGRAM afc_get_curr_tier_options:dba
 RECORD reply(
   1 cell_qual = i4
   1 cell[10]
     2 tier_cell_id = f8
     2 tier_col_num = i4
     2 tier_row_num = i4
     2 tier_cell_type_cd = f8
     2 tier_cell_type_disp = c40
     2 tier_cell_type_desc = c60
     2 tier_cell_type_mean = c12
     2 tier_cell_value = f8
     2 tier_cell_desc = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET tier_group_type = 0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=13031
   AND c.cdf_meaning="TIERGROUP"
  DETAIL
   tier_group_type = c.code_value
  WITH nocounter
 ;end select
 SET reply->status_data.status = "F"
 SET count2 = 0
 SET maxarray = 10
 SELECT INTO "nl:"
  c.code_value, c.display, c.cdf_meaning,
  c2.cdf_meaning, b.bill_org_type_id, b.bill_org_type_cd,
  b.organization_id, t.tier_cell_value, t.tier_group_cd,
  t.tier_cell_type_cd, t.tier_row_num, t.tier_col_num,
  t.tier_cell_id, p.price_sched_id, p.price_sched_desc
  FROM bill_org_payor b,
   tier_matrix t,
   price_sched p,
   code_value c,
   code_value c2,
   (dummyt d  WITH seq = 1)
  PLAN (b
   WHERE (b.organization_id=request->organization_id))
   JOIN (c2
   WHERE b.bill_org_type_cd=c2.code_value)
   JOIN (d)
   JOIN (((p
   WHERE b.bill_org_type_id=p.price_sched_id)
   ) ORJOIN ((((c
   WHERE b.bill_org_type_id=c.code_value)
   ) ORJOIN ((t
   WHERE b.bill_org_type_id=t.tier_cell_value
    AND t.beg_effective_dt_tm <= cnvtdatetime(request->check_date)
    AND ((t.end_effective_dt_tm >= cnvtdatetime(request->check_date)) OR (t.end_effective_dt_tm=null
   ))
    AND b.beg_effective_dt_tm <= cnvtdatetime(request->check_date)
    AND ((b.end_effective_dt_tm >= cnvtdatetime(request->check_date)) OR (b.end_effective_dt_tm=null
   )) )
   )) ))
  ORDER BY t.tier_row_num, t.tier_col_num
  DETAIL
   IF (t.tier_cell_id > 0)
    count2 = (count2+ 1)
    IF (count2 > maxarray)
     maxarray = (maxarray+ 5), stat = alter(reply->cell,maxarray)
    ENDIF
    reply->cell[count2].tier_cell_id = t.tier_cell_id, reply->cell[count2].tier_col_num = t
    .tier_col_num, reply->cell[count2].tier_row_num = t.tier_row_num,
    reply->cell[count2].tier_cell_type_cd = t.tier_cell_type_cd, reply->cell[count2].tier_cell_value
     = t.tier_cell_value
    CASE (c2.cdf_meaning)
     OF "FIN CLASS":
      reply->cell[count2].tier_cell_desc = c.display
     OF "VISITTYPE":
      reply->cell[count2].tier_cell_desc = c.display
     OF "PRICESCHED":
      reply->cell[count2].tier_cell_desc = p.price_sched_desc
     OF "CPT4":
      reply->cell[count2].tier_cell_desc = c.display
     OF "ICD9":
      reply->cell[count2].tier_cell_desc = c.display
     OF "SNMI95":
      reply->cell[count2].tier_cell_desc = c.display
     OF "CDM_SCHED":
      reply->cell[count2].tier_cell_desc = c.display
     OF "GL":
      reply->cell[count2].tier_cell_desc = c.display
     OF "HOLD_SUSP":
      reply->cell[count2].tier_cell_desc = c.display
     OF "FLAT_DISC":
      reply->cell[count2].tier_cell_desc = c.display
    ENDCASE
    reply->cell[count2].beg_effective_dt_tm = cnvtdatetime(t.beg_effective_dt_tm), reply->cell[count2
    ].end_effective_dt_tm = cnvtdatetime(t.end_effective_dt_tm), reply->cell[count2].active_ind = t
    .active_ind,
    reply->cell_qual = count2
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "BILL_ITEM"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
