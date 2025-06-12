CREATE PROGRAM bed_rec_iv_interact_check:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 run_status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET tempreply
 RECORD tempreply(
   1 rowlist[*]
     2 celllist[*]
       3 date_value = dq8
       3 nbr_value = i4
       3 double_value = f8
       3 string_value = vc
       3 display_flag = i2
 )
 SET detail_mode = validate(request->detail_mode)
 SET reply->run_status_flag = 1
 SET col_cnt = 15
 SET resolution_txt = ""
 SET short_desc = ""
 SELECT INTO "nl:"
  FROM br_rec b,
   br_long_text bl
  PLAN (b
   WHERE b.rec_mean="ORDIVINTCHECKWINDOW2")
   JOIN (bl
   WHERE bl.long_text_id=b.resolution_txt_id)
  DETAIL
   resolution_txt = trim(bl.long_text), short_desc = trim(b.short_desc)
  WITH nocounter
 ;end select
 DECLARE powerchart_value = vc
 DECLARE surginet_value = vc
 DECLARE firstnet_value = vc
 DECLARE powerchart_app_desc = vc
 DECLARE surginet_app_desc = vc
 DECLARE firstnet_app_desc = vc
 SELECT INTO "NL:"
  FROM application a
  WHERE a.application_number IN (600005, 820000, 4250111, 961000)
   AND a.active_ind=1
  DETAIL
   IF (a.application_number=600005)
    powerchart_app_desc = a.description
   ELSEIF (a.application_number=820000)
    surginet_app_desc = a.description
   ELSEIF (a.application_number=4250111)
    firstnet_app_desc = a.description
   ENDIF
  WITH nocounter
 ;end select
 SET powerchart_pref_row_exists = 0
 SET surginet_pref_row_exists = 0
 SET firstnet_pref_row_exists = 0
 SET powerchart_found = 0
 SET surginet_found = 0
 SET firstnet_found = 0
 SET powerchart_value = " "
 SET surginet_value = " "
 SET firstnet_value = " "
 SELECT INTO "nl:"
  FROM app_prefs ap,
   name_value_prefs nvp
  PLAN (ap
   WHERE ap.application_number IN (600005, 820000, 4250111)
    AND ap.position_cd=0
    AND ap.prsnl_id=0
    AND ap.active_ind=1)
   JOIN (nvp
   WHERE nvp.parent_entity_name="APP_PREFS"
    AND nvp.parent_entity_id=ap.app_prefs_id
    AND nvp.pvc_name="MUL_IVCOMPATINTERRUPTION"
    AND nvp.active_ind=1)
  DETAIL
   IF (ap.application_number=600005)
    powerchart_pref_row_exists = 1
    IF (nvp.pvc_value="3")
     powerchart_found = 1
    ENDIF
    powerchart_value = nvp.pvc_value
   ELSEIF (ap.application_number=820000)
    surginet_pref_row_exists = 1
    IF (nvp.pvc_value="3")
     surginet_found = 1
    ENDIF
    surginet_value = nvp.pvc_value
   ELSEIF (ap.application_number=4250111)
    firstnet_pref_row_exists = 1
    IF (nvp.pvc_value="3")
     firstnet_found = 1
    ENDIF
    firstnet_value = nvp.pvc_value
   ENDIF
  WITH nocounter
 ;end select
 IF (detail_mode=1)
  IF (((powerchart_found=0) OR (powerchart_pref_row_exists=0)) )
   SET row_tot_cnt = (size(tempreply->rowlist,5)+ 1)
   SET stat = alterlist(tempreply->rowlist,row_tot_cnt)
   SET stat = alterlist(tempreply->rowlist[row_tot_cnt].celllist,col_cnt)
   SET tempreply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc
   SET tempreply->rowlist[row_tot_cnt].celllist[2].string_value = "MUL_IVCOMPATINTERRUPTION"
   SET tempreply->rowlist[row_tot_cnt].celllist[3].string_value = "3"
   IF (powerchart_pref_row_exists=0)
    SET tempreply->rowlist[row_tot_cnt].celllist[4].string_value = "Not Defined"
   ELSE
    SET tempreply->rowlist[row_tot_cnt].celllist[4].string_value = powerchart_value
   ENDIF
   SET tempreply->rowlist[row_tot_cnt].celllist[5].string_value = "Application"
   SET tempreply->rowlist[row_tot_cnt].celllist[6].string_value = powerchart_app_desc
   SET tempreply->rowlist[row_tot_cnt].celllist[7].string_value = ""
   SET tempreply->rowlist[row_tot_cnt].celllist[12].string_value = ""
   SET tempreply->rowlist[row_tot_cnt].celllist[13].string_value = ""
   SET tempreply->rowlist[row_tot_cnt].celllist[14].string_value = "PrefMaint"
   SET tempreply->rowlist[row_tot_cnt].celllist[15].string_value = resolution_txt
  ENDIF
  IF (((surginet_found=0) OR (surginet_pref_row_exists=0)) )
   SET row_tot_cnt = (size(tempreply->rowlist,5)+ 1)
   SET stat = alterlist(tempreply->rowlist,row_tot_cnt)
   SET stat = alterlist(tempreply->rowlist[row_tot_cnt].celllist,col_cnt)
   SET tempreply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc
   SET tempreply->rowlist[row_tot_cnt].celllist[2].string_value = "MUL_IVCOMPATINTERRUPTION"
   SET tempreply->rowlist[row_tot_cnt].celllist[3].string_value = "3"
   IF (surginet_pref_row_exists=0)
    SET tempreply->rowlist[row_tot_cnt].celllist[4].string_value = "Not Defined"
   ELSE
    SET tempreply->rowlist[row_tot_cnt].celllist[4].string_value = surginet_value
   ENDIF
   SET tempreply->rowlist[row_tot_cnt].celllist[5].string_value = "Application"
   SET tempreply->rowlist[row_tot_cnt].celllist[6].string_value = surginet_app_desc
   SET tempreply->rowlist[row_tot_cnt].celllist[7].string_value = ""
   SET tempreply->rowlist[row_tot_cnt].celllist[12].string_value = ""
   SET tempreply->rowlist[row_tot_cnt].celllist[13].string_value = ""
   SET tempreply->rowlist[row_tot_cnt].celllist[14].string_value = "PrefMaint"
   SET tempreply->rowlist[row_tot_cnt].celllist[15].string_value = resolution_txt
  ENDIF
  IF (((firstnet_found=0) OR (firstnet_pref_row_exists=0)) )
   SET row_tot_cnt = (size(tempreply->rowlist,5)+ 1)
   SET stat = alterlist(tempreply->rowlist,row_tot_cnt)
   SET stat = alterlist(tempreply->rowlist[row_tot_cnt].celllist,col_cnt)
   SET tempreply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc
   SET tempreply->rowlist[row_tot_cnt].celllist[2].string_value = "MUL_IVCOMPATINTERRUPTION"
   SET tempreply->rowlist[row_tot_cnt].celllist[3].string_value = "3"
   IF (firstnet_pref_row_exists=0)
    SET tempreply->rowlist[row_tot_cnt].celllist[4].string_value = "Not Defined"
   ELSE
    SET tempreply->rowlist[row_tot_cnt].celllist[4].string_value = firstnet_value
   ENDIF
   SET tempreply->rowlist[row_tot_cnt].celllist[5].string_value = "Application"
   SET tempreply->rowlist[row_tot_cnt].celllist[6].string_value = firstnet_app_desc
   SET tempreply->rowlist[row_tot_cnt].celllist[7].string_value = ""
   SET tempreply->rowlist[row_tot_cnt].celllist[12].string_value = ""
   SET tempreply->rowlist[row_tot_cnt].celllist[13].string_value = ""
   SET tempreply->rowlist[row_tot_cnt].celllist[14].string_value = "PrefMaint"
   SET tempreply->rowlist[row_tot_cnt].celllist[15].string_value = resolution_txt
  ENDIF
 ENDIF
 SET yes_cd = 0.0
 SET no_cd = 0.0
 SET yes_except_for_cd = 0.0
 SET no_except_for_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6017
   AND cv.cdf_meaning IN ("YES", "NO", "EXCLUDE", "INCLUDE")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="YES")
    yes_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="NO")
    no_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="EXCLUDE")
    yes_except_for_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="INCLUDE")
    no_except_for_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET order_priv_cd = 0.0
 SET order_priv_cd = uar_get_code_by("MEANING",6016,"ORDER")
 SET prescribe_priv_cd = 0.0
 SET prescribe_priv_cd = uar_get_code_by("MEANING",6016,"PRESCRIBE")
 SET cat_type_excep_cd = 0.0
 SET cat_type_excep_cd = uar_get_code_by("MEANING",6015,"CATALOGTYPE")
 SET pharm_cat_type_cd = 0.0
 SET pharm_cat_type_cd = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET fail_ind = 0
 SELECT INTO "nl:"
  FROM code_value cv,
   app_prefs ap,
   prsnl p,
   name_value_prefs nvp,
   priv_loc_reltn plr,
   privilege pv1,
   privilege pv2,
   privilege_exception pe1,
   privilege_exception pe2,
   dummyt d
  PLAN (cv
   WHERE cv.code_set=88
    AND cv.active_ind=1)
   JOIN (p
   WHERE p.position_cd=cv.code_value
    AND p.active_ind=1)
   JOIN (plr
   WHERE plr.position_cd=outerjoin(p.position_cd)
    AND plr.person_id=outerjoin(0)
    AND plr.ppr_cd=outerjoin(0)
    AND plr.location_cd=outerjoin(0)
    AND plr.active_ind=outerjoin(1))
   JOIN (pv1
   WHERE pv1.priv_loc_reltn_id=outerjoin(plr.priv_loc_reltn_id)
    AND pv1.privilege_cd=outerjoin(order_priv_cd)
    AND pv1.active_ind=outerjoin(1))
   JOIN (pv2
   WHERE pv2.priv_loc_reltn_id=outerjoin(plr.priv_loc_reltn_id)
    AND pv2.privilege_cd=outerjoin(prescribe_priv_cd)
    AND pv2.active_ind=outerjoin(1))
   JOIN (pe1
   WHERE pe1.privilege_id=outerjoin(pv1.privilege_id)
    AND pe1.exception_type_cd=outerjoin(cat_type_excep_cd)
    AND pe1.exception_id=outerjoin(pharm_cat_type_cd)
    AND pe1.active_ind=outerjoin(1))
   JOIN (pe2
   WHERE pe2.privilege_id=outerjoin(pv2.privilege_id)
    AND pe2.exception_type_cd=outerjoin(cat_type_excep_cd)
    AND pe2.exception_id=outerjoin(pharm_cat_type_cd)
    AND pe2.active_ind=outerjoin(1))
   JOIN (d)
   JOIN (ap
   WHERE ap.application_number IN (600005, 820000, 4250111)
    AND ap.position_cd=cv.code_value
    AND ap.prsnl_id=0
    AND ap.active_ind=1)
   JOIN (nvp
   WHERE nvp.parent_entity_name="APP_PREFS"
    AND nvp.parent_entity_id=ap.app_prefs_id
    AND nvp.pvc_name="MUL_IVCOMPATINTERRUPTION"
    AND nvp.active_ind=1)
  ORDER BY cv.display, p.position_cd, ap.application_number
  HEAD p.position_cd
   pc = 0, sn = 0, fn = 0,
   priv_exists_ind = 0
   IF (((pv1.privilege_id=0) OR (((pv1.privilege_id > 0
    AND pv1.priv_value_cd=yes_cd) OR (((pv1.privilege_id > 0
    AND pv1.priv_value_cd=yes_except_for_cd
    AND pe1.privilege_exception_id=0) OR (((pv1.privilege_id > 0
    AND pv1.priv_value_cd=no_except_for_cd
    AND pe1.privilege_exception_id > 0) OR (((pv2.privilege_id=0) OR (((pv2.privilege_id > 0
    AND pv2.priv_value_cd=yes_cd) OR (((pv2.privilege_id > 0
    AND pv2.priv_value_cd=yes_except_for_cd
    AND pe2.privilege_exception_id=0) OR (pv2.privilege_id > 0
    AND pv2.priv_value_cd=no_except_for_cd
    AND pe2.privilege_exception_id > 0)) )) )) )) )) )) )) )
    priv_exists_ind = 1
   ENDIF
  HEAD ap.application_number
   IF (ap.application_number=600005)
    pc = 1
   ELSEIF (ap.application_number=820000)
    sn = 1
   ELSEIF (ap.application_number=4250111)
    fn = 1
   ENDIF
   IF (priv_exists_ind=1)
    IF (nvp.name_value_prefs_id > 0
     AND nvp.pvc_value != "3")
     fail_ind = 1
    ELSEIF (nvp.name_value_prefs_id=0)
     IF (ap.application_number=600005
      AND powerchart_found=0)
      fail_ind = 1
     ELSEIF (ap.application_number=820000
      AND surginet_found=0)
      fail_ind = 1
     ELSEIF (ap.application_number=4250111
      AND firstnet_found=0)
      fail_ind = 1
     ENDIF
    ENDIF
   ENDIF
   IF (priv_exists_ind=1
    AND detail_mode=1)
    IF (nvp.name_value_prefs_id > 0
     AND nvp.pvc_value != "3")
     row_tot_cnt = (size(tempreply->rowlist,5)+ 1), stat = alterlist(tempreply->rowlist,row_tot_cnt),
     stat = alterlist(tempreply->rowlist[row_tot_cnt].celllist,col_cnt),
     tempreply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, tempreply->rowlist[
     row_tot_cnt].celllist[2].string_value = "MUL_IVCOMPATINTERRUPTION", tempreply->rowlist[
     row_tot_cnt].celllist[3].string_value = "3",
     tempreply->rowlist[row_tot_cnt].celllist[4].string_value = nvp.pvc_value, tempreply->rowlist[
     row_tot_cnt].celllist[5].string_value = "Position"
     IF (ap.application_number=600005)
      tempreply->rowlist[row_tot_cnt].celllist[6].string_value = powerchart_app_desc
     ELSEIF (ap.application_number=820000)
      tempreply->rowlist[row_tot_cnt].celllist[6].string_value = surginet_app_desc
     ELSEIF (ap.application_number=4250111)
      tempreply->rowlist[row_tot_cnt].celllist[6].string_value = firstnet_app_desc
     ENDIF
     tempreply->rowlist[row_tot_cnt].celllist[7].string_value = cv.display, tempreply->rowlist[
     row_tot_cnt].celllist[8].string_value = "Order"
     IF (pv1.privilege_id=0)
      tempreply->rowlist[row_tot_cnt].celllist[9].string_value = "Not defined, default Yes"
     ELSEIF (pv1.privilege_id > 0
      AND pv1.priv_value_cd=yes_cd)
      tempreply->rowlist[row_tot_cnt].celllist[9].string_value = "Yes"
     ELSEIF (pv1.privilege_id > 0
      AND pv1.priv_value_cd=yes_except_for_cd)
      tempreply->rowlist[row_tot_cnt].celllist[9].string_value = "Yes except for"
     ELSEIF (pv1.privilege_id > 0
      AND pv1.priv_value_cd=no_except_for_cd)
      tempreply->rowlist[row_tot_cnt].celllist[9].string_value = "No except for"
     ELSEIF (pv1.privilege_id > 0
      AND pv1.priv_value_cd=no_cd)
      tempreply->rowlist[row_tot_cnt].celllist[9].string_value = "No"
     ENDIF
     tempreply->rowlist[row_tot_cnt].celllist[10].string_value = "Prescribe"
     IF (pv2.privilege_id=0)
      tempreply->rowlist[row_tot_cnt].celllist[11].string_value = "Not defined, default Yes"
     ELSEIF (pv2.privilege_id > 0
      AND pv2.priv_value_cd=yes_cd)
      tempreply->rowlist[row_tot_cnt].celllist[11].string_value = "Yes"
     ELSEIF (pv2.privilege_id > 0
      AND pv2.priv_value_cd=yes_except_for_cd)
      tempreply->rowlist[row_tot_cnt].celllist[11].string_value = "Yes except for"
     ELSEIF (pv2.privilege_id > 0
      AND pv2.priv_value_cd=no_except_for_cd)
      tempreply->rowlist[row_tot_cnt].celllist[11].string_value = "No except for"
     ELSEIF (pv2.privilege_id > 0
      AND pv2.priv_value_cd=no_cd)
      tempreply->rowlist[row_tot_cnt].celllist[11].string_value = "No"
     ENDIF
     tempreply->rowlist[row_tot_cnt].celllist[12].string_value = "", tempreply->rowlist[row_tot_cnt].
     celllist[13].string_value = "", tempreply->rowlist[row_tot_cnt].celllist[14].string_value =
     "PrefMaint",
     tempreply->rowlist[row_tot_cnt].celllist[15].string_value = resolution_txt
    ELSEIF (nvp.name_value_prefs_id=0)
     IF (((ap.application_number=600005
      AND powerchart_found=0) OR (((ap.application_number=820000
      AND surginet_found=0) OR (ap.application_number=4250111
      AND firstnet_found=0)) )) )
      row_tot_cnt = (size(tempreply->rowlist,5)+ 1), stat = alterlist(tempreply->rowlist,row_tot_cnt),
      stat = alterlist(tempreply->rowlist[row_tot_cnt].celllist,col_cnt),
      tempreply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, tempreply->rowlist[
      row_tot_cnt].celllist[2].string_value = "MUL_IVCOMPATINTERRUPTION", tempreply->rowlist[
      row_tot_cnt].celllist[3].string_value = "3"
      IF (ap.application_number=600005)
       tempreply->rowlist[row_tot_cnt].celllist[4].string_value = powerchart_value, tempreply->
       rowlist[row_tot_cnt].celllist[6].string_value = powerchart_app_desc
      ELSEIF (ap.application_number=820000)
       tempreply->rowlist[row_tot_cnt].celllist[4].string_value = surginet_value, tempreply->rowlist[
       row_tot_cnt].celllist[6].string_value = surginet_app_desc
      ELSEIF (ap.application_number=4250111)
       tempreply->rowlist[row_tot_cnt].celllist[4].string_value = firstnet_value, tempreply->rowlist[
       row_tot_cnt].celllist[6].string_value = firstnet_app_desc
      ENDIF
      tempreply->rowlist[row_tot_cnt].celllist[5].string_value = "Application", tempreply->rowlist[
      row_tot_cnt].celllist[7].string_value = cv.display, tempreply->rowlist[row_tot_cnt].celllist[8]
      .string_value = "Order"
      IF (pv1.privilege_id=0)
       tempreply->rowlist[row_tot_cnt].celllist[9].string_value = "Not defined, default Yes"
      ELSEIF (pv1.privilege_id > 0
       AND pv1.priv_value_cd=yes_cd)
       tempreply->rowlist[row_tot_cnt].celllist[9].string_value = "Yes"
      ELSEIF (pv1.privilege_id > 0
       AND pv1.priv_value_cd=yes_except_for_cd)
       tempreply->rowlist[row_tot_cnt].celllist[9].string_value = "Yes except for"
      ELSEIF (pv1.privilege_id > 0
       AND pv1.priv_value_cd=no_except_for_cd)
       tempreply->rowlist[row_tot_cnt].celllist[9].string_value = "No except for"
      ELSEIF (pv1.privilege_id > 0
       AND pv1.priv_value_cd=no_cd)
       tempreply->rowlist[row_tot_cnt].celllist[9].string_value = "No"
      ENDIF
      tempreply->rowlist[row_tot_cnt].celllist[10].string_value = "Prescribe"
      IF (pv2.privilege_id=0)
       tempreply->rowlist[row_tot_cnt].celllist[11].string_value = "Not defined, default Yes"
      ELSEIF (pv2.privilege_id > 0
       AND pv2.priv_value_cd=yes_cd)
       tempreply->rowlist[row_tot_cnt].celllist[11].string_value = "Yes"
      ELSEIF (pv2.privilege_id > 0
       AND pv2.priv_value_cd=yes_except_for_cd)
       tempreply->rowlist[row_tot_cnt].celllist[11].string_value = "Yes except for"
      ELSEIF (pv2.privilege_id > 0
       AND pv2.priv_value_cd=no_except_for_cd)
       tempreply->rowlist[row_tot_cnt].celllist[11].string_value = "No except for"
      ELSEIF (pv2.privilege_id > 0
       AND pv2.priv_value_cd=no_cd)
       tempreply->rowlist[row_tot_cnt].celllist[11].string_value = "No"
      ENDIF
      tempreply->rowlist[row_tot_cnt].celllist[12].string_value = "", tempreply->rowlist[row_tot_cnt]
      .celllist[13].string_value = "", tempreply->rowlist[row_tot_cnt].celllist[14].string_value =
      "PrefMaint",
      tempreply->rowlist[row_tot_cnt].celllist[15].string_value = resolution_txt
     ENDIF
    ENDIF
   ENDIF
  FOOT  p.position_cd
   IF (fail_ind=1)
    reply->run_status_flag = 3
   ELSEIF (priv_exists_ind=1
    AND powerchart_found=0
    AND pc=0)
    reply->run_status_flag = 3
   ELSEIF (priv_exists_ind=1
    AND surginet_found=0
    AND sn=0)
    reply->run_status_flag = 3
   ELSEIF (priv_exists_ind=1
    AND firstnet_found=0
    AND fn=0)
    reply->run_status_flag = 3
   ENDIF
   IF (priv_exists_ind=1
    AND powerchart_found=0
    AND pc=0
    AND detail_mode=1)
    row_tot_cnt = (size(tempreply->rowlist,5)+ 1), stat = alterlist(tempreply->rowlist,row_tot_cnt),
    stat = alterlist(tempreply->rowlist[row_tot_cnt].celllist,col_cnt),
    tempreply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, tempreply->rowlist[
    row_tot_cnt].celllist[2].string_value = "MUL_IVCOMPATINTERRUPTION", tempreply->rowlist[
    row_tot_cnt].celllist[3].string_value = "3",
    tempreply->rowlist[row_tot_cnt].celllist[4].string_value = powerchart_value, tempreply->rowlist[
    row_tot_cnt].celllist[5].string_value = "Application", tempreply->rowlist[row_tot_cnt].celllist[6
    ].string_value = powerchart_app_desc,
    tempreply->rowlist[row_tot_cnt].celllist[7].string_value = cv.display, tempreply->rowlist[
    row_tot_cnt].celllist[8].string_value = "Order"
    IF (pv1.privilege_id=0)
     tempreply->rowlist[row_tot_cnt].celllist[9].string_value = "Not defined, default Yes"
    ELSEIF (pv1.privilege_id > 0
     AND pv1.priv_value_cd=yes_cd)
     tempreply->rowlist[row_tot_cnt].celllist[9].string_value = "Yes"
    ELSEIF (pv1.privilege_id > 0
     AND pv1.priv_value_cd=yes_except_for_cd)
     tempreply->rowlist[row_tot_cnt].celllist[9].string_value = "Yes except for"
    ELSEIF (pv1.privilege_id > 0
     AND pv1.priv_value_cd=no_except_for_cd)
     tempreply->rowlist[row_tot_cnt].celllist[9].string_value = "No except for"
    ELSEIF (pv1.privilege_id > 0
     AND pv1.priv_value_cd=no_cd)
     tempreply->rowlist[row_tot_cnt].celllist[9].string_value = "No"
    ENDIF
    tempreply->rowlist[row_tot_cnt].celllist[10].string_value = "Prescribe"
    IF (pv2.privilege_id=0)
     tempreply->rowlist[row_tot_cnt].celllist[11].string_value = "Not defined, default Yes"
    ELSEIF (pv2.privilege_id > 0
     AND pv2.priv_value_cd=yes_cd)
     tempreply->rowlist[row_tot_cnt].celllist[11].string_value = "Yes"
    ELSEIF (pv2.privilege_id > 0
     AND pv2.priv_value_cd=yes_except_for_cd)
     tempreply->rowlist[row_tot_cnt].celllist[11].string_value = "Yes except for"
    ELSEIF (pv2.privilege_id > 0
     AND pv2.priv_value_cd=no_except_for_cd)
     tempreply->rowlist[row_tot_cnt].celllist[11].string_value = "No except for"
    ELSEIF (pv2.privilege_id > 0
     AND pv2.priv_value_cd=no_cd)
     tempreply->rowlist[row_tot_cnt].celllist[11].string_value = "No"
    ENDIF
    tempreply->rowlist[row_tot_cnt].celllist[12].string_value = "", tempreply->rowlist[row_tot_cnt].
    celllist[13].string_value = "", tempreply->rowlist[row_tot_cnt].celllist[14].string_value =
    "PrefMaint",
    tempreply->rowlist[row_tot_cnt].celllist[15].string_value = resolution_txt
   ENDIF
   IF (priv_exists_ind=1
    AND surginet_found=0
    AND sn=0
    AND detail_mode=1)
    row_tot_cnt = (size(tempreply->rowlist,5)+ 1), stat = alterlist(tempreply->rowlist,row_tot_cnt),
    stat = alterlist(tempreply->rowlist[row_tot_cnt].celllist,col_cnt),
    tempreply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, tempreply->rowlist[
    row_tot_cnt].celllist[2].string_value = "MUL_IVCOMPATINTERRUPTION", tempreply->rowlist[
    row_tot_cnt].celllist[3].string_value = "3",
    tempreply->rowlist[row_tot_cnt].celllist[4].string_value = surginet_value, tempreply->rowlist[
    row_tot_cnt].celllist[5].string_value = "Application", tempreply->rowlist[row_tot_cnt].celllist[6
    ].string_value = surginet_app_desc,
    tempreply->rowlist[row_tot_cnt].celllist[7].string_value = cv.display, tempreply->rowlist[
    row_tot_cnt].celllist[8].string_value = "Order"
    IF (pv1.privilege_id=0)
     tempreply->rowlist[row_tot_cnt].celllist[9].string_value = "Not defined, default Yes"
    ELSEIF (pv1.privilege_id > 0
     AND pv1.priv_value_cd=yes_cd)
     tempreply->rowlist[row_tot_cnt].celllist[9].string_value = "Yes"
    ELSEIF (pv1.privilege_id > 0
     AND pv1.priv_value_cd=yes_except_for_cd)
     tempreply->rowlist[row_tot_cnt].celllist[9].string_value = "Yes except for"
    ELSEIF (pv1.privilege_id > 0
     AND pv1.priv_value_cd=no_except_for_cd)
     tempreply->rowlist[row_tot_cnt].celllist[9].string_value = "No except for"
    ELSEIF (pv1.privilege_id > 0
     AND pv1.priv_value_cd=no_cd)
     tempreply->rowlist[row_tot_cnt].celllist[9].string_value = "No"
    ENDIF
    tempreply->rowlist[row_tot_cnt].celllist[10].string_value = "Prescribe"
    IF (pv2.privilege_id=0)
     tempreply->rowlist[row_tot_cnt].celllist[11].string_value = "Not defined, default Yes"
    ELSEIF (pv2.privilege_id > 0
     AND pv2.priv_value_cd=yes_cd)
     tempreply->rowlist[row_tot_cnt].celllist[11].string_value = "Yes"
    ELSEIF (pv2.privilege_id > 0
     AND pv2.priv_value_cd=yes_except_for_cd)
     tempreply->rowlist[row_tot_cnt].celllist[11].string_value = "Yes except for"
    ELSEIF (pv2.privilege_id > 0
     AND pv2.priv_value_cd=no_except_for_cd)
     tempreply->rowlist[row_tot_cnt].celllist[11].string_value = "No except for"
    ELSEIF (pv2.privilege_id > 0
     AND pv2.priv_value_cd=no_cd)
     tempreply->rowlist[row_tot_cnt].celllist[11].string_value = "No"
    ENDIF
    tempreply->rowlist[row_tot_cnt].celllist[12].string_value = "", tempreply->rowlist[row_tot_cnt].
    celllist[13].string_value = "", tempreply->rowlist[row_tot_cnt].celllist[14].string_value =
    "PrefMaint",
    tempreply->rowlist[row_tot_cnt].celllist[15].string_value = resolution_txt
   ENDIF
   IF (priv_exists_ind=1
    AND firstnet_found=0
    AND fn=0
    AND detail_mode=1)
    row_tot_cnt = (size(tempreply->rowlist,5)+ 1), stat = alterlist(tempreply->rowlist,row_tot_cnt),
    stat = alterlist(tempreply->rowlist[row_tot_cnt].celllist,col_cnt),
    tempreply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, tempreply->rowlist[
    row_tot_cnt].celllist[2].string_value = "MUL_IVCOMPATINTERRUPTION", tempreply->rowlist[
    row_tot_cnt].celllist[3].string_value = "3",
    tempreply->rowlist[row_tot_cnt].celllist[4].string_value = firstnet_value, tempreply->rowlist[
    row_tot_cnt].celllist[5].string_value = "Application", tempreply->rowlist[row_tot_cnt].celllist[6
    ].string_value = firstnet_app_desc,
    tempreply->rowlist[row_tot_cnt].celllist[7].string_value = cv.display, tempreply->rowlist[
    row_tot_cnt].celllist[8].string_value = "Order"
    IF (pv1.privilege_id=0)
     tempreply->rowlist[row_tot_cnt].celllist[9].string_value = "Not defined, default Yes"
    ELSEIF (pv1.privilege_id > 0
     AND pv1.priv_value_cd=yes_cd)
     tempreply->rowlist[row_tot_cnt].celllist[9].string_value = "Yes"
    ELSEIF (pv1.privilege_id > 0
     AND pv1.priv_value_cd=yes_except_for_cd)
     tempreply->rowlist[row_tot_cnt].celllist[9].string_value = "Yes except for"
    ELSEIF (pv1.privilege_id > 0
     AND pv1.priv_value_cd=no_except_for_cd)
     tempreply->rowlist[row_tot_cnt].celllist[9].string_value = "No except for"
    ELSEIF (pv1.privilege_id > 0
     AND pv1.priv_value_cd=no_cd)
     tempreply->rowlist[row_tot_cnt].celllist[9].string_value = "No"
    ENDIF
    tempreply->rowlist[row_tot_cnt].celllist[10].string_value = "Prescribe"
    IF (pv2.privilege_id=0)
     tempreply->rowlist[row_tot_cnt].celllist[11].string_value = "Not defined, default Yes"
    ELSEIF (pv2.privilege_id > 0
     AND pv2.priv_value_cd=yes_cd)
     tempreply->rowlist[row_tot_cnt].celllist[11].string_value = "Yes"
    ELSEIF (pv2.privilege_id > 0
     AND pv2.priv_value_cd=yes_except_for_cd)
     tempreply->rowlist[row_tot_cnt].celllist[11].string_value = "Yes except for"
    ELSEIF (pv2.privilege_id > 0
     AND pv2.priv_value_cd=no_except_for_cd)
     tempreply->rowlist[row_tot_cnt].celllist[11].string_value = "No except for"
    ELSEIF (pv2.privilege_id > 0
     AND pv2.priv_value_cd=no_cd)
     tempreply->rowlist[row_tot_cnt].celllist[11].string_value = "No"
    ENDIF
    tempreply->rowlist[row_tot_cnt].celllist[12].string_value = "", tempreply->rowlist[row_tot_cnt].
    celllist[13].string_value = "", tempreply->rowlist[row_tot_cnt].celllist[14].string_value =
    "PrefMaint",
    tempreply->rowlist[row_tot_cnt].celllist[15].string_value = resolution_txt
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 IF (detail_mode=1)
  SET ccnt = size(tempreply->rowlist,5)
  IF (ccnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(ccnt))
    DETAIL
     row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat =
     alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
     reply->rowlist[d.seq].celllist[1].string_value = tempreply->rowlist[d.seq].celllist[1].
     string_value, reply->rowlist[d.seq].celllist[2].string_value = tempreply->rowlist[d.seq].
     celllist[2].string_value, reply->rowlist[d.seq].celllist[3].string_value = tempreply->rowlist[d
     .seq].celllist[3].string_value,
     reply->rowlist[d.seq].celllist[4].string_value = tempreply->rowlist[d.seq].celllist[4].
     string_value, reply->rowlist[d.seq].celllist[5].string_value = tempreply->rowlist[d.seq].
     celllist[5].string_value, reply->rowlist[d.seq].celllist[6].string_value = tempreply->rowlist[d
     .seq].celllist[6].string_value,
     reply->rowlist[d.seq].celllist[7].string_value = tempreply->rowlist[d.seq].celllist[7].
     string_value, reply->rowlist[d.seq].celllist[8].string_value = tempreply->rowlist[d.seq].
     celllist[8].string_value, reply->rowlist[d.seq].celllist[9].string_value = tempreply->rowlist[d
     .seq].celllist[9].string_value,
     reply->rowlist[d.seq].celllist[10].string_value = tempreply->rowlist[d.seq].celllist[10].
     string_value, reply->rowlist[d.seq].celllist[11].string_value = tempreply->rowlist[d.seq].
     celllist[11].string_value, reply->rowlist[d.seq].celllist[12].string_value = tempreply->rowlist[
     d.seq].celllist[12].string_value,
     reply->rowlist[d.seq].celllist[13].string_value = tempreply->rowlist[d.seq].celllist[13].
     string_value, reply->rowlist[d.seq].celllist[14].string_value = tempreply->rowlist[d.seq].
     celllist[14].string_value, reply->rowlist[d.seq].celllist[15].string_value = tempreply->rowlist[
     d.seq].celllist[15].string_value
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
