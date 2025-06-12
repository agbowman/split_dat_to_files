CREATE PROGRAM collate_codeset_4002119:dba
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
 SET readme_data->message = "Readme Failed:  Starting script collate_codeset_4002119"
 FREE SET codesetcdfmeaning
 RECORD codesetcdfmeaning(
   1 qual[*]
     2 cdf_meaning = vc
     2 collate_seq = i4
 )
 DECLARE err_code = i4 WITH protect, noconstant(0)
 DECLARE err_msg = vc WITH protect, noconstant("")
 DECLARE csv1 = vc WITH public, noconstant("codeset4002119_displays.csv")
 DECLARE csvtotal = i4 WITH public, noconstant(1)
 DECLARE rdm_current_status = c1 WITH public, noconstant("F")
 DECLARE fullcsv1 = vc WITH public, noconstant("")
 DECLARE fillcollatedescription4002119() = null
 DECLARE checkcsvfilesforenglishandnonenglishdomain() = null
 DECLARE updatecollatesequencenumber() = null
 CALL fillcollatedescription4002119(null)
 CALL checkcsvfilesforenglishandnonenglishdomain(null)
 CALL updatecollatesequencenumber(null)
 SUBROUTINE fillcollatedescription4002119(dummyvar)
   SET stat = alterlist(codesetcdfmeaning->qual,23)
   SET codesetcdfmeaning->qual[1].cdf_meaning = "VAGINAL"
   SET codesetcdfmeaning->qual[1].collate_seq = 1
   SET codesetcdfmeaning->qual[2].cdf_meaning = "FORCEPVACUUM"
   SET codesetcdfmeaning->qual[2].collate_seq = 2
   SET codesetcdfmeaning->qual[3].cdf_meaning = "FORCEP ASSIS"
   SET codesetcdfmeaning->qual[3].collate_seq = 3
   SET codesetcdfmeaning->qual[4].cdf_meaning = "VACUUMASSIST"
   SET codesetcdfmeaning->qual[4].collate_seq = 4
   SET codesetcdfmeaning->qual[5].cdf_meaning = "VBAC"
   SET codesetcdfmeaning->qual[5].collate_seq = 5
   SET codesetcdfmeaning->qual[6].cdf_meaning = "CSECTION"
   SET codesetcdfmeaning->qual[6].collate_seq = 6
   SET codesetcdfmeaning->qual[7].cdf_meaning = "CLASSICAL"
   SET codesetcdfmeaning->qual[7].collate_seq = 7
   SET codesetcdfmeaning->qual[8].cdf_meaning = "LOWTRANSVERS"
   SET codesetcdfmeaning->qual[8].collate_seq = 8
   SET codesetcdfmeaning->qual[9].cdf_meaning = "LOWVERTICAL"
   SET codesetcdfmeaning->qual[9].collate_seq = 9
   SET codesetcdfmeaning->qual[10].cdf_meaning = "J INCISION"
   SET codesetcdfmeaning->qual[10].collate_seq = 10
   SET codesetcdfmeaning->qual[11].cdf_meaning = "T INCISION"
   SET codesetcdfmeaning->qual[11].collate_seq = 11
   SET codesetcdfmeaning->qual[12].cdf_meaning = "C FORCEPVACU"
   SET codesetcdfmeaning->qual[12].collate_seq = 12
   SET codesetcdfmeaning->qual[13].cdf_meaning = "C FORCEP"
   SET codesetcdfmeaning->qual[13].collate_seq = 13
   SET codesetcdfmeaning->qual[14].cdf_meaning = "C VACUUM"
   SET codesetcdfmeaning->qual[14].collate_seq = 14
   SET codesetcdfmeaning->qual[15].cdf_meaning = "C OTHER"
   SET codesetcdfmeaning->qual[15].collate_seq = 15
   SET codesetcdfmeaning->qual[16].cdf_meaning = "C UNKNOWN"
   SET codesetcdfmeaning->qual[16].collate_seq = 16
   SET codesetcdfmeaning->qual[17].cdf_meaning = "ECTOPIC"
   SET codesetcdfmeaning->qual[17].collate_seq = 17
   SET codesetcdfmeaning->qual[18].cdf_meaning = "ECTOPIC LAT"
   SET codesetcdfmeaning->qual[18].collate_seq = 18
   SET codesetcdfmeaning->qual[19].cdf_meaning = "ECTOPIC MM"
   SET codesetcdfmeaning->qual[19].collate_seq = 19
   SET codesetcdfmeaning->qual[20].cdf_meaning = "S ABORT"
   SET codesetcdfmeaning->qual[20].collate_seq = 20
   SET codesetcdfmeaning->qual[21].cdf_meaning = "S ABORT DC"
   SET codesetcdfmeaning->qual[21].collate_seq = 21
   SET codesetcdfmeaning->qual[22].cdf_meaning = "T ABORT MED"
   SET codesetcdfmeaning->qual[22].collate_seq = 22
   SET codesetcdfmeaning->qual[23].cdf_meaning = "T ABORT SRG"
   SET codesetcdfmeaning->qual[23].collate_seq = 23
 END ;Subroutine
 SUBROUTINE checkcsvfilesforenglishandnonenglishdomain(dummyvar)
   IF (checkprg("RDM_GLOBAL_OMF"))
    EXECUTE rdm_global_omf csvtotal
    IF (rdm_current_status="F")
     SET readme_data->message = concat("Fail checking global.",readme_data->message)
     GO TO exit_script
    ENDIF
   ENDIF
   SET fullcsv1 = concat("cer_install:",csv1)
   EXECUTE dm_dbimport fullcsv1, "update_codeset4002119_display", 300
 END ;Subroutine
 SUBROUTINE updatecollatesequencenumber(null)
  UPDATE  FROM code_value cv,
    (dummyt d  WITH seq = value(size(codesetcdfmeaning->qual,5)))
   SET cv.collation_seq = codesetcdfmeaning->qual[d.seq].collate_seq, cv.updt_dt_tm = cnvtdatetime(
     curdate,curtime3), cv.updt_id = reqinfo->updt_id,
    cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv
    .updt_cnt+ 1)
   PLAN (d)
    JOIN (cv
    WHERE cv.code_set=4002119
     AND cv.active_ind=1
     AND (cv.cdf_meaning=codesetcdfmeaning->qual[d.seq].cdf_meaning))
  ;end update
  IF (error(err_msg,0) != 0)
   CALL echo("Readme Failed: Could not update the continue collation_seq value")
   SET readme_data->message = concat("collation_seq -  failed to update table rows: ",err_msg)
   SET readme_data->status = "F"
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 END ;Subroutine
 SET readme_data->message = "collate_codeset_4002119 - Updated successfully."
 SET readme_data->status = "S"
#exit_script
 IF ((readme_data->status="S"))
  CALL echo("*** collate_codeset_4002119 - Updated successfully ***")
 ELSE
  ROLLBACK
  CALL echo("*** collate_codeset_4002119 - Update failed ***")
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
