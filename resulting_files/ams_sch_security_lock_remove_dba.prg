CREATE PROGRAM ams_sch_security_lock_remove:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Type to Add" = 1,
  "Directory" = ""
  WITH outdev, typesel, directory
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
 FREE SET request
 RECORD request(
   1 call_echo_ind = i2
   1 allow_partial_ind = i2
   1 qual[*]
     2 security_id = f8
     2 version_dt_tm = di8
     2 sec_type_cd = f8
     2 sec_type_meaning = c12
     2 parent1_table = c32
     2 parent1_id = f8
     2 parent1_meaning = c12
     2 display1_table = c32
     2 display1_id = f8
     2 display1_meaning = c12
     2 data1_source_cd = f8
     2 data1_source_meaning = c12
     2 parent2_table = c32
     2 parent2_id = f8
     2 parent2_meaning = c12
     2 display2_table = c32
     2 display2_id = f8
     2 display2_meaning = c12
     2 data2_source_cd = f8
     2 data2_source_meaning = c12
     2 parent3_table = c32
     2 parent3_id = f8
     2 parent3_meaning = c12
     2 display3_table = c32
     2 display3_id = f8
     2 display3_meaning = c12
     2 data3_source_cd = f8
     2 data3_source_meaning = c12
     2 lock_table = c32
     2 lock_id = f8
     2 lock_meaning = c12
     2 updt_cnt = i4
     2 action = i2
     2 force_updt_ind = i2
     2 version_ind = i2
     2 active_status_cd = f8
     2 active_ind = i2
     2 candidate_id = f8
 )
 SET path = value(logical( $DIRECTORY))
 SET infile =  $INPUTFILE
 SET file_path = build(path,":",infile)
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
 DECLARE k = i2
 SET stat = alterlist(request->qual,(size(file_content->line[1],5) * size(file_content->line[2],5)))
 IF (( $TYPESEL=1))
  FOR (i = 1 TO size(file_content->line[1],5))
    FOR (j = 1 TO size(file_content->line[2],5))
      CALL echo(build2("parent1_Id:",file_content->line[i].col[1].value))
      SET k = (k+ 1)
      SET request->qual[k].sec_type_cd = 625986.00
      SET request->qual[k].sec_type_meaning = "APPTTYPE"
      SET request->qual[k].parent1_table = "CODE_VALUE"
      SET request->qual[k].parent1_id = value(uar_get_code_by("DISPLAYKEY",14230,file_content->line[i
        ].col[1].value))
      SET request->qual[k].parent1_meaning = ""
      SET request->qual[k].display1_table = "CODE_VALUE"
      SET request->qual[k].display1_id = value(uar_get_code_by("DISPLAYKEY",14249,file_content->line[
        i].col[1].value))
      SET request->qual[k].display1_meaning = ""
      SET request->qual[k].data1_source_cd = 625815.00
      SET request->qual[k].data1_source_meaning = "APPTTYPE"
      CALL echo(build2("parent2_Id:",file_content->line[j].col[2].value))
      SET request->qual[k].parent2_table = "CODE_VALUE"
      SET request->qual[k].parent2_id = uar_get_code_by("DISPLAYKEY",16166,file_content->line[j].col[
       2].value)
      SET request->qual[k].parent2_meaning = file_content->line[j].col[2].value
      SET request->qual[k].display2_table = "CODE_VALUE"
      SET request->qual[k].display2_id = uar_get_code_by("DISPLAYKEY",16166,file_content->line[j].
       col[2].value)
      SET request->qual[k].display2_meaning = file_content->line[j].col[2].value
      SET request->qual[k].data2_source_cd = 625834.00
      SET request->qual[k].data2_source_meaning = uar_get_code_meaning(625834.00)
      SET request->qual[k].parent3_table = ""
      SET request->qual[k].parent3_id = 0.00
      SET request->qual[k].parent3_meaning = ""
      SET request->qual[k].display3_table = ""
      SET request->qual[k].display3_id = 0.00
      SET request->qual[k].display3_meaning = ""
      SET request->qual[k].data3_source_cd = 0.00
      SET request->qual[k].data3_source_meaning = ""
      SET request->qual[k].lock_table = "SCH_OBJECT"
      SET request->qual[k].lock_id = cnvtreal(file_content->line[1].col[3].value)
      SET request->qual[k].lock_meaning = ""
      SET request->qual[k].action = 3
    ENDFOR
  ENDFOR
  SELECT INTO "nl:"
   FROM sch_security s,
    (dummyt d  WITH seq = value(size(request->qual,5)))
   PLAN (d)
    JOIN (s
    WHERE (s.parent1_id=request->qual[d.seq].parent1_id)
     AND (s.parent2_id=request->qual[d.seq].parent2_id)
     AND (s.lock_id=request->qual[d.seq].lock_id)
     AND (s.sch_type_meaning=request->qual[d.seq].sec_type_meaning))
   DETAIL
    request->qual[d.seq].security_id = s.security_id, col 0, "Succesfully Completed"
   WITH nocounter
  ;end select
  CALL echorecord(request)
  EXECUTE sch_chgw_security
 ELSEIF (( $TYPESEL=2))
  FOR (i = 1 TO size(file_content->line[1],5))
    FOR (j = 1 TO size(file_content->line[2],5))
      CALL echo(build2("parent1_Id:",file_content->line[i].col[1].value))
      SET k = (k+ 1)
      SET request->qual[k].sec_type_cd = 625982.00
      SET request->qual[k].sec_type_meaning = "APPTBOOK"
      SET request->qual[k].parent1_table = "SCH_APPT_BOOK"
      SET request->qual[k].parent1_id = cnvtreal(file_content->line[i].col[1].value)
      SET request->qual[k].parent1_meaning = ""
      SET request->qual[k].display1_table = "SCH_APPT_BOOK"
      SET request->qual[k].display1_id = cnvtreal(file_content->line[i].col[1].value)
      SET request->qual[k].display1_meaning = ""
      SET request->qual[k].data1_source_cd = 625814.00
      SET request->qual[k].data1_source_meaning = "APPTBOOK"
      CALL echo(build2("parent2_Id:",file_content->line[j].col[2].value))
      SET request->qual[k].parent2_table = "CODE_VALUE"
      SET request->qual[k].parent2_id = uar_get_code_by("DISPLAYKEY",16166,file_content->line[j].col[
       2].value)
      SET request->qual[k].parent2_meaning = file_content->line[j].col[2].value
      SET request->qual[k].display2_table = "CODE_VALUE"
      SET request->qual[k].display2_id = uar_get_code_by("DISPLAYKEY",16166,file_content->line[j].
       col[2].value)
      SET request->qual[k].display2_meaning = file_content->line[j].col[2].value
      SET request->qual[k].data2_source_cd = 625834.00
      SET request->qual[k].data2_source_meaning = uar_get_code_meaning(625834.00)
      SET request->qual[k].parent3_table = ""
      SET request->qual[k].parent3_id = 0.00
      SET request->qual[k].parent3_meaning = ""
      SET request->qual[k].display3_table = ""
      SET request->qual[k].display3_id = 0.00
      SET request->qual[k].display3_meaning = ""
      SET request->qual[k].data3_source_cd = 0.00
      SET request->qual[k].data3_source_meaning = ""
      SET request->qual[k].lock_table = "SCH_OBJECT"
      SET request->qual[k].lock_id = cnvtreal(file_content->line[1].col[3].value)
      SET request->qual[k].lock_meaning = ""
      SET request->qual[k].action = 1
    ENDFOR
  ENDFOR
  SELECT INTO "nl:"
   FROM sch_security s,
    (dummyt d  WITH seq = value(size(request->qual,5)))
   PLAN (d)
    JOIN (s
    WHERE (s.parent1_id=request->qual[d.seq].parent1_id)
     AND (s.parent2_id=request->qual[d.seq].parent2_id)
     AND (s.lock_id=request->qual[d.seq].lock_id)
     AND (s.sch_type_meaning=request->qual[d.seq].sec_type_meaning))
   DETAIL
    request->qual[d.seq].security_id = s.security_id
   WITH nocounter
  ;end select
  CALL echorecord(request)
  EXECUTE sch_chgw_security
 ELSEIF (( $TYPESEL=3))
  FOR (i = 1 TO size(file_content->line[1],5))
    FOR (j = 1 TO size(file_content->line[2],5))
      CALL echo(build2("parent1_Id:",file_content->line[i].col[1].value))
      SET k = (k+ 1)
      SET request->qual[k].sec_type_cd = 625998.00
      SET request->qual[k].sec_type_meaning = "RESOURCE"
      SET request->qual[k].parent1_table = "CODE_VALUE"
      SET request->qual[k].parent1_id = value(uar_get_code_by("DISPLAYKEY",14231,file_content->line[i
        ].col[1].value))
      SET request->qual[k].parent1_meaning = ""
      SET request->qual[k].display1_table = "CODE_VALUE"
      SET request->qual[k].display1_id = value(uar_get_code_by("DISPLAYKEY",14231,file_content->line[
        i].col[1].value))
      SET request->qual[k].display1_meaning = ""
      SET request->qual[k].data1_source_cd = 625832.00
      SET request->qual[k].data1_source_meaning = "RESOURCE"
      CALL echo(build2("parent2_Id:",file_content->line[j].col[2].value))
      SET request->qual[k].parent2_table = "CODE_VALUE"
      SET request->qual[k].parent2_id = uar_get_code_by("DISPLAYKEY",16166,file_content->line[j].col[
       2].value)
      SET request->qual[k].parent2_meaning = file_content->line[j].col[2].value
      SET request->qual[k].display2_table = "CODE_VALUE"
      SET request->qual[k].display2_id = uar_get_code_by("DISPLAYKEY",16166,file_content->line[j].
       col[2].value)
      SET request->qual[k].display2_meaning = file_content->line[j].col[2].value
      SET request->qual[k].data2_source_cd = 625834.00
      SET request->qual[k].data2_source_meaning = uar_get_code_meaning(625834.00)
      SET request->qual[k].parent3_table = ""
      SET request->qual[k].parent3_id = 0.00
      SET request->qual[k].parent3_meaning = ""
      SET request->qual[k].display3_table = ""
      SET request->qual[k].display3_id = 0.00
      SET request->qual[k].display3_meaning = ""
      SET request->qual[k].data3_source_cd = 0.00
      SET request->qual[k].data3_source_meaning = ""
      SET request->qual[k].lock_table = "SCH_OBJECT"
      SET request->qual[k].lock_id = cnvtreal(file_content->line[1].col[3].value)
      SET request->qual[k].lock_meaning = ""
      SET request->qual[k].action = 1
    ENDFOR
  ENDFOR
  SELECT INTO "nl:"
   FROM sch_security s,
    (dummyt d  WITH seq = value(size(request->qual,5)))
   PLAN (d)
    JOIN (s
    WHERE (s.parent1_id=request->qual[d.seq].parent1_id)
     AND (s.parent2_id=request->qual[d.seq].parent2_id)
     AND (s.lock_id=request->qual[d.seq].lock_id)
     AND (s.sch_type_meaning=request->qual[d.seq].sec_type_meaning))
   DETAIL
    request->qual[d.seq].security_id = s.security_id, col 0, "Succesfully Completed"
   WITH nocounter
  ;end select
  CALL echorecord(request)
  EXECUTE sch_chgw_security
 ENDIF
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
