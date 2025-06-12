CREATE PROGRAM ams_tallman_multum:dba
 PAINT
 SET modify = predeclare
 DECLARE include_combo_drug = i2 WITH constant(request->combo_ind), protect
 DECLARE ignore_mismatch_warn = i2 WITH constant(request->ignore_mismatch_ind), protect
 DECLARE regex_combo_drug = cv WITH constant(request->regex_chars), protect
 DECLARE tallman_file = vc WITH constant(request->tman_filename), protect
 DECLARE delim = vc WITH constant(","), protect
 DECLARE numrows = i4 WITH constant(20), protect
 DECLARE numcols = i4 WITH constant(75), protect
 DECLARE soffrow = i4 WITH constant(6), protect
 DECLARE soffcol = i4 WITH constant(3), protect
 DECLARE cdpharmacy = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY")), protect
 DECLARE cdtyperxmnem = f8 WITH constant(uar_get_code_by("MEANING",6011,"RXMNEMONIC")), protect
 DECLARE cdtypeprimary = f8 WITH constant(uar_get_code_by("MEANING",6011,"PRIMARY")), protect
 DECLARE cdtypemed = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6026,"MEDICATION")), protect
 DECLARE debug_ind = i2 WITH constant(request->debug_ind), protect
 DECLARE start_dt_tm = dq8 WITH constant(cnvtdatetime(request->begin_dt_tm)), protect
 DECLARE loadprsnlid = f8 WITH constant(request->prsnl_id), protect
 DECLARE check_all = i2 WITH constant(request->check_all_ind), protect
 DECLARE mnem_cnt = i4 WITH protect
 DECLARE primary_cnt = i4 WITH protect
 DECLARE last_mod = vc WITH protect
 DECLARE loadtallmanfile(sfilename=vc) = i2 WITH protect
 DECLARE getsynonymmatches(null) = i4 WITH protect
 DECLARE getprimarymatches(null) = i4 WITH protect
 DECLARE gettallmanmnemonic(stallmanstr=vc,sorigmnemonic=vc) = vc WITH protect
 DECLARE displaymatches(null) = null WITH protect
 DECLARE clearscreen(null) = null WITH protect
 DECLARE displaysynstoupdate(null) = null WITH protect
 DECLARE drawscrollbox(begrow=i4,begcol=i4,endrow=i4,endcol=i4) = null WITH protect
 DECLARE downarrow(newrow=c75) = null WITH protect
 DECLARE uparrow(newrow=c75) = null WITH protect
 DECLARE buildrowstr(i=i4) = c75 WITH protect
 DECLARE performupdates(null) = null WITH protect
 FREE RECORD tman
 RECORD tman(
   1 search_list_sz = i4
   1 search_list[*]
     2 tallman_str = vc
     2 tallman_str_cap = vc
     2 tallman_str_search = vc
     2 tallman_str_search_alphanum = vc
     2 syn_list[*]
       3 primary_mnemonic = vc
       3 synonym_id = f8
       3 synonym_type = vc
       3 orig_mnemonic = vc
       3 proposed_mnemonic = vc
       3 ref_task_id = f8
       3 orig_task = vc
       3 proposed_task = vc
       3 event_set_cd = f8
       3 orig_event_set = vc
       3 proposed_event_set = vc
       3 event_cd = f8
       3 orig_event_cd = vc
       3 proposed_event_cd = vc
 )
 FREE RECORD updt_rec
 RECORD updt_rec(
   1 updt_list_sz = i4
   1 updt_list[*]
     2 primary_ind = i2
     2 synonym_id = f8
     2 new_mnemonic = vc
     2 ref_task_id = f8
     2 new_task = vc
     2 event_set_cd = f8
     2 new_event_set = vc
     2 event_cd = f8
     2 new_event_cd = vc
 )
 IF (debug_ind=1)
  CALL echo("Debug Mode Enabled")
 ELSE
  SET trace = callecho
  SET trace = notest
  SET trace = noechoinput
  SET trace = noechoinput2
  SET trace = noechorecord
  SET trace = noshowuar
  SET message = noinformation
  SET trace = nocost
 ENDIF
 IF (loadtallmanfile(tallman_file) <= 0)
  CALL clearscreen(null)
  CALL text(soffrow,soffcol,"No tallman strings loaded.")
  CALL text((soffrow+ 1),soffcol,build2("Check that the file exists in CCLUSERDIR: ",tallman_file))
  CALL text((soffrow+ 16),soffcol,"Continue?:")
  CALL accept((soffrow+ 16),(soffcol+ 11),"A;CU","Y"
   WHERE curaccept IN ("Y"))
 ELSE
  SET mnem_cnt = getsynonymmatches(null)
  IF (mnem_cnt > 0)
   SET primary_cnt = getprimarymatches(null)
#repick_syns
   CALL displaymatches(null)
   IF ((updt_rec->updt_list_sz > 0))
    CALL displaysynstoupdate(null)
   ENDIF
  ELSE
   CALL clearscreen(null)
   CALL text(soffrow,soffcol,"No new synonyms found to tallman.")
   CALL text((soffrow+ 16),soffcol,"Continue?:")
   CALL accept((soffrow+ 16),(soffcol+ 11),"A;CU","Y"
    WHERE curaccept IN ("Y"))
  ENDIF
 ENDIF
 SUBROUTINE loadtallmanfile(sfilename)
   DECLARE i = i4 WITH protect
   DECLARE tcnt = i4 WITH protect
   DECLARE beg_index = i4 WITH protect
   DECLARE end_index = i4 WITH protect
   DECLARE tstrlen = i4 WITH protect
   CALL echo(build("Reading tallman synonyms from file: ",sfilename))
   CALL text(soffrow,soffcol,build("Reading tallman synonyms from file: ",sfilename))
   FREE DEFINE rtl
   DEFINE rtl sfilename
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    WHERE  NOT (r.line IN (" ", null))
    HEAD REPORT
     tcnt = 0
    DETAIL
     beg_index = 1, end_index = 0, tcnt = (tcnt+ 1)
     IF (mod(tcnt,100)=1)
      stat = alterlist(tman->search_list,(tcnt+ 99))
     ENDIF
     end_index = findstring(delim,r.line,beg_index), tstrlen = (end_index - beg_index)
     IF (end_index > 0)
      tman->search_list[tcnt].tallman_str = substring(beg_index,tstrlen,r.line)
     ELSE
      tman->search_list[tcnt].tallman_str = r.line
     ENDIF
     tman->search_list[tcnt].tallman_str_cap = cnvtupper(tman->search_list[tcnt].tallman_str), tman->
     search_list[tcnt].tallman_str_search = build("*",cnvtupper(tman->search_list[tcnt].tallman_str),
      "*"), tman->search_list[tcnt].tallman_str_search_alphanum = build("*",cnvtalphanum(cnvtupper(
        tman->search_list[tcnt].tallman_str)),"*"),
     beg_index = (end_index+ 1)
    FOOT REPORT
     IF (mod(tcnt,100) != 0)
      stat = alterlist(tman->search_list,tcnt)
     ENDIF
    WITH nocounter
   ;end select
   SET tman->search_list_sz = size(tman->search_list,5)
   CALL clearscreen(null)
   RETURN(evaluate(tman->search_list_sz,0,0,1))
 END ;Subroutine
 SUBROUTINE gettallmanmnemonic(stallmanstr,sorigmnemonic)
   DECLARE startpos = i4 WITH protect
   DECLARE endpos = i4 WITH protect
   DECLARE final_str = vc WITH protect
   DECLARE prefix = vc WITH protect
   DECLARE suffix = vc WITH protect
   SET startpos = 1
   SET endpos = findstring(cnvtupper(stallmanstr),cnvtupper(sorigmnemonic))
   SET prefix = notrim(substring(startpos,(endpos - 1),sorigmnemonic))
   SET startpos = (endpos+ textlen(stallmanstr))
   SET endpos = ((textlen(sorigmnemonic) - startpos)+ 1)
   SET suffix = substring(startpos,endpos,sorigmnemonic)
   SET final_str = concat(prefix,stallmanstr,suffix)
   IF (debug_ind=1)
    CALL echo(build("sTallmanStr: ",stallmanstr))
    CALL echo(build("sOrigSynonym: ",sorigmnemonic))
    CALL echo(build("final_str: ",final_str))
   ENDIF
   RETURN(final_str)
 END ;Subroutine
 SUBROUTINE getsynonymmatches(null)
   DECLARE i = i4 WITH protect
   DECLARE tcnt = i4 WITH protect
   DECLARE exportcnt = i4 WITH protect
   DECLARE tallman_mnemonic = vc WITH protect
   DECLARE combodrugprefix = i2 WITH protect
   DECLARE combodrugsuffix = i2 WITH protect
   DECLARE combodrug = i2 WITH protect
   DECLARE partialdrugprefix = i2 WITH protect
   DECLARE partialdrugsuffix = i2 WITH protect
   DECLARE partialdrug = i2 WITH protect
   CALL text(soffrow,soffcol,"Checking for any new synonyms to tallman")
   FOR (i = 1 TO tman->search_list_sz)
     CALL echo(build("Checking tallman record for synonym matches:",i,":",tman->search_list[i].
       tallman_str))
     CALL text(soffrow,(soffcol+ 62),build2(trim(cnvtstring(i))," of ",trim(cnvtstring(tman->
         search_list_sz))))
     SELECT INTO "nl:"
      ocs.synonym_id, ocs.updt_dt_tm, ocs.mnemonic,
      synonymtype = uar_get_code_display(ocs.mnemonic_type_cd), ocs.mnemonic_key_cap, oc.catalog_cd,
      oc.primary_mnemonic
      FROM order_catalog_synonym ocs,
       order_catalog oc
      PLAN (ocs
       WHERE ocs.updt_dt_tm >= cnvtdatetime(start_dt_tm)
        AND ((((ocs.updt_id+ 0)=loadprsnlid)) OR (check_all=1))
        AND ocs.mnemonic_key_cap=patstring(tman->search_list[i].tallman_str_search)
        AND  NOT (((ocs.mnemonic_type_cd+ 0) IN (cdtyperxmnem)))
        AND ((ocs.catalog_type_cd+ 0)=cdpharmacy)
        AND ((ocs.active_ind+ 0)=1)
        AND ocs.active_status_dt_tm >= cnvtdatetime(start_dt_tm))
       JOIN (oc
       WHERE ocs.catalog_cd=oc.catalog_cd)
      ORDER BY cnvtupper(oc.primary_mnemonic), synonymtype, ocs.mnemonic
      HEAD REPORT
       tcnt = 0
      DETAIL
       combodrugprefix = operator(cnvtupper(oc.primary_mnemonic),"REGEXPLIKE",concat(regex_combo_drug,
         tman->search_list[i].tallman_str_cap)), combodrugsuffix = operator(cnvtupper(oc
         .primary_mnemonic),"REGEXPLIKE",concat(tman->search_list[i].tallman_str_cap,regex_combo_drug
         )), combodrug = bor(combodrugprefix,combodrugsuffix),
       partialdrugprefix = operator(cnvtupper(oc.primary_mnemonic),"REGEXPLIKE",concat("[A-Z]",tman->
         search_list[i].tallman_str_cap)), partialdrugsuffix = operator(cnvtupper(oc.primary_mnemonic
         ),"REGEXPLIKE",concat(tman->search_list[i].tallman_str_cap,"[A-Z]")), partialdrug = bor(
        partialdrugprefix,partialdrugsuffix)
       IF (debug_ind=1)
        CALL echo("*****************************************"),
        CALL echo(oc.primary_mnemonic),
        CALL echo(ocs.mnemonic),
        CALL echo(build("ComboDrug: ",combodrug)),
        CALL echo(build("ComboDrugPrefix: ",combodrugprefix)),
        CALL echo(build("ComboDrugSuffix: ",combodrugsuffix)),
        CALL echo(build("PartialDrug: ",partialdrug)),
        CALL echo(build("PartialDrugPrefix: ",partialdrugprefix)),
        CALL echo(build("PartialDrugSuffix: ",partialdrugsuffix))
       ENDIF
       tallman_mnemonic = gettallmanmnemonic(tman->search_list[i].tallman_str,ocs.mnemonic)
       IF (tallman_mnemonic != ocs.mnemonic
        AND partialdrug=0
        AND ((combodrug=0) OR (include_combo_drug=1)) )
        exportcnt = (exportcnt+ 1), tcnt = (tcnt+ 1)
        IF (mod(tcnt,100)=1)
         stat = alterlist(tman->search_list[i].syn_list,(tcnt+ 99))
        ENDIF
        tman->search_list[i].syn_list[tcnt].primary_mnemonic = oc.primary_mnemonic, tman->
        search_list[i].syn_list[tcnt].synonym_id = ocs.synonym_id, tman->search_list[i].syn_list[tcnt
        ].synonym_type = uar_get_code_display(ocs.mnemonic_type_cd),
        tman->search_list[i].syn_list[tcnt].orig_mnemonic = ocs.mnemonic, tman->search_list[i].
        syn_list[tcnt].proposed_mnemonic = tallman_mnemonic
       ELSE
        CALL echo(build("Skipping synonym: ",ocs.mnemonic))
       ENDIF
      FOOT REPORT
       IF (mod(tcnt,100) != 0)
        stat = alterlist(tman->search_list[i].syn_list,tcnt)
       ENDIF
      WITH nocounter
     ;end select
   ENDFOR
   CALL echo(build2("Found ",exportcnt," synonyms to tallman"))
   CALL clearscreen(null)
   RETURN(exportcnt)
 END ;Subroutine
 SUBROUTINE getprimarymatches(null)
   DECLARE i = i4 WITH protect
   DECLARE j = i4 WITH protect
   DECLARE tallman_es = vc WITH protect
   DECLARE tallman_task = vc WITH protect
   DECLARE tallman_ec = vc WITH protect
   FOR (i = 1 TO tman->search_list_sz)
    SET j = 0
    FOR (j = 1 TO size(tman->search_list[i].syn_list,5))
      IF (cnvtupper(tman->search_list[i].syn_list[j].synonym_type)="PRIMARY")
       SELECT INTO "nl:"
        ocs.synonym_id, ocs.mnemonic, oc.catalog_cd,
        oc.primary_mnemonic, ot.reference_task_id, ot.task_description,
        es.event_set_cd, es.event_set_cd_disp, ec.event_cd,
        ec.event_cd_disp
        FROM order_catalog_synonym ocs,
         order_catalog oc,
         order_task_xref ox,
         order_task ot,
         code_value_event_r cver,
         v500_event_set_explode vee,
         v500_event_set_code es,
         v500_event_code ec
        PLAN (ocs
         WHERE (ocs.synonym_id=tman->search_list[i].syn_list[j].synonym_id)
          AND ((ocs.mnemonic_type_cd+ 0)=cdtypeprimary))
         JOIN (oc
         WHERE oc.catalog_cd=ocs.catalog_cd
          AND ((oc.catalog_type_cd+ 0)=cdpharmacy)
          AND oc.active_ind=1)
         JOIN (ox
         WHERE ox.catalog_cd=outerjoin(oc.catalog_cd))
         JOIN (ot
         WHERE ot.reference_task_id=outerjoin(ox.reference_task_id)
          AND ot.task_type_cd=outerjoin(cdtypemed)
          AND ot.active_ind=outerjoin(1))
         JOIN (cver
         WHERE cver.parent_cd=outerjoin(oc.catalog_cd))
         JOIN (vee
         WHERE vee.event_cd=outerjoin(cver.event_cd)
          AND vee.event_set_level=outerjoin(0))
         JOIN (es
         WHERE es.event_set_cd=outerjoin(vee.event_set_cd))
         JOIN (ec
         WHERE ec.event_cd=outerjoin(cver.event_cd))
        ORDER BY oc.primary_mnemonic
        DETAIL
         tallman_task = gettallmanmnemonic(tman->search_list[i].tallman_str,ot.task_description),
         tallman_ec = gettallmanmnemonic(tman->search_list[i].tallman_str,ec.event_cd_disp),
         tallman_es = gettallmanmnemonic(tman->search_list[i].tallman_str,es.event_set_cd_disp)
         IF (debug_ind=1)
          CALL echo(build("tman->search_list: ",i)),
          CALL echo(build("orig task: ",ot.task_description)),
          CALL echo(build("proposed task: ",tallman_task)),
          CALL echo(build("orig event_cd: ",ec.event_cd_disp)),
          CALL echo(build("proposed event_cd: ",tallman_ec)),
          CALL echo(build("orig event_set: ",es.event_set_cd_disp)),
          CALL echo(build("proposed event_set: ",tallman_es))
         ENDIF
         IF (((tallman_task != ot.task_description) OR (((tallman_ec != ec.event_cd_disp) OR (
         tallman_es != es.event_set_cd_disp)) )) )
          primary_cnt = (primary_cnt+ 1)
          IF (tallman_task != ot.task_description)
           tman->search_list[i].syn_list[j].ref_task_id = ot.reference_task_id, tman->search_list[i].
           syn_list[j].orig_task = ot.task_description, tman->search_list[i].syn_list[j].
           proposed_task = tallman_task
          ENDIF
          IF (tallman_ec != ec.event_cd_disp)
           tman->search_list[i].syn_list[j].event_cd = ec.event_cd, tman->search_list[i].syn_list[j].
           orig_event_cd = ec.event_cd_disp, tman->search_list[i].syn_list[j].proposed_event_cd =
           tallman_ec
          ENDIF
          IF (tallman_es != es.event_set_cd_disp)
           tman->search_list[i].syn_list[j].event_set_cd = es.event_set_cd, tman->search_list[i].
           syn_list[j].orig_event_set = es.event_set_cd_disp, tman->search_list[i].syn_list[j].
           proposed_event_set = tallman_es
          ENDIF
         ENDIF
        WITH nocounter
       ;end select
      ENDIF
    ENDFOR
   ENDFOR
   RETURN(primary_cnt)
 END ;Subroutine
 SUBROUTINE displaymatches(null)
   DECLARE i = i4 WITH protect
   DECLARE cnt = i4 WITH protect
   DECLARE tcnt = i4 WITH protect
   DECLARE syncnt = i4 WITH protect
   SET tcnt = 1
   FOR (i = 1 TO tman->search_list_sz)
     FOR (cnt = 1 TO size(tman->search_list[i].syn_list,5))
       CALL clearscreen(null)
       CALL text(soffrow,soffcol,"Tallman string:")
       CALL text((soffrow+ 1),soffcol,"Primary:")
       CALL text((soffrow+ 2),soffcol,"Synonym_ID:")
       CALL text((soffrow+ 3),soffcol,"Synonym Type:")
       CALL text((soffrow+ 4),soffcol,"Original Synonym:")
       CALL text((soffrow+ 5),soffcol,"Proposed Synonym:")
       CALL text(soffrow,(soffcol+ 18),substring(1,57,tman->search_list[i].tallman_str))
       CALL text((soffrow+ 1),(soffcol+ 18),substring(1,57,tman->search_list[i].syn_list[cnt].
         primary_mnemonic))
       CALL text((soffrow+ 2),(soffcol+ 18),cnvtstring(tman->search_list[i].syn_list[cnt].synonym_id)
        )
       CALL text((soffrow+ 3),(soffcol+ 18),substring(1,57,tman->search_list[i].syn_list[cnt].
         synonym_type))
       CALL text((soffrow+ 4),(soffcol+ 18),substring(1,57,tman->search_list[i].syn_list[cnt].
         orig_mnemonic))
       CALL text((soffrow+ 5),(soffcol+ 18),substring(1,57,tman->search_list[i].syn_list[cnt].
         proposed_mnemonic))
       CALL text((soffrow+ 16),(soffcol+ 56),build2("Match ",trim(cnvtstring(tcnt))," of ",trim(
          cnvtstring(mnem_cnt))))
       CALL text((soffrow+ 16),soffcol,"Update Synonym? (Y)es (N)o (M)ain Menu:")
       CALL accept((soffrow+ 16),(soffcol+ 40),"A;CU","Y"
        WHERE curaccept IN ("Y", "N", "M"))
       IF (curaccept="Y")
        SET syncnt = (syncnt+ 1)
        SET stat = alterlist(updt_rec->updt_list,syncnt)
        SET updt_rec->updt_list[syncnt].synonym_id = tman->search_list[i].syn_list[cnt].synonym_id
        SET updt_rec->updt_list[syncnt].new_mnemonic = tman->search_list[i].syn_list[cnt].
        proposed_mnemonic
        IF (cnvtupper(tman->search_list[i].syn_list[cnt].synonym_type)="PRIMARY")
         SET updt_rec->updt_list[syncnt].primary_ind = 1
        ENDIF
       ELSEIF (curaccept="M")
        CALL clearscreen(null)
        GO TO exit_script
       ENDIF
       IF ((tman->search_list[i].syn_list[cnt].ref_task_id > 0))
        CALL text((soffrow+ 7),soffcol,"Original Task:")
        CALL text((soffrow+ 8),soffcol,"Proposed Task:")
        CALL text((soffrow+ 7),(soffcol+ 18),substring(1,57,tman->search_list[i].syn_list[cnt].
          orig_task))
        CALL text((soffrow+ 8),(soffcol+ 18),substring(1,57,tman->search_list[i].syn_list[cnt].
          proposed_task))
        CALL clear((soffrow+ 16),soffcol,55)
        CALL text((soffrow+ 16),soffcol,"Update Task? (Y)es (N)o (M)ain Menu:")
        CALL accept((soffrow+ 16),(soffcol+ 37),"A;CU","Y"
         WHERE curaccept IN ("Y", "N", "M"))
        IF (curaccept="Y")
         SET updt_rec->updt_list[syncnt].ref_task_id = tman->search_list[i].syn_list[cnt].ref_task_id
         SET updt_rec->updt_list[syncnt].new_task = tman->search_list[i].syn_list[cnt].proposed_task
        ELSEIF (curaccept="M")
         CALL clearscreen(null)
         GO TO exit_script
        ENDIF
       ENDIF
       IF ((tman->search_list[i].syn_list[cnt].event_set_cd > 0))
        CALL text((soffrow+ 10),soffcol,"Original EventSet:")
        CALL text((soffrow+ 11),soffcol,"Proposed EventSet:")
        CALL text((soffrow+ 10),(soffcol+ 18),substring(1,57,tman->search_list[i].syn_list[cnt].
          orig_event_set))
        CALL text((soffrow+ 11),(soffcol+ 18),substring(1,57,tman->search_list[i].syn_list[cnt].
          proposed_event_set))
        CALL clear((soffrow+ 16),soffcol,55)
        CALL text((soffrow+ 16),soffcol,"Update EventSet? (Y)es (N)o (M)ain Menu:")
        CALL accept((soffrow+ 16),(soffcol+ 41),"A;CU","Y"
         WHERE curaccept IN ("Y", "N", "M"))
        IF (curaccept="Y")
         SET updt_rec->updt_list[syncnt].event_set_cd = tman->search_list[i].syn_list[cnt].
         event_set_cd
         SET updt_rec->updt_list[syncnt].new_event_set = tman->search_list[i].syn_list[cnt].
         proposed_event_set
        ELSEIF (curaccept="M")
         CALL clearscreen(null)
         GO TO exit_script
        ENDIF
       ENDIF
       IF ((tman->search_list[i].syn_list[cnt].event_cd > 0))
        CALL text((soffrow+ 13),soffcol,"Original EventCD:")
        CALL text((soffrow+ 14),soffcol,"Proposed EventCD:")
        CALL text((soffrow+ 13),(soffcol+ 18),substring(1,57,tman->search_list[i].syn_list[cnt].
          orig_event_cd))
        CALL text((soffrow+ 14),(soffcol+ 18),substring(1,57,tman->search_list[i].syn_list[cnt].
          proposed_event_cd))
        CALL clear((soffrow+ 16),soffcol,55)
        CALL text((soffrow+ 16),soffcol,"Update EventCD? (Y)es (N)o (M)ain Menu:")
        CALL accept((soffrow+ 16),(soffcol+ 40),"A;CU","Y"
         WHERE curaccept IN ("Y", "N", "M"))
        IF (curaccept="Y")
         SET updt_rec->updt_list[syncnt].event_cd = tman->search_list[i].syn_list[cnt].event_cd
         SET updt_rec->updt_list[syncnt].new_event_cd = tman->search_list[i].syn_list[cnt].
         proposed_event_cd
        ELSEIF (curaccept="M")
         CALL clearscreen(null)
         GO TO exit_script
        ENDIF
       ENDIF
       SET tcnt = (tcnt+ 1)
     ENDFOR
   ENDFOR
   SET updt_rec->updt_list_sz = syncnt
   CALL clearscreen(null)
 END ;Subroutine
 SUBROUTINE displaysynstoupdate(null)
   DECLARE maxrows = i4 WITH noconstant(13), protect
   DECLARE cnt = i4 WITH protect
   DECLARE arow = i4 WITH protect
   DECLARE str = c75 WITH protect
   CALL drawscrollbox(soffrow,(soffcol+ 1),numrows,(numcols+ 1))
   CALL text(soffrow,(soffcol+ 6),"Synonym")
   CALL text(soffrow,(soffcol+ 62),"Task")
   CALL text(soffrow,(soffcol+ 67),"ES")
   CALL text(soffrow,(soffcol+ 70),"EC")
   WHILE (cnt < maxrows
    AND (cnt < updt_rec->updt_list_sz))
     SET cnt = (cnt+ 1)
     SET str = buildrowstr(cnt)
     CALL scrolltext(cnt,str)
   ENDWHILE
   SET cnt = 1
   SET arow = 1
   SET pick = 0
   WHILE (pick=0)
     CALL text((soffrow+ 16),soffcol,"Update all? (Y)es (N)o (M)ain Menu:")
     CALL accept((soffrow+ 16),(soffcol+ 36),"A;CUS"
      WHERE curaccept IN ("Y", "N", "M"))
     CASE (curscroll)
      OF 0:
       IF (curaccept="Y")
        CALL performupdates(null)
       ELSEIF (curaccept="N")
        GO TO repick_syns
       ENDIF
       SET pick = 1
      OF 1:
       IF ((cnt < updt_rec->updt_list_sz))
        SET cnt = (cnt+ 1)
        SET str = buildrowstr(cnt)
        CALL downarrow(str)
       ENDIF
      OF 2:
       IF (cnt > 1)
        SET cnt = (cnt - 1)
        SET str = buildrowstr(cnt)
        CALL uparrow(str)
       ENDIF
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE performupdates(null)
   CALL clearscreen(null)
   CALL text(soffrow,soffcol,"Performing updates")
   SELECT INTO "nl:"
    d1.seq, updatetable = "CODE_VALUE", newdisplay = updt_rec->updt_list[d1.seq].new_mnemonic,
    currentdisplay = cv.display, cv.display_key, cv.updt_dt_tm
    FROM (dummyt d1  WITH seq = value(updt_rec->updt_list_sz)),
     code_value cv
    PLAN (d1)
     JOIN (cv
     WHERE cv.code_set=200
      AND (cv.code_value=
     (SELECT
      ocs.catalog_cd
      FROM order_catalog_synonym ocs
      WHERE (ocs.synonym_id=updt_rec->updt_list[d1.seq].synonym_id)
       AND (updt_rec->updt_list[d1.seq].synonym_id > 0)
       AND ((ocs.mnemonic_type_cd+ 0)=cdtypeprimary)
       AND ((ocs.catalog_type_cd+ 0)=cdpharmacy))))
    WITH nocounter, forupdate(cv)
   ;end select
   SELECT INTO "nl:"
    d1.seq, updatetable = "ORDER_CATALOG", newprimary = updt_rec->updt_list[d1.seq].new_mnemonic,
    oc.primary_mnemonic, oc.updt_dt_tm
    FROM (dummyt d1  WITH seq = value(updt_rec->updt_list_sz)),
     order_catalog oc
    PLAN (d1)
     JOIN (oc
     WHERE (oc.catalog_cd=
     (SELECT
      ocs.catalog_cd
      FROM order_catalog_synonym ocs
      WHERE (ocs.synonym_id=updt_rec->updt_list[d1.seq].synonym_id)
       AND (updt_rec->updt_list[d1.seq].synonym_id > 0)
       AND ((ocs.mnemonic_type_cd+ 0)=cdtypeprimary)
       AND ((ocs.catalog_type_cd+ 0)=cdpharmacy))))
    WITH nocounter, forupdate(oc)
   ;end select
   SELECT INTO "nl:"
    d1.seq, updatetable = "ORDER_CATALOG_SYNONYM", newsynonym = updt_rec->updt_list[d1.seq].
    new_mnemonic,
    currentsynonym = ocs.mnemonic, ocs.mnemonic_key_cap, ocs.updt_dt_tm
    FROM (dummyt d1  WITH seq = value(updt_rec->updt_list_sz)),
     order_catalog_synonym ocs
    PLAN (d1)
     JOIN (ocs
     WHERE (ocs.synonym_id=updt_rec->updt_list[d1.seq].synonym_id)
      AND (updt_rec->updt_list[d1.seq].synonym_id > 0)
      AND  NOT (((ocs.mnemonic_type_cd+ 0) IN (cdtyperxmnem)))
      AND ((ocs.catalog_type_cd+ 0)=cdpharmacy))
    WITH nocounter, forupdate(ocs)
   ;end select
   SELECT INTO "nl:"
    d1.seq, updatetable = "ORDER_TASK", newtask = updt_rec->updt_list[d1.seq].new_task,
    currenttask = ot.task_description, ot.updt_dt_tm
    FROM (dummyt d1  WITH seq = value(updt_rec->updt_list_sz)),
     order_task ot
    PLAN (d1)
     JOIN (ot
     WHERE (ot.reference_task_id=updt_rec->updt_list[d1.seq].ref_task_id)
      AND (updt_rec->updt_list[d1.seq].ref_task_id > 0))
    WITH nocounter, forupdate(ot)
   ;end select
   SELECT INTO "nl:"
    d1.seq, updatetable = "V500_EVENT_SET_CODE", neweventset = updt_rec->updt_list[d1.seq].
    new_event_set,
    currenteventset = es.event_set_cd_disp, es.updt_dt_tm
    FROM (dummyt d1  WITH seq = value(updt_rec->updt_list_sz)),
     v500_event_set_code es
    PLAN (d1)
     JOIN (es
     WHERE (es.event_set_cd=updt_rec->updt_list[d1.seq].event_set_cd)
      AND (updt_rec->updt_list[d1.seq].event_set_cd > 0))
    WITH nocounter, forupdate(es)
   ;end select
   SELECT INTO "nl:"
    d1.seq, updatetable = "CODE_VALUE", neweventset = updt_rec->updt_list[d1.seq].new_event_set,
    currenteventset = cv.display, cv.updt_dt_tm
    FROM (dummyt d1  WITH seq = value(updt_rec->updt_list_sz)),
     code_value cv
    PLAN (d1)
     JOIN (cv
     WHERE cv.code_set=93
      AND (cv.code_value=updt_rec->updt_list[d1.seq].event_set_cd)
      AND (updt_rec->updt_list[d1.seq].event_set_cd > 0))
    WITH nocounter, forupdate(cv)
   ;end select
   SELECT INTO "nl:"
    d1.seq, updatetable = "V500_EVENT_CODE", neweventcd = updt_rec->updt_list[d1.seq].new_event_cd,
    currenteventcd = ec.event_cd_disp, ec.updt_dt_tm
    FROM (dummyt d1  WITH seq = value(updt_rec->updt_list_sz)),
     v500_event_code ec
    PLAN (d1)
     JOIN (ec
     WHERE (ec.event_cd=updt_rec->updt_list[d1.seq].event_cd)
      AND (updt_rec->updt_list[d1.seq].event_cd > 0))
    WITH nocounter, forupdate(ec)
   ;end select
   SELECT INTO "nl:"
    d1.seq, updatetable = "CODE_VALUE", neweventcd = updt_rec->updt_list[d1.seq].new_event_cd,
    currenteventcd = cv.display, cv.updt_dt_tm
    FROM (dummyt d1  WITH seq = value(updt_rec->updt_list_sz)),
     code_value cv
    PLAN (d1)
     JOIN (cv
     WHERE cv.code_set=72
      AND (cv.code_value=updt_rec->updt_list[d1.seq].event_cd)
      AND (updt_rec->updt_list[d1.seq].event_cd > 0))
    WITH nocounter, forupdate(cv)
   ;end select
   CALL echo("Updating code_value for code_set 200")
   UPDATE  FROM (dummyt d1  WITH seq = value(updt_rec->updt_list_sz)),
     code_value cv
    SET cv.display = trim(substring(1,40,updt_rec->updt_list[d1.seq].new_mnemonic)), cv.display_key
      = trim(cnvtalphanum(cnvtupper(substring(1,40,updt_rec->updt_list[d1.seq].new_mnemonic)))), cv
     .description = trim(substring(1,60,updt_rec->updt_list[d1.seq].new_mnemonic)),
     cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv.updt_cnt = (cv
     .updt_cnt+ 1),
     cv.updt_applctx = 0, cv.updt_task = - (267)
    PLAN (d1)
     JOIN (cv
     WHERE cv.code_set=200
      AND (cv.code_value=
     (SELECT
      ocs.catalog_cd
      FROM order_catalog_synonym ocs
      WHERE (ocs.synonym_id=updt_rec->updt_list[d1.seq].synonym_id)
       AND (updt_rec->updt_list[d1.seq].synonym_id > 0)
       AND ((ocs.mnemonic_type_cd+ 0)=cdtypeprimary)
       AND ((ocs.catalog_type_cd+ 0)=cdpharmacy))))
    WITH nocounter
   ;end update
   CALL echo(build("curqual: ",curqual))
   CALL echo("Updating order_catalog")
   UPDATE  FROM (dummyt d1  WITH seq = value(updt_rec->updt_list_sz)),
     order_catalog oc
    SET oc.primary_mnemonic = trim(updt_rec->updt_list[d1.seq].new_mnemonic), oc.updt_dt_tm =
     cnvtdatetime(curdate,curtime3), oc.updt_id = reqinfo->updt_id,
     oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_applctx = 0, oc.updt_task = - (267)
    PLAN (d1)
     JOIN (oc
     WHERE (oc.catalog_cd=
     (SELECT
      ocs.catalog_cd
      FROM order_catalog_synonym ocs
      WHERE (ocs.synonym_id=updt_rec->updt_list[d1.seq].synonym_id)
       AND (updt_rec->updt_list[d1.seq].synonym_id > 0)
       AND ((ocs.mnemonic_type_cd+ 0)=cdtypeprimary)
       AND ((ocs.catalog_type_cd+ 0)=cdpharmacy))))
    WITH nocounter
   ;end update
   CALL echo(build("curqual: ",curqual))
   CALL echo("Updating order_catalog_synonym")
   UPDATE  FROM (dummyt d1  WITH seq = value(updt_rec->updt_list_sz)),
     order_catalog_synonym ocs
    SET ocs.mnemonic = trim(updt_rec->updt_list[d1.seq].new_mnemonic), ocs.mnemonic_key_cap = trim(
      cnvtupper(updt_rec->updt_list[d1.seq].new_mnemonic)), ocs.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     ocs.updt_id = reqinfo->updt_id, ocs.updt_cnt = (ocs.updt_cnt+ 1), ocs.updt_applctx = 0,
     ocs.updt_task = - (267)
    PLAN (d1)
     JOIN (ocs
     WHERE (ocs.synonym_id=updt_rec->updt_list[d1.seq].synonym_id)
      AND (updt_rec->updt_list[d1.seq].synonym_id > 0)
      AND  NOT (((ocs.mnemonic_type_cd+ 0) IN (cdtyperxmnem)))
      AND ((ocs.catalog_type_cd+ 0)=cdpharmacy))
    WITH nocounter
   ;end update
   CALL echo(build("curqual: ",curqual))
   CALL echo("Updating order_task")
   UPDATE  FROM (dummyt d1  WITH seq = value(updt_rec->updt_list_sz)),
     order_task ot
    SET ot.task_description = trim(updt_rec->updt_list[d1.seq].new_task), ot.task_description_key =
     trim(cnvtupper(updt_rec->updt_list[d1.seq].new_task)), ot.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     ot.updt_id = reqinfo->updt_id, ot.updt_cnt = (ot.updt_cnt+ 1), ot.updt_applctx = 0,
     ot.updt_task = - (267)
    PLAN (d1)
     JOIN (ot
     WHERE (ot.reference_task_id=updt_rec->updt_list[d1.seq].ref_task_id)
      AND (updt_rec->updt_list[d1.seq].ref_task_id > 0))
    WITH nocounter
   ;end update
   CALL echo(build("curqual: ",curqual))
   CALL echo("Updating v500_event_set_code")
   UPDATE  FROM (dummyt d1  WITH seq = value(updt_rec->updt_list_sz)),
     v500_event_set_code es
    SET es.event_set_cd_disp = trim(updt_rec->updt_list[d1.seq].new_event_set), es
     .event_set_cd_disp_key = trim(cnvtalphanum(cnvtupper(updt_rec->updt_list[d1.seq].new_event_set))
      ), es.event_set_cd_descr = trim(updt_rec->updt_list[d1.seq].new_event_set),
     es.event_set_cd_definition = trim(updt_rec->updt_list[d1.seq].new_event_set), es.updt_dt_tm =
     cnvtdatetime(curdate,curtime3), es.updt_id = reqinfo->updt_id,
     es.updt_cnt = (es.updt_cnt+ 1), es.updt_applctx = 0, es.updt_task = - (267)
    PLAN (d1)
     JOIN (es
     WHERE (es.event_set_cd=updt_rec->updt_list[d1.seq].event_set_cd)
      AND (updt_rec->updt_list[d1.seq].event_set_cd > 0))
    WITH nocounter
   ;end update
   CALL echo(build("curqual: ",curqual))
   CALL echo("Updating code_value for code_set 93")
   UPDATE  FROM (dummyt d1  WITH seq = value(updt_rec->updt_list_sz)),
     code_value cv
    SET cv.display = trim(substring(1,40,updt_rec->updt_list[d1.seq].new_event_set)), cv.display_key
      = trim(cnvtalphanum(cnvtupper(substring(1,40,updt_rec->updt_list[d1.seq].new_event_set)))), cv
     .description = trim(substring(1,60,updt_rec->updt_list[d1.seq].new_event_set)),
     cv.definition = trim(substring(1,100,updt_rec->updt_list[d1.seq].new_event_set)), cv.updt_dt_tm
      = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id,
     cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_applctx = 0, cv.updt_task = - (267)
    PLAN (d1)
     JOIN (cv
     WHERE cv.code_set=93
      AND (cv.code_value=updt_rec->updt_list[d1.seq].event_set_cd)
      AND (updt_rec->updt_list[d1.seq].event_set_cd > 0))
    WITH nocounter
   ;end update
   CALL echo(build("curqual: ",curqual))
   CALL echo("Updating v500_event_code")
   UPDATE  FROM (dummyt d1  WITH seq = value(updt_rec->updt_list_sz)),
     v500_event_code ec
    SET ec.event_cd_disp = trim(updt_rec->updt_list[d1.seq].new_event_cd), ec.event_cd_disp_key =
     trim(cnvtalphanum(cnvtupper(updt_rec->updt_list[d1.seq].new_event_cd))), ec.event_cd_descr =
     trim(updt_rec->updt_list[d1.seq].new_event_cd),
     ec.event_cd_definition = trim(updt_rec->updt_list[d1.seq].new_event_cd), ec.updt_dt_tm =
     cnvtdatetime(curdate,curtime3), ec.updt_id = reqinfo->updt_id,
     ec.updt_cnt = (ec.updt_cnt+ 1), ec.updt_applctx = 0, ec.updt_task = - (267)
    PLAN (d1)
     JOIN (ec
     WHERE (ec.event_cd=updt_rec->updt_list[d1.seq].event_cd)
      AND (updt_rec->updt_list[d1.seq].event_cd > 0))
    WITH nocounter
   ;end update
   CALL echo(build("curqual: ",curqual))
   CALL echo("Updating code_value for code_set 72")
   UPDATE  FROM (dummyt d1  WITH seq = value(updt_rec->updt_list_sz)),
     code_value cv
    SET cv.display = trim(substring(1,40,updt_rec->updt_list[d1.seq].new_event_cd)), cv.display_key
      = trim(cnvtalphanum(cnvtupper(substring(1,40,updt_rec->updt_list[d1.seq].new_event_cd)))), cv
     .description = trim(substring(1,60,updt_rec->updt_list[d1.seq].new_event_cd)),
     cv.definition = trim(substring(1,100,updt_rec->updt_list[d1.seq].new_event_cd)), cv.updt_dt_tm
      = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id,
     cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_applctx = 0, cv.updt_task = - (267)
    PLAN (d1)
     JOIN (cv
     WHERE cv.code_set=72
      AND (cv.code_value=updt_rec->updt_list[d1.seq].event_cd)
      AND (updt_rec->updt_list[d1.seq].event_cd > 0))
    WITH nocounter
   ;end update
   CALL echo(build("curqual: ",curqual))
   CALL clearscreen(null)
   CALL text(soffrow,soffcol,"All done")
   CALL text((soffrow+ 16),soffcol,"Commit changes? (Y)es (N)o:")
   CALL accept((soffrow+ 16),(soffcol+ 28),"A;CU"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    COMMIT
   ELSE
    ROLLBACK
   ENDIF
 END ;Subroutine
 SUBROUTINE clearscreen(null)
   DECLARE i = i4 WITH protect
   SET i = soffrow
   WHILE (i <= numrows)
    CALL clear(i,soffcol,numcols)
    SET i = (i+ 1)
   ENDWHILE
   CALL clear((numrows+ 2),soffcol,numcols)
 END ;Subroutine
 SUBROUTINE drawscrollbox(begrow,begcol,endrow,endcol)
  CALL box(begrow,begcol,endrow,endcol)
  CALL scrollinit((begrow+ 1),(begcol+ 1),(endrow - 1),(endcol - 1))
 END ;Subroutine
 SUBROUTINE downarrow(newrow)
   IF (arow=maxrows)
    CALL scrolldown(maxrows,maxrows,newrow)
   ELSE
    SET arow = (arow+ 1)
    CALL scrolldown((arow - 1),arow,newrow)
   ENDIF
 END ;Subroutine
 SUBROUTINE uparrow(newrow)
   IF (arow=1)
    CALL scrollup(arow,arow,str)
   ELSE
    SET arow = (arow - 1)
    CALL scrollup((arow+ 1),arow,str)
   ENDIF
 END ;Subroutine
 SUBROUTINE buildrowstr(i)
   DECLARE rstr = c75 WITH protect
   SET rstr = build2(cnvtstring(i,3,0,r)," ",substring(1,56,updt_rec->updt_list[i].new_mnemonic)," ",
    IF ((updt_rec->updt_list[i].primary_ind=1)
     AND (updt_rec->updt_list[i].ref_task_id > 0)) "Y"
    ELSEIF ((updt_rec->updt_list[i].primary_ind=1)) "N"
    ENDIF
    ,
    "   ",
    IF ((updt_rec->updt_list[i].primary_ind=1)
     AND (updt_rec->updt_list[i].event_set_cd > 0)) "Y"
    ELSEIF ((updt_rec->updt_list[i].primary_ind=1)) "N"
    ENDIF
    ,"   ",
    IF ((updt_rec->updt_list[i].primary_ind=1)
     AND (updt_rec->updt_list[i].event_cd > 0)) "Y"
    ELSEIF ((updt_rec->updt_list[i].primary_ind=1)) "N"
    ENDIF
    )
   RETURN(rstr)
 END ;Subroutine
#exit_script
 SET last_mod = "000"
END GO
