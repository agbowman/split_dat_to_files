CREATE PROGRAM dcp_catsel_key_call_intl:dba
 DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 SUBROUTINE (loadcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) =f8)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET table_name = build("ERROR-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(table_name)
      SET failed = uar_error
      GO TO exit_script
     OF 1:
      CALL echo(build("INFO-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
        '"',",",option_flag,") not found, CURPROG [",curprog,
        "]"))
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
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
 DECLARE search_string = vc WITH private, noconstant(
  "ocs.mnemonic_key_cap between startrange AND endrange")
 DECLARE result = i2 WITH private, noconstant(- (1))
 DECLARE i18nmsghandle = i4 WITH public, noconstant(0)
 DECLARE last_seed = vc WITH public, noconstant(" ")
 SET h = uar_i18nlocalizationinit(i18nmsghandle,curprog,"",curcclrev)
 SET i18nhandle = uar_i18nalphabet_init()
 SET reply->status_data.status = "F"
 SET s_cnt = 0
 SET show_inactive_ind = request->show_inactive_ind
 SET exact_match_ind = request->exact_match_ind
 SET exact_match_found = 0
 SET virtual_orc = 0
 IF ((request->virtual_view_offset > 0)
  AND (request->virtual_view_offset < 101))
  SET virtual_orc = 1
 ELSE
  SET virtual_orc = 0
  SET request->virtual_view_offset = 99
 ENDIF
 DECLARE buffer = c20 WITH protect, noconstant(fillstring(20," "))
 DECLARE cat_not_size = i4 WITH private, noconstant(0)
 CALL uar_i18nalphabet_highchar(i18nhandle,buffer,size(buffer))
 DECLARE highvalues = vc WITH protect, constant(cnvtupper(trim(buffer)))
 DECLARE seed = vc WITH protect, noconstant(cnvtupper(trim(request->seed,3)))
 SET bcontinue_search = 1
 SET last_seed = seed
 SET last_s_cnt = 0
 DECLARE ordrindxsrt_cd = f8 WITH protected, constant(loadcodevalue(23010,"ORDRINDXSRT",0))
 DECLARE dordrindxsrtpref = f8 WITH protected, noconstant(0)
 SELECT INTO "nl:"
  a.pref_value
  FROM sch_pref a
  PLAN (a
   WHERE a.pref_type_cd=ordrindxsrt_cd
    AND a.parent_table="SYSTEM"
    AND a.parent_id=0
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  DETAIL
   dordrindxsrtpref = a.pref_value
  WITH nocounter
 ;end select
 WHILE (bcontinue_search=1)
   IF (textlen(seed)=0)
    SET buffer = fillstring(20," ")
    CALL uar_i18nalphabet_lowchar(i18nhandle,buffer,size(buffer))
    SET seed = cnvtupper(trim(buffer))
   ENDIF
   SET endrange = highvalues
   SET startrange = seed
   SET loc_size = size(loc_cd->qual,5)
   SET last_seed_added = 0
   CALL echo(build("request seed = ",request->seed))
   IF (validate(request->check_wildcard_ind)=1)
    IF ((request->check_wildcard_ind=1))
     SET result = findstring("*",seed,1,0)
     IF (result=0)
      SET result = findstring("?",seed,1,0)
     ENDIF
     IF (result > 0)
      SET search_string = "ocs.mnemonic_key_cap = patstring(concat(seed, '*'))"
      SET dordrindxsrtpref = 0.0
     ENDIF
    ENDIF
   ENDIF
   SET bcontinue_search = 0
   IF ((((request->exact_match_ind=1)) OR (exact_match_ind=1)) )
    SELECT
     IF (logical_domain_flag > 0)
      ocs.mnemonic
      FROM order_catalog_synonym ocs,
       ocs_facility_r ofr,
       location l,
       organization o,
       surgical_procedure sp,
       surg_proc_detail spd,
       dummyt d1
      PLAN (ocs
       WHERE ocs.mnemonic_key_cap=startrange
        AND ocs.active_ind=1
        AND  $1
        AND ((ocs.hide_flag=null) OR (ocs.hide_flag=0))
        AND ((virtual_orc=0) OR (virtual_orc=1
        AND substring(request->virtual_view_offset,1,ocs.virtual_view)="1")) )
       JOIN (ofr
       WHERE ofr.synonym_id=ocs.synonym_id)
       JOIN (l
       WHERE l.location_cd=ofr.facility_cd)
       JOIN (o
       WHERE o.organization_id=l.organization_id
        AND ((o.logical_domain_id=m_logical_domain_id) OR (((o.organization_id+ 0)=0.0))) )
       JOIN (sp
       WHERE (sp.catalog_cd= Outerjoin(ocs.catalog_cd)) )
       JOIN (d1)
       JOIN (spd
       WHERE spd.catalog_cd=sp.catalog_cd
        AND expand(idx,1,size(loc_cd->qual,5),spd.surg_area_cd,loc_cd->qual[idx].surg_area_cd))
     ELSE
      ocs.mnemonic
      FROM order_catalog_synonym ocs,
       surgical_procedure sp,
       surg_proc_detail spd,
       dummyt d1
      PLAN (ocs
       WHERE ocs.mnemonic_key_cap=startrange
        AND ocs.active_ind=1
        AND  $1
        AND ((ocs.hide_flag=null) OR (ocs.hide_flag=0))
        AND ((virtual_orc=0) OR (virtual_orc=1
        AND substring(request->virtual_view_offset,1,ocs.virtual_view)="1")) )
       JOIN (sp
       WHERE (sp.catalog_cd= Outerjoin(ocs.catalog_cd)) )
       JOIN (d1)
       JOIN (spd
       WHERE spd.catalog_cd=sp.catalog_cd
        AND expand(idx,1,size(loc_cd->qual,5),spd.surg_area_cd,loc_cd->qual[idx].surg_area_cd))
     ENDIF
     INTO "NL:"
     ORDER BY ocs.mnemonic_key_cap, ocs.synonym_id, spd.surg_area_cd
     HEAD ocs.synonym_id
      IF (((sp.catalog_cd=0) OR (((sp.catalog_cd > 0
       AND spd.catalog_cd > 0) OR ((loc_cd->qual[1].surg_area_cd=0))) ))
       AND s_cnt < 50)
       s_cnt += 1
       IF (mod(s_cnt,10)=1
        AND s_cnt != 1)
        stat = alter(reply->qual,(s_cnt+ 9))
       ENDIF
       reply->qual[s_cnt].display = ocs.mnemonic, reply->qual[s_cnt].keyval = ocs.mnemonic_key_cap,
       reply->qual[s_cnt].code = ocs.synonym_id,
       reply->qual[s_cnt].type = ocs.orderable_type_flag, reply->qual[s_cnt].ref_text_mask = ocs
       .ref_text_mask, reply->qual[s_cnt].catalog_cd = ocs.catalog_cd,
       reply->qual[s_cnt].catalog_type_cd = ocs.catalog_type_cd, reply->qual[s_cnt].activity_type_cd
        = ocs.activity_type_cd, reply->qual[s_cnt].activity_subtype_cd = ocs.activity_subtype_cd,
       reply->qual[s_cnt].oe_format_id = ocs.oe_format_id
       IF (exact_match_found=0)
        IF (cnvtupper(request->seed)=cnvtupper(ocs.mnemonic_key_cap))
         reply->exact_match_ind = 1, exact_match_found = 1
        ELSE
         reply->exact_match_ind = 0
        ENDIF
       ENDIF
       reply->qual[s_cnt].cat_not_avail_ind = 1, reply->qual[s_cnt].cat_not_avail_msg =
       uar_i18nbuildmessage(i18nmsghandle,"not_built_in_loc",
        "The procedure %1 is not included within the following surgical location(s) and cannot be added at this time:",
        "s",nullterm(trim(reply->qual[s_cnt].display))), stat = alterlist(reply->qual[s_cnt].
        cat_not_avail_qual,loc_size)
       FOR (x = 1 TO loc_size)
        reply->qual[s_cnt].cat_not_avail_qual[x].surg_area_cd = loc_cd->qual[x].surg_area_cd,reply->
        qual[s_cnt].cat_not_avail_qual[x].location_cd = loc_cd->qual[x].location_cd
       ENDFOR
      ENDIF
      bcontinue_search = 0
     HEAD spd.surg_area_cd
      IF (((sp.catalog_cd=0) OR (((sp.catalog_cd > 0
       AND spd.catalog_cd > 0) OR ((loc_cd->qual[1].surg_area_cd=0))) ))
       AND s_cnt <= 50)
       IF (spd.surg_area_cd > 0.0)
        cat_not_size = size(reply->qual[s_cnt].cat_not_avail_qual,5), loc_idx = locateval(idx,1,
         cat_not_size,spd.surg_area_cd,reply->qual[s_cnt].cat_not_avail_qual[idx].surg_area_cd)
        IF (loc_idx > 0)
         stat = alterlist(reply->qual[s_cnt].cat_not_avail_qual,(cat_not_size - 1),(loc_idx - 1))
         IF (size(reply->qual[s_cnt].cat_not_avail_qual,5)=0)
          reply->qual[s_cnt].cat_not_avail_ind = 0, reply->qual[s_cnt].cat_not_avail_msg = ""
         ENDIF
        ENDIF
       ENDIF
       IF (((sp.catalog_cd=0) OR ((loc_cd->qual[1].surg_area_cd=0))) )
        stat = alterlist(reply->qual[s_cnt].cat_not_avail_qual,0), reply->qual[s_cnt].
        cat_not_avail_ind = 0, reply->qual[s_cnt].cat_not_avail_msg = ""
       ENDIF
      ENDIF
     WITH outerjoin = d1, nocounter
    ;end select
   ELSEIF (dordrindxsrtpref=0.0)
    SELECT
     IF (logical_domain_flag > 0)
      ocs.mnemonic
      FROM order_catalog_synonym ocs,
       ocs_facility_r ofr,
       location l,
       organization o,
       surgical_procedure sp,
       surg_proc_detail spd,
       dummyt d1
      PLAN (ocs
       WHERE parser(search_string)
        AND ocs.active_ind=1
        AND  $1
        AND ((ocs.hide_flag=null) OR (ocs.hide_flag=0))
        AND ((virtual_orc=0) OR (virtual_orc=1
        AND substring(request->virtual_view_offset,1,ocs.virtual_view)="1")) )
       JOIN (ofr
       WHERE ofr.synonym_id=ocs.synonym_id)
       JOIN (l
       WHERE l.location_cd=ofr.facility_cd)
       JOIN (o
       WHERE o.organization_id=l.organization_id
        AND ((o.logical_domain_id=m_logical_domain_id) OR (((o.organization_id+ 0)=0.0))) )
       JOIN (sp
       WHERE (sp.catalog_cd= Outerjoin(ocs.catalog_cd)) )
       JOIN (d1)
       JOIN (spd
       WHERE spd.catalog_cd=sp.catalog_cd
        AND expand(idx,1,size(loc_cd->qual,5),spd.surg_area_cd,loc_cd->qual[idx].surg_area_cd))
     ELSE
      ocs.mnemonic
      FROM order_catalog_synonym ocs,
       surgical_procedure sp,
       surg_proc_detail spd,
       dummyt d1
      PLAN (ocs
       WHERE parser(search_string)
        AND ocs.active_ind=1
        AND  $1
        AND ((ocs.hide_flag=null) OR (ocs.hide_flag=0))
        AND ((virtual_orc=0) OR (virtual_orc=1
        AND substring(request->virtual_view_offset,1,ocs.virtual_view)="1")) )
       JOIN (sp
       WHERE (sp.catalog_cd= Outerjoin(ocs.catalog_cd)) )
       JOIN (d1)
       JOIN (spd
       WHERE spd.catalog_cd=sp.catalog_cd
        AND expand(idx,1,size(loc_cd->qual,5),spd.surg_area_cd,loc_cd->qual[idx].surg_area_cd))
     ENDIF
     INTO "NL:"
     ORDER BY ocs.mnemonic_key_cap, ocs.synonym_id, spd.surg_area_cd
     HEAD ocs.synonym_id
      last_seed_added = 0
      IF (((sp.catalog_cd=0) OR (((sp.catalog_cd > 0
       AND spd.catalog_cd > 0) OR ((loc_cd->qual[1].surg_area_cd=0))) ))
       AND s_cnt < 50)
       s_cnt += 1
       IF (mod(s_cnt,10)=1
        AND s_cnt != 1)
        stat = alter(reply->qual,(s_cnt+ 9))
       ENDIF
       reply->qual[s_cnt].display = ocs.mnemonic, reply->qual[s_cnt].keyval = ocs.mnemonic_key_cap,
       reply->qual[s_cnt].code = ocs.synonym_id,
       reply->qual[s_cnt].type = ocs.orderable_type_flag, reply->qual[s_cnt].ref_text_mask = ocs
       .ref_text_mask, reply->qual[s_cnt].catalog_cd = ocs.catalog_cd,
       reply->qual[s_cnt].catalog_type_cd = ocs.catalog_type_cd, reply->qual[s_cnt].activity_type_cd
        = ocs.activity_type_cd, reply->qual[s_cnt].activity_subtype_cd = ocs.activity_subtype_cd,
       reply->qual[s_cnt].oe_format_id = ocs.oe_format_id
       IF (exact_match_found=0)
        IF (cnvtupper(request->seed)=cnvtupper(ocs.mnemonic_key_cap))
         reply->exact_match_ind = 1, exact_match_found = 1
        ELSE
         reply->exact_match_ind = 0
        ENDIF
       ENDIF
       reply->qual[s_cnt].cat_not_avail_ind = 1, reply->qual[s_cnt].cat_not_avail_msg =
       uar_i18nbuildmessage(i18nmsghandle,"not_built_in_loc",
        "The procedure %1 is not included within the following surgical location(s) and cannot be added at this time:",
        "s",nullterm(trim(reply->qual[s_cnt].display))), stat = alterlist(reply->qual[s_cnt].
        cat_not_avail_qual,loc_size)
       FOR (x = 1 TO loc_size)
        reply->qual[s_cnt].cat_not_avail_qual[x].surg_area_cd = loc_cd->qual[x].surg_area_cd,reply->
        qual[s_cnt].cat_not_avail_qual[x].location_cd = loc_cd->qual[x].location_cd
       ENDFOR
      ENDIF
     HEAD spd.surg_area_cd
      IF (((sp.catalog_cd=0) OR (((sp.catalog_cd > 0
       AND spd.catalog_cd > 0) OR ((loc_cd->qual[1].surg_area_cd=0))) ))
       AND s_cnt <= 50)
       IF (spd.surg_area_cd > 0.0)
        cat_not_size = size(reply->qual[s_cnt].cat_not_avail_qual,5), loc_idx = locateval(idx,1,
         cat_not_size,spd.surg_area_cd,reply->qual[s_cnt].cat_not_avail_qual[idx].surg_area_cd)
        IF (loc_idx > 0)
         stat = alterlist(reply->qual[s_cnt].cat_not_avail_qual,(cat_not_size - 1),(loc_idx - 1))
         IF (size(reply->qual[s_cnt].cat_not_avail_qual,5)=0)
          reply->qual[s_cnt].cat_not_avail_ind = 0, reply->qual[s_cnt].cat_not_avail_msg = ""
         ENDIF
        ENDIF
       ENDIF
       IF (((sp.catalog_cd=0) OR ((loc_cd->qual[1].surg_area_cd=0))) )
        stat = alterlist(reply->qual[s_cnt].cat_not_avail_qual,0), reply->qual[s_cnt].
        cat_not_avail_ind = 0, reply->qual[s_cnt].cat_not_avail_msg = ""
       ENDIF
      ENDIF
     WITH outerjoin = d1, nocounter
    ;end select
   ELSE
    SELECT
     IF (logical_domain_flag > 0)
      ocs.mnemonic
      FROM order_catalog_synonym ocs,
       ocs_facility_r ofr,
       location l,
       organization o,
       surgical_procedure sp,
       surg_proc_detail spd,
       dummyt d1
      PLAN (ocs
       WHERE parser(search_string)
        AND ocs.active_ind=1
        AND  $1
        AND ((ocs.hide_flag=null) OR (ocs.hide_flag=0))
        AND ((virtual_orc=0) OR (virtual_orc=1
        AND substring(request->virtual_view_offset,1,ocs.virtual_view)="1")) )
       JOIN (ofr
       WHERE ofr.synonym_id=ocs.synonym_id)
       JOIN (l
       WHERE l.location_cd=ofr.facility_cd)
       JOIN (o
       WHERE o.organization_id=l.organization_id
        AND ((o.logical_domain_id=m_logical_domain_id) OR (((o.organization_id+ 0)=0.0))) )
       JOIN (sp
       WHERE (sp.catalog_cd= Outerjoin(ocs.catalog_cd)) )
       JOIN (d1)
       JOIN (spd
       WHERE spd.catalog_cd=sp.catalog_cd
        AND expand(idx,1,size(loc_cd->qual,5),spd.surg_area_cd,loc_cd->qual[idx].surg_area_cd))
     ELSE
      ocs.mnemonic
      FROM order_catalog_synonym ocs,
       surgical_procedure sp,
       surg_proc_detail spd,
       dummyt d1
      PLAN (ocs
       WHERE parser(search_string)
        AND ocs.active_ind=1
        AND  $1
        AND ((ocs.hide_flag=null) OR (ocs.hide_flag=0))
        AND ((virtual_orc=0) OR (virtual_orc=1
        AND substring(request->virtual_view_offset,1,ocs.virtual_view)="1")) )
       JOIN (sp
       WHERE (sp.catalog_cd= Outerjoin(ocs.catalog_cd)) )
       JOIN (d1)
       JOIN (spd
       WHERE spd.catalog_cd=sp.catalog_cd
        AND expand(idx,1,size(loc_cd->qual,5),spd.surg_area_cd,loc_cd->qual[idx].surg_area_cd))
     ENDIF
     INTO "NL:"
     ORDER BY ocs.mnemonic_key_cap, ocs.synonym_id, spd.surg_area_cd
     HEAD ocs.synonym_id
      last_seed_added = 0
      IF (((sp.catalog_cd=0) OR (((sp.catalog_cd > 0
       AND spd.catalog_cd > 0) OR ((loc_cd->qual[1].surg_area_cd=0))) ))
       AND s_cnt < 50)
       IF (ocs.mnemonic_key_cap != last_seed)
        last_s_cnt = s_cnt
       ENDIF
       s_cnt += 1
       IF (mod(s_cnt,10)=1
        AND s_cnt != 1)
        stat = alter(reply->qual,(s_cnt+ 9))
       ENDIF
       reply->qual[s_cnt].display = ocs.mnemonic, reply->qual[s_cnt].keyval = ocs.mnemonic_key_cap,
       reply->qual[s_cnt].code = ocs.synonym_id,
       reply->qual[s_cnt].type = ocs.orderable_type_flag, reply->qual[s_cnt].ref_text_mask = ocs
       .ref_text_mask, reply->qual[s_cnt].catalog_cd = ocs.catalog_cd,
       reply->qual[s_cnt].catalog_type_cd = ocs.catalog_type_cd, reply->qual[s_cnt].activity_type_cd
        = ocs.activity_type_cd, reply->qual[s_cnt].activity_subtype_cd = ocs.activity_subtype_cd,
       reply->qual[s_cnt].oe_format_id = ocs.oe_format_id
       IF (exact_match_found=0)
        IF (cnvtupper(request->seed)=cnvtupper(ocs.mnemonic_key_cap))
         reply->exact_match_ind = 1, exact_match_found = 1
        ELSE
         reply->exact_match_ind = 0
        ENDIF
       ENDIF
       reply->qual[s_cnt].cat_not_avail_ind = 1, reply->qual[s_cnt].cat_not_avail_msg =
       uar_i18nbuildmessage(i18nmsghandle,"not_built_in_loc",
        "The procedure %1 is not included within the following surgical location(s) and cannot be added at this time:",
        "s",nullterm(trim(reply->qual[s_cnt].display))), stat = alterlist(reply->qual[s_cnt].
        cat_not_avail_qual,loc_size)
       FOR (x = 1 TO loc_size)
        reply->qual[s_cnt].cat_not_avail_qual[x].surg_area_cd = loc_cd->qual[x].surg_area_cd,reply->
        qual[s_cnt].cat_not_avail_qual[x].location_cd = loc_cd->qual[x].location_cd
       ENDFOR
       last_seed_added = 1
      ENDIF
      last_seed = ocs.mnemonic_key_cap, bcontinue_search = 1
     HEAD spd.surg_area_cd
      IF (((sp.catalog_cd=0) OR (((sp.catalog_cd > 0
       AND spd.catalog_cd > 0) OR ((loc_cd->qual[1].surg_area_cd=0))) ))
       AND s_cnt <= 50)
       IF (spd.surg_area_cd > 0.0)
        cat_not_size = size(reply->qual[s_cnt].cat_not_avail_qual,5), loc_idx = locateval(idx,1,
         cat_not_size,spd.surg_area_cd,reply->qual[s_cnt].cat_not_avail_qual[idx].surg_area_cd)
        IF (loc_idx > 0)
         stat = alterlist(reply->qual[s_cnt].cat_not_avail_qual,(cat_not_size - 1),(loc_idx - 1))
         IF (size(reply->qual[s_cnt].cat_not_avail_qual,5)=0)
          reply->qual[s_cnt].cat_not_avail_ind = 0, reply->qual[s_cnt].cat_not_avail_msg = ""
         ENDIF
        ENDIF
       ENDIF
       IF (((sp.catalog_cd=0) OR ((loc_cd->qual[1].surg_area_cd=0))) )
        stat = alterlist(reply->qual[s_cnt].cat_not_avail_qual,0), reply->qual[s_cnt].
        cat_not_avail_ind = 0, reply->qual[s_cnt].cat_not_avail_msg = ""
       ENDIF
      ENDIF
     WITH outerjoin = d1, nocounter, maxqual(ocs,1000)
    ;end select
   ENDIF
   IF (((s_cnt >= 50) OR ((((request->exact_match_ind=1)) OR (dordrindxsrtpref=0.0)) )) )
    SET bcontinue_search = 0
   ELSE
    IF (exact_match_ind=1)
     SET exact_match_ind = 0
     SELECT INTO "NL:"
      ocs.mnemonic
      FROM order_catalog_synonym ocs
      WHERE ocs.mnemonic_key_cap > seed
      DETAIL
       seed = ocs.mnemonic_key_cap
      WITH nocounter, maxqual(ocs,1)
     ;end select
     IF (curqual=0)
      SET bcontinue_search = 0
     ELSE
      SET bcontinue_search = 1
     ENDIF
    ELSE
     IF (seed=last_seed)
      SET exact_match_ind = 1
      SET s_cnt = last_s_cnt
     ELSE
      SET seed = last_seed
      IF (last_seed_added=1)
       SET s_cnt = last_s_cnt
      ENDIF
     ENDIF
     SET bcontinue_search = 1
    ENDIF
   ENDIF
 ENDWHILE
 IF (s_cnt != size(reply->qual,5))
  SET stat = alter(reply->qual,s_cnt)
 ENDIF
 IF (s_cnt=0)
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORDER_CATALOG_SYNONYM"
  GO TO exit_script
 ENDIF
#exit_script
 CALL uar_i18nalphabet_end(i18nhandle)
 SET reply->status_data.status = "S"
 SET reply->qual_cnt = s_cnt
 SET last_mod = "299248 06/28/11 VB9120"
END GO
