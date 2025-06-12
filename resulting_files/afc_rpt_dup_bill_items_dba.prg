CREATE PROGRAM afc_rpt_dup_bill_items:dba
 FREE SET reqinfo
 RECORD reqinfo(
   1 commit_ind = i4
   1 updt_id = f8
   1 updt_applctx = i4
   1 updt_task = i4
 )
 SET reqinfo->updt_id = 4444
 SET reqinfo->updt_applctx = 951000
 SET reqinfo->updt_task = 951888
 FREE SET request
 RECORD request(
   1 bill_item_qual = i2
   1 bill_item[0]
     2 bill_item_id = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 ext_parent_reference_id = f8
     2 ext_parent_contributor_cd = f8
     2 ext_child_reference_id = f8
     2 ext_child_contributor_cd = f8
     2 ext_description = c100
     2 ext_short_desc = c50
     2 ext_owner_cd = f8
     2 charge_point_cd = f8
     2 parent_qual_ind = f8
     2 physician_qual_cd = f8
 )
 SET prev_id = 0.0
 SET prev_cd = 0.0
 SET prev_child_id = 0.0
 SET count1 = 0
 SELECT
  b.bill_item_id, b.ext_parent_reference_id, b.ext_parent_contributor_cd,
  b.ext_child_reference_id, b.ext_child_contributor_cd, desc = substring(0,50,b.ext_description),
  short_desc = trim(b.ext_short_desc), b.active_status_cd
  FROM bill_item b
  WHERE b.ext_parent_reference_id != 0
   AND b.ext_child_reference_id != 0
   AND b.active_ind=1
  ORDER BY b.ext_parent_reference_id, b.ext_child_reference_id
  HEAD REPORT
   col 01, "Duplicate Bill Items Report.  Duplicates are marked with a '~'.", row + 1
  HEAD b.ext_parent_reference_id
   row + 1, col 01, "*****",
   row + 1, col 03, b.bill_item_id,
   col 18, b.ext_parent_reference_id, col 33,
   b.ext_parent_contributor_cd, col 48, desc,
   row + 1, prev_id = b.ext_parent_reference_id, prev_cd = b.ext_parent_contributor_cd,
   prev_child_id = b.ext_child_reference_id, count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (b.ext_parent_reference_id=prev_id
    AND b.ext_parent_contributor_cd=prev_cd
    AND b.ext_child_reference_id=prev_child_id
    AND count1 != 1)
    col 01, "~", col 03,
    b.bill_item_id, col 18, b.ext_parent_reference_id,
    col 33, b.ext_parent_contributor_cd, col 48,
    desc, row + 1, request->bill_item_qual = (request->bill_item_qual+ 1),
    stat = alter(request->bill_item,request->bill_item_qual), request->bill_item[request->
    bill_item_qual].bill_item_id = b.bill_item_id, request->bill_item[request->bill_item_qual].
    active_status_cd = b.active_status_cd
   ENDIF
  WITH nocounter
 ;end select
 IF (( $1=1))
  EXECUTE afc_del_bill_item
  CALL echo("Duplicate bill items deleted")
 ELSE
  CALL echo("Duplicate bill items NOT deleted")
 ENDIF
END GO
