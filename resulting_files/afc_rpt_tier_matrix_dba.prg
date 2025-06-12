CREATE PROGRAM afc_rpt_tier_matrix:dba
 RECORD request(
   1 from_951392 = i2
   1 output_dist = c100
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
     2 fin_nbr = c40
     2 admit_type = c40
     2 organization_id = f8
     2 org_name = c100
     2 price_sched_id = f8
     2 price_sched_desc = vc
     2 cdm = c14
     2 cpt4 = c5
     2 icd9 = c5
     2 hold_susp = c8
     2 flat_disc = f8
     2 charge_point = c20
     2 interface_file = c8
     2 collection_priority = c8
     2 report_priority = c8
     2 add_on = c8
     2 service_res = c11
     2 patient_loc = c11
     2 ordering_loc = c11
     2 inst_finnbr = c20
     2 icd9_proc = c9
     2 catalog_cd = c10
     2 cost_center_cd = c10
     2 perf_loc = c11
     2 diag_reqd = c2
     2 phys_reqd = c2
     2 gl = c11
     2 hcpcs = c5
     2 revenue = c5
 )
 FREE SET reply
 RECORD reply(
   1 report_file_name = vc
 )
 DECLARE printer = vc WITH public, noconstant(fillstring(100," "))
 DECLARE prtr_name = vc WITH public, noconstant(fillstring(100," "))
 DECLARE file_name = vc WITH public, noconstant(fillstring(100," "))
 SET count1 = 0
 SET printer = fillstring(100," ")
 IF (validate(request->output_dist," ") != " ")
  SET printer = request->output_dist
  SET printer = trim(printer)
 ENDIF
 IF (trim(printer) != " ")
  SET prtr_name = printer
  EXECUTE cpm_create_file_name "afc", "dat"
  SET file_name = cpm_cfn_info->file_name_path
  SET reply->report_file_name = file_name
 ELSE
  SET prtr_name = "FILE"
  SET file_name = "MINE"
 ENDIF
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
   c.display
   FROM code_value c,
    (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="FIN CLASS"))
    JOIN (c
    WHERE (request->tier[d1.seq].tier_cell_value=c.code_value)
     AND c.active_ind=1)
   DETAIL
    request->tier[d1.seq].fin_nbr = c.display,
    CALL echo(request->tier[d1.seq].fin_nbr)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   c.display
   FROM code_value c,
    (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="VISITTYPE"))
    JOIN (c
    WHERE (request->tier[d1.seq].tier_cell_value=c.code_value)
     AND c.active_ind=1)
   DETAIL
    request->tier[d1.seq].admit_type = c.display,
    CALL echo(request->tier[d1.seq].admit_type)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   o.organization_id, o.org_name
   FROM organization o,
    (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="ORG"))
    JOIN (o
    WHERE (request->tier[d1.seq].tier_cell_value=o.organization_id)
     AND o.active_ind=1)
   DETAIL
    request->tier[d1.seq].org_name = o.org_name,
    CALL echo(request->tier[d1.seq].org_name)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   p.price_sched_id, p.price_sched_desc
   FROM price_sched p,
    (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="PRICESCHED"))
    JOIN (p
    WHERE (request->tier[d1.seq].tier_cell_value=p.price_sched_id)
     AND p.active_ind=1)
   DETAIL
    request->tier[d1.seq].price_sched_desc = p.price_sched_desc
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   c.display
   FROM code_value c,
    (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="CDM_SCHED"))
    JOIN (c
    WHERE (request->tier[d1.seq].tier_cell_value=c.code_value)
     AND c.active_ind=1)
   DETAIL
    request->tier[d1.seq].cdm = c.display
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   c.display
   FROM code_value c,
    (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="CPT4"))
    JOIN (c
    WHERE (request->tier[d1.seq].tier_cell_value=c.code_value)
     AND c.active_ind=1)
   DETAIL
    request->tier[d1.seq].cpt4 = c.display
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   c.display
   FROM code_value c,
    (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="HCPCS"))
    JOIN (c
    WHERE (request->tier[d1.seq].tier_cell_value=c.code_value)
     AND c.active_ind=1)
   DETAIL
    request->tier[d1.seq].hcpcs = c.display
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   c.display
   FROM code_value c,
    (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="REVENUE"))
    JOIN (c
    WHERE (request->tier[d1.seq].tier_cell_value=c.code_value)
     AND c.active_ind=1)
   DETAIL
    request->tier[d1.seq].revenue = c.display
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   c.display
   FROM code_value c,
    (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="GL"))
    JOIN (c
    WHERE (request->tier[d1.seq].tier_cell_value=c.code_value)
     AND c.active_ind=1)
   DETAIL
    request->tier[d1.seq].gl = c.display
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   c.display
   FROM code_value c,
    (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="PROCCODE"))
    JOIN (c
    WHERE (request->tier[d1.seq].tier_cell_value=c.code_value)
     AND c.active_ind=1)
   DETAIL
    request->tier[d1.seq].icd9 = c.display
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   c.display
   FROM code_value c,
    (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="HOLD_SUSP"))
    JOIN (c
    WHERE (request->tier[d1.seq].tier_cell_value=c.code_value)
     AND c.active_ind=1)
   DETAIL
    request->tier[d1.seq].hold_susp = c.display
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
   c.display
   FROM code_value c,
    (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="SERVICERES"))
    JOIN (c
    WHERE (c.code_value=request->tier[d1.seq].tier_cell_value)
     AND c.active_ind=1)
   DETAIL
    request->tier[d1.seq].service_res = c.display
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
   c.display
   FROM code_value c,
    (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="PAT LOC"))
    JOIN (c
    WHERE (c.code_value=request->tier[d1.seq].tier_cell_value)
     AND c.active_ind=1)
   DETAIL
    request->tier[d1.seq].patient_loc = c.display
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   c.display
   FROM code_value c,
    (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="PERF LOC"))
    JOIN (c
    WHERE (c.code_value=request->tier[d1.seq].tier_cell_value)
     AND c.active_ind=1)
   DETAIL
    request->tier[d1.seq].perf_loc = c.display
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   c.display
   FROM code_value c,
    (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="ORD LOC"))
    JOIN (c
    WHERE (c.code_value=request->tier[d1.seq].tier_cell_value)
     AND c.active_ind=1)
   DETAIL
    request->tier[d1.seq].ordering_loc = c.display
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   i.description
   FROM interface_file i,
    (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="INTERFACE"))
    JOIN (i
    WHERE (i.interface_file_id=request->tier[d1.seq].tier_cell_value)
     AND i.active_ind=1)
   DETAIL
    request->tier[d1.seq].interface_file = i.description
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   c.display
   FROM code_value c,
    (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="COL PRIORITY"))
    JOIN (c
    WHERE (c.code_value=request->tier[d1.seq].tier_cell_value)
     AND c.active_ind=1)
   DETAIL
    request->tier[d1.seq].collection_priority = c.display
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   c.display
   FROM code_value c,
    (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="RPT PRIORITY"))
    JOIN (c
    WHERE (c.code_value=request->tier[d1.seq].tier_cell_value)
     AND c.active_ind=1)
   DETAIL
    request->tier[d1.seq].report_priority = c.display
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   b.bill_item_id
   FROM bill_item b,
    (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="ADD ON"))
    JOIN (b
    WHERE (b.bill_item_id=request->tier[d1.seq].tier_cell_value)
     AND b.active_ind=1)
   DETAIL
    request->tier[d1.seq].add_on = b.ext_description
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   c.display
   FROM code_value c,
    (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="PROCCODE"))
    JOIN (c
    WHERE (c.code_value=request->tier[d1.seq].tier_cell_value)
     AND c.active_ind=1)
   DETAIL
    request->tier[d1.seq].icd9_proc = c.display
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   c.display
   FROM code_value c,
    (dummyt d1  WITH seq = value(request->tier_qual))
   PLAN (d1
    WHERE (request->tier[d1.seq].cdf_meaning2="CHARGE POINT"))
    JOIN (c
    WHERE (c.code_value=request->tier[d1.seq].tier_cell_value)
     AND c.active_ind=1)
   DETAIL
    request->tier[d1.seq].charge_point = c.display
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
 SELECT INTO "nl:"
  c.display
  FROM code_value c,
   (dummyt d1  WITH seq = value(request->tier_qual))
  PLAN (d1
   WHERE (request->tier[d1.seq].cdf_meaning2="ACTCODE"))
   JOIN (c
   WHERE (c.code_value=request->tier[d1.seq].tier_cell_value)
    AND c.active_ind=1)
  DETAIL
   request->tier[d1.seq].catalog_cd = c.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.display
  FROM code_value c,
   (dummyt d1  WITH seq = value(request->tier_qual))
  PLAN (d1
   WHERE (request->tier[d1.seq].cdf_meaning2="COSTCENTER"))
   JOIN (c
   WHERE (c.code_value=request->tier[d1.seq].tier_cell_value)
    AND c.active_ind=1)
  DETAIL
   request->tier[d1.seq].cost_center_cd = c.display
  WITH nocounter
 ;end select
 SELECT INTO value(file_name)
  t01_tier_group_cd = request->tier[d1.seq].tier_group_cd, t01_tier_beg_effective_dt_tm = request->
  tier[d1.seq].beg_effective_dt_tm, t01_tier_row_num = request->tier[d1.seq].tier_row_num
  FROM (dummyt d1  WITH seq = value(request->tier_qual))
  ORDER BY request->tier[d1.seq].tier_group_cd, request->tier[d1.seq].beg_effective_dt_tm, request->
   tier[d1.seq].tier_row_num,
   request->tier[d1.seq].end_effective_dt_tm
  HEAD REPORT
   line = fillstring(273,"="),
   CALL center("********** TIER MATRIX REPORT **********",0,275), col 174,
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
     col 0,
     CALL print(substring(1,10,request->tier[d1.seq].fin_nbr))
    OF "VISITTYPE":
     col 12,
     CALL print(substring(1,8,request->tier[d1.seq].admit_type))
    OF "ORG":
     col 26,
     CALL print(substring(1,20,request->tier[d1.seq].org_name))
    OF "ORD LOC":
     col 47,
     CALL print(substring(1,12,request->tier[d1.seq].ordering_loc))
    OF "PAT LOC":
     col 62,
     CALL print(substring(1,12,request->tier[d1.seq].patient_loc))
    OF "SERVICERES":
     col 74,
     CALL print(substring(1,12,request->tier[d1.seq].service_res))
    OF "RPT PRIORITY":
     col 86,
     CALL print(substring(1,9,request->tier[d1.seq].report_priority))
    OF "COL PRIORITY":
     col 94,
     CALL print(substring(1,9,request->tier[d1.seq].collection_priority))
    OF "PERF LOC":
     col 102,
     CALL print(substring(1,12,request->tier[d1.seq].perf_loc))
    OF "ACTCODE":
     col 114,
     CALL print(substring(1,15,request->tier[d1.seq].catalog_cd))
    OF "CHARGE POINT":
     col 132,
     CALL print(substring(1,14,request->tier[d1.seq].charge_point))
    OF "PRICESCHED":
     col 147,
     CALL print(substring(1,9,request->tier[d1.seq].price_sched_desc))
    OF "CDM_SCHED":
     col 157,
     CALL print(substring(1,9,request->tier[d1.seq].cdm))
    OF "CPT4":
     col 167,
     CALL print(substring(1,9,request->tier[d1.seq].cpt4))
    OF "PROCCODE":
     col 177,
     CALL print(substring(1,9,request->tier[d1.seq].icd9_proc))
    OF "HOLD_SUSP":
     col 187,
     CALL print(substring(1,7,request->tier[d1.seq].hold_susp))
    OF "GL":
     col 192,
     CALL print(substring(1,7,request->tier[d1.seq].gl))
    OF "DIAGREQD":
     col 207,request->tier[d1.seq].diag_reqd"####"
    OF "PHYSREQD":
     col 213,request->tier[d1.seq].phys_reqd"####"
    OF "FLAT_DISC":
     col 218,request->tier[d1.seq].flat_disc"##.##"
    OF "ADD ON":
     col 225,
     CALL print(substring(1,9,request->tier[d1.seq].add_on))
    OF "INTERFACE":
     col 235,
     CALL print(substring(1,9,request->tier[d1.seq].interface_file))
    OF "INSTFINNBR":
     col 245,
     CALL print(substring(1,9,request->tier[d1.seq].inst_finnbr))
    OF "COSTCENTER":
     col 254,
     CALL print(substring(1,5,request->tier[d1.seq].cost_center_cd))
    OF "HCPCS":
     col 259,
     CALL print(substring(1,5,request->tier[d1.seq].hcpcs))
    OF "REVENUE":
     col 265,
     CALL print(substring(1,5,request->tier[d1.seq].revenue))
   ENDCASE
   col 130, "*"
  WITH maxcol = 275
 ;end select
 IF (trim(printer) != " "
  AND validate(request->from_951392,0)=0)
  SET com = concat("print/que=",trim(prtr_name)," ",value(file_name))
  CALL dcl(com,size(trim(com)),0)
 ENDIF
 IF (validate(debug,0)=1)
  CALL echorecord(reply)
 ENDIF
END GO
