CREATE PROGRAM atrmissing
 SELECT
  a.application_number, a.description
  FROM application a
  WHERE  NOT (a.application_number IN (
  (SELECT
   at.application_number
   FROM application_task_r at
   WHERE at.application_number=a.application_number)))
  ORDER BY a.application_number
 ;end select
 SELECT
  t.task_number
  FROM application_task t
  WHERE  NOT (t.task_number IN (
  (SELECT
   at.task_number
   FROM task_request_r at
   WHERE at.task_number=t.task_number)))
  ORDER BY t.task_number
 ;end select
 SELECT
  r.request_number, r.request_name
  FROM request r
  WHERE  NOT (r.request_number IN (
  (SELECT
   rr.request_number
   FROM task_request_r rr
   WHERE rr.request_number=r.request_number)))
  ORDER BY r.request_number
 ;end select
END GO
