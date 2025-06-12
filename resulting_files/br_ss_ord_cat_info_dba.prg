CREATE PROGRAM br_ss_ord_cat_info:dba
 FREE RECORD temp
 RECORD temp(
   1 acnt = i2
   1 aqual[*]
     2 activity_type = vc
     2 scnt = i2
     2 squal[*]
       3 subtype = vc
       3 ocnt = i2
       3 oqual[*]
         4 ord = vc
 )
 DECLARE lab = f8 WITH public, noconstant(0.0)
 DECLARE ap = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="GENERAL LAB")
  DETAIL
   lab = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="AP")
  DETAIL
   ap = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog oc,
   code_value cv,
   code_value cv2
  PLAN (oc
   WHERE oc.catalog_type_cd=lab
    AND oc.activity_type_cd != ap
    AND oc.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=oc.activity_type_cd)
   JOIN (cv2
   WHERE cv2.code_value=oc.activity_subtype_cd)
  ORDER BY oc.activity_type_cd, oc.activity_subtype_cd, oc.description
  HEAD REPORT
   acnt = 0, scnt = 0, ocnt = 0
  HEAD oc.activity_type_cd
   scnt = 0, ocnt = 0, acnt = (acnt+ 1),
   temp->acnt = acnt, stat = alterlist(temp->aqual,acnt), temp->aqual[acnt].activity_type = cv
   .description
  HEAD oc.activity_subtype_cd
   ocnt = 0, scnt = (scnt+ 1), temp->aqual[acnt].scnt = scnt,
   stat = alterlist(temp->aqual[acnt].squal,scnt), temp->aqual[acnt].squal[scnt].subtype = cv2
   .description
  DETAIL
   IF (substring(1,2,oc.description) != "zz")
    ocnt = (ocnt+ 1), temp->aqual[acnt].squal[scnt].ocnt = ocnt, stat = alterlist(temp->aqual[acnt].
     squal[scnt].oqual,ocnt),
    temp->aqual[acnt].squal[scnt].oqual[ocnt].ord = oc.description, temp->aqual[acnt].squal[scnt].
    oqual[ocnt].ord = replace(temp->aqual[acnt].squal[scnt].oqual[ocnt].ord,","," ")
   ENDIF
  WITH nocounter
 ;end select
 DECLARE ord_string = vc
 DECLARE header_string = vc
 SELECT INTO "cer_temp:order_catalog.csv"
  FROM dummyt d
  PLAN (d)
  HEAD REPORT
   header_string = "Activity Type,Sub-Activity Type,Description"
  DETAIL
   col 0, header_string, row + 1
   FOR (x = 1 TO temp->acnt)
     FOR (y = 1 TO temp->aqual[x].scnt)
       FOR (z = 1 TO temp->aqual[x].squal[y].ocnt)
         ord_string = build(temp->aqual[x].activity_type,",",temp->aqual[x].squal[y].subtype,",",temp
          ->aqual[x].squal[y].oqual[z].ord), col 0, ord_string,
         row + 1
       ENDFOR
     ENDFOR
   ENDFOR
  WITH nocounter, format = pcformat
 ;end select
END GO
