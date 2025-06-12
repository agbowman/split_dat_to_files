CREATE PROGRAM dm_cmb_upt_metadata:dba
 IF (validate(dcue_upt_exc_reply->message,"YYY")="YYY"
  AND validate(dcue_upt_exc_reply->message,"zzz")="zzz")
  FREE RECORD dcue_upt_exc_reply
  RECORD dcue_upt_exc_reply(
    1 status = c1
    1 message = c255
    1 error_table = c30
  )
 ENDIF
 DECLARE dcum_script_prefix = vc
 DECLARE dcum_cust_cnt = i4
 DECLARE dcum_noexec_script_cnt = i4
 DECLARE dcum_err = i4
 DECLARE dcum_idx = i4 WITH noconstant(0)
 DECLARE dcum_pos = i4 WITH noconstant(0)
 DECLARE dcum_cust_tbl_missing = i4 WITH noconstant(0)
 DECLARE dcum_timezone = i4 WITH noconstant(0)
 SET dcum_script_prefix = cnvtupper( $1)
 SET dcum_cust_cnt = 0
 SET dcum_noexec_script_cnt = 0
 FREE RECORD dcum_script_rec
 RECORD dcum_script_rec(
   1 qual[*]
     2 sname = vc
     2 dict_date_utc = dq8
     2 info_date_utc = dq8
     2 exec_script_ind = i2
 )
 FREE RECORD dcum_tz
 RECORD dcum_tz(
   1 m_id = c64
   1 m_offset = i4
   1 m_daylight = i4
   1 m_tz[64] = c64
 )
 DECLARE uar_dcumgetsystemtimezone(p1=vc(ref)) = null WITH image_aix = "libdate.a(libdate.o)", uar =
 "DateGetSystemTimeZone"
 CALL uar_dcumgetsystemtimezone(dcum_tz)
 SET dcum_timezone = datetimezonebyname(dcum_tz->m_id)
 RECORD dcum_context_rec(
   1 called_by_dcum_ind = i2
 )
 SET dcum_context_rec->called_by_dcum_ind = 1
 SELECT INTO "nl:"
  dp.*
  FROM dprotect dp
  WHERE dp.object_name=patstring(dcum_script_prefix)
   AND dp.object="P"
  DETAIL
   dcum_cust_cnt += 1
   IF (mod(dcum_cust_cnt,100)=1)
    stat = alterlist(dcum_script_rec->qual,(dcum_cust_cnt+ 99))
   ENDIF
   dcum_script_rec->qual[dcum_cust_cnt].sname = dp.object_name, dcum_script_rec->qual[dcum_cust_cnt].
   info_date_utc = cnvtdatetime("01-jan-1900"), dcum_script_rec->qual[dcum_cust_cnt].exec_script_ind
    = 1,
   dcum_script_rec->qual[dcum_cust_cnt].dict_date_utc = cnvtdatetimeutc(cnvtdatetime(dp.datestamp,dp
     .timestamp),3,dcum_timezone)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  di.*
  FROM dm_info di
  WHERE di.info_domain="DM COMBINE CUSTOM SCRIPT DATE"
   AND di.info_name=patstring(dcum_script_prefix)
  DETAIL
   recpos = 0
   FOR (recloop = 1 TO dcum_cust_cnt)
     IF ((dcum_script_rec->qual[recloop].sname=di.info_name))
      recpos = recloop, recloop = dcum_cust_cnt
     ENDIF
   ENDFOR
   IF (recpos > 0)
    dcum_script_rec->qual[recpos].info_date_utc = cnvtdatetimeutc(di.info_date,0)
    IF ((dcum_script_rec->qual[recpos].info_date_utc=dcum_script_rec->qual[recpos].dict_date_utc))
     dcum_script_rec->qual[recpos].exec_script_ind = 0, dcum_noexec_script_cnt += 1
    ENDIF
   ELSE
    CALL echo(concat("There was script ",dcum_script_rec->qual[recloop].sname," but it is gone now"))
   ENDIF
  WITH nocounter, forupdatewait(di)
 ;end select
 SET dcum_err = error(dcue_upt_exc_reply->message,0)
 IF (dcum_err != 0)
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
   AND cnvtupper(dce.script_name)=patstring(dcum_script_prefix)
  DETAIL
   dcum_pos = 0, dcum_pos = locateval(dcum_idx,1,dcum_cust_cnt,cnvtupper(dce.script_name),cnvtupper(
     dcum_script_rec->qual[dcum_idx].sname))
   IF (dcum_pos > 0)
    dcum_script_rec->qual[dcum_pos].exec_script_ind = 1, dcum_cust_tbl_missing = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (dcum_noexec_script_cnt=dcum_cust_cnt
  AND dcum_cust_tbl_missing=0)
  SET dcue_upt_exc_reply->status = "S"
  CALL echo("No changes detected in scripts maintaining dm_cmb_exception rows.")
  GO TO exit_script
 ELSE
  FOR (loopcnt = 1 TO dcum_cust_cnt)
    IF ((dcum_script_rec->qual[loopcnt].exec_script_ind=1))
     CALL parser(concat("execute ",dcum_script_rec->qual[loopcnt].sname," go"),1)
     IF ((dcue_upt_exc_reply->status != "S"))
      GO TO exit_script
     ENDIF
    ENDIF
  ENDFOR
  INSERT  FROM dm_info di,
    (dummyt d  WITH seq = value(dcum_cust_cnt))
   SET di.info_domain = "DM COMBINE CUSTOM SCRIPT DATE", di.info_name = dcum_script_rec->qual[d.seq].
    sname, di.info_date = cnvtdatetimeutc(dcum_script_rec->qual[d.seq].dict_date_utc,0)
   PLAN (d
    WHERE (dcum_script_rec->qual[d.seq].exec_script_ind=1)
     AND (dcum_script_rec->qual[d.seq].info_date_utc=cnvtdatetime("01-jan-1900")))
    JOIN (di
    WHERE di.info_domain="DM COMBINE CUSTOM SCRIPT DATE"
     AND (di.info_name=dcum_script_rec->qual[d.seq].sname))
   WITH nocounter
  ;end insert
  UPDATE  FROM dm_info di,
    (dummyt d  WITH seq = value(dcum_cust_cnt))
   SET di.info_date = cnvtdatetimeutc(dcum_script_rec->qual[d.seq].dict_date_utc,0)
   PLAN (d
    WHERE (dcum_script_rec->qual[d.seq].exec_script_ind=1)
     AND (dcum_script_rec->qual[d.seq].info_date_utc > cnvtdatetime("01-jan-1900")))
    JOIN (di
    WHERE di.info_domain="DM COMBINE CUSTOM SCRIPT DATE"
     AND (di.info_name=dcum_script_rec->qual[d.seq].sname))
   WITH nocounter
  ;end update
  SET dcum_err = error(dcue_upt_exc_reply->message,0)
  IF (dcum_err != 0)
   SET dcue_upt_exc_reply->status = "F"
  ELSE
   SET dcue_upt_exc_reply->status = "S"
  ENDIF
 ENDIF
#exit_script
 FREE RECORD dcum_context_rec
 FREE RECORD dcum_script_rec
 IF ((dcue_upt_exc_reply->status != "S"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
END GO
