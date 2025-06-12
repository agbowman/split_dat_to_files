CREATE PROGRAM ccltambld:dba
 PROMPT
  "ENTER HNA VERSION (306)  " = 306
 SET k_size_dec = 11
 SET k_size_format = 20
 SET k_size_entname = 40
 SET k_size_loc = (75 * 5)
 RECORD r1 FROM dic,dictam,hna
 SET stat = 0
 SET stat = initarray(r1,0)
 SET r1->version =  $1
 SELECT INTO "NL:"
  d.max_reclen, key_num = k.seq, k.key_offset,
  k.key_len
  FROM dfile d,
   dfilekey k
  WHERE d.file_name IN ("PURTAPE", "EP", "IP", "SR", "TC",
  "XS")
  DETAIL
   CASE (d.file_name)
    OF "EP":
     r1->ep_rec_off = 0,r1->ep_rec_len = d.max_reclen,
     IF (key_num=1)
      r1->ep_key1_off = k.key_offset, r1->ep_key1_len = k.key_len
     ELSEIF (key_num=2)
      r1->ep_key2_off = k.key_offset, r1->ep_key2_len = k.key_len
     ELSEIF (key_num=3)
      r1->ep_key3_off = k.key_offset, r1->ep_key3_len = k.key_len
     ENDIF
    OF "IP":
     r1->ip_rec_off = 0,r1->ip_rec_len = d.max_reclen,
     IF (key_num=1)
      r1->ip_key1_off = k.key_offset, r1->ip_key1_len = k.key_len
     ELSEIF (key_num=2)
      r1->ip_key2_off = k.key_offset, r1->ip_key2_len = k.key_len
     ENDIF
    OF "SR":
     r1->sr_user_off = 0,r1->sr_user_len = 2,r1->sr_rcode_off = 2,
     r1->sr_rcode_len = 4,r1->sr_rec_off = 0,r1->sr_rec_len = d.max_reclen,
     IF (key_num=1)
      r1->sr_key1_off = k.key_offset, r1->sr_key1_len = k.key_len
     ENDIF
    OF "TC":
     r1->tc_rec_off = 0,r1->tc_rec_len = d.max_reclen
    OF "PURTAPE":
     r1->purtape_rec_off = 0,r1->purtape_rec_len = d.max_reclen
    OF "XS":
     r1->xs_user_off = 0,r1->xs_user_len = 2,r1->xs_rcode_off = 2,
     r1->xs_rcode_len = 2,r1->xs_rec_off = 0,r1->xs_rec_len = d.max_reclen,
     IF (key_num=1)
      r1->xs_key1_off = k.key_offset, r1->xs_key1_len = k.key_len
     ELSEIF (key_num=2)
      r1->xs_key2_off = k.key_offset, r1->xs_key2_len = k.key_len
     ENDIF
   ENDCASE
  WITH nocounter, outerjoin = d
 ;end select
 SELECT INTO "NL:"
  file_name = a.file_name, rectype_name = a.rectype_name, field_name = l.field_name,
  offset = l.offset, structtype = l.structtype, type = l.type,
  dimension = l.dimension, len = l.len
  FROM drectyp a,
   drectypfld l
  PLAN (a
   WHERE a.file_name IN ("EP", "IP", "PURTAPE", "SR", "TC",
   "XS"))
   JOIN (l
   WHERE a.rectype_name IN ("SR0008*", "SR0096*", "SR0249*", "SR0700*", "SR0701*",
   "SR9900*", "SR9930*", "IP*", "EP*", "TC*",
   "PURTAPE*", "XS01*", "XS15*"))
  DETAIL
   CASE (rectype_name)
    OF "SR0008*":
     CASE (field_name)
      OF "SR0008_CLIENT":
       r1->sr0008_client_off = offset,r1->sr0008_client_len = len
      OF "SR0008_DEC":
       r1->sr0008_dec_off = offset,r1->sr0008_dec_len = (len * dimension)
     ENDCASE
    OF "SR0096*":
     CASE (field_name)
      OF "SR0096_SITE":
       r1->sr0096_site_off = offset,r1->sr0096_site_len = len
      OF "SR0096_EXPAND_ACCESSION":
       r1->sr0096_expand_acc_off = offset,r1->sr0096_expand_acc_len = len
     ENDCASE
    OF "SR0249*":
     CASE (field_name)
      OF "SR0249_SITE":
       r1->sr0249_site_off = offset,r1->sr0249_site_len = len
      OF "SR0249_ACCESSION_PREFIX":
       r1->sr0249_acc_prefix_off = offset,r1->sr0249_acc_prefix_len = len
      OF "SR0249_ROUTINE":
       r1->sr0249_routine_off = offset,r1->sr0249_routine_len = len
     ENDCASE
    OF "SR0700*":
     CASE (field_name)
      OF "SR0700_PAT_FOR_IND":
       r1->sr0700_pat_for_ind_off = offset,r1->sr0700_pat_for_ind_len = len
      OF "SR0700_FORMAT_OCC":
       r1->sr0700_format_occ_off = offset,r1->sr0700_format_occ_len = (len * dimension)
     ENDCASE
    OF "SR0701*":
     CASE (field_name)
      OF "SR0701_FORMAT":
       r1->sr0701_format_off = offset,r1->sr0701_format_len = len
     ENDCASE
    OF "SR9900*":
     CASE (field_name)
      OF "SR9900_REF_LAB_PREFIX":
       r1->sr9900_ref_lab_prefix_off = offset,r1->sr9900_ref_lab_prefix_len = len
      OF "SR9900_EXPAND_ACCESSION":
       r1->sr9900_expand_acc_off = offset,r1->sr9900_expand_acc_len = len
     ENDCASE
    OF "SR9930*":
     CASE (field_name)
      OF "SR9930_STATION_ID":
       r1->sr9930_station_id_off = offset,r1->sr9930_station_id_len = len
      OF "SR9930_PROCESSOR_NODE":
       r1->sr9930_processor_node_off = offset,r1->sr9930_processor_node_len = len
      OF "SR9930_PRINTER_INDICATOR":
       r1->sr9930_printer_indicator_off = offset,r1->sr9930_printer_indicator_len = len
      OF "SR9930_PRINTER_CONTROL":
       r1->sr9930_printer_control_off = offset,r1->sr9930_printer_control_len = len
      OF "SR9930_PRT_FILE_CHAR":
       r1->sr9930_prt_file_char_off = offset,r1->sr9930_prt_file_char_len = len
      OF "SR9930_PRT_QUE":
       r1->sr9930_prt_que_off = offset,r1->sr9930_prt_que_len = len
      OF "SR9930_DIO_PTRT_TYPE":
       r1->sr9930_dio_ptrt_type_off = offset,r1->sr9930_dio_ptrt_type_len = len
      OF "SR9930_DEF_DEST":
       r1->sr9930_def_dest_off = offset,r1->sr9930_def_dest_len = len
      OF "SR9930_DEF_TYPE":
       r1->sr9930_def_type_off = offset,r1->sr9930_def_type_len = len
     ENDCASE
    OF "TC_*":
     CASE (field_name)
      OF "TC*USER_ID":
       r1->tc_user_name_off = offset,r1->tc_user_name_len = len
      OF "TC*USER_DEPARTMENT":
       r1->tc_dept_off = offset,r1->tc_dept_len = len
      OF "TC*INSTITUTION":
       r1->tc_inst_off = offset,r1->tc_inst_len = len
      OF "TC*SECTION":
       r1->tc_sect_off = offset,r1->tc_sect_len = len
      OF "TC*COMPANY_NBR":
       r1->tc_entity_off = offset,r1->tc_entity_len = len
      OF "TC*TECH_ID":
       r1->tc_tech_off = offset,r1->tc_tech_len = len
      OF "TC*DEFAULT_PRTR_ID":
       r1->tc_def_printer_off = offset,r1->tc_def_printer_len = len
      OF "TC*FILE_DRIVE_CODE":
       r1->tc_file_drive_off = offset,r1->tc_file_drive_len = len
      OF "TC*COMPANY_NAME":
       r1->tc_ent_name_off = offset,r1->tc_ent_name_len = len
      OF "TC*FILE_LOCATIONS":
       r1->tc_file_location_off = offset,r1->tc_file_location_len = len
      OF "TC*DIR_LOCATIONS":
       r1->tc_dir_location_off = offset,r1->tc_dir_location_len = len
      OF "TC*LOC_PREFIX_IND":
       r1->tc_loc_prefix_ind_off = offset,r1->tc_loc_prefix_ind_len = len
      OF "TC*DEF_LOC_PREFIX":
       r1->tc_def_loc_prefix_off = offset,r1->tc_def_loc_prefix_len = len
     ENDCASE
    OF "EP00*":
     CASE (field_name)
      OF "EP00_ENTITY1":
       r1->ep_entity_off = offset,r1->ep_entity_len = len
      OF "EP00_DEFAULT_PRINTER":
       r1->ep_def_printer_off = offset,r1->ep_def_printer_len = len
      OF "EP00_FILE_DRIVE_CODE":
       r1->ep_file_drive_off = offset,r1->ep_file_drive_len = len
      OF "EP00_SECTION":
       r1->ep_sect_off = offset,r1->ep_sect_len = len
      OF "EP00_TECH_ID":
       r1->ep_tech_off = offset,r1->ep_tech_len = len
      OF "EP00_INSTITUTION":
       r1->ep_inst_off = offset,r1->ep_inst_len = len
      OF "EP00_USER_DEPARTMENT":
       r1->ep_dept_off = offset,r1->ep_dept_len = len
     ENDCASE
    OF "IP*":
     CASE (field_name)
      OF "IP?00_DATA":
       r1->ip_ent_name_off = offset,r1->ip_ent_name_len = k_size_entname,r1->ip_file_location_off =
       offset,
       r1->ip_file_location_len = k_size_loc,r1->ip_dir_location_off = (offset+ r1->
       ip_file_location_len),r1->ip_dir_location_len = k_size_loc
      OF "IP?00_ENTITY":
       r1->ip_entity_off = offset,r1->ip_entity_len = len
      OF "IP?00_REC_TYPE":
       r1->ip_rec_type_off = offset,r1->ip_rec_type_len = len
      OF "IP?00_MODULE_K":
       r1->ip_file_drive_off = offset,r1->ip_file_drive_len = len
     ENDCASE
    OF "PURTAPE*":
     CASE (field_name)
      OF "RECSIZE":
       r1->purtape_recsize_off = offset,r1->purtape_recsize_len = len
      OF "FILE_ID":
       r1->purtape_file_id_off = offset,r1->purtape_file_id_len = len
      OF "FILE_TYPE":
       r1->purtape_file_type_off = offset,r1->purtape_file_type_len = len
      OF "VERSION":
       r1->purtape_version_off = offset,r1->purtape_version_len = len
      OF "PURGE_DATA":
       r1->purtape_purge_data_off = offset,r1->purtape_purge_data_len = len
     ENDCASE
    OF "XS01*":
     CASE (field_name)
      OF "XS01_COMM_DEST":
       r1->xs01_comm_dest1_off = offset,r1->xs01_comm_dest1_len = len
      OF "XS01_COMM_STAT":
       r1->xs01_comm_stat1_off = offset,r1->xs01_comm_stat1_len = len
      OF "XS01_DATA_TYPE":
       r1->xs01_data_type1_off = offset,r1->xs01_data_type1_len = len
      OF "XS01_DATA_CREATE_DATE":
       r1->xs01_data_create_date1_off = offset,r1->xs01_data_create_date1_len = len
      OF "XS01_DATA_CREATE_TIME":
       r1->xs01_data_create_time1_off = offset,r1->xs01_data_create_time1_len = len
      OF "XS01_ACTIVITY_DATE":
       r1->xs01_activity_date_off = offset,r1->xs01_activity_date_len = len
      OF "XS01_ACTIVITY_TIME":
       r1->xs01_activity_time_off = offset,r1->xs01_activity_time_len = len
      OF "XS01_ACTIVITY_TASK":
       r1->xs01_activity_task_off = offset,r1->xs01_activity_task_len = len
      OF "XS01_DATA_FILE_NAME":
       r1->xs01_data_file_name_off = offset,r1->xs01_data_file_name_len = len
      OF "XS01_PHONE_NBR":
       r1->xs01_phone_nbr_off = offset,r1->xs01_phone_nbr_len = len
      OF "XS01_DATA_FILE_IND":
       r1->xs01_data_file_ind_off = offset,r1->xs01_data_file_ind_len = len
      OF "XS01_HEADER_QUAL":
       r1->xs01_header_qual_off = offset,r1->xs01_header_qual_len = len
     ENDCASE
    OF "XS15*":
     CASE (field_name)
      OF "XS15_USER_NAME1":
       r1->xs15_user_name1_off = offset,r1->xs15_user_name1_len = len
      OF "XS15_DATA_CREATE_DATE1":
       r1->xs15_data_create_date1_off = offset,r1->xs15_data_create_date1_len = len
      OF "XS15_DATA_CREATE_TIME1":
       r1->xs15_data_create_time1_off = offset,r1->xs15_data_create_time1_len = len
      OF "XS15_QUAL1":
       r1->xs15_qual1_off = offset,r1->xs15_qual1_len = len
      OF "XS15_DATA_CREATE_DATE2":
       r1->xs15_data_create_date2_off = offset,r1->xs15_data_create_date2_len = len
      OF "XS15_DATA_CREATE_TIME2":
       r1->xs15_data_create_time2_off = offset,r1->xs15_data_create_time2_len = len
      OF "XS15_USER_NAME2":
       r1->xs15_user_name2_off = offset,r1->xs15_user_name2_len = len
      OF "XS15_ACTIVITY_DATE":
       r1->xs15_activity_date_off = offset,r1->xs15_activity_date_len = len
      OF "XS15_ACTIVITY_TIME":
       r1->xs15_activity_time_off = offset,r1->xs15_activity_time_len = len
      OF "XS15_ACTIVITY_TASK":
       r1->xs15_activity_task_off = offset,r1->xs15_activity_task_len = len
      OF "XS15_COMM_DEST":
       r1->xs15_comm_dest_off = offset,r1->xs15_comm_dest_len = len
      OF "XS15_DATA_TYPE":
       r1->xs15_data_type_off = offset,r1->xs15_data_type_len = len
      OF "XS15_COMM_STAT":
       r1->xs15_comm_stat_off = offset,r1->xs15_comm_stat_len = len
      OF "XS15_DEVICE_NAME":
       r1->xs15_device_name_off = offset,r1->xs15_device_name_len = len
      OF "XS15_FID":
       r1->xs15_fid_off = offset,r1->xs15_fid_len = len
     ENDCASE
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO concat("CCLDIC_",format(r1->version,"###"),".TAM")
  dummyt.seq
  FROM dummyt
  DETAIL
   CALL print(concat(";CCLDIC_",format(r1->version,"###"),
    ".TAM is generated by CCL program ccltambld.prg")), row + 1, "DROP CCLTAM GO",
   row + 1, "CREATE CCLTAM ", row + 1,
   "(", row + 1, "  DUM, LQ , HIQ, HOQ, IX , ",
   row + 1, "  MQ , BQ , AQ , CF , POQ, ", row + 1,
   "  PRQ, CQ , AO , ETH, PUR, ", row + 1, "  RE , IH , MS , DUM, DUM  ",
   row + 1, ")", row + 1,
   "WITH  ", row + 1, ";misc",
   row + 1,
   CALL print(build(" VERSION = ",r1->version,",")), row + 1,
   ";tc", row + 1,
   CALL print(build(" TC_REC(",r1->tc_rec_off,",",r1->tc_rec_len,"),")),
   row + 1,
   CALL print(build(" TC_DEPT(",r1->tc_dept_off,",",r1->tc_dept_len,"),")), row + 1,
   CALL print(build(" TC_USER_NAME(",r1->tc_user_name_off,",",r1->tc_user_name_len,"),")), row + 1,
   CALL print(build(" TC_INST(",r1->tc_inst_off,",",r1->tc_inst_len,"),")),
   row + 1,
   CALL print(build(" TC_SECT(",r1->tc_sect_off,",",r1->tc_sect_len,"),")), row + 1,
   CALL print(build(" TC_ENTITY(",r1->tc_entity_off,",",r1->tc_entity_len,"),")), row + 1,
   CALL print(build(" TC_TECH(",r1->tc_tech_off,",",r1->tc_tech_len,"),")),
   row + 1,
   CALL print(build(" TC_DEF_PRINTER(",r1->tc_def_printer_off,",",r1->tc_def_printer_len,"),")), row
    + 1,
   CALL print(build(" TC_FILE_DRIVE(",r1->tc_file_drive_off,",",r1->tc_file_drive_len,"),")), row + 1,
   CALL print(build(" TC_ENT_NAME(",r1->tc_ent_name_off,",",r1->tc_ent_name_len,"),")),
   row + 1,
   CALL print(build(" TC_FILE_LOCATION(",r1->tc_file_location_off,",",r1->tc_file_location_len,"),")),
   row + 1,
   CALL print(build(" TC_DIR_LOCATION(",r1->tc_dir_location_off,",",r1->tc_dir_location_len,"),")),
   row + 1,
   CALL print(build(" TC_LOC_PREFIX_IND(",r1->tc_loc_prefix_ind_off,",",r1->tc_loc_prefix_ind_len,
    "),")),
   row + 1,
   CALL print(build(" TC_DEF_LOC_PREFIX(",r1->tc_def_loc_prefix_off,",",r1->tc_def_loc_prefix_len,
    "),")), row + 1,
   ";ep", row + 1,
   CALL print(build(" EP_KEY1(",r1->ep_key1_off,",",r1->ep_key1_len,"),")),
   row + 1,
   CALL print(build(" EP_KEY2(",r1->ep_key2_off,",",r1->ep_key2_len,"),")), row + 1,
   CALL print(build(" EP_KEY3(",r1->ep_key3_off,",",r1->ep_key3_len,"),")), row + 1,
   CALL print(build(" EP_REC(",r1->ep_rec_off,",",r1->ep_rec_len,"),")),
   row + 1,
   CALL print(build(" EP_DEPT(",r1->ep_dept_off,",",r1->ep_dept_len,"),")), row + 1,
   CALL print(build(" EP_INST(",r1->ep_inst_off,",",r1->ep_inst_len,"),")), row + 1,
   CALL print(build(" EP_SECT(",r1->ep_sect_off,",",r1->ep_sect_len,"),")),
   row + 1,
   CALL print(build(" EP_ENTITY(",r1->ep_entity_off,",",r1->ep_entity_len,"),")), row + 1,
   CALL print(build(" EP_TECH(",r1->ep_tech_off,",",r1->ep_tech_len,"),")), row + 1,
   CALL print(build(" EP_DEF_PRINTER(",r1->ep_def_printer_off,",",r1->ep_def_printer_len,"),")),
   row + 1,
   CALL print(build(" EP_FILE_DRIVE(",r1->ep_file_drive_off,",",r1->ep_file_drive_len,"),")), row + 1,
   ";ip", row + 1,
   CALL print(build(" IP_KEY1(",r1->ip_key1_off,",",r1->ip_key1_len,"),")),
   row + 1,
   CALL print(build(" IP_KEY2(",r1->ip_key2_off,",",r1->ip_key2_len,"),")), row + 1,
   CALL print(build(" IP_REC(",r1->ip_rec_off,",",r1->ip_rec_len,"),")), row + 1,
   CALL print(build(" IP_ENTITY(",r1->ip_entity_off,",",r1->ip_entity_len,"),")),
   row + 1,
   CALL print(build(" IP_REC_TYPE(",r1->ip_rec_type_off,",",r1->ip_rec_type_len,"),")), row + 1,
   CALL print(build(" IP_ENT_NAME(",r1->ip_ent_name_off,",",r1->ip_ent_name_len,"),")), row + 1,
   CALL print(build(" IP_FILE_DRIVE(",r1->ip_file_drive_off,",",r1->ip_file_drive_len,"),")),
   row + 1,
   CALL print(build(" IP_FILE_LOCATION(",r1->ip_file_location_off,",",r1->ip_file_location_len,"),")),
   row + 1,
   CALL print(build(" IP_DIR_LOCATION(",r1->ip_dir_location_off,",",r1->ip_dir_location_len,"),")),
   row + 1, ";purge",
   row + 1,
   CALL print(build(" PURTAPE_REC(",r1->purtape_rec_off,",",r1->purtape_rec_len,"),")), row + 1,
   CALL print(build(" PURTAPE_RECSIZE(",r1->purtape_recsize_off,",",r1->purtape_recsize_len,"),")),
   row + 1,
   CALL print(build(" PURTAPE_FILE_ID(",r1->purtape_file_id_off,",",r1->purtape_file_id_len,"),")),
   row + 1,
   CALL print(build(" PURTAPE_FILE_TYPE(",r1->purtape_file_type_off,",",r1->purtape_file_type_len,
    "),")), row + 1,
   CALL print(build(" PURTAPE_VERSION(",r1->purtape_version_off,",",r1->purtape_version_len,"),")),
   row + 1,
   CALL print(build(" PURTAPE_PURGE_DATA(",r1->purtape_purge_data_off,",",r1->purtape_purge_data_len,
    "),")),
   row + 1, ";XS", row + 1,
   CALL print(build(" XS_KEY1(",r1->xs_key1_off,",",r1->xs_key1_len,"),")), row + 1,
   CALL print(build(" XS_KEY2(",r1->xs_key2_off,",",r1->xs_key2_len,"),")),
   row + 1,
   CALL print(build(" XS_REC(",r1->xs_rec_off,",",r1->xs_rec_len,"),")), row + 1,
   CALL print(build(" XS_USER(",r1->xs_user_off,",",r1->xs_user_len,"),")), row + 1,
   CALL print(build(" XS_RCODE(",r1->xs_rcode_off,",",r1->xs_rcode_len,"),")),
   row + 1, ";XS01", row + 1,
   CALL print(build(" XS01_COMM_DEST1(",r1->xs01_comm_dest1_off,",",r1->xs01_comm_dest1_len,"),")),
   row + 1,
   CALL print(build(" XS01_COMM_STAT1(",r1->xs01_comm_stat1_off,",",r1->xs01_comm_stat1_len,"),")),
   row + 1,
   CALL print(build(" XS01_DATA_TYPE1(",r1->xs01_data_type1_off,",",r1->xs01_data_type1_len,"),")),
   row + 1,
   CALL print(build(" XS01_DATA_CREATE_DATE1(",r1->xs01_data_create_date1_off,",",r1->
    xs01_data_create_date1_len,"),")), row + 1,
   CALL print(build(" XS01_DATA_CREATE_TIME1(",r1->xs01_data_create_time1_off,",",r1->
    xs01_data_create_time1_len,"),")),
   row + 1,
   CALL print(build(" XS01_ACTIVITY_DATE(",r1->xs01_activity_date_off,",",r1->xs01_activity_date_len,
    "),")), row + 1,
   CALL print(build(" XS01_ACTIVITY_TIME(",r1->xs01_activity_time_off,",",r1->xs01_activity_time_len,
    "),")), row + 1,
   CALL print(build(" XS01_ACTIVITY_TASK(",r1->xs01_activity_task_off,",",r1->xs01_activity_task_len,
    "),")),
   row + 1,
   CALL print(build(" XS01_DATA_FILE_NAME(",r1->xs01_data_file_name_off,",",r1->
    xs01_data_file_name_len,"),")), row + 1,
   CALL print(build(" XS01_PHONE_NBR(",r1->xs01_phone_nbr_off,",",r1->xs01_phone_nbr_len,"),")), row
    + 1,
   CALL print(build(" XS01_DATA_FILE_IND(",r1->xs01_data_file_ind_off,",",r1->xs01_data_file_ind_len,
    "),")),
   row + 1,
   CALL print(build(" XS01_HEADER_QUAL(",r1->xs01_header_qual_off,",",r1->xs01_header_qual_len,"),")),
   row + 1,
   ";XS15", row + 1,
   CALL print(build(" XS15_USER_NAME1(",r1->xs15_user_name1_off,",",r1->xs15_user_name1_len,"),")),
   row + 1,
   CALL print(build(" XS15_DATA_CREATE_DATE1(",r1->xs15_data_create_date1_off,",",r1->
    xs15_data_create_date1_len,"),")), row + 1,
   CALL print(build(" XS15_DATA_CREATE_TIME1(",r1->xs15_data_create_time1_off,",",r1->
    xs15_data_create_time1_len,"),")), row + 1,
   CALL print(build(" XS15_QUAL1(",r1->xs15_qual1_off,",",r1->xs15_qual1_len,"),")),
   row + 1,
   CALL print(build(" XS15_DATA_CREATE_DATE2(",r1->xs15_data_create_date2_off,",",r1->
    xs15_data_create_date2_len,"),")), row + 1,
   CALL print(build(" XS15_DATA_CREATE_TIME2(",r1->xs15_data_create_time2_off,",",r1->
    xs15_data_create_time2_len,"),")), row + 1,
   CALL print(build(" XS15_USER_NAME2(",r1->xs15_user_name2_off,",",r1->xs15_user_name2_len,"),")),
   row + 1,
   CALL print(build(" XS15_ACTIVITY_DATE(",r1->xs15_activity_date_off,",",r1->xs15_activity_date_len,
    "),")), row + 1,
   CALL print(build(" XS15_ACTIVITY_TIME(",r1->xs15_activity_time_off,",",r1->xs15_activity_time_len,
    "),")), row + 1,
   CALL print(build(" XS15_ACTIVITY_TASK(",r1->xs15_activity_task_off,",",r1->xs15_activity_task_len,
    "),")),
   row + 1,
   CALL print(build(" XS15_COMM_DEST(",r1->xs15_comm_dest_off,",",r1->xs15_comm_dest_len,"),")), row
    + 1,
   CALL print(build(" XS15_DATA_TYPE(",r1->xs15_data_type_off,",",r1->xs15_data_type_len,"),")), row
    + 1,
   CALL print(build(" XS15_COMM_STAT(",r1->xs15_comm_stat_off,",",r1->xs15_comm_stat_len,"),")),
   row + 1,
   CALL print(build(" XS15_DEVICE_NAME(",r1->xs15_device_name_off,",",r1->xs15_device_name_len,"),")),
   row + 1,
   CALL print(build(" XS15_FID(",r1->xs15_fid_off,",",r1->xs15_fid_len,"),")), row + 1, ";sr",
   row + 1,
   CALL print(build(" SR_USER(",r1->sr_user_off,",",r1->sr_user_len,"),")), row + 1,
   CALL print(build(" SR_RCODE(",r1->sr_rcode_off,",",r1->sr_rcode_len,"),")), row + 1,
   CALL print(build(" SR_KEY1(",r1->sr_key1_off,",",r1->sr_key1_len,"),")),
   row + 1,
   CALL print(build(" SR_REC(",r1->sr_rec_off,",",r1->sr_rec_len,"),")), row + 1,
   ";sr0008", row + 1,
   CALL print(build(" SR0008_CLIENT(",r1->sr0008_client_off,",",r1->sr0008_client_len,"),")),
   row + 1,
   CALL print(build(" SR0008_DEC(",r1->sr0008_dec_off,",",r1->sr0008_dec_len,"),")), row + 1,
   ";sr0096", row + 1,
   CALL print(build(" SR0096_CLIENT(",r1->sr0096_site_off,",",r1->sr0096_site_len,"),")),
   row + 1,
   CALL print(build(" SR0096_EXPAND_ACC(",r1->sr0096_expand_acc_off,",",r1->sr0096_expand_acc_len,
    "),")), row + 1,
   ";sr0249", row + 1,
   CALL print(build(" SR0249_SITE(",r1->sr0249_site_off,",",r1->sr0249_site_len,"),")),
   row + 1,
   CALL print(build(" SR0249_ACC_PREFIX(",r1->sr0249_acc_prefix_off,",",r1->sr0249_acc_prefix_len,
    "),")), row + 1,
   CALL print(build(" SR0249_ROUTINE(",r1->sr0249_routine_off,",",r1->sr0249_routine_len,"),")), row
    + 1, ";sr0700",
   row + 1,
   CALL print(build(" SR0700_FORMAT_OCC(",r1->sr0700_format_occ_off,",",r1->sr0700_format_occ_len,
    "),")), row + 1,
   CALL print(build(" SR0700_PAT_FOR_IND(",r1->sr0700_pat_for_ind_off,",",r1->sr0700_pat_for_ind_len,
    "),")), row + 1, ";sr0701",
   row + 1,
   CALL print(build(" SR0701_FORMAT(",r1->sr0701_format_off,",",r1->sr0701_format_len,"),")), row + 1,
   ";sr9900", row + 1,
   CALL print(build(" SR9900_REF_LAB_PREFIX(",r1->sr9900_ref_lab_prefix_off,",",r1->
    sr9900_ref_lab_prefix_len,"),")),
   row + 1,
   CALL print(build(" SR9900_EXPAND_ACC(",r1->sr9900_expand_acc_off,",",r1->sr9900_expand_acc_len,
    "),")), row + 1,
   ";sr9930", row + 1,
   CALL print(build(" SR9930_STATION_ID(",r1->sr9930_station_id_off,",",r1->sr9930_station_id_len,
    "),")),
   row + 1,
   CALL print(build(" SR9930_PROCESSOR_NODE(",r1->sr9930_processor_node_off,",",r1->
    sr9930_processor_node_len,"),")), row + 1,
   CALL print(build(" SR9930_PRINTER_INDICATOR(",r1->sr9930_printer_indicator_off,",",r1->
    sr9930_printer_indicator_len,"),")), row + 1,
   CALL print(build(" SR9930_DIO_PTRT_TYPE(",r1->sr9930_dio_ptrt_type_off,",",r1->
    sr9930_dio_ptrt_type_len,"),")),
   row + 1,
   CALL print(build(" SR9930_PRT_QUE(",r1->sr9930_prt_que_off,",",r1->sr9930_prt_que_len,"),")), row
    + 1,
   CALL print(build(" SR9930_PRINTER_CONTROL(",r1->sr9930_printer_control_off,",",r1->
    sr9930_printer_control_len,"),")), row + 1,
   CALL print(build(" SR9930_PRT_FILE_CHAR(",r1->sr9930_prt_file_char_off,",",r1->
    sr9930_prt_file_char_len,") ")),
   row + 1,
   CALL print(build(" SR9930_DEF_DEST(",r1->sr9930_def_dest_off,",",r1->sr9930_def_type_len,") ")),
   row + 1,
   CALL print(build(" SR9930_DEF_TYPE(",r1->sr9930_def_type_off,",",r1->sr9930_def_type_len,") ")),
   row + 1, "GO",
   row + 1
  WITH nocounter, format = variable, noformfeed,
   maxrow = 1
 ;end select
END GO
