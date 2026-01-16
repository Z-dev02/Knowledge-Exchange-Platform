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