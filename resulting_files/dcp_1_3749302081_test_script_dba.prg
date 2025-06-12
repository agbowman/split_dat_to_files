CREATE PROGRAM dcp_1_3749302081_test_script:dba
 DECLARE ierrorout = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM encounter e,
   person p
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
  DETAIL
   ierrorout = mod(cnvtint(substring(1,findstring(" Years",cnvtage(p.birth_dt_tm),1,0),cnvtage(p
       .birth_dt_tm))),2)
  WITH nocounter
 ;end select
 IF (ierrorout != 0)
  SET reply->status_data.status = "F"
 ELSE
  SET rhead = "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}"
  SET rhdc1 =
  "{\colortbl;\red0\green0\blue255;\red255\green255\blue255;\red255\green0\blue0;\red255\green255\blue0;"
  SET rhdc2 = "\red0\green128\blue0;red0\green0\blue255}\deftab1134"
  SET rh2by = "\plain \f0 \fs22 \b \cb4 \pard\s10 "
  SET rh2bb = "\plain \f0 \fs22 \b \cb1 \pard\s10 "
  SET rh2bg = "\plain \f0 \fs22 \b \cb5 \pard\s10 "
  SET rh2br = "\plain \f0 \fs22 \b \cb3 \pard\s10 "
  SET rh2r = "\plain \f0 \fs18 \cb4 \pard\sl0 "
  SET rh2b = "\plain \f0 \fs22 \b \cb4 \pard\sl0 "
  SET rh2bu = "\plain \f0 \fs18 \b \ul \cb4 \pard\sl0 "
  SET rh2u = "\plain \f0 \fs18 \u \cb4 \pard\sl0 "
  SET rh2i = "\plain \f0 \fs18 \i \cb4 \pard\sl0 "
  SET reol = "\par "
  SET rtab = "\tab "
  SET wr = " \plain \f0 \fs18 "
  SET wb = " \plain \f0 \fs18 \b \cb4 "
  SET wu = " \plain \f0 \fs18 \ul \cb "
  SET wi = " \plain \f0 \fs18 \i \cb4 "
  SET wbi = " \plain \f0 \fs18 \b \i \cb4 "
  SET wiu = " \plain \f0 \fs18 \i \ul \cb4 "
  SET wbiu = " \plain \f0 \fs18 \b \ul \i \cb4 "
  SET rtfeof = "}"
  SET lidx = 0
  SET temp_disp1 = fillstring(200," ")
  SET temp_disp2 = fillstring(200," ")
  SET temp_disp5 = fillstring(200," ")
  SET temp_disp6 = fillstring(200," ")
  SET name = fillstring(30," ")
  SET age = fillstring(20," ")
  SET dob = fillstring(20," ")
  SET emr = fillstring(20," ")
  SET finnbr = fillstring(20," ")
  SET sex = fillstring(20," ")
  SET unit = fillstring(20," ")
  SET bed = fillstring(20," ")
  SET room = fillstring(20," ")
  SET color = 0
  SET cdf_meaning = fillstring(12," ")
  SET cancel_cd = uar_get_code_by("MEANING",12025,"CANCELED")
  SET aller = fillstring(24," ")
  RECORD drec(
    1 line_cnt = i4
    1 display_line = vc
    1 line_qual[*]
      2 disp_line = vc
  )
  SELECT INTO "nl:"
   FROM encounter e,
    allergy a,
    nomenclature n
   PLAN (e
    WHERE (e.encntr_id=request->visit[1].encntr_id))
    JOIN (a
    WHERE a.person_id=e.person_id
     AND ((a.active_ind+ 0)=1)
     AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ((a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (a.end_effective_dt_tm=null))
     AND ((a.reaction_status_cd+ 0) != cancel_cd))
    JOIN (n
    WHERE a.substance_nom_id=n.nomenclature_id)
   HEAD REPORT
    nka = "Y"
   DETAIL
    IF (n.mnemonic="NKA")
     row + 0
    ELSE
     nka = "N"
    ENDIF
   FOOT REPORT
    IF (nka="N")
     aller = "** Allergies **"
    ELSE
     aller = "**NoAllergies**"
    ENDIF
   WITH nocounter
  ;end select
  FOR (y = 1 TO request->nv_cnt)
    IF ((request->nv[y].pvc_name="name_full_formatted"))
     SET name = request->nv[y].pvc_value
    ELSEIF ((request->nv[y].pvc_name="age"))
     SET age = request->nv[y].pvc_value
    ELSEIF ((request->nv[y].pvc_name="birth_dt_tm"))
     SET dob = request->nv[y].pvc_value
    ELSEIF ((request->nv[y].pvc_name="sex"))
     SET sex = request->nv[y].pvc_value
    ELSEIF ((request->nv[y].pvc_name="emr"))
     SET emr = request->nv[y].pvc_value
    ELSEIF ((request->nv[y].pvc_name="loc_nurse_unit_disp"))
     SET unit = request->nv[y].pvc_value
    ELSEIF ((request->nv[y].pvc_name="loc_room_disp"))
     SET room = request->nv[y].pvc_value
    ELSEIF ((request->nv[y].pvc_name="loc_bed_disp"))
     SET bed = request->nv[y].pvc_value
    ELSEIF ((request->nv[y].pvc_name="fin_nbr"))
     SET finnbr = request->nv[y].pvc_value
    ENDIF
  ENDFOR
  SET stat = alterlist(drec->line_qual,8)
  SET drec->line_qual[1].disp_line = concat(rhead,rhdc1,rhdc2,rh2by,trim(name),
   wr)
  SET drec->line_qual[2].disp_line = concat(rtab,rtab,wr,trim("DOB: "),trim(dob))
  SET drec->line_qual[3].disp_line = concat(rtab,rtab,wr,trim("EMR: "),trim(emr))
  SET drec->line_qual[4].disp_line = concat(rtab,rtab,wr,trim("Fin #: "),trim(finnbr),
   reol)
  IF (aller="** No Known Allergies **")
   SET drec->line_qual[5].disp_line = concat(wb,trim(aller),rtab,rtab)
  ELSEIF (aller="** Allergies **")
   SET drec->line_qual[5].disp_line = concat(wb,trim(aller),rtab,rtab,rtab)
  ELSE
   SET drec->line_qual[5].disp_line = concat(wb,rtab,rtab,rtab)
  ENDIF
  SET drec->line_qual[6].disp_line = concat(rtab,wr,trim("Age Testing: "),trim(age))
  SET drec->line_qual[7].disp_line = concat(rtab,rtab,wr,trim("Gender: "),trim(sex))
  SET drec->line_qual[8].disp_line = concat(rtab,rtab,wr,trim("Loc: "),trim(unit),
   " ; ",trim(room)," ;",bed,reol)
  FOR (x = 1 TO 8)
    SET reply->text = concat(reply->text,drec->line_qual[x].disp_line)
  ENDFOR
  SET reply->status_data.status = "Z"
  SET reply->status_data.status = "S"
  SET reply->text = concat(reply->text,rtfeof)
 ENDIF
END GO
