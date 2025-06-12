CREATE PROGRAM afc_rpt_audit_billitem:dba
 RECORD reply(
   1 bill_item_qual = i4
   1 bill_item[*]
     2 parent_description = vc
     2 bill_item_id = f8
     2 ext_description = vc
     2 ext_parent_reference_id = f8
     2 ext_parent_contributor_cd = f8
     2 ext_child_reference_id = f8
     2 ext_child_contributor_cd = f8
     2 ext_owner_cd = f8
     2 careset_ind = i2
     2 ext_short_desc = vc
     2 parent_qual_cd = f8
     2 physician_qual_cd = f8
     2 order_seq = i4
     2 status = c5
   1 price_sched_qual = i4
   1 price_sched[*]
     2 bill_item_id = f8
     2 price_sched_id = f8
     2 price_sched_items_id = f8
     2 price = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
   1 bill_item_mod_qual = i4
   1 bill_item_mod[*]
     2 bill_item_id = f8
     2 bill_item_mod_id = f8
     2 bill_item_type_cd = f8
     2 key1_id = f8
     2 key2_id = f8
     2 key4_id = f8
     2 key6 = vc
     2 key7 = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD billitems(
   1 bill_item_qual = i4
   1 qual[*]
     2 careset_id = f8
     2 careset_unit_id = f8
     2 parent_bill_item_id = f8
     2 parent_description = vc
     2 child_bill_item_id = f8
     2 bill_item_id = f8
     2 ext_description = vc
     2 ext_parent_reference_id = f8
     2 ext_parent_contributor_cd = f8
     2 ext_child_reference_id = f8
     2 ext_child_contributor_cd = f8
     2 ext_owner_cd = f8
     2 careset_ind = i2
     2 ext_short_desc = vc
     2 parent_qual_cd = f8
     2 physician_qual_cd = f8
     2 careset_ind = i2
     2 careset_unit_ind = i2
     2 cs_parent_ind = i2
     2 cs_child_ind = i2
     2 cs_default_ind = i2
     2 parent_ind = i2
     2 child_ind = i2
     2 default_ind = i2
     2 status = c5
     2 notcareset = i2
     2 pc_only = i2
     2 pd_only = i2
     2 cpc_only = i2
     2 cpd_only = i2
 )
 IF ((request->bill_item_mod_count > 0))
  SET billitemmodid = fillstring(200," ")
  SET billitemmodid = "bim.key1_id in ("
  SET i = 0
  FOR (i = 1 TO request->bill_item_mod_count)
    IF (i=1)
     SET billitemmodid = build(billitemmodid,cnvtstring(request->bill_item_mod_chosen[1].key1_id,17,2
       ))
    ELSE
     SET billitemmodid = build(billitemmodid,concat(",",cnvtstring(request->bill_item_mod_chosen[i].
        key1_id,17,2)))
    ENDIF
  ENDFOR
 ENDIF
 SET billitemmodid = build(billitemmodid,")")
 SET billitemmodid = trim(billitemmodid)
 CALL echo(billitemmodid)
 IF ((request->price_sched_count > 0))
  SET priceschedid = fillstring(200," ")
  SET priceschedid = "psi.price_sched_id in ("
  SET j = 0
  FOR (j = 1 TO request->price_sched_count)
    IF (j=1)
     SET priceschedid = build(priceschedid,cnvtstring(request->price_sched_chosen[1].price_sched_id,
       17,2))
    ELSE
     SET priceschedid = build(priceschedid,concat(",",cnvtstring(request->price_sched_chosen[j].
        price_sched_id,17,2)))
    ENDIF
  ENDFOR
 ENDIF
 SET priceschedid = build(priceschedid,")")
 SET priceschedid = trim(priceschedid)
 CALL echo(priceschedid)
 EXECUTE afc_rpt_audit_billitem2 parser(
  IF ((request->bill_item_mod_count > 0)) billitemmodid
  ELSE "0 = 0"
  ENDIF
  ), parser(
  IF ((request->price_sched_count > 0)) priceschedid
  ELSE "0 = 0"
  ENDIF
  )
END GO
