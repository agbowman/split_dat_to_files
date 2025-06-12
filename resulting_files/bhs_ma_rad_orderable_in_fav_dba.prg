CREATE PROGRAM bhs_ma_rad_orderable_in_fav:dba
 PROMPT
  "Defaut Prompt for any error messages:" = "MINE",
  "Catalog_cd('0' for all rad. orderables)" = 0
  WITH outdev, catcd
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 synonym_id = f8
 )
 DECLARE radiology = f8 WITH protect, constant(711.0)
 DECLARE x = i4
 SELECT INTO "NL:"
  FROM order_catalog_synonym ocs
  PLAN (ocs
   WHERE (((ocs.catalog_cd= $CATCD)
    AND ( $CATCD > 0)) OR (( $CATCD=0)
    AND ocs.activity_type_cd=radiology)) )
  HEAD REPORT
   x = 0
  DETAIL
   x = (x+ 1), stat = alterlist(temp->qual,x), temp->qual[x].synonym_id = ocs.synonym_id
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO  $OUTDEV
  als.synonym_id, p.name_full_formatted, ocs.mnemonic,
  als.*
  FROM alt_sel_list als,
   alt_sel_cat as1,
   order_catalog_synonym ocs,
   person p,
   (dummyt d  WITH seq = size(temp->qual,5))
  PLAN (d)
   JOIN (als
   WHERE (als.synonym_id=temp->qual[d.seq].synonym_id)
    AND als.synonym_id > 0)
   JOIN (ocs
   WHERE ocs.synonym_id=als.synonym_id)
   JOIN (as1
   WHERE as1.alt_sel_category_id=als.alt_sel_category_id
    AND as1.security_flag=1)
   JOIN (p
   WHERE p.person_id=as1.owner_id)
  ORDER BY p.name_full_formatted, als.synonym_id
  WITH format, nocounter
 ;end select
END GO
