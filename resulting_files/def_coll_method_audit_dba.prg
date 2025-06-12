CREATE PROGRAM def_coll_method_audit:dba
 PAINT
 CALL clear(1,1)
 CALL video(n)
 CALL box(1,1,3,80)
 CALL text(2,3,"DEFAULT COLLECTION METHOD AUDIT")
 CALL text(4,3,"This program is an audit of all order catalog items and")
 CALL text(5,3,"their corresponding default collection methods.")
 CALL clear(7,1)
 CALL text(7,3,"Sort by (O)rder Catalog Item or (C)ollection Method:")
 CALL accept(7,57,"X;;CU","C")
 SET psort = curaccept
 CALL clear(9,1)
 CALL text(9,3,"Continue? (Y/N) ")
 CALL accept(9,20,"P;;CU","Y")
 IF (curaccept="N")
  GO TO end_script
 ENDIF
 CALL clear(11,1)
 CALL text(11,3,"Retrieving order catalog information...")
 SELECT
  IF (psort="O")
   ORDER BY catalog_disp
  ELSE
   ORDER BY coll_method_disp
  ENDIF
  pst.catalog_cd, pst.default_collection_method_cd, catalog_disp = cv1.display
  "#############################################;;c",
  coll_method_disp = cv2.display"########################################;;c"
  FROM procedure_specimen_type pst,
   code_value cv1,
   code_value cv2
  PLAN (pst)
   JOIN (cv1
   WHERE cv1.code_value=pst.catalog_cd
    AND cv1.active_ind=1
    AND cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cv2
   WHERE cv2.code_value=pst.default_collection_method_cd
    AND cv2.active_ind=1
    AND cv2.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  HEAD REPORT
   CALL center("AUDIT OF ORDER CATALOG ITEMS AND DEFAULT COLLECTION METHODS",1,120), row + 2
  HEAD PAGE
   row + 1, col 0, "Order Catalog Item",
   col 65, "Default Collection Method", row + 1,
   col 0, "------------------", col 65,
   "-------------------------", row + 1
  DETAIL
   catalog_item = concat(trim(catalog_disp),"   (",trim(cnvtstring(cv1.code_value,19,0)),")"), col 0,
   catalog_item,
   coll_method = concat(trim(coll_method_disp),"   (",trim(cnvtstring(cv2.code_value,19,0)),")"), col
    65, coll_method,
   row + 1
  WITH nocounter
 ;end select
#end_script
END GO
