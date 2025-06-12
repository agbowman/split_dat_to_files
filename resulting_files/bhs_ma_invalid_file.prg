CREATE PROGRAM bhs_ma_invalid_file
 SET store_directory = "/cerner/d_prod/esa/esa_in/"
 SET invalid_filename = "invalid_file.dat"
 SET filename = concat(store_directory,invalid_filename)
 SET email_add = "'andrea.galiatsos@bhs.org'"
 SET cnt = 0
 FREE RECORD data
 RECORD data(
   1 qual[*]
     2 phys_nbr = vc
     2 nbr_unsigned_docs = f8
     2 cs_phys_name = vc
     2 date_processed = vc
 )
 IF (findfile(trim(filename))=1)
  CALL echo("found file")
  FREE DEFINE rtl2
  SET logical msg_file filename
  DEFINE rtl2 "msg_file"
 ELSE
  CALL echo("no file found")
  GO TO endprog
 ENDIF
 SELECT INTO "nl:"
  r.*
  FROM rtl2t r
  HEAD REPORT
   cnt = 0
  DETAIL
   IF (trim(substring(1,20,r.line),3) != " ")
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1
     AND cnt != 0)
     stat = alterlist(data->qual,(cnt+ 10))
    ENDIF
    data->qual[cnt].phys_nbr = trim(substring(1,20,r.line),3), data->qual[cnt].cs_phys_name = trim(
     substring(21,30,r.line),3), data->qual[cnt].nbr_unsigned_docs = cnvtint(trim(substring(51,15,r
       .line),3)),
    data->qual[cnt].date_processed = trim(substring(96,19,r.line),3)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO value(filename)
  phys_nbr = data->qual[d1.seq].phys_nbr, date_processed = data->qual[d1.seq].date_processed
  FROM (dummyt d1  WITH seq = value(cnt))
  ORDER BY phys_nbr, date_processed
  HEAD REPORT
   col 0, "When processing the ChartScript files, the following physicians", row + 1,
   col 0, "did not have SoftMed IDs within the Cerner system:", row + 2,
   col 0, "SoftMed ID", col 20,
   "Physician Name", col 50, "# unsigned doc",
   col 65, "Date Processed", row + 2
  FOOT  phys_nbr
   col 0, data->qual[d1.seq].phys_nbr, col 20,
   data->qual[d1.seq].cs_phys_name, col 50, data->qual[d1.seq].nbr_unsigned_docs";l",
   col 65, data->qual[d1.seq].date_processed, row + 1
  WITH nocounter
 ;end select
 SET email_subj = "'ChartScript Invalid Physician File'"
 SET aix_command = concat("mailx -s ",email_subj," ",email_add," < ",
  filename)
 SET email_size = size(trim(aix_command))
 SET comm_opt = 0
 CALL echo(email_size)
 CALL echo(aix_command)
 CALL dcl(aix_command,email_size,comm_opt)
 SET email_add = "'chanthou.sevilla@bhs.org'"
 SET email_subj = "'ChartScript Invalid Physician File'"
 SET aix_command = concat("mailx -s ",email_subj," ",email_add," < ",
  filename)
 SET email_size = size(trim(aix_command))
 SET comm_opt = 0
 CALL echo(email_size)
 CALL echo(aix_command)
 CALL dcl(aix_command,email_size,comm_opt)
 SET stat = remove(filename)
#endprog
END GO
