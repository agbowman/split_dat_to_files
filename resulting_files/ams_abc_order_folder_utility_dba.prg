CREATE PROGRAM ams_abc_order_folder_utility:dba
 PROMPT
  "Order Folder Search (not case-sensitive):" = 0,
  "Collate by type? 'No' if unchecked. If checked, set the collation sequence below for each type:"
   = 0,
  "Enter a value from '1' to '5' for each type. '1' puts that type at the top of the folder." = "",
  "Child Order Folder Sequence" = 0,
  "PowerPlan Sequence" = 0,
  "Regimen Sequence" = 0,
  "Order Sequence" = 0,
  "Task Sequence" = 0
  WITH orderfolder, groupingyesno, generalinfo,
  child_coll_seq, pp_coll_seq, reg_coll_seq,
  order_coll_seq, task_coll_seq
 DECLARE script_name = vc WITH protect, constant("AMS_ABC_ORDER_FOLDER_UTILITY")
 RECORD amsabcofrequest(
   1 alt_sel_category_id = f8
   1 upd_asc_ind = i2
   1 short_description = vc
   1 long_description = vc
   1 child_cat_ind = i2
   1 owner_id = f8
   1 security_flag = i2
   1 updt_cnt = i4
   1 del_aos_ordsents_ind = i2
   1 aosadd_cnt = i4
   1 aosadd_qual[*]
     2 sequence = i4
     2 list_type = i4
     2 synonym_id = f8
     2 child_alt_sel_cat_id = f8
     2 order_sentence_id = f8
     2 pathway_catalog_id = f8
     2 pw_cat_synonym_id = f8
     2 regimen_cat_synonym_id = f8
   1 aosupd_cnt = i4
   1 aosupd_qual[*]
     2 sequence = i4
     2 list_type = i4
     2 synonym_id = f8
     2 child_alt_sel_cat_id = f8
     2 order_sentence_id = f8
     2 pathway_catalog_id = f8
     2 pw_cat_synonym_id = f8
     2 regimen_cat_synonym_id = f8
   1 aosdel_cnt = i4
   1 aosdel_qual[*]
     2 sequence = i4
 )
 EXECUTE ams_define_toolkit_common
 IF (isamsuser(reqinfo->updt_id)=false)
  SELECT INTO "MINE"
   FROM dummyt d
   HEAD REPORT
    row 3, col 20, "ERROR: You are not recognized as an AMS Associate. Operation Denied."
   WITH nocounter
  ;end select
 ENDIF
 DECLARE item_cnt = i4 WITH protect, noconstant(0)
 DECLARE groupyesno = i2 WITH protect, noconstant(0)
 DECLARE altselcatid = f8
 SET groupyesno =  $GROUPINGYESNO
 SET altselcatid =  $ORDERFOLDER
 IF (groupyesno=0)
  SELECT INTO "nl:"
   aslc.alt_sel_category_id, aslc.short_description, aslc.long_description,
   asl.sequence, aslc.child_cat_ind, aslc.owner_id,
   aslc.security_flag, aslc.updt_cnt, asl.list_type,
   asl.synonym_id, asl.order_sentence_id, asl.pw_cat_synonym_id,
   asl.pathway_catalog_id, asl.child_alt_sel_cat_id, asl.reference_task_id,
   asl.regimen_cat_synonym_id, item_mnemonic =
   IF (asl.list_type=1) cnvtupper(aslcc.short_description)
   ELSEIF (asl.list_type=2) cnvtupper(ocs.mnemonic)
   ELSEIF (asl.list_type=4) cnvtupper(otf.task_synonym_desc)
   ELSEIF (asl.list_type=6) cnvtupper(pcs.synonym_name)
   ELSEIF (asl.list_type=7) cnvtupper(reg.synonym_display)
   ENDIF
   FROM alt_sel_list asl,
    alt_sel_cat aslc,
    order_catalog_synonym ocs,
    pw_cat_synonym pcs,
    alt_sel_cat aslcc,
    order_task_synonym_xref otf,
    regimen_cat_synonym reg
   PLAN (aslc
    WHERE aslc.alt_sel_category_id=altselcatid
     AND aslc.owner_id=0.00)
    JOIN (asl
    WHERE aslc.alt_sel_category_id=asl.alt_sel_category_id)
    JOIN (ocs
    WHERE ocs.synonym_id=outerjoin(asl.synonym_id))
    JOIN (pcs
    WHERE pcs.pw_cat_synonym_id=outerjoin(asl.pw_cat_synonym_id))
    JOIN (aslcc
    WHERE aslcc.alt_sel_category_id=outerjoin(asl.child_alt_sel_cat_id))
    JOIN (otf
    WHERE otf.reference_task_id=outerjoin(asl.reference_task_id))
    JOIN (reg
    WHERE reg.regimen_cat_synonym_id=outerjoin(asl.regimen_cat_synonym_id))
   ORDER BY item_mnemonic, asl.sequence
   HEAD REPORT
    item_cnt = 0, amsabcofrequest->alt_sel_category_id = aslc.alt_sel_category_id, amsabcofrequest->
    upd_asc_ind = 0,
    amsabcofrequest->short_description = aslc.short_description, amsabcofrequest->long_description =
    aslc.long_description, amsabcofrequest->child_cat_ind = aslc.child_cat_ind,
    amsabcofrequest->owner_id = aslc.owner_id, amsabcofrequest->security_flag = aslc.security_flag,
    amsabcofrequest->updt_cnt = aslc.updt_cnt,
    amsabcofrequest->del_aos_ordsents_ind = 0, amsabcofrequest->aosadd_cnt = 0
   HEAD asl.sequence
    amsabcofrequest->aosadd_cnt = (amsabcofrequest->aosadd_cnt+ 1), item_cnt = amsabcofrequest->
    aosadd_cnt
    IF (mod(item_cnt,5)=1)
     stat = alterlist(amsabcofrequest->aosadd_qual,(item_cnt+ 4))
    ENDIF
    amsabcofrequest->aosadd_qual[item_cnt].sequence = item_cnt, amsabcofrequest->aosadd_qual[item_cnt
    ].list_type = asl.list_type, amsabcofrequest->aosadd_qual[item_cnt].synonym_id = asl.synonym_id,
    amsabcofrequest->aosadd_qual[item_cnt].child_alt_sel_cat_id = asl.child_alt_sel_cat_id,
    amsabcofrequest->aosadd_qual[item_cnt].order_sentence_id = asl.order_sentence_id, amsabcofrequest
    ->aosadd_qual[item_cnt].pathway_catalog_id = asl.pathway_catalog_id,
    amsabcofrequest->aosadd_qual[item_cnt].pw_cat_synonym_id = asl.pw_cat_synonym_id, amsabcofrequest
    ->aosadd_qual[item_cnt].regimen_cat_synonym_id = asl.regimen_cat_synonym_id
   FOOT REPORT
    stat = alterlist(amsabcofrequest->aosadd_qual,item_cnt), amsabcofrequest->aosupd_cnt = 0,
    amsabcofrequest->aosdel_cnt = 0
   WITH nocounter
  ;end select
  CALL echorecord(amsabcofrequest)
  EXECUTE orm_upd_aos_cat_info:dba  WITH replace("REQUEST","AMSABCOFREQUEST")
 ENDIF
 IF (groupyesno=1)
  DECLARE childcollseq = i4
  DECLARE ppcollseq = i4
  DECLARE ordercollseq = i4
  DECLARE regcollseq = i4
  DECLARE taskcollseq = i4
  SET childcollseq =  $CHILD_COLL_SEQ
  SET ppcollseq =  $PP_COLL_SEQ
  SET ordercollseq =  $ORDER_COLL_SEQ
  SET regcollseq =  $REG_COLL_SEQ
  SET taskcollseq =  $TASK_COLL_SEQ
  SELECT INTO "nl:"
   aslc.alt_sel_category_id, aslc.short_description, aslc.long_description,
   aslc.child_cat_ind, aslc.owner_id, aslc.security_flag,
   aslc.updt_cnt, asl.list_type, asl.synonym_id,
   asl.order_sentence_id, asl.pw_cat_synonym_id, asl.pathway_catalog_id,
   asl.child_alt_sel_cat_id, asl.reference_task_id, asl.regimen_cat_synonym_id,
   item_mnemonic =
   IF (asl.list_type=1) cnvtupper(aslcc.short_description)
   ELSEIF (asl.list_type=2) cnvtupper(ocs.mnemonic)
   ELSEIF (asl.list_type=4) cnvtupper(otf.task_synonym_desc)
   ELSEIF (asl.list_type=6) cnvtupper(pcs.synonym_name)
   ELSEIF (asl.list_type=7) cnvtupper(reg.synonym_display)
   ENDIF
   , coll_seq =
   IF (asl.list_type=1) childcollseq
   ELSEIF (asl.list_type=2) ordercollseq
   ELSEIF (asl.list_type=4) taskcollseq
   ELSEIF (asl.list_type=6) ppcollseq
   ELSEIF (asl.list_type=7) regcollseq
   ENDIF
   FROM alt_sel_list asl,
    alt_sel_cat aslc,
    order_catalog_synonym ocs,
    pw_cat_synonym pcs,
    alt_sel_cat aslcc,
    order_task_synonym_xref otf,
    regimen_cat_synonym reg
   PLAN (aslc
    WHERE aslc.alt_sel_category_id=altselcatid
     AND aslc.owner_id=0.00)
    JOIN (asl
    WHERE aslc.alt_sel_category_id=asl.alt_sel_category_id)
    JOIN (ocs
    WHERE ocs.synonym_id=outerjoin(asl.synonym_id))
    JOIN (pcs
    WHERE pcs.pw_cat_synonym_id=outerjoin(asl.pw_cat_synonym_id))
    JOIN (aslcc
    WHERE aslcc.alt_sel_category_id=outerjoin(asl.child_alt_sel_cat_id))
    JOIN (otf
    WHERE otf.reference_task_id=outerjoin(asl.reference_task_id))
    JOIN (reg
    WHERE reg.regimen_cat_synonym_id=outerjoin(asl.regimen_cat_synonym_id))
   ORDER BY coll_seq, item_mnemonic, asl.sequence
   HEAD REPORT
    item_cnt = 0, amsabcofrequest->alt_sel_category_id = aslc.alt_sel_category_id, amsabcofrequest->
    upd_asc_ind = 0,
    amsabcofrequest->short_description = aslc.short_description, amsabcofrequest->long_description =
    aslc.long_description, amsabcofrequest->child_cat_ind = aslc.child_cat_ind,
    amsabcofrequest->owner_id = aslc.owner_id, amsabcofrequest->security_flag = aslc.security_flag,
    amsabcofrequest->updt_cnt = aslc.updt_cnt,
    amsabcofrequest->del_aos_ordsents_ind = 0, amsabcofrequest->aosadd_cnt = 0
   HEAD asl.sequence
    amsabcofrequest->aosadd_cnt = (amsabcofrequest->aosadd_cnt+ 1), item_cnt = amsabcofrequest->
    aosadd_cnt
    IF (mod(item_cnt,5)=1)
     stat = alterlist(amsabcofrequest->aosadd_qual,(item_cnt+ 4))
    ENDIF
    amsabcofrequest->aosadd_qual[item_cnt].sequence = item_cnt, amsabcofrequest->aosadd_qual[item_cnt
    ].list_type = asl.list_type, amsabcofrequest->aosadd_qual[item_cnt].synonym_id = asl.synonym_id,
    amsabcofrequest->aosadd_qual[item_cnt].child_alt_sel_cat_id = asl.child_alt_sel_cat_id,
    amsabcofrequest->aosadd_qual[item_cnt].order_sentence_id = asl.order_sentence_id, amsabcofrequest
    ->aosadd_qual[item_cnt].pathway_catalog_id = asl.pathway_catalog_id,
    amsabcofrequest->aosadd_qual[item_cnt].pw_cat_synonym_id = asl.pw_cat_synonym_id, amsabcofrequest
    ->aosadd_qual[item_cnt].regimen_cat_synonym_id = asl.regimen_cat_synonym_id
   FOOT REPORT
    stat = alterlist(amsabcofrequest->aosadd_qual,item_cnt), amsabcofrequest->aosupd_cnt = 0,
    amsabcofrequest->aosdel_cnt = 0
   WITH nocounter
  ;end select
  CALL echorecord(amsabcofrequest)
  EXECUTE orm_upd_aos_cat_info  WITH replace("REQUEST","AMSABCOFREQUEST")
 ENDIF
 CALL updtdminfo(script_name,cnvtreal(item_cnt))
 COMMIT
END GO
