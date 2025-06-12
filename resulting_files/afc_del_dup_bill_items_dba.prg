CREATE PROGRAM afc_del_dup_bill_items:dba
 SET upt_cnt = 0
 SELECT INTO "nl:"
  tot_nulls = count(*)
  FROM bill_item
  WHERE child_seq=null
  DETAIL
   upt_cnt = tot_nulls
  WITH nocounter
 ;end select
 IF (upt_cnt > 0)
  CALL echo("updating rows with null values...")
  CALL echo("child_seq...")
  UPDATE  FROM bill_item b
   SET b.child_seq = 0
   WHERE b.child_seq=null
   WITH nocounter
  ;end update
  CALL echo("misc_ind...")
  UPDATE  FROM bill_item b
   SET b.misc_ind = 0
   WHERE b.misc_ind=null
   WITH nocounter
  ;end update
  CALL echo("parent_qual_ind...")
  UPDATE  FROM bill_item b
   SET b.parent_qual_ind = 0
   WHERE b.parent_qual_ind=null
   WITH nocounter
  ;end update
  CALL echo("careset_ind ...")
  UPDATE  FROM bill_item b
   SET b.careset_ind = 0
   WHERE b.careset_ind=null
   WITH nocounter
  ;end update
  CALL echo("workload_only_ind...")
  UPDATE  FROM bill_item b
   SET b.workload_only_ind = 0
   WHERE b.workload_only_ind=null
   WITH nocounter
  ;end update
  CALL echo("active_ind...")
  UPDATE  FROM bill_item b
   SET b.active_ind = 0
   WHERE b.active_ind=null
   WITH nocounter
  ;end update
  COMMIT
  CALL echo("Done updating nulls.")
 ENDIF
 RECORD bi(
   1 bi_l[*]
     2 bill_item_id = f8
     2 desc = c50
     2 del_ind = i2
     2 active_ind = i2
     2 ext_p_ref_id = f8
     2 ext_p_cont_cd = f8
     2 ext_c_ref_id = f8
     2 ext_c_cont_cd = f8
 )
 RECORD e(
   1 e_cnt = i2
   1 e_l[*]
     2 bill_item_id = f8
     2 active_ind = i2
     2 ext_p_ref_id = f8
     2 ext_p_cont_cd = f8
     2 ext_c_ref_id = f8
     2 ext_c_cont_cd = f8
 )
 SET count1 = 0
 SET new_one = 0
 SET save_bill_item_id = 0.0
 SET readme = 0
 IF (validate(request->setup_proc[1].success_ind,999) != 999)
  SET readme = 1
  EXECUTE oragen3 "BILL_ITEM"
 ENDIF
 CALL echo("Finding duplicate bill items...")
 SELECT INTO "nl:"
  b.*, b1.*
  FROM bill_item b,
   bill_item b1
  PLAN (b)
   JOIN (b1
   WHERE b.ext_parent_reference_id=b1.ext_parent_reference_id
    AND b.ext_parent_contributor_cd=b1.ext_parent_contributor_cd
    AND b.ext_child_reference_id=b1.ext_child_reference_id
    AND b.ext_child_contributor_cd=b1.ext_child_contributor_cd
    AND b.active_ind=b1.active_ind
    AND b.child_seq=b1.child_seq
    AND b.bill_item_id != b1.bill_item_id)
  ORDER BY b.ext_parent_reference_id, b.ext_parent_contributor_cd, b.ext_child_reference_id,
   b.ext_child_contributor_cd, b.active_ind, b.bill_item_id
  HEAD b.ext_parent_reference_id
   save_bill_item_id = b.bill_item_id
  HEAD b.ext_parent_contributor_cd
   save_bill_item_id = b.bill_item_id
  HEAD b.ext_child_reference_id
   save_bill_item_id = b.bill_item_id
  HEAD b.ext_child_contributor_cd
   save_bill_item_id = b.bill_item_id
  HEAD b.active_ind
   save_bill_item_id = b.bill_item_id
  DETAIL
   count1 = (count1+ 1)
   IF (b.bill_item_id != save_bill_item_id)
    stat = alterlist(bi->bi_l,count1), bi->bi_l[count1].bill_item_id = b.bill_item_id, bi->bi_l[
    count1].desc = b.ext_description,
    bi->bi_l[count1].active_ind = b.active_ind, bi->bi_l[count1].ext_p_ref_id = b
    .ext_parent_reference_id, bi->bi_l[count1].ext_p_cont_cd = b.ext_parent_contributor_cd,
    bi->bi_l[count1].ext_c_ref_id = b.ext_child_reference_id, bi->bi_l[count1].ext_c_cont_cd = b
    .ext_child_contributor_cd
   ENDIF
   IF (b1.bill_item_id != save_bill_item_id)
    stat = alterlist(bi->bi_l,count1), bi->bi_l[count1].bill_item_id = b1.bill_item_id, bi->bi_l[
    count1].desc = b1.ext_description,
    bi->bi_l[count1].active_ind = b1.active_ind, bi->bi_l[count1].ext_p_ref_id = b
    .ext_parent_reference_id, bi->bi_l[count1].ext_p_cont_cd = b.ext_parent_contributor_cd,
    bi->bi_l[count1].ext_c_ref_id = b.ext_child_reference_id, bi->bi_l[count1].ext_c_cont_cd = b
    .ext_child_contributor_cd
   ENDIF
  WITH nocounter
 ;end select
 SET tot_cnt = count1
 SET count1 = 0
 IF (tot_cnt > 0)
  IF (readme=0)
   CALL echo("Preparing Report")
   SELECT
    bi_id = bi->bi_l[d1.seq].bill_item_id, bi_desc = bi->bi_l[d1.seq].desc
    FROM (dummyt d1  WITH seq = value(tot_cnt))
    ORDER BY bi_id
    HEAD PAGE
     col 100, "Page: ", col 110,
     curpage"####", row + 1, col 00,
     "The following bill_items are duplicates and will be deleted.", row + 1
    HEAD bi_id
     col 00, bi_id"########", col 10,
     bi_desc, col 65, bi->bi_l[d1.seq].active_ind"#",
     row + 1, bi->bi_l[d1.seq].del_ind = 1, count1 = (count1+ 1)
    DETAIL
     count1 = count1
    FOOT REPORT
     col 00, "Total bill items to be deleted: ", col 35,
     count1"########"
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    bi_id = bi->bi_l[d1.seq].bill_item_id, bi_desc = bi->bi_l[d1.seq].desc
    FROM (dummyt d1  WITH seq = value(tot_cnt))
    ORDER BY bi_id
    HEAD bi_id
     bi->bi_l[d1.seq].del_ind = 1, count1 = (count1+ 1)
    DETAIL
     count1 = count1
    WITH nocounter
   ;end select
  ENDIF
  CALL echo("Deleting Bill Items...")
  FOR (x = 1 TO tot_cnt)
    IF ((bi->bi_l[x].del_ind=1))
     IF ((bi->bi_l[x].active_ind=0))
      DELETE  FROM bill_item_modifier b
       WHERE (b.bill_item_id=bi->bi_l[x].bill_item_id)
      ;end delete
      DELETE  FROM price_sched_items p
       WHERE (p.bill_item_id=bi->bi_l[x].bill_item_id)
      ;end delete
      UPDATE  FROM charge c
       SET c.bill_item_id = 0.0
       WHERE (c.bill_item_id=bi->bi_l[x].bill_item_id)
      ;end update
     ENDIF
     DELETE  FROM bill_item b
      WHERE (b.bill_item_id=bi->bi_l[x].bill_item_id)
     ;end delete
     IF (curqual=0)
      CALL echo(build("Delete failed for bill_item: ",bi->bi_l[x].bill_item_id))
      SET e->e_cnt = (e->e_cnt+ 1)
      SET stat = alterlist(e->e_l,e->e_cnt)
      SET e->e_l[e->e_cnt].bill_item_id = bi->bi_l[x].bill_item_id
      SET e->e_l[e->e_cnt].active_ind = bi->bi_l[e->e_cnt].active_ind
      SET e->e_l[e->e_cnt].ext_p_ref_id = bi->bi_l[e->e_cnt].ext_p_ref_id
      SET e->e_l[e->e_cnt].ext_p_cont_cd = bi->bi_l[e->e_cnt].ext_p_cont_cd
      SET e->e_l[e->e_cnt].ext_c_ref_id = bi->bi_l[e->e_cnt].ext_c_ref_id
      SET e->e_l[e->e_cnt].ext_c_cont_cd = bi->bi_l[e->e_cnt].ext_c_cont_cd
     ENDIF
    ENDIF
  ENDFOR
  FREE SET bi
  IF ((e->e_cnt > 0))
   CALL echo("Clean up error rows")
   RECORD bi(
     1 bi_cnt = i2
     1 bi_l[*]
       2 bill_item_id = f8
   )
   FOR (x = 1 TO e->e_cnt)
     SELECT INTO "nl:"
      b.bill_item_id
      FROM (dummyt d1  WITH seq = value(e->e_cnt)),
       bill_item b
      PLAN (d1)
       JOIN (b
       WHERE (b.ext_parent_reference_id=e->e_l[d1.seq].ext_p_ref_id)
        AND (b.ext_parent_contributor_cd=e->e_l[d1.seq].ext_p_cont_cd)
        AND (b.ext_child_reference_id=e->e_l[d1.seq].ext_c_ref_id)
        AND (b.ext_child_contributor_cd=e->e_l[d1.seq].ext_c_cont_cd)
        AND (b.active_ind=e->e_l[d1.seq].active_ind))
      ORDER BY b.ext_parent_reference_id, b.ext_parent_contributor_cd, b.ext_child_reference_id,
       b.ext_child_contributor_cd, b.active_ind, b.bill_item_id
      HEAD b.ext_parent_reference_id
       save_bill_item_id = b.bill_item_id
      HEAD b.ext_parent_contributor_cd
       save_bill_item_id = b.bill_item_id
      HEAD b.ext_child_reference_id
       save_bill_item_id = b.bill_item_id
      HEAD b.ext_child_contributor_cd
       save_bill_item_id = b.bill_item_id
      HEAD b.active_ind
       save_bill_item_id = b.bill_item_id
      DETAIL
       IF (b.bill_item_id != save_bill_item_id)
        bi->bi_cnt = (bi->bi_cnt+ 1), stat = alterlist(bi->bi_l,bi_bi_cnt), bi->bi_l[bi->bi_cnt].
        bill_item_id
       ENDIF
      WITH nocounter
     ;end select
   ENDFOR
   FOR (x = 1 TO bi->bi_cnt)
     DELETE  FROM price_sched_items p
      WHERE (p.bill_item_id=bi->bi_l[bi_cnt].bill_item_id)
     ;end delete
     DELETE  FROM bill_item_modifier b
      WHERE (b.bill_item_id=bi->bi_l[bi_cnt].bill_item_id)
     ;end delete
     UPDATE  FROM charge c
      SET c.bill_item_id = 0.0
      WHERE (c.bill_item_id=bi->bi_l[bi_cnt].bill_item_id)
     ;end update
     DELETE  FROM bill_item b
      WHERE (b.bill_item_id=bi->bi_l[bi->bi_cnt].bill_item_id)
     ;end delete
   ENDFOR
  ENDIF
  IF (readme=1)
   CALL echo("Commit.")
   COMMIT
  ENDIF
 ELSE
  CALL echo("No duplicates found.")
 ENDIF
 FREE SET bi
 FREE SET e
 CALL echo("Checking for inactive duplicates of active bill_items...")
 SET new_item = 0
 SET item_cnt = 0
 SET i_cnt = 0
 FREE SET bill_item
 IF (readme=1)
  SET file_name = "nl:"
 ELSE
  SET file_name = "MINE"
 ENDIF
 RECORD bill_item(
   1 bi_l[*]
     2 bill_item_id = f8
     2 del_ind = i2
     2 ext_desc = c25
 )
 SELECT INTO value(file_name)
  b.*, desc = substring(1,25,b.ext_description)
  FROM bill_item b
  ORDER BY b.ext_parent_reference_id, b.ext_parent_contributor_cd, b.ext_child_reference_id,
   b.ext_child_contributor_cd, b.active_ind
  HEAD b.ext_parent_reference_id
   new_item = 1
  HEAD b.ext_parent_contributor_cd
   new_item = 1
  HEAD b.ext_child_reference_id
   new_item = 1
  HEAD b.ext_child_contributor_cd
   new_item = 1
  DETAIL
   IF (new_item=1)
    row + 1, new_item = 0
    IF (item_cnt=1)
     row- (2)
    ENDIF
    item_cnt = 0
   ENDIF
   item_cnt = (item_cnt+ 1), i_cnt = (i_cnt+ 1), stat = alterlist(bill_item->bi_l,i_cnt),
   bill_item->bi_l[i_cnt].bill_item_id = b.bill_item_id, bill_item->bi_l[i_cnt].del_ind = 0,
   bill_item->bi_l[i_cnt].ext_desc = desc
   IF (item_cnt > 1
    AND b.active_ind=1)
    bill_item->bi_l[(i_cnt - 1)].del_ind = 1
   ELSEIF (item_cnt > 1
    AND b.active_ind != 1)
    bill_item->bi_l[i_cnt].del_ind = 1
   ENDIF
   IF (readme=0)
    col 00, b.bill_item_id"########", col 10,
    b.ext_parent_reference_id"########", col 20, b.ext_parent_contributor_cd"########",
    col 30, b.ext_child_reference_id"########", col 40,
    b.ext_child_contributor_cd"########", col 50, b.active_ind,
    col 60, desc
    IF (item_cnt > 1)
     row- (1)
     IF ((bill_item->bi_l[(i_cnt - 1)].del_ind=1))
      col 101, "delete"
     ENDIF
     row + 1
    ENDIF
    IF ((bill_item->bi_l[i_cnt].del_ind=1))
     col 101, "delete"
    ENDIF
    row + 1
   ENDIF
  WITH nocounter
 ;end select
 IF (i_cnt != 0)
  CALL echo("Deleting...")
  FOR (x = 1 TO size(bill_item->bi_l,5))
    IF ((bill_item->bi_l[x].del_ind=1))
     DELETE  FROM bill_item_modifier
      WHERE (bill_item_id=bill_item->bi_l[x].bill_item_id)
     ;end delete
     DELETE  FROM price_sched_items
      WHERE (bill_item_id=bill_item->bi_l[x].bill_item_id)
     ;end delete
     UPDATE  FROM charge
      SET bill_item_id = 0.0
      WHERE (bill_item_id=bill_item->bi_l[x].bill_item_id)
     ;end update
     DELETE  FROM bill_item
      WHERE (bill_item_id=bill_item->bi_l[x].bill_item_id)
     ;end delete
     IF (curqual=0)
      CALL echo(build("       Could not delete: ",bill_item->bi_l[x].bill_item_id))
     ENDIF
    ENDIF
  ENDFOR
  IF (readme=0)
   CALL echo("Done.  Type 'commit go' to save changes.")
  ELSE
   CALL echo("Done. Commit.")
   COMMIT
  ENDIF
 ELSE
  CALL echo("No more duplicates found.")
 ENDIF
 FREE SET bill_item
END GO
