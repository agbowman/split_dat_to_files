CREATE PROGRAM ams_auto_add_problem_driver:dba
 PROMPT
  "Enter the Problem Source String" = 0,
  "Directory" = "",
  "Pass Input File Name" = ""
  WITH source_string, directory, inputfile
 SET exe_error = 10
 SET failed = false
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 FREE RECORD temp_person
 RECORD temp_person(
   1 qual[*]
     2 person_id = f8
     2 data_exist = i4
 )
 DECLARE problem_nomenclature_id = f8 WITH protect
 SET path = value(logical( $DIRECTORY))
 SET infile =  $INPUTFILE
 SET file_path = build(path,":",infile)
 CALL echo(build(path,":",infile))
 CALL echo(file_path)
 DEFINE rtl2 value(file_path)
 SELECT INTO "nl:"
  FROM rtl2t r1
  PLAN (r1)
  HEAD REPORT
   stat = alterlist(temp_person->qual,100), cntp = 0
  HEAD r1.line
   cntp = (cntp+ 1)
   IF (mod(cntp,10)=1
    AND cntp > 100)
    stat = alterlist(temp_person->qual,(cntp+ 9))
   ENDIF
   temp_person->qual[cntp].person_id = cnvtreal(piece(r1.line,",",1,"",3))
  FOOT REPORT
   stat = alterlist(temp_person->qual,cntp)
 ;end select
 SELECT INTO "nl:"
  FROM nomenclature n
  WHERE n.source_string=value( $1)
   AND n.active_ind=1
  DETAIL
   problem_nomenclature_id = n.nomenclature_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(temp_person->qual,5))),
   problem p
  PLAN (d1)
   JOIN (p
   WHERE (p.person_id=temp_person->qual[d1.seq].person_id)
    AND p.nomenclature_id=problem_nomenclature_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  DETAIL
   temp_person->qual[d1.seq].data_exist = 1
  WITH nocounter
 ;end select
 SET rec_cnt = size(temp_person->qual,5)
 FOR (x = 1 TO rec_cnt)
   CALL pause(5)
   CALL echo(build("calling main script =",x))
   IF ((temp_person->qual[x].data_exist=0))
    EXECUTE ams_auto_add_problem temp_person->qual[x].person_id,  $1
   ENDIF
   CALL echo(build("after main script =",x))
   CALL echo(build("time=:",format(sysdate,"dd-.csvmm-yyyy hh:mm:ss;;q")))
 ENDFOR
 CALL echorecord(temp_person)
 FREE RECORD temp_person
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
END GO
