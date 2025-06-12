CREATE PROGRAM bbd_get_mod_family:dba
 RECORD request(
   1 product_id = f8
 )
 RECORD productlist(
   1 product[*]
     2 product_id = f8
     2 product_nbr = vc
     2 lock_ind = i2
 )
 SET ncurrentcount = 1
 SET nlastcount = 0
 SET ntemp = 0
 SET nchildren = 1
 SET nroot = 1
 SET root_product_id = 0.0
 SET stat = alterlist(productlist->product,ncurrentcount)
 SET modified_product_id = 4128
 WHILE (nroot=1)
  SET nroot = 0
  SELECT INTO "nl:"
   p.product_id, p.modified_product_id
   FROM product p
   PLAN (p
    WHERE p.product_id=modified_product_id)
   DETAIL
    IF (p.modified_product_id > 0.0)
     modified_product_id = p.modified_product_id, nroot = 1
    ELSE
     nroot = 0
    ENDIF
   WITH nocounter
  ;end select
 ENDWHILE
 SET productlist->product[ncurrentcount].product_id = modified_product_id
 WHILE (nchildren=1)
   SET nchildren = 0
   SELECT INTO "nl:"
    p.product_id, p.modified_product_id, p.modified_product_ind,
    p.locked_ind
    FROM (dummyt d1  WITH seq = value(ncurrentcount)),
     product p
    PLAN (d1
     WHERE d1.seq > nlastcount
      AND d1.seq <= ncurrentcount)
     JOIN (p
     WHERE (p.modified_product_id=productlist->product[d1.seq].product_id))
    HEAD REPORT
     ntemp = ncurrentcount
    DETAIL
     ncurrentcount = (ncurrentcount+ 1), stat = alterlist(productlist->product,ncurrentcount),
     productlist->product[ncurrentcount].product_id = p.product_id,
     productlist->product[ncurrentcount].product_nbr = p.product_nbr, productlist->product[
     ncurrentcount].lock_ind = p.locked_ind
     IF (p.locked_ind=1)
      nlockedind = 1
     ENDIF
     IF (p.modified_product_ind=1)
      nchildren = 1
     ENDIF
    WITH nocounter
   ;end select
   SET nlastcount = ntemp
 ENDWHILE
#exit_script
END GO
