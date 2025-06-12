CREATE PROGRAM cr_upd_367571_displays:dba
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
 SET readme_data->message = "Readme Failed:  Starting script cr_upd_367571_displays..."
 FREE RECORD status_rec
 RECORD status_rec(
   1 qual[*]
     2 code_set = i4
     2 cdf_meaning = c12
     2 display = c40
     2 old_display = c40
     2 definition = vc
 )
 SET stat = alterlist(status_rec->qual,12)
 SET status_rec->qual[1].code_set = 367571
 SET status_rec->qual[1].cdf_meaning = "ARCHIVEERR"
 SET status_rec->qual[1].display = "Error Archiving the Report"
 SET status_rec->qual[1].old_display = "Archive Error"
 SET status_rec->qual[1].definition = "An error occurred when attempting to archive the report"
 SET status_rec->qual[2].code_set = 367571
 SET status_rec->qual[2].cdf_meaning = "DEBUGFILEERR"
 SET status_rec->qual[2].display = "Error Saving Debug Files"
 SET status_rec->qual[2].old_display = "Report Debug File Creating Error"
 SET status_rec->qual[2].definition = "An error occurred when attempting to save debug files"
 SET status_rec->qual[3].code_set = 367571
 SET status_rec->qual[3].cdf_meaning = "DMSERR"
 SET status_rec->qual[3].display = "Error Distributing Report"
 SET status_rec->qual[3].old_display = "Sending to DMS Error"
 SET status_rec->qual[3].definition = "An error occurred when attempting to distribute the report"
 SET status_rec->qual[4].code_set = 367571
 SET status_rec->qual[4].cdf_meaning = "FINDPMERR"
 SET status_rec->qual[4].display = "Error Retrieving Page Master"
 SET status_rec->qual[4].old_display = "Finding Page Master Error"
 SET status_rec->qual[4].definition =
 "An error occurred when attempting to locate a valid page master"
 SET status_rec->qual[5].code_set = 367571
 SET status_rec->qual[5].cdf_meaning = "FOERR"
 SET status_rec->qual[5].display = "Error Creating FO Document"
 SET status_rec->qual[5].old_display = "Report FO Creating Error"
 SET status_rec->qual[5].definition = "An error occurred when attempting to create the FO document"
 SET status_rec->qual[6].code_set = 367571
 SET status_rec->qual[6].cdf_meaning = "NODATA"
 SET status_rec->qual[6].display = "No Qualification"
 SET status_rec->qual[6].old_display = "No Data"
 SET status_rec->qual[6].definition =
 "The parameters of the request did not qualify any data for the report"
 SET status_rec->qual[7].code_set = 367571
 SET status_rec->qual[7].cdf_meaning = "PDFERR"
 SET status_rec->qual[7].display = "Error Creating Final Output"
 SET status_rec->qual[7].old_display = "Report Pdf Creating Error"
 SET status_rec->qual[7].definition = "An error occurred when attempting to create the final output"
 SET status_rec->qual[8].code_set = 367571
 SET status_rec->qual[8].cdf_meaning = "RETRIEVALERR"
 SET status_rec->qual[8].display = "Error Retrieving Data"
 SET status_rec->qual[8].old_display = "Report Data Retrieval Error"
 SET status_rec->qual[8].definition = "An error occurred when attempting to retrieve data"
 SET status_rec->qual[9].code_set = 367571
 SET status_rec->qual[9].cdf_meaning = "TRANSFORMERR"
 SET status_rec->qual[9].display = "Error Transforming Data"
 SET status_rec->qual[9].old_display = "Report Data Transform Error"
 SET status_rec->qual[9].definition = "An error occurred when attempting to transform the data"
 SET status_rec->qual[10].code_set = 367571
 SET status_rec->qual[10].cdf_meaning = "SENTTODMS"
 SET status_rec->qual[10].display = "Report Distributed"
 SET status_rec->qual[10].old_display = "Sent to DMS"
 SET status_rec->qual[10].definition =
 "The report request has been successfully processed and was distributed"
 SET status_rec->qual[11].code_set = 28382
 SET status_rec->qual[11].cdf_meaning = "RES_PRESENSE"
 SET status_rec->qual[11].display = "Presence of Results"
 SET status_rec->qual[11].old_display = "Presense of Results"
 SET status_rec->qual[11].definition = "Contain indicates the presence of results"
 SET status_rec->qual[12].code_set = 367571
 SET status_rec->qual[12].cdf_meaning = "SKIPPED"
 SET status_rec->qual[12].display = "Canceled"
 SET status_rec->qual[12].old_display = "Skipped"
 SET status_rec->qual[12].definition = "The report request has been canceled"
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 UPDATE  FROM code_value c,
   (dummyt d  WITH seq = value(size(status_rec->qual,5)))
  SET c.display = status_rec->qual[d.seq].display, c.display_key = trim(cnvtupper(cnvtalphanum(
      status_rec->qual[d.seq].display)),3), c.description = status_rec->qual[d.seq].display,
   c.definition = status_rec->qual[d.seq].definition
  PLAN (d)
   JOIN (c
   WHERE (c.code_set=status_rec->qual[d.seq].code_set)
    AND (c.cdf_meaning=status_rec->qual[d.seq].cdf_meaning)
    AND (c.display=status_rec->qual[d.seq].old_display)
    AND ((c.code_value+ 0) > 0))
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme failed to update code_value table:",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 IF (curqual > 0)
  SET readme_data->status = "S"
  SET readme_data->message = "Success: Finished updating code_value table"
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Success: No records found that needed to be updated"
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 IF (validate(debug_ind,0)=0)
  FREE RECORD status_rec
 ENDIF
 EXECUTE dm_readme_status
END GO
