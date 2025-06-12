CREATE PROGRAM dm_cm_rdm_prsnl:dba
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
 FREE RECORD dcdl_template_reply
 RECORD dcdl_template_reply(
   1 status = vc
   1 message = vc
 )
 DECLARE content_domain_name = vc WITH protect, constant("PRSNL")
 DECLARE dcdl_err_msg = vc WITH protect, noconstant("")
 SET dcdl_template_reply->status = "F"
 SET readme_data->status = "S"
 SET readme_data->message = concat("Failed to import data into CONTENT_PROPERTY* Tables for domain:",
  content_domain_name)
 SET stat = alterlist(dcip_template_request->list,1)
 SET dcip_template_request->list[1].domain_name = content_domain_name
 SET dcip_template_request->list[1].prop_csv = "cer_install:kia_cp_prsnl_properties.csv"
 SET dcip_template_request->list[1].reltn_csv = "cer_install:kia_cp_prsnl_reltn.csv"
 SET dcip_template_request->list[1].map_csv = "cer_install:kia_cp_prsnl_map.csv"
 CALL echo("** Execute dm_cm_imp_properties **")
 EXECUTE dm_cm_imp_properties  WITH replace(request,dcip_template_request), replace(reply,
  dcdl_template_reply)
 SET readme_data->message = dcdl_template_reply->message
 IF ( NOT ((dcdl_template_reply->status="S")))
  SET readme_data->status = "F"
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
 EXECUTE dm_dbimport "cer_install:kia_cp_prsnl_cdi.csv", "dm_content_domain_info_load", 1000
 IF ((reply->status_data.status != "S"))
  SET readme_data->status = "F"
  SET readme_data->message = reply->status_data.subeventstatus[1].targetobjectvalue
  GO TO exit_script
 ENDIF
 CALL echo("** Create record in dm_info for PRSNL conversion **")
 SELECT INTO "nl:"
  FROM dm_info
  WHERE info_domain="KNOWLEDGE INDEX APPLICATIONS"
   AND info_name="CSVCONV-Personnel with demographic reltn"
  WITH nocounter
 ;end select
 IF (error(dcdl_err_msg,1) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to retrieve data from DM_INFO: ",dcdl_err_msg)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  INSERT  FROM dm_info
   SET info_domain = "KNOWLEDGE INDEX APPLICATIONS", info_name = cm_domain_request->domain_list[
    dcdl_load_cnt].domain_desc
   WITH nocounter
  ;end insert
  IF (error(dcdl_err_msg,1) > 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat(
    "Failed to update table dm_info with CSVCONV-Personnel with demographic reltn: ",dcdl_err_msg)
   GO TO exit_script
  ENDIF
 ENDIF
 EXECUTE dm_dbimport "cer_install:kia_cp_prsnl_sql_ltxt.csv", "dm_cm_load_sql_long_txt", 1000
 IF ( NOT ((reply->status_data.status="S")))
  SET readme_data->status = "F"
  SET readme_data->message = reply->status_data.subeventstatus[1].targetobjectvalue
  GO TO exit_script
 ENDIF
#exit_script
 IF ((readme_data->status="S"))
  SET readme_data->message = "SUCCESS: all properties imoprted"
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 FREE RECORD dcip_template_request
 FREE RECORD dcdl_template_reply
END GO
