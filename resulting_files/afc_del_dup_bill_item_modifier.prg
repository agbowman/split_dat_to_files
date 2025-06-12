CREATE PROGRAM afc_del_dup_bill_item_modifier
 SET readme = 0
 IF ((validate(request->setup_proc[1].process_id,- (1)) != - (1)))
  SET readme = 1
 ENDIF
 FREE SET dup_rows
 RECORD dup_rows(
   1 dups[*]
     2 dup_key = f8
     2 dup_qual = i4
     2 del_ind = i2
 )
 CALL echo("Update possible NULL fields to 0...")
 UPDATE  FROM bill_item_modifier b
  SET b.bim1_int = 0
  WHERE b.bim1_int=null
 ;end update
 UPDATE  FROM bill_item_modifier b
  SET b.bim_ind = 0
  WHERE b.bim_ind=null
 ;end update
 FREE SET dup_keys
 RECORD dup_keys(
   1 dups[*]
     2 active_ind = f8
     2 bill_item_id = f8
     2 bill_item_type_cd = f8
     2 bim1_int = f8
     2 bim_ind = f8
     2 key1_id = f8
     2 key2_id = f8
     2 key3_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 )
 SET dup_cnt = 0
 SELECT INTO "nl:"
  t.active_ind, t.bill_item_id, t.bill_item_type_cd,
  t.bim1_int, t.bim_ind, t.key1_id,
  t.key2_id, t.key3_id, t.beg_effective_dt_tm,
  t.end_effective_dt_tm, count(*)
  FROM bill_item_modifier t
  GROUP BY t.active_ind, t.bill_item_id, t.bill_item_type_cd,
   t.bim1_int, t.bim_ind, t.key1_id,
   t.key2_id, t.key3_id, t.beg_effective_dt_tm,
   t.end_effective_dt_tm
  HAVING count(*) > 1
  DETAIL
   dup_cnt = (dup_cnt+ 1), stat = alterlist(dup_keys->dups,dup_cnt), dup_keys->dups[dup_cnt].
   active_ind = t.active_ind,
   dup_keys->dups[dup_cnt].bill_item_id = t.bill_item_id, dup_keys->dups[dup_cnt].bill_item_type_cd
    = t.bill_item_type_cd, dup_keys->dups[dup_cnt].bim1_int = t.bim1_int,
   dup_keys->dups[dup_cnt].bim_ind = t.bim_ind, dup_keys->dups[dup_cnt].key1_id = t.key1_id, dup_keys
   ->dups[dup_cnt].key2_id = t.key2_id,
   dup_keys->dups[dup_cnt].key3_id = t.key3_id, dup_keys->dups[dup_cnt].beg_effective_dt_tm =
   cnvtdatetime(t.beg_effective_dt_tm), dup_keys->dups[dup_cnt].end_effective_dt_tm = cnvtdatetime(t
    .end_effective_dt_tm)
  WITH nocounter
 ;end select
 SET count1 = 0
 SET dup_qual = 0
 SELECT INTO "nl:"
  t.bill_item_mod_id, t.active_ind, t.bill_item_id,
  t.bill_item_type_cd, t.bim1_int, t.bim_ind,
  t.key1_id, t.key2_id, t.key3_id,
  t.beg_effective_dt_tm, t.end_effective_dt_tm
  FROM (dummyt d1  WITH seq = value(dup_cnt)),
   bill_item_modifier t
  PLAN (d1)
   JOIN (t
   WHERE (t.active_ind=dup_keys->dups[d1.seq].active_ind)
    AND (t.bill_item_id=dup_keys->dups[d1.seq].bill_item_id)
    AND (t.bill_item_type_cd=dup_keys->dups[d1.seq].bill_item_type_cd)
    AND (t.bim1_int=dup_keys->dups[d1.seq].bim1_int)
    AND (t.bim_ind=dup_keys->dups[d1.seq].bim_ind)
    AND (t.key1_id=dup_keys->dups[d1.seq].key1_id)
    AND (t.key2_id=dup_keys->dups[d1.seq].key2_id)
    AND (t.key3_id=dup_keys->dups[d1.seq].key3_id)
    AND t.beg_effective_dt_tm=cnvtdatetime(dup_keys->dups[d1.seq].beg_effective_dt_tm)
    AND t.end_effective_dt_tm=cnvtdatetime(dup_keys->dups[d1.seq].end_effective_dt_tm))
  HEAD t.active_ind
   dup_qual = (dup_qual+ 1)
  HEAD t.bill_item_id
   dup_qual = (dup_qual+ 1)
  HEAD t.bill_item_type_cd
   dup_qual = (dup_qual+ 1)
  HEAD t.bim1_int
   dup_qual = (dup_qual+ 1)
  HEAD t.bim_ind
   dup_qual = (dup_qual+ 1)
  HEAD t.key1_id
   dup_qual = (dup_qual+ 1)
  HEAD t.key2_id
   dup_qual = (dup_qual+ 1)
  HEAD t.key3_id
   dup_qual = (dup_qual+ 1)
  HEAD t.beg_effective_dt_tm
   dup_qual = (dup_qual+ 1)
  HEAD t.end_effective_dt_tm
   dup_qual = (dup_qual+ 1)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(dup_rows->dups,count1), dup_rows->dups[count1].dup_key = t
   .bill_item_mod_id,
   dup_rows->dups[count1].dup_qual = dup_qual, col 00, dup_rows->dups[count1].dup_qual,
   " ", dup_rows->dups[count1].dup_key, row + 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  t.bill_item_mod_id, dup_qual = dup_rows->dups[d1.seq].dup_qual
  FROM (dummyt d1  WITH seq = value(size(dup_rows->dups,5))),
   bill_item_modifier t
  PLAN (d1)
   JOIN (t
   WHERE (t.bill_item_mod_id=dup_rows->dups[d1.seq].dup_key))
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
 CALL echo("size(dup_rows->dups,5): ",0)
 CALL echo(size(dup_rows->dups,5))
 FOR (x = 1 TO size(dup_rows->dups,5))
   IF ((dup_rows->dups[x].del_ind=1))
    CALL echo(build("deleting primary key: ",dup_rows->dups[x].dup_key))
    DELETE  FROM bill_item_modifier
     WHERE (bill_item_mod_id=dup_rows->dups[x].dup_key)
    ;end delete
    IF (readme=1)
     CALL echo("commit")
     COMMIT
    ENDIF
   ENDIF
 ENDFOR
END GO
