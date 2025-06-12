CREATE PROGRAM aps_get_prefix:dba
 RECORD getprompttestsreq(
   1 prefix_cd = f8
   1 default_catalog_cd = f8
   1 prompt_test_qual[*]
     2 specimen_catalog_cd = f8
 )
 RECORD reply(
   1 prefix_cd = f8
   1 prefix_name = c2
   1 prefix_desc = c50
   1 site_cd = f8
   1 unformatted_site_disp = c40
   1 accession_format_cd = f8
   1 order_catalog_cd = f8
   1 case_type_cd = f8
   1 case_type_disp = c40
   1 case_type_desc = vc
   1 case_type_mean = c12
   1 specimen_meaning_qual[1]
     2 specimen_meaning = c12
   1 group_cd = f8
   1 specimen_grouping_cd = f8
   1 service_resource_qual[*]
     2 service_resource_cd = f8
     2 service_resource_disp = c40
     2 service_resource_desc = c60
   1 prompt_test_qual[*]
     2 prefix_cd = f8
     2 task_assay_cd = f8
     2 catalog_cd = f8
     2 specimen_catalog_cd = f8
     2 required_ind = i2
     2 description = vc
     2 specimen_description = vc
     2 text = vc
     2 prompt_id = f8
     2 long_text_id = f8
     2 action_flag = i2
     2 updt_cnt = i4
     2 field_qual[*]
       3 field_nbr = i2
       3 field_type = c18
       3 field_action_flag = i2
       3 field_oe_field_id = f8
       3 oe_field_display = vc
   1 site_disp = c40
   1 rpt_info_qual[*]
     2 rpt_qual[*]
       3 catalog_cd = f8
       3 short_description = c50
       3 primary_ind = i2
       3 mult_allowed_ind = i2
       3 system_ordered_ind = i2
       3 resource_qual[*]
         4 service_resource_cd = f8
         4 service_resource_disp = c40
   1 tag_info_qual[*]
     2 tag_group_cnt = i2
     2 tag_group_qual[*]
       3 tag_type_flag = i2
       3 tag_separator = c1
       3 tag_group_cd = f8
       3 primary_ind = i2
       3 tag_cnt = i2
       3 tag_qual[*]
         4 tag_cd = f8
         4 tag_display = c7
         4 tag_sequence = i4
   1 interface_flag = i2
   1 prefix_service_resource_cd = f8
   1 interface_send_updates_as_new = i2
   1 tracking_service_resource_cd = f8
   1 imaging_interface_ind = i2
   1 imaging_service_resource_cd = f8
   1 imaging_send_updates_as_new = i2
   1 tracking_send_slide_from_spec = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 DECLARE prefix_where = vc WITH protect, noconstant(" ")
 SET stat = alterlist(reply->service_resource_qual,5)
 SET stat = alterlist(reply->prompt_test_qual,5)
 IF ((request->prefix_cd != 0))
  SET prefix_where = build(request->prefix_cd," = P.PREFIX_ID")
 ELSE
  SET prefix_where = concat("'",trim(cnvtupper(request->prefix_name)),"' = P.PREFIX_NAME")
 ENDIF
 EXECUTE aps_get_prefix1 parser(trim(prefix_where))
END GO
