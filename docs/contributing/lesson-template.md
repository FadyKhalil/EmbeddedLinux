# Lesson Template

Every lesson in this repo follows the same shape, so learners always know where to look.
Copy this file when you add a new lesson and delete the hints in *italics*.

---

# N · Lesson Title

> *One sentence: what the learner will have built or understood at the end.*

| | |
|---|---|
| **Boards** | QEMU (vexpress-a9) · Raspberry Pi · BeagleBone Black *(remove the ones that don't apply)* |
| **Time** | *rough estimate, e.g. ~1 hour + build time* |
| **Previous** | `[N-1 · Title](../NN-folder/README.md)` |
| **Next** | `[N+1 · Title](../NN-folder/README.md)` |

## What you will learn

- *3-5 bullets, each one a concrete skill.*

## Prerequisites

- *Lessons that must be finished first.*
- *Host packages or hardware needed.*
- *Environment variables expected from earlier lessons (e.g. `CROSS_COMPILE`, `ARCH`).*

## Background

*The "why" in a few short paragraphs. A diagram helps more than a wall of text.*

*To make an animated diagram, draw an SVG next to the lesson and describe each step in a list.
On GitHub it shows as a still image with the numbered steps; on the website it plays step by step:*

```html
<figure class="el-anim">
<img src="my-diagram.svg" alt="One sentence describing the whole diagram">
<ol class="el-anim-steps">
<li>What happens in step 1.</li>
<li>What happens in step 2.</li>
</ol>
<figcaption>▶ This diagram is animated on the course website.</figcaption>
</figure>
```

*Inside the SVG (copy the `<style>` block from an existing diagram, e.g. `04-kernel/bootz.svg`):*

| Attribute | Effect |
|---|---|
| `data-active="2"` or `"2-4,6"` | Highlighted at those steps (works on a group with a `.box` and a `.title`, or on a `.mono` text) |
| `data-from="3"` | Hidden before step 3 |
| `data-until="4"` | Hidden after step 4 |
| `data-move="2:120,0 4:240,40"` | Moved by (x, y) from that step on |
| `class="only-anim"` | Hidden in the still image (for elements that would overlap without animation) |

*Keep the HTML block free of blank lines, so GitHub doesn't break it apart.*

*For notes, use GitHub's callout syntax; the website renders it as a styled box:*

```markdown
> [!TIP]
> Helpful shortcut.

> [!WARNING]
> Something that can go wrong.

> [!CAUTION]
> Something that destroys data (e.g. dd, mkfs).
```

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
