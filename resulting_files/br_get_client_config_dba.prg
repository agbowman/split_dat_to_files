CREATE PROGRAM br_get_client_config:dba
 FREE SET reply
 RECORD reply(
   1 client_name = vc
   1 client_mnemonic = vc
   1 unknown_age_ind = i2
   1 unknown_sex_ind = i2
   1 reglist[*]
     2 region_mean = vc
     2 region_display = vc
     2 default_selected_ind = i2
   1 sollist[*]
     2 step_cat_mean = vc
     2 solution_display = vc
     2 live_in_prod_ind = i2
     2 going_live_ind = i2
   1 liclist[*]
     2 license_mean = vc
     2 license_display = vc
     2 default_selected_ind = i2
   1 apply_org_security_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE hold_region = vc
 SELECT INTO "nl:"
  FROM br_client bc
  HEAD REPORT
   reply->client_name = bc.br_client_name, reply->client_mnemonic = bc.client_mnemonic, hold_region
    = bc.region
  WITH counter
 ;end select
 SELECT INTO "nl:"
  FROM br_name_value bnv1,
   br_name_value bnv2
  PLAN (bnv1
   WHERE bnv1.br_nv_key1="STEP_CAT_MEAN")
   JOIN (bnv2
   WHERE bnv2.br_nv_key1=outerjoin("SOLUTION_STATUS")
    AND bnv2.br_value=outerjoin(bnv1.br_name))
  ORDER BY bnv1.br_value
  HEAD REPORT
   solcnt = 0
  HEAD bnv1.br_value
   solcnt = (solcnt+ 1), stat = alterlist(reply->sollist,solcnt), reply->sollist[solcnt].
   step_cat_mean = bnv1.br_name,
   reply->sollist[solcnt].solution_display = bnv1.br_value, reply->sollist[solcnt].live_in_prod_ind
    = 0, reply->sollist[solcnt].going_live_ind = 0
  DETAIL
   IF (bnv2.br_name_value_id > 0)
    IF (bnv2.br_name="LIVE_IN_PROD")
     reply->sollist[solcnt].live_in_prod_ind = 1
    ELSEIF (bnv2.br_name="GOING_LIVE")
     reply->sollist[solcnt].going_live_ind = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_name_value bnv
  PLAN (bnv
   WHERE bnv.br_nv_key1="REGION")
  ORDER BY bnv.br_value
  HEAD REPORT
   regcnt = 0
  DETAIL
   regcnt = (regcnt+ 1), stat = alterlist(reply->reglist,regcnt), reply->reglist[regcnt].region_mean
    = bnv.br_name,
   reply->reglist[regcnt].region_display = bnv.br_value
   IF (((bnv.br_name=hold_region) OR (bnv.br_value=hold_region)) )
    reply->reglist[regcnt].default_selected_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_name_value bnv
  PLAN (bnv
   WHERE bnv.br_nv_key1="LICENSE")
  ORDER BY bnv.br_value
  HEAD REPORT
   liccnt = 0
  DETAIL
   liccnt = (liccnt+ 1), stat = alterlist(reply->liclist,liccnt), reply->liclist[liccnt].license_mean
    = bnv.br_name,
   reply->liclist[liccnt].license_display = bnv.br_value, reply->liclist[liccnt].default_selected_ind
    = bnv.default_selected_ind
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_name_value bnv
  PLAN (bnv
   WHERE bnv.br_nv_key1="SYSTEMPARAM"
    AND bnv.br_client_id=1)
  DETAIL
   IF (bnv.br_name="UNKNOWNAGEIND")
    reply->unknown_age_ind = cnvtint(bnv.br_value)
   ELSEIF (bnv.br_name="UNKNOWNSEXIND")
    reply->unknown_sex_ind = cnvtint(bnv.br_value)
   ENDIF
   IF (bnv.br_name="APPLYORGSECURITYIND")
    reply->apply_org_security_ind = cnvtint(bnv.br_value)
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
