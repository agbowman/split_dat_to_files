CREATE PROGRAM afc_fix_owner_codes:dba
 RECORD billitems(
   1 bill_item_qual = i2
   1 bill_item[*]
     2 bill_item_id = f8
     2 owner_cd = f8
 )
 IF (validate(request->ops_date,999)=999)
  EXECUTE cclseclogin
  SET message = nowindow
 ENDIF
 SET ord_cat_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=13016
   AND cv.active_ind=1
   AND cv.cdf_meaning="ORD CAT"
  DETAIL
   ord_cat_cd = cv.code_value
  WITH nocounter
 ;end select
 CALL echo(build("ord_cat code_value is : ",ord_cat_cd))
 SET count1 = 0
 SET stat = alterlist(billitems->bill_item,count1)
 SELECT INTO "nl:"
  b.bill_item_id, b.ext_owner_cd, o.activity_type_cd,
  o.catalog_cd
  FROM bill_item b,
   order_catalog o
  PLAN (b
   WHERE b.active_ind=1
    AND b.ext_parent_contributor_cd=ord_cat_cd
    AND b.ext_child_reference_id=0)
   JOIN (o
   WHERE o.catalog_cd=b.ext_parent_reference_id
    AND b.ext_owner_cd != o.activity_type_cd
    AND o.active_ind=1)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(billitems->bill_item,count1), billitems->bill_item[count1].
   bill_item_id = b.bill_item_id,
   billitems->bill_item[count1].owner_cd = o.activity_type_cd
  WITH nocounter
 ;end select
 CALL echo(build("Parents to update : ",count1))
 SET billitems->bill_item_qual = count1
 SET stat = alterlist(billitems->bill_item,count1)
 FOR (x = 1 TO billitems->bill_item_qual)
   UPDATE  FROM bill_item b
    SET b.ext_owner_cd = billitems->bill_item[x].owner_cd
    WHERE (b.bill_item_id=billitems->bill_item[x].bill_item_id)
    WITH nocounter
   ;end update
 ENDFOR
 CALL echo("Commit go if results are correct.")
 CALL echo("Fixing child dta owner codes...")
 EXECUTE afc_fix_child_owner_codes
END GO
