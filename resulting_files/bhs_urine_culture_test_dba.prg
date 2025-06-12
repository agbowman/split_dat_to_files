CREATE PROGRAM bhs_urine_culture_test:dba
 FREE RECORD m_rec
 RECORD m_rec(
   1 list_cnt = i4
   1 list[*]
     2 person_id = f8
     2 person_name = vc
     2 person_dob = vc
     2 acct_nbr = vc
     2 ordered_by_nicora = c1
     2 ordered_by_reymond = c1
     2 ordered_by_grimes = c1
     2 ordered_by_perry = c1
     2 order_name = vc
     2 order_dt = vc
 )
 DECLARE rec_pos = i4
 DECLARE ndx1 = i4
 SELECT INTO "nl:"
  FROM orders o,
   person p,
   encntr_alias ea
  PLAN (o
   WHERE o.catalog_cd=787060.00
    AND o.last_update_provider_id IN (19461128.00, 750609.0, 21884908.0, 20298597.00)
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime("01-SEP-2024 00:00:00") AND cnvtdatetime(
    "30-SEP-2024 23:59:59"))
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (ea
   WHERE ea.encntr_id=o.encntr_id
    AND ea.encntr_alias_type_cd=1077
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate)
  HEAD REPORT
   rec_pos = 0
  DETAIL
   rec_pos = locateval(ndx1,1,m_rec->list_cnt,p.person_id,m_rec->list[ndx1].person_id)
   IF (rec_pos=0)
    m_rec->list_cnt += 1, stat = alterlist(m_rec->list,m_rec->list_cnt), rec_pos = m_rec->list_cnt
   ENDIF
   m_rec->list[rec_pos].person_id = p.person_id, m_rec->list[rec_pos].person_name = p
   .name_full_formatted, m_rec->list[rec_pos].person_dob = format(p.birth_dt_tm,"DD-MMM-YYYY"),
   m_rec->list[rec_pos].acct_nbr = ea.alias, m_rec->list[rec_pos].order_name = o.order_mnemonic,
   m_rec->list[rec_pos].order_dt = format(o.orig_order_dt_tm,"DD-MMM-YYYY")
   CASE (o.last_update_provider_id)
    OF 19461128.0:
     m_rec->list[rec_pos].ordered_by_nicora = "X"
    OF 750609.0:
     m_rec->list[rec_pos].ordered_by_reymond = "X"
    OF 21884908.0:
     m_rec->list[rec_pos].ordered_by_grimes = "X"
    OF 20298597.0:
     m_rec->list[rec_pos].ordered_by_perry = "X"
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "bhs_urine_culture_test.dat"
  FROM (dummyt d  WITH seq = value(m_rec->list_cnt))
  HEAD REPORT
   col 0,
   "PERSON_NAME|PERSON_DOB|ACCT_NBR|ORDER_NAME|ORDER_DT|ORDERED_BY_NICORA|ORDERED_BY_REYMOND|ORDERED_BY_GRIMES|",
   col + 1,
   "ORDERED_BY_PERRY|", row + 1
  DETAIL
   col 0, m_rec->list[d.seq].person_name, "|",
   col + 1, m_rec->list[d.seq].person_dob, "|",
   col + 1, m_rec->list[d.seq].acct_nbr, "|",
   col + 1, m_rec->list[d.seq].order_name, "|",
   col + 1, m_rec->list[d.seq].order_dt, "|",
   col + 1, m_rec->list[d.seq].ordered_by_nicora, "|",
   col + 1, m_rec->list[d.seq].ordered_by_reymond, "|",
   col + 1, m_rec->list[d.seq].ordered_by_grimes, "|",
   col + 1, m_rec->list[d.seq].ordered_by_perry, "|",
   row + 1
  WITH nocounter, format = variable, maxcol = 2000
 ;end select
END GO
