CREATE PROGRAM bhs_rw_updt_dept_display
 FREE RECORD temp
 RECORD temp(
   1 cnt = i4
   1 rows[*]
     2 catalog_cd = f8
     2 mnemonic = vc
 )
 SELECT
  oc.dept_display_name, ocs.mnemonic
  FROM order_catalog oc,
   order_catalog_synonym ocs
  PLAN (oc
   WHERE oc.active_ind=1
    AND oc.dcp_clin_cat_cd=10580.00
    AND oc.active_ind=1)
   JOIN (ocs
   WHERE oc.catalog_cd=ocs.catalog_cd
    AND oc.dept_display_name != ocs.mnemonic
    AND ocs.mnemonic_type_cd=2583.00
    AND ocs.mnemonic="ED - *")
  ORDER BY ocs.mnemonic_key_cap
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (temp->cnt+ 1), temp->cnt = cnt, stat = alterlist(temp->rows,temp->cnt),
   temp->rows[cnt].catalog_cd = oc.catalog_cd, temp->rows[cnt].mnemonic = ocs.mnemonic
  WITH nocounter
 ;end select
 UPDATE  FROM order_catalog oc,
   (dummyt d  WITH seq = value(temp->cnt))
  SET oc.dept_display_name = temp->rows[d.seq].mnemonic, oc.updt_task = 999
  PLAN (d)
   JOIN (oc
   WHERE (oc.catalog_cd=temp->rows[d.seq].catalog_cd))
  WITH nocounter
 ;end update
 IF ((curqual=temp->cnt))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO
