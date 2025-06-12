CREATE PROGRAM dm_data_default_custom_date:dba
 RECORD data_len(
   1 qual[*]
     2 len = i4
     2 name = vc
 )
 SET count = 0
 SET stat = alterlist(data_len->qual,count)
 SELECT DISTINCT
  length = textlen(trim(dt.data_default)), dt.data_default
  FROM dm_columns dt
  WHERE dt.schema_date=cnvtdatetime( $1)
   AND dt.data_default="*TO_DATE*"
  ORDER BY dt.data_default
  HEAD REPORT
   sdate = format(cnvtdatetime( $1),"DD-MMM-YYYY;;D"), col 0,
   "This report shows all the distinct data_defaults with length > 40 that exist in the dm_columns.",
   row + 1, "Only data defaults of length < 40 are acceptable.", row + 2,
   "Cerner is in the process of repromoting tables via the OCD process with the correct data default lengths.",
   row + 2, sdate,
   row + 2, "Length", col 20,
   "Type", row + 1, "-----------",
   col 20, "----", row + 1
  HEAD dt.data_default
   IF (textlen(trim(dt.data_default)) > 40)
    count = (count+ 1), stat = alterlist(data_len->qual,count)
   ENDIF
  DETAIL
   IF (textlen(trim(dt.data_default)) > 40)
    data_len->qual[count].len = textlen(trim(dt.data_default)), data_len->qual[count].name = concat(
     trim(dt.data_default),"*"), col 0,
    data_len->qual[count].len, col 20, data_len->qual[count].name,
    row + 1
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(data_len)
 FOR (xt = 1 TO count)
  UPDATE  FROM dm_columns dt
   SET dt.data_default = "TO_DATE ( '12/31/2100' , 'MM/DD/YYYY' )"
   WHERE dt.schema_date=cnvtdatetime( $1)
    AND dt.data_default=patstring(data_len->qual[xt].name)
   WITH nocounter
  ;end update
  COMMIT
 ENDFOR
 SELECT DISTINCT
  length = textlen(trim(dt.data_default)), dt.data_default
  FROM dm_columns dt
  WHERE dt.schema_date=cnvtdatetime( $1)
   AND dt.data_default="TO_DATE ( '12/31/2100' , 'MM/DD/YYYY' )"
  ORDER BY dt.data_default
  HEAD REPORT
   data_def = substring(1,50,dt.data_default), col 0,
   "All data_defaults have been converted to the following format",
   row + 2, col 20, data_def
  WITH nocounter
 ;end select
 FREE RECORD data_len
 FREE SET count
END GO
