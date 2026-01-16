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