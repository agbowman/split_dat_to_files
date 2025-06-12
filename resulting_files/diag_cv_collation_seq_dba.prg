CREATE PROGRAM diag_cv_collation_seq:dba
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
 FREE SET diagranking
 RECORD diagranking(
   1 diag[*]
     2 codevalue = f8
     2 collationseq = i4
     2 display = c40
 )
 DECLARE diagcnt = i4
 SET diagcnt = 0
 SET readme_data->status = "F"
 SET readme_data->message = "Populating Diagnosis Code Set Structure"
 EXECUTE dm_readme_status
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=12034
  DETAIL
   diagcnt = (diagcnt+ 1), stat = alterlist(diagranking->diag,diagcnt), diagranking->diag[diagcnt].
   codevalue = cv.code_value,
   diagranking->diag[diagcnt].display = cv.display
   IF (cv.display_key IN ("PRIMARY", "1"))
    diagranking->diag[diagcnt].collationseq = 1
   ELSEIF (cv.display_key IN ("SECONDARY", "2"))
    diagranking->diag[diagcnt].collationseq = 2
   ELSEIF (cv.display_key IN ("TERTIARY", "3"))
    diagranking->diag[diagcnt].collationseq = 3
   ELSEIF (cv.display_key="4")
    diagranking->diag[diagcnt].collationseq = 4
   ELSEIF (cv.display_key="5")
    diagranking->diag[diagcnt].collationseq = 5
   ENDIF
  WITH nocounter
 ;end select
 SET readme_data->message = "Updating 12034 code set collation_seq values"
 EXECUTE dm_readme_status
 UPDATE  FROM code_value cv,
   (dummyt d  WITH seq = value(size(diagranking->diag,5)))
  SET cv.collation_seq = diagranking->diag[d.seq].collationseq, cv.updt_dt_tm = cnvtdatetime(curdate,
    curtime3)
  PLAN (d)
   JOIN (cv
   WHERE (cv.code_value=diagranking->diag[d.seq].codevalue))
 ;end update
 IF (curqual=diagcnt)
  SET readme_data->status = "S"
 ENDIF
 SET readme_data->message = "12034 Code Set collation_seq values successfully updated"
 EXECUTE dm_readme_status
END GO
