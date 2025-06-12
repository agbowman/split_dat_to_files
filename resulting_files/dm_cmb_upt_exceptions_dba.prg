CREATE PROGRAM dm_cmb_upt_exceptions:dba
 IF (validate(dcue_upt_exc_reply->message,"YYY")="YYY"
  AND validate(dcue_upt_exc_reply->message,"zzz")="zzz")
  FREE RECORD dcue_upt_exc_reply
  RECORD dcue_upt_exc_reply(
    1 status = c1
    1 message = c255
    1 error_table = c30
  )
 ENDIF
 DECLARE dcue_script_prefix = vc
 DECLARE dcue_cust_cnt = i4
 DECLARE dcue_noexec_script_cnt = i4
 DECLARE dcue_err = i4
 DECLARE dcue_idx = i4 WITH noconstant(0)
 DECLARE dcue_pos = i4 WITH noconstant(0)
 DECLARE dcue_cust_tbl_missing = i4 WITH noconstant(0)
 DECLARE dcue_timezone = i4 WITH noconstant(0)
 SET dcue_script_prefix = cnvtupper( $1)
 SET dcue_cust_cnt = 0
 SET dcue_noexec_script_cnt = 0
 FREE RECORD dcue_script_rec
 RECORD dcue_script_rec(
   1 qual[*]
     2 sname = vc
     2 dict_date_utc = dq8
     2 info_date_utc = dq8
     2 exec_script_ind = i2
 )
 FREE RECORD dcue_tz
 RECORD dcue_tz(
   1 m_id = c64
   1 m_offset = i4
   1 m_daylight = i4
   1 m_tz[64] = c64
 )
 DECLARE uar_dcuegetsystemtimezone(p1=vc(ref)) = null WITH image_aix = "libdate.a(libdate.o)", uar =
 "DateGetSystemTimeZone"
 CALL uar_dcuegetsystemtimezone(dcue_tz)
 SET dcue_timezone = datetimezonebyname(dcue_tz->m_id)
 RECORD dcue_context_rec(
   1 called_by_dcue_ind = i2
 )
 SET dcue_context_rec->called_by_dcue_ind = 1
 SELECT INTO "nl:"
  dp.*
  FROM dprotect dp
  WHERE dp.object_name=patstring(dcue_script_prefix)
   AND dp.object="P"
  DETAIL
   dcue_cust_cnt = (dcue_cust_cnt+ 1)
   IF (mod(dcue_cust_cnt,100)=1)
    stat = alterlist(dcue_script_rec->qual,(dcue_cust_cnt+ 99))
   ENDIF
   dcue_script_rec->qual[dcue_cust_cnt].sname = dp.object_name, dcue_script_rec->qual[dcue_cust_cnt].
   info_date_utc = cnvtdatetime("01-jan-1900"), dcue_script_rec->qual[dcue_cust_cnt].exec_script_ind
    = 1,
   dcue_script_rec->qual[dcue_cust_cnt].dict_date_utc = cnvtdatetimeutc(cnvtdatetime(dp.datestamp,dp
     .timestamp),3,dcue_timezone)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  di.*
  FROM dm_info di
  WHERE di.info_domain="DM COMBINE CUSTOM SCRIPT DATE"
   AND di.info_name=patstring(dcue_script_prefix)
  DETAIL
   recpos = 0
   FOR (recloop = 1 TO dcue_cust_cnt)
     IF ((dcue_script_rec->qual[recloop].sname=di.info_name))
      recpos = recloop, recloop = dcue_cust_cnt
     ENDIF
   ENDFOR
   IF (recpos > 0)
    dcue_script_rec->qual[recpos].info_date_utc = cnvtdatetimeutc(di.info_date,0)
    IF ((dcue_script_rec->qual[recpos].info_date_utc=dcue_script_rec->qual[recpos].dict_date_utc))
     dcue_script_rec->qual[recpos].exec_script_ind = 0, dcue_noexec_script_cnt = (
     dcue_noexec_script_cnt+ 1)
    ENDIF
   ELSE
    CALL echo(concat("There was script ",dcue_script_rec->qual[recloop].sname," but it is gone now"))
   ENDIF
  WITH nocounter, forupdatewait(di)
 ;end select
 SET dcue_err = error(dcue_upt_exc_reply->message,0)
 IF (dcue_err != 0)
  SET dcue_upt_exc_reply->status = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_cmb_exception dce
  WHERE  NOT ( EXISTS (
  (SELECT
   "x"
   FROM user_tables ut
   WHERE ut.table_name=dce.child_entity)))
   AND cnvtupper(dce.script_name)=patstring(dcue_script_prefix)
  DETAIL
   dcue_pos = 0, dcue_pos = locateval(dcue_idx,1,dcue_cust_cnt,cnvtupper(dce.script_name),cnvtupper(
     dcue_script_rec->qual[dcue_idx].sname))
   IF (dcue_pos > 0)
    dcue_script_rec->qual[dcue_pos].exec_script_ind = 1, dcue_cust_tbl_missing = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (dcue_noexec_script_cnt=dcue_cust_cnt
  AND dcue_cust_tbl_missing=0)
  SET dcue_upt_exc_reply->status = "S"
  CALL echo("No changes detected in scripts maintaining dm_cmb_exception rows.")
  GO TO exit_script
 ELSE
  FOR (loopcnt = 1 TO dcue_cust_cnt)
    IF ((dcue_script_rec->qual[loopcnt].exec_script_ind=1))
     CALL parser(concat("execute ",dcue_script_rec->qual[loopcnt].sname," go"),1)
     IF ((dcue_upt_exc_reply->status != "S"))
      GO TO exit_script
     ENDIF
    ENDIF
  ENDFOR
  INSERT  FROM dm_info di,
    (dummyt d  WITH seq = value(dcue_cust_cnt))
   SET di.info_domain = "DM COMBINE CUSTOM SCRIPT DATE", di.info_name = dcue_script_rec->qual[d.seq].
    sname, di.info_date = cnvtdatetimeutc(dcue_script_rec->qual[d.seq].dict_date_utc,0)
   PLAN (d
    WHERE (dcue_script_rec->qual[d.seq].exec_script_ind=1)
     AND (dcue_script_rec->qual[d.seq].info_date_utc=cnvtdatetime("01-jan-1900")))
    JOIN (di
    WHERE di.info_domain="DM COMBINE CUSTOM SCRIPT DATE"
     AND (di.info_name=dcue_script_rec->qual[d.seq].sname))
   WITH nocounter
  ;end insert
  UPDATE  FROM dm_info di,
    (dummyt d  WITH seq = value(dcue_cust_cnt))
   SET di.info_date = cnvtdatetimeutc(dcue_script_rec->qual[d.seq].dict_date_utc,0)
   PLAN (d
    WHERE (dcue_script_rec->qual[d.seq].exec_script_ind=1)
     AND (dcue_script_rec->qual[d.seq].info_date_utc > cnvtdatetime("01-jan-1900")))
    JOIN (di
    WHERE di.info_domain="DM COMBINE CUSTOM SCRIPT DATE"
     AND (di.info_name=dcue_script_rec->qual[d.seq].sname))
   WITH nocounter
  ;end update
  SET dcue_err = error(dcue_upt_exc_reply->message,0)
  IF (dcue_err != 0)
   SET dcue_upt_exc_reply->status = "F"
  ELSE
   SET dcue_upt_exc_reply->status = "S"
  ENDIF
 ENDIF
#exit_script
 FREE RECORD dcue_context_rec
 FREE RECORD dcue_script_rec
 IF ((dcue_upt_exc_reply->status != "S"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
END GO
