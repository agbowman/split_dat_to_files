CREATE PROGRAM dm_cm_rdm_dta:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 FREE RECORD dcip_template_request
 RECORD dcip_template_request(
   1 list[*]
     2 domain_name = vc
     2 prop_csv = vc
     2 reltn_csv = vc
     2 map_csv = vc
 )
 FREE RECORD dcdl_template_request
 RECORD dcdl_template_request(
   1 domain_cnt = i4
   1 domain_list[*]
     2 domain_name = vc
     2 domain_desc = vc
 )
 FREE RECORD dcdl_template_reply
 RECORD dcdl_template_reply(
   1 status = vc
   1 message = vc
 )
 DECLARE template_domain_name = vc WITH protect, constant("DTA_OBJ")
 SET readme_data->status = "S"
 SET stat = alterlist(dcip_template_request->list,1)
 SET dcip_template_request->list[1].domain_name = template_domain_name
 SET dcip_template_request->list[1].prop_csv = "cer_install:kia_cp_dta_properties.csv"
 SET dcip_template_request->list[1].reltn_csv = "cer_install:kia_cp_dta_reltn.csv"
 CALL echo("** Execute dm_cm_imp_properties **")
 EXECUTE dm_cm_imp_properties  WITH replace(request,dcip_template_request), replace(reply,
  dcdl_template_reply)
 IF ( NOT ((dcdl_template_reply->status="S")))
  SET readme_data->status = "F"
  SET readme_data->message = dcdl_template_reply->message
  GO TO exit_script
 ENDIF
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 CALL echo("** Execute dm_content_domain_info_load **")
 EXECUTE dm_dbimport "cer_install:kia_cp_dta_cdi.csv", "dm_content_domain_info_load", 1000
 IF ( NOT ((reply->status_data.status="S")))
  SET readme_data->status = "F"
  SET readme_data->message = reply->status_data.subeventstatus[1].targetobjectvalue
  GO TO exit_script
 ENDIF
 EXECUTE dm_dbimport "cer_install:kia_cp_dta_sql_ltxt.csv", "dm_cm_load_sql_long_txt", 1000
 IF ( NOT ((reply->status_data.status="S")))
  SET readme_data->status = "F"
  SET readme_data->message = reply->status_data.subeventstatus[1].targetobjectvalue
  GO TO exit_script
 ENDIF
#exit_script
 IF ((readme_data->status="S"))
  SET readme_data->message = "SUCCESS: all properties imported"
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 FREE RECORD dcip_template_request
 FREE RECORD dcdl_template_request
 FREE RECORD dcdl_template_reply
END GO
