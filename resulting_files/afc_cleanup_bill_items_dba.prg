CREATE PROGRAM afc_cleanup_bill_items:dba
 EXECUTE cclseclogin
 SET message = nowindow
 DECLARE code_value = f8
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE code_value_cd = f8
 DECLARE gen_lab_cd = f8
 DECLARE rad_cd = f8
 DECLARE inactive_cd = f8
 DECLARE task_assay_cd = f8
 RECORD bi(
   1 bi_l[*]
     2 bill_item_id = f8
     2 inactivate = i2
     2 delete_ind = i2
 )
 SET count1 = 0
 SELECT INTO "nl:"
  b.bill_item_id
  FROM bill_item b,
   dummyt d1,
   order_catalog o
  PLAN (b
   WHERE b.ext_parent_reference_id != 0
    AND b.ext_child_reference_id=0
    AND (b.ext_parent_contributor_cd=
   (SELECT
    code_value
    FROM code_value
    WHERE cdf_meaning="ORD CAT"
     AND code_set=13016))
    AND b.active_ind=1)
   JOIN (d1)
   JOIN (o
   WHERE o.catalog_cd=b.ext_parent_reference_id)
  DETAIL
   IF (o.catalog_cd != 0
    AND o.active_ind=0)
    count1 = (count1+ 1), stat = alterlist(bi->bi_l,count1), bi->bi_l[count1].bill_item_id = b
    .bill_item_id,
    bi->bi_l[count1].inactivate = 1
   ELSEIF (o.catalog_cd=0)
    count1 = (count1+ 1), stat = alterlist(bi->bi_l,count1), bi->bi_l[count1].bill_item_id = b
    .bill_item_id,
    bi->bi_l[count1].delete_ind = 1
   ENDIF
  WITH outerjoin = d1
 ;end select
 SELECT INTO "nl:"
  b.bill_item_id
  FROM bill_item b,
   dummyt d1,
   discrete_task_assay dta
  PLAN (b
   WHERE b.ext_child_reference_id != 0
    AND (b.ext_child_contributor_cd=
   (SELECT
    code_value
    FROM code_value
    WHERE cdf_meaning="TASK ASSAY"
     AND code_set=13016))
    AND b.active_ind=1)
   JOIN (d1)
   JOIN (dta
   WHERE dta.task_assay_cd=b.ext_child_reference_id)
  DETAIL
   IF (dta.task_assay_cd != 0
    AND dta.active_ind=0)
    count1 = (count1+ 1), stat = alterlist(bi->bi_l,count1), bi->bi_l[count1].bill_item_id = b
    .bill_item_id,
    bi->bi_l[count1].inactivate = 1
   ELSEIF (dta.task_assay_cd=0)
    count1 = (count1+ 1), stat = alterlist(bi->bi_l,count1), bi->bi_l[count1].bill_item_id = b
    .bill_item_id,
    bi->bi_l[count1].delete_ind = 1
   ENDIF
  WITH outerjoin = d1
 ;end select
 SELECT INTO "nl:"
  b.bill_item_id
  FROM bill_item b,
   dummyt d1,
   mic_task m
  PLAN (b
   WHERE (b.ext_parent_contributor_cd=
   (SELECT
    code_value
    FROM code_value
    WHERE cdf_meaning="MIC TASK"
     AND code_set=13016))
    AND b.active_ind=1)
   JOIN (d1)
   JOIN (m
   WHERE m.task_assay_cd=b.ext_parent_reference_id)
  DETAIL
   IF (m.task_assay_cd != 0
    AND m.active_ind=0)
    count1 = (count1+ 1), stat = alterlist(bi->bi_l,count1), bi->bi_l[count1].bill_item_id = b
    .bill_item_id,
    bi->bi_l[count1].inactivate = 1
   ELSEIF (m.task_assay_cd=0)
    count1 = (count1+ 1), stat = alterlist(bi->bi_l,count1), bi->bi_l[count1].bill_item_id = b
    .bill_item_id,
    bi->bi_l[count1].delete_ind = 1
   ENDIF
  WITH outerjoin = d1
 ;end select
 DECLARE bi_value = f8
 SET code_set = 13016
 SET cdf_meaning = "ITEM MASTER"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,bi_value)
 CALL echo(build("Bill_item's ITEM MASTER is: ",bi_value))
 DECLARE id_value = f8
 SET code_set = 11001
 SET cdf_meaning = "ITEM_MASTER"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,id_value)
 CALL echo(build("Item_definition's ITEM_MASTER is: ",id_value))
 RECORD procure(
   1 bill_im[*]
     2 bid = f8
     2 inactivate = i2
     2 delete_ind = i2
 )
 DECLARE countid = i4
 DECLARE inactive_cnt = i4
 DECLARE delete_cnt = i4
 SELECT INTO "nl:"
  b.bill_item_id
  FROM bill_item b,
   dummyt d1,
   item_definition id
  PLAN (b
   WHERE b.ext_parent_contributor_cd=bi_value
    AND b.active_ind=1)
   JOIN (d1)
   JOIN (id
   WHERE id.item_id=b.ext_parent_reference_id
    AND id.item_type_cd=id_value)
  DETAIL
   IF (id.item_id != 0)
    IF (id.active_ind=0)
     countid = (countid+ 1), stat = alterlist(procure->bill_im,countid), procure->bill_im[countid].
     bid = b.bill_item_id,
     procure->bill_im[countid].inactivate = 1, inactive_cnt = (inactive_cnt+ 1)
    ENDIF
   ELSEIF (id.item_id=0)
    countid = (countid+ 1), stat = alterlist(procure->bill_im,countid), procure->bill_im[countid].bid
     = b.bill_item_id,
    procure->bill_im[countid].delete_ind = 1, delete_cnt = (delete_cnt+ 1)
   ENDIF
  WITH outerjoin = d1
 ;end select
 CALL echo(build("IM # to inactivate: ",inactive_cnt))
 CALL echo(build("IM # to delete: ",delete_cnt))
 FOR (q = 1 TO countid)
   IF ((procure->bill_im[q].inactivate=1))
    CALL echo(build("Inactivating IM bill_item_id: ",procure->bill_im[q].bid))
    UPDATE  FROM price_sched_items
     SET active_ind = 0, updt_dt_tm = cnvtdatetime(curdate,curtime), updt_task = 1919191,
      end_effective_dt_tm = cnvtdatetime(curdate,curtime)
     WHERE (bill_item_id=procure->bill_im[q].bid)
    ;end update
    UPDATE  FROM bill_item_modifier
     SET active_ind = 0, updt_dt_tm = cnvtdatetime(curdate,curtime), updt_task = 1919191,
      end_effective_dt_tm = cnvtdatetime(curdate,curtime)
     WHERE (bill_item_id=procure->bill_im[q].bid)
    ;end update
    UPDATE  FROM bill_item
     SET active_ind = 0, updt_dt_tm = cnvtdatetime(curdate,curtime), updt_id = 1919191,
      end_effective_dt_tm = cnvtdatetime(curdate,curtime)
     WHERE (bill_item_id=procure->bill_im[q].bid)
    ;end update
   ELSEIF ((procure->bill_im[q].delete_ind=1))
    CALL echo(build("Deleting IM bill_item_id: ",procure->bill_im[q].bid))
    DELETE  FROM price_sched_items
     WHERE (bill_item_id=procure->bill_im[q].bid)
    ;end delete
    DELETE  FROM bill_item_modifier
     WHERE (bill_item_id=procure->bill_im[q].bid)
    ;end delete
    UPDATE  FROM charge
     SET bill_item_id = 0.0
     WHERE (bill_item_id=procure->bill_im[q].bid)
    ;end update
    DELETE  FROM bill_item
     WHERE (bill_item_id=procure->bill_im[q].bid)
    ;end delete
   ENDIF
 ENDFOR
 SET bbantigen = 0.0
 SET bbspectest = 0.0
 SET bbproduct = 0.0
 SET bbphase = 0.0
 SET bb_code = 0
 SET bb_prod_code = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set IN (13016)
  DETAIL
   IF (cv.cdf_meaning="BBSPECTEST"
    AND cv.code_set=13016)
    bbspectest = cv.code_value,
    CALL echo(concat("BBSPECTEST: ",cnvtstring(bbspectest,17,2)))
   ELSEIF (cv.cdf_meaning="BBANTIGEN"
    AND cv.code_set=13016)
    bbantigen = cv.code_value,
    CALL echo(concat("BBANTIGEN: ",cnvtstring(bbantigen,17,2)))
   ELSEIF (cv.cdf_meaning="BBPRODUCT"
    AND cv.code_set=13016)
    bbproduct = cv.code_value,
    CALL echo(concat("BBPRODUCT: ",cnvtstring(bbproduct,17,2)))
   ELSEIF (cv.cdf_meaning="BBPHASE"
    AND cv.code_set=13016)
    bbphase = cv.code_value,
    CALL echo(concat("BBPHASE: ",cnvtstring(bbphase,17,2)))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  b.bill_item_id
  FROM bill_item b,
   dummyt d1,
   code_value cv
  PLAN (b
   WHERE b.ext_parent_contributor_cd IN (bbspectest, bbantigen, bbproduct, bbphase)
    AND b.active_ind=1)
   JOIN (d1)
   JOIN (cv
   WHERE cv.code_value=b.ext_parent_reference_id
    AND cv.code_set IN (1612, 1601, 1604))
  DETAIL
   IF (cv.code_value != 0
    AND cv.active_ind=0)
    count1 = (count1+ 1), stat = alterlist(bi->bi_l,count1), bi->bi_l[count1].bill_item_id = b
    .bill_item_id,
    bi->bi_l[count1].inactivate = 1
   ELSEIF (cv.code_value=0)
    count1 = (count1+ 1), stat = alterlist(bi->bi_l,count1), bi->bi_l[count1].bill_item_id = b
    .bill_item_id,
    bi->bi_l[count1].delete_ind = 1
   ENDIF
  WITH outerjoin = d1
 ;end select
 SET code_set = 13016
 SET cdf_meaning = "ORD CAT"
 EXECUTE cpm_get_cd_for_cdf
 SET ord_cat = code_value
 SET cdf_meaning = "TASKCAT"
 EXECUTE cpm_get_cd_for_cdf
 SET taskcat = code_value
 CALL echo("  Validating ORDERABLE/ORDER_TASK items")
 SELECT INTO "nl:"
  b.bill_item_id, oc.catalog_cd, otx.reference_task_id
  FROM bill_item b,
   dummyt d1,
   order_task_xref otx,
   dummyt d2,
   order_catalog oc
  PLAN (b
   WHERE b.ext_child_contributor_cd=taskcat
    AND b.ext_parent_contributor_cd=ord_cat
    AND b.active_ind=1)
   JOIN (d1)
   JOIN (otx
   WHERE otx.catalog_cd=b.ext_parent_reference_id
    AND otx.reference_task_id=b.ext_child_reference_id)
   JOIN (d2)
   JOIN (oc
   WHERE oc.catalog_cd=otx.catalog_cd)
  DETAIL
   IF (otx.reference_task_id != 0
    AND oc.active_ind=0)
    count1 = (count1+ 1), stat = alterlist(bi->bi_l,count1), bi->bi_l[count1].bill_item_id = b
    .bill_item_id,
    bi->bi_l[count1].inactivate = 1
   ELSEIF (((otx.reference_task_id=0) OR (oc.catalog_cd=0)) )
    count1 = (count1+ 1), stat = alterlist(bi->bi_l,count1), bi->bi_l[count1].bill_item_id = b
    .bill_item_id,
    bi->bi_l[count1].delete_ind = 1
   ENDIF
  WITH nocounter, outerjoin = d1, outerjoin = d2
 ;end select
 SELECT INTO "nl:"
  b.bill_item_id, ot.reference_task_id
  FROM bill_item b,
   dummyt d1,
   order_task ot
  PLAN (b
   WHERE b.ext_parent_contributor_cd=taskcat
    AND b.active_ind=1)
   JOIN (d1)
   JOIN (ot
   WHERE ot.reference_task_id=b.ext_parent_reference_id)
  DETAIL
   IF (ot.reference_task_id != 0
    AND ot.active_ind=0)
    count1 = (count1+ 1), stat = alterlist(bi->bi_l,count1), bi->bi_l[count1].bill_item_id = b
    .bill_item_id,
    bi->bi_l[count1].inactivate = 1
   ELSEIF (ot.reference_task_id=0)
    count1 = (count1+ 1), stat = alterlist(bi->bi_l,count1), bi->bi_l[count1].bill_item_id = b
    .bill_item_id,
    bi->bi_l[count1].delete_ind = 1
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 CALL echo("                     SELECTS FINISHED                        ")
 CALL echo(build(size(bi->bi_l,5)," items to delete."))
 FOR (x = 1 TO size(bi->bi_l,5))
  CALL echo(build(x,". "),0)
  IF ((bi->bi_l[x].inactivate=1))
   CALL echo(build(" inactivate: ",bi->bi_l[x].bill_item_id))
   CALL echo("     inactivating price_sched_items records...")
   UPDATE  FROM price_sched_items
    SET active_ind = 0, updt_dt_tm = cnvtdatetime(curdate,curtime), updt_task = 88888888,
     end_effective_dt_tm = cnvtdatetime(curdate,curtime)
    WHERE (bill_item_id=bi->bi_l[x].bill_item_id)
   ;end update
   CALL echo(" inactivating bill_item_modifier records...")
   UPDATE  FROM bill_item_modifier
    SET active_ind = 0, updt_dt_tm = cnvtdatetime(curdate,curtime), updt_task = 88888888,
     end_effective_dt_tm = cnvtdatetime(curdate,curtime)
    WHERE (bill_item_id=bi->bi_l[x].bill_item_id)
   ;end update
   CALL echo("     inactivating bill_item...")
   UPDATE  FROM bill_item
    SET active_ind = 0, updt_dt_tm = cnvtdatetime(curdate,curtime), updt_task = 88888888,
     end_effective_dt_tm = cnvtdatetime(curdate,curtime)
    WHERE (bill_item_id=bi->bi_l[x].bill_item_id)
   ;end update
   IF (curqual=0)
    CALL echo("curqual = 0, set x = size of list to break loop.")
    SET x = size(bi->bi_l,5)
   ENDIF
  ELSEIF ((bi->bi_l[x].delete_ind=1))
   CALL echo(build(" delete: ",bi->bi_l[x].bill_item_id))
   CALL echo("     deleting price_sched_items...")
   DELETE  FROM price_sched_items
    WHERE (bill_item_id=bi->bi_l[x].bill_item_id)
   ;end delete
   CALL echo("     deleting bill_item_modifiers...")
   DELETE  FROM bill_item_modifier
    WHERE (bill_item_id=bi->bi_l[x].bill_item_id)
   ;end delete
   CALL echo("     updating charge records with bill_item_id = 0")
   UPDATE  FROM charge
    SET bill_item_id = 0.0
    WHERE (bill_item_id=bi->bi_l[x].bill_item_id)
   ;end update
   DELETE  FROM bill_item
    WHERE (bill_item_id=bi->bi_l[x].bill_item_id)
   ;end delete
   IF (curqual=0)
    CALL echo("curqual = 0, set x = size of list to break loop.")
    SET x = size(bi->bi_l,5)
   ENDIF
  ELSE
   CALL echo("OK")
  ENDIF
 ENDFOR
 RECORD remove_bill_i(
   1 b[*]
     2 bill_item_id = f8
 )
 SET cnt = 0
 SET codeset = 13016
 SET cdf_meaning = "TASK ASSAY"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,task_assay_cd)
 CALL echo(build("the task assay cd is : ",task_assay_cd))
 SELECT INTO "nl:"
  FROM bill_item b,
   profile_task_r p,
   (dummyt a  WITH seq = 1)
  PLAN (b
   WHERE b.active_ind=1
    AND b.ext_parent_reference_id != 0
    AND b.ext_child_contributor_cd=task_assay_cd)
   JOIN (a)
   JOIN (p
   WHERE p.active_ind=1
    AND b.ext_parent_reference_id=p.catalog_cd
    AND b.ext_child_reference_id=p.task_assay_cd)
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(remove_bill_i->b,cnt), remove_bill_i->b[cnt].bill_item_id = b
   .bill_item_id
  WITH outerjoin = a, dontexist
 ;end select
 FOR (x = 1 TO cnt)
  UPDATE  FROM bill_item b
   SET active_ind = 0, updt_id = 13659
   WHERE (b.bill_item_id=remove_bill_i->b[x].bill_item_id)
  ;end update
  CALL echo(build("Inactivating: ",remove_bill_i->b[x].bill_item_id))
 ENDFOR
 CALL echo(build("Inactivated(ptr):  ",(x - 1)," bill_items"))
 SET cnt = 0
 SELECT INTO "nl:"
  FROM bill_item b
  WHERE b.active_ind=1
   AND ((b.ext_parent_contributor_cd=0
   AND b.ext_parent_reference_id != 0) OR (b.ext_child_contributor_cd=0
   AND b.ext_child_reference_id != 0))
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(remove_bill_i->b,cnt), remove_bill_i->b[cnt].bill_item_id = b
   .bill_item_id
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
  UPDATE  FROM bill_item b
   SET active_ind = 0, updt_id = 13659
   WHERE (b.bill_item_id=remove_bill_i->b[x].bill_item_id)
  ;end update
  CALL echo(build("Inactivating: ",remove_bill_i->b[x].bill_item_id))
 ENDFOR
 CALL echo(build("Inactivated:  ",(x - 1)," bill_items"))
 RECORD serv_res(
   1 items[*]
     2 bill_item_id = f8
     2 inactivate_ind = i2
     2 delete_ind = i2
 )
 SET serv_res_count = 0
 SET codeset = 13016
 SET cdf_meaning = "CODEVALUE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,code_value_cd)
 CALL echo(build("the code value cd is : ",code_value_cd))
 SET codeset = 106
 SET cdf_meaning = "GLB"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,gen_lab_cd)
 CALL echo(build("the gen lab cd is : ",gen_lab_cd))
 SET codeset = 106
 SET cdf_meaning = "RADIOLOGY"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,rad_cd)
 CALL echo(build("the rad cd is : ",rad_cd))
 SET codeset = 48
 SET cdf_meaning = "INACTIVE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,inactive_cd)
 CALL echo(build("the inactive cd is : ",inactive_cd))
 SELECT INTO "nl:"
  FROM bill_item b,
   code_value cv,
   dummyt d1
  PLAN (b
   WHERE b.ext_parent_reference_id != 0
    AND b.ext_parent_contributor_cd=code_value_cd
    AND b.ext_child_reference_id=0
    AND b.ext_owner_cd IN (gen_lab_cd, rad_cd)
    AND b.workload_only_ind=1)
   JOIN (d1)
   JOIN (cv
   WHERE cv.code_value=b.ext_parent_reference_id)
  DETAIL
   IF (cv.code_value != 0
    AND cv.active_ind=0)
    serv_res_count = (serv_res_count+ 1), stat = alterlist(serv_res->items,serv_res_count), serv_res
    ->items[serv_res_count].bill_item_id = b.bill_item_id,
    serv_res->items[serv_res_count].inactivate_ind = 1
   ELSEIF (cv.code_value=0)
    serv_res_count = (serv_res_count+ 1), stat = alterlist(serv_res->items,serv_res_count), serv_res
    ->items[serv_res_count].bill_item_id = b.bill_item_id,
    serv_res->items[serv_res_count].delete_ind = 1
   ENDIF
  WITH outerjoin = d1
 ;end select
 CALL echo(build(size(serv_res->items,5)," service resource items to delete/inactivate."))
 FOR (x = 1 TO size(serv_res->items,5))
  CALL echo(build(x,". "),0)
  IF ((serv_res->items[x].inactivate_ind=1))
   CALL echo(build(" inactivate: ",serv_res->items[x].bill_item_id))
   CALL echo("     inactivating price_sched_items records...")
   UPDATE  FROM price_sched_items
    SET active_ind = 0, active_status_cd = inactive_cd, active_status_dt_tm = cnvtdatetime(curdate,
      curtime),
     updt_dt_tm = cnvtdatetime(curdate,curtime), updt_task = 88888888, end_effective_dt_tm =
     cnvtdatetime(curdate,curtime)
    WHERE (bill_item_id=serv_res->items[x].bill_item_id)
   ;end update
   CALL echo(" inactivating bill_item_modifier records...")
   UPDATE  FROM bill_item_modifier
    SET active_ind = 0, active_status_cd = inactive_cd, active_status_dt_tm = cnvtdatetime(curdate,
      curtime),
     updt_dt_tm = cnvtdatetime(curdate,curtime), updt_task = 88888888, end_effective_dt_tm =
     cnvtdatetime(curdate,curtime)
    WHERE (bill_item_id=serv_res->items[x].bill_item_id)
   ;end update
   CALL echo("     inactivating bill_item...")
   UPDATE  FROM bill_item
    SET active_ind = 0, active_status_cd = inactive_cd, active_status_dt_tm = cnvtdatetime(curdate,
      curtime),
     updt_dt_tm = cnvtdatetime(curdate,curtime), updt_task = 88888888, end_effective_dt_tm =
     cnvtdatetime(curdate,curtime)
    WHERE (bill_item_id=serv_res->items[x].bill_item_id)
   ;end update
   IF (curqual=0)
    CALL echo("curqual = 0, set x = size of list to break loop.")
    SET x = size(serv_res->items,5)
   ENDIF
  ELSEIF ((serv_res->items[x].delete_ind=1))
   CALL echo(build(" delete: ",serv_res->items[x].bill_item_id))
   CALL echo("     deleting price_sched_items...")
   DELETE  FROM price_sched_items
    WHERE (bill_item_id=serv_res->items[x].bill_item_id)
   ;end delete
   CALL echo("     deleting bill_item_modifiers...")
   DELETE  FROM bill_item_modifier
    WHERE (bill_item_id=serv_res->items[x].bill_item_id)
   ;end delete
   CALL echo("     updating charge records with bill_item_id = 0")
   UPDATE  FROM charge
    SET bill_item_id = 0.0
    WHERE (bill_item_id=serv_res->items[x].bill_item_id)
   ;end update
   DELETE  FROM bill_item
    WHERE (bill_item_id=serv_res->items[x].bill_item_id)
   ;end delete
   IF (curqual=0)
    CALL echo("curqual = 0, set x = size of list to break loop.")
    SET x = size(serv_res->items,5)
   ENDIF
  ELSE
   CALL echo("OK")
  ENDIF
 ENDFOR
 CALL echo("Validate results and commit if okay.")
 FREE SET bi
 FREE SET remove_bill_i
 FREE SET procure
 FREE SET serv_res
END GO
