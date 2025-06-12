CREATE PROGRAM dcp_get_demogbar:dba
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
 SET code_value = 0.0
 SET code_set = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cancel_cd = 0
 SET code_set = 12025
 SET cdf_meaning = "CANCELED"
 EXECUTE cpm_get_cd_for_cdf
 SET cancel_cd = code_value
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
   (dummyt d  WITH seq = 1),
   nomenclature n
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (a
   WHERE a.person_id=e.person_id
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (a.end_effective_dt_tm=null))
    AND a.reaction_status_cd != cancel_cd)
   JOIN (d)
   JOIN (n
   WHERE a.substance_nom_id=n.nomenclature_id)
  HEAD REPORT
   nka = "Y"
  DETAIL
   CALL echo(n.mnemonic)
   IF (n.mnemonic="NKA")
    row + 0
   ELSE
    nka = "N"
   ENDIF
  FOOT REPORT
   IF (nka="N")
    aller = "** Allergies **"
   ELSE
    aller = "** No Known Allergies **"
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 CALL echo(aller)
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  DETAIL
   FOR (y = 1 TO request->nv_cnt)
     IF ((request->nv[y].pvc_name="name_full_formatted"))
      name = request->nv[y].pvc_value
     ELSEIF ((request->nv[y].pvc_name="age"))
      age = request->nv[y].pvc_value
     ELSEIF ((request->nv[y].pvc_name="birth_dt_tm"))
      dob = request->nv[y].pvc_value
     ELSEIF ((request->nv[y].pvc_name="sex"))
      sex = request->nv[y].pvc_value
     ELSEIF ((request->nv[y].pvc_name="emr"))
      emr = request->nv[y].pvc_value
     ELSEIF ((request->nv[y].pvc_name="loc_nurse_unit_disp"))
      unit = request->nv[y].pvc_value
     ELSEIF ((request->nv[y].pvc_name="loc_room_disp"))
      room = request->nv[y].pvc_value
     ELSEIF ((request->nv[y].pvc_name="loc_bed_disp"))
      bed = request->nv[y].pvc_value
     ELSEIF ((request->nv[y].pvc_name="fin_nbr"))
      finnbr = request->nv[y].pvc_value
     ENDIF
   ENDFOR
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (rhead,rhdc1,rhdc2,rh2by,trim(name),
    wr),
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (rtab,rtab,wr,trim("DOB: "),trim(dob)),
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (rtab,rtab,wr,trim("EMR: "),trim(emr)),
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (rtab,rtab,wr,trim("Fin #: "),trim(finnbr),
    reol),
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx)
   IF (aller="** No Known Allergies **")
    drec->line_qual[lidx].disp_line = concat(wb,trim(aller),rtab,rtab)
   ELSEIF (aller="** Allergies **")
    drec->line_qual[lidx].disp_line = concat(wb,trim(aller),rtab,rtab,rtab)
   ELSE
    drec->line_qual[lidx].disp_line = concat(wb,rtab,rtab,rtab)
   ENDIF
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (rtab,wr,trim("Age: "),trim(age)),
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (rtab,rtab,wr,trim("Gender: "),trim(sex)),
   lidx = (lidx+ 1), stat = alterlist(drec->line_qual,lidx), drec->line_qual[lidx].disp_line = concat
   (rtab,rtab,wr,trim("Loc: "),trim(unit),
    " ; ",trim(room)," ;",bed,reol)
   FOR (x = 1 TO lidx)
     reply->text = concat(reply->text,drec->line_qual[x].disp_line)
   ENDFOR
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
  SET reply->text = concat(reply->text,rtfeof)
 ENDIF
END GO
