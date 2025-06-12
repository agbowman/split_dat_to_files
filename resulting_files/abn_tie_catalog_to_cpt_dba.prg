CREATE PROGRAM abn_tie_catalog_to_cpt:dba
 RECORD cpt_cat(
   1 list[*]
     2 cpt_nomen_id = f8
     2 catalog_cd = f8
 )
 RECORD request(
   1 abn_cross_reference_qual = i2
   1 abn_cross_reference[*]
     2 abn_cross_reference_id = f8
     2 catalog_cd = f8
     2 cpt_nomen_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
 )
 SET ord_cat = 0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=13016
   AND cv.cdf_meaning="ORD CAT"
  DETAIL
   ord_cat = cv.code_value
  WITH nocounter
 ;end select
 CALL read_cpt_catalog("dummy")
 CALL cross_check_cross_reference("dummy")
 CALL echo("Adding records to abn_cross_reference...")
 EXECUTE abn_add_cross_reference
 COMMIT
 GO TO end_prog
 SUBROUTINE read_cpt_catalog(dummyvar)
   CALL echo("Reading bill_item_modifier/bill_item to get CPT/CATALOG combinations...")
   SET count1 = 0
   SELECT INTO "nl:"
    b.ext_parent_reference_id, bm.key3_id, cv.code_value
    FROM bill_item b,
     bill_item_modifier bm,
     code_value cv
    WHERE b.ext_parent_contributor_cd=ord_cat
     AND b.ext_child_reference_id=0
     AND bm.bill_item_id=b.bill_item_id
     AND bm.key3_id > 0
     AND bm.key1_id=cv.code_value
     AND cv.code_set=14002
     AND cv.cdf_meaning="CPT4"
    DETAIL
     count1 = (count1+ 1), stat = alterlist(cpt_cat->list,count1), cpt_cat->list[count1].cpt_nomen_id
      = bm.key3_id,
     cpt_cat->list[count1].catalog_cd = b.ext_parent_reference_id
    WITH nocounter
   ;end select
   CALL echo(build("Found: ",count1))
 END ;Subroutine
 SUBROUTINE cross_check_cross_reference(dummyvar)
   CALL echo("Checking abn_cross_reference to avoid duplicates...")
   SET count1 = 0
   SELECT INTO "nl:"
    catalog = cpt_cat->list[d1.seq].catalog_cd, nomen = cpt_cat->list[d1.seq].cpt_nomen_id, abn
    .catalog_cd,
    abn.cpt_nomen_id
    FROM abn_cross_reference abn,
     (dummyt d1  WITH seq = value(size(cpt_cat->list,5))),
     (dummyt d2  WITH seq = 1)
    PLAN (d1)
     JOIN (d2)
     JOIN (abn
     WHERE (abn.catalog_cd=cpt_cat->list[d1.seq].catalog_cd)
      AND (abn.cpt_nomen_id=cpt_cat->list[d1.seq].cpt_nomen_id))
    DETAIL
     count1 = (count1+ 1), stat = alterlist(request->abn_cross_reference,count1), request->
     abn_cross_reference_qual = count1,
     request->abn_cross_reference[count1].catalog_cd = cpt_cat->list[d1.seq].catalog_cd, request->
     abn_cross_reference[count1].cpt_nomen_id = cpt_cat->list[d1.seq].cpt_nomen_id, request->
     abn_cross_reference[count1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     request->abn_cross_reference[count1].end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59"),
     request->abn_cross_reference[count1].active_ind_ind = 1, request->abn_cross_reference[count1].
     active_ind = 1
    WITH nocounter, outerjoin = d2, dontexist
   ;end select
   CALL echo(build("will add: ",count1))
 END ;Subroutine
#end_prog
END GO
