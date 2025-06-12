CREATE PROGRAM ams_acc_to_acc_driver:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FREE RECORD request
 FREE RECORD temp1
 RECORD temp1(
   1 list[*]
     2 fromacctid = f8
     2 toacctid = f8
   1 count_rec = i2
 )
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
 SET script_failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET script_failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 SET logical _fn "ccluserdir:acc_to_acc_info.csv"
 FREE DEFINE rtl3
 DEFINE rtl3 "_fn"
 SELECT INTO "mine"
  r.line
  FROM rtl3t r
  HEAD REPORT
   count = 0
  HEAD r.line
   IF (mod(count,10)=0)
    stat = alterlist(temp1->list,(count+ 10))
   ENDIF
   count = (count+ 1), line1 = r.line, temp1->list[count].toacctid = cnvtint(piece(line1,",",1,"0")),
   temp1->list[count].fromacctid = cnvtint(piece(line1,",",2,"0"))
  FOOT REPORT
   stat = alterlist(temp1->list,count), temp1->count_rec = count
  WITH format, separator = " ", nocounter
 ;end select
 CALL echo(temp1->count_rec)
 FOR (i = 1 TO temp1->count_rec)
   FREE RECORD request
   RECORD request(
     1 debugmode = i2
     1 fromacctid = f8
     1 toacctid = f8
   )
   SET request->toacctid = temp1->list[i].toacctid
   SET request->fromacctid = temp1->list[i].fromacctid
   SET request->debugmode = 1
   EXECUTE ams_acct_to_acct_combine_cln:dba
   CALL echorecord(request)
 ENDFOR
 SELECT INTO  $OUTDEV
  message = "Scirpt called for-> ", toacctid = temp1->list[d1.seq].toacctid, fromacctid = temp1->
  list[d1.seq].fromacctid
  FROM (dummyt d1  WITH seq = value(size(temp1->list,5)))
  PLAN (d1)
  WITH nocounter, separator = " ", format
 ;end select
 CALL echorecord(temp1)
#exit_script
 IF (script_failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (script_failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
END GO
