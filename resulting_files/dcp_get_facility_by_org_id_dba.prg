CREATE PROGRAM dcp_get_facility_by_org_id:dba
 RECORD reply(
   1 census_ind = i2
   1 chart_format_id = f8
   1 contributor_source_cd = f8
   1 contributor_system_cd = f8
   1 data_status_cd = f8
   1 discipline_type_cd = f8
   1 facility_accn_prefix_cd = f8
   1 location_cd = f8
   1 location_disp = c40
   1 location_desc = c60
   1 location_mean = c12
   1 location_type_cd = f8
   1 location_type_disp = c40
   1 location_type_desc = c60
   1 location_type_mean = c12
   1 organization_id = f8
   1 patcare_node_ind = i2
   1 ref_lab_acct_nbr = vc
   1 registration_ind = i2
   1 resource_ind = i2
   1 transmit_outbound_order_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET cdf_meaning = "FACILITY"
 SET code_set = 222
 EXECUTE cpm_get_cd_for_cdf
 SET facility = code_value
 SET code_value = 0.0
 SET cdf_meaning = "DELETED"
 SET code_set = 48
 EXECUTE cpm_get_cd_for_cdf
 SET deleted = code_value
 SELECT INTO "nl:"
  l.location_cd
  FROM location l
  WHERE (l.organization_id=request->organization_id)
   AND l.location_type_cd=facility
   AND l.active_status_cd != deleted
   AND l.active_ind=1
   AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND l.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   reply->census_ind = l.census_ind, reply->chart_format_id = l.chart_format_id, reply->
   contributor_source_cd = l.contributor_source_cd,
   reply->contributor_system_cd = l.contributor_system_cd, reply->data_status_cd = l.data_status_cd,
   reply->discipline_type_cd = l.discipline_type_cd,
   reply->facility_accn_prefix_cd = l.facility_accn_prefix_cd, reply->location_cd = l.location_cd,
   reply->location_type_cd = l.location_type_cd,
   reply->organization_id = l.organization_id, reply->patcare_node_ind = l.patcare_node_ind, reply->
   ref_lab_acct_nbr = l.ref_lab_acct_nbr,
   reply->registration_ind = l.registration_ind, reply->resource_ind = l.resource_ind, reply->
   transmit_outbound_order_ind = l.transmit_outbound_order_ind
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
