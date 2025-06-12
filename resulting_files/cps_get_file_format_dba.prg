CREATE PROGRAM cps_get_file_format:dba
 PROMPT
  "File Full Path/Name: " = "NA"
 IF (validate(c_cpsstatus,"N")="N")
  CALL echo("***")
  CALL echo("***   declare persistscript variables")
  CALL echo("***")
  DECLARE c_cpsstatus = c1 WITH noconstant("S"), persistscript
  DECLARE str_cpsstatusmsg = vc WITH noconstant(""), persistscript
  DECLARE str_fileformat = vc WITH noconstant(""), persistscript
 ELSE
  CALL echo("***")
  CALL echo("***   set persistscript variables")
  CALL echo("***")
  SET c_cpsstatus = "S"
  SET str_cpsstatusmsg = ""
  SET str_fileformat = ""
 ENDIF
 DECLARE i_cpserror = i4 WITH noconstant(0), protect
 DECLARE const_appps = vc WITH constant("application/postscript"), protect
 DECLARE const_apprtf = vc WITH constant("application/rft"), protect
 DECLARE const_apppdf = vc WITH constant("application/pdf"), protect
 DECLARE const_textplain = vc WITH constant("text/plain"), protect
 IF (( $1="NA"))
  SET c_cpsstatus = "F"
  SET str_cpsstatusmsg = "Invalid or No File Name Passed"
  GO TO exit_script
 ENDIF
 IF (findfile( $1)=1)
  FREE DEFINE rtl3
  FREE SET file_loc
  SET logical file_loc value( $1)
  DEFINE rtl3 "file_loc"
  SELECT INTO "nl:"
   r2.line
   FROM rtl3t r2
   HEAD REPORT
    CASE (substring(1,5,r2.line))
     OF "%!PS-":
      str_fileformat = const_appps
     OF "%PDF-":
      str_fileformat = const_apppdf
     OF "{\RTF":
      str_fileformat = const_apprtf
     ELSE
      str_fileformat = const_textplain
    ENDCASE
   WITH nocounter, maxrec = 1
  ;end select
  FREE DEFINE rtl3
  FREE SET file_loc
  SET i_cpserror = error(str_cpsstatusmsg,1)
  IF (i_cpserror > 0)
   SET c_cpsstatus = "F"
  ENDIF
 ELSE
  SET c_cpsstatus = "F"
  SET str_cpsstatusmsg = concat("Failed to find file ",trim( $1))
 ENDIF
#exit_script
 SET cps_script_ver = "001 02/24/04 SF3151"
END GO
