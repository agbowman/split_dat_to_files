CREATE PROGRAM ams_pharm_wrk_stn_driver
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Directory" = "",
  "Enter the input file" = "",
  "Select audit or commit" = ""
  WITH outdev, directory, inputfile,
  auditcommit
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
 SET failed_mess = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE smessage = vc WITH protect, noconstant("")
 SET path = value(logical( $DIRECTORY))
 SET infile =  $INPUTFILE
 SET file_path = build(path,"/",infile)
 DEFINE rtl2 "CCLUSERDIR:ams_pharm_wrk_stn.csv"
 FREE RECORD file_reply
 RECORD file_reply(
   1 qual[*]
     2 description = vc
     2 short_desc = vc
     2 active_ind = vc
     2 pharmacy_type_cd = vc
     2 location_cd = vc
     2 inv_location_cd = vc
     2 organization_id = vc
     2 parent_resource = vc
 )
 SELECT
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, i = 0, count = 0,
   stat = alterlist(file_reply->qual,10)
  HEAD r.line
   line1 = r.line,
   CALL echo(line1)
   IF (size(trim(line1),1) > 0)
    count = (count+ 1)
    IF (count > 1)
     row_count = (row_count+ 1)
     IF (mod(row_count,10)=0)
      stat = alterlist(file_reply->qual,(row_count+ 9))
     ENDIF
     file_reply->qual[row_count].description = piece(line1,",",1,"Not Found"), file_reply->qual[
     row_count].short_desc = piece(line1,",",2,"Not Found"), file_reply->qual[row_count].active_ind
      = piece(line1,",",3,"Not Found"),
     file_reply->qual[row_count].pharmacy_type_cd = piece(line1,",",4,"Not Found"), file_reply->qual[
     row_count].location_cd = piece(line1,",",5,"Not Found"), file_reply->qual[row_count].
     inv_location_cd = piece(line1,",",6,"Not Found"),
     file_reply->qual[row_count].organization_id = piece(line1,",",7,"Not Found"), file_reply->qual[
     row_count].parent_resource = piece(line1,",",8,"Not Found")
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(file_reply->qual,row_count)
  WITH nocounter
 ;end select
 IF (( $AUDITCOMMIT="audit"))
  SELECT INTO  $OUTDEV
   qual_description = substring(1,30,file_reply->qual[d1.seq].description), qual_display = substring(
    1,30,file_reply->qual[d1.seq].short_desc), qual_active = substring(1,30,file_reply->qual[d1.seq].
    active_ind),
   qual_pharmacy_type = substring(1,30,file_reply->qual[d1.seq].pharmacy_type_cd), qual_location =
   substring(1,30,file_reply->qual[d1.seq].location_cd), qual_inventory_loc = substring(1,30,
    file_reply->qual[d1.seq].inv_location_cd),
   qual_organization_id = substring(1,30,file_reply->qual[d1.seq].organization_id),
   qual_parent_resource = substring(1,30,file_reply->qual[d1.seq].parent_resource)
   FROM (dummyt d1  WITH seq = value(size(file_reply->qual,5)))
   PLAN (d1)
   WITH nocounter, separator = " ", format
  ;end select
 ELSE
  EXECUTE ams_pharm_wrk_stn:group01
  SET failed_mess = true
  SET serrmsg = "Successfully Inserted"
 ENDIF
#exit_script
END GO
