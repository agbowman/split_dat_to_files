CREATE PROGRAM ams_inactv_order_appt_dissc:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Audit Or Commit" = ""
  WITH outdev, aoc
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
 FREE RECORD request_data
 RECORD request_data(
   1 call_echo_ind = i2
   1 qual[*]
     2 catalog_cd = f8
     2 appt_type_cd = f8
     2 updt_cnt = i4
     2 allow_partial_ind = i2
     2 force_updt_ind = i2
 )
 IF (( $AOC="A"))
  SELECT INTO  $OUTDEV
   order_name = substring(1,50,oc.description), last_updated = oc.updt_dt_tm"@SHORTDATETIME",
   appt_type = substring(1,50,sat.description)
   FROM sch_order_appt soa,
    order_catalog oc,
    sch_appt_type sat,
    sch_order_appt soa2
   PLAN (soa
    WHERE soa.active_ind=1
     AND soa.updt_dt_tm > cnvtdatetime("01-jan-2007 00:00"))
    JOIN (oc
    WHERE oc.catalog_cd=soa.catalog_cd
     AND oc.active_ind=0)
    JOIN (soa2
    WHERE soa2.catalog_cd=oc.catalog_cd)
    JOIN (sat
    WHERE soa2.appt_type_cd=sat.appt_type_cd)
   WITH nocounter, format
  ;end select
 ELSEIF (( $AOC="C"))
  SELECT INTO "nl:"
   order_name = substring(1,50,oc.description), last_updated = oc.updt_dt_tm"@SHORTDATETIME",
   appt_type = substring(1,50,sat.description)
   FROM sch_order_appt soa,
    order_catalog oc,
    sch_appt_type sat,
    sch_order_appt soa2
   PLAN (soa
    WHERE soa.active_ind=1
     AND soa.updt_dt_tm > cnvtdatetime("01-jan-2007 00:00"))
    JOIN (oc
    WHERE oc.catalog_cd=soa.catalog_cd
     AND oc.active_ind=0)
    JOIN (soa2
    WHERE soa2.catalog_cd=oc.catalog_cd)
    JOIN (sat
    WHERE sat.appt_type_cd=soa2.appt_type_cd)
   HEAD REPORT
    acnt = 0
   DETAIL
    IF (mod(acnt,10)=0)
     stat = alterlist(request_data->qual,(acnt+ 10))
    ENDIF
    acnt = (acnt+ 1), request_data->call_echo_ind = 0, request_data->qual[acnt].catalog_cd = soa
    .catalog_cd,
    request_data->qual[acnt].appt_type_cd = soa.appt_type_cd, request_data->qual[acnt].updt_cnt = soa
    .updt_cnt, request_data->qual[acnt].allow_partial_ind = 0,
    request_data->qual[acnt].force_updt_ind = 0
   FOOT REPORT
    stat = alterlist(request_data->qual,acnt)
   WITH format, separator = " "
  ;end select
  IF (curqual != 0)
   EXECUTE sch_del_order_appt  WITH replace(request,request_data)
   SELECT INTO  $OUTDEV
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     col 20, "Successfully Removed "
    WITH nocounter, format, separator = " "
   ;end select
  ELSE
   SELECT INTO  $OUTDEV
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     col 20, "No Records Found"
    WITH nocounter, format, separator = " "
   ;end select
  ENDIF
 ENDIF
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
 SET script_ver = "000  08/31/14   RC032418       Initial Release "
END GO
