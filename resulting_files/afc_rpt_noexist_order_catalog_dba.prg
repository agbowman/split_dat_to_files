CREATE PROGRAM afc_rpt_noexist_order_catalog:dba
 RECORD ordercatalog(
   1 order_catalog_qual = i4
   1 qual[*]
     2 catalog_cd = f8
     2 activity_type_cd = f8
     2 orderable_type_flag = i2
     2 description = vc
     2 exist_ind = i2
 )
 SET count = 0
 SELECT INTO "nl:"
  b.*, o.*
  FROM dummyt d1,
   bill_item b,
   order_catalog o
  PLAN (o
   WHERE o.active_ind=1)
   JOIN (d1)
   JOIN (b
   WHERE b.ext_parent_reference_id=o.catalog_cd
    AND b.active_ind=1
    AND b.ext_child_reference_id=0)
  DETAIL
   count = (count+ 1), stat = alterlist(ordercatalog->qual,count), ordercatalog->qual[count].
   catalog_cd = o.catalog_cd,
   ordercatalog->qual[count].activity_type_cd = o.activity_type_cd, ordercatalog->qual[count].
   orderable_type_flag = o.orderable_type_flag
   IF (trim(o.description)=" ")
    ordercatalog->qual[count].description = "BLANK DESCRIPTION"
   ELSE
    ordercatalog->qual[count].description = trim(o.description)
   ENDIF
  WITH outerjoin = o, dontexist, nocounter
 ;end select
 SET ordercatalog->order_catalog_qual = count
 SELECT
  cv.*
  FROM (dummyt d1  WITH seq = value(ordercatalog->order_catalog_qual)),
   code_value cv
  PLAN (d1)
   JOIN (cv
   WHERE (cv.code_value=ordercatalog->qual[d1.seq].activity_type_cd))
  HEAD PAGE
   CALL center("* * *   O R D E R    C A T A L O G    D O N ' T    E X I S T    R E P O R T  * * *",1,
   129), row + 2, col 5,
   "Report Name: AFC_RPT_NOEXIST_ORDER_CATALOG", row + 1, col 5,
   curdate"MM/DD/YY;;D", col + 1, curtime"HH:MM;;M",
   row + 1, col 5, "Order Catalog Item Description",
   col 65, "Catalog Code", col 85,
   "Activity Type Code", row + 1, line = fillstring(129,"="),
   col 1, line, row + 1
  DETAIL
   IF ((ordercatalog->qual[d1.seq].orderable_type_flag=2))
    col 2, "* "
   ENDIF
   col 5, ordercatalog->qual[d1.seq].description, col 65,
   ordercatalog->qual[d1.seq].catalog_cd, col 85, cv.display,
   row + 1
  FOOT PAGE
   col 117, "PAGE: ", col + 1,
   curpage"###"
  FOOT REPORT
   row + 2, col 5, "Note : Item With [*] Is CareSet Item",
   row + 1, col 5, "Total Order Catalog Items That Do Not Exist In Bill Item Table = ",
   count(ordercatalog->qual[d1.seq].catalog_cd)
  WITH nocounter
 ;end select
 FREE SET ordercatalog
END GO
