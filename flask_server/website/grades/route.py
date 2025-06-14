from datetime import datetime
from flask import *
from flask_login import login_required, current_user
from flask_server.website.extensions import db
from flask_server.website.classes.service import getClasses
from flask_server.website.classes.model import Classes
from flask_server.website.timetable.model import Subjects
from flask_server.website.grades.model import Grades
from flask_server.website.authorization.model import Students
from flask import request, render_template

grades = Blueprint('grades',
                          __name__,
                          static_folder='../static',
                          template_folder='templates',
                          url_prefix='/grades')

# endpoint wyświetlający stronę z ocenami
@grades.route('/')
@login_required
def getGrades():
    # jeśli użytkownik jest nauczycielem albo administratorem, następuje pobranie wszystkich klas,
    # żeby mógł wybrać, której klasy oceny chce zobaczyć
    if current_user.user_type == 'teacher' or current_user.user_type == 'admin':
        classes = getClasses()
        return render_template("grades.html", user=current_user, classes=classes)

    child = None
    # jeśli użytkownik jest rodzicem, następuje wyszukanie modelu ucznia jego dziecka
    if current_user.user_type == 'parent':
        child = Students.query.filter_by(student_id=current_user.parent[0].student_id).first()
    # jeśli użytkownik jest uczniem, od razu przypisanie do 'child' jego modelu ucznia
    elif current_user.user_type == 'student':
        child = current_user.student[0]
    # pobranie przedmiotów klasy, do której jezt przypisany uczeń (albo dziecko)
    subjects = Subjects.query.filter_by(class_name=child.class_name)

    return render_template("grades.html", user=current_user, child=child, subjects=subjects)


# endpoint wyświetlający oceny danej klasy (dla nauczyciela albo admina), pobiera nazwę danej klasy

@grades.route('<string:class_name>', methods=["GET", "POST"])
@login_required
def grades_teacher(class_name):
    # Pobierz klasę (przykładowo, dostosuj do swojej logiki)
    clas = Classes.query.filter_by(class_name=class_name).first()

    # Pobierz przedmioty nauczane w tej klasie (dla nauczyciela lub admina)
    if current_user.user_type == 'teacher':
        subjects = Subjects.query.filter_by(teacher_id=current_user.user_id, class_name=class_name).all()
    else:  # admin
        subjects = Subjects.query.filter_by(class_name=class_name).all()

    # Pobierz wszystkie klasy do wyboru (np. dla dropdowna)
    classes = Classes.query.all()

    # Pobierz uczniów w klasie
    students = Students.query.filter_by(class_name=class_name).all()

    # Funkcja do obliczenia średniej ocen ucznia dla tej klasy (i nauczyciela jeśli dotyczy)
    def student_average(student):
        relevant_grades = []
        for grade in student.grades:
            # Sprawdzamy czy ocena jest z przedmiotu tej klasy
            if grade.subject.class_name == class_name:
                # Jeśli nauczyciel, to tylko jego przedmioty
                if current_user.user_type == 'teacher':
                    if grade.subject.teacher_id != current_user.user_id:
                        continue
                # Pomijamy oceny końcowe
                if not grade.is_final:
                    relevant_grades.append((grade.type, grade.weight))
        if not relevant_grades:
            return 0
        weighted_sum = sum(g * w for g, w in relevant_grades)
        weight_sum = sum(w for _, w in relevant_grades)
        if weight_sum == 0:
            return 0
        return weighted_sum / weight_sum

    # Pobierz parametr sortowania z URL (domyślnie rosnąco)
    sort_order = request.args.get('sort', 'asc')

    # Sortuj uczniów po średniej ocen
    students = list(students)
    students.sort(key=student_average, reverse=(sort_order == 'desc'))

    if request.method == "POST":
        print('FORM DATA:', dict(request.form))  # LOGUJEMY CAŁY FORMULARZ
        action = request.form.get('action')
        # Dodanie oceny
        if action == "add_grade":
            try:
                grade_type = request.form.get('type')
                grade_weight = request.form.get('weight')
                description = request.form.get('description')
                is_final = request.form.get('is_final') == 'true'
                student_id = request.form.get('student_id')
                subject_id = request.form.get('subject_id')
                # Dodawanie/edycja oceny końcowej
                if is_final:
                    existing_final = Grades.query.filter_by(student_id=student_id, subject_id=subject_id, is_final=True).first()
                    if existing_final:
                        existing_final.type = int(grade_type) if grade_type is not None and grade_type != '' else existing_final.type
                        existing_final.weight = int(grade_weight) if grade_weight is not None and grade_weight != '' else existing_final.weight
                        existing_final.description = description if description and description.strip() != '' else existing_final.description
                        db.session.commit()
                        flash('Ocena końcowa została zaktualizowana!', 'success')
                    else:
                        new_grade = Grades(
                            student_id=student_id,
                            subject_id=subject_id,
                            type=int(grade_type) if grade_type is not None and grade_type != '' else 0,
                            weight=int(grade_weight) if grade_weight is not None and grade_weight != '' else 1,
                            description=description if description and description.strip() != '' else 'Brak opisu',
                            is_final=True
                        )
                        db.session.add(new_grade)
                        db.session.commit()
                        flash('Ocena końcowa została dodana!', 'success')
                # Dodawanie zwykłej oceny
                else:
                    new_grade = Grades(
                        student_id=student_id,
                        subject_id=subject_id,
                        type=int(grade_type) if grade_type is not None and grade_type != '' else 0,
                        weight=int(grade_weight) if grade_weight is not None and grade_weight != '' else 1,
                        description=description if description and description.strip() != '' else 'Brak opisu',
                        is_final=False
                    )
                    db.session.add(new_grade)
                    db.session.commit()
                    flash('Ocena została dodana pomyślnie!', 'success')
            except Exception as e:
                db.session.rollback()
                flash(f'Błąd podczas dodawania oceny: {e}', 'danger')
                print(f'Błąd podczas dodawania oceny: {e}')
        # Usuwanie oceny
        elif action == "delete_grade":
            try:
                grade_id = request.form.get('grade_id')
                grade = Grades.query.get(grade_id)
                if grade:
                    db.session.delete(grade)
                    db.session.commit()
                    flash('Ocena została usunięta!', 'success')
                else:
                    flash('Nie znaleziono oceny do usunięcia.', 'danger')
            except Exception as e:
                db.session.rollback()
                flash(f'Błąd podczas usuwania oceny: {e}', 'danger')
                print(f'Błąd podczas usuwania oceny: {e}')
        # Zmiana oceny
        elif request.form.get('change') == 'true':
            try:
                grade_id = request.form.get('grade_id')
                grade = Grades.query.get(grade_id)
                if grade:
                    grade.type = int(request.form.get('type')) if request.form.get('type') else grade.type
                    grade.weight = int(request.form.get('weight')) if request.form.get('weight') else grade.weight
                    grade.description = request.form.get('description') if request.form.get('description') else grade.description
                    db.session.commit()
                    flash('Ocena została zmieniona!', 'success')
                else:
                    flash('Nie znaleziono oceny do zmiany.', 'danger')
            except Exception as e:
                db.session.rollback()
                flash(f'Błąd podczas zmiany oceny: {e}', 'danger')
                print(f'Błąd podczas zmiany oceny: {e}')
    return render_template(
        'grades_teacher.html',
        user=current_user,
        clas=clas,
        subjects=subjects,
        classes=classes,
        students=students,
        sort_order=sort_order,
        student_average=student_average
    )
