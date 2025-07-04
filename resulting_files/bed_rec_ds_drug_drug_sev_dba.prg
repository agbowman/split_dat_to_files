CREATE PROGRAM bed_rec_ds_drug_drug_sev:dba
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
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET reply->run_status_flag = 1
 SET order_priv_cd = 0.0
 SET prescribe_priv_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6016
   AND cv.cdf_meaning IN ("ORDER", "PRESCRIBE")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="ORDER")
    order_priv_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="PRESCRIBE")
    prescribe_priv_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
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
 SET cat_type_excep_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6015
   AND cv.cdf_meaning="CATALOGTYPE"
   AND cv.active_ind=1
  DETAIL
   cat_type_excep_cd = cv.code_value
  WITH nocounter
 ;end select
 SET pharm_cat_type_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6000
   AND cv.cdf_meaning="PHARMACY"
   AND cv.active_ind=1
  DETAIL
   pharm_cat_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET powerchart_found = 0
 SET surginet_found = 0
 SET firstnet_found = 0
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
    AND nvp.pvc_name="MUL_INTRSEVERITY"
    AND nvp.active_ind=1)
  DETAIL
   IF (ap.application_number=600005
    AND nvp.pvc_value="5")
    powerchart_found = 1
   ELSEIF (ap.application_number=820000
    AND nvp.pvc_value="5")
    surginet_found = 1
   ELSEIF (ap.application_number=4250111
    AND nvp.pvc_value="5")
    firstnet_found = 1
   ENDIF
  WITH nocounter
 ;end select
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
    AND nvp.pvc_name="MUL_INTRSEVERITY"
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
     AND nvp.pvc_value != "5")
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
  WITH nocounter, outerjoin = d
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
