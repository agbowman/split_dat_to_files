CREATE PROGRAM bed_get_nomen_by_cki:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 synonyms[*]
      2 source_string = vc
      2 source_vocabulary_cd = f8
      2 source_vocabulary_disp = vc
      2 source_vocabulary_mean = c12
      2 principle_type_cd = f8
      2 principle_type_disp = vc
      2 principle_type_mean = c12
      2 vocab_axis_cd = f8
      2 vocab_axis_disp = vc
      2 vocab_axis_mean = c12
      2 contributor_system_cd = f8
      2 contributor_system_disp = vc
      2 contributor_system_mean = c12
      2 language_cd = f8
      2 language_disp = vc
      2 language_mean = c12
      2 nomenclature_id = f8
      2 primary_vterm_ind = i2
      2 primary_cterm_ind = i2
      2 string_source_cd = f8
      2 string_source_disp = vc
      2 string_source_mean = c12
      2 active_ind = i2
      2 source_identifier = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE nomen_cnt = i4 WITH public, noconstant(0)
 DECLARE wheredate = vc WITH public, noconstant(" ")
 DECLARE cki_size = i4 WITH public, noconstant(0)
 DECLARE pos = i4 WITH public, noconstant(0)
 DECLARE concept_identifier = vc WITH public, noconstant(" ")
 DECLARE concept_source_cd = f8 WITH public, noconstant(0.0)
 DECLARE concept_source_mean = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE req_concept_identifier = vc WITH public, noconstant(" ")
 DECLARE req_concept_source_cd = f8 WITH public, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET cki_size = size(request->concept_cki,1)
 SET pos = findstring("!",request->concept_cki)
 IF (validate(request->concept_identifier,"0") != "0")
  SET req_concept_identifier = request->concept_identifier
 ENDIF
 IF ((validate(request->concept_source_cd,- (1)) != - (1)))
  SET req_concept_source_cd = request->concept_source_cd
 ENDIF
 IF ((request->concept_cki > " "))
  IF (pos > 1
   AND cki_size > 2)
   SET concept_source_mean = cnvtupper(substring(1,(pos - 1),request->concept_cki))
   SET concept_identifier = substring((pos+ 1),cki_size,request->concept_cki)
   SET concept_source_cd = uar_get_code_by("MEANING",12100,nullterm(trim(concept_source_mean)))
  ELSE
   SET failed = "T"
   CALL echo(build("The Concept_cki is not in a valid format"))
   GO TO exit_script
  ENDIF
 ELSEIF (req_concept_source_cd > 0.0
  AND req_concept_identifier > " "
  AND  NOT ((request->concept_cki > " ")))
  SET concept_identifier = req_concept_identifier
  SET concept_source_cd = req_concept_source_cd
  SET concept_source_mean = uar_get_code_meaning(concept_source_cd)
  SET request->concept_cki = concat(trim(concept_source_mean),"!",concept_identifier)
 ELSE
  SET failed = "T"
  CALL echo("There was a problem determining which filter to use.")
  GO TO exit_script
 ENDIF
 SELECT
  IF ((request->all_ind=true))
   WHERE (((n.concept_cki=request->concept_cki)) OR (n.concept_identifier=concept_identifier
    AND n.concept_source_cd=concept_source_cd))
  ELSE
   WHERE (((n.concept_cki=request->concept_cki)) OR (n.concept_identifier=concept_identifier
    AND n.concept_source_cd=concept_source_cd))
    AND n.active_ind=1
    AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  ENDIF
  INTO "nl:"
  n.*
  FROM nomenclature n
  ORDER BY n.source_string
  HEAD REPORT
   nomen_cnt = 0, stat = alterlist(reply->synonyms,10)
  DETAIL
   nomen_cnt = (nomen_cnt+ 1)
   IF (mod(nomen_cnt,10)=1
    AND nomen_cnt != 1)
    stat = alterlist(reply->synonyms,(nomen_cnt+ 9))
   ENDIF
   reply->synonyms[nomen_cnt].source_string = n.source_string, reply->synonyms[nomen_cnt].
   source_vocabulary_cd = n.source_vocabulary_cd, reply->synonyms[nomen_cnt].principle_type_cd = n
   .principle_type_cd,
   reply->synonyms[nomen_cnt].vocab_axis_cd = n.vocab_axis_cd, reply->synonyms[nomen_cnt].
   contributor_system_cd = n.contributor_system_cd, reply->synonyms[nomen_cnt].language_cd = n
   .language_cd,
   reply->synonyms[nomen_cnt].nomenclature_id = n.nomenclature_id, reply->synonyms[nomen_cnt].
   primary_vterm_ind = n.primary_vterm_ind, reply->synonyms[nomen_cnt].primary_cterm_ind = n
   .primary_cterm_ind,
   reply->synonyms[nomen_cnt].string_source_cd = n.string_source_cd, reply->synonyms[nomen_cnt].
   active_ind = n.active_ind, reply->synonyms[nomen_cnt].source_identifier = n.source_identifier
  FOOT REPORT
   stat = alterlist(reply->synonyms,nomen_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
