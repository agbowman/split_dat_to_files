CREATE PROGRAM cps_add_default_sum_sheet:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
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
 SET readme_data->message = concat("CPS_ADD_DEFAULT_SUM_SHEET  BEG : ",format(cnvtdatetime(curdate,
    curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 EXECUTE dm_readme_status
 FREE RECORD request
 RECORD request(
   1 summary_sheet_id = f8
   1 prsnl_id = f8
   1 display = c40
   1 description = vc
   1 section_qual = i4
   1 section[18]
     2 subj_area_mean = c12
     2 section_type_mean = c12
     2 display = c40
     2 sequence = i4
     2 attr_qual = i4
     2 attr[10]
       3 col_num = i4
       3 subj_area_dtl_mean = c12
       3 detail_type_mean = c12
       3 detail_value = c40
       3 width = i4
   1 sect_with_child = i4
   1 parent[1]
     2 parent_sect_mean = c12
     2 child_qual = i4
     2 child[3]
       3 child_sect_mean = c12
       3 sequence = i4
 )
 SET request->summary_sheet_id = 0
 SET request->prsnl_id = 0
 SET request->display = " Default Template"
 SET request->description = "Default Summary Sheet Template"
 SET request->section_qual = 18
 SET request->sect_with_child = 1
 SET request->section[1].subj_area_mean = "PATIENTINFO"
 SET request->section[1].section_type_mean = "HEADER"
 SET request->section[1].display = "Patient Information"
 SET request->section[1].sequence = 1
 SET request->section[1].attr_qual = 0
 SET request->section[2].subj_area_mean = "DEMOGRAPHIC"
 SET request->section[2].section_type_mean = "HEADER"
 SET request->section[2].display = "Demographics"
 SET request->section[2].sequence = 0
 SET request->section[2].attr_qual = 2
 SET request->section[2].attr[1].subj_area_dtl_mean = "FULLNAME"
 SET request->section[2].attr[1].col_num = 1
 SET request->section[2].attr[1].detail_type_mean = "DETAIL"
 SET request->section[2].attr[1].detail_value = "Full Name"
 SET request->section[2].attr[1].width = 118
 SET request->section[2].attr[2].subj_area_dtl_mean = "BIRTHDATE"
 SET request->section[2].attr[2].col_num = 2
 SET request->section[2].attr[2].detail_type_mean = "DETAIL"
 SET request->section[2].attr[2].detail_value = "Birth Date"
 SET request->section[2].attr[2].width = 70
 SET request->section[3].subj_area_mean = "ADDRESS"
 SET request->section[3].section_type_mean = "HEADER"
 SET request->section[3].display = "Address"
 SET request->section[3].sequence = 0
 SET request->section[3].attr_qual = 5
 SET request->section[3].attr[1].subj_area_dtl_mean = "ADDR1"
 SET request->section[3].attr[1].col_num = 1
 SET request->section[3].attr[1].detail_type_mean = "DETAIL"
 SET request->section[3].attr[1].detail_value = "Address"
 SET request->section[3].attr[1].width = 206
 SET request->section[3].attr[2].subj_area_dtl_mean = "ADDR2"
 SET request->section[3].attr[2].col_num = 2
 SET request->section[3].attr[2].detail_type_mean = "DETAIL"
 SET request->section[3].attr[2].detail_value = "Address"
 SET request->section[3].attr[2].width = 206
 SET request->section[3].attr[3].subj_area_dtl_mean = "CITY"
 SET request->section[3].attr[3].col_num = 3
 SET request->section[3].attr[3].detail_type_mean = "DETAIL"
 SET request->section[3].attr[3].detail_value = "City"
 SET request->section[3].attr[3].width = 85
 SET request->section[3].attr[4].subj_area_dtl_mean = "STATE"
 SET request->section[3].attr[4].col_num = 4
 SET request->section[3].attr[4].detail_type_mean = "DETAIL"
 SET request->section[3].attr[4].detail_value = "State"
 SET request->section[3].attr[4].width = 80
 SET request->section[3].attr[5].subj_area_dtl_mean = "ZIP"
 SET request->section[3].attr[5].col_num = 5
 SET request->section[3].attr[5].detail_type_mean = "DETAIL"
 SET request->section[3].attr[5].detail_value = "Zip Code"
 SET request->section[3].attr[5].width = 86
 SET request->section[4].subj_area_mean = "PHONE"
 SET request->section[4].section_type_mean = "HEADER"
 SET request->section[4].display = "Phone"
 SET request->section[4].sequence = 0
 SET request->section[4].attr_qual = 5
 SET request->section[4].attr[1].subj_area_dtl_mean = "PHONENBR"
 SET request->section[4].attr[1].col_num = 1
 SET request->section[4].attr[1].detail_type_mean = "DETAIL"
 SET request->section[4].attr[1].detail_value = "Phone Number"
 SET request->section[4].attr[1].width = 114
 SET request->section[4].attr[2].subj_area_dtl_mean = "EXTENSION"
 SET request->section[4].attr[2].col_num = 2
 SET request->section[4].attr[2].detail_type_mean = "DETAIL"
 SET request->section[4].attr[2].detail_value = "Extension"
 SET request->section[4].attr[2].width = 70
 SET request->section[4].attr[3].subj_area_dtl_mean = "PHONETYPE"
 SET request->section[4].attr[3].col_num = 3
 SET request->section[4].attr[3].detail_type_mean = "DETAIL"
 SET request->section[4].attr[3].detail_value = "Phone Type"
 SET request->section[4].attr[3].width = 90
 SET request->section[4].attr[4].subj_area_dtl_mean = "CONTACT"
 SET request->section[4].attr[4].col_num = 4
 SET request->section[4].attr[4].detail_type_mean = "DETAIL"
 SET request->section[4].attr[4].detail_value = "Contact Number"
 SET request->section[4].attr[4].width = 130
 SET request->section[4].attr[5].subj_area_dtl_mean = "PAGING_CODE"
 SET request->section[4].attr[5].col_num = 5
 SET request->section[4].attr[5].detail_type_mean = "DETAIL"
 SET request->section[4].attr[5].detail_value = "Paging Code"
 SET request->section[4].attr[5].width = 91
 SET request->section[5].subj_area_mean = "HEALTH PLAN"
 SET request->section[5].section_type_mean = "HEADER"
 SET request->section[5].display = "Health Plan"
 SET request->section[5].sequence = 2
 SET request->section[5].attr_qual = 6
 SET request->section[5].attr[1].subj_area_dtl_mean = "ORGNAME"
 SET request->section[5].attr[1].col_num = 1
 SET request->section[5].attr[1].detail_type_mean = "DETAIL"
 SET request->section[5].attr[1].detail_value = "Organization Name"
 SET request->section[5].attr[1].width = 135
 SET request->section[5].attr[2].subj_area_dtl_mean = "HEALTHPLANTP"
 SET request->section[5].attr[2].col_num = 2
 SET request->section[5].attr[2].detail_type_mean = "DETAIL"
 SET request->section[5].attr[2].detail_value = "Health Plan Type"
 SET request->section[5].attr[2].width = 129
 SET request->section[5].attr[3].subj_area_dtl_mean = "CARRIER"
 SET request->section[5].attr[3].col_num = 3
 SET request->section[5].attr[3].detail_type_mean = "DETAIL"
 SET request->section[5].attr[3].detail_value = "Carrier"
 SET request->section[5].attr[3].width = 100
 SET request->section[5].attr[4].subj_area_dtl_mean = "COPAY"
 SET request->section[5].attr[4].col_num = 4
 SET request->section[5].attr[4].detail_type_mean = "DETAIL"
 SET request->section[5].attr[4].detail_value = "Copay"
 SET request->section[5].attr[4].width = 60
 SET request->section[5].attr[5].subj_area_dtl_mean = "PPRELTN"
 SET request->section[5].attr[5].col_num = 5
 SET request->section[5].attr[5].detail_type_mean = "DETAIL"
 SET request->section[5].attr[5].detail_value = "Person Plan Relation"
 SET request->section[5].attr[5].width = 100
 SET request->section[5].attr[6].subj_area_dtl_mean = "PRIORITYSEQ"
 SET request->section[5].attr[6].col_num = 6
 SET request->section[5].attr[6].detail_type_mean = "DETAIL"
 SET request->section[5].attr[6].detail_value = "Priority Sequence"
 SET request->section[5].attr[6].width = 83
 SET request->section[6].subj_area_mean = "CURENCOUNTER"
 SET request->section[6].section_type_mean = "HEADER"
 SET request->section[6].display = "Current Encounter"
 SET request->section[6].sequence = 3
 SET request->section[6].attr_qual = 0
 SET request->section[7].subj_area_mean = "ENCOUNTER"
 SET request->section[7].section_type_mean = "HEADER"
 SET request->section[7].display = "Encounter History"
 SET request->section[7].sequence = 4
 SET request->section[7].attr_qual = 0
 SET request->section[8].subj_area_mean = "CENEWRESULT"
 SET request->section[8].section_type_mean = "HEADER"
 SET request->section[8].display = "Clinical Events"
 SET request->section[8].sequence = 5
 SET request->section[8].attr_qual = 0
 SET request->section[9].subj_area_mean = "IMMUNIZATION"
 SET request->section[9].section_type_mean = "HEADER"
 SET request->section[9].display = "Immunization History"
 SET request->section[9].sequence = 6
 SET request->section[9].attr_qual = 0
 SET request->section[10].subj_area_mean = "PROBLEM"
 SET request->section[10].section_type_mean = "HEADER"
 SET request->section[10].display = "Problem List"
 SET request->section[10].sequence = 7
 SET request->section[10].attr_qual = 0
 SET request->section[11].subj_area_mean = "ALLERGY"
 SET request->section[11].section_type_mean = "HEADER"
 SET request->section[11].display = "Allergy Profile"
 SET request->section[11].sequence = 8
 SET request->section[11].attr_qual = 0
 SET request->section[12].subj_area_mean = "ORDERS"
 SET request->section[12].section_type_mean = "HEADER"
 SET request->section[12].display = "Order Profile"
 SET request->section[12].sequence = 9
 SET request->section[12].attr_qual = 0
 SET request->section[13].subj_area_mean = "MEDPROFILE"
 SET request->section[13].section_type_mean = "HEADER"
 SET request->section[13].display = "Medication Profile"
 SET request->section[13].sequence = 10
 SET request->section[13].attr_qual = 0
 SET request->section[14].subj_area_mean = "PGC"
 SET request->section[14].section_type_mean = "HEADER"
 SET request->section[14].display = "Pediatric Growth Chart"
 SET request->section[14].sequence = 11
 SET request->section[14].attr_qual = 0
 SET request->section[15].subj_area_mean = "PPR"
 SET request->section[15].section_type_mean = "HEADER"
 SET request->section[15].display = "PPR Section"
 SET request->section[15].sequence = 12
 SET request->section[15].attr_qual = 0
 SET request->section[16].subj_area_mean = "PATHIST"
 SET request->section[16].section_type_mean = "HEADER"
 SET request->section[16].display = "Patient History"
 SET request->section[16].sequence = 13
 SET request->section[16].attr_qual = 0
 SET request->section[17].subj_area_mean = "PROCHIST"
 SET request->section[17].section_type_mean = "HEADER"
 SET request->section[17].display = "Procedure History"
 SET request->section[17].sequence = 14
 SET request->section[17].attr_qual = 0
 SET request->section[18].subj_area_mean = "HEALTHMAINT"
 SET request->section[18].section_type_mean = "HEADER"
 SET request->section[18].display = "Health Maintenance"
 SET request->section[18].sequence = 15
 SET request->section[18].attr_qual = 0
 SET request->parent[1].parent_sect_mean = "PATIENTINFO"
 SET request->parent[1].child_qual = 3
 SET request->parent[1].child[1].child_sect_mean = "DEMOGRAPHIC"
 SET request->parent[1].child[1].sequence = 1
 SET request->parent[1].child[2].child_sect_mean = "ADDRESS"
 SET request->parent[1].child[2].sequence = 2
 SET request->parent[1].child[3].child_sect_mean = "PHONE"
 SET request->parent[1].child[3].sequence = 3
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 EXECUTE cps_add_sum_sheet
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET readme_data->message = "ERROR :: Failed to add default summary sheet"
  EXECUTE dm_readme_status
  SET readme_data->status = "F"
  SET readme_data->message = concat("CPS_ADD_DEFAULT_SUM_SHEET  END : ",format(cnvtdatetime(curdate,
     curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
  EXECUTE dm_readme_status
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = concat("CPS_ADD_DEFAULT_SUM_SHEET  END : ",format(cnvtdatetime(curdate,
     curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
  EXECUTE dm_readme_status
 ENDIF
 COMMIT
END GO
