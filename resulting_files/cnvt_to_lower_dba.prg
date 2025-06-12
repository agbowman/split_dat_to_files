CREATE PROGRAM cnvt_to_lower:dba
 RECORD newp(
   1 qual[*]
     2 catalog_cd = f8
     2 original = c100
     2 new = c100
 )
 DECLARE primary = f8 WITH constant(uar_get_code_by("MEANING",6011,"PRIMARY"))
 SET cnt = 0
 SELECT INTO "nl:"
  oc.primary_mnemonic
  FROM order_catalog oc
  WHERE oc.catalog_type_cd=2516
   AND oc.active_ind=1
   AND  NOT (oc.orderable_type_flag IN (8.00))
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(newp->qual,cnt), newp->qual[cnt].catalog_cd = oc.catalog_cd,
   newp->qual[cnt].original = oc.primary_mnemonic, newp->qual[cnt].new = oc.primary_mnemonic
  WITH nocounter
 ;end select
 UPDATE  FROM order_catalog oc,
   (dummyt d  WITH seq = value(cnt))
  SET oc.primary_mnemonic = newp->qual[d.seq].new, oc.description = newp->qual[d.seq].new
  PLAN (d)
   JOIN (oc
   WHERE (oc.catalog_cd=newp->qual[d.seq].catalog_cd))
  WITH nocounter
 ;end update
 UPDATE  FROM order_catalog_synonym ocs,
   (dummyt d  WITH seq = value(cnt))
  SET ocs.mnemonic = newp->qual[d.seq].new
  PLAN (d)
   JOIN (ocs
   WHERE (ocs.catalog_cd=newp->qual[d.seq].catalog_cd)
    AND ocs.mnemonic_type_cd=primary)
  WITH nocounter
 ;end update
 COMMIT
END GO
