# Day 2 — Interview Questions

## Technical fundamentals

1. What does "reproducible environment" actually require? Walk from `git clone` to a running
   stack and name every place non-determinism can creep in.
2. Lockfile vs. a loose `requirements.txt` — what specifically breaks without a lockfile, and
   when is that acceptable?
3. `src/` layout vs. flat layout for a Python project — what class of bug does `src/` prevent?
4. What belongs in pre-commit vs. in CI vs. in neither? Why not run the full test suite in
   pre-commit?
5. Docker `healthcheck` and `depends_on: condition: service_healthy` — what problem do they
   solve for a multi-service local stack?
6. Your CI is green. List five things that can still be broken.
7. How do you keep secrets out of a repo, and how do you recover if one is already committed
   and pushed?

## Real-world scenarios

8. A teammate says "CI takes 12 minutes, let's just skip it on hotfixes." How do you respond,
   and what would you actually change?
9. A new hire clones the repo and `make setup` fails on their machine but works on yours.
   Walk your debugging.
10. The security scan starts failing on a legitimate test fixture that contains a fake token.
    What are your options and which do you pick?
11. Leadership wants a "one-click demo environment" for a hospital pilot. What changes between
    your local compose stack and something you'd put in front of a customer?

## Explain what you built today

12. Walk me through your `Makefile` and compose stack. What starts, in what order, and how do
    you know it's healthy?
13. Show me your CI workflow. What does a red build tell a reviewer, and what does a green build
    *not* guarantee?
