CREATE PROGRAM ams_order_cancel_dc_driver:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH file
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
 DECLARE smessage = vc WITH protect, noconstant("")
 FREE RECORD rdata
 RECORD rdata(
   1 qual_knt = i4
   1 qual[*]
     2 object_name = vc
     2 user_name = vc
     2 compiled_dt_tm = vc
     2 source_name = vc
 )
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 FREE RECORD temp_order
 RECORD temp_order(
   1 qual[*]
     2 order_id = f8
 )
 SET input_file =  $FILE
 FREE DEFINE rtl2
 DEFINE rtl2 input_file
 SELECT INTO "nl:"
  FROM rtl2t r1
  PLAN (r1)
  HEAD REPORT
   stat = alterlist(temp_order->qual,100), cnt = 0
  HEAD r1.line
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt > 100)
    stat = alterlist(temp_order->qual,(cnt+ 9))
   ENDIF
   temp_order->qual[cnt].order_id = cnvtreal(piece(r1.line,",",1,"",3))
  FOOT REPORT
   stat = alterlist(temp_order->qual,cnt)
  WITH nocounter
 ;end select
 SET rec_cnt = size(temp_order->qual,5)
 FOR (x = 1 TO rec_cnt)
   CALL pause(5)
   CALL echo(build("calling main script =",x))
   EXECUTE ams_auto_order_cancel_dc temp_order->qual[x].order_id
   CALL echo(build("after main script =",x))
   CALL echo(build("time=:",format(sysdate,"dd-mm-yyyy hh:mm:ss;;q")))
 ENDFOR
 CALL echorecord(temp_order)
 FREE RECORD temp_order
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
