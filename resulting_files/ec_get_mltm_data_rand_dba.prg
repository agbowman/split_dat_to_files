CREATE PROGRAM ec_get_mltm_data_rand:dba
 PROMPT
  "Select output: " = "MINE"
  WITH outdev
 DECLARE dpharmcd = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 FREE RECORD mltm
 RECORD mltm(
   1 qualcnt = i4
   1 qual[*]
     2 catalog_cd = f8
     2 primary_mnem = vc
     2 cat_cki = vc
     2 synonym_id = f8
     2 mnemonic = vc
     2 mnem_type = vc
     2 mnem_format = vc
     2 cki = vc
     2 active_ind = i2
     2 hide_flag = i2
     2 drug_synonym_id = f8
     2 drug_name = vc
     2 is_obsolete = vc
     2 mltm_synonym = vc
     2 mltm_type = vc
     2 mltm_format = vc
 )
 SELECT INTO "nl:"
  FROM order_catalog oc,
   order_catalog_synonym ocs,
   order_entry_format_parent oef,
   mltm_drug_name mdn,
   mltm_order_catalog_load mocl
  PLAN (oc
   WHERE oc.catalog_type_cd=dpharmcd
    AND oc.orderable_type_flag != 6)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ((isnumeric(substring(13,6,ocs.cki)) != 0
    AND ocs.cki="MUL.ORD-SYN*") OR (ocs.cki=null)) )
   JOIN (oef
   WHERE oef.oe_format_id=outerjoin(ocs.oe_format_id))
   JOIN (mdn
   WHERE mdn.drug_synonym_id=outerjoin(cnvtreal(substring(13,6,ocs.cki))))
   JOIN (mocl
   WHERE mocl.synonym_cki=outerjoin(ocs.cki))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(mltm->qual,cnt), mltm->qual[cnt].catalog_cd = oc.catalog_cd,
   mltm->qual[cnt].primary_mnem = oc.primary_mnemonic, mltm->qual[cnt].cat_cki = oc.cki, mltm->qual[
   cnt].synonym_id = ocs.synonym_id,
   mltm->qual[cnt].mnemonic = ocs.mnemonic, mltm->qual[cnt].mnem_type = uar_get_code_display(ocs
    .mnemonic_type_cd), mltm->qual[cnt].mnem_format = oef.oe_format_name,
   mltm->qual[cnt].cki = ocs.cki, mltm->qual[cnt].active_ind = ocs.active_ind, mltm->qual[cnt].
   hide_flag = ocs.hide_flag,
   mltm->qual[cnt].drug_synonym_id = mdn.drug_synonym_id, mltm->qual[cnt].drug_name = mdn.drug_name,
   mltm->qual[cnt].is_obsolete = mdn.is_obsolete,
   mltm->qual[cnt].mltm_synonym = mocl.mnemonic, mltm->qual[cnt].mltm_type = mocl.mnemonic_type, mltm
   ->qual[cnt].mltm_format = mocl.order_entry_format
  FOOT REPORT
   mltm->qualcnt = cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog oc,
   order_catalog_synonym ocs,
   order_entry_format_parent oef
  PLAN (oc
   WHERE oc.catalog_type_cd=dpharmcd)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ((isnumeric(substring(13,6,ocs.cki))=0) OR (ocs.cki != "MUL.ORD-SYN*")) )
   JOIN (oef
   WHERE oef.oe_format_id=outerjoin(ocs.oe_format_id))
  HEAD REPORT
   cnt = mltm->qualcnt
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(mltm->qual,cnt), mltm->qual[cnt].catalog_cd = oc.catalog_cd,
   mltm->qual[cnt].primary_mnem = oc.primary_mnemonic, mltm->qual[cnt].cat_cki = oc.cki, mltm->qual[
   cnt].synonym_id = ocs.synonym_id,
   mltm->qual[cnt].mnemonic = ocs.mnemonic, mltm->qual[cnt].mnem_type = uar_get_code_display(ocs
    .mnemonic_type_cd), mltm->qual[cnt].mnem_format = oef.oe_format_name,
   mltm->qual[cnt].cki = ocs.cki, mltm->qual[cnt].active_ind = ocs.active_ind, mltm->qual[cnt].
   hide_flag = ocs.hide_flag
  FOOT REPORT
   mltm->qualcnt = cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM mltm_order_catalog_load mocl,
   mltm_drug_name mdn,
   order_catalog_synonym ocs
  PLAN (mocl)
   JOIN (mdn
   WHERE mdn.drug_synonym_id=outerjoin(cnvtreal(substring(13,6,mocl.synonym_cki))))
   JOIN (ocs
   WHERE ocs.cki=outerjoin(mocl.synonym_cki)
    AND ((ocs.catalog_type_cd+ 0)=outerjoin(dpharmcd)))
  HEAD REPORT
   cnt = mltm->qualcnt
  DETAIL
   IF (trim(ocs.cki)="")
    cnt = (cnt+ 1), stat = alterlist(mltm->qual,cnt), mltm->qual[cnt].drug_synonym_id = mdn
    .drug_synonym_id,
    mltm->qual[cnt].drug_name = mdn.drug_name, mltm->qual[cnt].is_obsolete = mdn.is_obsolete, mltm->
    qual[cnt].mltm_synonym = mocl.mnemonic,
    mltm->qual[cnt].mltm_type = mocl.mnemonic_type, mltm->qual[cnt].mltm_format = mocl
    .order_entry_format
   ENDIF
  FOOT REPORT
   mltm->qualcnt = cnt
  WITH nocounter
 ;end select
 SELECT INTO value( $OUTDEV)
  cat_cd = mltm->qual[d.seq].catalog_cd, prim_mnem = substring(1,100,mltm->qual[d.seq].primary_mnem),
  cat_cki = substring(1,40,mltm->qual[d.seq].cat_cki),
  syn_id = mltm->qual[d.seq].synonym_id, mnemonic = substring(1,100,mltm->qual[d.seq].mnemonic),
  mnem_type = substring(1,60,mltm->qual[d.seq].mnem_type),
  mnem_format = substring(1,60,mltm->qual[d.seq].mnem_format), syn_cki = substring(1,40,mltm->qual[d
   .seq].cki), active_ind = mltm->qual[d.seq].active_ind,
  hide_flag = mltm->qual[d.seq].hide_flag, drug_syn_id = mltm->qual[d.seq].drug_synonym_id, drug_name
   = substring(1,100,mltm->qual[d.seq].drug_name),
  is_obsolete = mltm->qual[d.seq].is_obsolete, mltm_syn = substring(1,100,mltm->qual[d.seq].
   mltm_synonym), mltm_type = substring(1,100,mltm->qual[d.seq].mltm_type),
  mltm_format = substring(1,60,mltm->qual[d.seq].mltm_format)
  FROM (dummyt d  WITH seq = value(mltm->qualcnt))
  PLAN (d)
  WITH nocounter, format, separator = " "
 ;end select
END GO
