CREATE PROGRAM dts_use_default_template:dba
 DECLARE itr = i4 WITH noconstant(0)
 DECLARE itr2 = i4 WITH noconstant(0)
 DECLARE listsize = i4 WITH noconstant(0)
 DECLARE datasize = i4 WITH noconstant(0)
 DECLARE pos = i4 WITH noconstant(0)
 DECLARE txlen = i4 WITH noconstant(0)
 DECLARE mtm = i4 WITH constant(4140000)
 DECLARE str = vc
 RECORD prefs(
   1 pref_qual[*]
     2 person_id = f8
     2 parameter_data = vc
 )
 RECORD changed(
   1 pref_qual[*]
     2 person_id = f8
     2 parameter_data = vc
 )
 SELECT
  *
  FROM application_ini a
  WHERE a.application_number=mtm
   AND a.section="General"
  DETAIL
   itr = (itr+ 1)
   IF (itr > listsize)
    listsize = (listsize+ 50), stat = alterlist(prefs->pref_qual,listsize)
   ENDIF
   prefs->pref_qual[itr].person_id = a.person_id, prefs->pref_qual[itr].parameter_data = notrim(a
    .parameter_data)
  FOOT REPORT
   stat = alterlist(prefs->pref_qual,itr), listsize = itr
  WITH nocounter
 ;end select
 SET stat = alterlist(changed->pref_qual,listsize)
 FOR (itr = 1 TO listsize)
   SET pos = findstring("bDefStartupTemp=False",prefs->pref_qual[itr].parameter_data)
   SET txlen = textlen("bDefStartupTemp=False")
   IF (pos > 0)
    SET itr2 = (itr2+ 1)
    SET datasize = textlen(prefs->pref_qual[itr].parameter_data)
    SET str = notrim(concat(substring(1,(pos - 1),prefs->pref_qual[itr].parameter_data),
      "bDefStartupTemp=True"))
    SET str = notrim(concat(str,substring((pos+ txlen),(((datasize - txlen) - 1) - pos),prefs->
       pref_qual[itr].parameter_data)))
    SET changed->pref_qual[itr2].person_id = prefs->pref_qual[itr].person_id
    SET changed->pref_qual[itr2].parameter_data = notrim(str)
   ENDIF
 ENDFOR
 SET listsize = itr2
 SET stat = alterlist(changed->pref_qual,listsize)
 UPDATE  FROM application_ini a,
   (dummyt d  WITH seq = listsize)
  SET a.parameter_data = notrim(changed->pref_qual[d.seq].parameter_data)
  PLAN (d)
   JOIN (a
   WHERE a.application_number=mtm
    AND a.section="General"
    AND (a.person_id=changed->pref_qual[d.seq].person_id))
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
