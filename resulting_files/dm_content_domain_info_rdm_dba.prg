CREATE PROGRAM dm_content_domain_info_rdm:dba
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
 DECLARE dcdir_initial_backfill_ind = i2 WITH public, noconstant(0)
 FREE RECORD dcdi_domain_request
 RECORD dcdi_domain_request(
   1 domain_cnt = i4
   1 domain_list[*]
     2 domain_name = vc
     2 domain_desc = vc
 )
 FREE RECORD dcdi_domain_reply
 RECORD dcdi_domain_reply(
   1 status = vc
   1 message = vc
 )
 DECLARE dcdi_domain_list_cnt = i4 WITH protect, noconstant(0)
 IF (validate(reply->status_data.status,"Z")="Z")
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
 ENDIF
 SET reply->status_data.status = "F"
 SET readme_data->status = "F"
 SET readme_data->message = "Failed to import data into CONTENT_DOMAIN_INFO"
 SET dcdir_initial_backfill_ind = 1
 EXECUTE dm_dbimport "cer_install:content_domain_info.csv", "dm_content_domain_info_load", 1000
 SET readme_data->message = reply->status_data.subeventstatus[1].targetobjectvalue
 IF ((reply->status_data.status="S"))
  SET readme_data->status = "S"
 ELSE
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 SET readme_data->message = "Failed to import  CSV Converter 2 data into DM_INFO"
 SET dcdi_domain_list_cnt = (dcdi_domain_list_cnt+ 1)
 SET stat = alterlist(dcdi_domain_request->domain_list,dcdi_domain_list_cnt)
 SET dcdi_domain_request->domain_list[dcdi_domain_list_cnt].domain_name = "CVALIAS"
 SET dcdi_domain_request->domain_list[dcdi_domain_list_cnt].domain_desc = "CSVCONV2-CVALIAS"
 SET dcdi_domain_list_cnt = (dcdi_domain_list_cnt+ 1)
 SET stat = alterlist(dcdi_domain_request->domain_list,dcdi_domain_list_cnt)
 SET dcdi_domain_request->domain_list[dcdi_domain_list_cnt].domain_name = "ORC"
 SET dcdi_domain_request->domain_list[dcdi_domain_list_cnt].domain_desc = "CSVCONV2-Order Catalog"
 SET dcdi_domain_list_cnt = (dcdi_domain_list_cnt+ 1)
 SET stat = alterlist(dcdi_domain_request->domain_list,dcdi_domain_list_cnt)
 SET dcdi_domain_request->domain_list[dcdi_domain_list_cnt].domain_name = "PRSNL3"
 SET dcdi_domain_request->domain_list[dcdi_domain_list_cnt].domain_desc = "CSVCONV2-Personnel"
 SET dcdi_domain_list_cnt = (dcdi_domain_list_cnt+ 1)
 SET stat = alterlist(dcdi_domain_request->domain_list,dcdi_domain_list_cnt)
 SET dcdi_domain_request->domain_list[dcdi_domain_list_cnt].domain_name = "CODE_VALUE_OBJ"
 SET dcdi_domain_request->domain_list[dcdi_domain_list_cnt].domain_desc = "CSVCONV2-Code Value"
 SET dcdi_domain_request->domain_cnt = dcdi_domain_list_cnt
 EXECUTE dm_ctm_domain_load  WITH replace(cm_domain_request,dcdi_domain_request), replace(
  cm_domain_reply,dcdi_domain_reply)
 IF ((dcdi_domain_reply->status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = dcdi_domain_reply->message
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = dcdi_domain_reply->message
 ENDIF
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 FREE SET dcdir_initial_backfill_ind
END GO
