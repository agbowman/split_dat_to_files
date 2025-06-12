CREATE PROGRAM aps_create_event_sets
 SET temp = fillstring(500," ")
 SET temp1 = fillstring(500," ")
 SET temp2 = fillstring(500," ")
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET ap_act_cd = 0.0
 SET ap_act_subtype_cd = 0.0
 SET code_set = 5801
 SET cdf_meaning = "APREPORT"
 EXECUTE cpm_get_cd_for_cdf
 SET ap_act_subtype_cd = code_value
 SET const_comma = ","
 SET const_quote = '"'
 SET const_s_quote = "'"
 SET const_zero = "0"
 SET msg_cnt = 1
 SET message[1] = fillstring(85," ")
 SET message[1] = "->  The APS_EVENT_SETS.CSV file has been created and placed within CCLUSERDIR:."
 RECORD temp_rec(
   1 qual[*]
     2 mnemonic = vc
     2 description = vc
     2 dta_qual[*]
       3 mnemonic = vc
   1 comp_qual[*]
     2 mnemonic = vc
 )
 SET max_qual_cnt = 0
 SET max_dta_cnt = 0
 SELECT INTO "nl:"
  oc.catalog_cd, dta.task_assay_cd
  FROM order_catalog oc,
   profile_task_r ptr,
   discrete_task_assay dta
  PLAN (oc
   WHERE oc.activity_subtype_cd=ap_act_subtype_cd
    AND oc.active_ind=1)
   JOIN (ptr
   WHERE oc.catalog_cd=ptr.catalog_cd
    AND ptr.active_ind=1
    AND cnvtdatetime(curdate,curtime3) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm)
   JOIN (dta
   WHERE ptr.task_assay_cd=dta.task_assay_cd
    AND dta.active_ind=1)
  ORDER BY oc.catalog_cd, ptr.sequence
  HEAD REPORT
   x = 0, stat = alterlist(temp_rec->qual,5)
  HEAD oc.catalog_cd
   x = (x+ 1)
   IF (mod(x,5)=1
    AND x != 1)
    stat = alterlist(temp_rec->qual,(x+ 4))
   ENDIF
   temp_rec->qual[x].mnemonic = oc.primary_mnemonic, temp_rec->qual[x].description = oc.description,
   y = 0,
   stat = alterlist(temp_rec->qual[x].dta_qual,5)
  DETAIL
   y = (y+ 1)
   IF (mod(y,5)=1
    AND y != 1)
    stat = alterlist(temp_rec->qual[x].dta_qual,(y+ 4))
   ENDIF
   IF (y > max_dta_cnt)
    max_dta_cnt = y
   ENDIF
   temp_rec->qual[x].dta_qual[y].mnemonic = dta.mnemonic
  FOOT  oc.catalog_cd
   stat = alterlist(temp_rec->qual[x].dta_qual,y)
  FOOT REPORT
   stat = alterlist(temp_rec->qual,x)
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  d1.seq, d2.seq
  FROM (dummyt d1  WITH seq = value(size(temp_rec->qual,5))),
   (dummyt d2  WITH seq = value(max_dta_cnt))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp_rec->qual[d1.seq].dta_qual,5))
  ORDER BY temp_rec->qual[d1.seq].dta_qual[d2.seq].mnemonic, 0
  HEAD REPORT
   x = 0, stat = alterlist(temp_rec->comp_qual,5)
  DETAIL
   x = (x+ 1)
   IF (mod(x,5)=1
    AND x != 1)
    stat = alterlist(temp_rec->comp_qual,(x+ 4))
   ENDIF
   temp_rec->comp_qual[x].mnemonic = temp_rec->qual[d1.seq].dta_qual[d2.seq].mnemonic
  FOOT REPORT
   stat = alterlist(temp_rec->comp_qual,x)
  WITH nocounter
 ;end select
 SELECT INTO "APS_EVENT_SETS.CSV"
  z = 0
  HEAD REPORT
   x = 0, y = 0, temp3 = "Event Set Name,Event Set Disp,Event Set Descr,Icon Name,Icon Color Name,",
   temp4 = "Accumulation Ind,Category Flag,Combine Format,Grouping Rule Flag,", temp6 =
   "Operation Display Flag,Operation Formula,Show If No Data Ind,", temp7 =
   "Child Set Name,Child Set Collating Seq,Child Set Expand Flag",
   temp5 = build(temp3,temp4,temp6,temp7), col 00, temp5,
   row + 1
  DETAIL
   FOR (x = 1 TO size(temp_rec->qual,5))
     IF (x=1)
      temp1 = build(const_quote,"PATH REPORT",const_quote,const_comma,const_quote,
       "Pathology Reports",const_quote,const_comma,const_quote,"Pathology Reports",
       const_quote,const_comma,const_comma,const_comma,const_zero,
       const_comma,const_zero,const_comma,const_comma,const_zero,
       const_comma,const_zero,const_comma,const_comma,const_zero,
       const_comma)
     ELSE
      temp1 = build(const_comma,const_comma,const_comma,const_comma,const_comma,
       const_comma,const_comma,const_comma,const_comma,const_comma,
       const_comma,const_comma)
     ENDIF
     temp2 = build(const_quote,substring(1,40,temp_rec->qual[x].mnemonic),const_quote,const_comma,x,
      const_comma,"Y"), temp = build(temp1,temp2), col 00,
     temp, row + 1
   ENDFOR
   max_qual_cnt = size(temp_rec->qual,5)
   FOR (x = 1 TO size(temp_rec->comp_qual,5))
     temp1 = build(const_comma,const_comma,const_comma,const_comma,const_comma,
      const_comma,const_comma,const_comma,const_comma,const_comma,
      const_comma,const_comma), temp2 = build(const_quote,substring(1,40,temp_rec->comp_qual[x].
       mnemonic),const_quote,const_comma,(max_qual_cnt+ x),
      const_comma,"Y"), temp = build(temp1,temp2),
     col 00, temp, row + 1
   ENDFOR
   FOR (x = 1 TO size(temp_rec->qual,5))
     temp1 = build(const_quote,substring(1,40,temp_rec->qual[x].mnemonic),const_quote,const_comma,
      const_quote,
      substring(1,40,temp_rec->qual[x].description),const_quote,const_comma,const_quote,substring(1,
       60,temp_rec->qual[x].description),
      const_quote,const_comma,const_comma,const_comma,const_comma,
      const_comma,const_comma,const_comma,const_comma,const_comma,
      const_comma,const_comma,const_comma), col 00, temp1,
     row + 1
   ENDFOR
   FOR (x = 1 TO size(temp_rec->comp_qual,5))
     temp1 = build(const_quote,substring(1,40,temp_rec->comp_qual[x].mnemonic),const_quote,
      const_comma,const_quote,
      substring(1,40,temp_rec->comp_qual[x].mnemonic),const_quote,const_comma,const_quote,substring(1,
       60,temp_rec->comp_qual[x].mnemonic),
      const_quote,const_comma,const_comma,const_comma,const_comma,
      const_comma,const_comma,const_comma,const_comma,const_comma,
      const_comma,const_comma,const_comma), col 00, temp1,
     row + 1
   ENDFOR
   FOR (x = 1 TO size(temp_rec->qual,5))
     IF (x=1)
      temp1 = build(const_quote,"PATH REPORT COMPONENTS",const_quote,const_comma,const_quote,
       "Pathology Report Components",const_quote,const_comma,const_quote,
       "Pathology Report Components",
       const_quote,const_comma,const_comma,const_comma,const_zero,
       const_comma,const_zero,const_comma,const_comma,const_zero,
       const_comma,const_zero,const_comma,const_comma,const_zero,
       const_comma)
     ELSE
      temp1 = build(const_comma,const_comma,const_comma,const_comma,const_comma,
       const_comma,const_comma,const_comma,const_comma,const_comma,
       const_comma,const_comma)
     ENDIF
     temp2 = build(const_quote,substring(1,29,temp_rec->qual[x].mnemonic)," Components",const_quote,
      const_comma,
      x,const_comma,"Y"), temp = build(temp1,temp2), col 00,
     temp, row + 1
   ENDFOR
   FOR (x = 1 TO size(temp_rec->qual,5))
     FOR (y = 1 TO size(temp_rec->qual[x].dta_qual,5))
       IF (y=1)
        temp1 = build(const_quote,substring(1,29,temp_rec->qual[x].mnemonic)," Components",
         const_quote,const_comma,
         const_quote,substring(1,40,temp_rec->qual[x].description),const_quote,const_comma,
         const_quote,
         substring(1,60,temp_rec->qual[x].description),const_quote,const_comma,const_comma,
         const_comma,
         const_zero,const_comma,const_zero,const_comma,const_comma,
         const_zero,const_comma,const_zero,const_comma,const_comma,
         const_zero,const_comma)
       ELSE
        temp1 = build(const_comma,const_comma,const_comma,const_comma,const_comma,
         const_comma,const_comma,const_comma,const_comma,const_comma,
         const_comma,const_comma)
       ENDIF
       temp2 = build(const_quote,substring(1,40,temp_rec->qual[x].dta_qual[y].mnemonic),const_quote,
        const_comma,y,
        const_comma,"Y"), temp = build(temp1,temp2), col 00,
       temp, row + 1
     ENDFOR
   ENDFOR
  WITH nocounter, maxrow = 1, maxcol = 501,
   noformfeed
 ;end select
 SELECT
  d.seq
  FROM (dummyt d  WITH seq = value(msg_cnt))
  DETAIL
   col 01, message[d.seq], row + 2
  WITH nocounter, noformfeed
 ;end select
END GO
