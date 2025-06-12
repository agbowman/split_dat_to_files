CREATE PROGRAM dm_mm_item_definition_rows:dba
 SET reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE days_to_keep = i4 WITH noconstant(- (1))
 DECLARE status_to_purge = i4 WITH noconstant(- (1))
 DECLARE rowcount = i4 WITH noconstant(0)
 DECLARE v_errmsg2 = c132
 DECLARE v_err_code2 = i4 WITH noconstant(0)
 DECLARE itemmastercd = f8 WITH noconstant(0.0)
 DECLARE venditmnbrcd = f8 WITH noconstant(0.0)
 DECLARE manfitmnbrcd = f8 WITH noconstant(0.0)
 DECLARE itemvendorcd = f8 WITH noconstant(0.0)
 DECLARE itemmanfcd = f8 WITH noconstant(0.0)
 DECLARE equipmastercd = f8 WITH noconstant(0.0)
 DECLARE activecd = f8 WITH noconstant(0.0)
 DECLARE inactivecd = f8 WITH noconstant(0.0)
 DECLARE dchargeentrycd = f8 WITH noconstant(0.0)
 DECLARE dceitemmastercd = f8 WITH noconstant(0.0)
 DECLARE itemcnt = i4 WITH noconstant(0)
 DECLARE identifiercnt = i4 WITH noconstant(0)
 DECLARE statuswherestr = vc
 DECLARE failed = i2 WITH noconstant(0)
 DECLARE code_set = i4 WITH public, noconstant(0)
 DECLARE code_value = f8 WITH public, noconstant(0.0)
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE qual_value = i4 WITH protect, noconstant(0)
 DECLARE filteredtrans_value = i4 WITH protect, noconstant(0)
 DECLARE barcodecd = f8 WITH protect
 FREE SET xtrans
 RECORD xtrans(
   1 qual[*]
     2 item_id = f8
     2 purge_flag = i2
 )
 FREE SET xfilteredtrans
 RECORD xfilteredtrans(
   1 qual[*]
     2 item_id = f8
     2 purge_flag = i2
     2 identifier_qual[*]
       3 identifier_id = f8
 )
 SET reply->table_name = "ITEM_DEFINITION"
 SET reply->rows_between_commit = 100
 SET venditmnbrcd = uar_get_code_by("MEANING",11000,"VEND_ITM_NBR")
 IF (venditmnbrcd=0)
  SET failed = true
  GO TO exit_script
 ENDIF
 SET manfitmnbrcd = uar_get_code_by("MEANING",11000,"MANF_ITM_NBR")
 IF (manfitmnbrcd=0)
  SET failed = true
  GO TO exit_script
 ENDIF
 SET itemvendorcd = uar_get_code_by("MEANING",11001,"ITEM_VENDOR")
 IF (itemvendorcd=0)
  SET failed = true
  GO TO exit_script
 ENDIF
 SET itemmanfcd = uar_get_code_by("MEANING",11001,"ITEM_MANF")
 IF (itemmanfcd=0)
  SET failed = true
  GO TO exit_script
 ENDIF
 SET itemmastercd = uar_get_code_by("MEANING",11001,"ITEM_MASTER")
 IF (itemmastercd=0)
  SET failed = true
  GO TO exit_script
 ENDIF
 SET equipmastercd = uar_get_code_by("MEANING",11001,"ITEM_EQP")
 IF (equipmastercd=0)
  SET failed = true
  GO TO exit_script
 ENDIF
 SET activecd = uar_get_code_by("MEANING",48,"ACTIVE")
 IF (activecd=0)
  SET failed = true
  GO TO exit_script
 ENDIF
 SET inactivecd = uar_get_code_by("MEANING",48,"INACTIVE")
 IF (inactivecd=0)
  SET failed = true
  GO TO exit_script
 ENDIF
 SET dceitemmastercd = uar_get_code_by("MEANING",13016,"ITEM MASTER")
 IF (dceitemmastercd=0)
  SET failed = true
  GO TO exit_script
 ENDIF
 SET dchargeentrycd = uar_get_code_by("MEANING",13016,"CHARGE ENTRY")
 IF (dchargeentrycd=0)
  SET failed = true
  GO TO exit_script
 ENDIF
 SET barcodecd = uar_get_code_by("MEANING",13019,"BARCODE")
 IF (barcodecd=0)
  SET failed = true
  GO TO exit_script
 ENDIF
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF (cnvtupper(request->tokens[tok_ndx].token_str)="DAYSTOKEEP")
    SET days_to_keep = cnvtreal(request->tokens[tok_ndx].value)
   ELSEIF (cnvtupper(request->tokens[tok_ndx].token_str)="STATUSTOPURGE")
    SET status_to_purge = cnvtreal(request->tokens[tok_ndx].value)
    IF (status_to_purge=1)
     SET statuswherestr = "i.active_status_cd = ActiveCd"
    ELSEIF (status_to_purge=2)
     SET statuswherestr = "i.active_status_cd = InactiveCd"
    ELSEIF (status_to_purge=3)
     SET statuswherestr = "i.active_status_cd in(ActiveCd,InactiveCd)"
    ENDIF
   ENDIF
 ENDFOR
 IF (days_to_keep < 90)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"k1","%1 %2 %3","sss",
   "You must keep at least 90 days worth of data.  You entered ",
   nullterm(trim(cnvtstring(days_to_keep),3))," days or did not enter any value.")
 ELSEIF (((status_to_purge < 1) OR (status_to_purge > 3)) )
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"k2","%1 %2 %3","sss",
   "You must enter a status flag between 1 and 3 to determine which status item to purge.  You entered ",
   nullterm(trim(cnvtstring(status_to_purge),3))," status flag or did not enter any value.")
 ELSE
  SELECT DISTINCT INTO "nl:"
   i.item_id
   FROM item_definition i
   PLAN (i
    WHERE i.item_id > 0
     AND i.item_type_cd IN (itemmastercd, equipmastercd)
     AND i.create_dt_tm < cnvtdatetime((curdate - days_to_keep),curtime3)
     AND parser(statuswherestr))
   ORDER BY i.item_id
   HEAD REPORT
    itemcnt = 0
   DETAIL
    itemcnt = (itemcnt+ 1)
    IF (mod(itemcnt,10)=1)
     stat = alterlist(xtrans->qual,(itemcnt+ 9))
    ENDIF
    xtrans->qual[itemcnt].item_id = i.item_id, xtrans->qual[itemcnt].purge_flag = 1
   FOOT REPORT
    stat = alterlist(xtrans->qual,itemcnt)
   WITH nocounter
  ;end select
  SET qual_value = value(size(xtrans->qual,5))
  IF (qual_value=0)
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ENDIF
  SELECT DISTINCT INTO "nl:"
   p.item_id
   FROM (dummyt d  WITH seq = qual_value),
    pref_card_pick_list p
   PLAN (d)
    JOIN (p
    WHERE (p.item_id=xtrans->qual[d.seq].item_id)
     AND p.item_id > 0)
   ORDER BY p.item_id
   DETAIL
    xtrans->qual[d.seq].purge_flag = 0
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   l.item_master_id
   FROM (dummyt d  WITH seq = qual_value),
    line_item l
   PLAN (d
    WHERE (xtrans->qual[d.seq].purge_flag=1))
    JOIN (l
    WHERE (l.item_master_id=xtrans->qual[d.seq].item_id))
   DETAIL
    xtrans->qual[d.seq].purge_flag = 0
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   tl.item_id
   FROM (dummyt d  WITH seq = qual_value),
    mm_trans_line tl
   PLAN (d
    WHERE (xtrans->qual[d.seq].purge_flag=1))
    JOIN (tl
    WHERE (tl.item_id=xtrans->qual[d.seq].item_id))
   DETAIL
    xtrans->qual[d.seq].purge_flag = 0
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   c.ext_m_reference_id
   FROM (dummyt d  WITH seq = qual_value),
    charge_event c
   PLAN (d
    WHERE (xtrans->qual[d.seq].purge_flag=1))
    JOIN (c
    WHERE (c.ext_m_reference_id=xtrans->qual[d.seq].item_id)
     AND c.ext_m_event_cont_cd=dchargeentrycd
     AND c.ext_m_reference_cont_cd=dceitemmastercd)
   ORDER BY c.ext_m_reference_id
   DETAIL
    xtrans->qual[d.seq].purge_flag = 0
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl"
   FROM (dummyt d  WITH seq = qual_value),
    bill_item b,
    bill_item_modifier bmi
   PLAN (d
    WHERE (xtrans->qual[d.seq].purge_flag=1))
    JOIN (b
    WHERE (b.ext_parent_reference_id=xtrans->qual[d.seq].item_id)
     AND b.ext_parent_contributor_cd=dceitemmastercd
     AND b.active_ind=1)
    JOIN (bmi
    WHERE b.bill_item_id=bmi.bill_item_id)
   DETAIL
    IF (bmi.bill_item_type_cd != barcodecd)
     xtrans->qual[d.seq].purge_flag = 0
    ENDIF
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   FROM (dummyt d  WITH seq = qual_value),
    case_cart_pick_list c
   PLAN (d
    WHERE (xtrans->qual[d.seq].purge_flag=1))
    JOIN (c
    WHERE (c.item_id=xtrans->qual[d.seq].item_id))
   DETAIL
    xtrans->qual[d.seq].purge_flag = 0
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   FROM (dummyt d  WITH seq = qual_value),
    sched_case_pick_list s
   PLAN (d
    WHERE (xtrans->qual[d.seq].purge_flag=1))
    JOIN (s
    WHERE (s.item_id=xtrans->qual[d.seq].item_id))
   DETAIL
    xtrans->qual[d.seq].purge_flag = 0
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   FROM (dummyt d  WITH seq = qual_value),
    sn_implant_log_st l
   PLAN (d
    WHERE (xtrans->qual[d.seq].purge_flag=1))
    JOIN (l
    WHERE (l.item_id=xtrans->qual[d.seq].item_id))
   DETAIL
    xtrans->qual[d.seq].purge_flag = 0
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = qual_value)
   PLAN (d
    WHERE (xtrans->qual[d.seq].purge_flag=1))
   HEAD REPORT
    itemcnt = 0
   DETAIL
    itemcnt = (itemcnt+ 1)
    IF (itemcnt <= value(request->max_rows))
     stat = alterlist(xfilteredtrans->qual,itemcnt), xfilteredtrans->qual[itemcnt].item_id = xtrans->
     qual[d.seq].item_id, xfilteredtrans->qual[itemcnt].purge_flag = 1
    ENDIF
   WITH nocounter
  ;end select
  SET filteredtrans_value = value(size(xfilteredtrans->qual,5))
  IF (filteredtrans_value=0)
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ENDIF
  SELECT DISTINCT INTO "nl:"
   o1.object_id
   FROM (dummyt d  WITH seq = filteredtrans_value),
    object_identifier_index o,
    object_identifier_index o1
   PLAN (d
    WHERE (xfilteredtrans->qual[d.seq].purge_flag=1))
    JOIN (o
    WHERE (o.object_id=xfilteredtrans->qual[d.seq].item_id)
     AND o.identifier_type_cd=venditmnbrcd
     AND o.rel_parent_entity_id=0)
    JOIN (o1
    WHERE o.identifier_id=o1.identifier_id
     AND o1.object_type_cd=itemvendorcd
     AND o1.rel_parent_entity_id=0)
   ORDER BY o1.object_id
   HEAD REPORT
    itemcnt = 0, itemcnt = size(xfilteredtrans->qual,5)
   HEAD o1.object_id
    itemcnt = (itemcnt+ 1), stat = alterlist(xfilteredtrans->qual,itemcnt), xfilteredtrans->qual[
    itemcnt].item_id = o1.object_id,
    xfilteredtrans->qual[itemcnt].purge_flag = 2
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   o1.object_id
   FROM (dummyt d  WITH seq = filteredtrans_value),
    object_identifier_index o,
    object_identifier_index o1
   PLAN (d
    WHERE (xfilteredtrans->qual[d.seq].purge_flag=1))
    JOIN (o
    WHERE (o.object_id=xfilteredtrans->qual[d.seq].item_id)
     AND o.identifier_type_cd=manfitmnbrcd
     AND o.rel_parent_entity_id=0)
    JOIN (o1
    WHERE o.identifier_id=o1.identifier_id
     AND o1.object_type_cd=itemmanfcd
     AND o1.rel_parent_entity_id=0)
   ORDER BY o1.object_id
   HEAD REPORT
    itemcnt = 0, itemcnt = size(xfilteredtrans->qual,5)
   HEAD o1.object_id
    itemcnt = (itemcnt+ 1), stat = alterlist(xfilteredtrans->qual,itemcnt), xfilteredtrans->qual[
    itemcnt].item_id = o1.object_id,
    xfilteredtrans->qual[itemcnt].purge_flag = 3
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   l.vendor_item_id
   FROM (dummyt d  WITH seq = filteredtrans_value),
    line_item l
   PLAN (d
    WHERE (xfilteredtrans->qual[d.seq].purge_flag=2))
    JOIN (l
    WHERE (l.vendor_item_id=xfilteredtrans->qual[d.seq].item_id))
   DETAIL
    xfilteredtrans->qual[d.seq].purge_flag = 0
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   l.manuf_item_id
   FROM (dummyt d  WITH seq = filteredtrans_value),
    line_item l
   PLAN (d
    WHERE (xfilteredtrans->qual[d.seq].purge_flag=3))
    JOIN (l
    WHERE (l.manuf_item_id=xfilteredtrans->qual[d.seq].item_id))
   DETAIL
    xfilteredtrans->qual[d.seq].purge_flag = 0
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   i.rowid
   FROM (dummyt d  WITH seq = filteredtrans_value),
    item_definition i
   PLAN (d
    WHERE (xfilteredtrans->qual[d.seq].purge_flag > 0))
    JOIN (i
    WHERE (i.item_id=xfilteredtrans->qual[d.seq].item_id))
   HEAD REPORT
    rowcount = 0
   DETAIL
    rowcount = (rowcount+ 1)
    IF (mod(rowcount,10)=1)
     stat = alterlist(reply->rows,(rowcount+ 9))
    ENDIF
    reply->rows[rowcount].row_id = i.rowid
   FOOT REPORT
    stat = alterlist(reply->rows,rowcount)
   WITH nocounter
  ;end select
  SET request->max_rows = value(size(reply->rows,5))
  CALL echo(build("Size of xFilteredTrans qual:",filteredtrans_value))
  CALL echo(build("Size of items to be purged:",value(size(reply->rows,5))))
  CALL echo(build("Request->purge_flag is :",request->purge_flag))
  IF ((request->purge_flag != 3))
   SELECT DISTINCT INTO "nl:"
    o.identifier_id
    FROM (dummyt d  WITH seq = filteredtrans_value),
     object_identifier o
    PLAN (d
     WHERE (xfilteredtrans->qual[d.seq].purge_flag > 0))
     JOIN (o
     WHERE (o.object_id=xfilteredtrans->qual[d.seq].item_id)
      AND o.identifier_id > 0)
    ORDER BY o.object_id, o.identifier_id
    HEAD o.object_id
     identifiercnt = 0
    HEAD o.identifier_id
     identifiercnt = (identifiercnt+ 1)
     IF (mod(identifiercnt,10)=1)
      stat = alterlist(xfilteredtrans->qual[d.seq].identifier_qual,(identifiercnt+ 9))
     ENDIF
     xfilteredtrans->qual[d.seq].identifier_qual[identifiercnt].identifier_id = o.identifier_id
    FOOT  o.object_id
     stat = alterlist(xfilteredtrans->qual[d.seq].identifier_qual,identifiercnt)
    WITH nocounter
   ;end select
   SET totalcnt = 0
   SET batchcnt = 0
   SET offsetcnt = 0
   SET totalcnt = size(xfilteredtrans->qual,5)
   SET batchcnt = 100
   WHILE (totalcnt > 0)
     IF (totalcnt >= batchcnt)
      SET totalcnt = (totalcnt - batchcnt)
     ELSE
      SET batchcnt = totalcnt
      SET totalcnt = 0
     ENDIF
     DELETE  FROM object_identifier_index oii,
       (dummyt d  WITH seq = value(batchcnt))
      SET oii.seq = 1
      PLAN (d
       WHERE (xfilteredtrans->qual[(d.seq+ offsetcnt)].purge_flag > 0))
       JOIN (oii
       WHERE (oii.object_id=xfilteredtrans->qual[(d.seq+ offsetcnt)].item_id))
      WITH nocounter
     ;end delete
     DELETE  FROM object_identifier oi,
       (dummyt d  WITH seq = value(batchcnt))
      SET oi.seq = 1
      PLAN (d
       WHERE (xfilteredtrans->qual[(d.seq+ offsetcnt)].purge_flag > 0))
       JOIN (oi
       WHERE (oi.object_id=xfilteredtrans->qual[(d.seq+ offsetcnt)].item_id))
      WITH nocounter
     ;end delete
     DELETE  FROM identifier i,
       (dummyt d  WITH seq = value(batchcnt)),
       (dummyt d1  WITH seq = 1)
      SET i.seq = 1
      PLAN (d
       WHERE maxrec(d1,size(xfilteredtrans->qual[(d.seq+ offsetcnt)].identifier_qual,5))
        AND (xfilteredtrans->qual[d.seq].purge_flag > 0))
       JOIN (d1)
       JOIN (i
       WHERE (i.identifier_id=xfilteredtrans->qual[(d.seq+ offsetcnt)].identifier_qual[d1.seq].
       identifier_id)
        AND i.identifier_id > 0)
      WITH nocounter
     ;end delete
     SET offsetcnt = (offsetcnt+ batchcnt)
     COMMIT
   ENDWHILE
  ENDIF
 ENDIF
 SET v_err_code2 = error(v_errmsg2,1)
 IF (v_err_code2=0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->err_code = v_err_code2
  SET reply->err_msg = v_errmsg2
 ENDIF
#exit_script
 IF (failed=true)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"k1","%1 %2 %3","sss","The cdf_meaning  ",
   nullterm(trim(cnvtstring(cdf_meaning),3))," is a necessary code value & could not be retrieved. ")
 ENDIF
END GO
