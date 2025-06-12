CREATE PROGRAM bhs_rpt_narco_contract_sp:dba
 FREE RECORD t_record
 RECORD t_record(
   1 encntr = f8
   1 pat_name = vc
   1 pat_dob = vc
   1 encntr_dt = vc
   1 provider = vc
   1 pcp = vc
   1 fin = vc
   1 mrn = vc
   1 para1 = vc
   1 para2 = vc
   1 para3 = vc
   1 para4 = vc
   1 para5 = vc
   1 para6 = vc
   1 para7 = vc
   1 para8 = vc
   1 para9 = vc
   1 para10 = vc
   1 para11 = vc
   1 para12 = vc
   1 para13 = vc
   1 para14 = vc
   1 para15 = vc
   1 para16 = vc
   1 para17 = vc
   1 para18 = vc
   1 para19 = vc
   1 para20 = vc
   1 para21 = vc
   1 para22 = vc
   1 para23 = vc
   1 para24 = vc
   1 para25 = vc
   1 para26 = vc
   1 para27 = vc
   1 para28 = vc
   1 para29 = vc
   1 para30 = vc
   1 para31 = vc
   1 para32 = vc
   1 para32b = vc
   1 para33 = vc
   1 para34 = vc
   1 para35 = vc
   1 para36 = vc
   1 para37 = vc
   1 para38 = vc
   1 para39 = vc
   1 para40 = vc
   1 para41 = vc
   1 para41b = vc
   1 para42 = vc
   1 para43 = vc
   1 para44 = vc
   1 para45 = vc
   1 para46 = vc
   1 line_cnt = i2
   1 line_qual[*]
     2 line = vc
 )
 IF (validate(request->visit,"Z") != "Z")
  SET printer_name = request->output_device
  SET t_record->encntr = request->visit[1].encntr_id
 ENDIF
 DECLARE fin_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mrn_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4,"CORPORATEMEDICALRECORDNUMBER"))
 DECLARE pcp_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",331,"PCP"))
 DECLARE attend_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",333,"ATTENDINGPHYSICIAN"))
 DECLARE t_line = vc
 DECLARE out_file = vc
 SELECT INTO "nl:"
  FROM encounter e,
   person p
  PLAN (e
   WHERE (e.encntr_id=t_record->encntr))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
  DETAIL
   t_record->pat_name = p.name_full_formatted, t_record->pat_dob = trim(format(cnvtdatetimeutc(
      datetimezone(p.birth_dt_tm,p.birth_tz),1),"mm-dd-yyyy;;q"))
  WITH nocounter
 ;end select
 SET t_record->encntr_dt = format(curdate,"mm-dd-yyyy;;q")
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_prsnl_reltn epr,
   prsnl p
  PLAN (e
   WHERE (e.encntr_id=t_record->encntr))
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=attend_cd)
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id)
  DETAIL
   t_record->provider = p.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   person_prsnl_reltn ppr,
   prsnl p
  PLAN (e
   WHERE (e.encntr_id=t_record->encntr))
   JOIN (ppr
   WHERE ppr.person_id=e.person_id
    AND ppr.person_prsnl_r_cd=pcp_cd
    AND ppr.active_ind=1
    AND cnvtdatetime(sysdate) BETWEEN ppr.beg_effective_dt_tm AND ppr.end_effective_dt_tm)
   JOIN (p
   WHERE p.person_id=ppr.prsnl_person_id
    AND p.active_ind=1)
  ORDER BY ppr.beg_effective_dt_tm DESC
  HEAD ppr.person_id
   t_record->pcp = p.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_alias ea
  PLAN (ea
   WHERE (ea.encntr_id=t_record->encntr)
    AND ea.encntr_alias_type_cd=fin_cd
    AND ea.active_ind=1)
  DETAIL
   t_record->fin = ea.alias
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   person_alias p
  PLAN (e
   WHERE (e.encntr_id=t_record->encntr))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.person_alias_type_cd=mrn_cd)
  DETAIL
   t_record->mrn = p.alias
  WITH nocounter
 ;end select
 SET t_record->para1 = concat(
  "El profesional de la salud que me atiende (cuyo nombre se menciona arriba) me",
  " recomend participar en un estudio sobre {f/11}sustancias controladas{f/8}  para",
  " abordar mejor el tratamiento de mi afeccin mdica e incrementar mi capacidad de",
  " realizar las actividades de la vida cotidiana.",
  " Tom esta decisin despus de analizar detenidamente con mi profesional de la salud",
  " los riesgos y beneficios de este tratamiento, as como las alternativas a dicho tratamiento.")
 SET t_record->para2 = concat(
  "Entiendo que el tratamiento con sustancias controladas tiene riesgos, entre los cuales",
  " encuentran los siguientes: estreimiento, falta de apetito, nuseas, somnolencia,",
  " confusin u otro cambio en la capacidad para pensar, as como problemas con el",
  " equilibrio. Por estos riesgos, no es seguro usar equipos peligrosos ni conducir vehculos",
  " a motor al tomar sustancias controladas. Entiendo que existe el riesgo de tener",
  " problemas al orinar, dificultades sexuales y una respiracin muy lenta, y que una",
  " sobredosis puede ocasionar un paro respiratorio y la muerte. Existen riesgos conocidos y",
  " secundarios menos comunes.")
 SET t_record->para3 = concat(
  "Entiendo que existe el riesgo de dependencia fsica, lo cual quiere decir que si se",
  " suspende abruptamente la administracin de la sustancia controlada puede presentarse",
  " un sndrome de abstinencia, caracterizado por uno o ms de los siguientes sntomas:",
  " goteo nasal, diarrea, clicos abdominales, piel de gallina o ansiedad.")
 SET t_record->para4 = concat(
  "Entiendo adems que existe el riesgo de dependencia psicolgica, lo que quiere decir que",
  " al dejar de tomar la sustancia controlada puede que sienta deseos de tomarla, quizs",
  " compulsivamente.")
 SET t_record->para5 = concat(
  "Mi profesional de la salud est dispuesto a comenzar a administrarme (o continuar",
  " administrndome) el tratamiento con sustancias controladas bajo las siguientes",
  " condiciones, las cuales acepto:")
 SET t_record->para6 = concat(
  "Otros tratamientos mdicos aceptables no han sido efectivos o han producido",
  " demasiados efectos secundarios.")
 SET t_record->para7 = concat("Actualmente no tengo problemas relacionados con consumo indebido o",
  " dependencia de sustancias controladas. Le he informado a mi profesional de la",
  " salud acerca de todas las veces que he consumido sustancias controladas en el",
  " pasado o el presente.")
 SET t_record->para8 = concat(
  "Actualmente no estoy involucrado/a en la venta, posesin ilegal, desviacin",
  " o transporte de sustancias controladas (narcticos, pastillas para dormir,",
  " pastillas para los nervios o analgsicos).")
 SET t_record->para9 = concat(
  "Acepto que solo recibir de mi profesional de la salud o de su equipo las ",
  " prescripciones (recetas) necesarias para obtener las sustancias controladas.",
  " Acepto informarle por anticipado a mi profesional de la salud en caso de",
  " presentarse cualquier tipo de necesidad aguda (como un trabajo dental o ciruga)",
  " que pueda requerir un cambio en la dosis de mi medicacin.")
 SET t_record->para10 = concat(
  "Tomar los medicamentos solo de la forma prescrita por mi profesional de la",
  " salud o su equipo y en ninguna circunstancia le permitir a otra persona",
  " tomar mis medicamentos.")
 SET t_record->para11 = concat(
  "Autorizo a mi profesional de la salud y/o a su equipo para que se comuniquen con cualquier",
  " otro mdico o proveedor de atencin mdica o cualquier farmacutico para informarles sobre la",
  " atencin mdica que me prestan y el tratamiento que me administran con respecto al uso de",
  " sustancias controladas.")
 SET t_record->para12 = concat(
  "Seguir las indicaciones de mi profesional de la salud y/o su equipo con respecto a suspender",
  " el tratamiento con sustancias controladas en caso de que ellos lo consideren recomendable.")
 SET t_record->para13 = concat(
  "Entiendo que se realizarn {f/9}conteos de pldoras y pruebas de sangre o de orina{f/8}",
  " para evaluar de forma apropiada el efecto de los medicamentos que me recetaron y si estoy",
  " cumpliendo con el tratamiento mdico; autorizo a hacer dichos conteos y pruebas.")
 SET t_record->para14 = concat(
  "Entiendo que tengo que estar disponible para los {f/9}conteos de pldoras y las pruebas",
  " de sangre y orina {f/8} que se realizarn sin fecha predefinida dentro de las 24 horas",
  " siguientes despus de haber recibido la notificacin.")
 SET t_record->para15 = concat(
  "Entiendo que mi profesional de la salud puede recomendarme consultas o evaluaciones",
  " con otros profesionales de la atencin mdica, entre los cuales pueden encontrarse",
  " los siguientes:")
 SET t_record->para16 = concat(
  "Ir a consulta con un psiquiatra a fin de que me realice una evaluacin para",
  "recibir tratamiento y medicamentos psicotrpicos.")
 SET t_record->para17 = concat(
  "Ir a consulta con un psiclogo u otro profesional de la salud para recibir",
  " atencin mdica en el campo de salud conductual u otra rea de la salud mental",
  " que pueda incluir un tratamiento conductual para controlar del dolor.")
 SET t_record->para18 =
 "Ir a consulta con un acupunturista para que me haga tratamiento con acupuntura."
 SET t_record->para19 =
 "Ir a consulta con un mdico u otro profesional de la salud para tratar esta u otra afeccin mdica."
 SET t_record->para20 = "Terapia fsica u ocupacional."
 SET t_record->para21 = "Programa de ejercicios en casa."
 SET t_record->para22 = concat(
  "Debido a riesgos conocidos y desconocidos para los nios por nacer, incluida la",
  " adiccin, si estoy embarazada, o si quedo embarazada en el futuro, se lo notificar",
  " a mi profesional de la salud.")
 SET t_record->para23 = concat(
  "Entiendo que, en trmino generales, {f/11}no{f/8} se harn concesiones por recetas",
  " medicamentos perdidos. Seguir las polticas del consultorio de mi profesional",
  " de la salud en cuanto a la repeticin (surtido) de recetas.")
 SET t_record->para24 = concat(
  "Entiendo que, en trminos generales, se suspender el tratamiento mdico con sustancias",
  " controladas en cualquiera de las siguientes circunstancias:")
 SET t_record->para25 = concat(
  "Mi profesional de la salud y/o su equipo cree que los medicamentos no",
  " estn teniendo ninguna efectividad o que mi actividad funcional no est mejorando.")
 SET t_record->para26 = "Regalo, vendo o uso los medicamentos de forma equivocada."
 SET t_record->para27 =
 "Desarrollo con rapidez una tolerancia al tratamiento o este pierde su efecto."
 SET t_record->para28 = concat(
  "Se me presentan efectos secundarios que, en opinin de mi profesional de la",
  " salud o su equipo, son significativos y me perjudican.")
 SET t_record->para29 = concat("Recibo sustancias controladas de fuentes distintas a mi profesional",
  " de la salud o sus colegas.")
 SET t_record->para30 = concat(
  "Los resultados de las pruebas muestran que hubo un consumo indebido de medicamentos",
  " recetados o consumo de drogas.")
 SET t_record->para31 = "Violo cualquiera de los trminos de este formulario de consentimiento."
 SET t_record->para32 = "Falto a dos o ms citas."
 SET t_record->para32b = concat(
  "Me involucro en algn comportamiento poco apropiado o amenazador para con mi",
  " profesional de la salud o el personal de apoyo.")
 SET t_record->para33 = concat(
  "Si mi profesional de la salud debe suspenderme el tratamiento, por lo general",
  " me indicar reducir las dosis gradualmente en el transcurso de varios das. Si mi",
  " profesional de la salud cree que tengo un problema de farmacodependencia, puede referirme",
  " a otro proveedor de atencin mdica a fin de que me indique un tratamiento para dicha dependencia."
  )
 SET t_record->para34 =
 "Entiendo que debo abstenerme de consumir cualquier tipo de droga y alcohol mientras est bajo tratamiento."
 SET t_record->para35 = concat(
  "Entiendo que puedo necesitar a un padrino, alguien que asista al consultorio con regularidad",
  " y d informacin sobre cmo me desenvuelvo en casa.")
 SET t_record->para36 = concat(
  "Entiendo que puede que, durante los periodos de ajuste de medicamentos, no se me permita",
  " manejar equipos que puedan ponerme a m o a otros en riesgo.")
 SET t_record->para37 = concat(
  "Entiendo que debo mantener todos mis medicamentos en una caja de seguridad o una caja que",
  " pueda trancarse y que dicha caja debe estar ubicada en un lugar seguro.")
 SET t_record->para38 = concat(
  "Mi profesional de la salud me recomienda limitar las conversaciones sobre mi estado",
  " de salud a los profesionales que me brindan atencin mdica y los miembros",
  " de mi familia inmediata.")
 SET t_record->para39 = concat(
  "Informar sobre cualquier medicamento que me prescriban otros profesionales de la",
  " salud, incluyendo cualquier medicamento nuevo que me administren en una Sala de Emergencias.")
 SET t_record->para40 = concat(
  "Una vez que mi afeccin mdica est bajo control y mi tratamiento mdico se haya",
  " estabilizado, la emisin de recetas mdicas puede transferirse a mi mdico de cabecera",
  " o a otro profesional de la salud, luego que los dos proveedores de atencin mdica lo analicen.")
 SET t_record->para41 = concat(
  "En caso de cambiar de farmacia, debo notificrselo a mi profesional de la salud.",
  " De no hacerlo, el presente acuerdo puede ser invalidado.")
 SET t_record->para41b = concat(
  "El paciente debe informarle al profesional de la salud que emite las recetas si cambia",
  " de mdico de cabecera, en caso de que el mdico que emite las recetas",
  " no sea el mdico de cabecera.")
 SET t_record->para42 = concat(
  "He ledo este documento, lo he entendido y me han respondido satisfactoriamente",
  " todas las preguntas que hice. Acepto consumir sustancias controladas como una ayuda",
  " para controlar mi afeccin mdica; entiendo que mi tratamiento con sustancias controladas",
  " deber cumplir con las condiciones previstas en este documento.")
 SET t_record->para43 = concat(
  "Acepto que mi farmaceuta reciba una copia de este documento; en caso de usar dos",
  "  farmacias, cada farmacia recibir una copia del documento. Acepto adems informarle a",
  " cada farmacia qu medicamento me estn entregando en la otra farmacia.")
 SET t_record->para44 = concat(
  "Solo usar la Farmacia _______________________________ para surtir mis recetas de",
  "  sustancias controladas.")
 SET t_record->para45 = concat(
  "I certify that the above named patient or responsible individual has received from me an",
  " explanation of this document. I have disclosed alternative methods of management that might be appropriate for",
  " the patient. I have offered to answer any questions by this patient/responsible individual.")
 SET t_record->para46 = concat(
  "I have interpreted the information and advice presented orally to the individual giving consent",
  " by the person obtaining this consent.  To the best of my knowledge and belief, the patient",
  " understood this explanation.")
 SET out_file = concat("narcocontract",t_record->fin)
 SELECT INTO value(out_file)
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD PAGE
   "{f/8}{cpi/10}", y_pos = 714, t_line = concat("(Patient Name: ",t_record->pat_name,")"),
   "{ps/68", y_pos, " moveto ",
   t_line, " show/}", row + 1,
   t_line = concat("(Patient DOB: ",t_record->pat_dob,")"), "{ps/400", y_pos,
   " moveto ", t_line, " show/}",
   row + 1, y_pos -= 12, t_line = concat("(Date of encounter: ",t_record->encntr_dt,")"),
   "{ps/68", y_pos, " moveto ",
   t_line, " show/}", row + 1,
   t_line = concat("(Acct.#: ",t_record->fin,")"), "{ps/400", y_pos,
   " moveto ", t_line, " show/}",
   row + 1, y_pos -= 12, t_line = concat("(Provider: ",t_record->provider,")"),
   "{ps/68", y_pos, " moveto ",
   t_line, " show/}", row + 1,
   t_line = concat("(MRN: ",t_record->mrn,")"), "{ps/400", y_pos,
   " moveto ", t_line, " show/}",
   row + 1, y_pos -= 12, t_line = concat("(Primary Care Provider: ",t_record->pcp,")"),
   "{ps/68", y_pos, " moveto ",
   t_line, " show/}", row + 1
  DETAIL
   y_pos -= 32, t_line = "(Acuerdo para la prescripcin de sustancias controladas)", "{b}{ps/306",
   y_pos, " moveto ", t_line,
   " dup stringwidth pop 2 div neg 0 rmoveto show/}{endb}", row + 1, y_pos -= 10,
   t_line = "((Agreement for the Prescription of Controlled Substances - Spanish))", "{ps/306", y_pos,
   " moveto ", t_line, " dup stringwidth pop 2 div neg 0 rmoveto show/}{endb}",
   row + 1, y_pos -= 24,
   CALL lines(t_record->para1,90)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(68,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, t_line = "(RIESGOS:)", "{b}{ps/68",
   y_pos, " moveto ", t_line,
   " show/}{endb}", row + 1, y_pos -= 20,
   CALL lines(t_record->para2,90)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(68,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8,
   CALL lines(t_record->para3,90)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(68,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8,
   CALL lines(t_record->para4,90)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(68,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, t_line = "(CONDICIONES:)", "{b}{ps/68",
   y_pos, " moveto ", t_line,
   " show/}{endb}", row + 1, y_pos -= 20,
   CALL lines(t_record->para5,90)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(68,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (1.) show/}",
   CALL lines(t_record->para6,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(94,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (2.) show/}",
   CALL lines(t_record->para7,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(94,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (3.) show/}",
   CALL lines(t_record->para8,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(94,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (4.) show/}",
   CALL lines(t_record->para9,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(94,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos = 36, t_line = "(Page 1 of 5)", "{ps/306",
   y_pos, " moveto ", t_line,
   " dup stringwidth pop 2 div neg 0 rmoveto show/}", row + 1, BREAK,
   y_pos -= 32, "{ps/80", y_pos,
   " moveto (5.) show/}",
   CALL lines(t_record->para10,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(94,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (6.) show/}",
   CALL lines(t_record->para11,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(94,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (7.) show/}",
   CALL lines(t_record->para12,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(94,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (8.) show/}",
   CALL lines(t_record->para13,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(94,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (9.) show/}",
   CALL lines(t_record->para14,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(94,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (10.) show/}",
   CALL lines(t_record->para15,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (a.) show/}",
   CALL lines(t_record->para16,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (b.) show/}",
   CALL lines(t_record->para17,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (c.) show/}",
   CALL lines(t_record->para18,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (d.) show/}",
   CALL lines(t_record->para19,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (e.) show/}",
   CALL lines(t_record->para20,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (f.) show/}",
   CALL lines(t_record->para21,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (11.) show/}",
   CALL lines(t_record->para22,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos = 36, t_line = "(Page 2 of 5)", "{ps/306",
   y_pos, " moveto ", t_line,
   " dup stringwidth pop 2 div neg 0 rmoveto show/}", row + 1, BREAK,
   y_pos -= 32, "{ps/80", y_pos,
   " moveto (12.) show/}",
   CALL lines(t_record->para23,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (13.) show/}",
   CALL lines(t_record->para24,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (a.) show/}",
   CALL lines(t_record->para25,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (b.) show/}",
   CALL lines(t_record->para26,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (c.) show/}",
   CALL lines(t_record->para27,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (d.) show/}",
   CALL lines(t_record->para28,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (e.) show/}",
   CALL lines(t_record->para29,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (f.) show/}",
   CALL lines(t_record->para30,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (g.) show/}",
   CALL lines(t_record->para31,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (h.) show/}",
   CALL lines(t_record->para32,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/98", y_pos,
   " moveto (i.) show/}",
   CALL lines(t_record->para32b,70)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(112,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (14.) show/}",
   CALL lines(t_record->para33,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (15.) show/}",
   CALL lines(t_record->para34,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (16.) show/}",
   CALL lines(t_record->para35,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (17.) show/}",
   CALL lines(t_record->para36,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (18.) show/}",
   CALL lines(t_record->para37,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (19.) show/}",
   CALL lines(t_record->para38,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos = 36, t_line = "(Page 3 of 5)", "{ps/306",
   y_pos, " moveto ", t_line,
   " dup stringwidth pop 2 div neg 0 rmoveto show/}", row + 1, BREAK,
   y_pos -= 32, "{ps/80", y_pos,
   " moveto (20.) show/}",
   CALL lines(t_record->para39,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (21.) show/}",
   CALL lines(t_record->para40,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (22.) show/}",
   CALL lines(t_record->para41,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8, "{ps/80", y_pos,
   " moveto (23.) show/}",
   CALL lines(t_record->para41b,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(102,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8,
   CALL lines(t_record->para42,90)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(68,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 8,
   CALL lines(t_record->para43,90)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(68,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos = 36, t_line = "(Page 4 of 5)", "{ps/306",
   y_pos, " moveto ", t_line,
   " dup stringwidth pop 2 div neg 0 rmoveto show/}", row + 1, BREAK,
   "{cpi/8}", y_pos -= 32, t_line = "(PGINA DE FIRMAS)",
   "{b}{ps/306", y_pos, " moveto ",
   t_line, " dup stringwidth pop 2 div neg 0 rmoveto show/}{endb}", row + 1,
   "{cpi/10}", y_pos -= 32,
   CALL lines(t_record->para44,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(68,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 14
   ENDFOR
   y_pos -= 32, "{b}{ps/newpath 68 ", y_pos,
   " moveto 350 ", y_pos, " lineto stroke 36 ",
   y_pos, " moveto/}{endb}", row + 1,
   "{b}{ps/newpath 450 ", y_pos, " moveto 520 ",
   y_pos, " lineto stroke 450 ", y_pos,
   " moveto/}{endb}", y_pos -= 14, t_line = "PACIENTE (Patient)",
   "{b}{ps/68", y_pos, " moveto (",
   t_line, ") show/}{endb}", row + 1,
   t_line = "FECHA (Date)", "{b}{ps/450", y_pos,
   " moveto (", t_line, ") show/}{endb}",
   row + 1, y_pos -= 32, "{b}{ps/newpath 68 ",
   y_pos, " moveto 350 ", y_pos,
   " lineto stroke 68 ", y_pos, " moveto/}{endb}",
   row + 1, "{b}{ps/newpath 450 ", y_pos,
   " moveto 520 ", y_pos, " lineto stroke 450 ",
   y_pos, " moveto/}{endb}", y_pos -= 14,
   t_line = "TESTIGO (Witness)", "{b}{ps/68", y_pos,
   " moveto (", t_line, ") show/}{endb}",
   row + 1, t_line = "FECHA (Date)", "{b}{ps/450",
   y_pos, " moveto (", t_line,
   ") show/}{endb}", row + 1, y_pos -= 32,
   t_line = "(PHYSICIAN ~ NURSE CERTIFICATION)", "{b}{ps/306", y_pos,
   " moveto ", t_line, " dup stringwidth pop 2 div neg 0 rmoveto show/}{endb}",
   row + 1, y_pos -= 16,
   CALL lines(t_record->para45,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(68,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 32, "{b}{ps/newpath 68 ", y_pos,
   " moveto 350 ", y_pos, " lineto stroke 68 ",
   y_pos, " moveto/}{endb}", row + 1,
   "{b}{ps/newpath 450 ", y_pos, " moveto 520 ",
   y_pos, " lineto stroke 450 ", y_pos,
   " moveto/}{endb}", y_pos -= 14, t_line = "PHYSICIAN ~ NURSE",
   "{b}{ps/68", y_pos, " moveto (",
   t_line, ") show/}{endb}", row + 1,
   t_line = "DATE", "{b}{ps/450", y_pos,
   " moveto (", t_line, ") show/}{endb}",
   row + 1, y_pos -= 32, t_line = "(INTERPRETER STATEMENT)",
   "{b}{ps/306", y_pos, " moveto ",
   t_line, " dup stringwidth pop 2 div neg 0 rmoveto show/}{endb}", row + 1,
   y_pos -= 16,
   CALL lines(t_record->para46,80)
   FOR (n = 1 TO t_record->line_cnt)
     CALL print(calcpos(68,(774 - y_pos))), t_record->line_qual[n].line, row + 1,
     y_pos -= 12
   ENDFOR
   y_pos -= 32, "{b}{ps/newpath 68 ", y_pos,
   " moveto 350 ", y_pos, " lineto stroke 68 ",
   y_pos, " moveto/}{endb}", row + 1,
   "{b}{ps/newpath 450 ", y_pos, " moveto 520 ",
   y_pos, " lineto stroke 450 ", y_pos,
   " moveto/}{endb}", y_pos -= 14, t_line = "INTERPRETER",
   "{b}{ps/68", y_pos, " moveto (",
   t_line, ") show/}{endb}", row + 1,
   t_line = "DATE", "{b}{ps/450", y_pos,
   " moveto (", t_line, ") show/}{endb}",
   row + 1, y_pos = 36, t_line = "(Page 5 of 5)",
   "{ps/306", y_pos, " moveto ",
   t_line, " dup stringwidth pop 2 div neg 0 rmoveto show/}", row + 1
  WITH maxrow = 750, maxcol = 3200, dio = postscript,
   nullreport
 ;end select
 SET spool patstring(out_file) patstring(printer_name) WITH deleted
 SUBROUTINE lines(string,chars)
   DECLARE ms_temp_str = vc WITH protect, noconstant("")
   DECLARE ml_chars = i4 WITH protect, noconstant(0)
   DECLARE ml_not_done = i4 WITH protect, noconstant(0)
   DECLARE ml_last = i4 WITH protect, noconstant(0)
   SET ms_temp_str = string
   SET ml_chars = chars
   SET t_record->line_cnt = 0
   SET stat = alterlist(t_record->line_qual,0)
   SET ml_not_done = 1
   WHILE (ml_not_done=1)
    SET ml_last = findstring(" ",substring(1,ml_chars,ms_temp_str),1,1)
    IF (textlen(ms_temp_str) <= ml_chars)
     SET ml_not_done = 0
     IF (textlen(ms_temp_str) > 0)
      SET t_record->line_cnt += 1
      SET stat = alterlist(t_record->line_qual,t_record->line_cnt)
      SET t_record->line_qual[t_record->line_cnt].line = trim(ms_temp_str,2)
     ENDIF
    ELSE
     SET t_record->line_cnt += 1
     SET stat = alterlist(t_record->line_qual,t_record->line_cnt)
     SET t_record->line_qual[t_record->line_cnt].line = trim(substring(1,ml_last,ms_temp_str),2)
     SET ms_temp_str = trim(substring((ml_last+ 1),textlen(ms_temp_str),ms_temp_str),3)
    ENDIF
   ENDWHILE
 END ;Subroutine
END GO
