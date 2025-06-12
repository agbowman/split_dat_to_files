CREATE PROGRAM ams_dcp_nonvirtual_orders
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE position = i4 WITH protect
 DECLARE catcount = i4 WITH protect
 DECLARE faccount = i4 WITH protect
 DECLARE index = i4 WITH protect
 FREE RECORD catrec
 RECORD catrec(
   1 catqual[*]
     2 catcd = f8
 )
 FREE RECORD facrec
 RECORD facrec(
   1 facqual[*]
     2 faccd = vc
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
 SELECT INTO "nl:"
  FROM ocs_facility_r ofr,
   order_catalog_synonym ocs,
   code_value cv
  PLAN (ofr)
   JOIN (ocs
   WHERE ocs.synonym_id=ofr.synonym_id)
   JOIN (cv
   WHERE cv.code_value=ofr.facility_cd)
  ORDER BY ocs.catalog_cd
  HEAD REPORT
   stat = alterlist(catrec->catqual,10), catcount = 0
  HEAD ocs.catalog_cd
   catcount = (catcount+ 1)
   IF (catcount > 10
    AND mod(catcount,10)=1)
    stat = alterlist(catrec->catqual,(catcount+ 9))
   ENDIF
   catrec->catqual[catcount].catcd = ocs.catalog_cd
  FOOT REPORT
   stat = alterlist(catrec->catqual,catcount)
  WITH nocounter, separator = " ", format
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog oc
  HEAD REPORT
   stat = alterlist(facrec->facqual,10), faccount = 0
  HEAD oc.catalog_cd
   position = locateval(index,1,catcount,oc.catalog_cd,catrec->catqual[index].catcd)
   IF (position=0)
    faccount = (faccount+ 1)
    IF (faccount > 10
     AND mod(faccount,10)=1)
     stat = alterlist(facrec->facqual,(faccount+ 9))
    ENDIF
    facrec->facqual[faccount].faccd = uar_get_code_display(oc.catalog_cd)
   ENDIF
  WITH nocounter, separator = " ", format
 ;end select
 CALL echorecord(facrec)
 SELECT INTO  $1
  order_name = substring(1,30,facrec->facqual[d1.seq].faccd)
  FROM (dummyt d1  WITH seq = value(size(facrec->facqual,5)))
  PLAN (d1)
  WITH nocounter, separator = " ", format
 ;end select
#exit_script
 IF (script_failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 SET last_mod = "001 12/05/2015 KP035208  Initial Release"
END GO
