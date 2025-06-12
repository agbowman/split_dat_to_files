CREATE PROGRAM afc_rpt_tier_matrix_id:dba
 FREE SET request
 RECORD request(
   1 tier_qual = i2
   1 tier[*]
     2 tier_cell_value = f8
     2 tier_cell_string = c50
     2 tier_group_cd = f8
     2 tier_cell_type_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 tier_col_num = i4
     2 tier_row_num = i4
     2 code_value = f8
     2 collation_seq = c12
     2 display = c40
     2 cdf_meaning = c12
     2 code_value2 = f8
     2 collation_seq2 = c12
     2 display2 = c40
     2 cdf_meaning2 = c12
     2 display3 = c40
     2 fin_class_cd = f8
     2 admit_type_cd = f8
     2 organization_id = f8
     2 price_sched_id = f8
     2 cdm_sched_cd = f8
     2 cpt4_sched_cd = f8
     2 icd9_sched_cd = f8
     2 hold_susp_cd = f8
     2 flat_disc = f8
     2 charge_point_cd = f8
     2 interface_file_id = f8
     2 collection_priority_cd = f8
     2 report_priority_cd = f8
     2 add_on_bi_id = f8
     2 service_res_cd = f8
     2 patient_loc_cd = f8
     2 ordering_loc_cd = f8
     2 inst_finnbr = c20
     2 icd9_proc_sched_cd = f8
     2 snomed = c8
     2 activity_type_cd = f8
     2 cost_center_cd = f8
     2 perf_loc_cd = f8
     2 diag_reqd = c2
     2 phys_reqd = c2
     2 gl_sched_cd = f8
     2 hcpcs = f8
     2 revenue = f8
 )
 SET count1 = 0
 SELECT INTO "nl:"
  t.*, c2.code_value, c2.display,
  c2.cdf_meaning, c2.collation_seq, c3.display
  FROM tier_matrix t,
   code_value c2,
   code_value c3
  PLAN (t
   WHERE t.active_ind=1
    AND t.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND t.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
   JOIN (c2
   WHERE t.tier_cell_type_cd=c2.code_value)
   JOIN (c3
   WHERE t.tier_group_cd=c3.code_value
    AND c3.active_ind=1)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(request->tier,count1), request->tier[count1].
   tier_cell_value = t.tier_cell_value_id,
   request->tier[count1].tier_cell_string = t.tier_cell_string, request->tier[count1].tier_group_cd
    = t.tier_group_cd, request->tier[count1].tier_cell_type_cd = t.tier_cell_type_cd,
   request->tier[count1].beg_effective_dt_tm = t.beg_effective_dt_tm, request->tier[count1].
   end_effective_dt_tm = t.end_effective_dt_tm, request->tier[count1].tier_col_num = t.tier_col_num,
   request->tier[count1].tier_row_num = t.tier_row_num, request->tier[count1].code_value2 = c2
   .code_value, request->tier[count1].cdf_meaning2 = c2.cdf_meaning,
   request->tier[count1].display2 = c2.display, request->tier[count1].display3 = c3.display
  WITH nocounter
 ;end select
 SET request->tier_qual = count1
 CALL echo(build("Tier Qual: ",request->tier_qual))
 IF ((request->tier_qual > 0))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="FIN CLASS"))
   DETAIL
    request->tier[d1.seq].fin_class_cd = request->tier[d1.seq].tier_cell_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="VISITTYPE"))
   DETAIL
    request->tier[d1.seq].admit_type_cd = request->tier[d1.seq].tier_cell_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="ORG"))
   DETAIL
    request->tier[d1.seq].organization_id = request->tier[d1.seq].tier_cell_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="ORD LOC"))
   DETAIL
    request->tier[d1.seq].ordering_loc_cd = request->tier[d1.seq].tier_cell_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="PERF LOC"))
   DETAIL
    request->tier[d1.seq].perf_loc_cd = request->tier[d1.seq].tier_cell_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="PAT LOC"))
   DETAIL
    request->tier[d1.seq].patient_loc_cd = request->tier[d1.seq].tier_cell_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="SERVICERES"))
   DETAIL
    request->tier[d1.seq].service_res_cd = request->tier[d1.seq].tier_cell_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="RPT PRIORITY"))
   DETAIL
    request->tier[d1.seq].report_priority_cd = request->tier[d1.seq].tier_cell_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="COL PRIORITY"))
   DETAIL
    request->tier[d1.seq].collection_priority_cd = request->tier[d1.seq].tier_cell_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="ACTCODE"))
   DETAIL
    request->tier[d1.seq].activity_type_cd = request->tier[d1.seq].tier_cell_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="CHARGE POINT"))
   DETAIL
    request->tier[d1.seq].charge_point_cd = request->tier[d1.seq].tier_cell_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="PRICESCHED"))
   DETAIL
    request->tier[d1.seq].price_sched_id = request->tier[d1.seq].tier_cell_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="CDM_SCHED"))
   DETAIL
    request->tier[d1.seq].cdm_sched_cd = request->tier[d1.seq].tier_cell_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="HCPCS"))
   DETAIL
    request->tier[d1.seq].hcpcs = request->tier[d1.seq].tier_cell_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="REVENUE"))
   DETAIL
    request->tier[d1.seq].revenue = request->tier[d1.seq].tier_cell_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="CPT4"))
   DETAIL
    request->tier[d1.seq].cpt4_sched_cd = request->tier[d1.seq].tier_cell_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="PROCCODE"))
   DETAIL
    request->tier[d1.seq].icd9_proc_sched_cd = request->tier[d1.seq].tier_cell_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="HOLD_SUSP"))
   DETAIL
    request->tier[d1.seq].hold_susp_cd = request->tier[d1.seq].tier_cell_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="GL"))
   DETAIL
    request->tier[d1.seq].gl_sched_cd = request->tier[d1.seq].tier_cell_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="ADD ON"))
   DETAIL
    request->tier[d1.seq].add_on_bi_id = request->tier[d1.seq].tier_cell_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="INTERFACE"))
   DETAIL
    request->tier[d1.seq].interface_file_id = request->tier[d1.seq].tier_cell_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="COSTCENTER"))
   DETAIL
    request->tier[d1.seq].cost_center_cd = request->tier[d1.seq].tier_cell_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="FLAT_DISC"))
   DETAIL
    request->tier[d1.seq].flat_disc = request->tier[d1.seq].tier_cell_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="DIAGREQD"))
   DETAIL
    IF ((request->tier[d1.seq].tier_cell_value=0))
     request->tier[d1.seq].diag_reqd = "Y"
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="PHYSREQD"))
   DETAIL
    IF ((request->tier[d1.seq].tier_cell_value=0))
     request->tier[d1.seq].phys_reqd = "Y"
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="INSTFINNBR"))
   DETAIL
    request->tier[d1.seq].inst_finnbr = request->tier[d1.seq].tier_cell_string
   WITH nocounter
  ;end select
 ENDIF
 SET outfile = "MINE"
 SELECT INTO value(outfile)
  t01_tier_group_cd = request->tier[d1.seq].tier_group_cd, t01_tier_beg_effective_dt_tm = request->
  tier[d1.seq].beg_effective_dt_tm, t01_tier_row_num = request->tier[d1.seq].tier_row_num
  FROM (dummyt d1  WITH seq = value(request->tier_qual))
  ORDER BY request->tier[d1.seq].tier_group_cd, request->tier[d1.seq].beg_effective_dt_tm, request->
   tier[d1.seq].tier_row_num,
   request->tier[d1.seq].end_effective_dt_tm
  HEAD REPORT
   line = fillstring(273,"="),
   CALL center("* * * * * * * * * * T I E R  M A T R I X  I D ' s  R E P O R T  * * * * * * * * * * ",
   0,275), col 174,
   curdate"MM/DD/YYYY;;D", col 190, curtime"HH:MM;;M",
   pagecnt = 0, row + 1
  HEAD t01_tier_group_cd
   last_col = 0, last_row = 0, row + 2,
   col 0, "Tier Group : ", col + 1,
   request->tier[d1.seq].display3, pagecnt = (pagecnt+ 1), col 190,
   "PAGE:", col 197, pagecnt"###"
  HEAD t01_tier_beg_effective_dt_tm
   row + 1, col 0, "From ",
   col 5, request->tier[d1.seq].beg_effective_dt_tm"MM/DD/YYYY;;D", col 16,
   "To ", col 19, request->tier[d1.seq].end_effective_dt_tm"MM/DD/YYYY;;D",
   row + 1, line, row + 1,
   col 02, "FIN", col 12,
   "ADMIT", col 47, "ORD",
   col 62, "PAT", col 74,
   "SVC", col 86, "REPORT",
   col 94, "COLLECT", col 102,
   "PERF", col 114, "ACTIVITY",
   col 130, "*", col 132,
   "CHARGE", col 147, "PRICE",
   col 157, "CDM", col 167,
   "CPT4", col 177, "ICD9",
   col 187, "HOLD", col 207,
   "DIAG", col 213, "PHYS",
   col 218, "FLAT", col 225,
   "ADDON", col 245, "INST",
   col 254, "COST", col 259,
   "HCPCS", col 265, "REVENUE",
   row + 1, col 02, "CLASS",
   col 12, "TYPE", col 26,
   "ORGANIZATION", col 47, "LOC",
   col 62, "LOC", col 74,
   "RES", col 86, "PRIOR",
   col 94, "PRIOR", col 102,
   "LOC", col 114, "TYPE",
   col 130, "*", col 132,
   "PROCESS", col 147, "SCHED",
   col 157, "SCHED", col 167,
   "SCHED", col 177, "PROC",
   col 187, "SUSP", col 197,
   "GL", col 207, "CHK",
   col 213, "CHK", col 218,
   "DISC", col 225, "BILLITEM",
   col 235, "INTERFACE", col 245,
   "FIN", col 253, "CENTER",
   row + 1, line
  HEAD t01_tier_row_num
   row + 1
  DETAIL
   CASE (request->tier[d1.seq].cdf_meaning2)
    OF "FIN CLASS":
     col 0,request->tier[d1.seq].fin_class_cd"##########"
    OF "VISITTYPE":
     col 12,request->tier[d1.seq].admit_type_cd"##########"
    OF "ORG":
     col 26,request->tier[d1.seq].organization_id"##########"
    OF "ORD LOC":
     col 47,request->tier[d1.seq].ordering_loc_cd"##########"
    OF "PAT LOC":
     col 62,request->tier[d1.seq].patient_loc_cd"##########"
    OF "SERVICERES":
     col 74,request->tier[d1.seq].service_res_cd"##########"
    OF "RPT PRIORITY":
     col 86,request->tier[d1.seq].report_priority_cd"########"
    OF "COL PRIORITY":
     col 94,request->tier[d1.seq].collection_priority_cd"########"
    OF "PERF LOC":
     col 102,request->tier[d1.seq].perf_loc_cd"##########"
    OF "ACTCODE":
     col 114,request->tier[d1.seq].activity_type_cd"##########"
    OF "CHARGE POINT":
     col 132,request->tier[d1.seq].charge_point_cd"##########"
    OF "PRICESCHED":
     col 147,request->tier[d1.seq].price_sched_id"#######"
    OF "CDM_SCHED":
     col 157,request->tier[d1.seq].cdm_sched_cd"#######"
    OF "CPT4":
     col 167,request->tier[d1.seq].cpt4_sched_cd"#######"
    OF "PROCCODE":
     col 177,request->tier[d1.seq].icd9_proc_sched_cd"#######"
    OF "HOLD_SUSP":
     col 187,request->tier[d1.seq].hold_susp_cd"#######"
    OF "GL":
     col 192,request->tier[d1.seq].gl_sched_cd"#######"
    OF "DIAGREQD":
     col 207,request->tier[d1.seq].diag_reqd"####"
    OF "PHYSREQD":
     col 213,request->tier[d1.seq].phys_reqd"####"
    OF "FLAT_DISC":
     col 218,request->tier[d1.seq].flat_disc"##.##"
    OF "ADD ON":
     col 225,request->tier[d1.seq].add_on_bi_id"##########"
    OF "INTERFACE":
     col 235,request->tier[d1.seq].interface_file_id"#########"
    OF "INSTFINNBR":
     col 245,
     CALL print(substring(1,10,request->tier[d1.seq].inst_finnbr))
    OF "COSTCENTER":
     col 253,request->tier[d1.seq].cost_center_cd"######"
    OF "HCPCS":
     col 259,request->tier[d1.seq].hcpcs"######"
    OF "REVENUE":
     col 265,request->tier[d1.seq].revenue"######"
   ENDCASE
   col 130, "*"
  WITH maxcol = 275
 ;end select
END GO
