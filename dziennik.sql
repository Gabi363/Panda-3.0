PGDMP                    
    {            dziennik_db    16.1    16.1 @    ;           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            <           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            =           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            >           1262    16398    dziennik_db    DATABASE     ~   CREATE DATABASE dziennik_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Polish_Poland.1250';
    DROP DATABASE dziennik_db;
                postgres    false                        2615    16539    public    SCHEMA     2   -- *not* creating schema, since initdb creates it
 2   -- *not* dropping schema, since initdb creates it
                postgres    false            ?           0    0 
   SCHEMA public    COMMENT         COMMENT ON SCHEMA public IS '';
                   postgres    false    5            @           0    0 
   SCHEMA public    ACL     +   REVOKE USAGE ON SCHEMA public FROM PUBLIC;
                   postgres    false    5            �            1255    16679    handle_user_insert()    FUNCTION       CREATE FUNCTION public.handle_user_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Dodanie komunikatu do logów w celu śledzenia
    IF NEW.user_type = 'student' THEN
        INSERT INTO students (student_id)
        VALUES (NEW.user_id);
    ELSIF NEW.user_type = 'teacher' THEN
        INSERT INTO teachers (teacher_id)
        VALUES (NEW.user_id);
    ELSIF NEW.user_type = 'parent' THEN
        INSERT INTO parents (parent_id)
        VALUES (NEW.user_id);
    END IF;
    RETURN NEW;
END;
$$;
 +   DROP FUNCTION public.handle_user_insert();
       public          postgres    false    5            �            1259    16667 
   announcements    TABLE     �   CREATE TABLE public.announcements (
    announcement_id integer NOT NULL,
    description character varying,
    add_date date,
    in_archive boolean
);
 !   DROP TABLE public.announcements;
       public         heap    postgres    false    5            �            1259    16573    classes    TABLE     �   CREATE TABLE public.classes (
    class_name character varying NOT NULL,
    homeroom_teacher_id integer,
    class_profile character varying
);
    DROP TABLE public.classes;
       public         heap    postgres    false    5            �            1259    16541    flyway_schema_history    TABLE     �  CREATE TABLE public.flyway_schema_history (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);
 )   DROP TABLE public.flyway_schema_history;
       public         heap    postgres    false    5            �            1259    16633    grades    TABLE     �   CREATE TABLE public.grades (
    grade_id integer NOT NULL,
    subject_id integer,
    type integer,
    weight integer,
    student_id integer,
    description character varying,
    add_date date
);
    DROP TABLE public.grades;
       public         heap    postgres    false    5            �            1259    16650    lessons    TABLE     %  CREATE TABLE public.lessons (
    lesson_id integer NOT NULL,
    subject_id integer,
    teacher_id integer,
    day_of_week character varying,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    building character varying,
    test character varying
);
    DROP TABLE public.lessons;
       public         heap    postgres    false    5            �            1259    16602    parents    TABLE     �   CREATE TABLE public.parents (
    parent_id integer NOT NULL,
    name character varying,
    surname character varying,
    student_id integer
);
    DROP TABLE public.parents;
       public         heap    postgres    false    5            �            1259    16585    students    TABLE       CREATE TABLE public.students (
    student_id integer NOT NULL,
    name character varying,
    surname character varying,
    gradebook_nr integer,
    class_name character varying,
    date_of_birth date,
    place_of_birth character varying,
    address character varying
);
    DROP TABLE public.students;
       public         heap    postgres    false    5            �            1259    16620    subjects    TABLE     �   CREATE TABLE public.subjects (
    subject_id integer NOT NULL,
    subject_name character varying,
    class_name character varying
);
    DROP TABLE public.subjects;
       public         heap    postgres    false    5            �            1259    16619    subjects_subject_id_seq    SEQUENCE     �   CREATE SEQUENCE public.subjects_subject_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.subjects_subject_id_seq;
       public          postgres    false    5    224            A           0    0    subjects_subject_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.subjects_subject_id_seq OWNED BY public.subjects.subject_id;
          public          postgres    false    223            �            1259    16560    teachers    TABLE     �   CREATE TABLE public.teachers (
    teacher_id integer NOT NULL,
    name character varying,
    surname character varying,
    subject_id integer,
    classroom_nr integer,
    description character varying
);
    DROP TABLE public.teachers;
       public         heap    postgres    false    5            �            1259    16559    teachers_teacher_id_seq    SEQUENCE     �   CREATE SEQUENCE public.teachers_teacher_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.teachers_teacher_id_seq;
       public          postgres    false    219    5            B           0    0    teachers_teacher_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.teachers_teacher_id_seq OWNED BY public.teachers.teacher_id;
          public          postgres    false    218            �            1259    16551    users    TABLE       CREATE TABLE public.users (
    user_id integer NOT NULL,
    user_type character varying,
    email character varying,
    login character varying,
    password character varying,
    logged_in boolean,
    phone_nr integer,
    photo character varying
);
    DROP TABLE public.users;
       public         heap    postgres    false    5            �            1259    16550    users_user_id_seq    SEQUENCE     �   CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.users_user_id_seq;
       public          postgres    false    217    5            C           0    0    users_user_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;
          public          postgres    false    216            z           2604    16623    subjects subject_id    DEFAULT     z   ALTER TABLE ONLY public.subjects ALTER COLUMN subject_id SET DEFAULT nextval('public.subjects_subject_id_seq'::regclass);
 B   ALTER TABLE public.subjects ALTER COLUMN subject_id DROP DEFAULT;
       public          postgres    false    223    224    224            y           2604    16563    teachers teacher_id    DEFAULT     z   ALTER TABLE ONLY public.teachers ALTER COLUMN teacher_id SET DEFAULT nextval('public.teachers_teacher_id_seq'::regclass);
 B   ALTER TABLE public.teachers ALTER COLUMN teacher_id DROP DEFAULT;
       public          postgres    false    219    218    219            x           2604    16554 
   users user_id    DEFAULT     n   ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);
 <   ALTER TABLE public.users ALTER COLUMN user_id DROP DEFAULT;
       public          postgres    false    217    216    217            8          0    16667 
   announcements 
   TABLE DATA           [   COPY public.announcements (announcement_id, description, add_date, in_archive) FROM stdin;
    public          postgres    false    227   fP       1          0    16573    classes 
   TABLE DATA           Q   COPY public.classes (class_name, homeroom_teacher_id, class_profile) FROM stdin;
    public          postgres    false    220   �P       ,          0    16541    flyway_schema_history 
   TABLE DATA           �   COPY public.flyway_schema_history (installed_rank, version, description, type, script, checksum, installed_by, installed_on, execution_time, success) FROM stdin;
    public          postgres    false    215   �P       6          0    16633    grades 
   TABLE DATA           g   COPY public.grades (grade_id, subject_id, type, weight, student_id, description, add_date) FROM stdin;
    public          postgres    false    225   {Q       7          0    16650    lessons 
   TABLE DATA           w   COPY public.lessons (lesson_id, subject_id, teacher_id, day_of_week, start_time, end_time, building, test) FROM stdin;
    public          postgres    false    226   �Q       3          0    16602    parents 
   TABLE DATA           G   COPY public.parents (parent_id, name, surname, student_id) FROM stdin;
    public          postgres    false    222   �Q       2          0    16585    students 
   TABLE DATA              COPY public.students (student_id, name, surname, gradebook_nr, class_name, date_of_birth, place_of_birth, address) FROM stdin;
    public          postgres    false    221   �Q       5          0    16620    subjects 
   TABLE DATA           H   COPY public.subjects (subject_id, subject_name, class_name) FROM stdin;
    public          postgres    false    224   R       0          0    16560    teachers 
   TABLE DATA           d   COPY public.teachers (teacher_id, name, surname, subject_id, classroom_nr, description) FROM stdin;
    public          postgres    false    219   �R       .          0    16551    users 
   TABLE DATA           g   COPY public.users (user_id, user_type, email, login, password, logged_in, phone_nr, photo) FROM stdin;
    public          postgres    false    217   �R       D           0    0    subjects_subject_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.subjects_subject_id_seq', 24, true);
          public          postgres    false    223            E           0    0    teachers_teacher_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.teachers_teacher_id_seq', 1, false);
          public          postgres    false    218            F           0    0    users_user_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.users_user_id_seq', 6, true);
          public          postgres    false    216            �           2606    16673     announcements announcements_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_pkey PRIMARY KEY (announcement_id);
 J   ALTER TABLE ONLY public.announcements DROP CONSTRAINT announcements_pkey;
       public            postgres    false    227            �           2606    16579    classes classes_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_pkey PRIMARY KEY (class_name);
 >   ALTER TABLE ONLY public.classes DROP CONSTRAINT classes_pkey;
       public            postgres    false    220            |           2606    16548 .   flyway_schema_history flyway_schema_history_pk 
   CONSTRAINT     x   ALTER TABLE ONLY public.flyway_schema_history
    ADD CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank);
 X   ALTER TABLE ONLY public.flyway_schema_history DROP CONSTRAINT flyway_schema_history_pk;
       public            postgres    false    215            �           2606    16639    grades grades_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_pkey PRIMARY KEY (grade_id);
 <   ALTER TABLE ONLY public.grades DROP CONSTRAINT grades_pkey;
       public            postgres    false    225            �           2606    16656    lessons lessons_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_pkey PRIMARY KEY (lesson_id);
 >   ALTER TABLE ONLY public.lessons DROP CONSTRAINT lessons_pkey;
       public            postgres    false    226            �           2606    16608    parents parents_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY public.parents
    ADD CONSTRAINT parents_pkey PRIMARY KEY (parent_id);
 >   ALTER TABLE ONLY public.parents DROP CONSTRAINT parents_pkey;
       public            postgres    false    222            �           2606    16591    students students_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (student_id);
 @   ALTER TABLE ONLY public.students DROP CONSTRAINT students_pkey;
       public            postgres    false    221            �           2606    16627    subjects subjects_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (subject_id);
 @   ALTER TABLE ONLY public.subjects DROP CONSTRAINT subjects_pkey;
       public            postgres    false    224            �           2606    16567    teachers teachers_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_pkey PRIMARY KEY (teacher_id);
 @   ALTER TABLE ONLY public.teachers DROP CONSTRAINT teachers_pkey;
       public            postgres    false    219                       2606    16558    users users_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public            postgres    false    217            }           1259    16549    flyway_schema_history_s_idx    INDEX     `   CREATE INDEX flyway_schema_history_s_idx ON public.flyway_schema_history USING btree (success);
 /   DROP INDEX public.flyway_schema_history_s_idx;
       public            postgres    false    215            �           2620    16680    users insert_user_trigger    TRIGGER     {   CREATE TRIGGER insert_user_trigger AFTER INSERT ON public.users FOR EACH ROW EXECUTE FUNCTION public.handle_user_insert();
 2   DROP TRIGGER insert_user_trigger ON public.users;
       public          postgres    false    217    228            �           2606    16580 (   classes classes_homeroom_teacher_id_fkey 
   FK CONSTRAINT     �   ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_homeroom_teacher_id_fkey FOREIGN KEY (homeroom_teacher_id) REFERENCES public.teachers(teacher_id);
 R   ALTER TABLE ONLY public.classes DROP CONSTRAINT classes_homeroom_teacher_id_fkey;
       public          postgres    false    4737    219    220            �           2606    16674    teachers fk_subject 
   FK CONSTRAINT     �   ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT fk_subject FOREIGN KEY (subject_id) REFERENCES public.subjects(subject_id);
 =   ALTER TABLE ONLY public.teachers DROP CONSTRAINT fk_subject;
       public          postgres    false    224    4745    219            �           2606    16645    grades grades_student_id_fkey 
   FK CONSTRAINT     �   ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(student_id);
 G   ALTER TABLE ONLY public.grades DROP CONSTRAINT grades_student_id_fkey;
       public          postgres    false    4741    225    221            �           2606    16640    grades grades_subject_id_fkey 
   FK CONSTRAINT     �   ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(subject_id);
 G   ALTER TABLE ONLY public.grades DROP CONSTRAINT grades_subject_id_fkey;
       public          postgres    false    224    225    4745            �           2606    16657    lessons lessons_subject_id_fkey 
   FK CONSTRAINT     �   ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(subject_id);
 I   ALTER TABLE ONLY public.lessons DROP CONSTRAINT lessons_subject_id_fkey;
       public          postgres    false    224    226    4745            �           2606    16662    lessons lessons_teacher_id_fkey 
   FK CONSTRAINT     �   ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(teacher_id);
 I   ALTER TABLE ONLY public.lessons DROP CONSTRAINT lessons_teacher_id_fkey;
       public          postgres    false    219    226    4737            �           2606    16609    parents parents_parent_id_fkey 
   FK CONSTRAINT     �   ALTER TABLE ONLY public.parents
    ADD CONSTRAINT parents_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.users(user_id);
 H   ALTER TABLE ONLY public.parents DROP CONSTRAINT parents_parent_id_fkey;
       public          postgres    false    4735    222    217            �           2606    16614    parents parents_student_id_fkey 
   FK CONSTRAINT     �   ALTER TABLE ONLY public.parents
    ADD CONSTRAINT parents_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(student_id);
 I   ALTER TABLE ONLY public.parents DROP CONSTRAINT parents_student_id_fkey;
       public          postgres    false    222    221    4741            �           2606    16597 !   students students_class_name_fkey 
   FK CONSTRAINT     �   ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_class_name_fkey FOREIGN KEY (class_name) REFERENCES public.classes(class_name);
 K   ALTER TABLE ONLY public.students DROP CONSTRAINT students_class_name_fkey;
       public          postgres    false    220    4739    221            �           2606    16592 !   students students_student_id_fkey 
   FK CONSTRAINT     �   ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(user_id);
 K   ALTER TABLE ONLY public.students DROP CONSTRAINT students_student_id_fkey;
       public          postgres    false    221    4735    217            �           2606    16628 !   subjects subjects_class_name_fkey 
   FK CONSTRAINT     �   ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_class_name_fkey FOREIGN KEY (class_name) REFERENCES public.classes(class_name);
 K   ALTER TABLE ONLY public.subjects DROP CONSTRAINT subjects_class_name_fkey;
       public          postgres    false    4739    220    224            �           2606    16568 !   teachers teachers_teacher_id_fkey 
   FK CONSTRAINT     �   ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.users(user_id);
 K   ALTER TABLE ONLY public.teachers DROP CONSTRAINT teachers_teacher_id_fkey;
       public          postgres    false    4735    217    219            8   
   x������ � �      1   4   x�3t����M,�Mˬ�2t�2�st�3Rs��Pd��d�Qd��dc���� �z      ,   �   x���M
�0FדSx���L�&=�\	�J,�����������,�|̛�c_���'��p�*�{��C���v�ʐk�q]4�7Ju�;��;FǠ=A@/A�!�UAo�ʟoГ�旤��P�5pup��1��
��>0�B���ִ�����zOv      6   
   x������ � �      7   
   x������ � �      3      x�3�� �=... ��      2      x�3���D\&؅Ͱ��qqq j�      5   �   x�U�K�0��aP�e|6���
���O�da�4v���q���8��,�|�>R�|����W��%���!otǼ���$%f� b��SZ�5}kvD��?ͮ���2p(d��ηy�u�ɀ�p4ELSo ��t<���`[      0      x�3��CF\��1z\\\ ��"      .   �   x�m��
�0�s�0�$m��|/c�q�l}|kk+�/�>�#l�9���O�=,�n��.e	nض�]'H,�n��l���殂��a�͚����{�V+Ʉ	�q8Y���g~��pPTNR8*�؋j��@.�9	�R�^T���T������G\���C�.'A:B�F��א     