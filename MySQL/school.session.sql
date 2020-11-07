USE school;
SHOW TABLES;
SELECT *
FROM class;
SELECT *
FROM course;
SELECT *
FROM student;
SELECT *
FROM teacher;
SELECT *
FROM score;
select *
from -- 1、查询所有的课程的名称以及对应的任课老师姓名
select course.cname,
	teacher.tname
from course
	left join teacher on course.teacher_id = teacher.tid;
-- 2、查询学生表中男女生各有多少人
select gender as 性别,
	count(*) as 人数
from student
group by gender;
-- 3、查询物理成绩等于100的学生的姓名
SELECT s.sname -- OK 0.079s
FROM student s
	INNER JOIN score sc ON s.sid = sc.student_id
	INNER JOIN course c ON c.cid = sc.course_id
WHERE c.cname = '物理'
	AND sc.num = 100;
SELECT student.sname -- 0.000s
FROM student
WHERE student.sid IN (
		SELECT s.student_id
		FROM score s
			INNER JOIN course c ON s.course_id = c.cid
		WHERE c.cname = '物理'
			AND s.num = 100
	);
-- 4、查询平均成绩大于八十分的同学的姓名和平均成绩
SELECT s.sname,
	sc.avg_num
FROM student s
	INNER JOIN (
		SELECT student_id,
			AVG(num) AS avg_num
		FROM score
		GROUP BY student_id
		HAVING AVG(num) > 80
	) sc ON s.sid = sc.student_id;
-- 5、查询所有学生的学号，姓名，选课数，总成绩
SELECT s.sid,
	s.sname,
	COUNT(sc.sid) AS pick_num,
	SUM(sc.num) AS sum_num
FROM score sc
	INNER JOIN student s ON sc.student_id = s.sid
GROUP BY s.sname;
-- 6、 查询姓李老师的个数
SELECT '李老师个数' AS tname,
	COUNT(tid)
FROM teacher
WHERE tname LIKE '李%';
-- 7、 查询没有报李平老师课的学生姓名
SELECT student.sname -- 1
FROM student
WHERE student.sid NOT IN (
		SELECT DISTINCT student_id
		FROM score
		WHERE course_id IN (
				SELECT cid
				FROM course
				WHERE teacher_id IN (
						SELECT tid
						FROM teacher
						WHERE tname = '李平老师'
					)
			)
	);
SELECT student.sname -- 2
FROM student
WHERE sid NOT IN (
		SELECT DISTINCT student_id
		FROM score
		WHERE course_id IN (
				SELECT course.cid
				FROM course
					INNER JOIN teacher ON course.teacher_id = teacher.tid
				WHERE teacher.tname = '李平老师'
			)
	);
-- 先查询出李平老师任教的课程
SELECT course.cid,
	course.cname,
	teacher.tname
FROM course
	INNER JOIN teacher ON course.teacher_id = teacher.tid
WHERE tname = '李平老师';
-- 然后查出每个班级对应的课程
SELECT score.student_id
FROM score
	INNER JOIN (
		SELECT course.cid,
			course.cname,
			teacher.tname
		FROM course
			INNER JOIN teacher ON course.teacher_id = teacher.tid
		WHERE tname = '李平老师'
	) ct ON score.course_id = ct.cid;
-- 最后得到学生姓名 -- 3
SELECT student.sname
FROM student
WHERE sid NOT IN (
		SELECT score.student_id
		FROM score
			INNER JOIN (
				SELECT course.cid,
					course.cname,
					teacher.tname
				FROM course
					INNER JOIN teacher ON course.teacher_id = teacher.tid
				WHERE tname = '李平老师'
			) ct ON score.course_id = ct.cid
	);
-- 8、 查询物理课程比生物课程高的学生的学号
SELECT s1.student_id
FROM (
		SELECT student_id,
			num
		FROM score
		WHERE course_id = (
				SELECT cid
				FROM course
				WHERE cname = '物理'
			)
	) s1
	INNER JOIN (
		SELECT student_id,
			num
		FROM score
		WHERE course_id = (
				SELECT cid
				FROM course
				WHERE cname = '生物'
			)
	) s2 ON s1.student_id = s2.student_id
WHERE s1.num > s2.num;
-- 9、 查询没有同时选修物理课程和体育课程的学生姓名
SELECT student.sname
FROM student
WHERE sid NOT IN (
		SELECT sc.student_id
		FROM score sc
			INNER JOIN course c ON c.cid = sc.course_id
		WHERE c.cname IN ('物理', '体育')
	);
-- 10、查询挂科超过两门(包括两门)的学生姓名和班级
select *
from score
group by student_id;
-- 19、查询在所有选修了李平老师课程的学生中，这些课程(李平老师的课程，不是所有课程)平均成绩最高的学生姓名
-- 20、查询每门课程成绩最好的前两名学生姓名
-- 21、查询不同课程但成绩相同的学号，课程号，成绩
-- 22、查询没学过“李平”老师课程的学生姓名以及选修的课程名称；
SELECT s.sname,
	c.cname,
	t.tname
FROM student s
	INNER JOIN score sc ON s.sid = sc.student_id
	INNER JOIN course c ON sc.course_id = c.cid
	INNER JOIN teacher t ON t.tid = c.teacher_id
WHERE t.tname != '李平老师';
-- 23、查询所有选修了学号为1的同学选修过的一门或者多门课程的同学学号和姓名；
-- 24、任课最多的老师中学生单科成绩最高的学生姓