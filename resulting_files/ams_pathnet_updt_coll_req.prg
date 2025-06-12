CREATE PROGRAM ams_pathnet_updt_coll_req
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Directory" = "",
  "Pass Input File Name" = ""
  WITH outdev, directory, inputfile
 FREE RECORD request_custom
 RECORD request_custom(
   1 qual[*]
     2 catalog_cd = f8
     2 specimen_type_cd = f8
     2 accession_class_cd = f8
     2 default_collection_method_cd = f8
     2 sequence = f8
     2 species_cd = f8
     2 age_from_minutes = i4
     2 age_to_minutes = i4
     2 coll_priority_cd = f8
     2 spec_cntnr_cd = f8
     2 spec_hndl_cd = f8
     2 min_vol = f8
     2 min_vol_units = c15
     2 aliquot_ind = i2
     2 optional_ind = i2
     2 aliquot_seq = f8
     2 aliquot_route_sequence = i4
     2 coll_class_cd = f8
     2 service_resource_cd = f8
     2 additional_labels = i2
 )
 FREE RECORD file_content
 RECORD file_content(
   1 qual[*]
     2 catalog = vc
     2 specimen_type = vc
     2 accession_class = vc
     2 default_collection_method = vc
     2 age_from_minutes = vc
     2 age_to_minutes = vc
     2 spec_cntnr = vc
     2 spec_hndl = vc
     2 min_vol = vc
     2 min_vol_units = c15
     2 coll_class = vc
     2 service_resource = vc
     2 additional_labels = vc
 )
 DECLARE parse_req_list(row_count=i2,req_list_content=vc,file_content=vc(ref)) = null
 DECLARE parse_appts(row_count=i2,inst_prep_list_content=vc,file_content=vc(ref)) = null
 DECLARE line1 = c1000
 DECLARE line2 = c1000
 DECLARE j = i4
 DECLARE locateroles = c500
 DECLARE sub_content = vc
 SET path = value(logical( $DIRECTORY))
 SET infile =  $INPUTFILE
 SET file_path = build(path,":",infile)
 CALL echo(build(path,":",infile))
 CALL echo(file_path)
 DEFINE rtl2 value(file_path)
 SELECT
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, i = 0, count = 0,
   stat = alterlist(file_content->qual,10)
  HEAD r.line
   line1 = r.line,
   CALL echo(line1)
   IF (size(trim(line1),1) > 0)
    count = (count+ 1)
    IF (count > 1)
     row_count = (row_count+ 1)
     IF (mod(row_count,10)=1
      AND row_count > 10)
      stat = alterlist(file_content->qual,(row_count+ 9))
     ENDIF
     file_content->qual[row_count].catalog = piece(line1,",",1,"Not Found"), file_content->qual[
     row_count].specimen_type = piece(line1,",",2,"Not Found"), file_content->qual[row_count].
     accession_class = piece(line1,",",3,"Not Found"),
     file_content->qual[row_count].default_collection_method = piece(line1,",",4,"Not Found"),
     file_content->qual[row_count].age_from_minutes = piece(line1,",",5,"Not Found"), file_content->
     qual[row_count].age_to_minutes = piece(line1,",",6,"Not Found"),
     file_content->qual[row_count].spec_cntnr = piece(line1,",",7,"Not Found"), file_content->qual[
     row_count].spec_hndl = piece(line1,",",8,"Not Found"), file_content->qual[row_count].min_vol =
     piece(line1,",",9,"Not Found"),
     file_content->qual[row_count].min_vol_units = piece(line1,",",10,"Not Found"), file_content->
     qual[row_count].coll_class = piece(line1,",",11,"Not Found"), file_content->qual[row_count].
     service_resource = piece(line1,",",12,"Not Found"),
     file_content->qual[row_count].additional_labels = piece(line1,",",13,"Not Found")
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(file_content->qual,row_count)
  WITH nocounter
 ;end select
 SET scnt = 0
 FOR (i = 1 TO size(file_content->qual,5))
   SET scnt = (scnt+ 1)
   SET stat = alterlist(request_custom->qual,scnt)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=200
     AND cv.display=trim(file_content->qual[i].catalog)
    HEAD cv.code_value
     request_custom->qual[scnt].catalog_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=2052
     AND cv.display=trim(file_content->qual[i].specimen_type)
    HEAD cv.code_value
     request_custom->qual[scnt].specimen_type_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=2056
     AND cv.display=trim(file_content->qual[i].accession_class)
    HEAD cv.code_value
     request_custom->qual[scnt].accession_class_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=2058
     AND cv.display=trim(file_content->qual[i].default_collection_method)
    HEAD cv.code_value
     request_custom->qual[scnt].default_collection_method_cd = cv.code_value
    WITH nocounter
   ;end select
   SET request_custom->qual[scnt].age_from_minutes = cnvtreal(file_content->qual[i].age_from_minutes)
   SET request_custom->qual[scnt].age_to_minutes = cnvtreal(file_content->qual[i].age_to_minutes)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=2051
     AND cv.display=trim(file_content->qual[i].spec_cntnr)
    HEAD cv.code_value
     request_custom->qual[scnt].spec_cntnr_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=230
     AND cv.display=trim(file_content->qual[i].spec_hndl)
    HEAD cv.code_value
     request_custom->qual[scnt].spec_hndl_cd = cv.code_value
    WITH nocounter
   ;end select
   SET request_custom->qual[scnt].min_vol = cnvtreal(file_content->qual[i].min_vol)
   SET request_custom->qual[scnt].min_vol_units = file_content->qual[i].min_vol_units
   SET request_custom->qual[scnt].aliquot_ind = 0
   SET request_custom->qual[scnt].optional_ind = 0
   SET request_custom->qual[scnt].aliquot_seq = 0
   SET request_custom->qual[scnt].aliquot_route_sequence = 0
   SET request_custom->qual[scnt].coll_priority_cd = 0
   SET request_custom->qual[scnt].species_cd = 0.0
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=231
     AND cv.display=trim(file_content->qual[i].coll_class)
    HEAD cv.code_value
     request_custom->qual[scnt].coll_class_cd = cv.code_value
    WITH nocounter
   ;end select
   IF ((file_content->qual[i].service_resource="ALL"))
    SET request_custom->qual[scnt].service_resource_cd = 0.0
   ELSE
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_set=221
      AND cv.display=trim(file_content->qual[i].service_resource)
     HEAD cv.code_value
      request_custom->qual[scnt].service_resource_cd = cv.code_value
     WITH nocounter
    ;end select
   ENDIF
   SET request_custom->qual[scnt].additional_labels = cnvtint(file_content->qual[i].additional_labels
    )
   CALL echo(build("serv_res:",file_content->qual[i].service_resource))
   SELECT INTO "nl:"
    FROM collection_info_qualifiers ciq
    WHERE (ciq.service_resource_cd=request_custom->qual[scnt].service_resource_cd)
     AND (ciq.specimen_type_cd=request_custom->qual[scnt].specimen_type_cd)
     AND (ciq.catalog_cd=request_custom->qual[scnt].catalog_cd)
    HEAD ciq.sequence
     request_custom->qual[scnt].sequence = ciq.sequence
    WITH nocounter
   ;end select
   EXECUTE scs_chg_collection_info  WITH replace("REQUEST","REQUEST_CUSTOM")
 ENDFOR
 CALL echorecord(request_custom)
END GO
