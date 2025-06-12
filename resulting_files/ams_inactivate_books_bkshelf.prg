CREATE PROGRAM ams_inactivate_books_bkshelf
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Audit/Commit" = ""
  WITH outdev, auditcommit
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
 RECORD list_inactive_books(
   1 cnt = i2
   1 qual[*]
     2 activeind = i4
     2 appt_book_id = f8
     2 description = vc
 )
 FREE RECORD request
 RECORD request(
   1 call_echo_ind = i2
   1 qual[*]
     2 allow_partial_ind = i2
     2 active_status_cd = f8
     2 appt_book_id = f8
     2 updt_cnt = i4
     2 force_updt_ind = i2
     2 version_ind = i2
     2 version_dt_tm = dq8
     2 description = vc
     2 activeind = i4
 )
 RECORD ina_appt_book_reply(
   1 qual_cnt = i4
   1 qual[*]
     2 status = i4
 )
 RECORD reply(
   1 qual_cnt = i4
   1 qual[*]
     2 status = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 targetobjectvalue = vc
       3 operationstatus = c1
       3 targetobjectname = c25
 )
 EXECUTE ams_define_toolkit_common
 IF (( $AUDITCOMMIT="Audit"))
  SELECT
   l.appt_book_id, r.description
   FROM sch_book_list lb,
    sch_appt_book bb,
    sch_resource r,
    sch_appt_book b,
    sch_book_list l
   PLAN (r
    WHERE r.active_ind=1)
    JOIN (l
    WHERE l.resource_cd=r.resource_cd
     AND l.active_ind=1)
    JOIN (b
    WHERE b.appt_book_id=outerjoin(l.appt_book_id)
     AND b.active_ind=1)
    JOIN (lb
    WHERE lb.child_appt_book_id=outerjoin(b.appt_book_id)
     AND lb.active_ind=1)
    JOIN (bb
    WHERE bb.appt_book_id=outerjoin(lb.appt_book_id)
     AND bb.active_ind=1)
   ORDER BY bb.mnemonic, b.mnemonic
   HEAD PAGE
    r = 0
   HEAD l.appt_book_id
    IF (mod(r,10)=0)
     stat = alterlist(request->qual,(r+ 10))
    ENDIF
    r = (r+ 1), request->call_echo_ind = 1, request->qual[r].appt_book_id = l.appt_book_id,
    request->qual[r].version_dt_tm = ((0/ 0)/ 0), request->qual[r].active_status_cd = 0, request->
    qual[r].updt_cnt = 0,
    request->qual[r].allow_partial_ind = 0, request->qual[r].version_ind = 0, request->qual[r].
    force_updt_ind = 1,
    request->qual[r].description = r.description, request->qual[r].activeind = l.active_ind
   FOOT PAGE
    stat = alterlist(request->qual,r)
   WITH nullreport
  ;end select
  SELECT INTO  $OUTDEV
   app_book_id = request->qual[d.seq].appt_book_id, active = request->qual[d.seq].activeind,
   description = request->qual[d.seq].description
   FROM (dummyt d  WITH seq = value(size(request->qual,5)))
   PLAN (d)
   WITH format
  ;end select
 ELSE
  SELECT
   l.appt_book_id, r.description
   FROM sch_resource r,
    sch_book_list l,
    sch_appt_book b,
    sch_book_list lb,
    sch_appt_book bb
   PLAN (r
    WHERE r.active_ind=1)
    JOIN (l
    WHERE l.resource_cd=r.resource_cd
     AND l.active_ind=1)
    JOIN (b
    WHERE b.appt_book_id=outerjoin(l.appt_book_id)
     AND b.active_ind=1)
    JOIN (lb
    WHERE lb.child_appt_book_id=outerjoin(b.appt_book_id)
     AND lb.active_ind=1)
    JOIN (bb
    WHERE bb.appt_book_id=outerjoin(lb.appt_book_id)
     AND bb.active_ind=1)
   ORDER BY bb.mnemonic, b.mnemonic
   HEAD PAGE
    r = 0
   HEAD l.appt_book_id
    IF (mod(r,10)=0)
     stat = alterlist(request->qual,(r+ 10))
    ENDIF
    r = (r+ 1), request->qual[r].appt_book_id = l.appt_book_id, request->qual[r].version_dt_tm = ((0
    / 0)/ 0),
    request->qual[r].activeind = 0, request->qual[r].version_ind = 0, request->call_echo_ind = 1,
    request->qual[r].force_updt_ind = 1, request->qual[r].active_status_cd = 0, request->qual[r].
    updt_cnt = 0,
    request->qual[r].allow_partial_ind = 0, request->qual[r].description = r.description
   FOOT PAGE
    stat = alterlist(request->qual,r)
   WITH nullreport
  ;end select
  EXECUTE sch_ina_appt_book  WITH replace(ina_appt_book_request,request)
  SELECT INTO  $OUTDEV
   app_book_id = request->qual[d.seq].appt_book_id, active = request->qual[d.seq].activeind,
   description = request->qual[d.seq].description
   FROM (dummyt d  WITH seq = value(size(request->qual,5)))
   PLAN (d)
   WITH format
  ;end select
 ENDIF
END GO
