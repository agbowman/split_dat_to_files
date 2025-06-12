CREATE PROGRAM dd_rdm_upd_careteam_specialty:dba
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
 SET readme_data->status = "F"
 SET readme_data->message = "Readme dd_rdm_upd_careteam_specialty failed."
 DECLARE errmsg = vc WITH protect, noconstant("")
 FREE RECORD codes
 RECORD codes(
   1 code_list[*]
     2 cki = vc
     2 cdf_mean = vc
 )
 SET stat = alterlist(codes->code_list,62)
 SET codes->code_list[1].cki = "CKI.CODEVALUE!4108695718"
 SET codes->code_list[1].cdf_mean = "ANESTHESIOLO"
 SET codes->code_list[2].cki = "CKI.CODEVALUE!4108695722"
 SET codes->code_list[2].cdf_mean = "COLON_SURG"
 SET codes->code_list[3].cki = "CKI.CODEVALUE!4108695724"
 SET codes->code_list[3].cdf_mean = "DENTISTRY"
 SET codes->code_list[4].cki = "CKI.CODEVALUE!4108695727"
 SET codes->code_list[4].cdf_mean = "EMER_MED"
 SET codes->code_list[5].cki = "CKI.CODEVALUE!4108695728"
 SET codes->code_list[5].cdf_mean = "ENDO"
 SET codes->code_list[6].cki = "CKI.CODEVALUE!4108695732"
 SET codes->code_list[6].cdf_mean = "GENETICS"
 SET codes->code_list[7].cki = "CKI.CODEVALUE!4108695734"
 SET codes->code_list[7].cdf_mean = "HEMATOLOGY"
 SET codes->code_list[8].cki = "CKI.CODEVALUE!4108695737"
 SET codes->code_list[8].cdf_mean = "INTERN_MED"
 SET codes->code_list[9].cki = "CKI.CODEVALUE!4108695741"
 SET codes->code_list[9].cdf_mean = "NUKE_MED"
 SET codes->code_list[10].cki = "CKI.CODEVALUE!4108695743"
 SET codes->code_list[10].cdf_mean = "OBGYN"
 SET codes->code_list[11].cki = "CKI.CODEVALUE!4108695745"
 SET codes->code_list[11].cdf_mean = "OPHTHALM"
 SET codes->code_list[12].cki = "CKI.CODEVALUE!4108695730"
 SET codes->code_list[12].cdf_mean = "GASTRO"
 SET codes->code_list[13].cki = "CKI.CODEVALUE!4108695736"
 SET codes->code_list[13].cdf_mean = "INFECT_DIS"
 SET codes->code_list[14].cki = "CKI.CODEVALUE!4108695738"
 SET codes->code_list[14].cdf_mean = "NEPHROLOGY"
 SET codes->code_list[15].cki = "CKI.CODEVALUE!4108695744"
 SET codes->code_list[15].cdf_mean = "OCC_THERAPY"
 SET codes->code_list[16].cki = "CKI.CODEVALUE!4108695748"
 SET codes->code_list[16].cdf_mean = "ORTHOPAEDICS"
 SET codes->code_list[17].cki = "CKI.CODEVALUE!4108695749"
 SET codes->code_list[17].cdf_mean = "ENT"
 SET codes->code_list[18].cki = "CKI.CODEVALUE!4108695782"
 SET codes->code_list[18].cdf_mean = "PED_INFECT"
 SET codes->code_list[19].cki = "CKI.CODEVALUE!4108695784"
 SET codes->code_list[19].cdf_mean = "PED_PULMONO"
 SET codes->code_list[20].cki = "CKI.CODEVALUE!4108695785"
 SET codes->code_list[20].cdf_mean = "PED_RHEUMA"
 SET codes->code_list[21].cki = "CKI.CODEVALUE!4108695787"
 SET codes->code_list[21].cdf_mean = "PED_UROLOGY"
 SET codes->code_list[22].cki = "CKI.CODEVALUE!4108695792"
 SET codes->code_list[22].cdf_mean = "PLASTIC_SURG"
 SET codes->code_list[23].cki = "CKI.CODEVALUE!4108695793"
 SET codes->code_list[23].cdf_mean = "PODIATRY"
 SET codes->code_list[24].cki = "CKI.CODEVALUE!4108695796"
 SET codes->code_list[24].cdf_mean = "PSYCHIATRY"
 SET codes->code_list[25].cki = "CKI.CODEVALUE!4108695764"
 SET codes->code_list[25].cdf_mean = "PED_CARDIO"
 SET codes->code_list[26].cki = "CKI.CODEVALUE!4108695767"
 SET codes->code_list[26].cdf_mean = "PED_ENDO"
 SET codes->code_list[27].cki = "CKI.CODEVALUE!4108695770"
 SET codes->code_list[27].cdf_mean = "PED_HEMA_ONC"
 SET codes->code_list[28].cki = "CKI.CODEVALUE!4108695783"
 SET codes->code_list[28].cdf_mean = "PED_NEPHRO"
 SET codes->code_list[29].cki = "CKI.CODEVALUE!4108695789"
 SET codes->code_list[29].cdf_mean = "PHARMACY"
 SET codes->code_list[30].cki = "CKI.CODEVALUE!4108695790"
 SET codes->code_list[30].cdf_mean = "PHYS_MED"
 SET codes->code_list[31].cki = "CKI.CODEVALUE!4108695791"
 SET codes->code_list[31].cdf_mean = "PHYS_THERAPY"
 SET codes->code_list[32].cki = "CKI.CODEVALUE!4108695795"
 SET codes->code_list[32].cdf_mean = "PRIMARY_CARE"
 SET codes->code_list[33].cki = "CKI.CODEVALUE!4108695799"
 SET codes->code_list[33].cdf_mean = "RADIOLOGY"
 SET codes->code_list[34].cki = "CKI.CODEVALUE!4108695800"
 SET codes->code_list[34].cdf_mean = "RESP_THERAPY"
 SET codes->code_list[35].cki = "CKI.CODEVALUE!4108695802"
 SET codes->code_list[35].cdf_mean = "SPORTS_MED"
 SET codes->code_list[36].cki = "CKI.CODEVALUE!4108695803"
 SET codes->code_list[36].cdf_mean = "UROLOGY"
 SET codes->code_list[37].cki = "CKI.CODEVALUE!4108695751"
 SET codes->code_list[37].cdf_mean = "PATHOLOGY"
 SET codes->code_list[38].cki = "CKI.CODEVALUE!4108695765"
 SET codes->code_list[38].cdf_mean = "PED_CRITCARE"
 SET codes->code_list[39].cki = "CKI.CODEVALUE!4108695788"
 SET codes->code_list[39].cdf_mean = "PEDIATRICS"
 SET codes->code_list[40].cki = "CKI.CODEVALUE!4108695794"
 SET codes->code_list[40].cdf_mean = "PREVENT_MED"
 SET codes->code_list[41].cki = "CKI.CODEVALUE!4108695797"
 SET codes->code_list[41].cdf_mean = "PSYCHOLOGY"
 SET codes->code_list[42].cki = "CKI.CODEVALUE!4108695801"
 SET codes->code_list[42].cdf_mean = "RHEUMATOLOGY"
 SET codes->code_list[43].cki = "CKI.CODEVALUE!4108695719"
 SET codes->code_list[43].cdf_mean = "CARDIOLOGY"
 SET codes->code_list[44].cki = "CKI.CODEVALUE!4108695720"
 SET codes->code_list[44].cdf_mean = "CARDIO_SURG"
 SET codes->code_list[45].cki = "CKI.CODEVALUE!4108695723"
 SET codes->code_list[45].cdf_mean = "CRIT_CARE"
 SET codes->code_list[46].cki = "CKI.CODEVALUE!4108695725"
 SET codes->code_list[46].cdf_mean = "DERMATOLOGY"
 SET codes->code_list[47].cki = "CKI.CODEVALUE!4108695726"
 SET codes->code_list[47].cdf_mean = "DIETARY"
 SET codes->code_list[48].cki = "CKI.CODEVALUE!4108695735"
 SET codes->code_list[48].cdf_mean = "HOSPITALIST"
 SET codes->code_list[49].cki = "CKI.CODEVALUE!4108695740"
 SET codes->code_list[49].cdf_mean = "NEUROLOGY"
 SET codes->code_list[50].cki = "CKI.CODEVALUE!4108695747"
 SET codes->code_list[50].cdf_mean = "OPTOMETRY"
 SET codes->code_list[51].cki = "CKI.CODEVALUE!4108695766"
 SET codes->code_list[51].cdf_mean = "PED_EMER_MED"
 SET codes->code_list[52].cki = "CKI.CODEVALUE!4108695768"
 SET codes->code_list[52].cdf_mean = "PED_GASTRO"
 SET codes->code_list[53].cki = "CKI.CODEVALUE!4108695786"
 SET codes->code_list[53].cdf_mean = "PED_SURG"
 SET codes->code_list[54].cki = "CKI.CODEVALUE!4108695798"
 SET codes->code_list[54].cdf_mean = "PULMONOLOGY"
 SET codes->code_list[55].cki = "CKI.CODEVALUE!4108695804"
 SET codes->code_list[55].cdf_mean = "VASC_SURG"
 SET codes->code_list[56].cki = "CKI.CODEVALUE!4108695717"
 SET codes->code_list[56].cdf_mean = "ALLERGY_IMMU"
 SET codes->code_list[57].cki = "CKI.CODEVALUE!4108695721"
 SET codes->code_list[57].cdf_mean = "CHIROPRACTIC"
 SET codes->code_list[58].cki = "CKI.CODEVALUE!4108695729"
 SET codes->code_list[58].cdf_mean = "FAM_MED"
 SET codes->code_list[59].cki = "CKI.CODEVALUE!4108695731"
 SET codes->code_list[59].cdf_mean = "GEN_SURG"
 SET codes->code_list[60].cki = "CKI.CODEVALUE!4108695733"
 SET codes->code_list[60].cdf_mean = "GERONTOLOGY"
 SET codes->code_list[61].cki = "CKI.CODEVALUE!4108695739"
 SET codes->code_list[61].cdf_mean = "NEURO_SURG"
 SET codes->code_list[62].cki = "CKI.CODEVALUE!4108695742"
 SET codes->code_list[62].cdf_mean = "NURSING"
 UPDATE  FROM code_value cv,
   (dummyt d  WITH seq = value(size(codes->code_list,5)))
  SET cv.cdf_meaning = codes->code_list[d.seq].cdf_mean, cv.updt_applctx = reqinfo->updt_applctx, cv
   .updt_cnt = (cv.updt_cnt+ 1),
   cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv.updt_task =
   reqinfo->updt_task
  PLAN (d)
   JOIN (cv
   WHERE cv.code_set=4003171
    AND (cv.cki=codes->code_list[d.seq].cki)
    AND cv.active_ind=1
    AND ((cv.cdf_meaning="") OR (cv.cdf_meaning=null)) )
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update CODE_VALUE: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 FREE RECORD codes
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
