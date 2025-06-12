CREATE PROGRAM cr_add_logical_domain_dist:dba
 DECLARE enum_column_type_date = i2 WITH protect, constant(true)
 DECLARE enum_column_type_string = i2 WITH protect, constant(2)
 DECLARE enum_column_type_number = i2 WITH protect, constant(3)
 DECLARE enum_column_type_datetm = i2 WITH protect, constant(4)
 FREE RECORD export_reply
 RECORD export_reply(
   1 column_cnt = i4
   1 column[*]
     2 column_name = vc
     2 column_heading = vc
     2 column_type = i2
 )
 IF (validate(exportreplyascsv,char(128))=char(128))
  DECLARE exportreplyascsv(file_name=vc) = i2
  SUBROUTINE exportreplyascsv(file_name)
    DECLARE file_loc = vc WITH noconstant("cer_temp:")
    DECLARE char34 = c1 WITH private, constant(char(34))
    DECLARE delimiter = vc WITH private, noconstant(",")
    DECLARE x = i4 WITH private, noconstant(0)
    DECLARE first_column_ind = i2 WITH private, noconstant(true)
    DECLARE parser_value = vc WITH private, noconstant("")
    DECLARE temp = vc WITH protect, noconstant(" ")
    IF (size(trim(file_name,3),1)=0)
     RETURN(false)
    ENDIF
    SET file_loc = build(file_loc,file_name)
    CALL echo(file_loc)
    IF (validate(reply_obj->objarray)=0)
     CALL echo("reply_obj->objArray does not exist")
     RETURN(false)
    ENDIF
    SET parser_value = concat("select into ",'"',file_loc,'"')
    IF (validate(debug,0)=1)
     CALL echo(parser_value)
    ENDIF
    CALL parser(parser_value,1)
    SET parser_value =
    "from (dummyt d1 with seq = reply_obj->qual_cnt) plan d1  head report temp = build("
    CALL parser(parser_value,1)
    IF (validate(debug,0)=1)
     CALL echo(parser_value)
    ENDIF
    FOR (x = 1 TO export_reply->column_cnt)
      IF (first_column_ind=true)
       SET parser_value = concat("'",char34,"'",", '",export_reply->column[x].column_heading,
        "','",char34,"'")
       SET first_column_ind = false
      ELSE
       SET parser_value = concat(",'",char34,"'",", '",export_reply->column[x].column_heading,
        "','",char34,"'")
      ENDIF
      IF ((x != export_reply->column_cnt))
       SET parser_value = concat(parser_value,', "',delimiter,'"')
      ENDIF
      CALL parser(parser_value,1)
      IF (validate(debug,0)=1)
       CALL echo(parser_value)
      ENDIF
    ENDFOR
    SET first_column_ind = true
    SET parser_value = ") col 0 temp row +1 detail temp =build("
    IF (validate(debug,0)=1)
     CALL echo(parser_value)
    ENDIF
    CALL parser(parser_value,1)
    FOR (x = 1 TO export_reply->column_cnt)
      SET parser_value = ""
      IF ((export_reply->column[x].column_type=enum_column_type_date))
       SET parser_value = build("format(cnvtdatetime(reply_obj->objarray[d1.seq].",export_reply->
        column[x].column_name,',0), "mm/dd/yyyy;;d")')
      ELSEIF ((export_reply->column[x].column_type=enum_column_type_datetm))
       SET parser_value = build("format(cnvtdatetime(reply_obj->objarray[d1.seq].",export_reply->
        column[x].column_name,'), "mm/dd/yyyy;;d")')
      ELSEIF ((export_reply->column[x].column_type=enum_column_type_string))
       SET parser_value = build("build('",char34,"', reply_obj->objarray[d1.seq].",export_reply->
        column[x].column_name,",'",
        char34,"')")
      ELSE
       SET parser_value = build(" evaluate2(if(isNumeric(reply_obj->objarray[d1.seq].",export_reply->
        column[x].column_name,"))")
       SET parser_value = build(parser_value," cnvtstring(reply_obj->objarray[d1.seq].",export_reply
        ->column[x].column_name,",17,2) else ")
       SET parser_value = build(parser_value," build('",char34,"', reply_obj->objarray[d1.seq].",
        export_reply->column[x].column_name,
        ",'",char34,"') endif)")
      ENDIF
      IF ((x < export_reply->column_cnt))
       SET parser_value = build(parser_value,",'",delimiter,"',")
      ENDIF
      CALL parser(parser_value,1)
      IF (validate(debug,0)=1)
       CALL echo(parser_value)
      ENDIF
    ENDFOR
    SET parser_value =
    ") col 0 temp row +1 with nocounter, format=lfstream, noheading, maxcol = 10000, noformfeed, maxrow=1 go"
    IF (validate(debug,0)=1)
     CALL echo(parser_value)
    ENDIF
    CALL parser(parser_value,1)
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF (validate(addfieldtoexport,char(128))=char(128))
  DECLARE addfieldtoexport(field_name=vc,field_heading=vc,field_type=i2(value,false)) = null
  SUBROUTINE addfieldtoexport(field_name,field_heading,field_type)
    IF (trim(field_name,3) != "")
     SET export_reply->column_cnt = (export_reply->column_cnt+ 1)
     SET stat = alterlist(export_reply->column,export_reply->column_cnt)
     SET export_reply->column[export_reply->column_cnt].column_name = trim(field_name,3)
     SET export_reply->column[export_reply->column_cnt].column_heading = uar_i18ngetmessage(hi18n,
      "Val1",nullterm(field_heading))
     SET export_reply->column[export_reply->column_cnt].column_type = field_type
     IF (validate(debug,0)=1)
      CALL echo(build("Adding Field: ",trim(field_name,3)))
      CALL echo(build("Adding Heading: ",trim(field_heading,3)))
      CALL echo(build("Field Type: ",field_type))
     ENDIF
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(freeexport,char(128))=char(128))
  DECLARE freeexport(s_null_index=i2) = null
  SUBROUTINE freeexport(s_null_index)
    FREE RECORD export_reply
  END ;Subroutine
 ENDIF
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE dist_count = i4 WITH noconstant(0)
 DECLARE ld_count = i4 WITH noconstant(0)
 DECLARE x_encntr_count = i4 WITH noconstant(0)
 DECLARE operations = vc WITH noconstant("")
 DECLARE comment = vc WITH noconstant("")
 DECLARE opr_index = f8 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE org_filter_type = i4 WITH constant(1)
 DECLARE loc_filter_type = i4 WITH constant(3)
 DECLARE src_loc = i4 WITH constant(1)
 DECLARE src_opr = i4 WITH constant(2)
 DECLARE src_loc_opr = i4 WITH constant(3)
 SET hi18n = 0
 SET stat = uar_i18nlocalizationinit(hi18n,curprog,"",curcclrev)
 IF ( NOT (validate(success)))
  DECLARE success = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "CR_ADD_LOGICAL_DOMAIN_DIST.SUCCESS","Success"))
 ENDIF
 IF ( NOT (validate(no_related_loc)))
  DECLARE no_related_loc = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "CR_ADD_LOGICAL_DOMAIN_DIST.NO_RELATED_LOC","No related locations/clients"))
 ENDIF
 IF ( NOT (validate(no_related_loc_opr)))
  DECLARE no_related_loc_opr = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "CR_ADD_LOGICAL_DOMAIN_DIST.NO_RELATED_LOC_OPR","No related locations/clients or Operations"))
 ENDIF
 IF ( NOT (validate(conflict_lds_loc)))
  DECLARE conflict_lds_loc = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "CR_ADD_LOGICAL_DOMAIN_DIST.CONFLICT_LDS_LOC",
    "Conflicting logical domain ids for related locations/clients"))
 ENDIF
 IF ( NOT (validate(conflict_lds_loc_opr)))
  DECLARE conflict_lds_loc_opr = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "CR_ADD_LOGICAL_DOMAIN_DIST.CONFLICT_LDS_LOC_OPR",
    "Conflicting logical domain ids for related locations/clients  AND related operations"))
 ENDIF
 IF ( NOT (validate(conflict_lds_opr)))
  DECLARE conflict_lds_opr = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "CR_ADD_LOGICAL_DOMAIN_DIST.CONFLICT_LDS_OPR",
    "Conflicting logical domain ids for related operations"))
 ENDIF
 IF ( NOT (validate(distribution)))
  DECLARE distribution = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "CR_ADD_LOGICAL_DOMAIN_DIST.DISTRIBUTION","Distribution"))
 ENDIF
 IF ( NOT (validate(operation)))
  DECLARE operation = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "CR_ADD_LOGICAL_DOMAIN_DIST.OPERATION","Operation"))
 ENDIF
 IF ( NOT (validate(cross_encounter)))
  DECLARE cross_encounter = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "CR_ADD_LOGICAL_DOMAIN_DIST.CROSS_ENCOUNTER","Cross Encounter"))
 ENDIF
 IF ( NOT (validate(na)))
  DECLARE na = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"CR_ADD_LOGICAL_DOMAIN_DIST.NA",
    "N/A"))
 ENDIF
 IF ( NOT (validate(logical_domain)))
  DECLARE logical_domain = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "CR_ADD_LOGICAL_DOMAIN_DIST.LOGICAL_DOMAIN","Logical Domain"))
 ENDIF
 IF ( NOT (validate(comment_header)))
  DECLARE comment_header = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "CR_ADD_LOGICAL_DOMAIN_DIST.COMMENT_HEADER","Comment"))
 ENDIF
 FREE RECORD distributions
 RECORD distributions(
   1 dist_list[*]
     2 dist_id = f8
     2 dist_name = vc
     2 client_location_lds[*]
       3 logical_domain_name = vc
       3 logical_domain_id = f8
     2 operations_list[*]
       3 operation_id = f8
       3 operation_name = vc
 )
 FREE RECORD x_encounters
 RECORD x_encounters(
   1 law_list[*]
     2 law_id = f8
     2 law_name = vc
     2 client_location_opr_lds[*]
       3 logical_domain_name = vc
       3 logical_domain_id = f8
       3 source = i4
 )
 FREE RECORD reply_obj
 RECORD reply_obj(
   1 qual_cnt = i4
   1 objarray[*]
     2 name = vc
     2 operations = vc
     2 logical_domain = vc
     2 comment = vc
 )
 SELECT INTO "nl:"
  FROM chart_distribution d,
   chart_dist_filter_value cdfv,
   organization o,
   dummyt dt,
   logical_domain ld
  PLAN (d
   WHERE d.distribution_id > 0
    AND d.active_ind=1)
   JOIN (dt)
   JOIN (cdfv
   WHERE cdfv.distribution_id=d.distribution_id
    AND cdfv.type_flag=org_filter_type
    AND cdfv.parent_entity_id > 0)
   JOIN (o
   WHERE cdfv.parent_entity_id=o.organization_id)
   JOIN (ld
   WHERE ld.logical_domain_id=o.logical_domain_id)
  ORDER BY d.dist_descr, o.logical_domain_id
  HEAD REPORT
   dist_count = 0
  HEAD d.distribution_id
   dist_count = (dist_count+ 1)
   IF (mod(dist_count,10)=1)
    stat = alterlist(distributions->dist_list,(dist_count+ 9))
   ENDIF
   distributions->dist_list[dist_count].dist_id = d.distribution_id, distributions->dist_list[
   dist_count].dist_name = d.dist_descr, ld_count = 0
  DETAIL
   IF (o.organization_id > 0)
    idx = 0, ldindex = locateval(idx,1,ld_count,o.logical_domain_id,distributions->dist_list[
     dist_count].client_location_lds[idx].logical_domain_id)
    IF (ldindex=0)
     ld_count = (ld_count+ 1), stat = alterlist(distributions->dist_list[dist_count].
      client_location_lds,ld_count), distributions->dist_list[dist_count].client_location_lds[
     ld_count].logical_domain_name = ld.mnemonic,
     distributions->dist_list[dist_count].client_location_lds[ld_count].logical_domain_id = o
     .logical_domain_id
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(distributions->dist_list,dist_count)
  WITH outerjoin = dt
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(dist_count)),
   chart_dist_filter_value cdfv,
   location l,
   organization o,
   logical_domain ld
  PLAN (d)
   JOIN (cdfv
   WHERE (cdfv.distribution_id=distributions->dist_list[d.seq].dist_id)
    AND cdfv.type_flag=loc_filter_type
    AND cdfv.parent_entity_id > 0)
   JOIN (l
   WHERE l.location_cd=cdfv.parent_entity_id)
   JOIN (o
   WHERE o.organization_id=l.organization_id)
   JOIN (ld
   WHERE ld.logical_domain_id=o.logical_domain_id)
  ORDER BY d.seq, o.logical_domain_id
  HEAD d.seq
   ld_count = size(distributions->dist_list[d.seq].client_location_lds,5)
  DETAIL
   IF (o.organization_id > 0)
    idx = 0, ldindex = locateval(idx,1,ld_count,o.logical_domain_id,distributions->dist_list[d.seq].
     client_location_lds[idx].logical_domain_id)
    IF (ldindex=0)
     ld_count = (ld_count+ 1), stat = alterlist(distributions->dist_list[d.seq].client_location_lds,
      ld_count), distributions->dist_list[d.seq].client_location_lds[ld_count].logical_domain_name =
     ld.mnemonic,
     distributions->dist_list[d.seq].client_location_lds[ld_count].logical_domain_id = o
     .logical_domain_id
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(dist_count)),
   charting_operations o
  PLAN (d)
   JOIN (o
   WHERE o.param_type_flag=2
    AND (cnvtint(o.param)=distributions->dist_list[d.seq].dist_id)
    AND o.active_ind=1)
  HEAD d.seq
   op_count = 0
  DETAIL
   op_count = (op_count+ 1), stat = alterlist(distributions->dist_list[d.seq].operations_list,
    op_count), distributions->dist_list[d.seq].operations_list[op_count].operation_id = o
   .charting_operations_id,
   distributions->dist_list[d.seq].operations_list[op_count].operation_name = o.batch_name
  WITH nocounter
 ;end select
 SET stat = alterlist(reply_obj->objarray,dist_count)
 FOR (num = 1 TO dist_count)
   SET reply_obj->objarray[num].name = build(distributions->dist_list[num].dist_name," (",cnvtstring(
     distributions->dist_list[num].dist_id,11,0),")")
   SET operations = ""
   SET comment = ""
   FOR (op_num = 1 TO size(distributions->dist_list[num].operations_list,5))
     IF (op_num=1)
      SET operations = build(distributions->dist_list[num].operations_list[op_num].operation_name,"(",
       cnvtstring(distributions->dist_list[num].operations_list[op_num].operation_id,11,0),")")
     ELSE
      SET operations = build(operations,"; ",distributions->dist_list[num].operations_list[op_num].
       operation_name,"(",cnvtstring(distributions->dist_list[num].operations_list[op_num].
        operation_id,11,0),
       ")")
     ENDIF
   ENDFOR
   SET reply_obj->objarray[num].operations = operations
   SET ld_count = size(distributions->dist_list[num].client_location_lds,5)
   IF (ld_count=0)
    SET reply_obj->objarray[num].logical_domain = " "
    SET reply_obj->objarray[num].comment = no_related_loc
   ELSEIF (ld_count > 1)
    SET reply_obj->objarray[num].logical_domain = " "
    FOR (ld = 1 TO ld_count)
      SET comment = build(comment,distributions->dist_list[num].client_location_lds[ld].
       logical_domain_name," (",cnvtstring(distributions->dist_list[num].client_location_lds[ld].
        logical_domain_id,11,0),"); ")
    ENDFOR
    SET reply_obj->objarray[num].comment = build(comment," ",conflict_lds_loc)
   ELSEIF (ld_count=1)
    SET reply_obj->objarray[num].logical_domain = build(distributions->dist_list[num].
     client_location_lds[1].logical_domain_name," (",cnvtstring(distributions->dist_list[num].
      client_location_lds[1].logical_domain_id,11,0),")")
    SET reply_obj->objarray[num].comment = success
    UPDATE  FROM chart_distribution d
     SET d.logical_domain_id = distributions->dist_list[num].client_location_lds[1].logical_domain_id
     WHERE (d.distribution_id=distributions->dist_list[num].dist_id)
     WITH nocounter
    ;end update
    IF (size(distributions->dist_list[num].operations_list,5) > 0)
     UPDATE  FROM charting_operations co,
       (dummyt o  WITH seq = size(distributions->dist_list[num].operations_list,5))
      SET co.logical_domain_id = distributions->dist_list[num].client_location_lds[1].
       logical_domain_id
      PLAN (o)
       JOIN (co
       WHERE (co.charting_operations_id=distributions->dist_list[num].operations_list[o.seq].
       operation_id))
      WITH nocounter
     ;end update
    ENDIF
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM chart_law x,
   chart_law_filter_value clfv,
   organization o,
   dummyt dt,
   logical_domain ld
  PLAN (x
   WHERE x.law_id > 0.0
    AND x.active_ind=1)
   JOIN (dt)
   JOIN (clfv
   WHERE clfv.law_id=x.law_id
    AND clfv.type_flag=org_filter_type
    AND clfv.parent_entity_id > 0)
   JOIN (o
   WHERE clfv.parent_entity_id=o.organization_id)
   JOIN (ld
   WHERE ld.logical_domain_id=o.logical_domain_id)
  ORDER BY x.law_descr
  HEAD REPORT
   x_encntr_count = 0
  HEAD x.law_id
   x_encntr_count = (x_encntr_count+ 1)
   IF (mod(x_encntr_count,10)=1)
    stat = alterlist(x_encounters->law_list,(x_encntr_count+ 9))
   ENDIF
   x_encounters->law_list[x_encntr_count].law_id = x.law_id, x_encounters->law_list[x_encntr_count].
   law_name = x.law_descr, ld_count = 0
  DETAIL
   IF (o.organization_id > 0)
    idx = 0, ldindex = locateval(idx,1,size(x_encounters->law_list[x_encntr_count].
      client_location_opr_lds,5),o.logical_domain_id,x_encounters->law_list[x_encntr_count].
     client_location_opr_lds[idx].logical_domain_id)
    IF (ldindex=0)
     ld_count = (ld_count+ 1), stat = alterlist(x_encounters->law_list[x_encntr_count].
      client_location_opr_lds,ld_count), x_encounters->law_list[x_encntr_count].
     client_location_opr_lds[ld_count].logical_domain_name = ld.mnemonic,
     x_encounters->law_list[x_encntr_count].client_location_opr_lds[ld_count].logical_domain_id = o
     .logical_domain_id, x_encounters->law_list[x_encntr_count].client_location_opr_lds[ld_count].
     source = src_loc
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(x_encounters->law_list,x_encntr_count)
  WITH outerjoin = dt
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(x_encntr_count)),
   chart_law_filter_value clfv,
   location l,
   organization o,
   logical_domain ld
  PLAN (d)
   JOIN (clfv
   WHERE (clfv.law_id=x_encounters->law_list[d.seq].law_id)
    AND clfv.type_flag=loc_filter_type
    AND clfv.parent_entity_id > 0)
   JOIN (l
   WHERE l.location_cd=clfv.parent_entity_id)
   JOIN (o
   WHERE o.organization_id=l.organization_id)
   JOIN (ld
   WHERE ld.logical_domain_id=o.logical_domain_id)
  HEAD d.seq
   ld_count = size(x_encounters->law_list[d.seq].client_location_opr_lds,5)
  DETAIL
   IF (o.organization_id > 0)
    idx = 0, ldindex = locateval(idx,1,ld_count,o.logical_domain_id,x_encounters->law_list[d.seq].
     client_location_opr_lds[idx].logical_domain_id)
    IF (ldindex=0)
     ld_count = (ld_count+ 1), stat = alterlist(x_encounters->law_list[d.seq].client_location_opr_lds,
      ld_count), x_encounters->law_list[d.seq].client_location_opr_lds[ld_count].logical_domain_name
      = ld.mnemonic,
     x_encounters->law_list[d.seq].client_location_opr_lds[ld_count].logical_domain_id = o
     .logical_domain_id, x_encounters->law_list[d.seq].client_location_opr_lds[ld_count].source =
     src_loc
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(x_encntr_count)),
   charting_operations o,
   logical_domain ld
  PLAN (d)
   JOIN (o
   WHERE o.param_type_flag=18
    AND (cnvtint(o.param)=x_encounters->law_list[d.seq].law_id)
    AND o.active_ind=1)
   JOIN (ld
   WHERE ld.logical_domain_id=o.logical_domain_id)
  HEAD d.seq
   ld_count = size(x_encounters->law_list[d.seq].client_location_opr_lds,5)
  DETAIL
   idx = 0, ldindex = locateval(idx,1,ld_count,o.logical_domain_id,x_encounters->law_list[d.seq].
    client_location_opr_lds[idx].logical_domain_id)
   IF (ldindex=0)
    ld_count = (ld_count+ 1), stat = alterlist(x_encounters->law_list[d.seq].client_location_opr_lds,
     ld_count), x_encounters->law_list[d.seq].client_location_opr_lds[ld_count].logical_domain_name
     = ld.mnemonic,
    x_encounters->law_list[d.seq].client_location_opr_lds[ld_count].logical_domain_id = o
    .logical_domain_id, x_encounters->law_list[d.seq].client_location_opr_lds[ld_count].source =
    src_opr
   ELSEIF (ldindex > 0)
    IF ((x_encounters->law_list[d.seq].client_location_opr_lds[ldindex].source=src_loc))
     x_encounters->law_list[d.seq].client_location_opr_lds[ldindex].source = src_loc_opr
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply_obj->objarray,((x_encntr_count+ dist_count)+ 5))
 SET reply_obj->qual_cnt = ((dist_count+ x_encntr_count)+ 5)
 FOR (reply_count = (dist_count+ 1) TO (dist_count+ 4))
   SET reply_obj->objarray[reply_count].name = "**********************"
   SET reply_obj->objarray[reply_count].operations = "************************"
   SET reply_obj->objarray[reply_count].logical_domain = "********************"
   SET reply_obj->objarray[reply_count].comment = "************************"
 ENDFOR
 SET reply_count = (dist_count+ 5)
 SET reply_obj->objarray[reply_count].name = cross_encounter
 SET reply_obj->objarray[reply_count].operations = na
 SET reply_obj->objarray[reply_count].logical_domain = logical_domain
 SET reply_obj->objarray[reply_count].comment = comment_header
 FOR (num = 1 TO x_encntr_count)
   SET reply_count = (reply_count+ 1)
   SET reply_obj->objarray[reply_count].name = build(x_encounters->law_list[num].law_name," (",
    cnvtstring(x_encounters->law_list[num].law_id,11,0),")")
   SET reply_obj->objarray[reply_count].operations = "N/A"
   SET ld_count = size(x_encounters->law_list[num].client_location_opr_lds,5)
   IF (ld_count=0)
    SET reply_obj->objarray[reply_count].logical_domain = " "
    SET reply_obj->objarray[reply_count].comment = no_related_loc_opr
   ELSEIF (ld_count > 1)
    SET reply_obj->objarray[reply_count].logical_domain = " "
    SET comment = ""
    FOR (ld = 1 TO ld_count)
      SET comment = build(comment,x_encounters->law_list[num].client_location_opr_lds[ld].
       logical_domain_name,"(",cnvtstring(x_encounters->law_list[num].client_location_opr_lds[ld].
        logical_domain_id,11,0),")",
       "; ")
    ENDFOR
    SET loc_index = locateval(idx,1,ld_count,src_loc,x_encounters->law_list[num].
     client_location_opr_lds[idx].source)
    SET opr_index = locateval(idx,1,ld_count,src_opr,x_encounters->law_list[num].
     client_location_opr_lds[idx].source)
    SET loc_opr_index = locateval(idx,1,ld_count,src_loc_opr,x_encounters->law_list[num].
     client_location_opr_lds[idx].source)
    IF (((loc_opr_index > 0) OR (opr_index > 0
     AND loc_index > 0)) )
     SET comment = build(comment," ",conflict_lds_loc_opr)
    ELSEIF (opr_index > 0)
     SET comment = build(comment," ",conflict_lds_opr)
    ELSE
     SET comment = build(comment," ",conflict_lds_loc)
    ENDIF
    SET reply_obj->objarray[reply_count].comment = comment
   ELSEIF (ld_count=1)
    SET reply_obj->objarray[reply_count].logical_domain = build(x_encounters->law_list[num].
     client_location_opr_lds[1].logical_domain_name,"(",cnvtstring(x_encounters->law_list[num].
      client_location_opr_lds[1].logical_domain_id,11,0),")")
    SET reply_obj->objarray[reply_count].comment = success
    UPDATE  FROM chart_law cl
     SET cl.logical_domain_id = x_encounters->law_list[num].client_location_opr_lds[1].
      logical_domain_id
     WHERE (cl.law_id=x_encounters->law_list[num].law_id)
     WITH nocounter
    ;end update
   ENDIF
 ENDFOR
 COMMIT
 CALL addfieldtoexport("name",distribution,enum_column_type_string)
 CALL addfieldtoexport("operations",operation,enum_column_type_string)
 CALL addfieldtoexport("logical_domain",logical_domain,enum_column_type_string)
 CALL addfieldtoexport("comment",comment_header,enum_column_type_string)
 CALL exportreplyascsv("cr_add_logical_domain_report.csv")
 CALL freeexport(null)
 CALL echorecord(x_encounters)
END GO
