# Contributing

A good addition solves a specific support question and teaches how to interpret the result.

Use this shape:

1. Symptom and affected environment/version.
2. Smallest useful observation, with required access and expected output.
3. What different results mean and the next check.
4. Any change clearly labeled, with recovery/rollback considerations.
5. A primary documentation link.

Keep examples generic and use reserved hosts such as `example.com`. Prefer short output excerpts over full logs. Place practice data in `labs/` and explain how to reset the exercise without overwriting another database.

Before proposing a change, check links and fenced commands, and validate changed executable SQL in a disposable instance. Record the actual server version; do not describe a document review as a runtime test. MySQL and MariaDB behavior should not be treated as interchangeable.
