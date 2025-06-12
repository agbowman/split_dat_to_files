CREATE PROGRAM bhs_virtualview_audit
 PROMPT
  "Output to File/Printer/MINE" = mine
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
 SET stat = alterlist(fac_group->list,5)
 SET fac_group->list[1].group = "BMC"
 SET fac_group->list[2].group = "FMC"
 SET fac_group->list[3].group = "MLH"
 SET fac_group->list[4].group = "MOCK"
 SET fac_group->list[5].group = "BWH"
 SET fac_group->list[6].group = "BNH"
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
 SELECT INTO "nl:"
  catalog_type = uar_get_code_display(oc.catalog_type_cd), activity_type = uar_get_code_display(oc
   .activity_type_cd), ocs.mnemonic,
  mnemonic_type = uar_get_code_display(ocs.mnemonic_type_cd), ocs.hide_flag, facility =
  uar_get_code_display(ofr.facility_cd)
  FROM order_catalog oc,
   order_catalog_synonym ocs,
   ocs_facility_r ofr
  PLAN (oc
   WHERE oc.active_ind=1
    AND oc.catalog_type_cd != 2516)
   JOIN (ocs
   WHERE oc.catalog_cd=ocs.catalog_cd
    AND ocs.active_ind=1)
   JOIN (ofr
   WHERE ofr.synonym_id=outerjoin(ocs.synonym_id))
  ORDER BY oc.catalog_type_cd, oc.activity_type_cd, oc.catalog_cd,
   ocs.synonym_id
  HEAD oc.catalog_cd
   ords->cnt = (ords->cnt+ 1)
   IF (mod(ords->cnt,100)=1)
    stat = alterlist(ords->list,(ords->cnt+ 99))
   ENDIF
   ords->list[ords->cnt].catalog_cd = oc.catalog_cd, ords->list[ords->cnt].catalog_type_cd = oc
   .catalog_type_cd, ords->list[ords->cnt].activity_type_cd = oc.activity_type_cd,
   syn_cnt = 0
  HEAD ocs.synonym_id
   syn_cnt = (syn_cnt+ 1)
   IF (mod(syn_cnt,10)=1)
    stat = alterlist(ords->list[ords->cnt].synonyms,(syn_cnt+ 9))
   ENDIF
   ords->list[ords->cnt].synonyms[syn_cnt].synonym_id = ocs.synonym_id, ords->list[ords->cnt].
   synonyms[syn_cnt].mnemonic = substring(1,40,ocs.mnemonic), ords->list[ords->cnt].synonyms[syn_cnt]
   .mnemonic_type_cd = ocs.mnemonic_type_cd,
   ords->list[ords->cnt].synonyms[syn_cnt].hide_flag = ocs.hide_flag, ords->list[ords->cnt].synonyms[
   syn_cnt].all_flag = 0, ords->list[ords->cnt].synonyms[syn_cnt].none_flag = 0
   IF (ofr.synonym_id > 0
    AND ofr.facility_cd=0)
    ords->list[ords->cnt].synonyms[syn_cnt].all_flag = 1
   ELSEIF (ofr.synonym_id=0)
    ords->list[ords->cnt].synonyms[syn_cnt].none_flag = 1
   ENDIF
   vv_cnt = 0
  DETAIL
   IF ((ords->list[ords->cnt].synonyms[syn_cnt].all_flag=0)
    AND (ords->list[ords->cnt].synonyms[syn_cnt].none_flag=0))
    vv_cnt = (vv_cnt+ 1)
    IF (mod(vv_cnt,10)=1)
     stat = alterlist(ords->list[ords->cnt].synonyms[syn_cnt].facilities,(vv_cnt+ 9))
    ENDIF
    ords->list[ords->cnt].synonyms[syn_cnt].facilities[vv_cnt].facility_cd = ofr.facility_cd
    FOR (i = 1 TO fac_cnt)
      IF ((ofr.facility_cd=facs->list[i].facility_cd))
       ords->list[ords->cnt].synonyms[syn_cnt].facilities[vv_cnt].group = facs->list[i].group
      ENDIF
    ENDFOR
   ENDIF
  FOOT  ocs.synonym_id
   ords->list[ords->cnt].synonyms[syn_cnt].facility_cnt = vv_cnt, stat = alterlist(ords->list[ords->
    cnt].synonyms[syn_cnt].facilities,vv_cnt)
  FOOT  oc.catalog_cd
   ords->list[ords->cnt].synonym_cnt = syn_cnt, stat = alterlist(ords->list[ords->cnt].synonyms,
    syn_cnt)
  FOOT REPORT
   stat = alterlist(ords->list,ords->cnt)
  WITH nocounter, skipreport = 0
 ;end select
 SELECT INTO  $1
  catalog_disp = substring(1,40,uar_get_code_display(ords->list[d.seq].catalog_cd)),
  catalog_type_disp = substring(1,40,uar_get_code_display(ords->list[d.seq].catalog_type_cd)),
  activity_type_disp = substring(1,40,uar_get_code_display(ords->list[d.seq].activity_type_cd))
  FROM (dummyt d  WITH seq = value(ords->cnt))
  ORDER BY catalog_type_disp, activity_type_disp, catalog_disp
  HEAD REPORT
   col 1, "Catalog Type", col 42,
   "Activity Type", col 85, "Catalog Code Display",
   col 127, "Mnemonic Type", col 170,
   "Mnemonic", col 213, "Catalog CD",
   col 230, "Synonym ID", col 245,
   "All"
   FOR (x = 1 TO size(fac_group->list,5))
    col + 5,fac_group->list[x].group
   ENDFOR
   row + 1
  HEAD activity_type_disp
   row + 0
  HEAD catalog_disp
   row + 0
  DETAIL
   FOR (i = 1 TO ords->list[d.seq].synonym_cnt)
     col 1, catalog_type_disp, col 42,
     activity_type_disp, col 85, catalog_disp,
     mnemonic_type_disp = substring(1,40,uar_get_code_display(ords->list[d.seq].synonyms[i].
       mnemonic_type_cd)), col 127, mnemonic_type_disp,
     col 170, ords->list[d.seq].synonyms[i].mnemonic, col 213,
     ords->list[d.seq].catalog_cd, col 230, ords->list[d.seq].synonyms[i].synonym_id,
     zz = 1
     IF ((ords->list[d.seq].synonyms[i].all_flag=1))
      col 245, "X", zz = 2
     ELSEIF ((ords->list[d.seq].synonyms[i].none_flag=1))
      zz = 2
     ENDIF
     curcol = 253
     IF (zz=1)
      FOR (j = 1 TO size(fac_group->list,5))
        found_one = 0, missing_one = 0
        FOR (k = 1 TO size(facs->list,5))
          IF ((facs->list[k].group=fac_group->list[j].group))
           found_this_one = 0
           FOR (l = 1 TO ords->list[d.seq].synonyms[i].facility_cnt)
             IF ((ords->list[d.seq].synonyms[i].facilities[l].facility_cd=facs->list[k].facility_cd))
              found_this_one = 1, l = (ords->list[d.seq].synonyms[i].facility_cnt+ 1)
             ENDIF
           ENDFOR
           IF (found_this_one=1)
            found_one = 1
           ELSE
            missing_one = 1
           ENDIF
          ENDIF
        ENDFOR
        IF (found_one=1
         AND missing_one=1)
         col curcol, "*"
        ELSEIF (found_one=1
         AND missing_one=0)
         col curcol, "X"
        ENDIF
        curcol = ((curcol+ size(fac_group->list[j].group))+ 5)
      ENDFOR
     ENDIF
     row + 1
   ENDFOR
  WITH maxcol = 300, formfeed = none
 ;end select
END GO
