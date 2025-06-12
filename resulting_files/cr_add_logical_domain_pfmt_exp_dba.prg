CREATE PROGRAM cr_add_logical_domain_pfmt_exp:dba
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
  SUBROUTINE (exportreplyascsv(file_name=vc) =i2)
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
  SUBROUTINE (addfieldtoexport(field_name=vc,field_heading=vc,field_type=i2(value,false)) =null)
    IF (trim(field_name,3) != "")
     SET export_reply->column_cnt += 1
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
  SUBROUTINE (freeexport(s_null_index=i2) =null)
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
 DECLARE ld_count = i4 WITH noconstant(0)
 DECLARE exp_count = i4 WITH noconstant(0)
 DECLARE params_count = i4 WITH noconstant(0)
 DECLARE triggers_txt = vc WITH noconstant("")
 DECLARE comment = vc WITH noconstant("")
 DECLARE params_txt = vc WITH noconstant("")
 DECLARE idx = i4 WITH noconstant(0)
 SET hi18n = 0
 SET stat = uar_i18nlocalizationinit(hi18n,curprog,"",curcclrev)
 IF ( NOT (validate(success)))
  DECLARE success = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "CR_ADD_LOGICAL_DOMAIN_PFMT_EXP.SUCCESS","Success"))
 ENDIF
 IF ( NOT (validate(no_related_loc)))
  DECLARE no_related_loc = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "CR_ADD_LOGICAL_DOMAIN_PFMT_EXP.NO_RELATED_LOC","No related locations/clients for trigger"))
 ENDIF
 IF ( NOT (validate(conflict_lds_loc)))
  DECLARE conflict_lds_loc = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "CR_ADD_LOGICAL_DOMAIN_PFMT_EXP.CONFLICT_LDS_LOC",
    "Conflicting logical domains for related locations/clients"))
 ENDIF
 IF ( NOT (validate(conflict_lds_params)))
  DECLARE conflict_lds_params = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "CR_ADD_LOGICAL_DOMAIN_PFMT_EXP.CONFLICT_LDS_PARAMS",
    "Conflicting logical domains for associated triggers"))
 ENDIF
 IF ( NOT (validate(no_related_trig)))
  DECLARE no_related_trig = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "CR_ADD_LOGICAL_DOMAIN_PFMT_EXP.NO_RELATED_TRIG","No related trigger"))
 ENDIF
 IF ( NOT (validate(exp_triggers)))
  DECLARE exp_triggers = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "CR_ADD_LOGICAL_DOMAIN_PFMT_EXP.EXP_TRIGGERS","Expedite Trigger"))
 ENDIF
 IF ( NOT (validate(parameters)))
  DECLARE parameters = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "CR_ADD_LOGICAL_DOMAIN_PFMT_EXP.PARAMETERS","Destination Parameters"))
 ENDIF
 IF ( NOT (validate(na)))
  DECLARE na = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"CR_ADD_LOGICAL_DOMAIN_PFMT_EXP.NA",
    "N/A"))
 ENDIF
 IF ( NOT (validate(logical_domain)))
  DECLARE logical_domain = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "CR_ADD_LOGICAL_DOMAIN_PFMT_EXP.LOGICAL_DOMAIN","Logical Domain"))
 ENDIF
 IF ( NOT (validate(comment_header)))
  DECLARE comment_header = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "CR_ADD_LOGICAL_DOMAIN_PFMT_EXP.COMMENT_HEADER","Comment"))
 ENDIF
 FREE RECORD triggers
 RECORD triggers(
   1 trigger_list[*]
     2 trigger_name_key = vc
     2 trigger_name = vc
     2 active_ind = i2
     2 client_loc_logical_domains[*]
       3 logical_domain_name = vc
       3 logical_domain_id = f8
 )
 FREE RECORD exp_params
 RECORD exp_params(
   1 params_list[*]
     2 params_id = f8
     2 params_name = vc
     2 trigger_logical_domains[*]
       3 logical_domain_name = vc
       3 logical_domain_id = f8
       3 trigger_name_key = vc
     2 associated_trigger_nbr = i4
 )
 FREE RECORD reply_obj
 RECORD reply_obj(
   1 qual_cnt = i4
   1 objarray[*]
     2 name = vc
     2 logical_domain = vc
     2 comment = vc
 )
 SELECT INTO "nl:"
  FROM expedite_trigger et,
   organization o,
   logical_domain ld
  PLAN (et
   WHERE et.expedite_trigger_id > 0)
   JOIN (o
   WHERE o.organization_id=et.organization_id)
   JOIN (ld
   WHERE ld.logical_domain_id=o.logical_domain_id)
  ORDER BY et.name_key, o.logical_domain_id
  HEAD REPORT
   exp_count = 0
  HEAD et.name_key
   exp_count += 1
   IF (mod(exp_count,10)=1)
    stat = alterlist(triggers->trigger_list,(exp_count+ 9))
   ENDIF
   triggers->trigger_list[exp_count].trigger_name_key = et.name_key, triggers->trigger_list[exp_count
   ].trigger_name = et.name, triggers->trigger_list[exp_count].active_ind = et.active_ind,
   ld_count = 0
  HEAD o.logical_domain_id
   IF (et.organization_id > 0)
    ld_count += 1, stat = alterlist(triggers->trigger_list[exp_count].client_loc_logical_domains,
     ld_count), triggers->trigger_list[exp_count].client_loc_logical_domains[ld_count].
    logical_domain_name = ld.mnemonic,
    triggers->trigger_list[exp_count].client_loc_logical_domains[ld_count].logical_domain_id = ld
    .logical_domain_id
   ENDIF
  FOOT REPORT
   stat = alterlist(triggers->trigger_list,exp_count)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(exp_count)),
   expedite_trigger et,
   location l,
   organization o,
   logical_domain ld
  PLAN (d)
   JOIN (et
   WHERE (et.name_key=triggers->trigger_list[d.seq].trigger_name_key)
    AND et.location_cd > 0)
   JOIN (l
   WHERE l.location_cd=et.location_cd)
   JOIN (o
   WHERE o.organization_id=l.organization_id)
   JOIN (ld
   WHERE ld.logical_domain_id=o.logical_domain_id)
  ORDER BY d.seq, o.logical_domain_id
  HEAD d.seq
   ld_count = size(triggers->trigger_list[d.seq].client_loc_logical_domains,5)
  DETAIL
   IF (o.organization_id > 0)
    idx = 0, ldindex = locateval(idx,1,ld_count,ld.logical_domain_id,triggers->trigger_list[d.seq].
     client_loc_logical_domains[idx].logical_domain_id)
    IF (ldindex=0)
     ld_count += 1, stat = alterlist(triggers->trigger_list[d.seq].client_loc_logical_domains,
      ld_count), triggers->trigger_list[d.seq].client_loc_logical_domains[ld_count].
     logical_domain_name = ld.mnemonic,
     triggers->trigger_list[d.seq].client_loc_logical_domains[ld_count].logical_domain_id = ld
     .logical_domain_id
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM expedite_params ep,
   expedite_params_r epr,
   expedite_trigger et
  PLAN (ep
   WHERE ep.expedite_params_id > 0)
   JOIN (epr
   WHERE (epr.expedite_params_id= Outerjoin(ep.expedite_params_id)) )
   JOIN (et
   WHERE (et.expedite_trigger_id= Outerjoin(epr.expedite_trigger_id)) )
  ORDER BY ep.name_key, et.name_key
  HEAD REPORT
   params_count = 0
  HEAD ep.name_key
   params_count += 1, stat = alterlist(exp_params->params_list,params_count), exp_params->
   params_list[params_count].params_id = ep.expedite_params_id,
   exp_params->params_list[params_count].params_name = ep.name, trigcnt = 0, trignbr = 0
  HEAD et.name_key
   idx = 0, expidx = locateval(idx,1,exp_count,et.name_key,triggers->trigger_list[idx].
    trigger_name_key)
   IF (expidx > 0)
    trignbr += 1, trigldcnt = size(triggers->trigger_list[expidx].client_loc_logical_domains,5)
    IF (trigldcnt > 0)
     paramldcnt = size(exp_params->params_list[params_count].trigger_logical_domains,5)
     IF (paramldcnt=0)
      stat = alterlist(exp_params->params_list[params_count].trigger_logical_domains,trigldcnt)
      FOR (i = 1 TO trigldcnt)
        trigcnt += 1, exp_params->params_list[params_count].trigger_logical_domains[trigcnt].
        logical_domain_id = triggers->trigger_list[expidx].client_loc_logical_domains[i].
        logical_domain_id, exp_params->params_list[params_count].trigger_logical_domains[trigcnt].
        logical_domain_name = triggers->trigger_list[expidx].client_loc_logical_domains[i].
        logical_domain_name,
        exp_params->params_list[params_count].trigger_logical_domains[trigcnt].trigger_name_key = et
        .name_key
      ENDFOR
     ELSE
      FOR (i = 1 TO trigldcnt)
        didx = 0, ldidx = locateval(didx,1,paramldcnt,triggers->trigger_list[expidx].
         client_loc_logical_domains[i].logical_domain_id,exp_params->params_list[params_count].
         trigger_logical_domains[didx].logical_domain_id)
        IF (ldidx=0)
         trigcnt += 1, stat = alterlist(exp_params->params_list[params_count].trigger_logical_domains,
          trigcnt), exp_params->params_list[params_count].trigger_logical_domains[trigcnt].
         logical_domain_id = triggers->trigger_list[expidx].client_loc_logical_domains[i].
         logical_domain_id,
         exp_params->params_list[params_count].trigger_logical_domains[trigcnt].logical_domain_name
          = triggers->trigger_list[expidx].client_loc_logical_domains[i].logical_domain_name,
         exp_params->params_list[params_count].trigger_logical_domains[trigcnt].trigger_name_key = et
         .name_key
        ELSE
         exp_params->params_list[params_count].trigger_logical_domains[ldidx].trigger_name_key =
         build(exp_params->params_list[params_count].trigger_logical_domains[ldidx].trigger_name_key,
          ", ",et.name_key)
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
   ENDIF
  FOOT  et.name_key
   exp_params->params_list[params_count].associated_trigger_nbr = trignbr
  WITH nocounter
 ;end select
 SET stat = alterlist(reply_obj->objarray,exp_count)
 FOR (num = 1 TO exp_count)
   SET reply_obj->objarray[num].name = triggers->trigger_list[num].trigger_name
   SET comment = ""
   SET ld_count = size(triggers->trigger_list[num].client_loc_logical_domains,5)
   IF (ld_count=0)
    SET reply_obj->objarray[num].logical_domain = " "
    SET reply_obj->objarray[num].comment = no_related_loc
   ELSEIF (ld_count > 1)
    SET reply_obj->objarray[num].logical_domain = " "
    FOR (ld = 1 TO ld_count)
      SET comment = build(comment,triggers->trigger_list[num].client_loc_logical_domains[ld].
       logical_domain_name," (",cnvtstring(triggers->trigger_list[num].client_loc_logical_domains[ld]
        .logical_domain_id,11,0),"); ")
    ENDFOR
    CALL echo(concat("comment: ",comment))
    SET reply_obj->objarray[num].comment = build(comment," ",conflict_lds_loc)
    CALL echo(reply_obj->objarray[num].comment)
   ELSEIF (ld_count=1)
    SET reply_obj->objarray[num].logical_domain = build(triggers->trigger_list[num].
     client_loc_logical_domains[1].logical_domain_name," (",cnvtstring(triggers->trigger_list[num].
      client_loc_logical_domains[1].logical_domain_id,11,0),")")
    SET reply_obj->objarray[num].comment = success
    UPDATE  FROM expedite_trigger d
     SET d.logical_domain_id = triggers->trigger_list[num].client_loc_logical_domains[1].
      logical_domain_id, d.updt_id = reqinfo->updt_id, d.updt_cnt = (d.updt_cnt+ 1),
      d.updt_dt_tm = cnvtdatetime(sysdate)
     WHERE (d.name_key=triggers->trigger_list[num].trigger_name_key)
     WITH nocounter
    ;end update
   ENDIF
 ENDFOR
 SET stat = alterlist(reply_obj->objarray,(exp_count+ 5))
 FOR (reply_count = (exp_count+ 1) TO (exp_count+ 4))
   SET reply_obj->objarray[reply_count].name = "**********************"
   SET reply_obj->objarray[reply_count].logical_domain = "********************"
   SET reply_obj->objarray[reply_count].comment = "************************"
 ENDFOR
 SET reply_count = (exp_count+ 5)
 SET reply_obj->objarray[reply_count].name = parameters
 SET reply_obj->objarray[reply_count].logical_domain = logical_domain
 SET reply_obj->objarray[reply_count].comment = comment_header
 SET row_cnt = size(reply_obj->objarray,5)
 SET stat = alterlist(reply_obj->objarray,(row_cnt+ params_count))
 SET reply_obj->qual_cnt = (row_cnt+ params_count)
 SET pidx = 0
 FOR (num = (row_cnt+ 1) TO (row_cnt+ params_count))
   SET pidx += 1
   SET reply_obj->objarray[num].name = exp_params->params_list[pidx].params_name
   SET comment = ""
   SET ld_count = size(exp_params->params_list[pidx].trigger_logical_domains,5)
   IF ((exp_params->params_list[pidx].associated_trigger_nbr=0))
    SET reply_obj->objarray[num].logical_domain = " "
    SET reply_obj->objarray[num].comment = no_related_trig
   ELSEIF (ld_count=0)
    SET reply_obj->objarray[num].logical_domain = " "
    SET reply_obj->objarray[num].comment = no_related_loc
   ELSEIF (ld_count > 1)
    SET reply_obj->objarray[num].logical_domain = " "
    FOR (ld = 1 TO ld_count)
      SET comment = build(comment,exp_params->params_list[pidx].trigger_logical_domains[ld].
       logical_domain_name," (",cnvtstring(exp_params->params_list[pidx].trigger_logical_domains[ld].
        logical_domain_id,11,0),"); ")
    ENDFOR
    SET reply_obj->objarray[num].comment = build(comment," ",conflict_lds_params)
   ELSEIF (ld_count=1)
    SET reply_obj->objarray[num].logical_domain = build(exp_params->params_list[pidx].
     trigger_logical_domains[1].logical_domain_name," (",cnvtstring(exp_params->params_list[pidx].
      trigger_logical_domains[1].logical_domain_id,11,0),")")
    SET reply_obj->objarray[num].comment = success
    UPDATE  FROM expedite_params d
     SET d.logical_domain_id = exp_params->params_list[pidx].trigger_logical_domains[1].
      logical_domain_id, d.updt_id = reqinfo->updt_id, d.updt_cnt = (d.updt_cnt+ 1),
      d.updt_dt_tm = cnvtdatetime(sysdate)
     WHERE (d.expedite_params_id=exp_params->params_list[pidx].params_id)
     WITH nocounter
    ;end update
   ENDIF
 ENDFOR
 CALL echorecord(reply_obj)
 COMMIT
 CALL addfieldtoexport("name",exp_triggers,enum_column_type_string)
 CALL addfieldtoexport("logical_domain",logical_domain,enum_column_type_string)
 CALL addfieldtoexport("comment",comment_header,enum_column_type_string)
 CALL exportreplyascsv("cr_add_logical_domain_expedites.csv")
 CALL freeexport(null)
END GO
