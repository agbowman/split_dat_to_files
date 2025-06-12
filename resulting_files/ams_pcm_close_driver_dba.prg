CREATE PROGRAM ams_pcm_close_driver:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET exe_error = 10
 SET failed = false
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 person_id = f8
 )
 DEFINE rtl2 "pcmclose.csv"
 SELECT INTO "nl:"
  FROM rtl2t r1
  PLAN (r1)
  HEAD REPORT
   stat = alterlist(temp->qual,100), cntp = 0
  HEAD r1.line
   cntp = (cntp+ 1)
   IF (mod(cntp,10)=1
    AND cntp > 100)
    stat = alterlist(temp->qual,(cntp+ 9))
   ENDIF
   temp->qual[cntp].person_id = cnvtreal(piece(r1.line,",",1,"",3))
  FOOT REPORT
   stat = alterlist(temp->qual,cntp)
  WITH nocounter
 ;end select
 SET rec_cnt = size(temp->qual,5)
 FOR (x = 1 TO rec_cnt)
   CALL pause(5)
   CALL echo(build("calling main script =",x))
   EXECUTE ams_pcm_close temp->qual[x].person_id
   CALL echo(build("after main script =",x))
   CALL echo(build("time=:",format(sysdate,"dd-mm-yyyy hh:mm:ss;;q")))
 ENDFOR
 CALL echorecord(temp)
 FREE RECORD temp
 CALL updtdminfo(trim(cnvtupper(curprog),3))
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
END GO
