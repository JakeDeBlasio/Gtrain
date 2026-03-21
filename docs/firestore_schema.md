# Firestore schema

## users/{userId}
- name: string
- building: string
- account: string
- email: string
- templateIds: string[]
- createdAt: timestamp
- updatedAt: timestamp

## trainings/{trainingId}
- title: string
- description: string
- renewalIntervalMonths: number
- renewalMode: `by_completion` | `fixed_date`
- fixedMonth: number?
- fixedDay: number?
- documentName: string?
- documentUrl: string?
- documentPath: string?
- createdAt: timestamp
- updatedAt: timestamp

## templates/{templateId}
- name: string
- description: string
- trainingIds: string[]
- createdAt: timestamp
- updatedAt: timestamp

## assignments/{assignmentId}
- userId: string
- trainingId: string
- source: `manual` | `template`
- templateId: string?
- assignedAt: timestamp
- dueAt: timestamp
- completedAt: timestamp?
- updatedAt: timestamp
