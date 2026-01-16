;; Knowledge Exchange Platform Contract
;; Connecting students and mentors for safe knowledge sharing

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-found (err u100))
(define-constant err-unauthorized (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-invalid-rating (err u103))

;; Data Variables
(define-data-var session-nonce uint u0)

;; Data Maps
(define-map mentors
  principal
  {
    expertise: (string-ascii 200),
    active: bool,
    total-sessions: uint,
    rating-sum: uint,
    rating-count: uint
  }
)

(define-map students
  principal
  {
    interests: (string-ascii 200),
    active: bool,
    sessions-attended: uint
  }
)

(define-map sessions
  uint
  {
    mentor: principal,
    student: principal,
    topic: (string-ascii 100),
    scheduled-time: uint,
    completed: bool,
    rating: uint
  }
)

;; Read-only functions
(define-read-only (get-session-nonce)
  (var-get session-nonce)
)

;; Read-only functions
(define-read-only (get-mentor (mentor principal))
  (map-get? mentors mentor)
)

(define-read-only (get-student (student principal))
  (map-get? students student)
)

(define-read-only (is-mentor (user principal))
  (is-some (map-get? mentors user))
)

(define-read-only (is-student (user principal))
  (is-some (map-get? students user))
)

(define-read-only (is-mentor-active (mentor principal))
  (match (map-get? mentors mentor)
    mentor-data (get active mentor-data)
    false
  )
)

(define-read-only (is-student-active (student principal))
  (match (map-get? students student)
    student-data (get active student-data)
    false
  )
)

;; Public functions
;; #[allow(unchecked_data)]
(define-public (register-as-mentor (expertise (string-ascii 200)))
  (let
    (
      (mentor tx-sender)
    )
    (asserts! (is-none (map-get? mentors mentor)) err-already-exists)
    (map-set mentors mentor
      {
        expertise: expertise,
        active: true,
        total-sessions: u0,
        rating-sum: u0,
        rating-count: u0
      }
    )
    (ok true)
  )
)

;; #[allow(unchecked_data)]
(define-public (register-as-student (interests (string-ascii 200)))
  (let
    (
      (student tx-sender)
    )
    (asserts! (is-none (map-get? students student)) err-already-exists)
    (map-set students student
      {
        interests: interests,
        active: true,
        sessions-attended: u0
      }
    )
    (ok true)
  )
)

(define-public (update-mentor-status (active bool))
  (let
    (
      (mentor-data (unwrap! (map-get? mentors tx-sender) err-not-found))
    )
    (map-set mentors tx-sender (merge mentor-data { active: active }))
    (ok true)
  )
)

;; #[allow(unchecked_data)]
(define-public (update-mentor-expertise (new-expertise (string-ascii 200)))
  (let
    (
      (mentor-data (unwrap! (map-get? mentors tx-sender) err-not-found))
    )
    (map-set mentors tx-sender (merge mentor-data { expertise: new-expertise }))
    (ok true)
  )
)

;; #[allow(unchecked_data)]
(define-public (update-student-interests (new-interests (string-ascii 200)))
  (let
    (
      (student-data (unwrap! (map-get? students tx-sender) err-not-found))
    )
    (map-set students tx-sender (merge student-data { interests: new-interests }))
    (ok true)
  )
)

(define-public (update-student-status (active bool))
  (let
    (
      (student-data (unwrap! (map-get? students tx-sender) err-not-found))
    )
    (map-set students tx-sender (merge student-data { active: active }))
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-session (session-id uint))
  (map-get? sessions session-id)
)

(define-read-only (get-session-mentor (session-id uint))
  (match (map-get? sessions session-id)
    session (some (get mentor session))
    none
  )
)

(define-read-only (get-session-student (session-id uint))
  (match (map-get? sessions session-id)
    session (some (get student session))
    none
  )
)

(define-read-only (is-session-completed (session-id uint))
  (match (map-get? sessions session-id)
    session (get completed session)
    false
  )
)

(define-read-only (get-session-topic (session-id uint))
  (match (map-get? sessions session-id)
    session (some (get topic session))
    none
  )
)

(define-read-only (get-session-scheduled-time (session-id uint))
  (match (map-get? sessions session-id)
    session (some (get scheduled-time session))
    none
  )
)

;; Public functions
;; #[allow(unchecked_data)]
(define-public (schedule-session (mentor principal) (topic (string-ascii 100)) (scheduled-time uint))
  (let
    (
      (session-id (var-get session-nonce))
      (student tx-sender)
      (mentor-data (unwrap! (map-get? mentors mentor) err-not-found))
      (student-data (unwrap! (map-get? students student) err-not-found))
    )
    (asserts! (get active mentor-data) err-unauthorized)
    (map-set sessions session-id
      {
        mentor: mentor,
        student: student,
        topic: topic,
        scheduled-time: scheduled-time,
        completed: false,
        rating: u0
      }
    )
    (var-set session-nonce (+ session-id u1))
    (ok session-id)
  )
)

;; #[allow(unchecked_data)]
(define-public (reschedule-session (session-id uint) (new-time uint))
  (let
    (
      (session (unwrap! (map-get? sessions session-id) err-not-found))
    )
    (asserts! (or (is-eq tx-sender (get mentor session)) 
                  (is-eq tx-sender (get student session))) err-unauthorized)
    (asserts! (not (get completed session)) err-unauthorized)
    (map-set sessions session-id (merge session { scheduled-time: new-time }))
    (ok true)
  )
)

(define-public (cancel-session (session-id uint))
  (let
    (
      (session (unwrap! (map-get? sessions session-id) err-not-found))
    )
    (asserts! (or (is-eq tx-sender (get mentor session)) 
                  (is-eq tx-sender (get student session))) err-unauthorized)
    (asserts! (not (get completed session)) err-unauthorized)
    (map-delete sessions session-id)
    (ok true)
  )
)

(define-public (complete-session (session-id uint))
  (let
    (
      (session (unwrap! (map-get? sessions session-id) err-not-found))
      (mentor-data (unwrap! (map-get? mentors (get mentor session)) err-not-found))
      (student-data (unwrap! (map-get? students (get student session)) err-not-found))
    )
    (asserts! (is-eq tx-sender (get mentor session)) err-unauthorized)
    (map-set sessions session-id (merge session { completed: true }))
    (map-set mentors (get mentor session)
      (merge mentor-data { total-sessions: (+ (get total-sessions mentor-data) u1) })
    )
    (map-set students (get student session)
      (merge student-data { sessions-attended: (+ (get sessions-attended student-data) u1) })
    )
    (ok true)
  )
)