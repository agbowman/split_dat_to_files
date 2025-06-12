CREATE PROGRAM dm_ocd_include_check_date:dba
 DECLARE icd_prompt_user(null) = c1
 DECLARE icd_column_exists(ce_table=vc,ce_column=vc) = i2
 DECLARE icd_status(s_text=vc) = null
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 EXECUTE FROM 2000_check_date TO 2999_check_date_exit
 GO TO 9999_exit_program
 SUBROUTINE icd_prompt_user(null)
   SET message = window
   CALL clear(1,1)
   CALL text(1,1,"You are about to install a lower version of this package ")
   CALL text(2,1,"when a higher version is already available in the Admin Database.")
   CALL text(3,1,"Do you want to continue (Y/N)?")
   CALL accept(3,60,"P(1);CU","N"
    WHERE curaccept IN ("Y", "N"))
   SET message = nowindow
   RETURN(curaccept)
 END ;Subroutine
 SUBROUTINE icd_column_exists(ce_table,ce_column)
   IF (checkdic(cnvtupper(concat(ce_table,".",ce_column)),"A",0)=2)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE icd_status(s_text)
   CALL echo(s_text)
 END ;Subroutine
#1000_initialize
 IF ( NOT (validate(docd_reply,0)))
  RECORD docd_reply(
    1 status = c1
    1 err_msg = vc
  )
 ENDIF
 SET docd_reply->status = "L"
 SET icd_i = 0
 SET icd_j = 0
 DECLARE docd_tmp_status = vc WITH protect, noconstant(" ")
 FREE RECORD icd_data
 RECORD icd_data(
   1 ocd = i4
   1 file = vc
   1 text = vc
   1 archive_date = dq8
   1 cload_ind = i2
 )
 SET icd_data->ocd =  $1
 IF ( NOT (icd_data->ocd))
  CALL icd_status("WARNING: Unable to verify install.  No OCD number provided.")
  GO TO 9999_exit_program
 ENDIF
 SET icd_data->cload_ind = 0
#1999_initialize_exit
#2000_check_date
 CALL icd_status("Checking schema file archive date.")
 IF ( NOT (icd_column_exists("DM_ALPHA_FEATURES","ARCHIVE_DT_TM")))
  CALL icd_status("DM_ALPHA_FEATURES table does not exist.  Aborting schema archive date check.")
  GO TO 9999_exit_program
 ENDIF
 SET icd_data->text = cnvtlower(trim(logical("cer_ocd"),3))
 SET icd_i = findstring("]",icd_data->text)
 IF (icd_i)
  SET icd_data->text = substring(1,(icd_i - 1),icd_data->text)
 ENDIF
 IF (cursys="AIX")
  SET icd_data->file = concat(icd_data->text,"/",trim(format(icd_data->ocd,"######;P0"),3),"/")
 ELSEIF (cursys="WIN")
  SET icd_data->file = concat(icd_data->text,"\",trim(format(icd_data->ocd,"######;P0"),3),"\")
 ELSE
  SET icd_data->file = concat(icd_data->text,trim(format(icd_data->ocd,"######;P0"),3),"]")
 ENDIF
 SET icd_data->file = concat(icd_data->file,"ocd_schema_",trim(cnvtstring(icd_data->ocd),3),".txt")
 IF ( NOT (findfile(icd_data->file)))
  CALL icd_status(concat("WARNING: Unable to check schema file archive date.  File (",icd_data->file,
    ") not found."))
  GO TO 9999_exit_program
 ENDIF
 FREE DEFINE rtl
 FREE SET icd_file
 SET logical icd_file value(icd_data->file)
 DEFINE rtl "icd_file"
 SELECT INTO "nl:"
  r.line
  FROM rtlt r
  DETAIL
   IF ( NOT (icd_data->archive_date))
    icd_i = findstring(";",r.line)
    IF (icd_i)
     icd_j = findstring("=",r.line,icd_i)
     IF ((icd_j > (icd_i+ 1)))
      icd_data->text = cnvtupper(trim(substring((icd_i+ 1),((icd_j - icd_i) - 1),r.line),3))
      IF ((icd_data->text="ARCHIVE DATE"))
       icd_data->archive_date = cnvtdatetime(substring((icd_j+ 1),23,r.line))
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF ((icd_data->cload_ind=0))
    IF (((findstring("$CLOAD$",r.line) > 0) OR (findstring("$ALOAD$DM_TABLE_RELATIONSHIPS",r.line) >
    0)) )
     icd_data->cload_ind = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (icd_data->archive_date)
  SELECT INTO "nl:"
   f.archive_dt_tm
   FROM dm_alpha_features f
   WHERE (f.alpha_feature_nbr=icd_data->ocd)
    AND f.owner=currdbuser
    AND f.archive_dt_tm > cnvtdatetime("01-JAN-1900")
   DETAIL
    IF ((icd_data->archive_date < f.archive_dt_tm))
     docd_reply->status = "F"
    ELSEIF ((icd_data->archive_date > f.archive_dt_tm))
     docd_reply->status = "L"
    ELSEIF ((icd_data->cload_ind=0))
     docd_reply->status = "N"
    ELSE
     docd_reply->status = "C"
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (validate(dir_ui_misc->auto_install_ind,0)=1)
  IF ((docd_reply->status="F"))
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_PKG_INSTALL_ARCHIVE_CHK"
     AND d.info_name=trim(cnvtstring(icd_data->ocd),3)
    DETAIL
     docd_tmp_status = d.info_char
    WITH nocounter
   ;end select
   IF (curqual > 0)
    IF (docd_tmp_status="L")
     DELETE  FROM dm_info d
      WHERE d.info_domain="DM2_PKG_INSTALL_ARCHIVE_CHK"
       AND d.info_name=trim(cnvtstring(icd_data->ocd),3)
      WITH nocounter
     ;end delete
     DELETE  FROM dm_alpha_features f
      WHERE (f.alpha_feature_nbr=icd_data->ocd)
       AND f.owner=currdbuser
       AND f.archive_dt_tm > cnvtdatetime("01-JAN-1900")
      WITH nocounter
     ;end delete
     COMMIT
     SET docd_reply->status = "L"
     SET user_sel_load = 1
    ELSEIF (docd_tmp_status="N")
     DELETE  FROM dm_info d
      WHERE d.info_domain="DM2_PKG_INSTALL_ARCHIVE_CHK"
       AND d.info_name=trim(cnvtstring(icd_data->ocd),3)
      WITH nocounter
     ;end delete
     SET docd_reply->status = "N"
    ELSE
     SET docd_reply->status = "F"
    ENDIF
   ENDIF
  ENDIF
 ELSE
  IF ((docd_reply->status="F"))
   IF (icd_prompt_user(null)="Y")
    DELETE  FROM dm_alpha_features f
     WHERE (f.alpha_feature_nbr=icd_data->ocd)
      AND f.owner=currdbuser
      AND f.archive_dt_tm > cnvtdatetime("01-JAN-1900")
     WITH nocounter
    ;end delete
    COMMIT
    SET docd_reply->status = "L"
    SET user_sel_load = 1
   ENDIF
  ENDIF
 ENDIF
 CASE (docd_reply->status)
  OF "F":
   CALL icd_status("Schema file archive date check complete.  Quitting.")
  OF "L":
   CALL icd_status("Schema file archive date check complete.  Load necessary.")
  OF "N":
   CALL icd_status("Schema file archive date check complete.  No load necessary.")
  OF "C":
   CALL icd_status("Schema file archive date check complete.  Only clinical load necessary.")
 ENDCASE
#2999_check_date_exit
#9999_exit_program
END GO
