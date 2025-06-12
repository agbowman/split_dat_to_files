CREATE PROGRAM afc_fix_child_owner_codes:dba
 RECORD def_items(
   1 qual[*]
     2 bi_id = f8
     2 ext_cref_id = f8
     2 ext_cref_cd = f8
     2 ext_pref_id = f8
     2 ext_pref_cd = f8
     2 ext_desc = c25
     2 match_ind = f8
     2 ext_owner_cd = f8
 )
 IF (validate(request->ops_date,999)=999)
  EXECUTE cclseclogin
  SET message = nowindow
 ENDIF
 DECLARE cnt = i4
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE taskcat_cd = f8
 DECLARE ordcat_cd = f8
 DECLARE task_assay_cd = f8
 SET codeset = 13016
 SET cdf_meaning = "TASK ASSAY"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,task_assay_cd)
 CALL echo(build("the task assay code value is: ",task_assay_cd))
 SET count1 = 0
 SELECT INTO "nl:"
  b.ext_child_reference_id, b.ext_child_contributor_cd, b.bill_item_id,
  b.ext_parent_reference_id, b.ext_parent_contributor_cd
  FROM bill_item b
  WHERE b.active_ind=1
   AND b.ext_child_reference_id != 0
   AND b.ext_child_contributor_cd=task_assay_cd
  ORDER BY b.ext_child_reference_id
  DETAIL
   count1 = (count1+ 1), stat = alterlist(def_items->qual,count1), def_items->qual[count1].bi_id = b
   .bill_item_id,
   def_items->qual[count1].ext_cref_id = b.ext_child_reference_id, def_items->qual[count1].
   ext_cref_cd = b.ext_child_contributor_cd, def_items->qual[count1].ext_pref_id = b
   .ext_parent_reference_id,
   def_items->qual[count1].ext_pref_cd = b.ext_parent_contributor_cd, def_items->qual[count1].
   ext_desc = b.ext_description, def_items->qual[count1].ext_owner_cd = b.ext_owner_cd
  WITH nocounter
 ;end select
 CALL echo(count1,0)
 CALL echo(" child items found...")
 SELECT INTO "nl:"
  dta.activity_type_cd, dta.task_assay_cd
  FROM discrete_task_assay dta,
   (dummyt d1  WITH seq = value(size(def_items->qual,5)))
  PLAN (d1)
   JOIN (dta
   WHERE (dta.task_assay_cd=def_items->qual[d1.seq].ext_cref_id)
    AND dta.active_ind=1)
  DETAIL
   IF ((def_items->qual[d1.seq].ext_owner_cd=dta.activity_type_cd))
    def_items->qual[d1.seq].match_ind = 1
   ELSE
    def_items->qual[d1.seq].match_ind = 0, def_items->qual[d1.seq].ext_owner_cd = dta
    .activity_type_cd
   ENDIF
  WITH nocounter
 ;end select
 SELECT
  bi_id = def_items->qual[d1.seq].bi_id, desc = def_items->qual[d1.seq].ext_desc, match = def_items->
  qual[d1.seq].match_ind,
  ext_owner_cd = def_items->qual[d1.seq].ext_owner_cd
  FROM (dummyt d1  WITH seq = value(size(def_items->qual,5)))
  PLAN (d1)
  ORDER BY match, ext_owner_cd, bi_id
  HEAD REPORT
   col 05, "Created by:	", curuser,
   col 30, "This report shows child items (cont_cd of task assay) from the ", row + 1,
   col 30, "bill item table whose activity type does not", row + 1,
   col 30, "match the activity type on the discrete task assay table, ", row + 1,
   col 30, "and how they will be updated.", row + 1,
   col 05, "Time:		", curdate,
   " ", curtime, row + 1
  HEAD PAGE
   col 00, "bi id", col 10,
   "bi desc", col 79, "owner cd",
   row + 1
  HEAD match
   count1 = 0
   IF (match=0)
    col 00,
    "These bill items activity types did not match that of their corresponding discrete_task_assay items."
   ELSE
    row + 1, col 00,
    "These bill items activity types did match that of their corresponding discrete_task_assay items."
   ENDIF
   row + 1
  DETAIL
   count1 = (count1+ 1), col 00, bi_id"########",
   col 10, desc, col 79,
   " ", ext_owner_cd"########", row + 1
  FOOT  match
   col 10, "total: ", count1,
   row + 2
  WITH nocounter
 ;end select
 CALL echo("Updating child items' (task assay) ext_owner_cd")
 UPDATE  FROM bill_item b,
   (dummyt d1  WITH seq = value(size(def_items->qual,5)))
  SET b.ext_owner_cd = def_items->qual[d1.seq].ext_owner_cd, b.updt_dt_tm = cnvtdatetime(curdate,
    curtime), b.updt_id = 2208,
   b.updt_task = 99999999
  PLAN (d1
   WHERE (def_items->qual[d1.seq].match_ind=0))
   JOIN (b
   WHERE (b.bill_item_id=def_items->qual[d1.seq].bi_id))
  WITH nocounter
 ;end update
 SET num_tasks = 0
 RECORD task_items(
   1 tasks[*]
     2 bi_id = f8
     2 ext_cref_id = f8
     2 ext_cref_cd = f8
     2 ext_pref_id = f8
     2 ext_pref_cd = f8
     2 match_ind = i2
     2 ext_desc = c25
     2 ext_owner_cd = f8
 )
 SET codeset = 13016
 SET cdf_meaning = "TASKCAT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,taskcat_cd)
 CALL echo(build("the task cat code value is: ",taskcat_cd))
 SET codeset = 13016
 SET cdf_meaning = "ORD CAT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,ordcat_cd)
 CALL echo(build("the ord cat code value is: ",ordcat_cd))
 SELECT INTO "nl:"
  b.bill_item_id, b.ext_child_reference_id, b.ext_child_contributor_cd,
  b.ext_parent_reference_id, b.ext_parent_contributor_cd, b.ext_description
  FROM bill_item b
  WHERE b.ext_parent_contributor_cd=ordcat_cd
   AND b.ext_child_contributor_cd=taskcat_cd
   AND b.active_ind=1
  DETAIL
   num_tasks = (num_tasks+ 1), stat = alterlist(task_items->tasks,num_tasks), task_items->tasks[
   num_tasks].bi_id = b.bill_item_id,
   task_items->tasks[num_tasks].ext_cref_id = b.ext_child_reference_id, task_items->tasks[num_tasks].
   ext_cref_cd = b.ext_child_contributor_cd, task_items->tasks[num_tasks].ext_pref_id = b
   .ext_parent_reference_id,
   task_items->tasks[num_tasks].ext_pref_cd = b.ext_parent_contributor_cd, task_items->tasks[
   num_tasks].ext_desc = b.ext_description, task_items->tasks[num_tasks].ext_owner_cd = 0,
   task_items->tasks[num_tasks].match_ind = 0
  WITH nocounter
 ;end select
 CALL echo(build("********** num tasks is : ",num_tasks))
 IF (num_tasks > 0)
  SELECT INTO "nl:"
   o.activity_type_cd, o.catalog_cd
   FROM order_catalog o,
    (dummyt d1  WITH seq = value(size(task_items->tasks,5)))
   PLAN (d1)
    JOIN (o
    WHERE (o.catalog_cd=task_items->tasks[d1.seq].ext_pref_id)
     AND o.active_ind=1)
   DETAIL
    task_items->tasks[d1.seq].match_ind = 1, task_items->tasks[d1.seq].ext_owner_cd = o
    .activity_type_cd
   WITH nocounter
  ;end select
  SELECT
   bi_id = task_items->tasks[d1.seq].bi_id, desc = task_items->tasks[d1.seq].ext_desc, match =
   task_items->tasks[d1.seq].match_ind,
   ext_owner_cd = task_items->tasks[d1.seq].ext_owner_cd
   FROM (dummyt d1  WITH seq = value(size(task_items->tasks,5)))
   PLAN (d1)
   ORDER BY match, ext_owner_cd, bi_id
   HEAD REPORT
    col 05, "Created by:	", curuser,
    col 30,
    "This report shows child items (cont_cd of taskcat) with 0 owner code, and how they'll be updated",
    row + 1,
    col 05, "Time:		", curdate,
    " ", curtime, row + 1
   HEAD PAGE
    col 00, "bi id", col 10,
    "bi desc", col 79, "owner cd",
    row + 1
   HEAD match
    count1 = 0
    IF (match=0)
     col 00, "These items had no matching task items."
    ELSE
     row + 1, col 00, "These items found task matches."
    ENDIF
    row + 1
   DETAIL
    count1 = (count1+ 1), col 00, bi_id"########",
    col 10, desc, col 79,
    " ", ext_owner_cd"########", row + 1
   FOOT  match
    col 10, "total: ", count1,
    row + 2
   WITH nocounter
  ;end select
  CALL echo("Updating child items' (tasks) ext_owner_cd")
  UPDATE  FROM bill_item b,
    (dummyt d1  WITH seq = value(size(task_items->tasks,5)))
   SET b.ext_owner_cd = task_items->tasks[d1.seq].ext_owner_cd, b.updt_dt_tm = cnvtdatetime(curdate,
     curtime), b.updt_id = 2208,
    b.updt_task = 99999999
   PLAN (d1
    WHERE (task_items->tasks[d1.seq].ext_owner_cd != 0))
    JOIN (b
    WHERE (b.bill_item_id=task_items->tasks[d1.seq].bi_id))
   WITH nocounter
  ;end update
 ENDIF
 CALL echo("done.  type commit go.")
END GO
