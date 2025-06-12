CREATE PROGRAM bed_clean_bb_product_barcode
 DELETE  FROM product_barcode pb
  WHERE pb.product_barcode <= " "
  WITH nocounter
 ;end delete
 RECORD bc(
   1 bcode[*]
     2 product_cd = f8
     2 codes[*]
       3 barcode = vc
       3 id = f8
       3 del_ind = i2
 )
 DECLARE pcnt = i4
 DECLARE bcnt = i4
 DECLARE tcnt = i4
 DECLARE tvar = i2
 SET pcnt = 0
 SELECT INTO "nl:"
  FROM product_barcode pb
  PLAN (pb
   WHERE pb.active_ind=1)
  ORDER BY pb.product_cd
  HEAD pb.product_cd
   pcnt = (pcnt+ 1), bcnt = 0, stat = alterlist(bc->bcode,pcnt),
   bc->bcode[pcnt].product_cd = pb.product_cd
  DETAIL
   bcnt = (bcnt+ 1), stat = alterlist(bc->bcode[pcnt].codes,bcnt), bc->bcode[pcnt].codes[bcnt].id =
   pb.product_barcode_id,
   bc->bcode[pcnt].codes[bcnt].barcode = pb.product_barcode, bc->bcode[pcnt].codes[bcnt].del_ind = 0
  WITH nocounter
 ;end select
 FOR (ii = 1 TO pcnt)
  SET tcnt = size(bc->bcode[ii].codes,5)
  IF (tcnt > 1)
   FOR (jj = 1 TO (tcnt - 1))
    IF ((bc->bcode[ii].codes[jj].del_ind=0))
     SET bc->bcode[ii].codes[jj].del_ind = 2
    ENDIF
    FOR (kk = (jj+ 1) TO tcnt)
      IF ((bc->bcode[ii].codes[jj].barcode=bc->bcode[ii].codes[kk].barcode))
       SET bc->bcode[ii].codes[kk].del_ind = 1
      ENDIF
    ENDFOR
   ENDFOR
  ENDIF
 ENDFOR
 CALL echorecord(bc)
 FOR (ii = 1 TO pcnt)
  SET tcnt = size(bc->bcode[ii].codes,5)
  FOR (jj = 1 TO tcnt)
    IF ((bc->bcode[ii].codes[jj].del_ind=1))
     DELETE  FROM product_barcode pb
      WHERE (pb.product_barcode_id=bc->bcode[ii].codes[jj].id)
      WITH nocounter
     ;end delete
    ENDIF
  ENDFOR
 ENDFOR
END GO
