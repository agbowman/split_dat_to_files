CREATE PROGRAM afc_cvt_task_bill_items:dba
 EXECUTE oragen3 "BILL_ITEM"
 SET taskcat = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=13016
   AND cv.cdf_meaning="TASKCAT"
  DETAIL
   taskcat = cv.code_value
  WITH nocounter
 ;end select
 RECORD def_task(
   1 qual[*]
     2 bi_id = f8
 )
 SET count1 = 0
 SELECT INTO "nl:"
  b.bill_item_id
  FROM bill_item b
  WHERE b.ext_child_contributor_cd=taskcat
   AND b.ext_parent_reference_id=0
  DETAIL
   count1 = (count1+ 1), stat = alterlist(def_task->qual,count1), def_task->qual[count1].bi_id = b
   .bill_item_id
  WITH nocounter
 ;end select
 SET item_cnt = size(def_task->qual,5)
 SELECT INTO "nl:"
  psi.price_sched_items_id
  FROM (dummyt d1  WITH seq = value(item_cnt)),
   price_sched_items psi
  PLAN (d1)
   JOIN (psi
   WHERE (psi.bill_item_id=def_task->qual[d1.seq].bi_id))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  CALL echo("deleting price_sched_items records")
  FOR (x = 1 TO item_cnt)
    DELETE  FROM price_sched_items
     WHERE (bill_item_id=def_task->qual[x].bi_id)
     WITH nocounter
    ;end delete
  ENDFOR
 ENDIF
 COMMIT
 SELECT INTO "nl:"
  bm.bill_item_mod_id
  FROM (dummyt d1  WITH seq = value(item_cnt)),
   bill_item_modifier bm
  PLAN (d1)
   JOIN (bm
   WHERE (bm.bill_item_id=def_task->qual[d1.seq].bi_id))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  CALL echo("deleting bill_item_modifier records")
  FOR (x = 1 TO item_cnt)
    DELETE  FROM bill_item_modifier
     WHERE (bill_item_id=def_task->qual[x].bi_id)
     WITH nocounter
    ;end delete
  ENDFOR
 ENDIF
 COMMIT
 DELETE  FROM bill_item b
  WHERE b.ext_parent_reference_id=0
   AND b.ext_child_contributor_cd=taskcat
  WITH nocounter
 ;end delete
 COMMIT
 UPDATE  FROM bill_item b
  SET b.ext_child_entity_name = "ORDER_TASK", b.updt_task = 646
  WHERE b.ext_child_contributor_cd=taskcat
  WITH nocounter
 ;end update
 COMMIT
END GO
