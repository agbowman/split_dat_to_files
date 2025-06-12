CREATE PROGRAM ams_delete_collection_specimen:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Audit/Commit" = ""
  WITH outdev, auditcommit
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed_mess = false
 SET table_name = fillstring(50," ")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE smessage = vc WITH protect, noconstant("")
 FREE RECORD details
 RECORD details(
   1 del_pst_record = i4
   1 qual[*]
     2 catalog_cd = f8
     2 service_resource_cd = f8
     2 specimen_type_cd = f8
     2 sequence = f8
     2 exist = i4
 )
 FREE RECORD req_details
 RECORD req_details(
   1 del_pst_record = i4
   1 qual[*]
     2 catalog_cd = f8
     2 service_resource_cd = f8
     2 specimen_type_cd = f8
     2 sequence = f8
     2 exist = i4
 )
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed_mess = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 SELECT
  catalog = uar_get_code_display(c.catalog_cd), service_resource = uar_get_code_display(c
   .service_resource_cd), c.catalog_cd,
  c.specimen_type_cd
  FROM collection_info_qualifiers c
  WHERE c.service_resource_cd != 0.00
  HEAD REPORT
   r = 0
  DETAIL
   IF (mod(r,10)=0)
    stat = alterlist(details->qual,(r+ 10))
   ENDIF
   r = (r+ 1), details->qual[r].catalog_cd = c.catalog_cd, details->qual[r].service_resource_cd = c
   .service_resource_cd,
   details->qual[r].specimen_type_cd = c.specimen_type_cd, details->qual[r].sequence = c.sequence
  FOOT REPORT
   stat = alterlist(details->qual,r)
  WITH nocounter
 ;end select
 FOR (i = 1 TO value(size(details->qual,5)))
  SELECT INTO "nl:"
   FROM orc_resource_list o
   WHERE (o.catalog_cd=details->qual[i].catalog_cd)
    AND (o.service_resource_cd=details->qual[i].service_resource_cd)
   WITH oncounter
  ;end select
  IF (curqual=0)
   SET details->qual[i].exist = 0
  ELSE
   SET details->qual[i].exist = 1
  ENDIF
 ENDFOR
 IF (( $AUDITCOMMIT="Audit"))
  SELECT INTO  $OUTDEV
   catalog = substring(1,30,uar_get_code_display(details->qual[d1.seq].catalog_cd)), service_resource
    = substring(1,30,uar_get_code_display(details->qual[d1.seq].service_resource_cd)), specimen_tpye
    = substring(1,30,uar_get_code_display(details->qual[d1.seq].specimen_type_cd)),
   sequence = details->qual[d1.seq].sequence
   FROM (dummyt d1  WITH seq = value(size(details->qual,5)))
   PLAN (d1
    WHERE (details->qual[d1.seq].exist=0)
     AND value(size(details->qual,5)) > 0)
   ORDER BY catalog
   WITH nocounter, separator = " ", format
  ;end select
 ELSE
  SELECT INTO "nl:"
   catalog = substring(1,30,uar_get_code_display(details->qual[d1.seq].catalog_cd)), service_resource
    = substring(1,30,uar_get_code_display(details->qual[d1.seq].service_resource_cd)), specimen_tpye
    = substring(1,30,uar_get_code_display(details->qual[d1.seq].specimen_type_cd)),
   sequence = details->qual[d1.seq].sequence
   FROM (dummyt d1  WITH seq = value(size(details->qual,5)))
   PLAN (d1
    WHERE (details->qual[d1.seq].exist=0)
     AND value(size(details->qual,5)) > 0)
   ORDER BY catalog
   HEAD REPORT
    r = 0
   DETAIL
    IF (mod(r,10)=0)
     stat = alterlist(req_details->qual,(r+ 10))
    ENDIF
    r = (r+ 1), req_details->qual[r].catalog_cd = details->qual[d1.seq].catalog_cd, req_details->
    qual[r].service_resource_cd = details->qual[d1.seq].service_resource_cd,
    req_details->qual[r].specimen_type_cd = details->qual[d1.seq].specimen_type_cd, req_details->
    qual[r].sequence = details->qual[d1.seq].sequence
   FOOT REPORT
    stat = alterlist(req_details->qual,r)
   WITH nocounter, separator = " ", format
  ;end select
  DECLARE number_to_delete = i4
  EXECUTE scs_del_collection_info:dba  WITH replace("REQUEST",req_details)
  SET failed_mess = true
  SET serrmsg = "Successfully Inserted"
 ENDIF
 IF (failed_mess != false)
  SELECT INTO  $OUTDEV
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (failed_mess != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
#exit_script
 SET script_ver = " 000 05/20/15 SD0303079         Initial Release "
END GO
