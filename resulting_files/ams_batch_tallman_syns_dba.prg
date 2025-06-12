CREATE PROGRAM ams_batch_tallman_syns:dba
 SET modify = predeclare
 DECLARE include_combo_drug = i2 WITH constant(request->combo_ind), protect
 DECLARE ignore_mismatch_warn = i2 WITH constant(request->ignore_mismatch_ind), protect
 DECLARE regex_combo_drug = cv WITH constant(request->regex_chars), protect
 DECLARE tallman_file = vc WITH constant(request->tman_filename), protect
 DECLARE delim = vc WITH constant(","), protect
 DECLARE cdpharmacy = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY")), protect
 DECLARE cdtyperxmnem = f8 WITH constant(uar_get_code_by("MEANING",6011,"RXMNEMONIC")), protect
 DECLARE cdtypeprimary = f8 WITH constant(uar_get_code_by("MEANING",6011,"PRIMARY")), protect
 DECLARE cdtypemed = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6026,"MEDICATION")), protect
 DECLARE debug_ind = i2 WITH constant(request->debug_ind), protect
 DECLARE script_mode = i2 WITH protect
 DECLARE eexport_mode = i2 WITH constant(1), protect
 DECLARE eupdate_mode = i2 WITH constant(2), protect
 DECLARE output_csv_file = vc WITH protect
 DECLARE input_csv_file = vc WITH protect
 DECLARE mismatch_ind = i2 WITH noconstant(0), protect
 DECLARE mnem_mismatch_cnt = i4 WITH protect
 DECLARE task_mismatch_cnt = i4 WITH protect
 DECLARE es_mismatch_cnt = i4 WITH protect
 DECLARE ec_mismatch_cnt = i4 WITH protect
 DECLARE mnem_cnt = i4 WITH protect
 DECLARE task_cnt = i4 WITH protect
 DECLARE es_cnt = i4 WITH protect
 DECLARE ec_cnt = i4 WITH protect
 DECLARE last_mod = vc WITH protect
 DECLARE script_name = vc WITH protect, constant("AMS_BATCH_TALLMAN_SYNS")
 DECLARE total_cnt = i4 WITH protect
 DECLARE loadtallmanfile(sfilename=vc) = i2 WITH protect
 DECLARE getsynonymmatches(null) = i4 WITH protect
 DECLARE gettallmanmnemonic(stallmanstr=vc,sorigmnemonic=vc) = vc WITH protect
 DECLARE writesynstocsv(sfilename=vc) = null WITH protect
 DECLARE readupdatedsynsfromcsv(sfilename=vc) = null WITH protect
 DECLARE performupdates(null) = null WITH protect
 DECLARE checkformnemonicmismatches(null) = i4 WITH protect
 DECLARE gettaskmatches(null) = i4 WITH protect
 DECLARE checkfortaskmismatches(null) = i4 WITH protect
 DECLARE geteventsetmatches(null) = i4 WITH protect
 DECLARE checkforeventsetmismatches(null) = i4 WITH protect
 DECLARE geteventcodematches(null) = i4 WITH protect
 DECLARE checkforeventcodemismatches(null) = i4 WITH protect
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
   1 syn_list[*]
     2 synonym_id = f8
     2 new_mnemonic = vc
   1 task_list[*]
     2 ref_task_id = f8
     2 new_task = vc
   1 event_set_list[*]
     2 event_set_cd = f8
     2 new_event_set = vc
   1 event_cd_list[*]
     2 event_cd = f8
     2 new_event_cd = vc
 )
 FREE RECORD syn_rec
 RECORD syn_rec(
   1 qual[*]
     2 synonym_id = f8
     2 proposed_mnemonic = vc
 )
 FREE RECORD task_rec
 RECORD task_rec(
   1 qual[*]
     2 task_id = f8
     2 proposed_task = vc
 )
 FREE RECORD event_set_rec
 RECORD event_set_rec(
   1 qual[*]
     2 event_set = f8
     2 proposed_es = vc
 )
 FREE RECORD event_code_rec
 RECORD event_code_rec(
   1 qual[*]
     2 event_code = f8
     2 proposed_ec = vc
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
 SET script_mode = request->mode
 IF (script_mode=eexport_mode)
  CALL echo("Export Mode")
  SET output_csv_file = request->filename
 ELSEIF (script_mode=eupdate_mode)
  CALL echo("Update Mode")
  SET input_csv_file = request->filename
 ELSE
  CALL echo("Mode is not valid. Exiting")
  GO TO exit_script
 ENDIF
 IF ((request->filename=""))
  CALL echo("Filename not valid. Exiting")
  GO TO exit_script
 ENDIF
 IF (script_mode=eexport_mode)
  IF (loadtallmanfile(tallman_file) <= 0)
   CALL echo(build("No tallman strings loaded. Check that the file exists in CCLUSERDIR: ",
     tallman_file))
   GO TO exit_script
  ENDIF
  SET mnem_cnt = getsynonymmatches(null)
  SET task_cnt = gettaskmatches(null)
  SET es_cnt = geteventsetmatches(null)
  SET ec_cnt = geteventcodematches(null)
  IF (((mnem_cnt > 0) OR (((task_cnt > 0) OR (((es_cnt > 0) OR (ec_cnt > 0)) )) )) )
   IF (debug_ind=1)
    CALL echo("tallman record after being populated select")
    CALL echorecord(tman)
   ENDIF
   CALL writesynstocsv(output_csv_file)
  ENDIF
 ELSEIF (script_mode=eupdate_mode)
  IF (readupdatedsynsfromcsv(input_csv_file) <= 0)
   CALL echo("No synonyms loaded from CSV for update")
   GO TO exit_script
  ENDIF
  CALL performupdates(null)
 ENDIF
 SUBROUTINE loadtallmanfile(sfilename)
   DECLARE i = i4 WITH protect
   DECLARE tcnt = i4 WITH protect
   DECLARE beg_index = i4 WITH protect
   DECLARE end_index = i4 WITH protect
   DECLARE tstrlen = i4 WITH protect
   CALL echo(build("Reading tallman synonyms from file: ",sfilename))
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
   RETURN(evaluate(tman->search_list_sz,0,0,1))
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
   DECLARE idx = i4
   DECLARE x = i4
   DECLARE y = i4
   DECLARE pos = i4
   FOR (i = 1 TO tman->search_list_sz)
    CALL echo(build("Checking tallman record for synonym matches:",i,":",tman->search_list[i].
      tallman_str))
    SELECT INTO "nl:"
     FROM order_catalog_synonym ocs,
      order_catalog oc
     PLAN (ocs
      WHERE ocs.mnemonic_key_cap=patstring(tman->search_list[i].tallman_str_search)
       AND  NOT (ocs.mnemonic_type_cd IN (cdtyperxmnem))
       AND ((ocs.catalog_type_cd+ 0)=cdpharmacy)
       AND ocs.active_ind=1)
      JOIN (oc
      WHERE ocs.catalog_cd=oc.catalog_cd)
     ORDER BY oc.primary_mnemonic, ocs.mnemonic
     HEAD REPORT
      tcnt = 0
     DETAIL
      combodrugprefix = operator(cnvtupper(oc.primary_mnemonic),"REGEXPLIKE",concat(regex_combo_drug,
        tman->search_list[i].tallman_str_cap)), combodrugsuffix = operator(cnvtupper(oc
        .primary_mnemonic),"REGEXPLIKE",concat(tman->search_list[i].tallman_str_cap,regex_combo_drug)
       ), combodrug = bor(combodrugprefix,combodrugsuffix),
      partialdrugprefix = operator(cnvtupper(oc.primary_mnemonic),"REGEXPLIKE",concat("[A-Z]",tman->
        search_list[i].tallman_str_cap)), partialdrugsuffix = operator(cnvtupper(oc.primary_mnemonic),
       "REGEXPLIKE",concat(tman->search_list[i].tallman_str_cap,"[A-Z]")), partialdrug = bor(
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
      FOR (idx = 1 TO size(syn_rec->qual,5))
        IF ((ocs.synonym_id=syn_rec->qual[idx].synonym_id)
         AND partialdrug=0)
         tallman_mnemonic = gettallmanmnemonic(tman->search_list[i].tallman_str,syn_rec->qual[idx].
          proposed_mnemonic), syn_rec->qual[idx].proposed_mnemonic = tallman_mnemonic
         FOR (x = 1 TO tman->search_list_sz)
          pos = locateval(y,1,size(tman->search_list[x].syn_list,5),ocs.synonym_id,tman->search_list[
           x].syn_list[y].synonym_id),
          IF (pos > 0)
           tman->search_list[x].syn_list[pos].proposed_mnemonic = tallman_mnemonic
          ENDIF
         ENDFOR
        ENDIF
      ENDFOR
      IF (tallman_mnemonic="")
       tallman_mnemonic = gettallmanmnemonic(tman->search_list[i].tallman_str,ocs.mnemonic)
      ENDIF
      IF (tallman_mnemonic != ocs.mnemonic
       AND partialdrug=0
       AND ((combodrug=0) OR (include_combo_drug=1)) )
       exportcnt = (exportcnt+ 1), tcnt = (tcnt+ 1)
       IF (mod(tcnt,100)=1)
        stat = alterlist(tman->search_list[i].syn_list,(tcnt+ 99))
       ENDIF
       tman->search_list[i].syn_list[tcnt].primary_mnemonic = oc.primary_mnemonic, tman->search_list[
       i].syn_list[tcnt].synonym_id = ocs.synonym_id, tman->search_list[i].syn_list[tcnt].
       synonym_type = uar_get_code_display(ocs.mnemonic_type_cd),
       tman->search_list[i].syn_list[tcnt].orig_mnemonic = ocs.mnemonic, tman->search_list[i].
       syn_list[tcnt].proposed_mnemonic = tallman_mnemonic, stat = alterlist(syn_rec->qual,exportcnt),
       syn_rec->qual[exportcnt].synonym_id = ocs.synonym_id, syn_rec->qual[exportcnt].
       proposed_mnemonic = tallman_mnemonic
      ELSE
       CALL echo(build("Skipping synonym: ",ocs.mnemonic))
      ENDIF
      tallman_mnemonic = ""
     FOOT REPORT
      IF (mod(tcnt,100) != 0)
       stat = alterlist(tman->search_list[i].syn_list,tcnt)
      ENDIF
     WITH nocounter
    ;end select
   ENDFOR
   CALL echo(build2("Exporting ",trim(cnvtstring(exportcnt))," synonyms to CSV file: ",trim(
      output_csv_file)))
   RETURN(exportcnt)
 END ;Subroutine
 SUBROUTINE gettaskmatches(null)
   DECLARE i = i4 WITH protect
   DECLARE x = i4 WITH protect
   DECLARE taskcnt = i4 WITH protect
   DECLARE tallman_task = vc WITH protect
   DECLARE primaryfnd = i2 WITH protect
   DECLARE combodrugprefix = i2 WITH protect
   DECLARE combodrugsuffix = i2 WITH protect
   DECLARE combodrug = i2 WITH protect
   DECLARE partialdrugprefix = i2 WITH protect
   DECLARE partialdrugsuffix = i2 WITH protect
   DECLARE partialdrug = i2 WITH protect
   DECLARE idx = i4
   DECLARE z = i4
   DECLARE y = i4
   DECLARE pos = i4
   CALL echo("Checking for task matches")
   FOR (i = 1 TO tman->search_list_sz)
     SELECT INTO "nl:"
      ot.task_description, ot.task_description_key, ot.reference_task_id
      FROM order_task ot,
       order_task_xref ox,
       order_catalog oc,
       order_catalog_synonym ocs
      PLAN (ot
       WHERE ot.task_description_key=patstring(tman->search_list[i].tallman_str_search)
        AND ((ot.task_type_cd+ 0)=cdtypemed)
        AND ot.active_ind=1)
       JOIN (ox
       WHERE ox.reference_task_id=ot.reference_task_id)
       JOIN (oc
       WHERE oc.catalog_cd=ox.catalog_cd
        AND ((oc.catalog_type_cd+ 0)=cdpharmacy)
        AND oc.active_ind=1)
       JOIN (ocs
       WHERE ocs.catalog_cd=oc.catalog_cd
        AND ocs.mnemonic_type_cd=cdtypeprimary)
      ORDER BY oc.primary_mnemonic
      HEAD REPORT
       primaryfnd = 0, x = 0
      HEAD oc.primary_mnemonic
       primaryfnd = 0, x = 0
      DETAIL
       combodrugprefix = operator(cnvtupper(oc.primary_mnemonic),"REGEXPLIKE",concat(regex_combo_drug,
         tman->search_list[i].tallman_str_cap)), combodrugsuffix = operator(cnvtupper(oc
         .primary_mnemonic),"REGEXPLIKE",concat(tman->search_list[i].tallman_str_cap,regex_combo_drug
         )), combodrug = bor(combodrugprefix,combodrugsuffix),
       partialdrugprefix = operator(cnvtupper(oc.primary_mnemonic),"REGEXPLIKE",concat("[A-Z]",tman->
         search_list[i].tallman_str_cap)), partialdrugsuffix = operator(cnvtupper(oc.primary_mnemonic
         ),"REGEXPLIKE",concat(tman->search_list[i].tallman_str_cap,"[A-Z]")), partialdrug = bor(
        partialdrugprefix,partialdrugsuffix)
       FOR (idx = 1 TO size(task_rec->qual,5))
         IF ((ot.reference_task_id=task_rec->qual[idx].task_id)
          AND partialdrug=0)
          tallman_task = gettallmanmnemonic(tman->search_list[i].tallman_str,task_rec->qual[idx].
           proposed_task), task_rec->qual[idx].proposed_task = tallman_task
          FOR (z = 1 TO tman->search_list_sz)
           pos = locateval(y,1,size(tman->search_list[z].syn_list,5),ot.reference_task_id,tman->
            search_list[z].syn_list[y].ref_task_id),
           IF (pos > 0)
            tman->search_list[z].syn_list[pos].proposed_task = tallman_task
           ENDIF
          ENDFOR
         ENDIF
       ENDFOR
       IF (tallman_task="")
        tallman_task = gettallmanmnemonic(tman->search_list[i].tallman_str,ot.task_description)
       ENDIF
       IF (tallman_task != ot.task_description
        AND partialdrug=0
        AND ((combodrug=0) OR (include_combo_drug=1)) )
        WHILE (primaryfnd != 1
         AND x <= size(tman->search_list[i].syn_list,5))
          IF (size(tman->search_list[i].syn_list,5)=0)
           taskcnt = (taskcnt+ 1), stat = alterlist(tman->search_list[i].syn_list,(x+ 1)), tman->
           search_list[i].syn_list[(x+ 1)].primary_mnemonic = oc.primary_mnemonic,
           tman->search_list[i].syn_list[(x+ 1)].synonym_type = uar_get_code_display(ocs
            .mnemonic_type_cd), tman->search_list[i].syn_list[(x+ 1)].orig_mnemonic = ocs.mnemonic,
           tman->search_list[i].syn_list[(x+ 1)].synonym_id = ocs.synonym_id,
           tman->search_list[i].syn_list[(x+ 1)].ref_task_id = ot.reference_task_id, tman->
           search_list[i].syn_list[(x+ 1)].orig_task = ot.task_description, tman->search_list[i].
           syn_list[(x+ 1)].proposed_task = tallman_task,
           primaryfnd = 1, stat = alterlist(task_rec->qual,taskcnt), task_rec->qual[taskcnt].task_id
            = ot.reference_task_id,
           task_rec->qual[taskcnt].proposed_task = tallman_task
          ELSE
           x = (x+ 1)
           IF ((tman->search_list[i].syn_list[x].synonym_id=ocs.synonym_id))
            taskcnt = (taskcnt+ 1), tman->search_list[i].syn_list[x].ref_task_id = ot
            .reference_task_id, tman->search_list[i].syn_list[x].orig_task = ot.task_description,
            tman->search_list[i].syn_list[x].proposed_task = tallman_task, primaryfnd = 1, stat =
            alterlist(task_rec->qual,taskcnt),
            task_rec->qual[taskcnt].task_id = ot.reference_task_id, task_rec->qual[taskcnt].
            proposed_task = tallman_task
           ELSEIF (x=size(tman->search_list[i].syn_list,5))
            taskcnt = (taskcnt+ 1), stat = alterlist(tman->search_list[i].syn_list,(x+ 1)), tman->
            search_list[i].syn_list[(x+ 1)].primary_mnemonic = oc.primary_mnemonic,
            tman->search_list[i].syn_list[(x+ 1)].synonym_type = uar_get_code_display(ocs
             .mnemonic_type_cd), tman->search_list[i].syn_list[(x+ 1)].orig_mnemonic = ocs.mnemonic,
            tman->search_list[i].syn_list[(x+ 1)].synonym_id = ocs.synonym_id,
            tman->search_list[i].syn_list[(x+ 1)].ref_task_id = ot.reference_task_id, tman->
            search_list[i].syn_list[(x+ 1)].orig_task = ot.task_description, tman->search_list[i].
            syn_list[(x+ 1)].proposed_task = tallman_task,
            primaryfnd = 1, stat = alterlist(task_rec->qual,taskcnt), task_rec->qual[taskcnt].task_id
             = ot.reference_task_id,
            task_rec->qual[taskcnt].proposed_task = tallman_task
           ENDIF
          ENDIF
        ENDWHILE
       ENDIF
       tallman_task = ""
      WITH nocounter
     ;end select
   ENDFOR
   CALL echo(build2("Exporting ",trim(cnvtstring(taskcnt))," tasks to CSV file: ",trim(
      output_csv_file)))
   RETURN(taskcnt)
 END ;Subroutine
 SUBROUTINE geteventsetmatches(null)
   DECLARE i = i4 WITH protect
   DECLARE x = i4 WITH protect
   DECLARE eventsetcnt = i4 WITH protect
   DECLARE tallman_event_set = vc WITH protect
   DECLARE primaryfnd = i2 WITH protect
   DECLARE combodrugprefix = i2 WITH protect
   DECLARE combodrugsuffix = i2 WITH protect
   DECLARE combodrug = i2 WITH protect
   DECLARE partialdrugprefix = i2 WITH protect
   DECLARE partialdrugsuffix = i2 WITH protect
   DECLARE partialdrug = i2 WITH protect
   DECLARE idx = i4
   DECLARE z = i4
   DECLARE y = i4
   DECLARE pos = i4
   CALL echo("Checking for event_set matches")
   FOR (i = 1 TO tman->search_list_sz)
     SELECT INTO "nl:"
      es.event_set_cd, es.event_set_name, es.event_set_name_key
      FROM v500_event_set_code es,
       v500_event_set_explode vee,
       code_value_event_r cvr,
       order_catalog oc,
       order_catalog_synonym ocs
      PLAN (es
       WHERE es.event_set_name_key=patstring(tman->search_list[i].tallman_str_search))
       JOIN (vee
       WHERE vee.event_set_cd=es.event_set_cd)
       JOIN (cvr
       WHERE cvr.event_cd=vee.event_cd)
       JOIN (oc
       WHERE oc.catalog_cd=cvr.parent_cd
        AND ((oc.catalog_type_cd+ 0)=cdpharmacy)
        AND oc.active_ind=1)
       JOIN (ocs
       WHERE ocs.catalog_cd=oc.catalog_cd
        AND ocs.mnemonic_type_cd=cdtypeprimary)
      ORDER BY es.event_set_name_key
      HEAD REPORT
       primaryfnd = 0, x = 0
      HEAD es.event_set_name_key
       primaryfnd = 0, x = 0
      DETAIL
       combodrugprefix = operator(cnvtupper(oc.primary_mnemonic),"REGEXPLIKE",concat(regex_combo_drug,
         tman->search_list[i].tallman_str_cap)), combodrugsuffix = operator(cnvtupper(oc
         .primary_mnemonic),"REGEXPLIKE",concat(tman->search_list[i].tallman_str_cap,regex_combo_drug
         )), combodrug = bor(combodrugprefix,combodrugsuffix),
       partialdrugprefix = operator(cnvtupper(oc.primary_mnemonic),"REGEXPLIKE",concat("[A-Z]",tman->
         search_list[i].tallman_str_cap)), partialdrugsuffix = operator(cnvtupper(oc.primary_mnemonic
         ),"REGEXPLIKE",concat(tman->search_list[i].tallman_str_cap,"[A-Z]")), partialdrug = bor(
        partialdrugprefix,partialdrugsuffix)
       FOR (idx = 1 TO size(event_set_rec->qual,5))
         IF ((es.event_set_cd=event_set_rec->qual[idx].event_set)
          AND partialdrug=0)
          tallman_event_set = gettallmanmnemonic(tman->search_list[i].tallman_str,event_set_rec->
           qual[idx].proposed_es), event_set_rec->qual[idx].proposed_es = tallman_event_set
          FOR (z = 1 TO tman->search_list_sz)
           pos = locateval(y,1,size(tman->search_list[z].syn_list,5),es.event_set_cd,tman->
            search_list[z].syn_list[y].event_set_cd),
           IF (pos > 0)
            tman->search_list[z].syn_list[pos].proposed_event_set = tallman_event_set
           ENDIF
          ENDFOR
         ENDIF
       ENDFOR
       IF (tallman_event_set="")
        tallman_event_set = gettallmanmnemonic(tman->search_list[i].tallman_str,es.event_set_cd_disp)
       ENDIF
       IF (tallman_event_set != es.event_set_cd_disp
        AND partialdrug=0
        AND ((combodrug=0) OR (include_combo_drug=1)) )
        WHILE (primaryfnd != 1
         AND x <= size(tman->search_list[i].syn_list,5))
          IF (size(tman->search_list[i].syn_list,5)=0)
           eventsetcnt = (eventsetcnt+ 1), stat = alterlist(tman->search_list[i].syn_list,(x+ 1)),
           tman->search_list[i].syn_list[(x+ 1)].primary_mnemonic = oc.primary_mnemonic,
           tman->search_list[i].syn_list[(x+ 1)].synonym_type = uar_get_code_display(ocs
            .mnemonic_type_cd), tman->search_list[i].syn_list[(x+ 1)].orig_mnemonic = ocs.mnemonic,
           tman->search_list[i].syn_list[(x+ 1)].synonym_id = ocs.synonym_id,
           tman->search_list[i].syn_list[(x+ 1)].event_set_cd = es.event_set_cd, tman->search_list[i]
           .syn_list[(x+ 1)].orig_event_set = es.event_set_cd_disp, tman->search_list[i].syn_list[(x
           + 1)].proposed_event_set = tallman_event_set,
           primaryfnd = 1, stat = alterlist(event_set_rec->qual,eventsetcnt), event_set_rec->qual[
           eventsetcnt].event_set = es.event_set_cd,
           event_set_rec->qual[eventsetcnt].proposed_es = tallman_event_set
          ELSE
           x = (x+ 1)
           IF ((tman->search_list[i].syn_list[x].synonym_id=ocs.synonym_id))
            eventsetcnt = (eventsetcnt+ 1), tman->search_list[i].syn_list[x].event_set_cd = es
            .event_set_cd, tman->search_list[i].syn_list[x].orig_event_set = es.event_set_cd_disp,
            tman->search_list[i].syn_list[x].proposed_event_set = tallman_event_set, primaryfnd = 1,
            stat = alterlist(event_set_rec->qual,eventsetcnt),
            event_set_rec->qual[eventsetcnt].event_set = es.event_set_cd, event_set_rec->qual[
            eventsetcnt].proposed_es = tallman_event_set
           ELSEIF (x=size(tman->search_list[i].syn_list,5))
            eventsetcnt = (eventsetcnt+ 1), stat = alterlist(tman->search_list[i].syn_list,(x+ 1)),
            tman->search_list[i].syn_list[(x+ 1)].primary_mnemonic = oc.primary_mnemonic,
            tman->search_list[i].syn_list[(x+ 1)].synonym_type = uar_get_code_display(ocs
             .mnemonic_type_cd), tman->search_list[i].syn_list[(x+ 1)].orig_mnemonic = ocs.mnemonic,
            tman->search_list[i].syn_list[(x+ 1)].synonym_id = ocs.synonym_id,
            tman->search_list[i].syn_list[(x+ 1)].event_set_cd = es.event_set_cd, tman->search_list[i
            ].syn_list[(x+ 1)].orig_event_set = es.event_set_cd_disp, tman->search_list[i].syn_list[(
            x+ 1)].proposed_event_set = tallman_event_set,
            primaryfnd = 1, stat = alterlist(event_set_rec->qual,eventsetcnt), event_set_rec->qual[
            eventsetcnt].event_set = es.event_set_cd,
            event_set_rec->qual[eventsetcnt].proposed_es = tallman_event_set
           ENDIF
          ENDIF
        ENDWHILE
       ENDIF
       tallman_event_set = ""
      WITH nocounter
     ;end select
   ENDFOR
   CALL echo(build2("Exporting ",trim(cnvtstring(eventsetcnt))," event_sets to CSV file: ",trim(
      output_csv_file)))
   RETURN(eventsetcnt)
 END ;Subroutine
 SUBROUTINE geteventcodematches(null)
   DECLARE i = i4 WITH protect
   DECLARE x = i4 WITH protect
   DECLARE eventcdcnt = i4 WITH protect
   DECLARE tallman_event_cd = vc WITH protect
   DECLARE primaryfnd = i2 WITH protect
   DECLARE combodrugprefix = i2 WITH protect
   DECLARE combodrugsuffix = i2 WITH protect
   DECLARE combodrug = i2 WITH protect
   DECLARE partialdrugprefix = i2 WITH protect
   DECLARE partialdrugsuffix = i2 WITH protect
   DECLARE partialdrug = i2 WITH protect
   DECLARE idx = i4
   DECLARE z = i4
   DECLARE y = i4
   DECLARE pos = i4
   CALL echo("Checking for event_code matches")
   FOR (i = 1 TO tman->search_list_sz)
     SELECT INTO "nl:"
      ec.event_cd_disp, ec.event_cd_descr, ec.event_cd_definition,
      ec.event_cd
      FROM v500_event_code ec,
       code_value_event_r cvr,
       order_catalog oc,
       order_catalog_synonym ocs
      PLAN (ec
       WHERE ec.event_cd_disp_key=patstring(tman->search_list[i].tallman_str_search_alphanum))
       JOIN (cvr
       WHERE cvr.event_cd=ec.event_cd)
       JOIN (oc
       WHERE oc.catalog_cd=cvr.parent_cd
        AND ((oc.catalog_type_cd+ 0)=cdpharmacy)
        AND oc.active_ind=1)
       JOIN (ocs
       WHERE ocs.catalog_cd=oc.catalog_cd
        AND ocs.mnemonic_type_cd=cdtypeprimary)
      ORDER BY ec.event_cd_disp_key
      HEAD REPORT
       primaryfnd = 0, x = 0
      HEAD ec.event_cd_disp_key
       primaryfnd = 0, x = 0
      DETAIL
       combodrugprefix = operator(cnvtupper(oc.primary_mnemonic),"REGEXPLIKE",concat(regex_combo_drug,
         tman->search_list[i].tallman_str_cap)), combodrugsuffix = operator(cnvtupper(oc
         .primary_mnemonic),"REGEXPLIKE",concat(tman->search_list[i].tallman_str_cap,regex_combo_drug
         )), combodrug = bor(combodrugprefix,combodrugsuffix),
       partialdrugprefix = operator(cnvtupper(oc.primary_mnemonic),"REGEXPLIKE",concat("[A-Z]",tman->
         search_list[i].tallman_str_cap)), partialdrugsuffix = operator(cnvtupper(oc.primary_mnemonic
         ),"REGEXPLIKE",concat(tman->search_list[i].tallman_str_cap,"[A-Z]")), partialdrug = bor(
        partialdrugprefix,partialdrugsuffix)
       FOR (idx = 1 TO size(event_code_rec->qual,5))
         IF ((ec.event_cd=event_code_rec->qual[idx].event_code)
          AND partialdrug=0)
          tallman_event_cd = gettallmanmnemonic(tman->search_list[i].tallman_str,event_code_rec->
           qual[idx].proposed_ec), event_code_rec->qual[idx].proposed_ec = tallman_event_cd
          FOR (z = 1 TO tman->search_list_sz)
           pos = locateval(y,1,size(tman->search_list[z].syn_list,5),ec.event_cd,tman->search_list[z]
            .syn_list[y].event_cd),
           IF (pos > 0)
            tman->search_list[z].syn_list[pos].proposed_event_cd = tallman_event_cd
           ENDIF
          ENDFOR
         ENDIF
       ENDFOR
       IF (tallman_event_cd="")
        tallman_event_cd = gettallmanmnemonic(tman->search_list[i].tallman_str,ec.event_cd_disp)
       ENDIF
       IF (tallman_event_cd != ec.event_cd_disp
        AND partialdrug=0
        AND ((combodrug=0) OR (include_combo_drug=1)) )
        WHILE (primaryfnd != 1
         AND x <= size(tman->search_list[i].syn_list,5))
          IF (size(tman->search_list[i].syn_list,5)=0)
           eventcdcnt = (eventcdcnt+ 1), stat = alterlist(tman->search_list[i].syn_list,(x+ 1)), tman
           ->search_list[i].syn_list[(x+ 1)].primary_mnemonic = oc.primary_mnemonic,
           tman->search_list[i].syn_list[(x+ 1)].synonym_type = uar_get_code_display(ocs
            .mnemonic_type_cd), tman->search_list[i].syn_list[(x+ 1)].orig_mnemonic = ocs.mnemonic,
           tman->search_list[i].syn_list[(x+ 1)].synonym_id = ocs.synonym_id,
           tman->search_list[i].syn_list[(x+ 1)].event_cd = ec.event_cd, tman->search_list[i].
           syn_list[(x+ 1)].orig_event_cd = ec.event_cd_disp, tman->search_list[i].syn_list[(x+ 1)].
           proposed_event_cd = tallman_event_cd,
           primaryfnd = 1, stat = alterlist(event_code_rec->qual,eventcdcnt), event_code_rec->qual[
           eventcdcnt].event_code = ec.event_cd,
           event_code_rec->qual[eventcdcnt].proposed_ec = tallman_event_cd
          ELSE
           x = (x+ 1)
           IF ((tman->search_list[i].syn_list[x].synonym_id=ocs.synonym_id))
            eventcdcnt = (eventcdcnt+ 1), tman->search_list[i].syn_list[x].event_cd = ec.event_cd,
            tman->search_list[i].syn_list[x].orig_event_cd = ec.event_cd_disp,
            tman->search_list[i].syn_list[x].proposed_event_cd = tallman_event_cd, primaryfnd = 1,
            stat = alterlist(event_code_rec->qual,eventcdcnt),
            event_code_rec->qual[eventcdcnt].event_code = ec.event_cd, event_code_rec->qual[
            eventcdcnt].proposed_ec = tallman_event_cd
           ELSEIF (x=size(tman->search_list[i].syn_list,5))
            eventcdcnt = (eventcdcnt+ 1), stat = alterlist(tman->search_list[i].syn_list,(x+ 1)),
            tman->search_list[i].syn_list[(x+ 1)].primary_mnemonic = oc.primary_mnemonic,
            tman->search_list[i].syn_list[(x+ 1)].synonym_type = uar_get_code_display(ocs
             .mnemonic_type_cd), tman->search_list[i].syn_list[(x+ 1)].orig_mnemonic = ocs.mnemonic,
            tman->search_list[i].syn_list[(x+ 1)].synonym_id = ocs.synonym_id,
            tman->search_list[i].syn_list[(x+ 1)].event_cd = ec.event_cd, tman->search_list[i].
            syn_list[(x+ 1)].orig_event_cd = ec.event_cd_disp, tman->search_list[i].syn_list[(x+ 1)].
            proposed_event_cd = tallman_event_cd,
            primaryfnd = 1, stat = alterlist(event_code_rec->qual,eventcdcnt), event_code_rec->qual[
            eventcdcnt].event_code = ec.event_cd,
            event_code_rec->qual[eventcdcnt].proposed_ec = tallman_event_cd
           ENDIF
          ENDIF
        ENDWHILE
       ENDIF
       tallman_event_cd = ""
      WITH nocounter
     ;end select
   ENDFOR
   CALL echo(build2("Exporting ",trim(cnvtstring(eventcdcnt))," event_codes to CSV file: ",trim(
      output_csv_file)))
   RETURN(eventcdcnt)
 END ;Subroutine
 SUBROUTINE writesynstocsv(sfilename)
   DECLARE j = i4 WITH protect
   SELECT INTO value(sfilename)
    DETAIL
     row 0, col 0, "The upload process will use the 'proposed' columns to update fields",
     row + 1, col 0, "Delete any ROWS you do not want to update prior to upload",
     row + 1, col 0,
     "Do not reorder or remove any COLUMNS. You may insert columns only after the last column",
     row + 1, col 0,
     "CAUTION: synonym_id's may differ between domains. Extract/Import should be performed separately in each"
    WITH pcformat('"',delim), maxcol = 20000, format = variable,
     noformfeed, landscape, maxrow = 1
   ;end select
   SELECT INTO value(sfilename)
    tallmanstr = substring(1,25,tman->search_list[d1.seq].tallman_str), primary = substring(1,100,
     tman->search_list[d1.seq].syn_list[d2.seq].primary_mnemonic), synonymid =
    IF ((tman->search_list[d1.seq].syn_list[d2.seq].proposed_mnemonic="")) ""
    ELSE cnvtstring(tman->search_list[d1.seq].syn_list[d2.seq].synonym_id)
    ENDIF
    ,
    synonymtype = substring(1,27,tman->search_list[d1.seq].syn_list[d2.seq].synonym_type),
    origsynonym = substring(1,100,tman->search_list[d1.seq].syn_list[d2.seq].orig_mnemonic),
    proposedsynonym = substring(1,100,tman->search_list[d1.seq].syn_list[d2.seq].proposed_mnemonic),
    referencetaskid =
    IF ((tman->search_list[d1.seq].syn_list[d2.seq].ref_task_id=0)) ""
    ELSE cnvtstring(tman->search_list[d1.seq].syn_list[d2.seq].ref_task_id)
    ENDIF
    , origtask = substring(1,100,tman->search_list[d1.seq].syn_list[d2.seq].orig_task), proposedtask
     = substring(1,100,tman->search_list[d1.seq].syn_list[d2.seq].proposed_task),
    eventsetcd =
    IF ((tman->search_list[d1.seq].syn_list[d2.seq].event_set_cd=0)) ""
    ELSE cnvtstring(tman->search_list[d1.seq].syn_list[d2.seq].event_set_cd)
    ENDIF
    , origeventset = substring(1,40,tman->search_list[d1.seq].syn_list[d2.seq].orig_event_set),
    proposedeventset = substring(1,40,tman->search_list[d1.seq].syn_list[d2.seq].proposed_event_set),
    eventcd =
    IF ((tman->search_list[d1.seq].syn_list[d2.seq].event_cd=0)) ""
    ELSE cnvtstring(tman->search_list[d1.seq].syn_list[d2.seq].event_cd)
    ENDIF
    , origeventcd = substring(1,40,tman->search_list[d1.seq].syn_list[d2.seq].orig_event_cd),
    proposedeventcd = substring(1,40,tman->search_list[d1.seq].syn_list[d2.seq].proposed_event_cd)
    FROM (dummyt d1  WITH seq = value(tman->search_list_sz)),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(tman->search_list[d1.seq].syn_list,5)))
     JOIN (d2)
    ORDER BY cnvtupper(tman->search_list[d1.seq].tallman_str), primary
    WITH format = stream, pcformat('"',delim,1), format,
     append
   ;end select
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
   IF (endpos > 0)
    SET startpos = (endpos+ textlen(stallmanstr))
    SET endpos = ((textlen(sorigmnemonic) - startpos)+ 1)
    SET suffix = substring(startpos,endpos,sorigmnemonic)
    SET final_str = concat(prefix,stallmanstr,suffix)
   ELSE
    SET final_str = sorigmnemonic
   ENDIF
   IF (debug_ind=1)
    CALL echo(build("sTallmanStr: ",stallmanstr))
    CALL echo(build("sOrigMnemonic: ",sorigmnemonic))
    CALL echo(build("final_str: ",final_str))
   ENDIF
   RETURN(final_str)
 END ;Subroutine
 SUBROUTINE readupdatedsynsfromcsv(sfilename)
   DECLARE str = vc WITH protect
   DECLARE notfnd = vc WITH protect, constant("<not_found>")
   DECLARE piecenum = i4 WITH protect
   DECLARE cnt = i4 WITH protect
   DECLARE taskcnt = i4 WITH protect
   DECLARE eventsetcnt = i4 WITH protect
   DECLARE eventcdcnt = i4 WITH protect
   FREE DEFINE rtl2
   DEFINE rtl2 sfilename
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    HEAD REPORT
     cnt = 0
    DETAIL
     IF (cnvtreal(piece(r.line,delim,3,notfnd,3)) > 0.0)
      cnt = (cnt+ 1)
      IF (mod(cnt,100)=1)
       stat = alterlist(updt_rec->syn_list,(cnt+ 99))
      ENDIF
      piecenum = 1, str = ""
      WHILE (str != notfnd)
        str = piece(r.line,delim,piecenum,notfnd,3)
        IF (debug_ind=1)
         CALL echo(build("piece",piecenum,"=",str))
        ENDIF
        CASE (piecenum)
         OF 3:
          updt_rec->syn_list[cnt].synonym_id = cnvtreal(str)
         OF 6:
          updt_rec->syn_list[cnt].new_mnemonic = trim(substring(1,100,str))
        ENDCASE
        piecenum = (piecenum+ 1)
      ENDWHILE
     ELSE
      IF (debug_ind=1)
       CALL echo(build("synonym: skipping line: ",r.line))
      ENDIF
     ENDIF
     IF (cnvtreal(piece(r.line,delim,7,notfnd,3)) > 0.0)
      taskcnt = (taskcnt+ 1)
      IF (mod(taskcnt,100)=1)
       stat = alterlist(updt_rec->task_list,(taskcnt+ 99))
      ENDIF
      piecenum = 1, str = ""
      WHILE (str != notfnd)
        str = piece(r.line,delim,piecenum,notfnd,3)
        IF (debug_ind=1)
         CALL echo(build("piece",piecenum,"=",str))
        ENDIF
        CASE (piecenum)
         OF 7:
          updt_rec->task_list[taskcnt].ref_task_id = cnvtreal(str)
         OF 9:
          updt_rec->task_list[taskcnt].new_task = trim(substring(1,100,str))
        ENDCASE
        piecenum = (piecenum+ 1)
      ENDWHILE
     ELSE
      IF (debug_ind=1)
       CALL echo(build("task: skipping line: ",r.line))
      ENDIF
     ENDIF
     IF (cnvtreal(piece(r.line,delim,10,notfnd,3)) > 0.0)
      eventsetcnt = (eventsetcnt+ 1)
      IF (mod(eventsetcnt,100)=1)
       stat = alterlist(updt_rec->event_set_list,(eventsetcnt+ 99))
      ENDIF
      piecenum = 1, str = ""
      WHILE (str != notfnd)
        str = piece(r.line,delim,piecenum,notfnd,3)
        IF (debug_ind=1)
         CALL echo(build("piece",piecenum,"=",str))
        ENDIF
        CASE (piecenum)
         OF 10:
          updt_rec->event_set_list[eventsetcnt].event_set_cd = cnvtreal(str)
         OF 12:
          updt_rec->event_set_list[eventsetcnt].new_event_set = trim(substring(1,40,str))
        ENDCASE
        piecenum = (piecenum+ 1)
      ENDWHILE
     ELSE
      IF (debug_ind=1)
       CALL echo(build("event_set: skipping line: ",r.line))
      ENDIF
     ENDIF
     IF (cnvtreal(piece(r.line,delim,13,notfnd,3)) > 0.0)
      eventcdcnt = (eventcdcnt+ 1)
      IF (mod(eventcdcnt,100)=1)
       stat = alterlist(updt_rec->event_cd_list,(eventcdcnt+ 99))
      ENDIF
      piecenum = 1, str = ""
      WHILE (str != notfnd)
        str = piece(r.line,delim,piecenum,notfnd,3)
        IF (debug_ind=1)
         CALL echo(build("piece",piecenum,"=",str))
        ENDIF
        CASE (piecenum)
         OF 13:
          updt_rec->event_cd_list[eventcdcnt].event_cd = cnvtreal(str)
         OF 15:
          updt_rec->event_cd_list[eventcdcnt].new_event_cd = trim(substring(1,40,str))
        ENDCASE
        piecenum = (piecenum+ 1)
      ENDWHILE
     ELSE
      IF (debug_ind=1)
       CALL echo(build("event_cd: skipping line: ",r.line))
      ENDIF
     ENDIF
    FOOT REPORT
     IF (mod(cnt,100) != 0)
      stat = alterlist(updt_rec->syn_list,cnt)
     ENDIF
     IF (mod(taskcnt,100) != 0)
      stat = alterlist(updt_rec->task_list,taskcnt)
     ENDIF
     IF (mod(eventsetcnt,100) != 0)
      stat = alterlist(updt_rec->event_set_list,eventsetcnt)
     ENDIF
     IF (mod(eventcdcnt,100) != 0)
      stat = alterlist(updt_rec->event_cd_list,eventcdcnt)
     ENDIF
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL echorecord(updt_rec)
   ENDIF
   RETURN(evaluate(size(updt_rec->syn_list,5),0,0,1))
 END ;Subroutine
 SUBROUTINE performupdates(null)
   CALL echo("Checking for any synonym mismatches")
   CALL checkformnemonicmismatches(null)
   CALL echo("Checking for any task mismatches")
   CALL checkfortaskmismatches(null)
   CALL echo("Checking for any event_set mismatches")
   CALL checkforeventsetmismatches(null)
   CALL echo("Checking for any event_code mismatches")
   CALL checkforeventcodemismatches(null)
   IF (mismatch_ind > 0
    AND ignore_mismatch_warn=0)
    GO TO exit_script
   ENDIF
   SELECT
    IF ((request->commit_ind=1))INTO "nl:"
    ELSE
    ENDIF
    d1.seq, updatetable = "CODE_VALUE", newdisplay = updt_rec->syn_list[d1.seq].new_mnemonic,
    currentdisplay = cv.display, cv.display_key, cv.updt_dt_tm
    FROM (dummyt d1  WITH seq = value(size(updt_rec->syn_list,5))),
     code_value cv
    PLAN (d1
     WHERE (updt_rec->syn_list[d1.seq].synonym_id > 0))
     JOIN (cv
     WHERE cv.code_set=200
      AND (cv.code_value=
     (SELECT
      ocs.catalog_cd
      FROM order_catalog_synonym ocs
      WHERE (ocs.synonym_id=updt_rec->syn_list[d1.seq].synonym_id)
       AND ((ocs.mnemonic_type_cd+ 0)=cdtypeprimary)
       AND ((ocs.catalog_type_cd+ 0)=cdpharmacy))))
    WITH nocounter, forupdate(cv)
   ;end select
   SELECT
    IF ((request->commit_ind=1))INTO "nl:"
    ELSE
    ENDIF
    d1.seq, updatetable = "ORDER_CATALOG", newprimary = updt_rec->syn_list[d1.seq].new_mnemonic,
    oc.primary_mnemonic, oc.updt_dt_tm
    FROM (dummyt d1  WITH seq = value(size(updt_rec->syn_list,5))),
     order_catalog oc
    PLAN (d1
     WHERE (updt_rec->syn_list[d1.seq].synonym_id > 0))
     JOIN (oc
     WHERE (oc.catalog_cd=
     (SELECT
      ocs.catalog_cd
      FROM order_catalog_synonym ocs
      WHERE (ocs.synonym_id=updt_rec->syn_list[d1.seq].synonym_id)
       AND ((ocs.mnemonic_type_cd+ 0)=cdtypeprimary)
       AND ((ocs.catalog_type_cd+ 0)=cdpharmacy))))
    WITH nocounter, forupdate(oc)
   ;end select
   SELECT
    IF ((request->commit_ind=1))INTO "nl:"
    ELSE
    ENDIF
    d1.seq, updatetable = "ORDER_CATALOG_SYNONYM", newsynonym = updt_rec->syn_list[d1.seq].
    new_mnemonic,
    currentsynonym = ocs.mnemonic, ocs.mnemonic_key_cap, ocs.updt_dt_tm
    FROM (dummyt d1  WITH seq = value(size(updt_rec->syn_list,5))),
     order_catalog_synonym ocs
    PLAN (d1
     WHERE (updt_rec->syn_list[d1.seq].synonym_id > 0))
     JOIN (ocs
     WHERE (ocs.synonym_id=updt_rec->syn_list[d1.seq].synonym_id)
      AND  NOT (((ocs.mnemonic_type_cd+ 0) IN (cdtyperxmnem)))
      AND ((ocs.catalog_type_cd+ 0)=cdpharmacy))
    WITH nocounter, forupdate(ocs)
   ;end select
   SET mnem_cnt = curqual
   SELECT
    IF ((request->commit_ind=1))INTO "nl:"
    ELSE
    ENDIF
    d1.seq, updatetable = "ORDER_TASK", newtask = updt_rec->task_list[d1.seq].new_task,
    currenttask = ot.task_description, ot.updt_dt_tm
    FROM (dummyt d1  WITH seq = value(size(updt_rec->task_list,5))),
     order_task ot
    PLAN (d1
     WHERE (updt_rec->task_list[d1.seq].ref_task_id > 0))
     JOIN (ot
     WHERE (ot.reference_task_id=updt_rec->task_list[d1.seq].ref_task_id))
    WITH nocounter, forupdate(ot)
   ;end select
   SET task_cnt = curqual
   SELECT
    IF ((request->commit_ind=1))INTO "nl:"
    ELSE
    ENDIF
    d1.seq, updatetable = "V500_EVENT_SET_CODE", neweventset = updt_rec->event_set_list[d1.seq].
    new_event_set,
    currenteventset = es.event_set_cd_disp, es.updt_dt_tm
    FROM (dummyt d1  WITH seq = value(size(updt_rec->event_set_list,5))),
     v500_event_set_code es
    PLAN (d1
     WHERE (updt_rec->event_set_list[d1.seq].event_set_cd > 0))
     JOIN (es
     WHERE (es.event_set_cd=updt_rec->event_set_list[d1.seq].event_set_cd))
    WITH nocounter, forupdate(es)
   ;end select
   SET es_cnt = curqual
   SELECT
    IF ((request->commit_ind=1))INTO "nl:"
    ELSE
    ENDIF
    d1.seq, updatetable = "CODE_VALUE", neweventset = updt_rec->event_set_list[d1.seq].new_event_set,
    currenteventset = cv.display, cv.updt_dt_tm
    FROM (dummyt d1  WITH seq = value(size(updt_rec->event_set_list,5))),
     code_value cv
    PLAN (d1
     WHERE (updt_rec->event_set_list[d1.seq].event_set_cd > 0))
     JOIN (cv
     WHERE cv.code_set=93
      AND (cv.code_value=updt_rec->event_set_list[d1.seq].event_set_cd))
    WITH nocounter, forupdate(cv)
   ;end select
   SELECT
    IF ((request->commit_ind=1))INTO "nl:"
    ELSE
    ENDIF
    d1.seq, updatetable = "V500_EVENT_CODE", neweventcd = updt_rec->event_cd_list[d1.seq].
    new_event_cd,
    currenteventcd = ec.event_cd_disp, ec.updt_dt_tm
    FROM (dummyt d1  WITH seq = value(size(updt_rec->event_cd_list,5))),
     v500_event_code ec
    PLAN (d1
     WHERE (updt_rec->event_cd_list[d1.seq].event_cd > 0))
     JOIN (ec
     WHERE (ec.event_cd=updt_rec->event_cd_list[d1.seq].event_cd))
    WITH nocounter, forupdate(ec)
   ;end select
   SET ec_cnt = curqual
   SELECT
    IF ((request->commit_ind=1))INTO "nl:"
    ELSE
    ENDIF
    d1.seq, updatetable = "CODE_VALUE", neweventcd = updt_rec->event_cd_list[d1.seq].new_event_cd,
    currenteventcd = cv.display, cv.updt_dt_tm
    FROM (dummyt d1  WITH seq = value(size(updt_rec->event_cd_list,5))),
     code_value cv
    PLAN (d1
     WHERE (updt_rec->event_cd_list[d1.seq].event_cd > 0))
     JOIN (cv
     WHERE cv.code_set=72
      AND (cv.code_value=updt_rec->event_cd_list[d1.seq].event_cd))
    WITH nocounter, forupdate(cv)
   ;end select
   IF ((request->commit_ind=1))
    CALL echo("Updating code_value for code_set 200")
    UPDATE  FROM (dummyt d1  WITH seq = value(size(updt_rec->syn_list,5))),
      code_value cv
     SET cv.display = trim(substring(1,40,updt_rec->syn_list[d1.seq].new_mnemonic)), cv.display_key
       = trim(cnvtalphanum(cnvtupper(substring(1,40,updt_rec->syn_list[d1.seq].new_mnemonic)))), cv
      .description = trim(substring(1,60,updt_rec->syn_list[d1.seq].new_mnemonic)),
      cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv.updt_cnt = (
      cv.updt_cnt+ 1),
      cv.updt_applctx = 0, cv.updt_task = - (267)
     PLAN (d1
      WHERE (updt_rec->syn_list[d1.seq].synonym_id > 0))
      JOIN (cv
      WHERE cv.code_set=200
       AND (cv.code_value=
      (SELECT
       ocs.catalog_cd
       FROM order_catalog_synonym ocs
       WHERE (ocs.synonym_id=updt_rec->syn_list[d1.seq].synonym_id)
        AND ((ocs.mnemonic_type_cd+ 0)=cdtypeprimary)
        AND ((ocs.catalog_type_cd+ 0)=cdpharmacy))))
     WITH nocounter
    ;end update
    CALL echo("Updating order_catalog")
    UPDATE  FROM (dummyt d1  WITH seq = value(size(updt_rec->syn_list,5))),
      order_catalog oc
     SET oc.primary_mnemonic = trim(updt_rec->syn_list[d1.seq].new_mnemonic), oc.updt_dt_tm =
      cnvtdatetime(curdate,curtime3), oc.updt_id = reqinfo->updt_id,
      oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_applctx = 0, oc.updt_task = - (267)
     PLAN (d1
      WHERE (updt_rec->syn_list[d1.seq].synonym_id > 0))
      JOIN (oc
      WHERE (oc.catalog_cd=
      (SELECT
       ocs.catalog_cd
       FROM order_catalog_synonym ocs
       WHERE (ocs.synonym_id=updt_rec->syn_list[d1.seq].synonym_id)
        AND ((ocs.mnemonic_type_cd+ 0)=cdtypeprimary)
        AND ((ocs.catalog_type_cd+ 0)=cdpharmacy))))
     WITH nocounter
    ;end update
    CALL echo("Updating order_catalog_synonym")
    UPDATE  FROM (dummyt d1  WITH seq = value(size(updt_rec->syn_list,5))),
      order_catalog_synonym ocs
     SET ocs.mnemonic = trim(updt_rec->syn_list[d1.seq].new_mnemonic), ocs.mnemonic_key_cap = trim(
       cnvtupper(updt_rec->syn_list[d1.seq].new_mnemonic)), ocs.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      ocs.updt_id = reqinfo->updt_id, ocs.updt_cnt = (ocs.updt_cnt+ 1), ocs.updt_applctx = 0,
      ocs.updt_task = - (267)
     PLAN (d1
      WHERE (updt_rec->syn_list[d1.seq].synonym_id > 0))
      JOIN (ocs
      WHERE (ocs.synonym_id=updt_rec->syn_list[d1.seq].synonym_id)
       AND  NOT (((ocs.mnemonic_type_cd+ 0) IN (cdtyperxmnem)))
       AND ((ocs.catalog_type_cd+ 0)=cdpharmacy))
     WITH nocounter
    ;end update
    CALL echo("Updating order_task")
    UPDATE  FROM (dummyt d1  WITH seq = value(size(updt_rec->task_list,5))),
      order_task ot
     SET ot.task_description = trim(updt_rec->task_list[d1.seq].new_task), ot.task_description_key =
      trim(cnvtupper(updt_rec->task_list[d1.seq].new_task)), ot.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      ot.updt_id = reqinfo->updt_id, ot.updt_cnt = (ot.updt_cnt+ 1), ot.updt_applctx = 0,
      ot.updt_task = - (267)
     PLAN (d1
      WHERE (updt_rec->task_list[d1.seq].ref_task_id > 0))
      JOIN (ot
      WHERE (ot.reference_task_id=updt_rec->task_list[d1.seq].ref_task_id))
     WITH nocounter
    ;end update
    CALL echo("Updating v500_event_set_code")
    UPDATE  FROM (dummyt d1  WITH seq = value(size(updt_rec->event_set_list,5))),
      v500_event_set_code es
     SET es.event_set_cd_disp = trim(updt_rec->event_set_list[d1.seq].new_event_set), es
      .event_set_cd_disp_key = trim(cnvtalphanum(cnvtupper(updt_rec->event_set_list[d1.seq].
         new_event_set))), es.event_set_cd_descr = trim(updt_rec->event_set_list[d1.seq].
       new_event_set),
      es.event_set_cd_definition = trim(updt_rec->event_set_list[d1.seq].new_event_set), es
      .updt_dt_tm = cnvtdatetime(curdate,curtime3), es.updt_id = reqinfo->updt_id,
      es.updt_cnt = (es.updt_cnt+ 1), es.updt_applctx = 0, es.updt_task = - (267)
     PLAN (d1
      WHERE (updt_rec->event_set_list[d1.seq].event_set_cd > 0))
      JOIN (es
      WHERE (es.event_set_cd=updt_rec->event_set_list[d1.seq].event_set_cd))
     WITH nocounter
    ;end update
    CALL echo("Updating code_value for code_set 93")
    UPDATE  FROM (dummyt d1  WITH seq = value(size(updt_rec->event_set_list,5))),
      code_value cv
     SET cv.display = trim(substring(1,40,updt_rec->event_set_list[d1.seq].new_event_set)), cv
      .display_key = trim(cnvtalphanum(cnvtupper(substring(1,40,updt_rec->event_set_list[d1.seq].
          new_event_set)))), cv.description = trim(substring(1,60,updt_rec->event_set_list[d1.seq].
        new_event_set)),
      cv.definition = trim(substring(1,100,updt_rec->event_set_list[d1.seq].new_event_set)), cv
      .updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id,
      cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_applctx = 0, cv.updt_task = - (267)
     PLAN (d1
      WHERE (updt_rec->event_set_list[d1.seq].event_set_cd > 0))
      JOIN (cv
      WHERE cv.code_set=93
       AND (cv.code_value=updt_rec->event_set_list[d1.seq].event_set_cd))
     WITH nocounter
    ;end update
    CALL echo("Updating v500_event_code")
    UPDATE  FROM (dummyt d1  WITH seq = value(size(updt_rec->event_cd_list,5))),
      v500_event_code ec
     SET ec.event_cd_disp = trim(updt_rec->event_cd_list[d1.seq].new_event_cd), ec.event_cd_disp_key
       = trim(cnvtalphanum(cnvtupper(updt_rec->event_cd_list[d1.seq].new_event_cd))), ec
      .event_cd_descr = trim(updt_rec->event_cd_list[d1.seq].new_event_cd),
      ec.event_cd_definition = trim(updt_rec->event_cd_list[d1.seq].new_event_cd), ec.updt_dt_tm =
      cnvtdatetime(curdate,curtime3), ec.updt_id = reqinfo->updt_id,
      ec.updt_cnt = (ec.updt_cnt+ 1), ec.updt_applctx = 0, ec.updt_task = - (267)
     PLAN (d1
      WHERE (updt_rec->event_cd_list[d1.seq].event_cd > 0))
      JOIN (ec
      WHERE (ec.event_cd=updt_rec->event_cd_list[d1.seq].event_cd))
     WITH nocounter
    ;end update
    CALL echo("Updating code_value for code_set 72")
    UPDATE  FROM (dummyt d1  WITH seq = value(size(updt_rec->event_cd_list,5))),
      code_value cv
     SET cv.display = trim(substring(1,40,updt_rec->event_cd_list[d1.seq].new_event_cd)), cv
      .display_key = trim(cnvtalphanum(cnvtupper(substring(1,40,updt_rec->event_cd_list[d1.seq].
          new_event_cd)))), cv.description = trim(substring(1,60,updt_rec->event_cd_list[d1.seq].
        new_event_cd)),
      cv.definition = trim(substring(1,100,updt_rec->event_cd_list[d1.seq].new_event_cd)), cv
      .updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id,
      cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_applctx = 0, cv.updt_task = - (267)
     PLAN (d1
      WHERE (updt_rec->event_cd_list[d1.seq].event_cd > 0))
      JOIN (cv
      WHERE cv.code_set=72
       AND (cv.code_value=updt_rec->event_cd_list[d1.seq].event_cd))
     WITH nocounter
    ;end update
   ENDIF
 END ;Subroutine
 SUBROUTINE checkformnemonicmismatches(null)
  SELECT INTO "nl: "
   ocs.synonym_id, newsynonym = updt_rec->syn_list[d1.seq].new_mnemonic, origsynonym = ocs.mnemonic
   FROM (dummyt d1  WITH seq = value(size(updt_rec->syn_list,5))),
    order_catalog_synonym ocs
   PLAN (d1)
    JOIN (ocs
    WHERE (ocs.synonym_id=updt_rec->syn_list[d1.seq].synonym_id)
     AND  NOT (((ocs.mnemonic_type_cd+ 0) IN (cdtyperxmnem)))
     AND ((ocs.catalog_type_cd+ 0)=cdpharmacy)
     AND ocs.mnemonic_key_cap != cnvtupper(updt_rec->syn_list[d1.seq].new_mnemonic))
   ORDER BY d1.seq
   HEAD REPORT
    mnem_mismatch_cnt = 0
   DETAIL
    mismatch_ind = 1, mnem_mismatch_cnt = (mnem_mismatch_cnt+ 1),
    CALL echo("*******************************************"),
    CALL echo("WARNING: Synonym mismatch found between upload CSV and order_catalog_synonym"),
    CALL echo(build("synonym_id: ",ocs.synonym_id)),
    CALL echo(build("CSV Synonym: ",cnvtupper(updt_rec->syn_list[d1.seq].new_mnemonic))),
    CALL echo(build("OCS Synonym: ",ocs.mnemonic_key_cap)),
    CALL echo("*******************************************")
   WITH nocounter
  ;end select
  RETURN(mnem_mismatch_cnt)
 END ;Subroutine
 SUBROUTINE checkfortaskmismatches(null)
  SELECT INTO "nl:"
   ot.reference_task_id, newtask = updt_rec->task_list[d1.seq].new_task, origtask = ot
   .task_description
   FROM (dummyt d1  WITH seq = value(size(updt_rec->task_list,5))),
    order_task ot
   PLAN (d1)
    JOIN (ot
    WHERE (ot.reference_task_id=updt_rec->task_list[d1.seq].ref_task_id)
     AND ot.task_description_key != cnvtupper(updt_rec->task_list[d1.seq].new_task))
   ORDER BY d1.seq
   HEAD REPORT
    task_mismatch_cnt = 0
   DETAIL
    mismatch_ind = 1, task_mismatch_cnt = (task_mismatch_cnt+ 1),
    CALL echo("*******************************************"),
    CALL echo("WARNING: Task Mismatch found between upload CSV and order_task"),
    CALL echo(build("reference_task_id: ",ot.reference_task_id)),
    CALL echo(build("CSV Task: ",cnvtupper(updt_rec->task_list[d1.seq].new_task))),
    CALL echo(build("OT Task: ",ot.task_description_key)),
    CALL echo("*******************************************")
   WITH nocounter
  ;end select
  RETURN(task_mismatch_cnt)
 END ;Subroutine
 SUBROUTINE checkforeventsetmismatches(null)
  SELECT INTO "nl:"
   es.event_set_cd, neweventset = updt_rec->event_set_list[d1.seq].new_event_set, origeventset = es
   .event_set_cd_disp
   FROM (dummyt d1  WITH seq = value(size(updt_rec->event_set_list,5))),
    v500_event_set_code es
   PLAN (d1)
    JOIN (es
    WHERE (es.event_set_cd=updt_rec->event_set_list[d1.seq].event_set_cd)
     AND es.event_set_cd_disp_key != cnvtalphanum(cnvtupper(updt_rec->event_set_list[d1.seq].
      new_event_set)))
   ORDER BY d1.seq
   HEAD REPORT
    es_mismatch_cnt = 0
   DETAIL
    mismatch_ind = 1, es_mismatch_cnt = (es_mismatch_cnt+ 1),
    CALL echo("*******************************************"),
    CALL echo("WARNING: Event_set Mismatch found between upload CSV and v500_event_set_code"),
    CALL echo(build("event_set_cd: ",es.event_set_cd)),
    CALL echo(build("CSV Event_set: ",cnvtalphanum(cnvtupper(updt_rec->event_set_list[d1.seq].
       new_event_set)))),
    CALL echo(build("V500 Event_set_disp_key: ",es.event_set_cd_disp_key)),
    CALL echo("*******************************************")
   WITH nocounter
  ;end select
  RETURN(es_mismatch_cnt)
 END ;Subroutine
 SUBROUTINE checkforeventcodemismatches(null)
  SELECT INTO "nl:"
   ec.event_cd, neweventcd = updt_rec->event_cd_list[d1.seq].new_event_cd, origeventcd = ec
   .event_cd_disp
   FROM (dummyt d1  WITH seq = value(size(updt_rec->event_cd_list,5))),
    v500_event_code ec
   PLAN (d1)
    JOIN (ec
    WHERE (ec.event_cd=updt_rec->event_cd_list[d1.seq].event_cd)
     AND ec.event_cd_disp_key != cnvtalphanum(cnvtupper(updt_rec->event_cd_list[d1.seq].new_event_cd)
     ))
   ORDER BY d1.seq
   HEAD REPORT
    ec_mismatch_cnt = 0
   DETAIL
    mismatch_ind = 1, ec_mismatch_cnt = (ec_mismatch_cnt+ 1),
    CALL echo("*******************************************"),
    CALL echo("WARNING: Event_code Mismatch found between upload CSV and v500_event_code"),
    CALL echo(build("Event_cd: ",ec.event_cd)),
    CALL echo(build("CSV Event_code: ",cnvtalphanum(cnvtupper(updt_rec->event_cd_list[d1.seq].
       new_event_cd)))),
    CALL echo(build("V500 Event_code_disp_key: ",ec.event_cd_disp_key)),
    CALL echo("*******************************************")
   WITH nocounter
  ;end select
  RETURN(ec_mismatch_cnt)
 END ;Subroutine
#exit_script
 IF (mnem_mismatch_cnt > 0)
  CALL echo(build("WARNING: ",mnem_mismatch_cnt,
    " synonym mismatches found. Scroll up to evaluate mismatch."))
 ENDIF
 IF (task_mismatch_cnt > 0)
  CALL echo(build("WARNING: ",task_mismatch_cnt,
    " task mismatches found. Scroll up to evaluate mismatch."))
 ENDIF
 IF (es_mismatch_cnt > 0)
  CALL echo(build("WARNING: ",es_mismatch_cnt,
    " event_set mismatches found. Scroll up to evaluate mismatch."))
 ENDIF
 IF (ec_mismatch_cnt > 0)
  CALL echo(build("WARNING: ",ec_mismatch_cnt,
    " event_code mismatches found. Scroll up to evaluate mismatch."))
 ENDIF
 IF (script_mode=eupdate_mode
  AND (request->commit_ind=1)
  AND ((mismatch_ind=0) OR (ignore_mismatch_warn=1)) )
  CALL echo("Committing changes")
  COMMIT
  SET total_cnt = (((mnem_cnt+ task_cnt)+ es_cnt)+ ec_cnt)
  EXECUTE ams_define_toolkit_common
  CALL updtdminfo(script_name,cnvtreal(total_cnt))
 ELSEIF (script_mode=eupdate_mode)
  CALL echo("Rolling back changes")
  ROLLBACK
 ENDIF
 CALL echo("All Done")
 SET last_mod = "006"
END GO
