CREATE PROGRAM ams_carenet_task_pos_del:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Directory" = "",
  "Pass Input File Name" = ""
  WITH outdev, directory, inputfile
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 FREE SET request_del
 RECORD request_del(
   1 reference_task_id = f8
   1 delqual[*]
     2 position_cd = f8
 )
 SET path = value(logical( $DIRECTORY))
 SET infile =  $INPUTFILE
 SET file_path = build(path,":",infile)
 CALL echo(build(path,":",infile))
 CALL echo(file_path)
 DEFINE rtl2 value(file_path)
 RECORD file_content(
   1 line[*]
     2 col[*]
       3 value = vc
 )
 SELECT
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, stat = alterlist(file_content->line,10)
  DETAIL
   line1 = r.line
   IF (size(trim(line1),1) > 0)
    row_count = (row_count+ 1)
    IF (mod(row_count,10)=1
     AND row_count > 10)
     stat = alterlist(file_content->line,(row_count+ 9))
    ENDIF
    stat = alterlist(file_content->line[row_count].col,10), count = 0
    WHILE (size(trim(line1),1) > 0)
      count = (count+ 1)
      IF (count > 10
       AND mod(count,10)=1)
       stat = alterlist(file_content->line[row_count].col,(count+ 9))
      ENDIF
      position = findstring(",",line1,1,0)
      IF (position > 0)
       file_content->line[row_count].col[count].value = substring(1,(position - 1),line1), line1 =
       substring((position+ 1),size(trim(line1),1),line1)
      ELSE
       file_content->line[row_count].col[count].value = line1, line1 = ""
      ENDIF
    ENDWHILE
    stat = alterlist(file_content->line[row_count].col,count)
   ENDIF
  FOOT REPORT
   stat = alterlist(file_content->line,row_count)
  WITH format, separator = " "
 ;end select
 SET stat = alterlist(request_del->delqual,1)
 FOR (i = 1 TO size(file_content->line[1],5))
   SET request_del->reference_task_id = cnvtreal(file_content->line[i].col[1].value)
   SET request_del->delqual[1].position_cd = cnvtreal(file_content->line[i].col[2].value)
   EXECUTE orm_del_pos_order_task  WITH replace("REQUEST","REQUEST_DEL")
 ENDFOR
 CALL echorecord(request_del)
 SELECT INTO "NL:"
  FROM dummyt d1
  DETAIL
   col 0, "Completed Successfully"
  WITH nocounter
 ;end select
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
 SET last_mod = "06/23/14 Pavan P S    Initial Release"
END GO
