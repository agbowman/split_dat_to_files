CREATE PROGRAM afc_rpt_audit_bb_trans:dba
 PAINT
 CALL text(5,10,"Beginning Date	:")
 CALL text(6,10,"Ending Date	:")
 CALL accept(5,30,"nndpppdnnnn;cs",format(curdate,"dd-mmm-yyyy;;d")
  WHERE format(cnvtdatetime(curaccept),"dd-mmm-yyyy;;d")=curaccept)
 SET begdate = concat(curaccept," 00:00:00.00")
 CALL accept(6,30,"nndpppdnnnn;cs",format(curdate,"dd-mmm-yyyy;;d")
  WHERE format(cnvtdatetime(curaccept),"dd-mmm-yyyy;;d")=curaccept)
 SET enddate = concat(curaccept," 23:59:59.99")
 CALL text(7,10,"PROCESSING...")
 RECORD trans(
   1 trans_qual = i4
   1 trans[*]
     2 product_id = f8
     2 product_event_id = f8
     2 product_cd = f8
     2 product_desc = c20
     2 product_nbr = c26
     2 p_product_id = f8
     2 p_product_cd = f8
     2 event_dt_tm = dq8
     2 ce_trans_flag = i2
     2 person_id = f8
     2 person_name = c25
     2 pooled_ind = i2
 )
 SET code_value = 0.0
 SET code_set = 13029
 SET cdf_meaning = "TRANSFUSED"
 EXECUTE cpm_get_cd_for_cdf
 SET ce_transfused = code_value
 SET code_set = 1610
 SET cdf_meaning = "7"
 EXECUTE cpm_get_cd_for_cdf
 SET transfused = code_value
 SET cdf_meaning = "17"
 EXECUTE cpm_get_cd_for_cdf
 SET pooled = code_value
 SET count1 = 0
 SELECT INTO "nl:"
  t.product_id, pe.product_event_id, pe.event_dt_tm,
  p.product_nbr, p.product_sub_nbr, p.pooled_product_ind,
  p.product_cd, cv.display
  FROM transfusion t,
   product_event pe,
   product p,
   code_value cv
  PLAN (t
   WHERE t.active_ind=1)
   JOIN (pe
   WHERE pe.product_id=t.product_id
    AND pe.event_dt_tm BETWEEN cnvtdatetime(begdate) AND cnvtdatetime(enddate)
    AND pe.event_type_cd=transfused)
   JOIN (p
   WHERE p.product_id=t.product_id)
   JOIN (cv
   WHERE cv.code_value=p.product_cd)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(trans->trans,count1), trans->trans[count1].product_id = t
   .product_id,
   trans->trans[count1].product_event_id = t.product_event_id, trans->trans[count1].product_cd = p
   .product_cd, trans->trans[count1].product_desc = cv.display,
   trans->trans[count1].p_product_id = t.product_id, trans->trans[count1].p_product_cd = p.product_cd,
   trans->trans[count1].product_nbr = concat(p.product_nbr," ",p.product_sub_nbr),
   trans->trans[count1].event_dt_tm = pe.event_dt_tm, trans->trans[count1].person_id = t.person_id,
   trans->trans[count1].pooled_ind = p.pooled_product_ind
  WITH nocounter
 ;end select
 SET trans->trans_qual = count1
 CALL text(8,10,"trans_qual: ")
 CALL text(8,22,cnvtstring(trans->trans_qual))
 IF ((trans->trans_qual=0))
  GO TO endprog
 ENDIF
 SELECT INTO "nl:"
  p.product_id, p.product_cd, p.product_nbr,
  p.product_sub_nbr, p.pooled_product_id, cv.display
  FROM (dummyt d1  WITH seq = value(trans->trans_qual)),
   product p,
   product_event pe,
   code_value cv
  PLAN (d1
   WHERE (trans->trans[d1.seq].pooled_ind=1))
   JOIN (p
   WHERE (p.pooled_product_id=trans->trans[d1.seq].product_id))
   JOIN (cv
   WHERE cv.code_value=p.product_cd)
   JOIN (pe
   WHERE pe.product_id=p.product_id
    AND pe.event_dt_tm BETWEEN cnvtdatetime(begdate) AND cnvtdatetime(enddate)
    AND pe.event_type_cd=pooled)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(trans->trans,count1), trans->trans[count1].product_id = p
   .product_id,
   trans->trans[count1].product_cd = p.product_cd, trans->trans[count1].product_desc = cv.display,
   trans->trans[count1].product_event_id = pe.product_event_id,
   trans->trans[count1].p_product_id = trans->trans[d1.seq].product_id, trans->trans[count1].
   p_product_cd = trans->trans[d1.seq].product_cd, trans->trans[count1].product_nbr = concat(p
    .product_nbr," ",p.product_sub_nbr),
   trans->trans[count1].event_dt_tm = pe.event_dt_tm, trans->trans[count1].person_id = trans->trans[
   d1.seq].person_id, trans->trans[count1].pooled_ind = p.pooled_product_ind
  WITH nocounter
 ;end select
 SET trans->trans_qual = count1
 CALL text(8,10,"trans_qual: ")
 CALL text(8,22,cnvtstring(trans->trans_qual))
 SELECT INTO "nl:"
  cea.charge_event_act_id
  FROM (dummyt d1  WITH seq = value(trans->trans_qual)),
   charge_event c,
   charge_event_act cea
  PLAN (d1)
   JOIN (c
   WHERE (c.ext_m_event_id=trans->trans[d1.seq].p_product_id)
    AND (c.ext_m_reference_id=trans->trans[d1.seq].p_product_cd)
    AND (c.ext_i_event_id=trans->trans[d1.seq].product_id)
    AND (c.ext_i_reference_id=trans->trans[d1.seq].product_cd))
   JOIN (cea
   WHERE cea.charge_event_id=c.charge_event_id
    AND cea.cea_type_cd=ce_transfused)
  DETAIL
   IF (cea.charge_event_act_id != 0)
    trans->trans[d1.seq].ce_trans_flag = 1
   ENDIF
  WITH nocounter
 ;end select
 SET dashline = fillstring(130,"-")
 SET qualcnt = 0
 SET lastpersid = 0
 CALL text(9,10,"Retrieving Patient Info...")
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM (dummyt d1  WITH seq = value(trans->trans_qual)),
   person p
  PLAN (d1
   WHERE (trans->trans[d1.seq].ce_trans_flag=0))
   JOIN (p
   WHERE (p.person_id=trans->trans[d1.seq].person_id))
  DETAIL
   trans->trans[d1.seq].person_name = p.name_full_formatted
  WITH nocounter
 ;end select
 CALL text(10,10,"Preparing Report...")
 SELECT
  dt = format(trans->trans[d1.seq].event_dt_tm,"DDMMMYYYY;;D"), tm = format(trans->trans[d1.seq].
   event_dt_tm,"HHMM;;M")
  FROM (dummyt d1  WITH seq = value(trans->trans_qual))
  PLAN (d1
   WHERE (trans->trans[d1.seq].ce_trans_flag=0))
  ORDER BY trans->trans[d1.seq].person_id, cnvtdatetime(trans->trans[d1.seq].event_dt_tm)
  HEAD REPORT
   col 01, "Date: ", col 10,
   curdate, col 20, curtime,
   col 45, " ** BB Transfusion Charge Event Exception Report ** ", row + 1
  HEAD PAGE
   col 100, "Page:", col 110,
   curpage"####", row + 1, col 01,
   "Prod Id", col 15, "Prod Cd",
   col 25, "Date/Time", col 40,
   "Desc", col 62, "Product Nbr",
   col 90, "Person Name", row + 1,
   col 01, dashline, row + 1
  DETAIL
   IF (lastpersid != 0
    AND (lastpersid != trans->trans[d1.seq].person_id))
    row + 1
   ENDIF
   col 01, trans->trans[d1.seq].product_id"########", col 15,
   trans->trans[d1.seq].product_cd"########", col 25, dt,
   col 35, tm, col 40,
   trans->trans[d1.seq].product_desc, col 62, trans->trans[d1.seq].product_nbr,
   col 90, trans->trans[d1.seq].person_name, row + 1,
   qualcnt = (qualcnt+ 1), lastpersid = trans->trans[d1.seq].person_id
  FOOT REPORT
   col 01, "Qualifying Records: ", col 25,
   qualcnt"########"
  WITH nocounter
 ;end select
#endprog
 FREE SET trans
END GO
