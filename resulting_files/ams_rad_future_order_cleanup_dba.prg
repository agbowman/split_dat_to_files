CREATE PROGRAM ams_rad_future_order_cleanup:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date" = "SYSDATE",
  "End Date" = "SYSDATE"
  WITH outdev, bdate, edate
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
 DECLARE radiology_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6000,"RADIOLOGY"))
 DECLARE epi_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",4,
   "COMMUNITYMEDICALRECORDNUMBER"))
 SELECT INTO  $OUTDEV
  epi = cnvtalias(pa.alias,pa.alias_pool_cd), person_name = p.name_full_formatted, order_mnemonic = o
  .order_mnemonic,
  catalog_type = uar_get_code_display(o.catalog_type_cd), order_placed_dt_tm = o.orig_order_dt_tm
  "dd/mmm/yyyy hh:mm:ss", o.order_id
  FROM orders o,
   person p,
   person_alias pa
  PLAN (o
   WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime( $BDATE) AND cnvtdatetime( $EDATE)
    AND o.catalog_type_cd=radiology_cd
    AND o.encntr_id=0.0
    AND o.active_ind=1)
   JOIN (p
   WHERE p.person_id=o.person_id
    AND p.active_ind=1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=epi_cd
    AND pa.active_ind=1)
  ORDER BY o.orig_order_dt_tm
  WITH separator = " ", format, nocounter
 ;end select
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
