CREATE PROGRAM aps_db_orc_audit:dba
 PAINT
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET sub_type = 0.0
 SET type_sub = fillstring(1," ")
 SET cat_type = 0.0
 SET act_type = 0.0
 SET action_type = 0.0
 SET app_type = 0.0
 SET apr_type = 0.0
 SET aps_type = 0.0
 SET code_set = 6000
 SET cdf_meaning = "GENERAL LAB"
 EXECUTE cpm_get_cd_for_cdf
 SET cat_type = code_value
 SET code_set = 106
 SET cdf_meaning = "AP"
 EXECUTE cpm_get_cd_for_cdf
 SET act_type = code_value
 SET code_set = 6003
 SET cdf_meaning = "ORDER"
 EXECUTE cpm_get_cd_for_cdf
 SET action_type = code_value
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE 5801=cv.code_set
   AND cv.cdf_meaning IN ("APPROCESS", "APREPORT", "APSPECIMEN")
  DETAIL
   IF (cv.cdf_meaning="APPROCESS")
    app_type = cv.code_value
   ENDIF
   IF (cv.cdf_meaning="APREPORT")
    apr_type = cv.code_value
   ENDIF
   IF (cv.cdf_meaning="APSPECIMEN")
    aps_type = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
#input_here
 CALL video(n)
 CALL clear(1,1)
 CALL video(n)
 CALL box(2,1,23,80)
 CALL line(05,01,80,"XH")
 CALL text(3,3,"A P   V 5 0 0   R E F E R E N C E   F I L E   A U D I T ")
 CALL text(4,3,"    Order Catalog Audit ")
 CALL text(8,15,"    Catalog Type:   Laboratory")
 CALL text(9,15,"   Activity Type:   Anatomic Pathology")
 CALL text(10,15," Select Sub-type:")
 CALL text(12,15," Valid Sub-types:")
 CALL video(iu)
 CALL text(12,35,"A")
 CALL video(n)
 CALL text(12,36,"ll")
 CALL video(iu)
 CALL text(13,35,"P")
 CALL video(n)
 CALL text(13,36,"rocessing")
 CALL video(iu)
 CALL text(14,35,"R")
 CALL video(n)
 CALL text(14,36,"eporting")
 CALL video(iu)
 CALL text(15,35,"S")
 CALL video(n)
 CALL text(15,36,"pecimen")
 CALL video(iu)
 CALL text(17,35,"Q")
 CALL video(n)
 CALL text(17,36,"uit")
 CALL accept(10,35,"P;CU","A"
  WHERE curaccept IN ("A", "P", "R", "S", "Q"))
 SET type_sub = curaccept
 CALL video(b)
 CALL text(24,3," PROCESSING REQUESTED AUDIT... ")
 CALL video(n)
 IF (type_sub IN ("A"))
  SET sub_type = 0.0
  CALL text(10,35,"All")
 ELSEIF (type_sub IN ("P"))
  SET sub_type = app_type
  CALL text(10,35,"Processing")
 ELSEIF (type_sub IN ("R"))
  SET sub_type = apr_type
  CALL text(10,35,"Reporting")
 ELSEIF (type_sub IN ("S"))
  SET sub_type = aps_type
  CALL text(10,35,"Specimen")
 ELSE
  GO TO exit_script
 ENDIF
 CALL clear(12,15,60)
 CALL clear(13,15,60)
 CALL clear(14,15,60)
 CALL clear(15,15,60)
 CALL clear(16,15,60)
 CALL clear(17,15,60)
 SELECT
  activ_subtype = decode(cv1.seq,substring(1,15,cv1.display),"** NONE **"), oc_primary_mnemonic =
  decode(oc.seq,substring(1,50,oc.primary_mnemonic)," "), oe_format_name = decode(oef.seq,oef
   .oe_format_name,"** NONE **"),
  service_resource = decode(cv2.seq,substring(1,25,cv2.display),"** NONE **"), dta_mnemonic = decode(
   dta.seq,dta.mnemonic,"** NONE **"), result_type = decode(cv3.seq,cv3.display,"** NONE **"),
  ptr_sequence = decode(ptr.seq,ptr.sequence,0), oc.primary_mnemonic, oc.oe_format_id
  FROM order_catalog oc,
   dummyt d,
   dummyt d2,
   code_value cv1,
   dummyt d1,
   order_entry_format oef,
   dummyt d3,
   orc_resource_list orl,
   dummyt d4,
   code_value cv2,
   dummyt d5,
   profile_task_r ptr,
   dummyt d6,
   discrete_task_assay dta,
   dummyt d7,
   code_value cv3
  PLAN (oc
   WHERE cat_type=oc.catalog_type_cd
    AND act_type=oc.activity_type_cd
    AND parser(
    IF (sub_type=0) "0 = 0"
    ELSE "sub_type = oc.activity_subtype_cd"
    ENDIF
    ))
   JOIN (d
   WHERE 1=d.seq)
   JOIN (d2
   WHERE 1=d2.seq)
   JOIN (cv1
   WHERE 5801=cv1.code_set
    AND oc.activity_subtype_cd=cv1.code_value)
   JOIN (d1
   WHERE 1=d1.seq)
   JOIN (oef
   WHERE oc.oe_format_id=oef.oe_format_id
    AND action_type=oef.action_type_cd
    AND oef.oe_format_id > 0)
   JOIN (d3
   WHERE 1=d3.seq)
   JOIN (orl
   WHERE oc.catalog_cd=orl.catalog_cd
    AND oc.catalog_cd > 0)
   JOIN (d4
   WHERE 1=d4.seq)
   JOIN (cv2
   WHERE 221=cv2.code_set
    AND orl.service_resource_cd=cv2.code_value)
   JOIN (d5
   WHERE 1=d5.seq)
   JOIN (ptr
   WHERE oc.catalog_cd=ptr.catalog_cd
    AND oc.catalog_cd > 0)
   JOIN (d6
   WHERE 1=d6.seq)
   JOIN (dta
   WHERE ptr.task_assay_cd=dta.task_assay_cd
    AND ptr.catalog_cd > 0)
   JOIN (d7
   WHERE 1=d7.seq)
   JOIN (cv3
   WHERE 289=cv3.code_set
    AND dta.default_result_type_cd=cv3.code_value)
  ORDER BY activ_subtype, oc_primary_mnemonic, service_resource,
   ptr_sequence
  HEAD REPORT
   pg = 0, line = fillstring(130,"~"), saved_cat = 0.0,
   pri = "Y", row1 = "Y"
  HEAD PAGE
   pg += 1, col 1, "Cerner Millennium Anatomic Pathology",
   col 90, "Page", pg,
   row + 1, col 1, "Order Catalog Audit",
   col 90, "Printed ", curdate,
   " ", curtime, row + 2,
   col 1, " Catalog type: Laboratory", row + 1,
   col 1, "Activity type: Anatomic Pathology", row + 1,
   col 1, "     Sub-type:", col 16
   IF (type_sub="A")
    "ALL"
   ELSEIF (type_sub="R")
    "Reporting"
   ELSEIF (type_sub="S")
    "Specimen"
   ELSEIF (type_sub="P")
    "Processing"
   ENDIF
   row + 1, line, row + 1,
   col 0, "Sub-type", col 15,
   "Order Catalog", col 45, "OE Format",
   col 70, "Resource", col 89,
   "Discrete Task", col 110, "Result type",
   row + 1, col 0, "--------",
   col 15, "-------------", col 45,
   "---------", col 70, "--------",
   col 89, "-------------", col 110,
   "-----------", row + 2
  HEAD activ_subtype
   col 0, activ_subtype
  HEAD oc_primary_mnemonic
   col 15, oc.primary_mnemonic, col 45,
   oe_format_name
  HEAD service_resource
   col 70, pri = "Y", service_resource
   IF (saved_cat=oc.catalog_cd)
    pri = "N"
   ENDIF
   saved_cat = oc.catalog_cd, row1 = "Y"
  DETAIL
   IF (pri="Y")
    col 89, dta_mnemonic, col 110,
    result_type, row1 = "Y"
   ENDIF
   IF (row1="Y")
    row + 1, row1 = "N"
   ENDIF
  WITH nocounter, outerjoin = d, outerjoin = d2,
   dontcare = cv1, outerjoin = d1, dontcare = oef,
   outerjoin = d3, dontcare = orl, outerjoin = d4,
   dontcare = cv2, outerjoin = d5, dontcare = ptr,
   outerjoin = d6, dontcare = dta, outerjoin = d7,
   dontcare = cv3, maxcol = 250
 ;end select
END GO
