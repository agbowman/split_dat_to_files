CREATE PROGRAM afc_fix_careset_comp:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 RECORD bill_items(
   1 bill_items[*]
     2 bill_item_id = f8
     2 activity_type_cd = f8
 )
 SET ord_cat_cd = 0.0
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=13016
   AND a.cdf_meaning="ORD CAT"
   AND a.active_ind=1
  DETAIL
   ord_cat_cd = a.code_value
  WITH nocounter
 ;end select
 SET readme_data->message = build("the ord cat code value is : ",ord_cat_cd)
 SET count = 0
 SELECT INTO "nl:"
  FROM bill_item b,
   order_catalog o
  PLAN (b
   WHERE b.ext_parent_contributor_cd=ord_cat_cd
    AND b.ext_child_contributor_cd=ord_cat_cd
    AND b.active_ind=1)
   JOIN (o
   WHERE o.catalog_cd=b.ext_child_reference_id)
  DETAIL
   count = (count+ 1), stat = alterlist(bill_items->bill_items,count), bill_items->bill_items[count].
   bill_item_id = b.bill_item_id,
   bill_items->bill_items[count].activity_type_cd = o.activity_type_cd
  WITH nocounter
 ;end select
 SET readme_data->message = build("the number of items is : ",value(size(bill_items->bill_items,5)))
 FOR (number = 1 TO value(size(bill_items->bill_items,5)))
   UPDATE  FROM bill_item
    SET ext_owner_cd = bill_items->bill_items[number].activity_type_cd, updt_id = 13659000
    WHERE (bill_item_id=bill_items->bill_items[number].bill_item_id)
   ;end update
 ENDFOR
 COMMIT
 SET readme_data->status = "S"
 SET readme_data->message = "Careset components properly updated."
 EXECUTE dm_readme_status
END GO
