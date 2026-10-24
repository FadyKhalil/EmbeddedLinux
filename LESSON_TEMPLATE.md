# Lesson Template

Every lesson in this repo follows the same shape, so learners always know where to look.
Copy this file when you add a new lesson and delete the hints in *italics*.

---

# NN - Lesson Title

> *One sentence: what the learner will have built or understood at the end.*

| | |
|---|---|
| **Boards** | QEMU (vexpress-a9) · Raspberry Pi · BeagleBone Black *(remove the ones that don't apply)* |
| **Time** | *rough estimate, e.g. ~1 hour + build time* |
| **Previous** | [NN-1 - Title](../path/README.md) |
| **Next** | [NN+1 - Title](../path/README.md) |

## What you will learn

- *3-5 bullets, each one a concrete skill.*

## Prerequisites

- *Lessons that must be finished first.*
- *Host packages or hardware needed.*
- *Environment variables expected from earlier lessons (e.g. `CROSS_COMPILE`, `ARCH`).*

## Background

*The "why" in a few short paragraphs. A diagram helps more than a wall of text.*

## Steps

*Numbered steps. Each step: one sentence of intent, then the commands.
Put board-specific commands under `#### QEMU`, `#### Raspberry Pi`, `#### BeagleBone` sub-headings,
and keep shared commands outside them so nothing is copied three times.*

### 1. Step name

```bash
# comment explaining the command
command --flag
```

## Checkpoint

*What the learner should see when everything worked. Paste a short, real snippet of output.*

```text
expected output here
```

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| *error message* | *why* | *what to do* |

## Exercises

1. *A small task that makes the learner change something on their own.*

## Recap

- *What was built, in one or two bullets, and how it connects to the next lesson.*
