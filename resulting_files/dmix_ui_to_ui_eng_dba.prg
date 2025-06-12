CREATE PROGRAM dmix_ui_to_ui_eng:dba
 CALL echo("<============== Entering dmix_ui_to_ui_eng Script ==============>")
 CALL echo("<===== OEN_PROFILE_UTILS.INC START =====>")
 CALL echo("<===== oen_commmon.inc Begin =====>")
 CALL echo("MOD:003")
 DECLARE whatis(trait_name) = vc
 DECLARE whatisint(trait_name) = i4
 SUBROUTINE whatis(trait_name)
   DECLARE string_value = vc
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(size(oen_proc->trait_list,5)))
    WHERE (oen_proc->trait_list[d.seq].name=trim(cnvtupper(trait_name)))
    DETAIL
     string_value = oen_proc->trait_list[d.seq].value
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL echo(concat("Trait not found: ",trait_name))
   ELSE
    CALL echo(concat("trait value: ",string_value))
    RETURN(string_value)
   ENDIF
 END ;Subroutine
 SUBROUTINE whatisint(trait_name)
   DECLARE string_value = vc
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(size(oen_proc->trait_list,5)))
    WHERE (oen_proc->trait_list[d.seq].name=trim(cnvtupper(trait_name)))
    DETAIL
     string_value = oen_proc->trait_list[d.seq].value
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL echo(concat("Trait not found: ",trait_name))
   ELSE
    CALL echo(concat("trait value: ",string_value))
    RETURN(cnvtint(string_value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (getcernerstring(strmeaning=vc) =vc)
   DECLARE strretval = vc WITH public, noconstant("")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(oen_reply->cerner.stringlist,5)))
    WHERE (oen_reply->cerner.stringlist[d.seq].strmeaning=strmeaning)
    DETAIL
     strretval = oen_reply->cerner.stringlist[d.seq].strval
    WITH nocounter
   ;end select
   RETURN(strretval)
 END ;Subroutine
 SUBROUTINE (getcernerlong(strmeaning=vc) =i4)
   DECLARE dretval = i4 WITH public, noconstant(0.0)
   DECLARE temp = vc WITH private, noconstant("")
   SET temp = validate(oen_reply->cerner,"nocernerarea")
   IF (temp="nocernerarea")
    RETURN("")
   ELSE
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(oen_reply->cerner.longlist,5)))
     WHERE cnvtupper(oen_reply->cerner.longlist[d.seq].strmeaning)=cnvtupper(strmeaning)
     DETAIL
      dretval = oen_reply->cerner.longlist[d.seq].lval
     WITH nocounter
    ;end select
    RETURN(dretval)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getcernerdouble(string_meaning=vc) =f8)
   DECLARE ret_val = f8 WITH public, noconstant(0.0)
   DECLARE temp = vc WITH private, noconstant("")
   SET temp = validate(oen_reply->cerner,"nocernerarea")
   IF (temp="nocernerarea")
    RETURN(0)
   ELSE
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(oen_reply->cerner.doublelist,5)))
     WHERE cnvtupper(oen_reply->cerner.doublelist[d.seq].strmeaning)=cnvtupper(string_meaning)
     DETAIL
      ret_val = oen_reply->cerner.doublelist[d.seq].dval
     WITH nocounter
    ;end select
    RETURN(ret_val)
   ENDIF
 END ;Subroutine
 SUBROUTINE (addcernerstring(strmeaning=vc,strvalue=vc) =vc)
   DECLARE temp = vc WITH private, noconstant("")
   SET temp = validate(oen_reply->cerner,"nocernerarea")
   IF (temp != "nocernerarea")
    SET istringsize = (size(oen_reply->cerner.stringlist,5)+ 1)
    SET stat = alterlist(oen_reply->cerner.stringlist,istringsize)
    SET oen_reply->cerner.stringlist[istringsize].strmeaning = strmeaning
    SET oen_reply->cerner.stringlist[istringsize].strval = strvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE oentrimzeros(number)
   CALL echo("Entering oenTrimZeros subroutine")
   FREE SET t_initial
   FREE SET t_length
   FREE SET t_decimal
   FREE SET t_last_sig
   FREE SET t_final
   FREE SET t_i
   SET t_initial = build(number)
   SET t_length = size(t_initial)
   SET t_decimal = findstring(".",t_initial,1)
   SET t_final = trim(t_initial,3)
   CALL echo(build("    number=",number))
   CALL echo(build("    t_initial=",t_initial))
   IF (t_decimal > 0)
    SET t_last_sig = (t_decimal - 1)
    SET t_i = 0
    FOR (t_i = (t_decimal+ 1) TO t_length)
      IF (substring(t_i,1,t_initial) > "0")
       SET t_last_sig = t_i
      ENDIF
    ENDFOR
    SET t_final = trim(substring(1,t_last_sig,t_initial),3)
   ENDIF
   FREE SET t_initial
   FREE SET t_length
   FREE SET t_decimal
   FREE SET t_last_sig
   FREE SET t_i
   CALL echo(build("    t_final=",t_final))
   CALL echo("Exiting oenTrimZeros subroutine")
   RETURN(t_final)
 END ;Subroutine
 CALL echo("<===== oen_commmon.inc End =====>")
 DECLARE uar_getcvofromcache(p1=f8(ref),p2=f8(ref),p3=i4(ref)) = vc WITH image_axp = "esortl", uar =
 "GetCVOFromCache", image_aix = "libesortl.a(libesortl.o)"
 DECLARE uar_storecvoincache(p1=f8(ref),p2=f8(ref),p3=vc(ref)) = null WITH image_axp = "esortl", uar
  = "StoreCVOInCache", image_aix = "libesortl.a(libesortl.o)"
 DECLARE uar_getcvofromcachewithmeaning(p1=f8(ref),p2=f8(ref),p3=vc(ref),p4=i4(ref)) = vc WITH
 image_axp = "esortl", uar = "GetCVOFromCacheWithMeaning", image_aix = "libesortl.a(libesortl.o)"
 DECLARE uar_storecvoincachewithmeaning(p1=f8(ref),p2=f8(ref),p3=vc(ref),p4=vc(ref)) = null WITH
 image_axp = "esortl", uar = "StoreCVOInCacheWithMeaning", image_aix = "libesortl.a(libesortl.o)"
 SUBROUTINE (get_cvo(dcodevalue=f8,dcontributorsource=f8,straliastypemeaning=vc) =vc)
   DECLARE alias = vc WITH protect, noconstant(" ")
   DECLARE ifound = i4 WITH protect, noconstant(0)
   IF (((dcodevalue=0) OR (dcontributorsource=0)) )
    RETURN("")
   ENDIF
   IF (size(trim(straliastypemeaning)) > 0)
    SET alias = nullterm(uar_getcvofromcachewithmeaning(dcodevalue,dcontributorsource,nullterm(
       straliastypemeaning),ifound))
   ENDIF
   IF (ifound=0)
    SET alias = nullterm(uar_getcvofromcache(dcodevalue,dcontributorsource,ifound))
   ENDIF
   IF ( NOT (ifound))
    IF (size(trim(straliastypemeaning)) > 0)
     SELECT INTO "nl"
      cvo.alias
      FROM code_value_outbound cvo
      PLAN (cvo
       WHERE cvo.contributor_source_cd=dcontributorsource
        AND cvo.code_value=dcodevalue
        AND cvo.alias_type_meaning=straliastypemeaning)
      DETAIL
       alias = cvo.alias
      WITH nocounter
     ;end select
     IF (curqual > 0)
      SET ifound = 1
      CALL uar_storecvoincachewithmeaning(dcodevalue,dcontributorsource,nullterm(straliastypemeaning),
       nullterm(alias))
     ENDIF
    ENDIF
    IF (ifound=0)
     SELECT INTO "nl"
      cvo.alias
      FROM code_value_outbound cvo
      PLAN (cvo
       WHERE cvo.contributor_source_cd=dcontributorsource
        AND cvo.code_value=dcodevalue)
      DETAIL
       alias = cvo.alias
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET alias = trim("")
     ENDIF
     CALL uar_storecvoincache(dcodevalue,dcontributorsource,nullterm(alias))
    ENDIF
   ENDIF
   RETURN(alias)
 END ;Subroutine
 DECLARE uar_sioutwritemessage(p1=i4(ref),p2=vc(ref),p3=vc(ref),p4=i4(ref),p5=vc(ref),
  p6=vc(ref)) = i4 WITH uar = "SiOutWriteMessage", image_aix = "libsirtl.a(libsirtl.o)", image_axp =
 "sirtl"
 DECLARE uar_sioutgetcmblevel(null) = i4 WITH uar = "SiOutGetCmbLevel", image_aix =
 "libsirtl.a(libsirtl.o)", image_axp = "sirtl"
 DECLARE uar_sisrvdump(p1=i4(ref)) = null WITH uar = "SiSrvDump", image_aix =
 "libsirtl.a(libsirtl.o)", image_axp = "sirtl"
 IF ((validate(esierror,- (1))=- (1)))
  DECLARE esierror = i4 WITH public, constant(0)
  DECLARE esiwarning = i4 WITH public, constant(1)
  DECLARE esiaudit = i4 WITH public, constant(2)
  DECLARE esiinfo = i4 WITH public, constant(3)
  DECLARE esidebug = i4 WITH public, constant(4)
 ENDIF
 SUBROUTINE (si_out_write_message(level=i4(value),message=vc(value)) =i4)
   CALL uar_sioutwritemessage(level,nullterm(curprog),"",0,nullterm(message),
    "")
 END ;Subroutine
 CALL echo("<===== ESO_GET_CODE.INC Begin =====>")
 CALL echo("MOD:008")
 DECLARE eso_get_code_meaning(code) = c12
 DECLARE eso_get_code_display(code) = c40
 DECLARE eso_get_meaning_by_codeset(x_code_set,x_meaning) = f8
 DECLARE eso_get_code_set(code) = i4
 DECLARE eso_get_alias_or_display(code,contrib_src_cd) = vc
 SUBROUTINE eso_get_code_meaning(code)
   CALL echo("Entering eso_get_code_meaning subroutine")
   CALL echo(build("    code=",code))
   FREE SET t_meaning
   DECLARE t_meaning = c12
   SET t_meaning = fillstring(12," ")
   IF (code > 0)
    IF (validate(readme_data,0))
     CALL echo("    A Readme is calling this script")
     CALL echo("    selecting rows from code_value table")
     SELECT INTO "nl:"
      cv.*
      FROM code_value cv
      WHERE cv.code_value=code
       AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
       AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND cv.active_ind=1
      DETAIL
       t_meaning = cv.cdf_meaning
      WITH maxqual(cv,1)
     ;end select
     IF (curqual < 1)
      CALL echo("    no rows qualified on code_value table")
     ENDIF
    ELSE
     SET t_meaning = uar_get_code_meaning(cnvtreal(code))
     IF (trim(t_meaning)="")
      CALL echo("    uar_get_code_meaning failed")
      CALL echo("    selecting row from code_value table")
      SELECT INTO "nl:"
       cv.*
       FROM code_value cv
       WHERE cv.code_value=code
        AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
        AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND cv.active_ind=1
       DETAIL
        t_meaning = cv.cdf_meaning
       WITH maxqual(cv,1)
      ;end select
      IF (curqual < 1)
       CALL echo("    no rows qualified on code_value table")
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL echo(build("    t_meaning=",t_meaning))
   CALL echo("Exiting eso_get_code_meaning subroutine")
   RETURN(trim(t_meaning,3))
 END ;Subroutine
 SUBROUTINE eso_get_code_display(code)
   CALL echo("Entering eso_get_code_display subroutine")
   CALL echo(build("    code=",code))
   FREE SET t_display
   DECLARE t_display = c40
   SET t_display = fillstring(40," ")
   IF (code > 0)
    IF (validate(readme_data,0))
     CALL echo("   A Readme is calling this script")
     CALL echo("   Selecting rows from code_value table")
     SELECT INTO "nl:"
      cv.*
      FROM code_value cv
      WHERE cv.code_value=code
       AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
       AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND cv.active_ind=1
      DETAIL
       t_display = cv.display
      WITH maxqual(cv,1)
     ;end select
     IF (curqual < 1)
      CALL echo("    no rows qualified on code_value table")
     ENDIF
    ELSE
     SET t_display = uar_get_code_display(cnvtreal(code))
     IF (trim(t_display)="")
      CALL echo("    uar_get_code_display failed")
      CALL echo("    selecting row from code_value table")
      SELECT INTO "nl:"
       cv.*
       FROM code_value cv
       WHERE cv.code_value=code
        AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
        AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND cv.active_ind=1
       DETAIL
        t_display = cv.display
       WITH maxqual(cv,1)
      ;end select
      IF (curqual < 1)
       CALL echo("    no rows qualified on code_value table")
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL echo(build("    t_display=",t_display))
   CALL echo("Exiting eso_get_code_display subroutine")
   RETURN(trim(t_display,3))
 END ;Subroutine
 SUBROUTINE eso_get_meaning_by_codeset(x_code_set,x_meaning)
   CALL echo("Entering eso_get_meaning_by_codeset subroutine")
   CALL echo(build("    code_set=",x_code_set))
   CALL echo(build("    meaning=",x_meaning))
   FREE SET t_code
   DECLARE t_code = f8
   SET t_code = 0.0
   IF (x_code_set > 0
    AND trim(x_meaning) > "")
    FREE SET t_meaning
    DECLARE t_meaning = c12
    SET t_meaning = fillstring(12," ")
    SET t_meaning = x_meaning
    FREE SET t_rc
    IF (validate(readme_data,0))
     CALL echo("   A Readme is calling this script")
     CALL echo("   Selecting rows from code_value table")
     SELECT INTO "nl:"
      cv.*
      FROM code_value cv
      WHERE cv.code_set=x_code_set
       AND cv.cdf_meaning=trim(x_meaning)
       AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
       AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND cv.active_ind=1
      DETAIL
       t_code = cv.code_value
      WITH maxqual(cv,1)
     ;end select
     IF (curqual < 1)
      CALL echo("    no rows qualified on code_value table")
     ENDIF
    ELSE
     SET t_rc = uar_get_meaning_by_codeset(cnvtint(x_code_set),nullterm(t_meaning),1,t_code)
     IF (t_code <= 0)
      CALL echo("    uar_get_meaning_by_codeset failed")
      CALL echo("    selecting row from code_value table")
      SELECT INTO "nl:"
       cv.*
       FROM code_value cv
       WHERE cv.code_set=x_code_set
        AND cv.cdf_meaning=trim(x_meaning)
        AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
        AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND cv.active_ind=1
       DETAIL
        t_code = cv.code_value
       WITH maxqual(cv,1)
      ;end select
      IF (curqual < 1)
       CALL echo("    no rows qualified on code_value table")
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL echo(build("    t_code=",t_code))
   CALL echo("Exiting eso_get_meaning_by_codeset subroutine")
   RETURN(t_code)
 END ;Subroutine
 SUBROUTINE eso_get_code_set(code)
   CALL echo("Entering eso_get_code_set subroutine")
   CALL echo(build("    code=",code))
   DECLARE icode_set = i4 WITH private, noconstant(0)
   IF (code > 0)
    IF (validate(readme_data,0))
     CALL echo("   A Readme is calling this script")
     CALL echo("   Selecting rowS from code_value table")
     SELECT INTO "nl:"
      cv.code_set
      FROM code_value cv
      WHERE cv.code_value=code
       AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
       AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND cv.active_ind=1
      DETAIL
       icode_set = cv.code_set
      WITH maxqual(cv,1)
     ;end select
     IF (curqual < 1)
      CALL echo("    no rows qualified on code_value table")
     ENDIF
    ELSE
     SET icode_set = uar_get_code_set(cnvtreal(code))
     IF ( NOT (icode_set > 0))
      CALL echo("    uar_get_code_set failed")
      CALL echo("    selecting row from code_value table")
      SELECT INTO "nl:"
       cv.code_set
       FROM code_value cv
       WHERE cv.code_value=code
        AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
        AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND cv.active_ind=1
       DETAIL
        icode_set = cv.code_set
       WITH maxqual(cv,1)
      ;end select
      IF (curqual < 1)
       CALL echo("    no rows qualified on code_value table")
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL echo(build("    Code_set=",icode_set))
   CALL echo("Exiting eso_get_code_set subroutine")
   RETURN(icode_set)
 END ;Subroutine
 SUBROUTINE eso_get_alias_or_display(code,contrib_src_cd)
   CALL echo("Entering eso_get_alias_or_display")
   CALL echo(build("   code            = ",code))
   CALL echo(build("   contrib_src_cd = ",contrib_src_cd))
   FREE SET t_alias_or_display
   DECLARE t_alias_or_display = vc
   SET t_alias_or_display = " "
   IF ( NOT (code > 0.0))
    RETURN(t_alias_or_display)
   ENDIF
   IF (contrib_src_cd > 0.0)
    SELECT INTO "nl:"
     cvo.alias
     FROM code_value_outbound cvo
     WHERE cvo.code_value=code
      AND cvo.contributor_source_cd=contrib_src_cd
     DETAIL
      IF (cvo.alias > "")
       t_alias_or_display = cvo.alias
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (size(trim(t_alias_or_display))=0)
    CALL echo("Alias not found, checking code value display")
    SET t_alias_or_display = eso_get_code_display(code)
   ENDIF
   CALL echo("Exiting eso_get_alias_or_display")
   RETURN(t_alias_or_display)
 END ;Subroutine
 CALL echo("<===== ESO_GET_CODE.INC End =====>")
 IF ( NOT (validate(profile_def)))
  RECORD profile_def(
    1 profiles[*]
      2 profile_ident = vc
      2 fields[*]
        3 field_ident = vc
        3 primary_source_cd = f8
        3 primary_source_display = vc
        3 primary_default_alias = vc
        3 secondary_source_cd = f8
        3 secondary_source_display = vc
        3 secondary_default_alias = vc
  ) WITH persist
  DECLARE uar_si_set_asis(p1=i4(value),p2=vc(ref),p3=vc(ref),p5=i4(value)) = null WITH persist
 ENDIF
 RECORD related_oids_rec(
   1 organization_id = f8
   1 contributor_system_cd = f8
   1 alias_pools[*]
     2 alias_pool_cd = f8
   1 result
     2 relation_type_flag = i2
     2 related_oids[*]
       3 alias_pool_cd = f8
       3 alias_pool_oid = vc
 )
 DECLARE list_size = i4 WITH noconstant(0)
 DECLARE list_size2 = i4 WITH noconstant(0)
 DECLARE lpos = i4 WITH noconstant(0)
 DECLARE lnum = i4 WITH noconstant(0)
 DECLARE lcount = i4 WITH noconstant(0)
 DECLARE lidx = i4 WITH noconstant(0)
 DECLARE lidx1 = i4 WITH noconstant(0)
 DECLARE profile_idx = i4 WITH noconstant(0)
 DECLARE field_idx = i4 WITH noconstant(0)
 DECLARE field_count = i4 WITH noconstant(0)
 DECLARE profile_count = i4 WITH noconstant(0)
 DECLARE lpos_profile = i4 WITH noconstant(0)
 DECLARE lpos_field = i4 WITH noconstant(0)
 DECLARE hcerner = i4 WITH noconstant(0)
 DECLARE hitem = i4 WITH noconstant(0)
 DECLARE hprsnlitem = i4 WITH noconstant(0)
 DECLARE haliasitem = i4 WITH noconstant(0)
 DECLARE hcontrol_group = i4 WITH noconstant(0)
 DECLARE hmsh_group = i4 WITH noconstant(0)
 DECLARE hassign_auth = i4 WITH noconstant(0)
 DECLARE primary_source_cd = f8 WITH noconstant(0.0)
 DECLARE alias_pool_cd = f8 WITH noconstant(0.0)
 DECLARE feed_primary_source_cd = f8 WITH noconstant(0.0)
 DECLARE feed_secondary_source_cd = f8 WITH noconstant(0.0)
 DECLARE sparsedvalue = f8 WITH noconstant(0.0)
 DECLARE soutboundalias = vc WITH noconstant("")
 DECLARE sfieldvalue = vc WITH noconstant("")
 DECLARE profile_ident = vc WITH noconstant("")
 DECLARE field_ident = vc WITH noconstant("")
 DECLARE mailto_cd = f8 WITH constant(eso_get_meaning_by_codeset(23056,"MAILTO"))
 DECLARE istdprofiledebugind = i4 WITH protect, constant(whatisint("STD_PROFILE_DEBUG_IND"))
 DECLARE primary_source_display = vc WITH noconstant("")
 SUBROUTINE (locate_profile_field(profile_ident=vc,field_ident=vc,profile_idx=i4(ref),field_idx=i4(
   ref)) =i2)
   SET profile_idx = 0
   SET field_idx = 0
   SET lpos_profile = locateval(lnum,1,size(profile_def->profiles,5),profile_ident,profile_def->
    profiles[lnum].profile_ident)
   IF (lpos_profile > 0)
    SET profile_idx = lpos_profile
    SET lpos_field = locateval(lnum,1,size(profile_def->profiles[lpos_profile].fields,5),field_ident,
     profile_def->profiles[lpos_profile].fields[lnum].field_ident)
    IF (lpos_field > 0)
     SET field_idx = lpos_field
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (get_related_oids(dummy=i2) =null)
   IF (size(related_oids_rec->alias_pools,5) > 0)
    SET lcount = 0
    SELECT INTO "nl:"
     so.oid_txt, so.entity_id, ssor.contributor_system_cd
     FROM si_system_org_reltn ssor,
      si_oid so,
      (dummyt d1  WITH seq = size(related_oids_rec->alias_pools,5))
     PLAN (d1)
      JOIN (ssor
      WHERE (ssor.organization_id=related_oids_rec->organization_id)
       AND ssor.contributor_system_cd IN (related_oids_rec->contributor_system_cd, 0.0)
       AND (ssor.alias_pool_cd=related_oids_rec->alias_pools[d1.seq].alias_pool_cd))
      JOIN (so
      WHERE so.entity_type="ALIAS_POOL"
       AND so.entity_id=ssor.alias_pool_cd)
     ORDER BY ssor.contributor_system_cd DESC
     HEAD ssor.contributor_system_cd
      specific_contributor_found = 0, related_oids_rec->result.relation_type_flag = 2
     DETAIL
      IF (ssor.contributor_system_cd > 0)
       specific_contributor_found = 1
      ENDIF
      IF (((ssor.contributor_system_cd > 0) OR (specific_contributor_found=0)) )
       lcount = (size(related_oids_rec->result.related_oids,5)+ 1), stat = alterlist(related_oids_rec
        ->result.related_oids,lcount), related_oids_rec->result.related_oids[lcount].alias_pool_cd =
       so.entity_id,
       related_oids_rec->result.related_oids[lcount].alias_pool_oid = so.oid_txt
      ENDIF
     WITH nocounter
    ;end select
    IF ((related_oids_rec->result.relation_type_flag > 0))
     RETURN
    ENDIF
    SELECT INTO "nl:"
     so.oid_txt, so.entity_id
     FROM si_oid so,
      (dummyt d1  WITH seq = size(related_oids_rec->alias_pools,5))
     PLAN (d1)
      JOIN (so
      WHERE so.entity_type="ALIAS_POOL"
       AND (so.entity_id=related_oids_rec->alias_pools[d1.seq].alias_pool_cd))
     HEAD REPORT
      related_oids_rec->result.relation_type_flag = 1
     DETAIL
      lcount = (size(related_oids_rec->result.related_oids,5)+ 1), stat = alterlist(related_oids_rec
       ->result.related_oids,lcount), related_oids_rec->result.related_oids[lcount].alias_pool_cd =
      so.entity_id,
      related_oids_rec->result.related_oids[lcount].alias_pool_oid = so.oid_txt
     WITH nocounter
    ;end select
    IF ((related_oids_rec->result.relation_type_flag > 0))
     RETURN
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (set_profile_field(profile_ident=vc,field_ident=vc,primary_source_cd=f8,
  primary_source_display=vc,secondary_source_cd=f8,secondary_source_display=vc) =null)
   CALL set_profile_field_with_default(profile_ident,field_ident,primary_source_cd,
    primary_source_display,"",
    secondary_source_cd,secondary_source_display,"")
 END ;Subroutine
 SUBROUTINE (set_profile_field_with_default(profile_ident=vc,field_ident=vc,primary_source_cd=f8,
  primary_source_display=vc,primary_default_alias=vc,secondary_source_cd=f8,secondary_source_display=
  vc,secondary_default_alias=vc) =null)
   IF (locate_profile_field(profile_ident,field_ident,profile_idx,field_idx)=1)
    SET profile_def->profiles[profile_idx].fields[field_idx].primary_source_cd = primary_source_cd
    SET profile_def->profiles[profile_idx].fields[field_idx].primary_source_display =
    primary_source_display
    SET profile_def->profiles[profile_idx].fields[field_idx].primary_default_alias =
    primary_default_alias
    SET profile_def->profiles[profile_idx].fields[field_idx].secondary_source_cd =
    secondary_source_cd
    SET profile_def->profiles[profile_idx].fields[field_idx].secondary_source_display =
    secondary_source_display
    SET profile_def->profiles[profile_idx].fields[field_idx].secondary_default_alias =
    secondary_default_alias
   ELSE
    IF (profile_idx=0)
     SET profile_count = (size(profile_def->profiles,5)+ 1)
     SET stat = alterlist(profile_def->profiles,profile_count)
     SET profile_def->profiles[profile_count].profile_ident = profile_ident
     SET profile_idx = profile_count
    ENDIF
    IF (field_idx=0)
     SET field_count = (size(profile_def->profiles[profile_idx].fields,5)+ 1)
     SET stat = alterlist(profile_def->profiles[profile_idx].fields,field_count)
     SET profile_def->profiles[profile_idx].fields[field_count].field_ident = field_ident
     SET profile_def->profiles[profile_idx].fields[field_count].primary_source_cd = primary_source_cd
     SET profile_def->profiles[profile_idx].fields[field_count].primary_source_display =
     primary_source_display
     SET profile_def->profiles[profile_idx].fields[field_count].primary_default_alias =
     primary_default_alias
     SET profile_def->profiles[profile_idx].fields[field_count].secondary_source_cd =
     secondary_source_cd
     SET profile_def->profiles[profile_idx].fields[field_count].secondary_source_display =
     secondary_source_display
     SET profile_def->profiles[profile_idx].fields[field_count].secondary_default_alias =
     secondary_default_alias
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (set_profile_field_by_cdf(profile_ident=vc,field_ident=vc,primary_source_cdf=vc,
  primary_source_display=vc,secondary_source_cdf=vc,secondary_source_display=vc) =null)
   CALL set_profile_field_by_cdf_with_defaults(profile_ident,field_ident,primary_source_cdf,
    primary_source_display,"",
    secondary_source_cdf,secondary_source_display,"")
 END ;Subroutine
 SUBROUTINE (set_profile_field_by_cdf_with_defaults(profile_ident=vc,field_ident=vc,
  primary_source_cdf=vc,primary_source_display=vc,primary_default_alias=vc,secondary_source_cdf=vc,
  secondary_source_display=vc,secondary_default_alias=vc) =null)
   SET primary_source_cd = uar_get_code_by("MEANING",73,primary_source_cdf)
   IF (secondary_source_cdf != "")
    SET secondary_source_cd = uar_get_code_by("MEANING",73,secondary_source_cdf)
   ELSE
    SET secondary_source_cd = 0.0
   ENDIF
   CALL set_profile_field_with_default(profile_ident,field_ident,primary_source_cd,
    primary_source_display,primary_default_alias,
    secondary_source_cd,secondary_source_display,secondary_default_alias)
 END ;Subroutine
 SUBROUTINE (set_cust_profile_fields(dummy=i2) =null)
   IF (validate(cust_profile_def))
    FOR (lidx = 1 TO size(cust_profile_def->profiles,5))
      SET profile_ident = cust_profile_def->profiles[lidx].profile_ident
      SET lpos_profile = locateval(lnum,1,size(profile_def->profiles,5),profile_ident,profile_def->
       profiles[lnum].profile_ident)
      IF (lpos_profile > 0)
       FOR (lidx1 = 1 TO size(cust_profile_def->profiles[lidx].fields,5))
         SET field_ident = cust_profile_def->profiles[lidx].fields[lidx1].field_ident
         SET lpos_field = locateval(lnum,1,size(profile_def->profiles[lpos_profile].fields,5),
          field_ident,profile_def->profiles[lpos_profile].fields[lnum].field_ident)
         IF (lpos_field > 0)
          SET primary_source_cd = cust_profile_def->profiles[lidx].fields[lidx1].primary_source_cd
          SET primary_source_display = cust_profile_def->profiles[lidx].fields[lidx1].
          primary_source_display
          SET primary_default_alias = cust_profile_def->profiles[lidx].fields[lidx1].
          primary_default_alias
          SET secondary_source_cd = cust_profile_def->profiles[lidx].fields[lidx1].
          secondary_source_cd
          SET secondary_source_display = cust_profile_def->profiles[lidx].fields[lidx1].
          secondary_source_display
          SET secondary_default_alias = cust_profile_def->profiles[lidx].fields[lidx1].
          secondary_default_alias
          CALL set_profile_field_with_default(profile_ident,field_ident,primary_source_cd,
           primary_source_display,primary_default_alias,
           secondary_source_cd,secondary_source_display,secondary_default_alias)
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_ce_field(hce=i4,code_value=f8,contributor_source_cd=f8,
  contributor_source_display=vc,default_alias=vc,alternate_ind=i2,struct_type_ind=i2) =i2)
   IF (struct_type_ind=0)
    IF (alternate_ind=0)
     SET code_field_name = "IDENTIFIER"
     SET text_field_name = "TEXT"
     SET coding_system_field_name = "CODING_SYSTEM"
    ELSE
     SET code_field_name = "ALT_IDENTIFIER"
     SET text_field_name = "ALT_TEXT"
     SET coding_system_field_name = "ALT_CODING_SYSTEM"
    ENDIF
   ELSE
    IF (alternate_ind=0)
     SET code_field_name = "VALUE_1"
     SET text_field_name = "VALUE_2"
     SET coding_system_field_name = "VALUE_3"
    ELSE
     SET code_field_name = "VALUE_4"
     SET text_field_name = "VALUE_5"
     SET coding_system_field_name = "VALUE_6"
    ENDIF
   ENDIF
   SET soutboundalias = get_cvo(code_value,contributor_source_cd,contributor_source_display)
   IF (soutboundalias != "")
    CALL uar_srvsetstring(hce,nullterm(code_field_name),nullterm(soutboundalias))
    CALL uar_srvsetstring(hce,nullterm(coding_system_field_name),nullterm(contributor_source_display)
     )
    CALL set_text_field(hce,text_field_name,code_value)
    RETURN(1)
   ELSEIF (default_alias != "")
    CALL uar_srvsetstring(hce,nullterm(code_field_name),nullterm(default_alias))
    CALL uar_srvsetstring(hce,nullterm(coding_system_field_name),nullterm(contributor_source_display)
     )
    RETURN(1)
   ELSE
    IF (uar_srvgettype(hce,nullterm(text_field_name))=7)
     CALL uar_si_set_asis(hce,nullterm(text_field_name),nullterm(""),0)
    ELSE
     CALL uar_srvsetstring(hce,nullterm(text_field_name),nullterm(""))
    ENDIF
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (set_text_field(hce=i4,field_name=vc,code_value=f8) =null)
   DECLARE stemptext = vc WITH protect, noconstant("")
   IF (uar_srvgettype(hce,nullterm(field_name))=7)
    IF (uar_get_code_set(code_value)=54)
     SET stemptext = uar_get_code_description(code_value)
     CALL uar_si_set_asis(hce,nullterm(field_name),nullterm(stemptext),size(stemptext,1))
    ELSEIF (uar_srvgetasissize(hce,nullterm(field_name))=0)
     SET stemptext = uar_get_code_display(code_value)
     CALL uar_si_set_asis(hce,nullterm(field_name),nullterm(stemptext),size(stemptext,1))
    ENDIF
   ELSE
    IF (uar_get_code_set(code_value)=54)
     CALL uar_srvsetstring(hce,nullterm(field_name),nullterm(uar_get_code_description(code_value)))
    ELSEIF (uar_srvgetstringptr(hce,nullterm(field_name))="")
     CALL uar_srvsetstring(hce,nullterm(field_name),nullterm(uar_get_code_display(code_value)))
    ENDIF
   ENDIF
   IF (uar_srvfieldexists(hce,"ORIGINAL_TEXT"))
    IF (uar_get_code_set(code_value)=54)
     CALL uar_srvsetstring(hce,nullterm("ORIGINAL_TEXT"),nullterm(uar_get_code_description(code_value
        )))
    ELSEIF (uar_srvgetstringptr(hce,"ORIGINAL_TEXT")="")
     CALL uar_srvsetstring(hce,nullterm("ORIGINAL_TEXT"),nullterm(uar_get_code_display(code_value)))
    ENDIF
   ENDIF
   IF (uar_srvfieldexists(hce,nullterm("VALUE_9")))
    IF (uar_srvgetstringptr(hce,nullterm("VALUE_9"))="")
     CALL uar_srvsetstring(hce,nullterm("VALUE_9"),nullterm(uar_get_code_display(code_value)))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (get_cerner_area_double(hmsg=i4,strmean=vc) =f8)
   IF (hmsg > 0)
    SET hcerner = uar_srvgetstruct(hmsg,"Cerner")
   ENDIF
   IF (hcerner)
    SET list_size = uar_srvgetitemcount(hcerner,"doubleList")
    IF (list_size > 0)
     FOR (lcount = 0 TO (list_size - 1))
       SET hitem = uar_srvgetitem(hcerner,"doubleList",lcount)
       IF (hitem > 0)
        SET sfieldvalue = nullterm(uar_srvgetstringptr(hitem,"strMeaning"))
       ENDIF
       IF (sfieldvalue=strmean)
        RETURN(uar_srvgetdouble(hitem,"dVal"))
       ENDIF
     ENDFOR
    ELSE
     CALL si_out_write_message(esidebug,"doubleList is empty")
    ENDIF
   ELSE
    CALL si_out_write_message(esierror,"uar_SrvGetStruct() failed to get cerner struct")
   ENDIF
   RETURN(0.0)
 END ;Subroutine
 SUBROUTINE (get_msh_handle(hmsg=i4) =i4)
   IF (hmsg > 0)
    SET hcontrol_group = uar_srvgetitem(hmsg,"CONTROL_GROUP",0)
    IF (hcontrol_group > 0)
     SET hmsh_group = uar_srvgetitem(hcontrol_group,"MSH",0)
     RETURN(hmsh_group)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (get_contributor_system_cd(dummy=i2) =f8)
   DECLARE spackeso = vc WITH private, noconstant("")
   SET spackeso = trim(whatis("PACKESO"),3)
   IF (spackeso="")
    RETURN(0.0)
   ELSE
    RETURN(cnvtreal(spackeso))
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_msh_facility_oids(hmsh=i4,organization_id=f8,contributor_system_cd=f8,
  organization_oid=vc) =null)
  DECLARE sreceivingfacilityoidtxt = vc WITH protect, noconstant("")
  IF (hmsh > 0)
   IF (organization_oid="")
    SET organization_oid = get_organization_oid(organization_id)
   ENDIF
   IF (organization_oid != "")
    SET hitem = uar_srvgetstruct(hmsh,"sending_facility")
    IF (hitem != 0)
     CALL uar_srvsetstring(hitem,"UNIV_ID",nullterm(organization_oid))
     CALL uar_srvsetstring(hitem,"UNIV_ID_TYPE",nullterm("ISO"))
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    oid_txt
    FROM si_oid so
    WHERE so.entity_type="CONTRIBUTORSYSTEM"
     AND so.entity_id=contributor_system_cd
    DETAIL
     sreceivingfacilityoidtxt = so.oid_txt
    WITH nocounter
   ;end select
   IF (sreceivingfacilityoidtxt != "")
    SET hitem = uar_srvgetstruct(hmsh,"receiving_facility")
    IF (hitem != 0)
     CALL uar_srvsetstring(hitem,"UNIV_ID",nullterm(sreceivingfacilityoidtxt))
     CALL uar_srvsetstring(hitem,"UNIV_ID_TYPE",nullterm("ISO"))
    ENDIF
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE (filter_person_or_encounter_aliases(hparent=i4,alias_list_name=vc,organization_id=f8,
  contributor_system_cd=f8,is_struct=i2) =null)
  SET lcount = 0
  IF (hparent > 0)
   SET stat = initrec(related_oids_rec)
   SET related_oids_rec->organization_id = organization_id
   SET related_oids_rec->contributor_system_cd = contributor_system_cd
   IF (is_struct=1)
    SET hitem = uar_srvgetstruct(hparent,nullterm(alias_list_name))
    IF (hitem > 0)
     SET hassign_auth = uar_srvgetstruct(hitem,"ASSIGN_AUTH")
    ENDIF
    IF (hassign_auth > 0)
     SET sfieldvalue = nullterm(uar_srvgetstringptr(hassign_auth,"NAME_ID"))
    ENDIF
    SET sparsedvalue = parse_value(sfieldvalue)
    IF ((sparsedvalue != - (1)))
     SET lcount += 1
     SET stat = alterlist(related_oids_rec->alias_pools,lcount)
     SET related_oids_rec->alias_pools[lcount].alias_pool_cd = sparsedvalue
    ENDIF
    CALL get_related_oids(0)
    IF ((related_oids_rec->result.relation_type_flag > 0))
     CALL uar_srvsetstring(hassign_auth,"UNIV_ID",nullterm(related_oids_rec->result.related_oids[1].
       alias_pool_oid))
     CALL uar_srvsetstring(hassign_auth,"UNIV_ID_TYPE",nullterm("ISO"))
    ENDIF
   ELSE
    SET list_size = uar_srvgetitemcount(hparent,nullterm(alias_list_name))
    IF (list_size > 0)
     FOR (lidx = 0 TO (list_size - 1))
       SET hitem = uar_srvgetitem(hparent,nullterm(alias_list_name),lidx)
       IF (hitem > 0)
        SET hassign_auth = uar_srvgetstruct(hitem,"ASSIGN_AUTH")
       ENDIF
       IF (hassign_auth > 0)
        SET sfieldvalue = nullterm(uar_srvgetstringptr(hassign_auth,"NAME_ID"))
       ENDIF
       SET sparsedvalue = parse_value(sfieldvalue)
       IF ((sparsedvalue != - (1)))
        SET lcount += 1
        SET stat = alterlist(related_oids_rec->alias_pools,lcount)
        SET related_oids_rec->alias_pools[lcount].alias_pool_cd = sparsedvalue
       ENDIF
     ENDFOR
     CALL get_related_oids(0)
     IF ((related_oids_rec->result.relation_type_flag > 0))
      SET lidx = 0
      WHILE ((lidx <= (list_size - 1)))
        SET hitem = uar_srvgetitem(hparent,nullterm(alias_list_name),lidx)
        IF (hitem > 0)
         SET hassign_auth = uar_srvgetstruct(hitem,"ASSIGN_AUTH")
        ENDIF
        IF (hassign_auth > 0)
         SET sfieldvalue = nullterm(uar_srvgetstringptr(hassign_auth,"NAME_ID"))
        ENDIF
        SET sparsedvalue = parse_value(sfieldvalue)
        IF ((sparsedvalue != - (1)))
         SET alias_pool_cd = sparsedvalue
         SET lpos = locateval(lnum,1,size(related_oids_rec->result.related_oids,5),alias_pool_cd,
          related_oids_rec->result.related_oids[lnum].alias_pool_cd)
         IF (lpos > 0)
          CALL uar_srvsetstring(hassign_auth,"UNIV_ID",nullterm(related_oids_rec->result.
            related_oids[lpos].alias_pool_oid))
          CALL uar_srvsetstring(hassign_auth,"UNIV_ID_TYPE",nullterm("ISO"))
         ELSE
          CALL uar_srvremoveitem(hparent,nullterm(alias_list_name),lidx)
          SET lidx -= 1
          SET list_size -= 1
         ENDIF
        ELSE
         CALL uar_srvremoveitem(hparent,nullterm(alias_list_name),lidx)
         SET lidx -= 1
         SET list_size -= 1
        ENDIF
        SET lidx += 1
      ENDWHILE
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE (filter_encounter_personnel_aliases(hmsg=i4,organization_id=f8,contributor_system_cd=f8
  ) =null)
  DECLARE laliascount = i4 WITH private, noconstant(0)
  IF (hmsg > 0)
   SET stat = initrec(related_oids_rec)
   SET lcount = 0
   SET related_oids_rec->organization_id = organization_id
   SET related_oids_rec->contributor_system_cd = contributor_system_cd
   SET hcerner = uar_srvgetstruct(hmsg,"Cerner")
   IF (hcerner > 0)
    SET hprsnl_info = uar_srvgetstruct(hcerner,"PRSNL_INFO")
   ENDIF
   IF (hprsnl_info > 0)
    SET hprsnl = uar_srvgetitem(hprsnl_info,"PRSNL",0)
    SET list_size = uar_srvgetitemcount(hprsnl_info,"PRSNL")
   ENDIF
   IF (list_size > 0)
    FOR (lidx = 0 TO (list_size - 1))
      IF (hprsnl_info > 0)
       SET hprsnlitem = uar_srvgetitem(hprsnl_info,"PRSNL",lidx)
      ENDIF
      SET list_size2 = 0
      IF (hprsnlitem > 0)
       SET list_size2 = uar_srvgetitemcount(hprsnlitem,"ALIAS")
      ENDIF
      FOR (lidx1 = 0 TO (list_size2 - 1))
        SET haliasitem = uar_srvgetitem(hprsnlitem,"ALIAS",lidx1)
        SET alias_pool_cd = 0.0
        IF (haliasitem > 0)
         SET alias_pool_cd = uar_srvgetdouble(haliasitem,"ALIAS_POOL_CD")
        ENDIF
        IF (alias_pool_cd > 0)
         SET lcount += 1
         SET stat = alterlist(related_oids_rec->alias_pools,lcount)
         SET related_oids_rec->alias_pools[lcount].alias_pool_cd = alias_pool_cd
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   CALL get_related_oids(0)
   IF ((related_oids_rec->result.relation_type_flag > 0))
    FOR (lidx = 0 TO (list_size - 1))
      IF (hprsnl_info > 0)
       SET hprsnlitem = uar_srvgetitem(hprsnl_info,"PRSNL",lidx)
      ENDIF
      SET list_size2 = 0
      IF (hprsnlitem > 0)
       SET list_size2 = uar_srvgetitemcount(hprsnlitem,"ALIAS")
       SET laliascount = uar_srvgetshort(hprsnlitem,"ALIAS_COUNT")
      ENDIF
      SET lidx1 = 0
      WHILE ((lidx1 <= (list_size2 - 1)))
        SET haliasitem = uar_srvgetitem(hprsnlitem,"ALIAS",lidx1)
        IF (haliasitem > 0)
         SET alias_pool_cd = uar_srvgetdouble(haliasitem,"ALIAS_POOL_CD")
        ENDIF
        SET lpos = locateval(lnum,1,size(related_oids_rec->result.related_oids,5),alias_pool_cd,
         related_oids_rec->result.related_oids[lnum].alias_pool_cd)
        IF (lpos > 0)
         CALL uar_srvsetstring(haliasitem,nullterm("ALIAS_POOL_OID"),nullterm(related_oids_rec->
           result.related_oids[lpos].alias_pool_oid))
        ELSE
         SET laliascount -= 1
         CALL uar_srvremoveitem(hprsnlitem,nullterm("ALIAS"),lidx1)
         SET stat = uar_srvsetshort(hprsnlitem,"ALIAS_COUNT",laliascount)
         SET lidx1 -= 1
         SET list_size2 -= 1
        ENDIF
        SET lidx1 += 1
      ENDWHILE
    ENDFOR
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE (populate_coded_string(hparent=i4,field_name=vc,profile_ident=vc,field_ident=vc) =null)
   IF (hparent > 0)
    SET sfieldvalue = nullterm(uar_srvgetstringptr(hparent,nullterm(field_name)))
    SET sparsedvalue = parse_value(sfieldvalue)
    IF ((sparsedvalue != - (1)))
     SET code_value = sparsedvalue
     IF (locate_profile_field(profile_ident,field_ident,profile_idx,field_idx)=0)
      CALL echo("the profile/field combination is NOT configured")
     ELSE
      IF (istdprofiledebugind > 0)
       CALL uar_srvsetstring(hparent,nullterm(field_name),nullterm(build("CD:",code_value)))
      ELSE
       CALL uar_srvsetstring(hparent,nullterm(field_name),nullterm(""))
      ENDIF
      SET primary_source_cd = profile_def->profiles[profile_idx].fields[field_idx].primary_source_cd
      SET primary_source_display = profile_def->profiles[profile_idx].fields[field_idx].
      primary_source_display
      IF (primary_source_cd > 0)
       SET soutboundalias = get_cvo(code_value,primary_source_cd,primary_source_display)
       IF (soutboundalias != "")
        CALL uar_srvsetstring(hparent,nullterm(field_name),nullterm(soutboundalias))
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_coded_string_list(hparent=i4,list_name=vc,field_name=vc,profile_ident=vc,
  field_ident=vc) =null)
   IF (hparent > 0)
    SET list_size = uar_srvgetitemcount(hparent,nullterm(list_name))
    IF (list_size > 0)
     FOR (lcount = 0 TO (list_size - 1))
       SET hitem = uar_srvgetitem(hparent,nullterm(list_name),lcount)
       IF (hitem > 0)
        SET sfieldvalue = nullterm(uar_srvgetstringptr(hitem,nullterm(field_name)))
       ENDIF
       SET sparsedvalue = parse_value(sfieldvalue)
       IF ((sparsedvalue != - (1)))
        SET code_value = sparsedvalue
        IF (locate_profile_field(profile_ident,field_ident,profile_idx,field_idx)=0)
         CALL echo("the profile/field combination is NOT configured")
        ELSE
         IF (istdprofiledebugind > 0)
          CALL uar_srvsetstring(hitem,nullterm(field_name),nullterm(build("CD:",code_value)))
         ELSE
          CALL uar_srvsetstring(hitem,nullterm(field_name),nullterm(""))
         ENDIF
         SET primary_source_cd = profile_def->profiles[profile_idx].fields[field_idx].
         primary_source_cd
         SET primary_source_display = profile_def->profiles[profile_idx].fields[field_idx].
         primary_source_display
         IF (primary_source_cd > 0)
          SET soutboundalias = get_cvo(code_value,primary_source_cd,primary_source_display)
          IF (soutboundalias != "")
           CALL uar_srvsetstring(hitem,nullterm(field_name),nullterm(soutboundalias))
          ENDIF
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_coded_entry(hce=i4,profile_ident=vc,field_ident=vc) =null)
   IF (hce > 0)
    SET code_value = 0.0
    SET sfieldvalue = nullterm(uar_srvgetstringptr(hce,"IDENTIFIER"))
    SET sparsedvalue = parse_value(sfieldvalue)
    IF ((sparsedvalue != - (1)))
     SET code_value = sparsedvalue
     IF (locate_profile_field(profile_ident,field_ident,profile_idx,field_idx)=0)
      CALL echo("the profile/field combination is NOT configured")
     ELSE
      IF (istdprofiledebugind > 0)
       CALL uar_srvsetstring(hce,"IDENTIFIER",nullterm(build("CD:",code_value)))
      ELSE
       CALL uar_srvsetstring(hce,"IDENTIFIER",nullterm(""))
      ENDIF
      IF ((profile_def->profiles[profile_idx].fields[field_idx].primary_source_cd > 0))
       CALL populate_ce_field(hce,code_value,profile_def->profiles[profile_idx].fields[field_idx].
        primary_source_cd,profile_def->profiles[profile_idx].fields[field_idx].primary_source_display,
        profile_def->profiles[profile_idx].fields[field_idx].primary_default_alias,
        0,0)
      ELSE
       IF (populate_ce_field(hce,code_value,feed_primary_source_cd,build("##CVA##,",
         feed_primary_source_cd),"",
        0,0)=0)
        CALL populate_ce_field(hce,code_value,feed_secondary_source_cd,build("##CVA##,",
          feed_secondary_source_cd),"",
         0,0)
       ENDIF
      ENDIF
      IF ((profile_def->profiles[profile_idx].fields[field_idx].secondary_source_cd > 0))
       CALL populate_ce_field(hce,code_value,profile_def->profiles[profile_idx].fields[field_idx].
        secondary_source_cd,profile_def->profiles[profile_idx].fields[field_idx].
        secondary_source_display,profile_def->profiles[profile_idx].fields[field_idx].
        secondary_default_alias,
        1,0)
      ELSE
       IF ((profile_def->profiles[profile_idx].fields[field_idx].primary_source_cd > 0))
        IF (populate_ce_field(hce,code_value,feed_primary_source_cd,build("##CVA##,",
          feed_primary_source_cd),"",
         1,0)=0)
         CALL populate_ce_field(hce,code_value,feed_secondary_source_cd,build("##CVA##,",
           feed_secondary_source_cd),"",
          1,0)
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_feed_source(contributor_system_cd=f8) =null)
   SELECT INTO "nl:"
    cs.contributor_source_cd, cs.alt_contrib_src_cd
    FROM contributor_system cs
    WHERE cs.contributor_system_cd=contributor_system_cd
    DETAIL
     feed_primary_source_cd = cs.contributor_source_cd, feed_secondary_source_cd = cs
     .alt_contrib_src_cd
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (parse_value(parsestring=vc) =f8)
   DECLARE firstcomma = i4 WITH private, noconstant(0)
   DECLARE secondcomma = i4 WITH private, noconstant(0)
   IF (findstring("##CVA##",parsestring)=0)
    RETURN(- (1))
   ENDIF
   SET firstcomma = findstring(",",parsestring)
   SET secondcomma = findstring(",",parsestring,(firstcomma+ 1))
   IF (secondcomma > 0)
    RETURN(cnvtreal(substring((firstcomma+ 1),((secondcomma - firstcomma) - 1),parsestring)))
   ELSE
    RETURN(cnvtreal(substring((firstcomma+ 1),textlen(parsestring),parsestring)))
   ENDIF
 END ;Subroutine
 SUBROUTINE (get_organization_oid(organization_id=f8) =vc)
  SELECT INTO "nl:"
   oid_txt
   FROM si_oid so
   WHERE so.entity_type="ORGANIZATION"
    AND so.entity_id=organization_id
   DETAIL
    organization_oid = so.oid_txt
   WITH nocounter
  ;end select
  RETURN(organization_oid)
 END ;Subroutine
 SUBROUTINE (populate_obs_entry(hobs=i4,profile_ident=vc,field_ident=vc) =null)
   IF (hobs > 0)
    SET code_value = 0.0
    SET sfieldvalue = nullterm(uar_srvgetstringptr(hobs,"VALUE_1"))
    SET sparsedvalue = parse_value(sfieldvalue)
    IF ((sparsedvalue != - (1)))
     SET code_value = sparsedvalue
     IF (locate_profile_field(profile_ident,field_ident,profile_idx,field_idx)=0)
      CALL echo("the profile/field combination is NOT configured")
     ELSE
      IF (istdprofiledebugind > 0)
       CALL uar_srvsetstring(hobs,"VALUE_1",nullterm(build("CD:",code_value)))
      ELSE
       CALL uar_srvsetstring(hobs,"VALUE_1",nullterm(""))
      ENDIF
      IF ((profile_def->profiles[profile_idx].fields[field_idx].primary_source_cd > 0))
       CALL populate_ce_field(hobs,code_value,profile_def->profiles[profile_idx].fields[field_idx].
        primary_source_cd,profile_def->profiles[profile_idx].fields[field_idx].primary_source_display,
        profile_def->profiles[profile_idx].fields[field_idx].primary_default_alias,
        0,1)
      ELSE
       IF (populate_ce_field(hobs,code_value,feed_primary_source_cd,build("##CVA##,",
         feed_primary_source_cd),"",
        0,1)=0)
        CALL populate_ce_field(hobs,code_value,feed_secondary_source_cd,build("##CVA##,",
          feed_secondary_source_cd),"",
         0,1)
       ENDIF
      ENDIF
      IF ((profile_def->profiles[profile_idx].fields[field_idx].secondary_source_cd > 0))
       CALL populate_ce_field(hobs,code_value,profile_def->profiles[profile_idx].fields[field_idx].
        secondary_source_cd,profile_def->profiles[profile_idx].fields[field_idx].
        secondary_source_display,profile_def->profiles[profile_idx].fields[field_idx].
        secondary_default_alias,
        1,1)
      ELSE
       IF ((profile_def->profiles[profile_idx].fields[field_idx].primary_source_cd > 0))
        IF (populate_ce_field(hobs,code_value,feed_primary_source_cd,build("##CVA##,",
          feed_primary_source_cd),"",
         1,1)=0)
         CALL populate_ce_field(hobs,code_value,feed_secondary_source_cd,build("##CVA##,",
           feed_secondary_source_cd),"",
          1,1)
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (logtosiaudit(hmsg=i4,entity_name=vc,entity_id=f8) =null)
   DECLARE message_ctrl_id = vc WITH protect, noconstant("")
   DECLARE messg_type = vc WITH protect, noconstant("")
   DECLARE messg_trigger = vc WITH protect, noconstant("")
   DECLARE hmsh = i4 WITH protect, noconstant(0)
   DECLARE hitem = i4 WITH protect, noconstant(0)
   DECLARE dcontribcd = f8 WITH protect, noconstant(0.0)
   DECLARE msh_receiving_facility = vc WITH protect, noconstant("")
   DECLARE msh_sending_facility = vc WITH protect, noconstant("")
   RECORD tmp_request(
     1 si_audit_qual = i4
     1 si_audit[*]
       2 ensure_type = c3
       2 si_audit_id = f8
       2 person_id = f8
       2 entity_name = c250
       2 entity_id = f8
       2 msg_ident = c250
       2 msg_creation_dt_tm = dq8
       2 refer_to_msg_ident = c250
       2 msg_type_txt = c250
       2 msg_trig_action_txt = c250
       2 send_app_ident = c250
       2 recv_app_ident = c250
       2 status_cd = f8
       2 error_cd = f8
       2 error_text = c500
       2 sys_direction_cd = f8
       2 trn_msg_ident = c250
       2 trn_conv_ident = c250
       2 trn_ref_to_msg_ident = c250
       2 queue_id = f8
       2 send_fac_ident = c250
       2 recv_fac_ident = c250
       2 retain_until_dt_tm = dq8
   )
   RECORD tmp_reply(
     1 si_audit_qual = i2
     1 si_audit[*]
       2 si_audit_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET hmsh = get_msh_handle(hmsg)
   IF (hmsh > 0)
    SET hitem = uar_srvgetstruct(hmsh,"message_ctrl_id")
    IF (hitem > 0)
     SET message_ctrl_id = nullterm(uar_srvgetstringptr(hitem,"ctrl_id1"))
    ENDIF
    SET hitem = uar_srvgetstruct(hmsh,"receiving_facility")
    IF (hitem > 0)
     SET msh_receiving_facility = nullterm(uar_srvgetstringptr(hitem,"univ_id"))
    ENDIF
    SET hitem = uar_srvgetstruct(hmsh,"sending_facility")
    IF (hitem > 0)
     SET msh_sending_facility = nullterm(uar_srvgetstringptr(hitem,"univ_id"))
    ENDIF
    SET hitem = uar_srvgetstruct(hmsh,"message_type")
    IF (hitem > 0)
     SET messg_type = nullterm(uar_srvgetstringptr(hitem,"messg_type"))
     SET messg_trigger = nullterm(uar_srvgetstringptr(hitem,"messg_trigger"))
    ENDIF
    IF ( NOT (validate(g_strprofilesendapp)))
     DECLARE g_strprofilesendapp = vc WITH protect, persist, noconstant(" ")
     DECLARE g_strprofilerecvapp = vc WITH protect, persist, noconstant(" ")
     DECLARE g_ofp_receiving_facility = vc WITH protect, persist, noconstant("")
     DECLARE g_ofp_sending_facility = vc WITH protect, persist, noconstant("")
     DECLARE dsendappcd = f8 WITH protect, constant(eso_get_meaning_by_codeset(14874,"SEND_APP"))
     DECLARE drecvappcd = f8 WITH protect, constant(eso_get_meaning_by_codeset(14874,"RECV_APP"))
     DECLARE dsendfaccd = f8 WITH protect, constant(eso_get_meaning_by_codeset(14874,"SEND_FAC"))
     DECLARE drecvfaccd = f8 WITH protect, constant(eso_get_meaning_by_codeset(14874,"RECV_FAC"))
     SET dcontribcd = get_contributor_system_cd(0)
     IF (dcontribcd > 0.0)
      SELECT INTO "nl:"
       o.null_string, o.process_type_cd, o.contributor_system_cd
       FROM outbound_field_processing o
       WHERE o.contributor_system_cd=dcontribcd
        AND o.process_type_cd IN (drecvappcd, dsendappcd, dsendfaccd, drecvfaccd)
       DETAIL
        IF (o.process_type_cd=drecvappcd)
         g_strprofilerecvapp = trim(o.null_string)
        ELSEIF (o.process_type_cd=dsendappcd)
         g_strprofilesendapp = trim(o.null_string)
        ELSEIF (o.process_type_cd=dsendfaccd)
         g_ofp_sending_facility = trim(o.null_string)
        ELSEIF (o.process_type_cd=drecvfaccd)
         g_ofp_receiving_facility = trim(o.null_string)
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
    SET tmp_request->si_audit_qual = 1
    SET stat = alterlist(tmp_request->si_audit,1)
    SET tmp_request->si_audit[1].msg_ident = message_ctrl_id
    SET tmp_request->si_audit[1].msg_creation_dt_tm = cnvtdatetime(sysdate)
    SET tmp_request->si_audit[1].msg_type_txt = messg_type
    SET tmp_request->si_audit[1].msg_trig_action_txt = messg_trigger
    SET tmp_request->si_audit[1].send_app_ident = g_strprofilesendapp
    SET tmp_request->si_audit[1].recv_app_ident = g_strprofilerecvapp
    IF (msh_sending_facility != trim(""))
     SET tmp_request->si_audit[1].send_fac_ident = msh_sending_facility
    ELSE
     SET tmp_request->si_audit[1].send_fac_ident = g_ofp_sending_facility
    ENDIF
    IF (msh_receiving_facility != trim(""))
     SET tmp_request->si_audit[1].recv_fac_ident = msh_receiving_facility
    ELSE
     SET tmp_request->si_audit[1].recv_fac_ident = g_ofp_receiving_facility
    ENDIF
    SET tmp_request->si_audit[1].sys_direction_cd = eso_get_meaning_by_codeset(14869,"FROM_HNA")
    SET tmp_request->si_audit[1].entity_id = entity_id
    SET tmp_request->si_audit[1].entity_name = entity_name
    SET tmp_request->si_audit[1].status_cd = eso_get_meaning_by_codeset(27400,"SUCCESS")
    SET tmp_request->si_audit[1].ensure_type = "ADD"
    IF (messg_type="ORU"
     AND entity_name="ORDERS")
     SET tmp_request->si_audit[1].retain_until_dt_tm = datetimeadd(tmp_request->si_audit[1].
      msg_creation_dt_tm,2190)
    ELSE
     SET tmp_request->si_audit[1].retain_until_dt_tm = 0.0
    ENDIF
    EXECUTE si_ens_audit  WITH replace("REQUEST","TMP_REQUEST"), replace("REPLY","TMP_REPLY")
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE (update_xtn_emails(hparent=i4,phone_list_name=vc) =null)
   DECLARE listsize = i2 WITH protect, noconstant(0)
   DECLARE sparsedvalue = f8 WITH protect, noconstant(0.0)
   IF (hparent > 0)
    SET listsize = uar_srvgetitemcount(hparent,nullterm(phone_list_name))
    FOR (lcount = 0 TO (listsize - 1))
     SET hphone = uar_srvgetitem(hparent,nullterm(phone_list_name),lcount)
     IF (hphone > 0)
      SET sparsedvalue = parse_value(nullterm(uar_srvgetstringptr(hphone,"equip_type_cd")))
      IF (sparsedvalue=mailto_cd)
       CALL uar_srvsetstring(hphone,"telecom_use_cd","NET")
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_coded_entry_alt(hce=i4) =null)
   IF (hce > 0)
    SET code_value = 0.0
    SET sfieldvalue = nullterm(uar_srvgetstringptr(hce,"ALT_IDENTIFIER"))
    SET sparsedvalue = parse_value(sfieldvalue)
    IF ((sparsedvalue != - (1)))
     SET code_value = sparsedvalue
     IF (istdprofiledebugind > 0)
      CALL uar_srvsetstring(hce,"ALT_IDENTIFIER",nullterm(build("CD:",code_value)))
     ELSE
      CALL uar_srvsetstring(hce,"ALT_IDENTIFIER",nullterm(""))
     ENDIF
     IF (populate_ce_field(hce,code_value,feed_primary_source_cd,build("##CVA##,",
       feed_primary_source_cd),"",
      1,0)=0)
      CALL populate_ce_field(hce,code_value,feed_secondary_source_cd,build("##CVA##,",
        feed_secondary_source_cd),"",
       1,0)
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_obs_entry_alt(hobs=i4) =null)
   IF (hobs > 0)
    SET code_value = 0.0
    SET sfieldvalue = nullterm(uar_srvgetstringptr(hobs,"VALUE_4"))
    SET sparsedvalue = parse_value(sfieldvalue)
    IF ((sparsedvalue != - (1)))
     SET code_value = sparsedvalue
     IF (istdprofiledebugind > 0)
      CALL uar_srvsetstring(hobs,"VALUE_4",nullterm(build("CD:",code_value)))
     ELSE
      CALL uar_srvsetstring(hobs,"VALUE_4",nullterm(""))
     ENDIF
     IF (populate_ce_field(hobs,code_value,feed_primary_source_cd,build("##CVA##,",
       feed_primary_source_cd),"",
      1,1)=0)
      CALL populate_ce_field(hobs,code_value,feed_secondary_source_cd,build("##CVA##,",
        feed_secondary_source_cd),"",
       1,1)
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 CALL echo("<===== ESO_HL7_FORMATTING.INC  START =====>")
 CALL echo("MOD:053")
 CALL echo("<===== ESO_COMMON_ROUTINES.INC  START =====>")
 CALL echo("MOD:026")
 CALL echo("MOD:025")
 DECLARE get_esoinfo_long_index(sea_name) = i4
 DECLARE get_esoinfo_long(sea_name) = i4
 DECLARE set_esoinfo_long(sea_name,lvalue) = i4
 DECLARE get_esoinfo_string_index(sea_name) = i4
 DECLARE get_esoinfo_string(sea_name) = c200
 DECLARE set_esoinfo_string(sea_name,svalue) = i4
 DECLARE get_esoinfo_double_index(sea_name) = i4
 DECLARE get_esoinfo_double(sea_name) = f8
 DECLARE set_esoinfo_double(sea_name,dvalue) = i4
 DECLARE get_request_long_index(sea_name) = i4
 DECLARE get_request_long(sea_name) = i4
 DECLARE set_request_long(sea_name,lvalue) = i4
 DECLARE get_reqinfo_double_index(sea_name) = i4
 DECLARE get_reqinfo_double(sea_name) = f8
 DECLARE set_reqinfo_double(sea_name,dvalue) = i4
 DECLARE get_reqinfo_string_index(sea_name) = i4
 DECLARE get_reqinfo_string(sea_name) = c200
 DECLARE set_reqinfo_string(sea_name,svalue) = i4
 DECLARE eso_trim_zeros(number) = c20
 DECLARE eso_trim_zeros_pos(number,pos) = c20
 DECLARE eso_remove_decimal(snumber) = vc
 DECLARE parse_formatting_string(f_string,arg) = vc
 DECLARE eso_column_exists(tablename,columnname) = i4
 DECLARE eso_pharm_decimal(decimal_val) = vc
 DECLARE get_routine_arg_value(name) = vc
 DECLARE cache_dm_flag_data(null) = null
 DECLARE search_forward = i4 WITH protect, constant(1)
 DECLARE search_backward = i4 WITH protect, constant(- (1))
 DECLARE uar_rtf2(p1=vc(ref),p2=i4(ref),p3=vc(ref),p4=i4(ref),p5=i4(ref),
  p6=i4(ref)) = i4
 FREE RECORD loc_record
 RECORD loc_record(
   1 location_cd = f8
   1 organization_id = f8
   1 location_type_cd = f8
   1 loc_facility_cd = f8
   1 loc_building_cd = f8
   1 loc_nurse_unit_cd = f8
   1 loc_room_cd = f8
   1 loc_bed_cd = f8
 )
 SUBROUTINE get_esoinfo_long_index(sea_name)
   SET list_size = 0
   SET list_size = size(context->cerner.longlist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((context->cerner.longlist[eso_x].strmeaning=cnvtlower(sea_name)))
       RETURN(eso_x)
      ENDIF
    ENDFOR
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE get_esoinfo_long(sea_name)
   SET eso_idx = 0
   SET list_size = 0
   SET list_size = size(context->cerner.longlist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((context->cerner.longlist[eso_x].strmeaning=cnvtlower(sea_name)))
       SET eso_idx = eso_x
      ENDIF
    ENDFOR
   ENDIF
   IF (eso_idx > 0)
    RETURN(context->cerner.longlist[eso_idx].lval)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE set_esoinfo_long(sea_name,lvalue)
   SET eso_idx = 0
   SET list_size = 0
   SET list_size = size(context->cerner.longlist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((context->cerner.longlist[eso_x].strmeaning=cnvtlower(sea_name)))
       SET eso_idx = eso_x
      ENDIF
    ENDFOR
   ENDIF
   IF (eso_idx > 0)
    SET context->cerner.longlist[eso_idx].lval = lvalue
    RETURN(0)
   ELSE
    SET list_size = 0
    SET list_size = size(context->cerner.longlist,5)
    SET eso_idx = 0
    SET eso_idx = (list_size+ 1)
    SET stat = alterlist(context->cerner.longlist,eso_idx)
    SET context->cerner.longlist[eso_idx].strmeaning = cnvtlower(sea_name)
    SET context->cerner.longlist[eso_idx].lval = lvalue
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_esoinfo_string_index(sea_name)
   SET list_size = 0
   SET list_size = size(context->cerner.stringlist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((context->cerner.stringlist[eso_x].strmeaning=cnvtlower(sea_name)))
       RETURN(eso_x)
      ENDIF
    ENDFOR
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE get_esoinfo_string(sea_name)
   SET eso_idx = 0
   SET list_size = 0
   SET list_size = size(context->cerner.stringlist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((context->cerner.stringlist[eso_x].strmeaning=cnvtlower(sea_name)))
       SET eso_idx = eso_x
      ENDIF
    ENDFOR
   ENDIF
   IF (eso_idx > 0)
    RETURN(context->cerner.stringlist[eso_idx].strval)
   ENDIF
   RETURN(" ")
 END ;Subroutine
 SUBROUTINE set_esoinfo_string(sea_name,svalue)
   SET eso_idx = 0
   SET list_size = 0
   SET list_size = size(context->cerner.stringlist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((context->cerner.stringlist[eso_x].strmeaning=cnvtlower(sea_name)))
       SET eso_idx = eso_x
      ENDIF
    ENDFOR
   ENDIF
   IF (eso_idx > 0)
    SET context->cerner.stringlist[eso_idx].strval = svalue
    RETURN(0)
   ELSE
    SET list_size = 0
    SET list_size = size(context->cerner.stringlist,5)
    SET eso_idx = 0
    SET eso_idx = (list_size+ 1)
    SET stat = alterlist(context->cerner.stringlist,eso_idx)
    SET context->cerner.stringlist[eso_idx].strmeaning = cnvtlower(sea_name)
    SET context->cerner.stringlist[eso_idx].strval = svalue
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_esoinfo_double_index(sea_name)
   SET list_size = 0
   SET list_size = size(context->cerner.doublelist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((context->cerner.doublelist[eso_x].strmeaning=cnvtlower(sea_name)))
       RETURN(eso_x)
      ENDIF
    ENDFOR
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE get_esoinfo_double(sea_name)
   SET eso_idx = 0
   SET list_size = 0
   SET list_size = size(context->cerner.doublelist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((context->cerner.doublelist[eso_x].strmeaning=cnvtlower(sea_name)))
       SET eso_idx = eso_x
      ENDIF
    ENDFOR
   ENDIF
   IF (eso_idx > 0)
    RETURN(context->cerner.doublelist[eso_idx].dval)
   ENDIF
   RETURN(0.0)
 END ;Subroutine
 SUBROUTINE set_esoinfo_double(sea_name,dvalue)
   SET eso_idx = 0
   SET list_size = 0
   SET list_size = size(context->cerner.doublelist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((context->cerner.doublelist[eso_x].strmeaning=cnvtlower(sea_name)))
       SET eso_idx = eso_x
      ENDIF
    ENDFOR
   ENDIF
   IF (eso_idx > 0)
    SET context->cerner.doublelist[eso_idx].dval = dvalue
    RETURN(0)
   ELSE
    SET list_size = 0
    SET list_size = size(context->cerner.doublelist,5)
    SET eso_idx = 0
    SET eso_idx = (list_size+ 1)
    SET stat = alterlist(context->cerner.doublelist,eso_idx)
    SET context->cerner.doublelist[eso_idx].strmeaning = cnvtlower(sea_name)
    SET context->cerner.doublelist[eso_idx].dval = dvalue
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_request_long_index(sea_name)
   SET list_size = 0
   SET list_size = size(request->esoinfo.longlist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((request->esoinfo.longlist[eso_x].strmeaning=cnvtlower(sea_name)))
       RETURN(eso_x)
      ENDIF
    ENDFOR
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE get_request_long(sea_name)
   SET eso_idx = 0
   SET list_size = 0
   SET list_size = size(request->esoinfo.longlist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((request->esoinfo.longlist[eso_x].strmeaning=cnvtlower(sea_name)))
       SET eso_idx = eso_x
      ENDIF
    ENDFOR
   ENDIF
   IF (eso_idx > 0)
    RETURN(request->esoinfo.longlist[eso_idx].lval)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE set_request_long(sea_name,lvalue)
   SET eso_idx = 0
   SET list_size = 0
   SET list_size = size(request->esoinfo.longlist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((request->esoinfo.longlist[eso_x].strmeaning=cnvtlower(sea_name)))
       SET eso_idx = eso_x
      ENDIF
    ENDFOR
   ENDIF
   IF (eso_idx > 0)
    SET request->esoinfo.longlist[eso_idx].lval = lvalue
    RETURN(0)
   ELSE
    SET list_size = 0
    SET list_size = size(request->esoinfo.longlist,5)
    SET eso_idx = 0
    SET eso_idx = (list_size+ 1)
    SET stat = alterlist(request->esoinfo.longlist,eso_idx)
    SET request->esoinfo.longlist[eso_idx].strmeaning = cnvtlower(sea_name)
    SET request->esoinfo.longlist[eso_idx].lval = lvalue
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_reqinfo_double_index(sea_name)
   SET list_size = 0
   SET list_size = size(request->esoinfo.doublelist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((request->esoinfo.doublelist[eso_x].strmeaning=cnvtlower(sea_name)))
       RETURN(eso_x)
      ENDIF
    ENDFOR
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE get_reqinfo_double(sea_name)
   SET eso_idx = 0
   SET list_size = 0
   SET list_size = size(request->esoinfo.doublelist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((request->esoinfo.doublelist[eso_x].strmeaning=cnvtlower(sea_name)))
       SET eso_idx = eso_x
      ENDIF
    ENDFOR
   ENDIF
   IF (eso_idx > 0)
    RETURN(request->esoinfo.doublelist[eso_idx].dval)
   ENDIF
   RETURN(0.0)
 END ;Subroutine
 SUBROUTINE set_reqinfo_double(sea_name,dvalue)
   SET eso_idx = 0
   SET list_size = 0
   SET list_size = size(request->esoinfo.doublelist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((request->esoinfo.doublelist[eso_x].strmeaning=cnvtlower(sea_name)))
       SET eso_idx = eso_x
      ENDIF
    ENDFOR
   ENDIF
   IF (eso_idx > 0)
    SET request->esoinfo.doublelist[eso_idx].dval = dvalue
    RETURN(0)
   ELSE
    SET list_size = 0
    SET list_size = size(request->esoinfo.doublelist,5)
    SET eso_idx = 0
    SET eso_idx = (list_size+ 1)
    SET stat = alterlist(request->esoinfo.doublelist,eso_idx)
    SET request->esoinfo.doublelist[eso_idx].strmeaning = cnvtlower(sea_name)
    SET request->esoinfo.doublelist[eso_idx].dval = dvalue
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_reqinfo_string_index(sea_name)
   SET list_size = 0
   SET list_size = size(request->esoinfo.stringlist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((request->esoinfo.stringlist[eso_x].strmeaning=cnvtlower(sea_name)))
       RETURN(eso_x)
      ENDIF
    ENDFOR
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE get_reqinfo_string(sea_name)
   SET eso_idx = 0
   SET list_size = 0
   SET list_size = size(request->esoinfo.stringlist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((request->esoinfo.stringlist[eso_x].strmeaning=cnvtlower(sea_name)))
       SET eso_idx = eso_x
      ENDIF
    ENDFOR
   ENDIF
   IF (eso_idx > 0)
    RETURN(request->esoinfo.stringlist[eso_idx].strval)
   ENDIF
   RETURN(" ")
 END ;Subroutine
 SUBROUTINE set_reqinfo_string(sea_name,svalue)
   SET eso_idx = 0
   SET list_size = 0
   SET list_size = size(request->esoinfo.stringlist,5)
   IF (list_size > 0)
    SET eso_x = 1
    FOR (eso_x = eso_x TO list_size)
      IF ((request->esoinfo.stringlist[eso_x].strmeaning=cnvtlower(sea_name)))
       SET eso_idx = eso_x
      ENDIF
    ENDFOR
   ENDIF
   IF (eso_idx > 0)
    SET request->esoinfo.stringlist[eso_idx].strval = svalue
    RETURN(0)
   ELSE
    SET list_size = 0
    SET list_size = size(request->esoinfo.stringlist,5)
    SET eso_idx = 0
    SET eso_idx = (list_size+ 1)
    SET stat = alterlist(request->esoinfo.stringlist,eso_idx)
    SET request->esoinfo.stringlist[eso_idx].strmeaning = cnvtlower(sea_name)
    SET request->esoinfo.stringlist[eso_idx].strval = svalue
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE eso_trim_zeros(number)
   CALL echo("Entering eso_trim_zeros subroutine")
   FREE SET t_initial
   FREE SET t_length
   FREE SET t_decimal
   FREE SET t_last_sig
   FREE SET t_final
   FREE SET t_i
   SET t_initial = build(number)
   SET t_length = size(t_initial)
   SET t_decimal = findstring(".",t_initial,1)
   SET t_final = trim(t_initial,3)
   CALL echo(build("    number=",number))
   CALL echo(build("    t_initial=",t_initial))
   IF (t_decimal > 0)
    SET t_last_sig = (t_decimal - 1)
    SET t_i = 0
    FOR (t_i = (t_decimal+ 1) TO t_length)
      IF (substring(t_i,1,t_initial) > "0")
       SET t_last_sig = t_i
      ENDIF
    ENDFOR
    SET t_final = trim(substring(1,t_last_sig,t_initial),3)
   ENDIF
   FREE SET t_initial
   FREE SET t_length
   FREE SET t_decimal
   FREE SET t_last_sig
   FREE SET t_i
   CALL echo(build("    t_final=",t_final))
   CALL echo("Exiting eso_trim_zeros subroutine")
   RETURN(t_final)
 END ;Subroutine
 SUBROUTINE eso_trim_zeros_pos(number,pos)
   CALL echo("Entering eso_trim_zeros_pos subroutine")
   FREE SET t_initial
   FREE SET t_length
   FREE SET t_decimal
   FREE SET t_last_sig
   FREE SET t_final
   FREE SET t_i
   SET t_initial = build(number)
   SET t_length = size(t_initial)
   SET t_decimal = findstring(".",t_initial,1)
   SET t_final = trim(t_initial)
   IF (t_decimal > 0)
    SET t_decimal += pos
    SET t_last_sig = t_decimal
    SET t_i = 0
    FOR (t_i = (t_decimal+ 1) TO t_length)
      IF (substring(t_i,1,t_initial) > "0")
       SET t_last_sig = t_i
      ENDIF
    ENDFOR
    SET t_final = trim(substring(1,t_last_sig,t_initial))
   ENDIF
   FREE SET t_initial
   FREE SET t_length
   FREE SET t_decimal
   FREE SET t_last_sig
   FREE SET t_i
   CALL echo(build("    t_final=",t_final))
   CALL echo("Exiting eso_trim_zeros_pos subroutine")
   RETURN(t_final)
 END ;Subroutine
 SUBROUTINE (eso_trim_zeros_sig_dig(number=f8,sig_dig=i4) =c20)
   CALL echo("Entering eso_trim_zeros_sig_dig subroutine")
   DECLARE strzeros = vc WITH private, noconstant("")
   SET strzeros = eso_trim_zeros(trim(cnvtstring(number,20,value(sig_dig))))
   CALL echo("Exiting eso_trim_zeros_sig_dig subroutine")
   RETURN(strzeros)
 END ;Subroutine
 SUBROUTINE parse_formatting_string(f_string,arg)
   CALL echo("Entering parse_formatting_string() subroutine")
   DECLARE p_pos = i2 WITH private, noconstant(0)
   DECLARE c_pos = i2 WITH private, noconstant(0)
   DECLARE argument = vc WITH private, noconstant("")
   DECLARE f_string_len = i4 WITH private, noconstant(0)
   SET f_string = trim(f_string,3)
   SET f_string_len = size(f_string,1)
   CALL echo(build("arg      =",arg))
   CALL echo(build("f_string =",f_string))
   IF (f_string_len)
    IF (arg)
     SET p_pos = 0
     FOR (x_i = 1 TO arg)
       SET c_pos = findstring(",",f_string,(p_pos+ 1))
       IF (x_i=arg)
        IF (p_pos > 0
         AND c_pos=0)
         SET argument = substring((p_pos+ 1),(f_string_len - p_pos),f_string)
        ELSE
         SET argument = substring((p_pos+ 1),(c_pos - (p_pos+ 1)),f_string)
        ENDIF
       ENDIF
       SET p_pos = c_pos
     ENDFOR
    ELSE
     CALL echo("ERROR!! a valid argument number was not passed in")
    ENDIF
   ELSE
    CALL echo("ERROR!! a valid formatting string was not passed in")
   ENDIF
   CALL echo("Exiting parse_formatting_string() subroutine")
   RETURN(argument)
 END ;Subroutine
 SUBROUTINE eso_remove_decimal(number)
   CALL echo("Entering eso_remove_decimal() subroutine")
   DECLARE t_pos = i4 WITH private, noconstant(0)
   DECLARE t_number = vc WITH private, noconstant("")
   SET t_number = build(number)
   CALL echo(build("t_number = ",t_number))
   SET t_pos = findstring(".",t_number)
   IF (t_pos)
    SET t_number = substring(1,(t_pos+ 2),t_number)
    CALL echo(build("t_number = ",t_number))
    SET t_number = trim(replace(t_number,".","",1),3)
    CALL echo(build("t_number = ",t_number))
   ENDIF
   CALL echo("Exiting eso_remove_decimal() subroutine")
   RETURN(t_number)
 END ;Subroutine
 SUBROUTINE (get_int_routine_arg(arg=vc,args=vc) =i4)
   CALL echo("Entering get_int_routine_arg() subroutine")
   DECLARE pos = i4 WITH private, noconstant(0)
   DECLARE b_pos = i4 WITH private, noconstant(0)
   DECLARE value = i4 WITH private, noconstant(0)
   DECLARE stop = i2 WITH private, noconstant(0)
   IF (args <= "")
    IF (validate(request->esoinfo,"!") != "!")
     SET args = request->esoinfo.scriptcontrolargs
    ELSE
     CALL echo("No incoming request->esoinfo structure detected")
    ENDIF
   ENDIF
   SET pos = findstring(arg,args)
   IF (pos)
    SET pos += 10
    SET b_pos = pos
    SET stop = 0
    WHILE ( NOT (stop))
      IF (isnumeric(substring(pos,1,args)))
       SET value = cnvtint(substring(b_pos,((pos+ 1) - b_pos),args))
       SET pos += 1
      ELSE
       SET stop = 1
      ENDIF
    ENDWHILE
   ELSE
    CALL echo(concat("arg=",arg," not found in routine args=",args))
   ENDIF
   CALL echo(build("value=",value))
   CALL echo("Exiting get_int_routine_arg() subroutine")
   RETURN(value)
 END ;Subroutine
 SUBROUTINE eso_column_exists(tablename,columnname)
   CALL echo("Entering eso_column_exists subroutine")
   DECLARE ce_flag = i4
   SET ce_flag = 0
   DECLARE ce_temp = vc WITH noconstant("")
   SET stable = cnvtupper(tablename)
   SET scolumn = cnvtupper(columnname)
   IF (((currev=8
    AND currevminor=2
    AND currevminor2 >= 4) OR (((currev=8
    AND currevminor > 2) OR (currev > 8)) )) )
    SET ce_temp = build('"',stable,".",scolumn,'"')
    SET stat = checkdic(parser(ce_temp),"A",0)
    IF (stat > 0)
     SET ce_flag = 1
    ENDIF
   ELSE
    SELECT INTO "nl:"
     l.attr_name
     FROM dtableattr a,
      dtableattrl l
     WHERE a.table_name=stable
      AND l.attr_name=scolumn
      AND l.structtype="F"
      AND btest(l.stat,11)=0
     DETAIL
      ce_flag = 1
     WITH nocounter
    ;end select
   ENDIF
   CALL echo("Exiting eso_column_exists subroutine")
   RETURN(ce_flag)
 END ;Subroutine
 SUBROUTINE eso_pharm_decimal(decimal_val)
   CALL echo("Entering eso_pharm_decimal...")
   DECLARE strdecimal = vc WITH noconstant(" ")
   SET strdecimal = cnvtstring(decimal_val,20,6)
   SET idecimalidx = findstring(".",strdecimal)
   IF (idecimalidx > 0)
    SET iend = size(strdecimal,1)
    WHILE (substring(iend,1,strdecimal)="0")
      SET iend -= 1
    ENDWHILE
    SET strdecimal = substring(1,iend,strdecimal)
    CALL echo(build2("removed zeros - ",strdecimal))
    IF (substring(size(strdecimal,1),1,strdecimal)=".")
     SET strdecimal = substring(1,(size(strdecimal,1) - 1),strdecimal)
     CALL echo(build2("removed decimal - ",strdecimal))
    ENDIF
    IF (idecimalidx=1)
     SET strdecimal = ("0"+ strdecimal)
     CALL echo(build2("added leading zero - ",strdecimal))
    ENDIF
   ENDIF
   CALL echo("Exiting eso_pharm_decimal...")
   RETURN(strdecimal)
 END ;Subroutine
 SUBROUTINE get_routine_arg_value(name)
   CALL echo("Entering get_routine_arg_value...")
   SET routine_args = trim(request->esoinfo.scriptcontrolargs)
   DECLARE strvalue = vc WITH public, noconstant(" ")
   SET iindex = findstring(name,routine_args)
   IF (iindex)
    SET iequalidx = findstring("=",routine_args,(iindex+ size(name)))
    IF (iequalidx > 0)
     SET isemiidx = findstring(";",routine_args,(iequalidx+ 1))
     IF (isemiidx > 0)
      SET strvalue = trim(substring((iequalidx+ 1),((isemiidx - iequalidx) - 1),routine_args),3)
     ELSE
      SET strvalue = trim(substring((iequalidx+ 1),(size(routine_args) - iequalidx),routine_args),3)
     ENDIF
    ENDIF
   ENDIF
   RETURN(strvalue)
   CALL echo("Exiting get_routine_arg_value...")
 END ;Subroutine
 SUBROUTINE (routine_arg_exists(name=vc) =i2)
   IF (validate(request->esoinfo.scriptcontrolargs,0))
    DECLARE routine_args = vc WITH private, noconstant(trim(request->esoinfo.scriptcontrolargs))
   ELSE
    DECLARE routine_args = vc WITH private, noconstant(trim(get_esoinfo_string("routine_args")))
   ENDIF
   DECLARE routine_args_size = i4 WITH private, constant(size(routine_args))
   DECLARE name_start = i4 WITH private, noconstant(0)
   DECLARE next_char_idx = i4 WITH private, noconstant(0)
   DECLARE trailing_char_exists = i2 WITH private, noconstant(0)
   DECLARE leading_char_exists = i2 WITH private, noconstant(0)
   IF (size(trim(name))=0)
    CALL echo("Invalid Empty Routine Arg")
    RETURN(0)
   ENDIF
   SET name_start = findstring(name,routine_args,1)
   WHILE (name_start > 0)
     SET next_char_idx = (name_start+ size(name))
     SET trailing_char_exists = additional_character_exists(routine_args,routine_args_size,
      next_char_idx,search_forward)
     IF (trailing_char_exists=0)
      SET leading_char_exists = additional_character_exists(routine_args,routine_args_size,(
       name_start - 1),search_backward)
     ENDIF
     IF (leading_char_exists=0
      AND trailing_char_exists=0)
      CALL echo(build("Routine Arg- ",name," is enabled."))
      RETURN(1)
     ELSE
      SET name_start = findstring(name,routine_args,next_char_idx)
     ENDIF
   ENDWHILE
   CALL echo(build("Routine Arg- ",name," is NOT enabled."))
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (additional_character_exists(arg_string=vc,arg_string_size=i4,start_idx=i4,
  search_increment=i4) =i2)
   DECLARE end_of_token_found = i4 WITH private, noconstant(0)
   DECLARE char_exists = i2 WITH private, noconstant(0)
   DECLARE check_idx = i4 WITH private, noconstant(start_idx)
   DECLARE check_char = c1 WITH private, noconstant(" ")
   WHILE ( NOT (end_of_token_found))
     IF (((check_idx < 1) OR (check_idx > arg_string_size)) )
      SET end_of_token_found = 1
     ELSE
      SET check_char = substring(check_idx,1,arg_string)
      IF (check_char=";")
       SET end_of_token_found = 1
      ELSEIF ( NOT (check_char=" "))
       SET char_exists = 1
       SET end_of_token_found = 1
      ELSE
       SET check_idx += search_increment
      ENDIF
     ENDIF
   ENDWHILE
   RETURN(char_exists)
 END ;Subroutine
 SUBROUTINE (get_synoptic_nomen_config(name=vc) =vc)
   CALL echo("Entering get_synoptic_nomen_config...")
   SET routine_args = trim(get_esoinfo_string("routine_args"),3)
   DECLARE strvalue = vc WITH public, noconstant(" ")
   SET iindex = findstring(name,routine_args)
   IF (iindex)
    SET iequalidx = findstring("=",routine_args,(iindex+ size(name)))
    IF (iequalidx > 0)
     SET isemiidx = findstring(";",routine_args,(iequalidx+ 1))
     IF (isemiidx > 0)
      SET strvalue = trim(substring((iequalidx+ 1),((isemiidx - iequalidx) - 1),routine_args),3)
     ELSE
      SET strvalue = trim(substring((iequalidx+ 1),(size(routine_args) - iequalidx),routine_args),3)
     ENDIF
    ENDIF
   ENDIF
   CALL echo(build("strValue:",strvalue))
   RETURN(strvalue)
   CALL echo("Exiting get_synoptic_nomen_config...")
 END ;Subroutine
 SUBROUTINE (rtfformatingremove(srtfstring=vc) =vc)
   CALL echo("Entering rtfFormat")
   CALL echo(build("sRtfString = ",srtfstring))
   IF ( NOT (validate(g_strreplacetext)))
    DECLARE dpicttextcd = f8 WITH private, noconstant(0.0)
    SET dpicttextcd = eso_get_meaning_by_codeset(40700,"PICT_TEXT")
    DECLARE strdisplayvalue = vc WITH private, noconstant(" ")
    SET strdisplayvalue = eso_get_code_display(dpicttextcd)
    DECLARE g_strreplacetext = vc WITH private, noconstant(" ")
    SET g_strreplacetext = concat(" ",trim(strdisplayvalue,3)," {\pict")
   ENDIF
   DECLARE srtftxt = vc WITH private, noconstant(" ")
   SET srtftxt = trim(replace(srtfstring,"{\pict",g_strreplacetext,0),3)
   DECLARE irtftextsize = i4 WITH private, noconstant(textlen(srtftxt))
   CALL echo(build("iRtfTextSize =",irtftextsize))
   DECLARE sasciitext = vc WITH private, noconstant(concat(srtftxt,"0123456789"))
   DECLARE iacsiilength = i4 WITH private, noconstant(0)
   DECLARE s_irtfflag = i4 WITH private, noconstant(1)
   SET iretvalue = uar_rtf2(srtftxt,irtftextsize,sasciitext,irtftextsize,iacsiilength,
    s_irtfflag)
   CALL echo(build("iRetValue=",iretvalue))
   FREE SET srtftxt
   SET sasciitext = trim(substring(1,iacsiilength,sasciitext))
   CALL echo(build("sAsciiText=",sasciitext))
   CALL echo("Exiting rtfFormat")
   RETURN(sasciitext)
 END ;Subroutine
 SUBROUTINE (get_parent_loc(child_loc=f8,loc_type=vc) =f8)
   DECLARE parent_loc = f8 WITH public, noconstant(0.0)
   SELECT INTO "nl:"
    lg.parent_loc_cd
    FROM location_group lg
    WHERE lg.child_loc_cd=child_loc
     AND lg.location_group_type_cd=loc_type
     AND ((lg.root_loc_cd+ 0)=0)
     AND lg.active_ind=1
    DETAIL
     parent_loc = lg.parent_loc_cd
    WITH nocounter
   ;end select
   RETURN(parent_loc)
 END ;Subroutine
 SUBROUTINE (fill_loc_tree(location_cd=f8) =i4)
   DECLARE val = i4 WITH noconstant(1)
   IF (location_cd > 0)
    SELECT INTO "nl:"
     a.location_type_cd, a.organization_id, meaning = uar_get_code_meaning(a.location_type_cd)
     FROM location a
     PLAN (a
      WHERE a.location_cd=location_cd)
     DETAIL
      IF (a.location_type_cd > 0)
       CASE (meaning)
        OF "BED":
         loc_record->loc_bed_cd = location_cd
        OF "ROOM":
         loc_record->loc_room_cd = location_cd
        OF "NURSEUNIT":
         loc_record->loc_nurse_unit_cd = location_cd
        OF "BUILDING":
         loc_record->loc_building_cd = location_cd
        OF "FACILITY":
         loc_record->loc_facility_cd = location_cd
        ELSE
         val = 0
       ENDCASE
      ENDIF
      loc_record->organization_id = a.organization_id, loc_record->location_type_cd = a
      .location_type_cd
     WITH nocounter
    ;end select
    IF ((loc_record->loc_bed_cd > 0)
     AND (loc_record->loc_room_cd <= 0))
     SET loc_record->loc_room_cd = get_parent_loc(loc_record->loc_bed_cd,eso_get_meaning_by_codeset(
       222,"ROOM"))
    ENDIF
    IF ((loc_record->loc_room_cd > 0)
     AND (loc_record->loc_nurse_unit_cd <= 0))
     SET loc_record->loc_nurse_unit_cd = get_parent_loc(loc_record->loc_room_cd,
      eso_get_meaning_by_codeset(222,"NURSEUNIT"))
    ENDIF
    IF ((loc_record->loc_nurse_unit_cd > 0)
     AND (loc_record->loc_building_cd <= 0))
     SET loc_record->loc_building_cd = get_parent_loc(loc_record->loc_nurse_unit_cd,
      eso_get_meaning_by_codeset(222,"BUILDING"))
    ENDIF
    IF ((loc_record->loc_building_cd > 0)
     AND (loc_record->loc_facility_cd <= 0))
     SET loc_record->loc_facility_cd = get_parent_loc(loc_record->loc_building_cd,
      eso_get_meaning_by_codeset(222,"FACILITY"))
    ENDIF
   ENDIF
   RETURN(val)
 END ;Subroutine
 SUBROUTINE cache_dm_flag_data(null)
  RECORD dm_flag(
    1 qual[*]
      2 flag_value = i2
      2 description = vc
      2 column_name = vc
  ) WITH persist
  SELECT DISTINCT INTO "nl:"
   dmf.description
   FROM dm_flags dmf
   WHERE dmf.table_name="ORDERS"
    AND dmf.column_name IN ("CS_FLAG", "TEMPLATE_ORDER_FLAG", "ORDERABLE_TYPE_FLAG")
   ORDER BY dmf.column_name
   HEAD REPORT
    i = 0
   DETAIL
    i += 1, stat = alterlist(dm_flag->qual,i), dm_flag->qual[i].description = dmf.description,
    dm_flag->qual[i].flag_value = dmf.flag_value, dm_flag->qual[i].column_name = dmf.column_name
   WITH nocounter
  ;end select
 END ;Subroutine
 CALL echo("<===== ESO_COMMON_ROUTINES.INC End =====>")
 DECLARE eso_format_dttm(input_dt_tm,hl7_format,time_zone) = c60
 DECLARE hl7_format_date(input_dt_tm,method) = c60
 DECLARE hl7_format_time(input_dt_tm,method) = c60
 DECLARE hl7_format_datetime(input_dt_tm,method) = c60
 DECLARE eso_format_nomen(n_field1,n_field2,n_field3,n_value1,n_value2) = c200
 DECLARE eso_format_item(identifier,value,item,index) = c200
 DECLARE eso_format_item_with_method(identifier,value,item,index,data_type,
  field_name) = c200
 DECLARE eso_format_code(fvalue) = c40
 DECLARE eso_format_code_with_method(fvalue,data_type,field_name) = c40
 DECLARE eso_format_code_blank(fvalue) = c40
 DECLARE eso_format_code_ctx(fvalue) = c40
 DECLARE eso_format_code_blank_ctx(fvalue) = c40
 DECLARE eso_format_code_aliases(fvalue1,fvalue2) = c40
 DECLARE eso_format_alias(field1,field2,type,subtype,pool,
  alias) = c200
 DECLARE eso_format_alias_ctx(field1,field2,type,subtype,pool,
  alias) = c200
 DECLARE eso_format_dbnull(dummy) = c40
 DECLARE eso_format_dbnull_ctx(dummy) = c40
 DECLARE eso_format_org(field_name,msg_format,datatype,org_alias_type_cd,repeat_ind,
  future,future2,assign_auth_org_id,fed_tax_id,org_name,
  org_id) = c200
 DECLARE eso_format_hlthplan(field_name,msg_format,datatype,hlthplan_alias_type_cd,repeat_ind,
  future,future2,assign_auth_org_id,hlthplan_plan_name,hlthplan_id,
  ins_org_id) = c200
 DECLARE eso_encode_timing(value,unit) = c20
 DECLARE eso_encode_range(low,high) = c45
 DECLARE eso_encode_timing_noround(value,unit) = c20
 DECLARE eso_format_previous_result(strverifydttm,struser,strresultval,strresultunitcd,strnormalcycd,
  strusername,strtype) = vc
 DECLARE encode_delimiter(original_string,search_string,replace_string) = vc
 DECLARE eso_format_short_result(strverifydttm,struser,strusername,strtype) = vc
 DECLARE eso_format_code_for_cs(fvalue,strcodingsys,straliastypmeaning) = vc
 DECLARE eso_format_multum_identifiers(catalog_cd,synonym_id,item_id,field_type,format_string) = vc
 DECLARE eso_format_attachment(strattachmentname,dstoragecd,strblobhandle,dformatcd,strcommentind) =
 vc
 DECLARE eso_format_phone_cd(dphonetypecd,dcontactmethodcd) = vc
 SET hl7_date_year = 1
 SET hl7_date_mon = 2
 SET hl7_date_day = 3
 SET hl7_dt_tm_hour = 4
 SET hl7_dt_tm_min = 5
 SET hl7_dt_tm_sec = 6
 SET hl7_dt_tm_hsec = 7
 SET hl7_time_hour = 8
 SET hl7_time_min = 9
 SET hl7_time_sec = 10
 SET hl7_time_hsec = 11
 SET hl7_date = 3
 SET hl7_dt_tm = 6
 SET hl7_time = 10
 SUBROUTINE (format_dttm_custom(s_dtinputdttm=dq8,s_strformat=vc,s_strtzformat=vc) =vc)
   DECLARE strdttmcustformatstring = vc WITH noconstant(" ")
   IF (s_dtinputdttm > 0
    AND textlen(trim(s_strformat,3)) > 0)
    DECLARE strtzformatstring = vc WITH noconstant(", ,")
    IF (textlen(trim(s_strtzformat,3)) > 0)
     SET strtzformatstring = build2(",",s_strtzformat,",")
    ENDIF
    IF (curutc=0)
     SET strdttmcustformatstring = build2("##DTTMCUST##,",s_strformat,strtzformatstring,format(
       s_dtinputdttm,"YYYYMMDD;;D"),",",
      format(s_dtinputdttm,"HHmmss.cc;3;M"),",")
    ELSE
     SET strdttmcustformatstring = build2("##DTTMCUST##,",s_strformat,strtzformatstring,format(
       s_dtinputdttm,"YYYYMMDD;;D"),",",
      format(s_dtinputdttm,"HHmmss.cc;3;M"),", ,",datetimezoneformat(s_dtinputdttm,datetimezonebyname
       ("UTC"),"yyyyMMddHHmmsscc"))
    ENDIF
   ENDIF
   RETURN(strdttmcustformatstring)
 END ;Subroutine
 SUBROUTINE (format_date_of_record_custom(s_dtinputdttm=dq8,s_strformat=vc,s_strtzformat=vc,s_idatetz
  =i4) =vc)
   DECLARE strdttmcustformatstring = vc WITH noconstant(" ")
   IF (s_dtinputdttm > 0
    AND textlen(trim(s_strformat,3)) > 0)
    DECLARE strtzformatstring = vc WITH noconstant(", ,")
    DECLARE strdatetz = vc WITH noconstant(notrim(", "))
    IF (textlen(trim(s_strtzformat,3)) > 0)
     SET strtzformatstring = build2(",",s_strtzformat,",")
    ENDIF
    IF (s_idatetz > 0)
     SET strdatetz = build2(",",cnvtstring(s_idatetz))
    ELSEIF (curutc=0)
     SET strdatetz = build2(",",cnvtstring(curtimezonesys))
    ENDIF
    IF (curutc=0)
     SET strdttmcustformatstring = build2("##DTTMCUST##,",s_strformat,strtzformatstring,format(
       s_dtinputdttm,"YYYYMMDD;;D"),",",
      format(s_dtinputdttm,"HHmmss.cc;3;M"),strdatetz)
    ELSE
     SET strdttmcustformatstring = build2("##DTTMCUST##,",s_strformat,strtzformatstring,format(
       s_dtinputdttm,"YYYYMMDD;;D"),",",
      format(s_dtinputdttm,"HHmmss.cc;3;M"),strdatetz,",",datetimezoneformat(s_dtinputdttm,
       datetimezonebyname("UTC"),"yyyyMMddHHmmsscc"))
    ENDIF
   ENDIF
   RETURN(strdttmcustformatstring)
 END ;Subroutine
 SUBROUTINE eso_format_dttm(input_dt_tm,hl7_format,time_zone)
  DECLARE strtimezonestring = vc WITH noconstant(", ,")
  IF (input_dt_tm > 0)
   FREE SET t_dt
   FREE SET t_dt_format
   FREE SET t_tm
   FREE SET t_tm_format
   SET t_dt = format(input_dt_tm,"YYYYMMDD;;D")
   SET t_tm = format(input_dt_tm,"HHmmss.cc;3;M")
   CASE (hl7_format)
    OF hl7_date_year:
     SET t_dt_format = "YYYY"
     SET t_tm_format = " "
    OF hl7_date_mon:
     SET t_dt_format = "YYYYMM"
     SET t_tm_format = " "
    OF hl7_date_day:
     SET t_dt_format = "YYYYMMDD"
     SET t_tm_format = " "
    OF hl7_date:
     SET t_dt_format = "YYYYMMDD"
     SET t_tm_format = " "
    OF hl7_dt_tm_hour:
     SET t_dt_format = "YYYYMMDD"
     SET t_tm_format = "HH"
    OF hl7_dt_tm_min:
     SET t_dt_format = "YYYYMMDD"
     SET t_tm_format = "HHMM"
    OF hl7_dt_tm_sec:
     SET t_dt_format = "YYYYMMDD"
     SET t_tm_format = "HHMMSS"
    OF hl7_dt_tm:
     SET t_dt_format = "YYYYMMDD"
     SET t_tm_format = "HHMMSS"
    OF hl7_dt_tm_hsec:
     SET t_dt_format = "YYYYMMDD"
     SET t_tm_format = "HHMMSS.CC"
    OF hl7_time_hour:
     SET t_dt_format = " "
     SET t_tm_format = "HH"
    OF hl7_time_min:
     SET t_dt_format = " "
     SET t_tm_format = "HHMM"
    OF hl7_time_sec:
     SET t_dt_format = " "
     SET t_tm_format = "HHMMSS"
    OF hl7_time:
     SET t_dt_format = " "
     SET t_tm_format = "HHMMSS"
    OF hl7_time_hsec:
     SET t_dt_format = " "
     SET t_tm_format = "HHMMSS.CC"
    ELSE
     SET t_dt_format = "YYYYMMDD"
     SET t_tm_format = "HHMMSS"
   ENDCASE
   IF (textlen(trim(time_zone,3)) > 0)
    SET strtimezonestring = build2(",",trim(time_zone,3),",")
   ENDIF
   IF (curutc=0)
    RETURN(concat("##DTTM##",",",t_dt_format,",",t_tm_format,
     ",",t_dt,",",t_tm,strtimezonestring))
   ELSE
    RETURN(concat("##DTTM##",",",t_dt_format,",",t_tm_format,
     ",",t_dt,",",t_tm,strtimezonestring,
     datetimezoneformat(input_dt_tm,datetimezonebyname("UTC"),"yyyyMMddHHmmsscc")))
   ENDIF
  ELSE
   RETURN(" ")
  ENDIF
 END ;Subroutine
 SUBROUTINE hl7_format_datetime(input_dt_tm,method)
   RETURN(eso_format_dttm(input_dt_tm,method,""))
 END ;Subroutine
 SUBROUTINE hl7_format_date(input_dt_tm,method)
   RETURN(eso_format_dttm(input_dt_tm,method,""))
 END ;Subroutine
 SUBROUTINE hl7_format_time(input_dt_tm,method)
   RETURN(eso_format_dttm(input_dt_tm,method,""))
 END ;Subroutine
 SUBROUTINE (eso_birth_date_format_specifier(birth_prec_flag=i2) =i4)
   DECLARE precision = i4 WITH noconstant(0)
   CASE (birth_prec_flag)
    OF 0:
     SET precision = hl7_date
    OF 1:
     SET precision = hl7_dt_tm
    OF 2:
     SET precision = hl7_date_mon
    OF 3:
     SET precision = hl7_date_year
    ELSE
     SET precision = hl7_dt_tm
   ENDCASE
   RETURN(precision)
 END ;Subroutine
 SUBROUTINE (eso_death_date_format_specifier(death_prec_flag=i2) =i4)
   DECLARE precision = i4 WITH noconstant(0)
   CASE (death_prec_flag)
    OF 0:
     SET precision = hl7_dt_tm
    OF 1:
     SET precision = hl7_dt_tm
    OF 2:
     SET precision = hl7_date_mon
    OF 3:
     SET precision = hl7_date_year
    OF 4:
     SET precision = hl7_date_day
    ELSE
     SET precision = hl7_dt_tm
   ENDCASE
   RETURN(precision)
 END ;Subroutine
 SUBROUTINE (not_a_maxdate(end_effect_dttm=dq8) =i2)
  DECLARE blankenddate = dq8 WITH protected, constant(cnvtdatetime("31-DEC-2100 23:59:59.00"))
  IF (datetimecmp(cnvtdatetime(end_effect_dttm),blankenddate))
   RETURN(1)
  ELSE
   RETURN(0)
  ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_nomen(n_field1,n_field2,n_field3,n_value1,n_value2)
   IF (n_value1
    AND n_value2)
    RETURN(substring(1,200,concat("##NOMEN##",",",trim(n_field1,3),",",trim(n_field2,3),
      ",",trim(n_field3,3),",",trim(cnvtstring(n_value1),3),",",
      trim(cnvtstring(n_value2),3))))
   ELSE
    RETURN(eso_format_dbnull(1))
   ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_item(identifier,value,item,index)
   IF (item > 0)
    RETURN(substring(1,200,concat("##ITEM##",",",trim(identifier),",",trim(value),
      ",",trim(cnvtstring(item)),",",trim(cnvtstring(index)))))
   ELSE
    RETURN(eso_format_dbnull(1))
   ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_item_with_method(identifier,value,item,index,data_type,field_name)
   IF (item > 0)
    RETURN(substring(1,200,concat("##ITEM##",",",trim(identifier),",",trim(value),
      ",",trim(cnvtstring(item)),",",trim(cnvtstring(index)),",",
      trim(data_type),",",trim(field_name))))
   ELSE
    RETURN(eso_format_dbnull(1))
   ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_code(fvalue)
   IF (fvalue > 0)
    RETURN(substring(1,40,concat("##CVA##",",",trim(cnvtstring(fvalue)))))
   ELSE
    RETURN(eso_format_dbnull(1))
   ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_code_with_method(fvalue,data_type,field_name)
   IF (fvalue > 0)
    IF (trim(data_type)="ALIAS_TYPE_MEANING")
     RETURN(substring(1,40,concat("##CVA##",",",trim(cnvtstring(fvalue)),",",trim(field_name))))
    ELSE
     RETURN(substring(1,40,concat("##CVA##",",",trim(cnvtstring(fvalue)),",",trim(data_type),
       ",",trim(field_name))))
    ENDIF
   ELSE
    RETURN(eso_format_dbnull(1))
   ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_code_blank(fvalue)
   IF (fvalue > 0)
    RETURN(substring(1,40,concat("##CVA##",",",trim(cnvtstring(fvalue)))))
   ELSE
    RETURN(" ")
   ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_code_aliases(fvalue1,fvalue2)
   IF (fvalue1 > 0
    AND fvalue2 > 0)
    RETURN(substring(1,40,concat("##CVAS##",",",trim(cnvtstring(fvalue1)),",",trim(cnvtstring(fvalue2
        )))))
   ELSE
    RETURN(" ")
   ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_code_ctx(fvalue)
   RETURN(eso_format_code(fvalue))
 END ;Subroutine
 SUBROUTINE eso_format_code_blank_ctx(fvalue)
   RETURN(eso_format_code_blank(fvalue))
 END ;Subroutine
 SUBROUTINE eso_format_alias(field1,field2,type,subtype,pool,alias)
  CALL echo(concat("alias type ",cnvtstring(type)))
  IF (type > 0)
   CALL echo("alias type > 0 ")
   IF (trim(alias)="")
    CALL echo('alias <= ""')
    RETURN(substring(1,200,concat("##ALIAS##",",",trim(field1),",",trim(field2),
      ",",trim(cnvtstring(type)),",",trim(cnvtstring(subtype)),",",
      trim(cnvtstring(pool)),","," ",","," ",
      ","," ")))
   ELSE
    CALL echo('alias > ""')
    RETURN(substring(1,200,concat("##ALIAS##",",",trim(field1),",",trim(field2),
      ",",trim(cnvtstring(type)),",",trim(cnvtstring(subtype)),",",
      trim(cnvtstring(pool)),","," ",","," ",
      ",",trim(alias))))
   ENDIF
  ELSE
   CALL echo("alias type <= 0 ")
   RETURN(" ")
  ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_alias_ctx(field1,field2,type,subtype,pool,alias)
  CALL echo(concat("alias type ",cnvtstring(type)))
  IF (type > 0)
   CALL echo("alias type > 0 ")
   IF (trim(alias)="")
    CALL echo('alias <= ""')
    RETURN(substring(1,200,concat("##ALIAS##",",",trim(field1),",",trim(field2),
      ",",trim(cnvtstring(type)),",",trim(cnvtstring(subtype)),",",
      trim(cnvtstring(pool)),","," ",","," ",
      ","," ")))
   ELSE
    CALL echo('alias > ""')
    RETURN(substring(1,200,concat("##ALIAS##",",",trim(field1),",",trim(field2),
      ",",trim(cnvtstring(type)),",",trim(cnvtstring(subtype)),",",
      trim(cnvtstring(pool)),","," ",","," ",
      ",",trim(alias))))
   ENDIF
  ELSE
   CALL echo("alias type <= 0 ")
   RETURN(" ")
  ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_dbnull(dummy)
   RETURN(substring(1,40,"##NULL##"))
 END ;Subroutine
 SUBROUTINE eso_format_dbnull_ctx(dummy)
   RETURN(substring(1,40,"##NULL##"))
 END ;Subroutine
 SUBROUTINE eso_format_org(msg_format,field_name,datatype,org_id,org_alias_type_cd,repeat_ind,
  assign_auth_org_id,fed_tax_id,org_name,future,future2)
  CALL echo(concat("org_id = ",cnvtstring(org_id)))
  IF (org_id > 0)
   CALL echo("org_id > 0 ")
   RETURN(substring(1,200,concat("##ORG##",",",trim(msg_format),",",trim(field_name),
     ",",trim(datatype),",",trim(cnvtstring(org_id)),",",
     trim(cnvtstring(org_alias_type_cd)),",",trim(cnvtstring(repeat_ind)),",",trim(cnvtstring(
       assign_auth_org_id)),
     ",",trim(cnvtstring(fed_tax_id)),",",trim(org_name),",",
     ",",",")))
  ELSE
   CALL echo("org_id <= 0 ")
   RETURN(" ")
  ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_hlthplan(field_name,msg_format,datatype,hlthplan_alias_type_cd,repeat_ind,
  future,future2,assign_auth_org_id,hlthplan_plan_name,hlthplan_id,ins_org_id)
  CALL echo(concat("hlthplan_id =",cnvtstring(hlthplan_id)))
  IF (hlthplan_id > 0)
   CALL echo("hlthplan_id > 0 ")
   RETURN(substring(1,200,concat("##HLTHPLAN##",",",trim(field_name),",",trim(msg_format),
     ",",trim(datatype),",",trim(cnvtstring(hlthplan_alias_type_cd)),",",
     trim(cnvtstring(repeat_ind)),",",",",",",trim(cnvtstring(assign_auth_org_id)),
     ",",trim(hlthplan_plan_name),",",trim(cnvtstring(hlthplan_id)),",",
     trim(cnvtstring(ins_org_id)))))
  ELSE
   CALL echo("hlthplan_id <= 0 ")
   RETURN(" ")
  ENDIF
 END ;Subroutine
 SUBROUTINE eso_encode_timing(value,unit)
   CALL echo("Entering eso_encode_timing subroutine")
   CALL echo(build("    value=",value))
   CALL echo(build("    unit=",unit))
   FREE SET t_timing
   FREE SET t_meaning
   IF (unit > 0)
    SET t_meaning = trim(uar_get_code_meaning(unit))
    CALL echo(build("    t_meaning=",t_meaning))
    IF (t_meaning="DOSES")
     SET t_timing = trim(build("X",cnvtstring(value)))
    ELSEIF (t_meaning="SECONDS")
     SET t_timing = trim(build("S",cnvtstring(value)))
    ELSEIF (t_meaning="MINUTES")
     SET t_timing = trim(build("M",cnvtstring(value)))
    ELSEIF (t_meaning="HOURS")
     SET t_timing = trim(build("H",cnvtstring(value)))
    ELSEIF (t_meaning="DAYS")
     SET t_timing = trim(build("D",cnvtstring(value)))
    ELSEIF (t_meaning="WEEKS")
     SET t_timing = trim(build("W",cnvtstring(value)))
    ELSEIF (t_meaning="MONTHS")
     SET t_timing = trim(build("L",cnvtstring(value)))
    ELSE
     SET t_timing = ""
    ENDIF
   ELSE
    SET t_timing = ""
   ENDIF
   CALL echo(build("    t_timing=",t_timing))
   CALL echo("Exiting eso_encode_timing subroutine")
   RETURN(t_timing)
 END ;Subroutine
 SUBROUTINE eso_encode_range(low,high)
   CALL echo("Entering eso_encode_range subroutine(low, high)")
   CALL echo(build("    low=",low))
   CALL echo(build("    high=",high))
   FREE SET t_range
   SET t_range = eso_encode_range_txt(cnvtstring(low),cnvtstring(high),"")
   CALL echo(build("t_range",t_range))
   CALL echo("Exiting eso_encode_range subroutine(low, high)")
   RETURN(t_range)
 END ;Subroutine
 SUBROUTINE (eso_encode_range_txt(low=vc,high=vc,text=vc) =vc)
   CALL echo("Entering eso_encode_range_txt subroutine(low, high, text)")
   CALL echo(build("    low=",low))
   CALL echo(build("    high=",high))
   CALL echo(build("    text=",text))
   IF (trim(text) > "")
    RETURN(text)
   ELSE
    IF (trim(high) > "")
     IF (trim(low) > "")
      RETURN(concat(low,"-",high))
     ELSE
      IF (isnumeric(high))
       RETURN(concat("<",high))
      ELSE
       RETURN(high)
      ENDIF
     ENDIF
    ELSE
     IF (trim(low) > "")
      IF (isnumeric(low))
       RETURN(concat(">",low))
      ELSE
       RETURN(low)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL echo("Exiting eso_encode_range_txt subroutine( low, high, text )")
   RETURN("")
 END ;Subroutine
 SUBROUTINE eso_encode_timing_noround(value,unit)
   CALL echo("Entering eso_encode_timing_noround subroutine")
   CALL echo(build("    value=",value))
   CALL echo(build("    unit=",unit))
   FREE SET t_timing
   FREE SET t_meaning
   IF (unit > 0)
    SET t_meaning = trim(uar_get_code_meaning(unit))
    CALL echo(build("    t_meaning=",t_meaning))
    IF (t_meaning="DOSES")
     SET t_timing = trim(build("X",value))
    ELSEIF (t_meaning="SECONDS")
     SET t_timing = trim(build("S",value))
    ELSEIF (t_meaning="MINUTES")
     SET t_timing = trim(build("M",value))
    ELSEIF (t_meaning="HOURS")
     SET t_timing = trim(build("H",value))
    ELSEIF (t_meaning="DAYS")
     SET t_timing = trim(build("D",value))
    ELSEIF (t_meaning="WEEKS")
     SET t_timing = trim(build("W",value))
    ELSEIF (t_meaning="MONTHS")
     SET t_timing = trim(build("L",value))
    ELSE
     SET t_timing = ""
    ENDIF
   ELSE
    SET t_timing = ""
   ENDIF
   CALL echo(build("    t_timing=",t_timing))
   CALL echo("Exiting eso_encode_timing_noround subroutine")
   RETURN(t_timing)
 END ;Subroutine
 SUBROUTINE (eso_format_frequency(freq_qual=i4) =c45)
   CALL echo("Entering eso_format_frequency subroutine")
   CALL echo(build("freq_qual = ",freq_qual))
   IF (freq_qual > 0)
    RETURN(substring(1,200,concat("##TIMEINTSTR##",",",build(freq_qual))))
   ELSE
    RETURN(" ")
   ENDIF
 END ;Subroutine
 SUBROUTINE (eso_format_pharm_timing(encoded=vc,noround=vc,type_meaning=vc) =c200)
   CALL echo("Entering eso_format_pharm_timing subroutine")
   CALL echo(build("encoded = ",encoded))
   CALL echo(build("noround = ",noround))
   CALL echo(build("type_meaning = ",type_meaning))
   IF (type_meaning > " ")
    RETURN(substring(1,200,concat("##PHARMTIMING##",",",trim(encoded),",",trim(noround),
      ",",trim(type_meaning))))
   ELSE
    CALL echo("Invalid Type")
    RETURN(" ")
   ENDIF
 END ;Subroutine
 SUBROUTINE encode_delimiter(original_string,search_string,replace_string)
   CALL echo("Entering encode_delimiter subroutine")
   DECLARE str_replace_string = vc
   SET str_replace_string = replace(original_string,search_string,replace_string,0)
   RETURN(str_replace_string)
 END ;Subroutine
 SUBROUTINE eso_format_previous_result(strverifydttm,struser,strresultval,strresultunitcd,
  strnormalcycd,strusername,strtype)
   CALL echo("Entering eso_format_previous_result subroutine")
   SET strresultval1 = encode_delimiter(strresultval,";","\SC\")
   RETURN(concat("##CORRECTRESULT##",";",trim(strverifydttm),";",trim(struser),
    ";",trim(strresultval1),";",trim(strresultunitcd),";",
    trim(strnormalcycd),";",trim(strusername),";",trim(strtype)))
 END ;Subroutine
 SUBROUTINE eso_format_short_result(strverifydttm,struser,strusername,strtype)
  CALL echo("Entering eso_format_short_result subroutine")
  RETURN(concat("##CORRECTRESULT##",";",trim(strverifydttm),";",trim(struser),
   ";",trim(strusername),";",trim(strtype)))
 END ;Subroutine
 SUBROUTINE eso_format_code_for_cs(fvalue,strcodingsys,straliastypmeaning)
   IF (fvalue > 0)
    RETURN(trim(concat("##CVA_W_CS##",",",trim(cnvtstring(fvalue)),",",trim(strcodingsys),
      ",",trim(straliastypmeaning))))
   ELSE
    RETURN("")
   ENDIF
 END ;Subroutine
 SUBROUTINE eso_format_multum_identifiers(catalog_cd,synonym_id,item_id,field_type,format_string)
   RETURN(concat("##SEND_MULTUM_IDENT##",";",trim(cnvtstring(catalog_cd)),";",trim(cnvtstring(
      synonym_id)),
    ";",trim(cnvtstring(item_id)),";",trim(field_type),";",
    trim(format_string),";"))
 END ;Subroutine
 SUBROUTINE eso_format_attachment(strattachmentname,dstoragecd,strblobhandle,dformatcd,strcommentind)
   RETURN(concat("##ATTACHMENT##",",",trim(strattachmentname),",",trim(cnvtstring(dstoragecd)),
    ",",trim(strblobhandle),",",trim(cnvtstring(dformatcd)),",",
    trim(strcommentind)))
 END ;Subroutine
 SUBROUTINE (eso_format_code_with_event_id(deventcd=f8,deventid=f8,dentitycd=f8,strsegmentname=vc,
  strfieldtype=vc) =vc)
   RETURN(eso_format_code_with_event_id_and_vocab_type(deventcd,deventid,dentitycd,strsegmentname,
    strfieldtype,
    "TEST"))
 END ;Subroutine
 SUBROUTINE (eso_format_code_with_event_id_and_vocab_type(deventcd=f8,deventid=f8,dentitycd=f8,
  strsegmentname=vc,strfieldtype=vc,strvocabularytype=vc) =vc)
   RETURN(trim(concat("##CVA##",",",trim(cnvtstring(deventcd)),","," ,",
     " ,",trim(cnvtstring(deventid)),",",trim(cnvtstring(dentitycd)),",",
     trim(strsegmentname),",",trim(strfieldtype),", ,",trim(strvocabularytype))))
 END ;Subroutine
 SUBROUTINE (eso_format_code_with_event_id_suscep_seq_nbr(deventcd=f8,deventid=f8,dentitycd=f8,
  strsegmentname=vc,strfieldtype=vc,isuscepseqnbr=i4,strvocabularytype=vc) =vc)
   RETURN(trim(concat("##CVA##",",",trim(cnvtstring(deventcd)),","," ,",
     " ,",trim(cnvtstring(deventid)),",",trim(cnvtstring(dentitycd)),",",
     trim(strsegmentname),",",trim(strfieldtype),",",trim(cnvtstring(isuscepseqnbr)),
     ",",trim(strvocabularytype))))
 END ;Subroutine
 SUBROUTINE (eso_format_code_with_event_id_micro_seq_nbr(deventcd=f8,deventid=f8,dentitycd=f8,
  strsegmentname=vc,strfieldtype=vc,imicroseqnbr=i4,strvocabularytype=vc) =vc)
   RETURN(trim(concat("##CVA##",",",trim(cnvtstring(deventcd)),","," ,",
     " ,",trim(cnvtstring(deventid)),",",trim(cnvtstring(dentitycd)),",",
     trim(strsegmentname),",",trim(strfieldtype),",",trim(cnvtstring(imicroseqnbr)),
     ",",trim(strvocabularytype))))
 END ;Subroutine
 SUBROUTINE (eso_format_nomen_or_string(strvalue=vc,deventid=f8,dentitycd=f8,strsegmentname=vc,
  strfieldtype=vc,imicroseqnbr=i4) =vc)
   RETURN(trim(concat("##NOS##",",",trim(strvalue),",",trim(cnvtstring(deventid)),
     ",",trim(cnvtstring(dentitycd)),",",trim(strsegmentname),",",
     trim(strfieldtype),",",trim(cnvtstring(imicroseqnbr)))))
 END ;Subroutine
 SUBROUTINE (eso_nomen_concept(dnomenid=f8) =i4)
   DECLARE icnt = i4 WITH protect, noconstant(1)
   DECLARE inomenidx = i4 WITH protect, noconstant(0)
   DECLARE inomensize = i4 WITH protect, noconstant(size(result_struct->nomenclatures,5))
   SET inomenidx = locateval(icnt,1,inomensize,dnomenid,result_struct->nomenclatures[icnt].nomen_id)
   IF (inomenidx=0)
    SELECT INTO "nl:"
     n.source_string, n.source_vocabulary_cd, cmt.concept_identifier,
     cmt.concept_name
     FROM cmt_concept cmt,
      nomenclature n
     PLAN (n
      WHERE n.nomenclature_id=dnomenid)
      JOIN (cmt
      WHERE cmt.concept_cki=n.concept_cki
       AND cmt.active_ind=1)
     DETAIL
      IF (size(trim(n.concept_cki)) > 0)
       inomenidx = (inomensize+ 1), stat = alterlist(result_struct->nomenclatures,inomenidx),
       result_struct->nomenclatures[inomenidx].nomen_id = dnomenid,
       result_struct->nomenclatures[inomenidx].concept_ident = cmt.concept_identifier, result_struct
       ->nomenclatures[inomenidx].concept_name = cmt.concept_name, result_struct->nomenclatures[
       inomenidx].source_string = n.source_string,
       result_struct->nomenclatures[inomenidx].source_vocab_cd = n.source_vocabulary_cd
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   RETURN(inomenidx)
 END ;Subroutine
 SUBROUTINE (populate_order_diagnoses(dorderid=f8,iobridx=i4) =i4)
   DECLARE idiagsize = i4 WITH protect, noconstant(0)
   DECLARE idiagidx = i4 WITH protect, noconstant(0)
   DECLARE inomidx = i4 WITH protect, noconstant(0)
   DECLARE dorderdiagcd = f8 WITH protect, constant(eso_get_meaning_by_codeset(23549,"ORDERDIAG"))
   DECLARE dordericd9cd = f8 WITH protect, constant(eso_get_meaning_by_codeset(23549,"ORDERICD9"))
   FREE RECORD diaglist
   RECORD diaglist(
     1 item[*]
       2 nomen_id = f8
       2 ft_desc = vc
   )
   SELECT INTO "nl:"
    table_ind = decode(n.seq,"n",d.seq,"d","x"), n.nomenclature_id, d.diag_ftdesc
    FROM nomen_entity_reltn er,
     nomenclature n,
     diagnosis d,
     (dummyt d1  WITH seq = 1),
     (dummyt d2  WITH seq = 1)
    PLAN (er
     WHERE er.active_ind > 0
      AND er.parent_entity_name="ORDERS"
      AND er.parent_entity_id=dorderid
      AND ((er.reltn_type_cd=dorderdiagcd) OR (er.reltn_type_cd=dordericd9cd)) )
     JOIN (d1)
     JOIN (((n
     WHERE er.nomenclature_id > 0.0
      AND n.nomenclature_id=er.nomenclature_id)
     ) ORJOIN ((d2)
     JOIN (d
     WHERE er.nomenclature_id <= 0.0
      AND er.child_entity_name="DIAGNOSIS"
      AND d.diagnosis_id=er.child_entity_id)
     ))
    HEAD REPORT
     i = 0
    DETAIL
     CASE (table_ind)
      OF "n":
       i += 1,stat = alterlist(diaglist->item,i),diaglist->item[i].nomen_id = n.nomenclature_id
      OF "d":
       i += 1,stat = alterlist(diaglist->item,i),diaglist->item[i].ft_desc = trim(d.diag_ftdesc,3)
      OF "x":
       CALL echo(build(
        "WARNING!! Did NOT join to either NOMENCLATURE or DIAGNOSIS tables for ORDER_ID = ",dorderid)
       )
     ENDCASE
    WITH nocounter, outerjoin = d1
   ;end select
   SET idiagsize = size(diaglist->item,5)
   FOR (idiagidx = 1 TO idiagsize)
     IF ((diaglist->item[idiagidx].nomen_id > 0.0))
      SET ifoundidx = eso_nomen_concept(diaglist->item[idiagidx].nomen_id)
      IF (ifoundidx)
       SET irealidx = (size(context->person_group[1].res_oru_group[iobridx].obr[1].relevant_clin_info,
        5)+ 1)
       SET stat = alterlist(context->person_group[1].res_oru_group[iobridx].obr[1].relevant_clin_info,
        irealidx)
       SET context->person_group[1].res_oru_group[iobridx].obr[1].relevant_clin_info[irealidx].
       identifier = result_struct->nomenclatures[ifoundidx].concept_ident
       SET context->person_group[1].res_oru_group[iobridx].obr[1].relevant_clin_info[irealidx].text
        = result_struct->nomenclatures[ifoundidx].concept_name
       SET context->person_group[1].res_oru_group[iobridx].obr[1].relevant_clin_info[irealidx].
       coding_system = eso_format_code(result_struct->nomenclatures[ifoundidx].source_vocab_cd)
       SET context->person_group[1].res_oru_group[iobridx].obr[1].relevant_clin_info[irealidx].
       original_text = result_struct->nomenclatures[ifoundidx].source_string
      ENDIF
     ELSEIF (size(trim(diaglist->item[idiagidx].ft_desc)) > 0)
      SET irealidx = (size(context->person_group[1].res_oru_group[iobridx].obr[1].relevant_clin_info,
       5)+ 1)
      SET stat = alterlist(context->person_group[1].res_oru_group[iobridx].obr[1].relevant_clin_info,
       irealidx)
      SET context->person_group[1].res_oru_group[iobridx].obr[1].relevant_clin_info[irealidx].text =
      trim(diaglist->item[idiagidx].ft_desc)
     ENDIF
   ENDFOR
   RETURN(size(context->person_group[1].res_oru_group[iobridx].obr[1].relevant_clin_info,5))
 END ;Subroutine
 SUBROUTINE eso_format_phone_cd(dphonetypecd,dcontactmethodcd)
   IF ((validate(g_dpvdphtpalternate,- (1))=- (1)))
    DECLARE g_dpvdphtpalternate = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "ALTERNATE"))
   ENDIF
   IF ((validate(g_dpvdphtpbilling,- (1))=- (1)))
    DECLARE g_dpvdphtpbilling = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "BILLING"))
   ENDIF
   IF ((validate(g_dpvdphtpbusiness,- (1))=- (1)))
    DECLARE g_dpvdphtpbusiness = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "BUSINESS"))
   ENDIF
   IF ((validate(g_dpvdphtpfaxalt,- (1))=- (1)))
    DECLARE g_dpvdphtpfaxalt = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "FAX ALT"))
   ENDIF
   IF ((validate(g_dpvdphtpfaxbill,- (1))=- (1)))
    DECLARE g_dpvdphtpfaxbill = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "FAX BILL"))
   ENDIF
   IF ((validate(g_dpvdphtpfaxbus,- (1))=- (1)))
    DECLARE g_dpvdphtpfaxbus = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "FAX BUS"))
   ENDIF
   IF ((validate(g_dpvdphtpfaxpers,- (1))=- (1)))
    DECLARE g_dpvdphtpfaxpers = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "FAX PERS"))
   ENDIF
   IF ((validate(g_dpvdphtpfaxtemp,- (1))=- (1)))
    DECLARE g_dpvdphtpfaxtemp = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "FAX TEMP"))
   ENDIF
   IF ((validate(g_dpvdphtphome,- (1))=- (1)))
    DECLARE g_dpvdphtphome = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,"HOME"))
   ENDIF
   IF ((validate(g_dpvdphtpmobile,- (1))=- (1)))
    DECLARE g_dpvdphtpmobile = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "MOBILE"))
   ENDIF
   IF ((validate(g_dpvdphtposafterhour,- (1))=- (1)))
    DECLARE g_dpvdphtposafterhour = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "OS AFTERHOUR"))
   ENDIF
   IF ((validate(g_dpvdphtposphone,- (1))=- (1)))
    DECLARE g_dpvdphtposphone = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "OS PHONE"))
   ENDIF
   IF ((validate(g_dpvdphtpospager,- (1))=- (1)))
    DECLARE g_dpvdphtpospager = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "OS PAGER"))
   ENDIF
   IF ((validate(g_dpvdphtposbkoffice,- (1))=- (1)))
    DECLARE g_dpvdphtposbkoffice = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "OS BK OFFICE"))
   ENDIF
   IF ((validate(g_dpvdphtppageralt,- (1))=- (1)))
    DECLARE g_dpvdphtppageralt = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "PAGER ALT"))
   ENDIF
   IF ((validate(g_dpvdphtppagerbill,- (1))=- (1)))
    DECLARE g_dpvdphtppagerbill = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "PAGER BILL"))
   ENDIF
   IF ((validate(g_dpvdphtppagerbus,- (1))=- (1)))
    DECLARE g_dpvdphtppagerbus = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "PAGER BUS"))
   ENDIF
   IF ((validate(g_dpvdphtppagertemp,- (1))=- (1)))
    DECLARE g_dpvdphtppagertemp = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "PAGER TEMP"))
   ENDIF
   IF ((validate(g_dpvdphtppagerpers,- (1))=- (1)))
    DECLARE g_dpvdphtppagerpers = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "PAGER PERS"))
   ENDIF
   IF ((validate(g_dpvdphtppaging,- (1))=- (1)))
    DECLARE g_dpvdphtppaging = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "PAGING"))
   ENDIF
   IF ((validate(g_dpvdphtpportbus,- (1))=- (1)))
    DECLARE g_dpvdphtpportbus = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "PORT BUS"))
   ENDIF
   IF ((validate(g_dpvdphtpporttemp,- (1))=- (1)))
    DECLARE g_dpvdphtpporttemp = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "PORT TEMP"))
   ENDIF
   IF ((validate(g_dpvdphtpsecbusiness,- (1))=- (1)))
    DECLARE g_dpvdphtpsecbusiness = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "SECBUSINESS"))
   ENDIF
   IF ((validate(g_dpvdphtptechnical,- (1))=- (1)))
    DECLARE g_dpvdphtptechnical = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "TECHNICAL"))
   ENDIF
   IF ((validate(g_dpvdphtpverify,- (1))=- (1)))
    DECLARE g_dpvdphtpverify = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "VERIFY"))
   ENDIF
   IF ((validate(g_deprescphone,- (1))=- (1)))
    DECLARE g_deprescphone = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "PHONEEPRESCR"))
   ENDIF
   IF ((validate(g_deprescfax,- (1))=- (1)))
    DECLARE g_deprescfax = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(43,
      "FAXEPRESCR"))
   ENDIF
   IF ((validate(g_dpvdphfmtfax,- (1))=- (1)))
    DECLARE g_dpvdphfmtfax = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(23056,"FAX"
      ))
   ENDIF
   IF ((validate(g_dpvdphfmttel,- (1))=- (1)))
    DECLARE g_dpvdphfmttel = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(23056,"TEL"
      ))
   ENDIF
   IF ((validate(g_dpvdphfmtemail,- (1))=- (1)))
    DECLARE g_dpvdphfmtemail = f8 WITH public, persist, constant(eso_get_meaning_by_codeset(23056,
      "MAILTO"))
   ENDIF
   IF (((dcontactmethodcd=0) OR (dcontactmethodcd=g_dpvdphfmttel)) )
    IF (dphonetypecd IN (g_dpvdphtpalternate, g_dpvdphtpbilling, g_dpvdphtpbusiness, g_dpvdphtpfaxalt,
    g_dpvdphtpfaxbill,
    g_dpvdphtpfaxbus, g_dpvdphtpfaxpers, g_dpvdphtpfaxtemp, g_dpvdphtphome, g_dpvdphtpmobile,
    g_dpvdphtposafterhour, g_dpvdphtposphone, g_dpvdphtpospager, g_dpvdphtposbkoffice,
    g_dpvdphtppageralt,
    g_dpvdphtppagerbill, g_dpvdphtppagerbus, g_dpvdphtppagertemp, g_dpvdphtppagerpers,
    g_dpvdphtppaging,
    g_dpvdphtpportbus, g_dpvdphtpporttemp, g_dpvdphtpsecbusiness, g_dpvdphtptechnical,
    g_dpvdphtpverify,
    g_deprescphone, g_deprescfax))
     RETURN(eso_format_code(dphonetypecd))
    ELSE
     RETURN(" ")
    ENDIF
   ELSE
    RETURN(eso_format_code(dcontactmethodcd))
   ENDIF
 END ;Subroutine
 CALL echo("<===== ESO_HL7_FORMATTING.INC End =====>")
 IF (validate(g_dcontribsyscd)=0)
  DECLARE g_dcontribsyscd = f8 WITH public, persist, constant(get_contributor_system_cd(0))
 ENDIF
 CALL si_out_write_message(esidebug,build("PACKESO [",cnvtstring(g_dcontribsyscd),"]"))
 IF (g_dcontribsyscd=0.0)
  CALL si_out_write_message(esierror,
   "PACKESO is not properly configured, unable to process the message")
  SET oen_reply->status = "F"
  GO TO exit_script
 ENDIF
 DECLARE hmsh = i4 WITH constant(get_msh_handle(oen_request->in_obj))
 IF (hmsh > 0)
  DECLARE hmessagetype = i4 WITH constant(uar_srvgetstruct(hmsh,"MESSAGE_TYPE"))
  DECLARE strmessagetrigger = vc WITH constant(uar_srvgetstringptr(hmessagetype,"MESSG_TRIGGER"))
  DECLARE strmessagetype = vc WITH constant(uar_srvgetstringptr(hmessagetype,"MESSG_TYPE"))
  CALL si_out_write_message(esidebug,build("CONTROL_GROUP->MSH->MESSAGE_TYPE->MESSG_TYPE [",
    strmessagetype,"]"))
  CALL si_out_write_message(esidebug,build("CONTROL_GROUP->MSH->MESSAGE_TYPE->MESSG_TRIGGER [",
    strmessagetrigger,"]"))
  IF (strmessagetype="ADT")
   DECLARE dpersonid = f8 WITH noconstant(0.0)
   DECLARE hcerner = i4 WITH constant(uar_srvgetstruct(oen_request->in_obj,"CERNER"))
   IF (hcerner > 0)
    DECLARE hperson_info = i4 WITH constant(uar_srvgetstruct(hcerner,"PERSON_INFO"))
    IF (hperson_info > 0)
     DECLARE hperson = i4 WITH constant(uar_srvgetitem(hperson_info,"PERSON",0))
     IF (hperson > 0)
      SET dpersonid = uar_srvgetdouble(hperson,"PERSON_ID")
     ENDIF
    ENDIF
   ENDIF
   CALL si_out_write_message(esidebug,build("CERNER->PERSON_INFO->PERSON->PERSON_ID [",cnvtstring(
      dpersonid),"]"))
   IF (dpersonid > 0.0)
    DECLARE hperson_group = i4 WITH constant(uar_srvgetitem(oen_request->in_obj,"PERSON_GROUP",0))
    IF (hperson_group > 0)
     DECLARE hpat_group = i4 WITH constant(uar_srvgetitem(hperson_group,"PAT_GROUP",0))
     IF (hpat_group > 0)
      DECLARE lastdt = dq8 WITH noconstant(null)
      SELECT INTO "nl:"
       s.doc_retr_complete_dt_tm
       FROM si_xdoc_metadata s
       WHERE s.person_id=dpersonid
        AND s.contributor_system_cd=g_dcontribsyscd
       ORDER BY s.doc_retr_complete_dt_tm DESC
       DETAIL
        lastdt = s.doc_retr_complete_dt_tm
       WITH nocounter, maxrec = 1
      ;end select
      IF (lastdt != null)
       CALL si_out_write_message(esidebug,build(
         "The last retrieved complete date/time for the document is [",format(lastdt,"mm/dd/yy;;d"),
         "]"))
       DECLARE hobx = i4 WITH constant(uar_srvadditem(hpat_group,"OBX"))
       IF (hobx)
        CALL uar_srvsetstring(hobx,"SET_ID",nullterm(cnvtstring(uar_srvgetitemcount(hpat_group,"OBX")
           )))
        CALL uar_srvsetstring(hobx,"VALUE_TYPE",nullterm("DT"))
        DECLARE hobsval = i4 WITH constant(uar_srvadditem(hobx,"OBSERVATION_VALUE"))
        CALL echo(hobsval)
        IF (hobsval > 0)
         CALL uar_srvsetstring(hobsval,"value_1",nullterm(eso_format_dttm(lastdt,hl7_dt_tm,"")))
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
#exit_script
END GO
