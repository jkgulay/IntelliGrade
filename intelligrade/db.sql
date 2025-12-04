-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

-- User Feedback Table for System Evaluation (Objective 3)
-- Run this in Supabase SQL Editor to create the table:
/*
CREATE TABLE IF NOT EXISTS public.user_feedback (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  user_type character varying NOT NULL CHECK (user_type::text = ANY (ARRAY['student'::character varying, 'teacher'::character varying]::text[])),
  context character varying NOT NULL DEFAULT 'general'::character varying,
  context_id uuid,
  rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
  likes jsonb DEFAULT '[]'::jsonb,
  improvements jsonb DEFAULT '[]'::jsonb,
  comments text,
  submitted_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_feedback_pkey PRIMARY KEY (id)
);

-- Add RLS policies
ALTER TABLE public.user_feedback ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert their own feedback"
  ON public.user_feedback
  FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Users can view their own feedback"
  ON public.user_feedback
  FOR SELECT
  USING (auth.uid() IS NOT NULL);

-- Add index for analytics queries
CREATE INDEX IF NOT EXISTS idx_user_feedback_context ON public.user_feedback(context);
CREATE INDEX IF NOT EXISTS idx_user_feedback_rating ON public.user_feedback(rating);
CREATE INDEX IF NOT EXISTS idx_user_feedback_submitted ON public.user_feedback(submitted_at);
*/

CREATE TABLE public.ai_feedback_cache (
  id integer NOT NULL DEFAULT nextval('ai_feedback_cache_id_seq'::regclass),
  cache_key character varying NOT NULL UNIQUE,
  question_text text,
  student_answer text,
  correct_answer text,
  question_type character varying,
  feedback_text text NOT NULL,
  explanation text,
  suggestions jsonb,
  ai_model character varying,
  confidence numeric,
  hit_count integer DEFAULT 1,
  created_at timestamp with time zone DEFAULT now(),
  last_used_at timestamp with time zone DEFAULT now(),
  expires_at timestamp with time zone,
  CONSTRAINT ai_feedback_cache_pkey PRIMARY KEY (id)
);
CREATE TABLE public.answer_keys (
  id integer NOT NULL DEFAULT nextval('answer_keys_id_seq'::regclass),
  title character varying NOT NULL,
  subject character varying NOT NULL,
  assessment_type character varying NOT NULL,
  original_filename character varying,
  file_path character varying,
  file_size integer,
  num_questions integer NOT NULL,
  questions_data jsonb NOT NULL,
  total_points integer NOT NULL,
  created_by integer,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  is_active boolean DEFAULT true,
  usage_count integer DEFAULT 0,
  CONSTRAINT answer_keys_pkey PRIMARY KEY (id)
);
CREATE TABLE public.assignment_comments (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  submission_id uuid NOT NULL,
  user_id uuid NOT NULL,
  user_type character varying NOT NULL CHECK (user_type::text = ANY (ARRAY['teacher'::character varying, 'student'::character varying]::text[])),
  comment_text text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT assignment_comments_pkey PRIMARY KEY (id),
  CONSTRAINT assignment_comments_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.assignment_submissions(id)
);
CREATE TABLE public.assignment_submissions (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  assignment_id uuid NOT NULL,
  student_id uuid NOT NULL,
  submission_type character varying NOT NULL,
  text_content text,
  file_url character varying,
  link_url character varying,
  attachments jsonb DEFAULT '[]'::jsonb,
  status character varying NOT NULL DEFAULT 'draft'::character varying CHECK (status::text = ANY (ARRAY['draft'::character varying, 'submitted'::character varying, 'graded'::character varying, 'returned'::character varying]::text[])),
  submitted_at timestamp with time zone,
  score integer,
  feedback text,
  graded_by uuid,
  graded_at timestamp with time zone,
  is_late boolean DEFAULT false,
  late_days integer DEFAULT 0,
  penalty_applied integer DEFAULT 0,
  plagiarism_score numeric,
  plagiarism_report jsonb,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT assignment_submissions_pkey PRIMARY KEY (id),
  CONSTRAINT assignment_submissions_assignment_id_fkey FOREIGN KEY (assignment_id) REFERENCES public.assignments(id),
  CONSTRAINT assignment_submissions_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id),
  CONSTRAINT assignment_submissions_graded_by_fkey FOREIGN KEY (graded_by) REFERENCES public.teachers(id)
);
CREATE TABLE public.assignments (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  teacher_id uuid NOT NULL,
  subject_id uuid NOT NULL,
  section_id uuid NOT NULL,
  title character varying NOT NULL,
  description text,
  assignment_type character varying NOT NULL CHECK (assignment_type::text = ANY (ARRAY['homework'::character varying, 'project'::character varying, 'essay'::character varying, 'presentation'::character varying, 'research'::character varying, 'lab'::character varying, 'other'::character varying]::text[])),
  submission_type character varying NOT NULL CHECK (submission_type::text = ANY (ARRAY['file_upload'::character varying, 'text_entry'::character varying, 'link'::character varying, 'physical'::character varying]::text[])),
  total_points integer NOT NULL DEFAULT 100,
  due_date timestamp with time zone NOT NULL,
  allow_late_submission boolean DEFAULT false,
  late_penalty integer DEFAULT 0,
  require_plagiarism_check boolean DEFAULT false,
  status character varying NOT NULL DEFAULT 'draft'::character varying CHECK (status::text = ANY (ARRAY['draft'::character varying, 'published'::character varying, 'archived'::character varying]::text[])),
  attachments jsonb DEFAULT '[]'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  published_at timestamp with time zone,
  view_count integer DEFAULT 0,
  submission_count integer DEFAULT 0,
  CONSTRAINT assignments_pkey PRIMARY KEY (id),
  CONSTRAINT assignments_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id),
  CONSTRAINT assignments_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id),
  CONSTRAINT assignments_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.sections(id)
);
CREATE TABLE public.developers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL UNIQUE,
  developer_id character varying UNIQUE,
  full_name character varying NOT NULL,
  email character varying NOT NULL UNIQUE,
  role character varying DEFAULT 'developer'::character varying CHECK (role::text = 'developer'::text),
  specialization text,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT developers_pkey PRIMARY KEY (id)
);
CREATE TABLE public.enrollments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  student_id uuid NOT NULL,
  section_id uuid NOT NULL,
  subject_id uuid NOT NULL,
  enrolled_at timestamp with time zone DEFAULT now(),
  status character varying DEFAULT 'active'::character varying CHECK (status::text = ANY (ARRAY['active'::character varying, 'dropped'::character varying, 'completed'::character varying]::text[])),
  final_grade numeric,
  enrollment_method character varying DEFAULT 'teacher_added'::character varying CHECK (enrollment_method::text = ANY (ARRAY['self_enrolled'::character varying, 'teacher_added'::character varying]::text[])),
  added_by_teacher_id uuid,
  CONSTRAINT enrollments_pkey PRIMARY KEY (id),
  CONSTRAINT enrollments_added_by_teacher_id_fkey FOREIGN KEY (added_by_teacher_id) REFERENCES public.teachers(id),
  CONSTRAINT enrollments_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id),
  CONSTRAINT enrollments_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.sections(id),
  CONSTRAINT enrollments_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id)
);
CREATE TABLE public.grading_results (
  id integer NOT NULL DEFAULT nextval('grading_results_id_seq'::regclass),
  uploaded_assessment_id integer,
  answer_key_id integer,
  student_name character varying NOT NULL,
  assessment_title character varying NOT NULL,
  subject character varying NOT NULL,
  total_questions integer NOT NULL,
  correct_answers integer NOT NULL,
  incorrect_answers integer NOT NULL,
  score numeric NOT NULL,
  max_score numeric NOT NULL,
  percentage numeric NOT NULL,
  letter_grade character varying,
  question_breakdown jsonb NOT NULL,
  strengths jsonb,
  weaknesses jsonb,
  recommendations jsonb,
  detailed_analysis text,
  ai_used boolean DEFAULT false,
  ai_model character varying,
  ai_confidence numeric,
  processing_time numeric,
  grading_method character varying DEFAULT 'rule-based'::character varying,
  graded_at timestamp with time zone DEFAULT now(),
  reviewed_by integer,
  reviewed_at timestamp with time zone,
  CONSTRAINT grading_results_pkey PRIMARY KEY (id),
  CONSTRAINT grading_results_uploaded_assessment_id_fkey FOREIGN KEY (uploaded_assessment_id) REFERENCES public.uploaded_assessments(id),
  CONSTRAINT grading_results_answer_key_id_fkey FOREIGN KEY (answer_key_id) REFERENCES public.answer_keys(id)
);
CREATE TABLE public.login_attempts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL,
  ip_address text,
  user_agent text,
  success boolean DEFAULT false,
  failure_reason text,
  attempted_at timestamp with time zone DEFAULT now(),
  CONSTRAINT login_attempts_pkey PRIMARY KEY (id),
  CONSTRAINT login_attempts_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.message_attachments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  message_id uuid NOT NULL,
  file_name text NOT NULL,
  file_path text NOT NULL,
  file_url text NOT NULL,
  file_type text NOT NULL,
  file_size bigint,
  mime_type text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT message_attachments_pkey PRIMARY KEY (id)
);
CREATE TABLE public.message_reads (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  message_id uuid NOT NULL,
  reader_id uuid NOT NULL,
  read_at timestamp with time zone DEFAULT now(),
  CONSTRAINT message_reads_pkey PRIMARY KEY (id),
  CONSTRAINT message_reads_message_id_fkey FOREIGN KEY (message_id) REFERENCES public.messages(id)
);
CREATE TABLE public.messages (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  section_id uuid NOT NULL,
  sender_id uuid NOT NULL,
  recipient_id uuid,
  message_text text NOT NULL,
  message_type character varying DEFAULT 'direct'::character varying CHECK (message_type::text = ANY (ARRAY['direct'::character varying, 'announcement'::character varying]::text[])),
  file_url text,
  is_read boolean DEFAULT false,
  read_at timestamp with time zone,
  sent_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT messages_pkey PRIMARY KEY (id),
  CONSTRAINT messages_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.sections(id)
);
CREATE TABLE public.password_history (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL,
  password_hash text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT password_history_pkey PRIMARY KEY (id),
  CONSTRAINT password_history_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.processing_logs (
  id integer NOT NULL DEFAULT nextval('processing_logs_id_seq'::regclass),
  uploaded_assessment_id integer,
  step character varying NOT NULL,
  status character varying NOT NULL,
  message text,
  error_details jsonb,
  started_at timestamp with time zone DEFAULT now(),
  completed_at timestamp with time zone,
  duration numeric,
  CONSTRAINT processing_logs_pkey PRIMARY KEY (id),
  CONSTRAINT processing_logs_uploaded_assessment_id_fkey FOREIGN KEY (uploaded_assessment_id) REFERENCES public.uploaded_assessments(id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  auth_user_id uuid NOT NULL UNIQUE,
  full_name character varying NOT NULL,
  email character varying NOT NULL UNIQUE,
  role character varying NOT NULL CHECK (role::text = ANY (ARRAY['student'::character varying, 'teacher'::character varying]::text[])),
  profile_photo text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  email_verified boolean DEFAULT false,
  failed_login_attempts integer DEFAULT 0,
  locked_until timestamp with time zone,
  last_login_attempt timestamp with time zone,
  password_changed_at timestamp with time zone DEFAULT now(),
  verification_token text,
  token_expires_at timestamp with time zone,
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_auth_user_id_fkey FOREIGN KEY (auth_user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.question_answers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  question_id uuid NOT NULL UNIQUE,
  correct_answer text NOT NULL,
  case_sensitive boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT question_answers_pkey PRIMARY KEY (id),
  CONSTRAINT question_answers_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.quiz_questions(id)
);
CREATE TABLE public.question_options (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  question_id uuid NOT NULL,
  option_number integer NOT NULL CHECK (option_number > 0),
  option_text text NOT NULL,
  is_correct boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT question_options_pkey PRIMARY KEY (id),
  CONSTRAINT question_options_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.quiz_questions(id)
);
CREATE TABLE public.quiz_attempts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  quiz_id uuid NOT NULL,
  student_id uuid NOT NULL,
  attempt_number integer NOT NULL DEFAULT 1 CHECK (attempt_number > 0),
  started_at timestamp with time zone DEFAULT now(),
  submitted_at timestamp with time zone,
  time_taken_minutes integer,
  total_score numeric DEFAULT 0.00,
  max_score numeric NOT NULL,
  percentage numeric DEFAULT 0.00 CHECK (percentage >= 0::numeric AND percentage <= 100::numeric),
  status USER-DEFINED DEFAULT 'in_progress'::attempt_status,
  auto_graded boolean DEFAULT false,
  manually_reviewed boolean DEFAULT false,
  teacher_feedback text,
  graded_by uuid,
  graded_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT quiz_attempts_pkey PRIMARY KEY (id),
  CONSTRAINT quiz_attempts_quiz_id_fkey FOREIGN KEY (quiz_id) REFERENCES public.quizzes(id)
);
CREATE TABLE public.quiz_questions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  quiz_id uuid NOT NULL,
  question_number integer NOT NULL CHECK (question_number > 0),
  question_type USER-DEFINED NOT NULL,
  question_text text NOT NULL,
  points numeric DEFAULT 1.00 CHECK (points > 0::numeric),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT quiz_questions_pkey PRIMARY KEY (id),
  CONSTRAINT quiz_questions_quiz_id_fkey FOREIGN KEY (quiz_id) REFERENCES public.quizzes(id)
);
CREATE TABLE public.quiz_results (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  quiz_id uuid NOT NULL,
  student_id uuid NOT NULL,
  best_attempt_id uuid,
  best_score numeric DEFAULT 0.00,
  best_percentage numeric DEFAULT 0.00,
  total_attempts integer DEFAULT 0,
  latest_attempt_date timestamp with time zone,
  status USER-DEFINED DEFAULT 'not_taken'::result_status,
  finalized boolean DEFAULT false,
  visible_to_student boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT quiz_results_pkey PRIMARY KEY (id),
  CONSTRAINT quiz_results_quiz_id_fkey FOREIGN KEY (quiz_id) REFERENCES public.quizzes(id),
  CONSTRAINT quiz_results_best_attempt_id_fkey FOREIGN KEY (best_attempt_id) REFERENCES public.quiz_attempts(id)
);
CREATE TABLE public.quizzes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  subject_id uuid NOT NULL,
  section_id uuid NOT NULL,
  teacher_id uuid NOT NULL,
  title character varying NOT NULL,
  description text,
  number_of_questions integer NOT NULL CHECK (number_of_questions > 0),
  has_time_limit boolean DEFAULT false,
  time_limit_minutes integer CHECK (time_limit_minutes IS NULL OR time_limit_minutes > 0),
  attempts_allowed integer DEFAULT 1 CHECK (attempts_allowed > 0),
  shuffle_questions boolean DEFAULT false,
  shuffle_options boolean DEFAULT false,
  start_date timestamp with time zone,
  end_date timestamp with time zone,
  status USER-DEFINED DEFAULT 'draft'::quiz_status,
  quiz_code character varying UNIQUE,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT quizzes_pkey PRIMARY KEY (id)
);
CREATE TABLE public.sections (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL,
  subject_id uuid NOT NULL,
  section_code character varying NOT NULL UNIQUE,
  max_students integer DEFAULT 40,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT sections_pkey PRIMARY KEY (id),
  CONSTRAINT sections_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id)
);
CREATE TABLE public.security_events (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL,
  event_type text NOT NULL,
  ip_address text,
  user_agent text,
  details jsonb,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT security_events_pkey PRIMARY KEY (id),
  CONSTRAINT security_events_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.student_answers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  attempt_id uuid NOT NULL,
  question_id uuid NOT NULL,
  selected_option_id uuid,
  answer_text text,
  is_correct boolean DEFAULT false,
  points_earned numeric DEFAULT 0.00,
  points_possible numeric NOT NULL,
  teacher_comment text,
  answered_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT student_answers_pkey PRIMARY KEY (id),
  CONSTRAINT student_answers_attempt_id_fkey FOREIGN KEY (attempt_id) REFERENCES public.quiz_attempts(id),
  CONSTRAINT student_answers_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.quiz_questions(id),
  CONSTRAINT student_answers_selected_option_id_fkey FOREIGN KEY (selected_option_id) REFERENCES public.question_options(id)
);
CREATE TABLE public.students (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL UNIQUE,
  student_id character varying NOT NULL UNIQUE,
  full_name character varying NOT NULL,
  email character varying NOT NULL UNIQUE,
  grade_level integer NOT NULL CHECK (grade_level >= 7 AND grade_level <= 12),
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT students_pkey PRIMARY KEY (id),
  CONSTRAINT students_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.subjects (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL,
  grade_level integer NOT NULL CHECK (grade_level >= 1 AND grade_level <= 10),
  teacher_id uuid NOT NULL,
  description text,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT subjects_pkey PRIMARY KEY (id),
  CONSTRAINT subjects_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id)
);
CREATE TABLE public.teachers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL UNIQUE,
  employee_id character varying UNIQUE,
  full_name character varying NOT NULL,
  email character varying NOT NULL UNIQUE,
  department character varying,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT teachers_pkey PRIMARY KEY (id),
  CONSTRAINT teachers_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.uploaded_assessments (
  id integer NOT NULL DEFAULT nextval('uploaded_assessments_id_seq'::regclass),
  answer_key_id integer,
  original_filename character varying,
  file_path character varying,
  file_size integer,
  assessment_title character varying NOT NULL,
  subject character varying NOT NULL,
  assessment_data jsonb NOT NULL,
  uploaded_at timestamp with time zone DEFAULT now(),
  processed_at timestamp with time zone,
  CONSTRAINT uploaded_assessments_pkey PRIMARY KEY (id),
  CONSTRAINT uploaded_assessments_answer_key_id_fkey FOREIGN KEY (answer_key_id) REFERENCES public.answer_keys(id)
);