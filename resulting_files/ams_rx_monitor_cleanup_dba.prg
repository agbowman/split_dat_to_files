CREATE PROGRAM ams_rx_monitor_cleanup:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Audit or Commit" = "0"
  WITH outdev, prompt1
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
 FREE RECORD master
 RECORD master(
   1 qual[*]
     2 order_id = f8
     2 refill_id = f8
 )
 FREE RECORD request
 RECORD request(
   1 order_list[0]
     2 order_id = f8
     2 encntr_id = f8
     2 action_sequence = i4
     2 perform_loc_cd = f8
     2 order_loc_cd = f8
     2 serv_res_cd = f8
     2 rx_pending_refill_id = f8
     2 wq_hx_action_type_cd = f8
     2 child_order_id = f8
   1 manual_commit_ind = i2
 )
 DECLARE remove_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",4563,"DELETE"))
 DEFINE rtl2 "rxordercleanup.csv"
 SELECT INTO "nl:"
  FROM rtl2t r
  HEAD REPORT
   cnt = 0
  DETAIL
   IF (mod(cnt,10)=0)
    stat = alterlist(master->qual,(cnt+ 10))
   ENDIF
   cnt = (cnt+ 1), master->qual[cnt].order_id = cnvtreal(piece(r.line,",",1,"",3))
  FOOT REPORT
   stat = alterlist(master->qual,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM rx_pending_refill rp,
   (dummyt d1  WITH seq = value(size(master->qual,5)))
  PLAN (d1)
   JOIN (rp
   WHERE (rp.order_id=master->qual[d1.seq].order_id))
  DETAIL
   master->qual[d1.seq].refill_id = rp.rx_pending_refill_id
  WITH nocounter
 ;end select
 IF (( $2="0"))
  SELECT INTO  $1
   order_id = master->qual[d1.seq].order_id, pending_refill_id =
   IF ((master->qual[d1.seq].refill_id=0)) "No Refill Pending"
   ELSE cnvtstring(master->qual[d1.seq].refill_id,12,2)
   ENDIF
   FROM (dummyt d1  WITH seq = value(size(master->qual,5)))
   WITH nocounter, separator = " ", format
  ;end select
 ENDIF
 CALL echorecord(master)
 IF (( $2="1"))
  SET reccnt = size(master->qual,5)
  FOR (i = 1 TO reccnt)
    SET request->order_list[1].order_id = master->qual[i].order_id
    SET request->order_list[1].wq_hx_action_type_cd = remove_cd
    SET request->order_list[1].rx_pending_refill_id = master->qual[i].refill_id
    SET request->order_list[1].action_sequence = 0
    CALL echo(build("PRK:",request->order_list[1].order_id))
    CALL echorecord(request)
    EXECUTE rxa_maintain_ezwq_list
  ENDFOR
  COMMIT
  IF (curqual > 0)
   SELECT INTO  $1
    FROM dummyt
    DETAIL
     col 0, reccnt, " orders are removed from E-RX monitor.  "
    WITH nocounter
   ;end select
  ENDIF
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
 SET script_ver = "000 17/04/14 Initial Release"
END GO
