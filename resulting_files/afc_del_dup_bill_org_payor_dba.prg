CREATE PROGRAM afc_del_dup_bill_org_payor:dba
 SET readme = 0
 IF (validate(request->setup_proc[1].success_ind,999) != 999)
  SET readme = 1
  EXECUTE oragen3 "BILL_ORG_PAYOR"
 ENDIF
 FREE SET dup_rows
 RECORD dup_rows(
   1 dups[*]
     2 dup_key = f8
     2 dup_qual = i4
     2 del_ind = i2
 )
 FREE SET dup_keys
 RECORD dup_keys(
   1 dups[*]
     2 active_ind = f8
     2 bill_org_type_cd = f8
     2 bill_org_type_id = f8
     2 organization_id = f8
 )
 SET dup_cnt = 0
 SELECT INTO "nl:"
  t.active_ind, t.bill_org_type_cd, t.bill_org_type_id,
  t.organization_id, count(*)
  FROM bill_org_payor t
  GROUP BY t.active_ind, t.bill_org_type_cd, t.bill_org_type_id,
   t.organization_id
  HAVING count(*) > 1
  DETAIL
   dup_cnt = (dup_cnt+ 1), stat = alterlist(dup_keys->dups,dup_cnt), dup_keys->dups[dup_cnt].
   active_ind = t.active_ind,
   dup_keys->dups[dup_cnt].bill_org_type_cd = t.bill_org_type_cd, dup_keys->dups[dup_cnt].
   bill_org_type_id = t.bill_org_type_id, dup_keys->dups[dup_cnt].organization_id = t.organization_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("No Duplicates Found")
  GO TO endprog
 ENDIF
 SET count1 = 0
 SET dup_qual = 0
 SELECT INTO "nl:"
  t.org_payor_id, t.active_ind, t.bill_org_type_cd,
  t.bill_org_type_id, t.organization_id
  FROM (dummyt d1  WITH seq = value(dup_cnt)),
   bill_org_payor t
  PLAN (d1)
   JOIN (t
   WHERE (t.active_ind=dup_keys->dups[d1.seq].active_ind)
    AND (t.bill_org_type_cd=dup_keys->dups[d1.seq].bill_org_type_cd)
    AND (t.bill_org_type_id=dup_keys->dups[d1.seq].bill_org_type_id)
    AND (t.organization_id=dup_keys->dups[d1.seq].organization_id))
  HEAD t.active_ind
   dup_qual = (dup_qual+ 1)
  HEAD t.bill_org_type_cd
   dup_qual = (dup_qual+ 1)
  HEAD t.bill_org_type_id
   dup_qual = (dup_qual+ 1)
  HEAD t.organization_id
   dup_qual = (dup_qual+ 1)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(dup_rows->dups,count1), dup_rows->dups[count1].dup_key = t
   .org_payor_id,
   dup_rows->dups[count1].dup_qual = dup_qual, col 00, dup_rows->dups[count1].dup_qual,
   " ", dup_rows->dups[count1].dup_key, row + 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  t.org_payor_id, dup_qual = dup_rows->dups[d1.seq].dup_qual
  FROM (dummyt d1  WITH seq = value(size(dup_rows->dups,5))),
   bill_org_payor t
  PLAN (d1)
   JOIN (t
   WHERE (t.org_payor_id=dup_rows->dups[d1.seq].dup_key))
  ORDER BY dup_qual, t.updt_dt_tm DESC
  HEAD dup_qual
   count1 = 0
  DETAIL
   IF (count1 > 0)
    dup_rows->dups[d1.seq].del_ind = 1
   ENDIF
   count1 = (count1+ 1)
  WITH nocounter
 ;end select
 IF (readme=0)
  CALL echo("size(dup_rows->dups,5): ",0)
  CALL echo(size(dup_rows->dups,5))
  SELECT
   dup_qual = dup_rows->dups[d1.seq].dup_qual, dup_key = dup_rows->dups[d1.seq].dup_key, del_ind =
   dup_rows->dups[d1.seq].del_ind
   FROM (dummyt d1  WITH seq = value(size(dup_rows->dups,5)))
   PLAN (d1)
   WITH nocounter
  ;end select
 ENDIF
 FOR (x = 1 TO size(dup_rows->dups,5))
   IF ((dup_rows->dups[x].del_ind=1))
    CALL echo(build("deleting primary key: ",dup_rows->dups[x].dup_key))
    DELETE  FROM bill_org_payor
     WHERE (org_payor_id=dup_rows->dups[x].dup_key)
    ;end delete
   ENDIF
 ENDFOR
 IF (readme=0)
  CALL echo("Type 'Commit Go' to keep changes")
 ELSE
  CALL echo("Commit")
  COMMIT
 ENDIF
#endprog
 FREE SET dup_rows
 FREE SET dup_keys
 CALL echo("Done.")
END GO
