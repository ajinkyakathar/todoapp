TodoApp – Offline-first Sync Queue
🔍 Overview

This project demonstrates an offline-first mobile application built using Flutter. The app ensures that users can interact with data even without internet connectivity, while maintaining a reliable synchronization mechanism with a remote backend (Firebase Firestore).

The focus of this implementation is on durability, retry handling, idempotency, and real-world sync behavior.

🚀 Features
✅ Local-first UX

Todos are loaded instantly from SQLite (local database)

No loading delay even when offline

✅ Offline Writes

Add Todo (offline supported)

Mark Todo complete (offline supported)

Actions are stored in a persistent sync queue

✅ Sync Queue

All actions stored in SQLite

Queue persists across app restarts

Each action processed sequentially

✅ Retry Mechanism

Each API call retries once on failure

Basic backoff implemented using delay

✅ Idempotency

Firestore document ID used for writes

Ensures no duplicate data even on retries

✅ Conflict Resolution

Implemented Last Write Wins

Based on latest updatedAt timestamp

✅ Auto Sync

Sync triggered automatically when internet is restored

✅ Observability (Logs)

Queue size tracking

Sync success/failure logs

Retry logs

Sync summary (success/failure count)

⭐ Bonus Features

TTL cache (5 minutes)

Unit test for idempotency key

🧠 Approach

The app follows an offline-first architecture:

Data is always read from local SQLite database

User actions are applied locally first

Each action is added to a sync queue

Sync service processes queue when internet is available

Retry mechanism ensures reliability

⚖️ Trade-offs

SQLite used instead of Hive for structured storage

Basic retry implemented instead of exponential backoff

Used overwrite strategy instead of complex merge logic

⚠️ Limitations

No background sync service

No queue deduplication for repeated updates

Retry logic is simple (single retry)

🚀 Future Improvements

Exponential backoff retry

Background sync worker

Queue deduplication

UI sync indicators

📊 Verification Evidence
🔹 Scenario 1: Offline Add Todo

📸 Screenshot:



Logs:

[QUEUE] Added: ADD_TODO
[QUEUE] Current size: 1
🔹 Scenario 2: Offline Toggle Complete

📸 Screenshot:



Logs:

[QUEUE] Added: UPDATE_TODO
🔹 Scenario 3: Retry Mechanism

📸 Screenshot:



Logs:

[SYNC] Failed → retrying
[SYNC] Retry success
🔹 Scenario 4: Sync Completion

📸 Screenshot:



Logs:

[SYNC] Pending items: 0
🔹 Scenario 5: TTL Cache

📸 Screenshot:



Logs:

[CACHE] TTL expired → should fetch from server
🧪 Unit Test

Verified idempotency key generation

🤖 AI Prompt Log

(Include your AI prompt log here — already prepared)

🛠 Tech Stack

Flutter

SQLite (sqflite)

Firebase Firestore

Connectivity Plus
