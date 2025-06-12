CREATE PROGRAM aps_get_spec_label_info:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 print_status_data
     2 print_directory = c19
     2 print_filename = c40
     2 print_dir_and_filename = c60
   1 label_job_data
     2 job_directory = vc
     2 job_filename = vc
     2 job_dir_and_filename = vc
     2 job_content = gvc
     2 suppress_spool_ind = i2
     2 line_template = vc
 )
 RECORD data(
   1 maxlabel = i2
   1 current_dt_tm_string = c8
   1 resrc[1]
     2 service_resource_cd = f8
     2 service_resource_disp = vc
     2 label[*]
       3 worklist_nbr = i4
       3 service_resource_cd = f8
       3 mnemonic = vc
       3 description = vc
       3 request_dt_tm = dq8
       3 request_dt_tm_string = c8
       3 priority_cd = f8
       3 priority_disp = c15
       3 case_specimen_id = f8
       3 case_specimen_tag_cd = f8
       3 case_specimen_tag_disp = c15
       3 case_specimen_tag_seq = i4
       3 cassette_id = f8
       3 cassette_tag_cd = f8
       3 cassette_tag_disp = c15
       3 cassette_tag_seq = i4
       3 cassette_sep_disp = c1
       3 cassette_origin_modifier = c7
       3 slide_id = f8
       3 slide_tag_cd = f8
       3 slide_tag_disp = c15
       3 slide_tag_seq = i4
       3 slide_sep_disp = c1
       3 slide_origin_modifier = c7
       3 spec_blk_sld_tag_disp = c15
       3 spec_blk_tag_disp = c15
       3 blk_sld_tag_disp = c15
       3 prefix_cd = f8
       3 accession_nbr = c21
       3 fmt_accession_nbr = c21
       3 acc_site_pre_yy_nbr = c21
       3 acc_site = c5
       3 acc_pre = c2
       3 acc_yy = c2
       3 acc_yyyy = c4
       3 acc_nbr = c7
       3 case_year = i4
       3 case_number = i4
       3 responsible_pathologist_id = f8
       3 responsible_pathologist_name_full = vc
       3 responsible_pathologist_name_last = vc
       3 responsible_pathologist_initial = c2
       3 responsible_resident_id = f8
       3 responsible_resident_name_full = vc
       3 responsible_resident_name_last = vc
       3 responsible_resident_initial = c2
       3 requesting_physician_id = f8
       3 requesting_physician_name_full = vc
       3 requesting_physician_name_last = vc
       3 case_received_dt_tm = dq8
       3 case_received_dt_tm_string = c8
       3 case_collect_dt_tm = dq8
       3 case_collect_dt_tm_string = c8
       3 mrn_alias = vc
       3 fin_nbr_alias = vc
       3 encntr_id = f8
       3 person_id = f8
       3 name_full_formatted = vc
       3 name_last = vc
       3 birth_dt_tm = dq8
       3 birth_dt_tm_string = c8
       3 deceased_dt_tm = dq8
       3 age = vc
       3 sex_cd = f8
       3 sex_disp = vc
       3 sex_desc = vc
       3 admit_doc_name = vc
       3 admit_doc_name_last = vc
       3 organization_id = f8
       3 loc_bed_cd = f8
       3 loc_bed_disp = c15
       3 loc_building_cd = f8
       3 loc_building_disp = c15
       3 loc_facility_cd = f8
       3 loc_facility_disp = c15
       3 location_cd = f8
       3 location_disp = c15
       3 loc_nurse_unit_cd = f8
       3 loc_nurse_unit_disp = c15
       3 loc_room_cd = f8
       3 loc_room_disp = c15
       3 loc_nurse_room_bed_disp = vc
       3 encntr_type_cd = f8
       3 encntr_type_disp = c15
       3 encntr_type_desc = vc
       3 adequacy_ind = i2
       3 adequacy_string = vc
       3 specimen_cd = f8
       3 specimen_disp = c15
       3 specimen_description = vc
       3 received_fixative_cd = f8
       3 received_fixative_disp = c15
       3 received_fixative_desc = vc
       3 fixative_added_cd = f8
       3 fixative_added_disp = c15
       3 fixative_added_desc = vc
       3 fixative_cd = f8
       3 fixative_disp = c15
       3 fixative_desc = vc
       3 supplemental_tag = c2
       3 pieces = c3
       3 sl_supplemental_tag = c2
       3 stain_task_assay_cd = f8
       3 stain_mnemonic = vc
       3 stain_description = vc
       3 inventory_type = i2
       3 inventory_code = vc
       3 location_code = vc
       3 compartment_code = vc
       3 spec_tracking_loc_disp = vc
       3 compartment_disp = vc
       3 storage_shelf_disp = vc
       3 organization_name = vc
       3 domain = vc
       3 identifier_type = vc
       3 identifier_code = vc
       3 identifier_disp = vc
       3 hopper = vc
       3 cassette_color = vc
       3 generic_field1 = vc
       3 generic_field2 = vc
       3 generic_field3 = vc
 )
 RECORD printer(
   1 output_dest_cd = f8
   1 name = vc
   1 label_program_prefix = vc
   1 label_program = vc
   1 label_x_pos = i4
   1 label_y_pos = i4
   1 device_cd = f8
   1 flatfile = vc
   1 hopper_name = vc
   1 script = vc
 )
 RECORD temp_inventory(
   1 specimen_list[*]
     2 id = f8
 )
#script
 RECORD cdinfo(
   1 fail = i2
   1 code = f8
   1 display = c15
   1 description = c50
   1 meaning = c12
   1 display_key = c15
 )
 DECLARE ltempinventorycnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET error_cnt = 0
 SET data->maxlabel = 0
 SET verified_code = 0.0
 SET ordered_code = 0.0
 SELECT INTO "nl:"
  pt.case_id, fmt_accession_nbr = decode(pc.seq,uar_fmt_accession(pc.accession_nbr,size(pc
     .accession_nbr,1)),"")
  FROM (dummyt d  WITH seq = value(request->spec_cnt)),
   processing_task pt,
   pathology_case pc,
   person p,
   encounter e,
   discrete_task_assay dta,
   case_specimen cs,
   ap_tag t
  PLAN (d)
   JOIN (pt
   WHERE (request->case_id=pt.case_id)
    AND (request->spec_qual[d.seq].case_specimen_id=pt.case_specimen_id)
    AND 4=pt.create_inventory_flag)
   JOIN (pc
   WHERE pt.case_id=pc.case_id)
   JOIN (p
   WHERE pc.person_id=p.person_id)
   JOIN (e
   WHERE pc.encntr_id=e.encntr_id)
   JOIN (dta
   WHERE pt.task_assay_cd=dta.task_assay_cd)
   JOIN (cs
   WHERE pt.case_specimen_id=cs.case_specimen_id)
   JOIN (t
   WHERE t.tag_id=cs.specimen_tag_id)
  ORDER BY t.tag_group_id, t.tag_sequence, pt.case_specimen_id,
   pt.create_inventory_flag DESC
  HEAD REPORT
   lcnt = 0, data->resrc[1].service_resource_cd = pt.service_resource_cd, ltempinventorycnt = 0
  HEAD pt.case_specimen_id
   IF (pt.case_specimen_id > 0
    AND cs.label_create_dt_tm=null)
    ltempinventorycnt += 1
    IF (ltempinventorycnt > size(temp_inventory->specimen_list,5))
     stat = alterlist(temp_inventory->specimen_list,(ltempinventorycnt+ 9))
    ENDIF
    temp_inventory->specimen_list[ltempinventorycnt].id = pt.case_specimen_id
   ENDIF
  DETAIL
   lcnt += 1
   IF ((lcnt > data->maxlabel))
    data->maxlabel = lcnt
   ENDIF
   stat = alterlist(data->resrc[1].label,lcnt), data->resrc[1].label[lcnt].priority_cd = pt
   .priority_cd, data->resrc[1].label[lcnt].worklist_nbr = pt.worklist_nbr,
   data->resrc[1].label[lcnt].service_resource_cd = pt.service_resource_cd, data->resrc[1].label[lcnt
   ].mnemonic = dta.mnemonic, data->resrc[1].label[lcnt].description = dta.description,
   data->resrc[1].label[lcnt].request_dt_tm = pt.request_dt_tm, data->resrc[1].label[lcnt].
   request_dt_tm_string = format(cnvtdatetime(pt.request_dt_tm),"mm/dd/yy;;d"), data->resrc[1].label[
   lcnt].priority_cd = pt.priority_cd,
   data->resrc[1].label[lcnt].case_specimen_id = pt.case_specimen_id, data->resrc[1].label[lcnt].
   case_specimen_tag_cd = pt.case_specimen_tag_id, data->resrc[1].label[lcnt].cassette_id = pt
   .cassette_id,
   data->resrc[1].label[lcnt].cassette_tag_cd = pt.cassette_tag_id, data->resrc[1].label[lcnt].
   slide_id = pt.slide_id, data->resrc[1].label[lcnt].slide_tag_cd = pt.slide_tag_id,
   data->resrc[1].label[lcnt].accession_nbr = pc.accession_nbr, data->resrc[1].label[lcnt].
   fmt_accession_nbr = fmt_accession_nbr, data->resrc[1].label[lcnt].prefix_cd = pc.prefix_id,
   data->resrc[1].label[lcnt].case_year = pc.case_year, data->resrc[1].label[lcnt].case_number = pc
   .case_number, data->resrc[1].label[lcnt].responsible_pathologist_id = pc
   .responsible_pathologist_id,
   data->resrc[1].label[lcnt].responsible_resident_id = pc.responsible_resident_id, data->resrc[1].
   label[lcnt].requesting_physician_id = pc.requesting_physician_id, data->resrc[1].label[lcnt].
   case_received_dt_tm = pc.case_received_dt_tm,
   data->resrc[1].label[lcnt].case_received_dt_tm_string = format(cnvtdatetime(pc.case_received_dt_tm
     ),"@SHORTDATE"), data->resrc[1].label[lcnt].case_collect_dt_tm = pc.case_collect_dt_tm, data->
   resrc[1].label[lcnt].case_collect_dt_tm_string = format(cnvtdatetime(pc.case_collect_dt_tm),
    "@SHORTDATE"),
   data->resrc[1].label[lcnt].name_full_formatted = p.name_full_formatted, data->resrc[1].label[lcnt]
   .name_last = p.name_last, data->resrc[1].label[lcnt].birth_dt_tm = cnvtdatetimeutc(datetimezone(p
     .birth_dt_tm,p.birth_tz),1),
   data->resrc[1].label[lcnt].birth_dt_tm_string = format(cnvtdatetime(data->resrc[1].label[lcnt].
     birth_dt_tm),"@SHORTDATE"), data->resrc[1].label[lcnt].deceased_dt_tm = p.deceased_dt_tm, data->
   resrc[1].label[lcnt].sex_cd = p.sex_cd,
   data->resrc[1].label[lcnt].encntr_id = e.encntr_id, data->resrc[1].label[lcnt].organization_id = e
   .organization_id, data->resrc[1].label[lcnt].person_id = pc.person_id,
   data->resrc[1].label[lcnt].loc_bed_cd = e.loc_bed_cd, data->resrc[1].label[lcnt].loc_building_cd
    = e.loc_building_cd, data->resrc[1].label[lcnt].loc_facility_cd = e.loc_facility_cd,
   data->resrc[1].label[lcnt].location_cd = e.location_cd, data->resrc[1].label[lcnt].
   loc_nurse_unit_cd = e.loc_nurse_unit_cd, data->resrc[1].label[lcnt].loc_room_cd = e.loc_room_cd,
   data->resrc[1].label[lcnt].encntr_type_cd = e.encntr_type_cd, data->resrc[1].label[lcnt].
   adequacy_ind = cs.adequacy_ind, data->resrc[1].label[lcnt].specimen_cd = cs.specimen_cd,
   data->resrc[1].label[lcnt].specimen_description = cs.specimen_description, data->resrc[1].label[
   lcnt].received_fixative_cd = cs.received_fixative_cd, data->resrc[1].label[lcnt].fixative_added_cd
    = cs.fixative_added_cd
  FOOT REPORT
   stat = alterlist(temp_inventory->specimen_list,ltempinventorycnt)
  WITH nocounter, maxqual(pt,1)
 ;end select
 SET data->current_dt_tm_string = format(cnvtdatetime(sysdate),"mm/dd/yy;;d")
 SELECT INTO "nl:"
  o.output_dest_cd, o.name, o.label_prefix,
  o.label_program_name, o.label_xpos, o.label_ypos
  FROM output_dest o
  WHERE (o.output_dest_cd=request->output_dest_cd)
  DETAIL
   printer->output_dest_cd = o.output_dest_cd, printer->name = o.name, printer->label_program_prefix
    = o.label_prefix,
   printer->label_program = o.label_program_name, printer->label_x_pos = o.label_xpos, printer->
   label_y_pos = o.label_ypos,
   printer->device_cd = o.device_cd
  WITH nocounter
 ;end select
 EXECUTE cpm_create_file_name_logical "aps_label", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 IF ( NOT (validate(label_job_data,0)))
  RECORD label_job_data(
    1 fields[*]
      2 name = vc
      2 size = i2
    1 job_directory = vc
    1 job_file_suffix = vc
    1 format_file_name = vc
    1 printer_name = vc
    1 copies = i4
  )
 ENDIF
 DECLARE field_cnt = i4 WITH protect, noconstant(0)
 SET field_cnt = 122
 SET stat = alterlist(label_job_data->fields,field_cnt)
 SET label_job_data->fields[1].name = "NBR_OF_LABELS"
 SET label_job_data->fields[2].name = "LABEL_SEQ"
 SET label_job_data->fields[3].name = "CURRENT_DT_TM_STRING"
 SET label_job_data->fields[4].name = "SERVICE_RESOURCE_CD"
 SET label_job_data->fields[5].name = "SERVICE_RESOURCE_DISP"
 SET label_job_data->fields[6].name = "WORKLIST_NBR"
 SET label_job_data->fields[7].name = "MNEMONIC"
 SET label_job_data->fields[8].name = "DESCRIPTION"
 SET label_job_data->fields[9].name = "REQUEST_DT_TM"
 SET label_job_data->fields[10].name = "REQUEST_DT_TM_STRING"
 SET label_job_data->fields[11].name = "PRIORITY_CD"
 SET label_job_data->fields[12].name = "PRIORITY_DISP"
 SET label_job_data->fields[13].name = "CASE_SPECIMEN_ID"
 SET label_job_data->fields[14].name = "CASE_SPECIMEN_TAG_CD"
 SET label_job_data->fields[15].name = "CASE_SPECIMEN_TAG_DISP"
 SET label_job_data->fields[16].name = "CASSETTE_ID"
 SET label_job_data->fields[17].name = "CASSETTE_TAG_CD"
 SET label_job_data->fields[18].name = "CASSETTE_TAG_DISP"
 SET label_job_data->fields[19].name = "CASSETTE_SEP_DISP"
 SET label_job_data->fields[20].name = "CASSETTE_ORIGIN_MODIFIER"
 SET label_job_data->fields[21].name = "SLIDE_ID"
 SET label_job_data->fields[22].name = "SLIDE_TAG_CD"
 SET label_job_data->fields[23].name = "SLIDE_TAG_DISP"
 SET label_job_data->fields[24].name = "SLIDE_SEP_DISP"
 SET label_job_data->fields[25].name = "SLIDE_ORIGIN_MODIFIER"
 SET label_job_data->fields[26].name = "SPEC_BLK_SLD_TAG_DISP"
 SET label_job_data->fields[27].name = "SPEC_BLK_TAG_DISP"
 SET label_job_data->fields[28].name = "BLK_SLD_TAG_DISP"
 SET label_job_data->fields[29].name = "PREFIX_CD"
 SET label_job_data->fields[30].name = "ACCESSION_NBR"
 SET label_job_data->fields[31].name = "FMT_ACCESSION_NBR"
 SET label_job_data->fields[32].name = "ACC_SITE_PRE_YY_NBR"
 SET label_job_data->fields[33].name = "ACC_SITE"
 SET label_job_data->fields[34].name = "ACC_PRE"
 SET label_job_data->fields[35].name = "ACC_YY"
 SET label_job_data->fields[36].name = "ACC_YYYY"
 SET label_job_data->fields[37].name = "ACC_NBR"
 SET label_job_data->fields[38].name = "CASE_YEAR"
 SET label_job_data->fields[39].name = "CASE_NUMBER"
 SET label_job_data->fields[40].name = "RESPONSIBLE_PATHOLOGIST_ID"
 SET label_job_data->fields[41].name = "RESPONSIBLE_PATHOLOGIST_NAME_FULL"
 SET label_job_data->fields[42].name = "RESPONSIBLE_PATHOLOGIST_NAME_LAST"
 SET label_job_data->fields[43].name = "RESPONSIBLE_PATHOLOGIST_INITIAL"
 SET label_job_data->fields[44].name = "RESPONSIBLE_RESIDENT_ID"
 SET label_job_data->fields[45].name = "RESPONSIBLE_RESIDENT_NAME_FULL"
 SET label_job_data->fields[46].name = "RESPONSIBLE_RESIDENT_NAME_LAST"
 SET label_job_data->fields[47].name = "RESPONSIBLE_RESIDENT_INITIAL"
 SET label_job_data->fields[48].name = "REQUESTING_PHYSICIAN_ID"
 SET label_job_data->fields[49].name = "REQUESTING_PHYSICIAN_NAME_FULL"
 SET label_job_data->fields[50].name = "REQUESTING_PHYSICIAN_NAME_LAST"
 SET label_job_data->fields[51].name = "CASE_RECEIVED_DT_TM"
 SET label_job_data->fields[52].name = "CASE_RECEIVED_DT_TM_STRING"
 SET label_job_data->fields[53].name = "CASE_COLLECT_DT_TM"
 SET label_job_data->fields[54].name = "CASE_COLLECT_DT_TM_STRING"
 SET label_job_data->fields[55].name = "MRN_ALIAS"
 SET label_job_data->fields[56].name = "FIN_NBR_ALIAS"
 SET label_job_data->fields[57].name = "ENCNTR_ID"
 SET label_job_data->fields[58].name = "PERSON_ID"
 SET label_job_data->fields[59].name = "NAME_FULL_FORMATTED"
 SET label_job_data->fields[60].name = "NAME_LAST"
 SET label_job_data->fields[61].name = "BIRTH_DT_TM"
 SET label_job_data->fields[62].name = "BIRTH_DT_TM_STRING"
 SET label_job_data->fields[63].name = "DECEASED_DT_TM"
 SET label_job_data->fields[64].name = "AGE"
 SET label_job_data->fields[65].name = "SEX_CD"
 SET label_job_data->fields[66].name = "SEX_DISP"
 SET label_job_data->fields[67].name = "SEX_DESC"
 SET label_job_data->fields[68].name = "ADMIT_DOC_NAME"
 SET label_job_data->fields[69].name = "ADMIT_DOC_NAME_LAST"
 SET label_job_data->fields[70].name = "ORGANIZATION_ID"
 SET label_job_data->fields[71].name = "LOC_BED_CD"
 SET label_job_data->fields[72].name = "LOC_BED_DISP"
 SET label_job_data->fields[73].name = "LOC_BUILDING_CD"
 SET label_job_data->fields[74].name = "LOC_BUILDING_DISP"
 SET label_job_data->fields[75].name = "LOC_FACILITY_CD"
 SET label_job_data->fields[76].name = "LOC_FACILITY_DISP"
 SET label_job_data->fields[77].name = "LOCATION_CD"
 SET label_job_data->fields[78].name = "LOCATION_DISP"
 SET label_job_data->fields[79].name = "LOC_NURSE_UNIT_CD"
 SET label_job_data->fields[80].name = "LOC_NURSE_UNIT_DISP"
 SET label_job_data->fields[81].name = "LOC_ROOM_CD"
 SET label_job_data->fields[82].name = "LOC_ROOM_DISP"
 SET label_job_data->fields[83].name = "LOC_NURSE_ROOM_BED_DISP"
 SET label_job_data->fields[84].name = "ENCNTR_TYPE_CD"
 SET label_job_data->fields[85].name = "ENCNTR_TYPE_DISP"
 SET label_job_data->fields[86].name = "ENCNTR_TYPE_DESC"
 SET label_job_data->fields[87].name = "ADEQUACY_IND"
 SET label_job_data->fields[88].name = "ADEQUACY_STRING"
 SET label_job_data->fields[89].name = "SPECIMEN_CD"
 SET label_job_data->fields[90].name = "SPECIMEN_DISP"
 SET label_job_data->fields[91].name = "SPECIMEN_DESCRIPTION"
 SET label_job_data->fields[92].name = "RECEIVED_FIXATIVE_CD"
 SET label_job_data->fields[93].name = "RECEIVED_FIXATIVE_DISP"
 SET label_job_data->fields[94].name = "RECEIVED_FIXATIVE_DESC"
 SET label_job_data->fields[95].name = "FIXATIVE_ADDED_CD"
 SET label_job_data->fields[96].name = "FIXATIVE_ADDED_DISP"
 SET label_job_data->fields[97].name = "FIXATIVE_ADDED_DESC"
 SET label_job_data->fields[98].name = "FIXATIVE_CD"
 SET label_job_data->fields[99].name = "FIXATIVE_DISP"
 SET label_job_data->fields[100].name = "FIXATIVE_DESC"
 SET label_job_data->fields[101].name = "SUPPLEMENTAL_TAG"
 SET label_job_data->fields[102].name = "PIECES"
 SET label_job_data->fields[103].name = "SL_SUPPLEMENTAL_TAG"
 SET label_job_data->fields[104].name = "STAIN_TASK_ASSAY_CD"
 SET label_job_data->fields[105].name = "STAIN_MNEMONIC"
 SET label_job_data->fields[106].name = "STAIN_DESCRIPTION"
 SET label_job_data->fields[107].name = "INVENTORY_CODE"
 SET label_job_data->fields[108].name = "LOCATION_CODE"
 SET label_job_data->fields[109].name = "COMPARTMENT_CODE"
 SET label_job_data->fields[110].name = "SPEC_TRACKING_LOC_DISP"
 SET label_job_data->fields[111].name = "STORAGE_SHELF_DISP"
 SET label_job_data->fields[112].name = "COMPARTMENT_DISP"
 SET label_job_data->fields[113].name = "ORGANIZATION_NAME"
 SET label_job_data->fields[114].name = "DOMAIN"
 SET label_job_data->fields[115].name = "IDENTIFIER_TYPE"
 SET label_job_data->fields[116].name = "IDENTIFIER_CODE"
 SET label_job_data->fields[117].name = "IDENTIFIER_DISP"
 SET label_job_data->fields[118].name = "HOPPER"
 SET label_job_data->fields[119].name = "CASSETTE_COLOR"
 SET label_job_data->fields[120].name = "GENERIC_FIELD1"
 SET label_job_data->fields[121].name = "GENERIC_FIELD2"
 SET label_job_data->fields[122].name = "GENERIC_FIELD3"
 EXECUTE value(concat(trim(printer->label_program_prefix),trim(printer->label_program))) reply->
 print_status_data.print_filename
 IF (size(printer->flatfile) > 0)
  IF (checkprg("APS_LABEL_RULE") > 0)
   EXECUTE aps_label_rule
  ENDIF
  EXECUTE value(concat("APS_LABEL_JOB_",printer->flatfile))
  IF ((reply->status_data.status="Z"))
   GO TO end_script
  ELSEIF (ltempinventorycnt > 0)
   IF (trim(printer->flatfile)="NICELABEL")
    IF (updatelabelcreateforspecimen(3)=0)
     SET reply->status_data.status = "F"
     GO TO exit_script
    ENDIF
   ELSE
    IF (updatelabelcreateforspecimen(1)=0)
     SET reply->status_data.status = "F"
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 GO TO exit_script
 SUBROUTINE (updatelabelcreateforspecimen(nlabelcreatetype=i2) =i2 WITH protect)
   DECLARE lqualcnt = i4 WITH protect, noconstant(0)
   DECLARE nloopcnt = i4 WITH protect, noconstant(0)
   DECLARE batch_size = i4 WITH protect, constant(20)
   DECLARE lpaddedsize = i4 WITH protect, noconstant(0)
   DECLARE lindex = i4 WITH protect, noconstant(0)
   SET nloopcnt = ceil((cnvtreal(ltempinventorycnt)/ batch_size))
   SET lpaddedsize = (nloopcnt * batch_size)
   SET stat = alterlist(temp_inventory->specimen_list,lpaddedsize)
   FOR (lindex = (ltempinventorycnt+ 1) TO lpaddedsize)
     SET temp_inventory->specimen_list[lindex].id = temp_inventory->specimen_list[ltempinventorycnt].
     id
   ENDFOR
   SELECT INTO "nl:"
    cs.case_specimen_id
    FROM case_specimen cs,
     (dummyt d  WITH seq = value(nloopcnt))
    PLAN (d)
     JOIN (cs
     WHERE expand(lindex,(((d.seq - 1) * batch_size)+ 1),(d.seq * batch_size),cs.case_specimen_id,
      temp_inventory->specimen_list[lindex].id))
    HEAD REPORT
     lqualcnt = 0
    DETAIL
     lqualcnt += 1
    WITH nocounter, forupdate(cs)
   ;end select
   IF (ltempinventorycnt != lqualcnt)
    CALL handle_errors("LOCK","F","TABLE","CASE_SPECIMEN")
    RETURN(0)
   ENDIF
   UPDATE  FROM case_specimen cs,
     (dummyt d  WITH seq = value(ltempinventorycnt))
    SET cs.label_create_dt_tm =
     IF (cs.label_create_dt_tm=null) cnvtdatetime(sysdate)
     ELSE cs.label_create_dt_tm
     ENDIF
     , cs.label_create_type_flag = nlabelcreatetype, cs.updt_id = reqinfo->updt_id,
     cs.updt_task = reqinfo->updt_task, cs.updt_applctx = reqinfo->updt_applctx, cs.updt_dt_tm =
     cnvtdatetime(sysdate)
    PLAN (d)
     JOIN (cs
     WHERE (cs.case_specimen_id=temp_inventory->specimen_list[d.seq].id))
    WITH nocounter
   ;end update
   IF (curqual != ltempinventorycnt)
    CALL handle_errors("UPDATE","F","TABLE","CASE_SPECIMEN")
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt += 1
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#exit_script
 IF (error_cnt > 0)
  SET reqinfo->commit_ind = 0
  CALL echo("<<<<< ROLLBACK <<<<<")
  CALL echo(error_cnt)
  CALL echo(reply->status_data.subeventstatus[1].operationname)
  CALL echo(reply->status_data.subeventstatus[1].targetobjectvalue)
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  CALL echo(">>>>> COMMIT >>>>>")
 ENDIF
#end_script
 FREE RECORD temp_inventory
END GO
