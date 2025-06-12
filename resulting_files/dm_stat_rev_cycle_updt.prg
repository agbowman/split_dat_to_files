CREATE PROGRAM dm_stat_rev_cycle_updt
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Upload Date" = "CURDATE"
  WITH outdev, date
 DECLARE scripttemplatevrsn = vc WITH noconstant("XXXXXX.001")
 DECLARE ds_begin_snapshot = dq8 WITH noconstant(cnvtdatetime(concat( $DATE," 12:00:00")))
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 DECLARE activitydate = i4 WITH protect, noconstant(0)
 DECLARE info_domain_id = f8
 DECLARE line1 = vc
 SELECT INTO "nl:"
  FROM dm_info di
  PLAN (di
   WHERE di.info_domain="REV_CYC_PARENT.*"
    AND di.info_name="RE_RUN")
  ORDER BY di.info_date DESC
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
  FOOT REPORT
   info_domain_id = (cnt+ 1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET info_domain_id = 1
 ENDIF
 CALL echo( $DATE)
 CALL echo(ds_begin_snapshot)
 INSERT  FROM dm_info di
  SET di.info_date = cnvtdatetime(ds_begin_snapshot), di.info_domain = "REV_CYC_PARENT.4", di
   .info_name = "RE_RUN",
   di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.info_domain_id = info_domain_id
  WITH nocounter
 ;end insert
 COMMIT
 IF (curqual=0)
  SET line1 = "An error occurred and the date was not updated"
 ELSE
  SET line1 = concat(format(ds_begin_snapshot,"mm/dd/yyyy;;d"),
   " was written to the table to be re-processed by Rev Cycle Lights On Collector Script")
 ENDIF
 SELECT INTO  $OUTDEV
  FROM dummyt d
  PLAN (d)
  HEAD REPORT
   col 0, line1
  WITH nocounter
 ;end select
END GO
