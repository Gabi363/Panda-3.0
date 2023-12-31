from datetime import datetime
from flask import *
from flask_login import login_required, current_user
from .models import *
from .get_data_from_db import *

views = Blueprint('views', __name__)


@views.route("/")
def home():
    return redirect(url_for("auth.login"))


@views.route('/grades')
@login_required
def grades():
    if current_user.user_type == 'teacher' or current_user.user_type == 'admin':
        classes = readClasses()
        return render_template("grades.html", user=current_user, classes=classes)

    child = None
    if current_user.user_type == 'parent':
        child = Students.query.filter_by(student_id=current_user.parent[0].student_id).first()
    elif current_user.user_type == 'student':
        child = current_user.student[0]
    subjects = Subjects.query.filter_by(class_name=child.class_name)

    return render_template("grades.html", user=current_user, child=child, subjects=subjects)


@views.route('/grades/<string:class_name>', methods=["GET", "POST"])
def grades_teacher(class_name):
    clas = Classes.query.get_or_404(class_name)
    classes = readClasses()
    if current_user.user_type == 'teacher':
        subjects = Subjects.query.filter_by(teacher_id=current_user.user_id, class_name=class_name)
    if current_user.user_type == 'admin':
        subjects = Subjects.query.filter_by(class_name=class_name)
    students = Students.query.filter_by(class_name=class_name)

    if request.method == "POST":
        grade = request.form.get("type")
        weight = request.form.get("weight")
        description = request.form.get("description")
        if not request.form.get("delete"):
            if not grade or not weight or not description:
                flash('Empty place!', category='error')
            elif int(grade) > 6 or int(grade) < 1:
                flash('Wrong grade!', category='error')
            else:
                if request.form.get("change") == "false":
                    if request.form.get("is_final") == 'true':
                        if int(request.form.get("final_id")) == 0:
                            is_final = True
                            weight = 100
                            description = "Final"
                            new_grade = Grades(
                                subject_id=request.form["subject_id"],
                                type=grade,
                                weight=weight,
                                student_id=request.form["student_id"],
                                description=description,
                                add_date=datetime.now(),
                                is_final=is_final)
                            db.session.add(new_grade)
                            db.session.commit()
                            flash('Grade added!', category='success')
                        else:
                            grade = Grades.query.filter_by(grade_id=request.form.get("final_id")).first()
                            grade.type = request.form.get("type")
                            grade.add_date = datetime.now()
                            db.session.commit()
                            flash('Grade changed!', category='success')

                    elif request.form.get("is_final") == 'false':
                        is_final = False
                        new_grade = Grades(
                            subject_id=request.form["subject_id"],
                            type=grade,
                            weight=weight,
                            student_id=request.form["student_id"],
                            description=description,
                            add_date=datetime.now(),
                            is_final=is_final)
                        db.session.add(new_grade)
                        db.session.commit()
                        flash('Grade added!', category='success')

                elif request.form.get("change") == "true":

                    grade = Grades.query.filter_by(grade_id=request.form.get("grade_id")).first()
                    grade.type = request.form.get("type")
                    grade.weight = request.form.get("weight")
                    grade.description = request.form.get("description")
                    db.session.commit()
                    flash('Grade changed!', category='success')
        else:
            if request.form.get("delete"):
                Grades.query.filter_by(grade_id=request.form.get("grade_id_delete")).delete()
                db.session.commit()
                flash('Grade deleted!', category='success')
        return redirect(url_for('views.grades_teacher', class_name=class_name))
    return render_template('grades_teacher.html', user=current_user, clas=clas, subjects=subjects,
                           classes=classes, students=students)


@views.route('/plan')
@login_required
def plan():
    if current_user.user_type == 'parent':
        child = Students.query.filter_by(student_id=current_user.parent[0].student_id).first()
        zajecia = readLessons(child.student_id, current_user.user_type)
    elif current_user.user_type == 'admin':
        classes = readClasses()
        return render_template("plan.html", classes=classes)
    elif current_user.user_type == 'teacher':
        classes = readClasses()
        zajecia = readLessons(current_user.user_id, current_user.user_type)
        return render_template("plan.html", user=current_user, zajecia=zajecia, classes=classes)
    else:
        zajecia = readLessons(current_user.user_id, current_user.user_type)

    return render_template("plan.html", user=current_user, zajecia=zajecia)


@views.route('/plan/<string:class_name>', methods=["GET", "POST"])
def plan_teacher(class_name):
    classes = readClasses()
    child = Students.query.filter_by(class_name=class_name).first()
    zajecia = readLessons(child.student_id, 'admin')

    return render_template("plan_teacher.html", user=current_user, class_name=class_name, zajecia=zajecia, classes=classes)


@views.route('/announcements')
@login_required
def announcements():
    filtered_announcements = Announcements.query.filter(Announcements.in_archive == False).order_by(Announcements.add_date.desc()).all()
    return render_template("announcements.html", user=current_user, filtered_announcements=filtered_announcements)


@views.route('/announcement/<int:announcement_id>', methods=["GET", "POST"])
def announcement_details(announcement_id):
    announcement = Announcements.query.get_or_404(announcement_id)
    if request.method == "POST":
        Announcements.query.filter_by(announcement_id=request.form.get("announcement_id")).delete()
        db.session.commit()
        flash('Announcement deleted!', category='success')
        filtered_announcements = Announcements.query.filter(Announcements.in_archive == False).order_by(
            Announcements.add_date.desc()).all()
        return render_template("announcements.html", user=current_user, filtered_announcements=filtered_announcements)
    return render_template('announcement_details.html', user=current_user, announcement=announcement)


@views.route('/add-announcement', methods=["GET", "POST"])
@login_required
def add_announcement():
    if request.method == "POST":
        if not request.form.get("description"):
            flash('Empty place!', category='error')
        else:
            new_announcement = Announcements(
                description=request.form.get("description"),
                add_date=datetime.now(),
                in_archive=False,
                teacher_id=current_user.user_id)
            db.session.add(new_announcement)
            db.session.commit()
            announcement_id = new_announcement.announcement_id

    return render_template("add_announcement.html", user=current_user)


@views.route('/profile')
@login_required
def profile():
    return render_template("profile.html", user=current_user)
