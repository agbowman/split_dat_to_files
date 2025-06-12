CREATE PROGRAM dm_combine_error_rpt:dba
 PAINT
 CALL clear(1,1)
 SET sdate = fillstring(50," ")
 SET edate = fillstring(50," ")
 SET start_date = fillstring(50," ")
 SET end_date = fillstring(50," ")
 CALL text(1,1,"Start of the date range, without quotes, in format 15-JAN-1997")
 CALL accept(2,1,"p(50);cu")
 SET sdate = curaccept
 SET start_date = build(sdate," 23:59:59")
 CALL text(4,1,"End of the date range, without quotes, in format 15-JAN-1997")
 CALL accept(5,1,"p(50);cu")
 SET edate = curaccept
 SET end_date = build(edate," 23:59:59")
 CALL clear(1,1)
 SELECT INTO "nl:"
  dce.*
  FROM dm_combine_error dce
  WHERE dce.operation_type="COMBINE"
   AND dce.parent_entity="PERSON"
   AND dce.create_dt_tm >= cnvtdatetime(start_date)
   AND dce.create_dt_tm <= cnvtdatetime(end_date)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT INTO mine
   dce.*
   FROM dm_combine_error dce
   WHERE dce.create_dt_tm >= cnvtdatetime(start_date)
    AND dce.create_dt_tm <= cnvtdatetime(end_date)
    AND dce.operation_type="COMBINE"
    AND dce.parent_entity="PERSON"
   ORDER BY dce.create_dt_tm DESC
   HEAD REPORT
    row + 1, col 45, "PERSON COMBINES THAT FAILED",
    row + 1, row + 1, col 1,
    "CreateDate", col 18, "FromPersonId",
    col 31, "ToPersonId", col 42,
    "EncntrId", col 51, "ErrorTable",
    col 82, "ErrorType", col 103,
    "CombineMode", row + 1, col 1,
    "----------------", col 18, "------------",
    col 31, "----------", col 42,
    "--------", col 51, "------------------------------",
    col 82, "--------------------", col 103,
    "------------------", row + 1, rowcnt = 0
   DETAIL
    rowcnt += 1, row + 1, col 1,
    dce.create_dt_tm"MM/DD/YYYY HH:MM", col 18, dce.from_id"########",
    col 31, dce.to_id"########", col 42,
    dce.encntr_id"########", col 51, dce.error_table,
    col 82,
    CALL print(substring(1,19,dce.error_type)), col 103,
    CALL print(substring(1,17,dce.combine_mode)), row + 1, col 1,
    CALL print(substring(1,118,dce.error_msg)), row + 1
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO mine
   d.seq
   FROM dummyt d
   HEAD REPORT
    row + 1, col 45, "PERSON COMBINES THAT FAILED",
    row + 1, row + 1, col 1,
    "CreateDate", col 18, "FromPersonId",
    col 31, "ToPersonId", col 42,
    "EncntrId", col 51, "ErrorTable",
    col 82, "ErrorType", col 103,
    "CombineMode", row + 1, col 1,
    "----------------", col 18, "------------",
    col 31, "----------", col 42,
    "--------", col 51, "------------------------------",
    col 82, "--------------------", col 103,
    "------------------"
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  dce.*
  FROM dm_combine_error dce
  WHERE dce.operation_type="UNCOMBINE"
   AND dce.parent_entity="PERSON"
   AND dce.create_dt_tm >= cnvtdatetime(start_date)
   AND dce.create_dt_tm <= cnvtdatetime(end_date)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT INTO mine
   dce.*
   FROM dm_combine_error dce
   WHERE dce.create_dt_tm >= cnvtdatetime(start_date)
    AND dce.create_dt_tm <= cnvtdatetime(end_date)
    AND dce.operation_type="UNCOMBINE"
    AND dce.parent_entity="PERSON"
   ORDER BY dce.create_dt_tm DESC
   HEAD REPORT
    row + 1, col 35, "PERSON UNCOMBINES THAT FAILED",
    row + 1, row + 1, col 1,
    "CreateDate", col 18, "FromPersonId",
    col 31, "ToPersonId", col 42,
    "EncntrId", col 51, "ErrorTable",
    col 82, "ErrorType", col 103,
    "CombineMode", row + 1, col 1,
    "----------------", col 18, "------------",
    col 31, "----------", col 42,
    "--------", col 51, "------------------------------",
    col 82, "--------------------", col 103,
    "------------------", row + 1, rowcnt = 0
   DETAIL
    rowcnt += 1, row + 1, col 1,
    dce.create_dt_tm"MM/DD/YYYY HH:MM", col 18, dce.from_id"########",
    col 31, dce.to_id"########", col 42,
    dce.encntr_id"########", col 51, dce.error_table,
    col 82,
    CALL print(substring(1,19,dce.error_type)), col 103,
    CALL print(substring(1,17,dce.combine_mode)), row + 1, col 1,
    CALL print(substring(1,118,dce.error_msg)), row + 1
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO mine
   d.seq
   FROM dummyt d
   HEAD REPORT
    row + 1, col 45, "PERSON UNCOMBINES THAT FAILED",
    row + 1, row + 1, col 1,
    "CreateDate", col 18, "FromPersonId",
    col 31, "ToPersonId", col 42,
    "EncntrId", col 51, "ErrorTable",
    col 82, "ErrorType", col 103,
    "CombineMode", row + 1, col 1,
    "----------------", col 18, "------------",
    col 31, "----------", col 42,
    "--------", col 51, "------------------------------",
    col 82, "--------------------", col 103,
    "------------------"
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  dce.*
  FROM dm_combine_error dce
  WHERE dce.operation_type="COMBINE"
   AND dce.parent_entity="ENCOUNTER"
   AND dce.create_dt_tm >= cnvtdatetime(start_date)
   AND dce.create_dt_tm <= cnvtdatetime(end_date)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT INTO mine
   dce.*
   FROM dm_combine_error dce
   WHERE dce.create_dt_tm >= cnvtdatetime(start_date)
    AND dce.create_dt_tm <= cnvtdatetime(end_date)
    AND dce.operation_type="COMBINE"
    AND dce.parent_entity="ENCOUNTER"
   ORDER BY dce.create_dt_tm DESC
   HEAD REPORT
    row + 1, col 45, "ENCOUNTER COMBINES THAT FAILED",
    row + 1, row + 1, col 1,
    "CreateDate", col 18, "FromEncntrId",
    col 31, "ToEncntrId", col 42,
    "ErrorTable", col 73, "ErrorType",
    col 94, "CombineMode", row + 1,
    col 1, "----------------", col 18,
    "------------", col 31, "----------",
    col 42, "------------------------------", col 73,
    "--------------------", col 94, "------------------",
    row + 1, rowcnt = 0
   DETAIL
    rowcnt += 1, row + 1, col 1,
    dce.create_dt_tm"MM/DD/YYYY HH:MM", col 18, dce.from_id"########",
    col 31, dce.to_id"########", col 42,
    dce.error_table, col 73,
    CALL print(substring(1,19,dce.error_type)),
    col 94,
    CALL print(substring(1,17,dce.combine_mode)), row + 1,
    col 1,
    CALL print(substring(1,118,dce.error_msg)), row + 1
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO mine
   d.seq
   FROM dummyt d
   HEAD REPORT
    row + 1, col 45, "ENCOUNTER COMBINES THAT FAILED",
    row + 1, row + 1, col 1,
    "CreateDate", col 18, "FromEncntrId",
    col 31, "ToEncntrId", col 42,
    "ErrorTable", col 73, "ErrorType",
    col 94, "CombineMode", row + 1,
    col 1, "----------------", col 18,
    "------------", col 31, "----------",
    col 42, "------------------------------", col 73,
    "--------------------", col 94, "------------------"
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  dce.*
  FROM dm_combine_error dce
  WHERE dce.operation_type="UNCOMBINE"
   AND dce.parent_entity="ENCOUNTER"
   AND dce.create_dt_tm >= cnvtdatetime(start_date)
   AND dce.create_dt_tm <= cnvtdatetime(end_date)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT INTO mine
   dce.*
   FROM dm_combine_error dce
   WHERE dce.create_dt_tm >= cnvtdatetime(start_date)
    AND dce.create_dt_tm <= cnvtdatetime(end_date)
    AND dce.operation_type="UNCOMBINE"
    AND dce.parent_entity="ENCOUNTER"
   ORDER BY dce.create_dt_tm DESC
   HEAD REPORT
    row + 1, col 45, "ENCOUNTER UNCOMBINES THAT FAILED",
    row + 1, row + 1, col 1,
    "CreateDate", col 18, "FromEncntrId",
    col 31, "ToEncntrId", col 42,
    "ErrorTable", col 73, "ErrorType",
    col 94, "CombineMode", row + 1,
    col 1, "----------------", col 18,
    "------------", col 31, "----------",
    col 42, "------------------------------", col 73,
    "--------------------", col 94, "------------------",
    row + 1, rowcnt = 0
   DETAIL
    rowcnt += 1, row + 1, col 1,
    dce.create_dt_tm"MM/DD/YYYY HH:MM", col 18, dce.from_id"########",
    col 31, dce.to_id"########", col 42,
    dce.error_table, col 73,
    CALL print(substring(1,19,dce.error_type)),
    col 94,
    CALL print(substring(1,17,dce.combine_mode)), row + 1,
    col 1,
    CALL print(substring(1,118,dce.error_msg)), row + 1
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO mine
   d.seq
   FROM dummyt d
   HEAD REPORT
    row + 1, col 45, "ENCOUNTER UNCOMBINES THAT FAILED",
    row + 1, row + 1, col 1,
    "CreateDate", col 18, "FromEncntrId",
    col 31, "ToEncntrId", col 42,
    "ErrorTable", col 73, "ErrorType",
    col 94, "CombineMode", row + 1,
    col 1, "----------------", col 18,
    "------------", col 31, "----------",
    col 42, "------------------------------", col 73,
    "--------------------", col 94, "------------------"
   WITH nocounter
  ;end select
 ENDIF
END GO
