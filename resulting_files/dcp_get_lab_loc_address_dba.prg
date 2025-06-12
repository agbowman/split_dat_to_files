CREATE PROGRAM dcp_get_lab_loc_address:dba
 RECORD reply(
   1 qual[1]
     2 address_id = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 address_format_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 contact_name = c200
     2 residence_type_cd = f8
     2 comment_txt = c200
     2 residence_type_cd = f8
     2 street_addr = c100
     2 street_addr2 = c100
     2 street_addr3 = c100
     2 street_addr4 = c100
     2 city = c60
     2 state = c25
     2 state_cd = f8
     2 zipcode = c11
     2 zip_code_group_cd = f8
     2 postal_barcode_info = c100
     2 county = c100
     2 county_cd = f8
     2 country = c100
     2 country_cd = f8
     2 residence_cd = f8
     2 mail_stop = c100
     2 updt_cnt = i4
     2 location_name = c100
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE location_cd = f8 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET address_type_cd = 0.0
 SET code_value = 0.0
 SET code_set = 212
 SET cdf_meaning = trim(cnvtupper(request->address_type_meaning))
 EXECUTE cpm_get_cd_for_cdf
 SET address_type_cd = code_value
 SELECT INTO "nl:"
  FROM service_resource sr
  WHERE (sr.service_resource_cd=request->service_resource_cd)
  HEAD REPORT
   location_cd = sr.location_cd
  WITH nocounter
 ;end select
 CALL echo(build("location_cd  = ",location_cd))
 IF (location_cd=0.0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM address a
  WHERE (a.parent_entity_name=request->parent_entity_name)
   AND a.parent_entity_id=location_cd
   AND a.address_type_cd=address_type_cd
   AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND a.active_ind=1
   AND a.address_id != 0
  DETAIL
   reply->qual[1].address_id = a.address_id, reply->qual[count1].active_ind = a.active_ind, reply->
   qual[count1].active_status_cd = a.active_status_cd,
   reply->qual[count1].active_status_dt_tm = cnvtdatetime(a.active_status_dt_tm), reply->qual[count1]
   .active_status_prsnl_id = a.active_status_prsnl_id, reply->qual[count1].address_format_cd = a
   .address_format_cd,
   reply->qual[count1].beg_effective_dt_tm = cnvtdatetime(a.beg_effective_dt_tm), reply->qual[count1]
   .end_effective_dt_tm = cnvtdatetime(a.end_effective_dt_tm), reply->qual[count1].contact_name = a
   .contact_name,
   reply->qual[count1].residence_type_cd = a.residence_type_cd, reply->qual[count1].comment_txt = a
   .comment_txt, reply->qual[count1].residence_type_cd = a.residence_type_cd,
   reply->qual[count1].street_addr = a.street_addr, reply->qual[count1].street_addr2 = a.street_addr2,
   reply->qual[count1].street_addr3 = a.street_addr3,
   reply->qual[count1].street_addr4 = a.street_addr4, reply->qual[count1].city = a.city, reply->qual[
   count1].state = a.state,
   reply->qual[count1].state_cd = a.state_cd, reply->qual[count1].zipcode = a.zipcode, reply->qual[
   count1].zip_code_group_cd = a.zip_code_group_cd,
   reply->qual[count1].postal_barcode_info = a.postal_barcode_info, reply->qual[count1].mail_stop = a
   .mail_stop, reply->qual[count1].county = a.county,
   reply->qual[count1].county_cd = a.county_cd, reply->qual[count1].country = a.country, reply->qual[
   count1].country_cd = a.country_cd,
   reply->qual[count1].residence_cd = a.residence_cd, reply->qual[count1].updt_cnt = a.updt_cnt,
   reply->qual[count1].location_name = uar_get_code_display(location_cd)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 SET ierrorcode = error(serrormsg,1)
 IF (ierrorcode != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",serrormsg))
  CALL echo("*********************************")
  CALL reportfailure("ERROR","F","DCP_GET_LAB_LOC_ADDRESS",serrormsg)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
