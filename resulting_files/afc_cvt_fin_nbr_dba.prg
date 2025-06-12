CREATE PROGRAM afc_cvt_fin_nbr:dba
 RECORD fin_nbr(
   1 fin_nbr_qual = i4
   1 fin_nbr[*]
     2 bill_org_type_id = f8
     2 org_payor_id = f8
 )
 SET count1 = 0
 SELECT INTO "nl:"
  b.bill_org_type_id, b.org_payor_id
  FROM bill_org_payor b
  WHERE (b.bill_org_type_cd=
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=13031
    AND cdf_meaning="FINNUM"))
   AND b.active_ind=1
  DETAIL
   count1 = (count1+ 1), stat = alterlist(fin_nbr->fin_nbr,count1), fin_nbr->fin_nbr[count1].
   bill_org_type_id = b.bill_org_type_id,
   fin_nbr->fin_nbr[count1].org_payor_id = b.org_payor_id
  WITH nocounter
 ;end select
 SET fin_nbr->fin_nbr_qual = count1
 UPDATE  FROM bill_org_payor b,
   (dummyt d1  WITH seq = value(fin_nbr->fin_nbr_qual))
  SET b.bill_org_type_string = cnvtstring(fin_nbr->fin_nbr[d1.seq].bill_org_type_id,17)
  PLAN (d1)
   JOIN (b
   WHERE (b.org_payor_id=fin_nbr->fin_nbr[d1.seq].org_payor_id))
  WITH nocounter
 ;end update
 FREE SET fin_nbr
END GO
