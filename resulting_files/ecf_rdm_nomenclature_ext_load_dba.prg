CREATE PROGRAM ecf_rdm_nomenclature_ext_load:dba
 FREE RECORD timer
 RECORD timer(
   1 start = dq8
   1 stop = dq8
 )
 SET timer->start = cnvtdatetime(curdate,curtime3)
 FREE RECORD timer2
 RECORD timer2(
   1 start = dq8
   1 stop = dq8
 )
 SET timer2->start = cnvtdatetime(curdate,curtime3)
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SUBROUTINE logging(log_num,log_msgparams,log_tablenms,log_offfields,log_rowidents,log_cclerrmsg,
  log_addcommts,log_extra1,log_extra2,log_contno)
   IF (textlen(log_cclerrmsg) > 100)
    SET log_cclerrmsg = substring(1,100,log_cclerrmsg)
   ENDIF
   IF (textlen(log_offfields) > 100)
    SET log_offfields = substring(1,100,log_offfields)
   ENDIF
   IF (textlen(log_rowidents) > 100)
    SET log_rowidents = substring(1,100,log_rowidents)
   ENDIF
   IF (textlen(log_addcommts) > 100)
    SET log_addcommts = substring(1,100,log_addcommts)
   ENDIF
   IF (textlen(log_extra1) > 100)
    SET log_extra1 = substring(1,100,log_extra1)
   ENDIF
   IF (textlen(log_extra2) > 100)
    SET log_extra2 = substring(1,100,log_extra2)
   ENDIF
   DECLARE log_type = c14 WITH public, noconstant(fillstring(14," "))
   DECLARE log_msg = c110 WITH public, noconstant(fillstring(110," "))
   DECLARE log_res = c110 WITH public, noconstant(fillstring(110," "))
   DECLARE log_res2 = c110 WITH public, noconstant(fillstring(110," "))
   DECLARE log_string = vc WITH public, noconstant(" ")
   DECLARE log_parse_str = vc WITH public, noconstant(" ")
   DECLARE log_idx_str = vc WITH public, noconstant(" ")
   DECLARE log_msg_cnt = i4 WITH public, noconstant(0)
   DECLARE rhead = vc WITH public, constant(notrim(concat("{\rtf1\ansi \deff0{\fonttbl",
      "{\f0\fswiss\fprq2\fcharset0 Arial;}}{\colortbl ;\red255\green0\blue0;\red0\green0",
      "\blue255;}\deftab1134 \f0 \fs20 ")))
   DECLARE reol = vc WITH public, constant(notrim(concat(" \par"," ")))
   DECLARE rtfeof = vc WITH public, constant("}")
   DECLARE bb = vc WITH public, constant(notrim(concat(" \b"," ")))
   DECLARE eb = vc WITH public, constant(notrim(concat(" \b0"," ")))
   DECLARE bi = vc WITH public, constant(notrim(concat(" \i"," ")))
   DECLARE ei = vc WITH public, constant(notrim(concat(" \i0"," ")))
   DECLARE cb = vc WITH public, constant(notrim(concat(" \cf0"," ")))
   DECLARE cr = vc WITH public, constant(notrim(concat(" \cf1"," ")))
   DECLARE cu = vc WITH public, constant(notrim(concat(" \cf2"," ")))
   DECLARE cilm_cmt_log_id = f8
   DECLARE cilm_log_instance = i4
   DECLARE cilm_log_seq = i4
   DECLARE cilm_log_message = vc
   CASE (log_num)
    OF 1:
     SET log_msg = "No routes on import file."
    OF 2:
     SET log_msg = "Failed to retrieve code value from database. Error code %1"
     IF (log_msgparams > " ")
      IF (cnvtint(log_msgparams)=0)
       SET log_res =
       "0 = Add the display to your database, or replace 0 values, and cycle code cache"
      ELSEIF ((cnvtint(log_msgparams)=- (1)))
       SET log_res = "-1 = Inactivate one of the displays and cycle code cache"
      ELSEIF ((cnvtint(log_msgparams)=- (2)))
       SET log_res = "-2 = Contact your database administrator"
      ENDIF
     ENDIF
    OF 3:
     SET log_msg = "No dose ranges on import file."
     SET log_res = "Add a dose range value to the import file."
    OF 4:
     SET log_msg = "Duplicate dose ranges on import file."
     SET log_res = "Delete the duplicate rows to the import file."
    OF 5:
     SET log_msg = "Unable to generate next sequence number."
     SET log_res = "Contact your database administrator."
    OF 6:
     SET log_msg = "Failed to insert row."
     SET log_res = concat("Provide your database administrator with the error ",
      "and table name to help resolve the error.")
    OF 7:
     SET log_msg = "Failed to update row."
     SET log_res = concat("Provide your database administrator with the error ",
      "and table name to help resolve the error.")
    OF 8:
     SET log_msg = "Failed to retrieve record from database."
     SET log_res = concat("Try to locate the missing fields in your database.  ",
      "If found, log a service request with")
     SET log_res2 = concat("Cerner Knowledge Index MILL; if not, update the ",
      "incorrect field and re-import the file.")
    OF 9:
     SET log_msg = "Invalid operator value."
     SET log_res = concat("If you want to have values in both the From and ","To fields, change the")
     SET log_res2 = concat("Age/Weight operator value to something other ",
      "than one of the operator values listed above.")
    OF 10:
     SET log_msg = "The To_%1 value must be greater than the From_%1 value."
     SET log_res = concat("Modify the To and From values so the To value is ",
      "greater than the From value.")
    OF 11:
     SET log_msg = concat("The To_%1 value must be greater or equal ","to the From_%1 value.")
     SET log_res = concat("Modify the To and From values so the To value ",
      "is greater than the From value.")
    OF 12:
     SET log_msg = "A child script failed to execute successfully."
     SET log_res = "Log a service request with Cerner Knowledge Index MILL."
    OF 13:
     SET log_msg = "The code value exists in the database, but does not have a CKI."
     SET log_res = "For Code Set 54, use Code_Set_54_Utility to reconcile that code value."
     SET log_res2 =
     "Log a service request with Cerner Knowledge Index MILL for access to this utility."
    OF 14:
     SET log_msg = concat("Each row on the Qualifier tab must have at least one ",
      "active row at the %1 level.")
     SET log_res = concat("Inactivate the row (select 0), try to import, and the script will ignore ",
      "the change and not import that row.")
    OF 15:
     SET log_msg = "Failed to find the %1 value."
     SET log_res = concat("Try to locate the missing field in your database.  If found, log a ",
      "service request with Cerner")
     SET log_res2 =
     "Knowledge Index MILL; if not, update the incorrect field and re-import the file."
    OF 16:
     SET log_msg = "A duplicate or incorrect sequence exists."
     SET log_res = "Check the sequence column and evaluate any duplicates that exist."
    OF 17:
     SET log_msg = "A value must be specified for %1."
     SET log_res = "Change the value to a numeric or alphanumeric value."
    OF 18:
     SET log_msg = "Failed to delete row."
     SET log_res = concat("Provide your database administrator with the error and table name ",
      "to help resolve the error.")
    OF 19:
     SET log_msg = "Invalid dose range type."
     SET log_res = "Access the drop-down help within the cell."
    OF 20:
     SET log_msg = "Standard content must be loaded before loading custom content."
     SET log_res = concat("Load the standard Multum content first, then load your custom content.  ",
      "Log a service request")
     SET log_res2 = "with Cerner Knowledge Index MILL for information about Multum content."
    OF 21:
     SET log_msg = "A value must be specified for DOSE_UNIT on the DOSE_RANGE tab."
     SET log_res = "Enter a numeric or alphanumeric value in the Dose_Unit field."
    OF 22:
     SET log_msg = "The CMTI value is not unique."
     SET log_res = "Log a service request with Cerner Knowledge Index MILL."
    OF 23:
     SET log_msg = "The SOURCE_STRING field cannot be blank on the .CSV file."
     SET log_res =
     "If the file is custom-created, enter a value in the source_string field and rerun the import"
     SET log_res2 =
     "to include the row; otherwise, log a service request with Cerner Knowledge Index MILL."
    OF 24:
     SET log_msg = "The value for %1 must be %2."
    OF 25:
     SET log_msg = "The %1 tab must be %2."
    OF 26:
     SET log_msg = "The row count is incorrect on the following table: %1."
     SET log_res = "Log a service request with Cerner Knowledge Index MILL."
    OF 27:
     SET log_msg = "PowerForm did not load successfully."
    OF 28:
     SET log_msg = "The Beg_effective_dt_tm is greater than the End_effective_dt_tm on the .CSV."
     SET log_res = concat(
      "If the file is custom-created, evaluate the effective dates; otherwise, log a ",
      "service request with")
     SET log_res2 = "Cerner Knowledge Index MILL."
    OF 29:
     SET log_msg = "Invalid type flag.  Enter a valid value for the type flag."
     SET log_res = concat("If the file is custom-created, enter a valid flag value, provided above, ",
      "in the flag type field;")
     SET log_res2 = "otherwise, log a service request with Cerner Knowledge Index MILL."
    OF 30:
     SET log_msg = "The following .CSV file did not import successfully."
     SET log_res = "Review the other errors in the log file for more information."
    OF 31:
     SET log_msg = concat(
      "Failed to locate the following .CSV file.  Verify the .CSV file is in the ","proper location."
      )
     SET log_res = concat("Review the installation manager to verify that the .CSV is in the proper ",
      "location and named correctly.")
    OF 32:
     SET log_msg = "Multiple CKIs (DNUMs) were found for the order catalog orderable you selected."
     SET log_res = concat("Run the Meds CKI Utility, or change the description to match the ",
      "description in your database.")
    OF 33:
     SET log_msg = "Mnemonic and mnemonic type already exist on the order catalog synonym table."
     SET log_res = "Either give the row a new mnemonic, or new mnemonic type."
    OF 34:
     SET log_msg = "Multiple primary synonyms were found for the order catalog synonym you selected."
     SET log_res = "Inactivate all but one primary synonym."
    OF 35:
     SET log_msg = "Invalid date format on .CSV file."
     SET log_res =
     "The format needs to be in the form DD-MMM-YYYY.  DO NOT use the format DD/MMM/YYYY."
    OF 36:
     SET log_msg = "Concept CKI value does not match mean and identifier."
     SET log_res = "Log a service request with Cerner Knowledge Index MILL."
    OF 37:
     SET log_msg = "Required field missing from CSV."
     SET log_res = "Review CSV file for required fields."
    OF 38:
     SET log_msg = "Duplicate records exist in the database."
     SET log_res = "If you are updating, resolve or inactivate the duplicate section."
    OF 39:
     SET log_msg = "No primary synonym was found for the order catalog synonym you selected."
     SET log_res = "Please set the MNEMONIC_TYPE_DISP field to Primary for one synonym."
    OF 40:
     SET log_msg = "Table does not exist in database."
     SET log_res = "Log a service request with Cerner Knowledge Index MILL."
    OF 42:
     SET log_msg = "Multiple Interps found for the reference range specified."
     SET log_res = "Manual steps should be taken to correct this issue."
    OF 43:
     SET log_msg =
     "The version of DRC attempting to be imported is not the same version of DRC installed in this domain."
    OF 5000:
     SET log_msg = "The CKI in the import file is different than the CKI in the database."
    OF 5001:
     SET log_msg = "The DTA event code has been updated."
    OF 5002:
     SET log_msg = "Primary key %1 does not exist on the table."
    OF 5003:
     SET log_msg = "Two forms of the same description exist in destination domain."
     SET log_res = "If you are updating, resolve or inactivate the duplicate form."
    OF 5004:
     SET log_msg = "Two sections of the same description exist in destination domain."
     SET log_res = "If you are updating, resolve or inactivate the duplicate section."
    OF 5005:
     SET log_msg = "WARNING: Section is overwritten."
    OF 5006:
     SET log_msg = "WARNING: Form is overwritten."
    OF 5007:
     SET log_msg = "Unable to find MERGE_NAME: %1"
    OF 5008:
     SET log_msg = "A record already exists in the database where primary_vterm_ind = 1."
    OF 5009:
     SET log_msg = "Order catalog code %1 has been inactivated by the source."
    OF 5010:
     SET log_msg = "Review the effective dates on the source identifier."
    OF 5011:
     SET log_msg = "A value should be specified for %1."
    OF 5012:
     SET log_msg = "The value for %1 should be %2."
    OF 5013:
     SET log_msg = "Duplicate records exist in the database."
     SET log_res = "If you are updating, resolve or inactivate the duplicate section."
    OF 5014:
     SET log_msg = "Script received request for zero data; no data was passed to the script."
    OF 5015:
     SET log_msg = "The effective dates are set to occur in the future."
     SET log_res = concat(
      "If the effective dates are supposed to be in the future, ignore this warning.  ",
      "If the term should")
     SET log_res2 = "be effective now, change the beginning effective date."
    OF 5016:
     SET log_msg = concat("More than one Surgical Procedure row exists on this request; only ",
      "one Surgical Procedure row can exist per Order Catalog item.")
    OF 5017:
     SET log_msg = "Failed to find the %1 value."
    OF 5018:
     SET log_msg = concat("The Dose Range Checking %1 operator (>, <=, or Between) are the only ",
      "three recommended operator values.")
    OF 5019:
     SET log_msg = "Record does not exist on database."
    OF 5020:
     SET log_msg = "A duplicate or incorrect sequence exists."
     SET log_res = "Check the sequence column and evaluate any duplicates that exist."
    OF 5021:
     SET log_msg = "Not allowed to insert into code_set."
    OF 5022:
     SET log_msg = "Not allowed to update code_value."
    OF 5023:
     SET log_msg = "Duplicate sequences loaded."
    OF 5024:
     SET log_msg = "The Event Code attached to this DTA has an existing concept_cki."
    OF 5025:
     SET log_msg = "Reference Text already exists for this DTA. Data not inserted."
    OF 5026:
     SET log_msg = "The Event Code belongs to multiple Event Sets. Data not updated."
    OF 5027:
     SET log_msg =
     "Event code Display was matched after converting to uppercase and removing spaces."
    OF 5028:
     SET log_msg =
     "The Event Code identified in the domain has a different CKI value than the one in the file."
    OF 5029:
     SET log_msg =
     "The Event Code CKI in file cannot be inserted or updated as the CKI is already in use in the domain."
    OF 5030:
     SET log_msg =
     "The Event Code identified has a Concept_CKI value, but it is not the specified Concept_CKI value."
    OF 5031:
     SET log_msg = "***Incomplete Data Exists***  An Event Code could not be uniquely identified."
     SET log_res =
     "Manual steps MUST be taken to identify the correct Event Code for the DTA or Ultra Grid intersection."
    OF 5032:
     SET log_msg = "WARNING: Interp was overwritten."
    OF 8001:
     SET log_msg = "Order catalog synonym %1 has been inactivated."
    OF 8002:
     SET log_msg = "Multum has made order catalog code %1 obsolete."
    OF 8003:
     SET log_msg = "Multum has made order catalog synonym %1 obsolete."
    OF 8004:
     SET log_msg = concat("The data has not been saved.  If you want to save the data, ",
      "try again or save the data to another location.")
    OF 8005:
     SET log_msg = "INFO.  Importing section %1."
    OF 8006:
     SET log_msg = "INFO.  Importing Input Control %1."
    OF 8007:
     SET log_msg = "INFO.  Real Sect Id: %1."
    OF 8008:
     SET log_msg = "INFO.  Temp Section Id: %1."
    OF 8009:
     SET log_msg = "INFO.  Prev Section Id: %1."
    OF 8010:
     SET log_msg = "INFO.  Number of rows: %1."
    OF 8011:
     SET log_msg = "The following record was updated:"
    OF 8012:
     SET log_msg = "The following record was inserted:"
    OF 8013:
     SET log_msg = "The following record was deleted:"
    OF 8014:
     SET log_msg = "The following .CSV file imported successfully."
    OF 8015:
     SET log_msg = "Duplicate records exist in the database."
    OF 8016:
     SET log_msg = "The beg_effective_dt_tm is greater than end_effective_dt_tm on the request."
     SET log_res = "Log a service request with Cerner Knowledge Index MILL."
    OF 8017:
     SET log_msg = "PowerForm already exists: %1"
     SET log_res = concat("If you got the ERROR (denoted by KIA-E-8017) version of this message, ",
      "log a service request")
     SET log_res2 = "with Cerner Knowledge Index MILL."
    OF 8018:
     SET log_msg = "Section is overwritten."
    OF 8019:
     SET log_msg = "Form is overwritten."
    OF 8020:
     SET log_msg = "A CKI (CNUM) already exists for this order catalog synonym."
    OF 8021:
     SET log_msg = "Record already exists on database."
    OF 8022:
     SET log_msg = "Record does not exist on database."
    OF 8023:
     SET log_msg = "Definition file could not be found."
    OF 8024:
     SET log_msg = "Future working view already exists."
    OF 8025:
     SET log_msg = "LDAP enabled."
    OF 8026:
     SET log_msg = "Event code created."
    OF 8027:
     SET log_msg = "Event code updated."
   ENDCASE
   IF (log_msgparams > " ")
    SET log_index = 0
    SET log_temp_index = 0
    SET log_continue = 1
    SET log_cnt = 0
    SET log_temp_string = fillstring(25," ")
    SET log_size = size(log_msgparams,1)
    SET log_msg = concat(log_msg,fillstring(50," "))
    WHILE (log_continue != 0)
      SET log_cnt = (log_cnt+ 1)
      SET log_temp_index = (log_index+ 1)
      SET log_index = findstring(";",log_msgparams,log_temp_index)
      IF (log_index=0)
       SET log_temp_string = substring(log_temp_index,((log_size - log_temp_index)+ 1),log_msgparams)
       SET log_continue = 0
      ELSE
       SET log_temp_string = substring(log_temp_index,(log_index - log_temp_index),log_msgparams)
      ENDIF
      SET log_msg = replace(log_msg,build("%",log_cnt),trim(log_temp_string),0)
    ENDWHILE
    SET log_msg = trim(log_msg)
   ENDIF
   IF (log_num < 5000
    AND log_num > 0)
    IF (log_num < 10)
     SET log_type = build("KIA-E-000",log_num,":")
    ELSEIF (log_num < 100)
     SET log_type = build("KIA-E-00",log_num,":")
    ELSE
     SET log_type = build("KIA-E-0",log_num,":")
    ENDIF
   ELSEIF (log_num < 8000
    AND log_num >= 5000)
    SET log_type = build("KIA-W-",log_num,":")
   ELSEIF (log_num < 10000
    AND log_num >= 8000)
    SET log_type = build("KIA-I-",log_num,":")
   ELSEIF (log_num=0)
    SET log_type = "DEBUG"
   ENDIF
   IF (log_num >= 0)
    IF (((log_level=1
     AND log_num < 8000
     AND log_num > 0) OR (((log_level=2
     AND log_num > 0) OR (log_level=3)) )) )
     IF (findstring("constraint",log_cclerrmsg,1,0)=0)
      IF (log_num > 0
       AND log_num < 5000)
       CALL insert_log_tables(log_type,log_msg,log_msgparams,log_tablenms,log_offfields,
        log_rowidents,log_cclerrmsg,log_addcommts,log_extra1,log_extra2,
        log_res)
      ENDIF
     ENDIF
     SELECT INTO value(logfile_name)
      FROM dual
      DETAIL
       log_msg = substring(1,110,log_msg), row + 1, col 0,
       log_type, col 15, log_msg
       IF (log_num < 5000
        AND log_num > 0)
        log_string = notrim(concat(cr,bb," ",trim(log_type)," ",
          trim(log_msg),eb,reol))
       ELSEIF (log_num < 8000
        AND log_num >= 5000)
        log_string = notrim(concat(cu,trim(log_type)," ",trim(log_msg),reol))
       ELSEIF (log_num < 10000
        AND log_num >= 8000)
        log_string = notrim(concat(cb,bi," ",trim(log_type)," ",
          trim(log_msg),ei,reol))
       ENDIF
       IF (log_tablenms > " ")
        temp_tablenms = concat("Table name(s) - ",trim(log_tablenms)), row + 1, col 0,
        temp_tablenms
        IF (log_num < 5000
         AND log_num > 0)
         log_string = notrim(concat(log_string,cr,bb," ",trim(temp_tablenms),
           eb,reol))
        ELSEIF (log_num < 8000
         AND log_num >= 5000)
         log_string = notrim(concat(log_string,cu,trim(temp_tablenms),reol))
        ELSEIF (log_num < 10000
         AND log_num >= 8000)
         log_string = notrim(concat(log_string,cb,bi," ",trim(temp_tablenms),
           ei,reol))
        ENDIF
       ENDIF
       IF (log_offfields > " ")
        temp_offfields = concat("Field value(s) - ",trim(log_offfields)), row + 1, col 0,
        temp_offfields
        IF (log_num < 5000
         AND log_num > 0)
         log_string = notrim(concat(log_string,cr,bb," ",trim(temp_offfields),
           eb,reol))
        ELSEIF (log_num < 8000
         AND log_num >= 5000)
         log_string = notrim(concat(log_string,cu,trim(temp_offfields),reol))
        ELSEIF (log_num < 10000
         AND log_num >= 8000)
         log_string = notrim(concat(log_string,cb,bi," ",trim(temp_offfields),
           ei,reol))
        ENDIF
       ENDIF
       IF (log_rowidents > " ")
        temp_rowidents = concat("Row identifier(s) - ",trim(log_rowidents)), row + 1, col 0,
        temp_rowidents
        IF (log_num < 5000
         AND log_num > 0)
         log_string = notrim(concat(log_string,cr,bb," ",trim(temp_rowidents),
           eb,reol))
        ELSEIF (log_num < 8000
         AND log_num >= 5000)
         log_string = notrim(concat(log_string,cu,trim(temp_rowidents),reol))
        ELSEIF (log_num < 10000
         AND log_num >= 8000)
         log_string = notrim(concat(log_string,cb,bi," ",trim(temp_rowidents),
           ei,reol))
        ENDIF
       ENDIF
       IF (log_cclerrmsg > " ")
        temp_cclerrmsg = concat("CCL error message - ",trim(log_cclerrmsg)), row + 1, col 0,
        temp_cclerrmsg
        IF (log_num < 5000
         AND log_num > 0)
         log_string = notrim(concat(log_string,cr,bb," ",trim(temp_cclerrmsg),
           eb,reol))
        ELSEIF (log_num < 8000
         AND log_num >= 5000)
         log_string = notrim(concat(log_string,cu,trim(temp_cclerrmsg),reol))
        ELSEIF (log_num < 10000
         AND log_num >= 8000)
         log_string = notrim(concat(log_string,cb,bi," ",trim(temp_cclerrmsg),
           ei,reol))
        ENDIF
       ENDIF
       IF (log_addcommts > " ")
        temp_addcommts = concat("Additional Comments - ",trim(log_addcommts)), row + 1, col 0,
        temp_addcommts
        IF (log_num < 5000
         AND log_num > 0)
         log_string = notrim(concat(log_string,cr,bb," ",trim(temp_addcommts),
           eb,reol))
        ELSEIF (log_num < 8000
         AND log_num >= 5000)
         log_string = notrim(concat(log_string,cu,trim(temp_addcommts),reol))
        ELSEIF (log_num < 10000
         AND log_num >= 8000)
         log_string = notrim(concat(log_string,cb,bi," ",trim(temp_addcommts),
           ei,reol))
        ENDIF
       ENDIF
       IF (log_extra1 > " ")
        temp_extra1 = trim(log_extra1), row + 1, col 0,
        temp_extra1
        IF (log_num < 5000
         AND log_num > 0)
         log_string = notrim(concat(log_string,cr,bb," ",trim(temp_extra1),
           eb,reol))
        ELSEIF (log_num < 8000
         AND log_num >= 5000)
         log_string = notrim(concat(log_string,cu,trim(temp_extra1),reol))
        ELSEIF (log_num < 10000
         AND log_num >= 8000)
         log_string = notrim(concat(log_string,cb,bi," ",trim(temp_extra1),
           ei,reol))
        ENDIF
       ENDIF
       IF (log_extra2 > " ")
        temp_extra2 = trim(log_extra2), row + 1, col 0,
        temp_extra2
        IF (log_num < 5000
         AND log_num > 0)
         log_string = notrim(concat(log_string,cr,bb," ",trim(temp_extra2),
           eb,reol))
        ELSEIF (log_num < 8000
         AND log_num >= 5000)
         log_string = notrim(concat(log_string,cu,trim(temp_extra2),reol))
        ELSEIF (log_num < 10000
         AND log_num >= 8000)
         log_string = notrim(concat(log_string,cb,bi," ",trim(temp_extra2),
           ei,reol))
        ENDIF
       ENDIF
       IF (log_res > " ")
        log_res_print = substring(1,130,concat("Resolution - ",log_res)), row + 1, col 0,
        log_res_print
        IF (log_num < 5000
         AND log_num > 0)
         log_string = notrim(concat(log_string,cr,bb," ",trim(log_res_print),
           eb,reol))
        ELSEIF (log_num < 8000
         AND log_num >= 5000)
         log_string = notrim(concat(log_string,cu,trim(log_res_print),reol))
        ELSEIF (log_num < 10000
         AND log_num >= 8000)
         log_string = notrim(concat(log_string,cb,bi," ",trim(log_res_print),
           ei,reol))
        ENDIF
       ENDIF
       IF (log_res2 > " ")
        log_res2_print = substring(1,130,log_res2), row + 1, col 0,
        log_res2_print
        IF (log_num < 5000
         AND log_num > 0)
         log_string = notrim(concat(log_string,cr,bb," ",trim(log_res2_print),
           eb,reol))
        ELSEIF (log_num < 8000
         AND log_num >= 5000)
         log_string = notrim(concat(log_string,cu,trim(log_res2_print),reol))
        ELSEIF (log_num < 10000
         AND log_num >= 8000)
         log_string = notrim(concat(log_string,cb,bi," ",trim(log_res2_print),
           ei,reol))
        ENDIF
       ENDIF
       log_string = notrim(concat(log_string,reol))
      WITH append, nocounter, noformfeed,
       format = variable, maxcol = 300, maxrow = 1
     ;end select
     IF (validate(log_idx,- (1)) > 0
      AND log_num > 0
      AND log_num < 10000)
      SET log_idx_str = trim(cnvtstring(log_idx))
      SET log_parse_str = concat("set ",log_reply,"->qual[",log_idx_str,"]->msg_cnt = ",
       log_reply,"->qual[",log_idx_str,"]->msg_cnt + 1 go")
      CALL parser(log_parse_str)
      SET log_parse_str = concat("set log_msg_cnt = ",log_reply,"->qual[",log_idx_str,"]->msg_cnt go"
       )
      CALL parser(log_parse_str)
      SET log_parse_str = concat("set stat = alterlist(",log_reply,"->qual[",log_idx_str,
       "]->messages, ",
       log_reply,"->qual[",log_idx_str,"]->msg_cnt) go")
      CALL parser(log_parse_str)
      IF (log_num < 5000
       AND log_num > 0)
       SET log_parse_str = concat("set ",log_reply,"->qual[",log_idx_str,"]->messages[",
        log_reply,"->qual[",log_idx_str,"]->msg_cnt]->msg_type_flag = 1 go")
       CALL parser(log_parse_str)
       IF (log_audit)
        SET log_parse_str = concat("set ",log_reply,"->qual[",log_idx_str,"]->success_ind = 2 go")
       ELSE
        SET log_parse_str = concat("set ",log_reply,"->qual[",log_idx_str,"]->success_ind = 0 go")
       ENDIF
       CALL parser(log_parse_str)
      ELSEIF (log_num < 8000
       AND log_num >= 5000)
       SET log_parse_str = concat("set ",log_reply,"->qual[",log_idx_str,"]->messages[",
        log_reply,"->qual[",log_idx_str,"]->msg_cnt]->msg_type_flag = 2 go")
       CALL parser(log_parse_str)
       IF (log_audit)
        SET log_parse_str = concat("set ",log_reply,"->qual[",log_idx_str,"]->success_ind = 5 go")
       ELSE
        SET log_parse_str = concat("set ",log_reply,"->qual[",log_idx_str,"]->success_ind = 4 go")
       ENDIF
       CALL parser(log_parse_str)
      ELSE
       SET log_parse_str = concat("set ",log_reply,"->qual[",log_idx_str,"]->messages[",
        log_reply,"->qual[",log_idx_str,"]->msg_cnt]->msg_type_flag = 3 go")
       CALL parser(log_parse_str)
      ENDIF
      IF (log_msg_cnt=1)
       SET log_string = notrim(concat(rhead,log_string,rtfeof))
      ELSEIF (log_msg_cnt > 1)
       SET log_parse_str = concat("set ",log_reply,"->qual[",log_idx_str,"]->messages[",
        log_reply,"->qual[",log_idx_str,"]->msg_cnt - 1]->msg_string = substring(1, textlen(",
        log_reply,
        "->qual[",log_idx_str,"]->messages[",log_reply,"->qual[",
        log_idx_str,"]->msg_cnt - 1]->msg_string) - 1, ",log_reply,"->qual[",log_idx_str,
        "]->messages[",log_reply,"->qual[",log_idx_str,"]->msg_cnt - 1]->msg_string) go")
       CALL parser(log_parse_str)
       SET log_string = notrim(concat(log_string,rtfeof))
      ENDIF
      SET log_parse_str = concat("set ",log_reply,"->qual[",log_idx_str,"]->messages[",
       log_reply,"->qual[",log_idx_str,"]->msg_cnt]->msg_string = log_string go")
      CALL parser(log_parse_str)
     ENDIF
    ENDIF
    IF (log_contno=1)
     IF (log_num > 0
      AND log_num < 8000)
      IF (validate(reply,0))
       SET reply->status_data.status = "W"
      ENDIF
     ENDIF
     GO TO start_loop
    ELSEIF (log_contno=0)
     IF (log_num > 0
      AND log_num < 8000)
      IF (validate(reply,0))
       SET reply->status_data.status = "F"
      ENDIF
     ENDIF
     GO TO exit_script
    ENDIF
   ELSEIF ((log_num=- (1)))
    SELECT INTO value(logfile_name)
     FROM dual
     DETAIL
      tm = format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"), line = fillstring(90,"*"
       ), logstring = concat(script_name,"  :begin > "),
      col 0, line, row + 1,
      row 0, col 0, logstring,
      col + 2, tm
     WITH append, nocounter, noformfeed,
      format = variable, maxcol = 132, maxrow = 1
    ;end select
    SELECT INTO "nl:"
     di.info_domain, di.info_name, di.info_number
     FROM dm_info di
     WHERE di.info_domain="KNOWLEDGE INDEX APPLICATIONS"
      AND di.info_name="IMPORT DEBUG LEVEL"
     DETAIL
      log_level = di.info_number
     WITH nocounter
    ;end select
    IF (((curqual < 0) OR ( NOT (log_level IN (1, 2, 3)))) )
     SET log_level = 1
    ENDIF
   ELSEIF ((log_num=- (2)))
    SELECT INTO value(logfile_name)
     FROM dual
     DETAIL
      row + 2, col 0, "End   :"
      CASE (reply->status_data.status)
       OF "S":
        col 8,"SUCCESS"
       OF "Z":
        col 8,"SUCCESS"
       OF "W":
        col 8,"WARNING"
       OF "F":
        col 8,"FAILURE"
      ENDCASE
      tm = format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"), col 17, tm
     WITH append, nocounter, noformfeed,
      format = variable, maxcol = 132, maxrow = 1
    ;end select
    IF ((((reply->status_data.status="F")) OR (log_audit=1)) )
     SET reqinfo->commit_ind = 0
    ELSE
     SET reqinfo->commit_ind = 1
    ENDIF
   ELSEIF ((log_num=- (3)))
    SELECT INTO value(logfile_name)
     FROM dual
     DETAIL
      row + 1, col 0, log_extra1,
      row + 2, col 0, log_extra2
     WITH append, nocounter, noformfeed,
      format = variable, maxcol = 132, maxrow = 1
    ;end select
   ELSEIF ((log_num=- (4)))
    IF (validate(log_idx,- (1)) > 0)
     SET log_idx_str = trim(cnvtstring(log_idx))
     IF (log_audit)
      SET log_parse_str = concat("set ",log_reply,"->qual[",log_idx_str,"]->success_ind = 3 go")
     ELSE
      SET log_parse_str = concat("set ",log_reply,"->qual[",log_idx_str,"]->success_ind = 1 go")
     ENDIF
     CALL parser(log_parse_str)
    ENDIF
   ELSEIF ((log_num=- (5)))
    SELECT INTO value(logfile_name)
     FROM dual
     DETAIL
      row + 1, col 0, log_extra1,
      row + 1, col 0, log_rowidents,
      row + 1, col 0, log_extra2
     WITH append, nocounter, noformfeed,
      format = variable, maxcol = 256, maxrow = 1
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE insert_log_tables(vlog_type,vlog_msg,vlog_msgparams,vlog_tablenms,vlog_offfields,
  vlog_rowidents,vlog_cclerrmsg,vlog_addcommts,vlog_extra1,vlog_extra2,vlog_res)
  DECLARE start_rec = i4 WITH public, noconstant(0)
  IF (validate(kia_pkg_nbr,9) != 9)
   IF (validate(kia_rdm_nbr,9) != 9)
    SELECT INTO "nl:"
     FROM dprotect d
     WHERE d.object="T"
      AND d.object_name="KIA_RMS_LOG"
     WITH nocounter
    ;end select
    IF (curqual < 1)
     SELECT INTO TABLE "KIA_RMS_LOG"
      block_size = 0, cmt_import_log_id = 0.0, end_dt_tm = format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"),
      input_filename = fillstring(50," "), logfile_name = fillstring(50," "), log_level = 0,
      package_nbr = 0, readme = 0, script_name = fillstring(35," "),
      start_dt_tm = format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"), start_record = 0, status_flag = 0,
      updt_applctx = 0, updt_cnt = 0, updt_dt_tm = format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"),
      updt_id = 0.0, updt_task = 0
      WITH nocounter
     ;end select
    ENDIF
    SELECT INTO "nl:"
     FROM kia_rms_log k
     WHERE k.cmt_import_log_id=kia_cmt_log_id
     WITH nocounter
    ;end select
    IF (curqual < 1)
     IF ((validate(dm_dbi_start_row,- (1))=- (1)))
      SET start_rec = 0
     ELSE
      SET start_rec = dm_dbi_start_row
     ENDIF
     SELECT INTO TABLE "KIA_RMS_LOG"
      block_size = kia_parse_blocks, cmt_import_log_id = kia_cmt_log_id, end_dt_tm = format(sysdate,
       "dd-mmm-yyyy hh:mm:ss;;d"),
      input_filename = substring(1,50,kia_rdm_input_name), logfile_name = substring(1,50,logfile_name
       ), log_level = log_level,
      package_nbr = kia_pkg_nbr, readme = kia_rdm_nbr, script_name = substring(1,35,script_name),
      start_dt_tm = format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"), start_record = start_rec, status_flag
       = 0,
      updt_applctx = reqinfo->updt_applctx, updt_cnt = 0, updt_dt_tm = format(sysdate,
       "dd-mmm-yyyy hh:mm:ss;;d"),
      updt_id = reqinfo->updt_id, updt_task = reqinfo->updt_task
      WITH nocounter, append
     ;end select
    ENDIF
    DECLARE log_seq_cnt = i4
    DECLARE param_msg = vc
    SET log_seq_cnt = 0
    SET param_msg = concat(trim(vlog_type),trim(vlog_msg))
    CALL insert_cilm(param_msg,log_seq_cnt)
    IF (vlog_tablenms > " ")
     SET param_msg = concat("Table name(s) - ",trim(vlog_tablenms))
     SET log_seq_cnt = (log_seq_cnt+ 1)
     CALL insert_cilm(param_msg,log_seq_cnt)
    ENDIF
    IF (vlog_offfields > " ")
     SET param_msg = concat("Field value(s) - ",trim(vlog_offfields))
     SET log_seq_cnt = (log_seq_cnt+ 1)
     CALL insert_cilm(param_msg,log_seq_cnt)
    ENDIF
    IF (vlog_rowidents > " ")
     SET param_msg = concat("Row identifier(s) - ",trim(vlog_rowidents))
     SET log_seq_cnt = (log_seq_cnt+ 1)
     CALL insert_cilm(param_msg,log_seq_cnt)
    ENDIF
    IF (vlog_addcommts > " ")
     SET param_msg = concat("Additional Comments - ",trim(vlog_addcommts))
     SET log_seq_cnt = (log_seq_cnt+ 1)
     CALL insert_cilm(param_msg,log_seq_cnt)
    ENDIF
    IF (vlog_cclerrmsg > " ")
     SET param_msg = concat("CCL error message - ",trim(vlog_cclerrmsg))
     SET log_seq_cnt = (log_seq_cnt+ 1)
     CALL insert_cilm(param_msg,log_seq_cnt)
    ENDIF
    IF (vlog_extra1 > " ")
     SET param_msg = trim(vlog_extra1)
     SET log_seq_cnt = (log_seq_cnt+ 1)
     CALL insert_cilm(param_msg,log_seq_cnt)
    ENDIF
    IF (vlog_extra2 > " ")
     SET param_msg = trim(log_extra2)
     SET log_seq_cnt = (log_seq_cnt+ 1)
     CALL insert_cilm(param_msg,log_seq_cnt)
    ENDIF
    IF (vlog_res > " ")
     SET param_msg = concat("Resolution - ",trim(vlog_res))
     SET log_seq_cnt = (log_seq_cnt+ 1)
     CALL insert_cilm(param_msg,log_seq_cnt)
    ENDIF
    SET kia_rdm_err_cnt = (kia_rdm_err_cnt+ 1)
    IF ((log_num=- (2)))
     FREE DEFINE kia_rms_log
     DEFINE kia_rms_log  WITH modify
     UPDATE  FROM kia_rms_log k
      SET k.status_flag =
       IF ((reply->status_data.status="S")) 0
       ELSEIF ((reply->status_data.status="W")) 1
       ELSEIF ((reply->status_data.status="F")) 2
       ELSE 3
       ENDIF
       , k.end_dt_tm = sysdate, k.updt_dt_tm = sysdate,
       k.updt_cnt = (k.updt_cnt+ 1)
      WHERE k.cmt_log_id=kia_cmt_log_id
      WITH nocounter
     ;end update
    ENDIF
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE insert_cilm(param_msg,log_seq_cnt)
   DECLARE next_seq_num = f8
   SET next_seq_num = kia_log_next_seq(next_seq_num)
   SELECT INTO "nl:"
    FROM dprotect d
    WHERE d.object="T"
     AND d.object_name="KIA_RMS_MSG"
    WITH nocounter
   ;end select
   IF (curqual < 1)
    SELECT INTO TABLE "KIA_RMS_MSG"
     cmt_import_log_id = 0.0, cmt_import_log_msg_id = 0.0, log_instance = 0,
     log_message = fillstring(250," "), log_seq = 0, updt_applctx = 0,
     updt_cnt = 0, updt_dt_tm = format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"), updt_id = 0.0,
     updt_task = 0
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO TABLE "KIA_RMS_MSG"
    cmt_import_log_id = kia_cmt_log_id, cmt_import_log_msg_id = next_seq_num, log_instance =
    kia_rdm_err_cnt,
    log_message = substring(1,250,param_msg), log_seq = log_seq_cnt, updt_applctx = 0,
    updt_cnt = 0, updt_dt_tm = format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"), updt_id = 0.0,
    updt_task = 0
    WITH nocounter, append
   ;end select
 END ;Subroutine
 SUBROUTINE kia_log_next_seq(kia_log_next_seq)
   DECLARE kia_log_next_seq1 = f8
   SET kia_log_next_seq1 = 0.0
   SELECT INTO "nl:"
    nval = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     kia_log_next_seq1 = nval
    WITH format, counter
   ;end select
   IF (curqual=0)
    CALL logging(5,"","DUAL","Sequence: NOMENCLATURE_SEQ","",
     "","","","",0)
   ELSE
    RETURN(kia_log_next_seq1)
   ENDIF
 END ;Subroutine
 SUBROUTINE log_echo(echo_msg)
   IF (log_level > 1)
    CALL echo(echo_msg)
   ENDIF
 END ;Subroutine
 SUBROUTINE kia_chk_oracle_err(kia_tbl,kia_type)
   FREE SET kia_type_str
   FREE SET find_pos
   FREE SET ora_err_num
   FREE SET ora_err_msg
   DECLARE kia_type_str = vc WITH public, noconstant("")
   DECLARE find_pos = i2 WITH public, noconstant(0)
   DECLARE ora_err_num = vc WITH public, noconstant("")
   DECLARE ora_err_msg = vc WITH public, noconstant("")
   IF ((validate(err_num,- (1))=- (1)))
    DECLARE err_num = i4 WITH public, noconstant(0)
   ENDIF
   IF (validate(err_msg,"z")="z")
    DECLARE err_msg = vc WITH public, noconstant("")
   ENDIF
   CASE (kia_type)
    OF "U":
     SET kia_type_str = "UPDATE"
    OF "I":
     SET kia_type_str = "INSERT"
    OF "D":
     SET kia_type_str = "DELETE"
    ELSE
     SET kia_type_str = "-"
   ENDCASE
   SET err_num = error(err_msg,0)
   IF (err_num > 0)
    CALL echo("*************************************************************")
    CALL echo("*************************************************************")
    CALL echo("*************************************************************")
    CALL echo(concat("--- ERRORS FOUND DURING ",kia_type_str," ---"))
    CALL echo(build("ERROR NUMBER:",err_num))
    CALL echo(build("ERROR MSG:",err_msg))
    CALL echo("*************************************************************")
    CALL echo("*************************************************************")
    CALL echo("*************************************************************")
    SET find_pos = findstring("ORA-",err_msg,1,0)
    SET ora_err_num = substring((find_pos+ 4),5,err_msg)
    SET ora_err_msg = substring((find_pos+ 11),size(err_msg),err_msg)
    SET ora_err_msg = replace(ora_err_msg,char(10),"",0)
    CALL logging(- (5),"","","",concat("FAILURE --- ORACLE ERROR NUMBER: ",ora_err_num),
     "","",concat(kia_tbl," - FAILED DURING ",kia_type_str),substring(1,255,ora_err_msg),0)
    SET reply->status_data.status = "F"
    SET readme_data->status = "F"
    SET readme_data->message = concat("FAILED - ",substring(1,245,ora_err_msg))
    GO TO exit_script
   ENDIF
 END ;Subroutine
 IF (validate(readme_data,"0")="0")
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
  SET kia_notreadme = 1
 ENDIF
 DECLARE temp_logfile = vc WITH private, noconstant("")
 DECLARE temp_mean = vc WITH public, noconstant("")
 DECLARE script_name = vc WITH public, constant("ecf_rdm_nomenclature_ext_load")
 DECLARE log_level = i2 WITH public, noconstant(0)
 DECLARE log_audit = i2 WITH public, noconstant(0)
 DECLARE err_msg = vc WITH public, noconstant("")
 DECLARE err_num = i2 WITH public, noconstant(0)
 DECLARE active_status_cd = f8 WITH public, noconstant(0.0)
 DECLARE data_status_cd = f8 WITH public, noconstant(0.0)
 DECLARE lang_cd = f8 WITH public, noconstant(0.0)
 DECLARE nomen_id = f8 WITH public, noconstant(0.0)
 DECLARE exit_flag = i2 WITH public, noconstant(0)
 DECLARE miss_code = vc WITH public, noconstant("")
 DECLARE insert_counter = i4 WITH public, noconstant(0)
 DECLARE updates_cnt = i4 WITH public, noconstant(0)
 DECLARE update_1needed = i2 WITH public, constant(1)
 DECLARE update_2needed = i2 WITH public, constant(2)
 DECLARE update_3needed = i2 WITH public, constant(3)
 DECLARE row_update1 = i2 WITH public, noconstant(false)
 DECLARE row_update2 = i2 WITH public, noconstant(false)
 DECLARE row_update3 = i2 WITH public, noconstant(false)
 DECLARE kia_vocabulary_mean = vc WITH public, noconstant(cnvtupper(trim( $1)))
 DECLARE kia_table_name = vc WITH public, constant("NOMENCLATURE_EXT_LOAD")
 SET reply->status_data.status = "F"
 SET readme_data->status = "F"
 SET readme_data->message = "FAILED - ECF_RDM_NOMENCLATURE_EXT_LOAD IMPORT"
 SELECT INTO "nl:"
  FROM (value(kia_table_name) nr)
  WHERE cnvtupper(nr.source_vocabulary_mean)=kia_vocabulary_mean
  DETAIL
   temp_mean = nr.source_vocabulary_mean
  WITH nocounter, maxqual(nr,1)
 ;end select
 IF (curqual < 1)
  CALL echo(concat("NO RECORDS IN LOAD TABLE WITH VOCABULARY_MEAN = ",kia_vocabulary_mean))
  CALL echo(concat("NO RECORDS IN LOAD TABLE WITH VOCABULARY_MEAN = ",kia_vocabulary_mean))
  CALL echo(concat("NO RECORDS IN LOAD TABLE WITH VOCABULARY_MEAN = ",kia_vocabulary_mean))
  SET reply->status_data.status = "F"
  SET readme_data->status = "F"
  SET readme_data->message =
  "FAILED - ECF_RDM_NOMENCLATURE_EXT_LOAD - INVALID SOURCE_VOCABULARY_MEAN"
  DECLARE logfile_name = vc WITH public, constant("ecf_rdm_nomenclature_ext_load.log")
  CALL logging(- (1),"","","","",
   "","","","",0)
  CALL logging(2,"0","CODE_VALUE",concat("source_vocab_mean = ",kia_vocabulary_mean),"Code Set: 400",
   "","","","",0)
  GO TO exit_script
 ENDIF
 SET temp_mean = replace(temp_mean,".","",0)
 SET temp_logfile = concat("kia_load_",trim(cnvtlower(temp_mean)),"_nomen_ext_2.log")
 DECLARE logfile_name = vc WITH public, constant(trim(temp_logfile))
 CALL logging(- (1),"","","","",
  "","","","",0)
 SET timer2->start = cnvtdatetime(curdate,curtime3)
 CALL echo(concat("UPDATING SOURCE_VOCAB_CD's on ",kia_table_name," table"))
 SET miss_code = ""
 SELECT INTO "nl:"
  FROM (value(kia_table_name) n)
  WHERE  NOT ( EXISTS (
  (SELECT
   c.cdf_meaning
   FROM code_value c
   WHERE c.active_ind=1
    AND c.code_set=400
    AND c.end_effective_dt_tm > cnvtdatetime("30-DEC-2100")
    AND c.cdf_meaning=n.source_vocabulary_mean)))
   AND  NOT (n.source_vocabulary_mean IN ("", " "))
   AND n.source_vocabulary_mean IS NOT null
   AND n.source_vocabulary_cd < 1
  DETAIL
   miss_code = n.source_vocabulary_mean
  WITH nocounter
 ;end select
 IF (curqual > 0)
  CALL echo(concat("FAILED - MISSING CODE_VALUE ON CODE_SET 400:",miss_code))
  CALL echo(concat("FAILED - MISSING CODE_VALUE ON CODE_SET 400:",miss_code))
  CALL echo(concat("FAILED - MISSING CODE_VALUE ON CODE_SET 400:",miss_code))
  SET readme_data->message = concat("FAILED - MISSING CODE_VALUE ON CODE_SET 400:",miss_code)
  CALL logging(2,"","CODE_VALUE",concat("source_vocab_mean = ",miss_code),"Code Set: 400",
   "","","","",0)
  GO TO exit_script
 ENDIF
 UPDATE  FROM (value(kia_table_name) n)
  SET n.source_vocabulary_cd =
   (SELECT
    c.code_value
    FROM code_value c
    WHERE c.code_set=400
     AND c.cdf_meaning=n.source_vocabulary_mean
     AND c.active_ind=1
     AND c.end_effective_dt_tm > cnvtdatetime("30-DEC-2100")
    WITH maxqual(c,1))
  WHERE n.source_vocabulary_cd < 1
   AND n.source_vocabulary_mean=kia_vocabulary_mean
  WITH nocounter
 ;end update
 CALL kia_chk_oracle_err(cnvtupper(kia_table_name),"U")
 COMMIT
 CALL echo(concat("UPDATING EXTENSION_TYPE_CD's on ",kia_table_name," table"))
 SET miss_code = ""
 SELECT INTO "nl:"
  FROM (value(kia_table_name) n)
  WHERE  NOT ( EXISTS (
  (SELECT
   c.cdf_meaning
   FROM code_value c
   WHERE c.active_ind=1
    AND c.code_set=29746
    AND c.end_effective_dt_tm > cnvtdatetime("30-DEC-2100")
    AND c.cdf_meaning=n.extension_type_mean)))
   AND  NOT (n.extension_type_mean IN ("", " "))
   AND n.extension_type_mean IS NOT null
  DETAIL
   miss_code = n.extension_type_mean
  WITH nocounter
 ;end select
 IF (curqual > 0)
  CALL echo(concat("FAILED - MISSING CODE_VALUE ON CODE_SET 29746:",miss_code))
  CALL echo(concat("FAILED - MISSING CODE_VALUE ON CODE_SET 29746:",miss_code))
  CALL echo(concat("FAILED - MISSING CODE_VALUE ON CODE_SET 29746:",miss_code))
  SET readme_data->message = concat("FAILED - MISSING CODE_VALUE ON CODE_SET 29746:",miss_code)
  CALL logging(2,"","CODE_VALUE",concat("extension_type_mean = ",miss_code),"Code Set: 29746",
   "","","","",0)
  GO TO exit_script
 ENDIF
 UPDATE  FROM (value(kia_table_name) n)
  SET n.extension_type_cd =
   (SELECT
    c.code_value
    FROM code_value c
    WHERE c.code_set=29746
     AND c.cdf_meaning=n.extension_type_mean
     AND c.active_ind=1
     AND c.end_effective_dt_tm > cnvtdatetime("30-DEC-2100")
    WITH maxqual(c,1))
  WHERE  NOT (n.extension_type_mean IN ("", " "))
   AND n.extension_type_mean IS NOT null
   AND n.extension_type_cd < 1
   AND n.source_vocabulary_mean=kia_vocabulary_mean
  WITH nocounter
 ;end update
 CALL kia_chk_oracle_err(cnvtupper(kia_table_name),"U")
 COMMIT
 SET timer2->stop = cnvtdatetime(curdate,curtime3)
 CALL echo(build("UPDATE _CD'S on NOMENCLATURE_EXT_LOAD - Time(secs):",datetimediff(timer2->stop,
    timer2->start,5)))
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
   AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND cnvtdatetime(curdate,curtime3) < cv.end_effective_dt_tm
  DETAIL
   active_status_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual < 1)
  CALL logging(2,cnvtstring(active_status_cd),"CODE_VALUE","active_status_mean = ACTIVE",
   "Code Set: 48; cdf_meaning: ACTIVE",
   "","","","",0)
 ENDIF
 SET timer2->stop = cnvtdatetime(curdate,curtime3)
 CALL logging(0,"","","","",
  "","",build("Script Initialize time(secs):",datetimediff(timer2->stop,timer2->start,5)),"",- (1))
 CALL echo(build("Script Initialize Time (seconds):",datetimediff(timer2->stop,timer2->start,5)))
 SET kia_more_inserts = true
 SET kia_insert_cnt = 0
 WHILE (kia_more_inserts=true
  AND kia_insert_cnt < 300)
   SET kia_insert_cnt = (kia_insert_cnt+ 1)
   CALL echo(build("SET THE ACTION_FLAG = 0 TO PROCESS THE DATA --- GROUP:",kia_insert_cnt))
   UPDATE  FROM (value(kia_table_name) n)
    SET n.action_flag = 0, n.updt_cnt = (n.updt_cnt+ 1), n.updt_dt_tm = cnvtdatetime(curdate,curtime3
      ),
     n.updt_task = reqinfo->updt_task
    WHERE ((n.action_flag != 0) OR (n.action_flag IN (null)
     AND n.source_vocabulary_mean=kia_vocabulary_mean))
    WITH nocounter, maxqual(n,25000)
   ;end update
   IF (curqual < 25000)
    SET kia_more_inserts = false
   ENDIF
   CALL kia_chk_oracle_err(cnvtupper(kia_table_name),"U")
   COMMIT
 ENDWHILE
 SET timer2->start = cnvtdatetime(curdate,curtime3)
 CALL echo("DELETING ROWS FROM NOMENCLATURE_EXT TABLE...")
 DELETE  FROM nomenclature_ext n
  WHERE n.source_vocabulary_cd IN (
  (SELECT
   code_value
   FROM code_value
   WHERE cdf_meaning="LOINC"
    AND code_set=400
    AND active_ind=1))
   AND n.extension_type_cd IN (
  (SELECT
   code_value
   FROM code_value
   WHERE cdf_meaning="LONG_SRC_STR"
    AND code_set=29746
    AND active_ind=1))
  WITH nocounter
 ;end delete
 CALL kia_chk_error(1)
 CALL echo("INSERTING new rows into NOMENCLATURE_EXT table...")
 INSERT  FROM nomenclature_ext n
  (n.active_ind, n.active_status_cd, n.active_status_dt_tm,
  n.active_status_prsnl_id, n.source_identifier, n.source_vocabulary_cd,
  n.beg_effective_dt_tm, n.end_effective_dt_tm, n.nomenclature_ext_id,
  n.extension_data_type_flag, n.extension_type_cd, n.extension_value,
  n.updt_applctx, n.updt_cnt, n.updt_dt_tm,
  n.updt_id, n.updt_task)(SELECT
   x.active_ind, active_status_cd, cnvtdatetime(curdate,curtime3),
   0.0, x.source_identifier, x.source_vocabulary_cd,
   x.beg_effective_dt_tm, x.end_effective_dt_tm, seq(nomenclature_seq,nextval),
   x.extension_data_type_flag, x.extension_type_cd, x.extension_value,
   0, 0, cnvtdatetime(curdate,curtime3),
   reqinfo->updt_task, 0.0
   FROM (value(kia_table_name) x)
   WHERE x.source_vocabulary_mean=kia_vocabulary_mean
    AND x.action_flag=0
   WITH nocounter)
  WITH nocounter
 ;end insert
 CALL kia_chk_oracle_err("NOMENCLATURE_EXT TABLE LOAD","I")
 COMMIT
 CALL echo("UPDATE ACTION_FLAG = 4 for this group of records processed")
 UPDATE  FROM (value(kia_table_name) n)
  SET n.action_flag = 4, n.updt_cnt = (n.updt_cnt+ 1), n.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   n.updt_task = reqinfo->updt_task
  WHERE n.action_flag=0
   AND n.source_vocabulary_mean=kia_vocabulary_mean
 ;end update
 CALL kia_chk_oracle_err("NOMENCLATURE_EXT","U")
 COMMIT
 IF ((reply->status_data.status != "W"))
  SET reply->status_data.status = "S"
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "SUCCESS - ECF_RDM_NOMENCLATURE_EXT_LOAD"
#exit_script
 SET timer->stop = cnvtdatetime(curdate,curtime3)
 CALL logging(0,"","","","",
  "","",build("Script Elapsed Time(seconds):",datetimediff(timer->stop,timer->start,5)),"",- (1))
 SET kia_version = "29-DEC-2020"
 EXECUTE dm_readme_status
 CALL logging(- (2),"","","","",
  "","","","",0)
END GO
