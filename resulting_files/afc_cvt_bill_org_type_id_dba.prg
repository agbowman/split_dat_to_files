CREATE PROGRAM afc_cvt_bill_org_type_id:dba
 RECORD bill_org_type_id(
   1 boti_qual = i4
   1 boti[*]
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
    AND ((cdf_meaning="CLIENTBILL") OR (cdf_meaning="BILLPERFORG")) ))
   AND b.active_ind=1
  DETAIL
   count1 = (count1+ 1), stat = alterlist(bill_org_type_id->boti,count1), bill_org_type_id->boti[
   count1].bill_org_type_id = b.bill_org_type_id,
   bill_org_type_id->boti[count1].org_payor_id = b.org_payor_id
  WITH nocounter
 ;end select
 SET bill_org_type_id->boti_qual = count1
 UPDATE  FROM bill_org_payor b,
   (dummyt d1  WITH seq = value(bill_org_type_id->boti_qual))
  SET b.bill_org_type_ind = bill_org_type_id->boti[d1.seq].bill_org_type_id
  PLAN (d1)
   JOIN (b
   WHERE (b.org_payor_id=bill_org_type_id->boti[d1.seq].org_payor_id))
  WITH nocounter
 ;end update
 COMMIT
 FREE SET bill_org_type_id
END GO
