CREATE PROGRAM ct_sub_rpt_prescreen_dx_pt:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Execution Mode:" = "",
  "Evaluation Start Date" = curdate,
  "Evaluation End Date" = curdate,
  "Encounter types to be considered:" = 0,
  "Facility to be evaluated:" = 0,
  "Protocols to be Considered:" = "",
  "For Report Order By:" = 0,
  "Gender" = 0.000000,
  "Age Qualifier" = 0.000000,
  "Age 1 (years)" = 0,
  "Age 2 (years)" = 0,
  "Race" = 0.000000,
  "Ethnicity" = 0.000000,
  "Terminology Codes" = "0.000000",
  "Codes" = "",
  "icd9DefaultHidden" = 0,
  "testOnlyHidden" = 0,
  "Evaluation By:" = 0
  WITH outdev, execmode, startdate,
  enddate, encntrtypecd, facilitycd,
  triggername, orderby, gender,
  qualifier, age1, age2,
  race, ethnicity, terminology,
  codes, icd9defaulthidden, testonlyhidden,
  evalby
 EXECUTE reportrtl
 RECORD paramlists(
   1 etypecnt = i4
   1 eanyflag = i2
   1 equal[*]
     2 etypecd = f8
   1 faccnt = i4
   1 fanyflag = i2
   1 fqual[*]
     2 faccd = f8
   1 protcnt = i4
   1 pqual[*]
     2 primary_mnemonic = vc
 )
 RECORD protlist(
   1 protqual[*]
     2 primary_mnemonic = vc
     2 init_service = vc
     2 prot_master_id = f8
     2 personcnt = i4
     2 personqual[*]
       3 person_id = f8
       3 comment = vc
 )
 RECORD eksctrequest(
   1 opsind = i2
   1 execmodeflag = i2
   1 screenerid = f8
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 order_id = f8
     2 accession_id = f8
     2 sex_cd = f8
     2 birth_dt_tm = dq8
     2 race_cd = f8
     2 currentct[*]
       3 prot_master_id = f8
       3 primary_mnemonic = vc
   1 checkct[*]
     2 prot_master_id = f8
     2 primary_mnemonic = vc
 )
 RECORD eksctreply(
   1 ctfndind = i2
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 ctcnt = i4
     2 ctqual[*]
       3 pt_prot_prescreen_id = f8
       3 primary_mnemonic = vc
       3 prot_master_id = f8
       3 comment = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(domain_reply)))
  RECORD domain_reply(
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE get_prescreen_results(dummy) = null WITH protect
 DECLARE updatequeryforevaluationby(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 IF (validate(_bsubreport) != 1)
  DECLARE _bsubreport = i1 WITH noconstant(0), protect
 ENDIF
 IF (_bsubreport=0)
  DECLARE _hreport = i4 WITH noconstant(0), protect
  DECLARE _yoffset = f8 WITH noconstant(0.0), protect
  DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 ENDIF
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yshift = f8 WITH noconstant(0.0), protect
 DECLARE _xshift = f8 WITH noconstant(0.0), protect
 DECLARE _sendto = vc WITH noconstant( $OUTDEV), protect
 DECLARE _rpterr = i2 WITH noconstant(0), protect
 DECLARE _rptstat = i2 WITH noconstant(0), protect
 DECLARE _oldfont = i4 WITH noconstant(0), protect
 DECLARE _oldpen = i4 WITH noconstant(0), protect
 DECLARE _dummyfont = i4 WITH noconstant(0), protect
 DECLARE _dummypen = i4 WITH noconstant(0), protect
 DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
 DECLARE _rptpage = i4 WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _remlabel_rpt_pt_inquiry_rpt = i4 WITH noconstant(1), protect
 DECLARE _remdate = i4 WITH noconstant(1), protect
 DECLARE _remlabel_total = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontheadpagesection = i2 WITH noconstant(0), protect
 DECLARE _remlabel_rpt_atient = i4 WITH noconstant(1), protect
 DECLARE _remlabel_rpt_encounter = i4 WITH noconstant(1), protect
 DECLARE _remlabel_rpt_gender = i4 WITH noconstant(1), protect
 DECLARE _remlabel_rpt_age = i4 WITH noconstant(1), protect
 DECLARE _remlabel_rpt_reg_dt = i4 WITH noconstant(1), protect
 DECLARE _remlabel_rpt_race = i4 WITH noconstant(1), protect
 DECLARE _remlabel_rpt_facility = i4 WITH noconstant(1), protect
 DECLARE _bcontheadpagesection1 = i2 WITH noconstant(0), protect
 DECLARE _remlabel_rpt_atient = i4 WITH noconstant(1), protect
 DECLARE _remlabel_rpt_gender = i4 WITH noconstant(1), protect
 DECLARE _remlabel_rpt_age = i4 WITH noconstant(1), protect
 DECLARE _remlabel_rpt_race = i4 WITH noconstant(1), protect
 DECLARE _bcontheadpagesection2 = i2 WITH noconstant(0), protect
 DECLARE _remname = i4 WITH noconstant(1), protect
 DECLARE _remencounter = i4 WITH noconstant(1), protect
 DECLARE _remgender = i4 WITH noconstant(1), protect
 DECLARE _remage = i4 WITH noconstant(1), protect
 DECLARE _remreg_dt_tm = i4 WITH noconstant(1), protect
 DECLARE _remfacility = i4 WITH noconstant(1), protect
 DECLARE _remrace = i4 WITH noconstant(1), protect
 DECLARE _bcontheadp_person_idsection = i2 WITH noconstant(0), protect
 DECLARE _remname = i4 WITH noconstant(1), protect
 DECLARE _remgender = i4 WITH noconstant(1), protect
 DECLARE _remage = i4 WITH noconstant(1), protect
 DECLARE _remrace = i4 WITH noconstant(1), protect
 DECLARE _bcontheadp_person_idsection1 = i2 WITH noconstant(0), protect
 DECLARE _remlabel_rpt_page = i4 WITH noconstant(1), protect
 DECLARE _bcontfootpagesection = i2 WITH noconstant(0), protect
 DECLARE _remlabel_total = i4 WITH noconstant(1), protect
 DECLARE _bcontfootreportsection = i2 WITH noconstant(0), protect
 DECLARE _remlabel_title = i4 WITH noconstant(1), protect
 DECLARE _remdate = i4 WITH noconstant(1), protect
 DECLARE _remlabel_total = i4 WITH noconstant(1), protect
 DECLARE _bcontfootreportsection2 = i2 WITH noconstant(0), protect
 DECLARE _courier70 = i4 WITH noconstant(0), protect
 DECLARE _courier10b0 = i4 WITH noconstant(0), protect
 DECLARE _courier12b0 = i4 WITH noconstant(0), protect
 DECLARE _courier80 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _courier100 = i4 WITH noconstant(0), protect
 DECLARE _courier8b0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s3c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE evaluationbywherestring = vc WITH protect, noconstant("")
 DECLARE appointmentwherestring = vc WITH protect, noconstant("")
 DECLARE active_cd = f8 WITH public, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE active_encntr_cd = f8 WITH public, constant(uar_get_code_by("MEANING",261,"ACTIVE"))
 DECLARE discharged_encntr_cd = f8 WITH public, constant(uar_get_code_by("MEANING",261,"DISCHARGED"))
 SUBROUTINE updatequeryforevaluationby(dummy)
  SET appointmentwherestring = "1=1"
  IF (( $EVALBY=0))
   SET evaluationbywherestring =
   "e.reg_dt_tm BETWEEN cnvtdatetime(startDtTm) AND cnvtdatetime(endDtTm)"
  ELSEIF (( $EVALBY=1))
   SET evaluationbywherestring =
"(e.active_ind = 1 and e.active_status_cd = ACTIVE_CD and e.reg_dt_tm <=                         cnvtdatetime(endDtTm)) AND\
 ((e.encntr_status_cd = DISCHARGED_ENCNTR_CD and e.disch_dt_tm >=                         cnvtdatetime(startDtTm)) OR (e.e\
ncntr_status_cd = ACTIVE_ENCNTR_CD and e.disch_dt_tm is NULL))\
"
  ELSEIF (( $EVALBY=2))
   SET evaluationbywherestring = "e.encntr_id > 0.0"
   SET appointmentwherestring =
"((sa.active_ind = 1 AND sa.encntr_id = e.encntr_id) 			AND (sa.beg_dt_tm BETWEEN cnvtdatetime(startDtTm) AND cnvtdatetime(\
endDtTm)) 			AND (sa.state_meaning in ('SCHEDULED', 'RESCHEDULED','CHECKED IN','CHECKED OUT','CONFIRMED')))\
"
  ENDIF
 END ;Subroutine
 SUBROUTINE get_prescreen_results(dummy)
   IF (( $EVALBY < 2))
    SELECT
     IF (dxcodecnt > 0)DISTINCT
      e.person_id, p.person_id, p.sex_cd,
      p.birth_dt_tm, p.name_last_key, p.name_last,
      p.name_first_key, p.name_first, p.name_middle_key,
      p.race_cd, p.ethnic_grp_cd, encounter = max(e.encntr_id)
      FROM nomenclature n,
       diagnosis d,
       encounter e,
       person p
      PLAN (e
       WHERE (((paramlists->eanyflag=1)) OR (expand(num,1,paramlists->etypecnt,e.encntr_type_cd,
        paramlists->equal[num].etypecd)))
        AND (((paramlists->fanyflag=1)) OR (expand(num2,1,paramlists->faccnt,e.loc_facility_cd,
        paramlists->fqual[num2].faccd)))
        AND parser(evaluationbywherestring)
        AND e.active_ind=1
        AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
       JOIN (p
       WHERE p.person_id=e.person_id
        AND p.active_ind=1
        AND p.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND (p.logical_domain_id=domain_reply->logical_domain_id)
        AND parser(genderqual)
        AND parser(racequal)
        AND parser(ethnicityqual))
       JOIN (d
       WHERE d.encntr_id=e.encntr_id)
       JOIN (n
       WHERE n.nomenclature_id=d.nomenclature_id
        AND n.source_vocabulary_cd=terminologycd
        AND n.active_ind=1
        AND n.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND parser(dxcodequal))
      GROUP BY e.person_id, p.person_id, p.sex_cd,
       p.birth_dt_tm, p.name_last_key, p.name_last,
       p.name_first_key, p.name_first, p.name_middle_key,
       p.race_cd, p.ethnic_grp_cd
      HAVING count(DISTINCT n.source_identifier)=dxcodecnt
      ORDER BY p.name_last_key, p.name_first_key, p.name_middle_key,
       p.person_id
     ELSE DISTINCT
      e.person_id, e.encntr_id, p.sex_cd,
      p.birth_dt_tm, encounter = 1
      FROM encounter e,
       person p
      PLAN (e
       WHERE (((paramlists->eanyflag=1)) OR (expand(num,1,paramlists->etypecnt,e.encntr_type_cd,
        paramlists->equal[num].etypecd)))
        AND (((paramlists->fanyflag=1)) OR (expand(num2,1,paramlists->faccnt,e.loc_facility_cd,
        paramlists->fqual[num2].faccd)))
        AND parser(evaluationbywherestring)
        AND e.active_ind=1
        AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
       JOIN (p
       WHERE p.person_id=e.person_id
        AND p.active_ind=1
        AND p.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND (p.logical_domain_id=domain_reply->logical_domain_id)
        AND parser(genderqual)
        AND parser(racequal)
        AND parser(ethnicityqual))
      ORDER BY p.name_last_key, p.name_first_key, p.name_middle_key,
       p.person_id, e.reg_dt_tm DESC
     ENDIF
     ORDER BY p.person_id
     HEAD REPORT
      _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom), _bholdcontinue = 0,
      _fenddetail -= footpagesection(rpt_calcheight,((rptreport->m_pageheight - rptreport->
       m_marginbottom) - _yoffset),_bholdcontinue),
      patient_cnt = 0
     HEAD PAGE
      IF (curpage > 1)
       dummy_val = pagebreak(0)
      ENDIF
      IF ((eksctrequest->opsind < 1))
       _bcontheadpagesection = 0, dummy_val = headpagesection(rpt_render,((rptreport->m_pageheight -
        rptreport->m_marginbottom) - _yoffset),_bcontheadpagesection)
       IF (testonly=0)
        _bcontheadpagesection1 = 0, dummy_val = headpagesection1(rpt_render,((rptreport->m_pageheight
          - rptreport->m_marginbottom) - _yoffset),_bcontheadpagesection1), dummy_val =
        headpagesection3(rpt_render),
        _bcontheadpagesection2 = 0, dummy_val = headpagesection2(rpt_render,((rptreport->m_pageheight
          - rptreport->m_marginbottom) - _yoffset),_bcontheadpagesection2)
       ENDIF
       personage = (datetimediff(cnvtdatetime(sysdate),p.birth_dt_tm,1)/ 365.25)
      ENDIF
     HEAD p.person_id
      bfound = 0
      IF (age_qual != "1=1")
       IF (parser(age_qual))
        bfound = 1
       ELSE
        bfound = 0
       ENDIF
      ELSE
       bfound = 1
      ENDIF
      IF (bfound=1)
       patient_cnt += 1
       IF ((eksctrequest->opsind < 1)
        AND testonly=0)
        tmp_name = concat(trim(p.name_last),", ",trim(p.name_first)," (",trim(cnvtstring(e.person_id)
          ),
         ")"), tmp_sex = trim(uar_get_code_display(p.sex_cd)), tmp_age = trim(cnvtage(p.birth_dt_tm),
         3),
        tmp_race = trim(uar_get_code_display(p.race_cd))
        IF (dxcodecnt=0)
         tmp_encntr = concat(trim(uar_get_code_display(e.encntr_type_cd))," (",trim(cnvtstring(e
            .encntr_id)),")"), tmp_reg_dt_tm = format(e.reg_dt_tm,"@MEDIUMDATETIME"), tmp_facility =
         trim(uar_get_code_display(e.loc_facility_cd))
        ENDIF
        _bcontheadp_person_idsection = 0, bfirsttime = 1
        WHILE (((_bcontheadp_person_idsection=1) OR (bfirsttime=1)) )
          _bholdcontinue = _bcontheadp_person_idsection, _fdrawheight = headp_person_idsection(
           rpt_calcheight,(_fenddetail - _yoffset),_bholdcontinue)
          IF (((_bholdcontinue=1) OR (_fdrawheight > 0)) )
           IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
            _bholdcontinue = 0, _fdrawheight += headp_person_idsection1(rpt_calcheight,((_fenddetail
              - _yoffset) - _fdrawheight),_bholdcontinue)
            IF (_bholdcontinue=1)
             _fdrawheight = (_fenddetail+ 1)
            ENDIF
           ENDIF
          ENDIF
          IF (((_yoffset+ _fdrawheight) > _fenddetail))
           BREAK
          ELSEIF (_bholdcontinue=1
           AND _bcontheadp_person_idsection=0)
           BREAK
          ENDIF
          dummy_val = headp_person_idsection(rpt_render,(_fenddetail - _yoffset),
           _bcontheadp_person_idsection), bfirsttime = 0
        ENDWHILE
        _bcontheadp_person_idsection1 = 0, bfirsttime = 1
        WHILE (((_bcontheadp_person_idsection1=1) OR (bfirsttime=1)) )
          _bholdcontinue = _bcontheadp_person_idsection1, _fdrawheight = headp_person_idsection1(
           rpt_calcheight,(_fenddetail - _yoffset),_bholdcontinue)
          IF (((_yoffset+ _fdrawheight) > _fenddetail))
           BREAK
          ELSEIF (_bholdcontinue=1
           AND _bcontheadp_person_idsection1=0)
           BREAK
          ENDIF
          dummy_val = headp_person_idsection1(rpt_render,(_fenddetail - _yoffset),
           _bcontheadp_person_idsection1), bfirsttime = 0
        ENDWHILE
       ENDIF
      ENDIF
     DETAIL
      row + 0
     FOOT  p.person_id
      row + 0
     FOOT PAGE
      _yhold = _yoffset, _yoffset = _fenddetail, _bcontfootpagesection = 0,
      dummy_val = footpagesection(rpt_render,((rptreport->m_pageheight - rptreport->m_marginbottom)
        - _yoffset),_bcontfootpagesection), _yoffset = _yhold
     FOOT REPORT
      IF ((eksctrequest->opsind > 0))
       tmp_total = uar_i18nbuildmessage(i18nhandle,"TOTAL_OPS_PRESCREEN_RPT",
        "Total of %1 patient(s) found from %2 to %3 will be evaluated for this screening job.",
        "iss",patient_cnt,
        trim(format(startdttm,"@LONGDATE;t(3);q"),3),trim(format(enddttm,"@LONGDATE;t(3);q"),3)),
       _bcontfootreportsection2 = 0, bfirsttime = 1
       WHILE (((_bcontfootreportsection2=1) OR (bfirsttime=1)) )
         _bholdcontinue = _bcontfootreportsection2, _fdrawheight = footreportsection2(rpt_calcheight,
          (_fenddetail - _yoffset),_bholdcontinue)
         IF (((_bholdcontinue=1) OR (_fdrawheight > 0)) )
          IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
           _fdrawheight += footreportsection3(rpt_calcheight)
          ENDIF
         ENDIF
         IF (((_yoffset+ _fdrawheight) > _fenddetail))
          CALL pagebreak(0)
         ELSEIF (_bholdcontinue=1
          AND _bcontfootreportsection2=0)
          CALL pagebreak(0)
         ENDIF
         dummy_val = footreportsection2(rpt_render,(_fenddetail - _yoffset),_bcontfootreportsection2),
         bfirsttime = 0
       ENDWHILE
       _fdrawheight = footreportsection3(rpt_calcheight)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        CALL pagebreak(0)
       ENDIF
       dummy_val = footreportsection3(rpt_render)
      ENDIF
     WITH nocounter, separator = " ", format
    ;end select
   ELSEIF (( $EVALBY=2))
    SELECT
     IF (dxcodecnt > 0)DISTINCT
      e.person_id, p.person_id, p.sex_cd,
      p.birth_dt_tm, p.name_last_key, p.name_last,
      p.name_first_key, p.name_first, p.name_middle_key,
      p.race_cd, p.ethnic_grp_cd, encounter = max(e.encntr_id)
      FROM nomenclature n,
       diagnosis d,
       encounter e,
       person p,
       sch_appt sa
      PLAN (e
       WHERE (((paramlists->eanyflag=1)) OR (expand(num,1,paramlists->etypecnt,e.encntr_type_cd,
        paramlists->equal[num].etypecd)))
        AND (((paramlists->fanyflag=1)) OR (expand(num2,1,paramlists->faccnt,e.loc_facility_cd,
        paramlists->fqual[num2].faccd)))
        AND parser(evaluationbywherestring)
        AND e.active_ind=1
        AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
       JOIN (p
       WHERE p.person_id=e.person_id
        AND p.active_ind=1
        AND p.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND (p.logical_domain_id=domain_reply->logical_domain_id)
        AND parser(genderqual)
        AND parser(racequal)
        AND parser(ethnicityqual))
       JOIN (d
       WHERE d.encntr_id=e.encntr_id)
       JOIN (sa
       WHERE parser(appointmentwherestring))
       JOIN (n
       WHERE n.nomenclature_id=d.nomenclature_id
        AND n.source_vocabulary_cd=terminologycd
        AND n.active_ind=1
        AND n.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND parser(dxcodequal))
      GROUP BY e.person_id, p.person_id, p.sex_cd,
       p.birth_dt_tm, p.name_last_key, p.name_last,
       p.name_first_key, p.name_first, p.name_middle_key,
       p.race_cd, p.ethnic_grp_cd
      HAVING count(DISTINCT n.source_identifier)=dxcodecnt
      ORDER BY p.name_last_key, p.name_first_key, p.name_middle_key,
       p.person_id
     ELSE DISTINCT
      e.person_id, e.encntr_id, p.sex_cd,
      p.birth_dt_tm, encounter = 1
      FROM encounter e,
       person p,
       sch_appt sa
      PLAN (e
       WHERE (((paramlists->eanyflag=1)) OR (expand(num,1,paramlists->etypecnt,e.encntr_type_cd,
        paramlists->equal[num].etypecd)))
        AND (((paramlists->fanyflag=1)) OR (expand(num2,1,paramlists->faccnt,e.loc_facility_cd,
        paramlists->fqual[num2].faccd)))
        AND parser(evaluationbywherestring)
        AND e.active_ind=1
        AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
       JOIN (p
       WHERE p.person_id=e.person_id
        AND p.active_ind=1
        AND p.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND (p.logical_domain_id=domain_reply->logical_domain_id)
        AND parser(genderqual)
        AND parser(racequal)
        AND parser(ethnicityqual))
       JOIN (sa
       WHERE parser(appointmentwherestring))
      ORDER BY p.name_last_key, p.name_first_key, p.name_middle_key,
       p.person_id, e.reg_dt_tm DESC
     ENDIF
     ORDER BY p.person_id
     HEAD REPORT
      _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom), _bholdcontinue = 0,
      _fenddetail -= footpagesection(rpt_calcheight,((rptreport->m_pageheight - rptreport->
       m_marginbottom) - _yoffset),_bholdcontinue),
      patient_cnt = 0
     HEAD PAGE
      IF (curpage > 1)
       dummy_val = pagebreak(0)
      ENDIF
      IF ((eksctrequest->opsind < 1))
       _bcontheadpagesection = 0, dummy_val = headpagesection(rpt_render,((rptreport->m_pageheight -
        rptreport->m_marginbottom) - _yoffset),_bcontheadpagesection)
       IF (testonly=0)
        _bcontheadpagesection1 = 0, dummy_val = headpagesection1(rpt_render,((rptreport->m_pageheight
          - rptreport->m_marginbottom) - _yoffset),_bcontheadpagesection1), dummy_val =
        headpagesection3(rpt_render),
        _bcontheadpagesection2 = 0, dummy_val = headpagesection2(rpt_render,((rptreport->m_pageheight
          - rptreport->m_marginbottom) - _yoffset),_bcontheadpagesection2)
       ENDIF
       personage = (datetimediff(cnvtdatetime(sysdate),p.birth_dt_tm,1)/ 365.25)
      ENDIF
     HEAD p.person_id
      bfound = 0
      IF (age_qual != "1=1")
       IF (parser(age_qual))
        bfound = 1
       ELSE
        bfound = 0
       ENDIF
      ELSE
       bfound = 1
      ENDIF
      IF (bfound=1)
       patient_cnt += 1
       IF ((eksctrequest->opsind < 1)
        AND testonly=0)
        tmp_name = concat(trim(p.name_last),", ",trim(p.name_first)," (",trim(cnvtstring(e.person_id)
          ),
         ")"), tmp_sex = trim(uar_get_code_display(p.sex_cd)), tmp_age = trim(cnvtage(p.birth_dt_tm),
         3),
        tmp_race = trim(uar_get_code_display(p.race_cd))
        IF (dxcodecnt=0)
         tmp_encntr = concat(trim(uar_get_code_display(e.encntr_type_cd))," (",trim(cnvtstring(e
            .encntr_id)),")"), tmp_reg_dt_tm = format(e.reg_dt_tm,"@MEDIUMDATETIME"), tmp_facility =
         trim(uar_get_code_display(e.loc_facility_cd))
        ENDIF
        _bcontheadp_person_idsection = 0, bfirsttime = 1
        WHILE (((_bcontheadp_person_idsection=1) OR (bfirsttime=1)) )
          _bholdcontinue = _bcontheadp_person_idsection, _fdrawheight = headp_person_idsection(
           rpt_calcheight,(_fenddetail - _yoffset),_bholdcontinue)
          IF (((_bholdcontinue=1) OR (_fdrawheight > 0)) )
           IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
            _bholdcontinue = 0, _fdrawheight += headp_person_idsection1(rpt_calcheight,((_fenddetail
              - _yoffset) - _fdrawheight),_bholdcontinue)
            IF (_bholdcontinue=1)
             _fdrawheight = (_fenddetail+ 1)
            ENDIF
           ENDIF
          ENDIF
          IF (((_yoffset+ _fdrawheight) > _fenddetail))
           BREAK
          ELSEIF (_bholdcontinue=1
           AND _bcontheadp_person_idsection=0)
           BREAK
          ENDIF
          dummy_val = headp_person_idsection(rpt_render,(_fenddetail - _yoffset),
           _bcontheadp_person_idsection), bfirsttime = 0
        ENDWHILE
        _bcontheadp_person_idsection1 = 0, bfirsttime = 1
        WHILE (((_bcontheadp_person_idsection1=1) OR (bfirsttime=1)) )
          _bholdcontinue = _bcontheadp_person_idsection1, _fdrawheight = headp_person_idsection1(
           rpt_calcheight,(_fenddetail - _yoffset),_bholdcontinue)
          IF (((_yoffset+ _fdrawheight) > _fenddetail))
           BREAK
          ELSEIF (_bholdcontinue=1
           AND _bcontheadp_person_idsection1=0)
           BREAK
          ENDIF
          dummy_val = headp_person_idsection1(rpt_render,(_fenddetail - _yoffset),
           _bcontheadp_person_idsection1), bfirsttime = 0
        ENDWHILE
       ENDIF
      ENDIF
     DETAIL
      row + 0
     FOOT  p.person_id
      row + 0
     FOOT PAGE
      _yhold = _yoffset, _yoffset = _fenddetail, _bcontfootpagesection = 0,
      dummy_val = footpagesection(rpt_render,((rptreport->m_pageheight - rptreport->m_marginbottom)
        - _yoffset),_bcontfootpagesection), _yoffset = _yhold
     FOOT REPORT
      IF ((eksctrequest->opsind > 0))
       tmp_total = uar_i18nbuildmessage(i18nhandle,"TOTAL_OPS_PRESCREEN_RPT",
        "Total of %1 patient(s) found from %2 to %3 will be evaluated for this screening job.",
        "iss",patient_cnt,
        trim(format(startdttm,"@LONGDATE"),3),trim(format(enddttm,"@LONGDATE"),3)),
       _bcontfootreportsection2 = 0, bfirsttime = 1
       WHILE (((_bcontfootreportsection2=1) OR (bfirsttime=1)) )
         _bholdcontinue = _bcontfootreportsection2, _fdrawheight = footreportsection2(rpt_calcheight,
          (_fenddetail - _yoffset),_bholdcontinue)
         IF (((_bholdcontinue=1) OR (_fdrawheight > 0)) )
          IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
           _fdrawheight += footreportsection3(rpt_calcheight)
          ENDIF
         ENDIF
         IF (((_yoffset+ _fdrawheight) > _fenddetail))
          CALL pagebreak(0)
         ELSEIF (_bholdcontinue=1
          AND _bcontfootreportsection2=0)
          CALL pagebreak(0)
         ENDIF
         dummy_val = footreportsection2(rpt_render,(_fenddetail - _yoffset),_bcontfootreportsection2),
         bfirsttime = 0
       ENDWHILE
       _fdrawheight = footreportsection3(rpt_calcheight)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        CALL pagebreak(0)
       ENDIF
       dummy_val = footreportsection3(rpt_render)
      ENDIF
     WITH nocounter, separator = " ", format
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE (finalizereport(ssendreport=vc) =null WITH protect)
   IF (_bsubreport=0)
    SET _rptpage = uar_rptendpage(_hreport)
    SET _rptstat = uar_rptendreport(_hreport)
    DECLARE sfilename = vc WITH noconstant(trim(ssendreport)), private
    DECLARE bprint = i2 WITH noconstant(0), private
    IF (textlen(sfilename) > 0)
     SET bprint = checkqueue(sfilename)
     IF (bprint)
      EXECUTE cpm_create_file_name "RPT", "PS"
      SET sfilename = cpm_cfn_info->file_name_path
     ENDIF
    ENDIF
    SET _rptstat = uar_rptprinttofile(_hreport,nullterm(sfilename))
    IF (bprint)
     SET spool value(sfilename) value(ssendreport) WITH deleted, dio = value(_diotype)
    ENDIF
    DECLARE _errorfound = i2 WITH noconstant(0), protect
    DECLARE _errcnt = i2 WITH noconstant(0), protect
    SET _errorfound = uar_rptfirsterror(_hreport,rpterror)
    WHILE (_errorfound=rpt_errorfound
     AND _errcnt < 512)
      SET _errcnt += 1
      SET stat = alterlist(rpterrors->errors,_errcnt)
      SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
      SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
      SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
      SET _errorfound = uar_rptnexterror(_hreport,rpterror)
    ENDWHILE
    SET _rptstat = uar_rptdestroyreport(_hreport)
   ENDIF
 END ;Subroutine
 SUBROUTINE (headpagesection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.700000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_rpt_pt_inquiry_rpt = f8 WITH noconstant(0.0), private
   DECLARE drawheight_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_total = f8 WITH noconstant(0.0), private
   DECLARE __label_rpt_pt_inquiry_rpt = vc WITH noconstant(build2(uar_i18ngetmessage(i18nhandle,
      "PT_INQUIRY_RPT","Patient Inquiry Report"),char(0))), protect
   DECLARE __date = vc WITH noconstant(build2(trim(datestr,3),char(0))), protect
   SET tmp_total = uar_i18nbuildmessage(i18nhandle,"TOTAL_OPS_PRESCREEN_RPT",
    "Total of %1 patient(s) found from %2 to %3 will be evaluated for this screening job.","iss",
    cnt,
    trim(format(startdttm,"@LONGDATE;t(3);q"),3),trim(format(enddttm,"@LONGDATE;t(3);q"),3))
   DECLARE __label_total = vc WITH noconstant(build2(tmp_total,char(0))), protect
   IF (bcontinue=0)
    SET _remlabel_rpt_pt_inquiry_rpt = 1
    SET _remdate = 1
    SET _remlabel_total = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier12b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlabel_rpt_pt_inquiry_rpt = _remlabel_rpt_pt_inquiry_rpt
   IF (_remlabel_rpt_pt_inquiry_rpt > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _remlabel_rpt_pt_inquiry_rpt,((size(__label_rpt_pt_inquiry_rpt) - _remlabel_rpt_pt_inquiry_rpt
       )+ 1),__label_rpt_pt_inquiry_rpt)))
    SET drawheight_label_rpt_pt_inquiry_rpt = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_rpt_pt_inquiry_rpt = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_rpt_pt_inquiry_rpt,((size(
        __label_rpt_pt_inquiry_rpt) - _remlabel_rpt_pt_inquiry_rpt)+ 1),__label_rpt_pt_inquiry_rpt)))
    ))
     SET _remlabel_rpt_pt_inquiry_rpt += rptsd->m_drawlength
    ELSE
     SET _remlabel_rpt_pt_inquiry_rpt = 0
    ENDIF
    SET growsum += _remlabel_rpt_pt_inquiry_rpt
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.260)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_courier100)
   SET _holdremdate = _remdate
   IF (_remdate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdate,((size(__date) -
       _remdate)+ 1),__date)))
    SET drawheight_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdate = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdate,((size(__date) - _remdate)+ 1),
       __date)))))
     SET _remdate += rptsd->m_drawlength
    ELSE
     SET _remdate = 0
    ENDIF
    SET growsum += _remdate
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.558)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_courier8b0)
   SET _holdremlabel_total = _remlabel_total
   IF (_remlabel_total > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_total,((size(
        __label_total) - _remlabel_total)+ 1),__label_total)))
    SET drawheight_label_total = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_total = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_total,((size(__label_total) -
       _remlabel_total)+ 1),__label_total)))))
     SET _remlabel_total += rptsd->m_drawlength
    ELSE
     SET _remlabel_total = 0
    ENDIF
    SET growsum += _remlabel_total
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = drawheight_label_rpt_pt_inquiry_rpt
   SET _dummyfont = uar_rptsetfont(_hreport,_courier12b0)
   IF (ncalc=rpt_render
    AND _holdremlabel_rpt_pt_inquiry_rpt > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_rpt_pt_inquiry_rpt,((size(__label_rpt_pt_inquiry_rpt) -
       _holdremlabel_rpt_pt_inquiry_rpt)+ 1),__label_rpt_pt_inquiry_rpt)))
   ELSE
    SET _remlabel_rpt_pt_inquiry_rpt = _holdremlabel_rpt_pt_inquiry_rpt
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.260)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = drawheight_date
   SET _dummyfont = uar_rptsetfont(_hreport,_courier100)
   IF (ncalc=rpt_render
    AND _holdremdate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdate,((size(__date
        ) - _holdremdate)+ 1),__date)))
   ELSE
    SET _remdate = _holdremdate
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.500)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = drawheight_label_total
   SET _dummyfont = uar_rptsetfont(_hreport,_courier8b0)
   IF (ncalc=rpt_render
    AND _holdremlabel_total > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_total,((size
       (__label_total) - _holdremlabel_total)+ 1),__label_total)))
   ELSE
    SET _remlabel_total = _holdremlabel_total
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headpagesection1(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesection1abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpagesection1abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_rpt_atient = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_rpt_encounter = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_rpt_gender = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_rpt_age = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_rpt_reg_dt = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_rpt_race = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_rpt_facility = f8 WITH noconstant(0.0), private
   DECLARE __label_rpt_atient = vc WITH noconstant(build2(rpt_patient,char(0))), protect
   DECLARE __label_rpt_encounter = vc WITH noconstant(build2(rpt_encounter,char(0))), protect
   DECLARE __label_rpt_gender = vc WITH noconstant(build2(rpt_gender,char(0))), protect
   DECLARE __label_rpt_age = vc WITH noconstant(build2(rpt_age,char(0))), protect
   DECLARE __label_rpt_reg_dt = vc WITH noconstant(build2(rpt_reg_dt,char(0))), protect
   DECLARE __label_rpt_race = vc WITH noconstant(build2(rpt_race,char(0))), protect
   DECLARE __label_rpt_facility = vc WITH noconstant(build2(rpt_facility,char(0))), protect
   IF ( NOT (dxcodecnt=0))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _remlabel_rpt_atient = 1
    SET _remlabel_rpt_encounter = 1
    SET _remlabel_rpt_gender = 1
    SET _remlabel_rpt_age = 1
    SET _remlabel_rpt_reg_dt = 1
    SET _remlabel_rpt_race = 1
    SET _remlabel_rpt_facility = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlabel_rpt_atient = _remlabel_rpt_atient
   IF (_remlabel_rpt_atient > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_rpt_atient,((
       size(__label_rpt_atient) - _remlabel_rpt_atient)+ 1),__label_rpt_atient)))
    SET drawheight_label_rpt_atient = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_rpt_atient = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_rpt_atient,((size(
        __label_rpt_atient) - _remlabel_rpt_atient)+ 1),__label_rpt_atient)))))
     SET _remlabel_rpt_atient += rptsd->m_drawlength
    ELSE
     SET _remlabel_rpt_atient = 0
    ENDIF
    SET growsum += _remlabel_rpt_atient
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.250)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_rpt_encounter = _remlabel_rpt_encounter
   IF (_remlabel_rpt_encounter > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_rpt_encounter,((
       size(__label_rpt_encounter) - _remlabel_rpt_encounter)+ 1),__label_rpt_encounter)))
    SET drawheight_label_rpt_encounter = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_rpt_encounter = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_rpt_encounter,((size(
        __label_rpt_encounter) - _remlabel_rpt_encounter)+ 1),__label_rpt_encounter)))))
     SET _remlabel_rpt_encounter += rptsd->m_drawlength
    ELSE
     SET _remlabel_rpt_encounter = 0
    ENDIF
    SET growsum += _remlabel_rpt_encounter
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.500)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_rpt_gender = _remlabel_rpt_gender
   IF (_remlabel_rpt_gender > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_rpt_gender,((
       size(__label_rpt_gender) - _remlabel_rpt_gender)+ 1),__label_rpt_gender)))
    SET drawheight_label_rpt_gender = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_rpt_gender = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_rpt_gender,((size(
        __label_rpt_gender) - _remlabel_rpt_gender)+ 1),__label_rpt_gender)))))
     SET _remlabel_rpt_gender += rptsd->m_drawlength
    ELSE
     SET _remlabel_rpt_gender = 0
    ENDIF
    SET growsum += _remlabel_rpt_gender
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.375)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_rpt_age = _remlabel_rpt_age
   IF (_remlabel_rpt_age > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_rpt_age,((size(
        __label_rpt_age) - _remlabel_rpt_age)+ 1),__label_rpt_age)))
    SET drawheight_label_rpt_age = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_rpt_age = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_rpt_age,((size(__label_rpt_age)
        - _remlabel_rpt_age)+ 1),__label_rpt_age)))))
     SET _remlabel_rpt_age += rptsd->m_drawlength
    ELSE
     SET _remlabel_rpt_age = 0
    ENDIF
    SET growsum += _remlabel_rpt_age
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.250)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_rpt_reg_dt = _remlabel_rpt_reg_dt
   IF (_remlabel_rpt_reg_dt > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_rpt_reg_dt,((
       size(__label_rpt_reg_dt) - _remlabel_rpt_reg_dt)+ 1),__label_rpt_reg_dt)))
    SET drawheight_label_rpt_reg_dt = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_rpt_reg_dt = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_rpt_reg_dt,((size(
        __label_rpt_reg_dt) - _remlabel_rpt_reg_dt)+ 1),__label_rpt_reg_dt)))))
     SET _remlabel_rpt_reg_dt += rptsd->m_drawlength
    ELSE
     SET _remlabel_rpt_reg_dt = 0
    ENDIF
    SET growsum += _remlabel_rpt_reg_dt
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.875)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_rpt_race = _remlabel_rpt_race
   IF (_remlabel_rpt_race > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_rpt_race,((size(
        __label_rpt_race) - _remlabel_rpt_race)+ 1),__label_rpt_race)))
    SET drawheight_label_rpt_race = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_rpt_race = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_rpt_race,((size(__label_rpt_race
        ) - _remlabel_rpt_race)+ 1),__label_rpt_race)))))
     SET _remlabel_rpt_race += rptsd->m_drawlength
    ELSE
     SET _remlabel_rpt_race = 0
    ENDIF
    SET growsum += _remlabel_rpt_race
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.000)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_rpt_facility = _remlabel_rpt_facility
   IF (_remlabel_rpt_facility > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_rpt_facility,((
       size(__label_rpt_facility) - _remlabel_rpt_facility)+ 1),__label_rpt_facility)))
    SET drawheight_label_rpt_facility = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_rpt_facility = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_rpt_facility,((size(
        __label_rpt_facility) - _remlabel_rpt_facility)+ 1),__label_rpt_facility)))))
     SET _remlabel_rpt_facility += rptsd->m_drawlength
    ELSE
     SET _remlabel_rpt_facility = 0
    ENDIF
    SET growsum += _remlabel_rpt_facility
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s3c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.095),(offsetx+ 8.000),(offsety+
     0.095))
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.156),(offsetx+ 8.000),(offsety+
     0.156))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = drawheight_label_rpt_atient
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND _holdremlabel_rpt_atient > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_rpt_atient,(
       (size(__label_rpt_atient) - _holdremlabel_rpt_atient)+ 1),__label_rpt_atient)))
   ELSE
    SET _remlabel_rpt_atient = _holdremlabel_rpt_atient
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.250)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = drawheight_label_rpt_encounter
   IF (ncalc=rpt_render
    AND _holdremlabel_rpt_encounter > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdremlabel_rpt_encounter,((size(__label_rpt_encounter) - _holdremlabel_rpt_encounter)+ 1),
       __label_rpt_encounter)))
   ELSE
    SET _remlabel_rpt_encounter = _holdremlabel_rpt_encounter
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.500)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = drawheight_label_rpt_gender
   IF (ncalc=rpt_render
    AND _holdremlabel_rpt_gender > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_rpt_gender,(
       (size(__label_rpt_gender) - _holdremlabel_rpt_gender)+ 1),__label_rpt_gender)))
   ELSE
    SET _remlabel_rpt_gender = _holdremlabel_rpt_gender
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.375)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = drawheight_label_rpt_age
   IF (ncalc=rpt_render
    AND _holdremlabel_rpt_age > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_rpt_age,((
       size(__label_rpt_age) - _holdremlabel_rpt_age)+ 1),__label_rpt_age)))
   ELSE
    SET _remlabel_rpt_age = _holdremlabel_rpt_age
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.250)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_label_rpt_reg_dt
   IF (ncalc=rpt_render
    AND _holdremlabel_rpt_reg_dt > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_rpt_reg_dt,(
       (size(__label_rpt_reg_dt) - _holdremlabel_rpt_reg_dt)+ 1),__label_rpt_reg_dt)))
   ELSE
    SET _remlabel_rpt_reg_dt = _holdremlabel_rpt_reg_dt
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.875)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = drawheight_label_rpt_race
   IF (ncalc=rpt_render
    AND _holdremlabel_rpt_race > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_rpt_race,((
       size(__label_rpt_race) - _holdremlabel_rpt_race)+ 1),__label_rpt_race)))
   ELSE
    SET _remlabel_rpt_race = _holdremlabel_rpt_race
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.000)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = drawheight_label_rpt_facility
   IF (ncalc=rpt_render
    AND _holdremlabel_rpt_facility > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_rpt_facility,
       ((size(__label_rpt_facility) - _holdremlabel_rpt_facility)+ 1),__label_rpt_facility)))
   ELSE
    SET _remlabel_rpt_facility = _holdremlabel_rpt_facility
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headpagesection2(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesection2abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpagesection2abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_rpt_atient = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_rpt_gender = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_rpt_age = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_rpt_race = f8 WITH noconstant(0.0), private
   DECLARE __label_rpt_atient = vc WITH noconstant(build2(rpt_patient,char(0))), protect
   DECLARE __label_rpt_gender = vc WITH noconstant(build2(rpt_gender,char(0))), protect
   DECLARE __label_rpt_age = vc WITH noconstant(build2(rpt_age,char(0))), protect
   DECLARE __label_rpt_race = vc WITH noconstant(build2(rpt_race,char(0))), protect
   IF ( NOT (dxcodecnt != 0))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _remlabel_rpt_atient = 1
    SET _remlabel_rpt_gender = 1
    SET _remlabel_rpt_age = 1
    SET _remlabel_rpt_race = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlabel_rpt_atient = _remlabel_rpt_atient
   IF (_remlabel_rpt_atient > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_rpt_atient,((
       size(__label_rpt_atient) - _remlabel_rpt_atient)+ 1),__label_rpt_atient)))
    SET drawheight_label_rpt_atient = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_rpt_atient = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_rpt_atient,((size(
        __label_rpt_atient) - _remlabel_rpt_atient)+ 1),__label_rpt_atient)))))
     SET _remlabel_rpt_atient += rptsd->m_drawlength
    ELSE
     SET _remlabel_rpt_atient = 0
    ENDIF
    SET growsum += _remlabel_rpt_atient
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.000)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_rpt_gender = _remlabel_rpt_gender
   IF (_remlabel_rpt_gender > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_rpt_gender,((
       size(__label_rpt_gender) - _remlabel_rpt_gender)+ 1),__label_rpt_gender)))
    SET drawheight_label_rpt_gender = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_rpt_gender = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_rpt_gender,((size(
        __label_rpt_gender) - _remlabel_rpt_gender)+ 1),__label_rpt_gender)))))
     SET _remlabel_rpt_gender += rptsd->m_drawlength
    ELSE
     SET _remlabel_rpt_gender = 0
    ENDIF
    SET growsum += _remlabel_rpt_gender
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.250)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_rpt_age = _remlabel_rpt_age
   IF (_remlabel_rpt_age > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_rpt_age,((size(
        __label_rpt_age) - _remlabel_rpt_age)+ 1),__label_rpt_age)))
    SET drawheight_label_rpt_age = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_rpt_age = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_rpt_age,((size(__label_rpt_age)
        - _remlabel_rpt_age)+ 1),__label_rpt_age)))))
     SET _remlabel_rpt_age += rptsd->m_drawlength
    ELSE
     SET _remlabel_rpt_age = 0
    ENDIF
    SET growsum += _remlabel_rpt_age
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.750)
   SET rptsd->m_width = 2.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlabel_rpt_race = _remlabel_rpt_race
   IF (_remlabel_rpt_race > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_rpt_race,((size(
        __label_rpt_race) - _remlabel_rpt_race)+ 1),__label_rpt_race)))
    SET drawheight_label_rpt_race = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_rpt_race = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_rpt_race,((size(__label_rpt_race
        ) - _remlabel_rpt_race)+ 1),__label_rpt_race)))))
     SET _remlabel_rpt_race += rptsd->m_drawlength
    ELSE
     SET _remlabel_rpt_race = 0
    ENDIF
    SET growsum += _remlabel_rpt_race
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s3c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.095),(offsetx+ 8.000),(offsety+
     0.095))
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.156),(offsetx+ 8.000),(offsety+
     0.156))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = drawheight_label_rpt_atient
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND _holdremlabel_rpt_atient > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_rpt_atient,(
       (size(__label_rpt_atient) - _holdremlabel_rpt_atient)+ 1),__label_rpt_atient)))
   ELSE
    SET _remlabel_rpt_atient = _holdremlabel_rpt_atient
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.000)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = drawheight_label_rpt_gender
   IF (ncalc=rpt_render
    AND _holdremlabel_rpt_gender > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_rpt_gender,(
       (size(__label_rpt_gender) - _holdremlabel_rpt_gender)+ 1),__label_rpt_gender)))
   ELSE
    SET _remlabel_rpt_gender = _holdremlabel_rpt_gender
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.250)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_label_rpt_age
   IF (ncalc=rpt_render
    AND _holdremlabel_rpt_age > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_rpt_age,((
       size(__label_rpt_age) - _holdremlabel_rpt_age)+ 1),__label_rpt_age)))
   ELSE
    SET _remlabel_rpt_age = _holdremlabel_rpt_age
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.750)
   SET rptsd->m_width = 2.250
   SET rptsd->m_height = drawheight_label_rpt_race
   IF (ncalc=rpt_render
    AND _holdremlabel_rpt_race > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_rpt_race,((
       size(__label_rpt_race) - _holdremlabel_rpt_race)+ 1),__label_rpt_race)))
   ELSE
    SET _remlabel_rpt_race = _holdremlabel_rpt_race
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headpagesection3(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesection3abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpagesection3abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s3c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.032),(offsetx+ 8.000),(offsety+
     0.032))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.095),(offsetx+ 8.000),(offsety+
     0.095))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headp_person_idsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headp_person_idsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headp_person_idsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)
  ) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_name = f8 WITH noconstant(0.0), private
   DECLARE drawheight_encounter = f8 WITH noconstant(0.0), private
   DECLARE drawheight_gender = f8 WITH noconstant(0.0), private
   DECLARE drawheight_age = f8 WITH noconstant(0.0), private
   DECLARE drawheight_reg_dt_tm = f8 WITH noconstant(0.0), private
   DECLARE drawheight_facility = f8 WITH noconstant(0.0), private
   DECLARE drawheight_race = f8 WITH noconstant(0.0), private
   DECLARE __name = vc WITH noconstant(build2(tmp_name,char(0))), protect
   DECLARE __encounter = vc WITH noconstant(build2(tmp_encntr,char(0))), protect
   DECLARE __gender = vc WITH noconstant(build2(tmp_sex,char(0))), protect
   DECLARE __age = vc WITH noconstant(build2(tmp_age,char(0))), protect
   DECLARE __reg_dt_tm = vc WITH noconstant(build2(tmp_reg_dt_tm,char(0))), protect
   DECLARE __facility = vc WITH noconstant(build2(tmp_facility,char(0))), protect
   DECLARE __race = vc WITH noconstant(build2(tmp_race,char(0))), protect
   IF ( NOT (dxcodecnt=0))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _remname = 1
    SET _remencounter = 1
    SET _remgender = 1
    SET _remage = 1
    SET _remreg_dt_tm = 1
    SET _remfacility = 1
    SET _remrace = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremname = _remname
   IF (_remname > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remname,((size(__name) -
       _remname)+ 1),__name)))
    SET drawheight_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remname = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remname,((size(__name) - _remname)+ 1),
       __name)))))
     SET _remname += rptsd->m_drawlength
    ELSE
     SET _remname = 0
    ENDIF
    SET growsum += _remname
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.250)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremencounter = _remencounter
   IF (_remencounter > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remencounter,((size(
        __encounter) - _remencounter)+ 1),__encounter)))
    SET drawheight_encounter = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remencounter = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remencounter,((size(__encounter) -
       _remencounter)+ 1),__encounter)))))
     SET _remencounter += rptsd->m_drawlength
    ELSE
     SET _remencounter = 0
    ENDIF
    SET growsum += _remencounter
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.500)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremgender = _remgender
   IF (_remgender > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remgender,((size(__gender
        ) - _remgender)+ 1),__gender)))
    SET drawheight_gender = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remgender = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remgender,((size(__gender) - _remgender)
       + 1),__gender)))))
     SET _remgender += rptsd->m_drawlength
    ELSE
     SET _remgender = 0
    ENDIF
    SET growsum += _remgender
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.375)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremage = _remage
   IF (_remage > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remage,((size(__age) -
       _remage)+ 1),__age)))
    SET drawheight_age = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remage = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remage,((size(__age) - _remage)+ 1),__age
       )))))
     SET _remage += rptsd->m_drawlength
    ELSE
     SET _remage = 0
    ENDIF
    SET growsum += _remage
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.250)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremreg_dt_tm = _remreg_dt_tm
   IF (_remreg_dt_tm > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remreg_dt_tm,((size(
        __reg_dt_tm) - _remreg_dt_tm)+ 1),__reg_dt_tm)))
    SET drawheight_reg_dt_tm = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remreg_dt_tm = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remreg_dt_tm,((size(__reg_dt_tm) -
       _remreg_dt_tm)+ 1),__reg_dt_tm)))))
     SET _remreg_dt_tm += rptsd->m_drawlength
    ELSE
     SET _remreg_dt_tm = 0
    ENDIF
    SET growsum += _remreg_dt_tm
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.000)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfacility = _remfacility
   IF (_remfacility > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfacility,((size(
        __facility) - _remfacility)+ 1),__facility)))
    SET drawheight_facility = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfacility = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfacility,((size(__facility) -
       _remfacility)+ 1),__facility)))))
     SET _remfacility += rptsd->m_drawlength
    ELSE
     SET _remfacility = 0
    ENDIF
    SET growsum += _remfacility
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.875)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremrace = _remrace
   IF (_remrace > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remrace,((size(__race) -
       _remrace)+ 1),__race)))
    SET drawheight_race = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remrace = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remrace,((size(__race) - _remrace)+ 1),
       __race)))))
     SET _remrace += rptsd->m_drawlength
    ELSE
     SET _remrace = 0
    ENDIF
    SET growsum += _remrace
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = drawheight_name
   IF (ncalc=rpt_render
    AND _holdremname > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremname,((size(__name
        ) - _holdremname)+ 1),__name)))
   ELSE
    SET _remname = _holdremname
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.250)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = drawheight_encounter
   IF (ncalc=rpt_render
    AND _holdremencounter > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremencounter,((size(
        __encounter) - _holdremencounter)+ 1),__encounter)))
   ELSE
    SET _remencounter = _holdremencounter
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.500)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = drawheight_gender
   IF (ncalc=rpt_render
    AND _holdremgender > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremgender,((size(
        __gender) - _holdremgender)+ 1),__gender)))
   ELSE
    SET _remgender = _holdremgender
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.375)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = drawheight_age
   IF (ncalc=rpt_render
    AND _holdremage > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremage,((size(__age)
        - _holdremage)+ 1),__age)))
   ELSE
    SET _remage = _holdremage
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.250)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_reg_dt_tm
   IF (ncalc=rpt_render
    AND _holdremreg_dt_tm > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremreg_dt_tm,((size(
        __reg_dt_tm) - _holdremreg_dt_tm)+ 1),__reg_dt_tm)))
   ELSE
    SET _remreg_dt_tm = _holdremreg_dt_tm
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.000)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = drawheight_facility
   IF (ncalc=rpt_render
    AND _holdremfacility > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfacility,((size(
        __facility) - _holdremfacility)+ 1),__facility)))
   ELSE
    SET _remfacility = _holdremfacility
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.875)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = drawheight_race
   IF (ncalc=rpt_render
    AND _holdremrace > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremrace,((size(__race
        ) - _holdremrace)+ 1),__race)))
   ELSE
    SET _remrace = _holdremrace
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headp_person_idsection1(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headp_person_idsection1abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headp_person_idsection1abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)
  ) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_name = f8 WITH noconstant(0.0), private
   DECLARE drawheight_gender = f8 WITH noconstant(0.0), private
   DECLARE drawheight_age = f8 WITH noconstant(0.0), private
   DECLARE drawheight_race = f8 WITH noconstant(0.0), private
   DECLARE __name = vc WITH noconstant(build2(tmp_name,char(0))), protect
   DECLARE __gender = vc WITH noconstant(build2(tmp_sex,char(0))), protect
   DECLARE __age = vc WITH noconstant(build2(tmp_age,char(0))), protect
   DECLARE __race = vc WITH noconstant(build2(tmp_race,char(0))), protect
   IF ( NOT (dxcodecnt != 0))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _remname = 1
    SET _remgender = 1
    SET _remage = 1
    SET _remrace = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremname = _remname
   IF (_remname > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remname,((size(__name) -
       _remname)+ 1),__name)))
    SET drawheight_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remname = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remname,((size(__name) - _remname)+ 1),
       __name)))))
     SET _remname += rptsd->m_drawlength
    ELSE
     SET _remname = 0
    ENDIF
    SET growsum += _remname
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.000)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremgender = _remgender
   IF (_remgender > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remgender,((size(__gender
        ) - _remgender)+ 1),__gender)))
    SET drawheight_gender = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remgender = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remgender,((size(__gender) - _remgender)
       + 1),__gender)))))
     SET _remgender += rptsd->m_drawlength
    ELSE
     SET _remgender = 0
    ENDIF
    SET growsum += _remgender
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.250)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremage = _remage
   IF (_remage > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remage,((size(__age) -
       _remage)+ 1),__age)))
    SET drawheight_age = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remage = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remage,((size(__age) - _remage)+ 1),__age
       )))))
     SET _remage += rptsd->m_drawlength
    ELSE
     SET _remage = 0
    ENDIF
    SET growsum += _remage
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.750)
   SET rptsd->m_width = 2.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremrace = _remrace
   IF (_remrace > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remrace,((size(__race) -
       _remrace)+ 1),__race)))
    SET drawheight_race = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remrace = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remrace,((size(__race) - _remrace)+ 1),
       __race)))))
     SET _remrace += rptsd->m_drawlength
    ELSE
     SET _remrace = 0
    ENDIF
    SET growsum += _remrace
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = drawheight_name
   IF (ncalc=rpt_render
    AND _holdremname > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremname,((size(__name
        ) - _holdremname)+ 1),__name)))
   ELSE
    SET _remname = _holdremname
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.000)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = drawheight_gender
   IF (ncalc=rpt_render
    AND _holdremgender > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremgender,((size(
        __gender) - _holdremgender)+ 1),__gender)))
   ELSE
    SET _remgender = _holdremgender
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.250)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_age
   IF (ncalc=rpt_render
    AND _holdremage > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremage,((size(__age)
        - _holdremage)+ 1),__age)))
   ELSE
    SET _remage = _holdremage
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.750)
   SET rptsd->m_width = 2.250
   SET rptsd->m_height = drawheight_race
   IF (ncalc=rpt_render
    AND _holdremrace > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremrace,((size(__race
        ) - _holdremrace)+ 1),__race)))
   ELSE
    SET _remrace = _holdremrace
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (footpagesection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footpagesectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_rpt_page = f8 WITH noconstant(0.0), private
   DECLARE __label_rpt_page = vc WITH noconstant(build2(uar_i18nbuildmessage(i18nhandle,
      "PAGE_PRESCREEN_RPT","Page: %1","i",curpage),char(0))), protect
   IF (bcontinue=0)
    SET _remlabel_rpt_page = 1
   ENDIF
   SET rptsd->m_flags = 21
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier70)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlabel_rpt_page = _remlabel_rpt_page
   IF (_remlabel_rpt_page > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_rpt_page,((size(
        __label_rpt_page) - _remlabel_rpt_page)+ 1),__label_rpt_page)))
    SET drawheight_label_rpt_page = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_rpt_page = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_rpt_page,((size(__label_rpt_page
        ) - _remlabel_rpt_page)+ 1),__label_rpt_page)))))
     SET _remlabel_rpt_page += rptsd->m_drawlength
    ELSE
     SET _remlabel_rpt_page = 0
    ENDIF
    SET growsum += _remlabel_rpt_page
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = drawheight_label_rpt_page
   IF (ncalc=rpt_render
    AND _holdremlabel_rpt_page > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_rpt_page,((
       size(__label_rpt_page) - _holdremlabel_rpt_page)+ 1),__label_rpt_page)))
   ELSE
    SET _remlabel_rpt_page = _holdremlabel_rpt_page
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (footreportsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footreportsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_total = f8 WITH noconstant(0.0), private
   DECLARE __label_total = vc WITH noconstant(build2(tmp_total,char(0))), protect
   IF (bcontinue=0)
    SET _remlabel_total = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier8b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlabel_total = _remlabel_total
   IF (_remlabel_total > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_total,((size(
        __label_total) - _remlabel_total)+ 1),__label_total)))
    SET drawheight_label_total = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_total = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_total,((size(__label_total) -
       _remlabel_total)+ 1),__label_total)))))
     SET _remlabel_total += rptsd->m_drawlength
    ELSE
     SET _remlabel_total = 0
    ENDIF
    SET growsum += _remlabel_total
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s3c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.156),(offsetx+ 8.000),(offsety+
     0.156))
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.219),(offsetx+ 8.000),(offsety+
     0.219))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = drawheight_label_total
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND _holdremlabel_total > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_total,((size
       (__label_total) - _holdremlabel_total)+ 1),__label_total)))
   ELSE
    SET _remlabel_total = _holdremlabel_total
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (footreportsection1(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footreportsection1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footreportsection1abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s3c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.032),(offsetx+ 8.000),(offsety+
     0.032))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.095),(offsetx+ 8.000),(offsety+
     0.095))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (footreportsection2(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footreportsection2abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footreportsection2abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
   WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(1.000000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_title = f8 WITH noconstant(0.0), private
   DECLARE drawheight_date = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_total = f8 WITH noconstant(0.0), private
   DECLARE __label_title = vc WITH noconstant(build2(title,char(0))), protect
   DECLARE __date = vc WITH noconstant(build2(trim(datestr),char(0))), protect
   DECLARE __label_total = vc WITH noconstant(build2(tmp_total,char(0))), protect
   IF (bcontinue=0)
    SET _remlabel_title = 1
    SET _remdate = 1
    SET _remlabel_total = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier12b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlabel_title = _remlabel_title
   IF (_remlabel_title > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_title,((size(
        __label_title) - _remlabel_title)+ 1),__label_title)))
    SET drawheight_label_title = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_title = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_title,((size(__label_title) -
       _remlabel_title)+ 1),__label_title)))))
     SET _remlabel_title += rptsd->m_drawlength
    ELSE
     SET _remlabel_title = 0
    ENDIF
    SET growsum += _remlabel_title
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.260)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_courier100)
   SET _holdremdate = _remdate
   IF (_remdate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdate,((size(__date) -
       _remdate)+ 1),__date)))
    SET drawheight_date = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdate = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdate,((size(__date) - _remdate)+ 1),
       __date)))))
     SET _remdate += rptsd->m_drawlength
    ELSE
     SET _remdate = 0
    ENDIF
    SET growsum += _remdate
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_courier8b0)
   SET _holdremlabel_total = _remlabel_total
   IF (_remlabel_total > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_total,((size(
        __label_total) - _remlabel_total)+ 1),__label_total)))
    SET drawheight_label_total = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_total = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_total,((size(__label_total) -
       _remlabel_total)+ 1),__label_total)))))
     SET _remlabel_total += rptsd->m_drawlength
    ELSE
     SET _remlabel_total = 0
    ENDIF
    SET growsum += _remlabel_total
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s3c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.656),(offsetx+ 8.000),(offsety+
     0.656))
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.720),(offsetx+ 8.000),(offsety+
     0.720))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = drawheight_label_title
   SET _dummyfont = uar_rptsetfont(_hreport,_courier12b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND _holdremlabel_title > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_title,((size
       (__label_title) - _holdremlabel_title)+ 1),__label_title)))
   ELSE
    SET _remlabel_title = _holdremlabel_title
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.260)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = drawheight_date
   SET _dummyfont = uar_rptsetfont(_hreport,_courier100)
   IF (ncalc=rpt_render
    AND _holdremdate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdate,((size(__date
        ) - _holdremdate)+ 1),__date)))
   ELSE
    SET _remdate = _holdremdate
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = drawheight_label_total
   SET _dummyfont = uar_rptsetfont(_hreport,_courier8b0)
   IF (ncalc=rpt_render
    AND _holdremlabel_total > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_total,((size
       (__label_total) - _holdremlabel_total)+ 1),__label_total)))
   ELSE
    SET _remlabel_total = _holdremlabel_total
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (footreportsection3(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footreportsection3abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footreportsection3abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s3c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.032),(offsetx+ 8.000),(offsety+
     0.032))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.095),(offsetx+ 8.000),(offsety+
     0.095))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   IF (_bsubreport=0)
    SET rptreport->m_recsize = 104
    SET rptreport->m_reportname = "CT_SUB_RPT_PRESCREEN_DX_PT"
    SET rptreport->m_pagewidth = 8.50
    SET rptreport->m_pageheight = 11.00
    SET rptreport->m_orientation = rpt_portrait
    SET rptreport->m_marginleft = 0.25
    SET rptreport->m_marginright = 0.25
    SET rptreport->m_margintop = 0.25
    SET rptreport->m_marginbottom = 0.25
    SET rptreport->m_horzprintoffset = _xshift
    SET rptreport->m_vertprintoffset = _yshift
    SET _yoffset = rptreport->m_margintop
    SET _xoffset = rptreport->m_marginleft
    SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
    SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
    SET _rptstat = uar_rptstartreport(_hreport)
    SET _rptpage = uar_rptstartpage(_hreport)
   ENDIF
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 60
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_courier
   SET rptfont->m_pointsize = 12
   SET rptfont->m_bold = rpt_on
   SET _courier12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET _courier100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET rptfont->m_bold = rpt_on
   SET _courier8b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _courier80 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 7
   SET _courier70 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penstyle = 3
   SET _pen14s3c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 CALL initializereport(0)
 CALL updatequeryforevaluationby(0)
 CALL get_prescreen_results(0)
 CALL finalizereport(_sendto)
 SET last_mod = "005"
 SET mod_date = "Feb 22, 2018"
END GO
