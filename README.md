# Knowledge Exchange Platform Smart Contract

A blockchain-based system for connecting students with mentors for safe knowledge sharing.

## Features

- Mentor and student registration
- Session scheduling and management
- Completion tracking
- Rating system for mentors
- Expertise matching
- Mentor availability control

## Contract Functions

### Public Functions

- `register-as-mentor` - Register as a mentor with expertise
- `register-as-student` - Register as a student with interests
- `schedule-session` - Schedule a mentoring session
- `complete-session` - Mark session as completed
- `rate-session` - Rate a completed session (1-5 stars)
- `update-mentor-status` - Update mentor availability

### Read-Only Functions

- `get-mentor` - Get mentor profile
- `get-student` - Get student profile
- `get-session` - Get session details
- `get-mentor-rating` - Calculate mentor's average rating
- `get-session-nonce` - Get current session counter

## Usage

Deploy with Clarinet to facilitate student-mentor connections.