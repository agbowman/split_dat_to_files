CREATE PROGRAM bsv_get_encntr_loc_tz:dba
 DECLARE last_mod = c12 WITH private, noconstant(fillstring(12," "))
 DECLARE lcnt = i4 WITH noconstant(0)
 DECLARE lstat = i4 WITH noconstant(0)
 DECLARE lencntrs = i4 WITH noconstant(0)
 DECLARE lfacilities = i4 WITH noconstant(0)
 DECLARE smsg = vc WITH noconstant
 DECLARE ldatecnt = i4 WITH noconstant(0)
 DECLARE lreplycnt = i4 WITH noconstant(0)
 DECLARE lfaccnt = i4 WITH noconstant(0)
 DECLARE istatustwo = i2 WITH noconstant(0)
 DECLARE lindex = i4 WITH noconstant(0)
 DECLARE ilocation = i4 WITH noconstant(0)
 IF (validate(reply->status_data.status,"-99")="-99")
  FREE RECORD reply
  RECORD reply(
    1 encntrs_qual_cnt = i4
    1 encntrs[*]
      2 encntr_id = f8
      2 time_zone_indx = i4
      2 time_zone = vc
      2 transaction_dt_tm = dq8
      2 check = i2
      2 status = i2
      2 loc_fac_cd = f8
    1 facilities_qual_cnt = i4
    1 facilities[*]
      2 loc_facility_cd = f8
      2 time_zone_indx = i4
      2 time_zone = vc
      2 status = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET reply->encntrs_qual_cnt = value(size(request->encntrs,5))
 SET reply->facilities_qual_cnt = value(size(request->facilities,5))
 IF (size(request->encntrs,5) > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(request->encntrs,5)))
   WHERE (request->encntrs[d.seq].encntr_id > 0.0)
   DETAIL
    lcnt = (lcnt+ 1)
    IF (mod(lcnt,10)=1)
     lstat = alterlist(reply->encntrs,(lcnt+ 9))
    ENDIF
    reply->encntrs[lcnt].encntr_id = request->encntrs[d.seq].encntr_id, reply->encntrs[lcnt].
    transaction_dt_tm = request->encntrs[d.seq].transaction_dt_tm
    IF ((request->encntrs[d.seq].transaction_dt_tm > cnvtdatetime("01-JAN-1800")))
     ldatecnt = (ldatecnt+ 1), reply->encntrs[lcnt].check = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (lcnt > 0)
   SET lstat = alterlist(reply->encntrs,lcnt)
  ENDIF
  SET lcnt = 0
  SET lstat = 0
  SET lencntrs = value(size(reply->encntrs,5))
 ENDIF
 IF (size(request->facilities,5) > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(request->facilities,5)))
   WHERE (request->facilities[d.seq].loc_facility_cd > 0.0)
   DETAIL
    lcnt = (lcnt+ 1)
    IF (mod(lcnt,10)=1)
     lstat = alterlist(reply->facilities,(lcnt+ 9))
    ENDIF
    reply->facilities[lcnt].loc_facility_cd = request->facilities[d.seq].loc_facility_cd
   WITH nocounter
  ;end select
  IF (lcnt > 0)
   SET lstat = alterlist(reply->facilities,lcnt)
  ENDIF
  SET lfacilities = value(size(reply->facilities,5))
 ENDIF
 IF (ldatecnt > 0)
  SELECT INTO "nl:"
   elh.encntr_id, t.time_zone
   FROM (dummyt d  WITH seq = lencntrs),
    encntr_loc_hist elh,
    time_zone_r t
   PLAN (d
    WHERE (reply->encntrs[d.seq].check=1))
    JOIN (elh
    WHERE (elh.encntr_id=reply->encntrs[d.seq].encntr_id)
     AND elh.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ((elh.transaction_dt_tm+ 0) <= cnvtdatetime(reply->encntrs[d.seq].transaction_dt_tm)))
    JOIN (t
    WHERE t.parent_entity_id=outerjoin(elh.loc_facility_cd)
     AND t.parent_entity_name=outerjoin("LOCATION"))
   ORDER BY cnvtdatetime(elh.transaction_dt_tm)
   DETAIL
    lreplycnt = (lreplycnt+ 1)
    IF (t.parent_entity_id > 0)
     reply->encntrs[d.seq].time_zone_indx = datetimezonebyname(trim(t.time_zone,3)), reply->encntrs[d
     .seq].time_zone = trim(t.time_zone,3)
    ENDIF
    reply->encntrs[d.seq].transaction_dt_tm = elh.transaction_dt_tm, reply->encntrs[d.seq].loc_fac_cd
     = elh.loc_facility_cd
    IF ((reply->encntrs[d.seq].time_zone_indx=0))
     reply->encntrs[d.seq].status = 2, istatustwo = true
    ELSE
     reply->encntrs[d.seq].status = 1
    ENDIF
   WITH maxqual(elh,1)
  ;end select
 ENDIF
 IF (lencntrs > 0)
  SET lcnt = 0
  SET lindex = 0
  IF (lencntrs=1)
   SELECT INTO "nl:"
    e.encntr_id, t.time_zone
    FROM encounter e,
     time_zone_r t
    PLAN (e
     WHERE (e.encntr_id=reply->encntrs[1].encntr_id))
     JOIN (t
     WHERE t.parent_entity_id=e.loc_facility_cd
      AND t.parent_entity_name="LOCATION")
    DETAIL
     IF ((reply->encntrs[1].status=0))
      lreplycnt = (lreplycnt+ 1), reply->encntrs[lindex].time_zone_indx = datetimezonebyname(trim(t
        .time_zone,3)), reply->encntrs[lindex].time_zone = trim(t.time_zone,3),
      reply->encntrs[lindex].status = 1, reply->encntrs[lindex].loc_fac_cd = e.loc_facility_cd
     ENDIF
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    e.encntr_id, t.time_zone
    FROM encounter e,
     time_zone_r t
    PLAN (e
     WHERE expand(lcnt,1,lencntrs,e.encntr_id,reply->encntrs[lcnt].encntr_id))
     JOIN (t
     WHERE t.parent_entity_id=e.loc_facility_cd
      AND t.parent_entity_name="LOCATION")
    DETAIL
     lindex = locateval(lcnt,1,lencntrs,e.encntr_id,reply->encntrs[lcnt].encntr_id)
     WHILE (lindex > 0)
      IF ((reply->encntrs[lindex].status=0))
       lreplycnt = (lreplycnt+ 1), reply->encntrs[lindex].time_zone_indx = datetimezonebyname(trim(t
         .time_zone,3)), reply->encntrs[lindex].time_zone = trim(t.time_zone,3),
       reply->encntrs[lindex].status = 1, reply->encntrs[lindex].loc_fac_cd = e.loc_facility_cdx
      ENDIF
      ,lindex = locateval(lcnt,(lindex+ 1),lencntrs,e.encntr_id,reply->encntrs[lcnt].encntr_id)
     ENDWHILE
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (lfacilities > 0)
  SET lcnt = 0
  SET lindex = 0
  IF (lfacilities=1)
   SELECT INTO "nl:"
    l.location_cd
    FROM location l,
     time_zone_r t
    PLAN (l
     WHERE (l.location_cd=reply->facilities[1].loc_facility_cd))
     JOIN (t
     WHERE t.parent_entity_id=l.location_cd
      AND t.parent_entity_name="LOCATION")
    DETAIL
     lfaccnt = (lfaccnt+ 1), reply->facilities[1].time_zone_indx = datetimezonebyname(trim(t
       .time_zone,3)), reply->facilities[1].time_zone = trim(t.time_zone,3),
     reply->facilities[1].status = 1
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    l.location_cd
    FROM location l,
     time_zone_r t
    PLAN (l
     WHERE expand(lcnt,1,lfacilities,l.location_cd,reply->facilities[lcnt].loc_facility_cd))
     JOIN (t
     WHERE t.parent_entity_id=l.location_cd
      AND t.parent_entity_name="LOCATION")
    DETAIL
     lindex = locateval(lcnt,1,lfacilities,l.location_cd,reply->facilities[lcnt].loc_facility_cd)
     WHILE (lindex > 0)
       lfaccnt = (lfaccnt+ 1), reply->facilities[lindex].time_zone_indx = datetimezonebyname(trim(t
         .time_zone,3)), reply->facilities[lindex].time_zone = trim(t.time_zone,3),
       reply->facilities[lindex].status = 1, lindex = locateval(lcnt,(lindex+ 1),lfacilities,l
        .location_cd,reply->facilities[lcnt].loc_facility_cd)
     ENDWHILE
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (lencntrs=0
  AND lfacilities=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bsv_get_encntr_loc_tz"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "There were no encounters or facilities to process"
 ELSEIF (lencntrs=lreplycnt
  AND lfacilities=lfaccnt)
  SET reply->status_data.status = "S"
 ELSEIF (((lreplycnt > 0) OR (((lfaccnt > 0) OR (istatustwo)) )) )
  IF (istatustwo)
   SET smsg = "Encounters found on the encntr_loc_hist table without matching time zones."
  ELSE
   SET smsg = "SOME time zones found.  Check encounter/facility statuses."
  ENDIF
  SET reply->status_data.status = "P"
  SET reply->status_data.subeventstatus[1].operationname = "bsv_get_encntr_loc_tz"
  SET reply->status_data.subeventstatus[1].operationstatus = "P"
  SET reply->status_data.subeventstatus[1].targetobjectname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = smsg
 ELSE
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "bsv_get_encntr_loc_tz"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No time zones were found"
 ENDIF
#exit_script
 SET last_mod = "001 10/01/13"
 SET modify = nopredeclare
END GO
