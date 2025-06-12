CREATE PROGRAM bhs_rad_audit_ord_with_vv:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Activity Sub Type:" = 0
  WITH outdev, prompt2
 FREE RECORD facs
 RECORD facs(
   1 list[*]
     2 facility_cd = f8
     2 group = c4
 )
 FREE RECORD fac_group
 RECORD fac_group(
   1 list[*]
     2 group = c4
 )
 SET stat = alterlist(fac_group->list,4)
 SET fac_group->list[1].group = "BMC"
 SET fac_group->list[2].group = "FMC"
 SET fac_group->list[3].group = "MLH"
 SET fac_group->list[4].group = "MOCK"
 SET fac_group->list[5].group = "BWH"
 SET fac_group->list[5].group = "BNH"
 DECLARE fac_cnt = i4
 SET fac_cnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=220
    AND cv.cdf_meaning="FACILITY"
    AND cv.active_ind=1)
  DETAIL
   fac_cnt = (fac_cnt+ 1)
   IF (mod(fac_cnt,10)=1)
    stat = alterlist(facs->list,(fac_cnt+ 9))
   ENDIF
   facs->list[fac_cnt].facility_cd = cv.code_value
   IF (cv.code_value IN (679549, 673936, 686764, 686765, 686766,
   686767, 686769, 686770, 686771, 686772,
   686773, 686775, 686776, 686777, 686778,
   686779, 686780, 686781, 686782, 686784,
   686785, 2159621, 2159646))
    facs->list[fac_cnt].group = "BMC"
   ELSEIF (cv.code_value IN (679586, 673937, 686768, 686774, 2159634))
    facs->list[fac_cnt].group = "FMC"
   ELSEIF (cv.code_value=673938)
    facs->list[fac_cnt].group = "MLH"
   ELSEIF (cv.code_value=2583987)
    facs->list[fac_cnt].group = "MOCK"
   ELSEIF (cv.code_value IN (580062482, 580061823))
    facs->list[fac_cnt].group = "BWH"
   ELSEIF (cv.code_value IN (780848199, 780611679))
    facs->list[fac_cnt].group = "BNH"
   ELSE
    fac_cnt = (fac_cnt - 1)
   ENDIF
  FOOT REPORT
   stat = alterlist(facs->list,fac_cnt)
  WITH nocounter
 ;end select
 FREE RECORD ords
 RECORD ords(
   1 cnt = i4
   1 list[*]
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 orderable_type = vc
     2 synonym_cnt = i4
     2 synonyms[*]
       3 synonym_id = f8
       3 mnemonic = vc
       3 mnemonic_type_cd = f8
       3 hide_flag = i4
       3 all_flag = i4
       3 none_flag = i4
       3 facility_cnt = i4
       3 facilities[*]
         4 facility_cd = f8
         4 group = c4
 )
 SET ords->cnt = 0
 SELECT INTO  $1
  catalog_type = uar_get_code_display(oc.catalog_type_cd), activity_sub_type = uar_get_code_display(
   oc.activity_subtype_cd), ocs.mnemonic,
  mnemonic_type = uar_get_code_display(ocs.mnemonic_type_cd), ocs.hide_flag, facility =
  uar_get_code_display(ofr.facility_cd)
  FROM order_catalog oc,
   order_catalog_synonym ocs,
   ocs_facility_r ofr
  PLAN (oc
   WHERE oc.active_ind=1
    AND oc.catalog_type_cd=2517
    AND (oc.activity_subtype_cd= $2))
   JOIN (ocs
   WHERE oc.catalog_cd=ocs.catalog_cd
    AND ocs.active_ind=1)
   JOIN (ofr
   WHERE ofr.synonym_id=outerjoin(ocs.synonym_id))
  ORDER BY oc.catalog_type_cd, oc.activity_type_cd, oc.activity_subtype_cd,
   oc.catalog_cd, ocs.synonym_id
  WITH nocounter, format, separator = " "
 ;end select
END GO
