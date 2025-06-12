CREATE PROGRAM ams_inactivate_queue:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select  Audit/Commit" = "",
  "Select" = "0"
  WITH outdev, auditcommit, delete_inactivate
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
 FREE RECORD request_queue
 RECORD request_queue(
   1 call_echo_ind = i2
   1 qual[*]
     2 sch_object_id = f8
     2 version_dt_tm = dq8
     2 active_status_cd = f8
     2 updt_cnt = i4
     2 allow_partial_ind = i2
     2 version_ind = i2
     2 force_updt_ind = i2
     2 queue_mnemonics = vc
     2 activeind = i4
 )
 RECORD reply(
   1 qual_cnt = i4
   1 qual[*]
     2 status = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 IF (( $AUDITCOMMIT="Audit"))
  SELECT INTO "nl:"
   request_list = substring(1,40,o.mnemonic), last_updated_by = substring(1,45,p.name_full_formatted),
   created_dt_tm = o.beg_effective_dt_tm"@SHORTDATETIME",
   activeind = o.active_ind
   FROM sch_object o,
    prsnl p
   PLAN (o
    WHERE  NOT ( EXISTS (
    (SELECT
     sar.routing_id
     FROM sch_appt_routing sar
     WHERE o.sch_object_id=sar.routing_id
      AND sar.active_ind=1)))
     AND o.active_ind=1
     AND o.object_type_meaning="QUEUE"
     AND o.updt_dt_tm > cnvtdatetime("01-JAN-2007 00:00"))
    JOIN (p
    WHERE o.updt_id=outerjoin(p.person_id))
   ORDER BY o.mnemonic
   HEAD PAGE
    r = 0
   HEAD o.sch_object_id
    IF (mod(r,10)=0)
     stat = alterlist(request_queue->qual,(r+ 10))
    ENDIF
    r = (r+ 1), request_queue->call_echo_ind = 1, request_queue->qual[r].sch_object_id = o
    .sch_object_id,
    request_queue->qual[r].version_dt_tm = ((0/ 0)/ 0), request_queue->qual[r].active_status_cd = 0,
    request_queue->qual[r].updt_cnt = 0,
    request_queue->qual[r].allow_partial_ind = 0, request_queue->qual[r].version_ind = 0,
    request_queue->qual[r].force_updt_ind = 1,
    request_queue->qual[r].activeind = activeind, request_queue->qual[r].queue_mnemonics =
    request_list
   FOOT PAGE
    stat = alterlist(request_queue->qual,r)
   WITH nullreport
  ;end select
  SELECT INTO  $OUTDEV
   sch_object_id = request_queue->qual[d.seq].sch_object_id, status = request_queue->qual[d.seq].
   activeind, mnemonic = request_queue->qual[d.seq].queue_mnemonics
   FROM (dummyt d  WITH seq = value(size(request_queue->qual,5)))
   PLAN (d)
   WITH format, separator = ""
  ;end select
 ELSE
  SELECT INTO "nl:"
   request_list = substring(1,40,o.mnemonic), last_updated_by = substring(1,45,p.name_full_formatted),
   created_dt_tm = o.beg_effective_dt_tm"@SHORTDATETIME",
   activeind = o.active_ind
   FROM sch_object o,
    prsnl p
   PLAN (o
    WHERE  NOT ( EXISTS (
    (SELECT
     sar.routing_id
     FROM sch_appt_routing sar
     WHERE o.sch_object_id=sar.routing_id
      AND sar.active_ind=1)))
     AND o.active_ind=1
     AND o.object_type_meaning="QUEUE"
     AND o.updt_dt_tm > cnvtdatetime("01-JAN-2007 00:00"))
    JOIN (p
    WHERE o.updt_id=outerjoin(p.person_id))
   ORDER BY o.mnemonic
   HEAD PAGE
    r = 0
   HEAD o.sch_object_id
    IF (mod(r,10)=0)
     stat = alterlist(request_queue->qual,(r+ 10))
    ENDIF
    r = (r+ 1), request_queue->call_echo_ind = 1, request_queue->qual[r].sch_object_id = o
    .sch_object_id,
    request_queue->qual[r].version_dt_tm = ((0/ 0)/ 0), request_queue->qual[r].active_status_cd = 0,
    request_queue->qual[r].updt_cnt = 0,
    request_queue->qual[r].allow_partial_ind = 0, request_queue->qual[r].version_ind = 0,
    request_queue->qual[r].force_updt_ind = 1,
    request_queue->qual[r].activeind = activeind, request_queue->qual[r].queue_mnemonics =
    request_list
   FOOT PAGE
    stat = alterlist(request_queue->qual,r)
   WITH nullreport
  ;end select
  IF (( $DELETE_INACTIVATE="I"))
   EXECUTE sch_ina_object  WITH replace(request,request_queue)
   SELECT INTO  $OUTDEV
    sch_object_id = request_queue->qual[d.seq].sch_object_id, status = 0, mnemonic = request_queue->
    qual[d.seq].queue_mnemonics
    FROM (dummyt d  WITH seq = value(size(request_queue->qual,5)))
    PLAN (d)
    WITH format, separator = ""
   ;end select
  ELSEIF (( $DELETE_INACTIVATE="D"))
   EXECUTE sch_del_object  WITH replace(request,request_queue)
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
 SET script_ver = "000 11/12/14 SD030379 Initial Release"
END GO
